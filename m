Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l93Mn6oS009045
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 18:49:06 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l93Mn6nq420894
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 16:49:06 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l93Mn6Q6004836
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 16:49:06 -0600
Date: Wed, 3 Oct 2007 15:49:04 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH 2/2] hugetlb: fix pool allocation with empty nodes
Message-ID: <20071003224904.GC29663@us.ibm.com>
References: <20071003224538.GB29663@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071003224538.GB29663@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: wli@holomorphy.com, anton@samba.org, agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Anton found a problem with the hugetlb pool allocation when some nodes
have no memory (http://marc.info/?l=linux-mm&m=118133042025995&w=2). Lee
worked on versions that tried to fix it, but none were accepted.
Christoph has created a set of patches which allow for GFP_THISNODE
allocations to fail if the node has no memory and for exporting a
nodemask indicating which nodes have memory. Simply interleave across
this nodemask rather than the online nodemask.

Tested on x86 !NUMA, x86 NUMA, x86_64 NUMA, ppc64 NUMA with 2 memoryless
nodes.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
Would it be better to combine this patch directly in 1/2? There is no
functional difference, really, just a matter of 'correctness'. Without
this patch, we'll iterate over nodes that we can't possibly do THISNODE
allocations on. So I guess this falls more into an optimization?

Also, I see that Adam's patches have been pulled in for the next -mm. I
can rebase on top of them and retest to minimise Andrew's work.

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d97508e..4d08cae 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -147,9 +147,10 @@ static int alloc_fresh_huge_page(void)
 		 * if we just successfully allocated a hugepage so that
 		 * the next caller gets hugepages on the next node.
 		 */
-		next_nid = next_node(last_allocated_nid, node_online_map);
+		next_nid = next_node(last_allocated_nid,
+						node_states[N_HIGH_MEMORY]);
 		if (next_nid == MAX_NUMNODES)
-			next_nid = first_node(node_online_map);
+			next_nid = first_node(node_states[N_HIGH_MEMORY]);
 		last_allocated_nid = next_nid;
 	} while (!page && last_allocated_nid != start_nid);
 
@@ -192,7 +193,7 @@ static int __init hugetlb_init(void)
 	for (i = 0; i < MAX_NUMNODES; ++i)
 		INIT_LIST_HEAD(&hugepage_freelists[i]);
 
-	last_allocated_nid = first_node(node_online_map);
+	last_allocated_nid = first_node(node_states[N_HIGH_MEMORY]);
 
 	for (i = 0; i < max_huge_pages; ++i) {
 		if (!alloc_fresh_huge_page())

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
