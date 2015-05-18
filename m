Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id A370A6B0073
	for <linux-mm@kvack.org>; Mon, 18 May 2015 15:50:10 -0400 (EDT)
Received: by qgde91 with SMTP id e91so27955662qgd.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:10 -0700 (PDT)
Received: from mail-qc0-x22c.google.com (mail-qc0-x22c.google.com. [2607:f8b0:400d:c01::22c])
        by mx.google.com with ESMTPS id m17si11334138qgd.53.2015.05.18.12.50.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 12:50:09 -0700 (PDT)
Received: by qctt3 with SMTP id t3so13600586qct.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:09 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 6/7] cgroup: separate out taskset operations from cgroup_migrate()
Date: Mon, 18 May 2015 15:49:54 -0400
Message-Id: <1431978595-12176-7-git-send-email-tj@kernel.org>
In-Reply-To: <1431978595-12176-1-git-send-email-tj@kernel.org>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>

Currently, cgroup_migreate() implements large part of the migration
logic inline including building the target taskset and actually
migrating them.  This patch separates out the following taskset
operations.

 CGROUP_TASKSET_INIT()		: taskset initializer
 cgroup_taskset_add()		: add a task to a taskset
 cgroup_taskset_migrate()	: migrate a taskset to the destination cgroup

This will be used to implement atomic multi-process migration in
cgroup_update_dfl_csses().  This is pure reorganization which doesn't
introduce any functional changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 kernel/cgroup.c | 211 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 125 insertions(+), 86 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b36707b..1d86d17 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1991,6 +1991,49 @@ struct cgroup_taskset {
 	struct task_struct	*cur_task;
 };
 
+#define CGROUP_TASKSET_INIT(tset)	(struct cgroup_taskset){	\
+	.src_csets		= LIST_HEAD_INIT(tset.src_csets),	\
+	.dst_csets		= LIST_HEAD_INIT(tset.dst_csets),	\
+	.csets			= &tset.src_csets,			\
+}
+
+/**
+ * cgroup_taskset_add - try to add a migration target task to a taskset
+ * @task: target task
+ * @tset: target taskset
+ *
+ * Add @task, which is a migration target, to @tset.  This function becomes
+ * noop if @task doesn't need to be migrated.  @task's css_set should have
+ * been added as a migration source and @task->cg_list will be moved from
+ * the css_set's tasks list to mg_tasks one.
+ */
+static void cgroup_taskset_add(struct task_struct *task,
+			       struct cgroup_taskset *tset)
+{
+	struct css_set *cset;
+
+	lockdep_assert_held(&css_set_rwsem);
+
+	/* @task either already exited or can't exit until the end */
+	if (task->flags & PF_EXITING)
+		return;
+
+	/* leave @task alone if post_fork() hasn't linked it yet */
+	if (list_empty(&task->cg_list))
+		return;
+
+	cset = task_css_set(task);
+	if (!cset->mg_src_cgrp)
+		return;
+
+	list_move_tail(&task->cg_list, &cset->mg_tasks);
+	if (list_empty(&cset->mg_node))
+		list_add_tail(&cset->mg_node, &tset->src_csets);
+	if (list_empty(&cset->mg_dst_cset->mg_node))
+		list_move_tail(&cset->mg_dst_cset->mg_node,
+			       &tset->dst_csets);
+}
+
 /**
  * cgroup_taskset_first - reset taskset and return the first task
  * @tset: taskset of interest
@@ -2075,6 +2118,84 @@ static void cgroup_task_migrate(struct cgroup *old_cgrp,
 }
 
 /**
+ * cgroup_taskset_migrate - migrate a taskset to a cgroup
+ * @tset: taget taskset
+ * @dst_cgrp: destination cgroup
+ *
+ * Migrate tasks in @tset to @dst_cgrp.  This function fails iff one of the
+ * ->can_attach callbacks fails and guarantees that either all or none of
+ * the tasks in @tset are migrated.  @tset is consumed regardless of
+ * success.
+ */
+static int cgroup_taskset_migrate(struct cgroup_taskset *tset,
+				  struct cgroup *dst_cgrp)
+{
+	struct cgroup_subsys_state *css, *failed_css = NULL;
+	struct task_struct *task, *tmp_task;
+	struct css_set *cset, *tmp_cset;
+	int i, ret;
+
+	/* methods shouldn't be called if no task is actually migrating */
+	if (list_empty(&tset->src_csets))
+		return 0;
+
+	/* check that we can legitimately attach to the cgroup */
+	for_each_e_css(css, i, dst_cgrp) {
+		if (css->ss->can_attach) {
+			ret = css->ss->can_attach(css, tset);
+			if (ret) {
+				failed_css = css;
+				goto out_cancel_attach;
+			}
+		}
+	}
+
+	/*
+	 * Now that we're guaranteed success, proceed to move all tasks to
+	 * the new cgroup.  There are no failure cases after here, so this
+	 * is the commit point.
+	 */
+	down_write(&css_set_rwsem);
+	list_for_each_entry(cset, &tset->src_csets, mg_node) {
+		list_for_each_entry_safe(task, tmp_task, &cset->mg_tasks, cg_list)
+			cgroup_task_migrate(cset->mg_src_cgrp, task,
+					    cset->mg_dst_cset);
+	}
+	up_write(&css_set_rwsem);
+
+	/*
+	 * Migration is committed, all target tasks are now on dst_csets.
+	 * Nothing is sensitive to fork() after this point.  Notify
+	 * controllers that migration is complete.
+	 */
+	tset->csets = &tset->dst_csets;
+
+	for_each_e_css(css, i, dst_cgrp)
+		if (css->ss->attach)
+			css->ss->attach(css, tset);
+
+	ret = 0;
+	goto out_release_tset;
+
+out_cancel_attach:
+	for_each_e_css(css, i, dst_cgrp) {
+		if (css == failed_css)
+			break;
+		if (css->ss->cancel_attach)
+			css->ss->cancel_attach(css, tset);
+	}
+out_release_tset:
+	down_write(&css_set_rwsem);
+	list_splice_init(&tset->dst_csets, &tset->src_csets);
+	list_for_each_entry_safe(cset, tmp_cset, &tset->src_csets, mg_node) {
+		list_splice_tail_init(&cset->mg_tasks, &cset->tasks);
+		list_del_init(&cset->mg_node);
+	}
+	up_write(&css_set_rwsem);
+	return ret;
+}
+
+/**
  * cgroup_migrate_finish - cleanup after attach
  * @preloaded_csets: list of preloaded css_sets
  *
@@ -2228,15 +2349,8 @@ err:
 static int cgroup_migrate(struct task_struct *leader, bool threadgroup,
 			  struct cgroup *cgrp)
 {
-	struct cgroup_taskset tset = {
-		.src_csets	= LIST_HEAD_INIT(tset.src_csets),
-		.dst_csets	= LIST_HEAD_INIT(tset.dst_csets),
-		.csets		= &tset.src_csets,
-	};
-	struct cgroup_subsys_state *css, *failed_css = NULL;
-	struct css_set *cset, *tmp_cset;
-	struct task_struct *task, *tmp_task;
-	int i, ret;
+	struct cgroup_taskset tset = CGROUP_TASKSET_INIT(tset);
+	struct task_struct *task;
 
 	/*
 	 * Prevent freeing of tasks while we take a snapshot. Tasks that are
@@ -2247,89 +2361,14 @@ static int cgroup_migrate(struct task_struct *leader, bool threadgroup,
 	rcu_read_lock();
 	task = leader;
 	do {
-		/* @task either already exited or can't exit until the end */
-		if (task->flags & PF_EXITING)
-			goto next;
-
-		/* leave @task alone if post_fork() hasn't linked it yet */
-		if (list_empty(&task->cg_list))
-			goto next;
-
-		cset = task_css_set(task);
-		if (!cset->mg_src_cgrp)
-			goto next;
-
-		list_move_tail(&task->cg_list, &cset->mg_tasks);
-		if (list_empty(&cset->mg_node))
-			list_add_tail(&cset->mg_node, &tset.src_csets);
-		if (list_empty(&cset->mg_dst_cset->mg_node))
-			list_move_tail(&cset->mg_dst_cset->mg_node,
-				       &tset.dst_csets);
-	next:
+		cgroup_taskset_add(task, &tset);
 		if (!threadgroup)
 			break;
 	} while_each_thread(leader, task);
 	rcu_read_unlock();
 	up_write(&css_set_rwsem);
 
