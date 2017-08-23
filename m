Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8D528073C
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 01:35:54 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f86so6671322pfj.5
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 22:35:54 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id x184si504348pfx.215.2017.08.22.22.35.52
        for <linux-mm@kvack.org>;
        Tue, 22 Aug 2017 22:35:52 -0700 (PDT)
Date: Wed, 23 Aug 2017 14:36:12 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 0/6] proactive kcompactd
Message-ID: <20170823053612.GA19689@js1304-P5Q-DELUXE>
References: <20170727160701.9245-1-vbabka@suse.cz>
 <alpine.DEB.2.10.1708091353500.1218@chino.kir.corp.google.com>
 <20170821141014.GC1371@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170821141014.GC1371@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>

On Mon, Aug 21, 2017 at 10:10:14AM -0400, Johannes Weiner wrote:
> On Wed, Aug 09, 2017 at 01:58:42PM -0700, David Rientjes wrote:
> > On Thu, 27 Jul 2017, Vlastimil Babka wrote:
> > 
> > > As we discussed at last LSF/MM [1], the goal here is to shift more compaction
> > > work to kcompactd, which currently just makes a single high-order page
> > > available and then goes to sleep. The last patch, evolved from the initial RFC
> > > [2] does this by recording for each order > 0 how many allocations would have
> > > potentially be able to skip direct compaction, if the memory wasn't fragmented.
> > > Kcompactd then tries to compact as long as it takes to make that many
> > > allocations satisfiable. This approach avoids any hooks in allocator fast
> > > paths. There are more details to this, see the last patch.
> > > 
> > 
> > I think I would have liked to have seen "less proactive" :)
> > 
> > Kcompactd currently has the problem that it is MIGRATE_SYNC_LIGHT so it 
> > continues until it can defragment memory.  On a host with 128GB of memory 
> > and 100GB of it sitting in a hugetlb pool, we constantly get kcompactd 
> > wakeups for order-2 memory allocation.  The stats are pretty bad:
> > 
> > compact_migrate_scanned 2931254031294 
> > compact_free_scanned    102707804816705 
> > compact_isolated        1309145254 
> > 
> > 0.0012% of memory scanned is ever actually isolated.  We constantly see 
> > very high cpu for compaction_alloc() because kcompactd is almost always 
> > running in the background and iterating most memory completely needlessly 
> > (define needless as 0.0012% of memory scanned being isolated).
> 
> The free page scanner will inevitably wade through mostly used memory,
> but 0.0012% is lower than what systems usually have free. I'm guessing
> this is because of concurrent allocation & free cycles racing with the
> scanner? There could also be an issue with how we do partial scans.
> 
> Anyway, we've also noticed scalability issues with the current scanner
> on 128G and 256G machines. Even with a better efficiency - finding the
> 1% of free memory, that's still a ton of linear search space.
> 
> I've been toying around with the below patch. It adds a free page
> bitmap, allowing the free scanner to quickly skip over the vast areas
> of used memory. I don't have good data on skip-efficiency at higher
> uptimes and the resulting fragmentation yet. The overhead added to the
> page allocator is concerning, but I cannot think of a better way to
> make the search more efficient. What do you guys think?

Hello, Johannes.

I think that the best solution is that the compaction doesn't do linear
scan completely. Vlastimil already have suggested that idea.

mm, compaction: direct freepage allocation for async direct
compaction

lkml.kernel.org/r/<1459414236-9219-5-git-send-email-vbabka@suse.cz>

It uses the buddy allocator to get a freepage so there is no linear
scan. It would completely remove scalability issue.

Unfortunately, he applied this idea only to async compaction since
changing the other compaction mode will probably cause long term
fragmentation. And, I disagreed with that idea at that time since
different compaction logic for different compaction mode would make
the system more unpredicatable.

I doubt long term fragmentation is a real issue in practice. We loses
too much things to prevent long term fragmentation. I think that it's
the time to fix up the real issue (yours and David's) by giving up the
solution for long term fragmentation.

If someone doesn't agree with above solution, your approach looks the
second best to me. Though, there is something to optimize.

I think that we don't need to be precise to track the pageblock's
freepage state. Compaction is a far rare event compared to page
allocation so compaction could be tolerate with false positive.

So, my suggestion is:

1) Use 1 bit for the pageblock. Reusing PB_migrate_skip looks the best
to me.
2) Mark PB_migrate_skip only in free path and only when needed.
Unmark it in compaction if freepage scan fails in that pageblock.
In compaction, skip the pageblock if PB_migrate_skip is set. It means
that there is no freepage in the pageblock.

