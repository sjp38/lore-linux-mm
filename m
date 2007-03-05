Date: Mon, 5 Mar 2007 10:18:26 -0800
From: Mark Gross <mgross@linux.intel.com>
Subject: [RFC] [PATCH] Power Managed memory base enabling
Message-ID: <20070305181826.GA21515@linux.intel.com>
Reply-To: mgross@linux.intel.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-pm@lists.osdl.org
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, mark.gross@intel.com, neelam.chandwani@intel.com
List-ID: <linux-mm.kvack.org>

The following patch is to help enable both allocation and access based
memory power optimization policies for systems that have the capability
to put sticks of memory selectively into lower power states based on
workload requirement.

To be clear PM-memory will not be useful unless you have workloads that
can take advantage of it.  The identified workloads are not desktop
workloads.  However; there is a non-zero number of interested users with
applicable workloads that make pushing the enabling patches out to the
community worth while.  These workloads tend to be within network
elements and servers where memory utilization tracks traffic load.  

This patch is very simple.  It is independent of the ongoing
anti-fragmentation, page migration and hot remove activities.  It should
coexist and be complimentary to those.

The goals of this patch are:
* provide a method for identifying power managed memory that could change
state at runtime under policy manager and OS control.
* avoid start up allocations from putting kernel memory structures into
such memory at boot time.
* be minimal and transparent for platforms without such memory.

It makes use of the existing NUMA implementation.  

It implements a convention on the 4 bytes of "Proximity Domain ID"
within the SRAT memory affinity structure as defined in ACPI3.0a.  If
bit 31 is set, then the memory range represented by that PXM is assumed
to be power managed.  We are working on defining a "standard" for
identifying such memory areas as power manageable and progress committee
based.  

We are going with the above convention for the time being as it doesn't
violate ACPI specifications.  Some time in the future after the
committees are finished some of this code may need to be updated.

To exercise the capability on a platform with PM-memory, you will still
need to include a policy manager with some code to trigger the state
changes to enable transition into and out of a low power state. 

More will be done, but for now we would like to get this base enabling
into the upstream kernel as an initial step.

Thanks,

--mgross 

Signed-off-by: Mark Gross <mark.gross@intel.com>



