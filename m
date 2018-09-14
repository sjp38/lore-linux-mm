Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E7FF08E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 09:55:12 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u74-v6so9576323oie.16
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 06:55:12 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m4-v6si1229511otl.183.2018.09.14.06.55.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 06:55:09 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
 <70a92ca8-ca3e-2586-d52a-36c5ef6f7e43@i-love.sakura.ne.jp>
 <20180912075054.GZ10951@dhcp22.suse.cz>
 <20180912134203.GJ10951@dhcp22.suse.cz>
 <4ed2213e-c4ca-4ef2-2cc0-17b5c5447325@i-love.sakura.ne.jp>
 <20180913090950.GD20287@dhcp22.suse.cz>
 <c70a8b7c-d1d2-66de-d87e-13a4a410335b@i-love.sakura.ne.jp>
 <20180913113538.GE20287@dhcp22.suse.cz>
 <0897639b-a1d9-2da1-0a1e-a3eeed799a0f@i-love.sakura.ne.jp>
 <20180913134032.GF20287@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <792a95e1-b81d-b220-f00b-27b7abf969f4@i-love.sakura.ne.jp>
Date: Fri, 14 Sep 2018 22:54:45 +0900
MIME-Version: 1.0
In-Reply-To: <20180913134032.GF20287@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On 2018/09/13 22:40, Michal Hocko wrote:
> On Thu 13-09-18 20:53:24, Tetsuo Handa wrote:
>> On 2018/09/13 20:35, Michal Hocko wrote:
>>>> Next question.
>>>>
>>>>         /* Use -1 here to ensure all VMAs in the mm are unmapped */
>>>>         unmap_vmas(&tlb, vma, 0, -1);
>>>>
>>>> in exit_mmap() will now race with the OOM reaper. And unmap_vmas() will handle
>>>> VM_HUGETLB or VM_PFNMAP or VM_SHARED or !vma_is_anonymous() vmas, won't it?
>>>> Then, is it guaranteed to be safe if the OOM reaper raced with unmap_vmas() ?
>>>
>>> I do not understand the question. unmap_vmas is basically MADV_DONTNEED
>>> and that doesn't require the exclusive mmap_sem lock so yes it should be
>>> safe those two to race (modulo bugs of course but I am not aware of any
>>> there).
>>>  
>>
>> You need to verify that races we observed with VM_LOCKED can't happen
>> for VM_HUGETLB / VM_PFNMAP / VM_SHARED / !vma_is_anonymous() cases.
> 
> Well, VM_LOCKED is kind of special because that is not a permanent state
> which might change. VM_HUGETLB, VM_PFNMAP resp VM_SHARED are not changed
> throughout the vma lifetime.
> 
OK, next question.
Is it guaranteed that arch_exit_mmap(mm) is safe with the OOM reaper?



Well, anyway, diffstat of your proposal would be

 include/linux/oom.h |  2 --
 mm/internal.h       |  3 +++
 mm/memory.c         | 28 ++++++++++++--------
 mm/mmap.c           | 73 +++++++++++++++++++++++++++++++----------------------
 mm/oom_kill.c       | 46 ++++++++++++++++++++++++---------
 5 files changed, 98 insertions(+), 54 deletions(-)

trying to hand over only __free_pgtables() part at the risk of
setting MMF_OOM_SKIP without reclaiming any memory due to dropping
__oom_reap_task_mm() and scattering down_write()/up_write() inside
exit_mmap(), while diffstat of my proposal (not tested yet) would be

 include/linux/mm_types.h |   2 +
 include/linux/oom.h      |   3 +-
 include/linux/sched.h    |   2 +-
 kernel/fork.c            |  11 +++
 mm/mmap.c                |  42 ++++-------
 mm/oom_kill.c            | 182 ++++++++++++++++++++++-------------------------
 6 files changed, 117 insertions(+), 125 deletions(-)

trying to wait until __mmput() completes and also trying to handle
multiple OOM victims in parallel.

