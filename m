Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id AEB086B0035
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 16:19:21 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id n7so4111491qcx.16
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 13:19:21 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id q18si14147756qeu.44.2014.01.17.13.19.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jan 2014 13:19:20 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH 5/7] numa,sched,mm: use active_nodes nodemask to limit numa migrations
Date: Fri, 17 Jan 2014 16:12:07 -0500
Message-Id: <1389993129-28180-6-git-send-email-riel@redhat.com>
In-Reply-To: <1389993129-28180-1-git-send-email-riel@redhat.com>
References: <1389993129-28180-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, chegu_vinod@hp.com, peterz@infradead.org, mgorman@suse.de, mingo@redhat.com

From: Rik van Riel <riel@redhat.com>

Use the active_nodes nodemask to make smarter decisions on NUMA migrations.

In order to maximize performance of workloads that do not fit in one NUMA
node, we want to satisfy the following criteria:
1) keep private memory local to each thread
2) avoid excessive NUMA migration of pages
3) distribute shared memory across the active nodes, to
   maximize memory bandwidth available to the workload

This patch accomplishes that by implementing the following policy for
NUMA migrations:
1) always migrate on a private fault
2) never migrate to a node that is not in the set of active nodes
   for the numa_group
3) always migrate from a node outside of the set of active nodes,
   to a node that is in that set
4) within the set of active nodes in the numa_group, only migrate
   from a node with more NUMA page faults, to a node with fewer
   NUMA page faults, with a 25% margin to avoid ping-ponging

This results in most pages of a workload ending up on the actively
used nodes, with reduced ping-ponging of pages between those nodes.

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Chegu Vinod <chegu_vinod@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/sched.h |  7 +++++++
 kernel/sched/fair.c   | 37 +++++++++++++++++++++++++++++++++++++
 mm/mempolicy.c        |  3 +++
 3 files changed, 47 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index a9f7f05..0af6c1a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1602,6 +1602,8 @@ extern void task_numa_fault(int last_node, int node, int pages, int flags);
 extern pid_t task_numa_group_id(struct task_struct *p);
 extern void set_numabalancing_state(bool enabled);
 extern void task_numa_free(struct task_struct *p);
+extern bool should_numa_migrate(struct task_struct *p, int last_cpupid,
+				int src_nid, int dst_nid);
 #else
 static inline void task_numa_fault(int last_node, int node, int pages,
 				   int flags)
@@ -1617,6 +1619,11 @@ static inline void set_numabalancing_state(bool enabled)
 static inline void task_numa_free(struct task_struct *p)
 {
 }
+static inline bool should_numa_migrate(struct task_struct *p, int last_cpupid,
+				       int src_nid, int dst_nid)
+{
+	return true;
+}
 #endif
 
 static inline struct pid *task_pid(struct task_struct *task)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 3551009..8e0a53a 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -948,6 +948,43 @@ static inline unsigned long group_weight(struct task_struct *p, int nid)
 	return 1000 * group_faults(p, nid) / p->numa_group->total_faults;
 }
 
+bool should_numa_migrate(struct task_struct *p, int last_cpupid,
+			 int src_nid, int dst_nid)
+{
+	struct numa_group *ng = p->numa_group;
+
+	/* Always allow migrate on private faults */
+	if (cpupid_match_pid(p, last_cpupid))
+		return true;
+
+	/* A shared fault, but p->numa_group has not been set up yet. */
+	if (!ng)
+		return true;
+
+	/*
+	 * Do not migrate if the destination is not a node that
+	 * is actively used by this numa group.
+	 */
+	if (!node_isset(dst_nid, ng->active_nodes))
+		return false;
+
+	/*
+	 * Source is a node that is not actively used by this
+	 * numa group, while the destination is. Migrate.
+	 */
+	if (!node_isset(src_nid, ng->active_nodes))
+		return true;
+
+	/*
+	 * Both source and destination are nodes in active
+	 * use by this numa group. Maximize memory bandwidth
+	 * by migrating from more heavily used groups, to less
+	 * heavily used ones, spreading the load around.
+	 * Use a 1/4 hysteresis to avoid spurious page movement.
+	 */
+	return group_faults(p, dst_nid) < (group_faults(p, src_nid) * 3 / 4);
+}
+
 static unsigned long weighted_cpuload(const int cpu);
 static unsigned long source_load(int cpu, int type);
 static unsigned long target_load(int cpu, int type);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 052abac..050962b 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2405,6 +2405,9 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		if (!cpupid_pid_unset(last_cpupid) && cpupid_to_nid(last_cpupid) != thisnid) {
 			goto out;
 		}
+
+		if (!should_numa_migrate(current, last_cpupid, curnid, polnid))
+			goto out;
 	}
 
 	if (curnid != polnid)
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
