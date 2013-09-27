Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1A303900015
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:20 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so2594949pde.24
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:19 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 26/63] sched: Check current->mm before allocating NUMA faults
Date: Fri, 27 Sep 2013 14:27:11 +0100
Message-Id: <1380288468-5551-27-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

task_numa_placement checks current->mm but after buffers for faults
have already been uselessly allocated. Move the check earlier.

[peterz@infradead.org: Identified the problem]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 96f6f08..7b7bc48 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -930,8 +930,6 @@ static void task_numa_placement(struct task_struct *p)
 	int seq, nid, max_nid = -1;
 	unsigned long max_faults = 0;
 
-	if (!p->mm)	/* for example, ksmd faulting in a user's mm */
-		return;
 	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
 	if (p->numa_scan_seq == seq)
 		return;
@@ -998,6 +996,10 @@ void task_numa_fault(int last_nid, int node, int pages, bool migrated)
 	if (!numabalancing_enabled)
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
