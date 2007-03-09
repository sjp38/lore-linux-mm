Date: Fri, 9 Mar 2007 12:53:44 -0800
From: Mark Gross <mgross@linux.intel.com>
Subject: Re: [RFC] [PATCH] Power Managed memory base enabling
Message-ID: <20070309205344.GA16777@linux.intel.com>
Reply-To: mgross@linux.intel.com
References: <20070305181826.GA21515@linux.intel.com> <Pine.LNX.4.64.0703051941310.18703@chino.kir.corp.google.com> <20070306164722.GB22725@linux.intel.com> <Pine.LNX.4.64.0703061838390.13314@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703061838390.13314@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-pm@lists.osdl.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, mark.gross@intel.com, neelam.chandwani@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, Mar 06, 2007 at 06:40:36PM -0800, David Rientjes wrote:
> On Tue, 6 Mar 2007, Mark Gross wrote:
> 
> > Let me give your idea a spin and get back to you. 
> > 
> 
> Something like the following might be a little better.

Thanks!  I've got things cleaned up and working with as many of your
ideas as I could get working.  I liked many of the changes you offered
in the patch you sent to me off list.  

One thing I found was your patch didn't use the SLIT data in computing
the nearest non PM node, and I had to be careful about the difference
between the PM memory PXM bitmap and node id's.  After I accounted for
the not_to_pxm mapping things started working for me.

BTW re basing to 2.6.21rc3mm2, resulted in one 4k allocation in my
PM-zones.  I'll be looking for where that allocation is coming from
after I get this post finished.

--mgross

Singed-off-by: Mark Gross <mark.gross@intel.com>

diff -urN -X linux-2.6.21rc3mm2/Documentation/dontdiff linux-2.6.21rc3mm2/arch/x86_64/mm/numa.c linux-2.6.21rc3mm2-monroe/arch/x86_64/mm/numa.c
--- linux-2.6.21rc3mm2/arch/x86_64/mm/numa.c	2007-03-08 11:14:19.000000000 -0800
+++ linux-2.6.21rc3mm2-monroe/arch/x86_64/mm/numa.c	2007-03-09 10:23:25.000000000 -0800
@@ -155,19 +155,47 @@
 }
 #endif
 
+/* we need a place to save the next start address to use for each node because
+ * we need to allocate the pgdata and bootmem for power managed memory in
+ * non-power managed nodes.  We do this by saving off where we can start
+ * allocating in the nodes and updating them as the boot up proceeds.
+ */
+static unsigned long bootmem_start[MAX_NUMNODES];
+
+
 static void * __init
 early_node_mem(int nodeid, unsigned long start, unsigned long end,
 	      unsigned long size)
 {
-	unsigned long mem = find_e820_area(start, end, size);
+	unsigned long mem;
 	void *ptr;
-	if (mem != -1L)
+	int nid;
+	
+	if (bootmem_start[nodeid] < start) {
+		bootmem_start[nodeid] = start;
+	}
+
+	mem = -1L;
+	nid = nearest_non_pm_node(nodeid);
+	if (nid != nodeid) {
+		if (!node_online(nid))
+			return NULL;
+
+		end = (NODE_DATA(nid)->node_start_pfn +
+			NODE_DATA(nid)->node_spanned_pages)
+				<< PAGE_SHIFT;
+	}
+	mem = find_e820_area(bootmem_start[nid], end, size);
+	if (mem!= -1L) {
+		/* now increment bootmem_start for next call */
+		bootmem_start[nid] = round_up(mem + size, PAGE_SIZE);
 		return __va(mem);
+	}
 	ptr = __alloc_bootmem_nopanic(size,
 				SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS));
 	if (ptr == 0) {
 		printk(KERN_ERR "Cannot find %lu bytes in node %d\n",
-			size, nodeid);
+			size, nid);
 		return NULL;
 	}
 	return ptr;
@@ -179,6 +207,7 @@
 	unsigned long start_pfn, end_pfn, bootmap_pages, bootmap_size, bootmap_start; 
 	unsigned long nodedata_phys;
 	void *bootmap;
+	int non_pm_node = nearest_non_pm_node(nodeid);
 	const int pgdat_size = round_up(sizeof(pg_data_t), PAGE_SIZE);
 
 	start = round_up(start, ZONE_ALIGN); 
@@ -218,8 +247,8 @@
 
 	free_bootmem_with_active_regions(nodeid, end);
 
