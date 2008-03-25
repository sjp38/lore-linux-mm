Message-Id: <20080325021955.228351000@polaris-admin.engr.sgi.com>
References: <20080325021954.979158000@polaris-admin.engr.sgi.com>
Date: Mon, 24 Mar 2008 19:19:55 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 01/10] x86_64: Cleanup non-smp usage of cpu maps v4
Content-Disposition: inline; filename=cleanup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Cleanup references to the early cpu maps for the non-SMP configuration
and remove some functions called for SMP configurations only.

Based on linux-2.6.25-rc5-mm1

Cc: Andi Kleen <ak@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <clameter@sgi.com>

Signed-off-by: Mike Travis <travis@sgi.com>
---
This patch was moved from the zero-based percpu variables patchset to here.
---

 arch/x86/kernel/genapic_64.c |    2 +
 arch/x86/kernel/mpparse_64.c |    2 +
 arch/x86/kernel/setup64.c    |   45 ++++++++++++++++++++++---------------------
 arch/x86/kernel/smpboot_32.c |    2 +
 arch/x86/mm/numa_64.c        |    4 ++-
 include/asm-x86/smp_32.h     |    4 +++
 include/asm-x86/smp_64.h     |    5 ++++
 include/asm-x86/topology.h   |   16 +++++++++++----
 8 files changed, 54 insertions(+), 26 deletions(-)

--- linux-2.6.25-rc5.orig/arch/x86/kernel/genapic_64.c
+++ linux-2.6.25-rc5/arch/x86/kernel/genapic_64.c
@@ -25,9 +25,11 @@
 #endif
 
 /* which logical CPU number maps to which CPU (physical APIC ID) */
+#ifdef CONFIG_SMP
 u16 x86_cpu_to_apicid_init[NR_CPUS] __initdata
 					= { [0 ... NR_CPUS-1] = BAD_APICID };
 void *x86_cpu_to_apicid_early_ptr;
+#endif
 DEFINE_PER_CPU(u16, x86_cpu_to_apicid) = BAD_APICID;
 EXPORT_PER_CPU_SYMBOL(x86_cpu_to_apicid);
 
--- linux-2.6.25-rc5.orig/arch/x86/kernel/mpparse_64.c
+++ linux-2.6.25-rc5/arch/x86/kernel/mpparse_64.c
@@ -67,9 +67,11 @@ unsigned disabled_cpus __cpuinitdata;
 /* Bitmask of physically existing CPUs */
 physid_mask_t phys_cpu_present_map = PHYSID_MASK_NONE;
 
+#ifdef CONFIG_SMP
 u16 x86_bios_cpu_apicid_init[NR_CPUS] __initdata
 				= { [0 ... NR_CPUS-1] = BAD_APICID };
 void *x86_bios_cpu_apicid_early_ptr;
+#endif
 DEFINE_PER_CPU(u16, x86_bios_cpu_apicid) = BAD_APICID;
 EXPORT_PER_CPU_SYMBOL(x86_bios_cpu_apicid);
 
--- linux-2.6.25-rc5.orig/arch/x86/kernel/setup64.c
+++ linux-2.6.25-rc5/arch/x86/kernel/setup64.c
@@ -86,6 +86,8 @@ static int __init nonx32_setup(char *str
 }
 __setup("noexec32=", nonx32_setup);
 
