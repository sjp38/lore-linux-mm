Date: Mon, 23 Jul 2007 14:16:49 +0100
Subject: Re: [RFC][PATCH] zone config patch set [1/2] zone ifdef cleaunp by renumbering
Message-ID: <20070723131649.GA8649@skynet.ie>
References: <20070721160049.75bc8d9f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070721160049.75bc8d9f.kamezawa.hiroyu@jp.fujitsu.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "apw@shadowen.org" <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>, nickpiggin@yahoo.com.au, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On (21/07/07 16:00), KAMEZAWA Hiroyuki didst pronounce:
> This patch set is for changing ZONE_MOVABLE as configurable.
> 
> This patch cleans up #ifdef used for zones to some extent.
> But I noticed this will conflict witl Christoph's memory_less_node patch set.
> 
> If his set is ready to be merged to -mm(I hope so), I'll repost this after that.
> For now, this post is just for review, again. If this patch looks danger, please
> point out.
> 
> Patch is against 2.6.22-rc6-mm1. Tested on ia64/NUMA with and without setting CONFIG_ZONE_MOVABLE. both works well.
> 
> I'm sorry but my response will be delayed.
> 
> Thanks,
> -Kame
> ==
> zone_ifdef_cleanup_by_renumbering.patch
> 
> Now, this patch defines zone_idx for not-configured-zones.
> like 
> 	enum_zone_type {
> 		(ZONE_DMA configured)
> 		(ZONE_DMA32 configured)
> 		ZONE_NORMAL
> 		(ZONE_HIGHMEM configured)
> 		ZONE_MOVABLE
> 		MAX_NR_ZONES,
> 		(ZONE_DMA not-configured)
> 		(ZONE_DMA32 not-configured)
> 		(ZONE_HIGHMEM not-configured)
> 		MAX_POSSIBLE_ZONES,
> 	};

As I said before, I like this idea.

> 
> By this, we can determine zone is configured or not by
> 
> 	zone_idx < MAX_NR_ZONES.
> 
> By this, we can avoid #ifdef for CONFIG_ZONE_xxx to some extent.
> 
> This patch also replaces CONFIG_ZONE_DMA_FLAG by is_configured_zone(ZONE_DMA).
> 
> Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  include/linux/gfp.h    |   16 +++++-------
>  include/linux/mmzone.h |   64 ++++++++++++++++++++++++++-----------------------
>  include/linux/vmstat.h |   24 +++++++++---------
>  mm/Kconfig             |    5 ---
>  mm/page-writeback.c    |    7 ++---
>  mm/page_alloc.c        |   37 ++++++++++++----------------
>  mm/slab.c              |    4 +--
>  7 files changed, 74 insertions(+), 83 deletions(-)
> 
> Index: linux-2.6.22-rc6-mm1/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/include/linux/mmzone.h
> +++ linux-2.6.22-rc6-mm1/include/linux/mmzone.h
> @@ -178,9 +178,24 @@ enum zone_type {
>  	ZONE_HIGHMEM,
>  #endif
>  	ZONE_MOVABLE,
> -	MAX_NR_ZONES
> +	MAX_NR_ZONES,
> +#ifndef CONFIG_ZONE_DMA
> +	ZONE_DMA,
> +#endif
> +#ifndef CONFIG_ZONE_DMA32
> +	ZONE_DMA32,
> +#endif
> +#ifndef CONFIG_HIGHMEM
> +	ZONE_HIGHMEM,
> +#endif
> +	MAX_POSSIBLE_ZONES,
>  };
>  
> +static inline int is_configured_zone(enum zone_type name)
> +{
> +	return (name < MAX_NR_ZONES);
> +}
> +

nit-pick; The use of "name" as a variable here is a little confusing because
zone->name is a char * while this is a zone index. I would prefer it was
called zoneidx or similar. Later you use idx so that would be fine.

