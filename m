Message-ID: <469355D4.1070008@shadowen.org>
Date: Tue, 10 Jul 2007 10:48:04 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: zone movable patches comments
References: <4691E8D1.4030507@yahoo.com.au>	<20070709110457.GB9305@skynet.ie>	<469226CB.4010900@yahoo.com.au>	<20070709132140.GC9305@skynet.ie> <20070710180845.ee1de048.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070710180845.ee1de048.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@skynet.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 9 Jul 2007 14:21:41 +0100
> mel@skynet.ie (Mel Gorman) wrote:
>> I'm pretty sure it can be made look nice by changing enum zone_type to
>> conditionally define ZONE_MOVABLE and define __GFP_MOVABLE to be 0 when
>> it doesn't exist. I'll look at Kame's patch before starting in case it's
>> nicer.
>>
> This patch is just for sharing idea. I updated mine against 2.6.22-rc6-mm1.
> just confirmed my system can boot with this.
> 
> Cheers,
> -Kame
> ==
> Includes 2 feature.
> 
> 1. By defining ZONE_xxx even if they are not configured, we can remove many
>    ifdefs.
>    Instead of #ifdef, is_configurated_zone() func is added.
>    compiler will do enough work to inline it and remove unnecessary codes.
> 
> 2. This patch makes ZONE_MOVABLE to be configurable.
> 
> Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

A nice little trick moving the 'unused' zones after MAX_NR_ZONES.  A few
of thoughts below, but generally it looks very promising.  Lots of nasty
#ifdef's going away is always a cause for cheering.