You are refusing timeout based approach but I don't think this is
something we have to be frayed around the edge about possibility of
overlooking races/bugs because you don't want to use timeout. And you
have never showed that timeout based approach cannot work well enough.



Michal's proposal:

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 69864a5..11e26ca 100644
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
diff --git a/mm/internal.h b/mm/internal.h
index 87256ae..35adbfe 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -40,6 +40,9 @@
 
 vm_fault_t do_swap_page(struct vm_fault *vmf);
 
+void __unlink_vmas(struct vm_area_struct *vma);
+void __free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
+		unsigned long floor, unsigned long ceiling);
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
diff --git a/mm/memory.c b/mm/memory.c
index c467102..cf910ed 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -612,20 +612,23 @@ void free_pgd_range(struct mmu_gather *tlb,
 	} while (pgd++, addr = next, addr != end);
 }
 
-void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
+void __unlink_vmas(struct vm_area_struct *vma)
+{
+	while (vma) {
+		unlink_anon_vmas(vma);
+		unlink_file_vma(vma);
+		vma = vma->vm_next;
+	}
+}
+
+/* expects that __unlink_vmas has been called already */
+void __free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		unsigned long floor, unsigned long ceiling)
 {
 	while (vma) {
 		struct vm_area_struct *next = vma->vm_next;
 		unsigned long addr = vma->vm_start;
 
-		/*
-		 * Hide vma from rmap and truncate_pagecache before freeing
-		 * pgtables
-		 */
-		unlink_anon_vmas(vma);
-		unlink_file_vma(vma);
-
 		if (is_vm_hugetlb_page(vma)) {
 			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
 				floor, next ? next->vm_start : ceiling);
@@ -637,8 +640,6 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			       && !is_vm_hugetlb_page(next)) {
 				vma = next;
 				next = vma->vm_next;
-				unlink_anon_vmas(vma);
-				unlink_file_vma(vma);
 			}
 			free_pgd_range(tlb, addr, vma->vm_end,
 				floor, next ? next->vm_start : ceiling);
@@ -647,6 +648,13 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	}
 }
 
+void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		unsigned long floor, unsigned long ceiling)
+{
+	__unlink_vmas(vma);
+	__free_pgtables(tlb, vma, floor, ceiling);
+}
+
 int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
 {
 	spinlock_t *ptl;
diff --git a/mm/mmap.c b/mm/mmap.c
index 5f2b2b1..67bd8a0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3042,40 +3042,26 @@ void exit_mmap(struct mm_struct *mm)
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	unsigned long nr_accounted = 0;
+	const bool oom = mm_is_oom_victim(mm);
 
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
-		vma = mm->mmap;
-		while (vma) {
-			if (vma->vm_flags & VM_LOCKED)
-				munlock_vma_pages_all(vma);
-			vma = vma->vm_next;
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			if (!(vma->vm_flags & VM_LOCKED))
+				continue;
+			/*
+			 * oom_reaper cannot handle mlocked vmas but we
+			 * need to serialize it with munlock_vma_pages_all
+			 * which clears VM_LOCKED, otherwise the oom reaper
+			 * cannot reliably test it.
+			 */
+			if (oom)
+				down_write(&mm->mmap_sem);
+			munlock_vma_pages_all(vma);
+			if (oom)
+				up_write(&mm->mmap_sem);
 		}
 	}
 
@@ -3091,10 +3077,37 @@ void exit_mmap(struct mm_struct *mm)
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
-	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
+
+	/*
+	 * oom_reaper cannot race with the page tables teardown but we
+	 * want to make sure that the exit path can take over the full
+	 * tear down when it is safe to do so
+	 */
+	if (oom) {
+		down_write(&mm->mmap_sem);
+		__unlink_vmas(vma);
+		/*
+		 * the exit path is guaranteed to finish the memory tear down
+		 * without any unbound blocking at this stage so make it clear
+		 * to the oom_reaper
+		 */
+		mm->mmap = NULL;
+		up_write(&mm->mmap_sem);
+		__free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
+	} else {
+		free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
+	}
+
 	tlb_finish_mmu(&tlb, 0, -1);
 
 	/*
+	 * Now that the full address space is torn down, make sure the
+	 * OOM killer skips over this task
+	 */
+	if (oom)
+		set_bit(MMF_OOM_SKIP, &mm->flags);
+
+	/*
 	 * Walk the list again, actually closing and freeing it,
 	 * with preemption enabled, without holding any MM locks.
 	 */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa53..abddcde 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -189,6 +189,16 @@ static bool is_dump_unreclaim_slabs(void)
 	return (global_node_page_state(NR_SLAB_UNRECLAIMABLE) > nr_lru);
 }
 
