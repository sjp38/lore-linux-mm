Message-Id: <20080122230409.379579000@sgi.com>
References: <20080122230409.198261000@sgi.com>
Date: Tue, 22 Jan 2008 15:04:10 -0800
From: travis@sgi.com
Subject: [PATCH 1/3] x86: fix percpu, nodeids, apicids in x86.git
Content-Disposition: inline; filename=01-fix-x86.git-need
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Eric Dumazet <dada1@cosmosbay.com>, Yinghai Lu <yhlu.kernel@gmail.com>
List-ID: <linux-mm.kvack.org>

[ patches for x86.git ]

    01-fix-x86.git-need
            - fixes up things missing in (08/01/22) x86.git  [necessary]

    This should bring x86.git up-to-date with changes from -mm specific to x86

Cc: David Rientjes <rientjes@google.com>
Cc: Eric Dumazet <dada1@cosmosbay.com>
Cc: Yinghai Lu <yhlu.kernel@gmail.com>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86/Kconfig             |    2 +-
 arch/x86/kernel/setup64.c    |   10 +++++-----
 arch/x86/kernel/smpboot_32.c |    2 +-
 arch/x86/mm/numa_64.c        |   14 ++++++--------
 arch/x86/mm/srat_64.c        |    2 +-
 include/asm-generic/percpu.h |   12 ++----------
 include/asm-x86/mmzone_64.h  |    6 +++---
 include/asm-x86/numa_64.h    |    2 +-
 include/asm-x86/topology.h   |   16 +++++++++-------
 init/main.c                  |    4 ++--
 kernel/module.c              |    8 ++++++++
 11 files changed, 39 insertions(+), 39 deletions(-)

--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -100,7 +100,7 @@ config GENERIC_TIME_VSYSCALL
 	bool
 	default X86_64
 
-config ARCH_SETS_UP_PER_CPU_AREA
+config HAVE_SETUP_PER_CPU_AREA
 	def_bool X86_64
 
 config ARCH_SUPPORTS_OPROFILE
--- a/arch/x86/kernel/setup64.c
+++ b/arch/x86/kernel/setup64.c
@@ -87,10 +87,10 @@ __setup("noexec32=", nonx32_setup);
 
 /*
  * Copy data used in early init routines from the initial arrays to the
- * per cpu data areas.  These arrays then become expendable and the *_ptrs
- * are zeroed indicating that the static arrays are gone.
+ * per cpu data areas.  These arrays then become expendable and the
+ * *_early_ptr's are zeroed indicating that the static arrays are gone.
  */
-void __init setup_percpu_maps(void)
+static void __init setup_per_cpu_maps(void)
 {
 	int cpu;
 
@@ -114,7 +114,7 @@ void __init setup_percpu_maps(void)
 #endif
 	}
 
-	/* indicate the early static arrays are gone */
+	/* indicate the early static arrays will soon be gone */
 	x86_cpu_to_apicid_early_ptr = NULL;
 	x86_bios_cpu_apicid_early_ptr = NULL;
 #ifdef CONFIG_NUMA
@@ -157,7 +157,7 @@ void __init setup_per_cpu_areas(void)
 	}
 
 	/* setup percpu data maps early */
-	setup_percpu_maps();
+	setup_per_cpu_maps();
 } 
 
 void pda_init(int cpu)
