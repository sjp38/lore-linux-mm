Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6083C5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 20:29:18 -0400 (EDT)
Date: Tue, 7 Apr 2009 19:29:41 -0500
From: Russ Anderson <rja@sgi.com>
Subject: Re: [PATCH] [2/16] POISON: Add page flag for poisoned pages
Message-ID: <20090408002941.GA14041@sgi.com>
Reply-To: Russ Anderson <rja@sgi.com>
References: <20090407509.382219156@firstfloor.org> <20090407150958.BA68F1D046D@basil.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090407150958.BA68F1D046D@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, rja@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, Apr 07, 2009 at 05:09:58PM +0200, Andi Kleen wrote:
> 
> Poisoned pages need special handling in the VM and shouldn't be touched 
> again. This requires a new page flag. Define it here.
> 
> The page flags wars seem to be over, so it shouldn't be a problem
> to get a new one. I hope.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> ---
>  include/linux/page-flags.h |   16 +++++++++++++++-
>  1 file changed, 15 insertions(+), 1 deletion(-)
> 
> Index: linux/include/linux/page-flags.h
> ===================================================================
> --- linux.orig/include/linux/page-flags.h	2009-04-07 16:39:27.000000000 +0200
> +++ linux/include/linux/page-flags.h	2009-04-07 16:39:39.000000000 +0200
> @@ -51,6 +51,9 @@
>   * PG_buddy is set to indicate that the page is free and in the buddy system
>   * (see mm/page_alloc.c).
>   *
> + * PG_poison indicates that a page got corrupted in hardware and contains
> + * data with incorrect ECC bits that triggered a machine check. Accessing is
> + * not safe since it may cause another machine check. Don't touch!
>   */
>  
>  /*
> @@ -104,6 +107,9 @@
>  #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
>  	PG_uncached,		/* Page has been mapped as uncached */
>  #endif
> +#ifdef CONFIG_MEMORY_FAILURE

Is it necessary to have this under CONFIG_MEMORY_FAILURE?

> +	PG_poison,		/* poisoned page. Don't touch */
> +#endif
>  	__NR_PAGEFLAGS,
>  
>  	/* Filesystems */
> @@ -273,6 +279,14 @@
>  PAGEFLAG_FALSE(Uncached)
>  #endif
>  
> +#ifdef CONFIG_MEMORY_FAILURE
> +PAGEFLAG(Poison, poison)
> +#define __PG_POISON (1UL << PG_poison)
> +#else
> +PAGEFLAG_FALSE(Poison)
> +#define __PG_POISON 0
> +#endif
> +
>  static inline int PageUptodate(struct page *page)
>  {
>  	int ret = test_bit(PG_uptodate, &(page)->flags);
> @@ -403,7 +417,7 @@
>  	 1 << PG_private | 1 << PG_private_2 | \
>  	 1 << PG_buddy	 | 1 << PG_writeback | 1 << PG_reserved | \
>  	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
> -	 __PG_UNEVICTABLE | __PG_MLOCKED)
> +	 __PG_POISON  | __PG_UNEVICTABLE | __PG_MLOCKED)
>  
>  /*
>   * Flags checked when a page is prepped for return by the page allocator.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
