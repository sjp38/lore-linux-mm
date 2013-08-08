Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id C4740900003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:00:53 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/27] sched: numa: Initialise numa_next_scan properly
Date: Thu,  8 Aug 2013 15:00:21 +0100
Message-Id: <1375970439-5111-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1375970439-5111-1-git-send-email-mgorman@suse.de>
References: <1375970439-5111-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Scan delay logic and resets are currently initialised to start scanning
immediately instead of delaying properly. Initialise them properly at
fork time and catch when a new mm has been allocated.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/core.c | 4 ++--
 kernel/sched/fair.c | 7 +++++++
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index b7c32cb..e148975 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1625,8 +1625,8 @@ static void __sched_fork(struct task_struct *p)
 
 #ifdef CONFIG_NUMA_BALANCING
 	if (p->mm && atomic_read(&p->mm->mm_users) == 1) {
-		p->mm->numa_next_scan = jiffies;
-		p->mm->numa_next_reset = jiffies;
+		p->mm->numa_next_scan = jiffies + msecs_to_jiffies(sysctl_numa_balancing_scan_delay);
+		p->mm->numa_next_reset = jiffies + msecs_to_jiffies(sysctl_numa_balancing_scan_period_reset);
 		p->mm->numa_scan_seq = 0;
 	}
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index bb5d978..2f16703 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -900,6 +900,13 @@ void task_numa_work(struct callback_head *work)
 	if (p->flags & PF_EXITING)
 		return;
 
+	if (!mm->numa_next_reset || !mm->numa_next_scan) {
+		mm->numa_next_scan = now +
+			msecs_to_jiffies(sysctl_numa_balancing_scan_delay);
+		mm->numa_next_reset = now +
+			msecs_to_jiffies(sysctl_numa_balancing_scan_period_reset);
+	}
+
 	/*
 	 * Reset the scan period if enough time has gone by. Objective is that
 	 * scanning will be reduced if pages are properly placed. As tasks
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
