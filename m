Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id C84126B006E
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 04:15:20 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 18/19] mm: sched: numa: Implement constant, per task Working Set Sampling (WSS) rate
Date: Tue,  6 Nov 2012 09:14:54 +0000
Message-Id: <1352193295-26815-19-git-send-email-mgorman@suse.de>
In-Reply-To: <1352193295-26815-1-git-send-email-mgorman@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Note: The scan period is much larger than it was in the original patch.
	The reason was because the system CPU usage went through the roof
	with a sample period of 100ms but it was unsuitable to have a
	situation where a large process could stall for excessively long
	updating pte_numa. This may need to be tuned again if a placement
	policy converges too slowly.

Previously, to probe the working set of a task, we'd use
a very simple and crude method: mark all of its address
space PROT_NONE.

That method has various (obvious) disadvantages:

 - it samples the working set at dissimilar rates,
   giving some tasks a sampling quality advantage
   over others.

 - creates performance problems for tasks with very
   large working sets

 - over-samples processes with large address spaces but
   which only very rarely execute

Improve that method by keeping a rotating offset into the
address space that marks the current position of the scan,
and advance it by a constant rate (in a CPU cycles execution
proportional manner). If the offset reaches the last mapped
address of the mm then it then it starts over at the first
address.

The per-task nature of the working set sampling functionality in this tree
allows such constant rate, per task, execution-weight proportional sampling
of the working set, with an adaptive sampling interval/frequency that
goes from once per 2 seconds up to just once per 32 seconds.  The current
sampling volume is 256 MB per interval.

As tasks mature and converge their working set, so does the
sampling rate slow down to just a trickle, 256 MB per 8
seconds of CPU time executed.

This, beyond being adaptive, also rate-limits rarely
executing systems and does not over-sample on overloaded
systems.

[ In AutoNUMA speak, this patch deals with the effective sampling
  rate of the 'hinting page fault'. AutoNUMA's scanning is
  currently rate-limited, but it is also fundamentally
  single-threaded, executing in the knuma_scand kernel thread,
  so the limit in AutoNUMA is global and does not scale up with
  the number of CPUs, nor does it scan tasks in an execution
  proportional manner.

  So the idea of rate-limiting the scanning was first implemented
  in the AutoNUMA tree via a global rate limit. This patch goes
  beyond that by implementing an execution rate proportional
  working set sampling rate that is not implemented via a single
  global scanning daemon. ]

[ Dan Carpenter pointed out a possible NULL pointer dereference in the
  first version of this patch. ]

Based-on-idea-by: Andrea Arcangeli <aarcange@redhat.com>
Bug-Found-By: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
[ Wrote changelog and fixed bug. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm_types.h |    3 +++
 include/linux/sched.h    |    1 +
 kernel/sched/fair.c      |   45 ++++++++++++++++++++++++++++++++-------------
 kernel/sysctl.c          |    7 +++++++
 4 files changed, 43 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d82accb..b40f4ef 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -406,6 +406,9 @@ struct mm_struct {
 	 */
 	unsigned long numa_next_scan;
 
+	/* Restart point for scanning and setting pte_numa */
+	unsigned long numa_scan_offset;
+
 	/* numa_scan_seq prevents two threads setting pte_numa */
 	int numa_scan_seq;
 #endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
index ac71181..abb1c70 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2008,6 +2008,7 @@ extern enum sched_tunable_scaling sysctl_sched_tunable_scaling;
 
 extern unsigned int sysctl_balance_numa_scan_period_min;
 extern unsigned int sysctl_balance_numa_scan_period_max;
+extern unsigned int sysctl_balance_numa_scan_size;
 extern unsigned int sysctl_balance_numa_settle_count;
 
 #ifdef CONFIG_SCHED_DEBUG
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 020a8f2..38b911ef 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -780,10 +780,13 @@ update_stats_curr_start(struct cfs_rq *cfs_rq, struct sched_entity *se)
 
 #ifdef CONFIG_BALANCE_NUMA
 /*
- * numa task sample period in ms: 5s
+ * numa task sample period in ms
  */
-unsigned int sysctl_balance_numa_scan_period_min = 5000;
-unsigned int sysctl_balance_numa_scan_period_max = 5000*16;
+unsigned int sysctl_balance_numa_scan_period_min = 2000;
+unsigned int sysctl_balance_numa_scan_period_max = 2000*16;
+
+/* Portion of address space to scan in MB */
+unsigned int sysctl_balance_numa_scan_size = 256;
 
 static void task_numa_placement(struct task_struct *p)
 {
@@ -817,6 +820,9 @@ void task_numa_work(struct callback_head *work)
 	unsigned long migrate, next_scan, now = jiffies;
 	struct task_struct *p = current;
 	struct mm_struct *mm = p->mm;
+	struct vm_area_struct *vma;
+	unsigned long offset, end;
+	long length;
 
 	WARN_ON_ONCE(p != container_of(work, struct task_struct, numa_work));
 
@@ -843,18 +849,31 @@ void task_numa_work(struct callback_head *work)
 	if (cmpxchg(&mm->numa_next_scan, migrate, next_scan) != migrate)
 		return;
 
-	ACCESS_ONCE(mm->numa_scan_seq)++;
-	{
-		struct vm_area_struct *vma;
+	offset = mm->numa_scan_offset;
+	length = sysctl_balance_numa_scan_size;
+	length <<= 20;
 
-		down_read(&mm->mmap_sem);
-		for (vma = mm->mmap; vma; vma = vma->vm_next) {
-			if (!vma_migratable(vma))
-				continue;
-			change_prot_numa(vma, vma->vm_start, vma->vm_end);
-		}
-		up_read(&mm->mmap_sem);
+	down_read(&mm->mmap_sem);
+	vma = find_vma(mm, offset);
+	if (!vma) {
+		ACCESS_ONCE(mm->numa_scan_seq)++;
+		offset = 0;
+		vma = mm->mmap;
+	}
+	for (; vma && length > 0; vma = vma->vm_next) {
+		if (!vma_migratable(vma))
+			continue;
+
+		offset = max(offset, vma->vm_start);
+		end = min(ALIGN(offset + length, HPAGE_SIZE), vma->vm_end);
+		length -= end - offset;
+
+		change_prot_numa(vma, offset, end);
+
+		offset = end;
 	}
+	mm->numa_scan_offset = offset;
+	up_read(&mm->mmap_sem);
 }
 
 /*
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 1359f51..d191203 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -366,6 +366,13 @@ static struct ctl_table kern_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "balance_numa_scan_size_mb",
+		.data		= &sysctl_balance_numa_scan_size,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #endif /* CONFIG_BALANCE_NUMA */
 #endif /* CONFIG_SCHED_DEBUG */
 	{
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
