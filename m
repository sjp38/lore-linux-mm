Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id B573B6B027F
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 02:00:15 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id 78so123041393pfw.2
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 23:00:15 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id rw4si3058325pac.72.2015.12.28.23.00.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Dec 2015 23:00:14 -0800 (PST)
Subject: [PATCH] mm,oom: Use hold off timer after invoking the OOM killer.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201512291559.HGA46749.VFOFSOHLMtFJQO@I-love.SAKURA.ne.jp>
Date: Tue, 29 Dec 2015 15:59:58 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>From 749b861430cca1cb5a1cd7df9bd79a475b2515eb Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 29 Dec 2015 15:52:41 +0900
Subject: [PATCH] mm,oom: Use hold off timer after invoking the OOM killer.

When many hundreds of tasks running on one CPU are trying to invoke the
OOM killer, schedule_timeout_killable(1) after oom_kill_process() at
out_of_memory() can sleep for many minutes. Since the oom_lock mutex is
kept held during that period, nobody is able to call out_of_memory() again
(effectively, the OOM killer is kept disabled) because everybody assume
that the process which held the oom_lock mutex is making progress for us.
We allow SIGKILL pending but !TIF_MEMDIE tasks (possibly tasks sharing OOM
victim's mm) to use ALLOC_NO_WATERMARKS by calling mark_oom_victim(current)
when they arrived at out_of_memory() (although this is not a safe behavior)
after they held the oom_lock mutex. But they cannot call out_of_memory(),
breaking "That thread will now get access to memory reserves since it has
a pending fatal signal." used in oom_kill_process() (although this is not
true if they are doing !__GFP_FS && !__GFP_NOFAIL allocations). Therefore,
we should avoid sleeping with the oom_lock mutex held.

On the other hand, even if only a few tasks are trying to invoke the OOM
killer, we can observe collateral victim being OOM-killed immediately
after the memory hog process is OOM-killed. This is caused by a race:

  (1) The process which called oom_kill_process() releases the oom_lock
      mutex before the memory reclaimed by OOM-killing the memory hog
      process becomes allocatable for others.

  (2) Another process acquires the oom_lock mutex and checks for
      get_page_from_freelist() before the memory reclaimed by OOM-killing
      the memory hog process becomes allocatable for others.
      get_page_from_freelist() fails and thus the process proceeds
      calling out_of_memory().

  (3) The memory hog process exits and clears TIF_MEMDIE flag.

  (4) select_bad_process() in out_of_memory() fails to find a task with
      TIF_MEMDIE pending. Thus the process proceeds choosing next OOM
      victim.

  (5) The memory reclaimed by OOM-killing the memory hog process becomes
      allocatable for others. But get_page_from_freelist() is no longer
      called by somebody which held the oom_lock mutex.

  (6) oom_kill_process() is called although get_page_from_freelist()
      could now succeed. If get_page_from_freelist() can succeed, this
      is a collateral victim.

We cannot completely avoid this race because we cannot predict when the
memory reclaimed by OOM-killing the memory hog process becomes allocatable
for others. But we can reduce possibility of hitting this race by keeping
the OOM killer disabled for some administrator controlled period, instead
of relying on a sleep with oom_lock mutex held.

This patch introduces a hold off timer which keeps the OOM killer disabled
for sysctl tunable period (between 1 ms to 5000 ms). Longer the period is,
more unlikely to hit this race but more likely to suffer with traps when
oom_kill_process() chose children of a memory hog process which consumed
little memory.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h |  1 +
 kernel/sysctl.c     | 10 ++++++++++
 mm/oom_kill.c       | 25 ++++++++++++++++++-------
 3 files changed, 29 insertions(+), 7 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 03e6257..ac202c3 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -117,4 +117,5 @@ static inline bool task_will_free_mem(struct task_struct *task)
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
+extern unsigned int sysctl_oomkiller_holdoff_ms;
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index aac2a20..3a989f4 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -124,6 +124,7 @@ static int zero;
 static int __maybe_unused one = 1;
 static int __maybe_unused two = 2;
 static int __maybe_unused four = 4;
+static int five_thousand = 5000;
 static unsigned long one_ul = 1;
 static int one_hundred = 100;
 #ifdef CONFIG_PRINTK
@@ -1219,6 +1220,15 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname       = "oomkiller_holdoff_ms",
+		.data           = &sysctl_oomkiller_holdoff_ms,
+		.maxlen         = sizeof(sysctl_oomkiller_holdoff_ms),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec_minmax,
+		.extra1         = &one,
+		.extra2         = &five_thousand,
+	},
+	{
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
 		.maxlen		= sizeof(sysctl_overcommit_ratio),
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4b0a5d8..f85d77f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -48,6 +48,7 @@
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
+unsigned int sysctl_oomkiller_holdoff_ms = 1;
 
 DEFINE_MUTEX(oom_lock);
 
@@ -539,6 +540,11 @@ static int __init oom_init(void)
 module_init(oom_init)
 #endif
 
+static void oomkiller_reset(unsigned long arg)
+{
+}
+static DEFINE_TIMER(oomkiller_holdoff_timer, oomkiller_reset, 0, 0);
+
 /**
  * mark_oom_victim - mark the given task as OOM victim
  * @tsk: task to mark
@@ -552,6 +558,10 @@ void mark_oom_victim(struct task_struct *tsk)
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
+	/* Start hold off timer. */
+	mod_timer(&oomkiller_holdoff_timer,
+		  jiffies + msecs_to_jiffies(sysctl_oomkiller_holdoff_ms));
+
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -848,6 +858,13 @@ bool out_of_memory(struct oom_control *oc)
 	}
 
 	/*
+	 * Give the TIF_MEMDIE process a good chance to exit before trying
+	 * to choose next OOM victim.
+	 */
+	if (timer_pending(&oomkiller_holdoff_timer))
+		return true;
+
+	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
@@ -871,15 +888,9 @@ bool out_of_memory(struct oom_control *oc)
 		dump_header(oc, NULL, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (p && p != (void *)-1UL) {
+	if (p && p != (void *)-1UL)
 		oom_kill_process(oc, p, points, totalpages, NULL,
 				 "Out of memory");
-		/*
-		 * Give the killed process a good chance to exit before trying
-		 * to allocate memory again.
-		 */
-		schedule_timeout_killable(1);
-	}
 	return true;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
