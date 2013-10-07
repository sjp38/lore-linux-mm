Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9F19C0038
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:41 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so7088036pab.40
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:41 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 61/63] sched: numa: skip some page migrations after a shared fault
Date: Mon,  7 Oct 2013 11:29:39 +0100
Message-Id: <1381141781-10992-62-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

Shared faults can lead to lots of unnecessary page migrations,
slowing down the system, and causing private faults to hit the
per-pgdat migration ratelimit.

This patch adds sysctl numa_balancing_migrate_deferred, which specifies
how many shared page migrations to skip unconditionally, after each page
migration that is skipped because it is a shared fault.

This reduces the number of page migrations back and forth in
shared fault situations. It also gives a strong preference to
the tasks that are already running where most of the memory is,
and to moving the other tasks to near the memory.

Testing this with a much higher scan rate than the default
still seems to result in fewer page migrations than before.

Memory seems to be somewhat better consolidated than previously,
with multi-instance specjbb runs on a 4 node system.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/sysctl/kernel.txt | 10 ++++++++-
 include/linux/sched.h           |  5 ++++-
 kernel/sched/fair.c             |  8 +++++++
 kernel/sysctl.c                 |  7 ++++++
 mm/mempolicy.c                  | 48 ++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 75 insertions(+), 3 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index 84f1780..4273b2d 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -375,7 +375,8 @@ feature should be disabled. Otherwise, if the system overhead from the
 feature is too high then the rate the kernel samples for NUMA hinting
 faults may be controlled by the numa_balancing_scan_period_min_ms,
 numa_balancing_scan_delay_ms, numa_balancing_scan_period_max_ms,
-numa_balancing_scan_size_mb and numa_balancing_settle_count sysctls.
+numa_balancing_scan_size_mb, numa_balancing_settle_count sysctls and
+numa_balancing_migrate_deferred.
 
 ==============================================================
 
@@ -421,6 +422,13 @@ the schedule balancer stops pushing the task towards a preferred node. This
 gives the scheduler a chance to place the task on an alternative node if the
 preferred node is overloaded.
 
+numa_balancing_migrate_deferred is how many page migrations get skipped
+unconditionally, after a page migration is skipped because a page is shared
+with other tasks. This reduces page migration overhead, and determines
+how much stronger the "move task near its memory" policy scheduler becomes,
+versus the "move memory near its task" memory management policy, for workloads
+with shared memory.
+
 ==============================================================
 
 osrelease, ostype & version:
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0f6b1b3..b737b72 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1332,6 +1332,8 @@ struct task_struct {
 	int numa_scan_seq;
 	unsigned int numa_scan_period;
 	unsigned int numa_scan_period_max;
+	int numa_preferred_nid;
+	int numa_migrate_deferred;
 	unsigned long numa_migrate_retry;
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
@@ -1362,7 +1364,6 @@ struct task_struct {
 	 */
 	unsigned long numa_faults_locality[2];
 
-	int numa_preferred_nid;
 	unsigned long numa_pages_migrated;
 #endif /* CONFIG_NUMA_BALANCING */
 
@@ -1459,6 +1460,8 @@ extern void task_numa_fault(int last_node, int node, int pages, int flags);
 extern pid_t task_numa_group_id(struct task_struct *p);
 extern void set_numabalancing_state(bool enabled);
 extern void task_numa_free(struct task_struct *p);
+
+extern unsigned int sysctl_numa_balancing_migrate_deferred;
 #else
 static inline void task_numa_fault(int last_node, int node, int pages,
 				   int flags)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index ceffce9..9e2271b 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -833,6 +833,14 @@ unsigned int sysctl_numa_balancing_scan_size = 256;
 /* Scan @scan_size MB every @scan_period after an initial @scan_delay in ms */
 unsigned int sysctl_numa_balancing_scan_delay = 1000;
 
+/*
+ * After skipping a page migration on a shared page, skip N more numa page
+ * migrations unconditionally. This reduces the number of NUMA migrations
+ * in shared memory workloads, and has the effect of pulling tasks towards
+ * where their memory lives, over pulling the memory towards the task.
+ */
+unsigned int sysctl_numa_balancing_migrate_deferred = 16;
+
 static unsigned int task_nr_scan_windows(struct task_struct *p)
 {
 	unsigned long rss = 0;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index e509b90..a159e1f 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -391,6 +391,13 @@ static struct ctl_table kern_table[] = {
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec,
 	},
+	{
+		.procname       = "numa_balancing_migrate_deferred",
+		.data           = &sysctl_numa_balancing_migrate_deferred,
+		.maxlen         = sizeof(unsigned int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec,
+	},
 #endif /* CONFIG_NUMA_BALANCING */
 #endif /* CONFIG_SCHED_DEBUG */
 	{
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2929c24..71cb253 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2301,6 +2301,35 @@ static void sp_free(struct sp_node *n)
 	kmem_cache_free(sn_cache, n);
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+static bool numa_migrate_deferred(struct task_struct *p, int last_cpupid)
+{
+	/* Never defer a private fault */
+	if (cpupid_match_pid(p, last_cpupid))
+		return false;
+
+	if (p->numa_migrate_deferred) {
+		p->numa_migrate_deferred--;
+		return true;
+	}
+	return false;
+}
+
+static inline void defer_numa_migrate(struct task_struct *p)
+{
+	p->numa_migrate_deferred = sysctl_numa_balancing_migrate_deferred;
+}
+#else
+static inline bool numa_migrate_deferred(struct task_struct *p, int last_cpupid)
+{
+	return false;
+}
+
+static inline void defer_numa_migrate(struct task_struct *p)
+{
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
 /**
  * mpol_misplaced - check whether current page node is valid in policy
  *
@@ -2402,7 +2431,24 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		 * relation.
 		 */
 		last_cpupid = page_cpupid_xchg_last(page, this_cpupid);
-		if (!cpupid_pid_unset(last_cpupid) && cpupid_to_nid(last_cpupid) != thisnid)
+		if (!cpupid_pid_unset(last_cpupid) && cpupid_to_nid(last_cpupid) != thisnid) {
+
+			/* See sysctl_numa_balancing_migrate_deferred comment */
+			if (!cpupid_match_pid(current, last_cpupid))
+				defer_numa_migrate(current);
+
+			goto out;
+		}
+
+		/*
+		 * The quadratic filter above reduces extraneous migration
+		 * of shared pages somewhat. This code reduces it even more,
+		 * reducing the overhead of page migrations of shared pages.
+		 * This makes workloads with shared pages rely more on
+		 * "move task near its memory", and less on "move memory
+		 * towards its task", which is exactly what we want.
+		 */
+		if (numa_migrate_deferred(current, last_cpupid))
 			goto out;
 	}
 
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
