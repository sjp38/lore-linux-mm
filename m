Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id DFA8E6B00A9
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 06:24:04 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 43/43] sched: numa: Increase and decrease a tasks scanning period based on task fault statistics
Date: Fri, 16 Nov 2012 11:22:53 +0000
Message-Id: <1353064973-26082-44-git-send-email-mgorman@suse.de>
In-Reply-To: <1353064973-26082-1-git-send-email-mgorman@suse.de>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Currently the rate of scanning for an address space is controlled by the
individual tasks. The next scan is determined by p->numa_scan_period
and slowly increases as NUMA faults are handled. This assumes there are
no phase changes.

Now that there is a policy in place that guesses if a task or process
is properly placed, use that information to grow/shrink the scanning
window on a per-task basis.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c |   22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 6d2ccd3..598f657 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1063,18 +1063,25 @@ static void task_numa_placement(struct task_struct *p)
 	}
 
 	/*
+	 * If this NUMA node is the selected on based on task NUMA
+	 * faults then increase the time before it scans again
+	 */
+	if (task_selected_nid == this_nid)
+		p->numa_scan_period = min(sysctl_balance_numa_scan_period_max,
+					  p->numa_scan_period * 2);
+
+	/*
 	 * If this NUMA node is the selected one based on process
 	 * memory and task NUMA faults then set the home node.
 	 * There should be no need to requeue the task.
 	 */
 	if (task_selected_nid == this_nid && mm_selected_nid == this_nid) {
-		p->numa_scan_period = min(sysctl_balance_numa_scan_period_max,
-					  p->numa_scan_period * 2);
 		p->home_node = this_nid;
 		return;
 	}
 
-	p->numa_scan_period = sysctl_balance_numa_scan_period_min;
+	p->numa_scan_period = max(sysctl_balance_numa_scan_period_min,
+				p->numa_scan_period / 2);
 	task_numa_find_placement(p);
 }
 
@@ -1110,15 +1117,6 @@ void task_numa_fault(int node, int pages)
 	p->mm->mm_balancenuma->mm_numa_fault_tot++;
 	p->mm->mm_balancenuma->mm_numa_fault[node]++;
 
-	/*
-	 * Assume that as faults occur that pages are getting properly placed
-	 * and fewer NUMA hints are required. Note that this is a big
-	 * assumption, it assumes processes reach a steady steady with no
-	 * further phase changes.
-	 */
-	p->numa_scan_period = min(sysctl_balance_numa_scan_period_max,
-				p->numa_scan_period + jiffies_to_msecs(2));
-
 	task_numa_placement(p);
 }
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