+/*
+ * Rough memory consumption of the given mm which should be theoretically freed
+ * when the mm is removed.
+ */
+static unsigned long oom_badness_pages(struct mm_struct *mm)
+{
+	return get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS) +
+		mm_pgtables_bytes(mm) / PAGE_SIZE;
+}
+
 /**
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
@@ -230,8 +240,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
-		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
+	points = oom_badness_pages(p->mm);
 	task_unlock(p);
 
 	/* Normalize to oom_score_adj units */
@@ -483,12 +492,11 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  * OOM Reaper kernel thread which tries to reap the memory used by the OOM
  * victim (if that is possible) to help the OOM killer to move on.
  */
-static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
-bool __oom_reap_task_mm(struct mm_struct *mm)
+static bool __oom_reap_task_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 	bool ret = true;
@@ -501,7 +509,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 	 */
 	set_bit(MMF_UNSTABLE, &mm->flags);
 
-	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (!can_madv_dontneed_vma(vma))
 			continue;
 
@@ -532,6 +540,16 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 		}
 	}
 
+	/*
+	 * If we still sit on a noticeable amount of memory even after successfully
+	 * reaping the address space then keep retrying until exit_mmap makes some
+	 * further progress.
+	 * TODO: add a flag for a stage when the exit path doesn't block anymore
+	 * and hand over MMF_OOM_SKIP handling there in that case
+	 */
+	if (ret && oom_badness_pages(mm) > 1024)
+		ret = false;
+
 	return ret;
 }
 
@@ -551,12 +569,10 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	}
 
 	/*
-	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
-	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
-	 * under mmap_sem for reading because it serializes against the
-	 * down_write();up_write() cycle in exit_mmap().
+	 * If exit path clear mm->mmap then we know it will finish the tear down
+	 * and we can go and bail out here.
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
+	if (!mm->mmap) {
 		trace_skip_task_reaping(tsk->pid);
 		goto out_unlock;
 	}
@@ -605,8 +621,14 @@ static void oom_reap_task(struct task_struct *tsk)
 	/*
 	 * Hide this mm from OOM killer because it has been either reaped or
 	 * somebody can't call up_write(mmap_sem).
+	 * Leave the MMF_OOM_SKIP to the exit path if it managed to reach the
+	 * point it is guaranteed to finish without any blocking
 	 */
-	set_bit(MMF_OOM_SKIP, &mm->flags);
+	if (mm->mmap)
+		set_bit(MMF_OOM_SKIP, &mm->flags);
+	else if (!test_bit(MMF_OOM_SKIP, &mm->flags))
+		pr_info("oom_reaper: handed over pid:%d (%s) to exit path\n",
+			task_pid_nr(tsk), tsk->comm);
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
@@ -650,7 +672,7 @@ static void wake_oom_reaper(struct task_struct *tsk)
 
 static int __init oom_init(void)
 {
-	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
+	kthread_run(oom_reaper, NULL, "oom_reaper");
 	return 0;
 }
 subsys_initcall(oom_init)
-- 
1.8.3.1



Tetsuo's proposal:

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cd2bc93..3c48c08 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -486,6 +486,8 @@ struct mm_struct {
 		atomic_long_t hugetlb_usage;
 #endif
 		struct work_struct async_put_work;
+		unsigned long last_oom_pages;
+		unsigned char oom_stalled_count;
 
 #if IS_ENABLED(CONFIG_HMM)
 		/* HMM needs to track a few things per mm */
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 69864a5..8a987c6 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -95,7 +95,7 @@ static inline vm_fault_t check_stable_address_space(struct mm_struct *mm)
 	return 0;
 }
 
