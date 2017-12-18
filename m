Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6AF6B0266
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 10:36:54 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 96so9520599wrk.7
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:36:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n22si1911265wrn.262.2017.12.18.07.36.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 07:36:53 -0800 (PST)
Date: Mon, 18 Dec 2017 16:36:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/8] mm: De-indent struct page
Message-ID: <20171218153652.GC3876@dhcp22.suse.cz>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-3-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171216164425.8703-3-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Sat 16-12-17 08:44:19, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> I found the struct { union { struct { union { struct { } } } } }
> layout rather confusing.  Fortunately, there is an easier way to write
> this.  The innermost union is of four things which are the size of an
> int, so the ones which are used by slab/slob/slub can be pulled up
> two levels to be in the outermost union with 'counters'.  That leaves
> us with struct { union { struct { atomic_t; atomic_t; } } } which
> has the same layout, but is easier to read.

This is where the pahole output would be really helpeful. The patch
looks OK, I will double check with a fresh brain tomorrow (with the rest
of the series), though.

> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  include/linux/mm_types.h | 40 +++++++++++++++++++---------------------
>  1 file changed, 19 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 4509f0cfaf39..27973166af28 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -84,28 +84,26 @@ struct page {
>  		 */
>  		unsigned counters;
>  #endif
> -		struct {
> +		unsigned int active;		/* SLAB */
> +		struct {			/* SLUB */
> +			unsigned inuse:16;
> +			unsigned objects:15;
> +			unsigned frozen:1;
> +		};
> +		int units;			/* SLOB */
> +
> +		struct {			/* Page cache */
> +			/*
> +			 * Count of ptes mapped in mms, to show when
> +			 * page is mapped & limit reverse map searches.
> +			 *
> +			 * Extra information about page type may be
> +			 * stored here for pages that are never mapped,
> +			 * in which case the value MUST BE <= -2.
> +			 * See page-flags.h for more details.
> +			 */
> +			atomic_t _mapcount;
>  
> -			union {
> -				/*
> -				 * Count of ptes mapped in mms, to show when
> -				 * page is mapped & limit reverse map searches.
> -				 *
> -				 * Extra information about page type may be
> -				 * stored here for pages that are never mapped,
> -				 * in which case the value MUST BE <= -2.
> -				 * See page-flags.h for more details.
> -				 */
> -				atomic_t _mapcount;
> -
> -				unsigned int active;		/* SLAB */
> -				struct {			/* SLUB */
> -					unsigned inuse:16;
> -					unsigned objects:15;
> -					unsigned frozen:1;
> -				};
> -				int units;			/* SLOB */
> -			};
>  			/*
>  			 * Usage count, *USE WRAPPER FUNCTION* when manual
>  			 * accounting. See page_ref.h
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
