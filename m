Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3EFB86B0255
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 13:36:30 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id n186so39132011wmn.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 10:36:30 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id y84si6100067wmg.105.2015.12.15.10.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 10:36:28 -0800 (PST)
Received: by mail-wm0-f44.google.com with SMTP id l126so7030789wml.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 10:36:28 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm, oom: introduce oom reaper
Date: Tue, 15 Dec 2015 19:36:15 +0100
Message-Id: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

This is based on the idea from Mel Gorman discussed during LSFMM 2015 and
independently brought up by Oleg Nesterov.

The OOM killer currently allows to kill only a single task in a good
hope that the task will terminate in a reasonable time and frees up its
memory.  Such a task (oom victim) will get an access to memory reserves
via mark_oom_victim to allow a forward progress should there be a need
for additional memory during exit path.

It has been shown (e.g. by Tetsuo Handa) that it is not that hard to
construct workloads which break the core assumption mentioned above and
the OOM victim might take unbounded amount of time to exit because it
might be blocked in the uninterruptible state waiting for on an event
(e.g. lock) which is blocked by another task looping in the page
allocator.

This patch reduces the probability of such a lockup by introducing a
specialized kernel thread (oom_reaper) which tries to reclaim additional
memory by preemptively reaping the anonymous or swapped out memory
owned by the oom victim under an assumption that such a memory won't
be needed when its owner is killed and kicked from the userspace anyway.
There is one notable exception to this, though, if the OOM victim was
in the process of coredumping the result would be incomplete. This is
considered a reasonable constrain because the overall system health is
more important than debugability of a particular application.

A kernel thread has been chosen because we need a reliable way of
invocation so workqueue context is not appropriate because all the
workers might be busy (e.g. allocating memory). Kswapd which sounds
like another good fit is not appropriate as well because it might get
blocked on locks during reclaim as well.

oom_reaper has to take mmap_sem on the target task for reading so the
solution is not 100% because the semaphore might be held or blocked for
write but the probability is reduced considerably wrt. basically any
lock blocking forward progress as described above. In order to prevent
from blocking on the lock without any forward progress we are using only
a trylock and retry 10 times with a short sleep in between.
Users of mmap_sem which need it for write should be carefully reviewed
to use _killable waiting as much as possible and reduce allocations
requests done with the lock held to absolute minimum to reduce the risk
even further.

The API between oom killer and oom reaper is quite trivial. wake_oom_reaper
updates mm_to_reap with cmpxchg to guarantee only NULL->mm transition
and oom_reaper clear this atomically once it is done with the work. This
means that only a single mm_struct can be reaped at the time. As the
operation is potentially disruptive we are trying to limit it to the
ncessary minimum and the reaper blocks any updates while it operates on
an mm. mm_struct is pinned by mm_count to allow parallel exit_mmap and a
race is detected by atomic_inc_not_zero(mm_users).

Changes since v2
- fix mm_count refernce leak reported by Tetsuo
- make sure oom_reaper_th is NULL after kthread_run fails - Tetsuo
- use wait_event_freezable rather than open coded wait loop - suggested
  by Tetsuo
Changes since v1
- fix the screwed up detail->check_swap_entries - Johannes
- do not use kthread_should_stop because that would need a cleanup
  and we do not have anybody to stop us - Tetsuo
- move wake_oom_reaper to oom_kill_process because we have to wait
  for all tasks sharing the same mm to get killed - Tetsuo
- do not reap mm structs which are shared with unkillable tasks - Tetsuo

Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
this is version 3 of the patch. Thanks to Tetsuo for his exhaustive
review.  There haven't been any fundamental objections to the approach
so I have dropped the RFC status. Any further feedback is welcome of
course.

 include/linux/mm.h |   2 +
 mm/internal.h      |   5 ++
 mm/memory.c        |  12 ++---
 mm/oom_kill.c      | 139 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 149 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 25cdec395f2c..d1ce03569942 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1061,6 +1061,8 @@ struct zap_details {
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
+	bool ignore_dirty;			/* Ignore dirty pages */
+	bool check_swap_entries;		/* Check also swap entries */
 };
 
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
diff --git a/mm/internal.h b/mm/internal.h
index 4ae7b7c7462b..9006ce1960ff 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -41,6 +41,11 @@ extern int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
+void unmap_page_range(struct mmu_gather *tlb,
+			     struct vm_area_struct *vma,
+			     unsigned long addr, unsigned long end,
+			     struct zap_details *details);
+
 static inline void set_page_count(struct page *page, int v)
 {
 	atomic_set(&page->_count, v);
diff --git a/mm/memory.c b/mm/memory.c
index f5b8e8c9f4c3..ccfd48c7286e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1104,6 +1104,9 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 
 			if (!PageAnon(page)) {
 				if (pte_dirty(ptent)) {
+					/* oom_reaper cannot tear down dirty pages */
+					if (unlikely(details && details->ignore_dirty))
+						continue;
 					force_flush = 1;
 					set_page_dirty(page);
 				}
@@ -1122,8 +1125,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 			}
 			continue;
 		}
-		/* If details->check_mapping, we leave swap entries. */
-		if (unlikely(details))
+		/* only check swap_entries if explicitly asked for in details */
+		if (unlikely(details && !details->check_swap_entries))
 			continue;
 
 		entry = pte_to_swp_entry(ptent);
