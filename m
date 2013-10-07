Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 779D49C0036
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:37 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so7010854pdi.27
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:37 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 57/63] sched: numa: Take false sharing into account when adapting scan rate
Date: Mon,  7 Oct 2013 11:29:35 +0100
Message-Id: <1381141781-10992-58-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Scan rate is altered based on whether shared/private faults dominated.
task_numa_group() may detect false sharing but that information is not
taken into account when adapting the scan rate. Take it into account.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index baa2276..03698f5 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1381,7 +1381,8 @@ static void double_lock(spinlock_t *l1, spinlock_t *l2)
 	spin_lock_nested(l2, SINGLE_DEPTH_NESTING);
 }
 
-static void task_numa_group(struct task_struct *p, int cpupid, int flags)
+static void task_numa_group(struct task_struct *p, int cpupid, int flags,
+			int *priv)
 {
 	struct numa_group *grp, *my_grp;
 	struct task_struct *tsk;
@@ -1447,6 +1448,9 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags)
 	if (flags & TNF_SHARED)
 		join = true;
 
+	/* Update priv based on whether false sharing was detected */
+	*priv = !join;
+
 	if (join && !get_numa_group(grp))
 		join = false;
 
@@ -1545,7 +1549,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 	} else {
 		priv = cpupid_match_pid(p, last_cpupid);
 		if (!priv && !(flags & TNF_NO_GROUP))
-			task_numa_group(p, last_cpupid, flags);
+			task_numa_group(p, last_cpupid, flags, &priv);
 	}
 
 	/*
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
