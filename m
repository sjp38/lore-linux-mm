Message-ID: <45F5D974.2050702@google.com>
Date: Mon, 12 Mar 2007 15:51:32 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: [PATCH 1/1] mm: Inconsistent use of node IDs
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

This patch corrects inconsistent use of node numbers (variously "nid" or
"node") in the presence of fake NUMA.

Both AMD and Intel x86_64 discovery code will determine a CPU's physical
node and use that node when calling numa_add_cpu() to associate that CPU
with the node, but numa_add_cpu() treats the node argument as a fake
node. This physical node may not exist within the fake nodespace, and
even if it does, it will likely incorrectly associate a CPU with a fake
memory node that may not share the same underlying physical NUMA node.

Similarly, the PCI code which determines the node of the PCI bus saves
it in the pci_sysdata structure. This node then propagates down to other
buses and devices which hang off the PCI bus, and is used to specify a
node when allocating memory. The purpose is to provide NUMA locality,
but the node is a physical node, and the memory allocation code expects
a fake node argument.

Provide a routine (get_fake_node()) to map a physical node ID to a fake
node ID, where the fake node ID contains memory on the specified
physical node ID. This fake node's zonelist is tied to other close fake
nodes, maintaining NUMA locality. Also provide numa_online_phys() which
is the same as numa_online() but takes a physical node ID.

Change init_cpu_to_node(), x86_64 and PCI code use get_fake_node() and
numa_online_phys() in order to convert to an appropriate fake ID.

Signed-off-by: Ethan Solomita <solo@google.com>
---
arch/i386/pci/acpi.c          |    6 +++
arch/x86_64/kernel/setup.c    |   14 ++++----
arch/x86_64/mm/numa.c         |   70 +++++++++++++++++++++++++++++++++++++-----
arch/x86_64/pci/k8-bus.c      |    3 +
include/asm-x86_64/topology.h |    8 ++++
5 files changed, 85 insertions(+), 16 deletions(-)



diff -uprN -x install -X linux-2.6.21-rc3-mm2/Documentation/dontdiff linux-2.6.21-rc3-mm2/arch/i386/pci/acpi.c linux-2.6.21-rc3-mm2-phystofake/arch/i386/pci/acpi.c
--- linux-2.6.21-rc3-mm2/arch/i386/pci/acpi.c	2007-03-09 16:42:42.000000000 -0800
+++ linux-2.6.21-rc3-mm2-phystofake/arch/i386/pci/acpi.c	2007-03-12 12:36:50.000000000 -0700
@@ -35,8 +35,13 @@ struct pci_bus * __devinit pci_acpi_scan
 
 	pxm = acpi_get_pxm(device->handle);
 #ifdef CONFIG_ACPI_NUMA
-	if (pxm >= 0)
+	if (pxm >= 0) {
 		sd->node = pxm_to_node(pxm);
+#ifdef CONFIG_NUMA_EMU
+		if (sd->node != -1)
+			sd->node = get_fake_node(sd->node);
+#endif
+	}
 #endif
 
 	bus = pci_scan_bus_parented(NULL, busnum, &pci_root_ops, sd);
diff -uprN -x install -X linux-2.6.21-rc3-mm2/Documentation/dontdiff linux-2.6.21-rc3-mm2/arch/x86_64/kernel/setup.c linux-2.6.21-rc3-mm2-phystofake/arch/x86_64/kernel/setup.c
--- linux-2.6.21-rc3-mm2/arch/x86_64/kernel/setup.c	2007-03-09 16:42:42.000000000 -0800
+++ linux-2.6.21-rc3-mm2-phystofake/arch/x86_64/kernel/setup.c	2007-03-12 12:44:31.000000000 -0700
@@ -476,20 +476,20 @@ static void __cpuinit display_cacheinfo(
 }
 
 #ifdef CONFIG_NUMA
-static int nearby_node(int apicid)
+static int __init nearby_node(int apicid)
 {
 	int i;
 	for (i = apicid - 1; i >= 0; i--) {
 		int node = apicid_to_node[i];
-		if (node != NUMA_NO_NODE && node_online(node))
+		if (node != NUMA_NO_NODE && node_online_phys(node))
 			return node;
 	}
 	for (i = apicid + 1; i < MAX_LOCAL_APIC; i++) {
 		int node = apicid_to_node[i];
-		if (node != NUMA_NO_NODE && node_online(node))
+		if (node != NUMA_NO_NODE && node_online_phys(node))
 			return node;
 	}
-	return first_node(node_online_map); /* Shouldn't happen */
+	return NUMA_NO_NODE; /* Shouldn't happen */
 }
 #endif
 