> ---
>  include/linux/gfp.h    |   21 ++++++-------
>  include/linux/mmzone.h |   47 ++++++++++++++++--------------
>  mm/Kconfig             |   10 ++++++
>  mm/page_alloc.c        |   75 +++++++++++++++++++++++++------------------------
>  4 files changed, 84 insertions(+), 69 deletions(-)
> 
> Index: linux-2.6.22-rc6-mm1/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/include/linux/mmzone.h
> +++ linux-2.6.22-rc6-mm1/include/linux/mmzone.h
> @@ -178,10 +178,33 @@ enum zone_type {
>  	 */
>  	ZONE_HIGHMEM,
>  #endif
> +#ifdef CONFIG_ZONE_MOVABLE
>  	ZONE_MOVABLE,
> -	MAX_NR_ZONES
> +#endif
> +	MAX_NR_ZONES,
> +	/*
> +	 * Number for not configured zones.
> +	 */
> +#ifndef CONFIG_ZONE_DMA
> +	ZONE_DMA,
> +#endif
> +#ifndef CONFIG_ZONE_DMA32
> +	ZONE_DMA32,
> +#endif
> +#ifndef CONFIG_HIGHMEM
> +	ZONE_HIGHMEM,
> +#endif
> +#ifndef CONFIG_ZONE_MOVABLE
> +	ZONE_MOVABLE,
> +#endif
> +	MAX_POSSIBLE_ZONES,
>  };
>  
> +static inline int is_configured_zone(enum zone_type type)
> +{
> +	return (type < MAX_NR_ZONES);
> +}
> +
>  /*
>   * When a memory allocation must conform to specific limitations (such
>   * as being suitable for DMA) the caller will pass in hints to the
> @@ -200,7 +223,7 @@ enum zone_type {
>  	+ defined(CONFIG_ZONE_DMA32)	\
>  	+ 1				\
>  	+ defined(CONFIG_HIGHMEM)	\
> -	+ 1				\
> +	+ defined(CONFIG_ZONE_MOVABLE)	\
>  )
>  #if __ZONE_COUNT < 2
>  #define ZONES_SHIFT 0
> @@ -546,21 +569,13 @@ extern int movable_zone;
>  
>  static inline int zone_movable_is_highmem(void)
>  {
> -#if defined(CONFIG_HIGHMEM) && defined(CONFIG_ARCH_POPULATES_NODE_MAP)
>  	return movable_zone == ZONE_HIGHMEM;
> -#else
> -	return 0;
> -#endif
>  }
>  
>  static inline int is_highmem_idx(enum zone_type idx)
>  {
> -#ifdef CONFIG_HIGHMEM
>  	return (idx == ZONE_HIGHMEM ||
>  		(idx == ZONE_MOVABLE && zone_movable_is_highmem()));
> -#else
> -	return 0;
> -#endif
>  }
>  
>  static inline int is_normal_idx(enum zone_type idx)
> @@ -576,13 +591,9 @@ static inline int is_normal_idx(enum zon
>   */
>  static inline int is_highmem(struct zone *zone)
>  {
> -#ifdef CONFIG_HIGHMEM
>  	int zone_idx = zone - zone->zone_pgdat->node_zones;
>  	return zone_idx == ZONE_HIGHMEM ||
>  		(zone_idx == ZONE_MOVABLE && zone_movable_is_highmem());
> -#else
> -	return 0;
> -#endif
>  }
>  
>  static inline int is_normal(struct zone *zone)
> @@ -592,20 +603,12 @@ static inline int is_normal(struct zone 
>  
>  static inline int is_dma32(struct zone *zone)
>  {
> -#ifdef CONFIG_ZONE_DMA32
>  	return zone == zone->zone_pgdat->node_zones + ZONE_DMA32;

I would have expected all of the is_zonename() checks to include the
zone_is_configured() checks, to allow the optimiser to catch on and
elide the code.

    if (zone_is_configured(ZONE_DMA32)
	return zone == zone->zone_pgdat->node_zones + ZONE_DMA32;
    else
	return 0;

Perhaps a little helper:

static inline zone_idx_is(int idx, int target)
{
	if (zone_is_configured(target))
		return idx == target;
	else
		return 0;
}

> -#else
> -	return 0;
> -#endif
>  }
>  
>  static inline int is_dma(struct zone *zone)
>  {
> -#ifdef CONFIG_ZONE_DMA
>  	return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
> -#else
> -	return 0;
> -#endif
>  }
>  
>  /* These two functions are used to setup the per zone pages min values */
> Index: linux-2.6.22-rc6-mm1/include/linux/gfp.h
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/include/linux/gfp.h
> +++ linux-2.6.22-rc6-mm1/include/linux/gfp.h
> @@ -116,21 +116,20 @@ static inline int allocflags_to_migratet
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
> -	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
> -			(__GFP_HIGHMEM | __GFP_MOVABLE))
> +
> +	if (is_configured_zone(ZONE_MOVABLE) &&
> +	    (flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) == (__GFP_HIGHMEM | __GFP_MOVABLE))
> +			
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
> @@ -112,6 +112,16 @@ config SPARSEMEM_EXTREME
>  	def_bool y
>  	depends on SPARSEMEM && !SPARSEMEM_STATIC
>  
> +config ZONE_MOVABLE
> +	bool "Create a zone for Movable Pages"
> +	depends on ARCH_POPULATES_NODE_MAP
> +	help
> +	  This option allows you to create a zone only for movable pages.
> +	  *movable pages* means which can be target of page migration.
> +	  With page migration, you will be able to do "deflag memory" and
> +	  "memory unplug". You can do it with usual zones but MOVABLE zones
> +	  enables page migration related stuff much easier.
> +
>  # eventually, we can have this option just 'select SPARSEMEM'
>  config MEMORY_HOTPLUG
>  	bool "Allow for memory hot-add"
> Index: linux-2.6.22-rc6-mm1/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/mm/page_alloc.c
> +++ linux-2.6.22-rc6-mm1/mm/page_alloc.c
> @@ -76,35 +76,34 @@ static void __free_pages_ok(struct page 
>   *
>   * TBD: should special case ZONE_DMA32 machines here - in those we normally
>   * don't need any ZONE_NORMAL reservation
> + * see zone_variables_init();
>   */
> -int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
> -#ifdef CONFIG_ZONE_DMA
> -	 256,
> -#endif
> -#ifdef CONFIG_ZONE_DMA32
> -	 256,
> -#endif
> -#ifdef CONFIG_HIGHMEM
> -	 32,
> -#endif
> -	 32,
> -};
> +int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
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
> -};
> +static char *zone_names[MAX_POSSIBLE_ZONES];
> +static char name_dma[] = "DMA";
> +static char name_dma32[] = "DMA32";
> +static char name_normal[] = "Normal";
> +static char name_highmem[] = "Highmem";
> +static char name_movable[] = "Movable";
> +
> +static inline void __init zone_variables_init(void)
> +{
> +	zone_names[ZONE_DMA] = name_dma;
> +	zone_names[ZONE_DMA32] = name_dma32;
> +	zone_names[ZONE_NORMAL] = name_normal;
> +	zone_names[ZONE_HIGHMEM] = name_highmem;
> +	zone_names[ZONE_MOVABLE] = name_movable;

You are able to always assign these as the array is sized on
MAX_POSSIBLE_ZONES, so I would have thought that these could be
statically initialised right?

static char * const zone_names = {
[ZONE_DMA] = "DMA",
[ZONE_DMA32] = "DMA32",
...
};


And in fact if you were to simply size sysctl_lowmem_reserve_ratio at
MAX_POSSIBLE_ZONES could you not do the same there too?  Then you would
not need to introduce zone_variables_init().

int sysctl_lowmem_reserve_ratio[MAX_POSSIBLE_ZONES] = {
[ZONE_DMA] = 256,
[ZONE_DMA32] = 256,
[ZONE_HIGHMEM] = 32
};

>  +	if (is_configured_zone(ZONE_DMA))
> +		sysctl_lowmem_reserve_ratio[ZONE_DMA] = 256;
> +	if (is_configured_zone(ZONE_DMA32))
> +		sysctl_lowmem_reserve_ratio[ZONE_DMA32] = 256;
> +	if (is_configured_zone(ZONE_HIGHMEM))
> +		sysctl_lowmem_reserve_ratio[ZONE_NORMAL] = 32;
> +	/* HIGHMEM and MOVABLE have value 0 */
> +}
>  
>  int min_free_kbytes = 1024;
>  
> @@ -135,8 +134,8 @@ static unsigned long __meminitdata dma_r
>  
>    static struct node_active_region __meminitdata early_node_map[MAX_ACTIVE_REGIONS];
>    static int __meminitdata nr_nodemap_entries;
> -  static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
> -  static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
> +  static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_POSSIBLE_ZONES];
> +  static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_POSSIBLE_ZONES];
>  #ifdef CONFIG_MEMORY_HOTPLUG_RESERVE
>    static unsigned long __meminitdata node_boundary_start_pfn[MAX_NUMNODES];
>    static unsigned long __meminitdata node_boundary_end_pfn[MAX_NUMNODES];
> @@ -1835,14 +1834,15 @@ void si_meminfo_node(struct sysinfo *val
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
> @@ -3487,7 +3487,6 @@ void __meminit free_area_init_node(int n
>  	calculate_node_totalpages(pgdat, zones_size, zholes_size);
>  
>  	alloc_node_mem_map(pgdat);
> -
>  	free_area_init_core(pgdat, zones_size, zholes_size);
>  }

Whitespace change.

>  
> @@ -3871,6 +3870,7 @@ void __init free_area_init_nodes(unsigne
>  						early_node_map[i].end_pfn);
>  
>  	/* Initialise every node */
> +	zone_variables_init();
>  	setup_nr_node_ids();
>  	for_each_online_node(nid) {
>  		pg_data_t *pgdat = NODE_DATA(nid);
> @@ -3888,7 +3888,9 @@ static int __init cmdline_parse_kernelco
>  	unsigned long long coremem;
>  	if (!p)
>  		return -EINVAL;
> -
> +	/* can we use ZONE_MOVABLE ? */
> +	if (!is_configured_zone(ZONE_MOVABLE))
> +		return 0;

Will this cause an error to the user?  Probabally want it too.

>  	coremem = memparse(p, &p);
>  	required_kernelcore = coremem >> PAGE_SHIFT;
>  
> @@ -3927,6 +3929,7 @@ EXPORT_SYMBOL(contig_page_data);
>  
>  void __init free_area_init(unsigned long *zones_size)
>  {
> +	zone_variables_init();
>  	free_area_init_node(0, NODE_DATA(0), zones_size,
>  			__pa(PAGE_OFFSET) >> PAGE_SHIFT, NULL);
>  }

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
