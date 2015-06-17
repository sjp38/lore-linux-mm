Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id ABAB46B009C
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 08:16:47 -0400 (EDT)
Received: by oiyy130 with SMTP id y130so15492687oiy.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 05:16:47 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e15si2559693obs.97.2015.06.17.05.16.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 05:16:45 -0700 (PDT)
Subject: Re: [RFC] panic_on_oom_timeout
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150610155646.GE4501@dhcp22.suse.cz>
	<201506130022.FJF05762.LSQMOFtVFFOJOH@I-love.SAKURA.ne.jp>
	<20150615124515.GC29447@dhcp22.suse.cz>
	<201506162214.IGG12982.QOFHMOFLOJFtSV@I-love.SAKURA.ne.jp>
	<20150616134650.GC24296@dhcp22.suse.cz>
In-Reply-To: <20150616134650.GC24296@dhcp22.suse.cz>
Message-Id: <201506172116.HGF17106.JFSOFOLFtMOHVQ@I-love.SAKURA.ne.jp>
Date: Wed, 17 Jun 2015 21:16:37 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote a few minutes ago:
> Subject: [RFC -v2] panic_on_oom_timeout

Oops, we raced...

Michal Hocko wrote:
> On Tue 16-06-15 22:14:28, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > This patch implements system_memdie_panic_secs sysctl which configures
> > > > a maximum timeout for the OOM killer to resolve the OOM situation.
> > > > If the system is still under OOM (i.e. the OOM victim cannot release
> > > > memory) after the timeout expires, it will panic the system. A
> > > > reasonably chosen timeout can protect from both temporal OOM conditions
> > > > and allows to have a predictable time frame for the OOM condition.
> > > > 
> > > > Since there are memcg OOM, cpuset OOM, mempolicy OOM as with system OOM,
> > > > this patch also implements {memcg,cpuset,mempolicy}_memdie_panic_secs .
> > > 
> > > I really hate having so many knobs. What would they be good for? Why
> > > cannot you simply use a single timeout and decide whether to panic or
> > > not based on panic_on_oom value? Or do you have any strong reason to
> > > put this aside from panic_on_oom?
> > > 
> > 
> > The reason would depend on
> > 
> >  (a) whether {memcg,cpuset,mempolicy} OOM stall is possible
> >
> >  (b) what {memcg,cpuset,mempolicy} users want to do when (a) is possible
> >      and {memcg,cpuset,mempolicy} OOM stall occurred
> 
> The system as such is still usable. And an administrator might
> intervene. E.g. enlarge the memcg limit or relax the numa restrictions
> for the same purpose.
> 
> > Since memcg OOM is less critical than system OOM because administrator still
> > has chance to perform steps to resolve the OOM state, we could give longer
> > timeout (e.g. 600 seconds) for memcg OOM while giving shorter timeout (e.g.
> > 10 seconds) for system OOM. But if (a) is impossible, trying to configure
> > different timeout for non-system OOM stall makes no sense.
> 
> I still do not see any point for a separate timeouts.
> 
I think that administrator cannot configure adequate timeout if we don't allow
separate timeouts.

> Again panic_on_oom=2 sounds very dubious to me as already mentioned. The
> life would be so much easier if we simply start by supporting
> panic_on_oom=1 for now. It would be a simple timer (as we cannot use
> DELAYED_WORK) which would just panic the machine after a timeout. We

My patch recommends administrators to stop setting panic_on_oom to non-zero
value and to start setting a separate timeouts, one is for system OOM (short
timeout) and the other is for non-system OOM (long timeout).

How does my patch involve panic_on_oom ?
My patch does not care about dubious panic_on_oom=2.



> > > Besides that oom_unkillable_task doesn't sound like a good match to
> > > evaluate this logic. I would expect it to be in oom_scan_process_thread.
> > 
> > Well, select_bad_process() which calls oom_scan_process_thread() would
> > break out from the loop when encountering the first TIF_MEMDIE task.
> > We need to change
> > 
> > 	case OOM_SCAN_ABORT:
> > 		rcu_read_unlock();
> > 		return (struct task_struct *)(-1UL);
> > 
> > to defer returning of (-1UL) when a TIF_MEMDIE thread was found, in order to
> > make sure that all TIF_MEMDIE threads are examined for timeout. With that
> > change made,
> > 
> > 	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> > 		/*** this location ***/
> > 		if (!force_kill)
> > 			return OOM_SCAN_ABORT;
> > 	}
> > 
> > in oom_scan_process_thread() will be an appropriate place for evaluating
> > this logic.
> 
> You can also keep select_bad_process untouched and simply check the
> remaining TIF_MEMDIE tasks in oom_scan_process_thread (if the timeout is > 0
> of course so the most configurations will be unaffected).