@@ -528,7 +528,7 @@ static void __init amd_detect_cmp(struct
   	node = c->phys_proc_id;
  	if (apicid_to_node[apicid] != NUMA_NO_NODE)
  		node = apicid_to_node[apicid];
- 	if (!node_online(node)) {
+ 	if (!node_online_phys(node)) {
  		/* Two possibilities here:
  		   - The CPU is missing memory and no node was created.
  		   In that case try picking one from a nearby CPU
@@ -543,9 +543,10 @@ static void __init amd_detect_cmp(struct
  		    apicid_to_node[ht_nodeid] != NUMA_NO_NODE)
  			node = apicid_to_node[ht_nodeid];
  		/* Pick a nearby node */
- 		if (!node_online(node))
+ 		if (!node_online_phys(node))
  			node = nearby_node(apicid);
  	}
+	node = get_fake_node(node);
 	numa_set_node(cpu, node);
 
 	printk(KERN_INFO "CPU %d/%x -> Node %d\n", cpu, apicid, node);
@@ -679,7 +680,7 @@ static int __cpuinit intel_num_cpu_cores
 		return 1;
 }
 
-static void srat_detect_node(void)
+static void __cpuinit srat_detect_node(void)
 {
 #ifdef CONFIG_NUMA
 	unsigned node;
@@ -689,6 +690,7 @@ static void srat_detect_node(void)
 	/* Don't do the funky fallback heuristics the AMD version employs
 	   for now. */
 	node = apicid_to_node[apicid];
+	node = get_fake_node(node);
 	if (node == NUMA_NO_NODE)
 		node = first_node(node_online_map);
 	numa_set_node(cpu, node);
diff -uprN -x install -X linux-2.6.21-rc3-mm2/Documentation/dontdiff linux-2.6.21-rc3-mm2/arch/x86_64/mm/k8topology.c linux-2.6.21-rc3-mm2-phystofake/arch/x86_64/mm/k8topology.c
--- linux-2.6.21-rc3-mm2/arch/x86_64/mm/k8topology.c	2007-03-09 16:42:42.000000000 -0800
+++ linux-2.6.21-rc3-mm2-phystofake/arch/x86_64/mm/k8topology.c	2007-03-09 17:12:03.000000000 -0800
@@ -148,9 +148,10 @@ int __init k8_scan_nodes(unsigned long s
 		
 		nodes[nodeid].start = base; 
 		nodes[nodeid].end = limit;
-		e820_register_active_regions(nodeid,
-				nodes[nodeid].start >> PAGE_SHIFT,
-				nodes[nodeid].end >> PAGE_SHIFT);
+		if (!fake)
+			e820_register_active_regions(nodeid,
+					nodes[nodeid].start >> PAGE_SHIFT,
+					nodes[nodeid].end >> PAGE_SHIFT);
 
 		prevbase = base;
 
diff -uprN -x install -X linux-2.6.21-rc3-mm2/Documentation/dontdiff linux-2.6.21-rc3-mm2/arch/x86_64/mm/numa.c linux-2.6.21-rc3-mm2-phystofake/arch/x86_64/mm/numa.c
--- linux-2.6.21-rc3-mm2/arch/x86_64/mm/numa.c	2007-03-09 16:42:42.000000000 -0800
+++ linux-2.6.21-rc3-mm2-phystofake/arch/x86_64/mm/numa.c	2007-03-12 12:43:14.000000000 -0700
@@ -285,6 +285,61 @@ char *cmdline __initdata;
 int numa_emu;
 
 /*
+ * Some arch routines want to call node_online() with a physical node after
+ * numa_emulation has already initialized fake nodes. They need to call this
+ * routine instead, which assumes that a physical node should be considered
+ * online iff it has associated memory.
+ */
+
+int __init node_online_phys(int nid)
+{
+	if (!numa_emu)
+		return node_online(nid);
+
+	if (nid < 0 || nid >= MAX_NUMNODES || nid == NUMA_NO_NODE)
+		return 0;
+
+	return (physical_node_map[nid].start != physical_node_map[nid].end);
+}
+
+
+/*
+ * Returns the first fake NUMA node that starts with phys node nid's memory
+ * if fake numa is in use, otherwise returns its argument.
+ */
+int __devinit get_fake_node(int nid)
+{
+	int fake;
+	u64 start, end;
+
+	if (!numa_emu)
+		return nid;
+
+	if (nid < 0 || nid >= MAX_NUMNODES || nid == NUMA_NO_NODE)
+		return first_online_node;
+
+	start = physical_node_map[nid].start;
+	end = physical_node_map[nid].end;
+
+	/* pick first online memory node for cpu nodes without memory */
+
+	if (start == end)
+		return first_online_node;
+
+	for (fake = 0; fake < MAX_NUMNODES; fake++) {
+		/* Return a fake node if it begins within the physical node */
+		if (nodes[fake].start >= start && nodes[fake].start < end)
+			return fake;
+
+		/* But don't skip past the last eligible fake node (e.g. numa=fake=1) */
+		if (nodes[fake].end >= end)
+			return fake;
+	}
+
+	return first_online_node;	/* Shouldn't happen */
+}
+
+/*
  * Returns the physical NUMA node that fake node nid resides on.  If NUMA
  * emulation is disabled, then this is the same as nid.
  */
@@ -636,23 +691,27 @@ early_param("numa", numa_setup);
  *
  * Populate cpu_to_node[] only if x86_cpu_to_apicid[],
  * and apicid_to_node[] tables have valid entries for a CPU.
- * This means we skip cpu_to_node[] initialisation for NUMA
- * emulation and faking node case (when running a kernel compiled
- * for NUMA on a non NUMA box), which is OK as cpu_to_node[]
- * is already initialized in a round robin manner at numa_init_array,
- * prior to this call, and this initialization is good enough
- * for the fake NUMA cases.
+ * If fake numa is in use, convert the physical node to the
+ * most appropriate fake node.
  */
 void __init init_cpu_to_node(void)
 {
 	int i;
+	unsigned char node;
+
  	for (i = 0; i < NR_CPUS; i++) {
 		u8 apicid = x86_cpu_to_apicid[i];
 		if (apicid == BAD_APICID)
 			continue;
-		if (apicid_to_node[apicid] == NUMA_NO_NODE)
+		node = apicid_to_node[apicid];
+		if (node == NUMA_NO_NODE)
 			continue;
-		numa_set_node(i,apicid_to_node[apicid]);
+#ifdef CONFIG_NUMA_EMU
+		node = get_fake_node(node);
+		if (numa_emu)
+			printk(KERN_INFO "CPU %d --> fake node %d\n", i, node);
+#endif
+		numa_set_node(i, node);
 	}
 }
 
diff -uprN -x install -X linux-2.6.21-rc3-mm2/Documentation/dontdiff linux-2.6.21-rc3-mm2/arch/x86_64/pci/k8-bus.c linux-2.6.21-rc3-mm2-phystofake/arch/x86_64/pci/k8-bus.c
--- linux-2.6.21-rc3-mm2/arch/x86_64/pci/k8-bus.c	2007-03-09 16:42:42.000000000 -0800
+++ linux-2.6.21-rc3-mm2-phystofake/arch/x86_64/pci/k8-bus.c	2007-03-12 12:46:51.000000000 -0700
@@ -67,6 +67,7 @@ fill_mp_bus_to_cpumask(void)
 					bus = pci_find_bus(0, j);
 					if (!bus)
 						continue;
+					node = get_fake_node(node);
 					if (!node_online(node))
 						node = 0;
 
diff -uprN -x install -X linux-2.6.21-rc3-mm2/Documentation/dontdiff linux-2.6.21-rc3-mm2/include/asm-x86_64/topology.h linux-2.6.21-rc3-mm2-phystofake/include/asm-x86_64/topology.h
--- linux-2.6.21-rc3-mm2/include/asm-x86_64/topology.h	2007-03-09 16:42:45.000000000 -0800
+++ linux-2.6.21-rc3-mm2-phystofake/include/asm-x86_64/topology.h	2007-03-09 16:50:19.000000000 -0800
@@ -69,4 +69,12 @@ extern int __node_distance(int, int);
 extern cpumask_t cpu_coregroup_map(int cpu);
 extern int get_phys_node(int nid);
 
+#ifdef CONFIG_NUMA_EMU
+extern int __init node_online_phys(int nid);
+extern int __devinit get_fake_node(int nid);
+#else
+#define node_online_phys(nid) node_online(nid)
+#define get_fake_node(nid) (nid)
+#endif
+
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
