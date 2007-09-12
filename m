Message-Id: <20070912015646.388900350@sgi.com>
References: <20070912015644.927677070@sgi.com>
Date: Tue, 11 Sep 2007 18:56:49 -0700
From: travis@sgi.com
Subject: [PATCH 05/10] x86: Convert x86_cpu_to_apicid to be a per cpu variable (v3)
Content-Disposition: inline; filename=convert-x86_cpu_to_apicid-to-per_cpu_data
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch converts the x86_cpu_to_apicid array to be a per
cpu variable.  This saves sizeof(apicid) * NR unused cpus.
Access is mostly from startup and CPU HOTPLUG functions.

MP_processor_info() is one of the functions that require access
to the x86_cpu_to_apicid array before the per_cpu data area is
setup.  For this case, a pointer to the __initdata array is
initialized in setup_arch() and removed in smp_prepare_cpus()
after the per_cpu data area is initialized.

A second change is included to change the initial array value
of ARCH i386 from 0xff to BAD_APICID to be consistent with
ARCH x86_64.

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/i386/kernel/acpi/boot.c      |    2 +-
 arch/i386/kernel/smp.c            |    2 +-
 arch/i386/kernel/smpboot.c        |   22 +++++++++++++++-------
 arch/x86_64/kernel/genapic.c      |   15 ++++++++++++---
 arch/x86_64/kernel/genapic_flat.c |    2 +-
 arch/x86_64/kernel/mpparse.c      |   15 +++++++++++++--
 arch/x86_64/kernel/setup.c        |    5 +++++
 arch/x86_64/kernel/smpboot.c      |   23 ++++++++++++++++++++++-
 arch/x86_64/mm/numa.c             |    2 +-
 include/asm-i386/smp.h            |    6 ++++--
 include/asm-x86_64/ipi.h          |    2 +-
 include/asm-x86_64/smp.h          |    6 ++++--
 12 files changed, 80 insertions(+), 22 deletions(-)

--- a/arch/i386/kernel/acpi/boot.c
+++ b/arch/i386/kernel/acpi/boot.c
@@ -555,7 +555,7 @@
 
 int acpi_unmap_lsapic(int cpu)
 {
-	x86_cpu_to_apicid[cpu] = -1;
+	per_cpu(x86_cpu_to_apicid, cpu) = -1;
 	cpu_clear(cpu, cpu_present_map);
 	num_processors--;
 
--- a/arch/i386/kernel/smp.c
+++ b/arch/i386/kernel/smp.c
@@ -673,7 +673,7 @@
 	int i;
 
 	for (i = 0; i < NR_CPUS; i++) {
-		if (x86_cpu_to_apicid[i] == apic_id)
+		if (per_cpu(x86_cpu_to_apicid, i) == apic_id)
 			return i;
 	}
 	return -1;
--- a/arch/i386/kernel/smpboot.c
+++ b/arch/i386/kernel/smpboot.c
@@ -92,9 +92,17 @@
 struct cpuinfo_x86 cpu_data[NR_CPUS] __cacheline_aligned;
 EXPORT_SYMBOL(cpu_data);
 
-u8 x86_cpu_to_apicid[NR_CPUS] __read_mostly =
-			{ [0 ... NR_CPUS-1] = 0xff };
-EXPORT_SYMBOL(x86_cpu_to_apicid);
+/*
+ * The following static array is used during kernel startup
+ * and the x86_cpu_to_apicid_ptr contains the address of the
+ * array during this time.  Is it zeroed when the per_cpu
+ * data area is removed.
+ */
+u8 x86_cpu_to_apicid_init[NR_CPUS] __initdata =
+			{ [0 ... NR_CPUS-1] = BAD_APICID };
+void *x86_cpu_to_apicid_ptr;
+DEFINE_PER_CPU(u8, x86_cpu_to_apicid) = BAD_APICID;
+EXPORT_PER_CPU_SYMBOL(x86_cpu_to_apicid);
 
 u8 apicid_2_node[MAX_APICID];
 
@@ -804,7 +812,7 @@
 
 	irq_ctx_init(cpu);
 
-	x86_cpu_to_apicid[cpu] = apicid;
+	per_cpu(x86_cpu_to_apicid, cpu) = apicid;
 	/*
 	 * This grunge runs the startup process for
 	 * the targeted processor.
@@ -866,7 +874,7 @@
 		cpu_clear(cpu, cpu_initialized); /* was set by cpu_init() */
 		cpucount--;
 	} else {
-		x86_cpu_to_apicid[cpu] = apicid;
+		per_cpu(x86_cpu_to_apicid, cpu) = apicid;
 		cpu_set(cpu, cpu_present_map);
 	}
 
