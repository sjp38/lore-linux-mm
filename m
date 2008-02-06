Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m16NG0qg025143
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 18:16:00 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m16NG04p224414
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 18:16:00 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m16NFxhj028369
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 18:16:00 -0500
Date: Wed, 6 Feb 2008 15:15:58 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH 1/3] hugetlb: numafy several functions
Message-ID: <20080206231558.GI3477@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add node-parameterized helpers for dequeue_huge_page,
alloc_fresh_huge_page, adjust_pool_surplus and try_to_free_low. Also
have update_and_free_page() take a nid parameter. These changes are
necessary to add sysfs attributes to specify the number of hugepages on
NUMA nodes.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d9a3803..d1f6c5a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -70,6 +70,20 @@ static void enqueue_huge_page(struct page *page)
 	free_huge_pages_node[nid]++;
 }
 
+static struct page *dequeue_huge_page_node(struct vm_area_struct *vma,
+								int nid)
+{
+	struct page *page;
+
+	page = list_entry(hugepage_freelists[nid].next, struct page, lru);
+	list_del(&page->lru);
+	free_huge_pages--;
+	free_huge_pages_node[nid]--;
+	if (vma && vma->vm_flags & VM_MAYSHARE)
+		resv_huge_pages--;
+	return page;
+}
+
 static struct page *dequeue_huge_page(struct vm_area_struct *vma,
 				unsigned long address)
 {
@@ -84,13 +98,7 @@ static struct page *dequeue_huge_page(struct vm_area_struct *vma,
 		nid = zone_to_nid(*z);
 		if (cpuset_zone_allowed_softwall(*z, htlb_alloc_mask) &&
 		    !list_empty(&hugepage_freelists[nid])) {
-			page = list_entry(hugepage_freelists[nid].next,
-					  struct page, lru);
-			list_del(&page->lru);
-			free_huge_pages--;
-			free_huge_pages_node[nid]--;
-			if (vma && vma->vm_flags & VM_MAYSHARE)
-				resv_huge_pages--;
+			page = dequeue_huge_page_node(vma, nid);
 			break;
 		}
 	}
@@ -98,11 +106,11 @@ static struct page *dequeue_huge_page(struct vm_area_struct *vma,
 	return page;
 }
 
-static void update_and_free_page(struct page *page)
+static void update_and_free_page(int nid, struct page *page)
 {
 	int i;
 	nr_huge_pages--;
-	nr_huge_pages_node[page_to_nid(page)]--;
+	nr_huge_pages_node[nid]--;
 	for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++) {
 		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
 				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
@@ -124,7 +132,7 @@ static void free_huge_page(struct page *page)
 
 	spin_lock(&hugetlb_lock);
 	if (surplus_huge_pages_node[nid]) {
-		update_and_free_page(page);
+		update_and_free_page(nid, page);
 		surplus_huge_pages--;
 		surplus_huge_pages_node[nid]--;
 	} else {
@@ -141,6 +149,18 @@ static void free_huge_page(struct page *page)
  * balanced by operating on them in a round-robin fashion.
  * Returns 1 if an adjustment was made.
  */
+static int adjust_pool_surplus_node(int delta, int nid)
+{
+	if (delta < 0 && !surplus_huge_pages_node[nid])
+		return 0;
+	if (delta > 0 && surplus_huge_pages_node[nid] >=
+					nr_huge_pages_node[nid])
+		return 0;
+	surplus_huge_pages += delta;
+	surplus_huge_pages_node[nid] += delta;
+	return 1;
+}
+
 static int adjust_pool_surplus(int delta)
 {
 	static int prev_nid;
@@ -152,19 +172,9 @@ static int adjust_pool_surplus(int delta)
 		nid = next_node(nid, node_online_map);
 		if (nid == MAX_NUMNODES)
 			nid = first_node(node_online_map);
-
-		/* To shrink on this node, there must be a surplus page */
-		if (delta < 0 && !surplus_huge_pages_node[nid])
-			continue;
-		/* Surplus cannot exceed the total number of pages */
-		if (delta > 0 && surplus_huge_pages_node[nid] >=
-						nr_huge_pages_node[nid])
-			continue;
-
-		surplus_huge_pages += delta;
-		surplus_huge_pages_node[nid] += delta;
-		ret = 1;
-		break;
+		ret = adjust_pool_surplus_node(delta, nid);
+		if (ret == 1)
+			break;
 	} while (nid != prev_nid);
 
 	prev_nid = nid;
@@ -384,7 +394,7 @@ static void return_unused_surplus_pages(unsigned long unused_resv_pages)
 			page = list_entry(hugepage_freelists[nid].next,
 					  struct page, lru);
 			list_del(&page->lru);
-			update_and_free_page(page);
+			update_and_free_page(nid, page);
 			free_huge_pages--;
 			free_huge_pages_node[nid]--;
 			surplus_huge_pages--;
@@ -489,25 +499,35 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
 
 #ifdef CONFIG_SYSCTL
 #ifdef CONFIG_HIGHMEM
+static void try_to_free_low_node(unsigned long count, int nid)
+{
+	struct page *page, *next;
+	list_for_each_entry_safe(page, next, &hugepage_freelists[nid], lru) {
+		if (PageHighMem(page))
+			continue;
+		list_del(&page->lru);
+		update_and_free_page(nid, page);
+		free_huge_pages--;
+		free_huge_pages_node[nid]--;
+		if (count >= nr_huge_pages_node[nid])
+			return;
+	}
+}
+
 static void try_to_free_low(unsigned long count)
 {
 	int i;
 
 	for (i = 0; i < MAX_NUMNODES; ++i) {
-		struct page *page, *next;
-		list_for_each_entry_safe(page, next, &hugepage_freelists[i], lru) {
-			if (count >= nr_huge_pages)
-				return;
-			if (PageHighMem(page))
-				continue;
-			list_del(&page->lru);
-			update_and_free_page(page);
-			free_huge_pages--;
-			free_huge_pages_node[page_to_nid(page)]--;
-		}
+		try_to_free_low_node(count, i);
+		if (count >= nr_huge_pages)
+			return;
 	}
 }
 #else
+static inline void try_to_free_low_node(unsigned long count, int nid)
+{
+}
 static inline void try_to_free_low(unsigned long count)
 {
 }
@@ -572,7 +592,7 @@ static unsigned long set_max_huge_pages(unsigned long count)
 		struct page *page = dequeue_huge_page(NULL, 0);
 		if (!page)
 			break;
-		update_and_free_page(page);
+		update_and_free_page(page_to_nid(page), page);
 	}
 	while (count < persistent_huge_pages) {
 		if (!adjust_pool_surplus(1))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