diff -urN -X linux-2.6.20-mm2/Documentation/dontdiff linux-2.6.20-mm2/arch/x86_64/mm/numa.c linux-2.6.20-mm2-monroe/arch/x86_64/mm/numa.c
--- linux-2.6.20-mm2/arch/x86_64/mm/numa.c	2007-02-23 11:20:38.000000000 -0800
+++ linux-2.6.20-mm2-monroe/arch/x86_64/mm/numa.c	2007-03-02 15:15:53.000000000 -0800
@@ -156,12 +156,55 @@
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
+	if (bootmem_start[nodeid] <= start) {
+		bootmem_start[nodeid] = start;
+	}
+
+	mem = -1L;
+	if (power_managed_node(nodeid)) {
+		int non_pm_node = find_closest_non_pm_node(nodeid);
+
+		if (!node_online(non_pm_node)) {
+			return NULL; /* expect nodeid to get setup on the next
+					pass of setup_node_boot_mem after
+					non_pm_node is online*/
+		} else {
+			/* We set up the allocation in the non_pm_node
+			 * get the end of non_pm_node boot allocations
+			 * allocate from there.
+			 */
+			unsigned int non_pm_end;
+
+			non_pm_end = (NODE_DATA(non_pm_node)->node_start_pfn +
+				NODE_DATA(non_pm_node)->node_spanned_pages)
+					<< PAGE_SHIFT;
+
+			mem = find_e820_area(bootmem_start[non_pm_node],
+					non_pm_end, size);
+			/* now increment bootmem_start for next call */
+			if (mem!= -1L)
+				bootmem_start[non_pm_node] =
+					round_up(mem + size, PAGE_SIZE);
+		}
+	} else {
+		mem = find_e820_area(bootmem_start[nodeid], end, size);
+		if (mem!= -1L)
+			bootmem_start[nodeid] = round_up(mem + size, PAGE_SIZE);
+	}	
 	if (mem != -1L)
 		return __va(mem);
 	ptr = __alloc_bootmem_nopanic(size,
@@ -180,6 +223,7 @@
 	unsigned long start_pfn, end_pfn, bootmap_pages, bootmap_size, bootmap_start; 
 	unsigned long nodedata_phys;
 	void *bootmap;
+	int temp_id;
 	const int pgdat_size = round_up(sizeof(pg_data_t), PAGE_SIZE);
 
 	start = round_up(start, ZONE_ALIGN); 
@@ -219,8 +263,13 @@
 
 	free_bootmem_with_active_regions(nodeid, end);
 
-	reserve_bootmem_node(NODE_DATA(nodeid), nodedata_phys, pgdat_size); 
-	reserve_bootmem_node(NODE_DATA(nodeid), bootmap_start, bootmap_pages<<PAGE_SHIFT);
+	if (power_managed_node(nodeid))
+		temp_id = find_closest_non_pm_node(nodeid);
+	else
+		temp_id = nodeid;
+
+	reserve_bootmem_node(NODE_DATA(temp_id), nodedata_phys, pgdat_size);
+	reserve_bootmem_node(NODE_DATA(temp_id), bootmap_start, bootmap_pages<<PAGE_SHIFT);
 #ifdef CONFIG_ACPI_NUMA
 	srat_reserve_add_area(nodeid);
 #endif
@@ -243,11 +292,21 @@
 	memmapsize = sizeof(struct page) * (end_pfn-start_pfn);
 	limit = end_pfn << PAGE_SHIFT;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
-	NODE_DATA(nodeid)->node_mem_map = 
-		__alloc_bootmem_core(NODE_DATA(nodeid)->bdata, 
-				memmapsize, SMP_CACHE_BYTES, 
-				round_down(limit - memmapsize, PAGE_SIZE), 
+	if (power_managed_node(nodeid)) {
+		int non_pm_node = find_closest_non_pm_node(nodeid);
+
+		NODE_DATA(nodeid)->node_mem_map =
+			__alloc_bootmem_core(NODE_DATA(non_pm_node)->bdata,
+				memmapsize, SMP_CACHE_BYTES,
+				round_down(limit - memmapsize, PAGE_SIZE),
 				limit);
+	} else {
+ 		NODE_DATA(nodeid)->node_mem_map =
+			__alloc_bootmem_core(NODE_DATA(nodeid)->bdata,
+				memmapsize, SMP_CACHE_BYTES,
+				round_down(limit - memmapsize, PAGE_SIZE),
+				limit);
+	}
 	printk(KERN_DEBUG "Node %d memmap at 0x%p size %lu first pfn 0x%p\n",
 			nodeid, NODE_DATA(nodeid)->node_mem_map,
 			memmapsize, NODE_DATA(nodeid)->node_mem_map);
@@ -266,7 +325,10 @@
 	for (i = 0; i < NR_CPUS; i++) {
 		if (cpu_to_node[i] != NUMA_NO_NODE)
 			continue;
- 		numa_set_node(i, rr);
+		if (power_managed_node(rr))
+			numa_set_node(i,find_closest_non_pm_node(rr));
+		else
+			numa_set_node(i, rr);
 		rr = next_node(rr, node_online_map);
 		if (rr == MAX_NUMNODES)
 			rr = first_node(node_online_map);
diff -urN -X linux-2.6.20-mm2/Documentation/dontdiff linux-2.6.20-mm2/arch/x86_64/mm/srat.c linux-2.6.20-mm2-monroe/arch/x86_64/mm/srat.c
--- linux-2.6.20-mm2/arch/x86_64/mm/srat.c	2007-02-23 11:20:38.000000000 -0800
+++ linux-2.6.20-mm2-monroe/arch/x86_64/mm/srat.c	2007-03-02 15:15:53.000000000 -0800
@@ -28,6 +28,7 @@
 static nodemask_t nodes_parsed __initdata;
 static struct bootnode nodes[MAX_NUMNODES] __initdata;
 static struct bootnode nodes_add[MAX_NUMNODES];
+static int pm_node[MAX_NUMNODES];
 static int found_add_area __initdata;
 int hotadd_percent __initdata = 0;
 
@@ -299,7 +300,11 @@
 		return;
 	start = ma->base_address;
 	end = start + ma->length;
-	pxm = ma->proximity_domain;
+	pxm = ma->proximity_domain & 0x0000ffff;
+	if (ma->proximity_domain & (1<<31))
+		pm_node[pxm] = 1;
+	else
+		pm_node[pxm] = 0;
 	node = setup_node(pxm);
 	if (node < 0) {
 		printk(KERN_ERR "SRAT: Too many proximity domains.\n");
@@ -467,8 +472,6 @@
 	return acpi_slit->entry[index + node_to_pxm(b)];
 }
 
-EXPORT_SYMBOL(__node_distance);
-
 int memory_add_physaddr_to_nid(u64 start)
 {
 	int i, ret = 0;
@@ -479,5 +482,36 @@
 
 	return ret;
 }
-EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
 
+int __power_managed_node(int srat_node)
+{
+	return pm_node[node_to_pxm(srat_node)];
+}
+
+int __power_managed_memory_present(void)
+{
+	int j;
+
+	for (j=0; j<MAX_LOCAL_APIC; j++) {
+		if(__power_managed_node(j) )
+			return 1;
+	}
+	return 0;
+}
+
+int __find_closest_non_pm_node(int nodeid)
+{
+	int i, dist, closest, temp;
+
+	dist = closest= 255;
+	for_each_node(i) {
+		if ((i != nodeid) && !power_managed_node(i)) {
+			temp = __node_distance(nodeid, i );
+			if (temp < dist) {
+				closest = i;
+				dist = temp;
+			}
+		}
+	}
+	return closest;
+}
diff -urN -X linux-2.6.20-mm2/Documentation/dontdiff linux-2.6.20-mm2/include/linux/mm.h linux-2.6.20-mm2-monroe/include/linux/mm.h
--- linux-2.6.20-mm2/include/linux/mm.h	2007-02-23 11:20:40.000000000 -0800
+++ linux-2.6.20-mm2-monroe/include/linux/mm.h	2007-03-02 15:15:53.000000000 -0800
@@ -1226,5 +1226,9 @@
 
 __attribute__((weak)) const char *arch_vma_name(struct vm_area_struct *vma);
 
+int power_managed_memory_present(void);
+int power_managed_node(int srat_node);
+int find_closest_non_pm_node(int nodeid);
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff -urN -X linux-2.6.20-mm2/Documentation/dontdiff linux-2.6.20-mm2/mm/bootmem.c linux-2.6.20-mm2-monroe/mm/bootmem.c
--- linux-2.6.20-mm2/mm/bootmem.c	2007-02-04 10:44:54.000000000 -0800
+++ linux-2.6.20-mm2-monroe/mm/bootmem.c	2007-03-02 15:17:06.000000000 -0800
@@ -417,13 +417,14 @@
 void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
 				      unsigned long goal)
 {
-	bootmem_data_t *bdata;
 	void *ptr;
+	int i;
 
-	list_for_each_entry(bdata, &bdata_list, list) {
-		ptr = __alloc_bootmem_core(bdata, size, align, goal, 0);
-		if (ptr)
-			return ptr;
+	for_each_online_node(i) {
+		if ((!power_managed_node(i)) && (ptr =
+			__alloc_bootmem_core(NODE_DATA(i)->bdata, size,
+				align, goal, 0)))
+			return(ptr);
 	}
 	return NULL;
 }
@@ -463,16 +464,15 @@
 void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
 				  unsigned long goal)
 {
-	bootmem_data_t *bdata;
 	void *ptr;
+	int i;
 
-	list_for_each_entry(bdata, &bdata_list, list) {
-		ptr = __alloc_bootmem_core(bdata, size, align, goal,
-						ARCH_LOW_ADDRESS_LIMIT);
-		if (ptr)
-			return ptr;
+	for_each_online_node(i) {
+		if ((!power_managed_node(i)) && (ptr =
+			__alloc_bootmem_core(NODE_DATA(i)->bdata, size,
+				align, goal, ARCH_LOW_ADDRESS_LIMIT)))
+			return(ptr);
 	}
-
 	/*
 	 * Whoops, we cannot satisfy the allocation request.
 	 */
diff -urN -X linux-2.6.20-mm2/Documentation/dontdiff linux-2.6.20-mm2/mm/memory.c linux-2.6.20-mm2-monroe/mm/memory.c
--- linux-2.6.20-mm2/mm/memory.c	2007-02-23 11:20:40.000000000 -0800
+++ linux-2.6.20-mm2-monroe/mm/memory.c	2007-03-02 15:15:53.000000000 -0800
@@ -2882,3 +2882,29 @@
 	return buf - old_buf;
 }
 EXPORT_SYMBOL_GPL(access_process_vm);
+
+#ifdef __x86_64__
+extern int __power_managed_memory_present(void);
+extern int __power_managed_node(int srat_node);
+extern int __find_closest_non_pm_node(int nodeid);
+#else
+inline int __power_managed_memory_present(void) { return 0};
+inline int __power_managed_node(int srat_node) { return 0};
+inline int __find_closest_non_pm_node(int nodeid) { return nodeid};
+#endif
+
+int power_managed_memory_present(void)
+{
+	return __power_managed_memory_present();
+}
+
+int power_managed_node(int srat_node)
+{
+	return __power_managed_node(srat_node);
+}
+
+int find_closest_non_pm_node(int nodeid)
+{
+	return __find_closest_non_pm_node(nodeid);
+}
+
diff -urN -X linux-2.6.20-mm2/Documentation/dontdiff linux-2.6.20-mm2/mm/mempolicy.c linux-2.6.20-mm2-monroe/mm/mempolicy.c
--- linux-2.6.20-mm2/mm/mempolicy.c	2007-02-23 11:20:40.000000000 -0800
+++ linux-2.6.20-mm2-monroe/mm/mempolicy.c	2007-03-02 15:15:53.000000000 -0800
@@ -1617,8 +1617,13 @@
 	/* Set interleaving policy for system init. This way not all
 	   the data structures allocated at system boot end up in node zero. */
 
-	if (do_set_mempolicy(MPOL_INTERLEAVE, &node_online_map))
-		printk("numa_policy_init: interleaving failed\n");
+	if (power_managed_memory_present()) {
+		if (do_set_mempolicy(MPOL_DEFAULT, &node_online_map))
+			printk("numa_policy_init: interleaving failed\n");
+	} else {
+		if (do_set_mempolicy(MPOL_INTERLEAVE, &node_online_map))
+			printk("numa_policy_init: interleaving failed\n");
+	}
 }
 
 /* Reset policy of current process to default */
diff -urN -X linux-2.6.20-mm2/Documentation/dontdiff linux-2.6.20-mm2/mm/page_alloc.c linux-2.6.20-mm2-monroe/mm/page_alloc.c
--- linux-2.6.20-mm2/mm/page_alloc.c	2007-02-23 11:20:40.000000000 -0800
+++ linux-2.6.20-mm2-monroe/mm/page_alloc.c	2007-03-02 15:15:53.000000000 -0800
@@ -2308,8 +2308,17 @@
 					* sizeof(wait_queue_head_t);
 
  	if (system_state == SYSTEM_BOOTING) {
-		zone->wait_table = (wait_queue_head_t *)
-			alloc_bootmem_node(pgdat, alloc_size);
+		if(power_managed_node(pgdat->node_id)) {
+			int nid;
+
+			nid = find_closest_non_pm_node(pgdat->node_id);
+			zone->wait_table = (wait_queue_head_t *)
+				alloc_bootmem_node(NODE_DATA(nid), alloc_size);
+		} else
+		{
+			zone->wait_table = (wait_queue_head_t *)
+				alloc_bootmem_node(pgdat, alloc_size);
+		}
 	} else {
 		/*
 		 * This case means that a zone whose size was 0 gets new memory
@@ -2824,8 +2833,15 @@
 		end = ALIGN(end, MAX_ORDER_NR_PAGES);
 		size =  (end - start) * sizeof(struct page);
 		map = alloc_remap(pgdat->node_id, size);
-		if (!map)
+		if (!map) {
+		if(power_managed_node(pgdat->node_id)) {
+			int nid;
+
+			nid = find_closest_non_pm_node(pgdat->node_id);
+			map = alloc_bootmem_node(NODE_DATA(nid), size);
+		} else	
 			map = alloc_bootmem_node(pgdat, size);
+		}
 		pgdat->node_mem_map = map + (pgdat->node_start_pfn - start);
 		printk(KERN_DEBUG
 			"Node %d memmap at 0x%p size %lu first pfn 0x%p\n",
diff -urN -X linux-2.6.20-mm2/Documentation/dontdiff linux-2.6.20-mm2/mm/slab.c linux-2.6.20-mm2-monroe/mm/slab.c
--- linux-2.6.20-mm2/mm/slab.c	2007-02-23 11:20:40.000000000 -0800
+++ linux-2.6.20-mm2-monroe/mm/slab.c	2007-03-02 15:15:53.000000000 -0800
@@ -3378,6 +3378,7 @@
  *
  * Fallback to other node is possible if __GFP_THISNODE is not set.
  */
+
 static __always_inline void *
 __cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 		   void *caller)
@@ -3391,6 +3392,9 @@
 	if (unlikely(nodeid == -1))
 		nodeid = numa_node_id();
 
+	if (power_managed_node(nodeid) )
+		nodeid = find_closest_non_pm_node(nodeid);
+
 	if (unlikely(!cachep->nodelists[nodeid])) {
 		/* Node not bootstrapped yet */
 		ptr = fallback_alloc(cachep, flags);
@@ -3664,6 +3668,8 @@
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
+	if (power_managed_node(nodeid) )
+			nodeid = find_closest_non_pm_node(nodeid);
 	return __cache_alloc_node(cachep, flags, nodeid,
 			__builtin_return_address(0));
 }
diff -urN -X linux-2.6.20-mm2/Documentation/dontdiff linux-2.6.20-mm2/mm/sparse.c linux-2.6.20-mm2-monroe/mm/sparse.c
--- linux-2.6.20-mm2/mm/sparse.c	2007-02-04 10:44:54.000000000 -0800
+++ linux-2.6.20-mm2-monroe/mm/sparse.c	2007-03-02 15:15:53.000000000 -0800
@@ -49,6 +49,8 @@
 	struct mem_section *section = NULL;
 	unsigned long array_size = SECTIONS_PER_ROOT *
 				   sizeof(struct mem_section);
+	if (power_managed_node(nid))
+		nid = find_closest_non_pm_node(nid);
 
 	if (slab_is_available())
 		section = kmalloc_node(array_size, GFP_KERNEL, nid);
@@ -215,6 +217,9 @@
 	struct mem_section *ms = __nr_to_section(pnum);
 	int nid = sparse_early_nid(ms);
 
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
