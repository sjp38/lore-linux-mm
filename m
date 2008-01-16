Message-Id: <20080116170903.114188000@sgi.com>
References: <20080116170902.006151000@sgi.com>
Date: Wed, 16 Jan 2008 09:09:10 -0800
From: travis@sgi.com
Subject: [PATCH 08/10] x86: Change NR_CPUS arrays in numa_64 V3
Content-Disposition: inline; filename=NR_CPUS-arrays-in-numa_64
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Eric Dumazet <dada1@cosmosbay.com>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Change the following static arrays sized by NR_CPUS to
per_cpu data variables:

	char cpu_to_node_map[NR_CPUS];


Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
V1->V2:
    - Removed extraneous casts
    - Fix !NUMA builds with '#ifdef CONFIG_NUMA"

V2->V3:
    - add early_cpu_to_node function to keep cpu_to_node efficient
    - move and rename smp_set_apicids() to setup_percpu_maps()
    - call setup_percpu_maps() as early as possible
---
 arch/x86/kernel/setup64.c    |   37 +++++++++++++++++++++++++++++++++++--
 arch/x86/kernel/setup_64.c   |    6 +++++-
 arch/x86/kernel/smpboot_64.c |   27 ++-------------------------
 arch/x86/mm/numa_64.c        |   20 ++++++++++++++++----
 arch/x86/mm/srat_64.c        |    5 +++--
 include/asm-x86/numa_64.h    |    9 ---------
 include/asm-x86/topology.h   |   23 +++++++++++++++++++++--
 mm/page_alloc.c              |    2 +-
 net/sunrpc/svc.c             |    1 +
 9 files changed, 84 insertions(+), 46 deletions(-)

--- a/arch/x86/kernel/setup64.c
+++ b/arch/x86/kernel/setup64.c
@@ -80,6 +80,36 @@ static int __init nonx32_setup(char *str
 __setup("noexec32=", nonx32_setup);
 
 /*
+ * Copy data used in early init routines from the initial arrays to the
+ * per cpu data areas.  These arrays then become expendable and the *_ptrs
+ * are zeroed indicating that the static arrays are gone.
+ */
+void __init setup_percpu_maps(void)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		if (per_cpu_offset(cpu)) {
+			per_cpu(x86_cpu_to_apicid, cpu) =
+						x86_cpu_to_apicid_init[cpu];
+#ifdef CONFIG_NUMA
+			per_cpu(x86_cpu_to_node_map, cpu) =
+						x86_cpu_to_node_map_init[cpu];
+#endif
+		}
+		else
+			printk(KERN_NOTICE "per_cpu_offset zero for cpu %d\n",
+									cpu);
+	}
+
+	/* indicate the early static arrays are gone */
+	x86_cpu_to_apicid_early_ptr = NULL;
+#ifdef CONFIG_NUMA
+	x86_cpu_to_node_map_early_ptr = NULL;
+#endif
+}
+
+/*
  * Great future plan:
  * Declare PDA itself and support (irqstack,tss,pgd) as per cpu data.
  * Always point %gs to its beginning
@@ -100,18 +130,21 @@ void __init setup_per_cpu_areas(void)
 	for_each_cpu_mask (i, cpu_possible_map) {
 		char *ptr;
 
-		if (!NODE_DATA(cpu_to_node(i))) {
+		if (!NODE_DATA(early_cpu_to_node(i))) {
 			printk("cpu with no node %d, num_online_nodes %d\n",
 			       i, num_online_nodes());
 			ptr = alloc_bootmem_pages(size);
 		} else { 
-			ptr = alloc_bootmem_pages_node(NODE_DATA(cpu_to_node(i)), size);
+			ptr = alloc_bootmem_pages_node(NODE_DATA(early_cpu_to_node(i)), size);
 		}
 		if (!ptr)
 			panic("Cannot allocate cpu data for CPU %d\n", i);
 		cpu_pda(i)->data_offset = ptr - __per_cpu_start;
 		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
 	}
+
+	/* setup percpu data maps early */
+	setup_percpu_maps();
 } 
 
 void pda_init(int cpu)
--- a/arch/x86/kernel/setup_64.c
+++ b/arch/x86/kernel/setup_64.c
@@ -63,6 +63,7 @@
 #include <asm/cacheflush.h>
 #include <asm/mce.h>
 #include <asm/ds.h>
+#include <asm/topology.h>
 
 #ifdef CONFIG_PARAVIRT
 #include <asm/paravirt.h>
