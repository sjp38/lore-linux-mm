Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DB54F6B0095
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 14:09:38 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 29 Jul 2009 14:11:52 -0400
Message-Id: <20090729181152.23716.22375.sendpatchset@localhost.localdomain>
In-Reply-To: <20090729181139.23716.85986.sendpatchset@localhost.localdomain>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain>
Subject: [PATCH 2/4] hugetlb:  numafy several functions
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Greg KH <gregkh@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH/RFC 2/4 hugetlb:  numafy several functions

Against: 2.6.31-rc3-mmotm-090716-1432
atop the previously posted alloc_bootmem_hugepages fix.
[http://marc.info/?l=linux-mm&m=124775468226290&w=4]

Based on a patch by Nishanth Aravamudan <nacc@us.ibm.com>, circa
april2008.

Factor out functions to dequeue and free huge pages and/or adjust
surplus huge page count for a specific node in support of subsequent
patch to alloc or free huge pages on a specified node.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

---
 mm/hugetlb.c |  126 +++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 72 insertions(+), 54 deletions(-)

Index: linux-2.6.31-rc3-mmotm-090716-1432/mm/hugetlb.c
===================================================================
--- linux-2.6.31-rc3-mmotm-090716-1432.orig/mm/hugetlb.c	2009-07-23 11:10:29.000000000 -0400
+++ linux-2.6.31-rc3-mmotm-090716-1432/mm/hugetlb.c	2009-07-27 15:26:39.000000000 -0400
@@ -456,6 +456,17 @@ static void enqueue_huge_page(struct hst
 	h->free_huge_pages_node[nid]++;
 }
 
+static struct page *hstate_dequeue_huge_page_node(struct hstate *h, int nid)
+{
+	struct page *page;
+
+	page = list_entry(h->hugepage_freelists[nid].next, struct page, lru);
+	list_del(&page->lru);
+	h->free_huge_pages--;
+	h->free_huge_pages_node[nid]--;
+	return page;
+}
+
 static struct page *dequeue_huge_page_vma(struct hstate *h,
 				struct vm_area_struct *vma,
 				unsigned long address, int avoid_reserve)
@@ -487,11 +498,7 @@ static struct page *dequeue_huge_page_vm
 		nid = zone_to_nid(zone);
 		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask) &&
 		    !list_empty(&h->hugepage_freelists[nid])) {
-			page = list_entry(h->hugepage_freelists[nid].next,
-					  struct page, lru);
-			list_del(&page->lru);
-			h->free_huge_pages--;
-			h->free_huge_pages_node[nid]--;
+			page = hstate_dequeue_huge_page_node(h, nid);
 
 			if (!avoid_reserve)
 				decrement_hugepage_resv_vma(h, vma);
@@ -599,12 +606,12 @@ int PageHuge(struct page *page)
 	return dtor == free_huge_page;
 }
 
-static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
+static int alloc_fresh_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
 
 	if (h->order >= MAX_ORDER)
-		return NULL;
+		return 0;
 
 	page = alloc_pages_exact_node(nid,
 		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
@@ -613,12 +620,12 @@ static struct page *alloc_fresh_huge_pag
 	if (page) {
 		if (arch_prepare_hugepage(page)) {
 			__free_pages(page, huge_page_order(h));
-			return NULL;
+			return 0;
 		}
 		prep_new_huge_page(h, page, nid);
 	}
 
-	return page;
+	return 1;
 }
 
 /*
@@ -658,7 +665,6 @@ static int hstate_next_node_to_alloc(str
 
 static int alloc_fresh_huge_page(struct hstate *h)
 {
-	struct page *page;
 	int start_nid;
 	int next_nid;
 	int ret = 0;
@@ -667,11 +673,9 @@ static int alloc_fresh_huge_page(struct 
 	next_nid = start_nid;
 
 	do {
-		page = alloc_fresh_huge_page_node(h, next_nid);
-		if (page) {
-			ret = 1;
+		ret = alloc_fresh_huge_page_node(h, next_nid);
+		if (ret)
 			break;
-		}
 		next_nid = hstate_next_node_to_alloc(h);
 	} while (next_nid != start_nid);
 
@@ -699,6 +703,23 @@ static int hstate_next_node_to_free(stru
 	return nid;
 }
 
+static int hstate_free_huge_page_node(struct hstate *h, bool acct_surplus,
+							int nid)
+{
+	struct page *page;
+
+	if (list_empty(&h->hugepage_freelists[nid]))
+		return 0;
+
+	page = hstate_dequeue_huge_page_node(h, nid);
+	if (acct_surplus) {
+		h->surplus_huge_pages--;
+		h->surplus_huge_pages_node[nid]--;
+	}
+	update_and_free_page(h, page);
+	return 1;
+}
+
 /*
  * Free huge page from pool from next node to free.
  * Attempt to keep persistent huge pages more or less
@@ -719,21 +740,11 @@ static int free_pool_huge_page(struct hs
 		 * If we're returning unused surplus pages, only examine
 		 * nodes with surplus pages.
 		 */
