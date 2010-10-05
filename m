Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E89746B0095
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:58:23 -0400 (EDT)
Message-Id: <20101005185819.367221853@linux.com>
Date: Tue, 05 Oct 2010 13:57:38 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [UnifiedV4 13/16] vmscan: Tie slub object expiration into page reclaim
References: <20101005185725.088808842@linux.com>
Content-Disposition: inline; filename=unified_vmscan
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
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
--- linux-2.6.orig/mm/vmscan.c	2010-10-04 08:14:25.000000000 -0500
+++ linux-2.6/mm/vmscan.c	2010-10-04 08:26:47.000000000 -0500
@@ -1917,6 +1917,7 @@ static unsigned long do_try_to_free_page
 				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 				reclaim_state->reclaimed_slab = 0;
 			}
+			kmem_cache_expire_all(NUMA_NO_NODE);
 		}
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
@@ -2221,6 +2222,7 @@ loop_again:
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);
+			kmem_cache_expire_all(zone_to_nid(zone));
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 			if (zone->all_unreclaimable)
@@ -2722,6 +2724,8 @@ static int __zone_reclaim(struct zone *z
 				break;
 		}
 
+		kmem_cache_expire_all(zone_to_nid(zone));
+
 		/*
 		 * Update nr_reclaimed by the number of slab pages we
 		 * reclaimed from this zone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
