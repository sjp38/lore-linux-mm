Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id C83B0900015
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:57:04 -0400 (EDT)
Received: by wiga1 with SMTP id a1so87448257wig.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:57:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ho2si5286581wjb.162.2015.06.08.06.56.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:56 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 12/25] mm, page_alloc: Consider dirtyable memory in terms of nodes
Date: Mon,  8 Jun 2015 14:56:18 +0100
Message-Id: <1433771791-30567-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Historically dirty pages were spread among zones but now that LRUs are
per-node it is more appropriate to consider dirty pages in a node.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h    | 12 +++----
 include/linux/writeback.h |  2 +-
 mm/page-writeback.c       | 89 ++++++++++++++++++++++++++---------------------
 mm/page_alloc.c           |  8 +++--
 4 files changed, 62 insertions(+), 49 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 4c761809d151..22cdd8da6fb0 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -355,12 +355,6 @@ struct zone {
 	struct pglist_data	*zone_pgdat;
 	struct per_cpu_pageset __percpu *pageset;
 
-	/*
-	 * This is a per-zone reserve of pages that should not be
-	 * considered dirtyable memory.
-	 */
-	unsigned long		dirty_balance_reserve;
-
 #ifndef CONFIG_SPARSEMEM
 	/*
 	 * Flags for a pageblock_nr_pages block. See pageblock-flags.h.
@@ -760,6 +754,12 @@ typedef struct pglist_data {
 	/* Number of pages migrated during the rate limiting time interval */
 	unsigned long numabalancing_migrate_nr_pages;
 #endif
+	/*
+	 * This is a per-node reserve of pages that should not be
+	 * considered dirtyable memory.
+	 */
+	unsigned long		dirty_balance_reserve;
+
 	/* Write-intensive fields used from the page allocator */
 	ZONE_PADDING(_pad1_)
 	spinlock_t		lru_lock;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index b2dd371ec0ca..76602a5d721e 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -119,7 +119,7 @@ void laptop_mode_timer_fn(unsigned long data);
 static inline void laptop_sync_completion(void) { }
 #endif
 void throttle_vm_writeout(gfp_t gfp_mask);
-bool zone_dirty_ok(struct zone *zone);
+bool node_dirty_ok(struct pglist_data *pgdat);
 
 extern unsigned long global_dirty_limit;
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 9707c450c7c5..88e346f36f79 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -174,21 +174,30 @@ static unsigned long writeout_period_time = 0;
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
 
-	nr_pages = zone_page_state(zone, NR_FREE_PAGES);
-	nr_pages -= min(nr_pages, zone->dirty_balance_reserve);
+	for (z = 0; z < MAX_NR_ZONES; z++) {
+		struct zone *zone = pgdat->node_zones + z;
 
-	nr_pages += node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE);
-	nr_pages += node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE);
+		if (!populated_zone(zone))
+			continue;
+
+		nr_pages += zone_page_state(zone, NR_FREE_PAGES);
+	}
+
+	nr_pages -= min(nr_pages, pgdat->dirty_balance_reserve);
+
+	nr_pages += node_page_state(pgdat, NR_INACTIVE_FILE);
+	nr_pages += node_page_state(pgdat, NR_ACTIVE_FILE);
 
 	return nr_pages;
 }
@@ -199,22 +208,11 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
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
@@ -289,23 +287,23 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
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
@@ -314,19 +312,30 @@ static unsigned long zone_dirty_limit(struct zone *zone)
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
index 34201c141916..fa54792f1719 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2042,6 +2042,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 				(gfp_mask & __GFP_WRITE);
 	int nr_fair_skipped = 0;
 	bool zonelist_rescan;
+	struct pglist_data *last_pgdat = NULL;
 
 zonelist_scan:
 	zonelist_rescan = false;
@@ -2101,8 +2102,11 @@ zonelist_scan:
 		 * will require awareness of zones in the
 		 * dirty-throttling and the flusher threads.
 		 */
-		if (consider_zone_dirty && !zone_dirty_ok(zone))
+		if (consider_zone_dirty && last_pgdat != zone->zone_pgdat &&
+					!node_dirty_ok(zone->zone_pgdat)) {
 			continue;
+		}
+		last_pgdat = zone->zone_pgdat;
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 		if (!zone_watermark_ok(zone, order, mark,
@@ -5656,7 +5660,7 @@ static void calculate_totalreserve_pages(void)
 			 * situation where reclaim has to clean pages
 			 * in order to balance the zones.
 			 */
-			zone->dirty_balance_reserve = max;
+			pgdat->dirty_balance_reserve += max;
 		}
 	}
 	dirty_balance_reserve = reserve_pages;
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
