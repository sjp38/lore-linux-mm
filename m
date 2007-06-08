Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 96761122ED
	for <linux-mm@kvack.org>; Fri,  8 Jun 2007 22:07:03 +0200 (CEST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 06 of 16] reduce the probability of an OOM livelock
Message-Id: <fe82f6d082c859c64166.1181332984@v2.random>
In-Reply-To: <patchbomb.1181332978@v2.random>
Date: Fri, 08 Jun 2007 22:03:04 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1181332961 -7200
# Node ID fe82f6d082c859c641664990c6e14de8d16dcb5d
# Parent  2ebc46595ead0f1790c6ec1d0302dd60ffbb1978
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
@@ -1007,7 +1007,7 @@ unsigned long try_to_free_pages(struct z
 	int priority;
 	int ret = 0;
 	unsigned long total_scanned = 0;
-	unsigned long nr_reclaimed = 0;
+	unsigned long nr_reclaimed;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
 	int i;
@@ -1035,12 +1035,12 @@ unsigned long try_to_free_pages(struct z
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
@@ -1131,7 +1131,6 @@ static unsigned long balance_pgdat(pg_da
 
 loop_again:
 	total_scanned = 0;
-	nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
 	count_vm_event(PAGEOUTRUN);
 
@@ -1186,6 +1185,7 @@ loop_again:
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
