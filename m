Date: Tue, 6 Mar 2007 08:06:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC} memory unplug patchset prep [9/16] create movable zone at
 boot
In-Reply-To: <20070306135232.42a55807.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0703060139570.22477@chino.kir.corp.google.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
 <20070306135232.42a55807.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007, KAMEZAWA Hiroyuki wrote:

> This patch adds codes for creating movable zones.
> 
> Add 2 kernel paramers.
> - kernel_core_pages=XXX[KMG]
> - kernel_core_ratio=xx
> 

These would never be specified together, right?

> Index: devel-tree-2.6.20-mm2/mm/page_alloc.c
> ===================================================================
> --- devel-tree-2.6.20-mm2.orig/mm/page_alloc.c
> +++ devel-tree-2.6.20-mm2/mm/page_alloc.c
> @@ -137,12 +137,16 @@ static unsigned long __initdata dma_rese
>    int __initdata nr_nodemap_entries;
>    unsigned long __initdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
>    unsigned long __initdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
> +  unsigned long __initdata lowest_movable_pfn[MAX_NUMNODES];
> +  unsigned long kernel_core_ratio;
> +  unsigned long kernel_core_pages;
>  #ifdef CONFIG_MEMORY_HOTPLUG_RESERVE
>    unsigned long __initdata node_boundary_start_pfn[MAX_NUMNODES];
>    unsigned long __initdata node_boundary_end_pfn[MAX_NUMNODES];
>  #endif /* CONFIG_MEMORY_HOTPLUG_RESERVE */
>  #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
>  
> +
>  #ifdef CONFIG_DEBUG_VM
>  static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
>  {

You could probably get away with:

	union {
		unsigned long kernel_core_ratio;
		unsigned long kernel_core_pages;
	};

> @@ -2604,6 +2608,8 @@ void __init get_pfn_range_for_nid(unsign
>   */
>  unsigned long __init zone_spanned_pages_in_node(int nid,
>  					unsigned long zone_type,
> +					unsigned long *start_pfn,
> +					unsigned long *end_pfn,
>  					unsigned long *ignored)
>  {
>  	unsigned long node_start_pfn, node_end_pfn;
> @@ -2611,8 +2617,30 @@ unsigned long __init zone_spanned_pages_
>  
>  	/* Get the start and end of the node and zone */
>  	get_pfn_range_for_nid(nid, &node_start_pfn, &node_end_pfn);
> -	zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
> -	zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
> +	if (start_pfn)
> +		*start_pfn = 0;
> +	if (end_pfn)
> +		*end_pfn = 0;
> +	if (!is_configured_zone(ZONE_MOVABLE) ||
> +		   lowest_movable_pfn[nid] == 0) {
> +		/* we don't use ZONE_MOVABLE */
> +		zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
> +		zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
> +	} else if (zone_type == ZONE_MOVABLE) {
> +		zone_start_pfn = lowest_movable_pfn[nid];
> +		zone_end_pfn = node_end_pfn;
> +	} else {
> +		/* adjust range to lowest_movable_pfn[] */
> +		zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
> +		zone_start_pfn = max(zone_start_pfn, node_start_pfn);
> +
> +		if (zone_start_pfn >= lowest_movable_pfn[nid])
> +			return 0;
> +		zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
> +		zone_end_pfn = min(zone_end_pfn, node_end_pfn);
> +		if (zone_end_pfn > lowest_movable_pfn[nid])
> +			zone_end_pfn = lowest_movable_pfn[nid];
> +	}
>  
>  	/* Check that this node has pages within the zone's required range */
>  	if (zone_end_pfn < node_start_pfn || zone_start_pfn > node_end_pfn)

These hacks of returning start_pfn and end_pfn depending on where it was 
called from and testing for things like start_pfn == end_pfn doesn't make 
much sense.  It'd probably be better to separate this logic out into a 
helper function and then call it from zone_absent_pages_in_node() and 
zone_spanned_pages_in_node(), respectively.

> @@ -2733,20 +2781,115 @@ static void __init calculate_node_totalp
>  	enum zone_type i;
>  
>  	for (i = 0; i < MAX_NR_ZONES; i++)
> -		totalpages += zone_spanned_pages_in_node(pgdat->node_id, i,
> +		totalpages += zone_spanned_pages_in_node(pgdat->node_id, i, NULL, NULL,
>  								zones_size);
>  	pgdat->node_spanned_pages = totalpages;
>  
>  	realtotalpages = totalpages;
>  	for (i = 0; i < MAX_NR_ZONES; i++)
>  		realtotalpages -=
> -			zone_absent_pages_in_node(pgdat->node_id, i,
> +			zone_absent_pages_in_node(pgdat->node_id, i, 0, 0,
>  								zholes_size);
>  	pgdat->node_present_pages = realtotalpages;
>  	printk(KERN_DEBUG "On node %d totalpages: %lu\n", pgdat->node_id,
>  							realtotalpages);
>  }
>  
> +#ifdef CONFIG_ZONE_MOVABLE
> +
> +unsigned long calc_zone_alignment(unsigned long pfn)
> +{
> +#ifdef CONFIG_SPARSEMEM
> +	return (pfn + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK;
> +#else
> +	return (pfn + MAX_ORDER_NR_PAGES - 1) & ~(MAX_ORDER_NR_PAGES - 1)
> +#endif
> +}
> +

Another missing semicolon.

> +static void split_movable_pages(void)
> +{
> +	int i, nid;
> +	unsigned long total_pages, nr_pages, start_pfn, end_pfn, pfn;
> +	long core;
> +	for_each_online_node(nid) {
> +		lowest_movable_pfn[nid] = 0;
> +		pfn = 0;
> +		total_pages = 0;
> +		for_each_active_range_index_in_nid(i, nid) {
> +			start_pfn = early_node_map[i].start_pfn;
> +			end_pfn = early_node_map[i].end_pfn;
> +			total_pages += end_pfn - start_pfn;
> +		}
> +		core = total_pages * kernel_core_ratio/100;
> +		for_each_active_range_index_in_nid(i, nid) {
> +			start_pfn = early_node_map[i].start_pfn;
> +			end_pfn = early_node_map[i].end_pfn;
> +			nr_pages = end_pfn - start_pfn;
> +			if (nr_pages > core) {
> +				pfn = start_pfn + core;
> +				pfn = calc_zone_alignment(pfn);
> +				if (pfn < end_pfn) {
> +					lowest_movable_pfn[nid] = pfn;
> +					break;
> +				} else {
> +					core -= nr_pages;
> +					if (core < 0)
> +						core = 0;
> +				}
> +			} else {
> +				core -= nr_pages;
> +			}
> +		}
> +	}
> +	return;
> +}
> +
> +
> +static void reserve_movable_pages(void)
> +{
> +	memset(lowest_movable_pfn, 0, MAX_NUMNODES);
> +	if (kernel_core_pages) {
> +		alloc_core_pages_from_low();
> +	} else if (kernel_core_ratio) {
> +		split_movable_pages();
> +	}
> +	return;
> +}
> +#else
> +static void reserve_movable_pages(void)
> +{
> +	return;
> +}
> +#endif
>  /*
>   * Set up the zone data structures:
>   *   - mark all pages reserved

reserve_movable_pages() and it's two helper functions, 
alloc_core_pages_from_low() and split_movable_pages(), can be __init?

If so, then both kernel_core_pages and kernel_core_ratio should be 
__initdata.

> Index: devel-tree-2.6.20-mm2/Documentation/kernel-parameters.txt
> ===================================================================
> --- devel-tree-2.6.20-mm2.orig/Documentation/kernel-parameters.txt
> +++ devel-tree-2.6.20-mm2/Documentation/kernel-parameters.txt
> @@ -764,6 +764,17 @@ and is between 256 and 4096 characters. 
>  
>  	keepinitrd	[HW,ARM]
>  
> +	kernel_core_pages=nn[KMG] [KNL, BOOT] divide the whole memory into
> +			not-movable and movable. movable memory can be
> +			used only for page cache and user data. This option
> +			specifies the amount of not-movable pages, called core
> +			pages. core pages are allocated from the lower address.
> +
> +	kernel_core_ratio=nn [KND, BOOT] specifies the amount of the core
> +			pages(see kernel_core_pages) by the ratio against
> +			total memory. If NUMA, core pages are allocated for
> +			each node by this ratio. "0" is not allowed.
> +
>  	kstack=N	[IA-32,X86-64] Print N words from the kernel stack
>  			in oops dumps.
>  

This documentation doesn't specify that we can't use both parameters 
together even though we can't.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
