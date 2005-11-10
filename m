From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051110090936.8083.13572.sendpatchset@cherry.local>
In-Reply-To: <20051110090920.8083.54147.sendpatchset@cherry.local>
References: <20051110090920.8083.54147.sendpatchset@cherry.local>
Subject: [PATCH 03/05] x86_64: NUMA emulation
Date: Thu, 10 Nov 2005 18:08:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>, pj@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Improve the x86_64 NUMA emulation code to use the generic NUMA emulation code.

This patch replaces the current x86_64 CONFIG_NUMA_EMU code with a more 
advanced implementation that uses the generic NUMA emulation code. The x86_64 
NUMA emulation today only supports dividing of nodes on single node systems, 
but this implementation supports both single node systems and larger systems
with multiple NUMA nodes. With the patch, each real NUMA node will be divided
into several smaller nodes during boot if requested on the kernel command line.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 arch/x86_64/Kconfig           |   11 +--
 arch/x86_64/mm/numa.c         |  119 +++++++++++++++++++++---------------------
 include/asm-x86_64/numa.h     |    1
 include/asm-x86_64/numnodes.h |    6 +-
 4 files changed, 68 insertions(+), 69 deletions(-)

--- from-0005/arch/x86_64/Kconfig
+++ to-work/arch/x86_64/Kconfig	2005-11-09 11:50:03.000000000 +0900
@@ -258,14 +258,6 @@ config X86_64_ACPI_NUMA
        help
 	 Enable ACPI SRAT based node topology detection.
 
-config NUMA_EMU
-	bool "NUMA emulation"
-	depends on NUMA
-	help
-	  Enable NUMA emulation. A flat machine will be split
-	  into virtual nodes when booted with "numa=fake=N", where N is the
-	  number of nodes. This is only useful for debugging.
-
 config ARCH_DISCONTIGMEM_ENABLE
        bool
        depends on NUMA
@@ -288,6 +280,9 @@ config ARCH_FLATMEM_ENABLE
 	def_bool y
 	depends on !NUMA
 
+config ARCH_NUMA_EMU_ENABLE
+	def_bool y
+
 source "mm/Kconfig"
 
 config HAVE_ARCH_EARLY_PFN_TO_NID
--- from-0006/arch/x86_64/mm/numa.c
+++ to-work/arch/x86_64/mm/numa.c	2005-11-09 17:50:54.000000000 +0900
@@ -48,15 +48,14 @@ int numa_off __initdata;
  * 0 if memnodmap[] too small (of shift too small)
  * -1 if node overlap or lost ram (shift too big)
  */
