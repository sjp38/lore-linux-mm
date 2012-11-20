Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 731706B0087
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 03:33:44 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 6/6] cpuacct: don't actually do anything.
Date: Tue, 20 Nov 2012 12:32:04 +0400
Message-Id: <1353400324-10897-7-git-send-email-glommer@parallels.com>
In-Reply-To: <1353400324-10897-1-git-send-email-glommer@parallels.com>
References: <1353400324-10897-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Balbir Singh <bsingharora@gmail.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.cz>, Kay Sievers <kay.sievers@vrfy.org>, Lennart Poettering <mzxreary@0pointer.de>, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>

All the information we have that is needed for cpuusage (and
cpuusage_percpu) is present in schedstats. It is already recorded
in a sane hierarchical way.

If we have CONFIG_SCHEDSTATS, we don't really need to do any extra
work. All former functions become empty inlines.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Kay Sievers <kay.sievers@vrfy.org>
Cc: Lennart Poettering <mzxreary@0pointer.de>
Cc: Dave Jones <davej@redhat.com>
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: Paul Turner <pjt@google.com>
---
 kernel/sched/core.c  | 102 ++++++++++++++++++++++++++++++++++++++++++---------
 kernel/sched/sched.h |  10 +++--
 2 files changed, 90 insertions(+), 22 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 7d85a01..13cc041 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7675,6 +7675,7 @@ void sched_move_task(struct task_struct *tsk)
 	task_rq_unlock(rq, tsk, &flags);
 }
 
+#ifndef CONFIG_SCHEDSTATS
 void task_group_charge(struct task_struct *tsk, u64 cputime)
 {
 	struct task_group *tg;
@@ -7692,6 +7693,7 @@ void task_group_charge(struct task_struct *tsk, u64 cputime)
 
 	rcu_read_unlock();
 }
+#endif
 #endif /* CONFIG_CGROUP_SCHED */
 
 #if defined(CONFIG_RT_GROUP_SCHED) || defined(CONFIG_CFS_BANDWIDTH)
@@ -8048,22 +8050,92 @@ cpu_cgroup_exit(struct cgroup *cgrp, struct cgroup *old_cgrp,
 	sched_move_task(task);
 }
 
-static u64 task_group_cpuusage_read(struct task_group *tg, int cpu)
+/*
+ * Take rq->lock to make 64-bit write safe on 32-bit platforms.
+ */
+static inline void lock_rq_dword(int cpu)
 {
-	u64 *cpuusage = per_cpu_ptr(tg->cpuusage, cpu);
-	u64 data;
-
 #ifndef CONFIG_64BIT
-	/*
-	 * Take rq->lock to make 64-bit read safe on 32-bit platforms.
-	 */
 	raw_spin_lock_irq(&cpu_rq(cpu)->lock);
-	data = *cpuusage;
+#endif
+}
+
+static inline void unlock_rq_dword(int cpu)
+{
+#ifndef CONFIG_64BIT
 	raw_spin_unlock_irq(&cpu_rq(cpu)->lock);
+#endif
+}
+
+#ifdef CONFIG_SCHEDSTATS
+#ifdef CONFIG_FAIR_GROUP_SCHED
+static inline u64 cfs_exec_clock(struct task_group *tg, int cpu)
+{
+	return tg->cfs_rq[cpu]->exec_clock - tg->cfs_rq[cpu]->prev_exec_clock;
+}
+
+static inline void cfs_exec_clock_reset(struct task_group *tg, int cpu)
+{
+	tg->cfs_rq[cpu]->prev_exec_clock = tg->cfs_rq[cpu]->exec_clock;
+}
 #else
-	data = *cpuusage;
+static inline u64 cfs_exec_clock(struct task_group *tg, int cpu)
+{
+}
+
+static inline void cfs_exec_clock_reset(struct task_group *tg, int cpu)
+{
+}
+#endif
+#ifdef CONFIG_RT_GROUP_SCHED
+static inline u64 rt_exec_clock(struct task_group *tg, int cpu)
+{
+	return tg->rt_rq[cpu]->exec_clock - tg->rt_rq[cpu]->prev_exec_clock;
+}
+
+static inline void rt_exec_clock_reset(struct task_group *tg, int cpu)
+{
+	tg->rt_rq[cpu]->prev_exec_clock = tg->rt_rq[cpu]->exec_clock;
+}
+#else
+static inline u64 rt_exec_clock(struct task_group *tg, int cpu)
+{
+	return 0;
+}
+
+static inline void rt_exec_clock_reset(struct task_group *tg, int cpu)
+{
+}
 #endif
 
+static u64 task_group_cpuusage_read(struct task_group *tg, int cpu)
+{
+	u64 ret = 0;
+
+	lock_rq_dword(cpu);
+	ret = cfs_exec_clock(tg, cpu) + rt_exec_clock(tg, cpu);
+	unlock_rq_dword(cpu);
+
+	return ret;
+}
+
+static void task_group_cpuusage_write(struct task_group *tg, int cpu, u64 val)
+{
+	lock_rq_dword(cpu);
+	cfs_exec_clock_reset(tg, cpu);
+	rt_exec_clock_reset(tg, cpu);
+	unlock_rq_dword(cpu);
+}
+#else
+static u64 task_group_cpuusage_read(struct task_group *tg, int cpu)
+{
+	u64 *cpuusage = per_cpu_ptr(tg->cpuusage, cpu);
+	u64 data;
+
+	lock_rq_dword(cpu);
+	data = *cpuusage;
+	unlock_rq_dword(cpu);
+
 	return data;
 }
 
@@ -8071,17 +8143,11 @@ static void task_group_cpuusage_write(struct task_group *tg, int cpu, u64 val)
 {
 	u64 *cpuusage = per_cpu_ptr(tg->cpuusage, cpu);
 
-#ifndef CONFIG_64BIT
-	/*
-	 * Take rq->lock to make 64-bit write safe on 32-bit platforms.
-	 */
-	raw_spin_lock_irq(&cpu_rq(cpu)->lock);
+	lock_rq_dword(cpu);
 	*cpuusage = val;
-	raw_spin_unlock_irq(&cpu_rq(cpu)->lock);
-#else
-	*cpuusage = val;
-#endif
+	unlock_rq_dword(cpu);
 }
+#endif
 
 /* return total cpu usage (in nanoseconds) of a group */
 static u64 cpucg_cpuusage_read(struct cgroup *cgrp, struct cftype *cft)
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 854d2e9..a6f3ec7 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -582,8 +582,6 @@ static inline void set_task_rq(struct task_struct *p, unsigned int cpu)
 #endif
 }
 
-extern void task_group_charge(struct task_struct *tsk, u64 cputime);
-
 #else /* CONFIG_CGROUP_SCHED */
 
 static inline void set_task_rq(struct task_struct *p, unsigned int cpu) { }
@@ -591,10 +589,14 @@ static inline struct task_group *task_group(struct task_struct *p)
 {
 	return NULL;
 }
-static inline void task_group_charge(struct task_struct *tsk, u64 cputime) { }
-
 #endif /* CONFIG_CGROUP_SCHED */
 
+#if defined(CONFIG_CGROUP_SCHED) && !defined(CONFIG_SCHEDSTATS)
+extern void task_group_charge(struct task_struct *tsk, u64 cputime);
+#else
+static inline void task_group_charge(struct task_struct *tsk, u64 cputime) {}
+#endif
+
 static inline void __set_task_cpu(struct task_struct *p, unsigned int cpu)
 {
 	set_task_rq(p, cpu);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
