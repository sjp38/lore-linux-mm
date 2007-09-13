Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8DHxVd1014708
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 13:59:31 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DHxVC6672592
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 13:59:31 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DHxUa2009501
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 13:59:31 -0400
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 3/5] hugetlb: Try to grow hugetlb pool for MAP_PRIVATE mappings
Date: Thu, 13 Sep 2007 10:59:28 -0700
Message-Id: <20070913175928.27074.14259.stgit@kernel>
In-Reply-To: <20070913175855.27074.27030.stgit@kernel>
References: <20070913175855.27074.27030.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: libhugetlbfs-devel@lists.sourceforge.net, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

Because we overcommit hugepages for MAP_PRIVATE mappings, it is possible
that the hugetlb pool will be exhausted or completely reserved when a
hugepage is needed to satisfy a page fault.  Before killing the process in
this situation, try to allocate a hugepage directly from the buddy
allocator.  Only do this if the process would remain within its locked_vm
memory limits.

The explicitly configured pool size becomes a low watermark.  When
dynamically grown, the allocated huge pages are accounted as a surplus over
the watermark.  As huge pages are freed on a node, surplus pages are
released to the buddy allocator so that the pool will shrink back to the
watermark.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 mm/hugetlb.c |   71 +++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 67 insertions(+), 4 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 50195a2..ec5207e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -27,6 +27,7 @@ unsigned long max_huge_pages;
 static struct list_head hugepage_freelists[MAX_NUMNODES];
 static unsigned int nr_huge_pages_node[MAX_NUMNODES];
 static unsigned int free_huge_pages_node[MAX_NUMNODES];
+static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
@@ -107,12 +108,18 @@ static void update_and_free_page(struct page *page)
 
 static void free_huge_page(struct page *page)
 {
-	BUG_ON(page_count(page));
+	int nid = page_to_nid(page);
 
+	BUG_ON(page_count(page));
 	INIT_LIST_HEAD(&page->lru);
 
 	spin_lock(&hugetlb_lock);
-	enqueue_huge_page(page);
+	if (surplus_huge_pages_node[nid]) {
+		update_and_free_page(page);
+		surplus_huge_pages_node[nid]--;
+	} else {
+		enqueue_huge_page(page);
+	}
 	spin_unlock(&hugetlb_lock);
 }
 
@@ -148,10 +155,57 @@ static int alloc_fresh_huge_page(void)
 	return 0;
 }
 
+/*
+ * Returns 1 if a process remains within lock limits after locking
+ * hpage_delta huge pages. It is expected that mmap_sem is held
+ * when calling this function, otherwise the locked_vm counter may
+ * change unexpectedly
+ */
+static int within_locked_vm_limits(long hpage_delta)
+{
+	unsigned long locked_pages, locked_pages_limit;
+
+	/* Check locked page limits */
+	locked_pages = current->mm->locked_vm;
+	locked_pages += hpage_delta * (HPAGE_SIZE >> PAGE_SHIFT);
+	locked_pages_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+	locked_pages_limit >>= PAGE_SHIFT;
+
+	/* Return 0 if we would exceed locked_vm limits */
+	if (locked_pages > locked_pages_limit)
+		return 0;
+
+	/* Nice, we're within limits */
+	return 1;
+}
+
+static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
+						unsigned long address)
+{
+	struct page *page;
+
+	/* Check we remain within limits if 1 huge page is allocated */
+	if (!within_locked_vm_limits(1))
+		return NULL;
+
+	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
+					HUGETLB_PAGE_ORDER);
+	if (page) {
+		set_compound_page_dtor(page, free_huge_page);
+		spin_lock(&hugetlb_lock);
+		nr_huge_pages++;
+		nr_huge_pages_node[page_to_nid(page)]++;
+		surplus_huge_pages_node[page_to_nid(page)]++;
+		spin_unlock(&hugetlb_lock);
+	}
+
+	return page;
+}
+
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
 				    unsigned long addr)
 {
-	struct page *page;
+	struct page *page = NULL;
 
 	spin_lock(&hugetlb_lock);
 	if (vma->vm_flags & VM_MAYSHARE)
@@ -171,7 +225,16 @@ fail:
 	if (vma->vm_flags & VM_MAYSHARE)
 		resv_huge_pages++;
 	spin_unlock(&hugetlb_lock);
-	return NULL;
+
+	/*
+	 * Private mappings do not use reserved huge pages so the allocation
+	 * may have failed due to an undersized hugetlb pool.  Try to grab a
+	 * surplus huge page from the buddy allocator.
+	 */
+	if (!(vma->vm_flags & VM_MAYSHARE))
+		page = alloc_buddy_huge_page(vma, addr);
+
+	return page;
 }
 
 static int __init hugetlb_init(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
