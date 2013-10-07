Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id E23A79C0034
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:34 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so6906538pdj.26
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:34 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 54/63] sched: numa: fix task or group comparison
Date: Mon,  7 Oct 2013 11:29:32 +0100
Message-Id: <1381141781-10992-55-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

This patch separately considers task and group affinities when
searching for swap candidates during NUMA placement. If tasks
are part of the same group, or no group at all, the task weights
are considered.

Some hysteresis is added to prevent tasks within one group from
getting bounced between NUMA nodes due to tiny differences.

If tasks are part of different groups, the code compares group
weights, in order to favor grouping task groups together.

The patch also changes the group weight multiplier to be the
same as the task weight multiplier, since the two are no longer
added up like before.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 32 +++++++++++++++++++++++++-------
 1 file changed, 25 insertions(+), 7 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index e7da6f2..6daf82e 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -962,7 +962,7 @@ static inline unsigned long group_weight(struct task_struct *p, int nid)
 	if (!total_faults)
 		return 0;
 
-	return 1200 * group_faults(p, nid) / total_faults;
+	return 1000 * group_faults(p, nid) / total_faults;
 }
 
 static unsigned long weighted_cpuload(const int cpu);
@@ -1068,16 +1068,34 @@ static void task_numa_compare(struct task_numa_env *env,
 
 		/*
 		 * If dst and source tasks are in the same NUMA group, or not
-		 * in any group then look only at task weights otherwise give
-		 * priority to the group weights.
+		 * in any group then look only at task weights.
 		 */
-		if (!cur->numa_group || !env->p->numa_group ||
-		    cur->numa_group == env->p->numa_group) {
+		if (cur->numa_group == env->p->numa_group) {
 			imp = taskimp + task_weight(cur, env->src_nid) -
 			      task_weight(cur, env->dst_nid);
+			/*
+			 * Add some hysteresis to prevent swapping the
+			 * tasks within a group over tiny differences.
+			 */
+			if (cur->numa_group)
+				imp -= imp/16;
 		} else {
-			imp = groupimp + group_weight(cur, env->src_nid) -
-			       group_weight(cur, env->dst_nid);
+			/*
+			 * Compare the group weights. If a task is all by
+			 * itself (not part of a group), use the task weight
+			 * instead.
+			 */
+			if (env->p->numa_group)
+				imp = groupimp;
+			else
+				imp = taskimp;
+
+			if (cur->numa_group)
+				imp += group_weight(cur, env->src_nid) -
+				       group_weight(cur, env->dst_nid);
+			else
+				imp += task_weight(cur, env->src_nid) -
+				       task_weight(cur, env->dst_nid);
 		}
 	}
 
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
