From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20051011151251.16178.24064.sendpatchset@skynet.csn.ul.ie>
In-Reply-To: <20051011151221.16178.67130.sendpatchset@skynet.csn.ul.ie>
References: <20051011151221.16178.67130.sendpatchset@skynet.csn.ul.ie>
Subject: [PATCH 6/8] Fragmentation Avoidance V17: 006_largealloc_tryharder
Date: Tue, 11 Oct 2005 16:12:52 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: jschopp@austin.ibm.com, Mel Gorman <mel@csn.ul.ie>, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Fragmentation avoidance patches increase our chances of satisfying high
order allocations.  So this patch takes more than one iteration at trying
to fulfill those allocations because, unlike before, the extra iterations
are often useful.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Mike Kravetz <kravetz@us.ibm.com>
Signed-off-by: Joel Schopp <jschopp@austin.ibm.com>
diff -rup -X /usr/src/patchset-0.5/bin//dontdiff linux-2.6.14-rc3-005_fallback/mm/page_alloc.c linux-2.6.14-rc3-006_largealloc_tryharder/mm/page_alloc.c
--- linux-2.6.14-rc3-005_fallback/mm/page_alloc.c	2005-10-11 12:09:27.000000000 +0100
+++ linux-2.6.14-rc3-006_largealloc_tryharder/mm/page_alloc.c	2005-10-11 12:11:31.000000000 +0100
@@ -1055,6 +1055,7 @@ __alloc_pages(unsigned int __nocast gfp_
 	int do_retry;
 	int can_try_harder;
 	int did_some_progress;
+	int highorder_retry = 3;
 
 	might_sleep_if(wait);
 
@@ -1203,8 +1204,19 @@ rebalance:
 				goto got_pg;
 		}
 
-		out_of_memory(gfp_mask, order);
+		if (order < MAX_ORDER / 2)
+			out_of_memory(gfp_mask, order);
+		
+		/*
+		 * Due to low fragmentation efforts, we try a little
+		 * harder to satisfy high order allocations and only
+		 * go OOM for low-order allocations
+		 */
+		if (order >= MAX_ORDER/2 && --highorder_retry > 0)
+				goto rebalance;
+
 		goto restart;
+
 	}
 
 	/*
@@ -1220,6 +1232,8 @@ rebalance:
 			do_retry = 1;
 		if (gfp_mask & __GFP_NOFAIL)
 			do_retry = 1;
+		if (order >= MAX_ORDER/2 && --highorder_retry > 0)
+			do_retry = 1;
 	}
 	if (do_retry) {
 		blk_congestion_wait(WRITE, HZ/50);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
