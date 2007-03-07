Date: Tue, 6 Mar 2007 18:40:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] [PATCH] Power Managed memory base enabling
In-Reply-To: <20070306164722.GB22725@linux.intel.com>
Message-ID: <Pine.LNX.4.64.0703061838390.13314@chino.kir.corp.google.com>
References: <20070305181826.GA21515@linux.intel.com>
 <Pine.LNX.4.64.0703051941310.18703@chino.kir.corp.google.com>
 <20070306164722.GB22725@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Gross <mgross@linux.intel.com>
Cc: linux-mm@kvack.org, linux-pm@lists.osdl.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, mark.gross@intel.com, neelam.chandwani@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007, Mark Gross wrote:

> Let me give your idea a spin and get back to you. 
> 

Something like the following might be a little better.

 [ You might consider adding this as a configuration option such
   as CONFIG_NODE_POWER_MANAGEMENT so that power_managed_node(nid)
   always returns 0 when this isn't defined in arch/x86_64/Kconfig. ]

		David
---
 arch/x86_64/mm/numa.c         |   59 ++++++++++++++++++++++++++++++++++++++--
 arch/x86_64/mm/srat.c         |    7 +++-
 include/asm-x86_64/numa.h     |    2 +
 include/asm-x86_64/topology.h |    7 +++++
 include/linux/topology.h      |   18 ++++++++++++
 mm/bootmem.c                  |   34 +++++++++++++----------
 mm/mempolicy.c                |    9 +++++-
 mm/page_alloc.c               |   19 ++++++++++++-
 mm/slab.c                     |    7 +++++
 mm/sparse.c                   |    8 +++++
 10 files changed, 146 insertions(+), 24 deletions(-)

diff --git a/arch/x86_64/mm/numa.c b/arch/x86_64/mm/numa.c
--- a/arch/x86_64/mm/numa.c
+++ b/arch/x86_64/mm/numa.c
@@ -11,6 +11,7 @@
 #include <linux/ctype.h>
 #include <linux/module.h>
 #include <linux/nodemask.h>
+#include <linux/acpi.h>
 
 #include <asm/e820.h>
 #include <asm/proto.h>
@@ -159,8 +160,23 @@ static void * __init
 early_node_mem(int nodeid, unsigned long start, unsigned long end,
 	      unsigned long size)
 {
-	unsigned long mem = find_e820_area(start, end, size);
+	unsigned long mem;
 	void *ptr;
+
+	/*
+	 * If this is a power-managed node, we need to allocate this memory
+	 * elsewhere so we remap it, if possible.
+	 */
+	if (power_managed_node(nodeid)) {
+		int new_node = node_remap(nodeid, nodes_parsed, non_pm_nodes);
+		if (nodeid != new_node) {
+			start = NODE_DATA(new_node)->node_start_pfn;
+			end = start + NODE_DATA(new_node)->node_spanned_pages;
+			nodeid = new_node;
+		}
+	}
+	mem = find_e820_area(start, end, size);
+
 	if (mem != -1L)
 		return __va(mem);
 	ptr = __alloc_bootmem_nopanic(size,
@@ -180,6 +196,7 @@ void __init setup_node_bootmem(int nodeid, unsigned long start, unsigned long en
 	unsigned long nodedata_phys;
 	void *bootmap;
 	const int pgdat_size = round_up(sizeof(pg_data_t), PAGE_SIZE);
+	int reserve_nid = nodeid;
 
 	start = round_up(start, ZONE_ALIGN); 
 
@@ -218,6 +235,13 @@ void __init setup_node_bootmem(int nodeid, unsigned long start, unsigned long en
 
 	free_bootmem_with_active_regions(nodeid, end);
 
+	/*
+	 * Make sure we reserve bootmem on a node that is not under power
+	 * management.
+	 */
+	if (power_managed_node(nodeid))
+		reserve_nid = node_remap(nodeid, nodes_parsed, non_pm_nodes);
+
 	reserve_bootmem_node(NODE_DATA(nodeid), nodedata_phys, pgdat_size); 
 	reserve_bootmem_node(NODE_DATA(nodeid), bootmap_start, bootmap_pages<<PAGE_SHIFT);
 #ifdef CONFIG_ACPI_NUMA
@@ -242,6 +266,9 @@ void __init setup_node_zones(int nodeid)
 	memmapsize = sizeof(struct page) * (end_pfn-start_pfn);
 	limit = end_pfn << PAGE_SHIFT;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
+	if (power_managed_node(nodeid))
+		nodeid = node_remap(nodeid, nodes_parsed, non_pm_nodes);
+
 	NODE_DATA(nodeid)->node_mem_map = 
 		__alloc_bootmem_core(NODE_DATA(nodeid)->bdata, 
 				memmapsize, SMP_CACHE_BYTES, 
@@ -255,7 +282,7 @@ void __init setup_node_zones(int nodeid)
 
 void __init numa_init_array(void)
 {
-	int rr, i;
+	int rr, i, nodeid;
 	/* There are unfortunately some poorly designed mainboards around
 	   that only connect memory to a single CPU. This breaks the 1:1 cpu->node
 	   mapping. To avoid this fill in the mapping for all possible
@@ -265,7 +292,11 @@ void __init numa_init_array(void)
 	for (i = 0; i < NR_CPUS; i++) {
 		if (cpu_to_node[i] != NUMA_NO_NODE)
 			continue;
- 		numa_set_node(i, rr);
+		if (power_managed_node(rr))
+			nodeid = node_remap(rr, nodes_parsed, non_pm_nodes);
+		else
+			nodeid = rr;
+ 		numa_set_node(i, nodeid);
 		rr = next_node(rr, node_online_map);
 		if (rr == MAX_NUMNODES)
 			rr = first_node(node_online_map);
@@ -681,3 +712,25 @@ int pfn_valid(unsigned long pfn)
 }
 EXPORT_SYMBOL(pfn_valid);
 #endif
+
+int __power_managed_node(int nid)
+{
+	return !node_isset(node_to_pxm(nid), non_pm_nodes);
+}
+
+int __power_managed_memory_present(void)
+{
+	return !nodes_full(non_pm_nodes);
+}
+
+int __find_closest_non_pm_node(int nid)
+{
+	int node;
+	nodemask_t new_nodes;
+
+	nodes_and(new_nodes, non_pm_nodes, node_online_map);
+	node = next_node(nid, non_pm_nodes);
+	if (node == MAX_NUMNODES)
+		node = first_node(non_pm_nodes);
+	return node;
+}
diff --git a/arch/x86_64/mm/srat.c b/arch/x86_64/mm/srat.c
--- a/arch/x86_64/mm/srat.c
+++ b/arch/x86_64/mm/srat.c
@@ -25,10 +25,11 @@ int acpi_numa __initdata;
 
 static struct acpi_table_slit *acpi_slit;
 
-static nodemask_t nodes_parsed __initdata;
+nodemask_t nodes_parsed __initdata;
 static struct bootnode nodes_add[MAX_NUMNODES];
 static int found_add_area __initdata;
 int hotadd_percent __initdata = 0;
+nodemask_t non_pm_nodes __read_mostly = NODE_MASK_ALL;
 
 /* Too small nodes confuse the VM badly. Usually they result
    from BIOS bugs. */
@@ -298,8 +299,10 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 		return;
 	start = ma->base_address;
 	end = start + ma->length;
-	pxm = ma->proximity_domain;
+	pxm = ma->proximity_domain & 0x0000ffff;
 	node = setup_node(pxm);
+	if (ma->proximity_domain & (1 << 31))
+		node_clear(node, non_pm_nodes);
 	if (node < 0) {
 		printk(KERN_ERR "SRAT: Too many proximity domains.\n");
 		bad_srat();
diff --git a/include/asm-x86_64/numa.h b/include/asm-x86_64/numa.h
--- a/include/asm-x86_64/numa.h
+++ b/include/asm-x86_64/numa.h
@@ -18,6 +18,8 @@ extern int numa_off;
 extern void numa_set_node(int cpu, int node);
 extern void srat_reserve_add_area(int nodeid);
 extern int hotadd_percent;
+extern nodemask_t nodes_parsed __initdata;
+extern nodemask_t non_pm_nodes;
 
 extern unsigned char apicid_to_node[256];
 #ifdef CONFIG_NUMA
diff --git a/include/asm-x86_64/topology.h b/include/asm-x86_64/topology.h
--- a/include/asm-x86_64/topology.h
+++ b/include/asm-x86_64/topology.h
@@ -18,6 +18,13 @@ extern int __node_distance(int, int);
 /* #else fallback version */
 #endif
 
+extern int __power_managed_memory_present(void);
+extern int __power_managed_node(int);
+extern int __find_closest_non_pm_node(int);
+#define power_managed_memory_present()	__power_managed_memory_present()
+#define power_managed_node(nid)		__power_managed_node(nid)
+#define find_closest_non_pm_node(nid)	__find_closest_non_pm_node(nid)
+
 #define cpu_to_node(cpu)		(cpu_to_node[cpu])
 #define parent_node(node)		(node)
 #define node_to_first_cpu(node) 	(first_cpu(node_to_cpumask[node]))
diff --git a/include/linux/topology.h b/include/linux/topology.h
--- a/include/linux/topology.h
+++ b/include/linux/topology.h
@@ -67,6 +67,24 @@
 #ifndef PENALTY_FOR_NODE_WITH_CPUS
 #define PENALTY_FOR_NODE_WITH_CPUS	(1)
 #endif
+#ifndef power_managed_memory_present
+static inline int power_managed_memory_present(void)
+{
+	return 0;
+}
+#endif
+#ifndef power_managed_node
+static inline int power_managed_node(int nid)
+{
+	return 0;
+}
+#endif
+#ifndef find_closest_non_pm_node
+static inline int find_closest_non_pm_node(int nid)
+{
+	return nid;
+}
+#endif
 
 /*
  * Below are the 3 major initializers used in building sched_domains:
diff --git a/mm/bootmem.c b/mm/bootmem.c
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -417,14 +417,16 @@ unsigned long __init free_all_bootmem(void)
 void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
 				      unsigned long goal)
 {
-	bootmem_data_t *bdata;
 	void *ptr;
-
-	list_for_each_entry(bdata, &bdata_list, list) {
-		ptr = __alloc_bootmem_core(bdata, size, align, goal, 0);
-		if (ptr)
-			return ptr;
-	}
+	int i;
+
+	for_each_online_node(i)
+		if (!power_managed_node(i)) {
+			ptr = __alloc_bootmem_core(NODE_DATA(i)->bdata,
+						   size, align, goal, 0);
+			if (ptr)
+				return ptr;
+		}
 	return NULL;
 }
 
@@ -463,15 +465,17 @@ void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
 				  unsigned long goal)
 {
-	bootmem_data_t *bdata;
 	void *ptr;
-
-	list_for_each_entry(bdata, &bdata_list, list) {
-		ptr = __alloc_bootmem_core(bdata, size, align, goal,
-						ARCH_LOW_ADDRESS_LIMIT);
-		if (ptr)
-			return ptr;
-	}
+	int i;
+
+	for_each_online_node(i)
+		if (!power_managed_node(i)) {
+			ptr = __alloc_bootmem_core(NODE_DATA(i)->bdata,
+						   size, align, goal,
+						   ARCH_LOW_ADDRESS_LIMIT);
+			if (ptr)
+				return ptr;
+		}
 
 	/*
 	 * Whoops, we cannot satisfy the allocation request.
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1609,8 +1609,13 @@ void __init numa_policy_init(void)
 	/* Set interleaving policy for system init. This way not all
 	   the data structures allocated at system boot end up in node zero. */
 
-	if (do_set_mempolicy(MPOL_INTERLEAVE, &node_online_map))
-		printk("numa_policy_init: interleaving failed\n");
+	if (power_managed_memory_present()) {
+		if (do_set_mempolicy(MPOL_DEFAULT, &node_online_map))
+			printk("numa_policy_init: default failed\n");
+	} else {
+		if (do_set_mempolicy(MPOL_INTERLEAVE, &node_online_map))
+			printk("numa_policy_init: interleaving failed\n");
+	}
 }
 
 /* Reset policy of current process to default */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2599,6 +2599,14 @@ int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 					* sizeof(wait_queue_head_t);
 
  	if (system_state == SYSTEM_BOOTING) {
+		struct pglist_data *alloc_pgdat = pgdat;
+
+		if (power_managed_node(pgdat->node_id)) {
+			int nid;
+			nid = find_closest_non_pm_node(pgdat->node_id);
+			alloc_pgdat = NODE_DATA(nid);
+		}
+
 		zone->wait_table = (wait_queue_head_t *)
 			alloc_bootmem_node(pgdat, alloc_size);
 	} else {
@@ -3203,6 +3211,7 @@ static void __init alloc_node_mem_map(struct pglist_data *pgdat)
 	if (!pgdat->node_mem_map) {
 		unsigned long size, start, end;
 		struct page *map;
+		struct pglist_data *alloc_pgdat = pgdat;
 
 		/*
 		 * The zone's endpoints aren't required to be MAX_ORDER
@@ -3214,8 +3223,14 @@ static void __init alloc_node_mem_map(struct pglist_data *pgdat)
 		end = ALIGN(end, MAX_ORDER_NR_PAGES);
 		size =  (end - start) * sizeof(struct page);
 		map = alloc_remap(pgdat->node_id, size);
-		if (!map)
-			map = alloc_bootmem_node(pgdat, size);
+		if (!map) {
+			if (power_managed_node(pgdat->node_id)) {
+				int nid;
+				nid = find_closest_non_pm_node(pgdat->node_id);
+				alloc_pgdat = NODE_DATA(nid);
+			}
+			map = alloc_bootmem_node(alloc_pgdat, size);
+		}
 		pgdat->node_mem_map = map + (pgdat->node_start_pfn - start);
 		printk(KERN_DEBUG
 			"Node %d memmap at 0x%p size %lu first pfn 0x%p\n",
diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3399,6 +3399,10 @@ __cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	if (unlikely(nodeid == -1))
 		nodeid = numa_node_id();
 
+	/* We cannot allocate objects to nodes subject to power management */
+	if (power_managed_node(nodeid))
+		nodeid = find_closest_non_pm_node(nodeid);
+
 	if (unlikely(!cachep->nodelists[nodeid])) {
 		/* Node not bootstrapped yet */
 		ptr = fallback_alloc(cachep, flags);
@@ -3672,6 +3676,9 @@ out:
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
+	/* We cannot allocate objects to nodes subject to power management */
+	if (power_managed_node(nodeid))
+		nodeid = find_closest_non_pm_node(nodeid);
 	return __cache_alloc_node(cachep, flags, nodeid,
 			__builtin_return_address(0));
 }
diff --git a/mm/sparse.c b/mm/sparse.c
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -50,6 +50,10 @@ static struct mem_section *sparse_index_alloc(int nid)
 	unsigned long array_size = SECTIONS_PER_ROOT *
 				   sizeof(struct mem_section);
 
+	/* The node we allocate on must not be subject to power management */
+	if (power_managed_node(nid))
+		nid = find_closest_non_pm_node(nid);
+
 	if (slab_is_available())
 		section = kmalloc_node(array_size, GFP_KERNEL, nid);
 	else
@@ -215,6 +219,10 @@ static struct page *sparse_early_mem_map_alloc(unsigned long pnum)
 	struct mem_section *ms = __nr_to_section(pnum);
 	int nid = sparse_early_nid(ms);
 
+	/* The node we allocate on must not be subject to power management */
+	if (power_managed_node(nid))
+		nid = find_closest_non_pm_node(nid);
+
 	map = alloc_remap(nid, sizeof(struct page) * PAGES_PER_SECTION);
 	if (map)
 		return map;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
