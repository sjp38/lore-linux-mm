Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l6DFBaak014516
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 11:11:36 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6DFH8IE257796
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 09:17:09 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6DFH8l5031013
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 09:17:08 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 4/5] [hugetlb] Try to grow pool on alloc_huge_page failure
Date: Fri, 13 Jul 2007 08:17:06 -0700
Message-Id: <20070713151706.17750.89107.stgit@kernel>
In-Reply-To: <20070713151621.17750.58171.stgit@kernel>
References: <20070713151621.17750.58171.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Lameter <clameter@sgi.com>, Ken Chen <kenchen@google.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Because we overcommit hugepages for MAP_PRIVATE mappings, it is possible that
the hugetlb pool will be exhausted (or fully reserved) when a hugepage is
needed to satisfy a page fault.  Before killing the process in this situation,
try to allocate a hugepage directly from the buddy allocator.  Only do this if
the process would remain within its locked_vm memory limits.

Hugepages allocated directly from the buddy allocator (surplus pages)
should be freed back to the buddy allocator to prevent unbounded growth of
the hugetlb pool.  Introduce a per-node surplus pages counter which is then
used by free_huge_page to determine how the page should be freed.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 mm/hugetlb.c |   82 ++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 77 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a754c20..f03db67 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -27,6 +27,7 @@ unsigned long max_huge_pages;
 static struct list_head hugepage_freelists[MAX_NUMNODES];
 static unsigned int nr_huge_pages_node[MAX_NUMNODES];
 static unsigned int free_huge_pages_node[MAX_NUMNODES];
+static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 /*
  * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
  */
@@ -105,16 +106,22 @@ static void update_and_free_page(struct page *page)
 
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
 
-static int alloc_fresh_huge_page(void)
+static struct page *__alloc_fresh_huge_page(void)
 {
 	static int nid = 0;
 	struct page *page;
@@ -129,16 +136,72 @@ static int alloc_fresh_huge_page(void)
 		nr_huge_pages++;
 		nr_huge_pages_node[page_to_nid(page)]++;
 		spin_unlock(&hugetlb_lock);
+	}
+	return page;
+}
+
+static int alloc_fresh_huge_page(void)
+{
+	struct page *page;
+
+	page = __alloc_fresh_huge_page();
+	if (page) {
 		put_page(page); /* free it into the hugepage allocator */
 		return 1;
 	}
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
+	locked_pages += hpage_delta * BASE_PAGES_PER_HPAGE;
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
+	struct page *page = NULL;
+
+	/* Check we remain within limits if 1 huge page is allocated */
+	if (!within_locked_vm_limits(1))
+		return NULL;
+
+	page = __alloc_fresh_huge_page();
+	if (page) {
+		INIT_LIST_HEAD(&page->lru);
+
+		/* We now have a surplus huge page, keep track of it */
+		spin_lock(&hugetlb_lock);
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
@@ -158,7 +221,16 @@ fail:
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
