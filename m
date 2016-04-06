Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5AD6B0253
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 10:13:32 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id f198so75609801wme.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 07:13:32 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id z126si3947955wmz.77.2016.04.06.07.13.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 07:13:29 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id i204so13658853wmd.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 07:13:29 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] oom, oom_reaper: Try to reap tasks which skip regular OOM killer path
Date: Wed,  6 Apr 2016 16:13:15 +0200
Message-Id: <1459951996-12875-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>

From: Michal Hocko <mhocko@suse.com>

If either the current task is already killed or PF_EXITING or a selected
task is PF_EXITING then the oom killer is suppressed and so is the oom
reaper. This patch adds try_oom_reaper which checks the given task
and queues it for the oom reaper if that is safe to be done meaning
that the task doesn't share the mm with an alive process.

This might help to release the memory pressure while the task tries to
exit.

Cc: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 90 +++++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 72 insertions(+), 18 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 32d8210b8773..74c38f5fffef 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -412,6 +412,25 @@ bool oom_killer_disabled __read_mostly;
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
 
+/*
+ * task->mm can be NULL if the task is the exited group leader.  So to
+ * determine whether the task is using a particular mm, we examine all the
+ * task's threads: if one of those is using this mm then this task was also
+ * using it.
+ */
+static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
+{
+	struct task_struct *t;
+
+	for_each_thread(p, t) {
+		struct mm_struct *t_mm = READ_ONCE(t->mm);
+		if (t_mm)
+			return t_mm == mm;
+	}
+	return false;
+}
+
+
 #ifdef CONFIG_MMU
 /*
  * OOM Reaper kernel thread which tries to reap the memory used by the OOM
@@ -563,6 +582,53 @@ static void wake_oom_reaper(struct task_struct *tsk)
 	wake_up(&oom_reaper_wait);
 }
 
+/* Check if we can reap the given task. This has to be called with stable
+ * tsk->mm
+ */
+static void try_oom_reaper(struct task_struct *tsk)
+{
+	struct mm_struct *mm = tsk->mm;
+	struct task_struct *p;
+
+	if (!mm)
+		return;
+
+	/*
+	 * There might be other threads/processes which are either not
+	 * dying or even not killable.
+	 */
+	if (atomic_read(&mm->mm_users) > 1) {
+		rcu_read_lock();
+		for_each_process(p) {
+			bool exiting;
+
+			if (!process_shares_mm(p, mm))
+				continue;
+			if (same_thread_group(p, tsk))
+				continue;
+			if (fatal_signal_pending(p))
+				continue;
+
+			/*
+			 * If the task is exiting make sure the whole thread group
+			 * is exiting and cannot acces mm anymore.
+			 */
+			spin_lock_irq(&p->sighand->siglock);
+			exiting = signal_group_exit(p->signal);
+			spin_unlock_irq(&p->sighand->siglock);
+			if (exiting)
+				continue;
+
+			/* Give up */
+			rcu_read_unlock();
+			return;
+		}
+		rcu_read_unlock();
+	}
+
+	wake_oom_reaper(tsk);
+}
+
 static int __init oom_init(void)
 {
 	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
@@ -575,6 +641,10 @@ static int __init oom_init(void)
 }
 subsys_initcall(oom_init)
 #else
+static void try_oom_reaper(struct task_struct *tsk)
+{
+}
+
 static void wake_oom_reaper(struct task_struct *tsk)
 {
 }
@@ -653,24 +723,6 @@ void oom_killer_enable(void)
 }
 
 /*
- * task->mm can be NULL if the task is the exited group leader.  So to
- * determine whether the task is using a particular mm, we examine all the
- * task's threads: if one of those is using this mm then this task was also
- * using it.
- */
-static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
-{
-	struct task_struct *t;
-
-	for_each_thread(p, t) {
-		struct mm_struct *t_mm = READ_ONCE(t->mm);
-		if (t_mm)
-			return t_mm == mm;
-	}
-	return false;
-}
-
-/*
  * Must be called while holding a reference to p, which will be released upon
  * returning.
  */
@@ -694,6 +746,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	task_lock(p);
 	if (p->mm && task_will_free_mem(p)) {
 		mark_oom_victim(p);
+		try_oom_reaper(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -873,6 +926,7 @@ bool out_of_memory(struct oom_control *oc)
 	if (current->mm &&
 	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
 		mark_oom_victim(current);
+		try_oom_reaper(current);
 		return true;
 	}
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
