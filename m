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
Date: Thu, 16 Aug 2007 17:10:21 -0400
Message-Id: <1187298621.5900.64.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: ak@suse.de, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

A slightly reworked version.  See change log.  

Tested:  printed node masks after __build_all_zonelists.  They all look
OK, except that it appears process_zones() isn't getting called on my
platform, so N_CPU mask is not being populated.  Still investigating.

Lee
------------------------------
PATCH/RFC Fix generic usage of node_online_map - V2

Against 2.6.23-rc2-mm2

V1 -> V2:
+ moved population of N_HIGH_MEMORY node state mask to
  free_area_init_node(), as this is called before we
  build zonelists.  So, we can use this mask in 
  find_next_best_node.  Still need to keep the duplicate
  code in early_calculate_totalpages() for zone movable
  setup.

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

	visit only nodes with memory [N_HIGH_MEMORY mask]
	looking for next best node for fallback zonelists.

mm/page_alloc.c:find_zone_movable_pfns_for_nodes()

	spread kernelcore over nodes with memory.

	This required calling early_calculate_totalpages()
	unconditionally, and populating N_HIGH_MEMORY node
	state therein from nodes in the early_node_map[].
	This duplicates the code in free_area_init_node(), but
	I don't want to depend on this copy if ZONE_MOVABLE 
	might go away, taking early_calculate_totalpages()
	with it.

mm/mempolicy.c:mpol_check_policy()

	Ensure nodes specified for policy are subset of
	nodes with memory.


Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c      |    2 -
 mm/page-writeback.c |    2 -
 mm/page_alloc.c     |   67 ++++++++++++++++++++++++++++++----------------------
 mm/shmem.c          |   13 ++++++----
 mm/swap_prefetch.c  |    4 +--
 5 files changed, 51 insertions(+), 37 deletions(-)

Index: Linux/mm/shmem.c
===================================================================
--- Linux.orig/mm/shmem.c	2007-08-15 10:01:22.000000000 -0400
+++ Linux/mm/shmem.c	2007-08-16 15:03:15.000000000 -0400
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
+++ Linux/mm/page_alloc.c	2007-08-16 15:11:36.000000000 -0400
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
 
@@ -2127,7 +2127,7 @@ static int find_next_best_node(int node,
 		return node;
 	}
 
-	for_each_online_node(n) {
+	for_each_node_state(n, N_HIGH_MEMORY) {
 		cpumask_t tmp;
 
 		/* Don't want a node to appear more than once */
@@ -2264,7 +2264,8 @@ static int default_zonelist_order(void)
   	 * If there is a node whose DMA/DMA32 memory is very big area on
  	 * local memory, NODE_ORDER may be suitable.
          */
-	average_size = total_size / (num_online_nodes() + 1);
+	average_size = total_size /
+				(nodes_weight(node_states[N_HIGH_MEMORY]) + 1);
 	for_each_online_node(nid) {
 		low_kmem_size = 0;
 		total_size = 0;
@@ -2423,20 +2424,6 @@ static void build_zonelist_cache(pg_data
 
 #endif	/* CONFIG_NUMA */
 
-/* Any regular memory on that node ? */
-static void check_for_regular_memory(pg_data_t *pgdat)
-{
-#ifdef CONFIG_HIGHMEM
-	enum zone_type zone_type;
-
-	for (zone_type = 0; zone_type <= ZONE_NORMAL; zone_type++) {
-		struct zone *zone = &pgdat->node_zones[zone_type];
-		if (zone->present_pages)
-			node_set_state(zone_to_nid(zone), N_NORMAL_MEMORY);
-	}
-#endif
-}
-
 /* return values int ....just for stop_machine_run() */
 static int __build_all_zonelists(void *dummy)
 {
@@ -2447,11 +2434,6 @@ static int __build_all_zonelists(void *d
 
 		build_zonelists(pgdat);
 		build_zonelist_cache(pgdat);
-
-		/* Any memory on that node */
-		if (pgdat->node_present_pages)
-			node_set_state(nid, N_HIGH_MEMORY);
-		check_for_regular_memory(pgdat);
 	}
 	return 0;
 }
@@ -3750,14 +3732,24 @@ unsigned long __init find_max_pfn_with_a
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
@@ -3773,7 +3765,8 @@ void __init find_zone_movable_pfns_for_n
 	int i, nid;
 	unsigned long usable_startpfn;
 	unsigned long kernelcore_node, kernelcore_remaining;
-	int usable_nodes = num_online_nodes();
+	unsigned long totalpages = early_calculate_totalpages();
+	int usable_nodes = nodes_weight(node_states[N_HIGH_MEMORY]);
 
 	/*
 	 * If movablecore was specified, calculate what size of
@@ -3784,7 +3777,6 @@ void __init find_zone_movable_pfns_for_n
 	 * what movablecore would have allowed.
 	 */
 	if (required_movablecore) {
-		unsigned long totalpages = early_calculate_totalpages();
 		unsigned long corepages;
 
 		/*
@@ -3809,7 +3801,7 @@ void __init find_zone_movable_pfns_for_n
 restart:
 	/* Spread kernelcore memory as evenly as possible throughout nodes */
 	kernelcore_node = required_kernelcore / usable_nodes;
-	for_each_online_node(nid) {
+	for_each_node_state(nid, N_HIGH_MEMORY) {
 		/*
 		 * Recalculate kernelcore_node if the division per node
 		 * now exceeds what is necessary to satisfy the requested
@@ -3901,6 +3893,20 @@ restart:
 			roundup(zone_movable_pfn[nid], MAX_ORDER_NR_PAGES);
 }
 
+/* Any regular memory on that node ? */
+static void check_for_regular_memory(pg_data_t *pgdat)
+{
+#ifdef CONFIG_HIGHMEM
+	enum zone_type zone_type;
+
+	for (zone_type = 0; zone_type <= ZONE_NORMAL; zone_type++) {
+		struct zone *zone = &pgdat->node_zones[zone_type];
+		if (zone->present_pages)
+			node_set_state(zone_to_nid(zone), N_NORMAL_MEMORY);
+	}
+#endif
+}
+
 /**
  * free_area_init_nodes - Initialise all pg_data_t and zone data
  * @max_zone_pfn: an array of max PFNs for each zone
@@ -3978,6 +3984,11 @@ void __init free_area_init_nodes(unsigne
 		pg_data_t *pgdat = NODE_DATA(nid);
 		free_area_init_node(nid, pgdat, NULL,
 				find_min_pfn_for_node(nid), NULL);
+
+		/* Any memory on that node */
+		if (pgdat->node_present_pages)
+			node_set_state(nid, N_HIGH_MEMORY);
+		check_for_regular_memory(pgdat);
 	}
 }
 
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-08-15 10:01:22.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-08-16 15:03:15.000000000 -0400
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