Following is some code about my suggestion.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 90b1996..c292ad2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -798,12 +798,17 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 static inline void __free_one_page(struct page *page,
                unsigned long pfn,
                struct zone *zone, unsigned int order,
-               int migratetype)
+               int pageblock_flag)
 {
        unsigned long combined_pfn;
        unsigned long uninitialized_var(buddy_pfn);
        struct page *buddy;
        unsigned int max_order;
+       int migratetype = pageblock_flag & MT_MASK;
+       int need_set_skip = !(pageblock_flag & SKIP_MASK);
+
+       if (unlikely(need_set_skip))
+               set_pageblock_skip(page);
 
        max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
 
@@ -1155,7 +1160,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 static void free_one_page(struct zone *zone,
                                struct page *page, unsigned long pfn,
                                unsigned int order,
-                               int migratetype)
+                               int pageblock_flag)
 {
        spin_lock(&zone->lock);
        if (unlikely(has_isolate_pageblock(zone) ||
@@ -1248,10 +1253,10 @@ static void __free_pages_ok(struct page *page, unsigned int order)
        if (!free_pages_prepare(page, order, true))
                return;
 
-       migratetype = get_pfnblock_migratetype(page, pfn);
+       pageblock_flage = get_pfnblock_flag(page, pfn);
        local_irq_save(flags);
        __count_vm_events(PGFREE, 1 << order);
-       free_one_page(page_zone(page), page, pfn, order, migratetype);
+       free_one_page(page_zone(page), page, pfn, order, pageblock_flag);
        local_irq_restore(flags);
 }

We already access the pageblock flag for migratetype. Reusing it would
reduce cache-line overhead. And, updating bit only happens when first
freepage in the pageblock is freed. We don't need to modify allocation
path since we don't track the freepage state precisly. I guess that
this solution has almost no overhead in allocation/free path.

If allocation happens after free, compaction would see false-positive
so it would scan the pageblock uselessly. But, as mentioned above,
compaction is a far rare event so doing more thing in the compaction
with reducing the overhead on allocation/free path seems better to me.

Johannes, what do you think about it?

Thanks.

> 
> ---
> 
> >From 115c76ee34c4c133e527b8b5358a8baed09d5bfb Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Fri, 16 Jun 2017 12:26:01 -0400
> Subject: [PATCH] mm: fast free bitmap for compaction free scanner
> 
> XXX: memory hotplug does "bootmem registering" for usemap
> XXX: evaluate page allocator performance impact of bitmap
> XXX: evaluate skip efficiency after some uptime
> 
> On Facebook machines, we routinely observe kcompactd running at
> 80-100% of CPU, spending most cycles in isolate_freepages_block(). The
> allocations that trigger this are order-3 requests coming in from the
> network stack at a rate of hundreds per second. In 4.6, the order-2
> kernel stack allocations on each fork also heavily contributed to that
> load; luckily we can use vmap stacks in later kernels. Still, there is
> something to be said about the scalability of the compaction free page
> scanner when we're looking at systems with hundreds of gigs of memory.
> 
> The compaction code scans movable pages and free pages from opposite
> ends of the PFN range. By packing used pages into one end of RAM, it
> frees up contiguous blocks at the other end. However, free pages
> usually don't make up more than 1-2% of a system's memory - that's a
> small needle for a linear search through the haystack. Looking at page
> structs one-by-one to find these pages is a serious bottleneck.
> 
> Our workaround in the Facebook fleet has been to bump min_free_kbytes
> to several gigabytes, just to make the needle bigger. But in the
> long-term that's not very satisfying answer to the problem.
> 
> This patch sets up a bitmap of free pages that the page allocator
> maintains and the compaction free scanner can consult to quickly skip
> over the majority of page blocks that have no free pages left in them.
> 
> A 24h production A/B test in our fleet showed a 62.67% reduction in
> cycles spent in isolate_freepages_block(). The load on the machines
> isn't exactly the same, but the patched kernel actually finishes more
> jobs/minute and puts, when adding up compact_free_scanned and the new
> compact_free_skipped, much more pressure on the compaction subsystem.
> 
> One bit per 4k page means the bitmap consumes 0.02% of total memory.
> 
> Not-yet-signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/mmzone.h        | 12 ++++++--
>  include/linux/vm_event_item.h |  3 +-
>  mm/compaction.c               |  9 +++++-
>  mm/page_alloc.c               | 71 +++++++++++++++++++++++++++++++++++++++----
>  mm/sparse.c                   | 64 +++++++++++++++++++++++++++++++++++---
>  mm/vmstat.c                   |  1 +
>  6 files changed, 145 insertions(+), 15 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index ef6a13b7bd3e..55c663f3da69 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -374,9 +374,12 @@ struct zone {
>  
>  #ifndef CONFIG_SPARSEMEM
>  	/*
> -	 * Flags for a pageblock_nr_pages block. See pageblock-flags.h.
> -	 * In SPARSEMEM, this map is stored in struct mem_section
> +	 * Allocation bitmap and flags for a pageblock_nr_pages
> +	 * block. See pageblock-flags.h.
> +	 *
> +	 * In SPARSEMEM, this map is * stored in struct mem_section
>  	 */
> +	unsigned long		*pageblock_freemap;
>  	unsigned long		*pageblock_flags;
>  #endif /* CONFIG_SPARSEMEM */
>  
> @@ -768,6 +771,7 @@ bool zone_watermark_ok(struct zone *z, unsigned int order,
>  		unsigned int alloc_flags);
>  bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
>  		unsigned long mark, int classzone_idx);
> +int test_page_freemap(struct page *page, unsigned int nr_pages);
>  enum memmap_context {
>  	MEMMAP_EARLY,
>  	MEMMAP_HOTPLUG,
> @@ -1096,7 +1100,8 @@ struct mem_section {
>  	 */
>  	unsigned long section_mem_map;
>  
> -	/* See declaration of similar field in struct zone */
> +	/* See declaration of similar fields in struct zone */
> +	unsigned long *pageblock_freemap;
>  	unsigned long *pageblock_flags;
>  #ifdef CONFIG_PAGE_EXTENSION
>  	/*
> @@ -1104,6 +1109,7 @@ struct mem_section {
>  	 * section. (see page_ext.h about this.)
>  	 */
>  	struct page_ext *page_ext;
> +#else
>  	unsigned long pad;
>  #endif
>  	/*
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index d84ae90ccd5c..6d6371df551b 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -52,7 +52,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		PGMIGRATE_SUCCESS, PGMIGRATE_FAIL,
>  #endif
>  #ifdef CONFIG_COMPACTION
> -		COMPACTMIGRATE_SCANNED, COMPACTFREE_SCANNED,
> +		COMPACTMIGRATE_SCANNED,
> +		COMPACTFREE_SKIPPED, COMPACTFREE_SCANNED,
>  		COMPACTISOLATED,
>  		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
>  		KCOMPACTD_WAKE,
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 613c59e928cb..1da4e557eaca 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -420,6 +420,13 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  
>  	cursor = pfn_to_page(blockpfn);
>  
> +	/* Usually, most memory is used. Skip full blocks quickly */
> +	if (!strict && !test_page_freemap(cursor, end_pfn - blockpfn)) {
> +		count_compact_events(COMPACTFREE_SKIPPED, end_pfn - blockpfn);
> +		blockpfn = end_pfn;
> +		goto skip_full;
> +	}
> +
>  	/* Isolate free pages. */
>  	for (; blockpfn < end_pfn; blockpfn++, cursor++) {
>  		int isolated;
> @@ -525,7 +532,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  	 */
>  	if (unlikely(blockpfn > end_pfn))
>  		blockpfn = end_pfn;
> -
> +skip_full:
>  	trace_mm_compaction_isolate_freepages(*start_pfn, blockpfn,
>  					nr_scanned, total_isolated);
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2302f250d6b1..5076c982d06a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -364,6 +364,54 @@ static inline bool update_defer_init(pg_data_t *pgdat,
>  }
>  #endif
>  
> +#ifdef CONFIG_SPARSEMEM
> +static void load_freemap(struct page *page,
> +			 unsigned long **bits, unsigned int *idx)
> +{
> +	unsigned long pfn = page_to_pfn(page);
> +
> +	*bits = __pfn_to_section(pfn)->pageblock_freemap;
> +	*idx = pfn & (PAGES_PER_SECTION - 1);
> +}
> +#else
> +static void load_freemap(struct page *page,
> +			 unsigned long **bits, unsigned int idx)
> +{
> +	unsigned long pfn = page_to_pfn(page);
> +	struct zone *zone = page_zone(page);
> +
> +	*bits = zone->pageblock_freemap;
> +	*idx = pfn - zone->zone_start_pfn;
> +}
> +#endif /* CONFIG_SPARSEMEM */
> +
> +static void set_page_freemap(struct page *page, int order)
> +{
> +	unsigned long *bits;
> +	unsigned int idx;
> +
> +	load_freemap(page, &bits, &idx);
> +	bitmap_set(bits, idx, 1 << order);
> +}
> +
> +static void clear_page_freemap(struct page *page, int order)
> +{
> +	unsigned long *bits;
> +	unsigned int idx;
> +
> +	load_freemap(page, &bits, &idx);
> +	bitmap_clear(bits, idx, 1 << order);
> +}
> +
> +int test_page_freemap(struct page *page, unsigned int nr_pages)
> +{
> +	unsigned long *bits;
> +	unsigned int idx;
> +
> +	load_freemap(page, &bits, &idx);
> +	return !bitmap_empty(bits + idx, nr_pages);
> +}
> +
>  /* Return a pointer to the bitmap storing bits affecting a block of pages */
>  static inline unsigned long *get_pageblock_bitmap(struct page *page,
>  							unsigned long pfn)
> @@ -718,12 +766,14 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
>  
>  static inline void set_page_order(struct page *page, unsigned int order)
>  {
> +	set_page_freemap(page, order);
>  	set_page_private(page, order);
>  	__SetPageBuddy(page);
>  }
>  
>  static inline void rmv_page_order(struct page *page)
>  {
> +	clear_page_freemap(page, page_private(page));
>  	__ClearPageBuddy(page);
>  	set_page_private(page, 0);
>  }
> @@ -5906,14 +5956,16 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
>   * round what is now in bits to nearest long in bits, then return it in
>   * bytes.
>   */
> -static unsigned long __init usemap_size(unsigned long zone_start_pfn, unsigned long zonesize)
> +static unsigned long __init map_size(unsigned long zone_start_pfn,
> +				     unsigned long zonesize,
> +				     unsigned int bits)
>  {
>  	unsigned long usemapsize;
>  
>  	zonesize += zone_start_pfn & (pageblock_nr_pages-1);
>  	usemapsize = roundup(zonesize, pageblock_nr_pages);
>  	usemapsize = usemapsize >> pageblock_order;
> -	usemapsize *= NR_PAGEBLOCK_BITS;
> +	usemapsize *= bits;
>  	usemapsize = roundup(usemapsize, 8 * sizeof(unsigned long));
>  
>  	return usemapsize / 8;
> @@ -5924,12 +5976,19 @@ static void __init setup_usemap(struct pglist_data *pgdat,
>  				unsigned long zone_start_pfn,
>  				unsigned long zonesize)
>  {
> -	unsigned long usemapsize = usemap_size(zone_start_pfn, zonesize);
> +	unsigned long size;
> +
> +	zone->pageblock_freemap = NULL;
>  	zone->pageblock_flags = NULL;
> -	if (usemapsize)
> +
> +	size = map_size(zone_start_pfn, zonesize, 1);
> +	if (size)
> +		zone->pageblock_freemap =
> +			memblock_virt_alloc_node_nopanic(size, pgdat->node_id);
> +	size = map_size(zone_start_pfn, zonesize, NR_PAGEBLOCK_BITS);
> +	if (size)
>  		zone->pageblock_flags =
> -			memblock_virt_alloc_node_nopanic(usemapsize,
> -							 pgdat->node_id);
> +			memblock_virt_alloc_node_nopanic(size, pgdat->node_id);
>  }
>  #else
>  static inline void setup_usemap(struct pglist_data *pgdat, struct zone *zone,
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 6903c8fc3085..f295b012cac9 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -233,7 +233,7 @@ struct page *sparse_decode_mem_map(unsigned long coded_mem_map, unsigned long pn
>  
>  static int __meminit sparse_init_one_section(struct mem_section *ms,
>  		unsigned long pnum, struct page *mem_map,
> -		unsigned long *pageblock_bitmap)
> +		unsigned long *pageblock_freemap, unsigned long *pageblock_flags)
>  {
>  	if (!present_section(ms))
>  		return -EINVAL;
> @@ -241,17 +241,27 @@ static int __meminit sparse_init_one_section(struct mem_section *ms,
>  	ms->section_mem_map &= ~SECTION_MAP_MASK;
>  	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum) |
>  							SECTION_HAS_MEM_MAP;
> - 	ms->pageblock_flags = pageblock_bitmap;
> +	ms->pageblock_freemap = pageblock_freemap;
> +	ms->pageblock_flags = pageblock_flags;
>  
>  	return 1;
>  }
>  
> +unsigned long freemap_size(void)
> +{
> +	return BITS_TO_LONGS(PAGES_PER_SECTION) * sizeof(unsigned long);
> +}
> +
>  unsigned long usemap_size(void)
>  {
>  	return BITS_TO_LONGS(SECTION_BLOCKFLAGS_BITS) * sizeof(unsigned long);
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> +static unsigned long *__kmalloc_section_freemap(void)
> +{
> +	return kmalloc(freemap_size(), GFP_KERNEL);
> +}
>  static unsigned long *__kmalloc_section_usemap(void)
>  {
>  	return kmalloc(usemap_size(), GFP_KERNEL);
> @@ -338,6 +348,32 @@ static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
>  }
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  
> +static void __init sparse_early_freemaps_alloc_node(void *data,
> +				 unsigned long pnum_begin,
> +				 unsigned long pnum_end,
> +				 unsigned long freemap_count, int nodeid)
> +{
> +	void *freemap;
> +	unsigned long pnum;
> +	unsigned long **freemap_map = (unsigned long **)data;
> +	int size = freemap_size();
> +
> +	freemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
> +							size * freemap_count);
> +	if (!freemap) {
> +		pr_warn("%s: allocation failed\n", __func__);
> +		return;
> +	}
> +
> +	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
> +		if (!present_section_nr(pnum))
> +			continue;
> +		freemap_map[pnum] = freemap;
> +		freemap += size;
> +		check_usemap_section_nr(nodeid, freemap_map[pnum]);
> +	}
> +}
> +
>  static void __init sparse_early_usemaps_alloc_node(void *data,
>  				 unsigned long pnum_begin,
>  				 unsigned long pnum_end,
> @@ -520,6 +556,8 @@ void __init sparse_init(void)
>  {
>  	unsigned long pnum;
>  	struct page *map;
> +	unsigned long *freemap;
> +	unsigned long **freemap_map;
>  	unsigned long *usemap;
>  	unsigned long **usemap_map;
>  	int size;
> @@ -546,6 +584,12 @@ void __init sparse_init(void)
>  	 * sparse_early_mem_map_alloc, so allocate usemap_map at first.
>  	 */
>  	size = sizeof(unsigned long *) * NR_MEM_SECTIONS;
> +	freemap_map = memblock_virt_alloc(size, 0);
> +	if (!freemap_map)
> +		panic("can not allocate freemap_map\n");
> +	alloc_usemap_and_memmap(sparse_early_freemaps_alloc_node,
> +							(void *)freemap_map);
> +
>  	usemap_map = memblock_virt_alloc(size, 0);
>  	if (!usemap_map)
>  		panic("can not allocate usemap_map\n");
> @@ -565,6 +609,10 @@ void __init sparse_init(void)
>  		if (!present_section_nr(pnum))
>  			continue;
>  
> +		freemap = freemap_map[pnum];
> +		if (!freemap)
> +			continue;
> +
>  		usemap = usemap_map[pnum];
>  		if (!usemap)
>  			continue;
> @@ -578,7 +626,7 @@ void __init sparse_init(void)
>  			continue;
>  
>  		sparse_init_one_section(__nr_to_section(pnum), pnum, map,
> -								usemap);
> +					freemap, usemap);
>  	}
>  
>  	vmemmap_populate_print_last();
> @@ -692,6 +740,7 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
>  	struct pglist_data *pgdat = zone->zone_pgdat;
>  	struct mem_section *ms;
>  	struct page *memmap;
> +	unsigned long *freemap;
>  	unsigned long *usemap;
>  	unsigned long flags;
>  	int ret;
> @@ -706,8 +755,14 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
>  	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id);
>  	if (!memmap)
>  		return -ENOMEM;
> +	freemap = __kmalloc_section_freemap();
> +	if (!freemap) {
> +		__kfree_section_memmap(memmap);
> +		return -ENOMEM;
> +	}
>  	usemap = __kmalloc_section_usemap();
>  	if (!usemap) {
> +		kfree(freemap);
>  		__kfree_section_memmap(memmap);
>  		return -ENOMEM;
>  	}
> @@ -724,12 +779,13 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
>  
>  	ms->section_mem_map |= SECTION_MARKED_PRESENT;
>  
> -	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
> +	ret = sparse_init_one_section(ms, section_nr, memmap, freemap, usemap);
>  
>  out:
>  	pgdat_resize_unlock(pgdat, &flags);
>  	if (ret <= 0) {
>  		kfree(usemap);
> +		kfree(freemap);
>  		__kfree_section_memmap(memmap);
>  	}
>  	return ret;
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 76f73670200a..e10a8213a562 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1032,6 +1032,7 @@ const char * const vmstat_text[] = {
>  #endif
>  #ifdef CONFIG_COMPACTION
>  	"compact_migrate_scanned",
> +	"compact_free_skipped",
>  	"compact_free_scanned",
>  	"compact_isolated",
>  	"compact_stall",
> -- 
> 2.13.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
