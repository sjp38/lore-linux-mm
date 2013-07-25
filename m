Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 497616B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 06:36:30 -0400 (EDT)
Date: Thu, 25 Jul 2013 12:36:20 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/18] Basic scheduler support for automatic NUMA
 balancing V5
Message-ID: <20130725103620.GM27075@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373901620-2021-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


Subject: sched, numa: Break stuff..
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue Jul 23 14:58:41 CEST 2013

This patch is mostly a comment in code. I don't believe the current
scan period adjustment scheme can work properly nor do I think it a
good idea to ratelimit the numa faults as a whole based on migration.

Reasons are in the modified comments...

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 kernel/sched/fair.c |   41 ++++++++++++++++++++++++++++++++---------
 1 file changed, 32 insertions(+), 9 deletions(-)

--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1108,7 +1108,6 @@ static void task_numa_placement(struct t
 
 	/* Preferred node as the node with the most faults */
 	if (max_faults && max_nid != p->numa_preferred_nid) {
-		int old_migrate_seq = p->numa_migrate_seq;
 
 		/* Queue task on preferred node if possible */
 		p->numa_preferred_nid = max_nid;
@@ -1116,14 +1115,19 @@ static void task_numa_placement(struct t
 		numa_migrate_preferred(p);
 
 		/*
+		int old_migrate_seq = p->numa_migrate_seq;
+		 *
 		 * If preferred nodes changes frequently then the scan rate
 		 * will be continually high. Mitigate this by increasing the
 		 * scan rate only if the task was settled.
-		 */
+		 *
+		 * APZ: disabled because we don't lower it again :/
+		 *
 		if (old_migrate_seq >= sysctl_numa_balancing_settle_count) {
 			p->numa_scan_period = max(p->numa_scan_period >> 1,
 					task_scan_min(p));
 		}
+		 */
 	}
 }
 
@@ -1167,10 +1171,20 @@ void task_numa_fault(int last_nidpid, in
 	/*
 	 * If pages are properly placed (did not migrate) then scan slower.
 	 * This is reset periodically in case of phase changes
-	 */
-        if (!migrated)
+	 *
+	 * APZ: it seems to me that one can get a ton of !migrated faults;
+	 * consider the scenario where two threads fight over a shared memory
+	 * segment. We'll win half the faults, half of that will be local, half
+	 * of that will be remote. This means we'll see 1/4-th of the total
+	 * memory being !migrated. Using a fixed increment will completely
+	 * flatten the scan speed for a sufficiently large workload. Another
+	 * scenario is due to that migration rate limit.
+	 *
+        if (!migrated) {
 		p->numa_scan_period = min(p->numa_scan_period_max,
 			p->numa_scan_period + jiffies_to_msecs(10));
+	}
+	 */
 
 	task_numa_placement(p);
 
@@ -1216,12 +1230,15 @@ void task_numa_work(struct callback_head
 	if (p->flags & PF_EXITING)
 		return;
 
+#if 0
 	/*
 	 * We do not care about task placement until a task runs on a node
 	 * other than the first one used by the address space. This is
 	 * largely because migrations are driven by what CPU the task
 	 * is running on. If it's never scheduled on another node, it'll
 	 * not migrate so why bother trapping the fault.
+	 *
+	 * APZ: seems like a bad idea for pure shared memory workloads.
 	 */
 	if (mm->first_nid == NUMA_PTE_SCAN_INIT)
 		mm->first_nid = numa_node_id();
@@ -1233,6 +1250,7 @@ void task_numa_work(struct callback_head
 
 		mm->first_nid = NUMA_PTE_SCAN_ACTIVE;
 	}
+#endif
 
 	/*
 	 * Enforce maximal scan/migration frequency..
@@ -1254,9 +1272,14 @@ void task_numa_work(struct callback_head
 	 * Do not set pte_numa if the current running node is rate-limited.
 	 * This loses statistics on the fault but if we are unwilling to
 	 * migrate to this node, it is less likely we can do useful work
-	 */
+	 *
+	 * APZ: seems like a bad idea; even if this node can't migrate anymore
+	 * other nodes might and we want up-to-date information to do balance
+	 * decisions.
+	 *
 	if (migrate_ratelimited(numa_node_id()))
 		return;
+	 */
 
 	start = mm->numa_scan_offset;
 	pages = sysctl_numa_balancing_scan_size;
@@ -1297,10 +1320,10 @@ void task_numa_work(struct callback_head
 
 out:
 	/*
-	 * It is possible to reach the end of the VMA list but the last few VMAs are
-	 * not guaranteed to the vma_migratable. If they are not, we would find the
-	 * !migratable VMA on the next scan but not reset the scanner to the start
-	 * so check it now.
+	 * It is possible to reach the end of the VMA list but the last few
+	 * VMAs are not guaranteed to the vma_migratable. If they are not, we
+	 * would find the !migratable VMA on the next scan but not reset the
+	 * scanner to the start so check it now.
 	 */
 	if (vma)
 		mm->numa_scan_offset = start;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
