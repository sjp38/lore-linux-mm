Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 497446B0044
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 13:59:24 -0500 (EST)
Date: Tue, 30 Dec 2008 18:59:19 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: stop kswapd's infinite loop at high order
	allocation
Message-ID: <20081230185919.GA17725@csn.ul.ie>
References: <20081230195006.1286.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20081230195006.1286.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, wassim dagash <wassim.dagash@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 30, 2008 at 07:55:47PM +0900, KOSAKI Motohiro wrote:
> 
> ok, wassim confirmed this patch works well.
> 
> 
> ==
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Subject: [PATCH] mm: kswapd stop infinite loop at high order allocation
> 
> Wassim Dagash reported following kswapd infinite loop problem.
> 
>   kswapd runs in some infinite loop trying to swap until order 10 of zone
>   highmem is OK, While zone higmem (as I understand) has nothing to do
>   with contiguous memory (cause there is no 1-1 mapping) which means
>   kswapd will continue to try to balance order 10 of zone highmem
>   forever (or until someone release a very large chunk of highmem).
> 
> He proposed remove contenious checking on highmem at all.
> However hugepage on highmem need contenious highmem page.
> 

I'm lacking the original problem report, but contiguous order-10 pages are
indeed required for hugepages in highmem and reclaiming for them should not
be totally disabled at any point. While no 1-1 mapping exists for the kernel,
contiguity is still required.

kswapd gets a sc.order when it is known there is a process trying to get
high-order pages so it can reclaim at that order in an attempt to prevent
future direct reclaim at a high-order. Your patch does not appear to depend on
GFP_KERNEL at all so I found the comment misleading. Furthermore, asking it to
loop again at order-0 means it may scan and reclaim more memory unnecessarily
seeing as all_zones_ok was calculated based on a high-order value, not order-0.

While constantly looping trying to balance for high-orders is indeed bad,
I'm unconvinced this is the correct change. As we have already gone through
a priorities and scanned everything at the high-order, would it not make
more sense to do just give up with something like the following?

       /*
        * If zones are still not balanced, loop again and continue attempting
        * to rebalance the system. For high-order allocations, fragmentation
        * can prevent the zones being rebalanced no matter how hard kswapd
        * works, particularly on systems with little or no swap. For costly
        * orders, just give up and assume interested processes will either
        * direct reclaim or wake up kswapd as necessary.
        */
        if (!all_zones_ok && sc.order <= PAGE_ALLOC_COSTLY_ORDER) {
                cond_resched();

                try_to_freeze();

                goto loop_again;
        }

I used PAGE_ALLOC_COSTLY_ORDER instead of sc.order == 0 because we are
expected to support allocations up to that order in a fairly reliable fashion.

> To add infinite loop stopper is simple and good.
> 
> 
> 
> Reported-by: wassim dagash <wassim.dagash@gmail.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

For the moment

NAKed-by: Mel Gorman <mel@csn.ul.ie>

How about the following (compile-tested-only) patch?

=============
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] mm: stop kswapd's infinite loop at high order allocation

  kswapd runs in some infinite loop trying to swap until order 10 of zone
  highmem is OK.... kswapd will continue to try to balance order 10 of zone
  highmem forever (or until someone release a very large chunk of highmem).

For costly high-order allocations, the system may never be balanced due to
fragmentation but kswapd should not infinitely loop as a result. The
following patch lets kswapd stop reclaiming in the event it cannot
balance zones and the order is high-order.

Reported-by: wassim dagash <wassim.dagash@gmail.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 62e7f62..03ed9a0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1867,7 +1867,16 @@ out:
 
 		zone->prev_priority = temp_priority[i];
 	}
-	if (!all_zones_ok) {
+
+	/*
+	 * If zones are still not balanced, loop again and continue attempting
+	 * to rebalance the system. For high-order allocations, fragmentation
+	 * can prevent the zones being rebalanced no matter how hard kswapd
+	 * works, particularly on systems with little or no swap. For costly
+	 * orders, just give up and assume interested processes will either
+	 * direct reclaim or wake up kswapd as necessary.
+	 */
+	if (!all_zones_ok && sc.order <= PAGE_ALLOC_COSTLY_ORDER) {
 		cond_resched();
 
 		try_to_freeze();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
