Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 48A726B0044
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 08:29:41 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 2/2] allow post_create to fail
Date: Wed, 31 Oct 2012 16:29:14 +0400
Message-Id: <1351686554-22592-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1351686554-22592-1-git-send-email-glommer@parallels.com>
References: <1351686554-22592-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Li Zefan <lizefan@huawei.com>

Initialization in post_create can theoretically fail (although it won't
in cpuset). The comment in cgroup.c even seem to indicate that the
possibility of failure was the intention.

It is not terribly complicated, so let us just allow it to fail.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Tejun Heo <tj@kernel.org>
CC: Michal Hocko <mhocko@suse.cz>
CC: Li Zefan <lizefan@huawei.com>
---
 include/linux/cgroup.h | 2 +-
 kernel/cgroup.c        | 7 +++++--
 kernel/cpuset.c        | 8 ++++----
 3 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 7f422ba..34cb906 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -477,7 +477,7 @@ struct cgroup_subsys {
 	void (*fork)(struct task_struct *task);
 	void (*exit)(struct cgroup *cgrp, struct cgroup *old_cgrp,
 		     struct task_struct *task);
-	void (*post_create)(struct cgroup *cgrp);
+	int (*post_create)(struct cgroup *cgrp);
 	void (*bind)(struct cgroup *root);
 
 	int subsys_id;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 40caab1..20a1422 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3963,8 +3963,11 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 				goto err_destroy;
 		}
 		/* At error, ->destroy() callback has to free assigned ID. */
-		if (ss->post_create)
-			ss->post_create(cgrp);
+		if (ss->post_create) {
+			err = ss->post_create(cgrp);
+			if (err)
+				goto err_destroy;
+		}
 
 		if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
 		    parent->parent) {
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index ca97af8..e7623ae 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1799,19 +1799,19 @@ static struct cftype files[] = {
  * (and likewise for mems) to the new cgroup. Called with cgroup_mutex
  * held.
  */
-static void cpuset_post_create(struct cgroup *cgroup)
+static int cpuset_post_create(struct cgroup *cgroup)
 {
 	struct cgroup *parent, *child;
 	struct cpuset *cs, *parent_cs;
 
 	if (!clone_children(cgroup))
-		return;
+		return 0;
 
 	parent = cgroup->parent;
 	list_for_each_entry(child, &parent->children, sibling) {
 		cs = cgroup_cs(child);
 		if (is_mem_exclusive(cs) || is_cpu_exclusive(cs))
-			return;
+			return 0;
 	}
 	cs = cgroup_cs(cgroup);
 	parent_cs = cgroup_cs(parent);
@@ -1820,7 +1820,7 @@ static void cpuset_post_create(struct cgroup *cgroup)
 	cs->mems_allowed = parent_cs->mems_allowed;
 	cpumask_copy(cs->cpus_allowed, parent_cs->cpus_allowed);
 	mutex_unlock(&callback_mutex);
-	return;
+	return 0;
 }
 
 /*
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
