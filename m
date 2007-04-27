Date: Fri, 27 Apr 2007 12:14:31 +0100
Subject: Re: [patch 09/10] SLUB: Exploit page mobility to increase allocation order
Message-ID: <20070427111431.GF3645@skynet.ie>
References: <20070427042655.019305162@sgi.com> <20070427042909.415420974@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070427042909.415420974@sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (26/04/07 21:27), clameter@sgi.com didst pronounce:
> If there is page mobility then we can defragment memory. So its possible to
> use higher order of pages for slab allocations.
> 
> If the defaults were not overridden set the max order to 4 and guarantee 16
> objects per slab. This will put some stress on Mel's antifrag approaches.
> If these defaults are too large then they should be later reduced.
> 

I see this went through mm-commits. When the next -mm kernel comes out,
I'll grind them through the external fragmentation tests and see how it
works out. Not all slabs are reclaimable so it might have side-effects
if there are large amounts of slab allocations that are not allocated
__GFP_RECLAIMABLE. Testing will tell.

> Cc: Mel Gorman <mel@skynet.ie>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.21-rc7-mm2/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/include/linux/mmzone.h	2007-04-26 20:57:58.000000000 -0700
> +++ linux-2.6.21-rc7-mm2/include/linux/mmzone.h	2007-04-26 21:05:48.000000000 -0700
> @@ -25,6 +25,8 @@
>  #endif
>  #define MAX_ORDER_NR_PAGES (1 << (MAX_ORDER - 1))
>  
> +extern int page_group_by_mobility_disabled;
> +
>  /*
>   * PAGE_ALLOC_COSTLY_ORDER is the order at which allocations are deemed
>   * costly to service.  That is between allocation orders which should
> Index: linux-2.6.21-rc7-mm2/mm/slub.c
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/mm/slub.c	2007-04-26 21:02:01.000000000 -0700
> +++ linux-2.6.21-rc7-mm2/mm/slub.c	2007-04-26 21:10:40.000000000 -0700
> @@ -129,6 +129,13 @@
>  #endif
>  
>  /*
> + * If antifragmentation methods are in effect then increase the
> + * slab sizes to increase performance
> + */
> +#define DEFAULT_ANTIFRAG_MAX_ORDER 4
> +#define DEFAULT_ANTIFRAG_MIN_OBJECTS 16
> +
> +/*
>   * Mininum number of partial slabs. These will be left on the partial
>   * lists even if they are empty. kmem_cache_shrink may reclaim them.
>   */
> @@ -1450,6 +1457,11 @@ static struct page *get_object_page(cons
>   */
>  
>  /*
> + * Set if the user has overridden any of the order related defaults.
> + */
> +static int user_override;
> +
> +/*
>   * Mininum / Maximum order of slab pages. This influences locking overhead
>   * and slab fragmentation. A higher order reduces the number of partial slabs
>   * and increases the number of allocations possible without having to
> @@ -1985,7 +1997,7 @@ static struct kmem_cache *kmalloc_caches
>  static int __init setup_slub_min_order(char *str)
>  {
>  	get_option (&str, &slub_min_order);
> -
> +	user_override = 1;
>  	return 1;
>  }
>  
> @@ -1994,7 +2006,7 @@ __setup("slub_min_order=", setup_slub_mi
>  static int __init setup_slub_max_order(char *str)
>  {
>  	get_option (&str, &slub_max_order);
> -
> +	user_override = 1;
>  	return 1;
>  }
>  
> @@ -2003,7 +2015,7 @@ __setup("slub_max_order=", setup_slub_ma
>  static int __init setup_slub_min_objects(char *str)
>  {
>  	get_option (&str, &slub_min_objects);
> -
> +	user_override = 1;
>  	return 1;
>  }
>  
> @@ -2319,6 +2331,15 @@ void __init kmem_cache_init(void)
>  {
>  	int i;
>  
> +	if (!page_group_by_mobility_disabled && !user_override) {
> +		/*
> +		 * Antifrag support available. Increase usable
> +		 * page order and generate slabs with more objects.
> +	 	 */
> +		slub_max_order = DEFAULT_ANTIFRAG_MAX_ORDER;
> +		slub_min_objects = DEFAULT_ANTIFRAG_MIN_OBJECTS;
> +	}
> +
>  #ifdef CONFIG_NUMA
>  	/*
>  	 * Must first have the slab cache available for the allocations of the
> 
> --

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
