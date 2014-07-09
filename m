Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8F335900002
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 04:13:13 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id x12so2126262wgg.19
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 01:13:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cg8si6839732wib.8.2014.07.09.01.13.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 01:13:12 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/6] mm: Rearrange zone fields into read-only, page alloc, statistics and page reclaim lines
Date: Wed,  9 Jul 2014 09:13:04 +0100
Message-Id: <1404893588-21371-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1404893588-21371-1-git-send-email-mgorman@suse.de>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

The arrangement of struct zone has changed over time and now it has reached the
point where there is some inappropriate sharing going on. On x86-64 for example

o The zone->node field is shared with the zone lock and zone->node is accessed
  frequently from the page allocator due to the fair zone allocation policy.
o span_seqlock is almost never used by shares a line with free_area
o Some zone statistics share a cache line with the LRU lock so reclaim-intensive
  and allocator-intensive workloads can bounce the cache line on a stat update

This patch rearranges struct zone to put read-only and read-mostly fields
together and then splits the page allocator intensive fields, the zone
statistics and the page reclaim intensive fields into their own cache
lines. Note that the type of lowmem_reserve changes due to the watermark
calculations being signed and avoiding a signed/unsigned conversion there.

On the test configuration I used the overall size of struct zone shrunk
by one cache line. On smaller machines, this is not likely to be noticable.
However, on a 4-node NUMA machine running tiobench the system CPU overhead
is reduced by this patch.

          3.16.0-rc3  3.16.0-rc3
             vanillarearrange-v5r9