@@ -372,8 +373,11 @@ void __init setup_arch(char **cmdline_p)
 	io_delay_init();
 
 #ifdef CONFIG_SMP
-	/* setup to use the static apicid table during kernel startup */
+	/* setup to use the early static init tables during kernel startup */
 	x86_cpu_to_apicid_early_ptr = (void *)&x86_cpu_to_apicid_init;
+#ifdef CONFIG_NUMA
+	x86_cpu_to_node_map_early_ptr = (void *)&x86_cpu_to_node_map_init;
+#endif
 #endif
 
 #ifdef CONFIG_ACPI
--- a/arch/x86/kernel/smpboot_64.c
+++ b/arch/x86/kernel/smpboot_64.c
@@ -702,7 +702,7 @@ do_rest:
 	if (boot_error) {
 		cpu_clear(cpu, cpu_callout_map); /* was set here (do_boot_cpu()) */
 		clear_bit(cpu, (unsigned long *)&cpu_initialized); /* was set by cpu_init() */
-		clear_node_cpumask(cpu); /* was set by numa_add_cpu */
+		clear_bit(cpu, (unsigned long *)&node_to_cpumask_map[cpu_to_node(cpu)]);
 		cpu_clear(cpu, cpu_present_map);
 		cpu_clear(cpu, cpu_possible_map);
 		per_cpu(x86_cpu_to_apicid, cpu) = BAD_APICID;
@@ -851,28 +851,6 @@ static int __init smp_sanity_check(unsig
 	return 0;
 }
 
-/*
- * Copy data used in early init routines from the initial arrays to the
- * per cpu data areas.  These arrays then become expendable and the
- * *_ptrs are zeroed indicating that the static arrays are gone.
- */
-void __init smp_set_apicids(void)
-{
-	int cpu;
-
-	for_each_possible_cpu(cpu) {
-		if (per_cpu_offset(cpu))
-			per_cpu(x86_cpu_to_apicid, cpu) =
-						x86_cpu_to_apicid_init[cpu];
-		else
-			printk(KERN_NOTICE "per_cpu_offset zero for cpu %d\n",
-									cpu);
-	}
-
-	/* indicate the early static arrays are gone */
-	x86_cpu_to_apicid_early_ptr = NULL;
-}
-
 static void __init smp_cpu_index_default(void)
 {
 	int i;
@@ -895,7 +873,6 @@ void __init smp_prepare_cpus(unsigned in
 	smp_cpu_index_default();
 	current_cpu_data = boot_cpu_data;
 	current_thread_info()->cpu = 0;  /* needed? */
-	smp_set_apicids();
 	set_cpu_sibling_map(0);
 
 	if (smp_sanity_check(max_cpus) < 0) {
@@ -1049,7 +1026,7 @@ void remove_cpu_from_maps(void)
 	cpu_clear(cpu, cpu_callout_map);
 	cpu_clear(cpu, cpu_callin_map);
 	clear_bit(cpu, (unsigned long *)&cpu_initialized); /* was set by cpu_init() */
-	clear_node_cpumask(cpu);
+	clear_bit(cpu, (unsigned long *)&node_to_cpumask_map[cpu_to_node(cpu)]);
 }
 
 int __cpu_disable(void)
--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -31,10 +31,14 @@ bootmem_data_t plat_node_bdata[MAX_NUMNO
 
 struct memnode memnode;
 
-u16 cpu_to_node_map[NR_CPUS] __read_mostly = {
+u16 x86_cpu_to_node_map_init[NR_CPUS] __initdata = {
 	[0 ... NR_CPUS-1] = NUMA_NO_NODE
 };
-EXPORT_SYMBOL(cpu_to_node_map);
+void *x86_cpu_to_node_map_early_ptr;
+EXPORT_SYMBOL(x86_cpu_to_node_map_init);
+EXPORT_SYMBOL(x86_cpu_to_node_map_early_ptr);
+DEFINE_PER_CPU(u16, x86_cpu_to_node_map) = NUMA_NO_NODE;
+EXPORT_PER_CPU_SYMBOL(x86_cpu_to_node_map);
 
 u16 apicid_to_node[MAX_LOCAL_APIC] __cpuinitdata = {
 	[0 ... MAX_LOCAL_APIC-1] = NUMA_NO_NODE
@@ -545,7 +549,7 @@ void __init numa_initmem_init(unsigned l
 	node_set(0, node_possible_map);
 	for (i = 0; i < NR_CPUS; i++)
 		numa_set_node(i, 0);
-	/* we can't use cpumask_of_cpu() yet */
+	/* cpumask_of_cpu() may not be available during early startup */
 	memset(&node_to_cpumask_map[0], 0, sizeof(node_to_cpumask_map[0]));
 	cpu_set(0, node_to_cpumask_map[0]);
 	e820_register_active_regions(0, start_pfn, end_pfn);
@@ -559,8 +563,16 @@ __cpuinit void numa_add_cpu(int cpu)
 
 void __cpuinit numa_set_node(int cpu, int node)
 {
+	u16 *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
+
 	cpu_pda(cpu)->nodenumber = node;
-	cpu_to_node_map[cpu] = node;
+
+	if(cpu_to_node_map)
+		cpu_to_node_map[cpu] = node;
+	else if(per_cpu_offset(cpu))
+		per_cpu(x86_cpu_to_node_map, cpu) = node;
+	else
+		Dprintk(KERN_INFO "Setting node for non-present cpu %d\n", cpu);
 }
 
 unsigned long __init numa_free_all_bootmem(void)
--- a/arch/x86/mm/srat_64.c
+++ b/arch/x86/mm/srat_64.c
@@ -382,9 +382,10 @@ int __init acpi_scan_nodes(unsigned long
 			setup_node_bootmem(i, nodes[i].start, nodes[i].end);
 
 	for (i = 0; i < NR_CPUS; i++) {
-		if (cpu_to_node(i) == NUMA_NO_NODE)
+		int node = cpu_to_node(i);
+		if (node == NUMA_NO_NODE)
 			continue;
-		if (!node_isset(cpu_to_node(i), node_possible_map))
+		if (!node_isset(node, node_possible_map))
 			numa_set_node(i, NUMA_NO_NODE);
 	}
 	numa_init_array();
--- a/include/asm-x86/numa_64.h
+++ b/include/asm-x86/numa_64.h
@@ -29,17 +29,8 @@ extern void setup_node_bootmem(int nodei
 
 #ifdef CONFIG_NUMA
 extern void __init init_cpu_to_node(void);
-
-static inline void clear_node_cpumask(int cpu)
-{
-	clear_bit(cpu, (unsigned long *)&node_to_cpumask_map[cpu_to_node(cpu)]);
-}
-
 #else
 #define init_cpu_to_node() do {} while (0)
-#define clear_node_cpumask(cpu) do {} while (0)
 #endif
 
-#define NUMA_NO_NODE 0xffff
-
 #endif
--- a/include/asm-x86/topology.h
+++ b/include/asm-x86/topology.h
@@ -30,13 +30,32 @@
 #include <asm/mpspec.h>
 
 /* Mappings between logical cpu number and node number */
-extern u16 cpu_to_node_map[];
+DECLARE_PER_CPU(u16, x86_cpu_to_node_map);
+extern u16 __initdata x86_cpu_to_node_map_init[];
+extern void *x86_cpu_to_node_map_early_ptr;
 extern cpumask_t node_to_cpumask_map[];
 
+#define NUMA_NO_NODE	((u16)(~0))
+
 /* Returns the number of the node containing CPU 'cpu' */
+static inline int early_cpu_to_node(int cpu)
+{
+	u16 *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
+
+	if (cpu_to_node_map)
+		return cpu_to_node_map[cpu];
+	else if(per_cpu_offset(cpu))
+		return per_cpu(x86_cpu_to_node_map, cpu);
+	else
+		return NUMA_NO_NODE;
+}
+
 static inline int cpu_to_node(int cpu)
 {
-	return cpu_to_node_map[cpu];
+	if(per_cpu_offset(cpu))
+		return per_cpu(x86_cpu_to_node_map, cpu);
+	else
+		return NUMA_NO_NODE;
 }
 
 /*
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1783,7 +1783,7 @@ EXPORT_SYMBOL(free_pages);
 static unsigned int nr_free_zone_pages(int offset)
 {
 	/* Just pick one node, since fallback list is circular */
-	pg_data_t *pgdat = NODE_DATA(numa_node_id());
+	pg_data_t *pgdat = NODE_DATA(cpu_to_node(raw_smp_processor_id()));
 	unsigned int sum = 0;
 
 	struct zonelist *zonelist = pgdat->node_zonelists + offset;
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -18,6 +18,7 @@
 #include <linux/mm.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
+#include <linux/sched.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
