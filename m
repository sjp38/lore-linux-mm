Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7AE6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:16:40 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w63so77862wrc.5
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 01:16:40 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id o6si4913892edb.408.2017.08.10.01.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 01:16:38 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id d40so2104391wma.3
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 01:16:38 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Date: Thu, 10 Aug 2017 10:16:32 +0200
Message-Id: <20170810081632.31265-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Argangeli <andrea@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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

Changes v1
- bail on null mm->mmap early as per David Rientjes
- take exclusive mmap_sem in exit_mmap only for oom victims to reduce
  the lock overhead

Reported-by: David Rientjes <rientjes@google.com>
Fixes: 26db62f179d1 ("oom: keep mm of the killed task available")
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
the previous version of the patch has been posted here [1]. The original
patch has taken mmap_sem in exit_mmap unconditionally but Kirill was
worried this could have a performance impact (we should exercise the
fast path most of the time because nobody should be holding lock at that
stage). An artificial testcase [2] has shown ~3% difference but numbers
are quite noisy [3] so it is effect is not all that clear. Anyway I have
made the lock conditional for oom victims.

Andrea has proposed and alternative solution [4] which should be
equivalent functionally similar to {ksm,khugepaged}_exit. I have to
confess I really don't like that approach but I can live with it if
that is a preferred way (to be honest I would like to drop the empty
down_write();up_write() from the other two callers as well). In fact I
have asked Andrea to post his patch [5] but that hasn't happened. I do
not think we should wait much longer and finally merge some fix. 

[1] http://lkml.kernel.org/r/20170724072332.31903-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20170725142626.GJ26723@dhcp22.suse.cz
[3] http://lkml.kernel.org/r/20170725160359.GO26723@dhcp22.suse.cz
[4] http://lkml.kernel.org/r/20170726162912.GA29716@redhat.com
[5] http://lkml.kernel.org/r/20170728062345.GA2274@dhcp22.suse.cz

 mm/mmap.c     | 16 ++++++++++++++++
 mm/oom_kill.c | 47 ++++++++---------------------------------------
 2 files changed, 24 insertions(+), 39 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 24e9261bdcc0..822e8860b9d2 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -44,6 +44,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/moduleparam.h>
 #include <linux/pkeys.h>
+#include <linux/oom.h>
 
 #include <linux/uaccess.h>
 #include <asm/cacheflush.h>
@@ -2967,6 +2968,7 @@ void exit_mmap(struct mm_struct *mm)
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	unsigned long nr_accounted = 0;
+	bool locked = false;
 
 	/* mm's last user has gone, and its about to be pulled down */
 	mmu_notifier_release(mm);
@@ -2993,6 +2995,17 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
 
+	/*
+	 * oom reaper might race with exit_mmap so make sure we won't free
+	 * page tables or unmap VMAs under its feet
+	 * Please note that mark_oom_victim is always called under task_lock
+	 * with tsk->mm != NULL checked on !current tasks which synchronizes
+	 * with exit_mm and so we cannot race here.
+	 */
+	if (tsk_is_oom_victim(current)) {
+		down_write(&mm->mmap_sem);
+		locked = true;
+	}
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
 
@@ -3005,7 +3018,10 @@ void exit_mmap(struct mm_struct *mm)
 			nr_accounted += vma_pages(vma);
 		vma = remove_vma(vma);
 	}
+	mm->mmap = NULL;
 	vm_unacct_memory(nr_accounted);
+	if (locked)
+		up_write(&mm->mmap_sem);
 }
 
 /* Insert vm structure into process list sorted by address
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9e8b4f030c1c..b1c96e1910f2 100644
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
 
@@ -540,18 +515,12 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
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
-	return ret;
+unlock:
+	up_read(&mm->mmap_sem);
+
+	return true;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
