Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id AA9916B0036
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 01:28:26 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 4/9] mm, hugetlb: fix and clean-up node iteration code to alloc or free
Date: Mon, 29 Jul 2013 14:28:16 +0900
Message-Id: <1375075701-5998-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1375075701-5998-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075701-5998-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Current node iteration code have a minor problem which do one more
node rotation if we can't succeed to allocate. For example,
if we start to allocate at node 0, we stop to iterate at node 0.
Then we start to allocate at node 1 for next allocation.

I introduce new macros "for_each_node_mask_to_[alloc|free]" and
fix and clean-up node iteration code to alloc or free.
This makes code more understandable.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 31d78c5..87d7637 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -755,33 +755,6 @@ static int hstate_next_node_to_alloc(struct hstate *h,
 	return nid;
 }
 
-static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
-{
-	struct page *page;
-	int start_nid;
-	int next_nid;
-	int ret = 0;
-
-	start_nid = hstate_next_node_to_alloc(h, nodes_allowed);
-	next_nid = start_nid;
-
-	do {
-		page = alloc_fresh_huge_page_node(h, next_nid);
-		if (page) {
-			ret = 1;
-			break;
-		}
-		next_nid = hstate_next_node_to_alloc(h, nodes_allowed);
-	} while (next_nid != start_nid);
-
-	if (ret)
-		count_vm_event(HTLB_BUDDY_PGALLOC);
-	else
-		count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
-
-	return ret;
-}
-
 /*
  * helper for free_pool_huge_page() - return the previously saved
  * node ["this node"] from which to free a huge page.  Advance the
@@ -800,6 +773,40 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
 	return nid;
 }
 
+#define for_each_node_mask_to_alloc(hs, nr_nodes, node, mask)		\
+	for (nr_nodes = nodes_weight(*mask);				\
+		nr_nodes > 0 &&						\
+		((node = hstate_next_node_to_alloc(hs, mask)) || 1);	\
+		nr_nodes--)
+
+#define for_each_node_mask_to_free(hs, nr_nodes, node, mask)		\
+	for (nr_nodes = nodes_weight(*mask);				\
+		nr_nodes > 0 &&						\
+		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
+		nr_nodes--)
+
+static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
+{
+	struct page *page;
+	int nr_nodes, node;
+	int ret = 0;
+
+	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
+		page = alloc_fresh_huge_page_node(h, node);
+		if (page) {
+			ret = 1;
+			break;
+		}
+	}
+
+	if (ret)
+		count_vm_event(HTLB_BUDDY_PGALLOC);
+	else
+		count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
+
+	return ret;
+}
+
 /*
  * Free huge page from pool from next node to free.
  * Attempt to keep persistent huge pages more or less
@@ -809,36 +816,31 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
 static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
 							 bool acct_surplus)
 {
-	int start_nid;
-	int next_nid;
+	int nr_nodes, node;
 	int ret = 0;
 
-	start_nid = hstate_next_node_to_free(h, nodes_allowed);
-	next_nid = start_nid;
-
-	do {
+	for_each_node_mask_to_free(h, nr_nodes, node, nodes_allowed) {
 		/*
 		 * If we're returning unused surplus pages, only examine
 		 * nodes with surplus pages.
 		 */
-		if ((!acct_surplus || h->surplus_huge_pages_node[next_nid]) &&
-		    !list_empty(&h->hugepage_freelists[next_nid])) {
+		if ((!acct_surplus || h->surplus_huge_pages_node[node]) &&
+		    !list_empty(&h->hugepage_freelists[node])) {
 			struct page *page =
-				list_entry(h->hugepage_freelists[next_nid].next,
+				list_entry(h->hugepage_freelists[node].next,
 					  struct page, lru);
 			list_del(&page->lru);
 			h->free_huge_pages--;
-			h->free_huge_pages_node[next_nid]--;
+			h->free_huge_pages_node[node]--;
 			if (acct_surplus) {
 				h->surplus_huge_pages--;
-				h->surplus_huge_pages_node[next_nid]--;
+				h->surplus_huge_pages_node[node]--;
 			}
 			update_and_free_page(h, page);
 			ret = 1;
 			break;
 		}
-		next_nid = hstate_next_node_to_free(h, nodes_allowed);
-	} while (next_nid != start_nid);
+	}
 
 	return ret;
 }
@@ -1175,14 +1177,12 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 int __weak alloc_bootmem_huge_page(struct hstate *h)
 {
 	struct huge_bootmem_page *m;
-	int nr_nodes = nodes_weight(node_states[N_MEMORY]);
+	int nr_nodes, node;
 
-	while (nr_nodes) {
+	for_each_node_mask_to_alloc(h, nr_nodes, node, &node_states[N_MEMORY]) {
 		void *addr;
 
-		addr = __alloc_bootmem_node_nopanic(
-				NODE_DATA(hstate_next_node_to_alloc(h,
-						&node_states[N_MEMORY])),
+		addr = __alloc_bootmem_node_nopanic(NODE_DATA(node),
 				huge_page_size(h), huge_page_size(h), 0);
 
 		if (addr) {
@@ -1194,7 +1194,6 @@ int __weak alloc_bootmem_huge_page(struct hstate *h)
 			m = addr;
 			goto found;
 		}
-		nr_nodes--;
 	}
 	return 0;
 
@@ -1333,48 +1332,28 @@ static inline void try_to_free_low(struct hstate *h, unsigned long count,
 static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
 				int delta)
 {
-	int start_nid, next_nid;
-	int ret = 0;
+	int nr_nodes, node;
 
 	VM_BUG_ON(delta != -1 && delta != 1);
 
-	if (delta < 0)
-		start_nid = hstate_next_node_to_alloc(h, nodes_allowed);
-	else
-		start_nid = hstate_next_node_to_free(h, nodes_allowed);
-	next_nid = start_nid;
-
-	do {
-		int nid = next_nid;
-		if (delta < 0)  {
-			/*
-			 * To shrink on this node, there must be a surplus page
-			 */
-			if (!h->surplus_huge_pages_node[nid]) {
-				next_nid = hstate_next_node_to_alloc(h,
-								nodes_allowed);
-				continue;
-			}
+	if (delta < 0) {
+		for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
+			if (h->surplus_huge_pages_node[node])
+				goto found;
 		}
-		if (delta > 0) {
-			/*
-			 * Surplus cannot exceed the total number of pages
-			 */
-			if (h->surplus_huge_pages_node[nid] >=
-						h->nr_huge_pages_node[nid]) {
-				next_nid = hstate_next_node_to_free(h,
-								nodes_allowed);
-				continue;
-			}
+	} else {
+		for_each_node_mask_to_free(h, nr_nodes, node, nodes_allowed) {
+			if (h->surplus_huge_pages_node[node] <
+					h->nr_huge_pages_node[node])
+				goto found;
 		}
+	}
+	return 0;
 
-		h->surplus_huge_pages += delta;
-		h->surplus_huge_pages_node[nid] += delta;
-		ret = 1;
-		break;
-	} while (next_nid != start_nid);
-
-	return ret;
+found:
+	h->surplus_huge_pages += delta;
+	h->surplus_huge_pages_node[node] += delta;
+	return 1;
 }
 
 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
