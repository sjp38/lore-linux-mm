Message-Id: <20070907040943.826587152@sgi.com>
References: <20070907040943.467530005@sgi.com>
Date: Thu, 06 Sep 2007 21:09:44 -0700
From: travis@sgi.com
Subject: [PATCH 1/3] core: Provide an arch independent means of accessing cpu_sibling_map
Content-Disposition: inline; filename=fix-sched-build-error-with-cpu_sibling_map
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

As the block/blktrace.c and kernel/sched.c are common (core) files for
all architectures, an access function has been defined for referencing
the cpu_sibling_map array.

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/ia64/Kconfig        |    1 -
 block/blktrace.c         |    2 +-
 include/asm-i386/smp.h   |    1 +
 include/asm-x86_64/smp.h |    1 +
 include/linux/smp.h      |    6 ++++++
 kernel/sched.c           |    8 ++++----
 6 files changed, 13 insertions(+), 6 deletions(-)

--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -308,7 +308,6 @@
 config SCHED_SMT
 	bool "SMT scheduler support"
 	depends on SMP
-	depends on BROKEN
 	help
 	  Improves the CPU scheduler's decision making when dealing with
 	  Intel IA64 chips with MultiThreading at a cost of slightly increased
--- a/block/blktrace.c
+++ b/block/blktrace.c
@@ -536,7 +536,7 @@
 	for_each_online_cpu(cpu) {
 		unsigned long long *cpu_off, *sibling_off;
 
-		for_each_cpu_mask(i, per_cpu(cpu_sibling_map, cpu)) {
+		for_each_cpu_mask(i, cpu_sibling_map(cpu)) {
 			if (i == cpu)
 				continue;
 
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -5905,7 +5905,7 @@
 			     struct sched_group **sg)
 {
 	int group;
-	cpumask_t mask = per_cpu(cpu_sibling_map, cpu);
+	cpumask_t mask = cpu_sibling_map(cpu);
 	cpus_and(mask, mask, *cpu_map);
 	group = first_cpu(mask);
 	if (sg)
@@ -5934,7 +5934,7 @@
 	cpus_and(mask, mask, *cpu_map);
 	group = first_cpu(mask);
 #elif defined(CONFIG_SCHED_SMT)
-	cpumask_t mask = per_cpu(cpu_sibling_map, cpu);
+	cpumask_t mask = cpu_sibling_map(cpu);
 	cpus_and(mask, mask, *cpu_map);
 	group = first_cpu(mask);
 #else
@@ -6169,7 +6169,7 @@
 		p = sd;
 		sd = &per_cpu(cpu_domains, i);
 		*sd = SD_SIBLING_INIT;
-		sd->span = per_cpu(cpu_sibling_map, i);
+		sd->span = cpu_sibling_map(i);
 		cpus_and(sd->span, sd->span, *cpu_map);
 		sd->parent = p;
 		p->child = sd;
@@ -6180,7 +6180,7 @@
 #ifdef CONFIG_SCHED_SMT
 	/* Set up CPU (sibling) groups */
 	for_each_cpu_mask(i, *cpu_map) {
-		cpumask_t this_sibling_map = per_cpu(cpu_sibling_map, i);
+		cpumask_t this_sibling_map = cpu_sibling_map(i);
 		cpus_and(this_sibling_map, this_sibling_map, *cpu_map);
 		if (i != first_cpu(this_sibling_map))
 			continue;
--- a/include/asm-i386/smp.h
+++ b/include/asm-i386/smp.h
@@ -32,6 +32,7 @@
 extern int smp_num_siblings;
 DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
 DECLARE_PER_CPU(cpumask_t, cpu_core_map);
+#define cpu_sibling_map(cpu) per_cpu(cpu_sibling_map, cpu)
 
 extern void (*mtrr_hook) (void);
 extern void zap_low_mappings (void);
--- a/include/asm-x86_64/smp.h
+++ b/include/asm-x86_64/smp.h
@@ -47,6 +47,7 @@
 DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
 DECLARE_PER_CPU(cpumask_t, cpu_core_map);
 DECLARE_PER_CPU(u8, cpu_llc_id);
+#define cpu_sibling_map(cpu) per_cpu(cpu_sibling_map, cpu)
 
 #define SMP_TRAMPOLINE_BASE 0x6000
 
--- a/include/linux/smp.h
+++ b/include/linux/smp.h
@@ -18,6 +18,12 @@
 #include <linux/thread_info.h>
 #include <asm/smp.h>
 
+#ifdef CONFIG_SCHED_SMT
+#ifndef cpu_sibling_map
+#define cpu_sibling_map(cpu) cpu_sibling_map[cpu]
+#endif
+#endif
+
 /*
  * main cross-CPU interfaces, handles INIT, TLB flush, STOP, etc.
  * (defined in asm header):

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
