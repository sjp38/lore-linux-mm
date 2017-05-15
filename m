Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B14876B0350
	for <linux-mm@kvack.org>; Mon, 15 May 2017 09:35:00 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j13so46595728qta.13
        for <linux-mm@kvack.org>; Mon, 15 May 2017 06:35:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a82si10567874qkb.1.2017.05.15.06.34.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 06:34:58 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH v2 12/17] cgroup: Remove cgroup v2 no internal process constraint
Date: Mon, 15 May 2017 09:34:11 -0400
Message-Id: <1494855256-12558-13-git-send-email-longman@redhat.com>
In-Reply-To: <1494855256-12558-1-git-send-email-longman@redhat.com>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de, longman@redhat.com

The rationale behind the cgroup v2 no internal process constraint is
to avoid resouorce competition between internal processes and child
cgroups. However, not all controllers have problem with internal
process competiton. Enforcing this rule may lead to unnatural process
hierarchy and unneeded levels for those controllers.

This patch removes the no internal process contraint by enabling those
controllers that don't like internal process competition to have a
separate set of control knobs just for internal processes in a cgroup.

A new control file "cgroup.resource_control" is added. Enabling a
controller with a "+" prefix will create a separate set of control
knobs for that controller in the special "cgroup.resource_domain"
sub-directory for all the internal processes. The existing control
knobs in the cgroup will then be used to manage resource distribution
between internal processes as a group and other child cgroups.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/cgroup-v2.txt     |  76 ++++++-----
 include/linux/cgroup-defs.h     |  15 +++
 kernel/cgroup/cgroup-internal.h |   1 -
 kernel/cgroup/cgroup-v1.c       |   3 -
 kernel/cgroup/cgroup.c          | 275 ++++++++++++++++++++++++++++------------
 kernel/cgroup/debug.c           |   7 +-
 6 files changed, 260 insertions(+), 117 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index 3ae7e9c..0f41282 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -23,7 +23,7 @@ CONTENTS
   2-4. Controlling Controllers
     2-4-1. Enabling and Disabling
     2-4-2. Top-down Constraint
-    2-4-3. No Internal Process Constraint
+    2-4-3. Managing Internal Process Competition
   2-5. Delegation
     2-5-1. Model of Delegation
     2-5-2. Delegation Containment
@@ -218,9 +218,7 @@ a subtree while still maintaining the common resource domain for them.
 Enabling thread mode on a subtree makes it threaded.  The root of a
 threaded subtree is called thread root and serves as the resource
 domain for the entire subtree.  In a threaded subtree, threads of a
-process can be put in different cgroups and are not subject to the no
-internal process constraint - threaded controllers can be enabled on
-non-leaf cgroups whether they have threads in them or not.
+process can be put in different cgroups.
 
 To enable the thread mode on a cgroup, the following conditions must
 be met.
@@ -263,11 +261,6 @@ it only accounts for and controls resource consumptions associated
 with the threads in the cgroup and its descendants.  All consumptions
 which aren't tied to a specific thread belong to the thread root.
 
-Because a threaded subtree is exempt from no internal process
-constraint, a threaded controller must be able to handle competition
-between threads in a non-leaf cgroup and its child cgroups.  Each
-threaded controller defines how such competitions are handled.
-
 A new child cgroup created under a thread root will not be threaded.
 Thread mode has to be explicitly enabled on each of the thread root's
 children.  Descendants of a threaded cgroup, however, will always be
@@ -364,35 +357,38 @@ the parent has the controller enabled and a controller can't be
 disabled if one or more children have it enabled.
 
 
-2-4-3. No Internal Process Constraint
+2-4-3. Managing Internal Process Competition
 
-Non-root cgroups can only distribute resources to their children when
-they don't have any processes of their own.  In other words, only
-cgroups which don't contain any processes can have controllers enabled
-in their "cgroup.subtree_control" files.
+There are resources managed by some controllers that don't work well
+if the internal processes in a non-leaf cgroup have to compete against
+the resource requirement of the other child cgroups. Other controllers
+work perfectly fine with internal process competition.
 
-This guarantees that, when a controller is looking at the part of the
-hierarchy which has it enabled, processes are always only on the
-leaves.  This rules out situations where child cgroups compete against
-internal processes of the parent.
+Internal processes are allowed in a non-leaf cgroup. Controllers
+that don't like internal process competition can use
+the "cgroup.resource_control" file to create a special
+"cgroup.resource_domain" child cgroup that hold the control knobs
+for all the internal processes in the cgroup.
 
