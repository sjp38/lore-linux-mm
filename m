Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 65A4E6B00AB
	for <linux-mm@kvack.org>; Thu,  1 Jan 2009 09:52:19 -0500 (EST)
Date: Thu, 1 Jan 2009 23:52:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm: stop kswapd's infinite loop at high order allocation take2
In-Reply-To: <20081231215934.1296.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081231115332.GB20534@csn.ul.ie> <20081231215934.1296.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20090101021240.A057.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, wassim dagash <wassim.dagash@gmail.com>
List-ID: <linux-mm.kvack.org>


> >                 /*
> >                  * Fragmentation may mean that the system cannot be
> >                  * rebalanced for high-order allocations in all zones.
> >                  * At this point, if nr_reclaimed < SWAP_CLUSTER_MAX,
> >                  * it means the zones have been fully scanned and are still
> >                  * not balanced. For high-order allocations, there is 
> >                  * little point trying all over again as kswapd may
> >                  * infinite loop.
> >                  *
> >                  * Instead, recheck all watermarks at order-0 as they
> >                  * are the most important. If watermarks are ok, kswapd will go
> >                  * back to sleep. High-order users can still direct reclaim
> >                  * if they wish.
> >                  */
> > 
> > ?
> 
> Excellent. I strongly like this and I hope merge it to my patch.
> I'll resend new patch.

Done.



==
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm: kswapd stop infinite loop at high order allocation

Wassim Dagash reported following kswapd infinite loop problem.

  kswapd runs in some infinite loop trying to swap until order 10 of zone
  highmem is OK.... kswapd will continue to try to balance order 10 of zone
  highmem forever (or until someone release a very large chunk of highmem).

For non order-0 allocations, the system may never be balanced due to
fragmentation but kswapd should not infinitely loop as a result. 

Instead, recheck all watermarks at order-0 as they are the most important. 
If watermarks are ok, kswapd will go back to sleep. 


Reported-by: wassim dagash <wassim.dagash@gmail.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>,
---
 mm/vmscan.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c	2008-12-25 08:26:37.000000000 +0900
+++ b/mm/vmscan.c	2009-01-01 01:56:02.000000000 +0900
@@ -1872,6 +1872,23 @@ out:
 
 		try_to_freeze();
 
+		/*
+		 * Fragmentation may mean that the system cannot be
+		 * rebalanced for high-order allocations in all zones.
+		 * At this point, if nr_reclaimed < SWAP_CLUSTER_MAX,
+		 * it means the zones have been fully scanned and are still
+		 * not balanced. For high-order allocations, there is
+		 * little point trying all over again as kswapd may
+		 * infinite loop.
+		 *
+		 * Instead, recheck all watermarks at order-0 as they
+		 * are the most important. If watermarks are ok, kswapd will go
+		 * back to sleep. High-order users can still direct reclaim
+		 * if they wish.
+		 */
+		if (nr_reclaimed < SWAP_CLUSTER_MAX)
+			order = sc.order = 0;
+
 		goto loop_again;
 	}
 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
