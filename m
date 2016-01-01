Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8636B0007
	for <linux-mm@kvack.org>; Thu, 31 Dec 2015 21:56:31 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id 6so132460238qgy.1
        for <linux-mm@kvack.org>; Thu, 31 Dec 2015 18:56:31 -0800 (PST)
Received: from mail-qk0-x22b.google.com (mail-qk0-x22b.google.com. [2607:f8b0:400d:c09::22b])
        by mx.google.com with ESMTPS id c63si84125207qgd.93.2015.12.31.18.56.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Dec 2015 18:56:30 -0800 (PST)
Received: by mail-qk0-x22b.google.com with SMTP id q19so51681611qke.3
        for <linux-mm@kvack.org>; Thu, 31 Dec 2015 18:56:29 -0800 (PST)
Date: Thu, 31 Dec 2015 21:56:28 -0500
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v4.4-rc7] sched: move sched lock synchronized bitfields in
 task_struct into ->atomic_flags
Message-ID: <20160101025628.GA3660@htj.duckdns.org>
References: <55FEC685.5010404@oracle.com>
 <20150921200141.GH13263@mtj.duckdns.org>
 <20151125144354.GB17308@twins.programming.kicks-ass.net>
 <20151125150207.GM11639@twins.programming.kicks-ass.net>
 <CAPAsAGwa9-7UBUnhysfek3kyWKMgaUJRwtDPEqas1rKwkeTtoA@mail.gmail.com>
 <20151125174449.GD17308@twins.programming.kicks-ass.net>
 <20151211162554.GS30240@mtj.duckdns.org>
 <20151215192245.GK6357@twins.programming.kicks-ass.net>
 <20151230092337.GD3873@htj.duckdns.org>
 <CA+55aFx0WxoUPrOPaq3HxM+YUQQ0DPV-c3f8kE1ec7agERb_Lg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx0WxoUPrOPaq3HxM+YUQQ0DPV-c3f8kE1ec7agERb_Lg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Ingo Molnar <mingo@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vladimir Davydov <vdavydov@parallels.com>, kernel-team <kernel-team@fb.com>, Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>

task_struct has a cluster of unsigned bitfields.  Some are updated
under scheduler locks while others are updated only by the task
itself.  Currently, the two classes of bitfields aren't distinguished
and end up on the same word which can lead to clobbering when there
are simultaneous read-modify-write attempts.  While difficult to prove
definitely, it's likely that the resulting inconsistency led to low
frqeuency failures such as wrong memcg_may_oom state or loadavg
underflow due to clobbered sched_contributes_to_load.

Fix it by moving sched lock synchronized bitfields into
->atomic_flags.

v2: Move flags into ->atomic_flags instead of segregating bitfields.

Original-patch-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Tejun Heo <tj@kernel.org>
Link: http://lkml.kernel.org/g/55FEC685.5010404@oracle.com
Cc: stable@vger.kernel.org
---
Hello,

task_struct is pretty well packed and I couldn't find a good hole to
fit a separate integer into.  atomic_flags is a bit cumbersome but it
looks like the better option.

