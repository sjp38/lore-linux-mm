Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AE667600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 12:12:14 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 01 Oct 2009 12:57:34 -0400
Message-Id: <20091001165734.32248.45839.sendpatchset@localhost.localdomain>
In-Reply-To: <20091001165721.32248.14861.sendpatchset@localhost.localdomain>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain>
Subject: [PATCH 2/10] hugetlb:  add nodemask arg to huge page alloc, free and surplus adjust fcns
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, clameter@sgi.com, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 2/10] hugetlb:  add nodemask arg to huge page alloc, free and surplus adjust fcns

Against:  2.6.31-mmotm-090925-1435

V3: + moved this patch to after the "rework" of hstate_next_node_to_...
      functions as this patch is more specific to using task mempolicy
      to control huge page allocation and freeing.

V5: + removed now unneeded 'nextnid' from hstate_next_node_to_{alloc|free}
      and updated the stale comments.

V6: + move defaulting of nodes_allowed [to &node_online_map] up to
      set_max_huge_pages().  Eliminate from hstate_next_node_*()
      functions.  [David Rientjes' suggestion].
    + renamed "this_node_allowed()" to "get_valid_node_allowed()"
      [for David]

V8: + add nodemask_t arg to set_max_huge_pages().  Subsequent
      patches will pass non-default values.

In preparation for constraining huge page allocation and freeing by the
controlling task's numa mempolicy, add a "nodes_allowed" nodemask pointer
to the allocate, free and surplus adjustment functions.  For now, pass
NULL to indicate default behavior--i.e., use node_online_map.  A
subsqeuent patch will derive a non-default mask from the controlling 
task's numa mempolicy.

Note that this method of updating the global hstate nr_hugepages under
the constraint of a nodemask simplifies keeping the global state 
consistent--especially the number of persistent and surplus pages
relative to reservations and overcommit limits.  There are undoubtedly
other ways to do this, but this works for both interfaces:  mempolicy
and per node attributes.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reviewed-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: David Rientjes <rientjes@google.com>

 mm/hugetlb.c |  127 ++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 75 insertions(+), 52 deletions(-)

Index: linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/mm/hugetlb.c	2009-09-28 10:12:20.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c	2009-09-30 11:41:36.000000000 -0400
@@ -622,48 +622,56 @@ static struct page *alloc_fresh_huge_pag
 }
 
 /*
- * common helper function for hstate_next_node_to_{alloc|free}.
- * return next node in node_online_map, wrapping at end.
+ * common helper functions for hstate_next_node_to_{alloc|free}.
+ * We may have allocated or freed a huge page based on a different
+ * nodes_allowed previously, so h->next_node_to_{alloc|free} might
+ * be outside of *nodes_allowed.  Ensure that we use an allowed
+ * node for alloc or free.
  */
-static int next_node_allowed(int nid)
+static int next_node_allowed(int nid, nodemask_t *nodes_allowed)
 {
-	nid = next_node(nid, node_online_map);
+	nid = next_node(nid, *nodes_allowed);
 	if (nid == MAX_NUMNODES)
-		nid = first_node(node_online_map);
+		nid = first_node(*nodes_allowed);
 	VM_BUG_ON(nid >= MAX_NUMNODES);
 
 	return nid;
 }
 
+static int get_valid_node_allowed(int nid, nodemask_t *nodes_allowed)
+{
+	if (!node_isset(nid, *nodes_allowed))
+		nid = next_node_allowed(nid, nodes_allowed);
+	return nid;
+}
+
 /*
- * Use a helper variable to find the next node and then
- * copy it back to next_nid_to_alloc afterwards:
- * otherwise there's a window in which a racer might
- * pass invalid nid MAX_NUMNODES to alloc_pages_exact_node.
- * But we don't need to use a spin_lock here: it really
- * doesn't matter if occasionally a racer chooses the
- * same nid as we do.  Move nid forward in the mask even
- * if we just successfully allocated a hugepage so that
- * the next caller gets hugepages on the next node.
+ * returns the previously saved node ["this node"] from which to
+ * allocate a persistent huge page for the pool and advance the
+ * next node from which to allocate, handling wrap at end of node
+ * mask.
  */
-static int hstate_next_node_to_alloc(struct hstate *h)
+static int hstate_next_node_to_alloc(struct hstate *h,
+					nodemask_t *nodes_allowed)
 {
-	int nid, next_nid;
+	int nid;
+
+	VM_BUG_ON(!nodes_allowed);
+
+	nid = get_valid_node_allowed(h->next_nid_to_alloc, nodes_allowed);
+	h->next_nid_to_alloc = next_node_allowed(nid, nodes_allowed);
 
-	nid = h->next_nid_to_alloc;
-	next_nid = next_node_allowed(nid);
-	h->next_nid_to_alloc = next_nid;
 	return nid;
 }
 
