Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8RK9DRL023851
	for <linux-mm@kvack.org>; Thu, 27 Sep 2007 16:09:13 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8RK9Db9688826
	for <linux-mm@kvack.org>; Thu, 27 Sep 2007 16:09:13 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8RK9CA1003499
	for <linux-mm@kvack.org>; Thu, 27 Sep 2007 16:09:13 -0400
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 2/4] hugetlb: Try to grow hugetlb pool for MAP_PRIVATE mappings
Date: Thu, 27 Sep 2007 13:09:10 -0700
Message-Id: <20070927200910.14951.41144.stgit@kernel>
In-Reply-To: <20070927200848.14951.26553.stgit@kernel>
References: <20070927200848.14951.26553.stgit@kernel>
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
allocator.

The explicitly configured pool size becomes a low watermark.  When
dynamically grown, the allocated huge pages are accounted as a surplus over
the watermark.  As huge pages are freed on a node, surplus pages are
released to the buddy allocator so that the pool will shrink back to the
watermark.

Surplus accounting also allows for friendlier explicit pool resizing.  When
shrinking a pool that is fully in-use, increase the surplus so pages will
be returned to the buddy allocator as soon as they are freed.  When growing
a pool that has a surplus, consume the surplus first and then allocate new
pages.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Dave McCracken <dave.mccracken@oracle.com>
---

 mm/hugetlb.c |  139 ++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 125 insertions(+), 14 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index eb5b9f4..98031a3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -23,10 +23,12 @@
 
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
 static unsigned long nr_huge_pages, free_huge_pages, resv_huge_pages;
+static unsigned long surplus_huge_pages;
 unsigned long max_huge_pages;
 static struct list_head hugepage_freelists[MAX_NUMNODES];
 static unsigned int nr_huge_pages_node[MAX_NUMNODES];
 static unsigned int free_huge_pages_node[MAX_NUMNODES];
+static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
@@ -107,15 +109,57 @@ static void update_and_free_page(struct page *page)
 
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
+		surplus_huge_pages--;
+		surplus_huge_pages_node[nid]--;
+	} else {
+		enqueue_huge_page(page);
+	}
 	spin_unlock(&hugetlb_lock);
 }
 
+/*
+ * Increment or decrement surplus_huge_pages.  Keep node-specific counters
+ * balanced by operating on them in a round-robin fashion.
+ * Returns 1 if an adjustment was made.
+ */
+static int adjust_pool_surplus(int delta)
+{
+	static int prev_nid;
+	int nid = prev_nid;
+	int ret = 0;
+
+	BUG_ON(delta != -1 || delta != 1);
+	do {
+		nid = next_node(nid, node_online_map);
+		if (nid == MAX_NUMNODES)
+			nid = first_node(node_online_map);
+
+		/* To shrink on this node, there must be a surplus page */
+		if (delta < 0 && !surplus_huge_pages_node[nid])
+			continue;
+		/* Surplus cannot exceed the total number of pages */
+		if (delta > 0 && surplus_huge_pages_node[nid] >=
+						nr_huge_pages_node[nid])
+			continue;
+
+		surplus_huge_pages += delta;
+		surplus_huge_pages_node[nid] += delta;
+		ret = 1;
+		break;
+	} while (nid != prev_nid);
+
+	prev_nid = nid;
+	return ret;
+}
+
 static int alloc_fresh_huge_page(void)
 {
 	static int prev_nid;
@@ -148,10 +192,30 @@ static int alloc_fresh_huge_page(void)
 	return 0;
 }
 
+static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
+						unsigned long address)
+{
+	struct page *page;
+
+	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
+					HUGETLB_PAGE_ORDER);
+	if (page) {
+		set_compound_page_dtor(page, free_huge_page);
+		spin_lock(&hugetlb_lock);
+		nr_huge_pages++;
+		nr_huge_pages_node[page_to_nid(page)]++;
+		surplus_huge_pages++;
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
@@ -171,7 +235,16 @@ fail:
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
@@ -239,26 +312,62 @@ static inline void try_to_free_low(unsigned long count)
 }
 #endif
 
+#define persistent_huge_pages (nr_huge_pages - surplus_huge_pages)
 static unsigned long set_max_huge_pages(unsigned long count)
 {
-	while (count > nr_huge_pages) {
-		if (!alloc_fresh_huge_page())
-			return nr_huge_pages;
-	}
-	if (count >= nr_huge_pages)
-		return nr_huge_pages;
+	unsigned long min_count, ret;
 
+	/*
+	 * Increase the pool size
+	 * First take pages out of surplus state.  Then make up the
+	 * remaining difference by allocating fresh huge pages.
+	 */
 	spin_lock(&hugetlb_lock);
-	count = max(count, resv_huge_pages);
-	try_to_free_low(count);
-	while (count < nr_huge_pages) {
+	while (surplus_huge_pages && count > persistent_huge_pages) {
+		if (!adjust_pool_surplus(-1))
+			break;
+	}
+
+	while (count > persistent_huge_pages) {
+		int ret;
+		/*
+		 * If this allocation races such that we no longer need the
+		 * page, free_huge_page will handle it by freeing the page
+		 * and reducing the surplus.
+		 */
+		spin_unlock(&hugetlb_lock);
+		ret = alloc_fresh_huge_page();
+		spin_lock(&hugetlb_lock);
+		if (!ret)
+			goto out;
+
+	}
+	if (count >= persistent_huge_pages)
+		goto out;
+
+	/*
+	 * Decrease the pool size
+	 * First return free pages to the buddy allocator (being careful
+	 * to keep enough around to satisfy reservations).  Then place
+	 * pages into surplus state as needed so the pool will shrink
+	 * to the desired size as pages become free.
+	 */
+	min_count = max(count, resv_huge_pages);
+	try_to_free_low(min_count);
+	while (min_count < persistent_huge_pages) {
 		struct page *page = dequeue_huge_page(NULL, 0);
 		if (!page)
 			break;
 		update_and_free_page(page);
 	}
+	while (count < persistent_huge_pages) {
+		if (!adjust_pool_surplus(1))
+			break;
+	}
+out:
+	ret = persistent_huge_pages;
 	spin_unlock(&hugetlb_lock);
-	return nr_huge_pages;
+	return ret;
 }
 
 int hugetlb_sysctl_handler(struct ctl_table *table, int write,
@@ -290,10 +399,12 @@ int hugetlb_report_meminfo(char *buf)
 			"HugePages_Total: %5lu\n"
 			"HugePages_Free:  %5lu\n"
 			"HugePages_Rsvd:  %5lu\n"
+			"HugePages_Surp:  %5lu\n"
 			"Hugepagesize:    %5lu kB\n",
 			nr_huge_pages,
 			free_huge_pages,
 			resv_huge_pages,
+			surplus_huge_pages,
 			HPAGE_SIZE/1024);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
