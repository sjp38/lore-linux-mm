Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E47676B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 11:46:59 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 30 Jun 2009 11:47:24 -0400
Message-Id: <20090630154724.1583.55926.sendpatchset@lts-notebook>
In-Reply-To: <20090630154716.1583.25274.sendpatchset@lts-notebook>
References: <20090630154716.1583.25274.sendpatchset@lts-notebook>
Subject: [RFC 1/3] hugetlb:  add nodemask arg to huge page alloc, free and surplus adjust fcns
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[RFC 1/3] hugetlb:  add nodemask arg to huge page alloc, free and surplus adjust fcns

Against: 25jun09 mmotm atop the "hugetlb: balance freeing..." series

In preparation for constraining huge page allocation and freeing by the
controlling task's numa mempolicy, add a "nodes_allowed" nodemask pointer
to the allocate, free and surplus adjustment functions.  For now, pass
NULL to indicate default behavior--i.e., use node_online_map.  A
subsqeuent patch will derive a non-default mask from the controlling 
task's numa mempolicy.

Note the "cleanup" in alloc_bootmem_huge_page(): always advance next nid,
even if allocation succeeds.  I believe that this is correct behavior,
and I'll replace it in the next patch which assumes this behavior.
However, perhaps the current code is correct:  we only want to advance
bootmem huge page allocation to the next node when we've exhausted all
huge pages on the current hstate "next_node_to_alloc".  Any who understands
the rationale for this:  please advise.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/hugetlb.c |   51 +++++++++++++++++++++++++++++++--------------------
 1 file changed, 31 insertions(+), 20 deletions(-)

Index: linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c
===================================================================
--- linux-2.6.31-rc1-mmotm-090625-1549.orig/mm/hugetlb.c	2009-06-29 17:35:11.000000000 -0400
+++ linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c	2009-06-29 23:01:01.000000000 -0400
@@ -631,17 +631,22 @@ static struct page *alloc_fresh_huge_pag
  * if we just successfully allocated a hugepage so that
  * the next caller gets hugepages on the next node.
  */
-static int hstate_next_node_to_alloc(struct hstate *h)
+static int hstate_next_node_to_alloc(struct hstate *h,
+					nodemask_t *nodes_allowed)
 {
 	int next_nid;
-	next_nid = next_node(h->next_nid_to_alloc, node_online_map);
+
+	if (!nodes_allowed)
+		nodes_allowed = &node_online_map;
+
+	next_nid = next_node(h->next_nid_to_alloc, *nodes_allowed);
 	if (next_nid == MAX_NUMNODES)
-		next_nid = first_node(node_online_map);
+		next_nid = first_node(*nodes_allowed);
 	h->next_nid_to_alloc = next_nid;
 	return next_nid;
 }
 
