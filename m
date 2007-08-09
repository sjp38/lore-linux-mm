Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l790nFbp003644
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 20:49:15 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l790nFXx262576
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 18:49:15 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l790nEmC003567
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 18:49:15 -0600
Date: Wed, 8 Aug 2007 17:49:14 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 2/4] hugetlb: fix pool allocation with empty nodes
Message-ID: <20070809004914.GI16588@us.ibm.com>
References: <20070809004726.GH16588@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070809004726.GH16588@us.ibm.com>
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

---
Note: given that alloc_fresh_huge_page() now interleaves using
GFP_THISNODE, it might be the case that this patch is no longer needed?
Instead, we'll just end up skipping over those memoryless nodes more
when we could just ignore them altogether.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Anton Blanchard <anton@samba.org>
Cc: Lee Schermerhorn <lee.schermerhon@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>
Cc: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7f6ab1b..7ca37f6 100644
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
