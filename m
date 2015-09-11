Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id B8D526B0257
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 15:00:33 -0400 (EDT)
Received: by ykdg206 with SMTP id g206so100521762ykd.1
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 12:00:33 -0700 (PDT)
Received: from mail-yk0-x22b.google.com (mail-yk0-x22b.google.com. [2607:f8b0:4002:c07::22b])
        by mx.google.com with ESMTPS id j185si780104ywg.46.2015.09.11.12.00.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 12:00:30 -0700 (PDT)
Received: by ykdt18 with SMTP id t18so80521356ykd.3
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 12:00:29 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/5] reorder cgroup_migrate()'s parameters
Date: Fri, 11 Sep 2015 15:00:20 -0400
Message-Id: <1441998022-12953-4-git-send-email-tj@kernel.org>
In-Reply-To: <1441998022-12953-1-git-send-email-tj@kernel.org>
References: <1441998022-12953-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

cgroup_migrate() has the destination cgroup as the first parameter
while cgroup_task_migrate() has the destination cset as the last.
Another migration function is scheduled to be added which can make the
discrepancy further stand out.  Let's reorder cgroup_migrate()'s
parameters so that the destination cgroup is the last.

This doesn't cause any functional difference.

Signed-off-by: Tejun Heo <tj@kernel.org>
Acked-by: Zefan Li <lizefan@huawei.com>
---
 kernel/cgroup.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0b732dd..1f0c189 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2228,9 +2228,9 @@ static int cgroup_migrate_prepare_dst(struct cgroup *dst_cgrp,
 
 /**
  * cgroup_migrate - migrate a process or task to a cgroup
- * @cgrp: the destination cgroup
  * @leader: the leader of the process or the task to migrate
  * @threadgroup: whether @leader points to the whole process or a single task
+ * @cgrp: the destination cgroup
  *
  * Migrate a process or task denoted by @leader to @cgrp.  If migrating a
  * process, the caller must be holding cgroup_threadgroup_rwsem.  The
@@ -2244,8 +2244,8 @@ static int cgroup_migrate_prepare_dst(struct cgroup *dst_cgrp,
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
@@ -2382,7 +2382,7 @@ static int cgroup_attach_task(struct cgroup *dst_cgrp,
 	/* prepare dst csets and commit */
 	ret = cgroup_migrate_prepare_dst(dst_cgrp, &preloaded_csets);
 	if (!ret)
-		ret = cgroup_migrate(dst_cgrp, leader, threadgroup);
+		ret = cgroup_migrate(leader, threadgroup, dst_cgrp);
 
 	cgroup_migrate_finish(&preloaded_csets);
 	return ret;
@@ -2689,7 +2689,7 @@ static int cgroup_update_dfl_csses(struct cgroup *cgrp)
 				goto out_finish;
 			last_task = task;
 
-			ret = cgroup_migrate(src_cset->dfl_cgrp, task, true);
+			ret = cgroup_migrate(task, true, src_cset->dfl_cgrp);
 
 			put_task_struct(task);
 
@@ -3760,7 +3760,7 @@ int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from)
 		css_task_iter_end(&it);
 
 		if (task) {
-			ret = cgroup_migrate(to, task, false);
+			ret = cgroup_migrate(task, false, to);
 			put_task_struct(task);
 		}
 	} while (task && !ret);
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
