Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C7078828E1
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 07:59:32 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so44853008wmr.0
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 04:59:32 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id wa3si4481645wjc.104.2016.06.29.04.59.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 04:59:31 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id a66so13727108wme.2
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 04:59:31 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mmotm: mm-oom-fortify-task_will_free_mem-fix
Date: Wed, 29 Jun 2016 13:59:22 +0200
Message-Id: <1467201562-6709-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

"mm, oom: fortify task_will_free_mem" has dropped task_lock around
task_will_free_mem in oom_kill_process bacause it assumed that a
potential race when the selected task exits will not be a problem
as the oom_reaper will call exit_oom_victim.

Tetsuo was objecting that nommu doesn't have oom_reaper so the race
would be still possible.  The code would be racy and lockup prone
theoretically in other aspects without the oom reaper anyway so I didn't
considered this a big deal. But it seems that further changes I am
planning in this area will benefit from stable task->mm in this path as
well. So let's drop find_lock_task_mm from task_will_free_mem and call
it from under task_lock as we did previously. Just pull the task->mm !=
NULL check inside the function.

Andrew, could you please fold this into
mm-oom-fortify-task_will_free_mem-fix.patch?

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 41 +++++++++++++++--------------------------
 1 file changed, 15 insertions(+), 26 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4c21f744daa6..7d0a275df822 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -757,45 +757,35 @@ static inline bool __task_will_free_mem(struct task_struct *task)
  * Checks whether the given task is dying or exiting and likely to
  * release its address space. This means that all threads and processes
  * sharing the same mm have to be killed or exiting.
+ * Caller has to make sure that task->mm is stable (hold task_lock or
+ * it operates on the current).
  */
 bool task_will_free_mem(struct task_struct *task)
 {
-	struct mm_struct *mm;
+	struct mm_struct *mm = task->mm;
 	struct task_struct *p;
 	bool ret;
 
-	if (!__task_will_free_mem(task))
-		return false;
-
 	/*
-	 * If the process has passed exit_mm we have to skip it because
-	 * we have lost a link to other tasks sharing this mm, we do not
-	 * have anything to reap and the task might then get stuck waiting
-	 * for parent as zombie and we do not want it to hold TIF_MEMDIE
+	 * Skip tasks without mm because it might have passed its exit_mm and
+	 * exit_oom_victim. oom_reaper could have rescued that but do not rely
+	 * on that for now. We can consider find_lock_task_mm in future.
 	 */
-	p = find_lock_task_mm(task);
-	if (!p)
+	if (!mm)
 		return false;
 
-	mm = p->mm;
+	if (!__task_will_free_mem(task))
+		return false;
 
 	/*
 	 * This task has already been drained by the oom reaper so there are
 	 * only small chances it will free some more
 	 */
-	if (test_bit(MMF_OOM_REAPED, &mm->flags)) {
-		task_unlock(p);
+	if (test_bit(MMF_OOM_REAPED, &mm->flags))
 		return false;
-	}
 
-	if (atomic_read(&mm->mm_users) <= 1) {
-		task_unlock(p);
+	if (atomic_read(&mm->mm_users) <= 1)
 		return true;
-	}
-
-	/* pin the mm to not get freed and reused */
-	atomic_inc(&mm->mm_count);
-	task_unlock(p);
 
 	/*
 	 * This is really pessimistic but we do not have any reliable way
@@ -812,7 +802,6 @@ bool task_will_free_mem(struct task_struct *task)
 			break;
 	}
 	rcu_read_unlock();
-	mmdrop(mm);
 
 	return ret;
 }
@@ -838,12 +827,15 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
+	task_lock(p);
 	if (task_will_free_mem(p)) {
 		mark_oom_victim(p);
 		wake_oom_reaper(p);
+		task_unlock(p);
 		put_task_struct(p);
 		return;
 	}
+	task_unlock(p);
 
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p);
@@ -1014,11 +1006,8 @@ bool out_of_memory(struct oom_control *oc)
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
-	 *
-	 * But don't select if current has already released its mm and cleared
-	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
 	 */
-	if (current->mm && task_will_free_mem(current)) {
+	if (task_will_free_mem(current)) {
 		mark_oom_victim(current);
 		wake_oom_reaper(current);
 		return true;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
