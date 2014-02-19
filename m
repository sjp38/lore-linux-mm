Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC0A6B0037
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:18:10 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id j15so1772758qaq.39
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 15:18:10 -0800 (PST)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id g88si1462594qgf.76.2014.02.19.15.18.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 15:18:10 -0800 (PST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 19 Feb 2014 18:18:09 -0500
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id BD55338C803B
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:18:06 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1JNI6sN8454588
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 23:18:06 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1JNI6wi022901
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:18:06 -0500
Date: Wed, 19 Feb 2014 15:18:00 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [PATCH 2/3] powerpc: enable CONFIG_HAVE_PERCPU_NUMA_NODE_ID
Message-ID: <20140219231800.GC413@linux.vnet.ibm.com>
References: <20140219231641.GA413@linux.vnet.ibm.com>
 <20140219231714.GB413@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140219231714.GB413@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Anton Blanchard <anton@samba.org>, linuxppc-dev@lists.ozlabs.org

In order to enable CONFIG_HAVE_MEMORYLESS_NODES, it is necessary to have
somewhere to store the cpu <-> local-memory-node mapping. We could
create another powerpc-specific lookup table, but the generic functions
in include/linux/topology.h (protected by HAVE_PERCPU_NUMA_NODE_ID) are
sufficient. This also allows us to remove the existing powerpc-specific
cpu <-> node lookup table.
    
Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

diff --git a/arch/powerpc/include/asm/mmzone.h b/arch/powerpc/include/asm/mmzone.h
index 7b58917..c8fbd1c 100644
--- a/arch/powerpc/include/asm/mmzone.h
+++ b/arch/powerpc/include/asm/mmzone.h
@@ -29,7 +29,6 @@ extern struct pglist_data *node_data[];
  * Following are specific to this numa platform.
  */
 
-extern int numa_cpu_lookup_table[];
 extern cpumask_var_t node_to_cpumask_map[];
 #ifdef CONFIG_MEMORY_HOTPLUG
 extern unsigned long max_pfn;
diff --git a/arch/powerpc/include/asm/topology.h b/arch/powerpc/include/asm/topology.h
index d0b5fca..8bbe8cc 100644
--- a/arch/powerpc/include/asm/topology.h
+++ b/arch/powerpc/include/asm/topology.h
@@ -20,19 +20,6 @@ struct device_node;
 
 #include <asm/mmzone.h>
 
-static inline int cpu_to_node(int cpu)
-{
-	int nid;
-
-	nid = numa_cpu_lookup_table[cpu];
-
-	/*
-	 * During early boot, the numa-cpu lookup table might not have been
-	 * setup for all CPUs yet. In such cases, default to node 0.
-	 */
-	return (nid < 0) ? 0 : nid;
-}
-
 #define parent_node(node)	(node)
 
 #define cpumask_of_node(node) ((node) == -1 ?				\
diff --git a/arch/powerpc/kernel/smp.c b/arch/powerpc/kernel/smp.c
index ac2621a..f45e68d 100644
--- a/arch/powerpc/kernel/smp.c
+++ b/arch/powerpc/kernel/smp.c
@@ -739,6 +739,9 @@ void start_secondary(void *unused)
 	}
 	traverse_core_siblings(cpu, true);
 
+	set_cpu_numa_node(cpu, cpu_to_node(cpu));
+	set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
+
 	smp_wmb();
 	notify_cpu_starting(cpu);
 	set_cpu_online(cpu, true);
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 30a42e2..57e2809 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -46,11 +46,9 @@ static char *cmdline __initdata;
 static int numa_debug;
 #define dbg(args...) if (numa_debug) { printk(KERN_INFO args); }
 
-int numa_cpu_lookup_table[NR_CPUS];
 cpumask_var_t node_to_cpumask_map[MAX_NUMNODES];
 struct pglist_data *node_data[MAX_NUMNODES];
 
