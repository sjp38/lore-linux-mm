Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 63A0F6B0095
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 21:16:11 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so3182596eek.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 18:16:10 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 24/27] sched: Improve convergence
Date: Mon, 19 Nov 2012 03:14:41 +0100
Message-Id: <1353291284-2998-25-git-send-email-mingo@kernel.org>
In-Reply-To: <1353291284-2998-1-git-send-email-mingo@kernel.org>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

 - break out of can_do_numa_run() earlier if we can make no progress
 - don't flip between siblings that often
 - turn on bidirectional fault balancing
 - improve the flow in task_numa_work()

Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/fair.c     | 46 ++++++++++++++++++++++++++++++++--------------
 kernel/sched/features.h |  2 +-
 2 files changed, 33 insertions(+), 15 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 59fea2e..9c46b45 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -917,12 +917,12 @@ void task_numa_fault(int node, int last_cpu, int pages)
  */
 void task_numa_work(struct callback_head *work)
 {
+	long pages_total, pages_left, pages_changed;
 	unsigned long migrate, next_scan, now = jiffies;
+	unsigned long start0, start, end;
 	struct task_struct *p = current;
 	struct mm_struct *mm = p->mm;
 	struct vm_area_struct *vma;
-	unsigned long start, end;
-	long pages;
 
 	WARN_ON_ONCE(p != container_of(work, struct task_struct, numa_work));
 
@@ -951,35 +951,42 @@ void task_numa_work(struct callback_head *work)
 
 	current->numa_scan_period += jiffies_to_msecs(2);
 
-	start = mm->numa_scan_offset;
-	pages = sysctl_sched_numa_scan_size;
-	pages <<= 20 - PAGE_SHIFT; /* MB in pages */
-	if (!pages)
+	start0 = start = end = mm->numa_scan_offset;
+	pages_total = sysctl_sched_numa_scan_size;
+	pages_total <<= 20 - PAGE_SHIFT; /* MB in pages */
+	if (!pages_total)
 		return;
 
+	pages_left	= pages_total;
+
 	down_write(&mm->mmap_sem);
 	vma = find_vma(mm, start);
 	if (!vma) {
 		ACCESS_ONCE(mm->numa_scan_seq)++;
-		start = 0;
-		vma = mm->mmap;
+		end = 0;
+		vma = find_vma(mm, end);
 	}
 	for (; vma; vma = vma->vm_next) {
 		if (!vma_migratable(vma))
 			continue;
 
 		do {
-			start = max(start, vma->vm_start);
-			end = ALIGN(start + (pages << PAGE_SHIFT), HPAGE_SIZE);
+			start = max(end, vma->vm_start);
+			end = ALIGN(start + (pages_left << PAGE_SHIFT), HPAGE_SIZE);
 			end = min(end, vma->vm_end);
-			pages -= change_prot_numa(vma, start, end);
-			start = end;
-			if (pages <= 0)
+			pages_changed = change_prot_numa(vma, start, end);
+
+			WARN_ON_ONCE(pages_changed > pages_total);
+			BUG_ON(pages_changed < 0);
+
+			pages_left -= pages_changed;
+			if (pages_left <= 0)
 				goto out;
 		} while (end != vma->vm_end);
 	}
 out:
-	mm->numa_scan_offset = start;
+	mm->numa_scan_offset = end;
+
 	up_write(&mm->mmap_sem);
 }
 
@@ -3306,6 +3313,13 @@ static int select_idle_sibling(struct task_struct *p, int target)
 	int i;
 
 	/*
+	 * For NUMA tasks constant, reliable placement is more important
+	 * than flipping tasks between siblings:
+	 */
+	if (task_numa_shared(p) >= 0)
+		return target;
+
+	/*
 	 * If the task is going to be woken-up on this cpu and if it is
 	 * already idle, then it is the right target.
 	 */
@@ -4581,6 +4595,10 @@ static bool can_do_numa_run(struct lb_env *env, struct sd_lb_stats *sds)
 	 * If we got capacity allow stacking up on shared tasks.
 	 */
 	if ((sds->this_shared_running < sds->this_group_capacity) && sds->numa_shared_running) {
+		/* There's no point in trying to move if all are here already: */
+		if (sds->numa_shared_running == sds->this_shared_running)
+			return false;
+
 		env->flags |= LBF_NUMA_SHARED;
 		return true;
 	}
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index a432eb8..b75a10d 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -71,6 +71,6 @@ SCHED_FEAT(LB_MIN, false)
 /* Do the working set probing faults: */
 SCHED_FEAT(NUMA,             true)
 SCHED_FEAT(NUMA_FAULTS_UP,   true)
-SCHED_FEAT(NUMA_FAULTS_DOWN, false)
+SCHED_FEAT(NUMA_FAULTS_DOWN, true)
 SCHED_FEAT(NUMA_SETTLE,      true)
 #endif
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
