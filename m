Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 96B296B0047
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 06:51:50 -0500 (EST)
Message-Id: <20090212114416.087292463@cmpxchg.org>
Date: Thu, 12 Feb 2009 12:36:10 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/2] shrink_all_memory(): use sc.nr_reclaimed
References: <20090212113609.351980834@cmpxchg.org>
Content-Disposition: inline; filename=shrink_all_memory-use-sc.nr_reclaimed.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, MinChan Kim <minchan.kim@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Impact: cleanup

Commit a79311c14eae4bb946a97af25f3e1b17d625985d "vmscan: bail out of
direct reclaim after swap_cluster_max pages" moved the nr_reclaimed
counter into the scan control to accumulate the number of all
reclaimed pages in a reclaim invocation.

shrink_all_memory() can use the same mechanism. it increase code 
consistency.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: MinChan Kim <minchan.kim@gmail.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   49 +++++++++++++++++++++++--------------------------
 1 file changed, 23 insertions(+), 26 deletions(-)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2048,16 +2048,14 @@ unsigned long global_lru_pages(void)
 #ifdef CONFIG_PM
 /*
  * Helper function for shrink_all_memory().  Tries to reclaim 'nr_pages' pages
- * from LRU lists system-wide, for given pass and priority, and returns the
- * number of reclaimed pages
+ * from LRU lists system-wide, for given pass and priority.
  *
  * For pass > 3 we also try to shrink the LRU lists that contain a few pages
  */
-static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
-				      int pass, struct scan_control *sc)
+static void shrink_all_zones(unsigned long nr_pages, int prio,
+			      int pass, struct scan_control *sc)
 {
 	struct zone *zone;
-	unsigned long ret = 0;
 
 	for_each_zone(zone) {
 		enum lru_list l;
@@ -2082,14 +2080,13 @@ static unsigned long shrink_all_zones(un
 
 				zone->lru[l].nr_scan = 0;
 				nr_to_scan = min(nr_pages, lru_pages);
-				ret += shrink_list(l, nr_to_scan, zone,
-								sc, prio);
-				if (ret >= nr_pages)
-					return ret;
+				sc->nr_reclaimed += shrink_list(l, nr_to_scan,
+								zone, sc, prio);
+				if (sc->nr_reclaimed >= nr_pages)
+					return;
 			}
 		}
 	}
-	return ret;
 }
 
 /*
@@ -2103,7 +2100,6 @@ static unsigned long shrink_all_zones(un
 unsigned long shrink_all_memory(unsigned long nr_pages)
 {
 	unsigned long lru_pages, nr_slab;
-	unsigned long ret = 0;
 	int pass;
 	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
@@ -2125,8 +2121,8 @@ unsigned long shrink_all_memory(unsigned
 		if (!reclaim_state.reclaimed_slab)
 			break;
 
-		ret += reclaim_state.reclaimed_slab;
-		if (ret >= nr_pages)
+		sc.nr_reclaimed += reclaim_state.reclaimed_slab;
+		if (sc.nr_reclaimed >= nr_pages)
 			goto out;
 
 		nr_slab -= reclaim_state.reclaimed_slab;
@@ -2148,18 +2144,18 @@ unsigned long shrink_all_memory(unsigned
 			sc.may_unmap = 1;
 
 		for (prio = DEF_PRIORITY; prio >= 0; prio--) {
-			unsigned long nr_to_scan = nr_pages - ret;
+			unsigned long nr_to_scan = nr_pages - sc.nr_reclaimed;
 
 			sc.nr_scanned = 0;
-			ret += shrink_all_zones(nr_to_scan, prio, pass, &sc);
-			if (ret >= nr_pages)
+			shrink_all_zones(nr_to_scan, prio, pass, &sc);
+			if (sc.nr_reclaimed >= nr_pages)
 				goto out;
 
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(sc.nr_scanned, sc.gfp_mask,
 					global_lru_pages());
-			ret += reclaim_state.reclaimed_slab;
-			if (ret >= nr_pages)
+			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
+			if (sc.nr_reclaimed >= nr_pages)
 				goto out;
 
 			if (sc.nr_scanned && prio < DEF_PRIORITY - 2)
@@ -2167,22 +2163,23 @@ unsigned long shrink_all_memory(unsigned
 		}
 	}
 
-	/*
-	 * If ret = 0, we could not shrink LRUs, but there may be something
-	 * in slab caches
-	 */
-	if (!ret) {
+	if (!sc.nr_reclaimed) {
+		/*
+		 * We could not shrink LRUs, but there may be something
+		 * in slab caches.
+		 */
 		do {
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
-			ret += reclaim_state.reclaimed_slab;
-		} while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
+			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
+		} while (sc.nr_reclaimed < nr_pages &&
+				reclaim_state.reclaimed_slab > 0);
 	}
 
 out:
 	current->reclaim_state = NULL;
 
-	return ret;
+	return sc.nr_reclaimed;
 }
 #endif
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
