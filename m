Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A84C1828E1
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 07:02:34 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id ot10so164444749obb.3
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 04:02:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v65si5803866iof.25.2016.06.24.04.02.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 04:02:33 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: use per signal_struct flag rather than clear TIF_MEMDIE
Date: Fri, 24 Jun 2016 20:02:01 +0900
Message-Id: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, David Rientjes <rientjes@google.com>

Currently, the OOM reaper calls exit_oom_victim() on remote TIF_MEMDIE
thread after an OOM reap attempt was made. This behavior is intended
for allowing oom_scan_process_thread() to select next OOM victim by
making atomic_read(&task->signal->oom_victims) == 0.

But since threads can be blocked for unbounded period at __mmput() from
mmput() from exit_mm() from do_exit(), we can't risk the OOM reaper
being blocked for unbounded period waiting for TIF_MEMDIE threads.
Therefore, when we hit a situation that a TIF_MEMDIE thread which is
the only thread of that thread group reached tsk->mm = NULL line in
exit_mm() from do_exit() before __oom_reap_task() finds a mm via
find_lock_task_mm(), oom_reap_task() does not wait for the TIF_MEMDIE
thread to return from __mmput() and instead calls exit_oom_victim().

Patch "mm, oom: hide mm which is shared with kthread or global init"
tried to avoid OOM livelock by setting MMF_OOM_REAPED, but it is racy
because setting MMF_OOM_REAPED will not help when find_lock_task_mm()
in oom_scan_process_thread() failed.

It is possible (though unlikely) that a !can_oom_reap TIF_MEMDIE thread
becomes the only user of that mm (i.e. mm->mm_users drops to 1) and is
later blocked for unbounded period at __mmput() from mmput() from
exit_mm() from do_exit() when we hit e.g.

  (1) First round of OOM killer invocation starts.
  (2) select_bad_process() chooses P1 as an OOM victim because
      oom_scan_process_thread() does not find existing victims.
  (3) oom_kill_process() sets TIF_MEMDIE on P1, but does not put P1 under
      the OOM reaper's supervision due to (p->flags & PF_KTHREAD) being
      true, and instead sets MMF_OOM_REAPED on the P1's mm.
  (4) First round of OOM killer invocation finishes.
  (5) P1 is unable to arrive at do_exit() due to being blocked at
      unkillable event waiting for somebody else's memory allocation.
  (6) Second round of OOM killer invocation starts.
  (7) select_bad_process() chooses P2 as an OOM victim because
      oom_scan_process_thread() finds P1's mm with MMF_OOM_REAPED set.
  (8) oom_kill_process() sets TIF_MEMDIE on P2 via mark_oom_victim(),
      and puts P2 under the OOM reaper's supervision due to
      (p->flags & PF_KTHREAD) being false.
  (9) Second round of OOM killer invocation finishes.
  (10) The OOM reaper reaps P2's mm, and sets MMF_OOM_REAPED to
       P2's mm, and clears TIF_MEMDIE from P2.
  (11) Regarding P1's mm, (p->flags & PF_KTHREAD) becomes false because
       somebody else's memory allocation succeeds and unuse_mm(P1->mm)
       is called. At this point P1 becomes the only user of P1->mm.
  (12) P1 arrives at do_exit() due to no longer being blocked at
       unkillable event waiting for somebody else's memory allocation.
  (13) P1 reaches P1->mm = NULL line in exit_mm() from do_exit().
  (14) P1 is blocked at __mmput().
  (15) Third round of OOM killer invocation starts.
  (16) select_bad_process() does not choose new OOM victim because
       oom_scan_process_thread() fails to find P1's mm while
       P1->signal->oom_victims > 0.
  (17) Third round of OOM killer invocation finishes.
  (18) OOM livelock happens because nobody will clear TIF_MEMDIE from
       P1 (and decrement P1->signal->oom_victims) while P1 is blocked
       at __mmput().

sequence.

