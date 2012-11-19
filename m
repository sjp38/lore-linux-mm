Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 28D1F6B005D
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 21:16:13 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so3182484eek.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 18:16:12 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 25/27] sched: Introduce staged average NUMA faults
Date: Mon, 19 Nov 2012 03:14:42 +0100
Message-Id: <1353291284-2998-26-git-send-email-mingo@kernel.org>
In-Reply-To: <1353291284-2998-1-git-send-email-mingo@kernel.org>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

The current way of building the p->numa_faults[2][node] faults
statistics has a sampling artifact:

The continuous and immediate nature of propagating new fault
stats to the numa_faults array creates a 'pulsating' dynamic,
that starts at the average value at the beginning of the scan,
increases monotonically until we finish the scan to about twice
the average, and then drops back to half of its value due to
the running average.

Since we rely on these values to balance tasks, the pulsating
nature resulted in false migrations and general noise in the
stats.

To solve this, introduce buffering of the current scan via
p->task_numa_faults_curr[]. The array is co-allocated with the
p->task_numa[] for efficiency reasons, but it is otherwise an
ordinary separate array.

At the end of the scan we propagate the latest stats into the
average stats value. Most of the balancing code stays unmodified.

The cost of this change is that we delay the effects of the latest
round of faults by 1 scan - but using the partial faults info was
creating artifacts.

This instantly stabilized the page fault stats and improved
numa02-alike workloads by making them faster to converge.

Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/sched.h |  1 +
 kernel/sched/fair.c   | 20 +++++++++++++++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8f65323..92b41b4 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1511,6 +1511,7 @@ struct task_struct {
 	u64 node_stamp;			/* migration stamp  */
 	unsigned long numa_weight;
 	unsigned long *numa_faults;
+	unsigned long *numa_faults_curr;
 	struct callback_head numa_work;
 #endif /* CONFIG_NUMA_BALANCING */
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 9c46b45..1ab11be 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -852,12 +852,26 @@ static void task_numa_placement(struct task_struct *p)
 
 	p->numa_scan_seq = seq;
 
+	/*
+	 * Update the fault average with the result of the latest
+	 * scan:
+	 */
 	for (node = 0; node < nr_node_ids; node++) {
 		faults = 0;
 		for (priv = 0; priv < 2; priv++) {
-			faults += p->numa_faults[2*node + priv];
-			total[priv] += p->numa_faults[2*node + priv];
-			p->numa_faults[2*node + priv] /= 2;
+			unsigned int new_faults;
+			unsigned int idx;
+
+			idx = 2*node + priv;
+			new_faults = p->numa_faults_curr[idx];
+			p->numa_faults_curr[idx] = 0;
+
+			/* Keep a simple running average: */
+			p->numa_faults[idx] += new_faults;
+			p->numa_faults[idx] /= 2;
+
+			faults += p->numa_faults[idx];
+			total[priv] += p->numa_faults[idx];
 		}
 		if (faults > max_faults) {
 			max_faults = faults;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
