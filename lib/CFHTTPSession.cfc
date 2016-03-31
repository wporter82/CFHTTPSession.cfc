/**
* Handles a CFHTTP session by sending an receving cookies behind the scenes.
*/
component {
	// Pseudo constructor. Set up data structures and 
	// default values. 
	Instance = {};
	// This is the log file path used for debugging.
	Instance.LogFilePath = "";
	// Create a newline macro that is platform-independent
	NL = createObject("java","java.lang.System").getProperty("line.separator");
	// These are the cookies that get returned from the 
	// request that enable us to keep the session across 
	// different CFHttp requests. 
	Instance.Cookies = {};
	
	// The request data contains the various types of data that
	// we will send with our request. These will be both for the
	// CFHttpParam tags as well as the CFHttp property values.
	Instance.RequestData = {};
	Instance.RequestData.Url = "";
	Instance.RequestData.Referer = "";
	Instance.RequestData.UserAgent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6";
	Instance.RequestData.Params = [];
	
	/**
	* Returns an initialized component.
	* @param 	LogFilePath 	I am the full path to the log file that will be used to debug the request / response data.
	* @param 	UserAgent 		The user agent that will be used on the subseqent page requests.
	*/
	function init(string LogFilePath, string UserAgent) {
		// Check to see if we have a log file path.
		if (StructKeyExists( ARGUMENTS, "LogFilePath" )) {
			Instance.LogFilePath = LogFilePath;
		}
		
		// Check to see if we have a user agent.
		if (StructKeyExists( ARGUMENTS, "UserAgent" )) {
			SetUserAgent( UserAgent );
		}
		
		return THIS;
	}

	/**
	* Adds a CGI value. Returns THIS scope for method chaining.
	* @param 	Name 		The name of the CGI value.
	* @param 	Value 		The CGI value
	* @param 	Encoded 	Determins whether or not to encode the CGI value.
	*/
	function AddCGI(required string Name, required string Value, string Encoded="yes") {
		return AddParam(
			Type = "CGI",
			Name = Name,
			Value = Value,
			Encoded = Encoded
			);
	}
	
	/**
	* Adds a cookie value. Returns THIS scope for method chaining.
	* @param 	Name 	The name of the CGI value.
	* @param 	Value 	The CGI Value.
	*/
	function AddCookie(required string Name, required string Value) {

		return AddParam(
			Type = "Cookie",
			Name = Name,
			Value = Value
			);
	}
	
	/**
	* Adds a file value. Returns THIS scope for method chaining.
	* @param 	Name 		The name of the form field for the posted file.
	* @param 	Path 		The expanded path to the file.
	* @param 	MimeType 	The mime type of the posted file. Defaults to *unknown* mime type.
	*/
	function AddFile(required string Name, required string Path, string MimeType="application/octet-stream") {

		return AddParam(
			Type = "File",
			Name = Name,
			File = Path,
			MimeType = MimeType
			);
	}
	
	/**
	* Adds a form value. Returns THIS scope for method chaining.
	* @param Name 		The name of the form field.
	* @param Value 		The form field value.
	* @param Encoded 	Determins whether or not to encode the form value.
	*/
	function AddFormField(required string Name, required string Value, string Encoded="yes") {

		return AddParam(
			Type = "FormField",
			Name = Name,
			Value = Value,
			Encoded = Encoded
			);
	}
	
	/**
	* Adds a header value. Returns THIS scope for method chaining.
	* @param Name 	The name of the header value.
	* @param Value 	The header value.
	*/
	function AddHeader(required string Name, required string Value) {

		return AddParam(
			Type = "Header",
			Name = Name,
			Value = Value
			);
	}
	
	/**
	* Adds a CFHttpParam data point. Returns THIS scope for method chaining.
	* @param Type 		The type of data point.
	* @param Name 		The name of the data point.
	* @param Value 		The value of the data point.
	* @param File 		The expanded path to be used if the data piont is a file.
	* @param MimeType 	The mime type of the file being passed (if file is being passed).
	* @param Encoded 	The determines whether or not to encode Form Field and CGI values.
	*/
	function AddParam(
				required string Type,
				string Name,
				Value,
				string File="",
				string MimeType=""
				string Encoded="yes") {

		var LOCAL = {};
				
		// Check to see which kind of data point we are dealing 
		// with so that we can see how to create the param.
		switch(Type) {
			case "Body":
				LOCAL.Param = {
					Type = Type,
					Value = Value
				};
				break;
			
			case "CGI":
				LOCAL.Param = {
					Type = Type,
					Name = Name,
					Value = Value,
					Encoded = Encoded
				};
				break;
			
			case "Cookie":
				LOCAL.Param = {
					Type = Type,
					Name = Name,
					Value = Value
				};
				break;
			
			case "File":
				LOCAL.Param = {
					Type = Type,
					Name = Name,
					File = File,
					MimeType = MimeType
				};
				break;
			
			case "FormField":
				LOCAL.Param = {
					Type = Type,
					Name = Name,
					Value = Value,
					Encoded = Encoded
				};
				break;
			
			case "Header":
				LOCAL.Param = {
					Type = Type,
					Name = Name,
					Value = Value
				};
				break;
			
			case "Url":
				LOCAL.Param = {
					Type = Type,
					Name = Name,
					Value = Value
				};
				break;
			
			case "Xml":
				LOCAL.Param = {
					Type = Type,
					Value = Value
				};
				break;
		}
					
		// Add the parameter for the next request.
		ArrayAppend(
			Instance.RequestData.Params,
			LOCAL.Param
			);
		
		return THIS;
	}
	
	/**
	* Adds a url value. Returns THIS scope for method chaining.
	* @param Name 	The name of the header value.
	* @param Value 	The header value.
	*/
	function AddUrl(required string Name, required string Value) {

		return AddParam(
				Type = "Url",
				Name = Name,
				Value = Value
				);
	}
	
	/**
	* Uses the GET method to place the next request. Returns the CFHttp response.
	* @param GetAsBinary 	Determines how to return the file content - return as binary value.
	*/
	struct function Get(string GetAsBinary="auto") {

		return THIS.Request(
			Method = "get",
			GetAsBinary = ARGUMENTS.GetAsBinary
			);
	}
	
	/**
	* Returns the internal session cookies.
	*/
	struct function GetCookies() {

		return Instance.Cookies;
	}
	
	/**
	* I log the given request to the log file, if it exists.
	* @param Method 		The type of request to make.
	* @param GetAsBinary 	Determines how to return body.
	*/
	void function LogRequestData(string Method="get", string GetAsBinary="auto") {
		// Check to see if the log file path is set. If not, 
		// just return out. 
		if (!Len( Instance.LogFilePath )) {
			return;
		}
		
		

		// Create a data buffer for the request data.
		var Output = "";
		Output &= "+----------------------------------------------+" & NL;
		Output &= "REQUEST: " & TimeFormat( Now(), "HH:mm:ss:L" ) & NL;
		Output &= "URL: " & Instance.RequestData.Url & NL;
		Output &= "Method: " & Method & NL;
		Output &= "UserAgent: " & Instance.RequestData.UserAgent & NL;
		Output &= "GetAsBinary: " & GetAsBinary & NL;
		Output &= "-- Cookies --" & NL;
		for(var Key in Instance.Cookies) {
			Output &= Key & ": " & Instance.Cookies[ Key ].Value & NL;
		}
		Output &= "-- Headers --" & NL;
		Output &= "Referer: " & Instance.RequestData.Referer & NL;
		Output &= "-- Params --" & NL;
		for(var Param in Instance.RequestData.Params) {
			for(var ParamKey in Param) {
				Output &= ParamKey & " : " & Param[ ParamKey ] & NL;
			}
			Output &= NL;
		}
		
		// Clean up request data.
		Output = REReplace(
			Output,
			"(?m)^[ \t]+|[ \t]+$",
			"",
			"all"
			);
			
		// Write the output to log file.
		var fileObj = FileOpen(Instance.LogFilePath, "append");
		fileWriteLine(fileObj,Output);
		fileClose(fileObj);
		
		// Return out.
		return;
	}
		
	/**	
	* I log the given response to the log file, if it exists.
	* @param Response 	I am the CFHTTP response object.
	*/
	void function LogResponseData(required struct Response) {
		/*
			Check to see if the log file path is set. If not, 
			just return out. 
		*/
		if (NOT Len( Instance.LogFilePath )) {
			return;
		}
		
		// Create a data buffer for the request data.
		var Output = "";
	
		Output &= "+----------------------------------------------+" & NL;
		Output &= "RESPONSE: " & TimeFormat( Now(), "HH:mm:ss:L" ) & NL;
		Output &= "-- Cookies --" & NL;
		
		if (StructKeyExists( Response.ResponseHeader, "Set-Cookie" )) {
			if (IsSimpleValue( Response.ResponseHeader[ "Set-Cookie" ] )) {
				Output &= Response.ResponseHeader[ "Set-Cookie" ] & NL;
			}else {
				for(var Cookie in Response.ResponseHeader[ 'Set-Cookie' ]) {
					Output &= Cookie & NL;
				}
			}
		}
		
		Output &= "-- Redirect --" & NL;
		
		if (StructKeyExists( Response.ResponseHeader, "Location" )) {
			Output &= Response.ResponseHeader.Location & NL;
		}
		
		// Clean up seponse data.
		Output = REReplace(
			Output,
			"(?m)^[ \t]+|[ \t]+$",
			"",
			"all"
			);
			
		// Write the output to log file.
		var fileObj = FileOpen(Instance.LogFilePath, "append");
		fileWriteLine(fileObj,Output);
		fileClose(fileObj);
		
		// Return out.
		return;
	}
	
	/**	
	* Sets up the object for a new request. Returns THIS scope for method chaining.
	* @param Url 		The URL for the new request.
	* @param Referer 	The referring URL for the request. By default, it will be the same directory as the target URL.
	*/
	function NewRequest(required string Url, string Referer="") {

		/*
			Before we store the URL, let's check to see if we 
			already had one in memory. If so, then we can use 
			that for a referer (which we then have the option 
			to override. The point here is that each URL can 
			be the referer for the next one.
		*/
		if (Len( Instance.RequestData.Url )) {
			/* 
				Store the previous url as the next referer. We 
				may override this in a second.
			*/
			Instance.RequestData.Referer = Instance.RequestData.Url;
		}
		
		// Store the passed-in url.
		Instance.RequestData.Url = Url;
		
		/*
			Check to see if the referer was passed in. Since we 
			are using previous URLs as the next referring url, 
			we only want to store the passed in value if it has 
			length
		*/
		if (Len( Referer )) {
			// Store manually set referer.
			Instance.RequestData.Referer = Referer;
		}
		
		// Clear the request data.
		Instance.RequestData.Params = [];
		
		// Return This reference.
		return THIS;
	}
	
	/**	
	* Uses the POST method to place the next request. Returns the CFHttp response.
	* @param GetAsBinary 	Determines how to return the file content - return as binary value.
	*/
	struct function Post(string GetAsBinary="auto") {
		// Return response.
		return THIS.Request(
			Method = "post",
			GetAsBinary = GetAsBinary
			);
	}
	
	/**	
	* Performs the CFHttp request and returns the response.
	* @param Method 		
	* @param GetAsBinary 	
	*/
	struct function Request(string Method="get", string GetAsBinary="auto") {
		var Get = {};
		
		/*
			Before we make the actual request, log request data 
			for debugging pursposes. Pass the same arguments to 
			the logging method.
		*/
		LogRequestData( ArgumentCollection = ARGUMENTS );
			
		/* 
			Make request. When the request comes back, we don't 
			want to follow any redirects. We want this to be 
			done manually.
		*/
		var httpSvc = new http();
		httpSvc.setUrl(Instance.RequestData.Url);
		httpSvc.setMethod(Method);
		httpSvc.setUseragent(Instance.RequestData.UserAgent);
		httpSvc.setGetasbinary(GetAsBinary);
		httpSvc.setRedirect("no");

		/*
			In order to maintain the user's session, we are 
			going to resend any cookies that we have stored 
			internally. 
		*/
		for(var Cookie in Instance.Cookies) {
			httpSvc.addParam(type="cookie", name=Cookie, value=Instance.Cookies[ Cookie ].Value);
		}

		/* 
			At this point, we have done everything that we 
			need to in order to maintain the user's session 
			across CFHttp requests. Now we can go ahead and 
			pass along any addional data that has been specified.
		*/
		httpSvc.addParam(type="header", name="referer", value=Instance.RequestData.Referer);
			
		// Loop over params.
		for(var Param in Instance.RequestData.Params) {
			httpSvc.addParam(argumentCollection=Param);
		}


		Get = httpSvc.send().getPrefix();
		
		// Debug the response.
		LogResponseData( Get );
					
		/*
			Store the response cookies into our internal cookie 
			storage struct.
		*/
		StoreResponseCookies( Get );
		
		/* 
			Check to see if there was some sort of redirect 
			returned with the repsonse. If there was, we want 
			to redirect with the proper value. 
		*/
		if (StructKeyExists( Get.ResponseHeader, "Location" )) {
			/*
				There was a response, so now we want to do a 
				recursive call to return the next page. When 
				we do this, make sure we have the proper URL 
				going out. 
			*/
			if (REFindNoCase( 
						"^http", 
						Get.ResponseHeader.Location
						)) {
				// Proper url.
				return NewRequest( Get.ResponseHeader.Location )
					.Get();
			// Check for absolute-relative URLs.
			} else if (REFindNoCase( 
							"^[\\\/]", 
							Get.ResponseHeader.Location
							)) {
				/*
					With an absolute-relative URL, we need to 
					append the given location to the DOMAIN of 
					our current url.
				*/
				return NewRequest( 
						REReplace(
							Instance.RequestData.Url,
							"^(https?://[^/]+).*",
							"\1",
							"one"
							) & 
						Get.ResponseHeader.Location 
					)
					.Get();
			} else {
				/*
					Non-root url. We need to append the current 
					redirect url to our last URL for relative 
					path traversal.
				*/
				return NewRequest( 
						GetDirectoryFromPath( Instance.RequestData.Url ) & 
						Get.ResponseHeader.Location 
					)
					.Get();
			}
		} else {
			/*
				No redirect, so just return the current 
				request response object.
			*/
			return Get;
		}
	}
	
	/**	
	* Sets the body data of next request. Returns THIS scope for method chaining.
	* @param Value 	The data body.
	*/
	function SetBody(Value) {
		// Set parameter and return This reference.
		return AddParam(
			Type = "Body",
			Name = "",
			Value = Value
			);
	}
	
	/**	
	* Sets the user agent for next request. Returns THIS scope for method chaining.
	* @param Value 	The user agent that will be used on the subseqent page requests.
	*/
	function SetUserAgent(string Value) {
		// Store value.
		Instance.RequestData.UserAgent = Value;
		
		// Return This reference.
		return THIS;
	}
	
	/**	
	* Sets the XML body data of next request. Returns THIS scope for method chaining.
	* @param Value 	The data body.
	*/
	function SetXml(Value) {
		// Set parameter and return This reference.
		return AddParam(
			Type = "Xml",
			Name = "",
			Value = Value
			);
	}
		
	/**	
	* This parses the response of a CFHttp call and puts the cookies into a struct.
	* @param Response 	The response of a CFHttp call.
	*/
	void function StoreResponseCookies(required struct Response) {
		/*
			Create the default struct in which we will hold 
			the response cookies. This struct will contain structs
			and will be keyed on the name of the cookie to be set.
		*/
		var Cookies = {};
		
		/*
			Get a reference to the cookies that were returned 
			from the page request. This will give us an numericly 
			indexed struct of cookie strings (which we will have
			to parse out for values). BUT, check to make sure
			that cookies were even sent in the response. If they
			were not, then there is not work to be done.	
		*/
		if (NOT StructKeyExists(
					Response.ResponseHeader,
					"Set-Cookie"
					)) {
			// No cookies were send back so just return.
			return;
		}
		
		/*
			ASSERT: We know that cookie were returned in the page
			response and that they are available at the key, 
			"Set-Cookie" of the reponse header.
		*/
		
		/*
			The cookies might be coming back as a struct or they
			might be coming back as a string. If there is only 
			ONE cookie being retunred, then it comes back as a 
			string. If that is the case, then re-store it as a 
			struct. 
		*/
		var ReturnedCookies = {};
		if (IsSimpleValue( Response.ResponseHeader[ "Set-Cookie" ] )) {
			ReturnedCookies[ 1 ] = Response.ResponseHeader[ "Set-Cookie" ];
		} else {
			// Get a reference to the cookies struct.
			ReturnedCookies = Response.ResponseHeader[ "Set-Cookie" ];
			
		}
		
		/*
			At this point, we know that no matter how the 
			cookies came back, we have the cookies in a 
			structure of cookie values. 
		*/
		for(var Cookie in ReturnedCookies) {
			/*
				As we loop through the cookie struct, get 
				the cookie string we want to parse.
			*/
			var CookieString = ReturnedCookies [ Cookie ];
			
			/*
				For each of these cookie strings, we are going 
				to need to parse out the values. We can treat 
				the cookie string as a semi-colon delimited list.
			*/
			for(var Index=1; Index <= ListLen( CookieString, ';' ); Index++) {
				// Get the name-value pair.
				var Pair = ListGetAt(
					CookieString,
					Index,
					";"
					);
				/*
					Get the name as the first part of the pair 
					sepparated by the equals sign.
				*/
				var Name = ListFirst( Pair, "=" );
				var Value = "";
			
				/*
					Check to see if we have a value part. Not all
					cookies are going to send values of length, 
					which can throw off ColdFusion.
				*/
				if (ListLen( Pair, "=" ) GT 1) {
					// Grab the rest of the list.
					Value = ListRest( Pair, "=" );
				} else {
					/*
						Since ColdFusion did not find more than 
						one value in the list, just get the empty 
						string as the value.
					*/
					Value = "";
				}
			
				/*
					Now that we have the name-value data values, 
					we have to store them in the struct. If we 
					are looking at the first part of the cookie 
					string, this is going to be the name of the 
					cookie and it's struct index.
				*/
				if (Index EQ 1) {
					/*
						Create a new struct with this cookie's name
						as the key in the return cookie struct.
					*/
					Cookies[ Name ] = {};
					
					/*
						Now that we have the struct in place, lets
						get a reference to it so that we can refer 
						to it in subseqent loops.
					*/
					Cookie = Cookies[ Name ];
					
					// Store the value of this cookie.
					Cookie.Value = Value;
				
					/*
						Now, this cookie might have more than just
						the first name-value pair. Let's create an 
						additional attributes struct to hold those 
						values.
					*/
					Cookie.Attributes = {};
				} else {
					/*
						For all subseqent calls, just store the 
						name-value pair into the established 
						cookie's attributes strcut.
					*/
					Cookie.Attributes[ Name ] = Value;
				}
			}
		}
		
		/*
			Now that we have all the response cookies in a 
			struct, let's append those cookies to our internal 
			response cookies. 
		*/
		StructAppend( 
			Instance.Cookies,
			Cookies
			);
		
		// Return out.
		return;
	}
	
}