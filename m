Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C73556B0038
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 11:23:06 -0400 (EDT)
Received: by padev16 with SMTP id ev16so24912216pad.0
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 08:23:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id mt2si5758959pbb.42.2015.06.12.08.23.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jun 2015 08:23:05 -0700 (PDT)
Subject: Re: [RFC] panic_on_oom_timeout
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150609170310.GA8990@dhcp22.suse.cz>
	<201506102120.FEC87595.OQSJLOVtMFOHFF@I-love.SAKURA.ne.jp>
	<20150610142801.GD4501@dhcp22.suse.cz>
	<20150610155646.GE4501@dhcp22.suse.cz>
In-Reply-To: <20150610155646.GE4501@dhcp22.suse.cz>
Message-Id: <201506130022.FJF05762.LSQMOFtVFFOJOH@I-love.SAKURA.ne.jp>
Date: Sat, 13 Jun 2015 00:23:00 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > Since my version uses per a "struct task_struct" variable (memdie_start),
> > 5 seconds of timeout is checked for individual memory cgroup. It can avoid
> > unnecessary panic() calls if nobody needs to call out_of_memory() again
> > (probably because somebody volunteered memory) when the OOM victim cannot
> > be terminated for some reason. If we want distinction between "the entire
> > system is under OOM" and "some memory cgroup is under OOM" because the
> > former is urgent but the latter is less urgent, it can be modified to
> > allow different timeout period for system-wide OOM and cgroup OOM.
> > Finally, it can give a hint for "in what sequence threads got stuck" and
> > "which thread did take 5 seconds" when analyzing vmcore.
> 
> I will have a look how you have implemented that but separate timeouts
> sound like a major over engineering. Also note that global vs. memcg OOM
> is not sufficient because there are other oom domains as mentioned above.

We also need to consider mempolicy and cpusets, right? I'm unfamiliar with
NUMA systems, but I guess that mempolicy OOM is a situation where "some
memory node is under OOM" and cpusets OOM is a situation where "memory
cannot be reclaimed/allocated without borrowing cpus outside of the given
cpusets".

Michal Hocko wrote:
> Your patch is doing way too many things at once :/ So let me just focus
> on the "panic if a task is stuck with TIF_MEMDIE for too long". It looks
> like an alternative to the approach I've chosen. It doesn't consider
> the allocation restriction so a locked up cpuset/numa node(s) might
> panic the system which doesn't sound like a good idea but that is easily
> fixable. Could you tear just this part out and repost it so that we can
> compare the two approaches?

Sure. Here is a "tear just this part out" version. I think that most
administrators will no longer need to use panic_on_oom > 0 by setting
adequate values to these timeouts.
------------------------------------------------------------
>From e59b64683827151a35257384352c70bce61babdd Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 12 Jun 2015 23:56:18 +0900
Subject: [RFC] oom: implement memdie_task_panic_secs

OOM killer is a desperate last resort reclaim attempt to free some
memory. It is based on heuristics which will never be 100% and may
result in an unusable or a locked up system.

panic_on_oom sysctl knob allows to set the OOM policy to panic the
system instead of trying to resolve the OOM condition. This might be
useful for several reasons - e.g. reduce the downtime to a predictable
amount of time, allow to get a crash dump of the system and debug the
issue post-mortem.

panic_on_oom is, however, a big hammer in many situations when the
OOM condition could be resolved in a reasonable time. So it would be
good to have some middle ground and allow the OOM killer to do its job
but have a failover when things go wrong and it is not able to make any
further progress for a considerable amount of time.

This patch implements system_memdie_panic_secs sysctl which configures
a maximum timeout for the OOM killer to resolve the OOM situation.
If the system is still under OOM (i.e. the OOM victim cannot release
memory) after the timeout expires, it will panic the system. A
reasonably chosen timeout can protect from both temporal OOM conditions
and allows to have a predictable time frame for the OOM condition.

