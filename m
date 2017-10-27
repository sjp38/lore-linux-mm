Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7F776B0253
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 15:34:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u70so5543993pfa.2
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 12:34:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id l87si5735175pfj.597.2017.10.27.12.34.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Oct 2017 12:34:35 -0700 (PDT)
Date: Fri, 27 Oct 2017 12:34:34 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] bug:roundup_pow_of_two(size) will return 0     when size
 > 2^63 because of overflow problem. fix:when size > max, return max. (when
 newsize > max will return max originally)
Message-ID: <20171027193434.GA19225@bombadil.infradead.org>
References: <SG2PR01MB13282FE183A0EA24DE95EB84C05A0@SG2PR01MB1328.apcprd01.prod.exchangelabs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <SG2PR01MB13282FE183A0EA24DE95EB84C05A0@SG2PR01MB1328.apcprd01.prod.exchangelabs.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ? ?? <weilongpingshu@hotmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>


You messed up the email so that the explanation went into the subject line ...


Subject: [PATCH] bug:roundup_pow_of_two(size) will return 0     when size >
        2^63 because of overflow problem. fix:when size > max, return max.
        (when newsize > max will return max originally)

Have you observed this happening?  How did req_size become larger than 2^63?

On Fri, Oct 27, 2017 at 01:32:45PM +0000, ? ?? wrote:
> Signed-off-by: LongPing.WEI <weilongpingshu@hotmail.com>
> ---
>  mm/readahead.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/readahead.c b/mm/readahead.c
> index c4ca702..4941f04 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -248,7 +248,12 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
>   */
>  static unsigned long get_init_ra_size(unsigned long size, unsigned long max)
>  {
> -	unsigned long newsize = roundup_pow_of_two(size);
> +	unsigned long newsize;
> +
> +	if (size > max)
> +		return max;
> +
> +	newsize = roundup_pow_of_two(size);
>  
>  	if (newsize <= max / 32)
>  		newsize = newsize * 4;
> -- 
> 2.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
