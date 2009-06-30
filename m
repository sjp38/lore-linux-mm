Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7EE5F6B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 16:47:03 -0400 (EDT)
Subject: [PATCH] hugetlb: use free_pool_huge_page() to return unused
	surplus pages fix
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Tue, 30 Jun 2009 16:48:02 -0400
Message-Id: <1246394882.25302.58.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

PATCH hugetlb: use free_pool_huge_page() to return unused surplus pages fix

Against: 25jun mmotm.

Fixes bug detected by libhugetlbfs test suite in:
hugetlb-use-free_pool_huge_page-to-return-unused-surplus-pages.patch

Can't just "continue" for node with no surplus pages when returning
unused surplus.  We need to advance to 'next node to free'.

With this fix, the "hugetlb balance free across nodes" series passes
the test suite.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/hugetlb.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

Index: linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c
===================================================================
--- linux-2.6.31-rc1-mmotm-090625-1549.orig/mm/hugetlb.c	2009-06-30 16:33:08.000000000 -0400
+++ linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c	2009-06-30 16:34:14.000000000 -0400
@@ -697,13 +697,11 @@ static int free_pool_huge_page(struct hs
 
 	do {
 		/*
-		 * If we're returning unused surplus pages, skip nodes
-		 * with no surplus.
+		 * If we're returning unused surplus pages, only examine
+		 * nodes with surplus pages.
 		 */
-		if (acct_surplus && !h->surplus_huge_pages_node[next_nid])
-			continue;
-
-		if (!list_empty(&h->hugepage_freelists[next_nid])) {
+		if ((!acct_surplus || h->surplus_huge_pages_node[next_nid]) &&
+		    !list_empty(&h->hugepage_freelists[next_nid])) {
 			struct page *page =
 				list_entry(h->hugepage_freelists[next_nid].next,
 					  struct page, lru);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
