Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id A9C38900008
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:01:02 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 17/27] sched: Update NUMA hinting faults once per scan
Date: Thu,  8 Aug 2013 15:00:29 +0100
Message-Id: <1375970439-5111-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1375970439-5111-1-git-send-email-mgorman@suse.de>
References: <1375970439-5111-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

NUMA hinting faults counts and placement decisions are both recorded in the
same array which distorts the samples in an unpredictable fashion. The values
linearly accumulate during the scan and then decay creating a sawtooth-like
pattern in the per-node counts. It also means that placement decisions are
time sensitive. At best it means that it is very difficult to state that
the buffer holds a decaying average of past faulting behaviour. At worst,
it can confuse the load balancer if it sees one node with an artifically high
count due to very recent faulting activity and may create a bouncing effect.

This patch adds a second array. numa_faults stores the historical data
which is used for placement decisions. numa_faults_buffer holds the
fault activity during the current scan window. When the scan completes,
numa_faults decays and the values from numa_faults_buffer are copied
across.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h | 13 +++++++++++++
 kernel/sched/core.c   |  1 +
 kernel/sched/fair.c   | 16 +++++++++++++---
 3 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index d65e31c..d017be9 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1335,7 +1335,20 @@ struct task_struct {
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
 
+	/*
+	 * Exponential decaying average of faults on a per-node basis.
+	 * Scheduling placement decisions are made based on the these counts.
+	 * The values remain static for the duration of a PTE scan
+	 */
 	unsigned long *numa_faults;
+
+	/*
+	 * numa_faults_buffer records faults per node during the current
+	 * scan window. When the scan completes, the counts in numa_faults
+	 * decay and these values are copied.
+	 */
+	unsigned long *numa_faults_buffer;
+
 	int numa_preferred_nid;
 #endif /* CONFIG_NUMA_BALANCING */
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 194559e..aad32ff 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1637,6 +1637,7 @@ static void __sched_fork(struct task_struct *p)
 	p->numa_preferred_nid = -1;
 	p->numa_work.next = &p->numa_work;
 	p->numa_faults = NULL;
+	p->numa_faults_buffer = NULL;
 #endif /* CONFIG_NUMA_BALANCING */
 }
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index ee8da21..8ca8901 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -892,8 +892,14 @@ static void task_numa_placement(struct task_struct *p)
 
 	/* Find the node with the highest number of faults */
 	for (nid = 0; nid < nr_node_ids; nid++) {
-		unsigned long faults = p->numa_faults[nid];
+		unsigned long faults;
+
+		/* Decay existing window and copy faults since last scan */
 		p->numa_faults[nid] >>= 1;
+		p->numa_faults[nid] += p->numa_faults_buffer[nid];
+		p->numa_faults_buffer[nid] = 0;
+
+		faults = p->numa_faults[nid];
 		if (faults > max_faults) {
 			max_faults = faults;
 			max_nid = nid;
@@ -919,9 +925,13 @@ void task_numa_fault(int node, int pages, bool migrated)
 	if (unlikely(!p->numa_faults)) {
 		int size = sizeof(*p->numa_faults) * nr_node_ids;
 
-		p->numa_faults = kzalloc(size, GFP_KERNEL|__GFP_NOWARN);
+		/* numa_faults and numa_faults_buffer share the allocation */
+		p->numa_faults = kzalloc(size * 2, GFP_KERNEL|__GFP_NOWARN);
 		if (!p->numa_faults)
 			return;
+
+		BUG_ON(p->numa_faults_buffer);
+		p->numa_faults_buffer = p->numa_faults + nr_node_ids;
 	}
 
 	/*
@@ -939,7 +949,7 @@ void task_numa_fault(int node, int pages, bool migrated)
 
 	task_numa_placement(p);
 
-	p->numa_faults[node] += pages;
+	p->numa_faults_buffer[node] += pages;
 }
 
 static void reset_ptenuma_scan(struct task_struct *p)
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