>  /*
>   * When a memory allocation must conform to specific limitations (such
>   * as being suitable for DMA) the caller will pass in hints to the
> @@ -543,28 +558,31 @@ static inline int populated_zone(struct 
>  
>  extern int movable_zone;
>  
> -static inline int zone_movable_is_highmem(void)
> +static inline int zone_idx_is(enum zone_type idx, enum zone_type target)
>  {
> -#if defined(CONFIG_HIGHMEM) && defined(CONFIG_ARCH_POPULATES_NODE_MAP)
> -	return movable_zone == ZONE_HIGHMEM;
> -#else
> +	if (is_configured_zone(target) && (idx == target))
> +		return 1;
>  	return 0;
> +}
> +
> +static inline int zone_movable_is_highmem(void)
> +{
> +#if CONFIG_ARCH_POPULATES_NODE_MAP
> +	if (is_configured_zone(ZONE_HIGHMEM))
> +		return movable_zone == ZONE_HIGHMEM;
>  #endif
> +	return 0;
>  }
>  
>  static inline int is_highmem_idx(enum zone_type idx)
>  {
> -#ifdef CONFIG_HIGHMEM
> -	return (idx == ZONE_HIGHMEM ||
> -		(idx == ZONE_MOVABLE && zone_movable_is_highmem()));
> -#else
> -	return 0;
> -#endif
> +	return (zone_idx_is(idx, ZONE_HIGHMEM) ||
> +	       (zone_idx_is(idx, ZONE_MOVABLE) && zone_movable_is_highmem()));

Using spaces instead of tabs here.

>  }
>  
>  static inline int is_normal_idx(enum zone_type idx)
>  {
> -	return (idx == ZONE_NORMAL);
> +	return zone_idx_is(idx, ZONE_NORMAL);
>  }
>  
>  /**
> @@ -575,36 +593,22 @@ static inline int is_normal_idx(enum zon
>   */
>  static inline int is_highmem(struct zone *zone)
>  {
> -#ifdef CONFIG_HIGHMEM
> -	int zone_idx = zone - zone->zone_pgdat->node_zones;
> -	return zone_idx == ZONE_HIGHMEM ||
> -		(zone_idx == ZONE_MOVABLE && zone_movable_is_highmem());
> -#else
> -	return 0;
> -#endif
> +	return is_highmem_idx(zone_idx(zone));
>  }

Much nicer looking.

