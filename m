Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 94DE86B0039
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 19:50:20 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so8372874pde.6
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:50:20 -0800 (PST)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id xa2si11855113pab.113.2013.12.10.16.50.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 16:50:19 -0800 (PST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 06:20:13 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id F23E2E0053
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:22:30 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBB0o9E56947084
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:20:09 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBB0oB1q020191
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:20:11 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v5 3/8] sched/numa: use wrapper function task_node to get node which task is on
Date: Wed, 11 Dec 2013 08:49:56 +0800
Message-Id: <1386723001-25408-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386723001-25408-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386723001-25408-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 v2 -> v3:
  * tranlate cpu_to_node(task_cpu(p)) to task_node(p) in sched/debug.c

Use wrapper function task_node to get node which task is on.

Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 kernel/sched/debug.c |    2 +-
 kernel/sched/fair.c  |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/sched/debug.c b/kernel/sched/debug.c
index 5c34d18..374fe04 100644
--- a/kernel/sched/debug.c
+++ b/kernel/sched/debug.c
@@ -139,7 +139,7 @@ print_task(struct seq_file *m, struct rq *rq, struct task_struct *p)
 		0LL, 0LL, 0LL, 0L, 0LL, 0L, 0LL, 0L);
 #endif
 #ifdef CONFIG_NUMA_BALANCING
-	SEQ_printf(m, " %d", cpu_to_node(task_cpu(p)));
+	SEQ_printf(m, " %d", task_node(p));
 #endif
 #ifdef CONFIG_CGROUP_SCHED
 	SEQ_printf(m, " %s", task_group_path(task_group(p)));
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 57f28d0..c20d22f 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1216,7 +1216,7 @@ static int task_numa_migrate(struct task_struct *p)
 	 * elsewhere, so there is no point in (re)trying.
 	 */
 	if (unlikely(!sd)) {
-		p->numa_preferred_nid = cpu_to_node(task_cpu(p));
+		p->numa_preferred_nid = task_node(p);
 		return -EINVAL;
 	}
 
@@ -1287,7 +1287,7 @@ static void numa_migrate_preferred(struct task_struct *p)
 	p->numa_migrate_retry = jiffies + HZ;
 
 	/* Success if task is already running on preferred CPU */
-	if (cpu_to_node(task_cpu(p)) == p->numa_preferred_nid)
+	if (task_node(p) == p->numa_preferred_nid)
 		return;
 
 	/* Otherwise, try migrate to a CPU on the preferred node */
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
