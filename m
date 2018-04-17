Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE7ED6B0005
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 18:46:57 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so12133594pfz.19
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 15:46:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l185sor3876115pgl.18.2018.04.17.15.46.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Apr 2018 15:46:56 -0700 (PDT)
Date: Tue, 17 Apr 2018 15:46:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, oom: fix concurrent munlock and oom reaper unmap
Message-ID: <alpine.DEB.2.21.1804171545460.53786@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Since exit_mmap() is done without the protection of mm->mmap_sem, it is
possible for the oom reaper to concurrently operate on an mm until
MMF_OOM_SKIP is set.

This allows munlock_vma_pages_all() to concurrently run while the oom
reaper is operating on a vma.  Since munlock_vma_pages_range() depends on
clearing VM_LOCKED from vm_flags before actually doing the munlock to
determine if any other vmas are locking the same memory, the check for
VM_LOCKED in the oom reaper is racy.

This is especially noticeable on architectures such as powerpc where
clearing a huge pmd requires kick_all_cpus_sync().  If the pmd is zapped
by the oom reaper during follow_page_mask() after the check for pmd_none()
is bypassed, this ends up deferencing a NULL ptl.

Fix this by reusing MMF_UNSTABLE to specify that an mm should not be
reaped.  This prevents the concurrent munlock_vma_pages_range() and
unmap_page_range().  The oom reaper will simply not operate on an mm that
has the bit set and leave the unmapping to exit_mmap().

Fixes: 212925802454 ("mm: oom: let oom_reap_task and exit_mmap run concurrently")
Cc: stable@vger.kernel.org [4.14+]
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/mmap.c     | 38 ++++++++++++++++++++------------------
 mm/oom_kill.c | 19 ++++++++-----------
 2 files changed, 28 insertions(+), 29 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3015,6 +3015,25 @@ void exit_mmap(struct mm_struct *mm)
 	/* mm's last user has gone, and its about to be pulled down */
 	mmu_notifier_release(mm);
 
+	if (unlikely(mm_is_oom_victim(mm))) {
+		/*
+		 * Wait for oom_reap_task() to stop working on this mm.  Because
+		 * MMF_UNSTABLE is already set before calling down_read(),
+		 * oom_reap_task() will not run on this mm after up_write().
+		 * oom_reap_task() also depends on a stable VM_LOCKED flag to
+		 * indicate it should not unmap during munlock_vma_pages_all().
+		 *
+		 * mm_is_oom_victim() cannot be set from under us because
+		 * victim->mm is already set to NULL under task_lock before
+		 * calling mmput() and victim->signal->oom_mm is set by the oom
+		 * killer only if victim->mm is non-NULL while holding
+		 * task_lock().
+		 */
+		set_bit(MMF_UNSTABLE, &mm->flags);
+		down_write(&mm->mmap_sem);
+		up_write(&mm->mmap_sem);
+	}
+
 	if (mm->locked_vm) {
 		vma = mm->mmap;
 		while (vma) {
@@ -3036,26 +3055,9 @@ void exit_mmap(struct mm_struct *mm)
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
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -521,12 +521,17 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	}
 
 	/*
-	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
-	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
+	 * Tell all users of get_user/copy_from_user etc... that the content
+	 * is no longer stable. No barriers really needed because unmapping
+	 * should imply barriers already and the reader would hit a page fault
+	 * if it stumbled over reaped memory.
+	 *
+	 * MMF_UNSTABLE is also set by exit_mmap when the OOM reaper shouldn't
+	 * work on the mm anymore. The check for MMF_OOM_UNSTABLE must run
 	 * under mmap_sem for reading because it serializes against the
 	 * down_write();up_write() cycle in exit_mmap().
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
+	if (test_and_set_bit(MMF_UNSTABLE, &mm->flags)) {
 		up_read(&mm->mmap_sem);
 		trace_skip_task_reaping(tsk->pid);
 		goto unlock_oom;
@@ -534,14 +539,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 
 	trace_start_task_reaping(tsk->pid);
 
-	/*
-	 * Tell all users of get_user/copy_from_user etc... that the content
-	 * is no longer stable. No barriers really needed because unmapping
-	 * should imply barriers already and the reader would hit a page fault
-	 * if it stumbled over a reaped memory.
-	 */
-	set_bit(MMF_UNSTABLE, &mm->flags);
-
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
 		if (!can_madv_dontneed_vma(vma))
 			continue;
