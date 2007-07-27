From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:43:42 -0400
Message-Id: <20070727194342.18614.10056.sendpatchset@localhost>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 04/14] OOM: use the N_MEMORY map instead of constructing one on the fly
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[patch 04/14] OOM: use the N_MEMORY map instead of constructing one on the fly

constrained_alloc() builds its own memory map for nodes with memory.
We have that available in node_memory_map now. So simplify the code.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Acked-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Bob Picco <bob.picco@hp.com>

 mm/oom_kill.c |    9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

Index: Linux/mm/oom_kill.c
===================================================================
--- Linux.orig/mm/oom_kill.c	2007-07-26 12:40:17.000000000 -0400
+++ Linux/mm/oom_kill.c	2007-07-27 08:59:31.000000000 -0400
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
+	nodemask_t nodes = node_states[N_MEMORY];
 
 	for (z = zonelist->zones; *z; z++)
 		if (cpuset_zone_allowed_softwall(*z, gfp_mask))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
