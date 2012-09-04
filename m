Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 38EE56B0070
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 10:21:59 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [RFC 3/5] sched: do not call cpuacct_charge when cpu and cpuacct are comounted
Date: Tue,  4 Sep 2012 18:18:18 +0400
Message-Id: <1346768300-10282-4-git-send-email-glommer@parallels.com>
In-Reply-To: <1346768300-10282-1-git-send-email-glommer@parallels.com>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, a.p.zijlstra@chello.nl, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org, tj@kernel.org, Glauber Costa <glommer@parallels.com>

cpuacct_charge() incurs in some quite expensive operations to achieve
its measurement goal. To make matters worse, this cost is not constant,
but grows with the depth of the cgroup hierarchy tree. Also, all this
data is already available anyway in the scheduler core.

The fact that the cpuacct cgroup cannot be guaranteed to be mounted in
the same hierarchy as the scheduler core cgroup (cpu), forces us to go
gather them all again.

With the introduction of CONFIG_CGROUP_FORCE_COMOUNT_CPU, we will be
able to be absolutely sure that such a coupling exists. After that, the
hierarchy walks can be completely abandoned.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Dave Jones <davej@redhat.com>
CC: Ben Hutchings <ben@decadent.org.uk>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Paul Turner <pjt@google.com>
CC: Lennart Poettering <lennart@poettering.net>
CC: Kay Sievers <kay.sievers@vrfy.org>
CC: Tejun Heo <tj@kernel.org>
---
 init/Kconfig         |  19 +++++++
 kernel/sched/core.c  | 141 +++++++++++++++++++++++++++++++++++++++++++++++----
 kernel/sched/sched.h |  14 ++++-
 3 files changed, 163 insertions(+), 11 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index d7d693d..694944e 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -684,6 +684,25 @@ config CGROUP_FORCE_COMOUNT
 	bool
 	default n
 
+config CGROUP_FORCE_COMOUNT_CPU
+	bool "Enforce single hierarchy for the cpu related cgroups"
+	depends on CGROUP_SCHED || CPUSETS || CGROUP_CPUACCT
+	select SCHEDSTATS
+	select CGROUP_FORCE_COMOUNT
+	default n
+	help
+	  Throughout cgroup's life, it was always possible to mount the
+	  controllers in completely independent hierarchies. However, the
+	  costs incurred by allowing are considerably big. Hotpaths in the
+	  scheduler needs to call expensive hierarchy walks more than once in
+	  the same place just to account for the fact that multiple controllers
+	  can be mounted in different places.
+
+	  Setting this option will disallow cpu, cpuacct and cpuset to be
+	  mounted in different hierarchies. Distributions are highly encouraged
+	  to set this option and comount those groups.
+
+
 config RESOURCE_COUNTERS
 	bool "Resource counters"
 	help
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 468bdd4..e46871d 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -8282,6 +8282,15 @@ static struct cftype cpu_files[] = {
 	{ }	/* terminate */
 };
 
+bool cpuacct_from_cpu;
+
+#ifdef CONFIG_CGROUP_FORCE_COMOUNT_CPU
+void cpu_cgroup_bind(struct cgroup *root)
+{
+	cpuacct_from_cpu = root->root == root_task_group.css.cgroup->root;
+#endif
+}
+
 struct cgroup_subsys cpu_cgroup_subsys = {
 	.name		= "cpu",
 	.create		= cpu_cgroup_create,
@@ -8291,6 +8300,11 @@ struct cgroup_subsys cpu_cgroup_subsys = {
 	.exit		= cpu_cgroup_exit,
 	.subsys_id	= cpu_cgroup_subsys_id,
 	.base_cftypes	= cpu_files,
+#ifdef CONFIG_CGROUP_FORCE_COMOUNT_CPU
+	.comounts	= 1,
+	.must_comount	= { cpuacct_subsys_id, },
+	.bind		= cpu_cgroup_bind,
+#endif
 	.early_init	= 1,
 };
 
@@ -8345,8 +8359,102 @@ static void cpuacct_destroy(struct cgroup *cgrp)
 	kfree(ca);
 }
 
