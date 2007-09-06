Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l86IOWe2020469
	for <linux-mm@kvack.org>; Thu, 6 Sep 2007 14:24:32 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l86IOW83512348
	for <linux-mm@kvack.org>; Thu, 6 Sep 2007 14:24:32 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l86IOVH9013915
	for <linux-mm@kvack.org>; Thu, 6 Sep 2007 14:24:32 -0400
Date: Thu, 6 Sep 2007 11:24:30 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH 2/4] hugetlb: fix pool allocation with empty nodes
Message-ID: <20070906182430.GB7779@us.ibm.com>
References: <20070906182134.GA7779@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070906182134.GA7779@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: anton@samba.org, wli@holomorphy.com, agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Anton found a problem with the hugetlb pool allocation when some nodes
have no memory (http://marc.info/?l=linux-mm&m=118133042025995&w=2). Lee
worked on versions that tried to fix it, but none were accepted.
Christoph has created a set of patches which allow for GFP_THISNODE
allocations to fail if the node has no memory and for exporting a
nodemask indicating which nodes have memory. Simply interleave across
this nodemask rather than the online nodemask.

Tested on 4-node ppc64, 2-node ia64 and 4-node x86_64.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
My 4-node ppc64 box with memoryless nodes is having issues with
2.6.23-rc4-mm1, so I'm unable to test. Lee, could you give this a spin?

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index edb2100..cc875c6 100644
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