+
+#ifdef CONFIG_SMP
 /*
  * Copy data used in early init routines from the initial arrays to the
  * per cpu data areas.  These arrays then become expendable and the
@@ -96,23 +98,13 @@ static void __init setup_per_cpu_maps(vo
 	int cpu;
 
 	for_each_possible_cpu(cpu) {
-#ifdef CONFIG_SMP
-		if (per_cpu_offset(cpu)) {
-#endif
-			per_cpu(x86_cpu_to_apicid, cpu) =
-						x86_cpu_to_apicid_init[cpu];
-			per_cpu(x86_bios_cpu_apicid, cpu) =
+		per_cpu(x86_cpu_to_apicid, cpu) = x86_cpu_to_apicid_init[cpu];
+		per_cpu(x86_bios_cpu_apicid, cpu) =
 						x86_bios_cpu_apicid_init[cpu];
 #ifdef CONFIG_NUMA
-			per_cpu(x86_cpu_to_node_map, cpu) =
+		per_cpu(x86_cpu_to_node_map, cpu) =
 						x86_cpu_to_node_map_init[cpu];
 #endif
-#ifdef CONFIG_SMP
-		}
-		else
-			printk(KERN_NOTICE "per_cpu_offset zero for cpu %d\n",
-									cpu);
-#endif
 	}
 
 	/* indicate the early static arrays will soon be gone */
@@ -140,26 +132,37 @@ void __init setup_per_cpu_areas(void)
 	/* Copy section for each CPU (we discard the original) */
 	size = PERCPU_ENOUGH_ROOM;
 
