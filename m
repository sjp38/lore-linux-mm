Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l86IRA9n025116
	for <linux-mm@kvack.org>; Thu, 6 Sep 2007 14:27:10 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l86IR6Hp447538
	for <linux-mm@kvack.org>; Thu, 6 Sep 2007 12:27:06 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l86IR57l015133
	for <linux-mm@kvack.org>; Thu, 6 Sep 2007 12:27:06 -0600
Date: Thu, 6 Sep 2007 11:27:04 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH 3/4] hugetlb: interleave dequeueing of huge pages
Message-ID: <20070906182704.GC7779@us.ibm.com>
References: <20070906182134.GA7779@us.ibm.com> <20070906182430.GB7779@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070906182430.GB7779@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: wli@holomorphy.com, agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, when shrinking the hugetlb pool, we free all of the pages on
node 0, then all the pages on node 1, etc. Instead, we interleave over
the nodes with memory. If some particularly node should be cleared
first, the to-be-introduced sysfs allocator can be used for
finer-grained control. This also helps with keeping the pool balanced as
we change the pool at run-time.

Tested on 4-node ppc64, 2-node ia64 and 4-node x86_64.

Before, on the same ppc64 box as 1/4:

Trying to resize the pool to 200
Node 0 HugePages_Free:     53
Node 1 HugePages_Free:     53
Node 2 HugePages_Free:     53
Node 3 HugePages_Free:     41
Done.     200 free
Trying to resize the pool back to     100
Node 0 HugePages_Free:      0
Node 1 HugePages_Free:      6
Node 2 HugePages_Free:     53
Node 3 HugePages_Free:     41
Done.     100 free

After:

Trying to resize the pool to 200
Node 0 HugePages_Free:     53
Node 1 HugePages_Free:     52
Node 2 HugePages_Free:     52
Node 3 HugePages_Free:     43
Done.     200 free
Trying to resize the pool back to     100
Node 0 HugePages_Free:     28
Node 1 HugePages_Free:     27
Node 2 HugePages_Free:     27
Node 3 HugePages_Free:     18
Done.     100 free

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index cc875c6..6a732bb 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -66,11 +66,56 @@ static void enqueue_huge_page(struct page *page)
 	free_huge_pages_node[nid]++;
 }
 
-static struct page *dequeue_huge_page(struct vm_area_struct *vma,
+static struct page *dequeue_huge_page_node(int nid)
+{
+	struct page *page;
+
+	page = list_entry(hugepage_freelists[nid].next,
+					struct page, lru);
+	list_del(&page->lru);
+	free_huge_pages--;
+	free_huge_pages_node[nid]--;
+	return page;
+}
+
+static struct page *dequeue_huge_page(void)
+{
+	static int nid = -1;
+	struct page *page = NULL;
+	int start_nid;
+	int next_nid;
+
+	if (nid < 0)
+		nid = first_node(node_states[N_HIGH_MEMORY]);
+	start_nid = nid;
+
+	do {
+		if (!list_empty(&hugepage_freelists[nid]))
+			page = dequeue_huge_page_node(nid);
+		/*
+		 * Use a helper variable to find the next node and then
+		 * copy it back to nid nid afterwards: otherwise there's
+		 * a window in which a racer might pass invalid nid
+		 * MAX_NUMNODES to dequeue_huge_page_node. But we don't
+		 * need to use a spin_lock here: it really doesn't
+		 * matter if occasionally a racer chooses the same nid
+		 * as we do.  Move nid forward in the mask even if we
+		 * just successfully allocated a hugepage so that the
+		 * next caller frees hugepages on the next node.
+		 */
+		next_nid = next_node(nid, node_states[N_HIGH_MEMORY]);
+		if (next_nid == MAX_NUMNODES)
+			next_nid = first_node(node_states[N_HIGH_MEMORY]);
+		nid = next_nid;
+	} while (!page && nid != start_nid);
+
+	return page;
+}
+
+static struct page *dequeue_huge_page_vma(struct vm_area_struct *vma,
 				unsigned long address)
 {
 	int nid;
-	struct page *page = NULL;
 	struct zonelist *zonelist = huge_zonelist(vma, address,
 						htlb_alloc_mask);
 	struct zone **z;
@@ -79,15 +124,10 @@ static struct page *dequeue_huge_page(struct vm_area_struct *vma,
 		nid = zone_to_nid(*z);
 		if (cpuset_zone_allowed_softwall(*z, htlb_alloc_mask) &&
 		    !list_empty(&hugepage_freelists[nid])) {
-			page = list_entry(hugepage_freelists[nid].next,
-					  struct page, lru);
-			list_del(&page->lru);
-			free_huge_pages--;
-			free_huge_pages_node[nid]--;
-			break;
+			return dequeue_huge_page_node(nid);
 		}
 	}
-	return page;
+	return NULL;
 }
 
 static void free_huge_page(struct page *page)
@@ -167,7 +207,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	else if (free_huge_pages <= resv_huge_pages)
 		goto fail;
 
-	page = dequeue_huge_page(vma, addr);
+	page = dequeue_huge_page_vma(vma, addr);
 	if (!page)
 		goto fail;
 
@@ -275,7 +315,7 @@ static unsigned long set_max_huge_pages(unsigned long count)
 	count = max(count, resv_huge_pages);
 	try_to_free_low(count);
 	while (count < nr_huge_pages) {
-		struct page *page = dequeue_huge_page(NULL, 0);
+		struct page *page = dequeue_huge_page();
 		if (!page)
 			break;
 		update_and_free_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
