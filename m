Message-Id: <20070822172123.650145000@sgi.com>
References: <20070822172101.138513000@sgi.com>
Date: Wed, 22 Aug 2007 10:21:03 -0700
From: travis@sgi.com
Subject: [PATCH 2/6] x86: Convert cpu_sibling_map to be a per cpu variable
Content-Disposition: inline; filename=convert-cpu_sibling_map-to-per_cpu_data
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Convert cpu_sibling_map from a static array sized by NR_CPUS to a
per_cpu variable.  This saves sizeof(cpumask_t) * NR unused cpus.
Access is mostly from startup and CPU HOTPLUG functions.

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/i386/kernel/cpu/cpufreq/p4-clockmod.c   |    2 -
 arch/i386/kernel/cpu/cpufreq/speedstep-ich.c |    2 -
 arch/i386/kernel/io_apic.c                   |    4 +--
 arch/i386/kernel/smpboot.c                   |   36 +++++++++++++--------------
 arch/i386/oprofile/op_model_p4.c             |    2 -
 arch/i386/xen/smp.c                          |    4 +--
 arch/x86_64/kernel/smpboot.c                 |   26 +++++++++----------
 block/blktrace.c                             |    2 -
 include/asm-i386/smp.h                       |    2 -
 include/asm-i386/topology.h                  |    2 -
 include/asm-x86_64/smp.h                     |    6 +++-
 include/asm-x86_64/topology.h                |    2 -
 kernel/sched.c                               |    8 +++---
 13 files changed, 50 insertions(+), 48 deletions(-)

