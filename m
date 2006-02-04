Date: Fri, 3 Feb 2006 16:29:43 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Hmmm... Stab at thinning scan_control
In-Reply-To: <20060119204411.18a83bd7.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0602031628140.2901@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0601192029100.14480@schroedinger.engr.sgi.com>
 <20060119204411.18a83bd7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jan 2006, Andrew Morton wrote:

> Looks sane, although I don't have time to go through it at present - please
> send later.

Rediff against 2.6.16-rc2




Thin out scan_control: remove nr_to_scan and priority

Make nr_to_scan and priority a parameter instead of putting it into
scan control. This allows various small optimizations and IMHO makes
the code easier to read.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc2/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc2.orig/mm/vmscan.c	2006-02-02 22:03:08.000000000 -0800
+++ linux-2.6.16-rc2/mm/vmscan.c	2006-02-03 16:25:58.000000000 -0800
@@ -52,9 +52,6 @@ typedef enum {
 } pageout_t;
 
 struct scan_control {
-	/* Ask refill_inactive_zone, or shrink_cache to scan this many pages */
-	unsigned long nr_to_scan;
-
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
 
@@ -63,9 +60,6 @@ struct scan_control {
 
 	unsigned long nr_mapped;	/* From page_state */
 
-	/* Ask shrink_caches, or shrink_zone to scan at this priority */
-	unsigned int priority;
-
 	/* This context's GFP mask */
 	gfp_t gfp_mask;
 
@@ -1084,11 +1078,10 @@ static int isolate_lru_pages(int nr_to_s
 /*
  * shrink_cache() adds the number of pages reclaimed to sc->nr_reclaimed
  */
-static void shrink_cache(struct zone *zone, struct scan_control *sc)
+static void shrink_cache(int max_scan, struct zone *zone, struct scan_control *sc)
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
-	int max_scan = sc->nr_to_scan;
 
 	pagevec_init(&pvec, 1);
 
@@ -1164,12 +1157,11 @@ done:
  * But we had to alter page->flags anyway.
  */
 static void
-refill_inactive_zone(struct zone *zone, struct scan_control *sc)
+refill_inactive_zone(int nr_pages, struct zone *zone, struct scan_control *sc)
 {
 	int pgmoved;
 	int pgdeactivate = 0;
 	int pgscanned;
-	int nr_pages = sc->nr_to_scan;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_inactive);	/* Pages to go onto the inactive_list */
 	LIST_HEAD(l_active);	/* Pages to go onto the active_list */
@@ -1296,10 +1288,11 @@ refill_inactive_zone(struct zone *zone, 
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
 static void
-shrink_zone(struct zone *zone, struct scan_control *sc)
+shrink_zone(int priority, struct zone *zone, struct scan_control *sc)
 {
 	unsigned long nr_active;
 	unsigned long nr_inactive;
+	unsigned long nr_to_scan;
 
 	atomic_inc(&zone->reclaim_in_progress);
 
@@ -1307,14 +1300,14 @@ shrink_zone(struct zone *zone, struct sc
 	 * Add one to `nr_to_scan' just to make sure that the kernel will
 	 * slowly sift through the active list.
 	 */
-	zone->nr_scan_active += (zone->nr_active >> sc->priority) + 1;
+	zone->nr_scan_active += (zone->nr_active >> priority) + 1;
 	nr_active = zone->nr_scan_active;
 	if (nr_active >= sc->swap_cluster_max)
 		zone->nr_scan_active = 0;
 	else
 		nr_active = 0;
 
-	zone->nr_scan_inactive += (zone->nr_inactive >> sc->priority) + 1;
+	zone->nr_scan_inactive += (zone->nr_inactive >> priority) + 1;
 	nr_inactive = zone->nr_scan_inactive;
 	if (nr_inactive >= sc->swap_cluster_max)
 		zone->nr_scan_inactive = 0;
@@ -1323,17 +1316,17 @@ shrink_zone(struct zone *zone, struct sc
 
 	while (nr_active || nr_inactive) {
 		if (nr_active) {
-			sc->nr_to_scan = min(nr_active,
+			nr_to_scan = min(nr_active,
 					(unsigned long)sc->swap_cluster_max);
-			nr_active -= sc->nr_to_scan;
-			refill_inactive_zone(zone, sc);
+			nr_active -= nr_to_scan;
+			refill_inactive_zone(nr_to_scan, zone, sc);
 		}
 
 		if (nr_inactive) {
-			sc->nr_to_scan = min(nr_inactive,
+			nr_to_scan = min(nr_inactive,
 					(unsigned long)sc->swap_cluster_max);
-			nr_inactive -= sc->nr_to_scan;
-			shrink_cache(zone, sc);
+			nr_inactive -= nr_to_scan;
+			shrink_cache(nr_to_scan, zone, sc);
 		}
 	}
 
@@ -1359,7 +1352,7 @@ shrink_zone(struct zone *zone, struct sc
  * scan then give up on it.
  */
 static void
-shrink_caches(struct zone **zones, struct scan_control *sc)
+shrink_caches(int priority, struct zone **zones, struct scan_control *sc)
 {
 	int i;
 
@@ -1372,14 +1365,14 @@ shrink_caches(struct zone **zones, struc
 		if (!cpuset_zone_allowed(zone, __GFP_HARDWALL))
 			continue;
 
-		zone->temp_priority = sc->priority;
-		if (zone->prev_priority > sc->priority)
-			zone->prev_priority = sc->priority;
+		zone->temp_priority = priority;
+		if (zone->prev_priority > priority)
+			zone->prev_priority = priority;
 
-		if (zone->all_unreclaimable && sc->priority != DEF_PRIORITY)
+		if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 			continue;	/* Let kswapd poll it */
 
-		shrink_zone(zone, sc);
+		shrink_zone(priority, zone, sc);
 	}
 }
  
@@ -1426,11 +1419,10 @@ int try_to_free_pages(struct zone **zone
 		sc.nr_mapped = read_page_state(nr_mapped);
 		sc.nr_scanned = 0;
 		sc.nr_reclaimed = 0;
-		sc.priority = priority;
 		sc.swap_cluster_max = SWAP_CLUSTER_MAX;
 		if (!priority)
 			disable_swap_token();
-		shrink_caches(zones, &sc);
+		shrink_caches(priority, zones, &sc);
 		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages);
 		if (reclaim_state) {
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
@@ -1593,10 +1585,9 @@ scan:
 				zone->prev_priority = priority;
 			sc.nr_scanned = 0;
 			sc.nr_reclaimed = 0;
-			sc.priority = priority;
 			sc.swap_cluster_max = nr_pages? nr_pages : SWAP_CLUSTER_MAX;
 			atomic_inc(&zone->reclaim_in_progress);
-			shrink_zone(zone, &sc);
+			shrink_zone(priority, zone, &sc);
 			atomic_dec(&zone->reclaim_in_progress);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
@@ -1852,6 +1843,7 @@ int zone_reclaim(struct zone *zone, gfp_
 	struct scan_control sc;
 	cpumask_t mask;
 	int node_id;
+	int priority;
 
 	if (time_before(jiffies,
 		zone->last_unsuccessful_zone_reclaim + zone_reclaim_interval))
@@ -1871,7 +1863,6 @@ int zone_reclaim(struct zone *zone, gfp_
 	sc.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP);
 	sc.nr_scanned = 0;
 	sc.nr_reclaimed = 0;
-	sc.priority = ZONE_RECLAIM_PRIORITY + 1;
 	sc.nr_mapped = read_page_state(nr_mapped);
 	sc.gfp_mask = gfp_mask;
 
@@ -1892,11 +1883,11 @@ int zone_reclaim(struct zone *zone, gfp_
 	 * Free memory by calling shrink zone with increasing priorities
 	 * until we have enough memory freed.
 	 */
-	do {
-		sc.priority--;
-		shrink_zone(zone, &sc);
+	for (priority = ZONE_RECLAIM_PRIORITY;
+		priority >=0 && sc.nr_reclaimed < nr_pages;
+		priority--)
+			shrink_zone(priority, zone, &sc);
 
-	} while (sc.nr_reclaimed < nr_pages && sc.priority > 0);
 
 	if (sc.nr_reclaimed < nr_pages && (zone_reclaim_mode & RECLAIM_SLAB)) {
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
