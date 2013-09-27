Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8320590001D
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:27 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so2557096pbc.35
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:27 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 34/63] sched: numa: increment numa_migrate_seq when task runs in correct location
Date: Fri, 27 Sep 2013 14:27:19 +0100
Message-Id: <1380288468-5551-35-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

When a task is already running on its preferred node, increment
numa_migrate_seq to indicate that the task is settled if migration is
temporarily disabled, and memory should migrate towards it.

[mgorman@suse.de: Only increment migrate_seq if migration temporarily disabled]
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 kernel/sched/fair.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 00ccc68..1a17e5e 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1016,8 +1016,16 @@ static void numa_migrate_preferred(struct task_struct *p)
 {
 	/* Success if task is already running on preferred CPU */
 	p->numa_migrate_retry = 0;
-	if (cpu_to_node(task_cpu(p)) == p->numa_preferred_nid)
+	if (cpu_to_node(task_cpu(p)) == p->numa_preferred_nid) {
+		/*
+		 * If migration is temporarily disabled due to a task migration
+		 * then re-enable it now as the task is running on its
+		 * preferred node and memory should migrate locally
+		 */
+		if (!p->numa_migrate_seq)
+			p->numa_migrate_seq++;
 		return;
+	}
 
 	/* This task has no NUMA fault statistics yet */
 	if (unlikely(p->numa_preferred_nid == -1))
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
