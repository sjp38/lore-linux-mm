Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 18CB383093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 06:03:37 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so30741336wml.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:37 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id jk1si12982833wjb.221.2016.08.25.03.03.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 03:03:32 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i138so6636126wmf.3
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:32 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2 5/9] mm, oom: get rid of signal_struct::oom_victims
Date: Thu, 25 Aug 2016 12:03:10 +0200
Message-Id: <1472119394-11342-6-git-send-email-mhocko@kernel.org>
In-Reply-To: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
References: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

After "oom: keep mm of the killed task available" we can safely
detect an oom victim by checking task->signal->oom_mm so we do not need
the signal_struct counter anymore so let's get rid of it.

This alone wouldn't be sufficient for nommu archs because exit_oom_victim
doesn't hide the process from the oom killer anymore. We can, however,
mark the mm with a MMF flag in __mmput. We can reuse MMF_OOM_REAPED and
rename it to a more generic MMF_OOM_SKIP.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/oom.h   |  5 +++++
 include/linux/sched.h |  3 +--
 kernel/fork.c         |  1 +
 mm/oom_kill.c         | 17 +++++++----------
 4 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 17946e5121b6..b61357d07170 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -58,6 +58,11 @@ static inline bool oom_task_origin(const struct task_struct *p)
 	return p->signal->oom_flag_origin;
 }
 
+static inline bool tsk_is_oom_victim(struct task_struct * tsk)
+{
+	return tsk->signal->oom_mm;
+}
+
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index cccb575dc242..eda579f3283a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -521,7 +521,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
-#define MMF_OOM_REAPED		21	/* mm has been already reaped */
+#define MMF_OOM_SKIP		21	/* mm is of no interest for the OOM killer */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
@@ -669,7 +669,6 @@ struct signal_struct {
 	atomic_t		sigcnt;
 	atomic_t		live;
 	int			nr_threads;
-	atomic_t oom_victims; /* # of TIF_MEDIE threads in this thread group */
 	struct list_head	thread_head;
 
 	wait_queue_head_t	wait_chldexit;	/* for wait4() */
diff --git a/kernel/fork.c b/kernel/fork.c
index 136a2c6784cb..64624fb42f96 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -725,6 +725,7 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 	mmdrop(mm);
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f16ec0840a0e..e2a2c35dd493 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -186,7 +186,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 */
 	adj = (long)p->signal->oom_score_adj;
 	if (adj == OOM_SCORE_ADJ_MIN ||
-			test_bit(MMF_OOM_REAPED, &p->mm->flags) ||
+			test_bit(MMF_OOM_SKIP, &p->mm->flags) ||
 			in_vfork(p)) {
 		task_unlock(p);
 		return 0;
@@ -296,11 +296,11 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	/*
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves unless
-	 * the task has MMF_OOM_REAPED because chances that it would release
+	 * the task has MMF_OOM_SKIP because chances that it would release
 	 * any memory is quite low.
 	 */
-	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
-		if (test_bit(MMF_OOM_REAPED, &task->signal->oom_mm->flags))
+	if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
+		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
 			goto next;
 		goto abort;
 	}
@@ -572,7 +572,7 @@ static void oom_reap_task(struct task_struct *tsk)
 	 * Hide this mm from OOM killer because it has been either reaped or
 	 * somebody can't call up_write(mmap_sem).
 	 */
-	set_bit(MMF_OOM_REAPED, &mm->flags);
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
@@ -654,8 +654,6 @@ static void mark_oom_victim(struct task_struct *tsk)
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
 
-	atomic_inc(&tsk->signal->oom_victims);
-
 	/* oom_mm is bound to the signal struct life time. */
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
 		atomic_inc(&tsk->signal->oom_mm->mm_count);
@@ -677,7 +675,6 @@ void exit_oom_victim(struct task_struct *tsk)
 {
 	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
-	atomic_dec(&tsk->signal->oom_victims);
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
@@ -769,7 +766,7 @@ static bool task_will_free_mem(struct task_struct *task)
 	 * This task has already been drained by the oom reaper so there are
 	 * only small chances it will free some more
 	 */
-	if (test_bit(MMF_OOM_REAPED, &mm->flags))
+	if (test_bit(MMF_OOM_SKIP, &mm->flags))
 		return false;
 
 	if (atomic_read(&mm->mm_users) <= 1)
@@ -906,7 +903,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 			 * killer to guarantee OOM forward progress.
 			 */
 			can_oom_reap = false;
-			set_bit(MMF_OOM_REAPED, &mm->flags);
+			set_bit(MMF_OOM_SKIP, &mm->flags);
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
 					task_pid_nr(p), p->comm);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
