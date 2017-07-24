Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F71D6B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 03:23:42 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k71so23630853wrc.15
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 00:23:42 -0700 (PDT)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id 69si915059wme.212.2017.07.24.00.23.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 00:23:41 -0700 (PDT)
Received: by mail-wr0-f194.google.com with SMTP id y43so16718325wrd.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 00:23:40 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Date: Mon, 24 Jul 2017 09:23:32 +0200
Message-Id: <20170724072332.31903-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

David has noticed that the oom killer might kill additional tasks while
the exiting oom victim hasn't terminated yet because the oom_reaper marks
the curent victim MMF_OOM_SKIP too early when mm->mm_users dropped down
to 0. The race is as follows

oom_reap_task				do_exit
					  exit_mm
  __oom_reap_task_mm
					    mmput
					      __mmput
    mmget_not_zero # fails
    						exit_mmap # frees memory
  set_bit(MMF_OOM_SKIP)

The victim is still visible to the OOM killer until it is unhashed.

Currently we try to reduce a risk of this race by taking oom_lock
and wait for out_of_memory sleep while holding the lock to give the
victim some time to exit. This is quite suboptimal approach because
there is no guarantee the victim (especially a large one) will manage
to unmap its address space and free enough memory to the particular oom
domain which needs a memory (e.g. a specific NUMA node).

Fix this problem by allowing __oom_reap_task_mm and __mmput path to
race. __oom_reap_task_mm is basically MADV_DONTNEED and that is allowed
to run in parallel with other unmappers (hence the mmap_sem for read).

The only tricky part is to exclude page tables tear down and all
operations which modify the address space in the __mmput path. exit_mmap
doesn't expect any other users so it doesn't use any locking. Nothing
really forbids us to use mmap_sem for write, though. In fact we are
already relying on this lock earlier in the __mmput path to synchronize
with ksm and khugepaged.

Take the exclusive mmap_sem when calling free_pgtables and destroying
vmas to sync with __oom_reap_task_mm which take the lock for read. All
other operations can safely race with the parallel unmap.

Changes
- bail on null mm->mmap early as per David Rientjes

Reported-by: David Rientjes <rientjes@google.com>
Fixes: 26db62f179d1 ("oom: keep mm of the killed task available")
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
I've sent this as an RFC [1] previously and it seems that the original
issue has been resolved [2], although an explicit tested-by would be
appreciated of course. Hugh has pointed out [3] that using mmap_sem
in exit_mmap will allow to drop the tricky
	down_write(mmap_sem);
	up_write(mmap_sem);
in both paths. I hope I will get to that in a forseeable future.

I am not yet sure this is important enough to merge to stable trees,
I would rather wait for a report to show up.

[1] http://lkml.kernel.org/r/20170626130346.26314-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/alpine.DEB.2.10.1707111336250.60183@chino.kir.corp.google.com
[3] http://lkml.kernel.org/r/alpine.LSU.2.11.1707191716030.2055@eggly.anvils

 mm/mmap.c     |  7 +++++++
 mm/oom_kill.c | 45 +++++++--------------------------------------
 2 files changed, 14 insertions(+), 38 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 24e9261bdcc0..0eeb658caa30 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2993,6 +2993,11 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
 
+	/*
+	 * oom reaper might race with exit_mmap so make sure we won't free
+	 * page tables or unmap VMAs under its feet
+	 */
+	down_write(&mm->mmap_sem);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
 
@@ -3005,7 +3010,9 @@ void exit_mmap(struct mm_struct *mm)
 			nr_accounted += vma_pages(vma);
 		vma = remove_vma(vma);
 	}
+	mm->mmap = NULL;
 	vm_unacct_memory(nr_accounted);
+	up_write(&mm->mmap_sem);
 }
 
 /* Insert vm structure into process list sorted by address
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9e8b4f030c1c..a6dabe3691c1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -470,40 +470,15 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
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
 
-	/*
-	 * increase mm_users only after we know we will reap something so
-	 * that the mmput_async is called only when we have reaped something
-	 * and delayed __mmput doesn't matter that much
-	 */
-	if (!mmget_not_zero(mm)) {
-		up_read(&mm->mmap_sem);
-		trace_skip_task_reaping(tsk->pid);
-		goto unlock_oom;
-	}
+	/* There is nothing to reap so bail out without signs in the log */
+	if (!mm->mmap)
+		goto unlock;
 
 	trace_start_task_reaping(tsk->pid);
 
@@ -540,17 +515,11 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 			K(get_mm_counter(mm, MM_ANONPAGES)),
 			K(get_mm_counter(mm, MM_FILEPAGES)),
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
-	up_read(&mm->mmap_sem);
 
-	/*
-	 * Drop our reference but make sure the mmput slow path is called from a
-	 * different context because we shouldn't risk we get stuck there and
-	 * put the oom_reaper out of the way.
-	 */
-	mmput_async(mm);
 	trace_finish_task_reaping(tsk->pid);
-unlock_oom:
-	mutex_unlock(&oom_lock);
+unlock:
+	up_read(&mm->mmap_sem);
+
 	return ret;
 }
 
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
