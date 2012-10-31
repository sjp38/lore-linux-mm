Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 174C86B006C
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 08:29:42 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 1/2] generalize post_clone into post_create
Date: Wed, 31 Oct 2012 16:29:13 +0400
Message-Id: <1351686554-22592-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1351686554-22592-1-git-send-email-glommer@parallels.com>
References: <1351686554-22592-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Li Zefan <lizefan@huawei.com>

When we call create_cgroup(), the css_ids are not yet initialized. The
only creation-time hook that is called with everything already setup is
post_clone().

However, post_clone is too fragile, in the sense that whether or not it
will be called depends on flag that can be switched on or off at
userspace will. So if any cgroup wants to do any mandatory
initialization, this won't hold.

The proposal of this patch is to generalize this into "post_create()",
which will always be called after create. The subsystem may then check
for the clone_children flag itself, and act accordingly. The cpuset
controller is currently the only in-tree user, and is converted.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Tejun Heo <tj@kernel.org>
CC: Michal Hocko <mhocko@suse.cz>
CC: Li Zefan <lizefan@huawei.com>
---
 Documentation/cgroups/cgroups.txt | 13 +++++++------
 include/linux/cgroup.h            |  7 ++++++-
 kernel/cgroup.c                   |  9 ++-------
 kernel/cpuset.c                   | 15 +++++++++------
 4 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 4a0b64c..5bc08f1 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -298,11 +298,12 @@ a cgroup hierarchy's release_agent path is empty.
 1.5 What does clone_children do ?
 ---------------------------------
 
-If the clone_children flag is enabled (1) in a cgroup, then all
-cgroups created beneath will call the post_clone callbacks for each
-subsystem of the newly created cgroup. Usually when this callback is
-implemented for a subsystem, it copies the values of the parent
-subsystem, this is the case for the cpuset.
+If the clone_children flag is enabled (1) in a cgroup, the group may perform
+specific initialization on its attributes based on the values in the parent,
+for each subsystem of the newly created cgroup that implements the
+post_create() callback. Usually when this callback is implemented for a
+subsystem, it copies the values of the parent subsystem, this is the case for
+the cpuset.
 
 1.6 How do I use cgroups ?
 --------------------------
@@ -634,7 +635,7 @@ void exit(struct task_struct *task)
 
 Called during task exit.
 
-void post_clone(struct cgroup *cgrp)
+void post_create(struct cgroup *cgrp)
 (cgroup_mutex held by caller)
 
 Called during cgroup_create() to do any parameter
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 68e8df7..7f422ba 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -218,6 +218,11 @@ struct cgroup {
 	spinlock_t event_list_lock;
 };
 
+static inline bool clone_children(const struct cgroup *cgrp)
+{
+	return test_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
+}
+
 /*
  * A css_set is a structure holding pointers to a set of
  * cgroup_subsys_state objects. This saves space in the task struct
@@ -472,7 +477,7 @@ struct cgroup_subsys {
 	void (*fork)(struct task_struct *task);
 	void (*exit)(struct cgroup *cgrp, struct cgroup *old_cgrp,
 		     struct task_struct *task);
-	void (*post_clone)(struct cgroup *cgrp);
+	void (*post_create)(struct cgroup *cgrp);
 	void (*bind)(struct cgroup *root);
 
 	int subsys_id;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b7d9606..40caab1 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -292,11 +292,6 @@ static int notify_on_release(const struct cgroup *cgrp)
 	return test_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
 }
 
-static int clone_children(const struct cgroup *cgrp)
-{
-	return test_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
-}
-
 /*
  * for_each_subsys() allows you to iterate on each subsystem attached to
  * an active hierarchy
@@ -3968,8 +3963,8 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 				goto err_destroy;
 		}
 		/* At error, ->destroy() callback has to free assigned ID. */
-		if (clone_children(parent) && ss->post_clone)
-			ss->post_clone(cgrp);
+		if (ss->post_create)
+			ss->post_create(cgrp);
 
 		if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
 		    parent->parent) {
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index f33c715..ca97af8 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1784,9 +1784,9 @@ static struct cftype files[] = {
 };
 
 /*
- * post_clone() is called during cgroup_create() when the
- * clone_children mount argument was specified.  The cgroup
- * can not yet have any tasks.
+ * post_create() is called during cgroup_create() if create succeeds. The
+ * cgroup can not yet have any tasks. In here, we will take action based
+ * on the value of the clone_children flag.
  *
  * Currently we refuse to set up the cgroup - thereby
  * refusing the task to be entered, and as a result refusing
@@ -1794,16 +1794,19 @@ static struct cftype files[] = {
  * sibling cpusets have exclusive cpus or mem.
  *
  * If this becomes a problem for some users who wish to
- * allow that scenario, then cpuset_post_clone() could be
+ * allow that scenario, then cpuset_post_create() could be
  * changed to grant parent->cpus_allowed-sibling_cpus_exclusive
  * (and likewise for mems) to the new cgroup. Called with cgroup_mutex
  * held.
  */
-static void cpuset_post_clone(struct cgroup *cgroup)
+static void cpuset_post_create(struct cgroup *cgroup)
 {
 	struct cgroup *parent, *child;
 	struct cpuset *cs, *parent_cs;
 
+	if (!clone_children(cgroup))
+		return;
+
 	parent = cgroup->parent;
 	list_for_each_entry(child, &parent->children, sibling) {
 		cs = cgroup_cs(child);
@@ -1882,7 +1885,7 @@ struct cgroup_subsys cpuset_subsys = {
 	.destroy = cpuset_destroy,
 	.can_attach = cpuset_can_attach,
 	.attach = cpuset_attach,
-	.post_clone = cpuset_post_clone,
+	.post_create = cpuset_post_create,
 	.subsys_id = cpuset_subsys_id,
 	.base_cftypes = files,
 	.early_init = 1,
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
