Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1935E6B0075
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 06:35:28 -0500 (EST)
Message-Id: <20081216113652.929310000@menage.corp.google.com>
References: <20081216113055.713856000@menage.corp.google.com>
Date: Tue, 16 Dec 2008 03:30:56 -0800
From: menage@google.com
Subject: [PATCH 1/3] CGroups: Add a per-subsystem hierarchy_mutex
Content-Disposition: inline; filename=cgroup_hierarchy_lock.patch
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds a hierarchy_mutex to the cgroup_subsys object that
protects changes to the hierarchy observed by that subsystem. It is
taken by the cgroup subsystem (in addition to cgroup_mutex) for the
following operations:

- linking a cgroup into that subsystem's cgroup tree
- unlinking a cgroup from that subsystem's cgroup tree
- moving the subsystem to/from a hierarchy (including across the
  bind() callback)

Thus if the subsystem holds its own hierarchy_mutex, it can safely
traverse its own hierarchy.

Signed-off-by: Paul Menage <menage@google.com>

---

 Documentation/cgroups/cgroups.txt |    2 +-
 include/linux/cgroup.h            |   17 ++++++++++++++++-
 kernel/cgroup.c                   |   37 +++++++++++++++++++++++++++++++++++--
 3 files changed, 52 insertions(+), 4 deletions(-)

Index: hierarchy_lock-mmotm-2008-12-09/include/linux/cgroup.h
===================================================================
--- hierarchy_lock-mmotm-2008-12-09.orig/include/linux/cgroup.h
+++ hierarchy_lock-mmotm-2008-12-09/include/linux/cgroup.h
@@ -337,8 +337,23 @@ struct cgroup_subsys {
 #define MAX_CGROUP_TYPE_NAMELEN 32
 	const char *name;
 
+	/*
+	 * Protects sibling/children links of cgroups in this
+	 * hierarchy, plus protects which hierarchy (or none) the
+	 * subsystem is a part of (i.e. root/sibling).  To avoid
+	 * potential deadlocks, the following operations should not be
+	 * undertaken while holding any hierarchy_mutex:
+	 *
+	 * - allocating memory
+	 * - initiating hotplug events
+	 */
+	struct mutex hierarchy_mutex;
+
+	/*
+	 * Link to parent, and list entry in parent's children.
+	 * Protected by this->hierarchy_mutex and cgroup_lock()
+	 */
 	struct cgroupfs_root *root;
-
 	struct list_head sibling;
 };
 
Index: hierarchy_lock-mmotm-2008-12-09/kernel/cgroup.c
===================================================================
--- hierarchy_lock-mmotm-2008-12-09.orig/kernel/cgroup.c
+++ hierarchy_lock-mmotm-2008-12-09/kernel/cgroup.c
@@ -714,23 +714,26 @@ static int rebind_subsystems(struct cgro
 			BUG_ON(cgrp->subsys[i]);
 			BUG_ON(!dummytop->subsys[i]);
 			BUG_ON(dummytop->subsys[i]->cgroup != dummytop);
+			mutex_lock(&ss->hierarchy_mutex);
 			cgrp->subsys[i] = dummytop->subsys[i];
 			cgrp->subsys[i]->cgroup = cgrp;
 			list_move(&ss->sibling, &root->subsys_list);
 			ss->root = root;
 			if (ss->bind)
 				ss->bind(ss, cgrp);
-
+			mutex_unlock(&ss->hierarchy_mutex);
 		} else if (bit & removed_bits) {
 			/* We're removing this subsystem */
 			BUG_ON(cgrp->subsys[i] != dummytop->subsys[i]);
 			BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
+			mutex_lock(&ss->hierarchy_mutex);
 			if (ss->bind)
 				ss->bind(ss, dummytop);
 			dummytop->subsys[i]->cgroup = dummytop;
 			cgrp->subsys[i] = NULL;
 			subsys[i]->root = &rootnode;
 			list_move(&ss->sibling, &rootnode.subsys_list);
+			mutex_unlock(&ss->hierarchy_mutex);
 		} else if (bit & final_bits) {
 			/* Subsystem state should already exist */
 			BUG_ON(!cgrp->subsys[i]);
@@ -2326,6 +2329,29 @@ static void init_cgroup_css(struct cgrou
 	cgrp->subsys[ss->subsys_id] = css;
 }
 
+static void cgroup_lock_hierarchy(struct cgroupfs_root *root)
+{
+	/* We need to take each hierarchy_mutex in a consistent order */
+	int i;
+
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+		struct cgroup_subsys *ss = subsys[i];
+		if (ss->root == root)
+			mutex_lock_nested(&ss->hierarchy_mutex, i);
+	}
+}
+
+static void cgroup_unlock_hierarchy(struct cgroupfs_root *root)
+{
+	int i;
+
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+		struct cgroup_subsys *ss = subsys[i];
+		if (ss->root == root)
+			mutex_unlock(&ss->hierarchy_mutex);
+	}
+}
+
 /*
  * cgroup_create - create a cgroup
  * @parent: cgroup that will be parent of the new cgroup
@@ -2374,7 +2400,9 @@ static long cgroup_create(struct cgroup 
 		init_cgroup_css(css, ss, cgrp);
 	}
 
+	cgroup_lock_hierarchy(root);
 	list_add(&cgrp->sibling, &cgrp->parent->children);
+	cgroup_unlock_hierarchy(root);
 	root->number_of_cgroups++;
 
 	err = cgroup_create_dir(cgrp, dentry, mode);
@@ -2492,8 +2520,12 @@ static int cgroup_rmdir(struct inode *un
 	if (!list_empty(&cgrp->release_list))
 		list_del(&cgrp->release_list);
 	spin_unlock(&release_list_lock);
-	/* delete my sibling from parent->children */
+
+	cgroup_lock_hierarchy(cgrp->root);
+	/* delete this cgroup from parent->children */
 	list_del(&cgrp->sibling);
+	cgroup_unlock_hierarchy(cgrp->root);
+
 	spin_lock(&cgrp->dentry->d_lock);
 	d = dget(cgrp->dentry);
 	spin_unlock(&d->d_lock);
@@ -2535,6 +2567,7 @@ static void __init cgroup_init_subsys(st
 	 * need to invoke fork callbacks here. */
 	BUG_ON(!list_empty(&init_task.tasks));
 
+	mutex_init(&ss->hierarchy_mutex);
 	ss->active = 1;
 }
 
Index: hierarchy_lock-mmotm-2008-12-09/Documentation/cgroups/cgroups.txt
===================================================================
--- hierarchy_lock-mmotm-2008-12-09.orig/Documentation/cgroups/cgroups.txt
+++ hierarchy_lock-mmotm-2008-12-09/Documentation/cgroups/cgroups.txt
@@ -528,7 +528,7 @@ example in cpusets, no task may attach b
 up.
 
 void bind(struct cgroup_subsys *ss, struct cgroup *root)
-(cgroup_mutex held by caller)
+(cgroup_mutex and ss->hierarchy_mutex held by caller)
 
 Called when a cgroup subsystem is rebound to a different hierarchy
 and root cgroup. Currently this will only involve movement between

--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
