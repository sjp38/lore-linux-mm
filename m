Date: Tue, 29 Aug 2006 11:11:34 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: zone reclaim with slab avoid unecessary off node allocations.
Message-ID: <Pine.LNX.4.64.0608291109260.19897@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Minor performance fix.

If we reclaimed enough slab pages from a zone then we can avoid going off
node with the current allocation. Take care of updating nr_reclaimed
when reclaiming from the slab.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc4-mm3/mm/vmscan.c
===================================================================
--- linux-2.6.18-rc4-mm3.orig/mm/vmscan.c	2006-08-26 16:38:04.915153612 -0700
+++ linux-2.6.18-rc4-mm3/mm/vmscan.c	2006-08-27 15:48:25.948204824 -0700
@@ -1574,6 +1574,7 @@ static int __zone_reclaim(struct zone *z
 		.gfp_mask = gfp_mask,
 		.swappiness = vm_swappiness,
 	};
+	unsigned long slab_reclaimable;
 
 	disable_swap_token();
 	cond_resched();
@@ -1600,7 +1601,8 @@ static int __zone_reclaim(struct zone *z
 		} while (priority >= 0 && nr_reclaimed < nr_pages);
 	}
 
-	if (zone_page_state(zone, NR_SLAB_RECLAIMABLE) > zone->min_slab_pages) {
+	slab_reclaimable = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+	if (slab_reclaimable > zone->min_slab_pages) {
 		/*
 		 * shrink_slab() does not currently allow us to determine how
 		 * many pages were freed in this zone. So we take the current
@@ -1611,12 +1613,17 @@ static int __zone_reclaim(struct zone *z
 		 * Note that shrink_slab will free memory on all zones and may
 		 * take a long time.
 		 */
-		unsigned long limit = zone_page_state(zone,
-				NR_SLAB_RECLAIMABLE) - nr_pages;
-
 		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
-			zone_page_state(zone, NR_SLAB_RECLAIMABLE) > limit)
+			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
+				slab_reclaimable - nr_pages)
 			;
+
+		/*
+		 * Update nr_reclaimed by the number of slab pages we
+		 * reclaimed from this zone.
+		 */
+		nr_reclaimed += slab_reclaimable -
+			zone_page_state(zone, NR_SLAB_RECLAIMABLE);
 	}
 
 	p->reclaim_state = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
