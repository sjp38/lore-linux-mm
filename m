Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9757B6B0262
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 07:52:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c82so20730276wme.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 04:52:42 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id id4si7455894wjb.67.2016.06.09.04.52.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 04:52:31 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id k184so10030316wme.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 04:52:31 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 07/10] mm, oom: fortify task_will_free_mem
Date: Thu,  9 Jun 2016 13:52:14 +0200
Message-Id: <1465473137-22531-8-git-send-email-mhocko@kernel.org>
In-Reply-To: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

task_will_free_mem is rather weak. It doesn't really tell whether
the task has chance to drop its mm. 98748bd72200 ("oom: consider
multi-threaded tasks in task_will_free_mem") made a first step
into making it more robust for multi-threaded applications so now we
know that the whole process is going down and probably drop the mm.

This patch builds on top for more complex scenarios where mm is shared
between different processes - CLONE_VM without CLONE_SIGHAND, or in
kernel use_mm().

Make sure that all processes sharing the mm are killed or exiting. This
will allow us to replace try_oom_reaper by wake_oom_reaper because
task_will_free_mem implies the task is reapable now. Therefore all paths
which bypass the oom killer are now reapable and so they shouldn't lock
up the oom killer.

Changes since v2 - per Oleg
- uninline task_will_free_mem and move it to oom proper
- reorganize checks in and simplify __task_will_free_mem
- add missing process_shares_mm in task_will_free_mem
- add same_thread_group to task_will_free_mem for clarity

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/oom.h |  26 ++--------
 mm/memcontrol.c     |   4 +-
 mm/oom_kill.c       | 136 ++++++++++++++++++++++++++++++----------------------
 3 files changed, 85 insertions(+), 81 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 606137b3b778..5bc0457ee3a8 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -73,9 +73,9 @@ static inline bool oom_task_origin(const struct task_struct *p)
 extern void mark_oom_victim(struct task_struct *tsk);
 
 #ifdef CONFIG_MMU
-extern void try_oom_reaper(struct task_struct *tsk);
+extern void wake_oom_reaper(struct task_struct *tsk);
 #else
-static inline void try_oom_reaper(struct task_struct *tsk)
+static inline void wake_oom_reaper(struct task_struct *tsk)
 {
 }
 #endif
@@ -107,27 +107,7 @@ extern void oom_killer_enable(void);
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
-static inline bool task_will_free_mem(struct task_struct *task)
-{
-	struct signal_struct *sig = task->signal;
-
-	/*
-	 * A coredumping process may sleep for an extended period in exit_mm(),
-	 * so the oom killer cannot assume that the process will promptly exit
-	 * and release memory.
-	 */
-	if (sig->flags & SIGNAL_GROUP_COREDUMP)
-		return false;
-
-	if (!(task->flags & PF_EXITING))
-		return false;
-
-	/* Make sure that the whole thread group is going down */
-	if (!thread_group_empty(task) && !(sig->flags & SIGNAL_GROUP_EXIT))
-		return false;
-
-	return true;
-}
+bool task_will_free_mem(struct task_struct *task);
 
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 83a6a2b92301..de67daf0394e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1276,9 +1276,9 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
 	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
+	if (task_will_free_mem(current)) {
 		mark_oom_victim(current);
-		try_oom_reaper(current);
+		wake_oom_reaper(current);
 		goto unlock;
 	}
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 38f89ac2df7f..21bf88a546d3 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -596,7 +596,7 @@ static int oom_reaper(void *unused)
 	return 0;
 }
 
-static void wake_oom_reaper(struct task_struct *tsk)
+void wake_oom_reaper(struct task_struct *tsk)
 {
 	if (!oom_reaper_th)
 		return;
@@ -614,46 +614,6 @@ static void wake_oom_reaper(struct task_struct *tsk)
 	wake_up(&oom_reaper_wait);
 }
 
