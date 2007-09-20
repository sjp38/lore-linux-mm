Message-Id: <20070920213004.781159000@sgi.com>
References: <20070920213004.527735000@sgi.com>
Date: Thu, 20 Sep 2007 14:30:05 -0700
From: travis@sgi.com
Subject: [PATCH 1/1] x86: Convert cpuinfo_x86 array to a per_cpu array v2
Content-Disposition: inline; filename=convert-cpu_data
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

(This resulted in one change removed and one change added.)


cpu_data is currently an array defined using NR_CPUS. This means that
we overallocate since we will rarely really use maximum configured cpus.
When NR_CPU count is raised to 4096 the size of cpu_data becomes
3,145,728 bytes.

These changes were adopted from the sparc64 (and ia64) code.  An
additional field was added to cpuinfo_x86 to be a non-ambiguous
cpu index.  This corresponds to the index into a cpumask_t as
well as the per_cpu index.  It's used in various places like
show_cpuinfo().

cpu_data is defined to be the boot_cpu_data structure for the
NON-SMP case.

This patch is based on 2.6.23-rc6 with the prior per_cpu patches
applied.  I can also provide a version based on 2.6.23-rc4-mm1 
which has some different changes.

Signed-off-by: Mike Travis <travis@sgi.com>

Acked-by: Christoph Lameter <clameter@sgi.com>
---
 arch/i386/kernel/acpi/cstate.c                    |    4 -
 arch/i386/kernel/acpi/processor.c                 |    2 
 arch/i386/kernel/alternative.c                    |    6 +-
 arch/i386/kernel/cpu/cpufreq/acpi-cpufreq.c       |    4 -
 arch/i386/kernel/cpu/cpufreq/e_powersaver.c       |    2 
 arch/i386/kernel/cpu/cpufreq/elanfreq.c           |    4 -
 arch/i386/kernel/cpu/cpufreq/longhaul.c           |    4 -
 arch/i386/kernel/cpu/cpufreq/longrun.c            |    4 -
 arch/i386/kernel/cpu/cpufreq/p4-clockmod.c        |    4 -
 arch/i386/kernel/cpu/cpufreq/powernow-k6.c        |    2 
 arch/i386/kernel/cpu/cpufreq/powernow-k7.c        |    2 
 arch/i386/kernel/cpu/cpufreq/sc520_freq.c         |    4 -
 arch/i386/kernel/cpu/cpufreq/speedstep-centrino.c |    6 +-
 arch/i386/kernel/cpu/cpufreq/speedstep-lib.c      |    2 
 arch/i386/kernel/cpu/intel_cacheinfo.c            |    8 +--
 arch/i386/kernel/cpu/proc.c                       |    9 ++--
 arch/i386/kernel/cpuid.c                          |    2 
 arch/i386/kernel/microcode.c                      |    6 +-
 arch/i386/kernel/msr.c                            |    2 
 arch/i386/kernel/sched-clock.c                    |    2 
 arch/i386/kernel/smp.c                            |    2 
 arch/i386/kernel/smpboot.c                        |   45 +++++++++++-----------
 arch/i386/kernel/tsc.c                            |    8 +--
 arch/i386/lib/delay.c                             |    2 
 arch/i386/mach-voyager/voyager_smp.c              |   12 ++---
 arch/x86_64/kernel/mce.c                          |    2 
 arch/x86_64/kernel/mce_amd.c                      |    4 -
 arch/x86_64/kernel/setup.c                        |   18 +++++---
 arch/x86_64/kernel/smpboot.c                      |   44 ++++++++++-----------
 arch/x86_64/kernel/tsc.c                          |    4 -
 arch/x86_64/kernel/vsyscall.c                     |    2 
 arch/x86_64/lib/delay.c                           |    2 
 drivers/hwmon/coretemp.c                          |    6 +-
 drivers/hwmon/hwmon-vid.c                         |    2 
 drivers/input/gameport/gameport.c                 |    2 
 drivers/video/geode/video_gx.c                    |    2 
 include/asm-i386/processor.h                      |   10 ++--
 include/asm-i386/topology.h                       |    4 -
 include/asm-x86_64/processor.h                    |   10 ++--
 include/asm-x86_64/topology.h                     |    4 -
 40 files changed, 138 insertions(+), 126 deletions(-)

--- a/arch/x86_64/kernel/smpboot.c
+++ b/arch/x86_64/kernel/smpboot.c
@@ -84,8 +84,8 @@ cpumask_t cpu_possible_map;
 EXPORT_SYMBOL(cpu_possible_map);
 
 /* Per CPU bogomips and other parameters */
-struct cpuinfo_x86 cpu_data[NR_CPUS] __cacheline_aligned;
-EXPORT_SYMBOL(cpu_data);
+DEFINE_PER_CPU_SHARED_ALIGNED(struct cpuinfo_x86, cpu_info);
+EXPORT_PER_CPU_SYMBOL(cpu_info);
 
 /* Set when the idlers are all forked */
 int smp_threads_ready;
@@ -138,9 +138,10 @@ static unsigned long __cpuinit setup_tra
 
 static void __cpuinit smp_store_cpu_info(int id)
 {
-	struct cpuinfo_x86 *c = cpu_data + id;
+	struct cpuinfo_x86 *c = &cpu_data(id);
 
 	*c = boot_cpu_data;
+	c->cpu_index = id;
 	identify_cpu(c);
 	print_cpu_info(c);
 }
