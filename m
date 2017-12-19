Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 45C3C6B0268
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 03:19:58 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 96so10735344wrk.7
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 00:19:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a19si5198137wrc.299.2017.12.19.00.19.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 00:19:57 -0800 (PST)
Date: Tue, 19 Dec 2017 09:19:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/8] mm: Store compound_dtor / compound_order as bytes
Message-ID: <20171219081956.GC2787@dhcp22.suse.cz>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-7-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171216164425.8703-7-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Sat 16-12-17 08:44:23, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Neither of these values get even close to 256; compound_dtor is
> currently at a maximum of 3, and compound_order can't be over 64.
> No machine has inefficient access to bytes since EV5, and while
> those are still supported, we don't optimise for them any more.

Hmm, so the improvement is the ifdef-ery removale, right? Beucase this
will not shrink the structure size AFAICS. I think that the former is
a sufficient justification. Maybe you should spell it out.

> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm_types.h | 15 ++-------------
>  1 file changed, 2 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 5521c9799c50..1a3ba1f1605d 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -136,19 +136,8 @@ struct page {
>  			unsigned long compound_head; /* If bit zero is set */
>  
>  			/* First tail page only */
> -#ifdef CONFIG_64BIT
> -			/*
> -			 * On 64 bit system we have enough space in struct page
> -			 * to encode compound_dtor and compound_order with
> -			 * unsigned int. It can help compiler generate better or
> -			 * smaller code on some archtectures.
> -			 */
> -			unsigned int compound_dtor;
> -			unsigned int compound_order;
> -#else
> -			unsigned short int compound_dtor;
> -			unsigned short int compound_order;
> -#endif
> +			unsigned char compound_dtor;
> +			unsigned char compound_order;
>  		};
>  
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
> -- 
> 2.15.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