The most configurations will be unaffected because there is usually no
TIF_MEMDIE thread. But if something went wrong and there were 100 TIF_MEMDIE
threads out of 10000 threads, traversing the tasklist from
oom_scan_process_thread() whenever finding a TIF_MEMDIE thread sounds
wasteful to me. If we keep traversing from select_bad_process(), the nuber
of threads to check remains 10000.

----------------------------------------
>From abc7d9dcf76ec32844d131ac6d6cf8d1c06427c2 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 17 Jun 2015 21:05:06 +0900
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

This patch implements system_oom_panic_secs sysctl which configures
a maximum timeout for the OOM killer to resolve the OOM situation.
If the system is still under OOM (i.e. the OOM victim cannot release
memory) after the timeout expires, it will panic the system. A
reasonably chosen timeout can protect from both temporal OOM conditions
and allows to have a predictable time frame for the OOM condition.

Since there are memcg OOM, mempolicy OOM as with system OOM,
this patch also implements {memcg,mempolicy}_oom_panic_secs .
These will allow administrator to use different timeout settings for
each type of OOM, for administrator still has chance to perform steps
to resolve the potential lockup or trashing from the global context
(e.g. by relaxing restrictions or even rebooting cleanly).

Note that this patch obsoletes panic_on_oom . In other words, this
patch recommends administrators to keep panic_on_oom to 0 and to set
{system,memcg,mempolicy}_oom_panic_secs to non-0.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h   |  7 ++++++
 include/linux/sched.h |  1 +
 kernel/sysctl.c       | 31 +++++++++++++++++++++++
 mm/memcontrol.c       | 13 +++++-----
 mm/oom_kill.c         | 68 ++++++++++++++++++++++++++++++++++++++++++++++++---
 5 files changed, 111 insertions(+), 9 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 7deecb7..1c7637b 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -99,4 +99,11 @@ static inline bool task_will_free_mem(struct task_struct *task)
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
+extern unsigned long sysctl_system_oom_panic_secs;
+#ifdef CONFIG_MEMCG
+extern unsigned long sysctl_memcg_oom_panic_secs;
+#endif
+#ifdef CONFIG_NUMA
+extern unsigned long sysctl_mempolicy_oom_panic_secs;
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
index c566b56..27c7c93 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -144,6 +144,9 @@ static const int cap_last_cap = CAP_LAST_CAP;
 static unsigned long hung_task_timeout_max = (LONG_MAX/HZ);
 #endif
 
+/* Used by proc_doulongvec_minmax of sysctl_*_oom_panic_secs. */
+static unsigned long wait_timeout_max = (LONG_MAX/HZ);
+
 #ifdef CONFIG_INOTIFY_USER
 #include <linux/inotify.h>
 #endif
@@ -1535,6 +1538,34 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_doulongvec_minmax,
 	},
+	{
+		.procname       = "system_oom_panic_secs",
+		.data           = &sysctl_system_oom_panic_secs,
+		.maxlen         = sizeof(sysctl_system_oom_panic_secs),
+		.mode           = 0644,
+		.proc_handler   = proc_doulongvec_minmax,
+		.extra2         = &wait_timeout_max,
+	},
+#ifdef CONFIG_MEMCG
+	{
+		.procname       = "memcg_oom_panic_secs",
+		.data           = &sysctl_memcg_oom_panic_secs,
+		.maxlen         = sizeof(sysctl_memcg_oom_panic_secs),
+		.mode           = 0644,
+		.proc_handler   = proc_doulongvec_minmax,
+		.extra2         = &wait_timeout_max,
+	},
+#endif
+#ifdef CONFIG_NUMA
+	{
+		.procname       = "mempolicy_oom_panic_secs",
+		.data           = &sysctl_mempolicy_oom_panic_secs,
+		.maxlen         = sizeof(sysctl_mempolicy_oom_panic_secs),
+		.mode           = 0644,
+		.proc_handler   = proc_doulongvec_minmax,
+		.extra2         = &wait_timeout_max,
+	},
+#endif
 	{ }
 };
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index acb93c5..b68f3a4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1550,6 +1550,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned long totalpages;
 	unsigned int points = 0;
 	struct task_struct *chosen = NULL;
