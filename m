Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BNh6xu004992
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 19:43:06 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BNg08V556400
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 19:42:00 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BNg0Vr018620
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 19:42:00 -0400
Date: Mon, 11 Jun 2007 16:41:55 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH v4] Add populated_map to account for memoryless nodes
Message-ID: <20070611234155.GG14458@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <Pine.LNX.4.64.0706111559490.21107@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111559490.21107@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [16:00:39 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > Err, duh -- I was thinking of making this change, but then forgot.
> 
> Now its fine.

Eep, except that we don't initialize node_populated_mask unless we're
NUMA. Also, do you think it's worth adding the comment in mmzone.h that
now now NUMA policies depend on present_pages?

Split up Lee and Anton's original patch
(http://marc.info/?l=linux-mm&m=118133042025995&w=2), to allow for the
populated_map changes to go in on their own.

Add a populated_map nodemask to indicate a node has memory or not. We
have run into a number of issues (in practice and in code) with
assumptions about every node having memory. Having this nodemask allows
us to fix these issues; in particular, THISNODE allocations will come
from the node specified, only, and the INTERLEAVE policy will be able to
do the right thing with memoryless nodes.

In the !NUMA case, we assume the pgdat represents a populated node.
This is needed for follow-on patches which assume the mask works in NUMA
and !NUMA.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f964af6..8e3f43e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -337,6 +337,10 @@ struct zone {
 	 * give them a chance of being in the same cacheline.
 	 */
 	unsigned long		spanned_pages;	/* total size, including holes */
+	/*
+	 * present_pages is assumed to indicate if a NUMA node is
+	 * populated or not
+	 */
 	unsigned long		present_pages;	/* amount of memory (excluding holes) */
 
 	/*
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 52c54a5..c00a249 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -64,12 +64,16 @@
  *
  * int node_online(node)		Is some node online?
  * int node_possible(node)		Is some node possible?
+ * int node_populated(node)		Is some node populated?
  *
  * int any_online_node(mask)		First online node in mask
  *
  * node_set_online(node)		set bit 'node' in node_online_map
  * node_set_offline(node)		clear bit 'node' in node_online_map
  *
+ * node_set_populated(node)		set bit 'node' in node_populated_map
+ * node_not_populated(node)		clear bit 'node' in node_populated_map
+ *
  * for_each_node(node)			for-loop node over node_possible_map
  * for_each_online_node(node)		for-loop node over node_online_map
  *
@@ -344,12 +348,14 @@ static inline void __nodes_remap(nodemask_t *dstp, const nodemask_t *srcp,
 
 extern nodemask_t node_online_map;
 extern nodemask_t node_possible_map;
+extern nodemask_t node_populated_map;
 
 #if MAX_NUMNODES > 1
 #define num_online_nodes()	nodes_weight(node_online_map)
 #define num_possible_nodes()	nodes_weight(node_possible_map)
 #define node_online(node)	node_isset((node), node_online_map)
 #define node_possible(node)	node_isset((node), node_possible_map)
+#define node_populated(node)	node_isset((node), node_populated_map)
 #define first_online_node	first_node(node_online_map)
 #define next_online_node(nid)	next_node((nid), node_online_map)
 extern int nr_node_ids;
@@ -358,6 +364,7 @@ extern int nr_node_ids;
 #define num_possible_nodes()	1
 #define node_online(node)	((node) == 0)
 #define node_possible(node)	((node) == 0)
+#define node_populated(node)	((node) == 0)
 #define first_online_node	0
 #define next_online_node(nid)	(MAX_NUMNODES)
 #define nr_node_ids		1
@@ -375,6 +382,9 @@ extern int nr_node_ids;
 #define node_set_online(node)	   set_bit((node), node_online_map.bits)
 #define node_set_offline(node)	   clear_bit((node), node_online_map.bits)
 
+#define node_set_populated(node)   set_bit((node), node_populated_map.bits)
+#define node_not_populated(node)   clear_bit((node), node_populated_map.bits)
+
 #define for_each_node(node)	   for_each_node_mask((node), node_possible_map)
 #define for_each_online_node(node) for_each_node_mask((node), node_online_map)
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 07cd5ae..526c126 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -54,6 +54,9 @@ nodemask_t node_online_map __read_mostly = { { [0] = 1UL } };
 EXPORT_SYMBOL(node_online_map);
 nodemask_t node_possible_map __read_mostly = NODE_MASK_ALL;
 EXPORT_SYMBOL(node_possible_map);
+nodemask_t node_populated_map __read_mostly = NODE_MASK_NONE;
+EXPORT_SYMBOL(node_populated_map);
+
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
 long nr_swap_pages;
@@ -2299,6 +2302,13 @@ static void build_zonelists(pg_data_t *pgdat)
 		/* calculate node order -- i.e., DMA last! */
 		build_zonelists_in_zone_order(pgdat, j);
 	}
+
+	/*
+	 * record populated zones for use when INTERLEAVE'ing or using
+	 * GFP_THISNODE
+	 */
+	if (pgdat->node_present_pages)
+		node_set_populated(local_node);
 }
 
 /* Construct the zonelist performance cache - see further mmzone.h */
@@ -2360,6 +2370,8 @@ static void build_zonelists(pg_data_t *pgdat)
 
 		zonelist->zones[j] = NULL;
 	}
+
+	node_set_populated(local_node);
 }
 
 /* non-NUMA variant of zonelist performance cache - just NULL zlcache_ptr */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
