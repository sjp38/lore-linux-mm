Message-Id: <20070912015646.663194236@sgi.com>
References: <20070912015644.927677070@sgi.com>
Date: Tue, 11 Sep 2007 18:56:50 -0700
From: travis@sgi.com
Subject: [PATCH 06/10] x86: Convert cpu_llc_id to be a per cpu variable (v3)
Content-Disposition: inline; filename=convert-cpu_llc_id-to-per_cpu_data
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Convert cpu_llc_id from a static array sized by NR_CPUS to a
per_cpu variable.  This saves sizeof(cpu_llc_id) * NR unused
cpus.  Access is mostly from startup and CPU HOTPLUG functions.

Note there's an addtional change of the type of cpu_llc_id
from int to u8 for ARCH i386 to correspond with the same
type in ARCH x86_64.

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/i386/kernel/cpu/intel_cacheinfo.c |    4 ++--
 arch/i386/kernel/smpboot.c             |    6 +++---
 arch/x86_64/kernel/smpboot.c           |    6 +++---
 include/asm-i386/processor.h           |    6 +++++-
 include/asm-x86_64/smp.h               |    9 ++++-----
 5 files changed, 17 insertions(+), 14 deletions(-)

--- a/arch/i386/kernel/cpu/intel_cacheinfo.c
+++ b/arch/i386/kernel/cpu/intel_cacheinfo.c
@@ -417,14 +417,14 @@
 	if (new_l2) {
 		l2 = new_l2;
 #ifdef CONFIG_X86_HT
-		cpu_llc_id[cpu] = l2_id;
+		per_cpu(cpu_llc_id, cpu) = l2_id;
 #endif
 	}
 
 	if (new_l3) {
 		l3 = new_l3;
 #ifdef CONFIG_X86_HT
-		cpu_llc_id[cpu] = l3_id;
+		per_cpu(cpu_llc_id, cpu) = l3_id;
 #endif
 	}
 
--- a/arch/i386/kernel/smpboot.c
+++ b/arch/i386/kernel/smpboot.c
@@ -67,7 +67,7 @@
 EXPORT_SYMBOL(smp_num_siblings);
 
 /* Last level cache ID of each logical CPU */
-int cpu_llc_id[NR_CPUS] __cpuinitdata = {[0 ... NR_CPUS-1] = BAD_APICID};
+DEFINE_PER_CPU(u8, cpu_llc_id) = BAD_APICID;
 
 /* representing HT siblings of each logical CPU */
 DEFINE_PER_CPU(cpumask_t, cpu_sibling_map);
@@ -348,8 +348,8 @@
 	}
 
 	for_each_cpu_mask(i, cpu_sibling_setup_map) {
-		if (cpu_llc_id[cpu] != BAD_APICID &&
-		    cpu_llc_id[cpu] == cpu_llc_id[i]) {
+		if (per_cpu(cpu_llc_id, cpu) != BAD_APICID &&
+		    per_cpu(cpu_llc_id, cpu) == per_cpu(cpu_llc_id, i)) {
 			cpu_set(i, c[cpu].llc_shared_map);
 			cpu_set(cpu, c[i].llc_shared_map);
 		}
--- a/arch/x86_64/kernel/smpboot.c
+++ b/arch/x86_64/kernel/smpboot.c
@@ -65,7 +65,7 @@
 EXPORT_SYMBOL(smp_num_siblings);
 
 /* Last level cache ID of each logical CPU */
-u8 cpu_llc_id[NR_CPUS] __cpuinitdata  = {[0 ... NR_CPUS-1] = BAD_APICID};
+DEFINE_PER_CPU(u8, cpu_llc_id) = BAD_APICID;
 
 /* Bitmask of currently online CPUs */
 cpumask_t cpu_online_map __read_mostly;
@@ -285,8 +285,8 @@
 	}
 
 	for_each_cpu_mask(i, cpu_sibling_setup_map) {
-		if (cpu_llc_id[cpu] != BAD_APICID &&
-		    cpu_llc_id[cpu] == cpu_llc_id[i]) {
+		if (per_cpu(cpu_llc_id, cpu) != BAD_APICID &&
+		    per_cpu(cpu_llc_id, cpu) == per_cpu(cpu_llc_id, i)) {
 			cpu_set(i, c[cpu].llc_shared_map);
 			cpu_set(cpu, c[i].llc_shared_map);
 		}
--- a/include/asm-i386/processor.h
+++ b/include/asm-i386/processor.h
@@ -110,7 +110,11 @@
 #define current_cpu_data boot_cpu_data
 #endif
 
-extern	int cpu_llc_id[NR_CPUS];
+/*
+ * the following now lives in the per cpu area:
+ * extern	int cpu_llc_id[NR_CPUS];
+ */
+DECLARE_PER_CPU(u8, cpu_llc_id);
 extern char ignore_fpu_irq;
 
 void __init cpu_detect(struct cpuinfo_x86 *c);
--- a/include/asm-x86_64/smp.h
+++ b/include/asm-x86_64/smp.h
@@ -39,16 +39,14 @@
 extern void smp_send_reschedule(int cpu);
 
 /*
- * cpu_sibling_map and cpu_core_map now live
- * in the per cpu area
- *
+ * the following now live in the per cpu area:
  * extern cpumask_t cpu_sibling_map[NR_CPUS];
  * extern cpumask_t cpu_core_map[NR_CPUS];
+ * extern u8 cpu_llc_id[NR_CPUS];
  */
 DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
 DECLARE_PER_CPU(cpumask_t, cpu_core_map);
-
-extern u8 cpu_llc_id[NR_CPUS];
+DECLARE_PER_CPU(u8, cpu_llc_id);
 
 #define SMP_TRAMPOLINE_BASE 0x6000
 
@@ -120,6 +118,7 @@
 #ifdef CONFIG_SMP
 #define cpu_physical_id(cpu)		per_cpu(x86_cpu_to_apicid, cpu)
 #else
+extern unsigned int boot_cpu_id;
 #define cpu_physical_id(cpu)		boot_cpu_id
 #endif /* !CONFIG_SMP */
 #endif

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
