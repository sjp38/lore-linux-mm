From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:38:56 +0200
Message-Id: <20060712143856.16998.49478.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 10/39] mm: pgrep: isolate the reclaim_mapped logic
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Move the reclaim_mapped code over to its own function so that other
reclaim policies can make use of it.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_page_replace.h |    2 
 mm/vmscan.c                     |   95 ++++++++++++++++++++--------------------
 2 files changed, 49 insertions(+), 48 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2006-07-12 16:11:49.000000000 +0200
@@ -618,6 +618,50 @@ done:
 	return nr_reclaimed;
 }
 
+int should_reclaim_mapped(struct zone *zone)
+{
+	long mapped_ratio;
+	long distress;
+	long swap_tendency;
+
+	/*
+	 * `distress' is a measure of how much trouble we're having
+	 * reclaiming pages.  0 -> no problems.  100 -> great trouble.
+	 */
+	distress = 100 >> zone->prev_priority;
+
+	/*
+	 * The point of this algorithm is to decide when to start
+	 * reclaiming mapped memory instead of just pagecache.  Work out
+	 * how much memory
+	 * is mapped.
+	 */
+	mapped_ratio = (read_page_state(nr_mapped) * 100) / total_memory;
+
+	/*
+	 * Now decide how much we really want to unmap some pages.  The
+	 * mapped ratio is downgraded - just because there's a lot of
+	 * mapped memory doesn't necessarily mean that page reclaim
+	 * isn't succeeding.
+	 *
+	 * The distress ratio is important - we don't want to start
+	 * going oom.
+	 *
+	 * A 100% value of vm_swappiness overrides this algorithm
+	 * altogether.
+	 */
+	swap_tendency = mapped_ratio / 2 + distress + vm_swappiness;
+
+	/*
+	 * Now use this metric to decide whether to start moving mapped
+	 * memory onto the inactive list.
+	 */
+	if (swap_tendency >= 100)
+		return 1;
+
+	return 0;
+}
+
 /*
  * This moves pages from the active list to the inactive list.
  *
@@ -636,7 +680,7 @@ done:
  * But we had to alter page->flags anyway.
  */
 static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
-				struct scan_control *sc)
+				struct scan_control *sc, int reclaim_mapped)
 {
 	unsigned long pgmoved;
 	int pgdeactivate = 0;
@@ -646,48 +690,9 @@ static void shrink_active_list(unsigned 
 	LIST_HEAD(l_active);	/* Pages to go onto the active_list */
 	struct page *page;
 	struct pagevec pvec;
-	int reclaim_mapped = 0;
-
-	if (sc->may_swap) {
-		long mapped_ratio;
-		long distress;
-		long swap_tendency;
-
-		/*
-		 * `distress' is a measure of how much trouble we're having
-		 * reclaiming pages.  0 -> no problems.  100 -> great trouble.
-		 */
-		distress = 100 >> zone->prev_priority;
-
-		/*
-		 * The point of this algorithm is to decide when to start
-		 * reclaiming mapped memory instead of just pagecache.  Work out
-		 * how much memory
-		 * is mapped.
-		 */
-		mapped_ratio = (sc->nr_mapped * 100) / total_memory;
 
-		/*
-		 * Now decide how much we really want to unmap some pages.  The
-		 * mapped ratio is downgraded - just because there's a lot of
-		 * mapped memory doesn't necessarily mean that page reclaim
-		 * isn't succeeding.
-		 *
-		 * The distress ratio is important - we don't want to start
-		 * going oom.
-		 *
-		 * A 100% value of vm_swappiness overrides this algorithm
-		 * altogether.
-		 */
-		swap_tendency = mapped_ratio / 2 + distress + vm_swappiness;
-
-		/*
-		 * Now use this metric to decide whether to start moving mapped
-		 * memory onto the inactive list.
-		 */
-		if (swap_tendency >= 100)
-			reclaim_mapped = 1;
-	}
+	if (!sc->may_swap)
+		reclaim_mapped = 0;
 
 	pgrep_add_drain();
 	spin_lock_irq(&zone->lru_lock);
@@ -781,6 +786,7 @@ static unsigned long shrink_zone(int pri
 	unsigned long nr_inactive;
 	unsigned long nr_to_scan;
 	unsigned long nr_reclaimed = 0;
+	int reclaim_mapped = should_reclaim_mapped(zone);
 
 	atomic_inc(&zone->reclaim_in_progress);
 
@@ -807,7 +813,7 @@ static unsigned long shrink_zone(int pri
 			nr_to_scan = min(nr_active,
 					(unsigned long)sc->swap_cluster_max);
 			nr_active -= nr_to_scan;
-			shrink_active_list(nr_to_scan, zone, sc);
+			shrink_active_list(nr_to_scan, zone, sc, reclaim_mapped);
 		}
 
 		if (nr_inactive) {
@@ -910,7 +916,6 @@ unsigned long try_to_free_pages(struct z
 	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
-		sc.nr_mapped = read_page_state(nr_mapped);
 		sc.nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
@@ -1000,7 +1005,6 @@ loop_again:
 	total_scanned = 0;
 	nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
-	sc.nr_mapped = read_page_state(nr_mapped);
 
 	inc_page_state(pageoutrun);
 
@@ -1351,7 +1355,6 @@ static int __zone_reclaim(struct zone *z
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
-		.nr_mapped = read_page_state(nr_mapped),
 		.swap_cluster_max = max_t(unsigned long, nr_pages,
 					SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,
Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:50.000000000 +0200
@@ -12,8 +12,6 @@ struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
 
-	unsigned long nr_mapped;	/* From page_state */
-
 	/* This context's GFP mask */
 	gfp_t gfp_mask;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
