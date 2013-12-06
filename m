Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8F16B0062
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 04:12:37 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so718424pbc.26
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 01:12:36 -0800 (PST)
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com. [202.81.31.148])
        by mx.google.com with ESMTPS id qz9si12171257pab.336.2013.12.06.01.12.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Dec 2013 01:12:36 -0800 (PST)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 6 Dec 2013 19:12:31 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 502CD3578053
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 20:12:29 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB68sIxr5439912
	for <linux-mm@kvack.org>; Fri, 6 Dec 2013 19:54:23 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB69CNXC000906
	for <linux-mm@kvack.org>; Fri, 6 Dec 2013 20:12:23 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 3/6] sched/numa: drop sysctl_numa_balancing_settle_count sysctl
Date: Fri,  6 Dec 2013 17:12:13 +0800
Message-Id: <1386321136-27538-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

commit 887c290e (sched/numa: Decide whether to favour task or group weights 
based on swap candidate relationships) drop the check against 
sysctl_numa_balancing_settle_count, this patch remove the sysctl.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 include/linux/sched/sysctl.h |    1 -
 kernel/sched/fair.c          |    9 ---------
 kernel/sysctl.c              |    7 -------
 3 files changed, 0 insertions(+), 17 deletions(-)

diff --git a/include/linux/sched/sysctl.h b/include/linux/sched/sysctl.h
index 41467f8..31e0193 100644
--- a/include/linux/sched/sysctl.h
+++ b/include/linux/sched/sysctl.h
@@ -48,7 +48,6 @@ extern unsigned int sysctl_numa_balancing_scan_delay;
 extern unsigned int sysctl_numa_balancing_scan_period_min;
 extern unsigned int sysctl_numa_balancing_scan_period_max;
 extern unsigned int sysctl_numa_balancing_scan_size;
-extern unsigned int sysctl_numa_balancing_settle_count;
 
 #ifdef CONFIG_SCHED_DEBUG
 extern unsigned int sysctl_sched_migration_cost;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index ea3fd1e..56bcc0c 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -886,15 +886,6 @@ static unsigned int task_scan_max(struct task_struct *p)
 	return max(smin, smax);
 }
 
-/*
- * Once a preferred node is selected the scheduler balancer will prefer moving
- * a task to that node for sysctl_numa_balancing_settle_count number of PTE
- * scans. This will give the process the chance to accumulate more faults on
- * the preferred node but still allow the scheduler to move the task again if
- * the nodes CPUs are overloaded.
- */
-unsigned int sysctl_numa_balancing_settle_count __read_mostly = 4;
-
 static void account_numa_enqueue(struct rq *rq, struct task_struct *p)
 {
 	rq->nr_numa_running += (p->numa_preferred_nid != -1);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 34a6047..c8da99f 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -385,13 +385,6 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.procname       = "numa_balancing_settle_count",
-		.data           = &sysctl_numa_balancing_settle_count,
-		.maxlen         = sizeof(unsigned int),
-		.mode           = 0644,
-		.proc_handler   = proc_dointvec,
-	},
-	{
 		.procname       = "numa_balancing_migrate_deferred",
 		.data           = &sysctl_numa_balancing_migrate_deferred,
 		.maxlen         = sizeof(unsigned int),
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
