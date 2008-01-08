Message-Id: <20080108210004.276570193@redhat.com>
References: <20080108205939.323955454@redhat.com>
Date: Tue, 08 Jan 2008 15:59:45 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 06/19] SEQ replacement for anonymous pages
Content-Disposition: inline; filename=rvr-03-linux-2.6-vm-anon-seq.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We avoid evicting and scanning anonymous pages for the most part, but
under some workloads we can end up with most of memory filled with
anonymous pages.  At that point, we suddenly need to clear the referenced
bits on all of memory, which can take ages on very large memory systems.

We can reduce the maximum number of pages that need to be scanned by
not taking the referenced state into account when deactivating an
anonymous page.  After all, every anonymous page starts out referenced,
so why check?

If an anonymous page gets referenced again before it reaches the end
of the inactive list, we move it back to the active list.

To keep the maximum amount of necessary work reasonable, we scale the
active to inactive ratio with the size of memory, using the formula
active:inactive ratio = sqrt(memory in GB * 10).

Kswapd CPU use now seems to scale by the amount of pageout bandwidth,
instead of by the amount of memory present in the system.

Signed-off-by: Rik van Riel <riel@redhat.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Index: linux-2.6.24-rc6-mm1/include/linux/mm_inline.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/mm_inline.h	2008-01-02 15:55:33.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/mm_inline.h	2008-01-02 16:00:39.000000000 -0500
@@ -106,4 +106,16 @@ del_page_from_lru(struct zone *zone, str
 	__dec_zone_state(zone, NR_INACTIVE_ANON + l);
 }
 
+static inline int inactive_anon_low(struct zone *zone)
+{
+	unsigned long active, inactive;
+
+	active = zone_page_state(zone, NR_ACTIVE_ANON);
+	inactive = zone_page_state(zone, NR_INACTIVE_ANON);
+
+	if (inactive * zone->inactive_ratio < active)
+		return 1;
+
+	return 0;
+}
 #endif
Index: linux-2.6.24-rc6-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/mmzone.h	2008-01-02 15:55:33.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/mmzone.h	2008-01-02 16:00:39.000000000 -0500
@@ -313,6 +313,11 @@ struct zone {
 	 */
 	int prev_priority;
 
+	/*
+	 * The ratio of active to inactive pages.
+	 */
+	unsigned int inactive_ratio;
+
 
 	ZONE_PADDING(_pad2_)
 	/* Rarely used or read-mostly fields */
Index: linux-2.6.24-rc6-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/page_alloc.c	2008-01-02 15:55:33.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/page_alloc.c	2008-01-02 16:00:39.000000000 -0500
@@ -4230,6 +4230,45 @@ void setup_per_zone_pages_min(void)
 	calculate_totalreserve_pages();
 }
 
