Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id D3A036B00A7
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 17:18:18 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id f11so9547509qae.20
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 14:18:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id w7si12152914qeg.0.2013.11.26.14.18.16
        for <linux-mm@kvack.org>;
        Tue, 26 Nov 2013 14:18:17 -0800 (PST)
From: riel@redhat.com
Subject: [RFC PATCH 4/4] use active_nodes nodemask to decide on numa migrations
Date: Tue, 26 Nov 2013 17:03:28 -0500
Message-Id: <1385503408-30041-5-git-send-email-riel@redhat.com>
In-Reply-To: <1385503408-30041-1-git-send-email-riel@redhat.com>
References: <1385503408-30041-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mgorman@suse.de, chegu_vinod@hp.com, peterz@infradead.org

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

This should result in most pages of a workload ending up on the
actively used nodes, with minimal ping-ponging of pages between
those nodes.

Unfortunately, it appears that something (scheduler idle balancer?)
is moving tasks around enough that nodes get dropped and added to
the set of active nodes semi-randomly...

Not-yet-signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/sched.h |  7 +++++++
 kernel/sched/fair.c   | 38 ++++++++++++++++++++++++++++++++++++++
 mm/mempolicy.c        |  3 +++
 3 files changed, 48 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index e4b00d8..ee17c28 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1475,6 +1475,8 @@ extern void task_numa_fault(int last_node, int node, int pages, int flags);
 extern pid_t task_numa_group_id(struct task_struct *p);
 extern void set_numabalancing_state(bool enabled);
 extern void task_numa_free(struct task_struct *p);
+extern bool should_numa_migrate(struct task_struct *p, int last_cpupid,
+				int src_nid, int dst_nid);
 #else
 static inline void task_numa_fault(int last_node, int node, int pages,
 				   int flags)
@@ -1490,6 +1492,11 @@ static inline void set_numabalancing_state(bool enabled)
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
index 91b8f11..8906aa4 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -931,6 +931,44 @@ static inline unsigned long group_weight(struct task_struct *p, int nid)
 	return 1000 * group_faults(p, nid) / p->numa_group->total_faults;
 }
 
+bool should_numa_migrate(struct task_struct *p, int last_cpupid,
+			 int src_nid, int dst_nid)
+{
+	struct numa_group *ng = p->numa_group;
+	unsigned long src_faults, dst_faults;
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
+	return group_faults(p, dst_nid) < (group_faults(p, src_nid * 3 / 4));
+}
+
 static unsigned long weighted_cpuload(const int cpu);
 static unsigned long source_load(int cpu, int type);
 static unsigned long target_load(int cpu, int type);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0522aa2..e314338 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2351,6 +2351,9 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		if (!cpupid_pid_unset(last_cpupid) && cpupid_to_nid(last_cpupid) != thisnid) {
 			goto out;
 		}
+
+		if (!should_numa_migrate(current, last_cpupid, curnid, polnid))
+			goto out;
 	}
 
 	if (curnid != polnid)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