-/* Check if we can reap the given task. This has to be called with stable
- * tsk->mm
- */
-void try_oom_reaper(struct task_struct *tsk)
-{
-	struct mm_struct *mm = tsk->mm;
-	struct task_struct *p;
-
-	if (!mm)
-		return;
-
-	/*
-	 * There might be other threads/processes which are either not
-	 * dying or even not killable.
-	 */
-	if (atomic_read(&mm->mm_users) > 1) {
-		rcu_read_lock();
-		for_each_process(p) {
-			if (!process_shares_mm(p, mm))
-				continue;
-			if (fatal_signal_pending(p))
-				continue;
-
-			/*
-			 * If the task is exiting make sure the whole thread group
-			 * is exiting and cannot acces mm anymore.
-			 */
-			if (signal_group_exit(p->signal))
-				continue;
-
-			/* Give up */
-			rcu_read_unlock();
-			return;
-		}
-		rcu_read_unlock();
-	}
-
-	wake_oom_reaper(tsk);
-}
-
 static int __init oom_init(void)
 {
 	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
@@ -665,10 +625,6 @@ static int __init oom_init(void)
 	return 0;
 }
 subsys_initcall(oom_init)
-#else
-static void wake_oom_reaper(struct task_struct *tsk)
-{
-}
 #endif
 
 /**
@@ -745,6 +701,81 @@ void oom_killer_enable(void)
 	oom_killer_disabled = false;
 }
 
+static inline bool __task_will_free_mem(struct task_struct *task)
+{
+	struct signal_struct *sig = task->signal;
+
+	/*
+	 * A coredumping process may sleep for an extended period in exit_mm(),
+	 * so the oom killer cannot assume that the process will promptly exit
+	 * and release memory.
+	 */
+	if (sig->flags & SIGNAL_GROUP_COREDUMP)
+		return false;
+
+	if (sig->flags & SIGNAL_GROUP_EXIT)
+		return true;
+
+	if (thread_group_empty(task) && (task->flags & PF_EXITING))
+		return true;
+
+	return false;
+}
+
+/*
+ * Checks whether the given task is dying or exiting and likely to
+ * release its address space. This means that all threads and processes
+ * sharing the same mm have to be killed or exiting.
+ */
+bool task_will_free_mem(struct task_struct *task)
+{
+	struct mm_struct *mm;
+	struct task_struct *p;
+	bool ret;
+
+	if (!__task_will_free_mem(task))
+		return false;
+
+	/*
+	 * If the process has passed exit_mm we have to skip it because
+	 * we have lost a link to other tasks sharing this mm, we do not
+	 * have anything to reap and the task might then get stuck waiting
+	 * for parent as zombie and we do not want it to hold TIF_MEMDIE
+	 */
+	p = find_lock_task_mm(task);
+	if (!p)
+		return false;
+
+	mm = p->mm;
+	if (atomic_read(&mm->mm_users) <= 1) {
+		task_unlock(p);
+		return true;
+	}
+
+	/* pin the mm to not get freed and reused */
+	atomic_inc(&mm->mm_count);
+	task_unlock(p);
+
+	/*
+	 * This is really pessimistic but we do not have any reliable way
+	 * to check that external processes share with our mm
+	 */
+	rcu_read_lock();
+	for_each_process(p) {
+		if (!process_shares_mm(p, mm))
+			continue;
+		if (same_thread_group(task, p))
+			continue;
+		ret = __task_will_free_mem(p);
+		if (!ret)
+			break;
+	}
+	rcu_read_unlock();
+	mmdrop(mm);
+
+	return ret;
+}
+
 /*
  * Must be called while holding a reference to p, which will be released upon
  * returning.
@@ -766,15 +797,12 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
-	task_lock(p);
-	if (p->mm && task_will_free_mem(p)) {
+	if (task_will_free_mem(p)) {
 		mark_oom_victim(p);
-		try_oom_reaper(p);
-		task_unlock(p);
+		wake_oom_reaper(p);
 		put_task_struct(p);
 		return;
 	}
-	task_unlock(p);
 
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p);
@@ -940,14 +968,10 @@ bool out_of_memory(struct oom_control *oc)
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
-	 *
-	 * But don't select if current has already released its mm and cleared
-	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
 	 */
-	if (current->mm &&
-	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
+	if (task_will_free_mem(current)) {
 		mark_oom_victim(current);
-		try_oom_reaper(current);
+		wake_oom_reaper(current);
 		return true;
 	}
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
