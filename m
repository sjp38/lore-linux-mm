Date: Tue, 25 Mar 2008 10:14:35 -0700
From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: [patch] srat, x86_64: Add support for nodes spanning other nodes
Message-ID: <20080325171435.GA3313@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, hpa@zytor.com, tglx@linutronix.de
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

For example, If the physical address layout on a two node system with 8 GB
memory is something like:
node 0: 0-2GB, 4-6GB
node 1: 2-4GB, 6-8GB

Current kernels fail to boot/detect this NUMA topology.

ACPI SRAT tables can expose such a topology which needs to be supported.

Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>
---

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 227fdb0..99eb102 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -880,6 +880,15 @@ config X86_64_ACPI_NUMA
 	help
 	  Enable ACPI SRAT based node topology detection.
 
+# Some NUMA nodes have memory ranges that span
+# other nodes.  Even though a pfn is valid and
+# between a node's start and end pfns, it may not
+# reside on that node.  See memmap_init_zone()
+# for details.
+config NODES_SPAN_OTHER_NODES
+	def_bool y
+	depends on X86_64_ACPI_NUMA
+
 config NUMA_EMU
 	bool "NUMA emulation"
 	depends on X86_64 && NUMA
diff --git a/arch/x86/mm/k8topology_64.c b/arch/x86/mm/k8topology_64.c
index 1f249f1..1f476e4 100644
--- a/arch/x86/mm/k8topology_64.c
+++ b/arch/x86/mm/k8topology_64.c
@@ -192,7 +192,7 @@ int __init k8_scan_nodes(unsigned long start, unsigned long end)
 	if (!found)
 		return -1;
 
