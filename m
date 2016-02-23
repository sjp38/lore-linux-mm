Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id BB8D16B0267
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:17:58 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id a4so213867776wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:17:58 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id g5si40198442wmf.51.2016.02.23.07.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 07:17:57 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 562CF1C1881
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:17:57 +0000 (GMT)
Date: Tue, 23 Feb 2016 15:17:55 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 16/27] mm, page_alloc: Consider dirtyable memory in terms of
 nodes
Message-ID: <20160223151755.GB2854@techsingularity.net>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

Historically dirty pages were spread among zones but now that LRUs are
per-node it is more appropriate to consider dirty pages in a node.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h    | 12 +++----
 include/linux/writeback.h |  2 +-
 mm/page-writeback.c       | 89 ++++++++++++++++++++++++++---------------------
 mm/page_alloc.c           |  4 +--
 4 files changed, 58 insertions(+), 49 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index cef476813581..a5968e8b88e9 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -362,12 +362,6 @@ struct zone {
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
@@ -686,6 +680,12 @@ typedef struct pglist_data {
 	/* Number of pages migrated during the rate limiting time interval */
 	unsigned long numabalancing_migrate_nr_pages;
 #endif
+	/*
+	 * This is a per-zone reserve of pages that are not available
+	 * to userspace allocations.
+	 */
+	unsigned long		totalreserve_pages;
+
 	/* Write-intensive fields used from the page allocator */
 	ZONE_PADDING(_pad1_)
 	spinlock_t		lru_lock;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index b333c945e571..f6a35510b629 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -315,7 +315,7 @@ void laptop_mode_timer_fn(unsigned long data);
 static inline void laptop_sync_completion(void) { }
 #endif
 void throttle_vm_writeout(gfp_t gfp_mask);
-bool zone_dirty_ok(struct zone *zone);
+bool node_dirty_ok(struct pglist_data *pgdat);
 int wb_domain_init(struct wb_domain *dom, gfp_t gfp);
 #ifdef CONFIG_CGROUP_WRITEBACK
 void wb_domain_exit(struct wb_domain *dom);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index b0960ec94bc9..4abce6295f7c 100644
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
@@ -297,22 +306,11 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 	int node;
 	unsigned long x = 0;
 
-	for_each_node_state(node, N_HIGH_MEMORY) {
-		struct zone *z = &NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
-
-		x += zone_dirtyable_memory(z);
-	}
 	/*
-	 * Unreclaimable memory (kernel memory or anonymous memory
-	 * without swap) can bring down the dirtyable pages below
-	 * the zone's dirty balance reserve and the above calculation
-	 * will underflow.  However we still want to add in nodes
-	 * which are below threshold (negative values) to get a more
-	 * accurate calculation but make sure that the total never
-	 * underflows.
+	 * LRU lists are per-node so there is accurate way of accurately
+	 * calculating dirtyable memory of just the high zone
 	 */
-	if ((long)x < 0)
-		x = 0;
+	x = totalhigh_pages;
 
 	/*
 	 * Make sure that the number of highmem pages is never larger
@@ -438,23 +436,23 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
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
@@ -463,19 +461,30 @@ static unsigned long zone_dirty_limit(struct zone *zone)
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
index d320524d68c6..4b99c28f7f9e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2665,7 +2665,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		 * will require awareness of zones in the
 		 * dirty-throttling and the flusher threads.
 		 */
-		if (ac->spread_dirty_pages && !zone_dirty_ok(zone))
+		if (ac->spread_dirty_pages && !node_dirty_ok(zone->zone_pgdat))
 			continue;
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
@@ -6333,7 +6333,7 @@ static void calculate_totalreserve_pages(void)
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
