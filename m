Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id BCA586B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 02:20:56 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g125-v6so6563727ita.0
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 23:20:56 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r9-v6si4141375itr.21.2018.07.12.23.20.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 23:20:54 -0700 (PDT)
Message-Id: <201807130620.w6D6KiAJ093010@www262.sakura.ne.jp>
Subject: Re: [patch -mm] mm, oom: remove =?ISO-2022-JP?B?b29tX2xvY2sgZnJvbSBleGl0?=
 =?ISO-2022-JP?B?X21tYXA=?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 13 Jul 2018 15:20:44 +0900
References: <alpine.DEB.2.21.1807121432370.170100@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1807121432370.170100@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

What a simplified description of oom_lock...

Positive effects

(1) Serialize "setting TIF_MEMDIE and calling __thaw_task()/atomic_inc() from
    mark_oom_victim()" and "setting oom_killer_disabled = true from
    oom_killer_disable()".

(2) Serialize all printk() messages from out_of_memory().

(3) Prevent from selecting new OOM victim when there is an !MMF_OOM_SKIP mm
    which current thread should wait for.

(4) Mutex blocking_notifier_call_chain() from out_of_memory() because some of
    callbacks might not be thread-safe and/or serialized call might release
    more memory than needed.

Negative effects

(A) Threads which called mutex_lock(&oom_lock) before calling out_of_memory()
    are blocked waiting for "__oom_reap_task_mm() from exit_mmap()" and/or
    "__oom_reap_task_mm() from oom_reap_task_mm()".

(B) Threads which do not call out_of_memory() because mutex_trylock(&oom_lock)
    failed continue consuming CPU resources pointlessly.

Regarding (A), we can reduce the range oom_lock serializes from
"__oom_reap_task_mm()" to "setting MMF_OOM_SKIP", for oom_lock is useful for (3).
Therefore, we can apply below change on top of your patch. But I don't like
sharing MMF_UNSBALE for two purposes (reason is explained below).

Regarding (B), we can do direct OOM reaping (like my proposal does).

---
 kernel/fork.c |  5 +++++
 mm/mmap.c     | 21 +++++++++------------
 mm/oom_kill.c | 57 ++++++++++++++++++++++-----------------------------------
 3 files changed, 36 insertions(+), 47 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 6747298..f37d481 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -984,6 +984,11 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+	if (unlikely(mm_is_oom_victim(mm))) {
+		mutex_lock(&oom_lock);
+		set_bit(MMF_OOM_SKIP, &mm->flags);
+		mutex_unlock(&oom_lock);
+	}
 	mmdrop(mm);
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 7f918eb..203061f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3075,19 +3075,17 @@ void exit_mmap(struct mm_struct *mm)
 		__oom_reap_task_mm(mm);
 
 		/*
-		 * Now, set MMF_UNSTABLE to avoid racing with the oom reaper.
-		 * This needs to be done before calling munlock_vma_pages_all(),
-		 * which clears VM_LOCKED, otherwise the oom reaper cannot
-		 * reliably test for it.  If the oom reaper races with
-		 * munlock_vma_pages_all(), this can result in a kernel oops if
-		 * a pmd is zapped, for example, after follow_page_mask() has
-		 * checked pmd_none().
+		 * Wait for the oom reaper to complete. This needs to be done
+		 * before calling munlock_vma_pages_all(), which clears
+		 * VM_LOCKED, otherwise the oom reaper cannot reliably test for
+		 * it. If the oom reaper races with munlock_vma_pages_all(),
+		 * this can result in a kernel oops if a pmd is zapped, for
+		 * example, after follow_page_mask() has checked pmd_none().
 		 *
-		 * Taking mm->mmap_sem for write after setting MMF_UNSTABLE will
-		 * guarantee that the oom reaper will not run on this mm again
-		 * after mmap_sem is dropped.
+		 * Taking mm->mmap_sem for write will guarantee that the oom
+		 * reaper will not run on this mm again after mmap_sem is
+		 * dropped.
 		 */
-		set_bit(MMF_UNSTABLE, &mm->flags);
 		down_write(&mm->mmap_sem);
 		up_write(&mm->mmap_sem);
 	}
@@ -3115,7 +3113,6 @@ void exit_mmap(struct mm_struct *mm)
 	unmap_vmas(&tlb, vma, 0, -1);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
