Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l76GmhuC029536
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:48:43 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l76GmhOJ452908
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:48:43 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l76GmhRG015434
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:48:43 -0400
Date: Mon, 6 Aug 2007 09:48:42 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 5/5] hugetlb: interleave dequeueing of huge pages
Message-ID: <20070806164842.GQ15714@us.ibm.com>
References: <20070806163254.GJ15714@us.ibm.com> <20070806163726.GK15714@us.ibm.com> <20070806163841.GL15714@us.ibm.com> <20070806164055.GN15714@us.ibm.com> <20070806164410.GO15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070806164410.GO15714@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

Currently, when shrinking the hugetlb pool, we free all of the pages on
node 0, then all the pages on node 1, etc. Instead, we interleave over
the valid nodes, as constrained by the enclosing cpuset (or populated
nodes if !CPUSETS). If some particularly node should be cleared first,
the sysfs allocator can be used for finer-grained control. This also
helps with keeping the pool balanced as we change the pool at run-time.

Before:

Trying to clear the hugetlb pool
Done.       0 free
Trying to resize the pool to 100
Node 3 HugePages_Free:      0
Node 2 HugePages_Free:      0
Node 1 HugePages_Free:     50
Node 0 HugePages_Free:     50
Done. Initially     100 free
Trying to resize the pool to 200
Node 3 HugePages_Free:      0
Node 2 HugePages_Free:      0
Node 1 HugePages_Free:    100
Node 0 HugePages_Free:    100
Done.     200 free
Trying to resize the pool back to     100
Node 3 HugePages_Free:      0
Node 2 HugePages_Free:      0
Node 1 HugePages_Free:    100
Node 0 HugePages_Free:      0
Done.     100 free

After:

Trying to clear the hugetlb pool
Done.       0 free
Trying to resize the pool to 100
Node 3 HugePages_Free:      0
Node 2 HugePages_Free:      0
Node 1 HugePages_Free:     50
Node 0 HugePages_Free:     50
Done. Initially     100 free
Trying to resize the pool to 200
Node 3 HugePages_Free:      0
Node 2 HugePages_Free:      0
Node 1 HugePages_Free:    100
Node 0 HugePages_Free:    100
Done.     200 free
Trying to resize the pool back to     100
Node 3 HugePages_Free:      0
Node 2 HugePages_Free:      0
Node 1 HugePages_Free:     50
Node 0 HugePages_Free:     50
Done.     100 free

Tested on: 2-node IA64, 4-node ppc64 (2 memoryless nodes), 4-node ppc64
(no memoryless nodes), 4-node x86_64, !NUMA x86, 1-node x86 (NUMA-Q)

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index af07a0b..f6d1811 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -78,7 +78,27 @@ static struct page *dequeue_huge_page_node(int nid)
 	return page;
 }
 
-static struct page *dequeue_huge_page(struct vm_area_struct *vma,
+static struct page *dequeue_huge_page(struct mempolicy *policy)
+{
+	struct page *page;
+	int nid;
+	int start_nid = interleave_nodes(policy);
+
+	nid = start_nid;
+
+	do {
+		if (!list_empty(&hugepage_freelists[nid])) {
+			page = dequeue_huge_page_node(nid);
+			if (page)
+				return page;
+		}
+		nid = interleave_nodes(policy);
+	} while (nid != start_nid);
+
+	return NULL;
+}
+
+static struct page *dequeue_huge_page_vma(struct vm_area_struct *vma,
 				unsigned long address)
 {
 	int nid;
@@ -155,7 +175,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	else if (free_huge_pages <= resv_huge_pages)
 		goto fail;
 
-	page = dequeue_huge_page(vma, addr);
+	page = dequeue_huge_page_vma(vma, addr);
 	if (!page)
 		goto fail;
 
@@ -295,20 +315,23 @@ static unsigned long set_max_huge_pages(unsigned long count)
 		if (!alloc_fresh_huge_page(pol))
 			break;
 	}
-	mpol_free(pol);
-	if (count >= nr_huge_pages)
+	if (count >= nr_huge_pages) {
+		mpol_free(pol);
 		return nr_huge_pages;
+	}
 
 	spin_lock(&hugetlb_lock);
 	count = max(count, resv_huge_pages);
 	try_to_free_low(count);
+	set_first_interleave_node(cpuset_current_mems_allowed);
 	while (count < nr_huge_pages) {
-		struct page *page = dequeue_huge_page(NULL, 0);
+		struct page *page = dequeue_huge_page(pol);
 		if (!page)
 			break;
 		update_and_free_page(page_to_nid(page), page);
 	}
 	spin_unlock(&hugetlb_lock);
+	mpol_free(pol);
 	return nr_huge_pages;
 }
 
-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
