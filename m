Subject: [PATCH/RFC] memoryless nodes - fixup uses of node_online_map in
	generic code
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708081638270.17335@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	 <20070727194322.18614.68855.sendpatchset@localhost>
	 <20070731192241.380e93a0.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
	 <20070731200522.c19b3b95.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
	 <20070731203203.2691ca59.akpm@linux-foundation.org>
	 <1185977011.5059.36.camel@localhost>
	 <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
	 <1186085994.5040.98.camel@localhost>
	 <Pine.LNX.4.64.0708021323390.9711@schroedinger.engr.sgi.com>
	 <1186611582.5055.95.camel@localhost>
	 <Pine.LNX.4.64.0708081638270.17335@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 16 Aug 2007 10:17:33 -0400
Message-Id: <1187273853.5900.21.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: ak@suse.de, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Christoph, Andrew:

Here's a cut at fixing up uses of the online node map in generic code.
I'll look at the archs as I get the time, but I thought it worth getting
the ball rolling on the generic fixes.

Note questions about use of N_HIGH_MEMORY in find_next_best_node() and
population of N_HIGH_MEMORY in early_calculate_totalpages().

Comments?

Lee

-----------------
PATCH/RFC Fix generic usage of node_online_map 

Against 2.6.23-rc2-mm2

mm/shmem.c:shmem_parse_mpol()

	Ensure nodelist is subset of nodes with memory.
	Use node_states[N_HIGH_MEMORY] as default for missing
	nodelist for interleave policy.

mm/shmem.c:shmem_fill_super()

	initialize policy_nodes to node_states[N_HIGH_MEMORY]

mm/page-writeback.c:highmem_dirtyable_memory()

	sum over nodes with memory

mm/swap_prefetch.c:clear_last_prefetch_free()
                   clear_last_current_free()

	use nodes with memory for prefetch nodes.
	just in case ...

mm/page_alloc.c:zlc_setup()

	allowednodes - use nodes with memory.

mm/page_alloc.c:default_zonelist_order()

	average over nodes with memory.

mm/page_alloc.c:find_next_best_node()

	skip nodes w/o memory.
	N_HIGH_MEMORY state mask may not be initialized at this time,
	unless we want to depend on early_calculate_totalpages() [see
	below].  Will ZONE_MOVABLE ever be configurable?

mm/page_alloc.c:find_zone_movable_pfns_for_nodes()

	spread kernelcore over nodes with memory.

	This required calling early_calculate_totalpages()
	unconditionally, and populating N_HIGH_MEMORY node
	state therein from nodes in the early_node_map[].
	If we can depend on this, we can eliminate the
	population of N_HIGH_MEMORY mask from __build_all_zonelists()
	and use the N_HIGH_MEMORY mask in find_next_best_node().

mm/mempolicy.c:mpol_check_policy()

	Ensure nodes specified for policy are subset of
	nodes with memory.


Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c      |    2 +-
 mm/page-writeback.c |    2 +-
 mm/page_alloc.c     |   36 ++++++++++++++++++++++++++++--------
 mm/shmem.c          |   13 ++++++++-----
 mm/swap_prefetch.c  |    4 ++--
 5 files changed, 40 insertions(+), 17 deletions(-)

