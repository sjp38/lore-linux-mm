Message-Id: <20080113183454.944455000@sgi.com>
References: <20080113183453.973425000@sgi.com>
Date: Sun, 13 Jan 2008 10:35:00 -0800
From: travis@sgi.com
Subject: [PATCH 07/10] x86: Cleanup x86_cpu_to_apicid references
Content-Disposition: inline; filename=cleanup-x86_cpu_to_apicid
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Clean up references to x86_cpu_to_apicid.  Removes extraneous
comments and standardizes on "x86_*_early_ptr" for the early
kernel init references.

Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
 arch/x86/kernel/genapic_64.c |   11 ++---------
 arch/x86/kernel/mpparse_64.c |   11 +++--------
 arch/x86/kernel/setup_64.c   |    2 +-
 arch/x86/kernel/smpboot_32.c |    9 ++-------
 arch/x86/kernel/smpboot_64.c |   16 +++++++++-------
 include/asm-x86/smp_32.h     |    2 +-
 include/asm-x86/smp_64.h     |    2 +-
 7 files changed, 19 insertions(+), 34 deletions(-)

--- a/arch/x86/kernel/genapic_64.c
+++ b/arch/x86/kernel/genapic_64.c
@@ -24,17 +24,10 @@
 #include <acpi/acpi_bus.h>
 #endif
 
-/*
- * which logical CPU number maps to which CPU (physical APIC ID)
- *
- * The following static array is used during kernel startup
- * and the x86_cpu_to_apicid_ptr contains the address of the
- * array during this time.  Is it zeroed when the per_cpu
- * data area is removed.
- */
+/* which logical CPU number maps to which CPU (physical APIC ID) */
 u16 x86_cpu_to_apicid_init[NR_CPUS] __initdata
 					= { [0 ... NR_CPUS-1] = BAD_APICID };
-void *x86_cpu_to_apicid_ptr;
+void *x86_cpu_to_apicid_early_ptr;
 DEFINE_PER_CPU(u16, x86_cpu_to_apicid) = BAD_APICID;
 EXPORT_PER_CPU_SYMBOL(x86_cpu_to_apicid);
 
--- a/arch/x86/kernel/mpparse_64.c
+++ b/arch/x86/kernel/mpparse_64.c
@@ -125,14 +125,9 @@ static void __cpuinit MP_processor_info(
 		cpu = 0;
  	}
 	bios_cpu_apicid[cpu] = m->mpc_apicid;
-	/*
-	 * We get called early in the the start_kernel initialization
-	 * process when the per_cpu data area is not yet setup, so we
-	 * use a static array that is removed after the per_cpu data
-	 * area is created.
-	 */
-	if (x86_cpu_to_apicid_ptr) {
-		u16 *x86_cpu_to_apicid = (u16 *)x86_cpu_to_apicid_ptr;
+	/* are we being called early in kernel startup? */
+	if (x86_cpu_to_apicid_early_ptr) {
+		u16 *x86_cpu_to_apicid = (u16 *)x86_cpu_to_apicid_early_ptr;
 		x86_cpu_to_apicid[cpu] = m->mpc_apicid;
 	} else {
 		per_cpu(x86_cpu_to_apicid, cpu) = m->mpc_apicid;
--- a/arch/x86/kernel/setup_64.c
+++ b/arch/x86/kernel/setup_64.c
@@ -373,7 +373,7 @@ void __init setup_arch(char **cmdline_p)
 
 #ifdef CONFIG_SMP
 	/* setup to use the static apicid table during kernel startup */
-	x86_cpu_to_apicid_ptr = (void *)&x86_cpu_to_apicid_init;
+	x86_cpu_to_apicid_early_ptr = (void *)&x86_cpu_to_apicid_init;
 #endif
 
 #ifdef CONFIG_ACPI
--- a/arch/x86/kernel/smpboot_32.c
+++ b/arch/x86/kernel/smpboot_32.c
@@ -91,15 +91,10 @@ static cpumask_t smp_commenced_mask;
 DEFINE_PER_CPU_SHARED_ALIGNED(struct cpuinfo_x86, cpu_info);
 EXPORT_PER_CPU_SYMBOL(cpu_info);
 
-/*
- * The following static array is used during kernel startup
- * and the x86_cpu_to_apicid_ptr contains the address of the
- * array during this time.  Is it zeroed when the per_cpu
- * data area is removed.
- */
+/* which logical CPU number maps to which CPU (physical APIC ID) */
 u8 x86_cpu_to_apicid_init[NR_CPUS] __initdata =
 			{ [0 ... NR_CPUS-1] = BAD_APICID };
-void *x86_cpu_to_apicid_ptr;
+void *x86_cpu_to_apicid_early_ptr;
 DEFINE_PER_CPU(u8, x86_cpu_to_apicid) = BAD_APICID;
 EXPORT_PER_CPU_SYMBOL(x86_cpu_to_apicid);
 
--- a/arch/x86/kernel/smpboot_64.c
+++ b/arch/x86/kernel/smpboot_64.c
@@ -852,23 +852,25 @@ static int __init smp_sanity_check(unsig
 }
 
 /*
- * Copy apicid's found by MP_processor_info from initial array to the per cpu
- * data area.  The x86_cpu_to_apicid_init array is then expendable and the
- * x86_cpu_to_apicid_ptr is zeroed indicating that the static array is no
- * longer available.
+ * Copy data used in early init routines from the initial arrays to the
+ * per cpu data areas.  These arrays then become expendable and the
+ * *_ptrs are zeroed indicating that the static arrays are gone.
  */
 void __init smp_set_apicids(void)
 {
 	int cpu;
 
-	for_each_cpu_mask(cpu, cpu_possible_map) {
+	for_each_possible_cpu(cpu) {
 		if (per_cpu_offset(cpu))
 			per_cpu(x86_cpu_to_apicid, cpu) =
 						x86_cpu_to_apicid_init[cpu];
+		else
+			printk(KERN_NOTICE "per_cpu_offset zero for cpu %d\n",
+									cpu);
 	}
 
-	/* indicate the static array will be going away soon */
-	x86_cpu_to_apicid_ptr = NULL;
+	/* indicate the early static arrays are gone */
+	x86_cpu_to_apicid_early_ptr = NULL;
 }
 
 static void __init smp_cpu_index_default(void)
--- a/include/asm-x86/smp_32.h
+++ b/include/asm-x86/smp_32.h
@@ -30,7 +30,7 @@ extern void (*mtrr_hook) (void);
 extern void zap_low_mappings (void);
 
 extern u8 __initdata x86_cpu_to_apicid_init[];
-extern void *x86_cpu_to_apicid_ptr;
+extern void *x86_cpu_to_apicid_early_ptr;
 
 DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
 DECLARE_PER_CPU(cpumask_t, cpu_core_map);
--- a/include/asm-x86/smp_64.h
+++ b/include/asm-x86/smp_64.h
@@ -27,7 +27,7 @@ extern int smp_call_function_mask(cpumas
 				  void *info, int wait);
 
 extern u16 __initdata x86_cpu_to_apicid_init[];
-extern void *x86_cpu_to_apicid_ptr;
+extern void *x86_cpu_to_apicid_early_ptr;
 extern u16 bios_cpu_apicid[];
 
 DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
