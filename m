Message-Id: <20080121211618.912440000@sgi.com>
References: <20080121211618.599818000@sgi.com>
Date: Mon, 21 Jan 2008 13:16:20 -0800
From: travis@sgi.com
Subject: [PATCH 2/3] x86: Change NR_CPUS arrays in numa_64 fixup V2 with git-x86
Content-Disposition: inline; filename=NR_CPUS-arrays-in-numa_64-fixup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Change the following static arrays sized by NR_CPUS to
per_cpu data variables:

	char cpu_to_node_map[NR_CPUS];

Based on 2.6.24-rc8-mm1 + latest (08/1/21) git-x86

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
 arch/x86/kernel/setup64.c    |   10 +++++-----
 arch/x86/kernel/smpboot_32.c |    2 +-
 arch/x86/mm/srat_64.c        |    2 +-
 include/asm-x86/topology.h   |    9 +++++++++
 4 files changed, 16 insertions(+), 7 deletions(-)

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
--- a/arch/x86/mm/srat_64.c
+++ b/arch/x86/mm/srat_64.c
@@ -408,7 +408,7 @@ int __init acpi_scan_nodes(unsigned long
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
@@ -81,6 +81,15 @@ static inline int cpu_to_node(int cpu)
 }
 #endif /* CONFIG_X86_64 */
 
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
