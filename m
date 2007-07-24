Date: Tue, 24 Jul 2007 16:35:31 +0100
Subject: [PATCH] Do not trigger OOM-killer for high-order allocation failures
Message-ID: <20070724153531.GA30585@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

out_of_memory() may be called when an allocation is failing and the direct
reclaim is not making any progress. This does not take into account the
requested order of the allocation. If the request if for an order larger
than PAGE_ALLOC_COSTLY_ORDER, it is reasonable to fail the allocation
because the kernel makes no guarantees about those allocations succeeding.

This false OOM situation can occur if a user is trying to grow the hugepage
pool in a script like;

#!/bin/bash
REQUIRED=$1
echo 1 > /proc/sys/vm/hugepages_treat_as_movable
echo $REQUIRED > /proc/sys/vm/nr_hugepages
ACTUAL=`cat /proc/sys/vm/nr_hugepages`
while [ $REQUIRED -ne $ACTUAL ]; do
	echo Huge page pool at $ACTUAL growing to $REQUIRED
	echo $REQUIRED > /proc/sys/vm/nr_hugepages
	ACTUAL=`cat /proc/sys/vm/nr_hugepages`
	sleep 1
done

This is a reasonable scenario when ZONE_MOVABLE is in use but triggers OOM
easily on 2.6.23-rc1. This patch will fail an allocation for an order above
PAGE_ALLOC_COSTLY_ORDER instead of killing processes and retrying.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

---
 page_alloc.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 40954fb..da57173 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1350,6 +1350,10 @@ nofail_alloc:
 		if (page)
 			goto got_pg;
 
+		/* The OOM killer will not help higher order allocs so fail */
+		if (order > PAGE_ALLOC_COSTLY_ORDER)
+			goto nopage;
+
 		out_of_memory(zonelist, gfp_mask, order);
 		goto restart;
 	}
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
