Message-Id: <20080326013812.761990000@polaris-admin.engr.sgi.com>
References: <20080326013811.569646000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 18:38:18 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 07/12] cpumask: reduce stack usage in SD_x_INIT initializers
Content-Disposition: inline; filename=sched_domain
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

Remove empty cpumask_t (and all non-zero/non-null) variables
in SD_*_INIT macros.  Use memset(0) to clear.  Also, don't
inline the initializer functions to save on stack space in
build_sched_domains().

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: H. Peter Anvin <hpa@zytor.com>

Signed-off-by: Mike Travis <travis@sgi.com>
---
One checkpatch warning that I think can't be removed:

ERROR: Macros with complex values should be enclosed in parenthesis
#165: FILE: kernel/sched.c:6591:
#define SD_INIT_FUNC(type)	\
static noinline void sd_init_##type(struct sched_domain *sd)	\
{								\
	memset(sd, 0, sizeof(*sd));				\
	*sd = SD_##type##_INIT;					\
}

---
 include/asm-x86/topology.h |    5 -----
 include/linux/topology.h   |   33 ++-------------------------------
 kernel/sched.c             |   35 ++++++++++++++++++++++++++++++-----
 3 files changed, 32 insertions(+), 41 deletions(-)

--- linux.trees.git.orig/include/asm-x86/topology.h
+++ linux.trees.git/include/asm-x86/topology.h
@@ -155,10 +155,6 @@ extern unsigned long node_remap_size[];
 
 /* sched_domains SD_NODE_INIT for NUMAQ machines */
 #define SD_NODE_INIT (struct sched_domain) {		\
-	.span			= CPU_MASK_NONE,	\
-	.parent			= NULL,			\
-	.child			= NULL,			\
-	.groups			= NULL,			\
 	.min_interval		= 8,			\
 	.max_interval		= 32,			\
 	.busy_factor		= 32,			\
@@ -176,7 +172,6 @@ extern unsigned long node_remap_size[];
 				| SD_WAKE_BALANCE,	\
 	.last_balance		= jiffies,		\
 	.balance_interval	= 1,			\
-	.nr_balance_failed	= 0,			\
 }
 
 #ifdef CONFIG_X86_64_ACPI_NUMA
--- linux.trees.git.orig/include/linux/topology.h
+++ linux.trees.git/include/linux/topology.h
@@ -79,7 +79,9 @@ void arch_update_cpu_topology(void);
  * by defining their own arch-specific initializer in include/asm/topology.h.
  * A definition there will automagically override these default initializers
  * and allow arch-specific performance tuning of sched_domains.
+ * (Only non-zero and non-null fields need be specified.)
  */
+
 #ifdef CONFIG_SCHED_SMT
 /* MCD - Do we really need this?  It is always on if CONFIG_SCHED_SMT is,
  * so can't we drop this in favor of CONFIG_SCHED_SMT?
@@ -88,20 +90,10 @@ void arch_update_cpu_topology(void);
 /* Common values for SMT siblings */
 #ifndef SD_SIBLING_INIT
 #define SD_SIBLING_INIT (struct sched_domain) {		\
-	.span			= CPU_MASK_NONE,	\
-	.parent			= NULL,			\
-	.child			= NULL,			\
-	.groups			= NULL,			\
 	.min_interval		= 1,			\
 	.max_interval		= 2,			\
 	.busy_factor		= 64,			\
 	.imbalance_pct		= 110,			\
-	.cache_nice_tries	= 0,			\
-	.busy_idx		= 0,			\
-	.idle_idx		= 0,			\
-	.newidle_idx		= 0,			\
-	.wake_idx		= 0,			\
-	.forkexec_idx		= 0,			\
 	.flags			= SD_LOAD_BALANCE	\
 				| SD_BALANCE_NEWIDLE	\
 				| SD_BALANCE_FORK	\
@@ -111,7 +103,6 @@ void arch_update_cpu_topology(void);
 				| SD_SHARE_CPUPOWER,	\
 	.last_balance		= jiffies,		\
 	.balance_interval	= 1,			\
-	.nr_balance_failed	= 0,			\
 }
 #endif
 #endif /* CONFIG_SCHED_SMT */
@@ -120,18 +111,12 @@ void arch_update_cpu_topology(void);
 /* Common values for MC siblings. for now mostly derived from SD_CPU_INIT */
 #ifndef SD_MC_INIT
 #define SD_MC_INIT (struct sched_domain) {		\
-	.span			= CPU_MASK_NONE,	\
-	.parent			= NULL,			\
-	.child			= NULL,			\
-	.groups			= NULL,			\
 	.min_interval		= 1,			\
 	.max_interval		= 4,			\
 	.busy_factor		= 64,			\
 	.imbalance_pct		= 125,			\
 	.cache_nice_tries	= 1,			\
 	.busy_idx		= 2,			\
-	.idle_idx		= 0,			\
-	.newidle_idx		= 0,			\
 	.wake_idx		= 1,			\
 	.forkexec_idx		= 1,			\
 	.flags			= SD_LOAD_BALANCE	\
@@ -143,7 +128,6 @@ void arch_update_cpu_topology(void);
 				| BALANCE_FOR_MC_POWER,	\
 	.last_balance		= jiffies,		\
 	.balance_interval	= 1,			\
