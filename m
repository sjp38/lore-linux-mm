Date: Thu, 2 Aug 2007 17:23:49 +0100
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various purposes
Message-ID: <20070802162348.GA23133@skynet.ie>
References: <20070727194316.18614.36380.sendpatchset@localhost> <20070727194322.18614.68855.sendpatchset@localhost> <20070731192241.380e93a0.akpm@linux-foundation.org> <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com> <20070731200522.c19b3b95.akpm@linux-foundation.org> <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com> <20070731203203.2691ca59.akpm@linux-foundation.org> <Pine.LNX.4.64.0707312151400.2894@schroedinger.engr.sgi.com> <20070731220727.1fd4b699.akpm@linux-foundation.org> <Pine.LNX.4.64.0707312214350.2997@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707312214350.2997@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On (31/07/07 22:22), Christoph Lameter didst pronounce:
> On Tue, 31 Jul 2007, Andrew Morton wrote:
> 
> > > Anyone have a 32 bit NUMA system for testing this out?
> > test.kernel.org has a NUMAQ
> 
> Ok someone do this please. SGI still has IA64 issues that need fixing 
> after the merge (nothing works on SN2 it seems) and that takes precedence.
> 

With the pci_create_bus() issue fixed up, I was able to boot on numaq
with the patch from your git tree applied. It survived running kernbench,
tbench and hackbench. Nish is looking closer than I am just to be sure.
For reference, the patch I tested on top of 2.6.23-rc1-mm2 with the pci
problem fixed up is below

diff --git a/Documentation/cpusets.txt b/Documentation/cpusets.txt
index f2c0a68..b875d23 100644
--- a/Documentation/cpusets.txt
+++ b/Documentation/cpusets.txt
@@ -35,7 +35,8 @@ CONTENTS:
 ----------------------
 
 Cpusets provide a mechanism for assigning a set of CPUs and Memory
-Nodes to a set of tasks.
+Nodes to a set of tasks.   In this document "Memory Node" refers to
+an on-line node that contains memory.
 
 Cpusets constrain the CPU and Memory placement of tasks to only
 the resources within a tasks current cpuset.  They form a nested
@@ -220,8 +221,8 @@ and name space for cpusets, with a minimum of additional kernel code.
 The cpus and mems files in the root (top_cpuset) cpuset are
 read-only.  The cpus file automatically tracks the value of
 cpu_online_map using a CPU hotplug notifier, and the mems file
-automatically tracks the value of node_online_map using the
-cpuset_track_online_nodes() hook.
+automatically tracks the value of node_states[N_MEMORY]--i.e.,
+nodes with memory--using the cpuset_track_online_nodes() hook.
 
 
 1.4 What are exclusive cpusets ?
diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
index c58e933..a7be4f2 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -196,7 +196,7 @@ unsigned long uncached_alloc_page(int starting_nid)
 	nid = starting_nid;
 
 	do {
-		if (!node_online(nid))
+		if (!node_state(nid, N_HIGH_MEMORY))
 			continue;
 		uc_pool = &uncached_pools[nid];
 		if (uc_pool->pool == NULL)
@@ -268,7 +268,7 @@ static int __init uncached_init(void)
 {
 	int nid;
 
-	for_each_online_node(nid) {
+	for_each_node_state(nid, N_ONLINE) {
 		uncached_pools[nid].pool = gen_pool_create(PAGE_SHIFT, nid);
 		mutex_init(&uncached_pools[nid].add_chunk_mutex);
 	}
diff --git a/drivers/char/mspec.c b/drivers/char/mspec.c
index c08a415..862747c 100644
--- a/drivers/char/mspec.c
+++ b/drivers/char/mspec.c
@@ -345,7 +345,7 @@ mspec_init(void)
 		is_sn2 = 1;
 		if (is_shub2()) {
 			ret = -ENOMEM;
-			for_each_online_node(nid) {
+			for_each_node_state(nid, N_ONLINE) {
 				int actual_nid;
 				int nasid;
 				unsigned long phys;
diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index 826b15e..9e633ea 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -93,7 +93,7 @@ static inline nodemask_t cpuset_mems_allowed(struct task_struct *p)
 	return node_possible_map;
 }
 
-#define cpuset_current_mems_allowed (node_online_map)
+#define cpuset_current_mems_allowed (node_states[N_HIGH_MEMORY])
 static inline void cpuset_init_current_mems_allowed(void) {}
 static inline void cpuset_update_task_memory_state(void) {}
 #define cpuset_nodes_subset_current_mems_allowed(nodes) (1)
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index bc68dd9..12a90a1 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -98,22 +98,29 @@ struct vm_area_struct;
 
 static inline enum zone_type gfp_zone(gfp_t flags)
 {
+	int base = 0;
+
+#ifdef CONFIG_NUMA
+	if (flags & __GFP_THISNODE)
+		base = MAX_NR_ZONES;
+#endif
+
 #ifdef CONFIG_ZONE_DMA
 	if (flags & __GFP_DMA)
-		return ZONE_DMA;
+		return base + ZONE_DMA;
 #endif
 #ifdef CONFIG_ZONE_DMA32
 	if (flags & __GFP_DMA32)
-		return ZONE_DMA32;
+		return base + ZONE_DMA32;
 #endif
 	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
 			(__GFP_HIGHMEM | __GFP_MOVABLE))
-		return ZONE_MOVABLE;
+		return base + ZONE_MOVABLE;
 #ifdef CONFIG_HIGHMEM
 	if (flags & __GFP_HIGHMEM)
-		return ZONE_HIGHMEM;
+		return base + ZONE_HIGHMEM;
 #endif
-	return ZONE_NORMAL;
+	return base + ZONE_NORMAL;
 }
 
 /*
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3ea68cd..d20cabb 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -324,6 +324,17 @@ struct zone {
 #define MAX_ZONES_PER_ZONELIST (MAX_NUMNODES * MAX_NR_ZONES)
 
 #ifdef CONFIG_NUMA
+
+/*
+ * The NUMA zonelists are doubled becausse we need zonelists that restrict the
+ * allocations to a single node for GFP_THISNODE.
+ *
+ * [0 .. MAX_NR_ZONES -1] 		: Zonelists with fallback
+ * [MAZ_NR_ZONES ... MAZ_ZONELISTS -1]  : No fallback (GFP_THISNODE)
+ */
+#define MAX_ZONELISTS (2 * MAX_NR_ZONES)
+
+
 /*
  * We cache key information from each zonelist for smaller cache
  * footprint when scanning for free pages in get_page_from_freelist().
@@ -389,6 +400,7 @@ struct zonelist_cache {
 	unsigned long last_full_zap;		/* when last zap'd (jiffies) */
 };
 #else
+#define MAX_ZONELISTS MAX_NR_ZONES
 struct zonelist_cache;
 #endif
 
@@ -437,7 +449,7 @@ extern struct page *mem_map;
 struct bootmem_data;
 typedef struct pglist_data {
 	struct zone node_zones[MAX_NR_ZONES];
-	struct zonelist node_zonelists[MAX_NR_ZONES];
+	struct zonelist node_zonelists[MAX_ZONELISTS];
 	int nr_zones;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
 	struct page *node_mem_map;
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 52c54a5..1145f33 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -338,31 +338,84 @@ static inline void __nodes_remap(nodemask_t *dstp, const nodemask_t *srcp,
 #endif /* MAX_NUMNODES */
 
 /*
+ * Bitmasks that are kept for all the nodes.
+ */
+enum node_states {
+	N_POSSIBLE,		/* The node could become online at some point */
+	N_ONLINE,		/* The node is online */
+	N_NORMAL_MEMORY,	/* The node has regular memory */
+	N_HIGH_MEMORY,		/* The node has regular or high memory */
+	N_CPU, 			/* The node has one or more cpus */
+	NR_NODE_STATES
+};
+
+/*
  * The following particular system nodemasks and operations
  * on them manage all possible and online nodes.
  */
 
-extern nodemask_t node_online_map;
-extern nodemask_t node_possible_map;
+extern nodemask_t node_states[NR_NODE_STATES];
 
 #if MAX_NUMNODES > 1
-#define num_online_nodes()	nodes_weight(node_online_map)
-#define num_possible_nodes()	nodes_weight(node_possible_map)
-#define node_online(node)	node_isset((node), node_online_map)
-#define node_possible(node)	node_isset((node), node_possible_map)
-#define first_online_node	first_node(node_online_map)
-#define next_online_node(nid)	next_node((nid), node_online_map)
+static inline int node_state(int node, enum node_states state)
+{
+	return node_isset(node, node_states[state]);
+}
+
+static inline void node_set_state(int node, enum node_states state)
+{
+	__node_set(node, &node_states[state]);
+}
+
+static inline void node_clear_state(int node, enum node_states state)
+{
+	__node_clear(node, &node_states[state]);
+}
+
+static inline int num_node_state(enum node_states state)
+{
+	return nodes_weight(node_states[state]);
+}
+
+#define for_each_node_state(__node, __state) \
+	for_each_node_mask((__node), node_states[__state])
+
+#define first_online_node	first_node(node_states[N_ONLINE])
+#define next_online_node(nid)	next_node((nid), node_states[N_ONLINE])
+
 extern int nr_node_ids;
 #else
-#define num_online_nodes()	1
-#define num_possible_nodes()	1
-#define node_online(node)	((node) == 0)
-#define node_possible(node)	((node) == 0)
+
+static inline int node_state(int node, enum node_states state)
+{
+	return node == 0;
+}
+
+static inline void node_set_state(int node, enum node_states state)
+{
+}
+
+static inline void node_clear_state(int node, enum node_states state)
+{
+}
+
+static inline int num_node_state(enum node_states state)
+{
+	return 1;
+}
+
+#define for_each_node_state(node, __state) \
+	for ( (node) = 0; (node) == 0; (node) = 1)
+
 #define first_online_node	0
 #define next_online_node(nid)	(MAX_NUMNODES)
 #define nr_node_ids		1
+
 #endif
 
+#define node_online_map 	node_states[N_ONLINE]
+#define node_possible_map 	node_states[N_POSSIBLE]
+
 #define any_online_node(mask)			\
 ({						\
 	int node;				\
@@ -372,10 +425,15 @@ extern int nr_node_ids;
 	node;					\
 })
 
-#define node_set_online(node)	   set_bit((node), node_online_map.bits)
-#define node_set_offline(node)	   clear_bit((node), node_online_map.bits)
+#define num_online_nodes()	num_node_state(N_ONLINE)
+#define num_possible_nodes()	num_node_state(N_POSSIBLE)
+#define node_online(node)	node_state((node), N_ONLINE)
+#define node_possible(node)	node_state((node), N_POSSIBLE)
+
+#define node_set_online(node)	   node_set_state((node), N_ONLINE)
+#define node_set_offline(node)	   node_clear_state((node), N_ONLINE)
 
-#define for_each_node(node)	   for_each_node_mask((node), node_possible_map)
-#define for_each_online_node(node) for_each_node_mask((node), node_online_map)
+#define for_each_node(node)	   for_each_node_state(node, N_POSSIBLE)
+#define for_each_online_node(node) for_each_node_state(node, N_ONLINE)
 
 #endif /* __LINUX_NODEMASK_H */
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 57e6448..8b2daac 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -581,26 +581,28 @@ static void guarantee_online_cpus(const struct cpuset *cs, cpumask_t *pmask)
 
 /*
  * Return in *pmask the portion of a cpusets's mems_allowed that
- * are online.  If none are online, walk up the cpuset hierarchy
- * until we find one that does have some online mems.  If we get
- * all the way to the top and still haven't found any online mems,
- * return node_online_map.
+ * are online, with memory.  If none are online with memory, walk
+ * up the cpuset hierarchy until we find one that does have some
+ * online mems.  If we get all the way to the top and still haven't
+ * found any online mems, return node_states[N_HIGH_MEMORY].
  *
  * One way or another, we guarantee to return some non-empty subset
- * of node_online_map.
+ * of node_states[N_HIGH_MEMORY].
  *
  * Call with callback_mutex held.
  */
 
 static void guarantee_online_mems(const struct cpuset *cs, nodemask_t *pmask)
 {
-	while (cs && !nodes_intersects(cs->mems_allowed, node_online_map))
+	while (cs && !nodes_intersects(cs->mems_allowed,
+					node_states[N_HIGH_MEMORY]))
 		cs = cs->parent;
 	if (cs)
-		nodes_and(*pmask, cs->mems_allowed, node_online_map);
+		nodes_and(*pmask, cs->mems_allowed,
+					node_states[N_HIGH_MEMORY]);
 	else
-		*pmask = node_online_map;
-	BUG_ON(!nodes_intersects(*pmask, node_online_map));
+		*pmask = node_states[N_HIGH_MEMORY];
+	BUG_ON(!nodes_intersects(*pmask, node_states[N_HIGH_MEMORY]));
 }
 
 /**
@@ -924,7 +926,10 @@ static int update_nodemask(struct cpuset *cs, char *buf)
 	int fudge;
 	int retval;
 
-	/* top_cpuset.mems_allowed tracks node_online_map; it's read-only */
+	/*
+	 * top_cpuset.mems_allowed tracks node_stats[N_HIGH_MEMORY];
+	 * it's read-only
+	 */
 	if (cs == &top_cpuset)
 		return -EACCES;
 
@@ -941,8 +946,21 @@ static int update_nodemask(struct cpuset *cs, char *buf)
 		retval = nodelist_parse(buf, trialcs.mems_allowed);
 		if (retval < 0)
 			goto done;
+		if (!nodes_intersects(trialcs.mems_allowed,
+						node_states[N_HIGH_MEMORY])) {
+			/*
+			 * error if only memoryless nodes specified.
+			 */
+			retval = -ENOSPC;
+			goto done;
+		}
 	}
-	nodes_and(trialcs.mems_allowed, trialcs.mems_allowed, node_online_map);
+	/*
+	 * Exclude memoryless nodes.  We know that trialcs.mems_allowed
+	 * contains at least one node with memory.
+	 */
+	nodes_and(trialcs.mems_allowed, trialcs.mems_allowed,
+						node_states[N_HIGH_MEMORY]);
 	oldmem = cs->mems_allowed;
 	if (nodes_equal(oldmem, trialcs.mems_allowed)) {
 		retval = 0;		/* Too easy - nothing to do */
@@ -2098,8 +2116,9 @@ static void guarantee_online_cpus_mems_in_subtree(const struct cpuset *cur)
 
 /*
  * The cpus_allowed and mems_allowed nodemasks in the top_cpuset track
- * cpu_online_map and node_online_map.  Force the top cpuset to track
- * whats online after any CPU or memory node hotplug or unplug event.
+ * cpu_online_map and node_states[N_HIGH_MEMORY].  Force the top cpuset to
+ * track what's online after any CPU or memory node hotplug or unplug
+ * event.
  *
  * To ensure that we don't remove a CPU or node from the top cpuset
  * that is currently in use by a child cpuset (which would violate
@@ -2119,7 +2138,7 @@ static void common_cpu_mem_hotplug_unplug(void)
 
 	guarantee_online_cpus_mems_in_subtree(&top_cpuset);
 	top_cpuset.cpus_allowed = cpu_online_map;
-	top_cpuset.mems_allowed = node_online_map;
+	top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
 
 	mutex_unlock(&callback_mutex);
 	mutex_unlock(&manage_mutex);
@@ -2147,8 +2166,9 @@ static int cpuset_handle_cpuhp(struct notifier_block *nb,
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
- * Keep top_cpuset.mems_allowed tracking node_online_map.
- * Call this routine anytime after you change node_online_map.
+ * Keep top_cpuset.mems_allowed tracking node_states[N_HIGH_MEMORY].
+ * Call this routine anytime after you change
+ * node_states[N_HIGH_MEMORY].
  * See also the previous routine cpuset_handle_cpuhp().
  */
 
@@ -2167,7 +2187,7 @@ void cpuset_track_online_nodes(void)
 void __init cpuset_init_smp(void)
 {
 	top_cpuset.cpus_allowed = cpu_online_map;
-	top_cpuset.mems_allowed = node_online_map;
+	top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
 
 	hotcpu_notifier(cpuset_handle_cpuhp, 0);
 }
@@ -2309,7 +2329,7 @@ void cpuset_init_current_mems_allowed(void)
  *
  * Description: Returns the nodemask_t mems_allowed of the cpuset
  * attached to the specified @tsk.  Guaranteed to return some non-empty
- * subset of node_online_map, even if this means going outside the
+ * subset of node_states[N_HIGH_MEMORY], even if this means going outside the
  * tasks cpuset.
  **/
 
diff --git a/kernel/profile.c b/kernel/profile.c
index 5b20fe9..ed407f5 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -346,7 +346,7 @@ static int __devinit profile_cpu_callback(struct notifier_block *info,
 		per_cpu(cpu_profile_flip, cpu) = 0;
 		if (!per_cpu(cpu_profile_hits, cpu)[1]) {
 			page = alloc_pages_node(node,
-					GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
+					GFP_KERNEL | __GFP_ZERO,
 					0);
 			if (!page)
 				return NOTIFY_BAD;
@@ -354,7 +354,7 @@ static int __devinit profile_cpu_callback(struct notifier_block *info,
 		}
 		if (!per_cpu(cpu_profile_hits, cpu)[0]) {
 			page = alloc_pages_node(node,
-					GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
+					GFP_KERNEL | __GFP_ZERO,
 					0);
 			if (!page)
 				goto out_free;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 71b84b4..93957fe 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -185,7 +185,9 @@ static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
 	switch (mode) {
 	case MPOL_INTERLEAVE:
 		policy->v.nodes = *nodes;
-		if (nodes_weight(*nodes) == 0) {
+		nodes_and(policy->v.nodes, policy->v.nodes,
+					node_states[N_HIGH_MEMORY]);
+		if (nodes_weight(policy->v.nodes) == 0) {
 			kmem_cache_free(policy_cache, policy);
 			return ERR_PTR(-EINVAL);
 		}
@@ -494,9 +496,9 @@ static void get_zonemask(struct mempolicy *p, nodemask_t *nodes)
 		*nodes = p->v.nodes;
 		break;
 	case MPOL_PREFERRED:
-		/* or use current node instead of online map? */
+		/* or use current node instead of memory_map? */
 		if (p->v.preferred_node < 0)
-			*nodes = node_online_map;
+			*nodes = node_states[N_HIGH_MEMORY];
 		else
 			node_set(p->v.preferred_node, *nodes);
 		break;
@@ -1617,7 +1619,7 @@ void __init numa_policy_init(void)
 	 * fall back to the largest node if they're all smaller.
 	 */
 	nodes_clear(interleave_nodes);
-	for_each_online_node(nid) {
+	for_each_node_state(nid, N_HIGH_MEMORY) {
 		unsigned long total_pages = node_present_pages(nid);
 
 		/* Preserve the largest node */
@@ -1897,7 +1899,7 @@ int show_numa_map(struct seq_file *m, void *v)
 		seq_printf(m, " huge");
 	} else {
 		check_pgd_range(vma, vma->vm_start, vma->vm_end,
-				&node_online_map, MPOL_MF_STATS, md);
+			&node_states[N_HIGH_MEMORY], MPOL_MF_STATS, md);
 	}
 
 	if (!md->pages)
@@ -1924,7 +1926,7 @@ int show_numa_map(struct seq_file *m, void *v)
 	if (md->writeback)
 		seq_printf(m," writeback=%lu", md->writeback);
 
-	for_each_online_node(n)
+	for_each_node_state(n, N_HIGH_MEMORY)
 		if (md->node[n])
 			seq_printf(m, " N%d=%lu", n, md->node[n]);
 out:
diff --git a/mm/migrate.c b/mm/migrate.c
index 37c73b9..0e3e304 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -979,7 +979,7 @@ asmlinkage long sys_move_pages(pid_t pid, unsigned long nr_pages,
 				goto out;
 
 			err = -ENODEV;
-			if (!node_online(node))
+			if (!node_state(node, N_HIGH_MEMORY))
 				goto out;
 
 			err = -EACCES;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f9b82ad..41b4e36 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -177,14 +177,7 @@ static inline int constrained_alloc(struct zonelist *zonelist, gfp_t gfp_mask)
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
+	nodemask_t nodes = node_states[N_HIGH_MEMORY];
 
 	for (z = zonelist->zones; *z; z++)
 		if (cpuset_zone_allowed_softwall(*z, gfp_mask))
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3da85b8..1d8e4c8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -47,13 +47,14 @@
 #include "internal.h"
 
 /*
- * MCD - HACK: Find somewhere to initialize this EARLY, or make this
- * initializer cleaner
+ * Array of node states.
  */
-nodemask_t node_online_map __read_mostly = { { [0] = 1UL } };
-EXPORT_SYMBOL(node_online_map);
-nodemask_t node_possible_map __read_mostly = NODE_MASK_ALL;
-EXPORT_SYMBOL(node_possible_map);
+nodemask_t node_states[NR_NODE_STATES] __read_mostly = {
+	[N_POSSIBLE] = NODE_MASK_ALL,
+	[N_ONLINE] = { { [0] = 1UL } }
+};
+EXPORT_SYMBOL(node_states);
+
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
 long nr_swap_pages;
@@ -1170,9 +1171,6 @@ zonelist_scan:
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 		zone = *z;
-		if (unlikely(NUMA_BUILD && (gfp_mask & __GFP_THISNODE) &&
-			zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))
-				break;
 		if ((alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				goto try_next_zone;
@@ -1241,7 +1239,10 @@ restart:
 	z = zonelist->zones;  /* the list of zones suitable for gfp_mask */
 
 	if (unlikely(*z == NULL)) {
-		/* Should this ever happen?? */
+		/*
+		 * Happens if we have an empty zonelist as a result of
+		 * GFP_THISNODE being used on a memoryless node
+		 */
 		return NULL;
 	}
 
@@ -1837,6 +1838,22 @@ static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
 }
 
 /*
+ * Build gfp_thisnode zonelists
+ */
+static void build_thisnode_zonelists(pg_data_t *pgdat)
+{
+	enum zone_type i;
+	int j;
+	struct zonelist *zonelist;
+
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		zonelist = pgdat->node_zonelists + MAX_NR_ZONES + i;
+		j = build_zonelists_node(pgdat, zonelist, 0, i);
+		zonelist->zones[j] = NULL;
+	}
+}
+
+/*
  * Build zonelists ordered by zone and nodes within zones.
  * This results in conserving DMA zone[s] until all Normal memory is
  * exhausted, but results in overflowing to remote node while memory
@@ -1940,7 +1957,7 @@ static void build_zonelists(pg_data_t *pgdat)
 	int order = current_zonelist_order;
 
 	/* initialize zonelists */
-	for (i = 0; i < MAX_NR_ZONES; i++) {
+	for (i = 0; i < MAX_ZONELISTS; i++) {
 		zonelist = pgdat->node_zonelists + i;
 		zonelist->zones[0] = NULL;
 	}
@@ -1985,6 +2002,8 @@ static void build_zonelists(pg_data_t *pgdat)
 		/* calculate node order -- i.e., DMA last! */
 		build_zonelists_in_zone_order(pgdat, j);
 	}
+
+	build_thisnode_zonelists(pgdat);
 }
 
 /* Construct the zonelist performance cache - see further mmzone.h */
@@ -2063,10 +2082,23 @@ static void build_zonelist_cache(pg_data_t *pgdat)
 static int __build_all_zonelists(void *dummy)
 {
 	int nid;
+	enum zone_type zone;
 
 	for_each_online_node(nid) {
-		build_zonelists(NODE_DATA(nid));
-		build_zonelist_cache(NODE_DATA(nid));
+		pg_data_t *pgdat = NODE_DATA(nid);
+
+		build_zonelists(pgdat);
+		build_zonelist_cache(pgdat);
+
+		/* Any memory on that node */
+		if (pgdat->node_present_pages)
+			node_set_state(nid, N_HIGH_MEMORY);
+
+		/* Any regular memory on that node ? */
+		for (zone = 0; zone <= ZONE_NORMAL; zone++)
+			if (pgdat->node_zones[zone].present_pages)
+				node_set_state(nid, N_NORMAL_MEMORY);
+
 	}
 	return 0;
 }
@@ -2311,6 +2343,7 @@ static struct per_cpu_pageset boot_pageset[NR_CPUS];
 static int __cpuinit process_zones(int cpu)
 {
 	struct zone *zone, *dzone;
+	int node = cpu_to_node(cpu);
 
 	for_each_zone(zone) {
 
@@ -2318,7 +2351,7 @@ static int __cpuinit process_zones(int cpu)
 			continue;
 
 		zone_pcp(zone, cpu) = kmalloc_node(sizeof(struct per_cpu_pageset),
-					 GFP_KERNEL, cpu_to_node(cpu));
+					 GFP_KERNEL, node);
 		if (!zone_pcp(zone, cpu))
 			goto bad;
 
@@ -2329,6 +2362,7 @@ static int __cpuinit process_zones(int cpu)
 			 	(zone->present_pages / percpu_pagelist_fraction));
 	}
 
+	node_set_state(node, N_CPU);
 	return 0;
 bad:
 	for_each_zone(dzone) {
@@ -2665,10 +2699,8 @@ void __meminit get_pfn_range_for_nid(unsigned int nid,
 		*end_pfn = max(*end_pfn, early_node_map[i].end_pfn);
 	}
 
-	if (*start_pfn == -1UL) {
-		printk(KERN_WARNING "Node %u active with no memory\n", nid);
+	if (*start_pfn == -1UL)
 		*start_pfn = 0;
-	}
 
 	/* Push the node boundaries out if requested */
 	account_node_boundary(nid, start_pfn, end_pfn);
diff --git a/mm/slab.c b/mm/slab.c
index a684778..73adca9 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1565,7 +1565,7 @@ void __init kmem_cache_init(void)
 		/* Replace the static kmem_list3 structures for the boot cpu */
 		init_list(&cache_cache, &initkmem_list3[CACHE_CACHE], node);
 
-		for_each_online_node(nid) {
+		for_each_node_state(nid, N_NORMAL_MEMORY) {
 			init_list(malloc_sizes[INDEX_AC].cs_cachep,
 				  &initkmem_list3[SIZE_AC + nid], nid);
 
@@ -1941,7 +1941,7 @@ static void __init set_up_list3s(struct kmem_cache *cachep, int index)
 {
 	int node;
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_NORMAL_MEMORY) {
 		cachep->nodelists[node] = &initkmem_list3[index + node];
 		cachep->nodelists[node]->next_reap = jiffies +
 		    REAPTIMEOUT_LIST3 +
@@ -2072,7 +2072,7 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep)
 			g_cpucache_up = PARTIAL_L3;
 		} else {
 			int node;
-			for_each_online_node(node) {
+			for_each_node_state(node, N_NORMAL_MEMORY) {
 				cachep->nodelists[node] =
 				    kmalloc_node(sizeof(struct kmem_list3),
 						GFP_KERNEL, node);
@@ -3782,7 +3782,7 @@ static int alloc_kmemlist(struct kmem_cache *cachep)
 	struct array_cache *new_shared;
 	struct array_cache **new_alien = NULL;
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_NORMAL_MEMORY) {
 
                 if (use_alien_caches) {
                         new_alien = alloc_alien_cache(node, cachep->limit);
diff --git a/mm/slub.c b/mm/slub.c
index 6c6d74f..e5fe0a9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1904,7 +1904,7 @@ static void free_kmem_cache_nodes(struct kmem_cache *s)
 {
 	int node;
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = s->node[node];
 		if (n && n != &s->local_node)
 			kmem_cache_free(kmalloc_caches, n);
@@ -1922,7 +1922,7 @@ static int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags)
 	else
 		local_node = 0;
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n;
 
 		if (local_node == node)
@@ -2176,7 +2176,7 @@ static inline int kmem_cache_close(struct kmem_cache *s)
 	flush_all(s);
 
 	/* Attempt to free all objects */
-	for_each_online_node(node) {
+	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		n->nr_partial -= free_list(s, n, &n->partial);
@@ -2471,7 +2471,7 @@ int kmem_cache_shrink(struct kmem_cache *s)
 		return -ENOMEM;
 
 	flush_all(s);
-	for_each_online_node(node) {
+	for_each_node_state(node, N_NORMAL_MEMORY) {
 		n = get_node(s, node);
 
 		if (!n->nr_partial)
@@ -2861,7 +2861,7 @@ static long validate_slab_cache(struct kmem_cache *s)
 		return -ENOMEM;
 
 	flush_all(s);
-	for_each_online_node(node) {
+	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		count += validate_slab_node(s, n, map);
@@ -3081,7 +3081,7 @@ static int list_locations(struct kmem_cache *s, char *buf,
 	/* Push back cpu slabs */
 	flush_all(s);
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 		unsigned long flags;
 		struct page *page;
@@ -3208,7 +3208,7 @@ static unsigned long slab_objects(struct kmem_cache *s,
 		}
 	}
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		if (flags & SO_PARTIAL) {
@@ -3236,7 +3236,7 @@ static unsigned long slab_objects(struct kmem_cache *s,
 
 	x = sprintf(buf, "%lu", total);
 #ifdef CONFIG_NUMA
-	for_each_online_node(node)
+	for_each_node_state(node, N_NORMAL_MEMORY)
 		if (nodes[node])
 			x += sprintf(buf + x, " N%d=%lu",
 					node, nodes[node]);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d419e10..f7fe92d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1674,7 +1674,7 @@ static int __init kswapd_init(void)
 	int nid;
 
 	swap_setup();
-	for_each_online_node(nid)
+	for_each_node_state(nid, N_HIGH_MEMORY)
  		kswapd_run(nid);
 	hotcpu_notifier(cpu_callback, 0);
 	return 0;
@@ -1794,7 +1794,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 
 int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 {
-	cpumask_t mask;
 	int node_id;
 
 	/*
@@ -1831,8 +1830,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	 * as wide as possible.
 	 */
 	node_id = zone_to_nid(zone);
-	mask = node_to_cpumask(node_id);
-	if (!cpus_empty(mask) && node_id != numa_node_id())
+	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
 		return 0;
 	return __zone_reclaim(zone, gfp_mask, order);
 }

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
