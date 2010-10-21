Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 68FFF5F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 13:59:22 -0400 (EDT)
Date: Thu, 21 Oct 2010 12:59:17 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
Message-ID: <alpine.DEB.2.00.1010211255570.24115@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

Slab objects (and other caches) are always allocated from ZONE_NORMAL.
Not from any other zone. Calling the shrinkers for those zones may put
unnecessary pressure on the caches.

Check the zone if we are in a reclaim situation where we are targeting
a specific node. Can occur f.e. in kswapd and in zone reclaim.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/vmscan.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2010-10-21 12:26:17.000000000 -0500
+++ linux-2.6/mm/vmscan.c	2010-10-21 12:33:56.000000000 -0500
@@ -2218,15 +2218,21 @@ loop_again:
 			if (!zone_watermark_ok(zone, order,
 					8*high_wmark_pages(zone), end_zone, 0))
 				shrink_zone(priority, zone, &sc);
-			reclaim_state->reclaimed_slab = 0;
-			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
-						lru_pages);
-			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
-			total_scanned += sc.nr_scanned;
+
+			if (zone_idx(zone) == ZONE_NORMAL) {
+				reclaim_state->reclaimed_slab = 0;
+				nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
+							lru_pages);
+				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
+				total_scanned += sc.nr_scanned;
+			} else
+				nr_slab = 0;
+
 			if (zone->all_unreclaimable)
 				continue;
 			if (nr_slab == 0 && !zone_reclaimable(zone))
 				zone->all_unreclaimable = 1;
+
 			/*
 			 * If we've done a decent amount of scanning and
 			 * the reclaim ratio is low, start doing writepage
@@ -2697,7 +2703,8 @@ static int __zone_reclaim(struct zone *z
 	}

 	nr_slab_pages0 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
-	if (nr_slab_pages0 > zone->min_slab_pages) {
+	if (nr_slab_pages0 > zone->min_slab_pages &&
+					zone_idx(zone) == ZONE_NORMAL) {
 		/*
 		 * shrink_slab() does not currently allow us to determine how
 		 * many pages were freed in this zone. So we take the current

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
