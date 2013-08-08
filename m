Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id B53A2900003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:00:50 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/27] sched, numa: Mitigate chance that same task always updates PTEs
Date: Thu,  8 Aug 2013 15:00:18 +0100
Message-Id: <1375970439-5111-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1375970439-5111-1-git-send-email-mgorman@suse.de>
References: <1375970439-5111-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <peterz@infradead.org>

With a trace_printk("working\n"); right after the cmpxchg in
task_numa_work() we can see that of a 4 thread process, its always the
same task winning the race and doing the protection change.

This is a problem since the task doing the protection change has a
penalty for taking faults -- it is busy when marking the PTEs. If its
always the same task the ->numa_faults[] get severely skewed.

Avoid this by delaying the task doing the protection change such that
it is unlikely to win the privilege again.

Before:

root@interlagos:~# grep "thread 0/.*working" /debug/tracing/trace | tail -15
      thread 0/0-3232  [022] ....   212.787402: task_numa_work: working
      thread 0/0-3232  [022] ....   212.888473: task_numa_work: working
      thread 0/0-3232  [022] ....   212.989538: task_numa_work: working
      thread 0/0-3232  [022] ....   213.090602: task_numa_work: working
      thread 0/0-3232  [022] ....   213.191667: task_numa_work: working
      thread 0/0-3232  [022] ....   213.292734: task_numa_work: working
      thread 0/0-3232  [022] ....   213.393804: task_numa_work: working
      thread 0/0-3232  [022] ....   213.494869: task_numa_work: working
      thread 0/0-3232  [022] ....   213.596937: task_numa_work: working
      thread 0/0-3232  [022] ....   213.699000: task_numa_work: working
      thread 0/0-3232  [022] ....   213.801067: task_numa_work: working
      thread 0/0-3232  [022] ....   213.903155: task_numa_work: working
      thread 0/0-3232  [022] ....   214.005201: task_numa_work: working
      thread 0/0-3232  [022] ....   214.107266: task_numa_work: working
      thread 0/0-3232  [022] ....   214.209342: task_numa_work: working

After:

root@interlagos:~# grep "thread 0/.*working" /debug/tracing/trace | tail -15
      thread 0/0-3253  [005] ....   136.865051: task_numa_work: working
      thread 0/2-3255  [026] ....   136.965134: task_numa_work: working
      thread 0/3-3256  [024] ....   137.065217: task_numa_work: working
      thread 0/3-3256  [024] ....   137.165302: task_numa_work: working
      thread 0/3-3256  [024] ....   137.265382: task_numa_work: working
      thread 0/0-3253  [004] ....   137.366465: task_numa_work: working
      thread 0/2-3255  [026] ....   137.466549: task_numa_work: working
      thread 0/0-3253  [004] ....   137.566629: task_numa_work: working
      thread 0/0-3253  [004] ....   137.666711: task_numa_work: working
      thread 0/1-3254  [028] ....   137.766799: task_numa_work: working
      thread 0/0-3253  [004] ....   137.866876: task_numa_work: working
      thread 0/2-3255  [026] ....   137.966960: task_numa_work: working
      thread 0/1-3254  [028] ....   138.067041: task_numa_work: working
      thread 0/2-3255  [026] ....   138.167123: task_numa_work: working
      thread 0/3-3256  [024] ....   138.267207: task_numa_work: working

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 679cfcf..2a08727 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -946,6 +946,12 @@ void task_numa_work(struct callback_head *work)
 		return;
 
 	/*
+	 * Delay this task enough that another task of this mm will likely win
+	 * the next time around.
+	 */
+	p->node_stamp += 2 * TICK_NSEC;
+
+	/*
 	 * Do not set pte_numa if the current running node is rate-limited.
 	 * This loses statistics on the fault but if we are unwilling to
 	 * migrate to this node, it is less likely we can do useful work
@@ -1026,7 +1032,7 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
 	if (now - curr->node_stamp > period) {
 		if (!curr->node_stamp)
 			curr->numa_scan_period = sysctl_numa_balancing_scan_period_min;
-		curr->node_stamp = now;
+		curr->node_stamp += period;
 
 		if (!time_before(jiffies, curr->mm->numa_next_scan)) {
 			init_task_work(work, task_numa_work); /* TODO: move this into sched_fork() */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
