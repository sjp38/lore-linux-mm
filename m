Date: Tue, 6 Mar 2007 08:06:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC} memory unplug patchset prep [4/16] ZONE_MOVABLE
In-Reply-To: <20070306134549.174cc160.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0703060024440.21900@chino.kir.corp.google.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
 <20070306134549.174cc160.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007, KAMEZAWA Hiroyuki wrote:

> Index: devel-tree-2.6.20-mm2/include/linux/mmzone.h
> ===================================================================
> --- devel-tree-2.6.20-mm2.orig/include/linux/mmzone.h
> +++ devel-tree-2.6.20-mm2/include/linux/mmzone.h
> @@ -142,6 +142,16 @@ enum zone_type {
>  	 */
>  	ZONE_HIGHMEM,
>  #endif
> +#ifdef CONFIG_ZONE_MOVABLE
> +	/*
> +	 * This memory area is used only for migratable pages.
> +	 * We have a chance to hot-remove memory in this zone.
> +	 * Currently, anonymous memory and usual page cache etc. are included.
> +	 * if HIGHMEM is configured, MOVABLE zone is treated as
> +         * not-direct-mapped-memory for kernel;.
> +	 */
> +	ZONE_MOVABLE,
> +#endif
>  	MAX_NR_ZONES,
>  #ifndef CONFIG_ZONE_DMA
>  	ZONE_DMA,
> @@ -152,6 +162,9 @@ enum zone_type {
>  #ifndef CONFIG_HIGHMEM
>  	ZONE_HIGHMEM,
>  #endif
> +#ifndef CONFIG_ZONE_MOVABLE
> +	ZONE_MOVABLE,
> +#endif
>  	MAX_POSSIBLE_ZONES
>  };
>  
> @@ -172,13 +185,18 @@ static inline int is_configured_zone(enu
>   * Count the active zones.  Note that the use of defined(X) outside
>   * #if and family is not necessarily defined so ensure we cannot use
>   * it later.  Use __ZONE_COUNT to work out how many shift bits we need.
> + *
> + * Assumes ZONE_DMA32,ZONE_HIGHMEM, ZONE_MOVABLE can't be configured at
> + * the same time.
>   */
>  #define __ZONE_COUNT (			\
>  	  defined(CONFIG_ZONE_DMA)	\
>  	+ defined(CONFIG_ZONE_DMA32)	\
>  	+ 1				\
>  	+ defined(CONFIG_HIGHMEM)	\
> +	+ defined(CONFIG_ZONE_MOVABLE) \
>  )
> +
>  #if __ZONE_COUNT < 2
>  #define ZONES_SHIFT 0
>  #elif __ZONE_COUNT <= 2
> @@ -513,6 +531,11 @@ static inline int populated_zone(struct 
>  	return (!!zone->present_pages);
>  }
>  
> +static inline int is_movable_dix(enum zone_type idx)
> +{
> +	return (idx == ZONE_MOVABLE);
> +}
> +

Should be is_movable_idx() maybe?  I assume this function is here for 
completeness since it's never referenced in the patchset.

> Index: devel-tree-2.6.20-mm2/mm/page_alloc.c
> ===================================================================
> --- devel-tree-2.6.20-mm2.orig/mm/page_alloc.c
> +++ devel-tree-2.6.20-mm2/mm/page_alloc.c
> @@ -82,6 +82,7 @@ static char name_dma[] = "DMA";
>  static char name_dma32[] = "DMA32";
>  static char name_normal[] = "Normal";
>  static char name_highmem[] = "Highmem";
> +static char name_movable[] = "Movable";
>  
>  static inline void __meminit zone_variables_init(void)
>  {
> @@ -91,6 +92,7 @@ static inline void __meminit zone_variab
>  	zone_names[ZONE_DMA32] = name_dma32;
>  	zone_names[ZONE_NORMAL] = name_normal;
>  	zone_names[ZONE_HIGHMEM] = name_highmem;
> +	zone_names[ZONE_MOVABLE] = name_movable;
>  
>  	/* ZONE below NORAML has ratio 256 */
>  	if (is_configured_zone(ZONE_DMA))
> @@ -99,6 +101,8 @@ static inline void __meminit zone_variab
>  		sysctl_lowmem_reserve_ratio[ZONE_DMA32] = 256;
>  	if (is_configured_zone(ZONE_HIGHMEM))
>  		sysctl_lowmem_reserve_ratio[ZONE_HIGHMEM] = 32;
> +	if (is_configured_zone(ZONE_MOVABLE))
> +		sysctl_lowmem_reserve_ratio[ZONE_MOVABLE] = 32;
>  }
>  
>  int min_free_kbytes = 1024;
> @@ -3065,11 +3069,17 @@ void __init free_area_init_nodes(unsigne
>  	arch_zone_lowest_possible_pfn[0] = find_min_pfn_with_active_regions();
>  	arch_zone_highest_possible_pfn[0] = max_zone_pfn[0];
>  	for (i = 1; i < MAX_NR_ZONES; i++) {
> +		if (i == ZONE_MOVABLE)
> +			continue;
>  		arch_zone_lowest_possible_pfn[i] =
>  			arch_zone_highest_possible_pfn[i-1];
>  		arch_zone_highest_possible_pfn[i] =
>  			max(max_zone_pfn[i], arch_zone_lowest_possible_pfn[i]);
>  	}
> +	if (is_configured_zone(ZONE_MOVABLE)) {
> +		arch_zone_lowest_possible_pfn[ZONE_MOVABLE] = 0;
> +		arch_zone_highest_possible_pfn[ZONE_MOVABLE] = 0;
> +	}
>  
>  	/* Print out the page size for debugging meminit problems */
>  	printk(KERN_DEBUG "sizeof(struct page) = %zd\n", sizeof(struct page));

Aren't the arch_zone_{lowest|highest}_possible_pfn's for ZONE_MOVABLE 
already at 0?  If not, it should definitely be memset early on to avoid 
any possible assignment mistakes amongst all these conditionals.

> Index: devel-tree-2.6.20-mm2/mm/Kconfig
> ===================================================================
> --- devel-tree-2.6.20-mm2.orig/mm/Kconfig
> +++ devel-tree-2.6.20-mm2/mm/Kconfig
> @@ -163,6 +163,10 @@ config ZONE_DMA_FLAG
>  	default "0" if !ZONE_DMA
>  	default "1"
>  
> +config ZONE_MOVABLE
> +	bool "Create zones for MOVABLE pages"
> +	depends on ARCH_POPULATES_NODE_MAP
> +	depends on MIGRATION
>  #
>  # Adaptive file readahead
>  #
> 

This patchset is heavily dependent on Mel Gorman's work with ZONE_MOVABLE 
so perhaps it would be better to base it off of the latest -mm with his 
patchset applied?  And if CONFIG_ZONE_MOVABLE wasn't documented in Kconfig 
prior to this, it might be a good opportunity to do so if you're going to 
get community adoption.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
