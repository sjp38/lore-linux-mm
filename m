Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D45946B0356
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 02:48:25 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 79so1402708ioi.10
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 23:48:25 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c184sor1339270itg.7.2017.12.05.23.48.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Dec 2017 23:48:24 -0800 (PST)
Date: Tue, 5 Dec 2017 23:48:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with
 exit_mmap
In-Reply-To: <201712060328.vB63SrDK069830@www262.sakura.ne.jp>
Message-ID: <alpine.DEB.2.10.1712052323170.119719@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com> <alpine.DEB.2.10.1712051857450.98120@chino.kir.corp.google.com> <201712060328.vB63SrDK069830@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 6 Dec 2017, Tetsuo Handa wrote:

> > > One way to solve the issue is to have two mm flags: one to indicate the mm 
> > > is entering unmap_vmas(): set the flag, do down_write(&mm->mmap_sem); 
> > > up_write(&mm->mmap_sem), then unmap_vmas().  The oom reaper needs this 
> > > flag clear, not MMF_OOM_SKIP, while holding down_read(&mm->mmap_sem) to be 
> > > allowed to call unmap_page_range().  The oom killer will still defer 
> > > selecting this victim for MMF_OOM_SKIP after unmap_vmas() returns.
> > > 
> > > The result of that change would be that we do not oom reap from any mm 
> > > entering unmap_vmas(): we let unmap_vmas() do the work itself and avoid 
> > > racing with it.
> > > 
> > 
> > I think we need something like the following?
> 
> This patch does not work. __oom_reap_task_mm() can find MMF_REAPING and
> return true and sets MMF_OOM_SKIP before exit_mmap() calls down_write().
> 

Ah, you're talking about oom_reap_task() setting MMF_OOM_SKIP prematurely 
and allowing for additional oom kills?  I see your point, but I was mainly 
focused on preventing the panic as the first order of business.  We could 
certainly fix oom_reap_task() to not set MMF_OOM_SKIP itself and rather 
leave that to exit_mmap() if it finds MMF_REAPING if your concern matches 
my understanding.

> Also, I don't know what exit_mmap() is doing but I think that there is a
> possibility that the OOM reaper tries to reclaim mlocked pages as soon as
> exit_mmap() cleared VM_LOCKED flag by calling munlock_vma_pages_all().
> 
> 	if (mm->locked_vm) {
> 		vma = mm->mmap;
> 		while (vma) {
> 			if (vma->vm_flags & VM_LOCKED)
> 				munlock_vma_pages_all(vma);
> 			vma = vma->vm_next;
> 		}
> 	}
> 

Yes, that looks possible as well, although the problem I have reported can 
happen with or without mlock.  Did you find this by code inspection or 
have you experienced runtime problems with it?

I think this argues to do MMF_REAPING-style behavior at the beginning of 
exit_mmap() and avoid reaping all together once we have reached that 
point.  There are no more users of the mm and we are in the process of 
tearing it down, I'm not sure that the oom reaper should be in the 
business with trying to interfere with that.  Or are there actual bug 
reports where an oom victim gets wedged while in exit_mmap() prior to 
releasing its memory?

I know this conflicts with your patches in -mm to remove the oom mutex, 
but I think we should make sure we can prevent crashes before cleaning it 
up.

(I also noticed that the mm_has_notifiers() check is missing a 
trace_skip_task_reaping(tsk->pid))
---
diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
--- a/include/linux/sched/coredump.h
+++ b/include/linux/sched/coredump.h
@@ -70,6 +70,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_UNSTABLE		22	/* mm is unstable for copy_from_user */
 #define MMF_HUGE_ZERO_PAGE	23      /* mm has ever used the global huge zero page */
 #define MMF_DISABLE_THP		24	/* disable THP for all VMAs */
+#define MMF_REAPING		25	/* mm is undergoing reaping */
 #define MMF_DISABLE_THP_MASK	(1 << MMF_DISABLE_THP)
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2996,6 +2996,23 @@ void exit_mmap(struct mm_struct *mm)
 
 	/* mm's last user has gone, and its about to be pulled down */
 	mmu_notifier_release(mm);
