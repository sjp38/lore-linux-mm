Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id E00216B007E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 10:23:54 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id i11so97799763igh.0
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 07:23:54 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d53si5683549ote.19.2016.06.10.07.23.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Jun 2016 07:23:54 -0700 (PDT)
Subject: mm, oom_reaper: How to handle race with oom_killer_disable() ?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201606102323.BCC73478.FtOJHFQMSVFLOO@I-love.SAKURA.ne.jp>
Date: Fri, 10 Jun 2016 23:23:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, mgorman@techsingularity.net, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

I got a question about commit e26796066fdf929c ("oom: make oom_reaper freezable").

static int enter_state(suspend_state_t state) {
  pr_debug("PM: Preparing system for sleep (%s)\n", pm_states[state]);
  error = suspend_prepare(state) {
    error = suspend_freeze_processes() {
      error = freeze_processes();
      if (error)
        return error;
      error = freeze_kernel_threads();
    }
  }
}

int freeze_processes(void) {
  if (!pm_freezing)
    atomic_inc(&system_freezing_cnt); // system_freezing_cnt becomes non-0 due to pm_freezing == false.
  pr_info("Freezing user space processes ... ");
  pm_freezing = true;
  error = try_to_freeze_tasks(true) {
    for_each_process_thread(g, p) {
      if (p == current || !freeze_task(p)) // freeze_task(oom_reaper_th) is called.
        continue;
    }
  }
  if (!error && !oom_killer_disable())
    error = -EBUSY;
}

bool freeze_task(struct task_struct *p) {
  if (!freezing(p) || frozen(p)) { // freezing(oom_reaper_th) is called.
    return false;
  }
  if (!(p->flags & PF_KTHREAD))
    fake_signal_wake_up(p);
  else
    wake_up_state(p, TASK_INTERRUPTIBLE);
  return true;
}

static inline bool freezing(struct task_struct *p) {
  if (likely(!atomic_read(&system_freezing_cnt))) // system_freezing_cnt is non-0 due to freeze_processes().
    return false;
  return freezing_slow_path(p); // freezing_slow_path(oom_reaper_th) is called.
}

bool freezing_slow_path(struct task_struct *p) {
  if (p->flags & (PF_NOFREEZE | PF_SUSPEND_TASK)) // false due to set_freezable() by oom_reaper().
    return false;
  if (test_thread_flag(TIF_MEMDIE)) // false due to unkillable thread.
    return false;
  if (pm_nosig_freezing || cgroup_freezing(p)) // pm_nosig_freezing == false for now. I assume cgroup_freezing(oom_reaper_th) is also false.
    return true;
  if (pm_freezing && !(p->flags & PF_KTHREAD)) // pm_freezing == true due to freeze_processes(). But oom_reaper_th has PF_KTHREAD.
    return true;
  return false; // After all, freezing(oom_reaper_th) returns false for now.
}

Therefore, freeze_task(oom_reaper_th) from freeze_processes() is a no-op.

int freeze_kernel_threads(void) {
  pr_info("Freezing remaining freezable tasks ... ");
  pm_nosig_freezing = true;
  error = try_to_freeze_tasks(false) {
    for_each_process_thread(g, p) {
      if (p == current || !freeze_task(p)) // freeze_task(oom_reaper_th) is called again.
        continue;
    }
  }
}

bool freeze_task(struct task_struct *p) {
  if (!freezing(p) || frozen(p)) { // freezing(oom_reaper_th) is called again.
    return false;
  }
  if (!(p->flags & PF_KTHREAD))
    fake_signal_wake_up(p);
  else
    wake_up_state(p, TASK_INTERRUPTIBLE);
  return true;
}

This time, freezing(oom_reaper_th) == true due to pm_nosig_freezing == true
and frozen(oom_reaper_th) == false. Thus, wake_up_state() wakes up the
oom_reaper_th sleeping at wait_event_freezable(), and the oom_reaper_th
calls __refrigerator() via try_to_freeze().

Therefore, the OOM reaper kernel thread might clear TIF_MEMDIE after
oom_killer_disable() set oom_killer_disabled = true, doesn't it?
This in turn allows sequence shown below, doesn't it?

  (1) freeze_processes() starts freezing user space threads.
  (2) Somebody (maybe a kenrel thread) calls out_of_memory().
  (3) The OOM killer calls mark_oom_victim() on a user space thread
      P1 which is already in __refrigerator().
  (4) oom_killer_disable() sets oom_killer_disabled = true.
  (5) P1 leaves __refrigerator() and enters do_exit().
  (6) The OOM reaper calls exit_oom_victim(P1) before P1 can call
      exit_oom_victim(P1).
  (7) oom_killer_disable() returns while P1 is not yet frozen
      again (i.e. not yet marked as PF_FROZEN).
  (8) P1 perform IO/interfere with the freezer.

try_to_freeze_tasks(false) from freeze_kernel_threads() will freeze
P1 again, but it seems to me that freeze_kernel_threads() is not
always called when freeze_processes() suceeded.

Therefore, we need to do like

-	exit_oom_victim(tsk);
+	mutex_lock(&oom_lock);
+	if (!oom_killer_disabled)
+		exit_oom_victim(tsk);
+	mutex_unlock(&oom_lock);

in oom_reap_task(), don't we?

----------------------------------------
>From 331842e86a6778cfce6de13ae6c029bc5123a714 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 10 Jun 2016 19:46:26 +0900
Subject: [PATCH] mm, oom_reaper: close race with oom_killer_disable()

