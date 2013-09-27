Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 01208900026
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:41 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so2588799pdj.20
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:41 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 50/63] sched: numa: call task_numa_free from do_execve
Date: Fri, 27 Sep 2013 14:27:35 +0100
Message-Id: <1380288468-5551-51-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

It is possible for a task in a numa group to call exec, and
have the new (unrelated) executable inherit the numa group
association from its former self.

This has the potential to break numa grouping, and is trivial
to fix.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/exec.c             | 1 +
 include/linux/sched.h | 4 ++++
 kernel/sched/fair.c   | 9 ++++++++-
 kernel/sched/sched.h  | 5 -----
 4 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index fd774c7..e73ce23 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1549,6 +1549,7 @@ static int do_execve_common(const char *filename,
 	current->fs->in_exec = 0;
 	current->in_execve = 0;
 	acct_update_integrals(current);
+	task_numa_free(current);
 	free_bprm(bprm);
 	if (displaced)
 		put_files_struct(displaced);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 46fb36a..31d1740 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1442,6 +1442,7 @@ struct task_struct {
 extern void task_numa_fault(int last_node, int node, int pages, int flags);
 extern pid_t task_numa_group_id(struct task_struct *p);
 extern void set_numabalancing_state(bool enabled);
+extern void task_numa_free(struct task_struct *p);
 #else
 static inline void task_numa_fault(int last_node, int node, int pages,
 				   int flags)
@@ -1454,6 +1455,9 @@ static inline pid_t task_numa_group_id(struct task_struct *p)
 static inline void set_numabalancing_state(bool enabled)
 {
 }
+static inline void task_numa_free(struct task_struct *p)
+{
+}
 #endif
 
 static inline struct pid *task_pid(struct task_struct *task)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 801fc74..5237feb 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1418,6 +1418,7 @@ void task_numa_free(struct task_struct *p)
 {
 	struct numa_group *grp = p->numa_group;
 	int i;
+	void *numa_faults = p->numa_faults;
 
 	if (grp) {
 		for (i = 0; i < 2*nr_node_ids; i++)
@@ -1433,7 +1434,9 @@ void task_numa_free(struct task_struct *p)
 		put_numa_group(grp);
 	}
 
-	kfree(p->numa_faults);
+	p->numa_faults = NULL;
+	p->numa_faults_buffer = NULL;
+	kfree(numa_faults);
 }
 
 /*
@@ -1452,6 +1455,10 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 	if (!p->mm)
 		return;
 
+	/* Do not worry about placement if exiting */
+	if (p->state == TASK_DEAD)
+		return;
+
 	/* Allocate buffer to track faults on a per-node basis */
 	if (unlikely(!p->numa_faults)) {
 		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index e0875dc..657472d 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -557,11 +557,6 @@ static inline u64 rq_clock_task(struct rq *rq)
 #ifdef CONFIG_NUMA_BALANCING
 extern int migrate_task_to(struct task_struct *p, int cpu);
 extern int migrate_swap(struct task_struct *, struct task_struct *);
-extern void task_numa_free(struct task_struct *p);
-#else /* CONFIG_NUMA_BALANCING */
-static inline void task_numa_free(struct task_struct *p)
-{
-}
 #endif /* CONFIG_NUMA_BALANCING */
 
 #ifdef CONFIG_SMP
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
