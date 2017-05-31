Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9428D6B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 02:42:35 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b86so1006319wmi.6
        for <linux-mm@kvack.org>; Tue, 30 May 2017 23:42:35 -0700 (PDT)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id s89si6770988wrc.28.2017.05.30.23.42.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 23:42:34 -0700 (PDT)
Received: by mail-wr0-f194.google.com with SMTP id 6so596444wrb.1
        for <linux-mm@kvack.org>; Tue, 30 May 2017 23:42:34 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: consider memblock reservations for deferred memory initialization sizing
Date: Wed, 31 May 2017 08:42:27 +0200
Message-Id: <20170531064227.5753-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

We have seen an early OOM killer invocation on ppc64 systems with
crashkernel=4096M
	kthreadd invoked oom-killer: gfp_mask=0x16040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK), nodemask=7, order=0, oom_score_adj=0
	kthreadd cpuset=/ mems_allowed=7
	CPU: 0 PID: 2 Comm: kthreadd Not tainted 4.4.68-1.gd7fe927-default #1
	Call Trace:
	[c0000000072fb7c0] [c00000000080830c] dump_stack+0xb0/0xf0 (unreliable)
	[c0000000072fb800] [c0000000008032d4] dump_header+0xb0/0x258
	[c0000000072fb8e0] [c00000000023dfc0] out_of_memory+0x5f0/0x640
	[c0000000072fb990] [c00000000024459c] __alloc_pages_nodemask+0xa8c/0xc80
	[c0000000072fbb10] [c0000000002b2504] kmem_getpages+0x84/0x1a0
	[c0000000072fbb50] [c0000000002b5174] fallback_alloc+0x2a4/0x320
	[c0000000072fbbc0] [c0000000002b4240] kmem_cache_alloc_node+0xc0/0x2e0
	[c0000000072fbc30] [c0000000000b9a80] copy_process.isra.25+0x260/0x1b30
	[c0000000072fbd10] [c0000000000bb514] _do_fork+0x94/0x470
	[c0000000072fbd80] [c0000000000bb978] kernel_thread+0x48/0x60
	[c0000000072fbda0] [c0000000000e9df4] kthreadd+0x264/0x330
	[c0000000072fbe30] [c000000000009538] ret_from_kernel_thread+0x5c/0xa4
	Mem-Info:
	active_anon:0 inactive_anon:0 isolated_anon:0
	 active_file:0 inactive_file:0 isolated_file:0
	 unevictable:0 dirty:0 writeback:0 unstable:0
	 slab_reclaimable:5 slab_unreclaimable:73
	 mapped:0 shmem:0 pagetables:0 bounce:0
	 free:0 free_pcp:0 free_cma:0
	Node 7 DMA free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:52428800kB managed:110016kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:320kB slab_unreclaimable:4672kB kernel_stack:1152kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
	lowmem_reserve[]: 0 0 0 0
	Node 7 DMA: 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*8192kB 0*16384kB = 0kB
	0 total pagecache pages
	0 pages in swap cache
	Swap cache stats: add 0, delete 0, find 0/0
	Free swap  = 0kB
	Total swap = 0kB
	819200 pages RAM
	0 pages HighMem/MovableOnly
	817481 pages reserved
	0 pages cma reserved
	0 pages hwpoisoned

the reason is that the managed memory is too low (only 110MB) while the
rest of the the 50GB is still waiting for the deferred intialization to
be done. update_defer_init estimates the initial memoty to initialize to
2GB at least but it doesn't consider any memory allocated in that range.
In this particular case we've had
	Reserving 4096MB of memory at 128MB for crashkernel (System RAM: 51200MB)
so the low 2GB is mostly depleted.

Fix this by considering memblock allocations in the initial static
initialization estimation. Move the max_initialise to reset_deferred_meminit
and implement a simple memblock_reserved_memory helper which iterates all
reserved blocks and sums the size of all that start below the given address.
The cumulative size is than added on top of the initial estimation. This
is still not ideal because reset_deferred_meminit doesn't consider holes
and so reservation might be above the initial estimation whihch we
ignore but let's make the logic simpler until we really need to handle
more complicated cases.

Fixes: 3a80a7fa7989 ("mm: meminit: initialise a subset of struct pages if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set")
Cc: stable # 4.2+
Tested-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/memblock.h |  8 ++++++++
 include/linux/mmzone.h   |  1 +
 mm/memblock.c            | 23 +++++++++++++++++++++++
 mm/page_alloc.c          | 33 ++++++++++++++++++++++-----------
 4 files changed, 54 insertions(+), 11 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index bdfc65af4152..14dbc4fd0a92 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -423,12 +423,20 @@ static inline void early_memtest(phys_addr_t start, phys_addr_t end)
 }
 #endif
 