-	memnode_shift = compute_hash_shift(nodes, 8);
+	memnode_shift = compute_hash_shift(nodes, 8, NULL);
 	if (memnode_shift < 0) {
 		printk(KERN_ERR "No NUMA node hash function found. Contact maintainer\n");
 		return -1;
diff --git a/arch/x86/mm/numa_64.c b/arch/x86/mm/numa_64.c
index ebfc1f8..b04fce7 100644
--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -58,7 +58,7 @@ unsigned long __initdata nodemap_size;
  * -1 if node overlap or lost ram (shift too big)
  */
 static int __init populate_memnodemap(const struct bootnode *nodes,
-				      int numnodes, int shift)
+				      int numnodes, int shift, int *nodeids)
 {
 	unsigned long addr, end;
 	int i, res = -1;
@@ -74,7 +74,12 @@ static int __init populate_memnodemap(const struct bootnode *nodes,
 		do {
 			if (memnodemap[addr >> shift] != NUMA_NO_NODE)
 				return -1;
-			memnodemap[addr >> shift] = i;
+
+			if (!nodeids)
+				memnodemap[addr >> shift] = i;
+			else
+				memnodemap[addr >> shift] = nodeids[i];
+
 			addr += (1UL << shift);
 		} while (addr < end);
 		res = 1;
@@ -137,7 +142,8 @@ static int __init extract_lsb_from_nodes(const struct bootnode *nodes,
 	return i;
 }
 
-int __init compute_hash_shift(struct bootnode *nodes, int numnodes)
+int __init compute_hash_shift(struct bootnode *nodes, int numnodes,
+			      int *nodeids)
 {
 	int shift;
 
@@ -147,7 +153,7 @@ int __init compute_hash_shift(struct bootnode *nodes, int numnodes)
 	printk(KERN_DEBUG "NUMA: Using %d for the hash shift.\n",
 		shift);
 
-	if (populate_memnodemap(nodes, numnodes, shift) != 1) {
+	if (populate_memnodemap(nodes, numnodes, shift, nodeids) != 1) {
 		printk(KERN_INFO "Your memory is not aligned you need to "
 		       "rebuild your kernel with a bigger NODEMAPSIZE "
 		       "shift=%d\n", shift);
@@ -491,7 +497,7 @@ done:
 		}
 	}
 out:
-	memnode_shift = compute_hash_shift(nodes, num_nodes);
+	memnode_shift = compute_hash_shift(nodes, num_nodes, NULL);
 	if (memnode_shift < 0) {
 		memnode_shift = 0;
 		printk(KERN_ERR "No NUMA hash function found.  NUMA emulation "
diff --git a/arch/x86/mm/srat_64.c b/arch/x86/mm/srat_64.c
index 04e06c8..768ffac 100644
--- a/arch/x86/mm/srat_64.c
+++ b/arch/x86/mm/srat_64.c
@@ -31,6 +31,10 @@ static struct bootnode nodes_add[MAX_NUMNODES];
 static int found_add_area __initdata;
 int hotadd_percent __initdata = 0;
 
+static int num_node_memblks __initdata;
+static struct bootnode node_memblk_range[NR_NODE_MEMBLKS] __initdata;
+static int memblk_nodeid[NR_NODE_MEMBLKS] __initdata;
+
 /* Too small nodes confuse the VM badly. Usually they result
    from BIOS bugs. */
 #define NODE_MIN_SIZE (4*1024*1024)
@@ -40,17 +44,17 @@ static __init int setup_node(int pxm)
 	return acpi_map_pxm_to_node(pxm);
 }
 
-static __init int conflicting_nodes(unsigned long start, unsigned long end)
+static __init int conflicting_memblks(unsigned long start, unsigned long end)
 {
 	int i;
-	for_each_node_mask(i, nodes_parsed) {
-		struct bootnode *nd = &nodes[i];
+	for (i = 0; i < num_node_memblks; i++) {
+		struct bootnode *nd = &node_memblk_range[i];
 		if (nd->start == nd->end)
 			continue;
 		if (nd->end > start && nd->start < end)
-			return i;
+			return memblk_nodeid[i];
 		if (nd->end == end && nd->start == start)
-			return i;
+			return memblk_nodeid[i];
 	}
 	return -1;
 }
@@ -254,7 +258,7 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 		bad_srat();
 		return;
 	}
-	i = conflicting_nodes(start, end);
+	i = conflicting_memblks(start, end);
 	if (i == node) {
 		printk(KERN_WARNING
 		"SRAT: Warning: PXM %d (%lx-%lx) overlaps with itself (%Lx-%Lx)\n",
@@ -279,10 +283,10 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 			nd->end = end;
 	}
 
-	printk(KERN_INFO "SRAT: Node %u PXM %u %Lx-%Lx\n", node, pxm,
-	       nd->start, nd->end);
-	e820_register_active_regions(node, nd->start >> PAGE_SHIFT,
-						nd->end >> PAGE_SHIFT);
+	printk(KERN_INFO "SRAT: Node %u PXM %u %lx-%lx\n", node, pxm,
+	       start, end);
+	e820_register_active_regions(node, start >> PAGE_SHIFT,
+				     end >> PAGE_SHIFT);
 	push_node_boundaries(node, nd->start >> PAGE_SHIFT,
 						nd->end >> PAGE_SHIFT);
 
@@ -294,6 +298,11 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 		if ((nd->start | nd->end) == 0)
 			node_clear(node, nodes_parsed);
 	}
+
+	node_memblk_range[num_node_memblks].start = start;
+	node_memblk_range[num_node_memblks].end = end;
+	memblk_nodeid[num_node_memblks] = node;
+	num_node_memblks++;
 }
 
 /* Sanity check to catch more bad SRATs (they are amazingly common).
@@ -364,7 +373,8 @@ int __init acpi_scan_nodes(unsigned long start, unsigned long end)
 		return -1;
 	}
 
-	memnode_shift = compute_hash_shift(nodes, MAX_NUMNODES);
+	memnode_shift = compute_hash_shift(node_memblk_range, num_node_memblks,
+					   memblk_nodeid);
 	if (memnode_shift < 0) {
 		printk(KERN_ERR
 		     "SRAT: No NUMA node hash function found. Contact maintainer\n");
diff --git a/include/asm-x86/numa_64.h b/include/asm-x86/numa_64.h
index 15fe07c..0d37e31 100644
--- a/include/asm-x86/numa_64.h
+++ b/include/asm-x86/numa_64.h
@@ -8,7 +8,8 @@ struct bootnode {
 	u64 start,end; 
 };
 
-extern int compute_hash_shift(struct bootnode *nodes, int numnodes);
+extern int compute_hash_shift(struct bootnode *nodes, int numblks,
+			      int *nodeids);
 
 #define ZONE_ALIGN (1UL << (MAX_ORDER+PAGE_SHIFT))
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
