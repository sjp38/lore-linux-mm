From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:37:23 +0200
Message-Id: <20060712143723.16998.2147.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 2/39] mm: adjust blk_congestion_wait() logic
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

The new page reclaim implementations can require a lot more scanning
in order to find a suiteable page. This causes kswapd to constantly hit:

 	blk_congestion_wait(WRITE, HZ/10);

without there being any submitted IO.

Count the number of async pages submitted by pageout() and only wait
for congestion when the last priority level has submitted more than
half SWAP_CLUSTER_MAX pages for IO.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 mm/vmscan.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2006-07-12 16:11:58.000000000 +0200
@@ -61,6 +61,8 @@ struct scan_control {
 	 * In this context, it doesn't matter that we scan the
 	 * whole list at once. */
 	int swap_cluster_max;
+
+	unsigned long nr_writeout;	/* page against which writeout was started */
 };
 
 /*
@@ -407,6 +409,7 @@ static unsigned long shrink_page_list(st
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
 	unsigned long nr_reclaimed = 0;
+	int writeout = 0;
 
 	cond_resched();
 
@@ -488,8 +491,10 @@ static unsigned long shrink_page_list(st
 			case PAGE_ACTIVATE:
 				goto activate_locked;
 			case PAGE_SUCCESS:
-				if (PageWriteback(page) || PageDirty(page))
+				if (PageWriteback(page) || PageDirty(page)) {
+					writeout++;
 					goto keep;
+				}
 				/*
 				 * A synchronous write - probably a ramdisk.  Go
 				 * ahead and try to reclaim the page.
@@ -555,6 +560,7 @@ keep:
 	if (pagevec_count(&freed_pvec))
 		__pagevec_release_nonlru(&freed_pvec);
 	mod_page_state(pgactivate, pgactivate);
+	sc->nr_writeout += writeout;
 	return nr_reclaimed;
 }
 
@@ -1123,6 +1129,7 @@ scan:
 		 * pages behind kswapd's direction of progress, which would
 		 * cause too much scanning of the lower zones.
 		 */
+		sc.nr_writeout = 0;
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 			int nr_slab;
@@ -1170,7 +1177,7 @@ scan:
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
 		 * another pass across the zones.
 		 */
-		if (total_scanned && priority < DEF_PRIORITY - 2)
+		if (sc.nr_writeout > SWAP_CLUSTER_MAX/2)
 			blk_congestion_wait(WRITE, HZ/10);
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
