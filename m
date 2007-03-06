Date: Tue, 6 Mar 2007 07:36:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC} memory unplug patchset prep [1/16] zone ids cleanup
In-Reply-To: <20070306134232.bb024956.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0703052320140.21484@chino.kir.corp.google.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
 <20070306134232.bb024956.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007, KAMEZAWA Hiroyuki wrote:

> OThis patch defines ZONE_DMA,DMA32,HIGHMEM on *any* config.
> MAX_NR_ZONES is unchanged and not-configured zones's id is greater than it.
> Now, you can check zone is configured or not by (zone_id < MAX_NR_ZONES).
> 
> Good bye #ifdefs. Compiler will do enough work, I think.
> 

Eliminating the abundance of #ifdef's certainly seems like a worthwhile 
goal.

Few comments below.

> Index: devel-tree-2.6.20-mm2/include/linux/mmzone.h
> ===================================================================
> --- devel-tree-2.6.20-mm2.orig/include/linux/mmzone.h
> +++ devel-tree-2.6.20-mm2/include/linux/mmzone.h
> @@ -142,9 +142,24 @@ enum zone_type {
>  	 */
>  	ZONE_HIGHMEM,
>  #endif
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
> +	MAX_POSSIBLE_ZONES
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
> @@ -500,11 +515,7 @@ static inline int populated_zone(struct 
>  
>  static inline int is_highmem_idx(enum zone_type idx)
>  {
> -#ifdef CONFIG_HIGHMEM
>  	return (idx == ZONE_HIGHMEM);
> -#else
> -	return 0;
> -#endif
>  }
>  

Doesn't this need a check for is_configured_zone(idx) as well since this 
will return 1 if we pass in idx == ZONE_HIGHMEM even though it's above 
MAX_NR_ZONES?

>  static inline int is_normal_idx(enum zone_type idx)
> @@ -520,11 +531,7 @@ static inline int is_normal_idx(enum zon
>   */
>  static inline int is_highmem(struct zone *zone)
>  {
> -#ifdef CONFIG_HIGHMEM
>  	return zone == zone->zone_pgdat->node_zones + ZONE_HIGHMEM;
> -#else
> -	return 0;
> -#endif
>  }
>  

The only call site for this after your patchset is applied is in i386 code 
which you can probably remove with the identity idx.

>  static inline int is_normal(struct zone *zone)
> @@ -534,20 +541,12 @@ static inline int is_normal(struct zone 
>  
>  static inline int is_dma32(struct zone *zone)
>  {
> -#ifdef CONFIG_ZONE_DMA32
>  	return zone == zone->zone_pgdat->node_zones + ZONE_DMA32;
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

Neither is_dma32() nor is_dma() are even used anymore.

>  /* These two functions are used to setup the per zone pages min values */
> Index: devel-tree-2.6.20-mm2/mm/page_alloc.c
> ===================================================================
> --- devel-tree-2.6.20-mm2.orig/mm/page_alloc.c
> +++ devel-tree-2.6.20-mm2/mm/page_alloc.c
> @@ -72,32 +72,34 @@ static void __free_pages_ok(struct page 
>   * TBD: should special case ZONE_DMA32 machines here - in those we normally
>   * don't need any ZONE_NORMAL reservation
>   */
> -int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
> -#ifdef CONFIG_ZONE_DMA
> -	 256,
> -#endif
> -#ifdef CONFIG_ZONE_DMA32
> -	 256,
> -#endif
> -#ifdef CONFIG_HIGHMEM
> -	 32
> -#endif
> -};
> +int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
>  

Probably an easier way to initialize these instead of 
zone_variables_init() is like this:

	int sysctl_lowmem_reserve_ratio[MAX_POSSIBLE_ZONES-1] = {
		[ZONE_DMA]	= 256,
		[ZONE_DMA32]	= 256,
		[ZONE_HIGHMEM]	= 32 };

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
> -	 "HighMem"
> -#endif
> -};
> +static char *zone_names[MAX_POSSIBLE_ZONES];
> +

Likewise:

	static const char *zone_names[MAX_POSSIBLE_ZONES-1] = {
		[ZONE_DMA]	= "DMA",
		[ZONE_DMA32]	= "DMA32",
		[ZONE_NORMAL]	= "Normal",
		[ZONE_HIGHMEM]	= "HighMem" };

> +static char name_dma[] = "DMA";
> +static char name_dma32[] = "DMA32";
> +static char name_normal[] = "Normal";
> +static char name_highmem[] = "Highmem";
> +
> +static inline void __meminit zone_variables_init(void)
> +{
> +	if (zone_names[0] != NULL)
> +		return;
> +	zone_names[ZONE_DMA] = name_dma;
> +	zone_names[ZONE_DMA32] = name_dma32;
> +	zone_names[ZONE_NORMAL] = name_normal;
> +	zone_names[ZONE_HIGHMEM] = name_highmem;
> +
> +	/* ZONE below NORAML has ratio 256 */
> +	if (is_configured_zone(ZONE_DMA))
> +		sysctl_lowmem_reserve_ratio[ZONE_DMA] = 256;
> +	if (is_configured_zone(ZONE_DMA32))
> +		sysctl_lowmem_reserve_ratio[ZONE_DMA32] = 256;
> +	if (is_configured_zone(ZONE_HIGHMEM))
> +		sysctl_lowmem_reserve_ratio[ZONE_HIGHMEM] = 32;
> +}
>  

Then you can avoid this.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
