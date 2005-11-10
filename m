From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051110090931.8083.50519.sendpatchset@cherry.local>
In-Reply-To: <20051110090920.8083.54147.sendpatchset@cherry.local>
References: <20051110090920.8083.54147.sendpatchset@cherry.local>
Subject: [PATCH 02/05] x86_64: NUMA cleanup
Date: Thu, 10 Nov 2005 18:08:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>, pj@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Rearrange the x86_64 NUMA code to make room for the new NUMA emulation code.

This patch rearranges the code and cleans it up a bit by moving duplicated
common code from srat.c and k8topology.c into numa.c.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 arch/x86_64/kernel/setup.c  |    7 ------
 arch/x86_64/mm/k8topology.c |   13 -----------
 arch/x86_64/mm/numa.c       |   51 +++++++++++++++++++++++++++++++-------------
 arch/x86_64/mm/srat.c       |   14 +-----------
 include/asm-x86_64/mmzone.h |    1
 5 files changed, 41 insertions(+), 45 deletions(-)

--- from-0002/arch/x86_64/kernel/setup.c
+++ to-work/arch/x86_64/kernel/setup.c	2005-11-08 21:33:12.000000000 +0900
@@ -581,13 +581,6 @@ void __init setup_arch(char **cmdline_p)
 	acpi_boot_table_init();
 #endif
 
-#ifdef CONFIG_ACPI_NUMA
-	/*
-	 * Parse SRAT to discover nodes.
-	 */
-	acpi_numa_init();
-#endif
-
 #ifdef CONFIG_NUMA
 	numa_initmem_init(0, end_pfn); 
 #else