-static int alloc_fresh_huge_page(struct hstate *h)
+static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
 {
 	struct page *page;
 	int start_nid;
 	int next_nid;
 	int ret = 0;
 
-	start_nid = hstate_next_node_to_alloc(h);
+	start_nid = hstate_next_node_to_alloc(h, nodes_allowed);
 	next_nid = start_nid;
 
 	do {
@@ -672,7 +680,7 @@ static int alloc_fresh_huge_page(struct
 			ret = 1;
 			break;
 		}
-		next_nid = hstate_next_node_to_alloc(h);
+		next_nid = hstate_next_node_to_alloc(h, nodes_allowed);
 	} while (next_nid != start_nid);
 
 	if (ret)
@@ -684,18 +692,20 @@ static int alloc_fresh_huge_page(struct
 }
 
 /*
- * helper for free_pool_huge_page() - return the next node
- * from which to free a huge page.  Advance the next node id
- * whether or not we find a free huge page to free so that the
- * next attempt to free addresses the next node.
+ * helper for free_pool_huge_page() - return the previously saved
+ * node ["this node"] from which to free a huge page.  Advance the
+ * next node id whether or not we find a free huge page to free so
+ * that the next attempt to free addresses the next node.
  */
-static int hstate_next_node_to_free(struct hstate *h)
+static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
 {
-	int nid, next_nid;
+	int nid;
+
+	VM_BUG_ON(!nodes_allowed);
+
+	nid = get_valid_node_allowed(h->next_nid_to_free, nodes_allowed);
+	h->next_nid_to_free = next_node_allowed(nid, nodes_allowed);
 
-	nid = h->next_nid_to_free;
-	next_nid = next_node_allowed(nid);
-	h->next_nid_to_free = next_nid;
 	return nid;
 }
 
@@ -705,13 +715,14 @@ static int hstate_next_node_to_free(stru
  * balanced over allowed nodes.
  * Called with hugetlb_lock locked.
  */
-static int free_pool_huge_page(struct hstate *h, bool acct_surplus)
+static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
+							 bool acct_surplus)
 {
 	int start_nid;
 	int next_nid;
 	int ret = 0;
 
-	start_nid = hstate_next_node_to_free(h);
+	start_nid = hstate_next_node_to_free(h, nodes_allowed);
 	next_nid = start_nid;
 
 	do {
@@ -735,7 +746,7 @@ static int free_pool_huge_page(struct hs
 			ret = 1;
 			break;
 		}
-		next_nid = hstate_next_node_to_free(h);
+		next_nid = hstate_next_node_to_free(h, nodes_allowed);
 	} while (next_nid != start_nid);
 
 	return ret;
@@ -937,7 +948,7 @@ static void return_unused_surplus_pages(
 	 * on-line nodes for us and will handle the hstate accounting.
 	 */
 	while (nr_pages--) {
-		if (!free_pool_huge_page(h, 1))
+		if (!free_pool_huge_page(h, &node_online_map, 1))
 			break;
 	}
 }
@@ -1047,7 +1058,7 @@ int __weak alloc_bootmem_huge_page(struc
 		void *addr;
 
 		addr = __alloc_bootmem_node_nopanic(
-				NODE_DATA(hstate_next_node_to_alloc(h)),
+				NODE_DATA(hstate_next_node_to_alloc(h, NULL)),
 				huge_page_size(h), huge_page_size(h), 0);
 
 		if (addr) {
@@ -1102,7 +1113,7 @@ static void __init hugetlb_hstate_alloc_
 		if (h->order >= MAX_ORDER) {
 			if (!alloc_bootmem_huge_page(h))
 				break;
-		} else if (!alloc_fresh_huge_page(h))
+		} else if (!alloc_fresh_huge_page(h, &node_online_map))
 			break;
 	}
 	h->max_huge_pages = i;
@@ -1144,16 +1155,22 @@ static void __init report_hugepages(void
 }
 
 #ifdef CONFIG_HIGHMEM
-static void try_to_free_low(struct hstate *h, unsigned long count)
+static void try_to_free_low(struct hstate *h, unsigned long count,
+						nodemask_t *nodes_allowed)
 {
 	int i;
 
 	if (h->order >= MAX_ORDER)
 		return;
 
+	if (!nodes_allowed)
+		nodes_allowed = &node_online_map;
+
 	for (i = 0; i < MAX_NUMNODES; ++i) {
 		struct page *page, *next;
 		struct list_head *freel = &h->hugepage_freelists[i];
+		if (!node_isset(i, *nodes_allowed))
+			continue;
 		list_for_each_entry_safe(page, next, freel, lru) {
 			if (count >= h->nr_huge_pages)
 				return;
@@ -1167,7 +1184,8 @@ static void try_to_free_low(struct hstat
 	}
 }
 #else
-static inline void try_to_free_low(struct hstate *h, unsigned long count)
+static inline void try_to_free_low(struct hstate *h, unsigned long count,
+						nodemask_t *nodes_allowed)
 {
 }
 #endif
@@ -1177,7 +1195,8 @@ static inline void try_to_free_low(struc
  * balanced by operating on them in a round-robin fashion.
  * Returns 1 if an adjustment was made.
  */
-static int adjust_pool_surplus(struct hstate *h, int delta)
+static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
+				int delta)
 {
 	int start_nid, next_nid;
 	int ret = 0;
@@ -1185,9 +1204,9 @@ static int adjust_pool_surplus(struct hs
 	VM_BUG_ON(delta != -1 && delta != 1);
 
 	if (delta < 0)
-		start_nid = hstate_next_node_to_alloc(h);
+		start_nid = hstate_next_node_to_alloc(h, nodes_allowed);
 	else
-		start_nid = hstate_next_node_to_free(h);
+		start_nid = hstate_next_node_to_free(h, nodes_allowed);
 	next_nid = start_nid;
 
 	do {
@@ -1197,7 +1216,8 @@ static int adjust_pool_surplus(struct hs
 			 * To shrink on this node, there must be a surplus page
 			 */
 			if (!h->surplus_huge_pages_node[nid]) {
-				next_nid = hstate_next_node_to_alloc(h);
+				next_nid = hstate_next_node_to_alloc(h,
+								nodes_allowed);
 				continue;
 			}
 		}
@@ -1207,7 +1227,8 @@ static int adjust_pool_surplus(struct hs
 			 */
 			if (h->surplus_huge_pages_node[nid] >=
 						h->nr_huge_pages_node[nid]) {
-				next_nid = hstate_next_node_to_free(h);
+				next_nid = hstate_next_node_to_free(h,
+								nodes_allowed);
 				continue;
 			}
 		}
@@ -1222,7 +1243,8 @@ static int adjust_pool_surplus(struct hs
 }
 
 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
-static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
+static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
+						nodemask_t *nodes_allowed)
 {
 	unsigned long min_count, ret;
 
@@ -1242,7 +1264,7 @@ static unsigned long set_max_huge_pages(
 	 */
 	spin_lock(&hugetlb_lock);
 	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
-		if (!adjust_pool_surplus(h, -1))
+		if (!adjust_pool_surplus(h, nodes_allowed, -1))
 			break;
 	}
 
@@ -1253,7 +1275,7 @@ static unsigned long set_max_huge_pages(
 		 * and reducing the surplus.
 		 */
 		spin_unlock(&hugetlb_lock);
-		ret = alloc_fresh_huge_page(h);
+		ret = alloc_fresh_huge_page(h, nodes_allowed);
 		spin_lock(&hugetlb_lock);
 		if (!ret)
 			goto out;
@@ -1277,13 +1299,13 @@ static unsigned long set_max_huge_pages(
 	 */
 	min_count = h->resv_huge_pages + h->nr_huge_pages - h->free_huge_pages;
 	min_count = max(count, min_count);
-	try_to_free_low(h, min_count);
+	try_to_free_low(h, min_count, nodes_allowed);
 	while (min_count < persistent_huge_pages(h)) {
-		if (!free_pool_huge_page(h, 0))
+		if (!free_pool_huge_page(h, nodes_allowed, 0))
 			break;
 	}
 	while (count < persistent_huge_pages(h)) {
-		if (!adjust_pool_surplus(h, 1))
+		if (!adjust_pool_surplus(h, nodes_allowed, 1))
 			break;
 	}
 out:
@@ -1329,7 +1351,7 @@ static ssize_t nr_hugepages_store(struct
 	if (err)
 		return 0;
 
-	h->max_huge_pages = set_max_huge_pages(h, input);
+	h->max_huge_pages = set_max_huge_pages(h, input, &node_online_map);
 
 	return count;
 }
@@ -1571,7 +1593,8 @@ int hugetlb_sysctl_handler(struct ctl_ta
 	proc_doulongvec_minmax(table, write, buffer, length, ppos);
 
 	if (write)
-		h->max_huge_pages = set_max_huge_pages(h, tmp);
+		h->max_huge_pages = set_max_huge_pages(h, tmp,
+							&node_online_map);
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
