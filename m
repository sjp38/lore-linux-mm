Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id DAA246B0258
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 15:00:35 -0400 (EDT)
Received: by ykei199 with SMTP id i199so100707859yke.0
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 12:00:35 -0700 (PDT)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id b75si772199ywe.120.2015.09.11.12.00.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 12:00:30 -0700 (PDT)
Received: by ykdg206 with SMTP id g206so100520269ykd.1
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 12:00:30 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 4/5] cgroup: separate out taskset operations from cgroup_migrate()
Date: Fri, 11 Sep 2015 15:00:21 -0400
Message-Id: <1441998022-12953-5-git-send-email-tj@kernel.org>
In-Reply-To: <1441998022-12953-1-git-send-email-tj@kernel.org>
References: <1441998022-12953-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

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
Acked-by: Zefan Li <lizefan@huawei.com>
---
 kernel/cgroup.c | 211 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 125 insertions(+), 86 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 1f0c189..fa63b92 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2010,6 +2010,49 @@ struct cgroup_taskset {
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
@@ -2094,6 +2137,84 @@ static void cgroup_task_migrate(struct cgroup *old_cgrp,
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
@@ -2247,15 +2368,8 @@ static int cgroup_migrate_prepare_dst(struct cgroup *dst_cgrp,
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
@@ -2266,89 +2380,14 @@ static int cgroup_migrate(struct task_struct *leader, bool threadgroup,
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
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
