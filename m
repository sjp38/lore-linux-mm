Message-Id: <20080201191415.572662000@sgi.com>
References: <20080201191414.961558000@sgi.com>
Date: Fri, 01 Feb 2008 11:14:18 -0800
From: travis@sgi.com
Subject: [PATCH 4/4] x86_64: Cleanup non-smp usage of cpu maps
Content-Disposition: inline; filename=cleanup_nonsmp_maps
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Cleanup references to the early cpu maps for the non-SMP configuration
and remove some functions called for SMP configurations only.

Based on linux-2.6.git + x86.git

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86/kernel/genapic_64.c |    2 ++
 arch/x86/kernel/mpparse_64.c |    2 ++
 arch/x86/kernel/setup64.c    |    3 +++
 arch/x86/kernel/smpboot_32.c |    2 ++
 arch/x86/mm/numa_64.c        |   12 ++++++------
 include/asm-x86/pda.h        |    1 -
 include/asm-x86/smp_32.h     |    4 ++++
 include/asm-x86/smp_64.h     |    5 +++++
 include/asm-x86/topology.h   |   16 ++++++++++++----
 9 files changed, 36 insertions(+), 11 deletions(-)

--- a/arch/x86/kernel/genapic_64.c
+++ b/arch/x86/kernel/genapic_64.c
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
 
--- a/arch/x86/kernel/mpparse_64.c
+++ b/arch/x86/kernel/mpparse_64.c
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
 
--- a/arch/x86/kernel/setup64.c
+++ b/arch/x86/kernel/setup64.c
@@ -89,6 +89,8 @@ static int __init nonx32_setup(char *str
 }
 __setup("noexec32=", nonx32_setup);
 
+
+#ifdef CONFIG_SMP
 /*
  * Copy data used in early init routines from the initial arrays to the
  * per cpu data areas.  These arrays then become expendable and the
@@ -176,6 +178,7 @@ void __init setup_per_cpu_areas(void)
 	/* Fix up pda for this processor .... */
 	pda_init(0);
 } 
+#endif /* CONFIG_SMP */
 
 void pda_init(int cpu)
 { 
--- a/arch/x86/kernel/smpboot_32.c
+++ b/arch/x86/kernel/smpboot_32.c
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
 
--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
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
@@ -536,13 +538,11 @@ void __cpuinit numa_set_node(int cpu, in
 {
 	int *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
 
-	cpu_pda(cpu)->nodenumber = node;
-
-	if(cpu_to_node_map)
+	if (cpu_to_node_map)
 		cpu_to_node_map[cpu] = node;
-	else if(per_cpu_offset(cpu))
+	else if (per_cpu_offset(cpu))
 		per_cpu(x86_cpu_to_node_map, cpu) = node;
-	else
+ 	else
 		Dprintk(KERN_INFO "Setting node for non-present cpu %d\n", cpu);
 }
 
--- a/include/asm-x86/pda.h
+++ b/include/asm-x86/pda.h
@@ -22,7 +22,6 @@ struct x8664_pda {
 					   offset 40!!! */
 #endif
 	char *irqstackptr;
-	unsigned int nodenumber;	/* number of current node */
 	unsigned int __softirq_pending;
 	unsigned int __nmi_count;	/* number of NMI on this CPUs */
 	short mmu_state;
--- a/include/asm-x86/smp_32.h
+++ b/include/asm-x86/smp_32.h
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
--- a/include/asm-x86/smp_64.h
+++ b/include/asm-x86/smp_64.h
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
--- a/include/asm-x86/topology.h
+++ b/include/asm-x86/topology.h
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
