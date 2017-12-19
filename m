Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 234716B0253
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 03:07:34 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id o2so728814wmf.2
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 00:07:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d4si992759wme.64.2017.12.19.00.07.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 00:07:32 -0800 (PST)
Date: Tue, 19 Dec 2017 09:07:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/8] mm: Introduce _slub_counter_t
Message-ID: <20171219080731.GB2787@dhcp22.suse.cz>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-6-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171216164425.8703-6-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Sat 16-12-17 08:44:22, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Instead of putting the ifdef in the middle of the definition of struct
> page, pull it forward to the rest of the ifdeffery around the SLUB
> cmpxchg_double optimisation.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

The definition of struct page looks better now. I think that slub.c
needs some love as well. I haven't checked too deeply but it seems that
it assumes counters to be unsigned long in some places. Maybe I've
missed some ifdef-ery but using the native type would be much better

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm_types.h | 21 ++++++++-------------
>  1 file changed, 8 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 8c3b8cea22ee..5521c9799c50 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -41,9 +41,15 @@ struct hmm;
>   */
>  #ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
>  #define _struct_page_alignment	__aligned(2 * sizeof(unsigned long))
> +#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE)
> +#define _slub_counter_t		unsigned long
>  #else
> -#define _struct_page_alignment
> +#define _slub_counter_t		unsigned int
>  #endif
> +#else /* !CONFIG_HAVE_ALIGNED_STRUCT_PAGE */
> +#define _struct_page_alignment
> +#define _slub_counter_t		unsigned int
> +#endif /* !CONFIG_HAVE_ALIGNED_STRUCT_PAGE */
>  
>  struct page {
>  	/* First double word block */
> @@ -66,18 +72,7 @@ struct page {
>  	};
>  
>  	union {
> -#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
> -	defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
> -		/* Used for cmpxchg_double in slub */
> -		unsigned long counters;
> -#else
> -		/*
> -		 * Keep _refcount separate from slub cmpxchg_double data.
> -		 * As the rest of the double word is protected by slab_lock
> -		 * but _refcount is not.
> -		 */
> -		unsigned counters;
> -#endif
> +		_slub_counter_t counters;
>  		unsigned int active;		/* SLAB */
>  		struct {			/* SLUB */
>  			unsigned inuse:16;
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