+extern unsigned long memblock_reserved_memory_within(phys_addr_t start_addr,
+		phys_addr_t end_addr);
 #else
 static inline phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align)
 {
 	return 0;
 }
 
+static inline unsigned long memblock_reserved_memory_within(phys_addr_t start_addr,
+		phys_addr_t end_addr)
+{
+	return 0;
+}
+
 #endif /* CONFIG_HAVE_MEMBLOCK */
 
 #endif /* __KERNEL__ */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f887fccb6ef0..964b187bd1ef 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -698,6 +698,7 @@ typedef struct pglist_data {
 	 * is the first PFN that needs to be initialised.
 	 */
 	unsigned long first_deferred_pfn;
+	unsigned long static_init_size;
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
diff --git a/mm/memblock.c b/mm/memblock.c
index 696f06d17c4e..ee9a2543a572 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1713,6 +1713,29 @@ static void __init_memblock memblock_dump(struct memblock_type *type)
 	}
 }
 
+extern unsigned long memblock_reserved_memory_within(phys_addr_t start_addr,
+		phys_addr_t end_addr)
+{
+	struct memblock_region *rgn;
+	unsigned long size = 0;
+	int idx;
+
+	for_each_memblock_type((&memblock.reserved), rgn) {
+		phys_addr_t start, end;
+
+		if (rgn->base + rgn->size < start_addr)
+			continue;
+		if (rgn->base > end_addr)
+			continue;
+
+		start = rgn->base;
+		end = start + rgn->size;
+		size += end - start;
+	}
+
+	return size;
+}
+
 void __init_memblock __memblock_dump_all(void)
 {
 	pr_info("MEMBLOCK configuration:\n");
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7e23f4eb68be..9d5aa4268b4f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -291,6 +291,26 @@ int page_group_by_mobility_disabled __read_mostly;
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 static inline void reset_deferred_meminit(pg_data_t *pgdat)
 {
+	unsigned long max_initialise;
+	unsigned long reserved_lowmem;
+
+	/*
+	 * Initialise at least 2G of a node but also take into account that
+	 * two large system hashes that can take up 1GB for 0.25TB/node.
+	 */
+	max_initialise = max(2UL << (30 - PAGE_SHIFT),
+		(pgdat->node_spanned_pages >> 8));
+
+	/*
+	 * Compensate the all the memblock reservations (e.g. crash kernel)
+	 * from the initial estimation to make sure we will initialize enough
+	 * memory to boot.
+	 */
+	reserved_lowmem = memblock_reserved_memory_within(pgdat->node_start_pfn,
+			pgdat->node_start_pfn + max_initialise);
+	max_initialise += reserved_lowmem;
+
+	pgdat->static_init_size = min(max_initialise, pgdat->node_spanned_pages);
 	pgdat->first_deferred_pfn = ULONG_MAX;
 }
 
@@ -313,20 +333,11 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 				unsigned long pfn, unsigned long zone_end,
 				unsigned long *nr_initialised)
 {
-	unsigned long max_initialise;
-
 	/* Always populate low zones for address-contrained allocations */
 	if (zone_end < pgdat_end_pfn(pgdat))
 		return true;
-	/*
-	 * Initialise at least 2G of a node but also take into account that
-	 * two large system hashes that can take up 1GB for 0.25TB/node.
-	 */
-	max_initialise = max(2UL << (30 - PAGE_SHIFT),
-		(pgdat->node_spanned_pages >> 8));
-
 	(*nr_initialised)++;
-	if ((*nr_initialised > max_initialise) &&
+	if ((*nr_initialised > pgdat->static_init_size) &&
 	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
 		pgdat->first_deferred_pfn = pfn;
 		return false;
@@ -6166,7 +6177,6 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 	/* pg_data_t should be reset to zero when it's allocated */
 	WARN_ON(pgdat->nr_zones || pgdat->kswapd_classzone_idx);
 
-	reset_deferred_meminit(pgdat);
 	pgdat->node_id = nid;
 	pgdat->node_start_pfn = node_start_pfn;
 	pgdat->per_cpu_nodestats = NULL;
@@ -6188,6 +6198,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 		(unsigned long)pgdat->node_mem_map);
 #endif
 
+	reset_deferred_meminit(pgdat);
 	free_area_init_core(pgdat);
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
