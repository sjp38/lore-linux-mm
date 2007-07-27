From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:43:29 -0400
Message-Id: <20070727194329.18614.33494.sendpatchset@localhost>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 02/14] Memoryless nodes:  introduce mask of nodes with memory
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[patch 2/14] Memoryless nodes:  introduce mask of nodes with memory

It is necessary to know if nodes have memory since we have recently
begun to add support for memoryless nodes. For that purpose we introduce
a new node state N_MEMORY.

A node has its bit in node_memory_map set if it has memory. If a node
has memory then it has at least one zone defined in its pgdat structure
that is located in the pgdat itself.

N_MEMORY can then be used in various places to insure that we
do the right thing when we encounter a memoryless node.

Signed-off-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Tested-off-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Acked-by: Bob Picco <bob.picco@hp.com>

 include/linux/nodemask.h |    1 +
 mm/page_alloc.c          |    9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

Index: Linux/include/linux/nodemask.h
===================================================================
--- Linux.orig/include/linux/nodemask.h	2007-07-25 11:36:25.000000000 -0400
+++ Linux/include/linux/nodemask.h	2007-07-25 11:36:27.000000000 -0400
@@ -343,6 +343,7 @@ static inline void __nodes_remap(nodemas
 enum node_states {
 	N_POSSIBLE,	/* The node could become online at some point */
 	N_ONLINE,	/* The node is online */
+	N_MEMORY,	/* The node has memory */
 	NR_NODE_STATES
 };
 
Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-07-25 11:36:25.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-07-25 11:36:27.000000000 -0400
@@ -2387,8 +2387,13 @@ static int __build_all_zonelists(void *d
 	int nid;
 
 	for_each_online_node(nid) {
-		build_zonelists(NODE_DATA(nid));
-		build_zonelist_cache(NODE_DATA(nid));
+		pg_data_t *pgdat = NODE_DATA(nid);
+
+		build_zonelists(pgdat);
+		build_zonelist_cache(pgdat);
+
+		if (pgdat->node_present_pages)
+			node_set_state(nid, N_MEMORY);
 	}
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
