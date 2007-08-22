Message-Id: <20070822172123.521671000@sgi.com>
References: <20070822172101.138513000@sgi.com>
Date: Wed, 22 Aug 2007 10:21:02 -0700
From: travis@sgi.com
Subject: [PATCH 1/6] x86: Convert cpu_core_map to be a per cpu variable
Content-Disposition: inline; filename=convert-cpu_core_map-to-per_cpu_data
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

This is from an earlier message from 'Christoph Lameter':

    cpu_core_map is currently an array defined using NR_CPUS. This means that
    we overallocate since we will rarely really use maximum configured cpu.

    If we put the cpu_core_map into the per cpu area then it will be allocated
    for each processor as it comes online.

    This means that the core map cannot be accessed until the per cpu area
    has been allocated. Xen does a weird thing here looping over all processors
    and zeroing the masks that are not yet allocated and that will be zeroed
    when they are allocated. I commented the code out.

    Signed-off-by: Christoph Lameter <clameter@sgi.com>

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/i386/kernel/cpu/cpufreq/acpi-cpufreq.c |    2 -
 arch/i386/kernel/cpu/cpufreq/powernow-k8.c  |   10 ++++----
 arch/i386/kernel/cpu/proc.c                 |    3 +-
 arch/i386/kernel/smpboot.c                  |   34 ++++++++++++++--------------
 arch/i386/xen/smp.c                         |   14 +++++++++--
 arch/x86_64/kernel/mce_amd.c                |    6 ++--
 arch/x86_64/kernel/setup.c                  |    3 +-
 arch/x86_64/kernel/smpboot.c                |   24 +++++++++----------
 include/asm-i386/smp.h                      |    2 -
 include/asm-i386/topology.h                 |    2 -
 include/asm-x86_64/smp.h                    |    8 +++++-
 include/asm-x86_64/topology.h               |    2 -
 12 files changed, 64 insertions(+), 46 deletions(-)

--- a/include/asm-x86_64/smp.h
+++ b/include/asm-x86_64/smp.h
@@ -39,7 +39,13 @@ extern int smp_num_siblings;
 extern void smp_send_reschedule(int cpu);
 
 extern cpumask_t cpu_sibling_map[NR_CPUS];
-extern cpumask_t cpu_core_map[NR_CPUS];
+/*
+ * cpu_core_map lives in a per cpu area
+ *
+ * extern cpumask_t cpu_core_map[NR_CPUS];
+ */
+DECLARE_PER_CPU(cpumask_t, cpu_core_map);
+
 extern u8 cpu_llc_id[NR_CPUS];
 
 #define SMP_TRAMPOLINE_BASE 0x6000