Thanks.

 include/linux/perf_event.h |    6 +++---
 include/linux/sched.h      |   31 ++++++++++++++++++++++++-------
 kernel/sched/core.c        |   22 +++++++++++-----------
 3 files changed, 38 insertions(+), 21 deletions(-)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index f9828a4..e5a80a4 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -921,7 +921,7 @@ perf_sw_migrate_enabled(void)
 static inline void perf_event_task_migrate(struct task_struct *task)
 {
 	if (perf_sw_migrate_enabled())
-		task->sched_migrated = 1;
+		task_set_sched_migrated(task);
 }
 
 static inline void perf_event_task_sched_in(struct task_struct *prev,
@@ -930,12 +930,12 @@ static inline void perf_event_task_sched_in(struct task_struct *prev,
 	if (static_key_false(&perf_sched_events.key))
 		__perf_event_task_sched_in(prev, task);
 
-	if (perf_sw_migrate_enabled() && task->sched_migrated) {
+	if (perf_sw_migrate_enabled() && task_sched_migrated(task)) {
 		struct pt_regs *regs = this_cpu_ptr(&__perf_regs[0]);
 
 		perf_fetch_caller_regs(regs);
 		___perf_sw_event(PERF_COUNT_SW_CPU_MIGRATIONS, 1, regs, 0);
-		task->sched_migrated = 0;
+		task_clear_sched_migrated(task);
 	}
 }
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index edad7a4..b289f47 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1455,14 +1455,9 @@ struct task_struct {
 	/* Used for emulating ABI behavior of previous Linux versions */
 	unsigned int personality;
 
-	unsigned in_execve:1;	/* Tell the LSMs that the process is doing an
-				 * execve */
+	/* unserialized, strictly 'current' */
+	unsigned in_execve:1; /* bit to tell LSMs we're in execve */
 	unsigned in_iowait:1;
-
-	/* Revert to default priority/policy when forking */
-	unsigned sched_reset_on_fork:1;
-	unsigned sched_contributes_to_load:1;
-	unsigned sched_migrated:1;
 #ifdef CONFIG_MEMCG
 	unsigned memcg_may_oom:1;
 #endif
@@ -2144,6 +2139,10 @@ static inline void memalloc_noio_restore(unsigned int flags)
 #define PFA_SPREAD_PAGE  1      /* Spread page cache over cpuset */
 #define PFA_SPREAD_SLAB  2      /* Spread some slab caches over cpuset */
 
+#define PFA_SCHED_RESET_ON_FORK		3 /* revert priority/policy on fork */
+#define PFA_SCHED_CONTRIBUTES_TO_LOAD	4
+#define PFA_SCHED_MIGRATED		5
+
 
 #define TASK_PFA_TEST(name, func)					\
 	static inline bool task_##func(struct task_struct *p)		\
@@ -2154,6 +2153,10 @@ static inline void memalloc_noio_restore(unsigned int flags)
 #define TASK_PFA_CLEAR(name, func)					\
 	static inline void task_clear_##func(struct task_struct *p)	\
 	{ clear_bit(PFA_##name, &p->atomic_flags); }
+#define TASK_PFA_UPDATE(name, func)					\
+	static inline void task_update_##func(struct task_struct *p, bool v) \
+	{ if (v) set_bit(PFA_##name, &p->atomic_flags);			\
+	  else clear_bit(PFA_##name, &p->atomic_flags); }
 
 TASK_PFA_TEST(NO_NEW_PRIVS, no_new_privs)
 TASK_PFA_SET(NO_NEW_PRIVS, no_new_privs)
@@ -2166,6 +2169,20 @@ TASK_PFA_TEST(SPREAD_SLAB, spread_slab)
 TASK_PFA_SET(SPREAD_SLAB, spread_slab)
 TASK_PFA_CLEAR(SPREAD_SLAB, spread_slab)
 
+TASK_PFA_TEST(SCHED_RESET_ON_FORK, sched_reset_on_fork);
+TASK_PFA_SET(SCHED_RESET_ON_FORK, sched_reset_on_fork);
+TASK_PFA_CLEAR(SCHED_RESET_ON_FORK, sched_reset_on_fork);
+TASK_PFA_UPDATE(SCHED_RESET_ON_FORK, sched_reset_on_fork);
+
+TASK_PFA_TEST(SCHED_CONTRIBUTES_TO_LOAD, sched_contributes_to_load);
+TASK_PFA_SET(SCHED_CONTRIBUTES_TO_LOAD, sched_contributes_to_load);
+TASK_PFA_CLEAR(SCHED_CONTRIBUTES_TO_LOAD, sched_contributes_to_load);
+TASK_PFA_UPDATE(SCHED_CONTRIBUTES_TO_LOAD, sched_contributes_to_load);
+
+TASK_PFA_TEST(SCHED_MIGRATED, sched_migrated);
+TASK_PFA_SET(SCHED_MIGRATED, sched_migrated);
+TASK_PFA_CLEAR(SCHED_MIGRATED, sched_migrated);
+
 /*
  * task->jobctl flags
  */
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 732e993..c5a6a8c 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1751,7 +1751,7 @@ ttwu_do_activate(struct rq *rq, struct task_struct *p, int wake_flags)
 	lockdep_assert_held(&rq->lock);
 
 #ifdef CONFIG_SMP
-	if (p->sched_contributes_to_load)
+	if (task_sched_contributes_to_load(p))
 		rq->nr_uninterruptible--;
 #endif
 
@@ -1982,7 +1982,7 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
 	 */
 	smp_rmb();
 
-	p->sched_contributes_to_load = !!task_contributes_to_load(p);
+	task_update_sched_contributes_to_load(p, task_contributes_to_load(p));
 	p->state = TASK_WAKING;
 
 	if (p->sched_class->task_waking)
@@ -2205,7 +2205,7 @@ int sched_fork(unsigned long clone_flags, struct task_struct *p)
 	/*
 	 * Revert to default priority/policy on fork if requested.
 	 */
-	if (unlikely(p->sched_reset_on_fork)) {
+	if (unlikely(task_sched_reset_on_fork(p))) {
 		if (task_has_dl_policy(p) || task_has_rt_policy(p)) {
 			p->policy = SCHED_NORMAL;
 			p->static_prio = NICE_TO_PRIO(0);
@@ -2220,7 +2220,7 @@ int sched_fork(unsigned long clone_flags, struct task_struct *p)
 		 * We don't need the reset flag anymore after the fork. It has
 		 * fulfilled its duty:
 		 */
-		p->sched_reset_on_fork = 0;
+		task_clear_sched_reset_on_fork(p);
 	}
 
 	if (dl_prio(p->prio)) {
@@ -3799,7 +3799,7 @@ static int __sched_setscheduler(struct task_struct *p,
 recheck:
 	/* double check policy once rq lock held */
 	if (policy < 0) {
-		reset_on_fork = p->sched_reset_on_fork;
+		reset_on_fork = task_sched_reset_on_fork(p);
 		policy = oldpolicy = p->policy;
 	} else {
 		reset_on_fork = !!(attr->sched_flags & SCHED_FLAG_RESET_ON_FORK);
@@ -3870,7 +3870,7 @@ static int __sched_setscheduler(struct task_struct *p,
 			return -EPERM;
 
 		/* Normal users shall not reset the sched_reset_on_fork flag */
-		if (p->sched_reset_on_fork && !reset_on_fork)
+		if (task_sched_reset_on_fork(p) && !reset_on_fork)
 			return -EPERM;
 	}
 
@@ -3909,7 +3909,7 @@ static int __sched_setscheduler(struct task_struct *p,
 		if (dl_policy(policy) && dl_param_changed(p, attr))
 			goto change;
 
-		p->sched_reset_on_fork = reset_on_fork;
+		task_update_sched_reset_on_fork(p, reset_on_fork);
 		task_rq_unlock(rq, p, &flags);
 		return 0;
 	}
@@ -3963,7 +3963,7 @@ static int __sched_setscheduler(struct task_struct *p,
 		return -EBUSY;
 	}
 
-	p->sched_reset_on_fork = reset_on_fork;
+	task_update_sched_reset_on_fork(p, reset_on_fork);
 	oldprio = p->prio;
 
 	if (pi) {
@@ -4260,8 +4260,8 @@ SYSCALL_DEFINE1(sched_getscheduler, pid_t, pid)
 	if (p) {
 		retval = security_task_getscheduler(p);
 		if (!retval)
-			retval = p->policy
-				| (p->sched_reset_on_fork ? SCHED_RESET_ON_FORK : 0);
+			retval = p->policy | (task_sched_reset_on_fork(p) ?
+					      SCHED_RESET_ON_FORK : 0);
 	}
 	rcu_read_unlock();
 	return retval;
@@ -4377,7 +4377,7 @@ SYSCALL_DEFINE4(sched_getattr, pid_t, pid, struct sched_attr __user *, uattr,
 		goto out_unlock;
 
 	attr.sched_policy = p->policy;
-	if (p->sched_reset_on_fork)
+	if (task_sched_reset_on_fork(p))
 		attr.sched_flags |= SCHED_FLAG_RESET_ON_FORK;
 	if (task_has_dl_policy(p))
 		__getparam_dl(p, &attr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
