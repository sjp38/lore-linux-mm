Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A55C6B0253
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 05:11:53 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id s10so5501072oth.14
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 02:11:53 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c16si2291361oib.474.2017.12.08.02.11.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 02:11:51 -0800 (PST)
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with exit_mmap
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com>
	<20171207113548.GG20234@dhcp22.suse.cz>
	<201712080044.BID56711.FFVOLMStJOQHOF@I-love.SAKURA.ne.jp>
	<20171207163003.GM20234@dhcp22.suse.cz>
In-Reply-To: <20171207163003.GM20234@dhcp22.suse.cz>
Message-Id: <201712081911.HIH69766.FLMSJOOVOQFHtF@I-love.SAKURA.ne.jp>
Date: Fri, 8 Dec 2017 19:11:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, aarcange@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> On Fri 08-12-17 00:44:11, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > David, could you test with this patch please?
> > 
> > Even if this patch solved David's case, you need to update
> > 
> > 	 * tsk_is_oom_victim() cannot be set from under us
> > 	 * either because current->mm is already set to NULL
> > 	 * under task_lock before calling mmput and oom_mm is
> > 	 * set not NULL by the OOM killer only if current->mm
> > 	 * is found not NULL while holding the task_lock.
> > 
> > part as well, for it is the explanation of why
> > tsk_is_oom_victim() test was expected to work.
> 
> Yes, the same applies for mm_is_oom_victim. I will fixup s@tsk_@mm_@
> here.
> 

If you try to "s@tsk_@mm_@", I suggest doing

----------
 mm/mmap.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 68fdd14..b2cb4e5 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3025,12 +3025,6 @@ void exit_mmap(struct mm_struct *mm)
 		 * mm. Because MMF_OOM_SKIP is already set before
 		 * calling down_read(), oom_reap_task() will not run
 		 * on this "mm" post up_write().
-		 *
-		 * mm_is_oom_victim() cannot be set from under us
-		 * either because current->mm is already set to NULL
-		 * under task_lock before calling mmput and oom_mm is
-		 * set not NULL by the OOM killer only if current->mm
-		 * is found not NULL while holding the task_lock.
 		 */
 		set_bit(MMF_OOM_SKIP, &mm->flags);
 		down_write(&mm->mmap_sem);
----------

because current->mm and current->signal->oom_mm are irrelevant for
the reason to set MMF_OOM_SKIP here. What matters here is that this
mm's ->mmap must not be accessed by the OOM reaper afterwards. (And
I think we can do mm->mmap = NULL instead of setting MMF_OOM_SKIP.
Then, we can defer setting MMF_OOM_SKIP until "the OOM reaper gave up
waiting for __mmput()" or "__mmput() became ready to call mmdrop()"
whichever occurred first.)

I think we can try changes shown below for

 (1) Allowing __oom_reap_task_mm() to run without oom_lock held.
     (Because start OOM reaping without waiting for oom_lock can mitigate
     unexpected stalls due to schedule_timeout_killable(1) with oom_lock
     held. Though, root cause of the stall is that we can't guarantee that
     enough CPU resource is given to a thread holding oom_lock.)

     Also, we could offload __oom_reap_task_mm() to some WQ_MEM_RECLAIM
     workqueue in order to allow reclaiming memory in parallel when many
     victims are waiting for OOM reaping.

 (2) Guarantee that last second allocation at __alloc_pages_may_oom()
     is attempted after confirming that there is no victim's mm without
     MMF_OOM_SKIP set. (Because moving last second allocation to after
     select_bad_process() was rejected. Though, doing last second
     allocation attempt after select_bad_process() can allow us to
     eliminate oom_lock taken in the changes shown below...)

 (3) Guarantee that MMF_OOM_SKIP is set at __mmput(). (Because this was
     an unexpected change for CONFIG_MMU=n.)

----------
 kernel/fork.c |  6 ++++++
 mm/mmap.c     |  9 ++-------
 mm/oom_kill.c | 49 ++++++++++---------------------------------------
 3 files changed, 18 insertions(+), 46 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 432eadf..dd1d69e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -931,6 +931,12 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+	if (unlikely(mm_is_oom_victim(mm))) {
+		/* Tell select_bad_process() to start selecting next mm. */
+		mutex_lock(&oom_lock);
+		set_bit(MMF_OOM_SKIP, &mm->flags);
+		mutex_unlock(&oom_lock);
+	}
 	mmdrop(mm);
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index b2cb4e5..641b5c1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3020,14 +3020,9 @@ void exit_mmap(struct mm_struct *mm)
 	unmap_vmas(&tlb, vma, 0, -1);
 
 	if (unlikely(mm_is_oom_victim(mm))) {
-		/*
-		 * Wait for oom_reap_task() to stop working on this
-		 * mm. Because MMF_OOM_SKIP is already set before
-		 * calling down_read(), oom_reap_task() will not run
-		 * on this "mm" post up_write().
-		 */
-		set_bit(MMF_OOM_SKIP, &mm->flags);
+		/* Tell oom_reap_task() to stop working on this mm. */
 		down_write(&mm->mmap_sem);
+		mm->mmap = NULL;
 		up_write(&mm->mmap_sem);
 	}
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 29f8555..ec5303d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -489,28 +489,10 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	bool ret = true;
-
-	/*
-	 * We have to make sure to not race with the victim exit path
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
-	 */
-	mutex_lock(&oom_lock);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
 		trace_skip_task_reaping(tsk->pid);
-		goto unlock_oom;
+		return false;
 	}
 
 	/*
@@ -525,19 +507,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	if (mm_has_notifiers(mm)) {
 		up_read(&mm->mmap_sem);
 		schedule_timeout_idle(HZ);
-		goto unlock_oom;
-	}
-
-	/*
-	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
-	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
-	 * under mmap_sem for reading because it serializes against the
-	 * down_write();up_write() cycle in exit_mmap().
-	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
-		up_read(&mm->mmap_sem);
-		trace_skip_task_reaping(tsk->pid);
-		goto unlock_oom;
+		return true;
 	}
 
 	trace_start_task_reaping(tsk->pid);
@@ -550,6 +520,10 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	set_bit(MMF_UNSTABLE, &mm->flags);
 
+	/*
+	 * exit_mmap() sets mm->mmap to NULL with mm->mmap_sem held for write
+	 * if I need to stop working on this mm.
+	 */
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
 		if (!can_madv_dontneed_vma(vma))
 			continue;
@@ -579,9 +553,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	up_read(&mm->mmap_sem);
 
 	trace_finish_task_reaping(tsk->pid);
-unlock_oom:
-	mutex_unlock(&oom_lock);
-	return ret;
+	return true;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
@@ -605,11 +577,10 @@ static void oom_reap_task(struct task_struct *tsk)
 done:
 	tsk->oom_reaper_list = NULL;
 
-	/*
-	 * Hide this mm from OOM killer because it has been either reaped or
-	 * somebody can't call up_write(mmap_sem).
-	 */
+	/* Tell select_bad_process() to start selecting next mm. */
+	mutex_lock(&oom_lock);
 	set_bit(MMF_OOM_SKIP, &mm->flags);
+	mutex_unlock(&oom_lock);
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
