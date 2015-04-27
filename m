Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id EF3E96B006E
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 03:21:47 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so119323769pdb.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 00:21:47 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id x3si28705318pas.29.2015.04.27.00.21.43
        for <linux-mm@kvack.org>;
        Mon, 27 Apr 2015 00:21:45 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 3/3] mm: support active anti-fragmentation algorithm
Date: Mon, 27 Apr 2015 16:23:41 +0900
Message-Id: <1430119421-13536-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We already have antifragmentation policy in page allocator. It works well
when system memory is sufficient, but, it doesn't works well when system
memory isn't sufficient because memory is already highly fragmented and
fallback/steal mechanism cannot get whole pageblock. If there is severe
unmovable allocation requestor like zram, problem could get worse.

CPU: 8
RAM: 512 MB with zram swap
WORKLOAD: kernel build with -j12
OPTION: page owner is enabled to measure fragmentation
After finishing the build, check fragmentation by 'cat /proc/pagetypeinfo'

* Before
Number of blocks type (movable)
DMA32: 207

Number of mixed blocks (movable)
DMA32: 111.2

Mixed blocks means that there is one or more allocated page for
unmovable/reclaimable allocation in movable pageblock. Results shows that
more than half of movable pageblock is tainted by other migratetype
allocation.

To mitigate this fragmentation, this patch implements active
anti-fragmentation algorithm. Idea is really simple. When some
unmovable/reclaimable steal happens from movable pageblock, we try to
migrate out other pages that can be migratable in this pageblock are and
use these generated freepage for further allocation request of
corresponding migratetype.

Once unmovable allocation taints movable pageblock, it cannot easily
recover. Instead of praying that it gets restored, making it unmovable
pageblock as much as possible and using it further unmovable request
would be more reasonable approach.

Below is result of this idea.

* After
Number of blocks type (movable)
DMA32: 208.2

Number of mixed blocks (movable)
DMA32: 55.8

Result shows that non-mixed block increase by 59% in this case.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/compaction.h |   8 +++
 include/linux/gfp.h        |   3 +
 mm/compaction.c            | 156 +++++++++++++++++++++++++++++++++++++++++++++
 mm/internal.h              |   1 +
 mm/page_alloc.c            |  32 +++++++++-
 mm/page_isolation.c        |  24 -------
 6 files changed, 198 insertions(+), 26 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index aa8f61c..3a6bb81 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -51,6 +51,9 @@ extern void compaction_defer_reset(struct zone *zone, int order,
 				bool alloc_success);
 extern bool compaction_restarting(struct zone *zone, int order);
 
+extern void wake_up_antifrag(struct zone *zone, unsigned long base_pfn,
+				int mt, int nr_moved);
+
 #else
 static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
 			unsigned int order, int alloc_flags,
@@ -83,6 +86,11 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	return true;
 }
 
+static inline void wake_up_antifrag(struct zone *zone, unsigned long base_pfn,
+					int mt, int nr_moved)
+{
+}
+
 #endif /* CONFIG_COMPACTION */
 
 #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 97a9373..a0dec6c 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -355,6 +355,9 @@ void free_pages_exact(void *virt, size_t size);
 /* This is different from alloc_pages_exact_node !!! */
 void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 
+extern struct page *alloc_migrate_target(struct page *page,
+				unsigned long private, int **resultp);
+
 #define __get_free_page(gfp_mask) \
 		__get_free_pages((gfp_mask), 0)
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 018f08d..0d76b9e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -7,6 +7,10 @@
  *
  * Copyright IBM Corp. 2007-2010 Mel Gorman <mel@csn.ul.ie>
  */
+
+#define pr_fmt(fmt) "compact: " fmt
+#define DEBUG
+
 #include <linux/swap.h>
 #include <linux/migrate.h>
 #include <linux/compaction.h>
@@ -663,6 +667,9 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		if (cc->mode == MIGRATE_ASYNC)
 			return 0;
 
+		if (cc->ignore_congestion_wait)
+			break;
+
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		if (fatal_signal_pending(current))
@@ -1714,4 +1721,153 @@ void compaction_unregister_node(struct node *node)
 }
 #endif /* CONFIG_SYSFS && CONFIG_NUMA */
 
