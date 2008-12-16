Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CA6346B0075
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 05:58:20 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBG9DBvR025106
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Dec 2008 18:13:11 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A34C45DE50
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:13:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DC3A145DE51
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:13:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 703C11DB803B
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:13:10 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BE7031DB8048
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:13:09 +0900 (JST)
Date: Tue, 16 Dec 2008 18:12:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/9] cgroup hierarchy mutex
Message-Id: <20081216181213.09a816d8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081216180936.d6b65abf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081216180936.d6b65abf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This was RFC from Paul Menage. Including here just for base of my series.
==
From:	menage@google.com

- linking a cgroup into that subsystem's cgroup tree
- unlinking a cgroup from that subsystem's cgroup tree
- moving the subsystem to/from a hierarchy (including across the
  bind() callback)

Thus if the subsystem holds its own hierarchy_mutex, it can safely
traverse its own hierarchy.

Signed-off-by: Paul Menage <menage@google.com>

---
Index: mmotm-2.6.28-Dec12/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.28-Dec12.orig/include/linux/cgroup.h
+++ mmotm-2.6.28-Dec12/include/linux/cgroup.h
@@ -337,8 +337,15 @@ struct cgroup_subsys {
 #define MAX_CGROUP_TYPE_NAMELEN 32
 	const char *name;
 
-	struct cgroupfs_root *root;
+	/*
+	 * Protects sibling/children links of cgroups in this
+	 * hierarchy, plus protects which hierarchy (or none) the
+	 * subsystem is a part of (i.e. root/sibling)
+	 */
+	struct mutex hierarchy_mutex;
 
+	/* Protected by this->hierarchy_mutex and cgroup_lock() */
+	struct cgroupfs_root *root;
 	struct list_head sibling;
 };
 
Index: mmotm-2.6.28-Dec12/kernel/cgroup.c
===================================================================
--- mmotm-2.6.28-Dec12.orig/kernel/cgroup.c
+++ mmotm-2.6.28-Dec12/kernel/cgroup.c
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
 
Index: mmotm-2.6.28-Dec12/Documentation/cgroups/cgroups.txt
===================================================================
--- mmotm-2.6.28-Dec12.orig/Documentation/cgroups/cgroups.txt
+++ mmotm-2.6.28-Dec12/Documentation/cgroups/cgroups.txt
@@ -528,7 +528,7 @@ example in cpusets, no task may attach b
 up.
 
 void bind(struct cgroup_subsys *ss, struct cgroup *root)
-(cgroup_mutex held by caller)
+(cgroup_mutex and ss->hierarchy_mutex held by caller)
 
 Called when a cgroup subsystem is rebound to a different hierarchy
 and root cgroup. Currently this will only involve movement between

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
