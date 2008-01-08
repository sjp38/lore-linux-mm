Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 05 of 13] reduce the probability of an OOM livelock
Message-Id: <351a3906181f5c0fe013.1199778636@v2.random>
In-Reply-To: <patchbomb.1199778631@v2.random>
Date: Tue, 08 Jan 2008 08:50:36 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199470021 -3600
# Node ID 351a3906181f5c0fe0137b6f066f725bd65673ba
# Parent  e08fdb8dad51268d7a786625fc54c65f277f736b
reduce the probability of an OOM livelock

There's no need to loop way too many times over the lrus in order to
declare defeat and decide to kill a task. The more loops we do the more
likely there we'll run in a livelock with a page bouncing back and
forth between tasks. The maximum number of entries to check in a loop
that returns less than swap-cluster-max pages freed, should be the size
of the list (or at most twice the size of the list if you want to be
really paranoid about the PG_referenced bit).

Our objective there is to know reliably when it's time that we kill a
task, tring to free a few more pages at that already ciritical point is
worthless.

This seems to have the effect of reducing the "hang" time during oom
killing.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1211,7 +1211,6 @@ unsigned long try_to_free_pages(struct z
 	int priority;
 	int ret = 0;
 	unsigned long total_scanned = 0;
-	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
 	int i;
@@ -1237,15 +1236,17 @@ unsigned long try_to_free_pages(struct z
 	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
+		unsigned long nr_reclaimed;
+
 		sc.nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
-		nr_reclaimed += shrink_zones(priority, zones, &sc);
+		nr_reclaimed = shrink_zones(priority, zones, &sc);
+		if (reclaim_state)
+			reclaim_state->reclaimed_slab = 0;
 		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages);
-		if (reclaim_state) {
+		if (reclaim_state)
 			nr_reclaimed += reclaim_state->reclaimed_slab;
-			reclaim_state->reclaimed_slab = 0;
-		}
 		total_scanned += sc.nr_scanned;
 		if (nr_reclaimed >= sc.swap_cluster_max) {
 			ret = 1;
@@ -1320,7 +1321,6 @@ static unsigned long balance_pgdat(pg_da
 	int priority;
 	int i;
 	unsigned long total_scanned;
-	unsigned long nr_reclaimed;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
@@ -1337,7 +1337,6 @@ static unsigned long balance_pgdat(pg_da
 
 loop_again:
 	total_scanned = 0;
-	nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
 	count_vm_event(PAGEOUTRUN);
 
@@ -1347,6 +1346,7 @@ loop_again:
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 		unsigned long lru_pages = 0;
+		unsigned long nr_reclaimed;
 
 		/* The swap token gets in the way of swapout... */
 		if (!priority)
@@ -1393,6 +1393,7 @@ loop_again:
 		 * pages behind kswapd's direction of progress, which would
 		 * cause too much scanning of the lower zones.
 		 */
+		nr_reclaimed = 0;
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 			int nr_slab;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