+#define NUM_ANTIFRAG_INFOS (100)
+
+struct antifrag_info {
+	struct work_struct antifrag_work;
+	struct list_head list;
+	unsigned long base_pfn;
+	int mt;
+	int nr_moved;
+};
+
+static DEFINE_SPINLOCK(infos_lock);
+static LIST_HEAD(free_infos);
+static struct antifrag_info infos[NUM_ANTIFRAG_INFOS];
+
+static unsigned long pending;
+static bool antifrag_initialized;
+
+void wake_up_antifrag(struct zone *zone, unsigned long base_pfn,
+			int mt, int nr_moved)
+{
+	struct antifrag_info *info;
+	unsigned long flags;
+
+	if (unlikely(!antifrag_initialized))
+		return;
+
+	spin_lock_irqsave(&infos_lock, flags);
+	if (list_empty(&free_infos)) {
+		spin_unlock_irqrestore(&infos_lock, flags);
+		return;
+	}
+
+	info = list_first_entry(&free_infos, struct antifrag_info, list);
+	list_del(&info->list);
+	pending++;
+	spin_unlock_irqrestore(&infos_lock, flags);
+
+	info->base_pfn = base_pfn;
+	info->mt = mt;
+	info->nr_moved = nr_moved;
+
+	pr_debug("%s: %d: wakeup (0x%lx, %d, %d, %lu)\n",
+		__func__, smp_processor_id(), base_pfn, mt, nr_moved, pending);
+	queue_work(system_highpri_wq, &info->antifrag_work);
+}
+
+static void empty_pageblock(unsigned long base_pfn, int mt, int nr_moved)
+{
+	int cpu;
+	int ret = 0;
+	int curr_moved = 0;
+	int count = 0;
+	unsigned long start, end, pfn;
+	unsigned long empty_threshold = 1 << (pageblock_order - 1);
+	struct page *base_page = pfn_to_page(base_pfn);
+	struct compact_control cc = {
+		.nr_migratepages = 0,
+		.order = -1,
+		.zone = page_zone(pfn_to_page(base_pfn)),
+		.mode = MIGRATE_SYNC_LIGHT,
+		.ignore_skip_hint = true,
+		.ignore_congestion_wait = true,
+	};
+	LIST_HEAD(isolated_pages);
+
+	INIT_LIST_HEAD(&cc.migratepages);
+
+	start = round_down(base_pfn, pageblock_nr_pages);
+	end = start + pageblock_nr_pages;
+	pfn = start;
+	while (pfn < end) {
+		if (fatal_signal_pending(current))
+			break;
+
+		cc.nr_migratepages = 0;
+		pfn = isolate_migratepages_range(&cc, pfn, end);
+		if (!pfn)
+			break;
+
+		count += cc.nr_migratepages;
+		list_splice_tail_init(&cc.migratepages, &isolated_pages);
+	}
+
+	if (count && nr_moved + count >= empty_threshold) {
+		spin_lock_irq(&cc.zone->lock);
+		set_pageblock_migratetype(base_page, mt);
+		curr_moved = move_freepages_block(cc.zone, base_page, mt);
+		spin_unlock_irq(&cc.zone->lock);
+
+		ret = migrate_pages(&isolated_pages, alloc_migrate_target,
+				NULL, __GFP_MEMALLOC, cc.mode, MR_COMPACTION);
+		if (ret > 0)
+			count -= ret;
+
+		cpu = get_cpu();
+		lru_add_drain_cpu(cpu);
+		drain_local_pages(cc.zone);
+		put_cpu();
+
+		spin_lock_irq(&cc.zone->lock);
+		curr_moved = move_freepages_block(cc.zone, base_page, mt);
+		spin_unlock_irq(&cc.zone->lock);
+
+		pr_debug("%s: %d: emptying success (0x%lx, %d, %d, %d %lu)\n",
+			__func__, smp_processor_id(),
+			base_pfn, mt, nr_moved, curr_moved, pending);
+	} else
+		pr_debug("%s: %d: emptying skipped (0x%lx, %d, %d, %d %lu)\n",
+			__func__, smp_processor_id(),
+			base_pfn, mt, nr_moved, nr_moved + count, pending);
+
+	putback_movable_pages(&isolated_pages);
+}
+
+static void do_antifrag(struct work_struct *work)
+{
+	struct antifrag_info *info =
+		container_of(work, struct antifrag_info, antifrag_work);
+
+	pr_debug("%s: %d: worker (0x%lx, %d, %d, %lu)\n",
+			__func__, smp_processor_id(),
+			info->base_pfn, info->mt, info->nr_moved, pending);
+
+	empty_pageblock(info->base_pfn, info->mt, info->nr_moved);
+
+	spin_lock_irq(&infos_lock);
+	list_add(&info->list, &free_infos);
+	pending--;
+	spin_unlock_irq(&infos_lock);
+}
+
+static int __init antifrag_init(void)
+{
+	int i;
+
+	spin_lock_irq(&infos_lock);
+	for (i = 0; i < NUM_ANTIFRAG_INFOS; i++) {
+		INIT_LIST_HEAD(&infos[i].list);
+		INIT_WORK(&infos[i].antifrag_work, do_antifrag);
+		list_add(&infos[i].list, &free_infos);
+	}
+	spin_unlock_irq(&infos_lock);
+
+	antifrag_initialized = true;
+
+	return 0;
+}
+module_init(antifrag_init)
+
 #endif /* CONFIG_COMPACTION */
