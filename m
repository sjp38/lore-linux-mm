Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 655D06B026C
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 06:37:40 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id zy2so58557207pac.1
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 03:37:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 124si17311447pfd.109.2016.04.20.03.37.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Apr 2016 03:37:39 -0700 (PDT)
Subject: [PATCH v2] mm,oom: Re-enable OOM killer using timeout.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201604200006.FBG45192.SOHFQJFOOLFMtV@I-love.SAKURA.ne.jp>
	<20160419200752.GA10437@dhcp22.suse.cz>
	<201604200655.HDH86486.HOStQFJFLOMFOV@I-love.SAKURA.ne.jp>
In-Reply-To: <201604200655.HDH86486.HOStQFJFLOMFOV@I-love.SAKURA.ne.jp>
Message-Id: <201604201937.AGB86467.MOFFOOQJVFHLtS@I-love.SAKURA.ne.jp>
Date: Wed, 20 Apr 2016 19:37:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > This patch adds a timeout for handling corner cases where a TIF_MEMDIE
> > > thread got stuck. Since the timeout is checked at oom_unkillable_task(),
> > > oom_scan_process_thread() will not find TIF_MEMDIE thread
> > > (for !oom_kill_allocating_task case) and oom_badness() will return 0
> > > (for oom_kill_allocating_task case).
> > >
> > > By applying this patch, the kernel will automatically press SysRq-f if
> > > the OOM reaper cannot reap the victim's memory, and we will never OOM
> > > livelock forever as long as the OOM killer is called.
> >
> > Which will not guarantee anything as already pointed out several times
> > before. So I think this is not really that useful. I have said it
> > earlier and will repeat it again. Any timeout based solution which
> > doesn't guarantee that the system will be in a consistent state (reboot,
> > panic or kill all existing tasks) after the specified timeout is
> > pointless.
>
> Triggering the reboot/panic is the worst action. Killing all existing tasks
> is the next worst action. Thus, I prefer killing tasks one by one.
>
> I'm OK with shortening the timeout like N (when waiting for the 1st victim)
> + N/2 (the 2nd victim) + N/4 (the 3rd victim) + N/8 (the 4th victim) + ...
> but does it worth complicating the least unlikely path?

Well, (N / (1 << atomic_read(&oom_victims))) is not accurate.
Having another timeout is simpler.

>
> >
> > I believe that the chances of the lockup are much less likely with the
> > oom reaper and that we are not really urged to provide a new knob with a
> > random semantic. If we really want to have a timeout based thing better
> > make it behave reliably.
>
> The threshold which the administrator can wait for ranges. Some may want to
> set few seconds because of 10 seconds /dev/watchdog timeout, others may want
> to set one minute because of not using watchdog. Thus, I think we should not
> hard code the timeout.

Well, I already tried to propose it using two timeouts (one for selecting next
victim, the other for triggering kernel panic) at
http://lkml.kernel.org/r/201505232339.DAB00557.VFFLHMSOJFOOtQ@I-love.SAKURA.ne.jp .

I thought I can apply these timeouts for per a signal_struct basis than
per a task_struct basis because you proposed changing task_will_free_mem()
to guarantee the whole thread group is going down. But it turned out that
since signal_struct has wider scope than OOM livelock check (i.e.
signal_struct remains even after TASK_DEAD while OOM livelock check must
stop at as of clearing TIF_MEMDIE), we need to apply these timestamps only
if one of threads has TIF_MEMDIE. This is needed for not requiring
find_lock_non_victim_task_mm() proposed at
http://lkml.kernel.org/r/201602171929.IFG12927.OVFJOQHOSMtFFL@I-love.SAKURA.ne.jp .

----------------------------------------
>From f3da6c8e98365e59226500142fcc3855f336d61f Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 20 Apr 2016 12:57:37 +0900
Subject: [PATCH v2] mm,oom: Re-enable OOM killer using timeout.

We are trying to reduce the possibility of hitting OOM livelock by
introducing the OOM reaper. But the OOM reaper cannot reap the victim's
memory if the victim's mmap_sem is held for write. It is possible that
the thread which got TIF_MEMDIE while holding mmap_sem for write gets
stuck at unkillable wait waiting for other thread's memory allocation.
This problem cannot be avoided even after we convert
down_write(&mm->mmap_sem) to down_write_killable(&mm->mmap_sem).
Since we cannot afford converting all waits killable, we should prepare
for such situation.

