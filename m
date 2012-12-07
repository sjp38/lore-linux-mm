Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 561D36B00C4
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:58 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 35/49] sched: numa: Slowly increase the scanning period as NUMA faults are handled
Date: Fri,  7 Dec 2012 10:23:38 +0000
Message-Id: <1354875832-9700-36-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Currently the rate of scanning for an address space is controlled
by the individual tasks. The next scan is simply determined by
2*p->numa_scan_period.

The 2*p->numa_scan_period is arbitrary and never changes. At this point
there is still no proper policy that decides if a task or process is
properly placed. It just scans and assumes the next NUMA fault will
place it properly. As it is assumed that pages will get properly placed
over time, increase the scan window each time a fault is incurred. This
is a big assumption as noted in the comments.

It should be noted that changing to p->numa_scan_period will increase
system CPU usage because now the scanning rate has effectively doubled.
If that is a problem then the min_rate should be made 200ms instead of
restoring the 2* logic.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 357057c..3c632448 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -812,6 +812,15 @@ void task_numa_fault(int node, int pages)
 
 	/* FIXME: Allocate task-specific structure for placement policy here */
 
+	/*
+	 * Assume that as faults occur that pages are getting properly placed
+	 * and fewer NUMA hints are required. Note that this is a big
+	 * assumption, it assumes processes reach a steady steady with no
+	 * further phase changes.
+	 */
+	p->numa_scan_period = min(sysctl_balance_numa_scan_period_max,
+				p->numa_scan_period + jiffies_to_msecs(2));
+
 	task_numa_placement(p);
 }
 
@@ -858,7 +867,7 @@ void task_numa_work(struct callback_head *work)
 	if (p->numa_scan_period == 0)
 		p->numa_scan_period = sysctl_balance_numa_scan_period_min;
 
-	next_scan = now + 2*msecs_to_jiffies(p->numa_scan_period);
+	next_scan = now + msecs_to_jiffies(p->numa_scan_period);
 	if (cmpxchg(&mm->numa_next_scan, migrate, next_scan) != migrate)
 		return;
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