diff --git a/mm/internal.h b/mm/internal.h
index a25e359..78527d7 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -192,6 +192,7 @@ struct compact_control {
 					 * contention detected during
 					 * compaction
 					 */
+	bool ignore_congestion_wait;
 };
 
 unsigned long
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fbe2211..0878ac5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1182,7 +1182,7 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
  * use it's pages as requested migratetype in the future.
  */
 static void steal_suitable_fallback(struct zone *zone, struct page *page,
-							  int start_type)
+					int start_type, int fallback_type)
 {
 	int current_order = page_order(page);
 	int pages;
@@ -1194,6 +1194,8 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	}
 
 	pages = move_freepages_block(zone, page, start_type);
+	if (start_type != MIGRATE_MOVABLE && fallback_type == MIGRATE_MOVABLE)
+		wake_up_antifrag(zone, page_to_pfn(page), start_type, pages);
 
 	/* Claim the whole block if over half of it is free */
 	if (pages >= (1 << (pageblock_order-1)) ||
@@ -1264,7 +1266,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 		BUG_ON(!page);
 
 		if (can_steal_pageblock)
-			steal_suitable_fallback(zone, page, start_migratetype);
+			steal_suitable_fallback(zone, page,
+				start_migratetype, fallback_mt);
 
 		list_move(&page->lru, &area->free_list[start_migratetype]);
 
@@ -6534,6 +6537,31 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 }
 #endif
 
+struct page *alloc_migrate_target(struct page *page, unsigned long private,
+				  int **resultp)
+{
+	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE | private;
+
+	/*
+	 * TODO: allocate a destination hugepage from a nearest neighbor node,
+	 * accordance with memory policy of the user process if possible. For
+	 * now as a simple work-around, we use the next node for destination.
+	 */
+	if (PageHuge(page)) {
+		nodemask_t src = nodemask_of_node(page_to_nid(page));
+		nodemask_t dst;
+
+		nodes_complement(dst, src);
+		return alloc_huge_page_node(page_hstate(compound_head(page)),
+					    next_node(page_to_nid(page), dst));
+	}
+
+	if (PageHighMem(page))
+		gfp_mask |= __GFP_HIGHMEM;
+
+	return alloc_page(gfp_mask);
+}
+
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
  * The zone indicated has a new number of managed_pages; batch sizes and percpu
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 0c4505b..5f5dfa5 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -290,27 +290,3 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 	spin_unlock_irqrestore(&zone->lock, flags);
 	return ret ? 0 : -EBUSY;
 }
-
-struct page *alloc_migrate_target(struct page *page, unsigned long private,
-				  int **resultp)
-{
-	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
-
-	/*
-	 * TODO: allocate a destination hugepage from a nearest neighbor node,
-	 * accordance with memory policy of the user process if possible. For
-	 * now as a simple work-around, we use the next node for destination.
-	 */
-	if (PageHuge(page)) {
-		nodemask_t src = nodemask_of_node(page_to_nid(page));
-		nodemask_t dst;
-		nodes_complement(dst, src);
-		return alloc_huge_page_node(page_hstate(compound_head(page)),
-					    next_node(page_to_nid(page), dst));
-	}
-
-	if (PageHighMem(page))
-		gfp_mask |= __GFP_HIGHMEM;
-
-	return alloc_page(gfp_mask);
-}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