-	.nr_balance_failed	= 0,			\
 }
 #endif
 #endif /* CONFIG_SCHED_MC */
@@ -151,10 +135,6 @@ void arch_update_cpu_topology(void);
 /* Common values for CPUs */
 #ifndef SD_CPU_INIT
 #define SD_CPU_INIT (struct sched_domain) {		\
-	.span			= CPU_MASK_NONE,	\
-	.parent			= NULL,			\
-	.child			= NULL,			\
-	.groups			= NULL,			\
 	.min_interval		= 1,			\
 	.max_interval		= 4,			\
 	.busy_factor		= 64,			\
@@ -173,16 +153,11 @@ void arch_update_cpu_topology(void);
 				| BALANCE_FOR_PKG_POWER,\
 	.last_balance		= jiffies,		\
 	.balance_interval	= 1,			\
-	.nr_balance_failed	= 0,			\
 }
 #endif
 
 /* sched_domains SD_ALLNODES_INIT for NUMA machines */
 #define SD_ALLNODES_INIT (struct sched_domain) {	\
-	.span			= CPU_MASK_NONE,	\
-	.parent			= NULL,			\
-	.child			= NULL,			\
-	.groups			= NULL,			\
 	.min_interval		= 64,			\
 	.max_interval		= 64*num_online_cpus(),	\
 	.busy_factor		= 128,			\
@@ -190,14 +165,10 @@ void arch_update_cpu_topology(void);
 	.cache_nice_tries	= 1,			\
 	.busy_idx		= 3,			\
 	.idle_idx		= 3,			\
-	.newidle_idx		= 0, /* unused */	\
-	.wake_idx		= 0, /* unused */	\
-	.forkexec_idx		= 0, /* unused */	\
 	.flags			= SD_LOAD_BALANCE	\
 				| SD_SERIALIZE,	\
 	.last_balance		= jiffies,		\
 	.balance_interval	= 64,			\
-	.nr_balance_failed	= 0,			\
 }
 
 #ifdef CONFIG_NUMA
--- linux.trees.git.orig/kernel/sched.c
+++ linux.trees.git/kernel/sched.c
@@ -6532,6 +6532,31 @@ static void init_sched_groups_power(int 
 }
 
 /*
+ * Initializers for schedule domains
+ * Non-inlined to reduce accumulated stack pressure in build_sched_domains()
+ */
+
+#define	SD_INIT(sd, type)	sd_init_##type(sd)
+#define SD_INIT_FUNC(type)	\
+static noinline void sd_init_##type(struct sched_domain *sd)	\
+{								\
+	memset(sd, 0, sizeof(*sd));				\
+	*sd = SD_##type##_INIT;					\
+}
+
+SD_INIT_FUNC(CPU)
+#ifdef CONFIG_NUMA
+ SD_INIT_FUNC(ALLNODES)
+ SD_INIT_FUNC(NODE)
+#endif
+#ifdef CONFIG_SCHED_SMT
+ SD_INIT_FUNC(SIBLING)
+#endif
+#ifdef CONFIG_SCHED_MC
+ SD_INIT_FUNC(MC)
+#endif
+
+/*
  * Build sched domains for a given set of cpus and attach the sched domains
  * to the individual cpus
  */
@@ -6574,7 +6599,7 @@ static int build_sched_domains(const cpu
 		if (cpus_weight(*cpu_map) >
 				SD_NODES_PER_DOMAIN*cpus_weight(nodemask)) {
 			sd = &per_cpu(allnodes_domains, i);
-			*sd = SD_ALLNODES_INIT;
+			SD_INIT(sd, ALLNODES);
 			sd->span = *cpu_map;
 			cpu_to_allnodes_group(i, cpu_map, &sd->groups);
 			p = sd;
@@ -6583,7 +6608,7 @@ static int build_sched_domains(const cpu
 			p = NULL;
 
 		sd = &per_cpu(node_domains, i);
-		*sd = SD_NODE_INIT;
+		SD_INIT(sd, NODE);
 		sd->span = sched_domain_node_span(cpu_to_node(i));
 		sd->parent = p;
 		if (p)
@@ -6593,7 +6618,7 @@ static int build_sched_domains(const cpu
 
 		p = sd;
 		sd = &per_cpu(phys_domains, i);
-		*sd = SD_CPU_INIT;
+		SD_INIT(sd, CPU);
 		sd->span = nodemask;
 		sd->parent = p;
 		if (p)
@@ -6603,7 +6628,7 @@ static int build_sched_domains(const cpu
 #ifdef CONFIG_SCHED_MC
 		p = sd;
 		sd = &per_cpu(core_domains, i);
-		*sd = SD_MC_INIT;
+		SD_INIT(sd, MC);
 		sd->span = cpu_coregroup_map(i);
 		cpus_and(sd->span, sd->span, *cpu_map);
 		sd->parent = p;
@@ -6614,7 +6639,7 @@ static int build_sched_domains(const cpu
 #ifdef CONFIG_SCHED_SMT
 		p = sd;
 		sd = &per_cpu(cpu_domains, i);
-		*sd = SD_SIBLING_INIT;
+		SD_INIT(sd, SIBLING);
 		sd->span = per_cpu(cpu_sibling_map, i);
 		cpus_and(sd->span, sd->span, *cpu_map);
 		sd->parent = p;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
