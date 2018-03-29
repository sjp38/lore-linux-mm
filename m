Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 38B556B0007
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 10:37:18 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i205-v6so5358884ita.3
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:37:18 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g129si4183088iof.38.2018.03.29.07.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 07:37:16 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: Do not unfreeze OOM victim thread.
Date: Thu, 29 Mar 2018 23:36:58 +0900
Message-Id: <1522334218-4268-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-pm@vger.kernel.org, linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

Currently, mark_oom_victim() calls __thaw_task() on the OOM victim
threads and freezing_slow_path() unfreezes the OOM victim thread.
But I think this exceptional behavior makes little sense nowadays.

The OOM killer kills only userspace processes. All userspace processes
except current thread which calls oom_killer_disable() and !TIF_MEMDIE
threads are already frozen by the time oom_killer_disable() is called.
If the freezer does not unfreeze TIF_MEMDIE threads, oom_killer_disable()
does not need to wait for TIF_MEMDIE threads.

Since CONFIG_MMU=y kernels have the OOM reaper, we can reclaim memory
without unfreezing TIF_MEMDIE threads. Even if memory cannot be
reclaimed (e.g. CONFIG_MMU=n), as long as freeze operation is using
timeout, OOM livelock will disappear eventually.

I think that nobody is testing situations where oom_killer_disable()
needs to wait for TIF_MEMDIE threads to call exit_oom_victim().
Therefore, by relying on timeout for freeze operation, this patch
stops unfreezing TIF_MEMDIE threads.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
---
 include/linux/oom.h |  2 +-
 kernel/freezer.c    |  3 ---
 mm/oom_kill.c       | 32 +-------------------------------
 3 files changed, 2 insertions(+), 35 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index d4d41c0..a9ac384 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -114,7 +114,7 @@ extern unsigned long oom_badness(struct task_struct *p,
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
 
-extern bool oom_killer_disable(signed long timeout);
+extern bool oom_killer_disable(void);
 extern void oom_killer_enable(void);
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
diff --git a/kernel/freezer.c b/kernel/freezer.c
index 6f56a9e..969cae4 100644
--- a/kernel/freezer.c
+++ b/kernel/freezer.c
@@ -42,9 +42,6 @@ bool freezing_slow_path(struct task_struct *p)
 	if (p->flags & (PF_NOFREEZE | PF_SUSPEND_TASK))
 		return false;
 
-	if (test_tsk_thread_flag(p, TIF_MEMDIE))
-		return false;
-
 	if (pm_nosig_freezing || cgroup_freezing(p))
 		return true;
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dfd3705..ebb7d75 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -441,12 +441,6 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 		dump_tasks(oc->memcg, oc->nodemask);
 }
 
-/*
- * Number of OOM victims in flight
- */
-static atomic_t oom_victims = ATOMIC_INIT(0);
-static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
-
 static bool oom_killer_disabled __read_mostly;
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
@@ -674,7 +668,6 @@ static void mark_oom_victim(struct task_struct *tsk)
 {
 	struct mm_struct *mm = tsk->mm;
 
-	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
@@ -685,14 +678,6 @@ static void mark_oom_victim(struct task_struct *tsk)
 		set_bit(MMF_OOM_VICTIM, &mm->flags);
 	}
 
-	/*
-	 * Make sure that the task is woken up from uninterruptible sleep
-	 * if it is frozen because OOM killer wouldn't be able to free
-	 * any memory and livelock. freezing_slow_path will tell the freezer
-	 * that TIF_MEMDIE tasks should be ignored.
-	 */
-	__thaw_task(tsk);
-	atomic_inc(&oom_victims);
 	trace_mark_victim(tsk->pid);
 }
 
@@ -702,9 +687,6 @@ static void mark_oom_victim(struct task_struct *tsk)
 void exit_oom_victim(void)
 {
 	clear_thread_flag(TIF_MEMDIE);
-
-	if (!atomic_dec_return(&oom_victims))
-		wake_up_all(&oom_victims_wait);
 }
 
 /**
@@ -721,8 +703,6 @@ void oom_killer_enable(void)
  * @timeout: maximum timeout to wait for oom victims in jiffies
  *
  * Forces all page allocations to fail rather than trigger OOM killer.
- * Will block and wait until all OOM victims are killed or the given
- * timeout expires.
  *
  * The function cannot be called when there are runnable user tasks because
  * the userspace would see unexpected allocation failures as a result. Any
@@ -731,10 +711,8 @@ void oom_killer_enable(void)
  * Returns true if successful and false if the OOM killer cannot be
  * disabled.
  */
-bool oom_killer_disable(signed long timeout)
+bool oom_killer_disable(void)
 {
-	signed long ret;
-
 	/*
 	 * Make sure to not race with an ongoing OOM killer. Check that the
 	 * current is not killed (possibly due to sharing the victim's memory).
@@ -743,15 +721,7 @@ bool oom_killer_disable(signed long timeout)
 		return false;
 	oom_killer_disabled = true;
 	mutex_unlock(&oom_lock);
-
-	ret = wait_event_interruptible_timeout(oom_victims_wait,
-			!atomic_read(&oom_victims), timeout);
-	if (ret <= 0) {
-		oom_killer_enable();
-		return false;
-	}
 	pr_info("OOM killer disabled.\n");
-
 	return true;
 }
 
-- 
1.8.3.1
