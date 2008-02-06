Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m16NLQ7Z032381
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 18:21:26 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m16NJWdQ267394
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 18:19:32 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m16NJVbw015169
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 18:19:32 -0500
Date: Wed, 6 Feb 2008 15:19:30 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH 3/3] hugetlb: interleave dequeing of huge pages
Message-ID: <20080206231930.GK3477@us.ibm.com>
References: <20080206231558.GI3477@us.ibm.com> <20080206231845.GJ3477@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080206231845.GJ3477@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org, greg@kroah.com
List-ID: <linux-mm.kvack.org>

Currently, when shrinking the hugetlb pool, we free all of the pages on
node 0, then all the pages on node 1, etc.  Instead, we interleave over
the nodes with memory. If some particularly node should be cleared
first, the per-node sysfs attribute can be used for finer-grained
control. This also helps with keeping the pool balanced as we change the
pool at run-time.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 05dac46..f7cd942 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -84,7 +84,38 @@ static struct page *dequeue_huge_page_node(struct vm_area_struct *vma,
 	return page;
 }
 
-static struct page *dequeue_huge_page(struct vm_area_struct *vma,
+static struct page *dequeue_huge_page(void)
+{
+	struct page *page = NULL;
+	int start_nid;
+	int next_nid;
+
+	start_nid = hugetlb_next_nid;
+
+	do {
+		if (!list_empty(&hugepage_freelists[hugetlb_next_nid]))
+			page = dequeue_huge_page_node(NULL, hugetlb_next_nid);
+		/*
+		 * Use a helper variable to find the next node and then
+		 * copy it back to hugetlb_next_nid afterwards:
+		 * otherwise there's a window in which a racer might
+		 * pass invalid nid MAX_NUMNODES to alloc_pages_node.
+		 * But we don't need to use a spin_lock here: it really
+		 * doesn't matter if occasionally a racer chooses the
+		 * same nid as we do.  Move nid forward in the mask even
+		 * if we just successfully allocated a hugepage so that
+		 * the next caller gets hugepages on the next node.
+		 */
+		next_nid = next_node(hugetlb_next_nid, node_online_map);
+		if (next_nid == MAX_NUMNODES)
+			next_nid = first_node(node_online_map);
+		hugetlb_next_nid = next_nid;
+	} while (!page && hugetlb_next_nid != start_nid);
+
+	return page;
+}
+
+static struct page *dequeue_huge_page_vma(struct vm_area_struct *vma,
 				unsigned long address)
 {
 	int nid;
@@ -411,7 +442,7 @@ static struct page *alloc_huge_page_shared(struct vm_area_struct *vma,
 	struct page *page;
 
 	spin_lock(&hugetlb_lock);
-	page = dequeue_huge_page(vma, addr);
+	page = dequeue_huge_page_vma(vma, addr);
 	spin_unlock(&hugetlb_lock);
 	return page ? page : ERR_PTR(-VM_FAULT_OOM);
 }
@@ -426,7 +457,7 @@ static struct page *alloc_huge_page_private(struct vm_area_struct *vma,
 
 	spin_lock(&hugetlb_lock);
 	if (free_huge_pages > resv_huge_pages)
-		page = dequeue_huge_page(vma, addr);
+		page = dequeue_huge_page_vma(vma, addr);
 	spin_unlock(&hugetlb_lock);
 	if (!page) {
 		page = alloc_buddy_huge_page(vma, addr);
@@ -592,7 +623,7 @@ static unsigned long set_max_huge_pages(unsigned long count)
 	min_count = max(count, min_count);
 	try_to_free_low(min_count);
 	while (min_count < persistent_huge_pages) {
-		struct page *page = dequeue_huge_page(NULL, 0);
+		struct page *page = dequeue_huge_page();
 		if (!page)
 			break;
 		update_and_free_page(page_to_nid(page), page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
