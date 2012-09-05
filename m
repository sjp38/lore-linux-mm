Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 8E9B36B005D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:06:44 -0400 (EDT)
Message-ID: <1346835993.2600.9.camel@twins>
Subject: Re: [RFC 0/5] forced comounts for cgroups.
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 05 Sep 2012 11:06:33 +0200
In-Reply-To: <20120905084740.GE3195@dhcp-172-17-108-109.mtv.corp.google.com>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
	 <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com>
	 <5047074D.1030104@parallels.com>
	 <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com>
	 <50470A87.1040701@parallels.com>
	 <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com>
	 <50470EBF.9070109@parallels.com>
	 <20120905084740.GE3195@dhcp-172-17-108-109.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

On Wed, 2012-09-05 at 01:47 -0700, Tejun Heo wrote:
> I think this is where we disagree.  I didn't mean that all controllers
> should be using exactly the same hierarchy when I was talking about
> unified hierarchy.  I do think it's useful and maybe even essential to
> allow differing levels of granularity.  cpu and cpuacct could be a
> valid example for this.  Likely blkcg and memcg too.
>=20
> So, I think it's desirable for all controllers to be able to handle
> hierarchies the same way and to have the ability to tag something as
> belonging to certain group in the hierarchy for all controllers but I
> don't think it's desirable or feasible to require all of them to
> follow exactly the same grouping at all levels.=20

*confused* I always thought that was exactly what you meant with unified
hierarchy.

Doing all this runtime is just going to make the mess even bigger,
because now we have to deal with even more stupid cases.

So either we go and try to contain this mess as proposed by Glauber or
we go delete controllers.. I've had it with this crap.

---
 Documentation/cgroups/00-INDEX    |   2 -
 Documentation/cgroups/cpuacct.txt |  49 --------
 include/linux/cgroup_subsys.h     |   6 -
 init/Kconfig                      |   6 -
 kernel/sched/core.c               | 247 ----------------------------------=
----
 kernel/sched/fair.c               |   1 -
 kernel/sched/rt.c                 |   1 -
 kernel/sched/sched.h              |  45 -------
 kernel/sched/stop_task.c          |   1 -
 9 files changed, 358 deletions(-)

diff --git a/Documentation/cgroups/00-INDEX b/Documentation/cgroups/00-INDE=
X
index 3f58fa3..9f100cc 100644
--- a/Documentation/cgroups/00-INDEX
+++ b/Documentation/cgroups/00-INDEX
@@ -2,8 +2,6 @@
 	- this file
 cgroups.txt
 	- Control Groups definition, implementation details, examples and API.
-cpuacct.txt
-	- CPU Accounting Controller; account CPU usage for groups of tasks.
 cpusets.txt
 	- documents the cpusets feature; assign CPUs and Mem to a set of tasks.
 devices.txt
