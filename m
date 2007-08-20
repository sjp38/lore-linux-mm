Message-Id: <20070820215317.202810753@sgi.com>
References: <20070820215040.937296148@sgi.com>
Date: Mon, 20 Aug 2007 14:50:46 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 6/7] kswapd: Do laundry after reclaim
Content-Disposition: inline; filename=kswapd
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Collect dirty pages and perform writeout when everything else is done.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/vmscan.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-08-19 23:53:43.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-08-19 23:53:47.000000000 -0700
@@ -1273,6 +1273,7 @@ static unsigned long balance_pgdat(pg_da
 	 * this zone was successfully refilled to free_pages == pages_high.
 	 */
 	int temp_priority[MAX_NR_ZONES];
+	LIST_HEAD(laundry);
 
 loop_again:
 	total_scanned = 0;
@@ -1347,7 +1348,7 @@ loop_again:
 			temp_priority[i] = priority;
 			sc.nr_scanned = 0;
 			note_zone_scanning_priority(zone, priority);
-			nr_reclaimed += shrink_zone(priority, zone, &sc, NULL);
+			nr_reclaimed += shrink_zone(priority, zone, &sc, &laundry);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);
@@ -1374,6 +1375,7 @@ loop_again:
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
 		 * another pass across the zones.
 		 */
+		throttle_vm_writeout(GFP_KERNEL);
 		if (total_scanned && priority < DEF_PRIORITY - 2)
 			congestion_wait(WRITE, HZ/10);
 
@@ -1404,7 +1406,8 @@ out:
 
 		goto loop_again;
 	}
-
+	nr_reclaimed += shrink_page_list(&laundry, &sc, NULL);
+	release_lru_pages(&laundry);
 	return nr_reclaimed;
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