-The root cgroup is exempt from this restriction.  Root contains
-processes and anonymous resource consumption which can't be associated
-with any other cgroups and requires special treatment from most
-controllers.  How resource consumption in the root cgroup is governed
-is up to each controller.
+  # echo "+memory -pids" > cgroup.resource_control
 
-The threaded cgroups and the thread roots are also exempt from this
-restriction.
+Here, the control files for the memory controller are activated in the
+"cgroup.resource_domain" directory while that of the pids controller
+are removed. All the internal processes in the cgroup will use the
+memory control files in the "cgroup.resource_domain" directory to
+manage their memory. The memory control files in the cgroup itself
+can then be used to manage resource distribution between internal
+processes as a group and other child cgroups.
 
-Note that the restriction doesn't get in the way if there is no
-enabled controller in the cgroup's "cgroup.subtree_control".  This is
-important as otherwise it wouldn't be possible to create children of a
-populated cgroup.  To control resource distribution of a cgroup, the
-cgroup must create children and transfer all its processes to the
-children before enabling controllers in its "cgroup.subtree_control"
-file.
+Only controllers that are enabled in the "cgroup.controllers" file
+can be enabled in the "cgroup.resource_control" file. Once enabled,
+the parent cgroup cannot take away the controller until it has been
+disabled in the "cgroup.resource_control" file.
 
+The directory name "cgroup.resource_domain" is reserved. It cannot
+be created or deleted directly and no child cgroups can be created
+underneath it. All the "cgroup." control files are missing and so
+the users cannot move process into it.
 
 2-5. Delegation
 
@@ -730,6 +726,22 @@ All cgroup core files are prefixed with "cgroup."
 	the last one is effective.  When multiple enable and disable
 	operations are specified, either all succeed or all fail.
 
+  cgroup.resource_control
+
+	A read-write space separated values file which exists on all
+	cgroups.  Starts out empty.
+
+	When read, it shows space separated list of the controllers
+	which are enabled to have separate control files in the
+	"cgroup.resource_domain" directory for internal processes.
+
+	Space separated list of controllers prefixed with '+' or '-'
+	can be written to enable or disable controllers.  A controller
+	name prefixed with '+' enables the controller and '-'
+	disables.  If a controller appears more than once on the list,
+	the last one is effective.  When multiple enable and disable
+	operations are specified, either all succeed or all fail.
+
   cgroup.events
 
 	A read-only flat-keyed file which exists on non-root cgroups.
diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index 104be73..67ab326 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -61,6 +61,9 @@ enum {
 	 * specified at mount time and thus is implemented here.
 	 */
 	CGRP_CPUSET_CLONE_CHILDREN,
+
+	/* Special child resource domain cgroup */
+	CGRP_RESOURCE_DOMAIN,
 };
 
 /* cgroup_root->flags */
