Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l77HFQjD029048
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 13:15:26 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l77HFQO3477054
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 13:15:26 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l77HFP3a029700
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 13:15:26 -0400
Date: Tue, 7 Aug 2007 10:15:25 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 2/2][V10] hugetlb: fix pool allocation with memoryless nodes
Message-ID: <20070807171525.GZ15714@us.ibm.com>
References: <20070807171432.GY15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070807171432.GY15714@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: anton@samba.org, lee.schermerhorn@hp.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[V10] hugetlb: fix pool allocation with empty nodes

Anton found a problem with the hugetlb pool allocation when some nodes
have no memory (http://marc.info/?l=linux-mm&m=118133042025995&w=2). Lee
worked on versions that tried to fix it, but none were accepted.
Christoph has created a set of patches which allow for GFP_THISNODE
allocations to fail if the node has no memory and for exporting a
nodemask indicating which nodes have memory. Simply interleave across
this nodemask rather than the online nodemask.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 17a377e..1f872ca 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -129,7 +129,7 @@ static int alloc_fresh_huge_page(void)
 	int ret = 0;
 
 	if (nid < 0)
-		nid = first_node(node_online_map);
+		nid = first_node(node_states[N_HIGH_MEMORY]);
 	start_nid = nid;
 
 	do {
@@ -147,9 +147,9 @@ static int alloc_fresh_huge_page(void)
 		 * successfully allocated a hugepage so that the next
 		 * caller gets hugepages on the next node.
 		 */
-		next_nid = next_node(nid, node_online_map);
+		next_nid = next_node(nid, node_states[N_HIGH_MEMORY]);
 		if (next_nid == MAX_NUMNODES)
-			next_nid = first_node(node_online_map);
+			next_nid = first_node(node_states[N_HIGH_MEMORY]);
 		nid = next_nid;
 	} while (!page && nid != start_nid);
 
-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
