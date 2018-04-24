Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B69BD6B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 22:31:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f19so11944080pfn.6
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 19:31:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m65sor4063852pfk.139.2018.04.23.19.31.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 19:31:09 -0700 (PDT)
Date: Mon, 23 Apr 2018 19:31:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaperunmap
In-Reply-To: <201804221248.CHE35432.FtOMOLSHOFJFVQ@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.21.1804231706340.18716@chino.kir.corp.google.com>
References: <20180419063556.GK17484@dhcp22.suse.cz> <alpine.DEB.2.21.1804191214130.157851@chino.kir.corp.google.com> <20180420082349.GW17484@dhcp22.suse.cz> <20180420124044.GA17484@dhcp22.suse.cz> <alpine.DEB.2.21.1804212019400.84222@chino.kir.corp.google.com>
 <201804221248.CHE35432.FtOMOLSHOFJFVQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 22 Apr 2018, Tetsuo Handa wrote:

> > I'm wondering why you do not see oom killing of many processes if the 
> > victim is a very large process that takes a long time to free memory in 
> > exit_mmap() as I do because the oom reaper gives up trying to acquire 
> > mm->mmap_sem and just sets MMF_OOM_SKIP itself.
> > 
> 
> We can call __oom_reap_task_mm() from exit_mmap() (or __mmput()) before
> exit_mmap() holds mmap_sem for write. Then, at least memory which could
> have been reclaimed if exit_mmap() did not hold mmap_sem for write will
> be guaranteed to be reclaimed before MMF_OOM_SKIP is set.
> 

I think that's an exceptionally good idea and will mitigate the concerns 
of others.

It can be done without holding mm->mmap_sem in exit_mmap() and uses the 
same criteria that the oom reaper uses to set MMF_OOM_SKIP itself, so we 
don't get dozens of unnecessary oom kills.

What do you think about this?  It passes preliminary testing on powerpc 
and I'm enqueued it for much more intensive testing.  (I'm wishing there 
was a better way to acknowledge your contribution to fixing this issue, 
especially since you brought up the exact problem this is addressing in 
previous emails.)


mm, oom: fix concurrent munlock and oom reaper unmap

Since exit_mmap() is done without the protection of mm->mmap_sem, it is
possible for the oom reaper to concurrently operate on an mm until
MMF_OOM_SKIP is set.

This allows munlock_vma_pages_all() to concurrently run while the oom
reaper is operating on a vma.  Since munlock_vma_pages_range() depends on
clearing VM_LOCKED from vm_flags before actually doing the munlock to
determine if any other vmas are locking the same memory, the check for
VM_LOCKED in the oom reaper is racy.

This is especially noticeable on architectures such as powerpc where
clearing a huge pmd requires serialize_against_pte_lookup().  If the pmd
is zapped by the oom reaper during follow_page_mask() after the check for
pmd_none() is bypassed, this ends up deferencing a NULL ptl.

Fix this by manually freeing all possible memory from the mm before doing
the munlock and then setting MMF_OOM_SKIP.  The oom reaper can not run on
the mm anymore so the munlock is safe to do in exit_mmap().  It also
matches the logic that the oom reaper currently uses for determining when
to set MMF_OOM_SKIP itself, so there's no new risk of excessive oom
killing.

Fixes: 212925802454 ("mm: oom: let oom_reap_task and exit_mmap run concurrently")
Cc: stable@vger.kernel.org [4.14+]
Suggested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/oom.h |  2 ++
 mm/mmap.c           | 39 ++++++++++++----------
 mm/oom_kill.c       | 81 ++++++++++++++++++++++++---------------------
 3 files changed, 66 insertions(+), 56 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -95,6 +95,8 @@ static inline int check_stable_address_space(struct mm_struct *mm)
 	return 0;
 }
 
+void __oom_reap_task_mm(struct mm_struct *mm);
+
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3015,6 +3015,27 @@ void exit_mmap(struct mm_struct *mm)
 	/* mm's last user has gone, and its about to be pulled down */
 	mmu_notifier_release(mm);
 
