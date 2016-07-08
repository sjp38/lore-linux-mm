Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id F34896B0268
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 05:38:06 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a2so26988045lfe.0
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 02:38:06 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id ie10si3978862wjb.98.2016.07.08.02.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 02:38:05 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 387391C24D8
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 10:38:05 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 16/34] mm, page_alloc: consider dirtyable memory in terms of nodes
Date: Fri,  8 Jul 2016 10:34:52 +0100
Message-Id: <1467970510-21195-17-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Historically dirty pages were spread among zones but now that LRUs are
per-node it is more appropriate to consider dirty pages in a node.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mmzone.h    | 12 +++----
 include/linux/writeback.h |  2 +-
 mm/page-writeback.c       | 91 +++++++++++++++++++++++++++++++----------------
 mm/page_alloc.c           | 26 ++++++--------
 4 files changed, 79 insertions(+), 52 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 62f477d6cfe8..fae2fe3c6942 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -363,12 +363,6 @@ struct zone {
 	struct pglist_data	*zone_pgdat;
 	struct per_cpu_pageset __percpu *pageset;
 
-	/*
-	 * This is a per-zone reserve of pages that are not available
-	 * to userspace allocations.
-	 */
-	unsigned long		totalreserve_pages;
-
 #ifndef CONFIG_SPARSEMEM
 	/*
 	 * Flags for a pageblock_nr_pages block. See pageblock-flags.h.
@@ -687,6 +681,12 @@ typedef struct pglist_data {
 	/* Number of pages migrated during the rate limiting time interval */
 	unsigned long numabalancing_migrate_nr_pages;
 #endif
+	/*
+	 * This is a per-node reserve of pages that are not available
+	 * to userspace allocations.
+	 */
+	unsigned long		totalreserve_pages;
+
 	/* Write-intensive fields used by page reclaim */
 	ZONE_PADDING(_pad1_)
 	spinlock_t		lru_lock;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 717e6149e753..fc1e16c25a29 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -320,7 +320,7 @@ void laptop_mode_timer_fn(unsigned long data);
 static inline void laptop_sync_completion(void) { }
 #endif
 void throttle_vm_writeout(gfp_t gfp_mask);
-bool zone_dirty_ok(struct zone *zone);
+bool node_dirty_ok(struct pglist_data *pgdat);
 int wb_domain_init(struct wb_domain *dom, gfp_t gfp);
 #ifdef CONFIG_CGROUP_WRITEBACK
 void wb_domain_exit(struct wb_domain *dom);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0ada2b2954b0..f7c0fb993fb9 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -267,26 +267,35 @@ static void wb_min_max_ratio(struct bdi_writeback *wb,
  */
 
 /**
- * zone_dirtyable_memory - number of dirtyable pages in a zone
- * @zone: the zone
+ * node_dirtyable_memory - number of dirtyable pages in a node
+ * @pgdat: the node
  *
- * Returns the zone's number of pages potentially available for dirty
- * page cache.  This is the base value for the per-zone dirty limits.
+ * Returns the node's number of pages potentially available for dirty
+ * page cache.  This is the base value for the per-node dirty limits.
  */
-static unsigned long zone_dirtyable_memory(struct zone *zone)
+static unsigned long node_dirtyable_memory(struct pglist_data *pgdat)
 {
-	unsigned long nr_pages;
+	unsigned long nr_pages = 0;
+	int z;
+
+	for (z = 0; z < MAX_NR_ZONES; z++) {
+		struct zone *zone = pgdat->node_zones + z;
+
+		if (!populated_zone(zone))
+			continue;
+
+		nr_pages += zone_page_state(zone, NR_FREE_PAGES);
+	}
 
-	nr_pages = zone_page_state(zone, NR_FREE_PAGES);
 	/*
 	 * Pages reserved for the kernel should not be considered
 	 * dirtyable, to prevent a situation where reclaim has to
 	 * clean pages in order to balance the zones.
 	 */
-	nr_pages -= min(nr_pages, zone->totalreserve_pages);
+	nr_pages -= min(nr_pages, pgdat->totalreserve_pages);
 
-	nr_pages += node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE);
-	nr_pages += node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE);
+	nr_pages += node_page_state(pgdat, NR_INACTIVE_FILE);
+	nr_pages += node_page_state(pgdat, NR_ACTIVE_FILE);
 
 	return nr_pages;
 }
