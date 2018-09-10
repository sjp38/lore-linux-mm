Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6918E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 08:55:56 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d47-v6so7204371edb.3
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 05:55:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g54-v6sor14960078edg.7.2018.09.10.05.55.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 05:55:54 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 1/3] mm, oom: rework mmap_exit vs. oom_reaper synchronization
Date: Mon, 10 Sep 2018 14:55:11 +0200
Message-Id: <20180910125513.311-2-mhocko@kernel.org>
In-Reply-To: <20180910125513.311-1-mhocko@kernel.org>
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

The oom_reaper cannot handle mlocked vmas right now and therefore we
have exit_mmap to reap the memory before it clears the mlock flags on
mappings. This is all good but we would like to have a better hand over
protocol between the oom_reaper and exit_mmap paths.

Therefore use exclusive mmap_sem in exit_mmap whenever exit_mmap has to
synchronize with the oom_reaper. There are two notable places. Mlocked
vmas (munlock_vma_pages_all) and page tables tear down path. All others
should be fine to race with oom_reap_task_mm.

This is mostly a preparatory patch which shouldn't introduce functional
changes.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/mmap.c | 48 +++++++++++++++++++++++-------------------------
 1 file changed, 23 insertions(+), 25 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 5f2b2b184c60..3481424717ac 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3042,39 +3042,29 @@ void exit_mmap(struct mm_struct *mm)
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	unsigned long nr_accounted = 0;
+	bool oom = mm_is_oom_victim(mm);
 
 	/* mm's last user has gone, and its about to be pulled down */
 	mmu_notifier_release(mm);
 
-	if (unlikely(mm_is_oom_victim(mm))) {
-		/*
-		 * Manually reap the mm to free as much memory as possible.
-		 * Then, as the oom reaper does, set MMF_OOM_SKIP to disregard
-		 * this mm from further consideration.  Taking mm->mmap_sem for
-		 * write after setting MMF_OOM_SKIP will guarantee that the oom
-		 * reaper will not run on this mm again after mmap_sem is
-		 * dropped.
-		 *
-		 * Nothing can be holding mm->mmap_sem here and the above call
-		 * to mmu_notifier_release(mm) ensures mmu notifier callbacks in
-		 * __oom_reap_task_mm() will not block.
-		 *
-		 * This needs to be done before calling munlock_vma_pages_all(),
-		 * which clears VM_LOCKED, otherwise the oom reaper cannot
-		 * reliably test it.
-		 */
-		(void)__oom_reap_task_mm(mm);
-
-		set_bit(MMF_OOM_SKIP, &mm->flags);
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
-	}
-
 	if (mm->locked_vm) {
 		vma = mm->mmap;
 		while (vma) {
-			if (vma->vm_flags & VM_LOCKED)
+			if (vma->vm_flags & VM_LOCKED) {
+				/*
+				 * oom_reaper cannot handle mlocked vmas but we
+				 * need to serialize it with munlock_vma_pages_all
+				 * which clears VM_LOCKED, otherwise the oom reaper
+				 * cannot reliably test it.
+				 */
+				if (oom)
+					down_write(&mm->mmap_sem);
+
 				munlock_vma_pages_all(vma);
+
+				if (oom)
+					up_write(&mm->mmap_sem);
+			}
 			vma = vma->vm_next;
 		}
 	}
@@ -3091,6 +3081,11 @@ void exit_mmap(struct mm_struct *mm)
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
+
+	/* oom_reaper cannot race with the page tables teardown */
+	if (oom)
+		down_write(&mm->mmap_sem);
+
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
 
@@ -3104,6 +3099,9 @@ void exit_mmap(struct mm_struct *mm)
 		vma = remove_vma(vma);
 	}
 	vm_unacct_memory(nr_accounted);
+
+	if (oom)
+		up_write(&mm->mmap_sem);
 }
 
 /* Insert vm structure into process list sorted by address
-- 
2.18.0