diff --git a/Documentation/cgroups/cpuacct.txt b/Documentation/cgroups/cpua=
cct.txt
deleted file mode 100644
index 9d73cc0..0000000
--- a/Documentation/cgroups/cpuacct.txt
+++ /dev/null
@@ -1,49 +0,0 @@
-CPU Accounting Controller
--------------------------
-
-The CPU accounting controller is used to group tasks using cgroups and
-account the CPU usage of these groups of tasks.
-
-The CPU accounting controller supports multi-hierarchy groups. An accounti=
ng
-group accumulates the CPU usage of all of its child groups and the tasks
-directly present in its group.
-
-Accounting groups can be created by first mounting the cgroup filesystem.
-
-# mount -t cgroup -ocpuacct none /sys/fs/cgroup
-
-With the above step, the initial or the parent accounting group becomes
-visible at /sys/fs/cgroup. At bootup, this group includes all the tasks in
-the system. /sys/fs/cgroup/tasks lists the tasks in this cgroup.
-/sys/fs/cgroup/cpuacct.usage gives the CPU time (in nanoseconds) obtained
-by this group which is essentially the CPU time obtained by all the tasks
-in the system.
-
-New accounting groups can be created under the parent group /sys/fs/cgroup=
.
-
-# cd /sys/fs/cgroup
-# mkdir g1
-# echo $$ > g1/tasks
-
-The above steps create a new group g1 and move the current shell
-process (bash) into it. CPU time consumed by this bash and its children
-can be obtained from g1/cpuacct.usage and the same is accumulated in
-/sys/fs/cgroup/cpuacct.usage also.
-
-cpuacct.stat file lists a few statistics which further divide the
-CPU time obtained by the cgroup into user and system times. Currently
-the following statistics are supported:
-
-user: Time spent by tasks of the cgroup in user mode.
-system: Time spent by tasks of the cgroup in kernel mode.
-
-user and system are in USER_HZ unit.
-
-cpuacct controller uses percpu_counter interface to collect user and
-system times. This has two side effects:
-
-- It is theoretically possible to see wrong values for user and system tim=
es.
-  This is because percpu_counter_read() on 32bit systems isn't safe
-  against concurrent writes.
-- It is possible to see slightly outdated values for user and system times
-  due to the batch processing nature of percpu_counter.
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index dfae957..73b7cc1 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -25,12 +25,6 @@ SUBSYS(cpu_cgroup)
=20
 /* */
=20
-#ifdef CONFIG_CGROUP_CPUACCT
-SUBSYS(cpuacct)
-#endif
-
-/* */
-
 #ifdef CONFIG_MEMCG
 SUBSYS(mem_cgroup)
 #endif
diff --git a/init/Kconfig b/init/Kconfig
index af6c7f8..3ac9e1c 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -674,12 +674,6 @@ config PROC_PID_CPUSET
 	depends on CPUSETS
 	default y
=20
-config CGROUP_CPUACCT
-	bool "Simple CPU accounting cgroup subsystem"
-	help
-	  Provides a simple Resource Controller for monitoring the
-	  total CPU consumed by the tasks in a cgroup.
-
 config RESOURCE_COUNTERS
 	bool "Resource counters"
 	help
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 4376c9f..47c7cdb 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -2809,18 +2809,9 @@ unsigned long long task_sched_runtime(struct task_st=
ruct *p)
 	return ns;
 }
=20
-#ifdef CONFIG_CGROUP_CPUACCT
-struct cgroup_subsys cpuacct_subsys;
-struct cpuacct root_cpuacct;
-#endif
-
 static inline void task_group_account_field(struct task_struct *p, int ind=
ex,
 					    u64 tmp)
 {
-#ifdef CONFIG_CGROUP_CPUACCT
-	struct kernel_cpustat *kcpustat;
-	struct cpuacct *ca;
-#endif
 	/*
 	 * Since all updates are sure to touch the root cgroup, we
 	 * get ourselves ahead and touch it first. If the root cgroup
@@ -2828,20 +2819,6 @@ static inline void task_group_account_field(struct t=
ask_struct *p, int index,
 	 *
 	 */
 	__get_cpu_var(kernel_cpustat).cpustat[index] +=3D tmp;
-
-#ifdef CONFIG_CGROUP_CPUACCT
-	if (unlikely(!cpuacct_subsys.active))
-		return;
-
-	rcu_read_lock();
-	ca =3D task_ca(p);
-	while (ca && (ca !=3D &root_cpuacct)) {
-		kcpustat =3D this_cpu_ptr(ca->cpustat);
-		kcpustat->cpustat[index] +=3D tmp;
-		ca =3D parent_ca(ca);
-	}
-	rcu_read_unlock();
-#endif
 }
=20
=20
@@ -7351,12 +7328,6 @@ void __init sched_init(void)
=20
 #endif /* CONFIG_CGROUP_SCHED */