--- a/arch/x86/kernel/smpboot_32.c
+++ b/arch/x86/kernel/smpboot_32.c
@@ -460,7 +460,7 @@ cpumask_t node_to_cpumask_map[MAX_NUMNOD
 				{ [0 ... MAX_NUMNODES-1] = CPU_MASK_NONE };
 EXPORT_SYMBOL(node_to_cpumask_map);
 /* which node each logical CPU is on */
-u8 cpu_to_node_map[NR_CPUS] __read_mostly = { [0 ... NR_CPUS-1] = 0 };
+int cpu_to_node_map[NR_CPUS] __read_mostly = { [0 ... NR_CPUS-1] = 0 };
 EXPORT_SYMBOL(cpu_to_node_map);
 
 /* set up a mapping between cpu and node. */
--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -31,17 +31,15 @@ bootmem_data_t plat_node_bdata[MAX_NUMNO
 
 struct memnode memnode;
 
-u16 x86_cpu_to_node_map_init[NR_CPUS] = {
+int x86_cpu_to_node_map_init[NR_CPUS] = {
 	[0 ... NR_CPUS-1] = NUMA_NO_NODE
 };
 void *x86_cpu_to_node_map_early_ptr;
-DEFINE_PER_CPU(u16, x86_cpu_to_node_map) = NUMA_NO_NODE;
+DEFINE_PER_CPU(int, x86_cpu_to_node_map) = NUMA_NO_NODE;
 EXPORT_PER_CPU_SYMBOL(x86_cpu_to_node_map);
-#ifdef	CONFIG_DEBUG_PER_CPU_MAPS
 EXPORT_SYMBOL(x86_cpu_to_node_map_early_ptr);
-#endif
 
-u16 apicid_to_node[MAX_LOCAL_APIC] __cpuinitdata = {
+s16 apicid_to_node[MAX_LOCAL_APIC] __cpuinitdata = {
 	[0 ... MAX_LOCAL_APIC-1] = NUMA_NO_NODE
 };
 
@@ -65,7 +63,7 @@ static int __init populate_memnodemap(co
 	unsigned long addr, end;
 	int i, res = -1;
 
-	memset(memnodemap, 0xff, memnodemapsize);
+	memset(memnodemap, 0xff, sizeof(s16)*memnodemapsize);
 	for (i = 0; i < numnodes; i++) {
 		addr = nodes[i].start;
 		end = nodes[i].end;
@@ -74,7 +72,7 @@ static int __init populate_memnodemap(co
 		if ((end >> shift) >= memnodemapsize)
 			return 0;
 		do {
-			if (memnodemap[addr >> shift] != 0xff)
+			if (memnodemap[addr >> shift] != NUMA_NO_NODE)
 				return -1;
 			memnodemap[addr >> shift] = i;
 			addr += (1UL << shift);
@@ -535,7 +533,7 @@ __cpuinit void numa_add_cpu(int cpu)
 
 void __cpuinit numa_set_node(int cpu, int node)
 {
-	u16 *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
+	int *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
 
 	cpu_pda(cpu)->nodenumber = node;
 
--- a/arch/x86/mm/srat_64.c
+++ b/arch/x86/mm/srat_64.c
@@ -397,7 +397,7 @@ int __init acpi_scan_nodes(unsigned long
 static int fake_node_to_pxm_map[MAX_NUMNODES] __initdata = {
 	[0 ... MAX_NUMNODES-1] = PXM_INVAL
 };
-static u16 fake_apicid_to_node[MAX_LOCAL_APIC] __initdata = {
+static s16 fake_apicid_to_node[MAX_LOCAL_APIC] __initdata = {
 	[0 ... MAX_LOCAL_APIC-1] = NUMA_NO_NODE
 };
 static int __init find_node_by_addr(unsigned long addr)
--- a/include/asm-generic/percpu.h
+++ b/include/asm-generic/percpu.h
@@ -47,7 +47,7 @@ extern unsigned long __per_cpu_offset[NR
 #endif
 
 /*
- * A percpu variable may point to a discarded reghions. The following are
+ * A percpu variable may point to a discarded regions. The following are
  * established ways to produce a usable pointer from the percpu variable
  * offset.
  */
@@ -59,18 +59,10 @@ extern unsigned long __per_cpu_offset[NR
 	(*SHIFT_PERCPU_PTR(&per_cpu_var(var), __my_cpu_offset))
 
 
-#ifdef CONFIG_ARCH_SETS_UP_PER_CPU_AREA
+#ifdef CONFIG_HAVE_SETUP_PER_CPU_AREA
 extern void setup_per_cpu_areas(void);
 #endif
 
-/* A macro to avoid #include hell... */
-#define percpu_modcopy(pcpudst, src, size)			\
-do {								\
-	unsigned int __i;					\
-	for_each_possible_cpu(__i)				\
-		memcpy((pcpudst)+per_cpu_offset(__i),		\
-		       (src), (size));				\
-} while (0)
 #else /* ! SMP */
 
 #define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu_var(var)))
--- a/include/asm-x86/mmzone_64.h
+++ b/include/asm-x86/mmzone_64.h
@@ -15,9 +15,9 @@
 struct memnode {
 	int shift;
 	unsigned int mapsize;
-	u8 *map;
-	u8 embedded_map[64-16];
-} ____cacheline_aligned; /* total size = 64 bytes */
+	s16 *map;
+	s16 embedded_map[64-8];
+} ____cacheline_aligned; /* total size = 128 bytes */
 extern struct memnode memnode;
 #define memnode_shift memnode.shift
 #define memnodemap memnode.map
--- a/include/asm-x86/numa_64.h
+++ b/include/asm-x86/numa_64.h
@@ -20,7 +20,7 @@ extern void numa_set_node(int cpu, int n
 extern void srat_reserve_add_area(int nodeid);
 extern int hotadd_percent;
 
-extern u16 apicid_to_node[MAX_LOCAL_APIC];
+extern s16 apicid_to_node[MAX_LOCAL_APIC];
 
 extern void numa_initmem_init(unsigned long start_pfn, unsigned long end_pfn);
 extern unsigned long numa_free_all_bootmem(void);
--- a/include/asm-x86/topology.h
+++ b/include/asm-x86/topology.h
@@ -31,17 +31,19 @@
 
 /* Mappings between logical cpu number and node number */
 #ifdef CONFIG_X86_32
-extern u8 cpu_to_node_map[];
+extern int cpu_to_node_map[];
 
 #else
-DECLARE_PER_CPU(u16, x86_cpu_to_node_map);
-extern u16 x86_cpu_to_node_map_init[];
+DECLARE_PER_CPU(int, x86_cpu_to_node_map);
+extern int x86_cpu_to_node_map_init[];
 extern void *x86_cpu_to_node_map_early_ptr;
+/* Returns the number of the current Node. */
+#define numa_node_id()		(early_cpu_to_node(raw_smp_processor_id()))
 #endif
 
 extern cpumask_t node_to_cpumask_map[];
 
-#define NUMA_NO_NODE	((u16)(~0))
+#define NUMA_NO_NODE	(-1)
 
 /* Returns the number of the node containing CPU 'cpu' */
 #ifdef CONFIG_X86_32
@@ -54,11 +56,11 @@ static inline int cpu_to_node(int cpu)
 #else /* CONFIG_X86_64 */
 static inline int early_cpu_to_node(int cpu)
 {
-	u16 *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
+	int *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
 
 	if (cpu_to_node_map)
 		return cpu_to_node_map[cpu];
-	else if(per_cpu_offset(cpu))
+	else if (per_cpu_offset(cpu))
 		return per_cpu(x86_cpu_to_node_map, cpu);
 	else
 		return NUMA_NO_NODE;
@@ -71,7 +73,7 @@ static inline int cpu_to_node(int cpu)
 		printk("KERN_NOTICE cpu_to_node(%d): usage too early!\n",
 			(int)cpu);
 		dump_stack();
-		return ((u16 *)x86_cpu_to_node_map_early_ptr)[cpu];
+		return ((int *)x86_cpu_to_node_map_early_ptr)[cpu];
 	}
 #endif
 	if (per_cpu_offset(cpu))
--- a/init/main.c
+++ b/init/main.c
@@ -363,7 +363,7 @@ static inline void smp_prepare_cpus(unsi
 
 #else
 
-#ifndef CONFIG_ARCH_SETS_UP_PER_CPU_AREA
+#ifndef CONFIG_HAVE_SETUP_PER_CPU_AREA
 unsigned long __per_cpu_offset[NR_CPUS] __read_mostly;
 
 EXPORT_SYMBOL(__per_cpu_offset);
@@ -384,7 +384,7 @@ static void __init setup_per_cpu_areas(v
 		ptr += size;
 	}
 }
-#endif /* CONFIG_ARCH_SETS_UP_CPU_AREA */
+#endif /* CONFIG_HAVE_SETUP_PER_CPU_AREA */
 
 /* Called by boot processor to activate the rest. */
 static void __init smp_init(void)
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -427,6 +427,14 @@ static unsigned int find_pcpusec(Elf_Ehd
 	return find_sec(hdr, sechdrs, secstrings, ".data.percpu");
 }
 
+static void percpu_modcopy(void *pcpudest, const void *from, unsigned long size)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		memcpy(pcpudest + per_cpu_offset(cpu), from, size);
+}
+
 static int percpu_modinit(void)
 {
 	pcpu_num_used = 2;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