The simplest way is to mark the victim's thread group as no longer
OOM-killable by updating victim's signal->oom_score_adj to
OOM_SCORE_ADJ_MIN at oom_kill_process().

But doing so is not sufficient for !oom_kill_allocating_task case
because oom_scan_process_thread() will find TIF_MEMDIE thread and
continue waiting. We will need to revoke TIF_MEMDIE from all victim
threads but TIF_MEMDIE will be automatically granted to potentially all
victim threads due to fatal_signal_pending() or task_will_free_mem() in
out_of_memory(). We don't want to walk the process list so many times
in order to revoke TIF_MEMDIE from all victim threads from racy loop.

Also, doing so breaks oom_kill_allocating_task case because we will not
wait for existing TIF_MEMDIE threads because oom_scan_process_thread()
is not called. As a result, all children of the calling process will be
needlessly OOM-killed if existing TIF_MEMDIE threads fail to terminate
immediately.

Therefore, we should not play with victim's signal->oom_score_adj value
and/or victim's TIF_MEMDIE flag.

This patch adds two timeouts for handling corner cases where a TIF_MEMDIE
thread got stuck. One for selecting next OOM victim and the other for
triggering kernel panic. Since these timeouts are checked at
oom_unkillable_task(), oom_scan_process_thread() will not find TIF_MEMDIE
thread (for !oom_kill_allocating_task case) and oom_badness() will return
0 (for oom_kill_allocating_task case) when the timeout for selecting next
OOM victim expired.

By applying this patch, the kernel will automatically press SysRq-f or
trigger kernel panic if the OOM reaper cannot reap the victim's memory,
and we will never OOM livelock forever as long as the OOM killer is
called. An example of panic on 10 seconds timeout (taken with the OOM
reaper disabled for demonstration) is shown below.

----------
[   75.736534] Out of memory: Kill process 1241 (oom-write) score 851 or sacrifice child
[   75.740947] Killed process 1250 (write) total-vm:156kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
[   85.741009] write           D ffff88003b493cb8     0  1250   1241 0x20120084
[   85.745823]  ffff88003b493cb8 ffff88003fb88040 ffff88003aeb0000 ffff88003b494000
[   85.750348]  ffff880038736548 0000000000000246 ffff88003aeb0000 00000000ffffffff
[   85.754851]  ffff88003b493cd0 ffffffff81667f30 ffff880038736540 ffff88003b493ce0
[   85.759346] Call Trace:
[   85.761274]  [<ffffffff81667f30>] schedule+0x30/0x80
[   85.764546]  [<ffffffff81668239>] schedule_preempt_disabled+0x9/0x10
[   85.768375]  [<ffffffff81669def>] mutex_lock_nested+0x14f/0x3a0
[   85.771986]  [<ffffffffa0240e1f>] ? xfs_file_buffered_aio_write+0x5f/0x1f0 [xfs]
[   85.776421]  [<ffffffffa0240e1f>] xfs_file_buffered_aio_write+0x5f/0x1f0 [xfs]
[   85.780679]  [<ffffffffa024103a>] xfs_file_write_iter+0x8a/0x150 [xfs]
[   85.784627]  [<ffffffff811c37b7>] __vfs_write+0xc7/0x100
[   85.787923]  [<ffffffff811c442d>] vfs_write+0x9d/0x190
[   85.791169]  [<ffffffff811e3dca>] ? __fget_light+0x6a/0x90
[   85.794577]  [<ffffffff811c5893>] SyS_write+0x53/0xd0
[   85.797721]  [<ffffffff810037b4>] do_int80_syscall_32+0x64/0x190
[   85.801378]  [<ffffffff8166ef3b>] entry_INT80_compat+0x3b/0x50
[   85.804933] Kernel panic - not syncing: Out of memory and 1250 (write) can not die...
----------