-	set_bit(MMF_OOM_SKIP, &mm->flags);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index e6328ce..7ed4ed0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -488,11 +488,9 @@ void __oom_reap_task_mm(struct mm_struct *mm)
 	 * Tell all users of get_user/copy_from_user etc... that the content
 	 * is no longer stable. No barriers really needed because unmapping
 	 * should imply barriers already and the reader would hit a page fault
-	 * if it stumbled over a reaped memory. If MMF_UNSTABLE is already set,
-	 * reaping as already occurred so nothing left to do.
+	 * if it stumbled over a reaped memory.
 	 */
-	if (test_and_set_bit(MMF_UNSTABLE, &mm->flags))
-		return;
+	set_bit(MMF_UNSTABLE, &mm->flags);
 
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
 		if (!can_madv_dontneed_vma(vma))
@@ -524,25 +522,9 @@ void __oom_reap_task_mm(struct mm_struct *mm)
 
 static void oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
-	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * oom_reap_task_mm		exit_mm
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
-
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		trace_skip_task_reaping(tsk->pid);
-		goto out_oom;
+		return;
 	}
 
 	/*
@@ -555,10 +537,18 @@ static void oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 		goto out_mm;
 
 	/*
-	 * MMF_UNSTABLE is set by exit_mmap when the OOM reaper can't
-	 * work on the mm anymore. The check for MMF_UNSTABLE must run
-	 * under mmap_sem for reading because it serializes against the
-	 * down_write();up_write() cycle in exit_mmap().
+	 * MMF_UNSTABLE is set by the time exit_mmap() calls
+	 * munlock_vma_pages_all() in order to avoid race condition. The check
+	 * for MMF_UNSTABLE must run under mmap_sem for reading because it
+	 * serializes against the down_write();up_write() cycle in exit_mmap().
+	 *
+	 * However, since MMF_UNSTABLE is set by __oom_reap_task_mm() from
+	 * exit_mmap() before start reaping (because the purpose of
+	 * MMF_UNSTABLE is to "tell all users of get_user/copy_from_user etc...
+	 * that the content is no longer stable"), it cannot be used for a flag
+	 * for indicating that the OOM reaper can't work on the mm anymore.
+	 * The OOM reaper will give up after (by default) 1 second even if
+	 * exit_mmap() is doing __oom_reap_task_mm().
 	 */
 	if (test_bit(MMF_UNSTABLE, &mm->flags)) {
 		trace_skip_task_reaping(tsk->pid);
@@ -576,8 +566,6 @@ static void oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
 out_mm:
 	up_read(&mm->mmap_sem);
-out_oom:
-	mutex_unlock(&oom_lock);
 }
 
 static void oom_reap_task(struct task_struct *tsk)
@@ -591,12 +579,7 @@ static void oom_reap_task(struct task_struct *tsk)
 	if (test_bit(MMF_OOM_SKIP, &mm->flags))
 		goto drop;
 
-	/*
-	 * If this mm has already been reaped, doing so again will not likely
-	 * free additional memory.
-	 */
-	if (!test_bit(MMF_UNSTABLE, &mm->flags))
-		oom_reap_task_mm(tsk, mm);
+	oom_reap_task_mm(tsk, mm);
 
 	if (time_after_eq(jiffies, mm->oom_free_expire)) {
 		if (!test_bit(MMF_OOM_SKIP, &mm->flags)) {
@@ -658,12 +641,16 @@ static int oom_reaper(void *unused)
 static u64 oom_free_timeout_ms = 1000;
 static void wake_oom_reaper(struct task_struct *tsk)
 {
+	unsigned long expire = jiffies + msecs_to_jiffies(oom_free_timeout_ms);
+
+	/* expire must not be 0 in order to avoid double list_add(). */
+	if (!expire)
+		expire++;
 	/*
 	 * Set the reap timeout; if it's already set, the mm is enqueued and
 	 * this tsk can be ignored.
 	 */
-	if (cmpxchg(&tsk->signal->oom_mm->oom_free_expire, 0UL,
-			jiffies + msecs_to_jiffies(oom_free_timeout_ms)))
+	if (cmpxchg(&tsk->signal->oom_mm->oom_free_expire, 0UL, expire))
 		return;
 
 	get_task_struct(tsk);
-- 
1.8.3.1