@@ -293,11 +296,23 @@ struct cgroup {
 	u16 old_subtree_control;
 	u16 old_subtree_ss_mask;
 
+	/*
+	 * The bitmask of subsystems that have separate sets of control
+	 * knobs in a special child resource cgroup to control internal
+	 * processes within the current cgroup so that they won't compete
+	 * directly with other regular child cgroups. This is for the
+	 * default hierarchy only.
+	 */
+	u16 resource_control;
+
 	/* Private pointers for each registered subsystem */
 	struct cgroup_subsys_state __rcu *subsys[CGROUP_SUBSYS_COUNT];
 
 	struct cgroup_root *root;
 
+	/* Pointer to the special resource child cgroup */
+	struct cgroup *resource_domain;
+
 	/*
 	 * List of cgrp_cset_links pointing at css_sets with tasks in this
 	 * cgroup.  Protected by css_set_lock.
diff --git a/kernel/cgroup/cgroup-internal.h b/kernel/cgroup/cgroup-internal.h
index 15abaa0..fc877e0 100644
--- a/kernel/cgroup/cgroup-internal.h
+++ b/kernel/cgroup/cgroup-internal.h
@@ -180,7 +180,6 @@ struct dentry *cgroup_do_mount(struct file_system_type *fs_type, int flags,
 			       struct cgroup_root *root, unsigned long magic,
 			       struct cgroup_namespace *ns);
 
-bool cgroup_may_migrate_to(struct cgroup *dst_cgrp);
 void cgroup_migrate_finish(struct cgroup_mgctx *mgctx);
 void cgroup_migrate_add_src(struct css_set *src_cset, struct cgroup *dst_cgrp,
 			    struct cgroup_mgctx *mgctx);
diff --git a/kernel/cgroup/cgroup-v1.c b/kernel/cgroup/cgroup-v1.c
index 302b3b8..ef578b6 100644
--- a/kernel/cgroup/cgroup-v1.c
+++ b/kernel/cgroup/cgroup-v1.c
@@ -99,9 +99,6 @@ int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from)
 	if (cgroup_on_dfl(to))
 		return -EINVAL;
 
-	if (!cgroup_may_migrate_to(to))
-		return -EBUSY;
-
 	mutex_lock(&cgroup_mutex);
 
 	percpu_down_write(&cgroup_threadgroup_rwsem);
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 11cb091..c3be7e2 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -63,6 +63,12 @@
 					 MAX_CFTYPE_NAME + 2)
 
 /*
+ * Reserved cgroup name for the special resource domain child cgroup of
+ * the default hierarchy.
+ */
+#define CGROUP_RESOURCE_DOMAIN	"cgroup.resource_domain"
+
+/*
  * cgroup_mutex is the master lock.  Any modification to cgroup or its
  * hierarchy must be performed while holding it.
  *
@@ -337,6 +343,9 @@ static u16 cgroup_control(struct cgroup *cgrp)
 	if (parent) {
 		u16 ss_mask = parent->subtree_control;
 
+		if (test_bit(CGRP_RESOURCE_DOMAIN, &cgrp->flags))
+			return parent->resource_control;
+
 		if (cgroup_is_threaded(cgrp))
 			ss_mask &= cgrp_dfl_threaded_ss_mask;
 		return ss_mask;
@@ -356,6 +365,9 @@ static u16 cgroup_ss_mask(struct cgroup *cgrp)
 	if (parent) {
 		u16 ss_mask = parent->subtree_ss_mask;
 
+		if (test_bit(CGRP_RESOURCE_DOMAIN, &cgrp->flags))
+			return parent->resource_control;
+
 		if (cgroup_is_threaded(cgrp))
 			ss_mask &= cgrp_dfl_threaded_ss_mask;
 		return ss_mask;
@@ -413,6 +425,11 @@ static struct cgroup_subsys_state *cgroup_e_css(struct cgroup *cgrp,
 			return NULL;
 	}
 
+	if (cgrp->resource_control & (1 << ss->id)) {
+		WARN_ON(!cgrp->resource_domain);
+		if (cgrp->resource_domain)
+			return cgroup_css(cgrp->resource_domain, ss);
+	}
 	return cgroup_css(cgrp, ss);
 }
 
@@ -435,8 +452,10 @@ struct cgroup_subsys_state *cgroup_get_e_css(struct cgroup *cgrp,
 	rcu_read_lock();
 
 	do {
-		css = cgroup_css(cgrp, ss);
-
+		if (cgrp->resource_control & (1 << ss->id))
+			css = cgroup_css(cgrp->resource_domain, ss);
+		else
+			css = cgroup_css(cgrp, ss);
 		if (css && css_tryget_online(css))
 			goto out_unlock;
 		cgrp = cgroup_parent(cgrp);
@@ -2234,20 +2253,6 @@ static int cgroup_migrate_execute(struct cgroup_mgctx *mgctx)
 }
 
 /**
- * cgroup_may_migrate_to - verify whether a cgroup can be migration destination
- * @dst_cgrp: destination cgroup to test
- *
- * On the default hierarchy, except for the root, subtree_control must be
- * zero for migration destination cgroups with tasks so that child cgroups
- * don't compete against tasks.
- */
-bool cgroup_may_migrate_to(struct cgroup *dst_cgrp)
-{
-	return !cgroup_on_dfl(dst_cgrp) || !cgroup_parent(dst_cgrp) ||
-		!dst_cgrp->subtree_control;
-}
-
-/**
  * cgroup_migrate_finish - cleanup after attach
  * @mgctx: migration context
  *
@@ -2449,9 +2454,6 @@ int cgroup_attach_task(struct cgroup *dst_cgrp, struct task_struct *leader,
 	struct task_struct *task;
 	int ret;
 
-	if (!cgroup_may_migrate_to(dst_cgrp))
-		return -EBUSY;
-
 	/* look up all src csets */
 	spin_lock_irq(&css_set_lock);
 	rcu_read_lock();
@@ -2572,6 +2574,15 @@ static int cgroup_subtree_control_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
+/* show controlllers that have resource control knobs in resource_domain */
+static int cgroup_resource_control_show(struct seq_file *seq, void *v)
+{
+	struct cgroup *cgrp = seq_css(seq)->cgroup;
+
+	cgroup_print_ss_mask(seq, cgrp->resource_control);
+	return 0;
+}
+
 /**
  * cgroup_update_dfl_csses - update css assoc of a subtree in default hierarchy
  * @cgrp: root of the subtree to update csses for
@@ -2921,33 +2932,30 @@ static ssize_t cgroup_subtree_control_write(struct kernfs_open_file *of,
 	if (!cgrp)
 		return -ENODEV;
 
-	for_each_subsys(ss, ssid) {
-		if (enable & (1 << ssid)) {
-			if (cgrp->subtree_control & (1 << ssid)) {
-				enable &= ~(1 << ssid);
-				continue;
-			}
-
-			if (!(cgroup_control(cgrp) & (1 << ssid))) {
-				ret = -ENOENT;
-				goto out_unlock;
-			}
-		} else if (disable & (1 << ssid)) {
-			if (!(cgrp->subtree_control & (1 << ssid))) {
-				disable &= ~(1 << ssid);
-				continue;
-			}
-
-			/* a child has it enabled? */
-			cgroup_for_each_live_child(child, cgrp) {
-				if (child->subtree_control & (1 << ssid)) {
-					ret = -EBUSY;
-					goto out_unlock;
-				}
-			}
+	/*
+	 * We cannot disable controllers that are enabled in a child
+	 * cgroup.
+	 */
+	if (disable) {
+		u16 child_enable = cgrp->resource_control;
+
+		cgroup_for_each_live_child(child, cgrp)
+			child_enable |= child->subtree_control|
+					child->resource_control;
+		if (disable & child_enable) {
+			ret = -EBUSY;
+			goto out_unlock;
 		}
 	}
 
+	if (enable & ~cgroup_control(cgrp)) {
+		ret = -ENOENT;
+		goto out_unlock;
+	}
+
+	enable  &= ~cgrp->subtree_control;
+	disable &= cgrp->subtree_control;
+
 	if (!enable && !disable) {
 		ret = 0;
 		goto out_unlock;
@@ -2959,45 +2967,116 @@ static ssize_t cgroup_subtree_control_write(struct kernfs_open_file *of,
 		goto out_unlock;
 	}
 
+	/* save and update control masks and prepare csses */
+	cgroup_save_control(cgrp);
+
+	cgrp->subtree_control |= enable;
+	cgrp->subtree_control &= ~disable;
+
+	ret = cgroup_apply_control(cgrp);
+
+	cgroup_finalize_control(cgrp, ret);
+
+	kernfs_activate(cgrp->kn);
+	ret = 0;
+out_unlock:
+	cgroup_kn_unlock(of->kn);
+	return ret ?: nbytes;
+}
+
+/*
+ * Change the list of resource domain controllers for a cgroup in the
+ * default hierarchy
+ */
+static ssize_t cgroup_resource_control_write(struct kernfs_open_file *of,
+					     char *buf, size_t nbytes,
+					     loff_t off)
+{
+	u16 enable = 0, disable = 0;
+	struct cgroup *cgrp;
+	struct cgroup_subsys *ss;
+	char *tok;
+	int ssid, ret;
+
 	/*
-	 * Except for root, thread roots and threaded cgroups, subtree_control
-	 * must be zero for a cgroup with tasks so that child cgroups don't
-	 * compete against tasks.
+	 * Parse input - space separated list of subsystem names prefixed
+	 * with either + or -.
 	 */
-	if (enable && cgroup_parent(cgrp) && !cgrp->proc_cgrp) {
-		struct cgrp_cset_link *link;
-
-		/*
-		 * Because namespaces pin csets too, @cgrp->cset_links
-		 * might not be empty even when @cgrp is empty.  Walk and
-		 * verify each cset.
-		 */
-		spin_lock_irq(&css_set_lock);
+	buf = strstrip(buf);
+	while ((tok = strsep(&buf, " "))) {
+		if (tok[0] == '\0')
+			continue;
+		do_each_subsys_mask(ss, ssid, ~cgrp_dfl_inhibit_ss_mask) {
+			if (!cgroup_ssid_enabled(ssid) ||
+			    strcmp(tok + 1, ss->name))
+				continue;
 
-		ret = 0;
-		list_for_each_entry(link, &cgrp->cset_links, cset_link) {
-			if (css_set_populated(link->cset)) {
-				ret = -EBUSY;
-				break;
+			if (*tok == '+') {
+				enable |= 1 << ssid;
+				disable &= ~(1 << ssid);
+			} else if (*tok == '-') {
+				disable |= 1 << ssid;
+				enable &= ~(1 << ssid);
+			} else {
+				return -EINVAL;
 			}
-		}
+			break;
+		} while_each_subsys_mask();
+		if (ssid == CGROUP_SUBSYS_COUNT)
+			return -EINVAL;
+	}
 
-		spin_unlock_irq(&css_set_lock);
+	cgrp = cgroup_kn_lock_live(of->kn, true);
+	if (!cgrp)
+		return -ENODEV;
 
-		if (ret)
-			goto out_unlock;
+	/*
+	 * All the enabled or disabled controllers must have been enabled
+	 * in the current cgroup.
+	 */
+	if ((cgroup_control(cgrp) & (enable|disable)) != (enable|disable)) {
+		ret = -ENOENT;
+		goto out_unlock;
 	}
 
+	/*
+	 * Clear bits that are currently enabled and disabled in
+	 * resource_control.
+	 */
+	enable  &= ~cgrp->resource_control;
+	disable &=  cgrp->resource_control;
+
+	if (!enable && !disable) {
+		ret = 0;
+		goto out_unlock;
+	}
+
+	/*
+	 * Create a new child resource domain cgroup if necessary.
+	 */
+	if (!cgrp->resource_domain && enable)
+		cgroup_mkdir(cgrp->kn, NULL, 0755);
+
+	cgrp->resource_control &= ~disable;
+	cgrp->resource_control |= enable;
+
 	/* save and update control masks and prepare csses */
 	cgroup_save_control(cgrp);
 
-	cgrp->subtree_control |= enable;
-	cgrp->subtree_control &= ~disable;
-
 	ret = cgroup_apply_control(cgrp);
 
 	cgroup_finalize_control(cgrp, ret);
 
+	/*
+	 * Destroy the child resource domain cgroup if no controllers are
+	 * enabled in the resource_control.
+	 */
+	if (!cgrp->resource_control) {
+		struct cgroup *rdomain = cgrp->resource_domain;
+
+		cgrp->resource_domain = NULL;
+		cgroup_destroy_locked(rdomain);
+	}
 	kernfs_activate(cgrp->kn);
 	ret = 0;
 out_unlock:
@@ -4303,6 +4382,11 @@ static ssize_t cgroup_threads_write(struct kernfs_open_file *of,
 		.write = cgroup_subtree_control_write,
 	},
 	{
+		.name = "cgroup.resource_control",
+		.seq_show = cgroup_resource_control_show,
+		.write = cgroup_resource_control_write,
+	},
+	{
 		.name = "cgroup.events",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.file_offset = offsetof(struct cgroup, events_file),
@@ -4661,25 +4745,49 @@ static struct cgroup *cgroup_create(struct cgroup *parent)
 	return ERR_PTR(ret);
 }
 
+/*
+ * The name parameter will be NULL if called internally for creating the
+ * special resource domain cgroup. In this case, the cgroup_mutex will be
+ * held and there is no need to acquire or release it.
+ */
 int cgroup_mkdir(struct kernfs_node *parent_kn, const char *name, umode_t mode)
 {
 	struct cgroup *parent, *cgrp;
 	struct kernfs_node *kn;
+	bool create_rd = (name == NULL);
 	int ret;
 
-	/* do not accept '\n' to prevent making /proc/<pid>/cgroup unparsable */
-	if (strchr(name, '\n'))
-		return -EINVAL;
+	/*
+	 * Do not accept '\n' to prevent making /proc/<pid>/cgroup unparsable.
+	 * The reserved resource domain directory name cannot be used. A
+	 * sub-directory cannot be created under a resource domain directory.
+	 */
+	if (create_rd) {
+		lockdep_assert_held(&cgroup_mutex);
+		name = CGROUP_RESOURCE_DOMAIN;
+		parent = parent_kn->priv;
+	} else {
+		if (strchr(name, '\n') || !strcmp(name, CGROUP_RESOURCE_DOMAIN))
+			return -EINVAL;
 
-	parent = cgroup_kn_lock_live(parent_kn, false);
-	if (!parent)
-		return -ENODEV;
+		parent = cgroup_kn_lock_live(parent_kn, false);
+		if (!parent)
+			return -ENODEV;
+		if (test_bit(CGRP_RESOURCE_DOMAIN, &parent->flags)) {
+			ret = -EINVAL;
+			goto out_unlock;
+		}
+	}
 
 	cgrp = cgroup_create(parent);
 	if (IS_ERR(cgrp)) {
 		ret = PTR_ERR(cgrp);
 		goto out_unlock;
 	}
+	if (create_rd) {
+		parent->resource_domain = cgrp;
+		set_bit(CGRP_RESOURCE_DOMAIN, &cgrp->flags);
+	}
 
 	/* create the directory */
 	kn = kernfs_create_dir(parent->kn, name, mode, cgrp);
@@ -4699,9 +4807,11 @@ int cgroup_mkdir(struct kernfs_node *parent_kn, const char *name, umode_t mode)
 	if (ret)
 		goto out_destroy;
 
-	ret = css_populate_dir(&cgrp->self);
-	if (ret)
-		goto out_destroy;
+	if (!create_rd) {
+		ret = css_populate_dir(&cgrp->self);
+		if (ret)
+			goto out_destroy;
+	}
 
 	ret = cgroup_apply_control_enable(cgrp);
 	if (ret)
@@ -4718,7 +4828,8 @@ int cgroup_mkdir(struct kernfs_node *parent_kn, const char *name, umode_t mode)
 out_destroy:
 	cgroup_destroy_locked(cgrp);
 out_unlock:
-	cgroup_kn_unlock(parent_kn);
+	if (!create_rd)
+		cgroup_kn_unlock(parent_kn);
 	return ret;
 }
 
@@ -4893,7 +5004,15 @@ int cgroup_rmdir(struct kernfs_node *kn)
 	if (!cgrp)
 		return 0;
 
-	ret = cgroup_destroy_locked(cgrp);
+	/*
+	 * A resource domain cgroup cannot be removed directly by users.
+	 * It can only be done indirectly by writing to the "cgroup.resource"
+	 * control file.
+	 */
+	if (test_bit(CGRP_RESOURCE_DOMAIN, &cgrp->flags))
+		ret = -EINVAL;
+	else
+		ret = cgroup_destroy_locked(cgrp);
 
 	if (!ret)
 		trace_cgroup_rmdir(cgrp);
diff --git a/kernel/cgroup/debug.c b/kernel/cgroup/debug.c
index 3121811..b565951 100644
--- a/kernel/cgroup/debug.c
+++ b/kernel/cgroup/debug.c
@@ -237,8 +237,9 @@ static int cgroup_masks_read(struct seq_file *seq, void *v)
 		u16  *mask;
 		char *name;
 	} mask_list[] = {
-		{ &cgrp->subtree_control, "subtree_control" },
-		{ &cgrp->subtree_ss_mask, "subtree_ss_mask" },
+		{ &cgrp->subtree_control,  "subtree_control"  },
+		{ &cgrp->subtree_ss_mask,  "subtree_ss_mask"  },
+		{ &cgrp->resource_control, "resource_control" },
 	};
 
 	mutex_lock(&cgroup_mutex);
@@ -246,7 +247,7 @@ static int cgroup_masks_read(struct seq_file *seq, void *v)
 		u16 mask = *mask_list[i].mask;
 		bool first = true;
 
-		seq_printf(seq, "%-15s: ", mask_list[i].name);
+		seq_printf(seq, "%-16s: ", mask_list[i].name);
 		for_each_subsys(ss, j) {
 			if (!(mask & (1 << ss->id)))
 				continue;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