-bool __oom_reap_task_mm(struct mm_struct *mm);
+void __oom_reap_task_mm(struct mm_struct *mm);
 
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
@@ -104,6 +104,7 @@ extern unsigned long oom_badness(struct task_struct *p,
 extern bool out_of_memory(struct oom_control *oc);
 
 extern void exit_oom_victim(void);
+extern void exit_oom_mm(struct mm_struct *mm);
 
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 977cb57..efed2ea 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1175,7 +1175,7 @@ struct task_struct {
 #endif
 	int				pagefault_disabled;
 #ifdef CONFIG_MMU
-	struct task_struct		*oom_reaper_list;
+	struct list_head		oom_victim;
 #endif
 #ifdef CONFIG_VMAP_STACK
 	struct vm_struct		*stack_vm_area;
diff --git a/kernel/fork.c b/kernel/fork.c
index f0b5847..3e662bb 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -992,7 +992,16 @@ struct mm_struct *mm_alloc(void)
 
 static inline void __mmput(struct mm_struct *mm)
 {
+	const bool oom = IS_ENABLED(CONFIG_MMU) && mm_is_oom_victim(mm);
+
 	VM_BUG_ON(atomic_read(&mm->mm_users));
+	if (oom) {
+		/* Try what the OOM reaper kernel thread can afford. */
+		__oom_reap_task_mm(mm);
+		/* Shut out the OOM reaper kernel thread. */
+		down_write(&mm->mmap_sem);
+		up_write(&mm->mmap_sem);
+	}
 
 	uprobe_clear_state(mm);
 	exit_aio(mm);
@@ -1008,6 +1017,8 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+	if (oom)
+		exit_oom_mm(mm);
 	mmdrop(mm);
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 5f2b2b1..f1b27f7 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3042,41 +3042,27 @@ void exit_mmap(struct mm_struct *mm)
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	unsigned long nr_accounted = 0;
+	const bool oom = mm_is_oom_victim(mm);
 
 	/* mm's last user has gone, and its about to be pulled down */
 	mmu_notifier_release(mm);
-
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
+	/*
+	 * Retry what the OOM reaper kernel thread can afford, for
+	 * all MMU notifiers are now gone.
+	 */
+	if (oom)
+		__oom_reap_task_mm(mm);
 
 	if (mm->locked_vm) {
-		vma = mm->mmap;
-		while (vma) {
+		for (vma = mm->mmap; vma; vma = vma->vm_next)
 			if (vma->vm_flags & VM_LOCKED)
 				munlock_vma_pages_all(vma);
-			vma = vma->vm_next;
-		}
+		/*
+		 * Retry what the OOM reaper kernel thread can afford, for
+		 * all mlocked vmas are now unlocked.
+		 */
+		if (oom)
+			__oom_reap_task_mm(mm);
 	}
 
 	arch_exit_mmap(mm);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa53..01fa0d7 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -189,6 +189,16 @@ static bool is_dump_unreclaim_slabs(void)
 	return (global_node_page_state(NR_SLAB_UNRECLAIMABLE) > nr_lru);
 }
 
+/*
+ * Rough memory consumption of the given mm which should be theoretically freed
+ * when the mm is removed.
+ */
+static unsigned long oom_badness_pages(struct mm_struct *mm)
+{
+	return get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS) +
+		mm_pgtables_bytes(mm) / PAGE_SIZE;
+}
+
 /**
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
@@ -230,8 +240,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
-		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
+	points = oom_badness_pages(p->mm);
 	task_unlock(p);
 
 	/* Normalize to oom_score_adj units */
@@ -483,25 +492,15 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  * OOM Reaper kernel thread which tries to reap the memory used by the OOM
  * victim (if that is possible) to help the OOM killer to move on.
  */
-static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
+static LIST_HEAD(oom_reaper_list);
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
-bool __oom_reap_task_mm(struct mm_struct *mm)
+void __oom_reap_task_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
-	bool ret = true;
-
-	/*
-	 * Tell all users of get_user/copy_from_user etc... that the content
-	 * is no longer stable. No barriers really needed because unmapping
-	 * should imply barriers already and the reader would hit a page fault
-	 * if it stumbled over a reaped memory.
-	 */
-	set_bit(MMF_UNSTABLE, &mm->flags);
 
-	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (!can_madv_dontneed_vma(vma))
 			continue;
 
@@ -523,7 +522,6 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 			tlb_gather_mmu(&tlb, mm, start, end);
 			if (mmu_notifier_invalidate_range_start_nonblock(mm, start, end)) {
 				tlb_finish_mmu(&tlb, start, end);
-				ret = false;
 				continue;
 			}
 			unmap_page_range(&tlb, vma, start, end, NULL);
@@ -531,118 +529,110 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 			tlb_finish_mmu(&tlb, start, end);
 		}
 	}