-	reserve_bootmem_node(NODE_DATA(nodeid), nodedata_phys, pgdat_size); 
-	reserve_bootmem_node(NODE_DATA(nodeid), bootmap_start, bootmap_pages<<PAGE_SHIFT);
+	reserve_bootmem_node(NODE_DATA(non_pm_node), nodedata_phys, pgdat_size);
+	reserve_bootmem_node(NODE_DATA(non_pm_node), bootmap_start, bootmap_pages<<PAGE_SHIFT);
 #ifdef CONFIG_ACPI_NUMA
 	srat_reserve_add_area(nodeid);
 #endif
@@ -230,8 +259,9 @@
 void __init setup_node_zones(int nodeid)
 { 
 	unsigned long start_pfn, end_pfn, memmapsize, limit;
+	int non_pm_node = nearest_non_pm_node(nodeid);
 
- 	start_pfn = node_start_pfn(nodeid);
+	start_pfn = node_start_pfn(nodeid);
  	end_pfn = node_end_pfn(nodeid);
 
 	Dprintk(KERN_INFO "Setting up memmap for node %d %lx-%lx\n",
@@ -242,11 +272,11 @@
 	memmapsize = sizeof(struct page) * (end_pfn-start_pfn);
 	limit = end_pfn << PAGE_SHIFT;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
-	NODE_DATA(nodeid)->node_mem_map = 
-		__alloc_bootmem_core(NODE_DATA(nodeid)->bdata, 
-				memmapsize, SMP_CACHE_BYTES, 
-				round_down(limit - memmapsize, PAGE_SIZE), 
-				limit);
+	NODE_DATA(nodeid)->node_mem_map =
+		__alloc_bootmem_core(NODE_DATA(non_pm_node)->bdata,
+			memmapsize, SMP_CACHE_BYTES,
+			round_down(limit - memmapsize, PAGE_SIZE),
+			limit);
 	printk(KERN_DEBUG "Node %d memmap at 0x%p size %lu first pfn 0x%p\n",
 			nodeid, NODE_DATA(nodeid)->node_mem_map,
 			memmapsize, NODE_DATA(nodeid)->node_mem_map);
@@ -265,7 +295,8 @@
 	for (i = 0; i < NR_CPUS; i++) {
 		if (cpu_to_node[i] != NUMA_NO_NODE)
 			continue;
- 		numa_set_node(i, rr);
+		numa_set_node(i,nearest_non_pm_node(rr));
+		//numa_set_node(i, rr);
 		rr = next_node(rr, node_online_map);
 		if (rr == MAX_NUMNODES)
 			rr = first_node(node_online_map);
diff -urN -X linux-2.6.21rc3mm2/Documentation/dontdiff linux-2.6.21rc3mm2/arch/x86_64/mm/srat.c linux-2.6.21rc3mm2-monroe/arch/x86_64/mm/srat.c
--- linux-2.6.21rc3mm2/arch/x86_64/mm/srat.c	2007-03-08 11:14:19.000000000 -0800
+++ linux-2.6.21rc3mm2-monroe/arch/x86_64/mm/srat.c	2007-03-09 11:00:51.000000000 -0800
@@ -27,6 +27,7 @@
 
 static nodemask_t nodes_parsed __initdata;
 static struct bootnode nodes_add[MAX_NUMNODES];
+static nodemask_t pm_nodes __read_mostly;
 static int found_add_area __initdata;
 int hotadd_percent __initdata = 0;
 
@@ -34,6 +35,9 @@
    from BIOS bugs. */
 #define NODE_MIN_SIZE (4*1024*1024)
 
+/* ACPI bit to represent power management node */
+#define POWER_MANAGEMENT_ACPI_BIT	(1 << 31)
+
 static __init int setup_node(int pxm)
 {
 	return acpi_map_pxm_to_node(pxm);
@@ -298,7 +302,10 @@
 		return;
 	start = ma->base_address;
 	end = start + ma->length;
-	pxm = ma->proximity_domain;
+	pxm = ma->proximity_domain & ~POWER_MANAGEMENT_ACPI_BIT;
+	if (ma->proximity_domain & POWER_MANAGEMENT_ACPI_BIT)
+		node_set(pxm, pm_nodes);
+
 	node = setup_node(pxm);
 	if (node < 0) {
 		printk(KERN_ERR "SRAT: Too many proximity domains.\n");
@@ -486,3 +493,35 @@
 }
 EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
 
+int __power_managed_node(int nid)
+{
+	return node_isset(node_to_pxm(nid), pm_nodes);
+}
+
+int __power_managed_memory_present(void)
+{
+	return !nodes_empty(pm_nodes);
+}
+
+int __nearest_non_pm_node(int nid)
+{
+	int i, dist, closest, temp;
+	
+	if (!__power_managed_node(nid))
+		return nid;
+	dist = closest= 255;
+	for_each_node(i) {
+		if (__power_managed_node(i))
+			continue;
+
+		if (i != nid) {
+			temp = __node_distance(nid, i );
+			if (temp < dist) {
+				closest = i;
+				dist = temp;
+			}
+		}
+	}
+	BUG_ON(closest == 255);
+	return closest;
+}
diff -urN -X linux-2.6.21rc3mm2/Documentation/dontdiff linux-2.6.21rc3mm2/include/asm-x86_64/topology.h linux-2.6.21rc3mm2-monroe/include/asm-x86_64/topology.h
--- linux-2.6.21rc3mm2/include/asm-x86_64/topology.h	2007-03-08 11:14:20.000000000 -0800
+++ linux-2.6.21rc3mm2-monroe/include/asm-x86_64/topology.h	2007-03-09 10:23:25.000000000 -0800
@@ -18,6 +18,13 @@
 /* #else fallback version */
 #endif
 
+extern int __power_managed_node(int);
+extern int __power_managed_memory_present(void);
+extern int __nearest_non_pm_node(int);
+#define power_managed_node(nid)		__power_managed_node(nid)
+#define power_managed_memory_present()	__power_managed_memory_present()
+#define nearest_non_pm_node(nid)	__nearest_non_pm_node(nid)
+
 #define cpu_to_node(cpu)		(cpu_to_node[cpu])
 #define parent_node(node)		(node)
 #define node_to_first_cpu(node) 	(first_cpu(node_to_cpumask[node]))
diff -urN -X linux-2.6.21rc3mm2/Documentation/dontdiff linux-2.6.21rc3mm2/include/linux/topology.h linux-2.6.21rc3mm2-monroe/include/linux/topology.h
--- linux-2.6.21rc3mm2/include/linux/topology.h	2007-03-08 11:14:08.000000000 -0800
+++ linux-2.6.21rc3mm2-monroe/include/linux/topology.h	2007-03-09 10:23:25.000000000 -0800
@@ -67,6 +67,24 @@
 #ifndef PENALTY_FOR_NODE_WITH_CPUS
 #define PENALTY_FOR_NODE_WITH_CPUS	(1)
 #endif
+#ifndef power_managed_node
+static inline int power_managed_node(int nid)
+{
+	return 0;
+}
+#endif
+#ifndef power_managed_memory_present
+static inline int power_managed_memory_present(void)
+{
+	return 0;
+}
+#endif
+#ifndef nearest_non_pm_node
+static inline int nearest_non_pm_node(int nid)
+{
+	return nid;
+}
+#endif
 
 /*
  * Below are the 3 major initializers used in building sched_domains:
diff -urN -X linux-2.6.21rc3mm2/Documentation/dontdiff linux-2.6.21rc3mm2/mm/bootmem.c linux-2.6.21rc3mm2-monroe/mm/bootmem.c
--- linux-2.6.21rc3mm2/mm/bootmem.c	2007-02-04 10:44:54.000000000 -0800
+++ linux-2.6.21rc3mm2-monroe/mm/bootmem.c	2007-03-09 10:23:25.000000000 -0800
@@ -417,11 +417,14 @@
 void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
 				      unsigned long goal)
 {
-	bootmem_data_t *bdata;
 	void *ptr;
+	int i;
 
-	list_for_each_entry(bdata, &bdata_list, list) {
-		ptr = __alloc_bootmem_core(bdata, size, align, goal, 0);
+	for_each_online_node(i) {
+		if (power_managed_node(i))
+			continue;
+		ptr = __alloc_bootmem_core(NODE_DATA(i)->bdata, size,
+					align, goal, 0);
 		if (ptr)
 			return ptr;
 	}
@@ -463,12 +466,14 @@
 void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
 				  unsigned long goal)
 {
-	bootmem_data_t *bdata;
 	void *ptr;
+	int i;
 
-	list_for_each_entry(bdata, &bdata_list, list) {
-		ptr = __alloc_bootmem_core(bdata, size, align, goal,
-						ARCH_LOW_ADDRESS_LIMIT);
+	for_each_online_node(i) {
+		if (power_managed_node(i))
+			continue;
+		ptr = __alloc_bootmem_core(NODE_DATA(i)->bdata, size, align,
+					goal, ARCH_LOW_ADDRESS_LIMIT);
 		if (ptr)
 			return ptr;
 	}
diff -urN -X linux-2.6.21rc3mm2/Documentation/dontdiff linux-2.6.21rc3mm2/mm/mempolicy.c linux-2.6.21rc3mm2-monroe/mm/mempolicy.c
--- linux-2.6.21rc3mm2/mm/mempolicy.c	2007-03-08 11:14:20.000000000 -0800
+++ linux-2.6.21rc3mm2-monroe/mm/mempolicy.c	2007-03-09 10:23:25.000000000 -0800
@@ -1609,8 +1609,13 @@
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
diff -urN -X linux-2.6.21rc3mm2/Documentation/dontdiff linux-2.6.21rc3mm2/mm/page_alloc.c linux-2.6.21rc3mm2-monroe/mm/page_alloc.c
--- linux-2.6.21rc3mm2/mm/page_alloc.c	2007-03-08 11:14:20.000000000 -0800
+++ linux-2.6.21rc3mm2-monroe/mm/page_alloc.c	2007-03-09 10:23:25.000000000 -0800
@@ -2600,8 +2600,10 @@
 					* sizeof(wait_queue_head_t);
 
  	if (system_state == SYSTEM_BOOTING) {
+		int nid = nearest_non_pm_node(pgdat->node_id);
+		
 		zone->wait_table = (wait_queue_head_t *)
-			alloc_bootmem_node(pgdat, alloc_size);
+			alloc_bootmem_node(NODE_DATA(nid), alloc_size);
 	} else {
 		/*
 		 * This case means that a zone whose size was 0 gets new memory
@@ -3215,8 +3217,11 @@
 		end = ALIGN(end, MAX_ORDER_NR_PAGES);
 		size =  (end - start) * sizeof(struct page);
 		map = alloc_remap(pgdat->node_id, size);
-		if (!map)
-			map = alloc_bootmem_node(pgdat, size);
+		if (!map) {
+			int nid = nearest_non_pm_node(pgdat->node_id);
+
+			map = alloc_bootmem_node(NODE_DATA(nid), size);
+		}
 		pgdat->node_mem_map = map + (pgdat->node_start_pfn - start);
 		printk(KERN_DEBUG
 			"Node %d memmap at 0x%p size %lu first pfn 0x%p\n",
diff -urN -X linux-2.6.21rc3mm2/Documentation/dontdiff linux-2.6.21rc3mm2/mm/slab.c linux-2.6.21rc3mm2-monroe/mm/slab.c
--- linux-2.6.21rc3mm2/mm/slab.c	2007-03-08 11:14:20.000000000 -0800
+++ linux-2.6.21rc3mm2-monroe/mm/slab.c	2007-03-09 10:23:25.000000000 -0800
@@ -3399,6 +3399,7 @@
 	if (unlikely(nodeid == -1))
 		nodeid = numa_node_id();
 
+	nodeid = nearest_non_pm_node(nodeid);
 	if (unlikely(!cachep->nodelists[nodeid])) {
 		/* Node not bootstrapped yet */
 		ptr = fallback_alloc(cachep, flags);
@@ -3672,6 +3673,7 @@
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
+	nodeid = nearest_non_pm_node(nodeid);
 	return __cache_alloc_node(cachep, flags, nodeid,
 			__builtin_return_address(0));
 }
diff -urN -X linux-2.6.21rc3mm2/Documentation/dontdiff linux-2.6.21rc3mm2/mm/sparse.c linux-2.6.21rc3mm2-monroe/mm/sparse.c
--- linux-2.6.21rc3mm2/mm/sparse.c	2007-02-04 10:44:54.000000000 -0800
+++ linux-2.6.21rc3mm2-monroe/mm/sparse.c	2007-03-09 10:23:25.000000000 -0800
@@ -49,7 +49,8 @@
 	struct mem_section *section = NULL;
 	unsigned long array_size = SECTIONS_PER_ROOT *
 				   sizeof(struct mem_section);
-
+	
+	nid = nearest_non_pm_node(nid);
 	if (slab_is_available())
 		section = kmalloc_node(array_size, GFP_KERNEL, nid);
 	else
@@ -215,6 +216,7 @@
 	struct mem_section *ms = __nr_to_section(pnum);
 	int nid = sparse_early_nid(ms);
 
+	nid = nearest_non_pm_node(nid);
 	map = alloc_remap(nid, sizeof(struct page) * PAGES_PER_SECTION);
 	if (map)
 		return map;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