=20
-#ifdef CONFIG_CGROUP_CPUACCT
-	root_cpuacct.cpustat =3D &kernel_cpustat;
-	root_cpuacct.cpuusage =3D alloc_percpu(u64);
-	/* Too early, not expected to fail */
-	BUG_ON(!root_cpuacct.cpuusage);
-#endif
 	for_each_possible_cpu(i) {
 		struct rq *rq;
=20
@@ -8409,221 +8380,3 @@ struct cgroup_subsys cpu_cgroup_subsys =3D {
 };
=20
 #endif	/* CONFIG_CGROUP_SCHED */
-
-#ifdef CONFIG_CGROUP_CPUACCT
-
-/*
- * CPU accounting code for task groups.
- *
- * Based on the work by Paul Menage (menage@google.com) and Balbir Singh
- * (balbir@in.ibm.com).
- */
-
-/* create a new cpu accounting group */
-static struct cgroup_subsys_state *cpuacct_create(struct cgroup *cgrp)
-{
-	struct cpuacct *ca;
-
-	if (!cgrp->parent)
-		return &root_cpuacct.css;
-
-	ca =3D kzalloc(sizeof(*ca), GFP_KERNEL);
-	if (!ca)
-		goto out;
-
-	ca->cpuusage =3D alloc_percpu(u64);
-	if (!ca->cpuusage)
-		goto out_free_ca;
-
-	ca->cpustat =3D alloc_percpu(struct kernel_cpustat);
-	if (!ca->cpustat)
-		goto out_free_cpuusage;
-
-	return &ca->css;
-
-out_free_cpuusage:
-	free_percpu(ca->cpuusage);
-out_free_ca:
-	kfree(ca);
-out:
-	return ERR_PTR(-ENOMEM);
-}
-
-/* destroy an existing cpu accounting group */
-static void cpuacct_destroy(struct cgroup *cgrp)
-{
-	struct cpuacct *ca =3D cgroup_ca(cgrp);
-
-	free_percpu(ca->cpustat);
-	free_percpu(ca->cpuusage);
-	kfree(ca);
-}
-
-static u64 cpuacct_cpuusage_read(struct cpuacct *ca, int cpu)
-{
-	u64 *cpuusage =3D per_cpu_ptr(ca->cpuusage, cpu);
-	u64 data;
-
-#ifndef CONFIG_64BIT
-	/*
-	 * Take rq->lock to make 64-bit read safe on 32-bit platforms.
-	 */
-	raw_spin_lock_irq(&cpu_rq(cpu)->lock);
-	data =3D *cpuusage;
-	raw_spin_unlock_irq(&cpu_rq(cpu)->lock);
-#else
-	data =3D *cpuusage;
-#endif
-
-	return data;
-}
-
-static void cpuacct_cpuusage_write(struct cpuacct *ca, int cpu, u64 val)
-{
-	u64 *cpuusage =3D per_cpu_ptr(ca->cpuusage, cpu);
-
-#ifndef CONFIG_64BIT
-	/*
-	 * Take rq->lock to make 64-bit write safe on 32-bit platforms.
-	 */
-	raw_spin_lock_irq(&cpu_rq(cpu)->lock);
-	*cpuusage =3D val;
-	raw_spin_unlock_irq(&cpu_rq(cpu)->lock);
-#else
-	*cpuusage =3D val;
-#endif
-}
-
-/* return total cpu usage (in nanoseconds) of a group */
-static u64 cpuusage_read(struct cgroup *cgrp, struct cftype *cft)
-{
-	struct cpuacct *ca =3D cgroup_ca(cgrp);
-	u64 totalcpuusage =3D 0;
-	int i;
-
-	for_each_present_cpu(i)
-		totalcpuusage +=3D cpuacct_cpuusage_read(ca, i);
-
-	return totalcpuusage;
-}
-
-static int cpuusage_write(struct cgroup *cgrp, struct cftype *cftype,
-								u64 reset)
-{
-	struct cpuacct *ca =3D cgroup_ca(cgrp);
-	int err =3D 0;
-	int i;
-
-	if (reset) {
-		err =3D -EINVAL;
-		goto out;
-	}
-
-	for_each_present_cpu(i)
-		cpuacct_cpuusage_write(ca, i, 0);
-
-out:
-	return err;
-}
-
-static int cpuacct_percpu_seq_read(struct cgroup *cgroup, struct cftype *c=
ft,
-				   struct seq_file *m)
-{
-	struct cpuacct *ca =3D cgroup_ca(cgroup);
-	u64 percpu;
-	int i;
-
-	for_each_present_cpu(i) {
-		percpu =3D cpuacct_cpuusage_read(ca, i);
-		seq_printf(m, "%llu ", (unsigned long long) percpu);
-	}
-	seq_printf(m, "\n");
-	return 0;
-}
-
-static const char *cpuacct_stat_desc[] =3D {
-	[CPUACCT_STAT_USER] =3D "user",
-	[CPUACCT_STAT_SYSTEM] =3D "system",
-};
-
-static int cpuacct_stats_show(struct cgroup *cgrp, struct cftype *cft,
-			      struct cgroup_map_cb *cb)
-{
-	struct cpuacct *ca =3D cgroup_ca(cgrp);
-	int cpu;
-	s64 val =3D 0;
-
-	for_each_online_cpu(cpu) {
-		struct kernel_cpustat *kcpustat =3D per_cpu_ptr(ca->cpustat, cpu);
-		val +=3D kcpustat->cpustat[CPUTIME_USER];
-		val +=3D kcpustat->cpustat[CPUTIME_NICE];
-	}
-	val =3D cputime64_to_clock_t(val);
-	cb->fill(cb, cpuacct_stat_desc[CPUACCT_STAT_USER], val);
-
-	val =3D 0;
-	for_each_online_cpu(cpu) {
-		struct kernel_cpustat *kcpustat =3D per_cpu_ptr(ca->cpustat, cpu);
-		val +=3D kcpustat->cpustat[CPUTIME_SYSTEM];
-		val +=3D kcpustat->cpustat[CPUTIME_IRQ];
-		val +=3D kcpustat->cpustat[CPUTIME_SOFTIRQ];
-	}
-
-	val =3D cputime64_to_clock_t(val);
-	cb->fill(cb, cpuacct_stat_desc[CPUACCT_STAT_SYSTEM], val);
-
-	return 0;
-}
-
-static struct cftype files[] =3D {
-	{
-		.name =3D "usage",
-		.read_u64 =3D cpuusage_read,
-		.write_u64 =3D cpuusage_write,
-	},
-	{
-		.name =3D "usage_percpu",
-		.read_seq_string =3D cpuacct_percpu_seq_read,
-	},
-	{
-		.name =3D "stat",
-		.read_map =3D cpuacct_stats_show,
-	},
-	{ }	/* terminate */
-};
-
-/*
- * charge this task's execution time to its accounting group.
- *
- * called with rq->lock held.
- */
-void cpuacct_charge(struct task_struct *tsk, u64 cputime)
-{
-	struct cpuacct *ca;
-	int cpu;
-
-	if (unlikely(!cpuacct_subsys.active))
-		return;
-
-	cpu =3D task_cpu(tsk);
-
-	rcu_read_lock();
-
-	ca =3D task_ca(tsk);
-
-	for (; ca; ca =3D parent_ca(ca)) {
-		u64 *cpuusage =3D per_cpu_ptr(ca->cpuusage, cpu);
-		*cpuusage +=3D cputime;
-	}
-
-	rcu_read_unlock();
-}
-
-struct cgroup_subsys cpuacct_subsys =3D {
-	.name =3D "cpuacct",
-	.create =3D cpuacct_create,
-	.destroy =3D cpuacct_destroy,
-	.subsys_id =3D cpuacct_subsys_id,
-	.base_cftypes =3D files,
-};
-#endif	/* CONFIG_CGROUP_CPUACCT */
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 01d3eda..bff5b6e 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -706,7 +706,6 @@ static void update_curr(struct cfs_rq *cfs_rq)
 		struct task_struct *curtask =3D task_of(curr);
=20
 		trace_sched_stat_runtime(curtask, delta_exec, curr->vruntime);
-		cpuacct_charge(curtask, delta_exec);
 		account_group_exec_runtime(curtask, delta_exec);
 	}
