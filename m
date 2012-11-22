Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 766098D0011
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:51:33 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so3216535eaa.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:51:33 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 24/33] sched: Implement NUMA scanning backoff
Date: Thu, 22 Nov 2012 23:49:45 +0100
Message-Id: <1353624594-1118-25-git-send-email-mingo@kernel.org>
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Back off slowly from scanning, up to sysctl_sched_numa_scan_period_max
(1.6 seconds). Scan faster again if we were forced to switch to
another node.

This makes sure that workload in equilibrium don't get scanned as often
as workloads that are still converging.

Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/core.c | 6 ++++++
 kernel/sched/fair.c | 8 +++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index af0602f..ec3cc74 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -6024,6 +6024,12 @@ void sched_setnuma(struct task_struct *p, int node, int shared)
 	if (on_rq)
 		enqueue_task(rq, p, 0);
 	task_rq_unlock(rq, p, &flags);
+
+	/*
+	 * Reset the scanning period. If the task converges
+	 * on this node then we'll back off again:
+	 */
+	p->numa_scan_period = sysctl_sched_numa_scan_period_min;
 }
 
 #endif /* CONFIG_NUMA_BALANCING */
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 8f0e6ba..59fea2e 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -865,8 +865,10 @@ static void task_numa_placement(struct task_struct *p)
 		}
 	}
 
-	if (max_node != p->numa_max_node)
+	if (max_node != p->numa_max_node) {
 		sched_setnuma(p, max_node, task_numa_shared(p));
+		goto out_backoff;
+	}
 
 	p->numa_migrate_seq++;
 	if (sched_feat(NUMA_SETTLE) &&
@@ -882,7 +884,11 @@ static void task_numa_placement(struct task_struct *p)
 	if (shared != task_numa_shared(p)) {
 		sched_setnuma(p, p->numa_max_node, shared);
 		p->numa_migrate_seq = 0;
+		goto out_backoff;
 	}
+	return;
+out_backoff:
+	p->numa_scan_period = min(p->numa_scan_period * 2, sysctl_sched_numa_scan_period_max);
 }
 
 /*
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
