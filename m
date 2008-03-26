Message-Id: <20080326013813.481009000@polaris-admin.engr.sgi.com>
References: <20080326013811.569646000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 18:38:23 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 12/12] cpu/node mask: reduce stack usage using MASK_NONE, MASK_ALL
Content-Disposition: inline; filename=CPU_NODE_MASK
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

Replace usages of CPU_MASK_NONE, CPU_MASK_ALL, NODE_MASK_NONE,
NODE_MASK_ALL to reduce stack requirements for large NR_CPUS
and MAXNODES counts.  In some cases, the cpumask variable was
initialized but then overwritten with another value.  This is
the case for changes like this:

-       cpumask_t oldmask = CPU_MASK_ALL;
+       cpumask_t oldmask;


Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

# x86
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: H. Peter Anvin <hpa@zytor.com>

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86/kernel/cpu/cpufreq/powernow-k8.c |    6 +++---
 arch/x86/kernel/cpu/mcheck/mce_amd_64.c   |    4 ++--
 arch/x86/kernel/genapic_flat_64.c         |    4 +++-
 arch/x86/kernel/io_apic_64.c              |    2 +-
 include/linux/cpumask.h                   |    6 ++++++
 init/main.c                               |    7 ++++++-
 kernel/cpu.c                              |    2 +-
 kernel/cpuset.c                           |   10 +++++-----
 kernel/irq/chip.c                         |    2 +-
 kernel/kmod.c                             |    2 +-
 kernel/kthread.c                          |    4 ++--
 kernel/rcutorture.c                       |    3 ++-
 kernel/sched.c                            |    8 ++++----
 mm/allocpercpu.c                          |    3 ++-
 14 files changed, 39 insertions(+), 24 deletions(-)

