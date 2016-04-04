Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id B22306B0291
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 13:14:06 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id bc4so169339294lbc.2
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 10:14:06 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id op7si9085617wjc.120.2016.04.04.10.14.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 10:14:03 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/3] mm: vmscan: reduce size of inactive file list
Date: Mon,  4 Apr 2016 13:13:38 -0400
Message-Id: <1459790018-6630-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1459790018-6630-1-git-send-email-hannes@cmpxchg.org>
References: <1459790018-6630-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Rik van Riel <riel@redhat.com>

The inactive file list should still be large enough to contain
readahead windows and freshly written file data, but it no
longer is the only source for detecting multiple accesses to
file pages. The workingset refault measurement code causes
recently evicted file pages that get accessed again after a
shorter interval to be promoted directly to the active list.

With that mechanism in place, we can afford to (on a larger
system) dedicate more memory to the active file list, so we
can actually cache more of the frequently used file pages
in memory, and not have them pushed out by streaming writes,
once-used streaming file reads, etc.

This can help things like database workloads, where only
half the page cache can currently be used to cache the
database working set. This patch automatically increases
that fraction on larger systems, using the same ratio that
has already been used for anonymous memory.

Reported-by: Andres Freund <andres@anarazel.de>
Signed-off-by: Rik van Riel <riel@redhat.com>
[hannes@cmpxchg.org: cgroup-awareness]
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |  25 -----------
 mm/page_alloc.c            |  44 -------------------
 mm/vmscan.c                | 104 ++++++++++++++++++---------------------------
 3 files changed, 42 insertions(+), 131 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1191d79..3694f88 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -415,25 +415,6 @@ unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 	return mz->lru_size[lru];
 }
 
-static inline bool mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
-{
-	unsigned long inactive_ratio;
-	unsigned long inactive;
-	unsigned long active;
-	unsigned long gb;
-
-	inactive = mem_cgroup_get_lru_size(lruvec, LRU_INACTIVE_ANON);
-	active = mem_cgroup_get_lru_size(lruvec, LRU_ACTIVE_ANON);
-
-	gb = (inactive + active) >> (30 - PAGE_SHIFT);
-	if (gb)
-		inactive_ratio = int_sqrt(10 * gb);
-	else
-		inactive_ratio = 1;
-
-	return inactive * inactive_ratio < active;
-}
-
 void mem_cgroup_handle_over_high(void);
 
 void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
@@ -646,12 +627,6 @@ static inline bool mem_cgroup_online(struct mem_cgroup *memcg)
 	return true;
 }
 
