Message-Id: <20071218211549.536791435@redhat.com>
References: <20071218211539.250334036@redhat.com>
Date: Tue, 18 Dec 2007 16:15:49 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 10/20] SEQ replacement for anonymous pages
Content-Disposition: inline; filename=rvr-03-linux-2.6-vm-anon-seq.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com
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

Index: linux-2.6.24-rc3-mm2/include/linux/mm_inline.h
===================================================================
--- linux-2.6.24-rc3-mm2.orig/include/linux/mm_inline.h
+++ linux-2.6.24-rc3-mm2/include/linux/mm_inline.h
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
Index: linux-2.6.24-rc3-mm2/include/linux/mmzone.h
===================================================================
--- linux-2.6.24-rc3-mm2.orig/include/linux/mmzone.h
+++ linux-2.6.24-rc3-mm2/include/linux/mmzone.h
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
Index: linux-2.6.24-rc3-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.24-rc3-mm2.orig/mm/page_alloc.c
+++ linux-2.6.24-rc3-mm2/mm/page_alloc.c
@@ -4221,6 +4221,34 @@ void setup_per_zone_pages_min(void)
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
@@ -4258,6 +4286,7 @@ static int __init init_per_zone_pages_mi
 		min_free_kbytes = 65536;
 	setup_per_zone_pages_min();
 	setup_per_zone_lowmem_reserve();
+	setup_per_zone_inactive_ratio();
 	return 0;
 }
 module_init(init_per_zone_pages_min)
Index: linux-2.6.24-rc3-mm2/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc3-mm2.orig/mm/vmscan.c
+++ linux-2.6.24-rc3-mm2/mm/vmscan.c
@@ -1018,7 +1018,7 @@ static inline int zone_is_near_oom(struc
 static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 				struct scan_control *sc, int priority, int file)
 {
-	unsigned long pgmoved;
+	unsigned long pgmoved = 0;
 	int pgdeactivate = 0;
 	unsigned long pgscanned;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
@@ -1057,12 +1057,25 @@ static void shrink_active_list(unsigned 
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
@@ -1144,7 +1157,11 @@ static unsigned long shrink_list(enum lr
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
@@ -1261,6 +1278,9 @@ static unsigned long shrink_zone(int pri
 					zone, priority, 0, 0);
 	}
 
+	if (!inactive_anon_low(zone))
+		nr[LRU_ACTIVE_ANON] = 0;
+
 	while (nr[LRU_ACTIVE_ANON] || nr[LRU_INACTIVE_ANON] ||
 			nr[LRU_ACTIVE_FILE] || nr[LRU_INACTIVE_FILE]) {
 		for_each_lru(l) {
@@ -1565,6 +1585,14 @@ loop_again:
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
Index: linux-2.6.24-rc3-mm2/mm/vmstat.c
===================================================================
--- linux-2.6.24-rc3-mm2.orig/mm/vmstat.c
+++ linux-2.6.24-rc3-mm2/mm/vmstat.c
@@ -807,10 +807,12 @@ static void zoneinfo_show_print(struct s
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