--- a/arch/i386/kernel/cpu/cpufreq/p4-clockmod.c
+++ b/arch/i386/kernel/cpu/cpufreq/p4-clockmod.c
@@ -200,7 +200,7 @@ static int cpufreq_p4_cpu_init(struct cp
 	unsigned int i;
 
 #ifdef CONFIG_SMP
-	policy->cpus = cpu_sibling_map[policy->cpu];
+	policy->cpus = per_cpu(cpu_sibling_map, policy->cpu);
 #endif
 
 	/* Errata workaround */
--- a/arch/i386/kernel/cpu/cpufreq/speedstep-ich.c
+++ b/arch/i386/kernel/cpu/cpufreq/speedstep-ich.c
@@ -322,7 +322,7 @@ static int speedstep_cpu_init(struct cpu
 
 	/* only run on CPU to be set, or on its sibling */
 #ifdef CONFIG_SMP
-	policy->cpus = cpu_sibling_map[policy->cpu];
+	policy->cpus = per_cpu(cpu_sibling_map, policy->cpu);
 #endif
 
 	cpus_allowed = current->cpus_allowed;
--- a/arch/i386/kernel/io_apic.c
+++ b/arch/i386/kernel/io_apic.c
@@ -378,7 +378,7 @@ static struct irq_cpu_info {
 
 #define IRQ_ALLOWED(cpu, allowed_mask)	cpu_isset(cpu, allowed_mask)
 
-#define CPU_TO_PACKAGEINDEX(i) (first_cpu(cpu_sibling_map[i]))
+#define CPU_TO_PACKAGEINDEX(i) (first_cpu(per_cpu(cpu_sibling_map, i)))
 
 static cpumask_t balance_irq_affinity[NR_IRQS] = {
 	[0 ... NR_IRQS-1] = CPU_MASK_ALL
@@ -598,7 +598,7 @@ tryanotherirq:
 	 * (A+B)/2 vs B
 	 */
 	load = CPU_IRQ(min_loaded) >> 1;
-	for_each_cpu_mask(j, cpu_sibling_map[min_loaded]) {
+	for_each_cpu_mask(j, per_cpu(cpu_sibling_map, min_loaded)) {
 		if (load > CPU_IRQ(j)) {
 			/* This won't change cpu_sibling_map[min_loaded] */
 			load = CPU_IRQ(j);
--- a/arch/i386/kernel/smpboot.c
+++ b/arch/i386/kernel/smpboot.c
@@ -70,8 +70,8 @@ EXPORT_SYMBOL(smp_num_siblings);
 int cpu_llc_id[NR_CPUS] __cpuinitdata = {[0 ... NR_CPUS-1] = BAD_APICID};
 
 /* representing HT siblings of each logical CPU */
-cpumask_t cpu_sibling_map[NR_CPUS] __read_mostly;
-EXPORT_SYMBOL(cpu_sibling_map);
+DEFINE_PER_CPU(cpumask_t, cpu_sibling_map);
+EXPORT_PER_CPU_SYMBOL(cpu_sibling_map);
 
 /* representing HT and core siblings of each logical CPU */
 DEFINE_PER_CPU(cpumask_t, cpu_core_map);
@@ -319,8 +319,8 @@ void __cpuinit set_cpu_sibling_map(int c
 		for_each_cpu_mask(i, cpu_sibling_setup_map) {
 			if (c[cpu].phys_proc_id == c[i].phys_proc_id &&
 			    c[cpu].cpu_core_id == c[i].cpu_core_id) {
-				cpu_set(i, cpu_sibling_map[cpu]);
-				cpu_set(cpu, cpu_sibling_map[i]);
+				cpu_set(i, per_cpu(cpu_sibling_map, cpu));
+				cpu_set(cpu, per_cpu(cpu_sibling_map, i));
 				cpu_set(i, per_cpu(cpu_core_map, cpu));
 				cpu_set(cpu, per_cpu(cpu_core_map, i));
 				cpu_set(i, c[cpu].llc_shared_map);
@@ -328,13 +328,13 @@ void __cpuinit set_cpu_sibling_map(int c
 			}
 		}
 	} else {
-		cpu_set(cpu, cpu_sibling_map[cpu]);
+		cpu_set(cpu, per_cpu(cpu_sibling_map, cpu));
 	}
 
 	cpu_set(cpu, c[cpu].llc_shared_map);
 
 	if (current_cpu_data.x86_max_cores == 1) {
-		per_cpu(cpu_core_map, cpu) = cpu_sibling_map[cpu];
+		per_cpu(cpu_core_map, cpu) = per_cpu(cpu_sibling_map, cpu);
 		c[cpu].booted_cores = 1;
 		return;
 	}
@@ -351,12 +351,12 @@ void __cpuinit set_cpu_sibling_map(int c
 			/*
 			 *  Does this new cpu bringup a new core?
 			 */
-			if (cpus_weight(cpu_sibling_map[cpu]) == 1) {
+			if (cpus_weight(per_cpu(cpu_sibling_map, cpu)) == 1) {
 				/*
 				 * for each core in package, increment
 				 * the booted_cores for this new cpu
 				 */
-				if (first_cpu(cpu_sibling_map[i]) == i)
+				if (first_cpu(per_cpu(cpu_sibling_map, i)) == i)
 					c[cpu].booted_cores++;
 				/*
 				 * increment the core count for all
@@ -983,7 +983,7 @@ static void __init smp_boot_cpus(unsigne
 			printk(KERN_NOTICE "Local APIC not detected."
 					   " Using dummy APIC emulation.\n");
 		map_cpu_to_logical_apicid();
-		cpu_set(0, cpu_sibling_map[0]);
+		cpu_set(0, per_cpu(cpu_sibling_map, 0));
 		cpu_set(0, per_cpu(cpu_core_map, 0));
 		return;
 	}
@@ -1008,7 +1008,7 @@ static void __init smp_boot_cpus(unsigne
 		printk(KERN_ERR "... forcing use of dummy APIC emulation. (tell your hw vendor)\n");
 		smpboot_clear_io_apic_irqs();
 		phys_cpu_present_map = physid_mask_of_physid(0);
-		cpu_set(0, cpu_sibling_map[0]);
+		cpu_set(0, per_cpu(cpu_sibling_map, 0));
 		cpu_set(0, per_cpu(cpu_core_map, 0));
 		return;
 	}
@@ -1023,7 +1023,7 @@ static void __init smp_boot_cpus(unsigne
 		printk(KERN_INFO "SMP mode deactivated, forcing use of dummy APIC emulation.\n");
 		smpboot_clear_io_apic_irqs();
 		phys_cpu_present_map = physid_mask_of_physid(0);
-		cpu_set(0, cpu_sibling_map[0]);
+		cpu_set(0, per_cpu(cpu_sibling_map, 0));
 		cpu_set(0, per_cpu(cpu_core_map, 0));
 		return;
 	}
@@ -1102,15 +1102,15 @@ static void __init smp_boot_cpus(unsigne
 	Dprintk("Boot done.\n");
 
 	/*
-	 * construct cpu_sibling_map[], so that we can tell sibling CPUs
+	 * construct cpu_sibling_map, so that we can tell sibling CPUs
 	 * efficiently.
 	 */
 	for (cpu = 0; cpu < NR_CPUS; cpu++) {
-		cpus_clear(cpu_sibling_map[cpu]);
+		cpus_clear(per_cpu(cpu_sibling_map, cpu));
 		cpus_clear(per_cpu(cpu_core_map, cpu));
 	}
 
-	cpu_set(0, cpu_sibling_map[0]);
+	cpu_set(0, per_cpu(cpu_sibling_map, 0));
 	cpu_set(0, per_cpu(cpu_core_map, 0));
 
 	smpboot_setup_io_apic();
@@ -1153,13 +1153,13 @@ void remove_siblinginfo(int cpu)
 		/*/
 		 * last thread sibling in this cpu core going down
 		 */
-		if (cpus_weight(cpu_sibling_map[cpu]) == 1)
+		if (cpus_weight(per_cpu(cpu_sibling_map, cpu)) == 1)
 			c[sibling].booted_cores--;
 	}
 			
-	for_each_cpu_mask(sibling, cpu_sibling_map[cpu])
-		cpu_clear(cpu, cpu_sibling_map[sibling]);
-	cpus_clear(cpu_sibling_map[cpu]);
+	for_each_cpu_mask(sibling, per_cpu(cpu_sibling_map, cpu))
+		cpu_clear(cpu, per_cpu(cpu_sibling_map, sibling));
+	cpus_clear(per_cpu(cpu_sibling_map, cpu));
 	cpus_clear(per_cpu(cpu_core_map, cpu));
 	c[cpu].phys_proc_id = 0;
 	c[cpu].cpu_core_id = 0;
--- a/arch/i386/oprofile/op_model_p4.c
+++ b/arch/i386/oprofile/op_model_p4.c
@@ -379,7 +379,7 @@ static unsigned int get_stagger(void)
 {
 #ifdef CONFIG_SMP
 	int cpu = smp_processor_id();
-	return (cpu != first_cpu(cpu_sibling_map[cpu]));
+	return (cpu != first_cpu(per_cpu(cpu_sibling_map, cpu)));
 #endif	
 	return 0;
 }
--- a/arch/i386/xen/smp.c
+++ b/arch/i386/xen/smp.c
@@ -147,7 +147,7 @@ void __init xen_smp_prepare_boot_cpu(voi
 	make_lowmem_page_readwrite(&per_cpu__gdt_page);
 
 	for (cpu = 0; cpu < NR_CPUS; cpu++) {
-		cpus_clear(cpu_sibling_map[cpu]);
+		cpus_clear(per_cpu(cpu_sibling_map, cpu));
 		/*
 		 * cpu_core_map lives in a per cpu area that is cleared
 		 * when the per cpu array is allocated.
@@ -164,7 +164,7 @@ void __init xen_smp_prepare_cpus(unsigne
 	unsigned cpu;
 
 	for (cpu = 0; cpu < NR_CPUS; cpu++) {
-		cpus_clear(cpu_sibling_map[cpu]);
+		cpus_clear(per_cpu(cpu_sibling_map, cpu));
 		/*
 		 * cpu_core_ map will be zeroed when the per
 		 * cpu area is allocated.
--- a/arch/x86_64/kernel/smpboot.c
+++ b/arch/x86_64/kernel/smpboot.c
@@ -91,8 +91,8 @@ EXPORT_SYMBOL(cpu_data);
 int smp_threads_ready;
 
 /* representing HT siblings of each logical CPU */
-cpumask_t cpu_sibling_map[NR_CPUS] __read_mostly;
-EXPORT_SYMBOL(cpu_sibling_map);
+DEFINE_PER_CPU(cpumask_t, cpu_sibling_map);
+EXPORT_PER_CPU_SYMBOL(cpu_sibling_map);
 
 /* representing HT and core siblings of each logical CPU */
 DEFINE_PER_CPU(cpumask_t, cpu_core_map);
@@ -264,8 +264,8 @@ static inline void set_cpu_sibling_map(i
 		for_each_cpu_mask(i, cpu_sibling_setup_map) {
 			if (c[cpu].phys_proc_id == c[i].phys_proc_id &&
 			    c[cpu].cpu_core_id == c[i].cpu_core_id) {
-				cpu_set(i, cpu_sibling_map[cpu]);
-				cpu_set(cpu, cpu_sibling_map[i]);
+				cpu_set(i, per_cpu(cpu_sibling_map, cpu));
+				cpu_set(cpu, per_cpu(cpu_sibling_map, i));
 				cpu_set(i, per_cpu(cpu_core_map, cpu));
 				cpu_set(cpu, per_cpu(cpu_core_map, i));
 				cpu_set(i, c[cpu].llc_shared_map);
@@ -273,13 +273,13 @@ static inline void set_cpu_sibling_map(i
 			}
 		}
 	} else {
-		cpu_set(cpu, cpu_sibling_map[cpu]);
+		cpu_set(cpu, per_cpu(cpu_sibling_map, cpu));
 	}
 
 	cpu_set(cpu, c[cpu].llc_shared_map);
 
 	if (current_cpu_data.x86_max_cores == 1) {
-		per_cpu(cpu_core_map, cpu) = cpu_sibling_map[cpu];
+		per_cpu(cpu_core_map, cpu) = per_cpu(cpu_sibling_map, cpu);
 		c[cpu].booted_cores = 1;
 		return;
 	}
@@ -296,12 +296,12 @@ static inline void set_cpu_sibling_map(i
 			/*
 			 *  Does this new cpu bringup a new core?
 			 */
-			if (cpus_weight(cpu_sibling_map[cpu]) == 1) {
+			if (cpus_weight(per_cpu(cpu_sibling_map, cpu)) == 1) {
 				/*
 				 * for each core in package, increment
 				 * the booted_cores for this new cpu
 				 */
-				if (first_cpu(cpu_sibling_map[i]) == i)
+				if (first_cpu(per_cpu(cpu_sibling_map, i)) == i)
 					c[cpu].booted_cores++;
 				/*
 				 * increment the core count for all
@@ -741,7 +741,7 @@ static __init void disable_smp(void)
 		phys_cpu_present_map = physid_mask_of_physid(boot_cpu_id);
 	else
 		phys_cpu_present_map = physid_mask_of_physid(0);
-	cpu_set(0, cpu_sibling_map[0]);
+	cpu_set(0, per_cpu(cpu_sibling_map, 0));
 	cpu_set(0, per_cpu(cpu_core_map, 0));
 }
 
@@ -982,13 +982,13 @@ static void remove_siblinginfo(int cpu)
 		/*
 		 * last thread sibling in this cpu core going down
 		 */
-		if (cpus_weight(cpu_sibling_map[cpu]) == 1)
+		if (cpus_weight(per_cpu(cpu_sibling_map, cpu)) == 1)
 			c[sibling].booted_cores--;
 	}
 			
-	for_each_cpu_mask(sibling, cpu_sibling_map[cpu])
-		cpu_clear(cpu, cpu_sibling_map[sibling]);
-	cpus_clear(cpu_sibling_map[cpu]);
+	for_each_cpu_mask(sibling, per_cpu(cpu_sibling_map, cpu))
+		cpu_clear(cpu, per_cpu(cpu_sibling_map, sibling));
+	cpus_clear(per_cpu(cpu_sibling_map, cpu));
 	cpus_clear(per_cpu(cpu_core_map, cpu));
 	c[cpu].phys_proc_id = 0;
 	c[cpu].cpu_core_id = 0;
--- a/block/blktrace.c
+++ b/block/blktrace.c
@@ -536,7 +536,7 @@ static void blk_trace_set_ht_offsets(voi
 	for_each_online_cpu(cpu) {
 		unsigned long long *cpu_off, *sibling_off;
 
-		for_each_cpu_mask(i, cpu_sibling_map[cpu]) {
+		for_each_cpu_mask(i, per_cpu(cpu_sibling_map, cpu)) {
 			if (i == cpu)
 				continue;
 
--- a/include/asm-i386/smp.h
+++ b/include/asm-i386/smp.h
@@ -30,7 +30,7 @@
 extern void smp_alloc_memory(void);
 extern int pic_mode;
 extern int smp_num_siblings;
-extern cpumask_t cpu_sibling_map[];
+DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
 DECLARE_PER_CPU(cpumask_t, cpu_core_map);
 
 extern void (*mtrr_hook) (void);
--- a/include/asm-i386/topology.h
+++ b/include/asm-i386/topology.h
@@ -31,7 +31,7 @@
 #define topology_physical_package_id(cpu)	(cpu_data[cpu].phys_proc_id)
 #define topology_core_id(cpu)			(cpu_data[cpu].cpu_core_id)
 #define topology_core_siblings(cpu)		(per_cpu(cpu_core_map, cpu))
-#define topology_thread_siblings(cpu)		(cpu_sibling_map[cpu])
+#define topology_thread_siblings(cpu)		(per_cpu(cpu_sibling_map, cpu))
 #endif
 
 #ifdef CONFIG_NUMA
--- a/include/asm-x86_64/smp.h
+++ b/include/asm-x86_64/smp.h
@@ -38,12 +38,14 @@ extern void unlock_ipi_call_lock(void);
 extern int smp_num_siblings;
 extern void smp_send_reschedule(int cpu);
 
-extern cpumask_t cpu_sibling_map[NR_CPUS];
 /*
- * cpu_core_map lives in a per cpu area
+ * cpu_sibling_map and cpu_core_map now live
+ * in the per cpu area
  *
+ * extern cpumask_t cpu_sibling_map[NR_CPUS];
  * extern cpumask_t cpu_core_map[NR_CPUS];
  */
+DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
 DECLARE_PER_CPU(cpumask_t, cpu_core_map);
 
 extern u8 cpu_llc_id[NR_CPUS];
--- a/include/asm-x86_64/topology.h
+++ b/include/asm-x86_64/topology.h
@@ -72,7 +72,7 @@ static inline void set_mp_bus_to_node(in
 #define topology_physical_package_id(cpu)	(cpu_data[cpu].phys_proc_id)
 #define topology_core_id(cpu)			(cpu_data[cpu].cpu_core_id)
 #define topology_core_siblings(cpu)		(per_cpu(cpu_core_map, cpu))
-#define topology_thread_siblings(cpu)		(cpu_sibling_map[cpu])
+#define topology_thread_siblings(cpu)		(per_cpu(cpu_sibling_map, cpu))
 #define mc_capable()			(boot_cpu_data.x86_max_cores > 1)
 #define smt_capable() 			(smp_num_siblings > 1)
 #endif
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -5822,7 +5822,7 @@ static int cpu_to_core_group(int cpu, co
 			     struct sched_group **sg)
 {
 	int group;
-	cpumask_t mask = cpu_sibling_map[cpu];
+	cpumask_t mask = per_cpu(cpu_sibling_map, cpu);
 	cpus_and(mask, mask, *cpu_map);
 	group = first_cpu(mask);
 	if (sg)
@@ -5851,7 +5851,7 @@ static int cpu_to_phys_group(int cpu, co
 	cpus_and(mask, mask, *cpu_map);
 	group = first_cpu(mask);
 #elif defined(CONFIG_SCHED_SMT)
-	cpumask_t mask = cpu_sibling_map[cpu];
+	cpumask_t mask = per_cpu(cpu_sibling_map, cpu);
 	cpus_and(mask, mask, *cpu_map);
 	group = first_cpu(mask);
 #else
@@ -6086,7 +6086,7 @@ static int build_sched_domains(const cpu
 		p = sd;
 		sd = &per_cpu(cpu_domains, i);
 		*sd = SD_SIBLING_INIT;
-		sd->span = cpu_sibling_map[i];
+		sd->span = per_cpu(cpu_sibling_map, i);
 		cpus_and(sd->span, sd->span, *cpu_map);
 		sd->parent = p;
 		p->child = sd;
@@ -6097,7 +6097,7 @@ static int build_sched_domains(const cpu
 #ifdef CONFIG_SCHED_SMT
 	/* Set up CPU (sibling) groups */
 	for_each_cpu_mask(i, *cpu_map) {
-		cpumask_t this_sibling_map = cpu_sibling_map[i];
+		cpumask_t this_sibling_map = per_cpu(cpu_sibling_map, i);
 		cpus_and(this_sibling_map, this_sibling_map, *cpu_map);
 		if (i != first_cpu(this_sibling_map))
 			continue;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
