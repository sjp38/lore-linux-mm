Message-Id: <20080121211600.405092000@sgi.com>
References: <20080121211600.079162000@sgi.com>
Date: Mon, 21 Jan 2008 13:16:02 -0800
From: travis@sgi.com
Subject: [PATCH 2/4] x86: Change NR_CPUS arrays in numa_64 fixup V2
Content-Disposition: inline; filename=NR_CPUS-arrays-in-numa_64-fixup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Change the following static arrays sized by NR_CPUS to
per_cpu data variables:

	char cpu_to_node_map[NR_CPUS];

Based on 2.6.24-rc8-mm1

Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
fixup:

  - Split cpu_to_node function into "early" and "late" versions
    so that x86_cpu_to_node_map_early_ptr is not EXPORT'ed and
    the cpu_to_node inline function is more streamlined.

  - This also involves setting up the percpu maps as early as possible.

  - Fix X86_32 NUMA build errors that previous version of this
    patch caused.

V2->V3:
    - add early_cpu_to_node function to keep cpu_to_node efficient
    - move and rename smp_set_apicids() to setup_percpu_maps()
    - call setup_percpu_maps() as early as possible

V1->V2:
    - Removed extraneous casts
    - Fix !NUMA builds with '#ifdef CONFIG_NUMA"
---
 arch/x86/kernel/setup64.c    |   41 +++++++++++++++++++++++++++++++++++++++--
 arch/x86/kernel/smpboot_64.c |   34 ----------------------------------
 arch/x86/mm/numa_64.c        |    2 --
 arch/x86/mm/srat_64.c        |    7 ++++---
 include/asm-x86/topology.h   |   23 +++++++++++++++++++++++
 5 files changed, 66 insertions(+), 41 deletions(-)

--- a/arch/x86/kernel/setup64.c
+++ b/arch/x86/kernel/setup64.c
@@ -84,6 +84,40 @@ static int __init nonx32_setup(char *str
 __setup("noexec32=", nonx32_setup);
 
 /*
+ * Copy data used in early init routines from the initial arrays to the
+ * per cpu data areas.  These arrays then become expendable and the
+ * *_early_ptr's are zeroed indicating that the static arrays are gone.
+ */
+static void __init setup_per_cpu_maps(void)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+#ifdef CONFIG_SMP
+		if (per_cpu_offset(cpu)) {
+#endif
+			per_cpu(x86_cpu_to_apicid, cpu) =
+						x86_cpu_to_apicid_init[cpu];
+#ifdef CONFIG_NUMA
+			per_cpu(x86_cpu_to_node_map, cpu) =
+						x86_cpu_to_node_map_init[cpu];
+#endif
+#ifdef CONFIG_SMP
+		}
+		else
+			printk(KERN_NOTICE "per_cpu_offset zero for cpu %d\n",
+									cpu);
+#endif
+	}
+
+	/* indicate the early static arrays will soon be gone */
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
@@ -104,18 +138,21 @@ void __init setup_per_cpu_areas(void)
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
+	setup_per_cpu_maps();
 } 
 
 void pda_init(int cpu)