--- from-0002/arch/x86_64/mm/k8topology.c
+++ to-work/arch/x86_64/mm/k8topology.c	2005-11-08 21:33:12.000000000 +0900
@@ -43,7 +43,6 @@ static __init int find_northbridge(void)
 int __init k8_scan_nodes(unsigned long start, unsigned long end)
 { 
 	unsigned long prevbase;
-	struct node nodes[8];
 	int nodeid, i, nb; 
 	unsigned char nodeids[8];
 	int found = 0;
@@ -65,7 +64,6 @@ int __init k8_scan_nodes(unsigned long s
 
 	printk(KERN_INFO "Number of nodes %d\n", numnodes);
 
-	memset(&nodes,0,sizeof(nodes)); 
 	prevbase = 0;
 	for (i = 0; i < 8; i++) { 
 		unsigned long base,limit; 
@@ -155,22 +153,13 @@ int __init k8_scan_nodes(unsigned long s
 	if (!found)
 		return -1; 
 
-	memnode_shift = compute_hash_shift(nodes, numnodes);
-	if (memnode_shift < 0) { 
-		printk(KERN_ERR "No NUMA node hash function found. Contact maintainer\n"); 
-		return -1; 
-	} 
-	printk(KERN_INFO "Using node hash shift of %d\n", memnode_shift); 
-
 	for (i = 0; i < 8; i++) {
 		if (nodes[i].start != nodes[i].end) { 
 			nodeid = nodeids[i];
 			apicid_to_node[nodeid << dualcore] = i;
 			apicid_to_node[(nodeid << dualcore) + dualcore] = i;
-			setup_node_bootmem(i, nodes[i].start, nodes[i].end); 
+			node_set_online(i);
 		} 
 	}
-
-	numa_init_array();
 	return 0;
 } 
--- from-0002/arch/x86_64/mm/numa.c
+++ to-work/arch/x86_64/mm/numa.c	2005-11-08 21:37:37.000000000 +0900
@@ -11,6 +11,7 @@
 #include <linux/ctype.h>
 #include <linux/module.h>
 #include <linux/nodemask.h>
+#include <linux/acpi.h>
 
 #include <asm/e820.h>
 #include <asm/proto.h>
@@ -25,6 +26,7 @@
 struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
 bootmem_data_t plat_node_bdata[MAX_NUMNODES];
 
+struct node nodes[MAX_NUMNODES] __initdata;
 int memnode_shift;
 u8  memnodemap[NODEMAPSIZE];
 
@@ -190,7 +192,6 @@ int numa_fake __initdata = 0;
 static int numa_emulation(unsigned long start_pfn, unsigned long end_pfn)
 {
  	int i;
- 	struct node nodes[MAX_NUMNODES];
  	unsigned long sz = ((end_pfn - start_pfn)<<PAGE_SHIFT) / numa_fake;
 
  	/* Kludge needed for the hash function */
@@ -203,7 +204,6 @@ static int numa_emulation(unsigned long 
  		sz = x;
  	}
 
- 	memset(&nodes,0,sizeof(nodes));
  	for (i = 0; i < numa_fake; i++) {
  		nodes[i].start = (start_pfn<<PAGE_SHIFT) + i*sz;
  		if (i == numa_fake-1)
@@ -215,38 +215,43 @@ static int numa_emulation(unsigned long 
  		       (nodes[i].end - nodes[i].start) >> 20);
 		node_set_online(i);
  	}
- 	memnode_shift = compute_hash_shift(nodes, numa_fake);
- 	if (memnode_shift < 0) {
- 		memnode_shift = 0;
- 		printk(KERN_ERR "No NUMA hash function found. Emulation disabled.\n");
- 		return -1;
- 	}
- 	for_each_online_node(i)
- 		setup_node_bootmem(i, nodes[i].start, nodes[i].end);
- 	numa_init_array();
  	return 0;
 }
 #endif
 
-void __init numa_initmem_init(unsigned long start_pfn, unsigned long end_pfn)
+void __init numa_initmem_doinit(unsigned long start_pfn, unsigned long end_pfn)
 { 
 	int i;
 
+	memset(&nodes,0,sizeof(nodes)); 
+
 #ifdef CONFIG_NUMA_EMU
 	if (numa_fake && !numa_emulation(start_pfn, end_pfn))
  		return;
 #endif
 
+	memset(&nodes,0,sizeof(nodes)); 
+
 #ifdef CONFIG_ACPI_NUMA
+	/*
+	 * Parse SRAT to discover nodes.
+	 */
+	acpi_numa_init();
+
 	if (!numa_off && !acpi_scan_nodes(start_pfn << PAGE_SHIFT,
 					  end_pfn << PAGE_SHIFT))
  		return;
 #endif
 
+	memset(&nodes,0,sizeof(nodes)); 
+
 #ifdef CONFIG_K8_NUMA
 	if (!numa_off && !k8_scan_nodes(start_pfn<<PAGE_SHIFT, end_pfn<<PAGE_SHIFT))
 		return;
 #endif
+
+	memset(&nodes,0,sizeof(nodes)); 
+
 	printk(KERN_INFO "%s\n",
 	       numa_off ? "NUMA turned off" : "No NUMA configuration found");
 
@@ -254,14 +259,32 @@ void __init numa_initmem_init(unsigned l
 	       start_pfn << PAGE_SHIFT,
 	       end_pfn << PAGE_SHIFT); 
 		/* setup dummy node covering all memory */ 
-	memnode_shift = 63; 
 	memnodemap[0] = 0;
 	nodes_clear(node_online_map);
 	node_set_online(0);
 	for (i = 0; i < NR_CPUS; i++)
 		numa_set_node(i, 0);
 	node_to_cpumask[0] = cpumask_of_cpu(0);
-	setup_node_bootmem(0, start_pfn << PAGE_SHIFT, end_pfn << PAGE_SHIFT);
+	nodes[0].start = start_pfn << PAGE_SHIFT;
+	nodes[0].end = end_pfn << PAGE_SHIFT;
+}
+
+void __init numa_initmem_init(unsigned long start_pfn, unsigned long end_pfn)
+{ 
+	int i;
+
+	numa_initmem_doinit(start_pfn, end_pfn);
+
+	memnode_shift = compute_hash_shift(nodes, num_online_nodes());
+	if (memnode_shift < 0) { 
+		printk(KERN_ERR "No NUMA node hash function found. Contact maintainer\n"); 
+		return; 
+	} 
+	printk(KERN_INFO "Using node hash shift of %d\n", memnode_shift); 
+
+ 	for_each_online_node(i)
+ 		setup_node_bootmem(i, nodes[i].start, nodes[i].end);
+ 	numa_init_array();
 }
 
 __cpuinit void numa_add_cpu(int cpu)
--- from-0002/arch/x86_64/mm/srat.c
+++ to-work/arch/x86_64/mm/srat.c	2005-11-08 21:35:35.000000000 +0900
@@ -22,7 +22,6 @@ static struct acpi_table_slit *acpi_slit
 
 static nodemask_t nodes_parsed __initdata;
 static nodemask_t nodes_found __initdata;
-static struct node nodes[MAX_NUMNODES] __initdata;
 static __u8  pxm2node[256] = { [0 ... 255] = 0xff };
 
 static int node_to_pxm(int n);
@@ -182,26 +181,17 @@ int __init acpi_scan_nodes(unsigned long
 		cutoff_node(i, start, end);
 		if (nodes[i].start == nodes[i].end)
 			node_clear(i, nodes_parsed);
-	}
-
-	memnode_shift = compute_hash_shift(nodes, nodes_weight(nodes_parsed));
-	if (memnode_shift < 0) {
-		printk(KERN_ERR
-		     "SRAT: No NUMA node hash function found. Contact maintainer\n");
-		bad_srat();
-		return -1;
+		else
+			node_set_online(i);
 	}
 
 	/* Finally register nodes */
-	for_each_node_mask(i, nodes_parsed)
-		setup_node_bootmem(i, nodes[i].start, nodes[i].end);
 	for (i = 0; i < NR_CPUS; i++) { 
 		if (cpu_to_node[i] == NUMA_NO_NODE)
 			continue;
 		if (!node_isset(cpu_to_node[i], nodes_parsed))
 			numa_set_node(i, NUMA_NO_NODE);
 	}
-	numa_init_array();
 	return 0;
 }
 
--- from-0002/include/asm-x86_64/mmzone.h
+++ to-work/include/asm-x86_64/mmzone.h	2005-11-08 21:33:34.000000000 +0900
@@ -17,6 +17,7 @@
 /* Simple perfect hash to map physical addresses to node numbers */
 extern int memnode_shift; 
 extern u8  memnodemap[NODEMAPSIZE]; 
+extern struct node nodes[MAX_NUMNODES] __initdata;
 
 extern struct pglist_data *node_data[];
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