>  
>  static inline int is_normal(struct zone *zone)
>  {
> -	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
> +	return zone_idx_is(zone_idx(zone), ZONE_NORMAL);
>  }
>  
>  static inline int is_dma32(struct zone *zone)
>  {
> -#ifdef CONFIG_ZONE_DMA32
> -	return zone == zone->zone_pgdat->node_zones + ZONE_DMA32;
> -#else
> -	return 0;
> -#endif
> +	return zone_idx_is(zone_idx(zone), ZONE_DMA32);
>  }
>  
>  static inline int is_dma(struct zone *zone)
>  {
> -#ifdef CONFIG_ZONE_DMA
> -	return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
> -#else
> -	return 0;
> -#endif
> +	return zone_idx_is(zone_idx(zone), ZONE_DMA);
>  }
>  
>  /* These two functions are used to setup the per zone pages min values */
> Index: linux-2.6.22-rc6-mm1/include/linux/vmstat.h
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/include/linux/vmstat.h
> +++ linux-2.6.22-rc6-mm1/include/linux/vmstat.h
> @@ -159,19 +159,19 @@ static inline unsigned long node_page_st
>  				 enum zone_stat_item item)
>  {
>  	struct zone *zones = NODE_DATA(node)->node_zones;
> +	unsigned long val = zone_page_state(&zones[ZONE_NORMAL],item);
>  
> -	return
> -#ifdef CONFIG_ZONE_DMA
> -		zone_page_state(&zones[ZONE_DMA], item) +
> -#endif
> -#ifdef CONFIG_ZONE_DMA32
> -		zone_page_state(&zones[ZONE_DMA32], item) +
> -#endif
> -#ifdef CONFIG_HIGHMEM
> -		zone_page_state(&zones[ZONE_HIGHMEM], item) +
> -#endif
> -		zone_page_state(&zones[ZONE_NORMAL], item) +
> -		zone_page_state(&zones[ZONE_MOVABLE], item);
> +	if (is_configured_zone(ZONE_DMA))
> +		val += zone_page_state(&zones[ZONE_DMA], item);
> +
> +	if (is_configured_zone(ZONE_DMA32))
> +		val += zone_page_state(&zones[ZONE_DMA32], item);
> +
> +	if (is_configured_zone(ZONE_HIGHMEM))
> +		val += zone_page_state(&zones[ZONE_HIGHMEM], item);
> +
> +	val += zone_page_state(&zones[ZONE_MOVABLE], item);
> +	return val;
>  }
>  
>  extern void zone_statistics(struct zonelist *, struct zone *);
> Index: linux-2.6.22-rc6-mm1/include/linux/gfp.h
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/include/linux/gfp.h
> +++ linux-2.6.22-rc6-mm1/include/linux/gfp.h
> @@ -116,21 +116,19 @@ static inline int allocflags_to_migratet
>  
>  static inline enum zone_type gfp_zone(gfp_t flags)
>  {
> -#ifdef CONFIG_ZONE_DMA
> -	if (flags & __GFP_DMA)
> +	if (is_configured_zone(ZONE_DMA) && (flags & __GFP_DMA))
>  		return ZONE_DMA;
> -#endif
> -#ifdef CONFIG_ZONE_DMA32
> -	if (flags & __GFP_DMA32)
> +
> +	if (is_configured_zone(ZONE_DMA32) && (flags & __GFP_DMA32))
>  		return ZONE_DMA32;
> -#endif
> +
>  	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
>  			(__GFP_HIGHMEM | __GFP_MOVABLE))
>  		return ZONE_MOVABLE;
> -#ifdef CONFIG_HIGHMEM
> -	if (flags & __GFP_HIGHMEM)
> +
> +	if (is_configured_zone(ZONE_HIGHMEM) && (flags & __GFP_HIGHMEM))
>  		return ZONE_HIGHMEM;
> -#endif
> +
>  	return ZONE_NORMAL;
>  }
>  
> Index: linux-2.6.22-rc6-mm1/mm/Kconfig
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/mm/Kconfig
> +++ linux-2.6.22-rc6-mm1/mm/Kconfig
> @@ -158,11 +158,6 @@ config RESOURCES_64BIT
>  	help
>  	  This option allows memory and IO resources to be 64 bit.
>  
> -config ZONE_DMA_FLAG
> -	int
> -	default "0" if !ZONE_DMA
> -	default "1"
> -
>  config BOUNCE
>  	def_bool y
>  	depends on BLOCK && MMU && (ZONE_DMA || HIGHMEM)
> Index: linux-2.6.22-rc6-mm1/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/mm/page_alloc.c
> +++ linux-2.6.22-rc6-mm1/mm/page_alloc.c
> @@ -91,18 +91,12 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_Z
>  
>  EXPORT_SYMBOL(totalram_pages);
>  
> -static char * const zone_names[MAX_NR_ZONES] = {
> -#ifdef CONFIG_ZONE_DMA
> -	 "DMA",
> -#endif
> -#ifdef CONFIG_ZONE_DMA32
> -	 "DMA32",
> -#endif
> -	 "Normal",
> -#ifdef CONFIG_HIGHMEM
> -	 "HighMem",
> -#endif
> -	 "Movable",
> +static char * const zone_names[MAX_POSSIBLE_ZONES] = {
> +	[ZONE_DMA] = "DMA",
> +	[ZONE_DMA32] = "DMA32",
> +	[ZONE_NORMAL] = "Normal",
> +	[ZONE_HIGHMEM] = "HighMem",
> +	[ZONE_MOVABLE] =  "Movable",
>  };
>  
>  int min_free_kbytes = 1024;
> @@ -134,8 +128,8 @@ static unsigned long __meminitdata dma_r
>  
>    static struct node_active_region __meminitdata early_node_map[MAX_ACTIVE_REGIONS];
>    static int __meminitdata nr_nodemap_entries;
> -  static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
> -  static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
> +  static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_POSSIBLE_ZONES];
> +  static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_POSSIBLE_ZONES];

