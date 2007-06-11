Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BNBsRG022268
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 19:11:54 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BNBsCh528332
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 19:11:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BNBswQ013568
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 19:11:54 -0400
Date: Mon, 11 Jun 2007 16:11:49 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH][RFC] hugetlb: numafy several functions
Message-ID: <20070611231149.GE14458@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070611231008.GD14458@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Applies to 2.6.22-rc4-mm2 with
add-populated_map-to-account-for-memoryless-nodes
fix-interleave-with-memoryless-nodes
fix-hugetlb-pool-allocation-with-empty-nodes
applied.

Add node-parameterized helpers for dequeue_huge_page,
alloc_fresh_huge_page and try_to_free_low. Also have
update_and_free_page() take a nid parameter. This is necessary to add a
per-node sysfs attribute to specify the number of hugepages on that
node.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 97ae1a3..d1e1063 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -66,11 +66,22 @@ static void enqueue_huge_page(struct page *page)
 	free_huge_pages_node[nid]++;
 }
 
+static struct page *dequeue_huge_page_node(int nid)
+{
+	struct page *page;
+
+	page = list_entry(hugepage_freelists[nid].next,
+					  struct page, lru);
+	list_del(&page->lru);
+	free_huge_pages--;
+	free_huge_pages_node[nid]--;
+	return page;
+}
+
 static struct page *dequeue_huge_page(struct vm_area_struct *vma,
 				unsigned long address)
 {
 	int nid;
-	struct page *page = NULL;
 	struct zonelist *zonelist = huge_zonelist(vma, address,
 						htlb_alloc_mask);
 	struct zone **z;
@@ -82,14 +93,9 @@ static struct page *dequeue_huge_page(struct vm_area_struct *vma,
 			break;
 	}
 
-	if (*z) {
-		page = list_entry(hugepage_freelists[nid].next,
-				  struct page, lru);
-		list_del(&page->lru);
-		free_huge_pages--;
-		free_huge_pages_node[nid]--;
-	}
-	return page;
+	if (*z)
+		return dequeue_huge_page_node(nid);
+	return NULL;
 }
 
 static void free_huge_page(struct page *page)
@@ -103,6 +109,25 @@ static void free_huge_page(struct page *page)
 	spin_unlock(&hugetlb_lock);
 }
 
+static struct page *alloc_fresh_huge_page_node(int nid)
+{
+	struct page *page;
+
+	page = alloc_pages_node(nid,
+			GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
+			HUGETLB_PAGE_ORDER);
+	if (page) {
+		set_compound_page_dtor(page, free_huge_page);
+		spin_lock(&hugetlb_lock);
+		nr_huge_pages++;
+		nr_huge_pages_node[nid]++;
+		spin_unlock(&hugetlb_lock);
+		put_page(page); /* free it into the hugepage allocator */
+	}
+
+	return page;
+}
+
 static int alloc_fresh_huge_page(void)
 {
 	static int nid = -1;
@@ -114,22 +139,14 @@ static int alloc_fresh_huge_page(void)
 	start_nid = nid;
 
 	do {
-		page = alloc_pages_node(nid,
-				GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
-				HUGETLB_PAGE_ORDER);
+		page = alloc_fresh_huge_page_node(nid);
 		nid = next_node(nid, node_populated_map);
 		if (nid >= nr_node_ids)
 			nid = first_node(node_populated_map);
 	} while (!page && nid != start_nid);
-	if (page) {
-		set_compound_page_dtor(page, free_huge_page);
-		spin_lock(&hugetlb_lock);
-		nr_huge_pages++;
-		nr_huge_pages_node[page_to_nid(page)]++;
-		spin_unlock(&hugetlb_lock);
-		put_page(page); /* free it into the hugepage allocator */
+
+	if (page)
 		return 1;
-	}
 	return 0;
 }
 
@@ -199,11 +216,11 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
 }
 
 #ifdef CONFIG_SYSCTL
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
@@ -215,25 +232,37 @@ static void update_and_free_page(struct page *page)
 }
 
 #ifdef CONFIG_HIGHMEM
+static void try_to_free_low_node(int nid, unsigned long count)
+{
+	struct page *page, *next;
+
+	list_for_each_entry_safe(page, next,
+				&hugepage_freelists[nid], lru) {
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
-			if (PageHighMem(page))
-				continue;
-			list_del(&page->lru);
-			update_and_free_page(page);
-			free_huge_pages--;
-			free_huge_pages_node[page_to_nid(page)]--;
-			if (count >= nr_huge_pages)
-				return;
-		}
+		try_to_free_low_node(i, count);
+		if (count >= nr_huge_pages)
+			break;
 	}
 }
 #else
+static inline void try_to_free_low_node(int nid, unsigned long count)
+{
+}
 static inline void try_to_free_low(unsigned long count)
 {
 }
@@ -255,7 +284,7 @@ static unsigned long set_max_huge_pages(unsigned long count)
 		struct page *page = dequeue_huge_page(NULL, 0);
 		if (!page)
 			break;
-		update_and_free_page(page);
+		update_and_free_page(page_to_nid(page), page);
 	}
 	spin_unlock(&hugetlb_lock);
 	return nr_huge_pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