Since there are memcg OOM, cpuset OOM, mempolicy OOM as with system OOM,
this patch also implements {memcg,cpuset,mempolicy}_memdie_panic_secs .
These will allow administrator to use different timeout settings for
each type of OOM, for administrator still has chance to perform steps
to resolve the potential lockup or trashing from the global context
(e.g. by relaxing restrictions or even rebooting cleanly).

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h   |  8 +++++
 include/linux/sched.h |  1 +
 kernel/sysctl.c       | 39 ++++++++++++++++++++++++
 mm/oom_kill.c         | 83 +++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 131 insertions(+)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 7deecb7..f69e0dd 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -99,4 +99,12 @@ static inline bool task_will_free_mem(struct task_struct *task)
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
+extern unsigned long sysctl_system_memdie_panic_secs;
+#ifdef CONFIG_MEMCG
+extern unsigned long sysctl_memcg_memdie_panic_secs;
+#endif
+#ifdef CONFIG_NUMA
+extern unsigned long sysctl_cpuset_memdie_panic_secs;
+extern unsigned long sysctl_mempolicy_memdie_panic_secs;
+#endif
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index d505bca..333bb3a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1784,6 +1784,7 @@ struct task_struct {
 	unsigned long	task_state_change;
 #endif
 	int pagefault_disabled;
+	unsigned long memdie_start;
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c566b56..0c5261f 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -144,6 +144,9 @@ static const int cap_last_cap = CAP_LAST_CAP;
 static unsigned long hung_task_timeout_max = (LONG_MAX/HZ);
 #endif
 
+/* Used by proc_doulongvec_minmax of sysctl_*_memdie_panic_secs. */
+static unsigned long wait_timeout_max = (LONG_MAX/HZ);
+
 #ifdef CONFIG_INOTIFY_USER
 #include <linux/inotify.h>
 #endif
@@ -1535,6 +1538,42 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_doulongvec_minmax,
 	},
+	{
+		.procname       = "system_memdie_panic_secs",
+		.data           = &sysctl_system_memdie_panic_secs,
+		.maxlen         = sizeof(sysctl_system_memdie_panic_secs),
+		.mode           = 0644,
+		.proc_handler   = proc_doulongvec_minmax,
+		.extra2         = &wait_timeout_max,
+	},
+#ifdef CONFIG_MEMCG
+	{
+		.procname       = "memcg_memdie_panic_secs",
+		.data           = &sysctl_memcg_memdie_panic_secs,
+		.maxlen         = sizeof(sysctl_memcg_memdie_panic_secs),
+		.mode           = 0644,
+		.proc_handler   = proc_doulongvec_minmax,
+		.extra2         = &wait_timeout_max,
+	},
+#endif
+#ifdef CONFIG_NUMA
+	{
+		.procname       = "cpuset_memdie_panic_secs",
+		.data           = &sysctl_cpuset_memdie_panic_secs,
+		.maxlen         = sizeof(sysctl_cpuset_memdie_panic_secs),
+		.mode           = 0644,
+		.proc_handler   = proc_doulongvec_minmax,
+		.extra2         = &wait_timeout_max,
+	},
+	{
+		.procname       = "mempolicy_memdie_panic_secs",
+		.data           = &sysctl_mempolicy_memdie_panic_secs,
+		.maxlen         = sizeof(sysctl_mempolicy_memdie_panic_secs),
+		.mode           = 0644,
+		.proc_handler   = proc_doulongvec_minmax,
+		.extra2         = &wait_timeout_max,
+	},
+#endif
 	{ }
 };
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dff991e..40d7b6d0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -43,6 +43,14 @@ int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 
+unsigned long sysctl_system_memdie_panic_secs;
+#ifdef CONFIG_MEMCG
+unsigned long sysctl_cgroup_memdie_panic_secs;
+#endif
+#ifdef CONFIG_NUMA
+unsigned long sysctl_cpuset_memdie_panic_secs;
+unsigned long sysctl_mempolicy_memdie_panic_secs;
+#endif
 DEFINE_MUTEX(oom_lock);
 
 #ifdef CONFIG_NUMA
@@ -118,6 +126,72 @@ found:
 	return t;
 }
 