@@ -1228,7 +1231,7 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 	return addr;
 }
 
-static void unmap_page_range(struct mmu_gather *tlb,
+void unmap_page_range(struct mmu_gather *tlb,
 			     struct vm_area_struct *vma,
 			     unsigned long addr, unsigned long end,
 			     struct zap_details *details)
@@ -1236,9 +1239,6 @@ static void unmap_page_range(struct mmu_gather *tlb,
 	pgd_t *pgd;
 	unsigned long next;
 
-	if (details && !details->check_mapping)
-		details = NULL;
-
 	BUG_ON(addr >= end);
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5314b206caa5..48025a21f8c4 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -35,6 +35,11 @@
 #include <linux/freezer.h>
 #include <linux/ftrace.h>
 #include <linux/ratelimit.h>
+#include <linux/kthread.h>
+#include <linux/module.h>
+
+#include <asm/tlb.h>
+#include "internal.h"
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
@@ -408,6 +413,105 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
 
 bool oom_killer_disabled __read_mostly;
 
+/*
+ * OOM Reaper kernel thread which tries to reap the memory used by the OOM
+ * victim (if that is possible) to help the OOM killer to move on.
+ */
+static struct task_struct *oom_reaper_th;
+static struct mm_struct *mm_to_reap;
+static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
+
+static bool __oom_reap_vmas(struct mm_struct *mm)
+{
+	struct mmu_gather tlb;
+	struct vm_area_struct *vma;
+	struct zap_details details = {.check_swap_entries = true,
+				      .ignore_dirty = true};
+	bool ret = true;
+
+	/* We might have raced with exit path */
+	if (!atomic_inc_not_zero(&mm->mm_users))
+		return true;
+
+	if (!down_read_trylock(&mm->mmap_sem)) {
+		ret = false;
+		goto out;
+	}
+
+	tlb_gather_mmu(&tlb, mm, 0, -1);
+	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
+		if (is_vm_hugetlb_page(vma))
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
+		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
+			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
+					 &details);
+	}
+	tlb_finish_mmu(&tlb, 0, -1);
+	up_read(&mm->mmap_sem);
+out:
+	mmput(mm);
+	return ret;
+}
+
+static void oom_reap_vmas(struct mm_struct *mm)
+{
+	int attempts = 0;
+
+	while (attempts++ < 10 && !__oom_reap_vmas(mm))
+		schedule_timeout(HZ/10);
+
+	/* Drop a reference taken by wake_oom_reaper */
+	mmdrop(mm);
+}
+
+static int oom_reaper(void *unused)
+{
+	while (true) {
+		struct mm_struct *mm;
+		wait_event_freezable(oom_reaper_wait, (mm = READ_ONCE(mm_to_reap)));
+		oom_reap_vmas(mm);
+		WRITE_ONCE(mm_to_reap, NULL);
+	}
+
+	return 0;
+}
+
+static void wake_oom_reaper(struct mm_struct *mm)
+{
+	struct mm_struct *old_mm;
+
+	if (!oom_reaper_th)
+		return;
+
+	/*
+	 * Pin the given mm. Use mm_count instead of mm_users because
+	 * we do not want to delay the address space tear down.
+	 */
+	atomic_inc(&mm->mm_count);
+
+	/*
+	 * Make sure that only a single mm is ever queued for the reaper
+	 * because multiple are not necessary and the operation might be
+	 * disruptive so better reduce it to the bare minimum.
+	 */
+	old_mm = cmpxchg(&mm_to_reap, NULL, mm);
+	if (!old_mm)
+		wake_up(&oom_reaper_wait);
+	else
+		mmdrop(mm);
+}
+
 /**
  * mark_oom_victim - mark the given task as OOM victim
  * @tsk: task to mark
@@ -517,6 +621,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
+	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -607,15 +712,23 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		if (same_thread_group(p, victim))
 			continue;
-		if (unlikely(p->flags & PF_KTHREAD))
-			continue;
-		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+		if (unlikely(p->flags & PF_KTHREAD) ||
+		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+			/*
+			 * We cannot use oom_reaper for the mm shared by this process
+			 * because it wouldn't get killed and so the memory might be
+			 * still used.
+			 */
+			can_oom_reap = false;
 			continue;
+		}
 
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 	}
 	rcu_read_unlock();
 
+	if (can_oom_reap)
+		wake_oom_reaper(mm);
 	mmdrop(mm);
 	put_task_struct(victim);
 }
@@ -767,3 +880,23 @@ void pagefault_out_of_memory(void)
 
 	mutex_unlock(&oom_lock);
 }
+
+static int __init oom_init(void)
+{
+	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
+	if (IS_ERR(oom_reaper_th)) {
+		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
+				PTR_ERR(oom_reaper_th));
+		oom_reaper_th = NULL;
+	} else {
+		struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
+
+		/*
+		 * Make sure our oom reaper thread will get scheduled when
+		 * ASAP and that it won't get preempted by malicious userspace.
+		 */
+		sched_setscheduler(oom_reaper_th, SCHED_FIFO, &param);
+	}
+	return 0;
+}
+module_init(oom_init)
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