-EXPORT_SYMBOL(numa_cpu_lookup_table);
 EXPORT_SYMBOL(node_to_cpumask_map);
 EXPORT_SYMBOL(node_data);
 
@@ -154,22 +152,25 @@ static void __init get_node_active_region(unsigned long pfn,
 	}
 }
 
-static void reset_numa_cpu_lookup_table(void)
+static void reset_numa_cpu_node(void)
 {
 	unsigned int cpu;
 
-	for_each_possible_cpu(cpu)
-		numa_cpu_lookup_table[cpu] = -1;
+	for_each_possible_cpu(cpu) {
+		set_cpu_numa_node(cpu, -1);
+		set_cpu_numa_mem(cpu, -1);
+	}
 }
 
-static void update_numa_cpu_lookup_table(unsigned int cpu, int node)
+static void update_numa_cpu_node(unsigned int cpu, int node)
 {
-	numa_cpu_lookup_table[cpu] = node;
+	set_cpu_numa_node(cpu, node);
+	set_cpu_numa_mem(cpu, local_memory_node(node));
 }
 
 static void map_cpu_to_node(int cpu, int node)
 {
-	update_numa_cpu_lookup_table(cpu, node);
+	update_numa_cpu_node(cpu, node);
 
 	dbg("adding cpu %d to node %d\n", cpu, node);
 
@@ -180,7 +181,7 @@ static void map_cpu_to_node(int cpu, int node)
 #if defined(CONFIG_HOTPLUG_CPU) || defined(CONFIG_PPC_SPLPAR)
 static void unmap_cpu_from_node(unsigned long cpu)
 {
-	int node = numa_cpu_lookup_table[cpu];
+	int node = cpu_to_node(cpu);
 
 	dbg("removing cpu %lu from node %d\n", cpu, node);
 
@@ -545,7 +546,7 @@ static int numa_setup_cpu(unsigned long lcpu)
 	 * directly instead of querying the firmware, since it represents
 	 * the most recent mapping notified to us by the platform (eg: VPHN).
 	 */
-	if ((nid = numa_cpu_lookup_table[lcpu]) >= 0) {
+	if ((nid = cpu_to_node(lcpu)) >= 0) {
 		map_cpu_to_node(lcpu, nid);
 		return nid;
 	}
@@ -1119,7 +1120,7 @@ void __init do_init_bootmem(void)
 	 */
 	setup_node_to_cpumask_map();
 
-	reset_numa_cpu_lookup_table();
+	reset_numa_cpu_node();
 	register_cpu_notifier(&ppc64_numa_nb);
 	cpu_numa_callback(&ppc64_numa_nb, CPU_UP_PREPARE,
 			  (void *)(unsigned long)boot_cpuid);
@@ -1518,7 +1519,7 @@ static int update_lookup_table(void *data)
 		base = cpu_first_thread_sibling(update->cpu);
 
 		for (j = 0; j < threads_per_core; j++) {
-			update_numa_cpu_lookup_table(base + j, nid);
+			update_numa_cpu_node(base + j, nid);
 		}
 	}
 
@@ -1571,7 +1572,7 @@ int arch_update_cpu_topology(void)
 		if (new_nid < 0 || !node_online(new_nid))
 			new_nid = first_online_node;
 
-		if (new_nid == numa_cpu_lookup_table[cpu]) {
+		if (new_nid == cpu_to_node(cpu)) {
 			cpumask_andnot(&cpu_associativity_changes_mask,
 					&cpu_associativity_changes_mask,
 					cpu_sibling_mask(cpu));
@@ -1583,7 +1584,7 @@ int arch_update_cpu_topology(void)
 			ud = &updates[i++];
 			ud->cpu = sibling;
 			ud->new_nid = new_nid;
-			ud->old_nid = numa_cpu_lookup_table[sibling];
+			ud->old_nid = cpu_to_node(sibling);
 			cpumask_set_cpu(sibling, &updated_cpus);
 			if (i < weight)
 				ud->next = &updates[i];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
