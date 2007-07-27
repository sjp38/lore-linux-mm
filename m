From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:43:35 -0400
Message-Id: <20070727194335.18614.78774.sendpatchset@localhost>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 03/14] Memoryless Nodes: Fix interleave behavior
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[patch 3/14] Memoryless Nodes: Fix interleave behavior for memoryless nodes

MPOL_INTERLEAVE currently simply loops over all nodes. Allocations on
memoryless nodes will be redirected to nodes with memory. This results in
an imbalance because the neighboring nodes to memoryless nodes will get significantly
more interleave hits that the rest of the nodes on the system.

We can avoid this imbalance by clearing the nodes in the interleave node
set that have no memory. If we use the node map of the memory nodes
instead of the online nodes then we have only the nodes we want.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Tested-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Bob Picco <bob.picco@hp.com>

 mm/mempolicy.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-07-25 09:29:50.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-07-25 11:36:30.000000000 -0400
@@ -183,7 +183,9 @@ static struct mempolicy *mpol_new(int mo
 	switch (mode) {
 	case MPOL_INTERLEAVE:
 		policy->v.nodes = *nodes;
-		if (nodes_weight(*nodes) == 0) {
+		nodes_and(policy->v.nodes, policy->v.nodes,
+					node_states[N_MEMORY]);
+		if (nodes_weight(policy->v.nodes) == 0) {
 			kmem_cache_free(policy_cache, policy);
 			return ERR_PTR(-EINVAL);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