-static int __init populate_memnodemap(
-	const struct node *nodes, int numnodes, int shift)
+static int __init populate_memnodemap(const struct node *nodes, int shift)
 {
 	int i; 
 	int res = -1;
 	unsigned long addr, end;
 
 	memset(memnodemap, 0xff, sizeof(memnodemap));
-	for (i = 0; i < numnodes; i++) {
+	for_each_online_node(i) {
 		addr = nodes[i].start;
 		end = nodes[i].end;
 		if (addr >= end)
@@ -74,17 +73,17 @@ static int __init populate_memnodemap(
 	return res;
 }
 
-int __init compute_hash_shift(struct node *nodes, int numnodes)
+int __init compute_hash_shift(struct node *nodes)
 {
 	int shift = 20;
 
-	while (populate_memnodemap(nodes, numnodes, shift + 1) >= 0)
+	while (populate_memnodemap(nodes, shift + 1) >= 0)
 		shift++;
 
 	printk(KERN_DEBUG "Using %d for the hash shift.\n",
 		shift);
 
-	if (populate_memnodemap(nodes, numnodes, shift) != 1) {
+	if (populate_memnodemap(nodes, shift) != 1) {
 		printk(KERN_INFO
 	"Your memory is not aligned you need to rebuild your kernel "
 	"with a bigger NODEMAPSIZE shift=%d\n",
@@ -186,36 +185,53 @@ void __init numa_init_array(void)
 }
 
 #ifdef CONFIG_NUMA_EMU
-int numa_fake __initdata = 0;
-
-/* Numa emulation */
-static int numa_emulation(unsigned long start_pfn, unsigned long end_pfn)
+void __init numa_emu_setup_nid(int real_nid)
 {
- 	int i;
- 	unsigned long sz = ((end_pfn - start_pfn)<<PAGE_SHIFT) / numa_fake;
+	unsigned long start_pfn, end_pfn;
+	int real_max = 1 << NODES_SHIFT_HW;
+	int nid, new_nodes;
+
+	if (real_nid >= real_max)
+		return;
+
+	/* setup emulated nodes */
+
+	new_nodes = 0;
+
+	for (nid = real_nid + real_max; nid < MAX_NUMNODES; nid += real_max) { 
+		if (numa_emu_new(nid, nodes[real_nid].start >> PAGE_SHIFT, 
+				 nodes[real_nid].end >> PAGE_SHIFT,
+				 &start_pfn, &end_pfn) != 0)
+		     break;
+
+		nodes[nid].start = start_pfn << PAGE_SHIFT;
+		nodes[nid].end = end_pfn << PAGE_SHIFT;
+		new_nodes++;
+	}
+
+	if (!new_nodes)
+		return;
+
+	/* shrink real node */
+
+	if (numa_emu_shrink(real_nid, new_nodes,
+			    nodes[real_nid].start >> PAGE_SHIFT, 
+			    nodes[real_nid].end >> PAGE_SHIFT,
+			    &start_pfn, &end_pfn) != 0)
+		return;
+
+	nodes[real_nid].start = start_pfn << PAGE_SHIFT;
+	nodes[real_nid].end = end_pfn << PAGE_SHIFT;
+
+	/* set emulated nodes online */
+
+	for (nid = real_nid + real_max; nid < MAX_NUMNODES; nid += real_max) { 
+		node_set_online(nid);
+
+		if (!--new_nodes)
+			break;
+	}
 
- 	/* Kludge needed for the hash function */
- 	if (hweight64(sz) > 1) {
- 		unsigned long x = 1;
- 		while ((x << 1) < sz)
- 			x <<= 1;
- 		if (x < sz/2)
- 			printk("Numa emulation unbalanced. Complain to maintainer\n");
- 		sz = x;
- 	}
-
- 	for (i = 0; i < numa_fake; i++) {
- 		nodes[i].start = (start_pfn<<PAGE_SHIFT) + i*sz;
- 		if (i == numa_fake-1)
- 			sz = (end_pfn<<PAGE_SHIFT) - nodes[i].start;
- 		nodes[i].end = nodes[i].start + sz;
- 		printk(KERN_INFO "Faking node %d at %016Lx-%016Lx (%LuMB)\n",
- 		       i,
- 		       nodes[i].start, nodes[i].end,
- 		       (nodes[i].end - nodes[i].start) >> 20);
-		node_set_online(i);
- 	}
- 	return 0;
 }
 #endif
 
@@ -223,16 +239,10 @@ void __init numa_initmem_doinit(unsigned
 { 
 	int i;
 
+#ifdef CONFIG_ACPI_NUMA
+	nodes_clear(node_online_map);
 	memset(&nodes,0,sizeof(nodes)); 
 
-#ifdef CONFIG_NUMA_EMU
-	if (numa_fake && !numa_emulation(start_pfn, end_pfn))
- 		return;
-#endif
-
-	memset(&nodes,0,sizeof(nodes)); 
-
-#ifdef CONFIG_ACPI_NUMA
 	/*
 	 * Parse SRAT to discover nodes.
 	 */
@@ -243,28 +253,26 @@ void __init numa_initmem_doinit(unsigned
  		return;
 #endif
 
+#ifdef CONFIG_K8_NUMA
+	nodes_clear(node_online_map);
 	memset(&nodes,0,sizeof(nodes)); 
 
-#ifdef CONFIG_K8_NUMA
 	if (!numa_off && !k8_scan_nodes(start_pfn<<PAGE_SHIFT, end_pfn<<PAGE_SHIFT))
 		return;
 #endif
 
+	nodes_clear(node_online_map);
 	memset(&nodes,0,sizeof(nodes)); 
 
 	printk(KERN_INFO "%s\n",
 	       numa_off ? "NUMA turned off" : "No NUMA configuration found");
 
-	printk(KERN_INFO "Faking a node at %016lx-%016lx\n", 
+	printk(KERN_INFO "Single node at %016lx-%016lx\n", 
 	       start_pfn << PAGE_SHIFT,
 	       end_pfn << PAGE_SHIFT); 
 		/* setup dummy node covering all memory */ 
-	memnodemap[0] = 0;
-	nodes_clear(node_online_map);
+
 	node_set_online(0);
-	for (i = 0; i < NR_CPUS; i++)
-		numa_set_node(i, 0);
-	node_to_cpumask[0] = cpumask_of_cpu(0);
 	nodes[0].start = start_pfn << PAGE_SHIFT;
 	nodes[0].end = end_pfn << PAGE_SHIFT;
 }
@@ -275,7 +283,10 @@ void __init numa_initmem_init(unsigned l
 
 	numa_initmem_doinit(start_pfn, end_pfn);
 
-	memnode_shift = compute_hash_shift(nodes, num_online_nodes());
+	for_each_online_node(i)
+		numa_emu_setup_nid(i);
+
+	memnode_shift = compute_hash_shift(nodes);
 	if (memnode_shift < 0) { 
 		printk(KERN_ERR "No NUMA node hash function found. Contact maintainer\n"); 
 		return; 
@@ -321,13 +332,7 @@ __init int numa_setup(char *opt) 
 { 
 	if (!strncmp(opt,"off",3))
 		numa_off = 1;
-#ifdef CONFIG_NUMA_EMU
-	if(!strncmp(opt, "fake=", 5)) {
-		numa_fake = simple_strtoul(opt+5,NULL,0); ;
-		if (numa_fake >= MAX_NUMNODES)
-			numa_fake = MAX_NUMNODES;
-	}
-#endif
+        numa_emu_setup(opt);
 #ifdef CONFIG_ACPI_NUMA
  	if (!strncmp(opt,"noacpi",6))
  		acpi_numa = -1;
--- from-0002/include/asm-x86_64/numa.h
+++ to-work/include/asm-x86_64/numa.h	2005-11-09 11:50:03.000000000 +0900
@@ -8,7 +8,6 @@ struct node { 
 	u64 start,end; 
 };
 
-extern int compute_hash_shift(struct node *nodes, int numnodes);
 extern int pxm_to_node(int nid);
 
 #define ZONE_ALIGN (1UL << (MAX_ORDER+PAGE_SHIFT))
--- from-0001/include/asm-x86_64/numnodes.h
+++ to-work/include/asm-x86_64/numnodes.h	2005-11-09 11:50:03.000000000 +0900
@@ -3,10 +3,10 @@
 
 #include <linux/config.h>
 
-#ifdef CONFIG_NUMA
-#define NODES_SHIFT	6
+#if defined(CONFIG_K8_NUMA) || defined(CONFIG_ACPI_NUMA)
+#define NODES_SHIFT_HW	3
 #else
-#define NODES_SHIFT	0
+#define NODES_SHIFT_HW	0
 #endif
 
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