-
-	return ret;
 }
 
 /*
  * Reaps the address space of the give task.
- *
- * Returns true on success and false if none or part of the address space
- * has been reclaimed and the caller should retry later.
  */
-static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
+static void oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
-	bool ret = true;
-
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		trace_skip_task_reaping(tsk->pid);
-		return false;
-	}
-
 	/*
-	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
-	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
-	 * under mmap_sem for reading because it serializes against the
-	 * down_write();up_write() cycle in exit_mmap().
+	 * Reaping operation needs mmap_sem held for read. Also, the check for
+	 * mm_users must run under mmap_sem for reading because it serializes
+	 * against the down_write()/up_write() cycle in __mmput().
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
-		trace_skip_task_reaping(tsk->pid);
-		goto out_unlock;
+	if (!down_read_trylock(&mm->mmap_sem)) {
+		/* Do nothing if already in __mmput() */
+		if (atomic_read(&mm->mm_users))
+			trace_skip_task_reaping(tsk->pid);
+		return;
+	}
+	/* Do nothing if already in __mmput() */
+	if (atomic_read(&mm->mm_users)) {
+		trace_start_task_reaping(tsk->pid);
+		__oom_reap_task_mm(mm);
+		trace_finish_task_reaping(tsk->pid);
 	}
-
-	trace_start_task_reaping(tsk->pid);
-
-	/* failed to reap part of the address space. Try again later */
-	ret = __oom_reap_task_mm(mm);
-	if (!ret)
-		goto out_finish;
-
-	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-			task_pid_nr(tsk), tsk->comm,
-			K(get_mm_counter(mm, MM_ANONPAGES)),
-			K(get_mm_counter(mm, MM_FILEPAGES)),
-			K(get_mm_counter(mm, MM_SHMEMPAGES)));
-out_finish:
-	trace_finish_task_reaping(tsk->pid);
-out_unlock:
 	up_read(&mm->mmap_sem);
-
-	return ret;
 }
 
