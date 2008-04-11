Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3BNlavR001765
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 19:47:36 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3BNlaPa190412
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 17:47:36 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3BNlZt4007503
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 17:47:36 -0600
Date: Fri, 11 Apr 2008 16:47:43 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH 3/5] hugetlb: interleave dequeueing of huge pages
Message-ID: <20080411234743.GG19078@us.ibm.com>
References: <20080411234449.GE19078@us.ibm.com> <20080411234712.GF19078@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080411234712.GF19078@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: clameter@sgi.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Currently, when shrinking the hugetlb pool, we free all of the pages on
node 0, then all the pages on node 1, etc. With this patch we instead
interleave over the nodes with memory. If some particularly node should
be cleared first, the to-be-introduced sysfs allocator can be used for
finer-grained control. This also helps with keeping the pool balanced as
we change the pool at run-time.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d35b087..18ece9e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -87,15 +87,32 @@ static struct page *dequeue_huge_page_node(struct vm_area_struct *vma,
 
 static struct page *dequeue_huge_page(void)
 {
-	int nid;
 	struct page *page = NULL;
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
 
-	for (nid = 0; nid < MAX_NUMNODES; ++nid) {
-		if (!list_empty(&hugepage_freelists[nid])) {
-			page = dequeue_huge_page_node(NULL, nid);
-			break;
-		}
-	}
 	return page;
 }
 

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
