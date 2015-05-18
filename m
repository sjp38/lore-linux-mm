Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 17ECA6B0071
	for <linux-mm@kvack.org>; Mon, 18 May 2015 15:50:07 -0400 (EDT)
Received: by qget53 with SMTP id t53so2605406qge.3
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:06 -0700 (PDT)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com. [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id h22si6558590qkh.125.2015.05.18.12.50.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 12:50:06 -0700 (PDT)
Received: by qgew3 with SMTP id w3so47391818qge.2
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:05 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 4/7] cgroup, memcg, cpuset: implement cgroup_taskset_for_each_leader()
Date: Mon, 18 May 2015 15:49:52 -0400
Message-Id: <1431978595-12176-5-git-send-email-tj@kernel.org>
In-Reply-To: <1431978595-12176-1-git-send-email-tj@kernel.org>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>

It wasn't explicitly documented but, when a process is being migrated,
cpuset and memcg depend on cgroup_taskset_first() returning the
threadgroup leader; however, this approach is somewhat ghetto and
would no longer work for the planned multi-process migration.

This patch introduces explicit cgroup_taskset_for_each_leader() which
iterates over only the threadgroup leaders and replaces
cgroup_taskset_first() usages for accessing the leader with it.

This prepares both memcg and cpuset for multi-process migration.  This
patch also updates the documentation for cgroup_taskset_for_each() to
clarify the iteration rules and removes comments mentioning task
ordering in tasksets.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>
---
 include/linux/cgroup.h | 22 ++++++++++++++++++++++
 kernel/cgroup.c        | 11 -----------
 kernel/cpuset.c        |  9 ++++-----
 mm/memcontrol.c        | 16 +++++++++++++---
 4 files changed, 39 insertions(+), 19 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 82319fb..788fab38 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -197,11 +197,33 @@ void css_task_iter_end(struct css_task_iter *it);
  * cgroup_taskset_for_each - iterate cgroup_taskset
  * @task: the loop cursor
  * @tset: taskset to iterate
+ *
+ * @tset may contain multiple tasks and they may belong to multiple
+ * processes.  When there are multiple tasks in @tset, if a task of a
+ * process is in @tset, all tasks of the process are in @tset.  Also, all
+ * are guaranteed to share the same source and destination csses.
+ *
+ * Iteration is not in any specific order.
  */
 #define cgroup_taskset_for_each(task, tset)				\
 	for ((task) = cgroup_taskset_first((tset)); (task);		\
 	     (task) = cgroup_taskset_next((tset)))
 
+/**
+ * cgroup_taskset_for_each_leader - iterate group leaders in a cgroup_taskset
+ * @leader: the loop cursor
+ * @tset: takset to iterate
+ *
+ * Iterate threadgroup leaders of @tset.  For single-task migrations, @tset
+ * may not contain any.
+ */
+#define cgroup_taskset_for_each_leader(leader, tset)			\
+	for ((leader) = cgroup_taskset_first((tset)); (leader);		\
+	     (leader) = cgroup_taskset_next((tset)))			\
+		if ((leader) != (leader)->group_leader)			\
+			;						\
+		else
+
 /*
  * Inline functions.
  */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index afe9a7e..da45ce9 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2064,13 +2064,6 @@ static void cgroup_task_migrate(struct cgroup *old_cgrp,
 
 	get_css_set(new_cset);
 	rcu_assign_pointer(tsk->cgroups, new_cset);
-
-	/*
-	 * Use move_tail so that cgroup_taskset_first() still returns the
-	 * leader after migration.  This works because cgroup_migrate()
-	 * ensures that the dst_cset of the leader is the first on the
-	 * tset's dst_csets list.
-	 */
 	list_move_tail(&tsk->cg_list, &new_cset->mg_tasks);
 
 	/*
@@ -2266,10 +2259,6 @@ static int cgroup_migrate(struct cgroup *cgrp, struct task_struct *leader,
 		if (!cset->mg_src_cgrp)
 			goto next;
 
-		/*
-		 * cgroup_taskset_first() must always return the leader.
-		 * Take care to avoid disturbing the ordering.
-		 */
 		list_move_tail(&task->cg_list, &cset->mg_tasks);
 		if (list_empty(&cset->mg_node))
 			list_add_tail(&cset->mg_node, &tset.src_csets);
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 43db5b7..54a2b99 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1485,7 +1485,7 @@ static void cpuset_attach(struct cgroup_subsys_state *css,
 	/* static buf protected by cpuset_mutex */
 	static nodemask_t cpuset_attach_nodemask_to;
 	struct task_struct *task;
-	struct task_struct *leader = cgroup_taskset_first(tset);
+	struct task_struct *leader;
 	struct cpuset *cs = css_cs(css);
 	struct cpuset *oldcs = cpuset_attach_old_cs;
 
@@ -1511,12 +1511,11 @@ static void cpuset_attach(struct cgroup_subsys_state *css,
 	}
 
 	/*
-	 * Change mm, possibly for multiple threads in a threadgroup. This
-	 * is expensive and may sleep and should be moved outside migration
-	 * path proper.
+	 * Change mm for all threadgroup leaders. This is expensive and may
+	 * sleep and should be moved outside migration path proper.
 	 */
 	cpuset_attach_nodemask_to = cs->effective_mems;
-	if (thread_group_leader(leader)) {
+	cgroup_taskset_for_each_leader(leader, tset) {
 		struct mm_struct *mm = get_task_mm(leader);
 
 		if (mm) {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 74fcea3..526ed58 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4999,7 +4999,7 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup *from;
-	struct task_struct *p;
+	struct task_struct *leader, *p;
 	struct mm_struct *mm;
 	unsigned long move_flags;
 	int ret = 0;
@@ -5013,8 +5013,18 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 	if (!move_flags)
 		return 0;
 
-	p = cgroup_taskset_first(tset);
-	if (!thread_group_leader(p))
+	/*
+	 * Multi-process migrations only happen on the default hierarchy
+	 * where charge immigration is not used.  Perform charge
+	 * immigration if @tset contains a leader and whine if there are
+	 * multiple.
+	 */
+	p = NULL;
+	cgroup_taskset_for_each_leader(leader, tset) {
+		WARN_ON_ONCE(p);
+		p = leader;
+	}
+	if (!p)
 		return 0;
 
 	from = mem_cgroup_from_task(p);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
