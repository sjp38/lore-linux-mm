Message-Id: <20070820215316.762304882@sgi.com>
References: <20070820215040.937296148@sgi.com>
Date: Mon, 20 Aug 2007 14:50:44 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 4/7] Pass laundry through shrink_inactive_list() and shrink_zone()
Content-Disposition: inline; filename=shrink_zones
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Both functions are equipped with an additional laundry parameter
that is then passed to shrink_page_list.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/vmscan.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-08-19 23:27:16.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-08-19 23:30:15.000000000 -0700
@@ -802,7 +802,7 @@ static unsigned long clear_active_flags(
  * of reclaimed pages
  */
 static unsigned long shrink_inactive_list(unsigned long max_scan,
-				struct zone *zone, struct scan_control *sc)
+	struct zone *zone, struct scan_control *sc, struct list_head *laundry)
 {
 	LIST_HEAD(page_list);
 	unsigned long nr_scanned = 0;
@@ -830,7 +830,7 @@ static unsigned long shrink_inactive_lis
 		spin_unlock_irq(&zone->lru_lock);
 
 		nr_scanned += nr_scan;
-		nr_freed = shrink_page_list(&page_list, sc, NULL);
+		nr_freed = shrink_page_list(&page_list, sc, laundry);
 		nr_reclaimed += nr_freed;
 		local_irq_disable();
 		if (current_is_kswapd()) {
@@ -1030,7 +1030,7 @@ force_reclaim_mapped:
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
 static unsigned long shrink_zone(int priority, struct zone *zone,
-				struct scan_control *sc)
+			struct scan_control *sc, struct list_head *laundry)
 {
 	unsigned long nr_active;
 	unsigned long nr_inactive;
@@ -1072,7 +1072,7 @@ static unsigned long shrink_zone(int pri
 					(unsigned long)sc->swap_cluster_max);
 			nr_inactive -= nr_to_scan;
 			nr_reclaimed += shrink_inactive_list(nr_to_scan, zone,
-								sc);
+								sc, laundry);
 		}
 	}
 
@@ -1121,7 +1121,7 @@ static unsigned long shrink_zones(int pr
 
 		sc->all_unreclaimable = 0;
 
-		nr_reclaimed += shrink_zone(priority, zone, sc);
+		nr_reclaimed += shrink_zone(priority, zone, sc, NULL);
 	}
 	return nr_reclaimed;
 }
@@ -1341,7 +1341,7 @@ loop_again:
 			temp_priority[i] = priority;
 			sc.nr_scanned = 0;
 			note_zone_scanning_priority(zone, priority);
-			nr_reclaimed += shrink_zone(priority, zone, &sc);
+			nr_reclaimed += shrink_zone(priority, zone, &sc, NULL);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);
@@ -1539,7 +1539,7 @@ static unsigned long shrink_all_zones(un
 			zone->nr_scan_inactive = 0;
 			nr_to_scan = min(nr_pages,
 				zone_page_state(zone, NR_INACTIVE));
-			ret += shrink_inactive_list(nr_to_scan, zone, sc);
+			ret += shrink_inactive_list(nr_to_scan, zone, sc, NULL);
 			if (ret >= nr_pages)
 				return ret;
 		}
@@ -1780,7 +1780,7 @@ static int __zone_reclaim(struct zone *z
 		priority = ZONE_RECLAIM_PRIORITY;
 		do {
 			note_zone_scanning_priority(zone, priority);
-			nr_reclaimed += shrink_zone(priority, zone, &sc);
+			nr_reclaimed += shrink_zone(priority, zone, &sc, NULL);
 			priority--;
 		} while (priority >= 0 && nr_reclaimed < nr_pages);
 	}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
