Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3613A9C002B
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:32 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so6915220pbc.12
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:31 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 51/63] sched: numa: Prevent parallel updates to group stats during placement
Date: Mon,  7 Oct 2013 11:29:29 +0100
Message-Id: <1381141781-10992-52-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Having multiple tasks in a group go through task_numa_placement
simultaneously can lead to a task picking a wrong node to run on, because
the group stats may be in the middle of an update. This patch avoids
parallel updates by holding the numa_group lock during placement
decisions.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 35 +++++++++++++++++++++++------------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index d5873e5..dc0c376 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1233,6 +1233,7 @@ static void task_numa_placement(struct task_struct *p)
 {
 	int seq, nid, max_nid = -1, max_group_nid = -1;
 	unsigned long max_faults = 0, max_group_faults = 0;
+	spinlock_t *group_lock = NULL;
 
 	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
 	if (p->numa_scan_seq == seq)
@@ -1241,6 +1242,12 @@ static void task_numa_placement(struct task_struct *p)
 	p->numa_migrate_seq++;
 	p->numa_scan_period_max = task_scan_max(p);
 
+	/* If the task is part of a group prevent parallel updates to group stats */
+	if (p->numa_group) {
+		group_lock = &p->numa_group->lock;
+		spin_lock(group_lock);
+	}
+
 	/* Find the node with the highest number of faults */
 	for_each_online_node(nid) {
 		unsigned long faults = 0, group_faults = 0;
@@ -1279,20 +1286,24 @@ static void task_numa_placement(struct task_struct *p)
 		}
 	}
 
-	/*
-	 * If the preferred task and group nids are different,
-	 * iterate over the nodes again to find the best place.
-	 */
-	if (p->numa_group && max_nid != max_group_nid) {
-		unsigned long weight, max_weight = 0;
-
-		for_each_online_node(nid) {
-			weight = task_weight(p, nid) + group_weight(p, nid);
-			if (weight > max_weight) {
-				max_weight = weight;
-				max_nid = nid;
+	if (p->numa_group) {
+		/*
+		 * If the preferred task and group nids are different,
+		 * iterate over the nodes again to find the best place.
+		 */
+		if (max_nid != max_group_nid) {
+			unsigned long weight, max_weight = 0;
+
+			for_each_online_node(nid) {
+				weight = task_weight(p, nid) + group_weight(p, nid);
+				if (weight > max_weight) {
+					max_weight = weight;
+					max_nid = nid;
+				}
 			}
 		}
+
+		spin_unlock(group_lock);
 	}
 
 	/* Preferred node as the node with the most faults */
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
