Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 266616B0074
	for <linux-mm@kvack.org>; Mon, 18 May 2015 15:50:12 -0400 (EDT)
Received: by qkgw4 with SMTP id w4so76331908qkg.3
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:11 -0700 (PDT)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id g36si11274922qgd.123.2015.05.18.12.50.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 12:50:11 -0700 (PDT)
Received: by qgde91 with SMTP id e91so27955839qgd.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:11 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 7/7] cgroup: make cgroup_update_dfl_csses() migrate all target processes atomically
Date: Mon, 18 May 2015 15:49:55 -0400
Message-Id: <1431978595-12176-8-git-send-email-tj@kernel.org>
In-Reply-To: <1431978595-12176-1-git-send-email-tj@kernel.org>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>

cgroup_update_dfl_csses() is responsible for migrating processes when
controllers are enabled or disabled on the default hierarchy.  As the
css association changes for all the processes in the affected cgroups,
this involves migrating multiple processes.

Up until now, it was implemented by migrating process-by-process until
the source css_sets are empty; however, this means that if a process
fails to migrate after some succeed before it, the recovery is very
tricky.  This was considered okay as subsystems weren't allowed to
reject process migration on the default hierarchy; unfortunately,
enforcing this policy turned out to be problematic for certain types
of resources - realtime slices for now.

As such, the default hierarchy is gonna allow restricted failures
during migration and to support that this patch makes
cgroup_update_dfl_csses() migrate all target processes atomically
rather than one-by-one.  The preceding patches made subsystems ready
for multi-process migration and factored out taskset operations making
this almost trivial.  All tasks of the target processes are put in the
same taskset and the migration operations are performed once which
either fails or succeeds for all.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 kernel/cgroup.c | 44 ++++++++------------------------------------
 1 file changed, 8 insertions(+), 36 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 1d86d17..978d741 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2616,6 +2616,7 @@ static int cgroup_subtree_control_show(struct seq_file *seq, void *v)
 static int cgroup_update_dfl_csses(struct cgroup *cgrp)
 {
 	LIST_HEAD(preloaded_csets);
+	struct cgroup_taskset tset = CGROUP_TASKSET_INIT(tset);
 	struct cgroup_subsys_state *css;
 	struct css_set *src_cset;
 	int ret;
@@ -2644,50 +2645,21 @@ static int cgroup_update_dfl_csses(struct cgroup *cgrp)
 	if (ret)
 		goto out_finish;
 
+	down_write(&css_set_rwsem);
 	list_for_each_entry(src_cset, &preloaded_csets, mg_preload_node) {
-		struct task_struct *last_task = NULL, *task;
+		struct task_struct *task, *ntask;
 
 		/* src_csets precede dst_csets, break on the first dst_cset */
 		if (!src_cset->mg_src_cgrp)
 			break;
 
-		/*
-		 * All tasks in src_cset need to be migrated to the
-		 * matching dst_cset.  Empty it process by process.  We
-		 * walk tasks but migrate processes.  The leader might even
-		 * belong to a different cset but such src_cset would also
-		 * be among the target src_csets because the default
-		 * hierarchy enforces per-process membership.
-		 */
-		while (true) {
-			down_read(&css_set_rwsem);
-			task = list_first_entry_or_null(&src_cset->tasks,
-						struct task_struct, cg_list);
-			if (task) {
-				task = task->group_leader;
-				WARN_ON_ONCE(!task_css_set(task)->mg_src_cgrp);
-				get_task_struct(task);
-			}
-			up_read(&css_set_rwsem);
-
-			if (!task)
-				break;
-
-			/* guard against possible infinite loop */
-			if (WARN(last_task == task,
-				 "cgroup: update_dfl_csses failed to make progress, aborting in inconsistent state\n"))
-				goto out_finish;
-			last_task = task;
-
-			ret = cgroup_migrate(task, true, src_cset->dfl_cgrp);
-
-			put_task_struct(task);
-
-			if (WARN(ret, "cgroup: failed to update controllers for the default hierarchy (%d), further operations may crash or hang\n", ret))
-				goto out_finish;
-		}
+		/* all tasks in src_csets need to be migrated */
+		list_for_each_entry_safe(task, ntask, &src_cset->tasks, cg_list)
+			cgroup_taskset_add(task, &tset);
 	}
+	up_write(&css_set_rwsem);
 
+	ret = cgroup_taskset_migrate(&tset, cgrp);
 out_finish:
 	cgroup_migrate_finish(&preloaded_csets);
 	percpu_up_write(&cgroup_threadgroup_rwsem);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
