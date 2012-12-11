Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 73BBB6B0071
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 08:20:41 -0500 (EST)
Received: by mail-ia0-f177.google.com with SMTP id u21so6594679ial.36
        for <linux-mm@kvack.org>; Tue, 11 Dec 2012 05:20:40 -0800 (PST)
Message-ID: <1355232032.1459.2.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH v3 3/5] page_alloc: Introduce zone_movable_limit[] to
 keep movable limit for nodes
From: Simon Jeons <simon.jeons@gmail.com>
Date: Tue, 11 Dec 2012 07:20:32 -0600
In-Reply-To: <50C729E7.4040108@huawei.com>
References: <1355193207-21797-1-git-send-email-tangchen@cn.fujitsu.com>
	  <1355193207-21797-4-git-send-email-tangchen@cn.fujitsu.com>
	  <50C6A36C.5030606@huawei.com> <1355228650.1919.9.camel@kernel.cn.ibm.com>
	 <50C729E7.4040108@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, jiang.liu@huawei.com, hpa@zytor.com, akpm@linux-foundation.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Tue, 2012-12-11 at 20:41 +0800, Jianguo Wu wrote:
> On 2012/12/11 20:24, Simon Jeons wrote:
> 
> > On Tue, 2012-12-11 at 11:07 +0800, Jianguo Wu wrote:
> >> On 2012/12/11 10:33, Tang Chen wrote:
> >>
> >>> This patch introduces a new array zone_movable_limit[] to store the
> >>> ZONE_MOVABLE limit from movablecore_map boot option for all nodes.
> >>> The function sanitize_zone_movable_limit() will find out to which
> >>> node the ranges in movable_map.map[] belongs, and calculates the
> >>> low boundary of ZONE_MOVABLE for each node.
> >>>
> >>> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> >>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> >>> Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
> >>> Reviewed-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> >>> Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
> >>> ---
> >>>  mm/page_alloc.c |   77 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >>>  1 files changed, 77 insertions(+), 0 deletions(-)
> >>>
> >>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >>> index 1c91d16..4853619 100644
> >>> --- a/mm/page_alloc.c
> >>> +++ b/mm/page_alloc.c
> >>> @@ -206,6 +206,7 @@ static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
> >>>  static unsigned long __initdata required_kernelcore;
> >>>  static unsigned long __initdata required_movablecore;
> >>>  static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
> >>> +static unsigned long __meminitdata zone_movable_limit[MAX_NUMNODES];
> >>>  
> >>>  /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
> >>>  int movable_zone;
> >>> @@ -4340,6 +4341,77 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
> >>>  	return __absent_pages_in_range(nid, zone_start_pfn, zone_end_pfn);
> >>>  }
> >>>  
> >>> +/**
> >>> + * sanitize_zone_movable_limit - Sanitize the zone_movable_limit array.
> >>> + *
> >>> + * zone_movable_limit is initialized as 0. This function will try to get
> >>> + * the first ZONE_MOVABLE pfn of each node from movablecore_map, and
> >>> + * assigne them to zone_movable_limit.
> >>> + * zone_movable_limit[nid] == 0 means no limit for the node.
> >>> + *
> >>> + * Note: Each range is represented as [start_pfn, end_pfn)
> >>> + */
> >>> +static void __meminit sanitize_zone_movable_limit(void)
> >>> +{
> >>> +	int map_pos = 0, i, nid;
> >>> +	unsigned long start_pfn, end_pfn;
> >>> +
> >>> +	if (!movablecore_map.nr_map)
> >>> +		return;
> >>> +
> >>> +	/* Iterate all ranges from minimum to maximum */
> >>> +	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
> >>> +		/*
> >>> +		 * If we have found lowest pfn of ZONE_MOVABLE of the node
> >>> +		 * specified by user, just go on to check next range.
> >>> +		 */
> >>> +		if (zone_movable_limit[nid])
> >>> +			continue;
> >>> +
> >>> +#ifdef CONFIG_ZONE_DMA
> >>> +		/* Skip DMA memory. */
> >>> +		if (start_pfn < arch_zone_highest_possible_pfn[ZONE_DMA])
> >>> +			start_pfn = arch_zone_highest_possible_pfn[ZONE_DMA];
> >>> +#endif
> >>> +
> >>> +#ifdef CONFIG_ZONE_DMA32
> >>> +		/* Skip DMA32 memory. */
> >>> +		if (start_pfn < arch_zone_highest_possible_pfn[ZONE_DMA32])
> >>> +			start_pfn = arch_zone_highest_possible_pfn[ZONE_DMA32];
> >>> +#endif
> >>> +
> >>> +#ifdef CONFIG_HIGHMEM
> >>> +		/* Skip lowmem if ZONE_MOVABLE is highmem. */
> >>> +		if (zone_movable_is_highmem() &&
> >>
> >> Hi Tang,
> >>
> >> I think zone_movable_is_highmem() is not work correctly here.
> >> 	sanitize_zone_movable_limit
> >> 		zone_movable_is_highmem      <--using movable_zone here
> >> 	find_zone_movable_pfns_for_nodes
> >> 		find_usable_zone_for_movable <--movable_zone is specified here
> >>
> > 
> > Hi Jiangguo and Chen,
> > 
> > - What's the meaning of zone_movable_is_highmem(), does it mean all zone
> > highmem pages are zone movable pages or ....
> 
> Hi Simon,
> 
> zone_movable_is_highmem() means whether zone pages in ZONE_MOVABLE are taken from
> highmem.
> 
> > - dmesg 
> > 
> >> 0.000000] Zone ranges:
> >> [    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
> >> [    0.000000]   Normal   [mem 0x01000000-0x373fdfff]
> >> [    0.000000]   HighMem  [mem 0x373fe000-0xb6cfffff]
> >> [    0.000000] Movable zone start for each node
> >> [    0.000000]   Node 0: 0x97800000
> > 
> > Why the start of zone movable is in the range of zone highmem, if all
> > the pages of zone movable are from zone highmem? If the answer is yes, 
> 
> > zone movable and zone highmem are in the equal status or not?
> 
> The pages of zone_movable can be taken from zone_movalbe or zone_normal,
> if we have highmem, then zone_movable will be taken from zone_highmem,
> otherwise zone_movable will be taken from zone_normal.
> 
> you can refer to find_usable_zone_for_movable().

Hi Jiangguo,

I have 8G memory, movablecore=5G, but dmesg looks strange, what
happended to me?

> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
> [    0.000000]   Normal   [mem 0x01000000-0x373fdfff]
> [    0.000000]   HighMem  [mem 0x373fe000-0xb6cfffff]
> [    0.000000] Movable zone start for each node
> [    0.000000]   Node 0: 0xb7000000
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x00010000-0x0009cfff]
> [    0.000000]   node   0: [mem 0x00100000-0x1fffffff]
> [    0.000000]   node   0: [mem 0x20200000-0x3fffffff]
> [    0.000000]   node   0: [mem 0x40200000-0xb69cbfff]
> [    0.000000]   node   0: [mem 0xb6a46000-0xb6a47fff]
> [    0.000000]   node   0: [mem 0xb6b1c000-0xb6cfffff]
> [    0.000000] On node 0 totalpages: 748095
> [    0.000000]   DMA zone: 32 pages used for memmap
> [    0.000000]   DMA zone: 0 pages reserved
> [    0.000000]   DMA zone: 3949 pages, LIFO batch:0
> [    0.000000]   Normal zone: 1736 pages used for memmap
> [    0.000000]   Normal zone: 219958 pages, LIFO batch:31
> [    0.000000]   HighMem zone: 4083 pages used for memmap
> [    0.000000]   HighMem zone: 517569 pages, LIFO batch:31
> [    0.000000]   Movable zone: 768 pages, LIFO batch:0

> 
> Thanks,
> Jianguo Wu
> 
> > 
> >> I think Jiang Liu's patch works fine for highmem, please refer to:
> >> http://marc.info/?l=linux-mm&m=135476085816087&w=2
> >>
> >> Thanks,
> >> Jianguo Wu
> >>
> >>> +		    start_pfn < arch_zone_lowest_possible_pfn[ZONE_HIGHMEM])
> >>> +			start_pfn = arch_zone_lowest_possible_pfn[ZONE_HIGHMEM];
> >>> +#endif
> >>> +
> >>> +		if (start_pfn >= end_pfn)
> >>> +			continue;
> >>> +
> >>> +		while (map_pos < movablecore_map.nr_map) {
> >>> +			if (end_pfn <= movablecore_map.map[map_pos].start_pfn)
> >>> +				break;
> >>> +
> >>> +			if (start_pfn >= movablecore_map.map[map_pos].end_pfn) {
> >>> +				map_pos++;
> >>> +				continue;
> >>> +			}
> >>> +
> >>> +			/*
> >>> +			 * The start_pfn of ZONE_MOVABLE is either the minimum
> >>> +			 * pfn specified by movablecore_map, or 0, which means
> >>> +			 * the node has no ZONE_MOVABLE.
> >>> +			 */
> >>> +			zone_movable_limit[nid] = max(start_pfn,
> >>> +					movablecore_map.map[map_pos].start_pfn);
> >>> +
> >>> +			break;
> >>> +		}
> >>> +	}
> >>> +}
> >>> +
> >>>  #else /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
> >>>  static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
> >>>  					unsigned long zone_type,
> >>> @@ -4358,6 +4430,10 @@ static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
> >>>  	return zholes_size[zone_type];
> >>>  }
> >>>  
> >>> +static void __meminit sanitize_zone_movable_limit(void)
> >>> +{
> >>> +}
> >>> +
> >>>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
> >>>  
> >>>  static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
> >>> @@ -4923,6 +4999,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
> >>>  
> >>>  	/* Find the PFNs that ZONE_MOVABLE begins at in each node */
> >>>  	memset(zone_movable_pfn, 0, sizeof(zone_movable_pfn));
> >>> +	sanitize_zone_movable_limit();
> >>>  	find_zone_movable_pfns_for_nodes();
> >>>  
> >>>  	/* Print out the zone ranges */
> >>
> >>
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> > 
> > 
> > .
> > 
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
