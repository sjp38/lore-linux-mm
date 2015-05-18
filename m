Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id EE6556B006C
	for <linux-mm@kvack.org>; Mon, 18 May 2015 15:50:01 -0400 (EDT)
Received: by qkgw4 with SMTP id w4so76328502qkg.3
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:01 -0700 (PDT)
Received: from mail-qk0-x22c.google.com (mail-qk0-x22c.google.com. [2607:f8b0:400d:c09::22c])
        by mx.google.com with ESMTPS id 65si1018458qks.95.2015.05.18.12.50.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 12:50:01 -0700 (PDT)
Received: by qkgv12 with SMTP id v12so42070748qkg.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:00 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/7] cpuset: migrate memory only for threadgroup leaders
Date: Mon, 18 May 2015 15:49:49 -0400
Message-Id: <1431978595-12176-2-git-send-email-tj@kernel.org>
In-Reply-To: <1431978595-12176-1-git-send-email-tj@kernel.org>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>

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
Cc: Li Zefan <lizefan@huawei.com>
---
 kernel/cpuset.c | 40 ++++++++++++++++++++++------------------
 1 file changed, 22 insertions(+), 18 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index ee14e3a..43db5b7 100644
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
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