+	set_bit(MMF_REAPING, &mm->flags);
+	if (unlikely(tsk_is_oom_victim(current))) {
+		/*
+		 * Wait for oom_reap_task() to stop working on this
+		 * mm. Because MMF_REAPING is already set before
+		 * calling down_read(), oom_reap_task() will not run
+		 * on this "mm" post up_write().
+		 *
+		 * tsk_is_oom_victim() cannot be set from under us
+		 * either because current->mm is already set to NULL
+		 * under task_lock before calling mmput and oom_mm is
+		 * set not NULL by the OOM killer only if current->mm
+		 * is found not NULL while holding the task_lock.
+		 */
+		down_write(&mm->mmap_sem);
+		up_write(&mm->mmap_sem);
+	}
 
 	if (mm->locked_vm) {
 		vma = mm->mmap;
@@ -3018,26 +3035,9 @@ void exit_mmap(struct mm_struct *mm)
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
-
-	set_bit(MMF_OOM_SKIP, &mm->flags);
-	if (unlikely(tsk_is_oom_victim(current))) {
-		/*
-		 * Wait for oom_reap_task() to stop working on this
-		 * mm. Because MMF_OOM_SKIP is already set before
-		 * calling down_read(), oom_reap_task() will not run
-		 * on this "mm" post up_write().
-		 *
-		 * tsk_is_oom_victim() cannot be set from under us
-		 * either because current->mm is already set to NULL
-		 * under task_lock before calling mmput and oom_mm is
-		 * set not NULL by the OOM killer only if current->mm
-		 * is found not NULL while holding the task_lock.
-		 */
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
-	}
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -485,30 +485,29 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
-static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
+/*
+ * Returns 0 on success or
+ * 	-EAGAIN: mm->mmap_sem is contended
+ *	-EINVAL: mm is ineligible
+ */
+static int __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	bool ret = true;
+	int ret = 0;
 
 	/*
 	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * __oom_reap_task_mm		exit_mm
-	 *   mmget_not_zero
-	 *				  mmput
-	 *				    atomic_dec_and_test
-	 *				  exit_oom_victim
-	 *				[...]
-	 *				out_of_memory
-	 *				  select_bad_process
-	 *				    # no TIF_MEMDIE task selects new victim
-	 *  unmap_page_range # frees some memory
+	 * and cause premature new oom victim selection: if MMF_REAPING is
+	 * not set under the protection of mmap_sem, allow reaping because
+	 * exit_mmap() has not been entered, which is serialized with a
+	 * down_write();up_write() cycle.  Otherwise, leave reaping to
+	 * exit_mmap(), which will set MMF_OOM_SKIP itself.
 	 */
 	mutex_lock(&oom_lock);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
+		ret = -EAGAIN;
 		trace_skip_task_reaping(tsk->pid);
 		goto unlock_oom;
 	}
@@ -529,13 +528,14 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	}
 
 	/*
-	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
-	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
+	 * MMF_REAPING is set by exit_mmap when the OOM reaper can't
+	 * work on the mm anymore. The check for MMF_REAPING must run
 	 * under mmap_sem for reading because it serializes against the
 	 * down_write();up_write() cycle in exit_mmap().
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
+	if (test_bit(MMF_REAPING, &mm->flags)) {
 		up_read(&mm->mmap_sem);
+		ret = -EINVAL;
 		trace_skip_task_reaping(tsk->pid);
 		goto unlock_oom;
 	}
@@ -589,15 +589,18 @@ static void oom_reap_task(struct task_struct *tsk)
 {
 	int attempts = 0;
 	struct mm_struct *mm = tsk->signal->oom_mm;
+	int ret;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
+	while (attempts++ < MAX_OOM_REAP_RETRIES) {
+		ret = __oom_reap_task_mm(tsk, mm);
+		if (ret != -EAGAIN)
+			break;
 		schedule_timeout_idle(HZ/10);
-
+	}
 	if (attempts <= MAX_OOM_REAP_RETRIES)
 		goto done;
 
-
 	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 		task_pid_nr(tsk), tsk->comm);
 	debug_show_all_locks();
@@ -609,7 +612,8 @@ static void oom_reap_task(struct task_struct *tsk)
 	 * Hide this mm from OOM killer because it has been either reaped or
 	 * somebody can't call up_write(mmap_sem).
 	 */
-	set_bit(MMF_OOM_SKIP, &mm->flags);
+	if (ret != -EINVAL)
+		set_bit(MMF_OOM_SKIP, &mm->flags);
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
