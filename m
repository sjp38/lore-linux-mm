Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 58B4F6B0082
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:31:13 -0400 (EDT)
Subject: [PATCH] hugetlb:  restore interleaving of bootmem huge pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Thu, 16 Jul 2009 10:31:02 -0400
Message-Id: <1247754662.4382.51.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>, linux-numa <linux-numa@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

PATCH restore interleaving of bootmem huge pages

Against: 2.6.31-rc1-mmotm-090625-1549
atop the "hugetlb-balance-freeing-of-huge-pages-across-node" series

I noticed that alloc_bootmem_huge_page() will only advance to the
next node on failure to allocate a huge page, potentially filling 
nodes with huge-pages.  I asked about this on linux-mm and linux-numa,
cc'ing the usual huge page suspects.

Mel Gorman responded:

	I strongly suspect that the same node being used until allocation
	failure instead of round-robin is an oversight and not deliberate
	at all. It appears to be a side-effect of a fix made way back in
	commit 63b4613c3f0d4b724ba259dc6c201bb68b884e1a ["hugetlb: fix
	hugepage allocation with memoryless nodes"]. Prior to that patch
	it looked like allocations would always round-robin even when
	allocation was successful.

This patch--factored out of my "hugetlb mempolicy" series--moves the
advance of the hstate next node from which to allocate up before the
test for success of the attempted allocation.

Note that alloc_bootmem_huge_page() is only used for order > MAX_ORDER
huge pages.

I'll post a separate patch for mainline/stable, as the above mentioned
"balance freeing" series renamed the next node to alloc function.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/hugetlb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c
===================================================================
--- linux-2.6.31-rc1-mmotm-090625-1549.orig/mm/hugetlb.c	2009-07-13 09:05:22.000000000 -0400
+++ linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c	2009-07-13 09:06:22.000000000 -0400
@@ -1030,6 +1030,7 @@ int __weak alloc_bootmem_huge_page(struc
 				NODE_DATA(h->next_nid_to_alloc),
 				huge_page_size(h), huge_page_size(h), 0);
 
+		hstate_next_node_to_alloc(h);
 		if (addr) {
 			/*
 			 * Use the beginning of the huge page to store the
@@ -1039,7 +1040,6 @@ int __weak alloc_bootmem_huge_page(struc
 			m = addr;
 			goto found;
 		}
-		hstate_next_node_to_alloc(h);
 		nr_nodes--;
 	}
 	return 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
