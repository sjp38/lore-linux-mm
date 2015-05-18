Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id DE91F6B0072
	for <linux-mm@kvack.org>; Mon, 18 May 2015 15:50:08 -0400 (EDT)
Received: by qget53 with SMTP id t53so2605871qge.3
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:08 -0700 (PDT)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com. [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id t92si11339324qga.36.2015.05.18.12.50.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 12:50:08 -0700 (PDT)
Received: by qgfa7 with SMTP id a7so40550695qgf.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:07 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 5/7] reorder cgroup_migrate()'s parameters
Date: Mon, 18 May 2015 15:49:53 -0400
Message-Id: <1431978595-12176-6-git-send-email-tj@kernel.org>
In-Reply-To: <1431978595-12176-1-git-send-email-tj@kernel.org>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>

cgroup_migrate() has the destination cgroup as the first parameter
while cgroup_task_migrate() has the destination cset as the last.
Another migration function is scheduled to be added which can make the
discrepancy further stand out.  Let's reorder cgroup_migrate()'s
parameters so that the destination cgroup is the last.

This doesn't cause any functional difference.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 kernel/cgroup.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index da45ce9..b36707b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2209,9 +2209,9 @@ err:
 
 /**
  * cgroup_migrate - migrate a process or task to a cgroup
- * @cgrp: the destination cgroup
  * @leader: the leader of the process or the task to migrate
  * @threadgroup: whether @leader points to the whole process or a single task
+ * @cgrp: the destination cgroup
  *
  * Migrate a process or task denoted by @leader to @cgrp.  If migrating a
  * process, the caller must be holding cgroup_threadgroup_rwsem.  The
@@ -2225,8 +2225,8 @@ err:
  * decided for all targets by invoking group_migrate_prepare_dst() before
  * actually starting migrating.
  */
-static int cgroup_migrate(struct cgroup *cgrp, struct task_struct *leader,
-			  bool threadgroup)
+static int cgroup_migrate(struct task_struct *leader, bool threadgroup,
+			  struct cgroup *cgrp)
 {
 	struct cgroup_taskset tset = {
 		.src_csets	= LIST_HEAD_INIT(tset.src_csets),
@@ -2363,7 +2363,7 @@ static int cgroup_attach_task(struct cgroup *dst_cgrp,
 	/* prepare dst csets and commit */
 	ret = cgroup_migrate_prepare_dst(dst_cgrp, &preloaded_csets);
 	if (!ret)
-		ret = cgroup_migrate(dst_cgrp, leader, threadgroup);
+		ret = cgroup_migrate(leader, threadgroup, dst_cgrp);
 
 	cgroup_migrate_finish(&preloaded_csets);
 	return ret;
@@ -2640,7 +2640,7 @@ static int cgroup_update_dfl_csses(struct cgroup *cgrp)
 				goto out_finish;
 			last_task = task;
 
-			ret = cgroup_migrate(src_cset->dfl_cgrp, task, true);
+			ret = cgroup_migrate(task, true, src_cset->dfl_cgrp);
 
 			put_task_struct(task);
 
@@ -3711,7 +3711,7 @@ int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from)
 		css_task_iter_end(&it);
 
 		if (task) {
-			ret = cgroup_migrate(to, task, false);
+			ret = cgroup_migrate(task, false, to);
 			put_task_struct(task);
 		}
 	} while (task && !ret);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