+	bool memdie_pending = false;
 
 	mutex_lock(&oom_lock);
 
@@ -1583,11 +1584,8 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 			case OOM_SCAN_CONTINUE:
 				continue;
 			case OOM_SCAN_ABORT:
-				css_task_iter_end(&it);
-				mem_cgroup_iter_break(memcg, iter);
-				if (chosen)
-					put_task_struct(chosen);
-				goto unlock;
+				memdie_pending = true;
+				continue;
 			case OOM_SCAN_OK:
 				break;
 			};
@@ -1608,7 +1606,10 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		css_task_iter_end(&it);
 	}
 
-	if (chosen) {
+	if (memdie_pending) {
+		if (chosen)
+			put_task_struct(chosen);
+	} else if (chosen) {
 		points = chosen_points * 1000 / totalpages;
 		oom_kill_process(chosen, gfp_mask, order, points, totalpages,
 				 memcg, NULL, "Memory cgroup out of memory");
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dff991e..51e127c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -43,6 +43,13 @@ int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 
+unsigned long sysctl_system_oom_panic_secs;
+#ifdef CONFIG_MEMCG
+unsigned long sysctl_cgroup_oom_panic_secs;
+#endif
+#ifdef CONFIG_NUMA
+unsigned long sysctl_mempolicy_oom_panic_secs;
+#endif
 DEFINE_MUTEX(oom_lock);
 
 #ifdef CONFIG_NUMA
@@ -118,6 +125,55 @@ found:
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
+ * /proc/sys/vm/{system,memcg,mempolicy}_oom_panic_secs seconds,
+ * this function triggers kernel panic.
+ * Setting 0 to {memcg,mempolicy}_oom_panic_secs causes
+ * respective interfaces to use system_oom_panic_secs setting.
+ * Setting 0 to system_oom_panic_secs disables this check.
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
+	if (memcg)
+		timeout = sysctl_cgroup_oom_panic_secs;
+#endif
+#ifdef CONFIG_NUMA
+	if (nodemask)
+		timeout = sysctl_mempolicy_oom_panic_secs;
+#endif
+	if (!timeout)
+		timeout = sysctl_system_oom_panic_secs;
+	/* If timeout is disabled, there is nothing to do. */
+	if (!timeout)
+		return;
+	if (time_before(spent, timeout * HZ))
+		return;
+	panic("Out of memory: %s (%u) did not die within %lu seconds.\n",
+	      p->comm, p->pid, timeout);
+}
+
 /* return true if the task is not adequate as candidate victim task. */
 static bool oom_unkillable_task(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask)
@@ -135,6 +191,7 @@ static bool oom_unkillable_task(struct task_struct *p,
 	if (!has_intersects_mems_allowed(p, nodemask))
 		return true;
 
+	check_memdie_task(p, memcg, nodemask);
 	return false;
 }
 
@@ -299,6 +356,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
 	unsigned long chosen_points = 0;
+	bool memdie_pending = false;
 
 	rcu_read_lock();
 	for_each_process_thread(g, p) {
@@ -313,8 +371,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		case OOM_SCAN_CONTINUE:
 			continue;
 		case OOM_SCAN_ABORT:
-			rcu_read_unlock();
-			return (struct task_struct *)(-1UL);
+			memdie_pending = true;
+			continue;
 		case OOM_SCAN_OK:
 			break;
 		};
@@ -328,7 +386,9 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		chosen = p;
 		chosen_points = points;
 	}
-	if (chosen)
+	if (memdie_pending)
+		chosen = (struct task_struct *)(-1UL);
+	else if (chosen)
 		get_task_struct(chosen);
 	rcu_read_unlock();
 
@@ -420,6 +480,8 @@ void mark_oom_victim(struct task_struct *tsk)
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
+	/* Set current time for check_memdie_task() check. */
+	tsk->memdie_start = jiffies;
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
