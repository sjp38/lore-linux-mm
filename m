Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id E294D6B0044
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 19:09:13 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/15] sched: Check current->mm before allocating NUMA faults
Date: Sat,  6 Jul 2013 00:08:56 +0100
Message-Id: <1373065742-9753-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1373065742-9753-1-git-send-email-mgorman@suse.de>
References: <1373065742-9753-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

task_numa_placement checks current->mm but after buffers for faults
have already been uselessly allocated. Move the check earlier.

[peterz@infradead.org: Identified the problem]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 3c69b599..aee3e0b 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -843,8 +843,6 @@ static void task_numa_placement(struct task_struct *p)
 	int seq, nid, max_nid = 0;
 	unsigned long max_faults = 0;
 
-	if (!p->mm)	/* for example, ksmd faulting in a user's mm */
-		return;
 	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
 	if (p->numa_scan_seq == seq)
 		return;
@@ -921,6 +919,10 @@ void task_numa_fault(int last_nid, int node, int pages, bool migrated)
 	if (!sched_feat_numa(NUMA))
 		return;
 
+	/* for example, ksmd faulting in a user's mm */
+	if (!p->mm)
+		return;
+
 	/* For now, do not attempt to detect private/shared accesses */
 	priv = 1;
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
