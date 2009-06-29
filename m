Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CA19B6B005C
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 17:51:07 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 29 Jun 2009 17:52:42 -0400
Message-Id: <20090629215242.20038.63689.sendpatchset@lts-notebook>
In-Reply-To: <20090629215226.20038.42028.sendpatchset@lts-notebook>
References: <20090629215226.20038.42028.sendpatchset@lts-notebook>
Subject: [PATCH 2/3] Use free_pool_huge_page() to return unused surplus pages
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH 2/3 - Use free_pool_huge_page() for return_unused_surplus_pages()

Against:  25jun09 mmotm

Use the [modified] free_pool_huge_page() function to return unused
surplus pages.  This will help keep huge pages balanced across nodes
between freeing of unused surplus pages and freeing of persistent huge
pages [from set_max_huge_pages] by using the same node id "cursor". It
also eliminates some code duplication.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/hugetlb.c |   57 +++++++++++++++++++++++++--------------------------------
 1 file changed, 25 insertions(+), 32 deletions(-)

Index: linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c
===================================================================
--- linux-2.6.31-rc1-mmotm-090625-1549.orig/mm/hugetlb.c	2009-06-29 15:53:55.000000000 -0400
+++ linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c	2009-06-29 16:52:45.000000000 -0400
@@ -686,7 +686,7 @@ static int hstate_next_node_to_free(stru
  * balanced over allowed nodes.
  * Called with hugetlb_lock locked.
  */
-static int free_pool_huge_page(struct hstate *h)
+static int free_pool_huge_page(struct hstate *h, bool acct_surplus)
 {
 	int start_nid;
 	int next_nid;
@@ -696,6 +696,13 @@ static int free_pool_huge_page(struct hs
 	next_nid = start_nid;
 
 	do {
+		/*
+		 * If we're returning unused surplus pages, skip nodes
+		 * with no surplus.
+		 */
+		if (acct_surplus && !h->surplus_huge_pages_node[next_nid])
+			continue;
+
 		if (!list_empty(&h->hugepage_freelists[next_nid])) {
 			struct page *page =
 				list_entry(h->hugepage_freelists[next_nid].next,
@@ -703,6 +710,10 @@ static int free_pool_huge_page(struct hs
 			list_del(&page->lru);
 			h->free_huge_pages--;
 			h->free_huge_pages_node[next_nid]--;
+			if (acct_surplus) {
+				h->surplus_huge_pages--;
+				h->surplus_huge_pages_node[next_nid]--;
+			}
 			update_and_free_page(h, page);
 			ret = 1;
 		}
@@ -883,22 +894,13 @@ free:
  * When releasing a hugetlb pool reservation, any surplus pages that were
  * allocated to satisfy the reservation must be explicitly freed if they were
  * never used.
+ * Called with hugetlb_lock held.
  */
 static void return_unused_surplus_pages(struct hstate *h,
 					unsigned long unused_resv_pages)
 {
-	static int nid = -1;
-	struct page *page;
 	unsigned long nr_pages;
 
-	/*
-	 * We want to release as many surplus pages as possible, spread
-	 * evenly across all nodes. Iterate across all nodes until we
-	 * can no longer free unreserved surplus pages. This occurs when
-	 * the nodes with surplus pages have no free pages.
-	 */
-	unsigned long remaining_iterations = nr_online_nodes;
-
 	/* Uncommit the reservation */
 	h->resv_huge_pages -= unused_resv_pages;
 
@@ -908,26 +910,17 @@ static void return_unused_surplus_pages(
 
 	nr_pages = min(unused_resv_pages, h->surplus_huge_pages);
 
-	while (remaining_iterations-- && nr_pages) {
-		nid = next_node(nid, node_online_map);
-		if (nid == MAX_NUMNODES)
-			nid = first_node(node_online_map);
-
-		if (!h->surplus_huge_pages_node[nid])
-			continue;
-
-		if (!list_empty(&h->hugepage_freelists[nid])) {
-			page = list_entry(h->hugepage_freelists[nid].next,
-					  struct page, lru);
-			list_del(&page->lru);
-			update_and_free_page(h, page);
-			h->free_huge_pages--;
-			h->free_huge_pages_node[nid]--;
-			h->surplus_huge_pages--;
-			h->surplus_huge_pages_node[nid]--;
-			nr_pages--;
-			remaining_iterations = nr_online_nodes;
-		}
+	/*
+	 * We want to release as many surplus pages as possible, spread
+	 * evenly across all nodes. Iterate across all nodes until we
+	 * can no longer free unreserved surplus pages. This occurs when
+	 * the nodes with surplus pages have no free pages.
+	 * free_pool_huge_page() will balance the the frees across the
+	 * on-line nodes for us and will handle the hstate accounting.
+	 */
+	while (nr_pages--) {
+		if (!free_pool_huge_page(h, 1))
+			break;
 	}
 }
 
@@ -1267,7 +1260,7 @@ static unsigned long set_max_huge_pages(
 	min_count = max(count, min_count);
 	try_to_free_low(h, min_count);
 	while (min_count < persistent_huge_pages(h)) {
-		if (!free_pool_huge_page(h))
+		if (!free_pool_huge_page(h, 0))
 			break;
 	}
 	while (count < persistent_huge_pages(h)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
