Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 44D4A6B000D
	for <linux-mm@kvack.org>; Sat,  4 Aug 2018 09:30:15 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 132-v6so3743171pga.18
        for <linux-mm@kvack.org>; Sat, 04 Aug 2018 06:30:15 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 2-v6si7850000pgq.479.2018.08.04.06.30.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Aug 2018 06:30:12 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 2/4] mm, oom: Check pending victims earlier in out_of_memory().
Date: Sat,  4 Aug 2018 22:29:44 +0900
Message-Id: <1533389386-3501-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>

Regarding CONFIG_MMU=y case, we have a list of inflight OOM victim threads
which are chained to oom_reaper_list. Therefore, by doing the same thing
for CONFIG_MMU=n case, we can check whether there are inflight OOM victims
before starting process/memcg list traversal. Since it is likely that only
few threads are chained to oom_reaper_list, checking all victims' OOM
domain will not matter.

Thus, check whether there are inflight OOM victims before starting
process/memcg list traversal. To do so, we need to chain OOM victims until
MMF_OOM_SKIP is set. Thus, this patch changes the OOM reaper to wait for
an request from the OOM killer using oom_reap_target variable. This change
allows the OOM reaper to preferentially reclaim from mm which the OOM
killer is waiting for the OOM reaper to reclaim.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>
---
 include/linux/oom.h   |  1 +
 include/linux/sched.h |  4 +--
 kernel/fork.c         |  2 ++
 mm/oom_kill.c         | 97 +++++++++++++++++++++++++++++----------------------
 4 files changed, 60 insertions(+), 44 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 69864a5..4a147871 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -104,6 +104,7 @@ extern unsigned long oom_badness(struct task_struct *p,
 extern bool out_of_memory(struct oom_control *oc);
 
 extern void exit_oom_victim(void);
+extern void exit_oom_mm(struct mm_struct *mm);
 
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 9e686dc..589fe78 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1173,9 +1173,7 @@ struct task_struct {
 	unsigned long			task_state_change;
 #endif
 	int				pagefault_disabled;
-#ifdef CONFIG_MMU
-	struct task_struct		*oom_reaper_list;
-#endif
+	struct list_head		oom_victim_list;
 #ifdef CONFIG_VMAP_STACK
 	struct vm_struct		*stack_vm_area;
 #endif
diff --git a/kernel/fork.c b/kernel/fork.c
index 276fdc6..ba1260d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1010,6 +1010,8 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+	if (unlikely(mm_is_oom_victim(mm)))
+		exit_oom_mm(mm);
 	mmdrop(mm);
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dad0409..a743a8e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -321,18 +321,6 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 		goto next;
 
 	/*
-	 * This task already has access to memory reserves and is being killed.
-	 * Don't allow any other task to have access to the reserves unless
-	 * the task has MMF_OOM_SKIP because chances that it would release
-	 * any memory is quite low.
-	 */
-	if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
-		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
-			goto next;
-		goto abort;
-	}
-
-	/*
 	 * If task is allocating a lot of memory and has been marked to be
 	 * killed first if it triggers an oom, then select it.
 	 */
@@ -356,11 +344,6 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	oc->chosen_points = points;
 next:
 	return 0;
-abort:
-	if (oc->chosen)
-		put_task_struct(oc->chosen);
-	oc->chosen = (void *)-1UL;
-	return 1;
 }
 
 /*
@@ -478,6 +461,8 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 	return false;
 }
 
+static LIST_HEAD(oom_victim_list);
+
 #ifdef CONFIG_MMU
 /*
  * OOM Reaper kernel thread which tries to reap the memory used by the OOM
@@ -485,7 +470,7 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  */
 static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
