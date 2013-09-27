Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9F590000F
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:15 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so2787790pad.19
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:15 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 21/63] sched: Update NUMA hinting faults once per scan
Date: Fri, 27 Sep 2013 14:27:06 +0100
Message-Id: <1380288468-5551-22-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

NUMA hinting fault counts and placement decisions are both recorded in the
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
index d6ec68a..84fb883 100644
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
index 0235ab8..2e8f3e2 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1646,6 +1646,7 @@ static void __sched_fork(struct task_struct *p)
 	p->numa_preferred_nid = -1;
 	p->numa_work.next = &p->numa_work;
 	p->numa_faults = NULL;
+	p->numa_faults_buffer = NULL;
 #endif /* CONFIG_NUMA_BALANCING */
 }
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index f9bc867..0fe4c4c 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -892,8 +892,14 @@ static void task_numa_placement(struct task_struct *p)
 
 	/* Find the node with the highest number of faults */
 	for_each_online_node(nid) {
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
