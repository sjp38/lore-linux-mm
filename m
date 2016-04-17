Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B0F3F6B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 07:54:26 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id d19so96691207lfb.0
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 04:54:26 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ch4si26255145wjb.189.2016.04.17.04.54.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Apr 2016 04:54:25 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id y144so17230841wmd.0
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 04:54:25 -0700 (PDT)
Date: Sun, 17 Apr 2016 07:54:22 -0400
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm, oom_reaper: clear TIF_MEMDIE for all tasks
 queued for oom_reaper
Message-ID: <20160417115422.GA21757@dhcp22.suse.cz>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
 <1459951996-12875-4-git-send-email-mhocko@kernel.org>
 <201604072055.GAI52128.tHLVOFJOQMFOFS@I-love.SAKURA.ne.jp>
 <20160408113425.GF29820@dhcp22.suse.cz>
 <201604161151.ECG35947.FFLtSFVQJOHOOM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604161151.ECG35947.FFLtSFVQJOHOOM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

On Sat 16-04-16 11:51:11, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 07-04-16 20:55:34, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > The first obvious one is when the oom victim clears its mm and gets
> > > > stuck later on. oom_reaper would back of on find_lock_task_mm returning
> > > > NULL. We can safely try to clear TIF_MEMDIE in this case because such a
> > > > task would be ignored by the oom killer anyway. The flag would be
> > > > cleared by that time already most of the time anyway.
> > > 
> > > I didn't understand what this wants to tell. The OOM victim will clear
> > > TIF_MEMDIE as soon as it sets current->mm = NULL.
> > 
> > No it clears the flag _after_ it returns from mmput. There is no
> > guarantee it won't get stuck somewhere on the way there - e.g. exit_aio
> > waits for completion and who knows what else might get stuck.
> 
> OK. Then, I think an OOM livelock scenario shown below is possible.
> 
>  (1) First OOM victim (where mm->mm_users == 1) is selected by the first
>      round of out_of_memory() call.
> 
>  (2) The OOM reaper calls atomic_inc_not_zero(&mm->mm_users).
> 
>  (3) The OOM victim calls mmput() from exit_mm() from do_exit().
>      mmput() returns immediately because atomic_dec_and_test(&mm->mm_users)
>      returns false because of (2).
> 
>  (4) The OOM reaper reaps memory and then calls mmput().
>      mmput() calls exit_aio() etc. and waits for completion because
>      atomic_dec_and_test(&mm->mm_users) is now true.
> 
>  (5) Second OOM victim (which is the parent of the first OOM victim)
>      is selected by the next round of out_of_memory() call.
> 
>  (6) The OOM reaper is waiting for completion of the first OOM victim's
>      memory while the second OOM victim is waiting for the OOM reaper to
>      reap memory.
> 
> Where is the guarantee that exit_aio() etc. called from mmput() by the
> OOM reaper does not depend on memory allocation (i.e. the OOM reaper is
> not blocked forever inside __oom_reap_task())?

You should realize that the mmput is called _after_ we have reclaimed
victim's address space. So there should be some memory freed by that
time which reduce the likelyhood of a lockup due to memory allocation
request if it is really needed for exit_aio.

But you have a good point here. We want to strive for robustness of
oom_reaper as much as possible. We have dropped the munlock patch because
of the robustness so I guess we want this to be fixed as well. The
reason for blocking might be different from memory pressure I guess.

Here is what should work - I have only compile tested it. I will prepare
the proper patch later this week with other oom reaper patches or after
I come back from LSF/MM.
---
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 624b78b848b8..5113e0e7e8ef 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -509,6 +509,7 @@ struct mm_struct {
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
index 44683a2f8fa7..65f2acbaad29 100644
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
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
