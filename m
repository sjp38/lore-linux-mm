Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF116B005D
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 09:51:56 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 16 Jun 2009 09:52:36 -0400
Message-Id: <20090616135236.25248.93692.sendpatchset@lts-notebook>
In-Reply-To: <20090616135228.25248.22018.sendpatchset@lts-notebook>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook>
Subject: [PATCH 1/5] Free huge pages round robin to balance across nodes
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 1/5] Free huge pages round robin to balance across nodes

Against:  17may09 mmotm

Currently, altho' increasing nr_hugepages will [attempt to]
distribute the new huge pages across all nodes in the system,
reducing nr_hugepages will free or surplus all free pages
from nodes in node id order.  This patch frees huges pages
from nodes in round robin fashion in an attempt to keep
[persistent] hugepage allocates balanced across the nodes.

New function free_pool_huge_page() is modeled on and
performs roughly the inverse of alloc_fresh_huge_page().
Replaces dequeue_huge_page() which now has no callers
and can be removed.

Helper function hstate_next_to_free_node() uses new hstate
member next_to_free_nid to distribute "frees" across all
nodes with huge pages.

I placed this patch first in the series because I think it
[or something similar] should be applied independent of the
rest of the series.  

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/hugetlb.h |    1 
 mm/hugetlb.c            |   68 +++++++++++++++++++++++++++++++++---------------
 2 files changed, 48 insertions(+), 21 deletions(-)

Index: linux-2.6.30-rc8-mmotm-090603-1633/include/linux/hugetlb.h
===================================================================
--- linux-2.6.30-rc8-mmotm-090603-1633.orig/include/linux/hugetlb.h	2009-06-04 12:59:29.000000000 -0400
+++ linux-2.6.30-rc8-mmotm-090603-1633/include/linux/hugetlb.h	2009-06-04 12:59:31.000000000 -0400
@@ -184,6 +184,7 @@ unsigned long hugetlb_get_unmapped_area(
 /* Defines one hugetlb page size */
 struct hstate {
 	int hugetlb_next_nid;
+	int next_to_free_nid;
 	unsigned int order;
 	unsigned long mask;
 	unsigned long max_huge_pages;
Index: linux-2.6.30-rc8-mmotm-090603-1633/mm/hugetlb.c
===================================================================
--- linux-2.6.30-rc8-mmotm-090603-1633.orig/mm/hugetlb.c	2009-06-04 12:59:29.000000000 -0400
+++ linux-2.6.30-rc8-mmotm-090603-1633/mm/hugetlb.c	2009-06-04 12:59:31.000000000 -0400
@@ -455,24 +455,6 @@ static void enqueue_huge_page(struct hst
 	h->free_huge_pages_node[nid]++;
 }
 
-static struct page *dequeue_huge_page(struct hstate *h)
-{
-	int nid;
-	struct page *page = NULL;
-
-	for (nid = 0; nid < MAX_NUMNODES; ++nid) {
-		if (!list_empty(&h->hugepage_freelists[nid])) {
-			page = list_entry(h->hugepage_freelists[nid].next,
-					  struct page, lru);
-			list_del(&page->lru);
-			h->free_huge_pages--;
-			h->free_huge_pages_node[nid]--;
-			break;
-		}
-	}
-	return page;
-}
-
 static struct page *dequeue_huge_page_vma(struct hstate *h,
 				struct vm_area_struct *vma,
 				unsigned long address, int avoid_reserve)
@@ -683,6 +665,52 @@ static int alloc_fresh_huge_page(struct 
 	return ret;
 }
 
+/*
+ * helper for free_pool_huge_page() - find next node
+ * from which to free a huge page
+ */
+static int hstate_next_to_free_node(struct hstate *h)
+{
+	int next_nid;
+	next_nid = next_node(h->next_to_free_nid, node_online_map);
+	if (next_nid == MAX_NUMNODES)
+		next_nid = first_node(node_online_map);
+	h->next_to_free_nid = next_nid;
+	return next_nid;
+}
+
+/*
+ * Free huge page from pool from next node to free.
+ * Attempt to keep persistent huge pages more or less
+ * balanced over allowed nodes.
+ * Called with hugetlb_lock locked.
+ */
+static int free_pool_huge_page(struct hstate *h)
+{
+	int start_nid;
+	int nid;
+	int ret = 0;
+
+	start_nid = h->next_to_free_nid;
+	nid = h->next_to_free_nid;
+
+	do {
+		if (!list_empty(&h->hugepage_freelists[nid])) {
+			struct page *page =
+				list_entry(h->hugepage_freelists[nid].next,
+					  struct page, lru);
+			list_del(&page->lru);
+			h->free_huge_pages--;
+			h->free_huge_pages_node[nid]--;
+			update_and_free_page(h, page);
+			ret = 1;
+		}
+		nid = hstate_next_to_free_node(h);
+	} while (!ret && nid != start_nid);
+
+	return ret;
+}
+
 static struct page *alloc_buddy_huge_page(struct hstate *h,
 			struct vm_area_struct *vma, unsigned long address)
 {
@@ -1226,10 +1254,8 @@ static unsigned long set_max_huge_pages(
 	min_count = max(count, min_count);
 	try_to_free_low(h, min_count);
 	while (min_count < persistent_huge_pages(h)) {
-		struct page *page = dequeue_huge_page(h);
-		if (!page)
+		if (!free_pool_huge_page(h))
 			break;
-		update_and_free_page(h, page);
 	}
 	while (count < persistent_huge_pages(h)) {
 		if (!adjust_pool_surplus(h, 1))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