@@ -915,7 +923,7 @@
 	struct warm_boot_cpu_info info;
 	int	apicid, ret;
 
-	apicid = x86_cpu_to_apicid[cpu];
+	apicid = per_cpu(x86_cpu_to_apicid, cpu);
 	if (apicid == BAD_APICID) {
 		ret = -ENODEV;
 		goto exit;
@@ -965,7 +973,7 @@
 
 	boot_cpu_physical_apicid = GET_APIC_ID(apic_read(APIC_ID));
 	boot_cpu_logical_apicid = logical_smp_processor_id();
-	x86_cpu_to_apicid[0] = boot_cpu_physical_apicid;
+	per_cpu(x86_cpu_to_apicid, 0) = boot_cpu_physical_apicid;
 
 	current_thread_info()->cpu = 0;
 
--- a/arch/x86_64/kernel/mpparse.c
+++ b/arch/x86_64/kernel/mpparse.c
@@ -86,7 +86,7 @@
 	return sum & 0xFF;
 }
 
-static void __cpuinit MP_processor_info (struct mpc_config_processor *m)
+static void __cpuinit MP_processor_info(struct mpc_config_processor *m)
 {
 	int cpu;
 	cpumask_t tmp_map;
@@ -123,7 +123,18 @@
 		cpu = 0;
  	}
 	bios_cpu_apicid[cpu] = m->mpc_apicid;
-	x86_cpu_to_apicid[cpu] = m->mpc_apicid;
+	/*
+	 * We get called early in the the start_kernel initialization
+	 * process when the per_cpu data area is not yet setup, so we
+	 * use a static array that is removed after the per_cpu data
+	 * area is created.
+	 */
+	if (x86_cpu_to_apicid_ptr) {
+		u8 *x86_cpu_to_apicid = (u8 *)x86_cpu_to_apicid_ptr;
+		x86_cpu_to_apicid[cpu] = m->mpc_apicid;
+	} else {
+		per_cpu(x86_cpu_to_apicid, cpu) = m->mpc_apicid;
+	}
 
 	cpu_set(cpu, cpu_possible_map);
 	cpu_set(cpu, cpu_present_map);
--- a/arch/x86_64/kernel/smpboot.c
+++ b/arch/x86_64/kernel/smpboot.c
@@ -701,7 +701,7 @@
 		clear_node_cpumask(cpu); /* was set by numa_add_cpu */
 		cpu_clear(cpu, cpu_present_map);
 		cpu_clear(cpu, cpu_possible_map);
-		x86_cpu_to_apicid[cpu] = BAD_APICID;
+		per_cpu(x86_cpu_to_apicid, cpu) = BAD_APICID;
 		return -EIO;
 	}
 
@@ -848,6 +848,26 @@
 }
 
 /*
+ * Copy apicid's found by MP_processor_info from initial array to the per cpu
+ * data area.  The x86_cpu_to_apicid_init array is then expendable and the
+ * x86_cpu_to_apicid_ptr is zeroed indicating that the static array is no
+ * longer available.
+ */
+void __init smp_set_apicids(void)
+{
+	int cpu;
+
+	for_each_cpu_mask(cpu, cpu_possible_map) {
+		if (per_cpu_offset(cpu))
+			per_cpu(x86_cpu_to_apicid, cpu) =
+						x86_cpu_to_apicid_init[cpu];
+	}
+
+	/* indicate the static array will be going away soon */
+	x86_cpu_to_apicid_ptr = NULL;
+}
+
+/*
  * Prepare for SMP bootup.  The MP table or ACPI has been read
  * earlier.  Just do some sanity checking here and enable APIC mode.
  */
@@ -856,6 +876,7 @@
 	nmi_watchdog_default();
 	current_cpu_data = boot_cpu_data;
 	current_thread_info()->cpu = 0;  /* needed? */