@@ -238,7 +239,7 @@ void __cpuinit smp_callin(void)
 /* maps the cpu to the sched domain representing multi-core */
 cpumask_t cpu_coregroup_map(int cpu)
 {
-	struct cpuinfo_x86 *c = cpu_data + cpu;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 	/*
 	 * For perf, we return last level cache shared map.
 	 * And for power savings, we return cpu_core_map
@@ -255,41 +256,41 @@ static cpumask_t cpu_sibling_setup_map;
 static inline void set_cpu_sibling_map(int cpu)
 {
 	int i;
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 
 	cpu_set(cpu, cpu_sibling_setup_map);
 
 	if (smp_num_siblings > 1) {
 		for_each_cpu_mask(i, cpu_sibling_setup_map) {
-			if (c[cpu].phys_proc_id == c[i].phys_proc_id &&
-			    c[cpu].cpu_core_id == c[i].cpu_core_id) {
+			if (c->phys_proc_id == cpu_data(i).phys_proc_id &&
+			    c->cpu_core_id == cpu_data(i).cpu_core_id) {
 				cpu_set(i, per_cpu(cpu_sibling_map, cpu));
 				cpu_set(cpu, per_cpu(cpu_sibling_map, i));
 				cpu_set(i, per_cpu(cpu_core_map, cpu));
 				cpu_set(cpu, per_cpu(cpu_core_map, i));
-				cpu_set(i, c[cpu].llc_shared_map);
-				cpu_set(cpu, c[i].llc_shared_map);
+				cpu_set(i, c->llc_shared_map);
+				cpu_set(cpu, cpu_data(i).llc_shared_map);
 			}
 		}
 	} else {
 		cpu_set(cpu, per_cpu(cpu_sibling_map, cpu));
 	}
 
-	cpu_set(cpu, c[cpu].llc_shared_map);
+	cpu_set(cpu, c->llc_shared_map);
 
 	if (current_cpu_data.x86_max_cores == 1) {
 		per_cpu(cpu_core_map, cpu) = per_cpu(cpu_sibling_map, cpu);
-		c[cpu].booted_cores = 1;
+		c->booted_cores = 1;
 		return;
 	}
 
 	for_each_cpu_mask(i, cpu_sibling_setup_map) {
 		if (per_cpu(cpu_llc_id, cpu) != BAD_APICID &&
 		    per_cpu(cpu_llc_id, cpu) == per_cpu(cpu_llc_id, i)) {
-			cpu_set(i, c[cpu].llc_shared_map);
-			cpu_set(cpu, c[i].llc_shared_map);
+			cpu_set(i, c->llc_shared_map);
+			cpu_set(cpu, cpu_data(i).llc_shared_map);
 		}
-		if (c[cpu].phys_proc_id == c[i].phys_proc_id) {
+		if (c->phys_proc_id == cpu_data(i).phys_proc_id) {
 			cpu_set(i, per_cpu(cpu_core_map, cpu));
 			cpu_set(cpu, per_cpu(cpu_core_map, i));
 			/*
@@ -301,15 +302,15 @@ static inline void set_cpu_sibling_map(i
 				 * the booted_cores for this new cpu
 				 */
 				if (first_cpu(per_cpu(cpu_sibling_map, i)) == i)
-					c[cpu].booted_cores++;
+					c->booted_cores++;
 				/*
 				 * increment the core count for all
 				 * the other cpus in this package
 				 */
 				if (i != cpu)
-					c[i].booted_cores++;
-			} else if (i != cpu && !c[cpu].booted_cores)
-				c[cpu].booted_cores = c[i].booted_cores;
+					cpu_data(i).booted_cores++;
+			} else if (i != cpu && !c->booted_cores)
+				c->booted_cores = cpu_data(i).booted_cores;
 		}
 	}
 }
