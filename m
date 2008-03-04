Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m241H3dZ001066
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 20:17:03 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m241H3bp267026
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 20:17:03 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m241H3Oj032534
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 20:17:03 -0500
Date: Mon, 3 Mar 2008 17:17:04 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH] hugetlb: fix pool shrinking while in restricted cpuset
Message-ID: <20080304011704.GA13954@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: agl@us.ibm.com
Cc: wli@holomorphy.com, Lee.Schermerhorn@hp.com, clameter@sgi.com, pj@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adam Litke noticed that currently we grow the hugepage pool independent
of any cpuset the running process may be in, but when shrinking the
pool, the cpuset is checked. This leads to inconsistency when shrinking
the pool in a restricted cpuset -- an administrator may have been able
to grow the pool on a node restricted by a containing cpuset, but they
cannot shrink it there. There are two options: either prevent growing of
the pool outside of the cpuset or allow shrinking outside of the cpuset.
>From previous discussions on linux-mm, /proc/sys/vm/nr_hugepages is an
administrative interface that should not be restricted by cpusets. So
allow shrinking the pool by removing pages from nodes outside of
current's cpuset.

This is a bugfix and should go into 2.6.25.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Adam Litke <agl@us.ibm.com>
Cc: William Irwin <wli@holomorphy.com>
Cc: Lee Schermerhorn <Lee.Schermerhonr@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>
Cc: Paul Jackson <pj@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 89e6286..61ac37f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -71,7 +71,25 @@ static void enqueue_huge_page(struct page *page)
 	free_huge_pages_node[nid]++;
 }
 
-static struct page *dequeue_huge_page(struct vm_area_struct *vma,
+static struct page *dequeue_huge_page(void)
+{
+	int nid;
+	struct page *page = NULL;
+
+	for (nid = 0; nid < MAX_NUMNODES; ++nid) {
+		if (!list_empty(&hugepage_freelists[nid])) {
+			page = list_entry(hugepage_freelists[nid].next,
+					  struct page, lru);
+			list_del(&page->lru);
+			free_huge_pages--;
+			free_huge_pages_node[nid]--;
+			break;
+		}
+	}
+	return page;
+}
+
+static struct page *dequeue_huge_page_vma(struct vm_area_struct *vma,
 				unsigned long address)
 {
 	int nid;
@@ -402,7 +420,7 @@ static struct page *alloc_huge_page_shared(struct vm_area_struct *vma,
 	struct page *page;
 
 	spin_lock(&hugetlb_lock);
-	page = dequeue_huge_page(vma, addr);
+	page = dequeue_huge_page_vma(vma, addr);
 	spin_unlock(&hugetlb_lock);
 	return page ? page : ERR_PTR(-VM_FAULT_OOM);
 }
@@ -417,7 +435,7 @@ static struct page *alloc_huge_page_private(struct vm_area_struct *vma,
 
 	spin_lock(&hugetlb_lock);
 	if (free_huge_pages > resv_huge_pages)
-		page = dequeue_huge_page(vma, addr);
+		page = dequeue_huge_page_vma(vma, addr);
 	spin_unlock(&hugetlb_lock);
 	if (!page) {
 		page = alloc_buddy_huge_page(vma, addr);
@@ -570,7 +588,7 @@ static unsigned long set_max_huge_pages(unsigned long count)
 	min_count = max(count, min_count);
 	try_to_free_low(min_count);
 	while (min_count < persistent_huge_pages) {
-		struct page *page = dequeue_huge_page(NULL, 0);
+		struct page *page = dequeue_huge_page();
 		if (!page)
 			break;
 		update_and_free_page(page);

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