+	if (unlikely(mm_is_oom_victim(mm))) {
+		/*
+		 * Manually reap the mm to free as much memory as possible.
+		 * Then, as the oom reaper, set MMF_OOM_SKIP to disregard this
+		 * mm from further consideration.  Taking mm->mmap_sem for write
+		 * after setting MMF_OOM_SKIP will guarantee that the oom reaper
+		 * will not run on this mm again after mmap_sem is dropped.
+		 *
+		 * This needs to be done before calling munlock_vma_pages_all(),
+		 * which clears VM_LOCKED, otherwise the oom reaper cannot
+		 * reliably test it.
+		 */
+		mutex_lock(&oom_lock);
+		__oom_reap_task_mm(mm);
+		mutex_unlock(&oom_lock);
+
+		set_bit(MMF_OOM_SKIP, &mm->flags);
+		down_write(&mm->mmap_sem);
+		up_write(&mm->mmap_sem);
+	}
+
 	if (mm->locked_vm) {
 		vma = mm->mmap;
 		while (vma) {
@@ -3036,24 +3057,6 @@ void exit_mmap(struct mm_struct *mm)
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
-
-	if (unlikely(mm_is_oom_victim(mm))) {
-		/*
-		 * Wait for oom_reap_task() to stop working on this
-		 * mm. Because MMF_OOM_SKIP is already set before
-		 * calling down_read(), oom_reap_task() will not run
-		 * on this "mm" post up_write().
-		 *
-		 * mm_is_oom_victim() cannot be set from under us
-		 * either because victim->mm is already set to NULL
-		 * under task_lock before calling mmput and oom_mm is
-		 * set not NULL by the OOM killer only if victim->mm
-		 * is found not NULL while holding the task_lock.
-		 */
-		set_bit(MMF_OOM_SKIP, &mm->flags);
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
-	}
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -469,7 +469,6 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 	return false;
 }
 
-
 #ifdef CONFIG_MMU
 /*
  * OOM Reaper kernel thread which tries to reap the memory used by the OOM
@@ -480,16 +479,54 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
-static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
+void __oom_reap_task_mm(struct mm_struct *mm)
 {
-	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
+
+	/*
+	 * Tell all users of get_user/copy_from_user etc... that the content
+	 * is no longer stable. No barriers really needed because unmapping
+	 * should imply barriers already and the reader would hit a page fault
+	 * if it stumbled over a reaped memory.
+	 */
+	set_bit(MMF_UNSTABLE, &mm->flags);
+
+	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
+		if (!can_madv_dontneed_vma(vma))
+			continue;
+
+		/*
+		 * Only anonymous pages have a good chance to be dropped
+		 * without additional steps which we cannot afford as we
+		 * are OOM already.
+		 *
+		 * We do not even care about fs backed pages because all
+		 * which are reclaimable have already been reclaimed and
+		 * we do not want to block exit_mmap by keeping mm ref
+		 * count elevated without a good reason.
+		 */
+		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
+			const unsigned long start = vma->vm_start;
+			const unsigned long end = vma->vm_end;
+			struct mmu_gather tlb;
+
+			tlb_gather_mmu(&tlb, mm, start, end);
+			mmu_notifier_invalidate_range_start(mm, start, end);
+			unmap_page_range(&tlb, vma, start, end, NULL);
+			mmu_notifier_invalidate_range_end(mm, start, end);
+			tlb_finish_mmu(&tlb, start, end);
+		}
+	}
+}
+
+static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
+{
 	bool ret = true;
 
 	/*
 	 * We have to make sure to not race with the victim exit path
 	 * and cause premature new oom victim selection:
-	 * __oom_reap_task_mm		exit_mm
+	 * oom_reap_task_mm		exit_mm
 	 *   mmget_not_zero
 	 *				  mmput
 	 *				    atomic_dec_and_test
@@ -534,39 +571,8 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 
 	trace_start_task_reaping(tsk->pid);
 
-	/*
-	 * Tell all users of get_user/copy_from_user etc... that the content
-	 * is no longer stable. No barriers really needed because unmapping
-	 * should imply barriers already and the reader would hit a page fault
-	 * if it stumbled over a reaped memory.
-	 */
-	set_bit(MMF_UNSTABLE, &mm->flags);
-
-	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
-		if (!can_madv_dontneed_vma(vma))
-			continue;
+	__oom_reap_task_mm(mm);
 
-		/*
-		 * Only anonymous pages have a good chance to be dropped
-		 * without additional steps which we cannot afford as we
-		 * are OOM already.
-		 *
-		 * We do not even care about fs backed pages because all
-		 * which are reclaimable have already been reclaimed and
-		 * we do not want to block exit_mmap by keeping mm ref
-		 * count elevated without a good reason.
-		 */
-		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
-			const unsigned long start = vma->vm_start;
-			const unsigned long end = vma->vm_end;
-
-			tlb_gather_mmu(&tlb, mm, start, end);
-			mmu_notifier_invalidate_range_start(mm, start, end);
-			unmap_page_range(&tlb, vma, start, end, NULL);
-			mmu_notifier_invalidate_range_end(mm, start, end);
-			tlb_finish_mmu(&tlb, start, end);
-		}
-	}
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 			task_pid_nr(tsk), tsk->comm,
 			K(get_mm_counter(mm, MM_ANONPAGES)),
@@ -587,14 +593,13 @@ static void oom_reap_task(struct task_struct *tsk)
 	struct mm_struct *mm = tsk->signal->oom_mm;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
+	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts <= MAX_OOM_REAP_RETRIES ||
 	    test_bit(MMF_OOM_SKIP, &mm->flags))
 		goto done;
 
-
 	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 		task_pid_nr(tsk), tsk->comm);
 	debug_show_all_locks();