+/**
+ * check_memdie_task - check task is not stuck with TIF_MEMDIE flag set.
+ *
+ * @p:        Pointer to "struct task_struct".
+ * @memcg:    Pointer to "struct mem_cgroup". Maybe NULL.
+ * @nodemask: Pointer to "nodemask_t". Maybe NULL.
+ *
+ * Setting TIF_MEMDIE flag to @p disables the OOM killer. However, @p could get
+ * stuck due to dependency which is invisible to the OOM killer. When @p got
+ * stuck, the system will stall for unpredictable duration (presumably forever)
+ * because the OOM killer is kept disabled.
+ *
+ * If @p remained stuck for
+ * /proc/sys/vm/{system,memcg,cpuset,mempolicy}_memdie_panic_secs seconds,
+ * this function triggers kernel panic.
+ * Setting 0 to {memcg,cpuset,mempolicy}_memdie_panic_secs causes
+ * respective interfaces to use system_memdie_panic_secs setting.
+ * Setting 0 to system_memdie_panic_secs disables this check.
+ */
+static void check_memdie_task(struct task_struct *p, struct mem_cgroup *memcg,
+			      const nodemask_t *nodemask)
+{
+	unsigned long start = p->memdie_start;
+	unsigned long spent;
+	unsigned long timeout = 0;
+
+	/* If task does not have TIF_MEMDIE flag, there is nothing to do. */
+	if (!start)
+		return;
+	spent = jiffies - start;
+#ifdef CONFIG_MEMCG
+	/* task_in_mem_cgroup(p, memcg) is true. */
+	if (memcg)
+		timeout = sysctl_cgroup_memdie_panic_secs;
+#endif
+#ifdef CONFIG_NUMA
+	/* has_intersects_mems_allowed(p, nodemask) is true. */
+	else if (nodemask)
+		timeout = sysctl_mempolicy_memdie_panic_secs;
+	else
+		timeout = sysctl_cpuset_memdie_panic_secs;
+#endif
+	if (!timeout)
+		timeout = sysctl_system_memdie_panic_secs;
+	/* If timeout is disabled, there is nothing to do. */
+	if (!timeout)
+		return;
+#ifdef CONFIG_NUMA
+	{
+		struct task_struct *t;
+
+		rcu_read_lock();
+		for_each_thread(p, t) {
+			start = t->memdie_start;
+			if (start && time_after(spent, timeout * HZ))
+				break;
+		}
+		rcu_read_unlock();
+	}
+#endif
+	if (time_before(spent, timeout * HZ))
+		return;
+	panic("Out of memory: %s (%u) did not die within %lu seconds.\n",
+	      p->comm, p->pid, timeout);
+}
+
 /* return true if the task is not adequate as candidate victim task. */
 static bool oom_unkillable_task(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask)
@@ -135,6 +209,7 @@ static bool oom_unkillable_task(struct task_struct *p,
 	if (!has_intersects_mems_allowed(p, nodemask))
 		return true;
 
+	check_memdie_task(p, memcg, nodemask);
 	return false;
 }
 
@@ -416,10 +491,17 @@ bool oom_killer_disabled __read_mostly;
  */
 void mark_oom_victim(struct task_struct *tsk)
 {
+	unsigned long start;
+
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
+	/* Set current time for is_killable_memdie_task() check. */
+	start = jiffies;
+	if (!start)
+		start = 1;
+	tsk->memdie_start = start;
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -435,6 +517,7 @@ void mark_oom_victim(struct task_struct *tsk)
  */
 void exit_oom_victim(void)
 {
+	current->memdie_start = 0;
 	clear_thread_flag(TIF_MEMDIE);
 
 	if (!atomic_dec_return(&oom_victims))
-- 
1.8.3.1
------------------------------------------------------------

By the way, with introduction of per "struct task_struct" variable, I think
that we can replace TIF_MEMDIE checks with memdie_start checks via

  test_tsk_thread_flag(p, TIF_MEMDIE) => p->memdie_start

  test_and_clear_thread_flag(TIF_MEMDIE) => xchg(&current->memdie_start, 0)

  test_and_set_tsk_thread_flag(p, TIF_MEMDIE)
  => xchg(&p->memdie_start, jiffies (or 1 if jiffies == 0))

though above patch did not replace TIF_MEMDIE in order to focus on one thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
