Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 09DC46B0266
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 10:22:19 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p190so7585538wmd.0
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:22:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o24si8835724wmi.38.2017.12.18.07.22.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 07:22:17 -0800 (PST)
Date: Mon, 18 Dec 2017 16:22:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/8] mm: Align struct page more aesthetically
Message-ID: <20171218152216.GB3876@dhcp22.suse.cz>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-2-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171216164425.8703-2-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Sat 16-12-17 08:44:18, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> instead of an ifdef block at the end of the struct, which needed
> its own comment, define _struct_page_alignment up at the top where it
> fits nicely with the existing comment.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm_types.h | 16 +++++++---------
>  1 file changed, 7 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index cfd0ac4e5e0e..4509f0cfaf39 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -39,6 +39,12 @@ struct hmm;
>   * allows the use of atomic double word operations on the flags/mapping
>   * and lru list pointers also.
>   */
> +#ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
> +#define _struct_page_alignment	__aligned(2 * sizeof(unsigned long))
> +#else
> +#define _struct_page_alignment
> +#endif
> +
>  struct page {
>  	/* First double word block */
>  	unsigned long flags;		/* Atomic flags, some possibly
> @@ -212,15 +218,7 @@ struct page {
>  #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
>  	int _last_cpupid;
>  #endif
> -}
> -/*
> - * The struct page can be forced to be double word aligned so that atomic ops
> - * on double words work. The SLUB allocator can make use of such a feature.
> - */
> -#ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
> -	__aligned(2 * sizeof(unsigned long))
> -#endif
> -;
> +} _struct_page_alignment;
>  
>  #define PAGE_FRAG_CACHE_MAX_SIZE	__ALIGN_MASK(32768, ~PAGE_MASK)
>  #define PAGE_FRAG_CACHE_MAX_ORDER	get_order(PAGE_FRAG_CACHE_MAX_SIZE)
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