Commit e26796066fdf929c ("oom: make oom_reaper freezable") meant to close
race with oom_killer_disable() by adding set_freezable() to oom_reaper().
But freezable kernel threads are not frozen until freeze_kernel_threads()
is called, which occurs after oom_killer_disable() from freeze_processes()
is called. Therefore, oom_reaper() needs to check right before calling
exit_oom_victim() whether oom_killer_disable() is already in progress.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/oom_kill.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index acbc432..29f42ad 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -559,9 +559,15 @@ static void oom_reap_task(struct task_struct *tsk)
 	 * reasonably reclaimable memory anymore or it is not a good candidate
 	 * for the oom victim right now because it cannot release its memory
 	 * itself nor by the oom reaper.
+	 *
+	 * But be sure to check race with oom_killer_disable() because
+	 * oom_reaper() is frozen after oom_killer_disable() returned.
 	 */
 	tsk->oom_reaper_list = NULL;
-	exit_oom_victim(tsk);
+	mutex_lock(&oom_lock);
+	if (!oom_killer_disabled)
+		exit_oom_victim(tsk);
+	mutex_unlock(&oom_lock);
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
-- 
1.8.3.1
----------------------------------------

But we might be able to do like below patch rather than above patch.
If below approach is OK, "[PATCH 10/10] mm, oom: hide mm which is shared
with kthread or global init" will be able to call exit_oom_victim() when
can_oom_reap became false.

----------------------------------------
>From e2b7a68dcb2ed6ace7038be0f6865efcc27b51bd Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 10 Jun 2016 22:59:11 +0900
Subject: [PATCH] mm, oom: stop thawing victim threads

Commit e26796066fdf929c ("oom: make oom_reaper freezable") meant to close
race with oom_killer_disable() by adding set_freezable() to oom_reaper().
But freezable kernel threads are not frozen until freeze_kernel_threads()
is called, which occurs after oom_killer_disable() from freeze_processes()
is called. Therefore, oom_reaper() needs to check right before calling
exit_oom_victim() whether oom_killer_disable() is already in progress.

But doing such check introduces a branch where the OOM reaper fails to
clear TIF_MEMDIE. There is a different approach which does not introduce
such branch.

Currently we thaw only one thread even if that thread's mm is shared by
multiple threads. While that thread might release some memory by e.g.
closing file descriptors after arriving at do_exit(), it won't help much
if such resource is shared by multiple threads. Unless we thaw all threads
using that memory, we can't guarantee that that memory is released before
oom_killer_disable() returns. If the victim was selected by memcg OOM,
memory allocation requests after oom_killer_disabled became true will
likely succeed because OOM situation is local. But if the victim was
selected by global OOM, memory allocation requests after
oom_killer_disabled became true will unlikely succeed; we will see
allocation failures caused by oom_killer_disabled == true.

Then, rather than risking memory allocation failures caused by not waiting
until the victim's memory is released (because the thawed victim might be
able to call exit_oom_victim(tsk) before the OOM reaper starts reaping the
victim's memory, for mmput(mm) which is called from between tsk->mm = NULL
and exit_oom_victim(tsk) in exit_mm() will not wait because there are other
still-frozen threads sharing that memory), waiting until the victim's
memory is reaped by the OOM reaper (by not thawing the victim thread)
will help reducing such risk.

This heuristic depends on an assumption that amount of memory released by
reaping mm is larger than that of by terminating one TIF_MEMDIE thread.
Since we assume that mm_struct is the primary source of memory usage, the
OOM reaper considers that there is no reasonably reclaimable memory after
the OOM reaper reaped the victim's memory. So, it should worth trying.

This patch stops thawing the TIF_MEMDIE thread because the OOM reaper
will reap memory on behalf of that thread, and defers out_of_memory()
returning false after oom_killer_disabled became true till the OOM reaper
clears all pending TIF_MEMDIE. Since the OOM killer does not thaw victim
threads, we won't break oom_killer_disable() semantics even if somebody
else clears TIF_MEMDIE.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/oom_kill.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index acbc432..11dfb16 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -678,6 +678,7 @@ void mark_oom_victim(struct task_struct *tsk)
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
 	atomic_inc(&tsk->signal->oom_victims);
+#ifndef CONFIG_MMU
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -685,6 +686,7 @@ void mark_oom_victim(struct task_struct *tsk)
 	 * that TIF_MEMDIE tasks should be ignored.
 	 */
 	__thaw_task(tsk);
+#endif
 	atomic_inc(&oom_victims);
 }
 
@@ -923,8 +925,24 @@ bool out_of_memory(struct oom_control *oc)
 	unsigned int uninitialized_var(points);
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
+#ifdef CONFIG_MMU
+	/*
+	 * If oom_killer_disable() is called, wait for the OOM reaper to reap
+	 * all victim's memory. Since oom_killer_disable() is called between
+	 * after all userspace threads except the one calling
+	 * oom_killer_disable() are frozen and before freezable kernel threads
+	 * are frozen, the OOM reaper is known to be not yet frozen. Also,
+	 * since anyone who calls out_of_memory() while oom_killer_disable() is
+	 * waiting for all victims to terminate is known to be a kernel thread,
+	 * it is better to retry allocation as long as the OOM reaper can find
+	 * reapable memory.
+	 */
+	if (oom_killer_disabled)
+		return atomic_read(&oom_victims);
+#else
 	if (oom_killer_disabled)
 		return false;
+#endif
 
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
 	if (freed > 0)
-- 
1.8.3.1
----------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
