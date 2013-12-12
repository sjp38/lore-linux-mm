Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 78DF26B0038
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 02:24:09 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so24030pde.0
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 23:24:09 -0800 (PST)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id 2si14061628pax.196.2013.12.11.23.24.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 23:24:08 -0800 (PST)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 12 Dec 2013 12:53:56 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 607B9394004E
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:53:54 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBC7NoRt13041748
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:53:50 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBC7NrAg006998
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:53:53 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v8 2/4] sched/numa: use wrapper function task_node to get node which task is on
Date: Thu, 12 Dec 2013 15:23:24 +0800
Message-Id: <1386833006-6600-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386833006-6600-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386833006-6600-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 v2 -> v3:
  * tranlate cpu_to_node(task_cpu(p)) to task_node(p) in sched/debug.c

Use wrapper function task_node to get node which task is on.

Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: David Rientjes <rientjes@google.com>
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
index acdef27..c3f6ff9 100644
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
 
@@ -1283,7 +1283,7 @@ static void numa_migrate_preferred(struct task_struct *p)
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