Index: Linux/mm/shmem.c
===================================================================
--- Linux.orig/mm/shmem.c	2007-08-15 10:01:22.000000000 -0400
+++ Linux/mm/shmem.c	2007-08-16 09:48:45.000000000 -0400
@@ -971,7 +971,7 @@ static inline int shmem_parse_mpol(char 
 		*nodelist++ = '\0';
 		if (nodelist_parse(nodelist, *policy_nodes))
 			goto out;
-		if (!nodes_subset(*policy_nodes, node_online_map))
+		if (!nodes_subset(*policy_nodes, node_states[N_HIGH_MEMORY]))
 			goto out;
 	}
 	if (!strcmp(value, "default")) {
@@ -996,9 +996,11 @@ static inline int shmem_parse_mpol(char 
 			err = 0;
 	} else if (!strcmp(value, "interleave")) {
 		*policy = MPOL_INTERLEAVE;
-		/* Default to nodes online if no nodelist */
+		/*
+		 * Default to online nodes with memory if no nodelist
+		 */
 		if (!nodelist)
-			*policy_nodes = node_online_map;
+			*policy_nodes = node_states[N_HIGH_MEMORY];
 		err = 0;
 	}
 out:
@@ -1060,7 +1062,8 @@ shmem_alloc_page(gfp_t gfp, struct shmem
 	return page;
 }
 #else
-static inline int shmem_parse_mpol(char *value, int *policy, nodemask_t *policy_nodes)
+static inline int shmem_parse_mpol(char *value, int *policy,
+						nodemask_t *policy_nodes)
 {
 	return 1;
 }
@@ -2239,7 +2242,7 @@ static int shmem_fill_super(struct super
 	unsigned long blocks = 0;
 	unsigned long inodes = 0;
 	int policy = MPOL_DEFAULT;
-	nodemask_t policy_nodes = node_online_map;
+	nodemask_t policy_nodes = node_states[N_HIGH_MEMORY];
 
 #ifdef CONFIG_TMPFS
 	/*
Index: Linux/mm/page-writeback.c
===================================================================
--- Linux.orig/mm/page-writeback.c	2007-08-15 10:01:22.000000000 -0400
+++ Linux/mm/page-writeback.c	2007-08-15 10:13:49.000000000 -0400
@@ -126,7 +126,7 @@ static unsigned long highmem_dirtyable_m
 	int node;
 	unsigned long x = 0;
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_HIGH_MEMORY) {
 		struct zone *z =
 			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
 
Index: Linux/mm/swap_prefetch.c
===================================================================
--- Linux.orig/mm/swap_prefetch.c	2007-08-15 10:01:22.000000000 -0400
+++ Linux/mm/swap_prefetch.c	2007-08-15 10:13:49.000000000 -0400
@@ -249,7 +249,7 @@ static void clear_last_prefetch_free(voi
 	 * Reset the nodes suitable for prefetching to all nodes. We could
 	 * update the data to take into account memory hotplug if desired..
 	 */
-	sp_stat.prefetch_nodes = node_online_map;
+	sp_stat.prefetch_nodes = node_states[N_HIGH_MEMORY];
 	for_each_node_mask(node, sp_stat.prefetch_nodes) {
 		struct node_stats *ns = &sp_stat.node[node];
 
@@ -261,7 +261,7 @@ static void clear_current_prefetch_free(
 {
 	int node;
 
-	sp_stat.prefetch_nodes = node_online_map;
+	sp_stat.prefetch_nodes = node_states[N_HIGH_MEMORY];
 	for_each_node_mask(node, sp_stat.prefetch_nodes) {
 		struct node_stats *ns = &sp_stat.node[node];
 
Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-08-15 10:05:41.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-08-16 09:45:47.000000000 -0400
@@ -1302,7 +1302,7 @@ int zone_watermark_ok(struct zone *z, in
  *
  * If the zonelist cache is present in the passed in zonelist, then
  * returns a pointer to the allowed node mask (either the current
- * tasks mems_allowed, or node_online_map.)
+ * tasks mems_allowed, or node_states[N_HIGH_MEMORY].)
  *
  * If the zonelist cache is not available for this zonelist, does
  * nothing and returns NULL.
@@ -1331,7 +1331,7 @@ static nodemask_t *zlc_setup(struct zone
 
 	allowednodes = !in_interrupt() && (alloc_flags & ALLOC_CPUSET) ?
 					&cpuset_current_mems_allowed :
-					&node_online_map;
+					&node_states[N_HIGH_MEMORY];
 	return allowednodes;
 }
 
@@ -2128,8 +2128,17 @@ static int find_next_best_node(int node,
 	}
 
 	for_each_online_node(n) {
+		pg_data_t *pgdat = NODE_DATA(n);
 		cpumask_t tmp;
 
+		/*
+		 * skip nodes w/o memory.
+		 * Note:  N_HIGH_MEMORY state not guaranteed to be
+		 *        populated yet.
+		 */
+		if (pgdat->node_present_pages)
+			continue;
+
 		/* Don't want a node to appear more than once */
 		if (node_isset(n, *used_node_mask))
 			continue;
@@ -2264,7 +2273,8 @@ static int default_zonelist_order(void)
   	 * If there is a node whose DMA/DMA32 memory is very big area on
  	 * local memory, NODE_ORDER may be suitable.
          */
-	average_size = total_size / (num_online_nodes() + 1);
+	average_size = total_size /
+				(nodes_weight(node_states[N_HIGH_MEMORY]) + 1);
 	for_each_online_node(nid) {
 		low_kmem_size = 0;
 		total_size = 0;
@@ -3750,14 +3760,24 @@ unsigned long __init find_max_pfn_with_a
 	return max_pfn;
 }
 
+/*
+ * early_calculate_totalpages()
+ * Sum pages in active regions for movable zone.
+ * Populate N_HIGH_MEMORY for calculating usable_nodes.
+ */
 static unsigned long __init early_calculate_totalpages(void)
 {
 	int i;
 	unsigned long totalpages = 0;
 
-	for (i = 0; i < nr_nodemap_entries; i++)
-		totalpages += early_node_map[i].end_pfn -
+	for (i = 0; i < nr_nodemap_entries; i++) {
+		unsigned long pages = early_node_map[i].end_pfn -
 						early_node_map[i].start_pfn;
+		totalpages += pages;
+		if (pages)
+			node_set_state(early_node_map[i].nid,
+						N_HIGH_MEMORY);
+	}
 
 	return totalpages;
 }
@@ -3773,7 +3793,8 @@ void __init find_zone_movable_pfns_for_n
 	int i, nid;
 	unsigned long usable_startpfn;
 	unsigned long kernelcore_node, kernelcore_remaining;
-	int usable_nodes = num_online_nodes();
+	unsigned long totalpages = early_calculate_totalpages();
+	int usable_nodes = nodes_weight(node_states[N_HIGH_MEMORY]);
 
 	/*
 	 * If movablecore was specified, calculate what size of
@@ -3784,7 +3805,6 @@ void __init find_zone_movable_pfns_for_n
 	 * what movablecore would have allowed.
 	 */
 	if (required_movablecore) {
-		unsigned long totalpages = early_calculate_totalpages();
 		unsigned long corepages;
 
 		/*
@@ -3809,7 +3829,7 @@ void __init find_zone_movable_pfns_for_n
 restart:
 	/* Spread kernelcore memory as evenly as possible throughout nodes */
 	kernelcore_node = required_kernelcore / usable_nodes;
-	for_each_online_node(nid) {
+	for_each_node_state(nid, N_HIGH_MEMORY) {
 		/*
 		 * Recalculate kernelcore_node if the division per node
 		 * now exceeds what is necessary to satisfy the requested
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-08-15 10:01:22.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-08-16 09:45:47.000000000 -0400
@@ -130,7 +130,7 @@ static int mpol_check_policy(int mode, n
 			return -EINVAL;
 		break;
 	}
-	return nodes_subset(*nodes, node_online_map) ? 0 : -EINVAL;
+ 	return nodes_subset(*nodes, node_states[N_HIGH_MEMORY]) ? 0 : -EINVAL;
 }
 
 /* Generate a custom zonelist for the BIND policy. */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
