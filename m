Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 339DF6B0255
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 15:00:29 -0400 (EDT)
Received: by ykdt18 with SMTP id t18so80520957ykd.3
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 12:00:29 -0700 (PDT)
Received: from mail-yk0-x235.google.com (mail-yk0-x235.google.com. [2607:f8b0:4002:c07::235])
        by mx.google.com with ESMTPS id s6si765747ywf.167.2015.09.11.12.00.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 12:00:28 -0700 (PDT)
Received: by ykdu9 with SMTP id u9so101425273ykd.2
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 12:00:28 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/5] cpuset: migrate memory only for threadgroup leaders
Date: Fri, 11 Sep 2015 15:00:18 -0400
Message-Id: <1441998022-12953-2-git-send-email-tj@kernel.org>
In-Reply-To: <1441998022-12953-1-git-send-email-tj@kernel.org>
References: <1441998022-12953-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

If memory_migrate flag is set, cpuset migrates memory according to the
destnation css's nodemask.  The current implementation migrates memory
whenever any thread of a process is migrated making the behavior
somewhat arbitrary.  Let's tie memory operations to the threadgroup
leader so that memory is migrated only when the leader is migrated.

While this is a behavior change, given the inherent fuziness, this
change is not too likely to be noticed and allows us to clearly define
who owns the memory (always the leader) and helps the planned atomic
multi-process migration.

Note that we're currently migrating memory in migration path proper
while holding all the locks.  In the long term, this should be moved
out to an async work item.

Signed-off-by: Tejun Heo <tj@kernel.org>
Acked-by: Zefan Li <lizefan@huawei.com>
---
 kernel/cpuset.c | 40 ++++++++++++++++++++++------------------
 1 file changed, 22 insertions(+), 18 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index f0acff0..09393f6 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1484,7 +1484,6 @@ static void cpuset_attach(struct cgroup_subsys_state *css,
 {
 	/* static buf protected by cpuset_mutex */
 	static nodemask_t cpuset_attach_nodemask_to;
-	struct mm_struct *mm;
 	struct task_struct *task;
 	struct task_struct *leader = cgroup_taskset_first(tset);
 	struct cpuset *cs = css_cs(css);
@@ -1512,26 +1511,31 @@ static void cpuset_attach(struct cgroup_subsys_state *css,
 	}
 
 	/*
-	 * Change mm, possibly for multiple threads in a threadgroup. This is
-	 * expensive and may sleep.
+	 * Change mm, possibly for multiple threads in a threadgroup. This
+	 * is expensive and may sleep and should be moved outside migration
+	 * path proper.
 	 */
 	cpuset_attach_nodemask_to = cs->effective_mems;
-	mm = get_task_mm(leader);
-	if (mm) {
-		mpol_rebind_mm(mm, &cpuset_attach_nodemask_to);
-
-		/*
-		 * old_mems_allowed is the same with mems_allowed here, except
-		 * if this task is being moved automatically due to hotplug.
-		 * In that case @mems_allowed has been updated and is empty,
-		 * so @old_mems_allowed is the right nodesets that we migrate
-		 * mm from.
-		 */
-		if (is_memory_migrate(cs)) {
-			cpuset_migrate_mm(mm, &oldcs->old_mems_allowed,
-					  &cpuset_attach_nodemask_to);
+	if (thread_group_leader(leader)) {
+		struct mm_struct *mm = get_task_mm(leader);
+
+		if (mm) {
+			mpol_rebind_mm(mm, &cpuset_attach_nodemask_to);
+
+			/*
+			 * old_mems_allowed is the same with mems_allowed
+			 * here, except if this task is being moved
+			 * automatically due to hotplug.  In that case
+			 * @mems_allowed has been updated and is empty, so
+			 * @old_mems_allowed is the right nodesets that we
+			 * migrate mm from.
+			 */
+			if (is_memory_migrate(cs)) {
+				cpuset_migrate_mm(mm, &oldcs->old_mems_allowed,
+						  &cpuset_attach_nodemask_to);
+			}
+			mmput(mm);
 		}
-		mmput(mm);
 	}
 
 	cs->old_mems_allowed = cpuset_attach_nodemask_to;
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