-	/* methods shouldn't be called if no task is actually migrating */
-	if (list_empty(&tset.src_csets))
-		return 0;
-
-	/* check that we can legitimately attach to the cgroup */
-	for_each_e_css(css, i, cgrp) {
-		if (css->ss->can_attach) {
-			ret = css->ss->can_attach(css, &tset);
-			if (ret) {
-				failed_css = css;
-				goto out_cancel_attach;
-			}
-		}
-	}
-
-	/*
-	 * Now that we're guaranteed success, proceed to move all tasks to
-	 * the new cgroup.  There are no failure cases after here, so this
-	 * is the commit point.
-	 */
-	down_write(&css_set_rwsem);
-	list_for_each_entry(cset, &tset.src_csets, mg_node) {
-		list_for_each_entry_safe(task, tmp_task, &cset->mg_tasks, cg_list)
-			cgroup_task_migrate(cset->mg_src_cgrp, task,
-					    cset->mg_dst_cset);
-	}
-	up_write(&css_set_rwsem);
-
-	/*
-	 * Migration is committed, all target tasks are now on dst_csets.
-	 * Nothing is sensitive to fork() after this point.  Notify
-	 * controllers that migration is complete.
-	 */
-	tset.csets = &tset.dst_csets;
-
-	for_each_e_css(css, i, cgrp)
-		if (css->ss->attach)
-			css->ss->attach(css, &tset);
-
-	ret = 0;
-	goto out_release_tset;
-
-out_cancel_attach:
-	for_each_e_css(css, i, cgrp) {
-		if (css == failed_css)
-			break;
-		if (css->ss->cancel_attach)
-			css->ss->cancel_attach(css, &tset);
-	}
-out_release_tset:
-	down_write(&css_set_rwsem);
-	list_splice_init(&tset.dst_csets, &tset.src_csets);
-	list_for_each_entry_safe(cset, tmp_cset, &tset.src_csets, mg_node) {
-		list_splice_tail_init(&cset->mg_tasks, &cset->tasks);
-		list_del_init(&cset->mg_node);
-	}
-	up_write(&css_set_rwsem);
-	return ret;
+	return cgroup_taskset_migrate(&tset, cgrp);
 }
 
 /**
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