-	printk(KERN_INFO "PERCPU: Allocating %lu bytes of per cpu data\n", size);
-	for_each_cpu_mask (i, cpu_possible_map) {
+	printk(KERN_INFO
+		"PERCPU: Allocating %lu bytes of per cpu data\n", size);
+
+	for_each_possible_cpu(i) {
+
+#ifndef CONFIG_NEED_MULTIPLE_NODES
+		char *ptr = alloc_bootmem_pages(size);
+#else
 		char *ptr;
+		int node = early_cpu_to_node(i);
 
-		if (!NODE_DATA(early_cpu_to_node(i))) {
-			printk("cpu with no node %d, num_online_nodes %d\n",
-			       i, num_online_nodes());
+		if (NODE_DATA(node))
+			ptr = alloc_bootmem_pages_node(NODE_DATA(node), size);
+
+		else {
 			ptr = alloc_bootmem_pages(size);
-		} else { 
-			ptr = alloc_bootmem_pages_node(NODE_DATA(early_cpu_to_node(i)), size);
+			printk(KERN_INFO
+			       "cpu %d has no node or node-local memory\n", i);
 		}
+#endif
 		if (!ptr)
 			panic("Cannot allocate cpu data for CPU %d\n", i);
+
 		cpu_pda(i)->data_offset = ptr - __per_cpu_start;
 		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
 	}
 
-	/* setup percpu data maps early */
+	/* Setup percpu data maps */
 	setup_per_cpu_maps();
 } 
+#endif /* CONFIG_SMP */
 
 void pda_init(int cpu)
 { 
--- linux-2.6.25-rc5.orig/arch/x86/kernel/smpboot_32.c
+++ linux-2.6.25-rc5/arch/x86/kernel/smpboot_32.c
@@ -92,9 +92,11 @@ DEFINE_PER_CPU_SHARED_ALIGNED(struct cpu
 EXPORT_PER_CPU_SYMBOL(cpu_info);
 
 /* which logical CPU number maps to which CPU (physical APIC ID) */
+#ifdef CONFIG_SMP
 u8 x86_cpu_to_apicid_init[NR_CPUS] __initdata =
 			{ [0 ... NR_CPUS-1] = BAD_APICID };
 void *x86_cpu_to_apicid_early_ptr;
+#endif
 DEFINE_PER_CPU(u8, x86_cpu_to_apicid) = BAD_APICID;
 EXPORT_PER_CPU_SYMBOL(x86_cpu_to_apicid);
 
--- linux-2.6.25-rc5.orig/arch/x86/mm/numa_64.c
+++ linux-2.6.25-rc5/arch/x86/mm/numa_64.c
@@ -31,13 +31,15 @@ bootmem_data_t plat_node_bdata[MAX_NUMNO
 
 struct memnode memnode;
 
+#ifdef CONFIG_SMP
 int x86_cpu_to_node_map_init[NR_CPUS] = {
 	[0 ... NR_CPUS-1] = NUMA_NO_NODE
 };
 void *x86_cpu_to_node_map_early_ptr;
+EXPORT_SYMBOL(x86_cpu_to_node_map_early_ptr);
+#endif
 DEFINE_PER_CPU(int, x86_cpu_to_node_map) = NUMA_NO_NODE;
 EXPORT_PER_CPU_SYMBOL(x86_cpu_to_node_map);
-EXPORT_SYMBOL(x86_cpu_to_node_map_early_ptr);
 
 s16 apicid_to_node[MAX_LOCAL_APIC] __cpuinitdata = {
 	[0 ... MAX_LOCAL_APIC-1] = NUMA_NO_NODE
--- linux-2.6.25-rc5.orig/include/asm-x86/smp_32.h
+++ linux-2.6.25-rc5/include/asm-x86/smp_32.h
@@ -29,8 +29,12 @@ extern void unlock_ipi_call_lock(void);
 extern void (*mtrr_hook) (void);
 extern void zap_low_mappings (void);
 
+#ifdef CONFIG_SMP
 extern u8 __initdata x86_cpu_to_apicid_init[];
 extern void *x86_cpu_to_apicid_early_ptr;
+#else
+#define x86_cpu_to_apicid_early_ptr NULL
+#endif
 
 DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
 DECLARE_PER_CPU(cpumask_t, cpu_core_map);
--- linux-2.6.25-rc5.orig/include/asm-x86/smp_64.h
+++ linux-2.6.25-rc5/include/asm-x86/smp_64.h
@@ -26,10 +26,15 @@ extern void unlock_ipi_call_lock(void);
 extern int smp_call_function_mask(cpumask_t mask, void (*func)(void *),
 				  void *info, int wait);
 
+#ifdef CONFIG_SMP
 extern u16 __initdata x86_cpu_to_apicid_init[];
 extern u16 __initdata x86_bios_cpu_apicid_init[];
 extern void *x86_cpu_to_apicid_early_ptr;
 extern void *x86_bios_cpu_apicid_early_ptr;
+#else
+#define x86_cpu_to_apicid_early_ptr NULL
+#define x86_bios_cpu_apicid_early_ptr NULL
+#endif
 
 DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
 DECLARE_PER_CPU(cpumask_t, cpu_core_map);
--- linux-2.6.25-rc5.orig/include/asm-x86/topology.h
+++ linux-2.6.25-rc5/include/asm-x86/topology.h
@@ -35,8 +35,14 @@ extern int cpu_to_node_map[];
 
 #else
 DECLARE_PER_CPU(int, x86_cpu_to_node_map);
+
+#ifdef CONFIG_SMP
 extern int x86_cpu_to_node_map_init[];
 extern void *x86_cpu_to_node_map_early_ptr;
+#else
+#define x86_cpu_to_node_map_early_ptr NULL
+#endif
+
 /* Returns the number of the current Node. */
 #define numa_node_id()		(early_cpu_to_node(raw_smp_processor_id()))
 #endif
@@ -54,6 +60,8 @@ static inline int cpu_to_node(int cpu)
 }
 
 #else /* CONFIG_X86_64 */
+
+#ifdef CONFIG_SMP
 static inline int early_cpu_to_node(int cpu)
 {
 	int *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
@@ -65,6 +73,9 @@ static inline int early_cpu_to_node(int 
 	else
 		return NUMA_NO_NODE;
 }
+#else
+#define	early_cpu_to_node(cpu)	cpu_to_node(cpu)
+#endif
 
 static inline int cpu_to_node(int cpu)
 {
@@ -76,10 +87,7 @@ static inline int cpu_to_node(int cpu)
 		return ((int *)x86_cpu_to_node_map_early_ptr)[cpu];
 	}
 #endif
-	if (per_cpu_offset(cpu))
-		return per_cpu(x86_cpu_to_node_map, cpu);
-	else
-		return NUMA_NO_NODE;
+	return per_cpu(x86_cpu_to_node_map, cpu);
 }
 #endif /* CONFIG_X86_64 */
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