I don't think this change is necessary. Values larger than MAX_NR_ZONES will
never be used by the initialisation code. At least, I cannot find a place
where it would but did you spot somewhere?. If values outside of MAX_NR_ZONES
are used then the initialisation is going to go wrong.

>  #ifdef CONFIG_MEMORY_HOTPLUG_RESERVE
>    static unsigned long __meminitdata node_boundary_start_pfn[MAX_NUMNODES];
>    static unsigned long __meminitdata node_boundary_end_pfn[MAX_NUMNODES];
> @@ -1834,14 +1828,15 @@ void si_meminfo_node(struct sysinfo *val
>  
>  	val->totalram = pgdat->node_present_pages;
>  	val->freeram = node_page_state(nid, NR_FREE_PAGES);
> -#ifdef CONFIG_HIGHMEM
> -	val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].present_pages;
> -	val->freehigh = zone_page_state(&pgdat->node_zones[ZONE_HIGHMEM],
> +	if (is_configured_zone(ZONE_HIGHMEM)) {
> +		val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].present_pages;
> +		val->freehigh =
> +			zone_page_state(&pgdat->node_zones[ZONE_HIGHMEM],
>  			NR_FREE_PAGES);
> -#else
> -	val->totalhigh = 0;
> -	val->freehigh = 0;
> -#endif
> +	} else {
> +		val->totalhigh = 0;
> +		val->freehigh = 0;
> +	}
>  	val->mem_unit = PAGE_SIZE;
>  }
>  #endif
> Index: linux-2.6.22-rc6-mm1/mm/slab.c
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/mm/slab.c
> +++ linux-2.6.22-rc6-mm1/mm/slab.c
> @@ -2328,7 +2328,7 @@ kmem_cache_create (const char *name, siz
>  	cachep->slab_size = slab_size;
>  	cachep->flags = flags;
>  	cachep->gfpflags = 0;
> -	if (CONFIG_ZONE_DMA_FLAG && (flags & SLAB_CACHE_DMA))
> +	if (is_configured_zone(ZONE_DMA) && (flags & SLAB_CACHE_DMA))
>  		cachep->gfpflags |= GFP_DMA;
>  	cachep->buffer_size = size;
>  	cachep->reciprocal_buffer_size = reciprocal_value(size);
> @@ -2649,7 +2649,7 @@ static void cache_init_objs(struct kmem_
>  
>  static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
>  {
> -	if (CONFIG_ZONE_DMA_FLAG) {
> +	if (is_configured_zone(ZONE_DMA)) {
>  		if (flags & GFP_DMA)
>  			BUG_ON(!(cachep->gfpflags & GFP_DMA));
>  		else
> Index: linux-2.6.22-rc6-mm1/mm/page-writeback.c
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/mm/page-writeback.c
> +++ linux-2.6.22-rc6-mm1/mm/page-writeback.c
> @@ -122,10 +122,12 @@ static void background_writeout(unsigned
>  
>  static unsigned long highmem_dirtyable_memory(unsigned long total)
>  {
> -#ifdef CONFIG_HIGHMEM
>  	int node;
>  	unsigned long x = 0;
>  
> +	if (!is_configured_zone(ZONE_HIGHMEM))
> +		return 0;
> +
>  	for_each_online_node(node) {
>  		struct zone *z =
>  			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
> @@ -141,9 +143,6 @@ static unsigned long highmem_dirtyable_m
>  	 * that this does not occur.
>  	 */
>  	return min(x, total);
> -#else
> -	return 0;
> -#endif
>  }
>  
>  static unsigned long determine_dirtyable_memory(void)

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