-static inline bool
-mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
-{
-	return true;
-}
-
 static inline unsigned long
 mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59de90d..67db15d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6395,49 +6395,6 @@ void setup_per_zone_wmarks(void)
 }
 
 /*
- * The inactive anon list should be small enough that the VM never has to
- * do too much work, but large enough that each inactive page has a chance
- * to be referenced again before it is swapped out.
- *
- * The inactive_anon ratio is the target ratio of ACTIVE_ANON to
- * INACTIVE_ANON pages on this zone's LRU, maintained by the
- * pageout code. A zone->inactive_ratio of 3 means 3:1 or 25% of
- * the anonymous pages are kept on the inactive list.
- *
- * total     target    max
- * memory    ratio     inactive anon
- * -------------------------------------
- *   10MB       1         5MB
- *  100MB       1        50MB
- *    1GB       3       250MB
- *   10GB      10       0.9GB
- *  100GB      31         3GB
- *    1TB     101        10GB
- *   10TB     320        32GB
- */
-static void __meminit calculate_zone_inactive_ratio(struct zone *zone)
-{
-	unsigned int gb, ratio;
-
-	/* Zone size in gigabytes */
-	gb = zone->managed_pages >> (30 - PAGE_SHIFT);
-	if (gb)
-		ratio = int_sqrt(10 * gb);
-	else
-		ratio = 1;
-
-	zone->inactive_ratio = ratio;
-}
-
-static void __meminit setup_per_zone_inactive_ratio(void)
-{
-	struct zone *zone;
-
-	for_each_zone(zone)
-		calculate_zone_inactive_ratio(zone);
-}
-
-/*
  * Initialise min_free_kbytes.
  *
  * For small machines we want it small (128k min).  For large machines
@@ -6482,7 +6439,6 @@ int __meminit init_per_zone_wmark_min(void)
 	setup_per_zone_wmarks();
 	refresh_zone_stat_thresholds();
 	setup_per_zone_lowmem_reserve();
-	setup_per_zone_inactive_ratio();
 	return 0;
 }
 module_init(init_per_zone_wmark_min)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b934223e..6f4f18c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1865,83 +1865,63 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	free_hot_cold_page_list(&l_hold, true);
 }
 
-#ifdef CONFIG_SWAP
-static bool inactive_anon_is_low_global(struct zone *zone)
-{
-	unsigned long active, inactive;
-
-	active = zone_page_state(zone, NR_ACTIVE_ANON);
-	inactive = zone_page_state(zone, NR_INACTIVE_ANON);
-
-	return inactive * zone->inactive_ratio < active;
-}
-
-/**
- * inactive_anon_is_low - check if anonymous pages need to be deactivated
- * @lruvec: LRU vector to check
+/*
+ * The inactive anon list should be small enough that the VM never has
+ * to do too much work.
  *
- * Returns true if the zone does not have enough inactive anon pages,
- * meaning some active anon pages need to be deactivated.
- */
-static bool inactive_anon_is_low(struct lruvec *lruvec)
-{
-	/*
-	 * If we don't have swap space, anonymous page deactivation
-	 * is pointless.
-	 */
-	if (!total_swap_pages)
-		return false;
-
-	if (!mem_cgroup_disabled())
-		return mem_cgroup_inactive_anon_is_low(lruvec);
-
-	return inactive_anon_is_low_global(lruvec_zone(lruvec));
-}
-#else
-static inline bool inactive_anon_is_low(struct lruvec *lruvec)
-{
-	return false;
-}
-#endif
-
-/**
- * inactive_file_is_low - check if file pages need to be deactivated
- * @lruvec: LRU vector to check
+ * The inactive file list should be small enough to leave most memory
+ * to the established workingset on the scan-resistant active list,
+ * but large enough to avoid thrashing the aggregate readahead window.
  *
- * When the system is doing streaming IO, memory pressure here
- * ensures that active file pages get deactivated, until more
- * than half of the file pages are on the inactive list.
+ * Both inactive lists should also be large enough that each inactive
+ * page has a chance to be referenced again before it is reclaimed.
  *
- * Once we get to that situation, protect the system's working
- * set from being evicted by disabling active file page aging.
+ * The inactive_ratio is the target ratio of ACTIVE to INACTIVE pages
+ * on this LRU, maintained by the pageout code. A zone->inactive_ratio
+ * of 3 means 3:1 or 25% of the pages are kept on the inactive list.
  *
- * This uses a different ratio than the anonymous pages, because
- * the page cache uses a use-once replacement algorithm.
+ * total     target    max
+ * memory    ratio     inactive
+ * -------------------------------------
+ *   10MB       1         5MB
+ *  100MB       1        50MB
+ *    1GB       3       250MB
+ *   10GB      10       0.9GB
+ *  100GB      31         3GB
+ *    1TB     101        10GB
+ *   10TB     320        32GB
  */
-static bool inactive_file_is_low(struct lruvec *lruvec)
+static bool inactive_list_is_low(struct lruvec *lruvec, bool file)
 {
+	unsigned long inactive_ratio;
 	unsigned long inactive;
 	unsigned long active;
+	unsigned long gb;
 
-	inactive = lruvec_lru_size(lruvec, LRU_INACTIVE_FILE);
-	active = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE);
+	/*
+	 * If we don't have swap space, anonymous page deactivation
+	 * is pointless.
+	 */
+	if (!file && !total_swap_pages)
+		return false;
 
-	return active > inactive;
-}
+	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
+	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
 
-static bool inactive_list_is_low(struct lruvec *lruvec, enum lru_list lru)
-{
-	if (is_file_lru(lru))
-		return inactive_file_is_low(lruvec);
+	gb = (inactive + active) >> (30 - PAGE_SHIFT);
+	if (gb)
+		inactive_ratio = int_sqrt(10 * gb);
 	else
-		return inactive_anon_is_low(lruvec);
+		inactive_ratio = 1;
+
+	return inactive * inactive_ratio < active;
 }
 
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 				 struct lruvec *lruvec, struct scan_control *sc)
 {
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(lruvec, lru))
+		if (inactive_list_is_low(lruvec, is_file_lru(lru)))
 			shrink_active_list(nr_to_scan, lruvec, sc, lru);
 		return 0;
 	}
@@ -2062,7 +2042,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * lruvec even if it has plenty of old anonymous pages unless the
 	 * system is under heavy pressure.
 	 */
-	if (!inactive_file_is_low(lruvec) &&
+	if (!inactive_list_is_low(lruvec, true) &&
 	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
@@ -2304,7 +2284,7 @@ static void shrink_zone_memcg(struct zone *zone, struct mem_cgroup *memcg,
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_anon_is_low(lruvec))
+	if (inactive_list_is_low(lruvec, false))
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
 
@@ -2965,7 +2945,7 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
 	do {
 		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 
-		if (inactive_anon_is_low(lruvec))
+		if (inactive_list_is_low(lruvec, false))
 			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 					   sc, LRU_ACTIVE_ANON);
 
-- 
2.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