User          746.94      759.78
System      65336.22    58350.98
Elapsed     27553.52    27282.02

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h | 211 +++++++++++++++++++++++++------------------------
 mm/page_alloc.c        |   7 +-
 mm/vmstat.c            |   4 +-
 3 files changed, 113 insertions(+), 109 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6cbd1b6..fbadc45 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -324,19 +324,12 @@ enum zone_type {
 #ifndef __GENERATING_BOUNDS_H
 
 struct zone {
-	/* Fields commonly accessed by the page allocator */
+	/* Read-mostly fields */
 
 	/* zone watermarks, access with *_wmark_pages(zone) macros */
 	unsigned long watermark[NR_WMARK];
 
 	/*
-	 * When free pages are below this point, additional steps are taken
-	 * when reading the number of free pages to avoid per-cpu counter
-	 * drift allowing watermarks to be breached
-	 */
-	unsigned long percpu_drift_mark;
-
-	/*
 	 * We don't know if the memory that we're going to allocate will be freeable
 	 * or/and it will be released eventually, so to avoid totally wasting several
 	 * GB of ram we must reserve some of the lower zone memory (otherwise we risk
@@ -344,41 +337,26 @@ struct zone {
 	 * on the higher zones). This array is recalculated at runtime if the
 	 * sysctl_lowmem_reserve_ratio sysctl changes.
 	 */
-	unsigned long		lowmem_reserve[MAX_NR_ZONES];
-
-	/*
-	 * This is a per-zone reserve of pages that should not be
-	 * considered dirtyable memory.
-	 */
-	unsigned long		dirty_balance_reserve;
+	long lowmem_reserve[MAX_NR_ZONES];
 
 #ifdef CONFIG_NUMA
 	int node;
+#endif
+
 	/*
-	 * zone reclaim becomes active if more unmapped pages exist.
+	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
+	 * this zone's LRU.  Maintained by the pageout code.
 	 */
-	unsigned long		min_unmapped_pages;
-	unsigned long		min_slab_pages;
-#endif
+	unsigned int inactive_ratio;
+
+	struct pglist_data	*zone_pgdat;
 	struct per_cpu_pageset __percpu *pageset;
+
 	/*
-	 * free areas of different sizes
+	 * This is a per-zone reserve of pages that should not be
+	 * considered dirtyable memory.
 	 */
-	spinlock_t		lock;
-#if defined CONFIG_COMPACTION || defined CONFIG_CMA
-	/* Set to true when the PG_migrate_skip bits should be cleared */
-	bool			compact_blockskip_flush;
-
-	/* pfn where compaction free scanner should start */
-	unsigned long		compact_cached_free_pfn;
-	/* pfn where async and sync compaction migration scanner should start */
-	unsigned long		compact_cached_migrate_pfn[2];
-#endif
-#ifdef CONFIG_MEMORY_HOTPLUG
-	/* see spanned/present_pages for more description */
-	seqlock_t		span_seqlock;
-#endif
-	struct free_area	free_area[MAX_ORDER];
+	unsigned long		dirty_balance_reserve;
 
 #ifndef CONFIG_SPARSEMEM
 	/*
@@ -388,74 +366,14 @@ struct zone {
 	unsigned long		*pageblock_flags;
 #endif /* CONFIG_SPARSEMEM */
 
-#ifdef CONFIG_COMPACTION
-	/*
-	 * On compaction failure, 1<<compact_defer_shift compactions
-	 * are skipped before trying again. The number attempted since
-	 * last failure is tracked with compact_considered.
-	 */
-	unsigned int		compact_considered;
-	unsigned int		compact_defer_shift;
-	int			compact_order_failed;
-#endif
-
-	ZONE_PADDING(_pad1_)
-
-	/* Fields commonly accessed by the page reclaim scanner */
-	spinlock_t		lru_lock;
-	struct lruvec		lruvec;
-
-	/* Evictions & activations on the inactive file list */
-	atomic_long_t		inactive_age;
-
-	unsigned long		pages_scanned;	   /* since last reclaim */
-	unsigned long		flags;		   /* zone flags, see below */
-
-	/* Zone statistics */
-	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
-
-	/*
-	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
-	 * this zone's LRU.  Maintained by the pageout code.
-	 */
-	unsigned int inactive_ratio;
-
-
-	ZONE_PADDING(_pad2_)
-	/* Rarely used or read-mostly fields */
-
+#ifdef CONFIG_NUMA
 	/*
-	 * wait_table		-- the array holding the hash table
-	 * wait_table_hash_nr_entries	-- the size of the hash table array
-	 * wait_table_bits	-- wait_table_size == (1 << wait_table_bits)
-	 *
-	 * The purpose of all these is to keep track of the people
-	 * waiting for a page to become available and make them
-	 * runnable again when possible. The trouble is that this
-	 * consumes a lot of space, especially when so few things
-	 * wait on pages at a given time. So instead of using
-	 * per-page waitqueues, we use a waitqueue hash table.
-	 *
-	 * The bucket discipline is to sleep on the same queue when
-	 * colliding and wake all in that wait queue when removing.
-	 * When something wakes, it must check to be sure its page is
-	 * truly available, a la thundering herd. The cost of a
-	 * collision is great, but given the expected load of the
-	 * table, they should be so rare as to be outweighed by the
-	 * benefits from the saved space.
-	 *
-	 * __wait_on_page_locked() and unlock_page() in mm/filemap.c, are the
-	 * primary users of these fields, and in mm/page_alloc.c
-	 * free_area_init_core() performs the initialization of them.
+	 * zone reclaim becomes active if more unmapped pages exist.
 	 */
-	wait_queue_head_t	* wait_table;
-	unsigned long		wait_table_hash_nr_entries;
-	unsigned long		wait_table_bits;
+	unsigned long		min_unmapped_pages;
+	unsigned long		min_slab_pages;
+#endif /* CONFIG_NUMA */
 
-	/*
-	 * Discontig memory support fields.
-	 */
-	struct pglist_data	*zone_pgdat;
 	/* zone_start_pfn == zone_start_paddr >> PAGE_SHIFT */
 	unsigned long		zone_start_pfn;
 
@@ -500,9 +418,11 @@ struct zone {
 	 * adjust_managed_page_count() should be used instead of directly
 	 * touching zone->managed_pages and totalram_pages.
 	 */
+	unsigned long		managed_pages;
 	unsigned long		spanned_pages;
 	unsigned long		present_pages;
-	unsigned long		managed_pages;
+
+	const char		*name;
 
 	/*
 	 * Number of MIGRATE_RESEVE page block. To maintain for just
@@ -510,10 +430,95 @@ struct zone {
 	 */
 	int			nr_migrate_reserve_block;
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+	/* see spanned/present_pages for more description */
+	seqlock_t		span_seqlock;
+#endif
+
 	/*
-	 * rarely used fields:
+	 * wait_table		-- the array holding the hash table
+	 * wait_table_hash_nr_entries	-- the size of the hash table array
+	 * wait_table_bits	-- wait_table_size == (1 << wait_table_bits)
+	 *
+	 * The purpose of all these is to keep track of the people
+	 * waiting for a page to become available and make them
+	 * runnable again when possible. The trouble is that this
+	 * consumes a lot of space, especially when so few things
+	 * wait on pages at a given time. So instead of using
+	 * per-page waitqueues, we use a waitqueue hash table.
+	 *
+	 * The bucket discipline is to sleep on the same queue when
+	 * colliding and wake all in that wait queue when removing.
+	 * When something wakes, it must check to be sure its page is
+	 * truly available, a la thundering herd. The cost of a
+	 * collision is great, but given the expected load of the
+	 * table, they should be so rare as to be outweighed by the
+	 * benefits from the saved space.
+	 *
+	 * __wait_on_page_locked() and unlock_page() in mm/filemap.c, are the
+	 * primary users of these fields, and in mm/page_alloc.c
+	 * free_area_init_core() performs the initialization of them.
 	 */
-	const char		*name;
+	wait_queue_head_t	*wait_table;
+	unsigned long		wait_table_hash_nr_entries;
+	unsigned long		wait_table_bits;
+
+	ZONE_PADDING(_pad1_)
+
+	/* Write-intensive fields used from the page allocator */
+	spinlock_t		lock;
+
+	/* free areas of different sizes */
+	struct free_area	free_area[MAX_ORDER];
+
+	/* zone flags, see below */
+	unsigned long		flags;
+
+	ZONE_PADDING(_pad2_)
+
+	/* Write-intensive fields used by page reclaim */
+
+	/* Fields commonly accessed by the page reclaim scanner */
+	spinlock_t		lru_lock;
+	unsigned long		pages_scanned;	   /* since last reclaim */
+	struct lruvec		lruvec;
+
+	/* Evictions & activations on the inactive file list */
+	atomic_long_t		inactive_age;
+
+	/*
+	 * When free pages are below this point, additional steps are taken
+	 * when reading the number of free pages to avoid per-cpu counter
+	 * drift allowing watermarks to be breached
+	 */
+	unsigned long percpu_drift_mark;
+
+#if defined CONFIG_COMPACTION || defined CONFIG_CMA
+	/* pfn where compaction free scanner should start */
+	unsigned long		compact_cached_free_pfn;
+	/* pfn where async and sync compaction migration scanner should start */
+	unsigned long		compact_cached_migrate_pfn[2];
+#endif
+
+#ifdef CONFIG_COMPACTION
+	/*
+	 * On compaction failure, 1<<compact_defer_shift compactions
+	 * are skipped before trying again. The number attempted since
+	 * last failure is tracked with compact_considered.
+	 */
+	unsigned int		compact_considered;
+	unsigned int		compact_defer_shift;
+	int			compact_order_failed;
+#endif
+
+#if defined CONFIG_COMPACTION || defined CONFIG_CMA
+	/* Set to true when the PG_migrate_skip bits should be cleared */
+	bool			compact_blockskip_flush;
+#endif
+
+	ZONE_PADDING(_pad3_)
+	/* Zone statistics */
+	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
 } ____cacheline_internodealigned_in_smp;
 
 typedef enum {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 20d17f8..c607acd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1700,7 +1700,6 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 {
 	/* free_pages my go negative - that's OK */
 	long min = mark;
-	long lowmem_reserve = z->lowmem_reserve[classzone_idx];
 	int o;
 	long free_cma = 0;
 
@@ -1715,7 +1714,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 		free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
 #endif
 
-	if (free_pages - free_cma <= min + lowmem_reserve)
+	if (free_pages - free_cma <= min + z->lowmem_reserve[classzone_idx])
 		return false;
 	for (o = 0; o < order; o++) {
 		/* At the next order, this order's pages become unavailable */
@@ -3246,7 +3245,7 @@ void show_free_areas(unsigned int filter)
 			);
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
-			printk(" %lu", zone->lowmem_reserve[i]);
+			printk(" %ld", zone->lowmem_reserve[i]);
 		printk("\n");
 	}
 
@@ -5567,7 +5566,7 @@ static void calculate_totalreserve_pages(void)
 	for_each_online_pgdat(pgdat) {
 		for (i = 0; i < MAX_NR_ZONES; i++) {
 			struct zone *zone = pgdat->node_zones + i;
-			unsigned long max = 0;
+			long max = 0;
 
 			/* Find valid and maximum lowmem_reserve in the zone */
 			for (j = i; j < MAX_NR_ZONES; j++) {
diff --git a/mm/vmstat.c b/mm/vmstat.c
index b37bd49..8267f77 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1077,10 +1077,10 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 				zone_page_state(zone, i));
 
 	seq_printf(m,
-		   "\n        protection: (%lu",
+		   "\n        protection: (%ld",
 		   zone->lowmem_reserve[0]);
 	for (i = 1; i < ARRAY_SIZE(zone->lowmem_reserve); i++)
-		seq_printf(m, ", %lu", zone->lowmem_reserve[i]);
+		seq_printf(m, ", %ld", zone->lowmem_reserve[i]);
 	seq_printf(m,
 		   ")"
 		   "\n  pagesets");
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
