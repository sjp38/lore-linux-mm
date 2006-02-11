Date: Sat, 11 Feb 2006 13:39:14 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Skip reclaim_mapped determination if we do not swap
Message-ID: <Pine.LNX.4.62.0602111335560.24685@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, nickpiggin@yahoo.com.au, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

This puts the variables and the way to get to reclaim_mapped in one 
block. And allows zone_reclaim or other things to skip the determination 
(maybe this whole block of code does not belong into 
refill_inactive_zone()?)

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc2/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc2.orig/mm/vmscan.c	2006-02-11 13:29:51.000000000 -0800
+++ linux-2.6.16-rc2/mm/vmscan.c	2006-02-11 13:31:15.000000000 -0800
@@ -1180,9 +1180,43 @@ refill_inactive_zone(struct zone *zone, 
 	struct page *page;
 	struct pagevec pvec;
 	int reclaim_mapped = 0;
-	long mapped_ratio;
-	long distress;
-	long swap_tendency;
+
+	if (sc->may_swap) {
+		long mapped_ratio;
+		long distress;
+		long swap_tendency;
+
+		/*
+		 * `distress' is a measure of how much trouble we're having reclaiming
+		 * pages.  0 -> no problems.  100 -> great trouble.
+		 */
+		distress = 100 >> zone->prev_priority;
+
+		/*
+		 * The point of this algorithm is to decide when to start reclaiming
+		 * mapped memory instead of just pagecache.  Work out how much memory
+		 * is mapped.
+		 */
+		mapped_ratio = (sc->nr_mapped * 100) / total_memory;
+
+		/*
+		 * Now decide how much we really want to unmap some pages.  The mapped
+		 * ratio is downgraded - just because there's a lot of mapped memory
+		 * doesn't necessarily mean that page reclaim isn't succeeding.
+		 *
+		 * The distress ratio is important - we don't want to start going oom.
+		 *
+		 * A 100% value of vm_swappiness overrides this algorithm altogether.
+		 */
+		swap_tendency = mapped_ratio / 2 + distress + vm_swappiness;
+
+		/*
+		 * Now use this metric to decide whether to start moving mapped memory
+		 * onto the inactive list.
+		 */
+		if (swap_tendency >= 100)
+			reclaim_mapped = 1;
+	}
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
@@ -1192,37 +1226,6 @@ refill_inactive_zone(struct zone *zone, 
 	zone->nr_active -= pgmoved;
 	spin_unlock_irq(&zone->lru_lock);
 
-	/*
-	 * `distress' is a measure of how much trouble we're having reclaiming
-	 * pages.  0 -> no problems.  100 -> great trouble.
-	 */
-	distress = 100 >> zone->prev_priority;
-
-	/*
-	 * The point of this algorithm is to decide when to start reclaiming
-	 * mapped memory instead of just pagecache.  Work out how much memory
-	 * is mapped.
-	 */
-	mapped_ratio = (sc->nr_mapped * 100) / total_memory;
-
-	/*
-	 * Now decide how much we really want to unmap some pages.  The mapped
-	 * ratio is downgraded - just because there's a lot of mapped memory
-	 * doesn't necessarily mean that page reclaim isn't succeeding.
-	 *
-	 * The distress ratio is important - we don't want to start going oom.
-	 *
-	 * A 100% value of vm_swappiness overrides this algorithm altogether.
-	 */
-	swap_tendency = mapped_ratio / 2 + distress + vm_swappiness;
-
-	/*
-	 * Now use this metric to decide whether to start moving mapped memory
-	 * onto the inactive list.
-	 */
-	if (swap_tendency >= 100 && sc->may_swap)
-		reclaim_mapped = 1;
-
 	while (!list_empty(&l_hold)) {
 		cond_resched();
 		page = lru_to_page(&l_hold);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