-static int alloc_fresh_huge_page(struct hstate *h)
+static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
 {
 	struct page *page;
 	int start_nid;
@@ -655,7 +660,7 @@ static int alloc_fresh_huge_page(struct 
 		page = alloc_fresh_huge_page_node(h, next_nid);
 		if (page)
 			ret = 1;
-		next_nid = hstate_next_node_to_alloc(h);
+		next_nid = hstate_next_node_to_alloc(h, nodes_allowed);
 	} while (!page && next_nid != start_nid);
 
 	if (ret)
@@ -670,12 +675,16 @@ static int alloc_fresh_huge_page(struct 
  * helper for free_pool_huge_page() - find next node
  * from which to free a huge page
  */
-static int hstate_next_node_to_free(struct hstate *h)
+static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
 {
 	int next_nid;
-	next_nid = next_node(h->next_nid_to_free, node_online_map);
+
+	if (!nodes_allowed)
+		nodes_allowed = &node_online_map;
+
+	next_nid = next_node(h->next_nid_to_free, *nodes_allowed);
 	if (next_nid == MAX_NUMNODES)
-		next_nid = first_node(node_online_map);
+		next_nid = first_node(*nodes_allowed);
 	h->next_nid_to_free = next_nid;
 	return next_nid;
 }
@@ -686,7 +695,8 @@ static int hstate_next_node_to_free(stru
  * balanced over allowed nodes.
  * Called with hugetlb_lock locked.
  */
-static int free_pool_huge_page(struct hstate *h, bool acct_surplus)
+static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
+							 bool acct_surplus)
 {
 	int start_nid;
 	int next_nid;
@@ -717,7 +727,7 @@ static int free_pool_huge_page(struct hs
 			update_and_free_page(h, page);
 			ret = 1;
 		}
-		next_nid = hstate_next_node_to_free(h);
+ 		next_nid = hstate_next_node_to_free(h, nodes_allowed);
 	} while (!ret && next_nid != start_nid);
 
 	return ret;
@@ -919,7 +929,7 @@ static void return_unused_surplus_pages(
 	 * on-line nodes for us and will handle the hstate accounting.
 	 */
 	while (nr_pages--) {
-		if (!free_pool_huge_page(h, 1))
+		if (!free_pool_huge_page(h, NULL, 1))
 			break;
 	}
 }
@@ -1032,6 +1042,7 @@ int __weak alloc_bootmem_huge_page(struc
 				NODE_DATA(h->next_nid_to_alloc),
 				huge_page_size(h), huge_page_size(h), 0);
 
+		hstate_next_node_to_alloc(h, NULL); /* always advance nid */
 		if (addr) {
 			/*
 			 * Use the beginning of the huge page to store the
@@ -1041,7 +1052,6 @@ int __weak alloc_bootmem_huge_page(struc
 			m = addr;
 			goto found;
 		}
-		hstate_next_node_to_alloc(h);
 		nr_nodes--;
 	}
 	return 0;
@@ -1085,7 +1095,7 @@ static void __init hugetlb_hstate_alloc_
 		if (h->order >= MAX_ORDER) {
 			if (!alloc_bootmem_huge_page(h))
 				break;
-		} else if (!alloc_fresh_huge_page(h))
+		} else if (!alloc_fresh_huge_page(h, NULL))
 			break;
 	}
 	h->max_huge_pages = i;
@@ -1160,7 +1170,8 @@ static inline void try_to_free_low(struc
  * balanced by operating on them in a round-robin fashion.
  * Returns 1 if an adjustment was made.
  */
-static int adjust_pool_surplus(struct hstate *h, int delta)
+static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
+				int delta)
 {
 	int start_nid, next_nid;
 	int ret = 0;
@@ -1176,7 +1187,7 @@ static int adjust_pool_surplus(struct hs
 	do {
 		int nid = next_nid;
 		if (delta < 0)  {
-			next_nid = hstate_next_node_to_alloc(h);
+			next_nid = hstate_next_node_to_alloc(h, nodes_allowed);
 			/*
 			 * To shrink on this node, there must be a surplus page
 			 */
@@ -1184,7 +1195,7 @@ static int adjust_pool_surplus(struct hs
 				continue;
 		}
 		if (delta > 0) {
-			next_nid = hstate_next_node_to_free(h);
+			next_nid = hstate_next_node_to_free(h, nodes_allowed);
 			/*
 			 * Surplus cannot exceed the total number of pages
 			 */
@@ -1223,7 +1234,7 @@ static unsigned long set_max_huge_pages(
 	 */
 	spin_lock(&hugetlb_lock);
 	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
-		if (!adjust_pool_surplus(h, -1))
+		if (!adjust_pool_surplus(h, NULL, -1))
 			break;
 	}
 
@@ -1234,7 +1245,7 @@ static unsigned long set_max_huge_pages(
 		 * and reducing the surplus.
 		 */
 		spin_unlock(&hugetlb_lock);
-		ret = alloc_fresh_huge_page(h);
+		ret = alloc_fresh_huge_page(h, NULL);
 		spin_lock(&hugetlb_lock);
 		if (!ret)
 			goto out;
@@ -1260,11 +1271,11 @@ static unsigned long set_max_huge_pages(
 	min_count = max(count, min_count);
 	try_to_free_low(h, min_count);
 	while (min_count < persistent_huge_pages(h)) {
-		if (!free_pool_huge_page(h, 0))
+		if (!free_pool_huge_page(h, NULL, 0))
 			break;
 	}
 	while (count < persistent_huge_pages(h)) {
-		if (!adjust_pool_surplus(h, 1))
+		if (!adjust_pool_surplus(h, NULL, 1))
 			break;
 	}
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
