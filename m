Message-Id: <20080325220651.011213000@polaris-admin.engr.sgi.com>
References: <20080325220650.835342000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 15:06:51 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 01/10] x86_64: Cleanup non-smp usage of cpu maps v2
Content-Disposition: inline; filename=cleanup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Cleanup references to the early cpu maps for the non-SMP configuration
and remove some functions called for SMP configurations only.

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Cc: Andi Kleen <ak@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <clameter@sgi.com>

Signed-off-by: Mike Travis <travis@sgi.com>
---
This patch was moved from the zero-based percpu variables patchset to here.

v2: rebased on linux-2.6.git + linux-2.6-x86.git
---

 arch/x86/kernel/genapic_64.c |    2 ++
 arch/x86/kernel/mpparse_64.c |    2 ++
 arch/x86/kernel/setup.c      |   28 +++++++++++-----------------
 arch/x86/mm/numa_64.c        |    4 +++-
 include/asm-x86/smp.h        |    5 +++++
 include/asm-x86/topology.h   |   15 +++++++++++----
 6 files changed, 34 insertions(+), 22 deletions(-)

--- linux.trees.git.orig/arch/x86/kernel/genapic_64.c
+++ linux.trees.git/arch/x86/kernel/genapic_64.c
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
 
--- linux.trees.git.orig/arch/x86/kernel/mpparse_64.c
+++ linux.trees.git/arch/x86/kernel/mpparse_64.c
@@ -69,9 +69,11 @@ unsigned disabled_cpus __cpuinitdata;
 /* Bitmask of physically existing CPUs */
 physid_mask_t phys_cpu_present_map = PHYSID_MASK_NONE;
 
+#ifdef CONFIG_SMP
 u16 x86_bios_cpu_apicid_init[NR_CPUS] __initdata
     = {[0 ... NR_CPUS - 1] = BAD_APICID };
 void *x86_bios_cpu_apicid_early_ptr;
+#endif
 DEFINE_PER_CPU(u16, x86_bios_cpu_apicid) = BAD_APICID;
 EXPORT_PER_CPU_SYMBOL(x86_bios_cpu_apicid);
 
--- linux.trees.git.orig/arch/x86/kernel/setup.c
+++ linux.trees.git/arch/x86/kernel/setup.c
@@ -10,7 +10,7 @@
 #include <asm/setup.h>
 #include <asm/topology.h>
 
-#ifdef CONFIG_HAVE_SETUP_PER_CPU_AREA
+#if defined(CONFIG_HAVE_SETUP_PER_CPU_AREA) && defined(CONFIG_SMP)
 /*
  * Copy data used in early init routines from the initial arrays to the
  * per cpu data areas.  These arrays then become expendable and the
@@ -21,22 +21,13 @@ static void __init setup_per_cpu_maps(vo
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
-		} else
-			printk(KERN_NOTICE "per_cpu_offset zero for cpu %d\n",
-									cpu);
-#endif
 	}
 
 	/* indicate the early static arrays will soon be gone */
@@ -72,17 +63,20 @@ void __init setup_per_cpu_areas(void)
 
 	/* Copy section for each CPU (we discard the original) */
 	size = PERCPU_ENOUGH_ROOM;
-
 	printk(KERN_INFO "PERCPU: Allocating %lu bytes of per cpu data\n",
 			  size);
-	for_each_cpu_mask(i, cpu_possible_map) {
+
+	for_each_possible_cpu(i) {
 		char *ptr;
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 		ptr = alloc_bootmem_pages(size);
 #else
 		int node = early_cpu_to_node(i);
-		if (!node_online(node) || !NODE_DATA(node))
+		if (!node_online(node) || !NODE_DATA(node)) {
 			ptr = alloc_bootmem_pages(size);
+			printk(KERN_INFO
+			       "cpu %d has no node or node-local memory\n", i);
+		}
 		else
 			ptr = alloc_bootmem_pages_node(NODE_DATA(node), size);
 #endif
@@ -96,7 +90,7 @@ void __init setup_per_cpu_areas(void)
 		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
 	}
 
-	/* setup percpu data maps early */
+	/* Setup percpu data maps */
 	setup_per_cpu_maps();
 }
 
--- linux.trees.git.orig/arch/x86/mm/numa_64.c
+++ linux.trees.git/arch/x86/mm/numa_64.c
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
--- linux.trees.git.orig/include/asm-x86/smp.h
+++ linux.trees.git/include/asm-x86/smp.h
@@ -11,10 +11,15 @@ extern int smp_num_siblings;
 extern unsigned int num_processors;
 extern cpumask_t cpu_initialized;
 
+#ifdef CONFIG_SMP
 extern u16 x86_cpu_to_apicid_init[];
 extern u16 x86_bios_cpu_apicid_init[];
 extern void *x86_cpu_to_apicid_early_ptr;
 extern void *x86_bios_cpu_apicid_early_ptr;
+#else
+#define x86_cpu_to_apicid_early_ptr NULL
+#define x86_bios_cpu_apicid_early_ptr NULL
+#endif
 
 DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
 DECLARE_PER_CPU(cpumask_t, cpu_core_map);
--- linux.trees.git.orig/include/asm-x86/topology.h
+++ linux.trees.git/include/asm-x86/topology.h
@@ -39,8 +39,13 @@ extern int cpu_to_node_map[];
 #endif
 
 DECLARE_PER_CPU(int, x86_cpu_to_node_map);
+
+#ifdef CONFIG_SMP
 extern int x86_cpu_to_node_map_init[];
 extern void *x86_cpu_to_node_map_early_ptr;
+#else
+#define x86_cpu_to_node_map_early_ptr NULL
+#endif
 
 extern cpumask_t node_to_cpumask_map[];
 
@@ -55,6 +60,8 @@ static inline int cpu_to_node(int cpu)
 }
 
 #else /* CONFIG_X86_64 */
+
+#ifdef CONFIG_SMP
 static inline int early_cpu_to_node(int cpu)
 {
 	int *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
@@ -66,6 +73,9 @@ static inline int early_cpu_to_node(int 
 	else
 		return NUMA_NO_NODE;
 }
+#else
+#define	early_cpu_to_node(cpu)	cpu_to_node(cpu)
+#endif
 
 static inline int cpu_to_node(int cpu)
 {
@@ -77,10 +87,7 @@ static inline int cpu_to_node(int cpu)
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
