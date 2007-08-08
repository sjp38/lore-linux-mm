Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l781urKx003452
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 21:56:53 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l781urOd215510
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 19:56:53 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l781uq5N010090
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 19:56:53 -0600
Date: Tue, 7 Aug 2007 18:56:51 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH] hugetlb: interleave dequeueing of huge pages
Message-ID: <20070808015651.GG15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: lee.schermerhorn@hp.com, wli@holomorphy.com, agl@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, when shrinking the hugetlb pool, we free all of the pages on
node 0, then all the pages on node 1, etc. With this patch, we instead
interleave over the nodes with memory. If some particularly node should
be cleared first, the to-be-introduced sysfs allocator can be used for
finer-grained control. This also helps with keeping the pool balanced as
we change the pool at run-time.

I have had a few requests for tying this interleave to the allocation
interleave, but I would like to see this tested first before moving to
that step (that is the first page to be dequeued would be the last page
we allocated, so they would use the same node iterator).

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
Patches on top of

hugetlb: search harder for memory in alloc_fresh_huge_page()
[V10] hugetlb: fix pool allocation with empty nodes

after Christoph's patches are applied to 2.6.23-rc1-mm2.

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c60602d..fbb23d5 100644
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
@@ -168,7 +208,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	else if (free_huge_pages <= resv_huge_pages)
 		goto fail;
 
-	page = dequeue_huge_page(vma, addr);
+	page = dequeue_huge_page_vma(vma, addr);
 	if (!page)
 		goto fail;
 
@@ -276,7 +316,7 @@ static unsigned long set_max_huge_pages(unsigned long count)
 	count = max(count, resv_huge_pages);
 	try_to_free_low(count);
 	while (count < nr_huge_pages) {
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
