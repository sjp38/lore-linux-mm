Date: Wed, 7 Mar 2007 11:02:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC} memory unplug patchset prep [9/16] create movable zone at
 boot
Message-Id: <20070307110221.f1a45523.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0703060139570.22477@chino.kir.corp.google.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
	<20070306135232.42a55807.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0703060139570.22477@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007 08:06:48 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 6 Mar 2007, KAMEZAWA Hiroyuki wrote:
> 
> > This patch adds codes for creating movable zones.
> > 
> > Add 2 kernel paramers.
> > - kernel_core_pages=XXX[KMG]
> > - kernel_core_ratio=xx
> > 
> 
> These would never be specified together, right?
> 
No. never be specified together.

> > Index: devel-tree-2.6.20-mm2/mm/page_alloc.c
> > ===================================================================
> > --- devel-tree-2.6.20-mm2.orig/mm/page_alloc.c
> > +++ devel-tree-2.6.20-mm2/mm/page_alloc.c
> > @@ -137,12 +137,16 @@ static unsigned long __initdata dma_rese
> >    int __initdata nr_nodemap_entries;
> >    unsigned long __initdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
> >    unsigned long __initdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
> > +  unsigned long __initdata lowest_movable_pfn[MAX_NUMNODES];
> > +  unsigned long kernel_core_ratio;
> > +  unsigned long kernel_core_pages;
> >  #ifdef CONFIG_MEMORY_HOTPLUG_RESERVE
> >    unsigned long __initdata node_boundary_start_pfn[MAX_NUMNODES];
> >    unsigned long __initdata node_boundary_end_pfn[MAX_NUMNODES];
> >  #endif /* CONFIG_MEMORY_HOTPLUG_RESERVE */
> >  #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
> >  
> > +
> >  #ifdef CONFIG_DEBUG_VM
> >  static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
> >  {
> 
> You could probably get away with:
> 
> 	union {
> 		unsigned long kernel_core_ratio;
> 		unsigned long kernel_core_pages;
> 	};
> 
> > @@ -2604,6 +2608,8 @@ void __init get_pfn_range_for_nid(unsign
> >   */
> >  unsigned long __init zone_spanned_pages_in_node(int nid,
> >  					unsigned long zone_type,
> > +					unsigned long *start_pfn,
> > +					unsigned long *end_pfn,
> >  					unsigned long *ignored)
> >  {
> >  	unsigned long node_start_pfn, node_end_pfn;
> > @@ -2611,8 +2617,30 @@ unsigned long __init zone_spanned_pages_
> >  
> >  	/* Get the start and end of the node and zone */
> >  	get_pfn_range_for_nid(nid, &node_start_pfn, &node_end_pfn);
> > -	zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
> > -	zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
> > +	if (start_pfn)
> > +		*start_pfn = 0;
> > +	if (end_pfn)
> > +		*end_pfn = 0;
> > +	if (!is_configured_zone(ZONE_MOVABLE) ||
> > +		   lowest_movable_pfn[nid] == 0) {
> > +		/* we don't use ZONE_MOVABLE */
> > +		zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
> > +		zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
> > +	} else if (zone_type == ZONE_MOVABLE) {
> > +		zone_start_pfn = lowest_movable_pfn[nid];
> > +		zone_end_pfn = node_end_pfn;
> > +	} else {
> > +		/* adjust range to lowest_movable_pfn[] */
> > +		zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
> > +		zone_start_pfn = max(zone_start_pfn, node_start_pfn);
> > +
> > +		if (zone_start_pfn >= lowest_movable_pfn[nid])
> > +			return 0;
> > +		zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
> > +		zone_end_pfn = min(zone_end_pfn, node_end_pfn);
> > +		if (zone_end_pfn > lowest_movable_pfn[nid])
> > +			zone_end_pfn = lowest_movable_pfn[nid];
> > +	}
> >  
> >  	/* Check that this node has pages within the zone's required range */
> >  	if (zone_end_pfn < node_start_pfn || zone_start_pfn > node_end_pfn)
> 
> These hacks of returning start_pfn and end_pfn depending on where it was 
> called from and testing for things like start_pfn == end_pfn doesn't make 
> much sense.  It'd probably be better to separate this logic out into a 
> helper function and then call it from zone_absent_pages_in_node() and 
> zone_spanned_pages_in_node(), respectively.
> 
Hmm. This whole logic is different from Mel's. 
I'll look into his and reconsider again.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