@@ -299,13 +308,24 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 	int i;
 
 	for_each_node_state(node, N_HIGH_MEMORY) {
-		for (i = 0; i < MAX_NR_ZONES; i++) {
-			struct zone *z = &NODE_DATA(node)->node_zones[i];
+		for (i = ZONE_NORMAL + 1; i < MAX_NR_ZONES; i++) {
+			struct zone *z;
+			unsigned long dirtyable;
+
+			if (!is_highmem_idx(i))
+				continue;
+
+			z = &NODE_DATA(node)->node_zones[i];
+			dirtyable = zone_page_state(z, NR_FREE_PAGES) +
+				zone_page_state(z, NR_ZONE_LRU_FILE);
 
-			if (is_highmem(z))
-				x += zone_dirtyable_memory(z);
+			/* watch for underflows */
+			dirtyable -= min(dirtyable, high_wmark_pages(z));
+
+			x += dirtyable;
 		}
 	}
+
 	/*
 	 * Unreclaimable memory (kernel memory or anonymous memory
 	 * without swap) can bring down the dirtyable pages below
@@ -445,23 +465,23 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
 }
 
 /**
- * zone_dirty_limit - maximum number of dirty pages allowed in a zone
- * @zone: the zone
+ * node_dirty_limit - maximum number of dirty pages allowed in a node
+ * @pgdat: the node
  *
- * Returns the maximum number of dirty pages allowed in a zone, based
- * on the zone's dirtyable memory.
+ * Returns the maximum number of dirty pages allowed in a node, based
+ * on the node's dirtyable memory.
  */
-static unsigned long zone_dirty_limit(struct zone *zone)
+static unsigned long node_dirty_limit(struct pglist_data *pgdat)
 {
-	unsigned long zone_memory = zone_dirtyable_memory(zone);
+	unsigned long node_memory = node_dirtyable_memory(pgdat);
 	struct task_struct *tsk = current;
 	unsigned long dirty;
 
 	if (vm_dirty_bytes)
 		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE) *
-			zone_memory / global_dirtyable_memory();
+			node_memory / global_dirtyable_memory();
 	else
-		dirty = vm_dirty_ratio * zone_memory / 100;
+		dirty = vm_dirty_ratio * node_memory / 100;
 
 	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk))
 		dirty += dirty / 4;
@@ -470,19 +490,30 @@ static unsigned long zone_dirty_limit(struct zone *zone)
 }
 
 /**
- * zone_dirty_ok - tells whether a zone is within its dirty limits
- * @zone: the zone to check
+ * node_dirty_ok - tells whether a node is within its dirty limits
+ * @pgdat: the node to check
  *
- * Returns %true when the dirty pages in @zone are within the zone's
+ * Returns %true when the dirty pages in @pgdat are within the node's
  * dirty limit, %false if the limit is exceeded.
  */
-bool zone_dirty_ok(struct zone *zone)
+bool node_dirty_ok(struct pglist_data *pgdat)
 {
-	unsigned long limit = zone_dirty_limit(zone);
+	int z;
+	unsigned long limit = node_dirty_limit(pgdat);
+	unsigned long nr_pages = 0;
+
+	for (z = 0; z < MAX_NR_ZONES; z++) {
+		struct zone *zone = pgdat->node_zones + z;
+
+		if (!populated_zone(zone))
+			continue;
+
+		nr_pages += zone_page_state(zone, NR_FILE_DIRTY);
+		nr_pages += zone_page_state(zone, NR_UNSTABLE_NFS);
+		nr_pages += zone_page_state(zone, NR_WRITEBACK);
+	}
 
-	return zone_page_state(zone, NR_FILE_DIRTY) +
-	       zone_page_state(zone, NR_UNSTABLE_NFS) +
-	       zone_page_state(zone, NR_WRITEBACK) <= limit;
+	return nr_pages <= limit;
 }
 
 int dirty_background_ratio_handler(struct ctl_table *table, int write,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8215c51d5b23..9e113a6ff9a0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2955,31 +2955,24 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		}
 		/*
 		 * When allocating a page cache page for writing, we
-		 * want to get it from a zone that is within its dirty
-		 * limit, such that no single zone holds more than its
+		 * want to get it from a node that is within its dirty
+		 * limit, such that no single node holds more than its
 		 * proportional share of globally allowed dirty pages.
-		 * The dirty limits take into account the zone's
+		 * The dirty limits take into account the node's
 		 * lowmem reserves and high watermark so that kswapd
 		 * should be able to balance it without having to
 		 * write pages from its LRU list.
 		 *
-		 * This may look like it could increase pressure on
-		 * lower zones by failing allocations in higher zones
-		 * before they are full.  But the pages that do spill
-		 * over are limited as the lower zones are protected
-		 * by this very same mechanism.  It should not become
-		 * a practical burden to them.
-		 *
 		 * XXX: For now, allow allocations to potentially
-		 * exceed the per-zone dirty limit in the slowpath
+		 * exceed the per-node dirty limit in the slowpath
 		 * (spread_dirty_pages unset) before going into reclaim,
 		 * which is important when on a NUMA setup the allowed
-		 * zones are together not big enough to reach the
+		 * nodes are together not big enough to reach the
 		 * global limit.  The proper fix for these situations
-		 * will require awareness of zones in the
+		 * will require awareness of nodes in the
 		 * dirty-throttling and the flusher threads.
 		 */
-		if (ac->spread_dirty_pages && !zone_dirty_ok(zone))
+		if (ac->spread_dirty_pages && !node_dirty_ok(zone->zone_pgdat))
 			continue;
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
@@ -6749,6 +6742,9 @@ static void calculate_totalreserve_pages(void)
 	enum zone_type i, j;
 
 	for_each_online_pgdat(pgdat) {
+
+		pgdat->totalreserve_pages = 0;
+
 		for (i = 0; i < MAX_NR_ZONES; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 			long max = 0;
@@ -6765,7 +6761,7 @@ static void calculate_totalreserve_pages(void)
 			if (max > zone->managed_pages)
 				max = zone->managed_pages;
 
-			zone->totalreserve_pages = max;
+			pgdat->totalreserve_pages += max;
 
 			reserve_pages += max;
 		}
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