--- linux.trees.git.orig/arch/x86/kernel/cpu/cpufreq/powernow-k8.c
+++ linux.trees.git/arch/x86/kernel/cpu/cpufreq/powernow-k8.c
@@ -478,7 +478,7 @@ static int core_voltage_post_transition(
 
 static int check_supported_cpu(unsigned int cpu)
 {
-	cpumask_t oldmask = CPU_MASK_ALL;
+	cpumask_t oldmask;
 	u32 eax, ebx, ecx, edx;
 	unsigned int rc = 0;
 
@@ -1015,7 +1015,7 @@ static int transition_frequency_pstate(s
 /* Driver entry point to switch to the target frequency */
 static int powernowk8_target(struct cpufreq_policy *pol, unsigned targfreq, unsigned relation)
 {
-	cpumask_t oldmask = CPU_MASK_ALL;
+	cpumask_t oldmask;
 	struct powernow_k8_data *data = per_cpu(powernow_data, pol->cpu);
 	u32 checkfid;
 	u32 checkvid;
@@ -1104,7 +1104,7 @@ static int powernowk8_verify(struct cpuf
 static int __cpuinit powernowk8_cpu_init(struct cpufreq_policy *pol)
 {
 	struct powernow_k8_data *data;
-	cpumask_t oldmask = CPU_MASK_ALL;
+	cpumask_t oldmask;
 	int rc;
 
 	if (!cpu_online(pol->cpu))
--- linux.trees.git.orig/arch/x86/kernel/cpu/mcheck/mce_amd_64.c
+++ linux.trees.git/arch/x86/kernel/cpu/mcheck/mce_amd_64.c
@@ -255,7 +255,7 @@ static void affinity_set(unsigned int cp
 						cpumask_t *newmask)
 {
 	*oldmask = current->cpus_allowed;
-	*newmask = CPU_MASK_NONE;
+	cpus_clear(*newmask);
 	cpu_set(cpu, *newmask);
 	set_cpus_allowed(current, newmask);
 }
@@ -468,7 +468,7 @@ static __cpuinit int threshold_create_ba
 {
 	int i, err = 0;
 	struct threshold_bank *b = NULL;
-	cpumask_t oldmask = CPU_MASK_NONE, newmask;
+	cpumask_t oldmask, newmask;
 	char name[32];
 
 	sprintf(name, "threshold_bank%i", bank);
--- linux.trees.git.orig/arch/x86/kernel/genapic_flat_64.c
+++ linux.trees.git/arch/x86/kernel/genapic_flat_64.c
@@ -138,7 +138,9 @@ static cpumask_t physflat_target_cpus(vo
 
 static cpumask_t physflat_vector_allocation_domain(int cpu)
 {
-	cpumask_t domain = CPU_MASK_NONE;
+	cpumask_t domain;
+
+	cpus_clear(domain);
 	cpu_set(cpu, domain);
 	return domain;
 }
--- linux.trees.git.orig/arch/x86/kernel/io_apic_64.c
+++ linux.trees.git/arch/x86/kernel/io_apic_64.c
@@ -770,7 +770,7 @@ static void __clear_irq_vector(int irq)
 		per_cpu(vector_irq, cpu)[vector] = -1;
 
 	cfg->vector = 0;
-	cfg->domain = CPU_MASK_NONE;
+	cpus_clear(cfg->domain);
 }
 
 void __setup_vector_irq(int cpu)
--- linux.trees.git.orig/include/linux/cpumask.h
+++ linux.trees.git/include/linux/cpumask.h
@@ -244,6 +244,8 @@ int __next_cpu(int n, const cpumask_t *s
 }))
 static inline void setup_cpumask_of_cpu(int num) {}
 
+#define CPU_MASK_ALL_PTR	(&CPU_MASK_ALL)
+
 #else
 
 #define CPU_MASK_ALL							\
@@ -252,6 +254,10 @@ static inline void setup_cpumask_of_cpu(
 	[BITS_TO_LONGS(NR_CPUS)-1] = CPU_MASK_LAST_WORD			\
 } }
 
+/* cpu_mask_all is in init/main.c */
+extern cpumask_t cpu_mask_all;
+#define CPU_MASK_ALL_PTR	(&cpu_mask_all)
+
 /* cpumask_of_cpu_map is in init/main.c */
 #define cpumask_of_cpu(cpu)    (cpumask_of_cpu_map[cpu])
 extern cpumask_t *cpumask_of_cpu_map;
--- linux.trees.git.orig/init/main.c
+++ linux.trees.git/init/main.c
@@ -194,6 +194,11 @@ static const char *panic_later, *panic_p
 
 extern struct obs_kernel_param __setup_start[], __setup_end[];
 
+#if NR_CPUS > BITS_PER_LONG
+cpumask_t cpu_mask_all = CPU_MASK_ALL;
+EXPORT_SYMBOL(cpu_mask_all);
+#endif
+
 static int __init obsolete_checksetup(char *line)
 {
 	struct obs_kernel_param *p;
@@ -845,7 +850,7 @@ static int __init kernel_init(void * unu
 	/*
 	 * init can run on any cpu.
 	 */
-	set_cpus_allowed(current, &CPU_MASK_ALL);
+	set_cpus_allowed(current, CPU_MASK_ALL_PTR);
 	/*
 	 * Tell the world that we're going to be the grim
 	 * reaper of innocent orphaned children.
--- linux.trees.git.orig/kernel/cpu.c
+++ linux.trees.git/kernel/cpu.c
@@ -232,7 +232,7 @@ static int _cpu_down(unsigned int cpu, i
 
 	/* Ensure that we are not runnable on dying cpu */
 	old_allowed = current->cpus_allowed;
-	tmp = CPU_MASK_ALL;
+	cpus_setall(tmp);
 	cpu_clear(cpu, tmp);
 	set_cpus_allowed(current, &tmp);
 
--- linux.trees.git.orig/kernel/cpuset.c
+++ linux.trees.git/kernel/cpuset.c
@@ -1556,8 +1556,8 @@ static struct cgroup_subsys_state *cpuse
 	if (is_spread_slab(parent))
 		set_bit(CS_SPREAD_SLAB, &cs->flags);
 	set_bit(CS_SCHED_LOAD_BALANCE, &cs->flags);
-	cs->cpus_allowed = CPU_MASK_NONE;
-	cs->mems_allowed = NODE_MASK_NONE;
+	cpus_clear(cs->cpus_allowed);
+	nodes_clear(cs->mems_allowed);
 	cs->mems_generation = cpuset_mems_generation++;
 	fmeter_init(&cs->fmeter);
 
@@ -1626,8 +1626,8 @@ int __init cpuset_init(void)
 {
 	int err = 0;
 
-	top_cpuset.cpus_allowed = CPU_MASK_ALL;
-	top_cpuset.mems_allowed = NODE_MASK_ALL;
+	cpus_setall(top_cpuset.cpus_allowed);
+	nodes_setall(top_cpuset.mems_allowed);
 
 	fmeter_init(&top_cpuset.fmeter);
 	top_cpuset.mems_generation = cpuset_mems_generation++;
@@ -1873,7 +1873,7 @@ void cpuset_cpus_allowed_locked(struct t
 
 void cpuset_init_current_mems_allowed(void)
 {
-	current->mems_allowed = NODE_MASK_ALL;
+	nodes_setall(current->mems_allowed);
 }
 
 /**
--- linux.trees.git.orig/kernel/irq/chip.c
+++ linux.trees.git/kernel/irq/chip.c
@@ -47,7 +47,7 @@ void dynamic_irq_init(unsigned int irq)
 	desc->irq_count = 0;
 	desc->irqs_unhandled = 0;
 #ifdef CONFIG_SMP
-	desc->affinity = CPU_MASK_ALL;
+	cpus_setall(desc->affinity);
 #endif
 	spin_unlock_irqrestore(&desc->lock, flags);
 }
--- linux.trees.git.orig/kernel/kmod.c
+++ linux.trees.git/kernel/kmod.c
@@ -165,7 +165,7 @@ static int ____call_usermodehelper(void 
 	}
 
 	/* We can run anywhere, unlike our parent keventd(). */
-	set_cpus_allowed(current, &CPU_MASK_ALL);
+	set_cpus_allowed(current, CPU_MASK_ALL_PTR);
 
 	/*
 	 * Our parent is keventd, which runs with elevated scheduling priority.
--- linux.trees.git.orig/kernel/kthread.c
+++ linux.trees.git/kernel/kthread.c
@@ -107,7 +107,7 @@ static void create_kthread(struct kthrea
 		 */
 		sched_setscheduler(create->result, SCHED_NORMAL, &param);
 		set_user_nice(create->result, KTHREAD_NICE_LEVEL);
-		set_cpus_allowed(create->result, &CPU_MASK_ALL);
+		set_cpus_allowed(create->result, CPU_MASK_ALL_PTR);
 	}
 	complete(&create->done);
 }
@@ -232,7 +232,7 @@ int kthreadd(void *unused)
 	set_task_comm(tsk, "kthreadd");
 	ignore_signals(tsk);
 	set_user_nice(tsk, KTHREAD_NICE_LEVEL);
-	set_cpus_allowed(tsk, &CPU_MASK_ALL);
+	set_cpus_allowed(tsk, CPU_MASK_ALL_PTR);
 
 	current->flags |= PF_NOFREEZE;
 
--- linux.trees.git.orig/kernel/rcutorture.c
+++ linux.trees.git/kernel/rcutorture.c
@@ -723,9 +723,10 @@ static int rcu_idle_cpu;	/* Force all to
  */
 static void rcu_torture_shuffle_tasks(void)
 {
-	cpumask_t tmp_mask = CPU_MASK_ALL;
+	cpumask_t tmp_mask;
 	int i;
 
+	cpus_setall(tmp_mask);
 	get_online_cpus();
 
 	/* No point in shuffling if there is only one online CPU (ex: UP) */
--- linux.trees.git.orig/kernel/sched.c
+++ linux.trees.git/kernel/sched.c
@@ -5502,7 +5502,7 @@ static void move_task_off_dead_cpu(int d
  */
 static void migrate_nr_uninterruptible(struct rq *rq_src)
 {
-	struct rq *rq_dest = cpu_rq(any_online_cpu(CPU_MASK_ALL));
+	struct rq *rq_dest = cpu_rq(any_online_cpu(*CPU_MASK_ALL_PTR));
 	unsigned long flags;
 
 	local_irq_save(flags);
@@ -6220,7 +6220,7 @@ init_sched_build_groups(const cpumask_t 
 	struct sched_group *first = NULL, *last = NULL;
 	int i;
 
-	*covered = CPU_MASK_NONE;
+	cpus_clear(*covered);
 
 	for_each_cpu_mask(i, *span) {
 		struct sched_group *sg;
@@ -6230,7 +6230,7 @@ init_sched_build_groups(const cpumask_t 
 		if (cpu_isset(i, *covered))
 			continue;
 
-		sg->cpumask = CPU_MASK_NONE;
+		cpus_clear(sg->cpumask);
 		sg->__cpu_power = 0;
 
 		for_each_cpu_mask(j, *span) {
@@ -6790,7 +6790,7 @@ static int build_sched_domains(const cpu
 		int j;
 
 		*nodemask = node_to_cpumask(i);
-		*covered = CPU_MASK_NONE;
+		cpus_clear(*covered);
 
 		cpus_and(*nodemask, *nodemask, *cpu_map);
 		if (cpus_empty(*nodemask)) {
--- linux.trees.git.orig/mm/allocpercpu.c
+++ linux.trees.git/mm/allocpercpu.c
@@ -82,9 +82,10 @@ EXPORT_SYMBOL_GPL(percpu_populate);
 int __percpu_populate_mask(void *__pdata, size_t size, gfp_t gfp,
 			   cpumask_t *mask)
 {
-	cpumask_t populated = CPU_MASK_NONE;
+	cpumask_t populated;
 	int cpu;
 
+	cpus_clear(populated);
 	for_each_cpu_mask(cpu, *mask)
 		if (unlikely(!percpu_populate(__pdata, size, gfp, cpu))) {
 			__percpu_depopulate_mask(__pdata, &populated);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