--- a/arch/i386/kernel/cpu/cpufreq/acpi-cpufreq.c
+++ b/arch/i386/kernel/cpu/cpufreq/acpi-cpufreq.c
@@ -595,7 +595,7 @@ static int acpi_cpufreq_cpu_init(struct 
 	dmi_check_system(sw_any_bug_dmi_table);
 	if (bios_with_sw_any_bug && cpus_weight(policy->cpus) == 1) {
 		policy->shared_type = CPUFREQ_SHARED_TYPE_ALL;
-		policy->cpus = cpu_core_map[cpu];
+		policy->cpus = per_cpu(cpu_core_map, cpu);
 	}
 #endif
 
--- a/arch/i386/kernel/cpu/cpufreq/powernow-k8.c
+++ b/arch/i386/kernel/cpu/cpufreq/powernow-k8.c
@@ -57,7 +57,7 @@ static struct powernow_k8_data *powernow
 static int cpu_family = CPU_OPTERON;
 
 #ifndef CONFIG_SMP
-static cpumask_t cpu_core_map[1];
+DEFINE_PER_CPU(cpumask_t, cpu_core_map)
 #endif
 
 /* Return a frequency in MHz, given an input fid */
@@ -667,7 +667,7 @@ static int fill_powernow_table(struct po
 
 	dprintk("cfid 0x%x, cvid 0x%x\n", data->currfid, data->currvid);
 	data->powernow_table = powernow_table;
-	if (first_cpu(cpu_core_map[data->cpu]) == data->cpu)
+	if (first_cpu(per_cpu(cpu_core_map, data->cpu)) == data->cpu)
 		print_basics(data);
 
 	for (j = 0; j < data->numps; j++)
@@ -821,7 +821,7 @@ static int powernow_k8_cpu_init_acpi(str
 
 	/* fill in data */
 	data->numps = data->acpi_data.state_count;
-	if (first_cpu(cpu_core_map[data->cpu]) == data->cpu)
+	if (first_cpu(per_cpu(cpu_core_map, data->cpu)) == data->cpu)
 		print_basics(data);
 	powernow_k8_acpi_pst_values(data, 0);
 
@@ -1214,7 +1214,7 @@ static int __cpuinit powernowk8_cpu_init
 	if (cpu_family == CPU_HW_PSTATE)
 		pol->cpus = cpumask_of_cpu(pol->cpu);
 	else
-		pol->cpus = cpu_core_map[pol->cpu];
+		pol->cpus = per_cpu(cpu_core_map, pol->cpu);
 	data->available_cores = &(pol->cpus);
 
 	/* Take a crude guess here.
@@ -1281,7 +1281,7 @@ static unsigned int powernowk8_get (unsi
 	cpumask_t oldmask = current->cpus_allowed;
 	unsigned int khz = 0;
 
-	data = powernow_data[first_cpu(cpu_core_map[cpu])];
+	data = powernow_data[first_cpu(per_cpu(cpu_core_map, cpu))];
 
 	if (!data)
 		return -EINVAL;
--- a/arch/i386/kernel/cpu/proc.c
+++ b/arch/i386/kernel/cpu/proc.c
@@ -122,7 +122,8 @@ static int show_cpuinfo(struct seq_file 
 #ifdef CONFIG_X86_HT
 	if (c->x86_max_cores * smp_num_siblings > 1) {
 		seq_printf(m, "physical id\t: %d\n", c->phys_proc_id);
-		seq_printf(m, "siblings\t: %d\n", cpus_weight(cpu_core_map[n]));
+		seq_printf(m, "siblings\t: %d\n",
+				cpus_weight(per_cpu(cpu_core_map, n)));
 		seq_printf(m, "core id\t\t: %d\n", c->cpu_core_id);
 		seq_printf(m, "cpu cores\t: %d\n", c->booted_cores);
 	}
--- a/arch/i386/kernel/smpboot.c
+++ b/arch/i386/kernel/smpboot.c
@@ -74,8 +74,8 @@ cpumask_t cpu_sibling_map[NR_CPUS] __rea
 EXPORT_SYMBOL(cpu_sibling_map);
 
 /* representing HT and core siblings of each logical CPU */
-cpumask_t cpu_core_map[NR_CPUS] __read_mostly;
-EXPORT_SYMBOL(cpu_core_map);
+DEFINE_PER_CPU(cpumask_t, cpu_core_map);
+EXPORT_PER_CPU_SYMBOL(cpu_core_map);
 
 /* bitmap of online cpus */
 cpumask_t cpu_online_map __read_mostly;
@@ -300,7 +300,7 @@ cpumask_t cpu_coregroup_map(int cpu)
 	 * And for power savings, we return cpu_core_map
 	 */
 	if (sched_mc_power_savings || sched_smt_power_savings)
-		return cpu_core_map[cpu];
+		return per_cpu(cpu_core_map, cpu);
 	else
 		return c->llc_shared_map;
 }
@@ -321,8 +321,8 @@ void __cpuinit set_cpu_sibling_map(int c
 			    c[cpu].cpu_core_id == c[i].cpu_core_id) {
 				cpu_set(i, cpu_sibling_map[cpu]);
 				cpu_set(cpu, cpu_sibling_map[i]);
-				cpu_set(i, cpu_core_map[cpu]);
-				cpu_set(cpu, cpu_core_map[i]);
+				cpu_set(i, per_cpu(cpu_core_map, cpu));
+				cpu_set(cpu, per_cpu(cpu_core_map, i));
 				cpu_set(i, c[cpu].llc_shared_map);
 				cpu_set(cpu, c[i].llc_shared_map);
 			}
@@ -334,7 +334,7 @@ void __cpuinit set_cpu_sibling_map(int c
 	cpu_set(cpu, c[cpu].llc_shared_map);
 
 	if (current_cpu_data.x86_max_cores == 1) {
-		cpu_core_map[cpu] = cpu_sibling_map[cpu];
+		per_cpu(cpu_core_map, cpu) = cpu_sibling_map[cpu];
 		c[cpu].booted_cores = 1;
 		return;
 	}
@@ -346,8 +346,8 @@ void __cpuinit set_cpu_sibling_map(int c
 			cpu_set(cpu, c[i].llc_shared_map);
 		}
 		if (c[cpu].phys_proc_id == c[i].phys_proc_id) {
-			cpu_set(i, cpu_core_map[cpu]);
-			cpu_set(cpu, cpu_core_map[i]);
+			cpu_set(i, per_cpu(cpu_core_map, cpu));
+			cpu_set(cpu, per_cpu(cpu_core_map, i));
 			/*
 			 *  Does this new cpu bringup a new core?
 			 */
@@ -984,7 +984,7 @@ static void __init smp_boot_cpus(unsigne
 					   " Using dummy APIC emulation.\n");
 		map_cpu_to_logical_apicid();
 		cpu_set(0, cpu_sibling_map[0]);
-		cpu_set(0, cpu_core_map[0]);
+		cpu_set(0, per_cpu(cpu_core_map, 0));
 		return;
 	}
 
@@ -1009,7 +1009,7 @@ static void __init smp_boot_cpus(unsigne
 		smpboot_clear_io_apic_irqs();
 		phys_cpu_present_map = physid_mask_of_physid(0);
 		cpu_set(0, cpu_sibling_map[0]);
-		cpu_set(0, cpu_core_map[0]);
+		cpu_set(0, per_cpu(cpu_core_map, 0));
 		return;
 	}
 
@@ -1024,7 +1024,7 @@ static void __init smp_boot_cpus(unsigne
 		smpboot_clear_io_apic_irqs();
 		phys_cpu_present_map = physid_mask_of_physid(0);
 		cpu_set(0, cpu_sibling_map[0]);
-		cpu_set(0, cpu_core_map[0]);
+		cpu_set(0, per_cpu(cpu_core_map, 0));
 		return;
 	}
 
@@ -1107,11 +1107,11 @@ static void __init smp_boot_cpus(unsigne
 	 */
 	for (cpu = 0; cpu < NR_CPUS; cpu++) {
 		cpus_clear(cpu_sibling_map[cpu]);
-		cpus_clear(cpu_core_map[cpu]);
+		cpus_clear(per_cpu(cpu_core_map, cpu));
 	}
 
 	cpu_set(0, cpu_sibling_map[0]);
-	cpu_set(0, cpu_core_map[0]);
+	cpu_set(0, per_cpu(cpu_core_map, 0));
 
 	smpboot_setup_io_apic();
 
@@ -1148,9 +1148,9 @@ void remove_siblinginfo(int cpu)
 	int sibling;
 	struct cpuinfo_x86 *c = cpu_data;
 
-	for_each_cpu_mask(sibling, cpu_core_map[cpu]) {
-		cpu_clear(cpu, cpu_core_map[sibling]);
-		/*
+	for_each_cpu_mask(sibling, per_cpu(cpu_core_map, cpu)) {
+		cpu_clear(cpu, per_cpu(cpu_core_map, sibling));
+		/*/
 		 * last thread sibling in this cpu core going down
 		 */
 		if (cpus_weight(cpu_sibling_map[cpu]) == 1)
@@ -1160,7 +1160,7 @@ void remove_siblinginfo(int cpu)
 	for_each_cpu_mask(sibling, cpu_sibling_map[cpu])
 		cpu_clear(cpu, cpu_sibling_map[sibling]);
 	cpus_clear(cpu_sibling_map[cpu]);
-	cpus_clear(cpu_core_map[cpu]);
+	cpus_clear(per_cpu(cpu_core_map, cpu));
 	c[cpu].phys_proc_id = 0;
 	c[cpu].cpu_core_id = 0;
 	cpu_clear(cpu, cpu_sibling_setup_map);
--- a/arch/i386/xen/smp.c
+++ b/arch/i386/xen/smp.c
@@ -148,7 +148,12 @@ void __init xen_smp_prepare_boot_cpu(voi
 
 	for (cpu = 0; cpu < NR_CPUS; cpu++) {
 		cpus_clear(cpu_sibling_map[cpu]);
-		cpus_clear(cpu_core_map[cpu]);
+		/*
+		 * cpu_core_map lives in a per cpu area that is cleared
+		 * when the per cpu array is allocated.
+		 *
+		 * cpus_clear(per_cpu(cpu_core_map, cpu));
+		 */
 	}
 
 	xen_setup_vcpu_info_placement();
@@ -160,7 +165,12 @@ void __init xen_smp_prepare_cpus(unsigne
 
 	for (cpu = 0; cpu < NR_CPUS; cpu++) {
 		cpus_clear(cpu_sibling_map[cpu]);
-		cpus_clear(cpu_core_map[cpu]);
+		/*
+		 * cpu_core_ map will be zeroed when the per
+		 * cpu area is allocated.
+		 *
+		 * cpus_clear(per_cpu(cpu_core_map, cpu));
+		 */
 	}
 
 	smp_store_cpu_info(0);
--- a/arch/x86_64/kernel/mce_amd.c
+++ b/arch/x86_64/kernel/mce_amd.c
@@ -473,7 +473,7 @@ static __cpuinit int threshold_create_ba
 
 #ifdef CONFIG_SMP
 	if (cpu_data[cpu].cpu_core_id && shared_bank[bank]) {	/* symlink */
-		i = first_cpu(cpu_core_map[cpu]);
+		i = first_cpu(per_cpu(cpu_core_map, cpu));
 
 		/* first core not up yet */
 		if (cpu_data[i].cpu_core_id)
@@ -493,7 +493,7 @@ static __cpuinit int threshold_create_ba
 		if (err)
 			goto out;
 
-		b->cpus = cpu_core_map[cpu];
+		b->cpus = per_cpu(cpu_core_map, cpu);
 		per_cpu(threshold_banks, cpu)[bank] = b;
 		goto out;
 	}
@@ -510,7 +510,7 @@ static __cpuinit int threshold_create_ba
 #ifndef CONFIG_SMP
 	b->cpus = CPU_MASK_ALL;
 #else
-	b->cpus = cpu_core_map[cpu];
+	b->cpus = per_cpu(cpu_core_map, cpu);
 #endif
 	err = kobject_register(&b->kobj);
 	if (err)
--- a/arch/x86_64/kernel/setup.c
+++ b/arch/x86_64/kernel/setup.c
@@ -1089,7 +1089,8 @@ static int show_cpuinfo(struct seq_file 
 	if (smp_num_siblings * c->x86_max_cores > 1) {
 		int cpu = c - cpu_data;
 		seq_printf(m, "physical id\t: %d\n", c->phys_proc_id);
-		seq_printf(m, "siblings\t: %d\n", cpus_weight(cpu_core_map[cpu]));
+		seq_printf(m, "siblings\t: %d\n",
+			       cpus_weight(per_cpu(cpu_core_map, cpu)));
 		seq_printf(m, "core id\t\t: %d\n", c->cpu_core_id);
 		seq_printf(m, "cpu cores\t: %d\n", c->booted_cores);
 	}
--- a/arch/x86_64/kernel/smpboot.c
+++ b/arch/x86_64/kernel/smpboot.c
@@ -95,8 +95,8 @@ cpumask_t cpu_sibling_map[NR_CPUS] __rea
 EXPORT_SYMBOL(cpu_sibling_map);
 
 /* representing HT and core siblings of each logical CPU */
-cpumask_t cpu_core_map[NR_CPUS] __read_mostly;
-EXPORT_SYMBOL(cpu_core_map);
+DEFINE_PER_CPU(cpumask_t, cpu_core_map);
+EXPORT_PER_CPU_SYMBOL(cpu_core_map);
 
 /*
  * Trampoline 80x86 program as an array.
@@ -245,7 +245,7 @@ cpumask_t cpu_coregroup_map(int cpu)
 	 * And for power savings, we return cpu_core_map
 	 */
 	if (sched_mc_power_savings || sched_smt_power_savings)
-		return cpu_core_map[cpu];
+		return per_cpu(cpu_core_map, cpu);
 	else
 		return c->llc_shared_map;
 }
@@ -266,8 +266,8 @@ static inline void set_cpu_sibling_map(i
 			    c[cpu].cpu_core_id == c[i].cpu_core_id) {
 				cpu_set(i, cpu_sibling_map[cpu]);
 				cpu_set(cpu, cpu_sibling_map[i]);
-				cpu_set(i, cpu_core_map[cpu]);
-				cpu_set(cpu, cpu_core_map[i]);
+				cpu_set(i, per_cpu(cpu_core_map, cpu));
+				cpu_set(cpu, per_cpu(cpu_core_map, i));
 				cpu_set(i, c[cpu].llc_shared_map);
 				cpu_set(cpu, c[i].llc_shared_map);
 			}
@@ -279,7 +279,7 @@ static inline void set_cpu_sibling_map(i
 	cpu_set(cpu, c[cpu].llc_shared_map);
 
 	if (current_cpu_data.x86_max_cores == 1) {
-		cpu_core_map[cpu] = cpu_sibling_map[cpu];
+		per_cpu(cpu_core_map, cpu) = cpu_sibling_map[cpu];
 		c[cpu].booted_cores = 1;
 		return;
 	}
@@ -291,8 +291,8 @@ static inline void set_cpu_sibling_map(i
 			cpu_set(cpu, c[i].llc_shared_map);
 		}
 		if (c[cpu].phys_proc_id == c[i].phys_proc_id) {
-			cpu_set(i, cpu_core_map[cpu]);
-			cpu_set(cpu, cpu_core_map[i]);
+			cpu_set(i, per_cpu(cpu_core_map, cpu));
+			cpu_set(cpu, per_cpu(cpu_core_map, i));
 			/*
 			 *  Does this new cpu bringup a new core?
 			 */
@@ -742,7 +742,7 @@ static __init void disable_smp(void)
 	else
 		phys_cpu_present_map = physid_mask_of_physid(0);
 	cpu_set(0, cpu_sibling_map[0]);
-	cpu_set(0, cpu_core_map[0]);
+	cpu_set(0, per_cpu(cpu_core_map, 0));
 }
 
 #ifdef CONFIG_HOTPLUG_CPU
@@ -977,8 +977,8 @@ static void remove_siblinginfo(int cpu)
 	int sibling;
 	struct cpuinfo_x86 *c = cpu_data;
 
-	for_each_cpu_mask(sibling, cpu_core_map[cpu]) {
-		cpu_clear(cpu, cpu_core_map[sibling]);
+	for_each_cpu_mask(sibling, per_cpu(cpu_core_map, cpu)) {
+		cpu_clear(cpu, per_cpu(cpu_core_map, sibling));
 		/*
 		 * last thread sibling in this cpu core going down
 		 */
@@ -989,7 +989,7 @@ static void remove_siblinginfo(int cpu)
 	for_each_cpu_mask(sibling, cpu_sibling_map[cpu])
 		cpu_clear(cpu, cpu_sibling_map[sibling]);
 	cpus_clear(cpu_sibling_map[cpu]);
-	cpus_clear(cpu_core_map[cpu]);
+	cpus_clear(per_cpu(cpu_core_map, cpu));
 	c[cpu].phys_proc_id = 0;
 	c[cpu].cpu_core_id = 0;
 	cpu_clear(cpu, cpu_sibling_setup_map);
--- a/include/asm-i386/smp.h
+++ b/include/asm-i386/smp.h
@@ -31,7 +31,7 @@ extern void smp_alloc_memory(void);
 extern int pic_mode;
 extern int smp_num_siblings;
 extern cpumask_t cpu_sibling_map[];
-extern cpumask_t cpu_core_map[];
+DECLARE_PER_CPU(cpumask_t, cpu_core_map);
 
 extern void (*mtrr_hook) (void);
 extern void zap_low_mappings (void);
--- a/include/asm-i386/topology.h
+++ b/include/asm-i386/topology.h
@@ -30,7 +30,7 @@
 #ifdef CONFIG_X86_HT
 #define topology_physical_package_id(cpu)	(cpu_data[cpu].phys_proc_id)
 #define topology_core_id(cpu)			(cpu_data[cpu].cpu_core_id)
-#define topology_core_siblings(cpu)		(cpu_core_map[cpu])
+#define topology_core_siblings(cpu)		(per_cpu(cpu_core_map, cpu))
 #define topology_thread_siblings(cpu)		(cpu_sibling_map[cpu])
 #endif
 
--- a/include/asm-x86_64/topology.h
+++ b/include/asm-x86_64/topology.h
@@ -71,7 +71,7 @@ static inline void set_mp_bus_to_node(in
 #ifdef CONFIG_SMP
 #define topology_physical_package_id(cpu)	(cpu_data[cpu].phys_proc_id)
 #define topology_core_id(cpu)			(cpu_data[cpu].cpu_core_id)
-#define topology_core_siblings(cpu)		(cpu_core_map[cpu])
+#define topology_core_siblings(cpu)		(per_cpu(cpu_core_map, cpu))
 #define topology_thread_siblings(cpu)		(cpu_sibling_map[cpu])
 #define mc_capable()			(boot_cpu_data.x86_max_cores > 1)
 #define smt_capable() 			(smp_num_siblings > 1)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