-static u64 cpuacct_cpuusage_read(struct cpuacct *ca, int cpu)
+#ifdef CONFIG_CGROUP_SCHED
+#ifdef CONFIG_FAIR_GROUP_SCHED
+static struct cfs_rq *
+cpu_cgroup_cfs_rq(struct cgroup *cgrp, int cpu)
+{
+	struct task_group *tg = cgroup_tg(cgrp);
+
+	if (tg == &root_task_group)
+		return &cpu_rq(cpu)->cfs;
+
+	return tg->cfs_rq[cpu];
+}
+
+static void cpu_cgroup_update_cpuusage_cfs(struct cgroup *cgrp, int cpu)
+{
+	struct cfs_rq *cfs = cpu_cgroup_cfs_rq(cgrp, cpu);
+	cfs->prev_exec_clock = cfs->exec_clock;
+}
+static u64 cpu_cgroup_cpuusage_cfs(struct cgroup *cgrp, int cpu)
+{
+	struct cfs_rq *cfs = cpu_cgroup_cfs_rq(cgrp, cpu);
+	return cfs->exec_clock - cfs->prev_exec_clock;
+}
+#else
+static void cpu_cgroup_update_cpuusage_cfs(struct cgroup *cgrp, int cpu)
 {
+}
+
+static u64 cpu_cgroup_cpuusage_cfs(struct cgroup *cgrp, int cpu)
+{
+	return 0;
+}
+#endif
+
+#ifdef CONFIG_RT_GROUP_SCHED
+static struct rt_rq *
+cpu_cgroup_rt_rq(struct cgroup *cgrp, int cpu)
+{
+	struct task_group *tg = cgroup_tg(cgrp);
+	if (tg == &root_task_group)
+		return &cpu_rq(cpu)->rt;
+
+	return tg->rt_rq[cpu];
+
+}
+static void cpu_cgroup_update_cpuusage_rt(struct cgroup *cgrp, int cpu)
+{
+	struct rt_rq *rt = cpu_cgroup_rt_rq(cgrp, cpu);
+	rt->prev_exec_clock = rt->exec_clock;
+}
+
+static u64 cpu_cgroup_cpuusage_rt(struct cgroup *cgrp, int cpu)
+{
+	struct rt_rq *rt = cpu_cgroup_rt_rq(cgrp, cpu);
+	return rt->exec_clock - rt->prev_exec_clock;
+}
+#else
+static void cpu_cgroup_update_cpuusage_rt(struct cgroup *cgrp, int cpu)
+{
+}
+static u64 cpu_cgroup_cpuusage_rt(struct cgroup *cgrp, int cpu)
+{
+	return 0;
+}
+#endif
+
+static int cpu_cgroup_cpuusage_write(struct cgroup *cgrp, int cpu, u64 val)
+{
+	cpu_cgroup_update_cpuusage_cfs(cgrp, cpu);
+	cpu_cgroup_update_cpuusage_rt(cgrp, cpu);
+	return 0;
+}
+
+static u64 cpu_cgroup_cpuusage_read(struct cgroup *cgrp, int cpu)
+{
+	return cpu_cgroup_cpuusage_cfs(cgrp, cpu) +
+	       cpu_cgroup_cpuusage_rt(cgrp, cpu);
+}
+
+#else
+static u64 cpu_cgroup_cpuusage_read(struct cgroup *cgrp, int i)
+{
+	BUG();
+	return 0;
+}
+
+static int cpu_cgroup_cpuusage_write(struct cgroup *cgrp, int cpu, u64 val)
+{
+	BUG();
+	return 0;
+}
+#endif /* CONFIG_CGROUP_SCHED */
+
+static u64 cpuacct_cpuusage_read(struct cgroup *cgrp, int cpu)
+{
+	struct cpuacct *ca = cgroup_ca(cgrp);
 	u64 *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
 	u64 data;
 
@@ -8364,8 +8472,9 @@ static u64 cpuacct_cpuusage_read(struct cpuacct *ca, int cpu)
 	return data;
 }
 
-static void cpuacct_cpuusage_write(struct cpuacct *ca, int cpu, u64 val)
+static void cpuacct_cpuusage_write(struct cgroup *cgrp, int cpu, u64 val)
 {
+	struct cpuacct *ca = cgroup_ca(cgrp);
 	u64 *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
 
 #ifndef CONFIG_64BIT
@@ -8380,15 +8489,21 @@ static void cpuacct_cpuusage_write(struct cpuacct *ca, int cpu, u64 val)
 #endif
 }
 