+static struct task_struct *oom_reap_target;
 
 bool __oom_reap_task_mm(struct mm_struct *mm)
 {
@@ -598,33 +583,21 @@ static void oom_reap_task(struct task_struct *tsk)
 	debug_show_all_locks();
 
 done:
-	tsk->oom_reaper_list = NULL;
-
 	/*
 	 * Hide this mm from OOM killer because it has been either reaped or
 	 * somebody can't call up_write(mmap_sem).
 	 */
 	set_bit(MMF_OOM_SKIP, &mm->flags);
-
-	/* Drop a reference taken by mark_oom_victim(). */
-	put_task_struct(tsk);
 }
 
 static int oom_reaper(void *unused)
 {
 	while (true) {
-		struct task_struct *tsk = NULL;
-
-		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
-		mutex_lock(&oom_lock);
-		if (oom_reaper_list != NULL) {
-			tsk = oom_reaper_list;
-			oom_reaper_list = tsk->oom_reaper_list;
-		}
-		mutex_unlock(&oom_lock);
-
-		if (tsk)
-			oom_reap_task(tsk);
+		wait_event_freezable(oom_reaper_wait, oom_reap_target != NULL);
+		oom_reap_task(oom_reap_target);
+		/* Drop a reference taken by oom_has_pending_victims(). */
+		put_task_struct(oom_reap_target);
+		oom_reap_target = NULL;
 	}
 
 	return 0;
@@ -661,13 +634,8 @@ static void mark_oom_victim(struct task_struct *tsk)
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
 		mmgrab(tsk->signal->oom_mm);
 		set_bit(MMF_OOM_VICTIM, &mm->flags);
-#ifdef CONFIG_MMU
 		get_task_struct(tsk);
-		tsk->oom_reaper_list = oom_reaper_list;
-		oom_reaper_list = tsk;
-		trace_wake_reaper(tsk->pid);
-		wake_up(&oom_reaper_wait);
-#endif
+		list_add(&tsk->oom_victim_list, &oom_victim_list);
 	}
 
 	/*
@@ -681,6 +649,21 @@ static void mark_oom_victim(struct task_struct *tsk)
 	trace_mark_victim(tsk->pid);
 }
 
+void exit_oom_mm(struct mm_struct *mm)
+{
+	struct task_struct *p, *tmp;
+
+	mutex_lock(&oom_lock);
+	list_for_each_entry_safe(p, tmp, &oom_victim_list, oom_victim_list) {
+		if (mm != p->signal->oom_mm)
+			continue;
+		list_del(&p->oom_victim_list);
+		/* Drop a reference taken by mark_oom_victim(). */
+		put_task_struct(p);
+	}
+	mutex_unlock(&oom_lock);
+}
+
 /**
  * exit_oom_victim - note the exit of an OOM victim
  */
@@ -1020,6 +1003,35 @@ int unregister_oom_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
+static bool oom_has_pending_victims(struct oom_control *oc)
+{
+	struct task_struct *p;
+
+	if (is_sysrq_oom(oc))
+		return false;
+	/*
+	 * Since oom_reap_task()/exit_mmap() will set MMF_OOM_SKIP, let's
+	 * wait for pending victims until MMF_OOM_SKIP is set or __mmput()
+	 * completes.
+	 */
+	list_for_each_entry(p, &oom_victim_list, oom_victim_list) {
+		if (oom_unkillable_task(p, oc->memcg, oc->nodemask))
+			continue;
+		if (!test_bit(MMF_OOM_SKIP, &p->signal->oom_mm->flags)) {
+#ifdef CONFIG_MMU
+			if (!oom_reap_target) {
+				get_task_struct(p);
+				oom_reap_target = p;
+				trace_wake_reaper(p->pid);
+				wake_up(&oom_reaper_wait);
+			}
+#endif
+			return true;
+		}
+	}
+	return false;
+}
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  * @oc: pointer to struct oom_control
@@ -1072,6 +1084,9 @@ bool out_of_memory(struct oom_control *oc)
 		oc->nodemask = NULL;
 	check_panic_on_oom(oc, constraint);
 
+	if (oom_has_pending_victims(oc))
+		return true;
+
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
 	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
-- 
1.8.3.1