--- a/arch/x86/kernel/smpboot_64.c
+++ b/arch/x86/kernel/smpboot_64.c
@@ -851,39 +851,6 @@ static int __init smp_sanity_check(unsig
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
-		if (per_cpu_offset(cpu)) {
-			per_cpu(x86_cpu_to_apicid, cpu) =
-						x86_cpu_to_apicid_init[cpu];
-#ifdef CONFIG_NUMA
-			per_cpu(x86_cpu_to_node_map, cpu) =
-						x86_cpu_to_node_map_init[cpu];
-#endif
-			per_cpu(x86_bios_cpu_apicid, cpu) =
-						x86_bios_cpu_apicid_init[cpu];
-		}
-		else
-			printk(KERN_NOTICE "per_cpu_offset zero for cpu %d\n",
-									cpu);
-	}
-
-	/* indicate the early static arrays are gone */
-	x86_cpu_to_apicid_early_ptr = NULL;
-#ifdef CONFIG_NUMA
-	x86_cpu_to_node_map_early_ptr = NULL;
-#endif
-	x86_bios_cpu_apicid_early_ptr = NULL;
-}
-
 static void __init smp_cpu_index_default(void)
 {
 	int i;
@@ -906,7 +873,6 @@ void __init smp_prepare_cpus(unsigned in
 	smp_cpu_index_default();
 	current_cpu_data = boot_cpu_data;
 	current_thread_info()->cpu = 0;  /* needed? */
-	smp_set_apicids();
 	set_cpu_sibling_map(0);
 
 	if (smp_sanity_check(max_cpus) < 0) {
--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -35,8 +35,6 @@ int x86_cpu_to_node_map_init[NR_CPUS] = 
 	[0 ... NR_CPUS-1] = NUMA_NO_NODE
 };
 void *x86_cpu_to_node_map_early_ptr;
-EXPORT_SYMBOL(x86_cpu_to_node_map_init);
-EXPORT_SYMBOL(x86_cpu_to_node_map_early_ptr);
 DEFINE_PER_CPU(int, x86_cpu_to_node_map) = NUMA_NO_NODE;
 EXPORT_PER_CPU_SYMBOL(x86_cpu_to_node_map);
 
--- a/arch/x86/mm/srat_64.c
+++ b/arch/x86/mm/srat_64.c
@@ -382,9 +382,10 @@ int __init acpi_scan_nodes(unsigned long
 			setup_node_bootmem(i, nodes[i].start, nodes[i].end);
 
 	for (i = 0; i < NR_CPUS; i++) {
-		if (cpu_to_node(i) == NUMA_NO_NODE)
+		int node = early_cpu_to_node(i);
+		if (node == NUMA_NO_NODE)
 			continue;
-		if (!node_isset(cpu_to_node(i), node_possible_map))
+		if (!node_isset(node, node_possible_map))
 			numa_set_node(i, NUMA_NO_NODE);
 	}
 	numa_init_array();
@@ -395,7 +396,7 @@ int __init acpi_scan_nodes(unsigned long
 static int fake_node_to_pxm_map[MAX_NUMNODES] __initdata = {
 	[0 ... MAX_NUMNODES-1] = PXM_INVAL
 };
-static u16 fake_apicid_to_node[MAX_LOCAL_APIC] __initdata = {
+static s16 fake_apicid_to_node[MAX_LOCAL_APIC] __initdata = {
 	[0 ... MAX_LOCAL_APIC-1] = NUMA_NO_NODE
 };
 static int __init find_node_by_addr(unsigned long addr)
--- a/include/asm-x86/topology.h
+++ b/include/asm-x86/topology.h
@@ -30,16 +30,30 @@
 #include <asm/mpspec.h>
 
 /* Mappings between logical cpu number and node number */
+#ifdef CONFIG_X86_32
+extern int cpu_to_node_map[];
+
+#else
 DECLARE_PER_CPU(int, x86_cpu_to_node_map);
 extern int x86_cpu_to_node_map_init[];
 extern void *x86_cpu_to_node_map_early_ptr;
+#endif
+
 extern cpumask_t node_to_cpumask_map[];
 
 #define NUMA_NO_NODE	(-1)
 
 /* Returns the number of the node containing CPU 'cpu' */
+#ifdef CONFIG_X86_32
+#define early_cpu_to_node(cpu)	cpu_to_node(cpu)
 static inline int cpu_to_node(int cpu)
 {
+	return cpu_to_node_map[cpu];
+}
+
+#else /* CONFIG_X86_64 */
+static inline int early_cpu_to_node(int cpu)
+{
 	int *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
 
 	if (cpu_to_node_map)
@@ -50,6 +64,15 @@ static inline int cpu_to_node(int cpu)
 		return NUMA_NO_NODE;
 }
 
+static inline int cpu_to_node(int cpu)
+{
+	if(per_cpu_offset(cpu))
+		return per_cpu(x86_cpu_to_node_map, cpu);
+	else
+		return NUMA_NO_NODE;
+}
+#endif /* CONFIG_X86_64 */
+
 /*
  * Returns the number of the node containing Node 'node'. This
  * architecture is flat, so it is a pretty simple function!

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
