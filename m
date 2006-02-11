Date: Sat, 11 Feb 2006 14:25:57 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Skip reclaim_mapped determination if we do not swap
In-Reply-To: <20060211135031.623fdef9.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0602111424050.24990@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0602111335560.24685@schroedinger.engr.sgi.com>
 <20060211135031.623fdef9.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, nickpiggin@yahoo.com.au, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

Here is a new rev of the earlier patch that moves the determination of
reclaim_mapped into shrink_zone(). This means that refill_inactive does 
not depend on scan control anymore. And its properly formatted for 80 
columns

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc2/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc2.orig/mm/vmscan.c	2006-02-11 13:35:20.000000000 -0800
+++ linux-2.6.16-rc2/mm/vmscan.c	2006-02-11 14:22:07.000000000 -0800
@@ -1168,21 +1168,16 @@ done:
  * But we had to alter page->flags anyway.
  */
 static void
-refill_inactive_zone(struct zone *zone, struct scan_control *sc)
+refill_inactive_zone(struct zone *zone, unsigned long nr_pages, int reclaim_mapped)
 {
 	int pgmoved;
 	int pgdeactivate = 0;
 	int pgscanned;
-	int nr_pages = sc->nr_to_scan;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_inactive);	/* Pages to go onto the inactive_list */
 	LIST_HEAD(l_active);	/* Pages to go onto the active_list */
 	struct page *page;
 	struct pagevec pvec;
-	int reclaim_mapped = 0;
-	long mapped_ratio;
-	long distress;
-	long swap_tendency;
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
@@ -1192,37 +1187,6 @@ refill_inactive_zone(struct zone *zone, 
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
@@ -1304,6 +1268,7 @@ shrink_zone(struct zone *zone, struct sc
 {
 	unsigned long nr_active;
 	unsigned long nr_inactive;
+	int reclaim_mapped = 0;
 
 	atomic_inc(&zone->reclaim_in_progress);
 
@@ -1325,12 +1290,52 @@ shrink_zone(struct zone *zone, struct sc
 	else
 		nr_inactive = 0;
 
+	if (sc->may_swap) {
+		long mapped_ratio;
+		long distress;
+		long swap_tendency;
+
+		/*
+		 * `distress' is a measure of how much trouble we're having
+		 * reclaiming  pages.  0 -> no problems.  100 -> great trouble.
+		 */
+		distress = 100 >> zone->prev_priority;
+
+		/*
+		 * The point of this algorithm is to decide when to start
+		 * reclaiming mapped memory instead of just pagecache.
+		 * Work out how much memory is mapped.
+		 */
+		mapped_ratio = (sc->nr_mapped * 100) / total_memory;
+
+		/*
+		 * Now decide how much we really want to unmap some pages.
+		 * The mappe ratio is downgraded - just because there's a lot
+		 * of mapped memory doesn't necessarily mean that page reclaim
+		 * isn't succeeding.
+		 *
+		 * The distress ratio is important - we don't want to start
+		 * going oom.
+		 *
+		 * A 100% value of vm_swappiness overrides this algorithm
+		 * altogether.
+		 */
+		swap_tendency = mapped_ratio / 2 + distress + vm_swappiness;
+
+		/*
+		 * Now use this metric to decide whether to start moving
+		 * mapped memory onto the inactive list.
+		 */
+		if (swap_tendency >= 100)
+			reclaim_mapped = 1;
+	}
+
 	while (nr_active || nr_inactive) {
 		if (nr_active) {
 			sc->nr_to_scan = min(nr_active,
 					(unsigned long)sc->swap_cluster_max);
 			nr_active -= sc->nr_to_scan;
-			refill_inactive_zone(zone, sc);
+			refill_inactive_zone(zone, sc->nr_to_scan, reclaim_mapped);
 		}
 
 		if (nr_inactive) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
