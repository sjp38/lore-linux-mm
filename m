Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id C94B96B0035
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 16:14:56 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id m20so4180692qcx.9
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 13:14:56 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id o46si3268562qgo.158.2014.01.17.13.14.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jan 2014 13:14:55 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH 1/7] numa,sched,mm: remove p->numa_migrate_deferred
Date: Fri, 17 Jan 2014 16:12:03 -0500
Message-Id: <1389993129-28180-2-git-send-email-riel@redhat.com>
In-Reply-To: <1389993129-28180-1-git-send-email-riel@redhat.com>
References: <1389993129-28180-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, chegu_vinod@hp.com, peterz@infradead.org, mgorman@suse.de, mingo@redhat.com

From: Rik van Riel <riel@redhat.com>

Excessive migration of pages can hurt the performance of workloads
that span multiple NUMA nodes.  However, it turns out that the
p->numa_migrate_deferred knob is a really big hammer, which does
reduce migration rates, but does not actually help performance.

Now that the second stage of the automatic numa balancing code
has stabilized, it is time to replace the simplistic migration
deferral code with something smarter.

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Chegu Vinod <chegu_vinod@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/sched.h |  1 -
 kernel/sched/fair.c   |  8 --------
 kernel/sysctl.c       |  7 -------
 mm/mempolicy.c        | 45 ---------------------------------------------
 4 files changed, 61 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 68a0e84..97efba4 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1469,7 +1469,6 @@ struct task_struct {
 	unsigned int numa_scan_period;
 	unsigned int numa_scan_period_max;
 	int numa_preferred_nid;
-	int numa_migrate_deferred;
 	unsigned long numa_migrate_retry;
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 867b0a4..41e2176 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -819,14 +819,6 @@ unsigned int sysctl_numa_balancing_scan_size = 256;
 /* Scan @scan_size MB every @scan_period after an initial @scan_delay in ms */
 unsigned int sysctl_numa_balancing_scan_delay = 1000;
 
-/*
- * After skipping a page migration on a shared page, skip N more numa page
- * migrations unconditionally. This reduces the number of NUMA migrations
- * in shared memory workloads, and has the effect of pulling tasks towards
- * where their memory lives, over pulling the memory towards the task.
- */
-unsigned int sysctl_numa_balancing_migrate_deferred = 16;
-
 static unsigned int task_nr_scan_windows(struct task_struct *p)
 {
 	unsigned long rss = 0;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 096db74..4d19492 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -384,13 +384,6 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.procname       = "numa_balancing_migrate_deferred",
-		.data           = &sysctl_numa_balancing_migrate_deferred,
-		.maxlen         = sizeof(unsigned int),
-		.mode           = 0644,
-		.proc_handler   = proc_dointvec,
-	},
-	{
 		.procname	= "numa_balancing",
 		.data		= NULL, /* filled in by handler */
 		.maxlen		= sizeof(unsigned int),
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 36cb46c..052abac 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2301,35 +2301,6 @@ static void sp_free(struct sp_node *n)
 	kmem_cache_free(sn_cache, n);
 }
 
-#ifdef CONFIG_NUMA_BALANCING
-static bool numa_migrate_deferred(struct task_struct *p, int last_cpupid)
-{
-	/* Never defer a private fault */
-	if (cpupid_match_pid(p, last_cpupid))
-		return false;
-
-	if (p->numa_migrate_deferred) {
-		p->numa_migrate_deferred--;
-		return true;
-	}
-	return false;
-}
-
-static inline void defer_numa_migrate(struct task_struct *p)
-{
-	p->numa_migrate_deferred = sysctl_numa_balancing_migrate_deferred;
-}
-#else
-static inline bool numa_migrate_deferred(struct task_struct *p, int last_cpupid)
-{
-	return false;
-}
-
-static inline void defer_numa_migrate(struct task_struct *p)
-{
-}
-#endif /* CONFIG_NUMA_BALANCING */
-
 /**
  * mpol_misplaced - check whether current page node is valid in policy
  *
@@ -2432,24 +2403,8 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		 */
 		last_cpupid = page_cpupid_xchg_last(page, this_cpupid);
 		if (!cpupid_pid_unset(last_cpupid) && cpupid_to_nid(last_cpupid) != thisnid) {
-
-			/* See sysctl_numa_balancing_migrate_deferred comment */
-			if (!cpupid_match_pid(current, last_cpupid))
-				defer_numa_migrate(current);
-
 			goto out;
 		}
-
-		/*
-		 * The quadratic filter above reduces extraneous migration
-		 * of shared pages somewhat. This code reduces it even more,
-		 * reducing the overhead of page migrations of shared pages.
-		 * This makes workloads with shared pages rely more on
-		 * "move task near its memory", and less on "move memory
-		 * towards its task", which is exactly what we want.
-		 */
-		if (numa_migrate_deferred(current, last_cpupid))
-			goto out;
 	}
 
 	if (curnid != polnid)
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
