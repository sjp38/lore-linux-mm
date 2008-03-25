Message-Id: <20080325023122.763571000@polaris-admin.engr.sgi.com>
References: <20080325023120.859257000@polaris-admin.engr.sgi.com>
Date: Mon, 24 Mar 2008 19:31:31 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 11/12] cpumask: reduce stack pressure in cpu_coregroup_map
Content-Disposition: inline; filename=cpu_coregroup_map
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, "William L. Irwin" <wli@holomorphy.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

Return pointer to requested cpumask for cpu_coregroup_map()
functions.

Based on linux-2.6.25-rc5-mm1

# sparc
Cc: David S. Miller <davem@davemloft.net>
Cc: William L. Irwin <wli@holomorphy.com>

# x86
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: H. Peter Anvin <hpa@zytor.com>

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86/kernel/smpboot_32.c   |    6 +++---
 arch/x86/kernel/smpboot_64.c   |    6 +++---
 include/asm-sparc64/topology.h |    2 +-
 include/asm-x86/topology.h     |    2 +-
 kernel/sched.c                 |    6 +++---
 5 files changed, 11 insertions(+), 11 deletions(-)

--- linux-2.6.25-rc5.orig/arch/x86/kernel/smpboot_32.c
+++ linux-2.6.25-rc5/arch/x86/kernel/smpboot_32.c
@@ -290,7 +290,7 @@ static void __cpuinit smp_callin(void)
 static int cpucount;
 
 /* maps the cpu to the sched domain representing multi-core */
-cpumask_t cpu_coregroup_map(int cpu)
+const cpumask_t *cpu_coregroup_map(int cpu)
 {
 	struct cpuinfo_x86 *c = &cpu_data(cpu);
 	/*
@@ -298,9 +298,9 @@ cpumask_t cpu_coregroup_map(int cpu)
 	 * And for power savings, we return cpu_core_map
 	 */
 	if (sched_mc_power_savings || sched_smt_power_savings)
-		return per_cpu(cpu_core_map, cpu);
+		return &per_cpu(cpu_core_map, cpu);
 	else
-		return c->llc_shared_map;
+		return &c->llc_shared_map;
 }
 
 /* representing cpus for which sibling maps can be computed */
--- linux-2.6.25-rc5.orig/arch/x86/kernel/smpboot_64.c
+++ linux-2.6.25-rc5/arch/x86/kernel/smpboot_64.c
@@ -226,7 +226,7 @@ void __cpuinit smp_callin(void)
 }
 
 /* maps the cpu to the sched domain representing multi-core */
-cpumask_t cpu_coregroup_map(int cpu)
+const cpumask_t *cpu_coregroup_map(int cpu)
 {
 	struct cpuinfo_x86 *c = &cpu_data(cpu);
 	/*
@@ -234,9 +234,9 @@ cpumask_t cpu_coregroup_map(int cpu)
 	 * And for power savings, we return cpu_core_map
 	 */
 	if (sched_mc_power_savings || sched_smt_power_savings)
-		return per_cpu(cpu_core_map, cpu);
+		return &per_cpu(cpu_core_map, cpu);
 	else
-		return c->llc_shared_map;
+		return &c->llc_shared_map;
 }
 
 /* representing cpus for which sibling maps can be computed */
--- linux-2.6.25-rc5.orig/include/asm-sparc64/topology.h
+++ linux-2.6.25-rc5/include/asm-sparc64/topology.h
@@ -12,6 +12,6 @@
 
 #include <asm-generic/topology.h>
 
-#define cpu_coregroup_map(cpu)			(cpu_core_map[cpu])
+#define cpu_coregroup_map(cpu)			(&cpu_core_map[cpu])
 
 #endif /* _ASM_SPARC64_TOPOLOGY_H */
--- linux-2.6.25-rc5.orig/include/asm-x86/topology.h
+++ linux-2.6.25-rc5/include/asm-x86/topology.h
@@ -185,7 +185,7 @@ extern int __node_distance(int, int);
 
 #include <asm-generic/topology.h>
 
-extern cpumask_t cpu_coregroup_map(int cpu);
+extern const cpumask_t *cpu_coregroup_map(int cpu);
 
 #ifdef ENABLE_TOPO_DEFINES
 #define topology_physical_package_id(cpu)	(cpu_data(cpu).phys_proc_id)
--- linux-2.6.25-rc5.orig/kernel/sched.c
+++ linux-2.6.25-rc5/kernel/sched.c
@@ -6438,7 +6438,7 @@ cpu_to_phys_group(int cpu, const cpumask
 {
 	int group;
 #ifdef CONFIG_SCHED_MC
-	*mask = cpu_coregroup_map(cpu);
+	*mask = *cpu_coregroup_map(cpu);
 	cpus_and(*mask, *mask, *cpu_map);
 	group = first_cpu(*mask);
 #elif defined(CONFIG_SCHED_SMT)
@@ -6755,7 +6755,7 @@ static int build_sched_domains(const cpu
 		p = sd;
 		sd = &per_cpu(core_domains, i);
 		SD_INIT(sd, MC);
-		sd->span = cpu_coregroup_map(i);
+		sd->span = *cpu_coregroup_map(i);
 		cpus_and(sd->span, sd->span, *cpu_map);
 		sd->parent = p;
 		p->child = sd;
@@ -6797,7 +6797,7 @@ static int build_sched_domains(const cpu
 		SCHED_CPUMASK_VAR(this_core_map, allmasks);
 		SCHED_CPUMASK_VAR(send_covered, allmasks);
 
-		*this_core_map = cpu_coregroup_map(i);
+		*this_core_map = *cpu_coregroup_map(i);
 		cpus_and(*this_core_map, *this_core_map, *cpu_map);
 		if (i != first_cpu(*this_core_map))
 			continue;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