+/**
+ * setup_per_zone_inactive_ratio - called when min_free_kbytes changes.
+ *
+ * The inactive anon list should be small enough that the VM never has to
+ * do too much work, but large enough that each inactive page has a chance
+ * to be referenced again before it is swapped out.
+ *
+ * The inactive_anon ratio is the ratio of active to inactive anonymous
+ * pages.  Ie. a ratio of 3 means 3:1 or 25% of the anonymous pages are
+ * on the inactive list.
+ *
+ * total     return    max
+ * memory    value     inactive anon
+ * -------------------------------------
+ *   10MB       1         5MB
+ *  100MB       1        50MB
+ *    1GB       3       250MB
+ *   10GB      10       0.9GB
+ *  100GB      31         3GB
+ *    1TB     101        10GB
+ *   10TB     320        32GB
+ */
+void setup_per_zone_inactive_ratio(void)
+{
+	struct zone *zone;
+
+	for_each_zone(zone) {
+		unsigned int gb, ratio;
+
+		/* Zone size in gigabytes */
+		gb = zone->present_pages >> (30 - PAGE_SHIFT);
+		ratio = int_sqrt(10 * gb);
+		if (!ratio)
+			ratio = 1;
+
+		zone->inactive_ratio = ratio;
+	}
+}
+
 /*
  * Initialise min_free_kbytes.
  *
@@ -4267,6 +4306,7 @@ static int __init init_per_zone_pages_mi
 		min_free_kbytes = 65536;
 	setup_per_zone_pages_min();
 	setup_per_zone_lowmem_reserve();
+	setup_per_zone_inactive_ratio();
 	return 0;
 }
 module_init(init_per_zone_pages_min)
Index: linux-2.6.24-rc6-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/vmscan.c	2008-01-02 15:56:00.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/vmscan.c	2008-01-02 16:00:39.000000000 -0500
@@ -1019,7 +1019,7 @@ static inline int zone_is_near_oom(struc
 static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 				struct scan_control *sc, int priority, int file)
 {
-	unsigned long pgmoved;
+	unsigned long pgmoved = 0;
 	int pgdeactivate = 0;
 	unsigned long pgscanned;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
@@ -1058,12 +1058,25 @@ static void shrink_active_list(unsigned 
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
-		if (page_referenced(page, 0, sc->mem_cgroup))
-			lru = LRU_ACTIVE_ANON;
+		if (page_referenced(page, 0, sc->mem_cgroup)) {
+			if (file)
+				/* Referenced file pages stay active. */
+				lru = LRU_ACTIVE_ANON;
+			else
+				/* Anonymous pages always get deactivated. */
+				pgmoved++;
+		}
 		list_add(&page->lru, &list[lru]);
 	}
 
 	/*
+	 * Count the referenced anon pages as rotated, to balance pageout
+	 * scan pressure between file and anonymous pages in get_scan_ratio.
+	 */
+	if (!file)
+		zone->recent_rotated_anon += pgmoved;
+
+	/*
 	 * Now put the pages back to the appropriate [file or anon] inactive
 	 * and active lists.
 	 */
@@ -1145,7 +1158,11 @@ static unsigned long shrink_list(enum lr
 {
 	int file = is_file_lru(lru);
 
-	if (lru == LRU_ACTIVE_ANON || lru == LRU_ACTIVE_FILE) {
+	if (lru == LRU_ACTIVE_FILE) {
+		shrink_active_list(nr_to_scan, zone, sc, priority, file);
+		return 0;
+	}
+	if (lru == LRU_ACTIVE_ANON && inactive_anon_low(zone)) {
 		shrink_active_list(nr_to_scan, zone, sc, priority, file);
 		return 0;
 	}
@@ -1255,8 +1272,8 @@ static unsigned long shrink_zone(int pri
 		}
 	}
 
-	while (nr[LRU_ACTIVE_ANON] || nr[LRU_INACTIVE_ANON] ||
-				nr[LRU_ACTIVE_FILE] || nr[LRU_INACTIVE_FILE]) {
+	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
+						 nr[LRU_INACTIVE_FILE]) {
 		for_each_lru(l) {
 			if (nr[l]) {
 				nr_to_scan = min(nr[l],
@@ -1560,6 +1577,14 @@ loop_again:
 			    priority != DEF_PRIORITY)
 				continue;
 
+			/*
+			 * Do some background aging of the anon list, to give
+			 * pages a chance to be referenced before reclaiming.
+			 */
+			if (inactive_anon_low(zone))
+				shrink_active_list(SWAP_CLUSTER_MAX, zone,
+							&sc, priority, 0);
+
 			if (!zone_watermark_ok(zone, order, zone->pages_high,
 					       0, 0)) {
 				end_zone = i;
Index: linux-2.6.24-rc6-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/vmstat.c	2008-01-02 15:55:33.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/vmstat.c	2008-01-02 15:56:07.000000000 -0500
@@ -800,10 +800,12 @@ static void zoneinfo_show_print(struct s
 	seq_printf(m,
 		   "\n  all_unreclaimable: %u"
 		   "\n  prev_priority:     %i"
-		   "\n  start_pfn:         %lu",
+		   "\n  start_pfn:         %lu"
+		   "\n  inactive_ratio:    %u",
 			   zone_is_all_unreclaimable(zone),
 		   zone->prev_priority,
-		   zone->zone_start_pfn);
+		   zone->zone_start_pfn,
+		   zone->inactive_ratio);
 	seq_putc(m, '\n');
 }
 

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
