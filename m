Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 6C0406B008A
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 21:16:02 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so3182484eek.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 18:16:01 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 19/27] sched: Implement constant, per task Working Set Sampling (WSS) rate
Date: Mon, 19 Nov 2012 03:14:36 +0100
Message-Id: <1353291284-2998-20-git-send-email-mingo@kernel.org>
In-Reply-To: <1353291284-2998-1-git-send-email-mingo@kernel.org>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

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

The per-task nature of the working set sampling functionality
in this tree allows such constant rate, per task,
execution-weight proportional sampling of the working set,
with an adaptive sampling interval/frequency that goes from
once per 100 msecs up to just once per 1.6 seconds.
The current sampling volume is 256 MB per interval.

As tasks mature and converge their working set, so does the
sampling rate slow down to just a trickle, 256 MB per 1.6
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
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Link: http://lkml.kernel.org/n/tip-wt5b48o2226ec63784i58s3j@git.kernel.org
[ Wrote changelog and fixed bug. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/mm_types.h |  1 +
 include/linux/sched.h    |  1 +
 kernel/sched/fair.c      | 41 +++++++++++++++++++++++++++++------------
 kernel/sysctl.c          |  7 +++++++
 4 files changed, 38 insertions(+), 12 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 48760e9..5995652 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -405,6 +405,7 @@ struct mm_struct {
 #endif
 #ifdef CONFIG_NUMA_BALANCING
 	unsigned long numa_next_scan;
+	unsigned long numa_scan_offset;
 	int numa_scan_seq;
 #endif
 	struct uprobes_state uprobes_state;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index bb12cc3..3372aac 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2047,6 +2047,7 @@ extern enum sched_tunable_scaling sysctl_sched_tunable_scaling;
 
 extern unsigned int sysctl_sched_numa_scan_period_min;
 extern unsigned int sysctl_sched_numa_scan_period_max;
+extern unsigned int sysctl_sched_numa_scan_size;
 extern unsigned int sysctl_sched_numa_settle_count;
 
 #ifdef CONFIG_SCHED_DEBUG
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index f3aeaac..151a3cd 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -825,8 +825,9 @@ static void account_numa_dequeue(struct rq *rq, struct task_struct *p)
 /*
  * numa task sample period in ms: 5s
  */
-unsigned int sysctl_sched_numa_scan_period_min = 5000;
-unsigned int sysctl_sched_numa_scan_period_max = 5000*16;
+unsigned int sysctl_sched_numa_scan_period_min = 100;
+unsigned int sysctl_sched_numa_scan_period_max = 100*16;
+unsigned int sysctl_sched_numa_scan_size = 256;   /* MB */
 
 /*
  * Wait for the 2-sample stuff to settle before migrating again
@@ -912,6 +913,9 @@ void task_numa_work(struct callback_head *work)
 	unsigned long migrate, next_scan, now = jiffies;
 	struct task_struct *p = current;
 	struct mm_struct *mm = p->mm;
+	struct vm_area_struct *vma;
+	unsigned long offset, end;
+	long length;
 
 	WARN_ON_ONCE(p != container_of(work, struct task_struct, numa_work));
 
@@ -938,18 +942,31 @@ void task_numa_work(struct callback_head *work)
 	if (cmpxchg(&mm->numa_next_scan, migrate, next_scan) != migrate)
 		return;
 
-	ACCESS_ONCE(mm->numa_scan_seq)++;
-	{
-		struct vm_area_struct *vma;
+	offset = mm->numa_scan_offset;
+	length = sysctl_sched_numa_scan_size;
+	length <<= 20;
 
-		down_write(&mm->mmap_sem);
-		for (vma = mm->mmap; vma; vma = vma->vm_next) {
-			if (!vma_migratable(vma))
-				continue;
-			change_prot_numa(vma, vma->vm_start, vma->vm_end);
-		}
-		up_write(&mm->mmap_sem);
+	down_write(&mm->mmap_sem);
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
+	up_write(&mm->mmap_sem);
 }
 
 /*
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 7736b9e..a14b8a4 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -367,6 +367,13 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "sched_numa_scan_size_mb",
+		.data		= &sysctl_sched_numa_scan_size,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "sched_numa_settle_count",
 		.data		= &sysctl_sched_numa_settle_count,
 		.maxlen		= sizeof(unsigned int),
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
