Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2575C66002E
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:37 -0400 (EDT)
Message-Id: <20100804024537.051343033@linux.com>
Date: Tue, 03 Aug 2010 21:45:37 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 23/23] vmscan: Tie slub object expiration into page reclaim
References: <20100804024514.139976032@linux.com>
Content-Disposition: inline; filename=unified_vmscan
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

We already do slab reclaim during page reclaim. Add a call to
object expiration in slub whenever shrink_slab() is called.
If the reclaim is zone specific then use the node of the zone
to restrict reclaim in slub.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/vmscan.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2010-07-30 18:37:47.638837043 -0500
+++ linux-2.6/mm/vmscan.c	2010-07-30 18:57:44.867515416 -0500
@@ -1826,6 +1826,7 @@
 				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 				reclaim_state->reclaimed_slab = 0;
 			}
+			kmem_cache_expire_all(NUMA_NO_NODE);
 		}
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
@@ -2133,6 +2134,7 @@
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);
+			kmem_cache_expire_all(nid);
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 			if (zone->all_unreclaimable)
@@ -2640,6 +2642,8 @@
 		 */
 		sc.nr_reclaimed += slab_reclaimable -
 			zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+
+		kmem_cache_expire_all(zone_to_nid(zone));
 	}
 
 	p->reclaim_state = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