+	smp_set_apicids();
 	set_cpu_sibling_map(0);
 
 	if (smp_sanity_check(max_cpus) < 0) {
--- a/arch/x86_64/mm/numa.c
+++ b/arch/x86_64/mm/numa.c
@@ -612,7 +612,7 @@
 {
 	int i;
  	for (i = 0; i < NR_CPUS; i++) {
-		u8 apicid = x86_cpu_to_apicid[i];
+		u8 apicid = x86_cpu_to_apicid_init[i];
 		if (apicid == BAD_APICID)
 			continue;
 		if (apicid_to_node[apicid] == NUMA_NO_NODE)
--- a/include/asm-i386/smp.h
+++ b/include/asm-i386/smp.h
@@ -39,9 +39,11 @@
 extern void unlock_ipi_call_lock(void);
 
 #define MAX_APICID 256
-extern u8 x86_cpu_to_apicid[];
+extern u8 __initdata x86_cpu_to_apicid_init[];
+extern void *x86_cpu_to_apicid_ptr;
+DECLARE_PER_CPU(u8, x86_cpu_to_apicid);
 
-#define cpu_physical_id(cpu)	x86_cpu_to_apicid[cpu]
+#define cpu_physical_id(cpu)	per_cpu(x86_cpu_to_apicid, cpu)
 
 extern void set_cpu_sibling_map(int cpu);
 
--- a/include/asm-x86_64/ipi.h
+++ b/include/asm-x86_64/ipi.h
@@ -119,7 +119,7 @@
 	 */
 	local_irq_save(flags);
 	for_each_cpu_mask(query_cpu, mask) {
-		__send_IPI_dest_field(x86_cpu_to_apicid[query_cpu],
+		__send_IPI_dest_field(per_cpu(x86_cpu_to_apicid, query_cpu),
 				      vector, APIC_DEST_PHYSICAL);
 	}
 	local_irq_restore(flags);
--- a/include/asm-x86_64/smp.h
+++ b/include/asm-x86_64/smp.h
@@ -85,7 +85,9 @@
  * Some lowlevel functions might want to know about
  * the real APIC ID <-> CPU # mapping.
  */
-extern u8 x86_cpu_to_apicid[NR_CPUS];	/* physical ID */
+extern u8 __initdata x86_cpu_to_apicid_init[];
+extern void *x86_cpu_to_apicid_ptr;
+DECLARE_PER_CPU(u8, x86_cpu_to_apicid);	/* physical ID */
 extern u8 bios_cpu_apicid[];
 
 static inline int cpu_present_to_apicid(int mps_cpu)
@@ -116,7 +118,7 @@
 }
 
 #ifdef CONFIG_SMP
-#define cpu_physical_id(cpu)		x86_cpu_to_apicid[cpu]
+#define cpu_physical_id(cpu)		per_cpu(x86_cpu_to_apicid, cpu)
 #else
 #define cpu_physical_id(cpu)		boot_cpu_id
 #endif /* !CONFIG_SMP */
--- a/arch/x86_64/kernel/genapic_flat.c
+++ b/arch/x86_64/kernel/genapic_flat.c
@@ -172,7 +172,7 @@
 	 */
 	cpu = first_cpu(cpumask);
 	if ((unsigned)cpu < NR_CPUS)
-		return x86_cpu_to_apicid[cpu];
+		return per_cpu(x86_cpu_to_apicid, cpu);
 	else
 		return BAD_APICID;
 }
--- a/arch/x86_64/kernel/genapic.c
+++ b/arch/x86_64/kernel/genapic.c
@@ -24,10 +24,19 @@
 #include <acpi/acpi_bus.h>
 #endif
 
-/* which logical CPU number maps to which CPU (physical APIC ID) */
-u8 x86_cpu_to_apicid[NR_CPUS] __read_mostly
+/*
+ * which logical CPU number maps to which CPU (physical APIC ID)
+ *
+ * The following static array is used during kernel startup
+ * and the x86_cpu_to_apicid_ptr contains the address of the
+ * array during this time.  Is it zeroed when the per_cpu
+ * data area is removed.
+ */
+u8 x86_cpu_to_apicid_init[NR_CPUS] __initdata
 					= { [0 ... NR_CPUS-1] = BAD_APICID };
-EXPORT_SYMBOL(x86_cpu_to_apicid);
+void *x86_cpu_to_apicid_ptr;
+DEFINE_PER_CPU(u8, x86_cpu_to_apicid) = BAD_APICID;
+EXPORT_PER_CPU_SYMBOL(x86_cpu_to_apicid);
 
 struct genapic __read_mostly *genapic = &apic_flat;
 
--- a/arch/x86_64/kernel/setup.c
+++ b/arch/x86_64/kernel/setup.c
@@ -276,6 +276,11 @@
 
 	dmi_scan_machine();
 
+#ifdef CONFIG_SMP
+	/* setup to use the static apicid table during kernel startup */
+	x86_cpu_to_apicid_ptr = (void *)&x86_cpu_to_apicid_init;
+#endif
+
 #ifdef CONFIG_ACPI
 	/*
 	 * Initialize the ACPI boot-time table parser (gets the RSDP and SDT).

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