-		if ((!acct_surplus || h->surplus_huge_pages_node[next_nid]) &&
-		    !list_empty(&h->hugepage_freelists[next_nid])) {
-			struct page *page =
-				list_entry(h->hugepage_freelists[next_nid].next,
-					  struct page, lru);
-			list_del(&page->lru);
-			h->free_huge_pages--;
-			h->free_huge_pages_node[next_nid]--;
-			if (acct_surplus) {
-				h->surplus_huge_pages--;
-				h->surplus_huge_pages_node[next_nid]--;
-			}
-			update_and_free_page(h, page);
-			ret = 1;
-			break;
+		if ((!acct_surplus || h->surplus_huge_pages_node[next_nid])) {
+			ret = hstate_free_huge_page_node(h, acct_surplus,
+			                                    next_nid);
+			if (ret)
+				break;
 		}
 		next_nid = hstate_next_node_to_free(h);
 	} while (next_nid != start_nid);
@@ -1173,6 +1184,31 @@ static inline void try_to_free_low(struc
 #endif
 
 /*
+ * Increment or decrement surplus_huge_pages for a specified node,
+ * if conditions permit.  Note that decrementing the surplus huge
+ * page count effective promotes a page to persistent, while
+ * incrementing the surplus count demotes a page to surplus.
+ */
+static int adjust_pool_surplus_node(struct hstate *h, int delta, int nid)
+{
+	int ret = 0;
+
+	/*
+	 * To shrink on this node, there must be a surplus page.
+	 * Surplus cannot exceed the total number of pages.
+	 */
+	if ((delta < 0 && h->surplus_huge_pages_node[nid]) ||
+	    (delta > 0 && h->surplus_huge_pages_node[nid] <
+					h->nr_huge_pages_node[nid])) {
+
+		h->surplus_huge_pages += delta;
+		h->surplus_huge_pages_node[nid] += delta;
+		ret = 1;
+	}
+	return ret;
+}
+
+/*
  * Increment or decrement surplus_huge_pages.  Keep node-specific counters
  * balanced by operating on them in a round-robin fashion.
  * Returns 1 if an adjustment was made.
@@ -1191,31 +1227,13 @@ static int adjust_pool_surplus(struct hs
 	next_nid = start_nid;
 
 	do {
-		int nid = next_nid;
-		if (delta < 0)  {
-			/*
-			 * To shrink on this node, there must be a surplus page
-			 */
-			if (!h->surplus_huge_pages_node[nid]) {
-				next_nid = hstate_next_node_to_alloc(h);
-				continue;
-			}
-		}
-		if (delta > 0) {
-			/*
-			 * Surplus cannot exceed the total number of pages
-			 */
-			if (h->surplus_huge_pages_node[nid] >=
-						h->nr_huge_pages_node[nid]) {
-				next_nid = hstate_next_node_to_free(h);
-				continue;
-			}
-		}
-
-		h->surplus_huge_pages += delta;
-		h->surplus_huge_pages_node[nid] += delta;
-		ret = 1;
-		break;
+		ret = adjust_pool_surplus_node(h, delta, next_nid);
+		if (ret)
+			break;
+		if (delta < 0)
+			next_nid = hstate_next_node_to_alloc(h);
+		else
+			next_nid = hstate_next_node_to_free(h);
 	} while (next_nid != start_nid);
 
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
