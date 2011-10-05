Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id BF579900149
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 02:58:36 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p956wXx2008062
	for <linux-mm@kvack.org>; Tue, 4 Oct 2011 23:58:33 -0700
Received: from ywp17 (ywp17.prod.google.com [10.192.16.17])
	by hpaq2.eem.corp.google.com with ESMTP id p956wVE4030184
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 4 Oct 2011 23:58:32 -0700
Received: by ywp17 with SMTP id 17so1615315ywp.13
        for <linux-mm@kvack.org>; Tue, 04 Oct 2011 23:58:31 -0700 (PDT)
Date: Tue, 4 Oct 2011 23:58:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFCv3][PATCH 1/4] replace string_get_size() arrays
In-Reply-To: <20111001000856.DD623081@kernel>
Message-ID: <alpine.DEB.2.00.1110042352410.16359@chino.kir.corp.google.com>
References: <20111001000856.DD623081@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, James.Bottomley@hansenpartnership.com, hpa@zytor.com

On Fri, 30 Sep 2011, Dave Hansen wrote:

> 
> Instead of explicitly storing the entire string for each
> possible units, just store the thing that varies: the
> first character.
> 
> We have to special-case the 'B' unit (index==0).
> 
> This shaves about 100 bytes off of my .o file.
> 

It shaved more than that from my .o file, but should we really be 
optimizing this for text size?  __unit_str() would be replacing what used 
to be a read of stack-allocated memory and make string_get_size() more 
expensive of a function and more complex code.

> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> ---
> 
>  linux-2.6.git-dave/lib/string_helpers.c |   30 ++++++++++++++++++++----------
>  1 file changed, 20 insertions(+), 10 deletions(-)
> 
> diff -puN lib/string_helpers.c~string_get_size-pow2 lib/string_helpers.c
> --- linux-2.6.git/lib/string_helpers.c~string_get_size-pow2	2011-09-30 16:50:31.628981352 -0700
> +++ linux-2.6.git-dave/lib/string_helpers.c	2011-09-30 17:04:02.211607364 -0700
> @@ -8,6 +8,23 @@
>  #include <linux/module.h>
>  #include <linux/string_helpers.h>
>  
> +static const char byte_units[] = "_KMGTPEZY";
> +
> +static char *__units_str(enum string_size_units unit, char *buf, int index)
> +{
> +	int place = 0;
> +
> +	/* index=0 is plain 'B' with no other unit */
> +	if (index) {
> +		buf[place++] = byte_units[index];
> +		if (unit == STRING_UNITS_2)
> +			buf[place++] = 'i';
> +	}
> +	buf[place++] = 'B';
> +	buf[place++] = '\0';
> +	return buf;
> +}
> +
>  /**
>   * string_get_size - get the size in the specified units
>   * @size:	The size to be converted
> @@ -23,26 +40,19 @@
>  int string_get_size(u64 size, const enum string_size_units units,
>  		    char *buf, int len)
>  {
> -	const char *units_10[] = { "B", "kB", "MB", "GB", "TB", "PB",
> -				   "EB", "ZB", "YB", NULL};
> -	const char *units_2[] = {"B", "KiB", "MiB", "GiB", "TiB", "PiB",
> -				 "EiB", "ZiB", "YiB", NULL };
> -	const char **units_str[] = {
> -		[STRING_UNITS_10] =  units_10,
> -		[STRING_UNITS_2] = units_2,
> -	};
>  	const unsigned int divisor[] = {
>  		[STRING_UNITS_10] = 1000,
>  		[STRING_UNITS_2] = 1024,
>  	};
>  	int i, j;
>  	u64 remainder = 0, sf_cap;
> +	char unit_buf[4];
>  	char tmp[8];
>  
>  	tmp[0] = '\0';
>  	i = 0;
>  	if (size >= divisor[units]) {
> -		while (size >= divisor[units] && units_str[units][i]) {
> +		while (size >= divisor[units] && (i < strlen(byte_units))) {
>  			remainder = do_div(size, divisor[units]);
>  			i++;
>  		}
> @@ -61,7 +71,7 @@ int string_get_size(u64 size, const enum
>  	}
>  
>  	snprintf(buf, len, "%lld%s %s", (unsigned long long)size,
> -		 tmp, units_str[units][i]);
> +		 tmp, __units_str(units, unit_buf, i));
>  
>  	return 0;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
