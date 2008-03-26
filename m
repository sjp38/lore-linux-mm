Message-Id: <20080326013813.331473000@polaris-admin.engr.sgi.com>
References: <20080326013811.569646000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 18:38:22 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 11/12] cpumask: reduce stack pressure in cpu_coregroup_map v2
Content-Disposition: inline; filename=cpu_coregroup_map
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, "William L. Irwin" <wli@holomorphy.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

Return pointer to requested cpumask for cpu_coregroup_map()
functions.

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

# sparc
Cc: David S. Miller <davem@davemloft.net>
Cc: William L. Irwin <wli@holomorphy.com>

# x86
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: H. Peter Anvin <hpa@zytor.com>

Signed-off-by: Mike Travis <travis@sgi.com>
---
v2: rebased on linux-2.6.git + linux-2.6-x86.git
---
 arch/x86/kernel/smpboot.c      |    6 +++---
 include/asm-sparc64/topology.h |    2 +-
 include/asm-x86/topology.h     |    2 +-
 kernel/sched.c                 |    6 +++---
 4 files changed, 8 insertions(+), 8 deletions(-)

--- linux.trees.git.orig/arch/x86/kernel/smpboot.c
+++ linux.trees.git/arch/x86/kernel/smpboot.c
@@ -538,7 +538,7 @@ void __cpuinit set_cpu_sibling_map(int c
 }
 
 /* maps the cpu to the sched domain representing multi-core */
-cpumask_t cpu_coregroup_map(int cpu)
+const cpumask_t *cpu_coregroup_map(int cpu)
 {
 	struct cpuinfo_x86 *c = &cpu_data(cpu);
 	/*
@@ -546,9 +546,9 @@ cpumask_t cpu_coregroup_map(int cpu)
 	 * And for power savings, we return cpu_core_map
 	 */
 	if (sched_mc_power_savings || sched_smt_power_savings)
-		return per_cpu(cpu_core_map, cpu);
+		return &per_cpu(cpu_core_map, cpu);
 	else
-		return c->llc_shared_map;
+		return &c->llc_shared_map;
 }
 
 /*
--- linux.trees.git.orig/include/asm-sparc64/topology.h
+++ linux.trees.git/include/asm-sparc64/topology.h
@@ -12,6 +12,6 @@
 
 #include <asm-generic/topology.h>
 
-#define cpu_coregroup_map(cpu)			(cpu_core_map[cpu])
+#define cpu_coregroup_map(cpu)			(&cpu_core_map[cpu])
 
 #endif /* _ASM_SPARC64_TOPOLOGY_H */
--- linux.trees.git.orig/include/asm-x86/topology.h
+++ linux.trees.git/include/asm-x86/topology.h
@@ -196,7 +196,7 @@ static inline void set_mp_bus_to_node(in
 
 #include <asm-generic/topology.h>
 
-extern cpumask_t cpu_coregroup_map(int cpu);
+const cpumask_t *cpu_coregroup_map(int cpu);
 
 #ifdef ENABLE_TOPO_DEFINES
 #define topology_physical_package_id(cpu)	(cpu_data(cpu).phys_proc_id)
--- linux.trees.git.orig/kernel/sched.c
+++ linux.trees.git/kernel/sched.c
@@ -6386,7 +6386,7 @@ cpu_to_phys_group(int cpu, const cpumask
 {
 	int group;
 #ifdef CONFIG_SCHED_MC
-	*mask = cpu_coregroup_map(cpu);
+	*mask = *cpu_coregroup_map(cpu);
 	cpus_and(*mask, *mask, *cpu_map);
 	group = first_cpu(*mask);
 #elif defined(CONFIG_SCHED_SMT)
@@ -6703,7 +6703,7 @@ static int build_sched_domains(const cpu
 		p = sd;
 		sd = &per_cpu(core_domains, i);
 		SD_INIT(sd, MC);
-		sd->span = cpu_coregroup_map(i);
+		sd->span = *cpu_coregroup_map(i);
 		cpus_and(sd->span, sd->span, *cpu_map);
 		sd->parent = p;
 		p->child = sd;
@@ -6745,7 +6745,7 @@ static int build_sched_domains(const cpu
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
