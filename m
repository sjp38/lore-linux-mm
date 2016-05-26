Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 15083828E1
	for <linux-mm@kvack.org>; Thu, 26 May 2016 08:40:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n2so45026987wma.0
        for <linux-mm@kvack.org>; Thu, 26 May 2016 05:40:38 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id ez7si18074966wjd.197.2016.05.26.05.40.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 05:40:29 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q62so5042342wmg.3
        for <linux-mm@kvack.org>; Thu, 26 May 2016 05:40:29 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 6/6] mm, oom: fortify task_will_free_mem
Date: Thu, 26 May 2016 14:40:15 +0200
Message-Id: <1464266415-15558-7-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

task_will_free_mem is rather weak. It doesn't really tell whether
the task has chance to drop its mm. 98748bd72200 ("oom: consider
multi-threaded tasks in task_will_free_mem") made a first step
into making it more robust for multi-threaded applications so now we
know that the whole process is going down. This builds on top for more
complex scenarios where mm is shared between different processes
(CLONE_VM without CLONE_THREAD resp CLONE_SIGHAND).

Make sure that all processes sharing the mm are killed or exiting. This
will allow us to replace try_oom_reaper by wake_oom_reaper. Therefore
all paths which bypass the oom killer are now reapable and so they
shouldn't lock up the oom killer.

Drop the mm checks for the bypass because those are not really
guaranteeing anything as the condition might change at any time
after task_lock is dropped.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/oom.h | 72 +++++++++++++++++++++++++++++++++++++++++++++++++----
 mm/memcontrol.c     |  4 +--
 mm/oom_kill.c       | 65 ++++-------------------------------------------
 3 files changed, 74 insertions(+), 67 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 83469522690a..412c4ecb42b1 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -70,9 +70,9 @@ static inline bool oom_task_origin(const struct task_struct *p)
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
@@ -105,7 +105,7 @@ extern void oom_killer_enable(void);
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
-static inline bool task_will_free_mem(struct task_struct *task)
+static inline bool __task_will_free_mem(struct task_struct *task)
 {
 	struct signal_struct *sig = task->signal;
 
@@ -117,13 +117,75 @@ static inline bool task_will_free_mem(struct task_struct *task)
 	if (sig->flags & SIGNAL_GROUP_COREDUMP)
 		return false;
 
-	if (!(task->flags & PF_EXITING))
+	if (!(task->flags & PF_EXITING || fatal_signal_pending(task)))
 		return false;
 
 	/* Make sure that the whole thread group is going down */
-	if (!thread_group_empty(task) && !(sig->flags & SIGNAL_GROUP_EXIT))
+	if (!thread_group_empty(task) &&
+		!(sig->flags & SIGNAL_GROUP_EXIT || fatal_signal_pending(task)))
+		return false;
+
+	return true;
+}
+
+/*
+ * Checks whether the given task is dying or exiting and likely to
+ * release its address space. This means that all threads and processes
+ * sharing the same mm have to be killed or exiting.
+ */
+static inline bool task_will_free_mem(struct task_struct *task)
+{
+	struct mm_struct *mm = NULL;
+	struct task_struct *p;
+
+	/*
+	 * If the process has passed exit_mm we have to skip it because
+	 * we have lost a link to other tasks sharing this mm, we do not
+	 * have anything to reap and the task might then get stuck waiting
+	 * for parent as zombie and we do not want it to hold TIF_MEMDIE
+	 */
+	p = find_lock_task_mm(task);
+	if (!p)
 		return false;
 
+	if (!__task_will_free_mem(p)) {
+		task_unlock(p);
+		return false;
+	}
+
+	/*
+	 * Check whether there are other processes sharing the mm - they all have
+	 * to be killed or exiting.
+	 */
+	if (atomic_read(&p->mm->mm_users) > get_nr_threads(p)) {
+		mm = p->mm;
+		/* pin the mm to not get freed and reused */
+		atomic_inc(&mm->mm_count);
+	}
+	task_unlock(p);
+
+	if (mm) {
+		rcu_read_lock();
+		for_each_process(p) {
+			bool vfork;
+
+			/*
+			 * skip over vforked tasks because they are mostly
+			 * independent and will drop the mm soon
+			 */
+			task_lock(p);
+			vfork = p->vfork_done;
+			task_unlock(p);
+			if (vfork)
+				continue;
+
+			if (!__task_will_free_mem(p))
+				break;
+		}
+		rcu_read_unlock();
+		mmdrop(mm);
+	}
+
 	return true;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f6477a9dbe7a..878a4308164c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1273,9 +1273,9 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
index 008c5b4732de..428e34df9f49 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -573,7 +573,7 @@ static int oom_reaper(void *unused)
 	return 0;
 }
 
-static void wake_oom_reaper(struct task_struct *tsk)
+void wake_oom_reaper(struct task_struct *tsk)
 {
 	if (!oom_reaper_th)
 		return;
@@ -594,50 +594,6 @@ static void wake_oom_reaper(struct task_struct *tsk)
 /* Check if we can reap the given task. This has to be called with stable
  * tsk->mm
  */
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
-			bool exiting;
-
-			if (!process_shares_mm(p, mm))
-				continue;
-			if (same_thread_group(p, tsk))
-				continue;
-			if (fatal_signal_pending(p))
-				continue;
-
-			/*
-			 * If the task is exiting make sure the whole thread group
-			 * is exiting and cannot acces mm anymore.
-			 */
-			spin_lock_irq(&p->sighand->siglock);
-			exiting = signal_group_exit(p->signal);
-			spin_unlock_irq(&p->sighand->siglock);
-			if (exiting)
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
@@ -649,10 +605,6 @@ static int __init oom_init(void)
 	return 0;
 }
 subsys_initcall(oom_init)
-#else
-static void wake_oom_reaper(struct task_struct *tsk)
-{
-}
 #endif
 
 /**
@@ -750,15 +702,12 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
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
 		dump_header(oc, p, memcg);
@@ -945,14 +894,10 @@ bool out_of_memory(struct oom_control *oc)
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
