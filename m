Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 1D94D8D000B
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:45:47 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1476612eek.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:45:46 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 52/52] sched: Add RSS filter to NUMA-balancing
Date: Sun,  2 Dec 2012 19:43:44 +0100
Message-Id: <1354473824-19229-53-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

NUMA-balancing, combined with NUMA-affine memory migration,
is a relatively long-term process (compared to the typical
time scale of scheduling) that takes time to establish and
converge - on the time scale of of several seconds or more.

Small, short-lived and don't have much of a NUMA placement
cost to begin with, so don't NUMA-balance them. A task needs
to execute long enough and needs to establish a large enough
user-space memory image to benefit from more intelligent
NUMA balancing.

We already have a CPU time limit before tasks are affected
by NUMA balancing - this change adds the memory equivalent:
by introducing an RSS limit of 128 MBs.

In practice this excludes most short-lived tasks - the limit
is in fact probably a bit on the conservative side - but with
intrusive kernel features conservative is good.

The /proc/sys/kernel/sched_numa_rss_threshold_mb value can be
tuned runtime - setting it to 0 turns off this filter.

To implement the RSS filter first factor out a clean
task_numa_candidate() function and comment on the various
reasons of why we wouldn't want to begin to NUMA-balance
a particular task (yet). Then add the RSS check.

Note, we are using the p->hiwater_rss value instead of the
current RSS size. We do this to avoid tasks flipping in and
out of the limit, if their RSS fluctuates around the limit.
The RSS high-water value increases monotonically in the
life-time of a task, so there's a single, precise transition
to NUMA-balancing as the limit is crossed.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/sched.h |  1 +
 kernel/sched/fair.c   | 50 ++++++++++++++++++++++++++++++++++++++++++++------
 kernel/sysctl.c       |  7 +++++++
 3 files changed, 52 insertions(+), 6 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index ce834e7..6a29dfd 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2059,6 +2059,7 @@ extern unsigned int sysctl_sched_numa_scan_period_min;
 extern unsigned int sysctl_sched_numa_scan_period_max;
 extern unsigned int sysctl_sched_numa_scan_size_min;
 extern unsigned int sysctl_sched_numa_scan_size_max;
+extern unsigned int sysctl_sched_numa_rss_threshold;
 extern unsigned int sysctl_sched_numa_settle_count;
 
 #ifdef CONFIG_SCHED_DEBUG
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 9667191..eb49f07 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -812,6 +812,8 @@ unsigned int sysctl_sched_numa_scan_period_max	__read_mostly = 100*16;	/* ms */
 unsigned int sysctl_sched_numa_scan_size_min	__read_mostly =  32;	/* MB */
 unsigned int sysctl_sched_numa_scan_size_max	__read_mostly = 512;	/* MB */
 
+unsigned int sysctl_sched_numa_rss_threshold	__read_mostly = 128;	/* MB */
+
 /*
  * Wait for the 2-sample stuff to settle before migrating again
  */
@@ -2486,17 +2488,53 @@ static void task_tick_numa_placement(struct rq *rq, struct task_struct *curr)
 	task_work_add(curr, work, true);
 }
 
-static void task_tick_numa(struct rq *rq, struct task_struct *curr)
+/*
+ * Is this task worth NUMA-scanning and NUMA-balancing?
+ */
+static bool task_numa_candidate(struct task_struct *p)
 {
+	unsigned long rss_pages;
+
+	/* kthreads don't have any user-space memory to scan: */
+	if (!p->mm || !p->numa_faults)
+		return false;
+
 	/*
-	 * We don't care about NUMA placement if we don't have memory
-	 * or are exiting:
+	 * Exiting tasks won't touch any user-space memory in the future,
+	 * and this also avoids a race with work_exit():
 	 */
-	if (!curr->mm || (curr->flags & PF_EXITING) || !curr->numa_faults)
-		return;
+	if (p->flags & PF_EXITING)
+		return false;
 
 	/* Don't disturb hard-bound tasks: */
-	if (sched_feat(NUMA_EXCLUDE_AFFINE) && (curr->nr_cpus_allowed != num_online_cpus())) {
+	if (sched_feat(NUMA_EXCLUDE_AFFINE)) {
+		if (p->nr_cpus_allowed != num_online_cpus())
+			return false;
+	}
+
+	/*
+	 * NUMA-balancing, combined with NUMA memory migration,
+	 * is a long-term process that takes time to establish
+	 * and converge, on the time scale of of several seconds
+	 * or more.
+	 *
+	 * Small tasks are usually short-lived and don't have much
+	 * of a NUMA placement cost to begin with, so don't
+	 * NUMA-balance them:
+	 */
+	rss_pages = sysctl_sched_numa_rss_threshold;
+	rss_pages <<= 20 - PAGE_SHIFT; /* MB to pages */
+
+	if (p->mm->hiwater_rss < rss_pages)
+		return false;
+
+	return true;
+}
+
+static void task_tick_numa(struct rq *rq, struct task_struct *curr)
+{
+	/* Cheap checks first: */
+	if (!task_numa_candidate(curr)) {
 		if (curr->numa_shared >= 0)
 			curr->numa_shared = -1;
 		return;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index b6ddfae..75ab895 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -388,6 +388,13 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "sched_numa_rss_threshold_mb",
+		.data		= &sysctl_sched_numa_rss_threshold,
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
