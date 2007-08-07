Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l77HEYUa027664
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 13:14:34 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l77HEXeB509408
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 13:14:33 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l77HEXMk028096
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 13:14:33 -0400
Date: Tue, 7 Aug 2007 10:14:32 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 1/2] hugetlb: search harder for memory in alloc_fresh_huge_page()
Message-ID: <20070807171432.GY15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: anton@samba.org, lee.schermerhorn@hp.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, alloc_fresh_huge_page() returns NULL when it is not able to
allocate a huge page on the current node, as specified by its custom
interleave variable. The callers of this function, though, assume that a
failure in alloc_fresh_huge_page() indicates no hugepages can be
allocated on the system period. This might not be the case, for
instance, if we have an uneven NUMA system, and we happen to try to
allocate a hugepage on a node with less memory and fail, while there is
still plenty of free memory on the other nodes.

To correct this, make alloc_fresh_huge_page() search through all online
nodes before deciding no hugepages can be allocated. Add a helper
function for actually allocating the hugepage.

While there are interleave interfaces that could be exported from the
mempolicy layer, that seems like an inappropriate design decision. Work
is needed on a subsystem-level interleaving interface, but I'm still not
quite sure how that should look. Hence the custom interleaving here.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
I split up patch 1/5 into two bits, as they are really two logical
changes. Does this look better, Christoph?

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d7ca59d..17a377e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -101,36 +101,59 @@ static void free_huge_page(struct page *page)
 	spin_unlock(&hugetlb_lock);
 }
 
-static int alloc_fresh_huge_page(void)
+static struct page *alloc_fresh_huge_page_node(int nid)
 {
-	static int prev_nid;
 	struct page *page;
-	int nid;
-
-	/*
-	 * Copy static prev_nid to local nid, work on that, then copy it
-	 * back to prev_nid afterwards: otherwise there's a window in which
-	 * a racer might pass invalid nid MAX_NUMNODES to alloc_pages_node.
-	 * But we don't need to use a spin_lock here: it really doesn't
-	 * matter if occasionally a racer chooses the same nid as we do.
-	 */
-	nid = next_node(prev_nid, node_online_map);
-	if (nid == MAX_NUMNODES)
-		nid = first_node(node_online_map);
-	prev_nid = nid;
 
-	page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
-					HUGETLB_PAGE_ORDER);
+	page = alloc_pages_node(nid,
+		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|__GFP_NOWARN,
+		HUGETLB_PAGE_ORDER);
 	if (page) {
 		set_compound_page_dtor(page, free_huge_page);
 		spin_lock(&hugetlb_lock);
 		nr_huge_pages++;
-		nr_huge_pages_node[page_to_nid(page)]++;
+		nr_huge_pages_node[nid]++;
 		spin_unlock(&hugetlb_lock);
 		put_page(page); /* free it into the hugepage allocator */
-		return 1;
 	}
-	return 0;
+
+	return page;
+}
+
+static int alloc_fresh_huge_page(void)
+{
+	static int nid = -1;
+	struct page *page;
+	int start_nid;
+	int next_nid;
+	int ret = 0;
+
+	if (nid < 0)
+		nid = first_node(node_online_map);
+	start_nid = nid;
+
+	do {
+		page = alloc_fresh_huge_page_node(nid);
+		if (page)
+			ret = 1;
+		/*
+		 * Use a helper variable to find the next node and then
+		 * copy it back to nid nid afterwards: otherwise there's
+		 * a window in which a racer might pass invalid nid
+		 * MAX_NUMNODES to alloc_pages_node.  But we don't need
+		 * to use a spin_lock here: it really doesn't matter if
+		 * occasionally a racer chooses the same nid as we do.
+		 * Move nid forward in the mask even if we just
+		 * successfully allocated a hugepage so that the next
+		 * caller gets hugepages on the next node.
+		 */
+		next_nid = next_node(nid, node_online_map);
+		if (next_nid == MAX_NUMNODES)
+			next_nid = first_node(node_online_map);
+		nid = next_nid;
+	} while (!page && nid != start_nid);
+
+	return ret;
 }
 
 static struct page *alloc_huge_page(struct vm_area_struct *vma,

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
