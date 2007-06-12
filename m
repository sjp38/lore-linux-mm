Message-Id: <20070612205738.782600504@sgi.com>
References: <20070612204843.491072749@sgi.com>
Date: Tue, 12 Jun 2007 13:48:46 -0700
From: clameter@sgi.com
Subject: [patch 3/3] Fix MPOL_INTERLEAVE behavior for memoryless nodes
Content-Disposition: inline; filename=fix_interleave
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

MPOL_INTERLEAVE currently simply loops over all nodes. Allocations on
memoryless nodes will be redirected to nodes with memory. This results in
an imbalance because the neighboring nodes to memoryless nodes will get
significantly more interleave hits that the rest of the nodes.

We can avoid this imbalance by clearing the nodes in the interleave node
set that have no memory.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

Index: linux-2.6.22-rc4-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/mempolicy.c	2007-06-12 13:45:16.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/mempolicy.c	2007-06-12 13:45:31.000000000 -0700
@@ -185,7 +185,8 @@ static struct mempolicy *mpol_new(int mo
 	switch (mode) {
 	case MPOL_INTERLEAVE:
 		policy->v.nodes = *nodes;
-		if (nodes_weight(*nodes) == 0) {
+		nodes_and(policy->v.nodes, policy->v.nodes, node_memory_map);
+		if (nodes_weight(policy->v.nodes) == 0) {
 			kmem_cache_free(policy_cache, policy);
 			return ERR_PTR(-EINVAL);
 		}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
