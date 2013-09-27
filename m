Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 33E50900026
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:37 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so2585708pdj.40
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:36 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 44/63] sched: numa: Report a NUMA task group ID
Date: Fri, 27 Sep 2013 14:27:29 +0100
Message-Id: <1380288468-5551-45-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

It is desirable to model from userspace how the scheduler groups tasks
over time. This patch adds an ID to the numa_group and reports it via
/proc/PID/status.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/proc/array.c       | 2 ++
 include/linux/sched.h | 5 +++++
 kernel/sched/fair.c   | 7 +++++++
 3 files changed, 14 insertions(+)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index cbd0f1b..1bd2077 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -183,6 +183,7 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 	seq_printf(m,
 		"State:\t%s\n"
 		"Tgid:\t%d\n"
+		"Ngid:\t%d\n"
 		"Pid:\t%d\n"
 		"PPid:\t%d\n"
 		"TracerPid:\t%d\n"
@@ -190,6 +191,7 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 		"Gid:\t%d\t%d\t%d\t%d\n",
 		get_task_state(p),
 		task_tgid_nr_ns(p, ns),
+		task_numa_group_id(p),
 		pid_nr_ns(pid, ns),
 		ppid, tpid,
 		from_kuid_munged(user_ns, cred->uid),
diff --git a/include/linux/sched.h b/include/linux/sched.h
index ea057a2..4fad1f17 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1436,12 +1436,17 @@ struct task_struct {
 
 #ifdef CONFIG_NUMA_BALANCING
 extern void task_numa_fault(int last_node, int node, int pages, bool migrated);
+extern pid_t task_numa_group_id(struct task_struct *p);
 extern void set_numabalancing_state(bool enabled);
 #else
 static inline void task_numa_fault(int last_node, int node, int pages,
 				   bool migrated)
 {
 }
+static inline pid_t task_numa_group_id(struct task_struct *p)
+{
+	return 0;
+}
 static inline void set_numabalancing_state(bool enabled)
 {
 }
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index a5673c6..abdbb7c 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -893,12 +893,18 @@ struct numa_group {
 
 	spinlock_t lock; /* nr_tasks, tasks */
 	int nr_tasks;
+	pid_t gid;
 	struct list_head task_list;
 
 	struct rcu_head rcu;
 	atomic_long_t faults[0];
 };
 
+pid_t task_numa_group_id(struct task_struct *p)
+{
+	return p->numa_group ? p->numa_group->gid : 0;
+}
+
 static inline int task_faults_idx(int nid, int priv)
 {
 	return 2 * nid + priv;
@@ -1265,6 +1271,7 @@ static void task_numa_group(struct task_struct *p, int cpupid)
 		atomic_set(&grp->refcount, 1);
 		spin_lock_init(&grp->lock);
 		INIT_LIST_HEAD(&grp->task_list);
+		grp->gid = p->pid;
 
 		for (i = 0; i < 2*nr_node_ids; i++)
 			atomic_long_set(&grp->faults[i], p->numa_faults[i]);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
