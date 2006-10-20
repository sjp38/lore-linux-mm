Message-Id: <200610201953.k9KJrpci032337@shell0.pdx.osdl.net>
Subject: [patch 4/4] Use min of two prio settings in calculating distress for reclaim
From: akpm@osdl.org
Date: Fri, 20 Oct 2006 12:53:50 -0700
Sender: owner-linux-mm@kvack.org
From: Martin Bligh <mbligh@google.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, mbligh@google.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

If try_to_free_pages / balance_pgdat are called with a gfp_mask specifying
GFP_IO and/or GFP_FS, they will reclaim the requisite number of pages, and the
reset prev_priority to DEF_PRIORITY (or to some other high (ie: unurgent)
value).

However, another reclaimer without those gfp_mask flags set (say, GFP_NOIO)
may still be struggling to reclaim pages.  The concurrent overwrite of
zone->prev_priority will cause this GFP_NOIO thread to unexpectedly cease
deactivating mapped pages, thus causing reclaim difficulties.

Fix this is to key the distress calculation not off zone->prev_priority, but
also take into account the local caller's priority by using
min(zone->prev_priority, sc->priority)

Signed-off-by: Martin J. Bligh <mbligh@google.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 mm/vmscan.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff -puN mm/vmscan.c~use-min-of-two-prio-settings-in-calculating-distress-for mm/vmscan.c
--- a/mm/vmscan.c~use-min-of-two-prio-settings-in-calculating-distress-for
+++ a/mm/vmscan.c
@@ -760,7 +760,7 @@ static inline int zone_is_near_oom(struc
  * But we had to alter page->flags anyway.
  */
 static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
-				struct scan_control *sc)
+				struct scan_control *sc, int priority)
 {
 	unsigned long pgmoved;
 	int pgdeactivate = 0;
@@ -784,7 +784,7 @@ static void shrink_active_list(unsigned 
 		 * `distress' is a measure of how much trouble we're having
 		 * reclaiming pages.  0 -> no problems.  100 -> great trouble.
 		 */
-		distress = 100 >> zone->prev_priority;
+		distress = 100 >> min(zone->prev_priority, priority);
 
 		/*
 		 * The point of this algorithm is to decide when to start
@@ -936,7 +936,7 @@ static unsigned long shrink_zone(int pri
 			nr_to_scan = min(nr_active,
 					(unsigned long)sc->swap_cluster_max);
 			nr_active -= nr_to_scan;
-			shrink_active_list(nr_to_scan, zone, sc);
+			shrink_active_list(nr_to_scan, zone, sc, priority);
 		}
 
 		if (nr_inactive) {
@@ -1384,7 +1384,7 @@ static unsigned long shrink_all_zones(un
 			if (zone->nr_scan_active >= nr_pages || pass > 3) {
 				zone->nr_scan_active = 0;
 				nr_to_scan = min(nr_pages, zone->nr_active);
-				shrink_active_list(nr_to_scan, zone, sc);
+				shrink_active_list(nr_to_scan, zone, sc, prio);
 			}
 		}
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
