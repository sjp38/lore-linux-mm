Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0916D6B000C
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 13:43:22 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 3so2732898pla.1
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 10:43:22 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b1si1689278pgn.191.2018.02.09.10.43.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 10:43:21 -0800 (PST)
Subject: Re: [PATCH v2] mm: Split page_type out from _map_count
References: <20180207213047.6148-1-willy@infradead.org>
 <20180209105132.hhkjoijini3f74fz@node.shutemov.name>
 <20180209134942.GB16666@bombadil.infradead.org>
 <20180209152848.GF16666@bombadil.infradead.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7c5414ce-fece-b908-bebc-22fa15fc783c@intel.com>
Date: Fri, 9 Feb 2018 10:43:19 -0800
MIME-Version: 1.0
In-Reply-To: <20180209152848.GF16666@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

On 02/09/2018 07:28 AM, Matthew Wilcox wrote:
>  	union {
> +		/*
> +		 * If the page is neither PageSlab nor PageAnon, the value
> +		 * stored here may help distinguish it from page cache pages.
> +		 * See page-flags.h for a list of page types which are
> +		 * currently stored here.
> +		 */
> +		unsigned int page_type;
> +
>  		_slub_counter_t counters;
>  		unsigned int active;		/* SLAB */
>  		struct {			/* SLUB */
> @@ -107,11 +115,6 @@ struct page {
>  			/*
>  			 * Count of ptes mapped in mms, to show when
>  			 * page is mapped & limit reverse map searches.
> -			 *
> -			 * Extra information about page type may be
> -			 * stored here for pages that are never mapped,
> -			 * in which case the value MUST BE <= -2.
> -			 * See page-flags.h for more details.
>  			 */
>  			atomic_t _mapcount;

Are there any straightforward rules that we can enforce here?  For
instance, if you are using "page_type", you can never have PG_lru set.

Not that we have done this at all for 'struct page' historically, it
would be really convenient to have a clear definition for when
"page_type" is valid vs. "_mapcount".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
