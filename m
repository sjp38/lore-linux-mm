Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AD01F6B026C
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 04:24:14 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i16-v6so4282595ede.11
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 01:24:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o16-v6sor2423601ejc.45.2018.10.25.01.24.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 01:24:12 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH v2 1/3] mm, oom: rework mmap_exit vs. oom_reaper synchronization
Date: Thu, 25 Oct 2018 10:24:01 +0200
Message-Id: <20181025082403.3806-2-mhocko@kernel.org>
In-Reply-To: <20181025082403.3806-1-mhocko@kernel.org>
References: <20181025082403.3806-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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

Changes since RFC
- move MMF_OOM_SKIP in exit_mmap to before we are going to free page
  tables.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/oom.h |  2 --
 mm/mmap.c           | 50 ++++++++++++++++++++++-----------------------
 mm/oom_kill.c       |  4 ++--
 3 files changed, 27 insertions(+), 29 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 69864a547663..11e26ca565a7 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -95,8 +95,6 @@ static inline vm_fault_t check_stable_address_space(struct mm_struct *mm)
 	return 0;
 }
 
-bool __oom_reap_task_mm(struct mm_struct *mm);
-
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
diff --git a/mm/mmap.c b/mm/mmap.c
index 5f2b2b184c60..a02b314c0546 100644
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
@@ -3091,6 +3081,13 @@ void exit_mmap(struct mm_struct *mm)
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
+
+	/* oom_reaper cannot race with the page tables teardown */
+	if (oom) {
+		down_write(&mm->mmap_sem);
+		set_bit(MMF_OOM_SKIP, &mm->flags);
+	}
+
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
 
@@ -3104,6 +3101,9 @@ void exit_mmap(struct mm_struct *mm)
 		vma = remove_vma(vma);
 	}
 	vm_unacct_memory(nr_accounted);
+
+	if (oom)
+		up_write(&mm->mmap_sem);
 }
 
 /* Insert vm structure into process list sorted by address
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa5360616..b3b2c2bbd8ab 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -488,7 +488,7 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
-bool __oom_reap_task_mm(struct mm_struct *mm)
+static bool __oom_reap_task_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 	bool ret = true;
@@ -554,7 +554,7 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
 	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
 	 * under mmap_sem for reading because it serializes against the
-	 * down_write();up_write() cycle in exit_mmap().
+	 * down_write() in exit_mmap().
 	 */
 	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
 		trace_skip_task_reaping(tsk->pid);
-- 
2.19.1
