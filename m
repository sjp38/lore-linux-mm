Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l76Gcgr7018117
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:38:42 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l76GcgoX542044
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:38:42 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l76GcgiG016855
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:38:42 -0400
Date: Mon, 6 Aug 2007 09:38:41 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 2/5] hugetlb: numafy several functions
Message-ID: <20070806163841.GL15714@us.ibm.com>
References: <20070806163254.GJ15714@us.ibm.com> <20070806163726.GK15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070806163726.GK15714@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

Add node-parameterized helpers for dequeue_huge_page,
alloc_fresh_huge_page and try_to_free_low. Also have
update_and_free_page() take a nid parameter. This is necessary to add a
per-node sysfs attribute to specify the number of hugepages on that
node.

Tested on: 2-node IA64, 4-node ppc64 (2 memoryless nodes), 4-node ppc64
(no memoryless nodes), 4-node x86_64, !NUMA x86, 1-node x86 (NUMA-Q), 

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1cd3118..31c4359 100644
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
 static int alloc_fresh_huge_page(struct mempolicy *policy)
 {
 	int nid;
@@ -112,22 +137,12 @@ static int alloc_fresh_huge_page(struct mempolicy *policy)
 	nid = start_nid;
 
 	do {
-		page = alloc_pages_node(nid,
-				htlb_alloc_mask|__GFP_COMP|GFP_THISNODE,
-				HUGETLB_PAGE_ORDER);
+		page = alloc_fresh_huge_page_node(nid);
 		if (page)
-			break;
+			return 1;
 		nid = interleave_nodes(policy);
 	} while (nid != start_nid);
-	if (page) {
-		set_compound_page_dtor(page, free_huge_page);
-		spin_lock(&hugetlb_lock);
-		nr_huge_pages++;
-		nr_huge_pages_node[page_to_nid(page)]++;
-		spin_unlock(&hugetlb_lock);
-		put_page(page); /* free it into the hugepage allocator */
-		return 1;
-	}
+
 	return 0;
 }
 
@@ -203,11 +218,11 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
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
@@ -219,25 +234,37 @@ static void update_and_free_page(struct page *page)
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
@@ -265,7 +292,7 @@ static unsigned long set_max_huge_pages(unsigned long count)
 		struct page *page = dequeue_huge_page(NULL, 0);
 		if (!page)
 			break;
-		update_and_free_page(page);
+		update_and_free_page(page_to_nid(page), page);
 	}
 	spin_unlock(&hugetlb_lock);
 	return nr_huge_pages;

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