@@ -1000,7 +1001,6 @@ void __init smp_cpus_done(unsigned int m
 static void remove_siblinginfo(int cpu)
 {
 	int sibling;
-	struct cpuinfo_x86 *c = cpu_data;
 
 	for_each_cpu_mask(sibling, per_cpu(cpu_core_map, cpu)) {
 		cpu_clear(cpu, per_cpu(cpu_core_map, sibling));
@@ -1008,15 +1008,15 @@ static void remove_siblinginfo(int cpu)
 		 * last thread sibling in this cpu core going down
 		 */
 		if (cpus_weight(per_cpu(cpu_sibling_map, cpu)) == 1)
-			c[sibling].booted_cores--;
+			cpu_data(sibling).booted_cores--;
 	}
 			
 	for_each_cpu_mask(sibling, per_cpu(cpu_sibling_map, cpu))
 		cpu_clear(cpu, per_cpu(cpu_sibling_map, sibling));
 	cpus_clear(per_cpu(cpu_sibling_map, cpu));
 	cpus_clear(per_cpu(cpu_core_map, cpu));
-	c[cpu].phys_proc_id = 0;
-	c[cpu].cpu_core_id = 0;
+	cpu_data(cpu).phys_proc_id = 0;
+	cpu_data(cpu).cpu_core_id = 0;
 	cpu_clear(cpu, cpu_sibling_setup_map);
 }
 
--- a/include/asm-x86_64/processor.h
+++ b/include/asm-x86_64/processor.h
@@ -75,6 +75,7 @@ struct cpuinfo_x86 {
 	__u8	booted_cores;	/* number of cores as seen by OS */
 	__u8	phys_proc_id;	/* Physical Processor id. */
 	__u8	cpu_core_id;	/* Core id. */
+	__u8	cpu_index;	/* index into per_cpu list */
 #endif
 } ____cacheline_aligned;
 
@@ -89,11 +90,12 @@ struct cpuinfo_x86 {
 #define X86_VENDOR_UNKNOWN 0xff
 
 #ifdef CONFIG_SMP
-extern struct cpuinfo_x86 cpu_data[];
-#define current_cpu_data cpu_data[smp_processor_id()]
+DECLARE_PER_CPU(struct cpuinfo_x86, cpu_info);
+#define cpu_data(cpu)		per_cpu(cpu_info, cpu)
+#define current_cpu_data	cpu_data(smp_processor_id())
 #else
-#define cpu_data (&boot_cpu_data)
-#define current_cpu_data boot_cpu_data
+#define cpu_data(cpu)		boot_cpu_data
+#define current_cpu_data	boot_cpu_data
 #endif
 
 extern char ignore_irq13;
--- a/arch/i386/kernel/acpi/cstate.c
+++ b/arch/i386/kernel/acpi/cstate.c
@@ -29,7 +29,7 @@
 void acpi_processor_power_init_bm_check(struct acpi_processor_flags *flags,
 					unsigned int cpu)
 {
-	struct cpuinfo_x86 *c = cpu_data + cpu;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 
 	flags->bm_check = 0;
 	if (num_online_cpus() == 1)
@@ -72,7 +72,7 @@ int acpi_processor_ffh_cstate_probe(unsi
 		struct acpi_processor_cx *cx, struct acpi_power_register *reg)
 {
 	struct cstate_entry *percpu_entry;
-	struct cpuinfo_x86 *c = cpu_data + cpu;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 
 	cpumask_t saved_mask;
 	int retval;
--- a/arch/i386/kernel/acpi/processor.c
+++ b/arch/i386/kernel/acpi/processor.c
@@ -63,7 +63,7 @@ static void init_intel_pdc(struct acpi_p
 void arch_acpi_processor_init_pdc(struct acpi_processor *pr)
 {
 	unsigned int cpu = pr->id;
-	struct cpuinfo_x86 *c = cpu_data + cpu;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 
 	pr->pdc = NULL;
 	if (c->x86_vendor == X86_VENDOR_INTEL)
--- a/arch/i386/kernel/alternative.c
+++ b/arch/i386/kernel/alternative.c
@@ -353,14 +353,14 @@ void alternatives_smp_switch(int smp)
 	if (smp) {
 		printk(KERN_INFO "SMP alternatives: switching to SMP code\n");
 		clear_bit(X86_FEATURE_UP, boot_cpu_data.x86_capability);
-		clear_bit(X86_FEATURE_UP, cpu_data[0].x86_capability);
+		clear_bit(X86_FEATURE_UP, cpu_data(0).x86_capability);
 		list_for_each_entry(mod, &smp_alt_modules, next)
 			alternatives_smp_lock(mod->locks, mod->locks_end,
 					      mod->text, mod->text_end);
 	} else {
 		printk(KERN_INFO "SMP alternatives: switching to UP code\n");
 		set_bit(X86_FEATURE_UP, boot_cpu_data.x86_capability);
-		set_bit(X86_FEATURE_UP, cpu_data[0].x86_capability);
+		set_bit(X86_FEATURE_UP, cpu_data(0).x86_capability);
 		list_for_each_entry(mod, &smp_alt_modules, next)
 			alternatives_smp_unlock(mod->locks, mod->locks_end,
 						mod->text, mod->text_end);
@@ -428,7 +428,7 @@ void __init alternative_instructions(voi
 		if (1 == num_possible_cpus()) {
 			printk(KERN_INFO "SMP alternatives: switching to UP code\n");
 			set_bit(X86_FEATURE_UP, boot_cpu_data.x86_capability);
-			set_bit(X86_FEATURE_UP, cpu_data[0].x86_capability);
+			set_bit(X86_FEATURE_UP, cpu_data(0).x86_capability);
 			alternatives_smp_unlock(__smp_locks, __smp_locks_end,
 						_text, _etext);
 		}
--- a/arch/i386/kernel/cpu/cpufreq/acpi-cpufreq.c
+++ b/arch/i386/kernel/cpu/cpufreq/acpi-cpufreq.c
@@ -77,7 +77,7 @@ static unsigned int acpi_pstate_strict;
 
 static int check_est_cpu(unsigned int cpuid)
 {
-	struct cpuinfo_x86 *cpu = &cpu_data[cpuid];
+	struct cpuinfo_x86 *cpu = &cpu_data(cpuid);
 
 	if (cpu->x86_vendor != X86_VENDOR_INTEL ||
 	    !cpu_has(cpu, X86_FEATURE_EST))
@@ -560,7 +560,7 @@ static int acpi_cpufreq_cpu_init(struct 
 	unsigned int cpu = policy->cpu;
 	struct acpi_cpufreq_data *data;
 	unsigned int result = 0;
-	struct cpuinfo_x86 *c = &cpu_data[policy->cpu];
+	struct cpuinfo_x86 *c = &cpu_data(policy->cpu);
 	struct acpi_processor_performance *perf;
 
 	dprintk("acpi_cpufreq_cpu_init\n");
--- a/arch/i386/kernel/cpu/cpufreq/e_powersaver.c
+++ b/arch/i386/kernel/cpu/cpufreq/e_powersaver.c
@@ -305,7 +305,7 @@ static struct cpufreq_driver eps_driver 
 
 static int __init eps_init(void)
 {
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 
 	/* This driver will work only on Centaur C7 processors with
 	 * Enhanced SpeedStep/PowerSaver registers */
--- a/arch/i386/kernel/cpu/cpufreq/elanfreq.c
+++ b/arch/i386/kernel/cpu/cpufreq/elanfreq.c
@@ -199,7 +199,7 @@ static int elanfreq_target (struct cpufr
 
 static int elanfreq_cpu_init(struct cpufreq_policy *policy)
 {
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 	unsigned int i;
 	int result;
 
@@ -280,7 +280,7 @@ static struct cpufreq_driver elanfreq_dr
 
 static int __init elanfreq_init(void)
 {
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 
 	/* Test if we have the right hardware */
 	if ((c->x86_vendor != X86_VENDOR_AMD) ||
--- a/arch/i386/kernel/cpu/cpufreq/longhaul.c
+++ b/arch/i386/kernel/cpu/cpufreq/longhaul.c
@@ -731,7 +731,7 @@ static int longhaul_setup_southbridge(vo
 
 static int __init longhaul_cpu_init(struct cpufreq_policy *policy)
 {
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(0);
 	char *cpuname=NULL;
 	int ret;
 	u32 lo, hi;
@@ -910,7 +910,7 @@ static struct cpufreq_driver longhaul_dr
 
 static int __init longhaul_init(void)
 {
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(0);
 
 	if (c->x86_vendor != X86_VENDOR_CENTAUR || c->x86 != 6)
 		return -ENODEV;
--- a/arch/i386/kernel/cpu/cpufreq/longrun.c
+++ b/arch/i386/kernel/cpu/cpufreq/longrun.c
@@ -172,7 +172,7 @@ static unsigned int __init longrun_deter
 	u32 save_lo, save_hi;
 	u32 eax, ebx, ecx, edx;
 	u32 try_hi;
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 
 	if (!low_freq || !high_freq)
 		return -EINVAL;
@@ -298,7 +298,7 @@ static struct cpufreq_driver longrun_dri
  */
 static int __init longrun_init(void)
 {
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 
 	if (c->x86_vendor != X86_VENDOR_TRANSMETA ||
 	    !cpu_has(c, X86_FEATURE_LONGRUN))
--- a/arch/i386/kernel/cpu/cpufreq/p4-clockmod.c
+++ b/arch/i386/kernel/cpu/cpufreq/p4-clockmod.c
@@ -195,7 +195,7 @@ static unsigned int cpufreq_p4_get_frequ
 
 static int cpufreq_p4_cpu_init(struct cpufreq_policy *policy)
 {
-	struct cpuinfo_x86 *c = &cpu_data[policy->cpu];
+	struct cpuinfo_x86 *c = &cpu_data(policy->cpu);
 	int cpuid = 0;
 	unsigned int i;
 
@@ -279,7 +279,7 @@ static struct cpufreq_driver p4clockmod_
 
 static int __init cpufreq_p4_init(void)
 {
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(0);
 	int ret;
 
 	/*
--- a/arch/i386/kernel/cpu/cpufreq/powernow-k6.c
+++ b/arch/i386/kernel/cpu/cpufreq/powernow-k6.c
@@ -215,7 +215,7 @@ static struct cpufreq_driver powernow_k6
  */
 static int __init powernow_k6_init(void)
 {
-	struct cpuinfo_x86      *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(0);
 
 	if ((c->x86_vendor != X86_VENDOR_AMD) || (c->x86 != 5) ||
 		((c->x86_model != 12) && (c->x86_model != 13)))
--- a/arch/i386/kernel/cpu/cpufreq/powernow-k7.c
+++ b/arch/i386/kernel/cpu/cpufreq/powernow-k7.c
@@ -114,7 +114,7 @@ static int check_fsb(unsigned int fsbspe
 
 static int check_powernow(void)
 {
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(0);
 	unsigned int maxei, eax, ebx, ecx, edx;
 
 	if ((c->x86_vendor != X86_VENDOR_AMD) || (c->x86 !=6)) {
--- a/arch/i386/kernel/cpu/cpufreq/sc520_freq.c
+++ b/arch/i386/kernel/cpu/cpufreq/sc520_freq.c
@@ -102,7 +102,7 @@ static int sc520_freq_target (struct cpu
 
 static int sc520_freq_cpu_init(struct cpufreq_policy *policy)
 {
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(0);
 	int result;
 
 	/* capability check */
@@ -151,7 +151,7 @@ static struct cpufreq_driver sc520_freq_
 
 static int __init sc520_freq_init(void)
 {
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(0);
 	int err;
 
 	/* Test if we have the right hardware */
--- a/arch/i386/kernel/cpu/cpufreq/speedstep-centrino.c
+++ b/arch/i386/kernel/cpu/cpufreq/speedstep-centrino.c
@@ -230,7 +230,7 @@ static struct cpu_model models[] =
 
 static int centrino_cpu_init_table(struct cpufreq_policy *policy)
 {
-	struct cpuinfo_x86 *cpu = &cpu_data[policy->cpu];
+	struct cpuinfo_x86 *cpu = &cpu_data(policy->cpu);
 	struct cpu_model *model;
 
 	for(model = models; model->cpu_id != NULL; model++)
@@ -340,7 +340,7 @@ static unsigned int get_cur_freq(unsigne
 
 static int centrino_cpu_init(struct cpufreq_policy *policy)
 {
-	struct cpuinfo_x86 *cpu = &cpu_data[policy->cpu];
+	struct cpuinfo_x86 *cpu = &cpu_data(policy->cpu);
 	unsigned freq;
 	unsigned l, h;
 	int ret;
@@ -612,7 +612,7 @@ static struct cpufreq_driver centrino_dr
  */
 static int __init centrino_init(void)
 {
-	struct cpuinfo_x86 *cpu = cpu_data;
+	struct cpuinfo_x86 *cpu = &cpu_data(0);
 
 	if (!cpu_has(cpu, X86_FEATURE_EST))
 		return -ENODEV;
--- a/arch/i386/kernel/cpu/cpufreq/speedstep-lib.c
+++ b/arch/i386/kernel/cpu/cpufreq/speedstep-lib.c
@@ -228,7 +228,7 @@ EXPORT_SYMBOL_GPL(speedstep_get_processo
 
 unsigned int speedstep_detect_processor (void)
 {
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(0);
 	u32 ebx, msr_lo, msr_hi;
 
 	dprintk("x86: %x, model: %x\n", c->x86, c->x86_model);
--- a/arch/i386/kernel/cpu/intel_cacheinfo.c
+++ b/arch/i386/kernel/cpu/intel_cacheinfo.c
@@ -295,7 +295,7 @@ unsigned int __cpuinit init_intel_cachei
 	unsigned int new_l2 = 0, new_l3 = 0, i; /* Cache sizes from cpuid(4) */
 	unsigned int l2_id = 0, l3_id = 0, num_threads_sharing, index_msb;
 #ifdef CONFIG_X86_HT
-	unsigned int cpu = (c == &boot_cpu_data) ? 0 : (c - cpu_data);
+	unsigned int cpu = c->cpu_index;
 #endif
 
 	if (c->cpuid_level > 3) {
@@ -459,7 +459,7 @@ static void __cpuinit cache_shared_cpu_m
 	struct _cpuid4_info	*this_leaf, *sibling_leaf;
 	unsigned long num_threads_sharing;
 	int index_msb, i;
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 
 	this_leaf = CPUID4_INFO_IDX(cpu, index);
 	num_threads_sharing = 1 + this_leaf->eax.split.num_threads_sharing;
@@ -470,8 +470,8 @@ static void __cpuinit cache_shared_cpu_m
 		index_msb = get_count_order(num_threads_sharing);
 
 		for_each_online_cpu(i) {
-			if (c[i].apicid >> index_msb ==
-			    c[cpu].apicid >> index_msb) {
+			if (cpu_data(i).apicid >> index_msb ==
+			    c->apicid >> index_msb) {
 				cpu_set(i, this_leaf->shared_cpu_map);
 				if (i != cpu && cpuid4_info[i])  {
 					sibling_leaf = CPUID4_INFO_IDX(i, index);
--- a/arch/i386/kernel/cpuid.c
+++ b/arch/i386/kernel/cpuid.c
@@ -116,7 +116,7 @@ static ssize_t cpuid_read(struct file *f
 static int cpuid_open(struct inode *inode, struct file *file)
 {
 	unsigned int cpu = iminor(file->f_path.dentry->d_inode);
-	struct cpuinfo_x86 *c = &(cpu_data)[cpu];
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 
 	if (cpu >= NR_CPUS || !cpu_online(cpu))
 		return -ENXIO;	/* No such CPU */
--- a/arch/i386/kernel/microcode.c
+++ b/arch/i386/kernel/microcode.c
@@ -132,7 +132,7 @@ static struct ucode_cpu_info {
 
 static void collect_cpu_info(int cpu_num)
 {
-	struct cpuinfo_x86 *c = cpu_data + cpu_num;
+	struct cpuinfo_x86 *c = &cpu_data(cpu_num);
 	struct ucode_cpu_info *uci = ucode_cpu_info + cpu_num;
 	unsigned int val[2];
 
@@ -522,7 +522,7 @@ static struct platform_device *microcode
 static int cpu_request_microcode(int cpu)
 {
 	char name[30];
-	struct cpuinfo_x86 *c = cpu_data + cpu;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 	const struct firmware *firmware;
 	void *buf;
 	unsigned long size;
@@ -570,7 +570,7 @@ static int cpu_request_microcode(int cpu
 
 static int apply_microcode_check_cpu(int cpu)
 {
-	struct cpuinfo_x86 *c = cpu_data + cpu;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 	struct ucode_cpu_info *uci = ucode_cpu_info + cpu;
 	cpumask_t old;
 	unsigned int val[2];
--- a/arch/i386/kernel/msr.c
+++ b/arch/i386/kernel/msr.c
@@ -114,7 +114,7 @@ static ssize_t msr_write(struct file *fi
 static int msr_open(struct inode *inode, struct file *file)
 {
 	unsigned int cpu = iminor(file->f_path.dentry->d_inode);
-	struct cpuinfo_x86 *c = &(cpu_data)[cpu];
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 
 	if (cpu >= NR_CPUS || !cpu_online(cpu))
 		return -ENXIO;	/* No such CPU */
--- a/arch/i386/kernel/smp.c
+++ b/arch/i386/kernel/smp.c
@@ -610,7 +610,7 @@ static void stop_this_cpu (void * dummy)
 	 */
 	cpu_clear(smp_processor_id(), cpu_online_map);
 	disable_local_APIC();
-	if (cpu_data[smp_processor_id()].hlt_works_ok)
+	if (cpu_data(smp_processor_id()).hlt_works_ok)
 		for(;;) halt();
 	for (;;);
 }
--- a/arch/i386/kernel/smpboot.c
+++ b/arch/i386/kernel/smpboot.c
@@ -89,8 +89,8 @@ EXPORT_SYMBOL(cpu_possible_map);
 static cpumask_t smp_commenced_mask;
 
 /* Per CPU bogomips and other parameters */
-struct cpuinfo_x86 cpu_data[NR_CPUS] __cacheline_aligned;
-EXPORT_SYMBOL(cpu_data);
+DEFINE_PER_CPU_SHARED_ALIGNED(struct cpuinfo_x86, cpu_info);
+EXPORT_PER_CPU_SYMBOL(cpu_info);
 
 /*
  * The following static array is used during kernel startup
@@ -158,9 +158,10 @@ void __init smp_alloc_memory(void)
 
 void __cpuinit smp_store_cpu_info(int id)
 {
-	struct cpuinfo_x86 *c = cpu_data + id;
+	struct cpuinfo_x86 *c = &cpu_data(id);
 
 	*c = boot_cpu_data;
+	c->cpu_index = id;
 	if (id!=0)
 		identify_secondary_cpu(c);
 	/*
@@ -302,7 +303,7 @@ static int cpucount;
 /* maps the cpu to the sched domain representing multi-core */
 cpumask_t cpu_coregroup_map(int cpu)
 {
-	struct cpuinfo_x86 *c = cpu_data + cpu;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 	/*
 	 * For perf, we return last level cache shared map.
 	 * And for power savings, we return cpu_core_map
@@ -319,41 +320,41 @@ static cpumask_t cpu_sibling_setup_map;
 void __cpuinit set_cpu_sibling_map(int cpu)
 {
 	int i;
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(cpu);
 
 	cpu_set(cpu, cpu_sibling_setup_map);
 
 	if (smp_num_siblings > 1) {
 		for_each_cpu_mask(i, cpu_sibling_setup_map) {
-			if (c[cpu].phys_proc_id == c[i].phys_proc_id &&
-			    c[cpu].cpu_core_id == c[i].cpu_core_id) {
+			if (c->phys_proc_id == cpu_data(i).phys_proc_id &&
+			    c->cpu_core_id == cpu_data(i).cpu_core_id) {
 				cpu_set(i, per_cpu(cpu_sibling_map, cpu));
 				cpu_set(cpu, per_cpu(cpu_sibling_map, i));
 				cpu_set(i, per_cpu(cpu_core_map, cpu));
 				cpu_set(cpu, per_cpu(cpu_core_map, i));
-				cpu_set(i, c[cpu].llc_shared_map);
-				cpu_set(cpu, c[i].llc_shared_map);
+				cpu_set(i, c->llc_shared_map);
+				cpu_set(cpu, cpu_data(i).llc_shared_map);
 			}
 		}
 	} else {
 		cpu_set(cpu, per_cpu(cpu_sibling_map, cpu));
 	}
 
-	cpu_set(cpu, c[cpu].llc_shared_map);
+	cpu_set(cpu, c->llc_shared_map);
 
 	if (current_cpu_data.x86_max_cores == 1) {
 		per_cpu(cpu_core_map, cpu) = per_cpu(cpu_sibling_map, cpu);
-		c[cpu].booted_cores = 1;
+		c->booted_cores = 1;
 		return;
 	}
 
 	for_each_cpu_mask(i, cpu_sibling_setup_map) {
 		if (per_cpu(cpu_llc_id, cpu) != BAD_APICID &&
 		    per_cpu(cpu_llc_id, cpu) == per_cpu(cpu_llc_id, i)) {
-			cpu_set(i, c[cpu].llc_shared_map);
-			cpu_set(cpu, c[i].llc_shared_map);
+			cpu_set(i, c->llc_shared_map);
+			cpu_set(cpu, cpu_data(i).llc_shared_map);
 		}
-		if (c[cpu].phys_proc_id == c[i].phys_proc_id) {
+		if (c->phys_proc_id == cpu_data(i).phys_proc_id) {
 			cpu_set(i, per_cpu(cpu_core_map, cpu));
 			cpu_set(cpu, per_cpu(cpu_core_map, i));
 			/*
@@ -365,15 +366,15 @@ void __cpuinit set_cpu_sibling_map(int c
 				 * the booted_cores for this new cpu
 				 */
 				if (first_cpu(per_cpu(cpu_sibling_map, i)) == i)
-					c[cpu].booted_cores++;
+					c->booted_cores++;
 				/*
 				 * increment the core count for all
 				 * the other cpus in this package
 				 */
 				if (i != cpu)
-					c[i].booted_cores++;
-			} else if (i != cpu && !c[cpu].booted_cores)
-				c[cpu].booted_cores = c[i].booted_cores;
+					cpu_data(i).booted_cores++;
+			} else if (i != cpu && !c->booted_cores)
+				c->booted_cores = cpu_data(i).booted_cores;
 		}
 	}
 }
@@ -852,7 +853,7 @@ static int __cpuinit do_boot_cpu(int api
 			/* number CPUs logically, starting from 1 (BSP is 0) */
 			Dprintk("OK.\n");
 			printk("CPU%d: ", cpu);
-			print_cpu_info(&cpu_data[cpu]);
+			print_cpu_info(&cpu_data(cpu));
 			Dprintk("CPU has booted.\n");
 		} else {
 			boot_error= 1;
@@ -969,7 +970,7 @@ static void __init smp_boot_cpus(unsigne
 	 */
 	smp_store_cpu_info(0); /* Final full version of the data */
 	printk("CPU%d: ", 0);
-	print_cpu_info(&cpu_data[0]);
+	print_cpu_info(&cpu_data(0));
 
 	boot_cpu_physical_apicid = GET_APIC_ID(apic_read(APIC_ID));
 	boot_cpu_logical_apicid = logical_smp_processor_id();
@@ -1084,7 +1085,7 @@ static void __init smp_boot_cpus(unsigne
 	Dprintk("Before bogomips.\n");
 	for (cpu = 0; cpu < NR_CPUS; cpu++)
 		if (cpu_isset(cpu, cpu_callout_map))
-			bogosum += cpu_data[cpu].loops_per_jiffy;
+			bogosum += cpu_data(cpu).loops_per_jiffy;
 	printk(KERN_INFO
 		"Total of %d processors activated (%lu.%02lu BogoMIPS).\n",
 		cpucount+1,
@@ -1154,7 +1155,7 @@ void __init native_smp_prepare_boot_cpu(
 void remove_siblinginfo(int cpu)
 {
 	int sibling;
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(0);
 
 	for_each_cpu_mask(sibling, per_cpu(cpu_core_map, cpu)) {
 		cpu_clear(cpu, per_cpu(cpu_core_map, sibling));
--- a/arch/i386/kernel/tsc.c
+++ b/arch/i386/kernel/tsc.c
@@ -119,8 +119,8 @@ int recalibrate_cpu_khz(void)
 	if (cpu_has_tsc) {
 		cpu_khz = calculate_cpu_khz();
 		tsc_khz = cpu_khz;
-		cpu_data[0].loops_per_jiffy =
-			cpufreq_scale(cpu_data[0].loops_per_jiffy,
+		cpu_data(0).loops_per_jiffy =
+			cpufreq_scale(cpu_data(0).loops_per_jiffy,
 					cpu_khz_old, cpu_khz);
 		return 0;
 	} else
@@ -153,7 +153,7 @@ time_cpufreq_notifier(struct notifier_bl
 			return 0;
 		}
 		ref_freq = freq->old;
-		loops_per_jiffy_ref = cpu_data[freq->cpu].loops_per_jiffy;
+		loops_per_jiffy_ref = cpu_data(freq->cpu).loops_per_jiffy;
 		cpu_khz_ref = cpu_khz;
 	}
 
@@ -161,7 +161,7 @@ time_cpufreq_notifier(struct notifier_bl
 	    (val == CPUFREQ_POSTCHANGE && freq->old > freq->new) ||
 	    (val == CPUFREQ_RESUMECHANGE)) {
 		if (!(freq->flags & CPUFREQ_CONST_LOOPS))
-			cpu_data[freq->cpu].loops_per_jiffy =
+			cpu_data(freq->cpu).loops_per_jiffy =
 				cpufreq_scale(loops_per_jiffy_ref,
 						ref_freq, freq->new);
 
--- a/arch/i386/lib/delay.c
+++ b/arch/i386/lib/delay.c
@@ -82,7 +82,7 @@ inline void __const_udelay(unsigned long
 	__asm__("mull %0"
 		:"=d" (xloops), "=&a" (d0)
 		:"1" (xloops), "0"
-		(cpu_data[raw_smp_processor_id()].loops_per_jiffy * (HZ/4)));
+		(cpu_data(raw_smp_processor_id()).loops_per_jiffy * (HZ/4)));
 
 	__delay(++xloops);
 }
--- a/arch/i386/mach-voyager/voyager_smp.c
+++ b/arch/i386/mach-voyager/voyager_smp.c
@@ -36,8 +36,8 @@ static unsigned long cpu_irq_affinity[NR
 
 /* per CPU data structure (for /proc/cpuinfo et al), visible externally
  * indexed physically */
-struct cpuinfo_x86 cpu_data[NR_CPUS] __cacheline_aligned;
-EXPORT_SYMBOL(cpu_data);
+DEFINE_PER_CPU(cpuinfo_x86, cpu_info) __cacheline_aligned;
+EXPORT_PER_CPU_SYMBOL(cpu_info);
 
 /* physical ID of the CPU used to boot the system */
 unsigned char boot_cpu_id;
@@ -430,7 +430,7 @@ find_smp_config(void)
 void __init
 smp_store_cpu_info(int id)
 {
-	struct cpuinfo_x86 *c=&cpu_data[id];
+	struct cpuinfo_x86 *c=&cpu_data(id);
 
 	*c = boot_cpu_data;
 
@@ -634,7 +634,7 @@ do_boot_cpu(__u8 cpu)
 			cpu, smp_processor_id()));
 	
 		printk("CPU%d: ", cpu);
-		print_cpu_info(&cpu_data[cpu]);
+		print_cpu_info(&cpu_data(cpu));
 		wmb();
 		cpu_set(cpu, cpu_callout_map);
 		cpu_set(cpu, cpu_present_map);
@@ -683,7 +683,7 @@ smp_boot_cpus(void)
 	 */
 	smp_store_cpu_info(boot_cpu_id);
 	printk("CPU%d: ", boot_cpu_id);
-	print_cpu_info(&cpu_data[boot_cpu_id]);
+	print_cpu_info(&cpu_data(boot_cpu_id));
 
 	if(is_cpu_quad()) {
 		/* booting on a Quad CPU */
@@ -714,7 +714,7 @@ smp_boot_cpus(void)
 		unsigned long bogosum = 0;
 		for (i = 0; i < NR_CPUS; i++)
 			if (cpu_isset(i, cpu_online_map))
-				bogosum += cpu_data[i].loops_per_jiffy;
+				bogosum += cpu_data(i).loops_per_jiffy;
 		printk(KERN_INFO "Total of %d processors activated (%lu.%02lu BogoMIPS).\n",
 			cpucount+1,
 			bogosum/(500000/HZ),
--- a/arch/x86_64/kernel/mce.c
+++ b/arch/x86_64/kernel/mce.c
@@ -815,7 +815,7 @@ static __cpuinit int mce_create_device(u
 {
 	int err;
 	int i;
-	if (!mce_available(&cpu_data[cpu]))
+	if (!mce_available(&cpu_data(cpu)))
 		return -EIO;
 
 	memset(&per_cpu(device_mce, cpu).kobj, 0, sizeof(struct kobject));
--- a/arch/x86_64/kernel/mce_amd.c
+++ b/arch/x86_64/kernel/mce_amd.c
@@ -472,11 +472,11 @@ static __cpuinit int threshold_create_ba
 	sprintf(name, "threshold_bank%i", bank);
 
 #ifdef CONFIG_SMP
-	if (cpu_data[cpu].cpu_core_id && shared_bank[bank]) {	/* symlink */
+	if (cpu_data(cpu).cpu_core_id && shared_bank[bank]) {	/* symlink */
 		i = first_cpu(per_cpu(cpu_core_map, cpu));
 
 		/* first core not up yet */
-		if (cpu_data[i].cpu_core_id)
+		if (cpu_data(i).cpu_core_id)
 			goto out;
 
 		/* already linked */
--- a/arch/x86_64/kernel/setup.c
+++ b/arch/x86_64/kernel/setup.c
@@ -554,7 +554,7 @@ static void __init amd_detect_cmp(struct
  		   but in the same order as the HT nodeids.
  		   If that doesn't result in a usable node fall back to the
  		   path for the previous case.  */
- 		int ht_nodeid = apicid - (cpu_data[0].phys_proc_id << bits);
+ 		int ht_nodeid = apicid - (cpu_data(0).phys_proc_id << bits);
  		if (ht_nodeid >= 0 &&
  		    apicid_to_node[ht_nodeid] != NUMA_NO_NODE)
  			node = apicid_to_node[ht_nodeid];
@@ -910,6 +910,7 @@ void __cpuinit early_identify_cpu(struct
 
 #ifdef CONFIG_SMP
 	c->phys_proc_id = (cpuid_ebx(1) >> 24) & 0xff;
+	c->cpu_index = 0;
 #endif
 	/* AMD-defined flags: level 0x80000001 */
 	xlvl = cpuid_eax(0x80000000);
@@ -1022,6 +1023,7 @@ void __cpuinit print_cpu_info(struct cpu
 static int show_cpuinfo(struct seq_file *m, void *v)
 {
 	struct cpuinfo_x86 *c = v;
+	int cpu = 0;
 
 	/* 
 	 * These flag bits must match the definitions in <asm/cpufeature.h>.
@@ -1100,8 +1102,9 @@ static int show_cpuinfo(struct seq_file 
 
 
 #ifdef CONFIG_SMP
-	if (!cpu_online(c-cpu_data))
+	if (!cpu_online(c->cpu_index))
 		return 0;
+	cpu = c->cpu_index;
 #endif
 
 	seq_printf(m,"processor\t: %u\n"
@@ -1109,7 +1112,7 @@ static int show_cpuinfo(struct seq_file 
 		     "cpu family\t: %d\n"
 		     "model\t\t: %d\n"
 		     "model name\t: %s\n",
-		     (unsigned)(c-cpu_data),
+		     (unsigned)cpu,
 		     c->x86_vendor_id[0] ? c->x86_vendor_id : "unknown",
 		     c->x86,
 		     (int)c->x86_model,
@@ -1121,7 +1124,7 @@ static int show_cpuinfo(struct seq_file 
 		seq_printf(m, "stepping\t: unknown\n");
 	
 	if (cpu_has(c,X86_FEATURE_TSC)) {
-		unsigned int freq = cpufreq_quick_get((unsigned)(c-cpu_data));
+		unsigned int freq = cpufreq_quick_get((unsigned)cpu);
 		if (!freq)
 			freq = cpu_khz;
 		seq_printf(m, "cpu MHz\t\t: %u.%03u\n",
@@ -1134,7 +1137,6 @@ static int show_cpuinfo(struct seq_file 
 	
 #ifdef CONFIG_SMP
 	if (smp_num_siblings * c->x86_max_cores > 1) {
-		int cpu = c - cpu_data;
 		seq_printf(m, "physical id\t: %d\n", c->phys_proc_id);
 		seq_printf(m, "siblings\t: %d\n",
 			       cpus_weight(per_cpu(cpu_core_map, cpu)));
@@ -1192,12 +1194,14 @@ static int show_cpuinfo(struct seq_file 
 
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
-	return *pos < NR_CPUS ? cpu_data + *pos : NULL;
+	if (*pos == 0)	/* just in case, cpu 0 is not the first */
+		*pos = first_cpu(cpu_possible_map);
+	return cpu_possible(*pos) ? &cpu_data(*pos) : NULL;
 }
 
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
 {
-	++*pos;
+	*pos = next_cpu(*pos, cpu_possible_map);
 	return c_start(m, pos);
 }
 
--- a/arch/x86_64/kernel/tsc.c
+++ b/arch/x86_64/kernel/tsc.c
@@ -48,13 +48,13 @@ static int time_cpufreq_notifier(struct 
 	struct cpufreq_freqs *freq = data;
 	unsigned long *lpj, dummy;
 
-	if (cpu_has(&cpu_data[freq->cpu], X86_FEATURE_CONSTANT_TSC))
+	if (cpu_has(&cpu_data(freq->cpu), X86_FEATURE_CONSTANT_TSC))
 		return 0;
 
 	lpj = &dummy;
 	if (!(freq->flags & CPUFREQ_CONST_LOOPS))
 #ifdef CONFIG_SMP
-		lpj = &cpu_data[freq->cpu].loops_per_jiffy;
+		lpj = &cpu_data(freq->cpu).loops_per_jiffy;
 #else
 		lpj = &boot_cpu_data.loops_per_jiffy;
 #endif
--- a/arch/x86_64/kernel/vsyscall.c
+++ b/arch/x86_64/kernel/vsyscall.c
@@ -293,7 +293,7 @@ static void __cpuinit vsyscall_set_cpu(i
 #ifdef CONFIG_NUMA
 	node = cpu_to_node(cpu);
 #endif
-	if (cpu_has(&cpu_data[cpu], X86_FEATURE_RDTSCP))
+	if (cpu_has(&cpu_data(cpu), X86_FEATURE_RDTSCP))
 		write_rdtscp_aux((node << 12) | cpu);
 
 	/* Store cpu number in limit so that it can be loaded quickly
--- a/drivers/hwmon/coretemp.c
+++ b/drivers/hwmon/coretemp.c
@@ -150,7 +150,7 @@ static struct coretemp_data *coretemp_up
 static int __devinit coretemp_probe(struct platform_device *pdev)
 {
 	struct coretemp_data *data;
-	struct cpuinfo_x86 *c = &(cpu_data)[pdev->id];
+	struct cpuinfo_x86 *c = &cpu_data(pdev->id);
 	int err;
 	u32 eax, edx;
 
@@ -359,7 +359,7 @@ static int __init coretemp_init(void)
 	struct pdev_entry *p, *n;
 
 	/* quick check if we run Intel */
-	if (cpu_data[0].x86_vendor != X86_VENDOR_INTEL)
+	if (cpu_data(0).x86_vendor != X86_VENDOR_INTEL)
 		goto exit;
 
 	err = platform_driver_register(&coretemp_driver);
@@ -367,7 +367,7 @@ static int __init coretemp_init(void)
 		goto exit;
 
 	for_each_online_cpu(i) {
-		struct cpuinfo_x86 *c = &(cpu_data)[i];
+		struct cpuinfo_x86 *c = &cpu_data(i);
 
 		/* check if family 6, models e, f */
 		if ((c->cpuid_level < 0) || (c->x86 != 0x6) ||
--- a/drivers/hwmon/hwmon-vid.c
+++ b/drivers/hwmon/hwmon-vid.c
@@ -200,7 +200,7 @@ static u8 find_vrm(u8 eff_family, u8 eff
 
 u8 vid_which_vrm(void)
 {
-	struct cpuinfo_x86 *c = cpu_data;
+	struct cpuinfo_x86 *c = &cpu_data(0);
 	u32 eax;
 	u8 eff_family, eff_model, eff_stepping, vrm_ret;
 
--- a/drivers/input/gameport/gameport.c
+++ b/drivers/input/gameport/gameport.c
@@ -136,7 +136,7 @@ static int gameport_measure_speed(struct
 	}
 
 	gameport_close(gameport);
-	return (cpu_data[raw_smp_processor_id()].loops_per_jiffy * (unsigned long)HZ / (1000 / 50)) / (tx < 1 ? 1 : tx);
+	return (cpu_data(raw_smp_processor_id()).loops_per_jiffy * (unsigned long)HZ / (1000 / 50)) / (tx < 1 ? 1 : tx);
 
 #else
 
--- a/drivers/video/geode/video_gx.c
+++ b/drivers/video/geode/video_gx.c
@@ -127,7 +127,7 @@ static void gx_set_dclk_frequency(struct
 	int timeout = 1000;
 
 	/* Rev. 1 Geode GXs use a 14 MHz reference clock instead of 48 MHz. */
-	if (cpu_data->x86_mask == 1) {
+	if (cpu_data(0).x86_mask == 1) {
 		pll_table = gx_pll_table_14MHz;
 		pll_table_len = ARRAY_SIZE(gx_pll_table_14MHz);
 	} else {
--- a/include/asm-i386/processor.h
+++ b/include/asm-i386/processor.h
@@ -79,6 +79,7 @@ struct cpuinfo_x86 {
 	unsigned char booted_cores;	/* number of cores as seen by OS */
 	__u8 phys_proc_id; 		/* Physical processor id. */
 	__u8 cpu_core_id;  		/* Core id */
+	__u8 cpu_index;			/* index into per_cpu list */
 #endif
 } __attribute__((__aligned__(SMP_CACHE_BYTES)));
 
@@ -103,11 +104,12 @@ extern struct tss_struct doublefault_tss
 DECLARE_PER_CPU(struct tss_struct, init_tss);
 
 #ifdef CONFIG_SMP
-extern struct cpuinfo_x86 cpu_data[];
-#define current_cpu_data cpu_data[smp_processor_id()]
+DECLARE_PER_CPU(struct cpuinfo_x86, cpu_info);
+#define cpu_data(cpu)		per_cpu(cpu_info, cpu)
+#define current_cpu_data	cpu_data(smp_processor_id())
 #else
-#define cpu_data (&boot_cpu_data)
-#define current_cpu_data boot_cpu_data
+#define cpu_data(cpu)		boot_cpu_data
+#define current_cpu_data	boot_cpu_data
 #endif
 
 /*
--- a/include/asm-i386/topology.h
+++ b/include/asm-i386/topology.h
@@ -28,8 +28,8 @@
 #define _ASM_I386_TOPOLOGY_H
 
 #ifdef CONFIG_X86_HT
-#define topology_physical_package_id(cpu)	(cpu_data[cpu].phys_proc_id)
-#define topology_core_id(cpu)			(cpu_data[cpu].cpu_core_id)
+#define topology_physical_package_id(cpu)	(cpu_data(cpu).phys_proc_id)
+#define topology_core_id(cpu)			(cpu_data(cpu).cpu_core_id)
 #define topology_core_siblings(cpu)		(per_cpu(cpu_core_map, cpu))
 #define topology_thread_siblings(cpu)		(per_cpu(cpu_sibling_map, cpu))
 #endif
--- a/include/asm-x86_64/topology.h
+++ b/include/asm-x86_64/topology.h
@@ -56,8 +56,8 @@ extern int __node_distance(int, int);
 #endif
 
 #ifdef CONFIG_SMP
-#define topology_physical_package_id(cpu)	(cpu_data[cpu].phys_proc_id)
-#define topology_core_id(cpu)			(cpu_data[cpu].cpu_core_id)
+#define topology_physical_package_id(cpu)	(cpu_data(cpu).phys_proc_id)
+#define topology_core_id(cpu)			(cpu_data(cpu).cpu_core_id)
 #define topology_core_siblings(cpu)		(per_cpu(cpu_core_map, cpu))
 #define topology_thread_siblings(cpu)		(per_cpu(cpu_sibling_map, cpu))
 #define mc_capable()			(boot_cpu_data.x86_max_cores > 1)
--- a/arch/x86_64/lib/delay.c
+++ b/arch/x86_64/lib/delay.c
@@ -40,7 +40,7 @@ EXPORT_SYMBOL(__delay);
 
 inline void __const_udelay(unsigned long xloops)
 {
-	__delay(((xloops * HZ * cpu_data[raw_smp_processor_id()].loops_per_jiffy) >> 32) + 1);
+	__delay(((xloops * HZ * cpu_data(raw_smp_processor_id()).loops_per_jiffy) >> 32) + 1);
 }
 EXPORT_SYMBOL(__const_udelay);
 
--- a/arch/i386/kernel/cpu/proc.c
+++ b/arch/i386/kernel/cpu/proc.c
@@ -85,12 +85,13 @@ static int show_cpuinfo(struct seq_file 
 		/* nothing */
 	};
 	struct cpuinfo_x86 *c = v;
-	int i, n = c - cpu_data;
+	int i, n = 0;
 	int fpu_exception;
 
 #ifdef CONFIG_SMP
 	if (!cpu_online(n))
 		return 0;
+	n = c->cpu_index;
 #endif
 	seq_printf(m, "processor\t: %d\n"
 		"vendor_id\t: %s\n"
@@ -175,11 +176,13 @@ static int show_cpuinfo(struct seq_file 
 
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
-	return *pos < NR_CPUS ? cpu_data + *pos : NULL;
+	if (*pos == 0)	/* just in case, cpu 0 is not the first */
+		*pos = first_cpu(cpu_possible_map);
+	return cpu_possible(*pos) ? &cpu_data(*pos) : NULL;
 }
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
 {
-	++*pos;
+	*pos = next_cpu(*pos, cpu_possible_map);
 	return c_start(m, pos);
 }
 static void c_stop(struct seq_file *m, void *v)
--- a/arch/i386/kernel/sched-clock.c
+++ b/arch/i386/kernel/sched-clock.c
@@ -205,7 +205,7 @@ static int sc_freq_event(struct notifier
 {
 	struct cpufreq_freqs *freq = data;
 
-	if (cpu_has(&cpu_data[freq->cpu], X86_FEATURE_CONSTANT_TSC))
+	if (cpu_has(&cpu_data(freq->cpu), X86_FEATURE_CONSTANT_TSC))
 		return NOTIFY_DONE;
 	if (freq->old == freq->new)
 		return NOTIFY_DONE;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
