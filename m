Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 304AF6B0263
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:04:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so13229749wme.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:04:41 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id fo6si30155096wjc.131.2016.04.26.07.04.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 07:04:38 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n3so5360495wmn.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:04:38 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm, oom_reaper: do not mmput synchronously from the oom reaper context
Date: Tue, 26 Apr 2016 16:04:30 +0200
Message-Id: <1461679470-8364-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461679470-8364-1-git-send-email-mhocko@kernel.org>
References: <1461679470-8364-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo has properly noted that mmput slow path might get blocked waiting
for another party (e.g. exit_aio waits for an IO). If that happens the
oom_reaper would be put out of the way and will not be able to process
next oom victim. We should strive for making this context as reliable
and independent on other subsystems as much as possible.

Introduce mmput_async which will perform the slow path from an async
(WQ) context. This will delay the operation but that shouldn't be a
problem because the oom_reaper has reclaimed the victim's address space
for most cases as much as possible and the remaining context shouldn't
bind too much memory anymore. The only exception is when mmap_sem
trylock has failed which shouldn't happen too often.

The issue is only theoretical but not impossible.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm_types.h |  1 +
 include/linux/sched.h    |  5 +++++
 kernel/fork.c            | 50 +++++++++++++++++++++++++++++++++---------------
 mm/oom_kill.c            |  8 ++++++--
 4 files changed, 47 insertions(+), 17 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index bf4f3ac5110c..f4f477244679 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -513,6 +513,7 @@ struct mm_struct {
 #ifdef CONFIG_HUGETLB_PAGE
 	atomic_long_t hugetlb_usage;
 #endif
+	struct work_struct async_put_work;
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7bd0fa9db199..df8778e72211 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2604,6 +2604,11 @@ static inline void mmdrop(struct mm_struct * mm)
 
 /* mmput gets rid of the mappings and all user-space */
 extern void mmput(struct mm_struct *);
+/* same as above but performs the slow path from the async kontext. Can
+ * be called from the atomic context as well
+ */
+extern void mmput_async(struct mm_struct *);
+
 /* Grab a reference to a task's mm, if it is not already going away */
 extern struct mm_struct *get_task_mm(struct task_struct *task);
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index accb7221d547..10b0f771d795 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -696,6 +696,26 @@ void __mmdrop(struct mm_struct *mm)
 }
 EXPORT_SYMBOL_GPL(__mmdrop);
 
+static inline void __mmput(struct mm_struct *mm)
+{
+	VM_BUG_ON(atomic_read(&mm->mm_users));
+
+	uprobe_clear_state(mm);
+	exit_aio(mm);
+	ksm_exit(mm);
+	khugepaged_exit(mm); /* must run before exit_mmap */
+	exit_mmap(mm);
+	set_mm_exe_file(mm, NULL);
+	if (!list_empty(&mm->mmlist)) {
+		spin_lock(&mmlist_lock);
+		list_del(&mm->mmlist);
+		spin_unlock(&mmlist_lock);
+	}
+	if (mm->binfmt)
+		module_put(mm->binfmt->module);
+	mmdrop(mm);
+}
+
 /*
  * Decrement the use count and release all resources for an mm.
  */
@@ -703,24 +723,24 @@ void mmput(struct mm_struct *mm)
 {
 	might_sleep();
 
+	if (atomic_dec_and_test(&mm->mm_users))
+		__mmput(mm);
+}
+EXPORT_SYMBOL_GPL(mmput);
+
+static void mmput_async_fn(struct work_struct *work)
+{
+	struct mm_struct *mm = container_of(work, struct mm_struct, async_put_work);
+	__mmput(mm);
+}
+
+void mmput_async(struct mm_struct *mm)
+{
 	if (atomic_dec_and_test(&mm->mm_users)) {
-		uprobe_clear_state(mm);
-		exit_aio(mm);
-		ksm_exit(mm);
-		khugepaged_exit(mm); /* must run before exit_mmap */
-		exit_mmap(mm);
-		set_mm_exe_file(mm, NULL);
-		if (!list_empty(&mm->mmlist)) {
-			spin_lock(&mmlist_lock);
-			list_del(&mm->mmlist);
-			spin_unlock(&mmlist_lock);
-		}
-		if (mm->binfmt)
-			module_put(mm->binfmt->module);
-		mmdrop(mm);
+		INIT_WORK(&mm->async_put_work, mmput_async_fn);
+		schedule_work(&mm->async_put_work);
 	}
 }
-EXPORT_SYMBOL_GPL(mmput);
 
 /**
  * set_mm_exe_file - change a reference to the mm's executable file
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c0376efa79ec..c0e37dd1422f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -446,7 +446,6 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
-
 static bool __oom_reap_task(struct task_struct *tsk)
 {
 	struct mmu_gather tlb;
@@ -520,7 +519,12 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 */
 	set_bit(MMF_OOM_REAPED, &mm->flags);
 out:
-	mmput(mm);
+	/*
+	 * Drop our reference but make sure the mmput slow path is called from a
+	 * different context because we shouldn't risk we get stuck there and
+	 * put the oom_reaper out of the way.
+	 */
+	mmput_async(mm);
 	return ret;
 }
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