-#define MAX_OOM_REAP_RETRIES 10
 static void oom_reap_task(struct task_struct *tsk)
 {
-	int attempts = 0;
 	struct mm_struct *mm = tsk->signal->oom_mm;
-
-	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
-		schedule_timeout_idle(HZ/10);
-
-	if (attempts <= MAX_OOM_REAP_RETRIES ||
-	    test_bit(MMF_OOM_SKIP, &mm->flags))
-		goto done;
-
-	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-		task_pid_nr(tsk), tsk->comm);
-	debug_show_all_locks();
-
-done:
-	tsk->oom_reaper_list = NULL;
-
-	/*
-	 * Hide this mm from OOM killer because it has been either reaped or
-	 * somebody can't call up_write(mmap_sem).
-	 */
-	set_bit(MMF_OOM_SKIP, &mm->flags);
-
-	/* Drop a reference taken by wake_oom_reaper */
-	put_task_struct(tsk);
+	unsigned long pages;
+
+	oom_reap_task_mm(tsk, mm);
+	pages = oom_badness_pages(mm);
+	/* Hide this mm from OOM killer if stalled for too long. */
+	if (mm->last_oom_pages > pages) {
+		mm->last_oom_pages = pages;
+		mm->oom_stalled_count = 0;
+	} else if (mm->oom_stalled_count++ > 10) {
+		pr_info("oom_reaper: gave up process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+			task_pid_nr(tsk), tsk->comm,
+			K(get_mm_counter(mm, MM_ANONPAGES)),
+			K(get_mm_counter(mm, MM_FILEPAGES)),
+			K(get_mm_counter(mm, MM_SHMEMPAGES)));
+		set_bit(MMF_OOM_SKIP, &mm->flags);
+	}
 }
 
 static int oom_reaper(void *unused)
 {
 	while (true) {
-		struct task_struct *tsk = NULL;
+		struct task_struct *tsk;
 
-		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
+		if (!list_empty(&oom_reaper_list))
+			schedule_timeout_uninterruptible(HZ / 10);
+		else
+			wait_event_freezable(oom_reaper_wait,
+					     !list_empty(&oom_reaper_list));
 		spin_lock(&oom_reaper_lock);
-		if (oom_reaper_list != NULL) {
-			tsk = oom_reaper_list;
-			oom_reaper_list = tsk->oom_reaper_list;
+		list_for_each_entry(tsk, &oom_reaper_list, oom_victim) {
+			get_task_struct(tsk);
+			spin_unlock(&oom_reaper_lock);
+			oom_reap_task(tsk);
+			spin_lock(&oom_reaper_lock);
+			put_task_struct(tsk);
 		}
 		spin_unlock(&oom_reaper_lock);
-
-		if (tsk)
-			oom_reap_task(tsk);
 	}
-
 	return 0;
 }
 
+void exit_oom_mm(struct mm_struct *mm)
+{
+	struct task_struct *tsk;
+
+	spin_lock(&oom_reaper_lock);
+	list_for_each_entry(tsk, &oom_reaper_list, oom_victim)
+		if (tsk->signal->oom_mm == mm)
+			break;
+	list_del(&tsk->oom_victim);
+	spin_unlock(&oom_reaper_lock);
+	/* Drop a reference taken by wake_oom_reaper(). */
+	put_task_struct(tsk);
+}
+
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
+	struct mm_struct *mm = tsk->signal->oom_mm;
+
+	/* There is no point with processing same mm twice. */
+	if (test_bit(MMF_UNSTABLE, &mm->flags))
 		return;
+	/*
+	 * Tell all users of get_user/copy_from_user etc... that the content
+	 * is no longer stable. No barriers really needed because unmapping
+	 * should imply barriers already and the reader would hit a page fault
+	 * if it stumbled over a reaped memory.
+	 */
+	set_bit(MMF_UNSTABLE, &mm->flags);
 
 	get_task_struct(tsk);
 
 	spin_lock(&oom_reaper_lock);
-	tsk->oom_reaper_list = oom_reaper_list;
-	oom_reaper_list = tsk;
+	list_add_tail(&tsk->oom_victim, &oom_reaper_list);
 	spin_unlock(&oom_reaper_lock);
 	trace_wake_reaper(tsk->pid);
 	wake_up(&oom_reaper_wait);
@@ -650,7 +640,7 @@ static void wake_oom_reaper(struct task_struct *tsk)
 
 static int __init oom_init(void)
 {
-	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
+	kthread_run(oom_reaper, NULL, "oom_reaper");
 	return 0;
 }
 subsys_initcall(oom_init)
@@ -681,8 +671,10 @@ static void mark_oom_victim(struct task_struct *tsk)
 
 	/* oom_mm is bound to the signal struct life time. */
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
-		mmgrab(tsk->signal->oom_mm);
+		mmgrab(mm);
 		set_bit(MMF_OOM_VICTIM, &mm->flags);
+		mm->last_oom_pages = oom_badness_pages(mm);
+		mm->oom_stalled_count = 0;
 	}
 
 	/*
-- 
1.8.3.1