Thus, we must not depend on find_lock_task_mm() not returning NULL.
We must use a raceless method which allows oom_scan_process_thread()
to select next OOM victim no matter when TIF_MEMDIE thread passed
tsk->mm = NULL line and is blocked for unbounded period at __mmput() from
mmput() from exit_mm() from do_exit().

In order to make atomic_read(&task->signal->oom_victims) == 0,
oom_kill_process() needs to call exit_oom_victim() when we don't put
the TIF_MEMDIE thread under the OOM reaper's supervision, as with
oom_reap_task() needs to call exit_oom_victim() when the OOM reaper
failed to reap memory due to find_lock_task_mm() in __oom_reap_task()
returning NULL.

On the other hand, calling exit_oom_victim() on remote TIF_MEMDIE thread
is racy with oom_killer_disable() synchronization. It would be possible to
call try_to_freeze_tasks(true) after returning from oom_killer_disable(),
but it is not optimal. Also, like patch "mm, oom: task_will_free_mem
should skip oom_reaped tasks" showed, calling exit_oom_victim() on remote
TIF_MEMDIE thread tends to increase possibility of asking for
task_will_free_mem() shortcut in out_of_memory(). Also, calling
exit_oom_victim(current) from oom_kill_process() prevents current from
using ALLOC_NO_WATERMARKS via TIF_MEMDIE.

Therefore, we should consider using a raceless method which does not
depend on atomic_read(&task->signal->oom_victims) == 0 and
atomic_read(&oom_victims) == 0 in order to respectively allow
oom_scan_process_thread() to select next OOM victim and allow
oom_killer_disable() synchronization to act as a full "barrier".

This patch introduces "struct signal_struct"->oom_ignore_victims flag
and sets that flag instead of calling exit_oom_victim().
oom_killer_disable() can use wait_event_timeout() in case something
went terribly wrong.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: David Rientjes <rientjes@google.com>
---
 include/linux/sched.h |  1 +
 mm/oom_kill.c         | 30 +++++++++++-------------------
 2 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index a1b4475..c5281da 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -801,6 +801,7 @@ struct signal_struct {
 	 * oom
 	 */
 	bool oom_flag_origin;
+	bool oom_ignore_victims;        /* Ignore oom_victims value */
 	short oom_score_adj;		/* OOM kill score adjustment */
 	short oom_score_adj_min;	/* OOM kill score adjustment min value.
 					 * Only settable by CAP_SYS_RESOURCE. */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4c21f74..aa030c8 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -284,21 +284,12 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	/*
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves unless
-	 * the task has MMF_OOM_REAPED because chances that it would release
-	 * any memory is quite low.
+	 * the task has oom_ignore_victims which is set when we can't wait for
+	 * exit_oom_victim().
 	 */
-	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
-		struct task_struct *p = find_lock_task_mm(task);
-		enum oom_scan_t ret = OOM_SCAN_ABORT;
-
-		if (p) {
-			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
-				ret = OOM_SCAN_CONTINUE;
-			task_unlock(p);
-		}
-
-		return ret;
-	}
+	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
+		return task->signal->oom_ignore_victims ?
+			OOM_SCAN_CONTINUE : OOM_SCAN_ABORT;
 
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
@@ -593,13 +584,13 @@ static void oom_reap_task(struct task_struct *tsk)
 	}
 
 	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
-	 * reasonably reclaimable memory anymore or it is not a good candidate
-	 * for the oom victim right now because it cannot release its memory
-	 * itself nor by the oom reaper.
+	 * Let oom_scan_process_thread() ignore this task because the task
+	 * shouldn't be sitting on a reasonably reclaimable memory anymore or
+	 * it is not a good candidate for the oom victim right now because it
+	 * cannot release its memory itself nor by the oom reaper.
 	 */
 	tsk->oom_reaper_list = NULL;
-	exit_oom_victim(tsk);
+	tsk->signal->oom_ignore_victims = true;
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
@@ -930,6 +921,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			 */
 			can_oom_reap = false;
 			set_bit(MMF_OOM_REAPED, &mm->flags);
+			victim->signal->oom_ignore_victims = true;
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
 					task_pid_nr(p), p->comm);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
