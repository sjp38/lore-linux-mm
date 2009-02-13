Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 706676B009B
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 19:16:32 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id u3so597094tia.8
        for <linux-mm@kvack.org>; Thu, 12 Feb 2009 16:16:30 -0800 (PST)
Date: Fri, 13 Feb 2009 09:15:55 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: [patch 1/2 v2] shrink_all_memory(): use sc.nr_reclaimed
Message-Id: <20090213091555.bdcae531.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, MinChan Kim <minchan.kim@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Impact: cleanup

Commit a79311c14eae4bb946a97af25f3e1b17d625985d "vmscan: bail out of
direct reclaim after swap_cluster_max pages" moved the nr_reclaimed
counter into the scan control to accumulate the number of all
reclaimed pages in a reclaim invocation.

shrink_all_memory() can use the same mechanism. it increase code 
consistency and redability.


Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   43 ++++++++++++++++++++++---------------------
 1 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ae4202b..172e394 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2055,16 +2055,15 @@ unsigned long global_lru_pages(void)
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
+static void shrink_all_zones(unsigned long nr_pages, int prio,
 				      int pass, struct scan_control *sc)
 {
 	struct zone *zone;
-	unsigned long ret = 0;
+	unsigned long nr_reclaimed = 0;
 
 	for_each_populated_zone(zone) {
 		enum lru_list l;
@@ -2087,14 +2086,16 @@ static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
 
 				zone->lru[l].nr_scan = 0;
 				nr_to_scan = min(nr_pages, lru_pages);
-				ret += shrink_list(l, nr_to_scan, zone,
+				nr_reclaimed += shrink_list(l, nr_to_scan, zone,
 								sc, prio);
-				if (ret >= nr_pages)
-					return ret;
+				if (nr_reclaimed >= nr_pages) {
+					sc->nr_reclaimed = nr_reclaimed;
+					return;
+				}
 			}
 		}
 	}
-	return ret;
+	sc->nr_reclaimed = nr_reclaimed;
 }
 
 /*
@@ -2108,7 +2109,6 @@ static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
 unsigned long shrink_all_memory(unsigned long nr_pages)
 {
 	unsigned long lru_pages, nr_slab;
-	unsigned long ret = 0;
 	int pass;
 	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
@@ -2130,8 +2130,8 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
 		if (!reclaim_state.reclaimed_slab)
 			break;
 
-		ret += reclaim_state.reclaimed_slab;
-		if (ret >= nr_pages)
+		sc.nr_reclaimed += reclaim_state.reclaimed_slab;
+		if (sc.nr_reclaimed >= nr_pages) 
 			goto out;
 
 		nr_slab -= reclaim_state.reclaimed_slab;
@@ -2153,18 +2153,18 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
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
@@ -2173,21 +2173,22 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
 	}
 
 	/*
-	 * If ret = 0, we could not shrink LRUs, but there may be something
+	 * If sc.nr_reclaimed = 0, we could not shrink LRUs, but there may be something
 	 * in slab caches
 	 */
-	if (!ret) {
+	if (!sc.nr_reclaimed) {
 		do {
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
-			ret += reclaim_state.reclaimed_slab;
-		} while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
+			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
+		} while (sc.nr_reclaimed < nr_pages && reclaim_state.reclaimed_slab > 0);
 	}
 
+
 out:
 	current->reclaim_state = NULL;
 
-	return ret;
+	return sc.nr_reclaimed;
 }
 #endif
 
-- 
1.5.4.3


-- 
Kinds Regards
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