+static u64 cpuusage_read_percpu(struct cgroup *cgrp, int cpu)
+{
+	if (cpuacct_from_cpu)
+		return cpu_cgroup_cpuusage_read(cgrp, cpu);
+	return cpuacct_cpuusage_read(cgrp, cpu);
+}
+
 /* return total cpu usage (in nanoseconds) of a group */
 static u64 cpuusage_read(struct cgroup *cgrp, struct cftype *cft)
 {
-	struct cpuacct *ca = cgroup_ca(cgrp);
 	u64 totalcpuusage = 0;
 	int i;
 
 	for_each_present_cpu(i)
-		totalcpuusage += cpuacct_cpuusage_read(ca, i);
+		totalcpuusage += cpuusage_read_percpu(cgrp, i);
 
 	return totalcpuusage;
 }
@@ -8396,7 +8511,6 @@ static u64 cpuusage_read(struct cgroup *cgrp, struct cftype *cft)
 static int cpuusage_write(struct cgroup *cgrp, struct cftype *cftype,
 								u64 reset)
 {
-	struct cpuacct *ca = cgroup_ca(cgrp);
 	int err = 0;
 	int i;
 
@@ -8405,8 +8519,12 @@ static int cpuusage_write(struct cgroup *cgrp, struct cftype *cftype,
 		goto out;
 	}
 
-	for_each_present_cpu(i)
-		cpuacct_cpuusage_write(ca, i, 0);
+	for_each_present_cpu(i) {
+		if (cpuacct_from_cpu)
+			cpu_cgroup_cpuusage_write(cgrp, i, 0);
+		else
+			cpuacct_cpuusage_write(cgrp, i, 0);
+	}
 
 out:
 	return err;
@@ -8415,12 +8533,11 @@ out:
 static int cpuacct_percpu_seq_read(struct cgroup *cgroup, struct cftype *cft,
 				   struct seq_file *m)
 {
-	struct cpuacct *ca = cgroup_ca(cgroup);
 	u64 percpu;
 	int i;
 
 	for_each_present_cpu(i) {
-		percpu = cpuacct_cpuusage_read(ca, i);
+		percpu = cpuusage_read_percpu(cgroup, i);
 		seq_printf(m, "%llu ", (unsigned long long) percpu);
 	}
 	seq_printf(m, "\n");
@@ -8483,7 +8600,7 @@ static struct cftype files[] = {
  *
  * called with rq->lock held.
  */
-void cpuacct_charge(struct task_struct *tsk, u64 cputime)
+void __cpuacct_charge(struct task_struct *tsk, u64 cputime)
 {
 	struct cpuacct *ca;
 	int cpu;
@@ -8511,5 +8628,9 @@ struct cgroup_subsys cpuacct_subsys = {
 	.destroy = cpuacct_destroy,
 	.subsys_id = cpuacct_subsys_id,
 	.base_cftypes = files,
+#ifdef CONFIG_CGROUP_FORCE_COMOUNT_CPU
+	.comounts = 1,
+	.must_comount = { cpu_cgroup_subsys_id, },
+#endif
 };
 #endif	/* CONFIG_CGROUP_CPUACCT */
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 8da579d..1da9fa8 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -885,6 +885,9 @@ extern void update_idle_cpu_load(struct rq *this_rq);
 
 #ifdef CONFIG_CGROUP_CPUACCT
 #include <linux/cgroup.h>
+
+extern bool cpuacct_from_cpu;
+
 /* track cpu usage of a group of tasks and its child groups */
 struct cpuacct {
 	struct cgroup_subsys_state css;
@@ -914,7 +917,16 @@ static inline struct cpuacct *parent_ca(struct cpuacct *ca)
 	return cgroup_ca(ca->css.cgroup->parent);
 }
 
-extern void cpuacct_charge(struct task_struct *tsk, u64 cputime);
+extern void __cpuacct_charge(struct task_struct *tsk, u64 cputime);
+
+static inline void cpuacct_charge(struct task_struct *tsk, u64 cputime)
+{
+#ifdef CONFIG_CGROUP_FORCE_COMOUNT_CPU
+	if (likely(!cpuacct_from_cpu))
+		return;
+#endif
+	__cpuacct_charge(tsk, cputime);
+}
 #else
 static inline void cpuacct_charge(struct task_struct *tsk, u64 cputime) {}
 #endif
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