For those who prefer existing behavior (i.e. let the kernel OOM livelock
forever if the OOM reaper cannot reap the victim's memory), these timeouts
are set to very large value (effectively no timeout) by default.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h   |  2 ++
 include/linux/sched.h |  2 ++
 kernel/sysctl.c       | 21 +++++++++++++++++++++
 mm/oom_kill.c         | 49 ++++++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 73 insertions(+), 1 deletion(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index abaab8e..7fcb586 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -112,4 +112,6 @@ static inline bool task_will_free_mem(struct task_struct *task)
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
+extern unsigned long sysctl_oom_victim_skip_secs;
+extern unsigned long sysctl_oom_victim_panic_secs;
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index d8f366c..e6cb766 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -790,6 +790,8 @@ struct signal_struct {
 	short oom_score_adj;		/* OOM kill score adjustment */
 	short oom_score_adj_min;	/* OOM kill score adjustment min value.
 					 * Only settable by CAP_SYS_RESOURCE. */
+	/* If not 0, timestamp of getting TIF_MEMDIE for the first time. */
+	unsigned long oom_start;
 
 	struct mutex cred_guard_mutex;	/* guard against foreign influences on
 					 * credential calculations
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d11c22d..bdd8a78 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -147,6 +147,9 @@ static const int cap_last_cap = CAP_LAST_CAP;
 static unsigned long hung_task_timeout_max = (LONG_MAX/HZ);
 #endif
 
+static unsigned long oom_victim_wait_timeout_min = 1;
+static unsigned long oom_victim_wait_timeout_max = (LONG_MAX / HZ);
+
 #ifdef CONFIG_INOTIFY_USER
 #include <linux/inotify.h>
 #endif
@@ -1222,6 +1225,24 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "oom_victim_skip_secs",
+		.data		= &sysctl_oom_victim_skip_secs,
+		.maxlen		= sizeof(sysctl_oom_victim_skip_secs),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+		.extra1         = &oom_victim_wait_timeout_min,
+		.extra2         = &oom_victim_wait_timeout_max,
+	},
+	{
+		.procname	= "oom_victim_panic_secs",
+		.data		= &sysctl_oom_victim_panic_secs,
+		.maxlen		= sizeof(sysctl_oom_victim_panic_secs),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+		.extra1         = &oom_victim_wait_timeout_min,
+		.extra2         = &oom_victim_wait_timeout_max,
+	},
+	{
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
 		.maxlen		= sizeof(sysctl_overcommit_ratio),
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7098104..1a4f54f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -47,6 +47,8 @@
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
+unsigned long sysctl_oom_victim_skip_secs = (LONG_MAX / HZ);
+unsigned long sysctl_oom_victim_panic_secs = (LONG_MAX / HZ);
 
 DEFINE_MUTEX(oom_lock);
 
@@ -132,6 +134,34 @@ static inline bool is_sysrq_oom(struct oom_control *oc)
 	return oc->order == -1;
 }
 
+static bool is_killable_memdie_task(struct task_struct *p)
+{
+	const unsigned long oom_start = p->signal->oom_start;
+	struct task_struct *t;
+	bool memdie_pending = false;
+
+	if (!oom_start)
+		return false;
+	rcu_read_lock();
+	for_each_thread(p, t) {
+		if (!test_tsk_thread_flag(t, TIF_MEMDIE))
+			continue;
+		memdie_pending = true;
+		break;
+	}
+	rcu_read_unlock();
+	if (!memdie_pending)
+		return false;
+	if (time_after(jiffies, oom_start +
+		       sysctl_oom_victim_panic_secs * HZ)) {
+		sched_show_task(p);
+		panic("Out of memory and %u (%s) can not die...\n",
+		      p->pid, p->comm);
+	}
+	return time_after(jiffies, oom_start +
+			  sysctl_oom_victim_skip_secs * HZ);
+}
+
 /* return true if the task is not adequate as candidate victim task. */
 static bool oom_unkillable_task(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask)
@@ -149,7 +179,8 @@ static bool oom_unkillable_task(struct task_struct *p,
 	if (!has_intersects_mems_allowed(p, nodemask))
 		return true;
 
-	return false;
+	/* Already OOM-killed p might get stuck at unkillable wait */
+	return is_killable_memdie_task(p);
 }
 
 /**
@@ -668,6 +699,22 @@ void mark_oom_victim(struct task_struct *tsk)
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
 	/*
+	 * The task might get stuck at unkillable wait with mmap_sem held for
+	 * write. In that case, even the OOM reaper will not help. Therefore,
+	 * record timestamp of setting TIF_MEMDIE for the first time of this
+	 * thread group, and check the timestamp at oom_unkillable_task().
+	 * If we record timestamp of setting TIF_MEMDIE for the first time of
+	 * this task, find_lock_task_mm() will select this task forever and
+	 * the OOM killer will wait for this thread group forever.
+	 */
+	if (!tsk->signal->oom_start) {
+		unsigned long oom_start = jiffies;
+
+		if (!oom_start)
+			oom_start = 1;
+		tsk->signal->oom_start = oom_start;
+	}
+	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
 	 * any memory and livelock. freezing_slow_path will tell the freezer
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