=20
diff --git a/kernel/sched/rt.c b/kernel/sched/rt.c
index 944cb68..8e5805e 100644
--- a/kernel/sched/rt.c
+++ b/kernel/sched/rt.c
@@ -934,7 +934,6 @@ static void update_curr_rt(struct rq *rq)
 	account_group_exec_runtime(curr, delta_exec);
=20
 	curr->se.exec_start =3D rq->clock_task;
-	cpuacct_charge(curr, delta_exec);
=20
 	sched_rt_avg_update(rq, delta_exec);
=20
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index f6714d0..00ca3f6 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -833,15 +833,6 @@ static const u32 prio_to_wmult[40] =3D {
  /*  15 */ 119304647, 148102320, 186737708, 238609294, 286331153,
 };
=20
-/* Time spent by the tasks of the cpu accounting group executing in ... */
-enum cpuacct_stat_index {
-	CPUACCT_STAT_USER,	/* ... user mode */
-	CPUACCT_STAT_SYSTEM,	/* ... kernel mode */
-
-	CPUACCT_STAT_NSTATS,
-};
-
-
 #define sched_class_highest (&stop_sched_class)
 #define for_each_class(class) \
    for (class =3D sched_class_highest; class; class =3D class->next)
@@ -881,42 +872,6 @@ extern void init_rt_bandwidth(struct rt_bandwidth *rt_=
b, u64 period, u64 runtime
=20
 extern void update_idle_cpu_load(struct rq *this_rq);
=20
-#ifdef CONFIG_CGROUP_CPUACCT
-#include <linux/cgroup.h>
-/* track cpu usage of a group of tasks and its child groups */
-struct cpuacct {
-	struct cgroup_subsys_state css;
-	/* cpuusage holds pointer to a u64-type object on every cpu */
-	u64 __percpu *cpuusage;
-	struct kernel_cpustat __percpu *cpustat;
-};
-
-/* return cpu accounting group corresponding to this container */
-static inline struct cpuacct *cgroup_ca(struct cgroup *cgrp)
-{
-	return container_of(cgroup_subsys_state(cgrp, cpuacct_subsys_id),
-			    struct cpuacct, css);
-}
-
-/* return cpu accounting group to which this task belongs */
-static inline struct cpuacct *task_ca(struct task_struct *tsk)
-{
-	return container_of(task_subsys_state(tsk, cpuacct_subsys_id),
-			    struct cpuacct, css);
-}
-
-static inline struct cpuacct *parent_ca(struct cpuacct *ca)
-{
-	if (!ca || !ca->css.cgroup->parent)
-		return NULL;
-	return cgroup_ca(ca->css.cgroup->parent);
-}
-
-extern void cpuacct_charge(struct task_struct *tsk, u64 cputime);
-#else
-static inline void cpuacct_charge(struct task_struct *tsk, u64 cputime) {}
-#endif
-
 static inline void inc_nr_running(struct rq *rq)
 {
 	rq->nr_running++;
diff --git a/kernel/sched/stop_task.c b/kernel/sched/stop_task.c
index da5eb5b..fda1cbe 100644
--- a/kernel/sched/stop_task.c
+++ b/kernel/sched/stop_task.c
@@ -68,7 +68,6 @@ static void put_prev_task_stop(struct rq *rq, struct task=
_struct *prev)
 	account_group_exec_runtime(curr, delta_exec);
=20
 	curr->se.exec_start =3D rq->clock_task;
-	cpuacct_charge(curr, delta_exec);
 }
=20
 static void task_tick_stop(struct rq *rq, struct task_struct *curr, int qu=
eued)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
