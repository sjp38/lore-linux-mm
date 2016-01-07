Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 863D0828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 06:26:44 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id y66so311861029oig.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 03:26:44 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id os5si14171090oeb.92.2016.01.07.03.26.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jan 2016 03:26:43 -0800 (PST)
Subject: [PATCH] mm,oom: Re-enable OOM killer using timers.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201601072026.JCJ95845.LHQOFOOSMFtVFJ@I-love.SAKURA.ne.jp>
Date: Thu, 7 Jan 2016 20:26:29 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

>From 2f73abcec47535062d41c04bd7d9068cd71214b0 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 7 Jan 2016 11:34:41 +0900
Subject: [PATCH] mm,oom: Re-enable OOM killer using timers.

This patch introduces two timers ( holdoff timer and victim wait timer)
and sysctl variables for changing timeout ( oomkiller_holdoff_ms and
oomkiller_victim_wait_ms ) for respectively handling collateral OOM
victim problem and OOM livelock problem. When you are trying to analyze
problems under OOM condition, you can set holdoff timer's timeout to 0
and victim wait timer's timeout to very large value for emulating
current behavior.


About collateral OOM victim problem:

We can observe collateral victim being OOM-killed immediately after
the memory hog process is OOM-killed. This is caused by a race:

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

This patch adds /proc/sys/vm/oomkiller_holdoff_ms for that purpose.
Since the OOM reaper retries for 10 times with 0.1 second interval,
this timeout can be relatively short (e.g. between 0.1 second and few
seconds). Longer the period is, more unlikely to hit this race but more
likely to stall longer when the OOM reaper failed to reclaim memory.


About OOM livelock problem:

We are trying to reduce the possibility of hitting OOM livelock by
introducing the OOM reaper, but we can still observe OOM livelock
when the OOM reaper failed to reclaim enough memory.

When the OOM reaper failed, we need to take some action for making forward
progress. Possible candidates are: choose next OOM victim, allow access to
memory reserves, trigger kernel panic.

Allowing access to memory reserves might help, but on rare occasions
we are already observing depletion of the memory reserves with current
behavior. Thus, this is not a reliable candidate.

Triggering kernel panic upon timeout might help, but can be overkilling
for those who use with /proc/sys/vm/panic_on_oom = 0. At least some of
them prefer choosing next OOM victim because it is very likely that the
OOM reaper can eventually reclaim memory if we continue choosing
subsequent OOM victims.

Therefore, this patch adds /proc/sys/vm/oomkiller_victim_wait_ms for
ignoring current behavior in order to choose subsequent OOM victims.
Since wait victim timer should expire after the OOM reaper fails,
this timeout should be longer than holdoff timer's timeout (e.g.
between few seconds and a minute).


Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
  include/linux/oom.h |  2 ++
  kernel/sysctl.c     | 14 ++++++++++++++
  mm/oom_kill.c       | 31 ++++++++++++++++++++++++++++++-
  3 files changed, 46 insertions(+), 1 deletion(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 03e6257..633e92a 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -117,4 +117,6 @@ static inline bool task_will_free_mem(struct task_struct *task)
  extern int sysctl_oom_dump_tasks;
  extern int sysctl_oom_kill_allocating_task;
  extern int sysctl_panic_on_oom;
+extern unsigned int sysctl_oomkiller_holdoff_ms;
+extern unsigned int sysctl_oomkiller_victim_wait_ms;
  #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 9142036..7102212 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1209,6 +1209,20 @@ static struct ctl_table vm_table[] = {
  		.proc_handler	= proc_dointvec,
  	},
  	{
+		.procname       = "oomkiller_holdoff_ms",
+		.data           = &sysctl_oomkiller_holdoff_ms,
+		.maxlen         = sizeof(sysctl_oomkiller_holdoff_ms),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec_minmax,
+	},
+	{
+		.procname       = "oomkiller_victim_wait_ms",
+		.data           = &sysctl_oomkiller_victim_wait_ms,
+		.maxlen         = sizeof(sysctl_oomkiller_victim_wait_ms),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec_minmax,
+	},
+	{
  		.procname	= "overcommit_ratio",
  		.data		= &sysctl_overcommit_ratio,
  		.maxlen		= sizeof(sysctl_overcommit_ratio),
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b8a4210..9548dce 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -48,9 +48,17 @@
  int sysctl_panic_on_oom;
  int sysctl_oom_kill_allocating_task;
  int sysctl_oom_dump_tasks = 1;
+unsigned int sysctl_oomkiller_holdoff_ms = 100; /* 0.1 second */
+unsigned int sysctl_oomkiller_victim_wait_ms = 5000; /* 5 seconds */

  DEFINE_MUTEX(oom_lock);

+static void oomkiller_reset(unsigned long arg)
+{
+}
+static DEFINE_TIMER(oomkiller_holdoff_timer, oomkiller_reset, 0, 0);
+static DEFINE_TIMER(oomkiller_victim_wait_timer, oomkiller_reset, 0, 0);
+
  #ifdef CONFIG_NUMA
  /**
   * has_intersects_mems_allowed() - check task eligiblity for kill
@@ -292,8 +300,14 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
  	 * Don't allow any other task to have access to the reserves.
  	 */
  	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
+		/*
+		 * If one of TIF_MEMDIE tasks cannot die after victim wait
+		 * timeout expires, treat such tasks as unkillable because
+		 * they are likely stuck at OOM livelock.
+		 */
  		if (!is_sysrq_oom(oc))
-			return OOM_SCAN_ABORT;
+			return timer_pending(&oomkiller_victim_wait_timer) ?
+				OOM_SCAN_ABORT : OOM_SCAN_CONTINUE;
  	}
  	if (!task->mm)
  		return OOM_SCAN_CONTINUE;
@@ -575,6 +589,14 @@ void mark_oom_victim(struct task_struct *tsk)
  	/* OOM killer might race with memcg OOM */
  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
  		return;
+	/* Start holdoff timer and victim wait timer. */
+	if (sysctl_oomkiller_holdoff_ms)
+		mod_timer(&oomkiller_holdoff_timer, jiffies +
+			  msecs_to_jiffies(sysctl_oomkiller_holdoff_ms));
+	if (sysctl_oomkiller_victim_wait_ms)
+		mod_timer(&oomkiller_victim_wait_timer, jiffies +
+			  msecs_to_jiffies(sysctl_oomkiller_victim_wait_ms));
+
  	/*
  	 * Make sure that the task is woken up from uninterruptible sleep
  	 * if it is frozen because OOM killer wouldn't be able to free
@@ -865,6 +887,13 @@ bool out_of_memory(struct oom_control *oc)
  	}

  	/*
+	 * Do not try to choose next OOM victim until holdoff timer expires
+	 * so that we can reduce possibility of making a collateral victim.
+	 */
+	if (timer_pending(&oomkiller_holdoff_timer))
+		return true;
+
+	/*
  	 * Check if there were limitations on the allocation (only relevant for
  	 * NUMA) that may require different handling.
  	 */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
