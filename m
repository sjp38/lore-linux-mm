Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 83C9283093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 06:03:32 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so30718570wme.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:32 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id xt4si12989629wjc.275.2016.08.25.03.03.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 03:03:31 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i5so6652455wmg.2
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:31 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2 3/9] oom: keep mm of the killed task available
Date: Thu, 25 Aug 2016 12:03:08 +0200
Message-Id: <1472119394-11342-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
References: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

oom_reap_task has to call exit_oom_victim in order to make sure that the
oom vicim will not block the oom killer for ever. This is, however,
opening new problems (e.g oom_killer_disable exclusion - see
74070542099c ("oom, suspend: fix oom_reaper vs. oom_killer_disable
race")). exit_oom_victim should be only called from the victim's
context ideally.

One way to achieve this would be to rely on per mm_struct flags. We
already have MMF_OOM_REAPED to hide a task from the oom killer since
"mm, oom: hide mm which is shared with kthread or global init". The
problem is that the exit path:
do_exit
  exit_mm
    tsk->mm = NULL;
    mmput
      __mmput
    exit_oom_victim

doesn't guarantee that exit_oom_victim will get called in a bounded
amount of time. At least exit_aio depends on IO which might get blocked
due to lack of memory and who knows what else is lurking there.

This patch takes a different approach. We remember tsk->mm into the
signal_struct and bind it to the signal struct life time for all oom
victims. __oom_reap_task_mm as well as oom_scan_process_thread do not have
to rely on find_lock_task_mm anymore and they will have a reliable
reference to the mm struct. As a result all the oom specific
communication inside the OOM killer can be done via tsk->signal->oom_mm.

Increasing the signal_struct for something as unlikely as the oom
killer is far from ideal but this approach will make the code much more
reasonable and long term we even might want to move task->mm into the
signal_struct anyway. In the next step we might want to make the oom
killer exclusion and access to memory reserves completely independent
which would be also nice.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/sched.h |  2 ++
 kernel/fork.c         |  2 ++
 mm/oom_kill.c         | 51 +++++++++++++++++++--------------------------------
 3 files changed, 23 insertions(+), 32 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index f9b0b2dd4f18..da278b6ce44d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -802,6 +802,8 @@ struct signal_struct {
 	short oom_score_adj;		/* OOM kill score adjustment */
 	short oom_score_adj_min;	/* OOM kill score adjustment min value.
 					 * Only settable by CAP_SYS_RESOURCE. */
+	struct mm_struct *oom_mm;	/* recorded mm when the thread group got
+					 * killed by the oom killer */
 
 	struct mutex cred_guard_mutex;	/* guard against foreign influences on
 					 * credential calculations
diff --git a/kernel/fork.c b/kernel/fork.c
index 52e725d4a866..f3b78c713211 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -243,6 +243,8 @@ static inline void free_signal_struct(struct signal_struct *sig)
 {
 	taskstats_tgid_free(sig);
 	sched_autogroup_exit(sig);
+	if (sig->oom_mm)
+		mmdrop(sig->oom_mm);
 	kmem_cache_free(signal_cachep, sig);
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 45097f5a8f30..f16ec0840a0e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -300,14 +300,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	 * any memory is quite low.
 	 */
 	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
-		struct task_struct *p = find_lock_task_mm(task);
-		bool reaped = false;
-
-		if (p) {
-			reaped = test_bit(MMF_OOM_REAPED, &p->mm->flags);
-			task_unlock(p);
-		}
-		if (reaped)
+		if (test_bit(MMF_OOM_REAPED, &task->signal->oom_mm->flags))
 			goto next;
 		goto abort;
 	}
@@ -537,11 +530,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	up_read(&mm->mmap_sem);
 
 	/*
-	 * This task can be safely ignored because we cannot do much more
-	 * to release its memory.
-	 */
-	set_bit(MMF_OOM_REAPED, &mm->flags);
-	/*
 	 * Drop our reference but make sure the mmput slow path is called from a
 	 * different context because we shouldn't risk we get stuck there and
 	 * put the oom_reaper out of the way.
@@ -556,20 +544,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 static void oom_reap_task(struct task_struct *tsk)
 {
 	int attempts = 0;
-	struct mm_struct *mm = NULL;
-	struct task_struct *p = find_lock_task_mm(tsk);
-
-	/*
-	 * Make sure we find the associated mm_struct even when the particular
-	 * thread has already terminated and cleared its mm.
-	 * We might have race with exit path so consider our work done if there
-	 * is no mm.
-	 */
-	if (!p)
-		goto done;
-	mm = p->mm;
-	atomic_inc(&mm->mm_count);
-	task_unlock(p);
+	struct mm_struct *mm = tsk->signal->oom_mm;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
 	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
@@ -578,8 +553,6 @@ static void oom_reap_task(struct task_struct *tsk)
 	if (attempts <= MAX_OOM_REAP_RETRIES)
 		goto done;
 
-	/* Ignore this mm because somebody can't call up_write(mmap_sem). */
-	set_bit(MMF_OOM_REAPED, &mm->flags);
 
 	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 		task_pid_nr(tsk), tsk->comm);
@@ -595,11 +568,14 @@ static void oom_reap_task(struct task_struct *tsk)
 	tsk->oom_reaper_list = NULL;
 	exit_oom_victim(tsk);
 
+	/*
+	 * Hide this mm from OOM killer because it has been either reaped or
+	 * somebody can't call up_write(mmap_sem).
+	 */
+	set_bit(MMF_OOM_REAPED, &mm->flags);
+
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
-	/* Drop a reference taken above. */
-	if (mm)
-		mmdrop(mm);
 }
 
 static int oom_reaper(void *unused)
@@ -665,14 +641,25 @@ static inline void wake_oom_reaper(struct task_struct *tsk)
  *
  * Has to be called with oom_lock held and never after
  * oom has been disabled already.
+ *
+ * tsk->mm has to be non NULL and caller has to guarantee it is stable (either
+ * under task_lock or operate on the current).
  */
 static void mark_oom_victim(struct task_struct *tsk)
 {
+	struct mm_struct *mm = tsk->mm;
+
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
+
 	atomic_inc(&tsk->signal->oom_victims);
+
+	/* oom_mm is bound to the signal struct life time. */
+	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
+		atomic_inc(&tsk->signal->oom_mm->mm_count);
+
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
