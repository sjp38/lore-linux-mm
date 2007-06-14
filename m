Message-Id: <20070614075334.761001237@sgi.com>
References: <20070614075026.607300756@sgi.com>
Date: Thu, 14 Jun 2007 00:50:29 -0700
From: clameter@sgi.com
Subject: [RFC 03/13] OOM: use the node_memory_map instead of constructing one on the fly
Content-Disposition: inline; filename=nodeless_oom_kill
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

constrained_alloc() builds its own memory map for nodes with memory.
We have that available in node_memory_map now. So simplify the code.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.22-rc4-mm2/mm/oom_kill.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/oom_kill.c	2007-06-13 23:11:32.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/oom_kill.c	2007-06-13 23:12:39.000000000 -0700
@@ -176,14 +176,7 @@ static inline int constrained_alloc(stru
 {
 #ifdef CONFIG_NUMA
 	struct zone **z;
-	nodemask_t nodes;
-	int node;
-
-	nodes_clear(nodes);
-	/* node has memory ? */
-	for_each_online_node(node)
-		if (NODE_DATA(node)->node_present_pages)
-			node_set(node, nodes);
+	nodemask_t nodes = node_memory_map;
 
 	for (z = zonelist->zones; *z; z++)
 		if (cpuset_zone_allowed_softwall(*z, gfp_mask))

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
