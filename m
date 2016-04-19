Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C5F916B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 11:06:18 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id js7so38481193obc.0
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 08:06:18 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m5si5147077igr.50.2016.04.19.08.06.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Apr 2016 08:06:17 -0700 (PDT)
Subject: [PATCH] mm,oom: Re-enable OOM killer using timeout.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201604200006.FBG45192.SOHFQJFOOLFMtV@I-love.SAKURA.ne.jp>
Date: Wed, 20 Apr 2016 00:06:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

>From dbe7dcb4ff757d5b1865e935f840d0418af804d3 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 19 Apr 2016 23:11:31 +0900
Subject: [PATCH] mm,oom: Re-enable OOM killer using timeout.

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
OOM_SCORE_ADJ_MIN.

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
needlessly OOM-killed.

Therefore, we should not play with victim's signal->oom_score_adj value
and/or victim's TIF_MEMDIE flag.

This patch adds a timeout for handling corner cases where a TIF_MEMDIE
thread got stuck. Since the timeout is checked at oom_unkillable_task(),
oom_scan_process_thread() will not find TIF_MEMDIE thread
(for !oom_kill_allocating_task case) and oom_badness() will return 0
(for oom_kill_allocating_task case).

By applying this patch, the kernel will automatically press SysRq-f if
the OOM reaper cannot reap the victim's memory, and we will never OOM
livelock forever as long as the OOM killer is called.

For those who prefer existing behavior (i.e. let the kernel OOM livelock
forever if the OOM reaper cannot reap the victim's memory), the timeout
is set to very large value (effectively no timeout) by default.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h   |  2 ++
 include/linux/sched.h |  1 +
 kernel/sysctl.c       | 12 ++++++++++++
 mm/oom_kill.c         | 18 ++++++++++++++++++
 4 files changed, 33 insertions(+)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index abaab8e..4d2a97e 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -112,4 +112,6 @@ static inline bool task_will_free_mem(struct task_struct *task)
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
+extern unsigned long sysctl_oom_victim_wait_timeout;
+
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index d8f366c..6e701b3 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -790,6 +790,7 @@ struct signal_struct {
 	short oom_score_adj;		/* OOM kill score adjustment */
 	short oom_score_adj_min;	/* OOM kill score adjustment min value.
 					 * Only settable by CAP_SYS_RESOURCE. */
+	unsigned long oom_start; /* If not 0, timestamp of being OOM-killed. */
 
 	struct mutex cred_guard_mutex;	/* guard against foreign influences on
 					 * credential calculations
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d11c22d..3092ec2 100644
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
@@ -1222,6 +1225,15 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "oom_victim_wait_timeout",
+		.data		= &sysctl_oom_victim_wait_timeout,
+		.maxlen		= sizeof(sysctl_oom_victim_wait_timeout),
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
index 7098104..a2e1543a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -47,6 +47,7 @@
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
+unsigned long sysctl_oom_victim_wait_timeout = (LONG_MAX / HZ);
 
 DEFINE_MUTEX(oom_lock);
 
@@ -149,6 +150,12 @@ static bool oom_unkillable_task(struct task_struct *p,
 	if (!has_intersects_mems_allowed(p, nodemask))
 		return true;
 
+	/* Already OOM-killed p might get stuck at unkillable wait */
+	if (p->signal->oom_start &&
+	    time_after(jiffies, p->signal->oom_start
+		       + sysctl_oom_victim_wait_timeout * HZ))
+		return true;
+
 	return false;
 }
 
@@ -668,6 +675,17 @@ void mark_oom_victim(struct task_struct *tsk)
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
 	/*
+	 * The task might get stuck at unkillable wait with mmap_sem held for
+	 * write. In that case, even the OOM reaper will not help.
+	 */
+	if (!tsk->signal->oom_start) {
+		unsigned long oom_start = jiffies;
+
+		if (!oom_start)
+			oom_start--;
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
