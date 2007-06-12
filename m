Message-Id: <20070612205738.548677035@sgi.com>
References: <20070612204843.491072749@sgi.com>
Date: Tue, 12 Jun 2007 13:48:45 -0700
From: clameter@sgi.com
Subject: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
Content-Disposition: inline; filename=gfp_thisnode_fix
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

GFP_THISNODE checks that the zone selected is within the pgdat (node) of the
first zone of a nodelist. That only works if the node has memory. A
memoryless node will have its first zone on another pgdat (node).

Thus GFP_THISNODE may be returning memory on other nodes.
GFP_THISNODE should fail if there is no local memory on a node.

So we add a check to verify that the node specified has memory in
alloc_pages_node(). If the node has no memory then return NULL.

The case of alloc_pages(GFP_THISNODE) is not changed. alloc_pages() (with
no memory policies in effect) is understood to prefer the current node.
If a process is running on a node with no memory then its default allocations
come from the next neighboring node. GFP_THISNODE will then force the memory
to come from that node.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

Index: linux-2.6.22-rc4-mm2/include/linux/gfp.h
===================================================================
--- linux-2.6.22-rc4-mm2.orig/include/linux/gfp.h	2007-06-12 12:33:37.000000000 -0700
+++ linux-2.6.22-rc4-mm2/include/linux/gfp.h	2007-06-12 12:38:37.000000000 -0700
@@ -175,6 +175,13 @@ static inline struct page *alloc_pages_n
 	if (nid < 0)
 		nid = numa_node_id();
 
+	/*
+	 * Check for the special case that GFP_THISNODE is used on a
+	 * memoryless node
+	 */
+	if ((gfp_mask & __GFP_THISNODE) && !node_memory(nid))
+		return NULL;
+
 	return __alloc_pages(gfp_mask, order,
 		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
