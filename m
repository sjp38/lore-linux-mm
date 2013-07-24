Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 4906D6B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 05:59:44 -0400 (EDT)
Message-ID: <51EFA570.5020907@huawei.com>
Date: Wed, 24 Jul 2013 17:59:12 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v2 1/8] cgroup: convert cgroup_ida to cgroup_idr
References: <51EFA554.6080801@huawei.com>
In-Reply-To: <51EFA554.6080801@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

This enables us to lookup a cgroup by its id.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 include/linux/cgroup.h |  4 ++--
 kernel/cgroup.c        | 40 ++++++++++++++++++++++++++++------------
 2 files changed, 30 insertions(+), 14 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 297462b..2bd052d 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -161,7 +161,7 @@ struct cgroup_name {
 struct cgroup {
 	unsigned long flags;		/* "unsigned long" so bitops work */
 
-	int id;				/* ida allocated in-hierarchy ID */
+	int id;				/* idr allocated in-hierarchy ID */
 
 	/*
 	 * We link our 'sibling' struct into our parent's 'children'.
@@ -322,7 +322,7 @@ struct cgroupfs_root {
 	unsigned long flags;
 
 	/* IDs for cgroups in this hierarchy */
-	struct ida cgroup_ida;
+	struct idr cgroup_idr;
 
 	/* The path to use for release notifications. */
 	char release_agent_path[PATH_MAX];
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 345fac8..ee3c02e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -866,8 +866,6 @@ static void cgroup_free_fn(struct work_struct *work)
 	 */
 	dput(cgrp->parent->dentry);
 
-	ida_simple_remove(&cgrp->root->cgroup_ida, cgrp->id);
-
 	/*
 	 * Drop the active superblock reference that we took when we
 	 * created the cgroup. This will free cgrp->root, if we are
@@ -1379,6 +1377,7 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 	cgrp->root = root;
 	RCU_INIT_POINTER(cgrp->name, &root_cgroup_name);
 	init_cgroup_housekeeping(cgrp);
+	idr_init(&root->cgroup_idr);
 }
 
 static int cgroup_init_root_id(struct cgroupfs_root *root, int start, int end)
@@ -1451,7 +1450,6 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
 	 */
 	root->subsys_mask = opts->subsys_mask;
 	root->flags = opts->flags;
-	ida_init(&root->cgroup_ida);
 	if (opts->release_agent)
 		strcpy(root->release_agent_path, opts->release_agent);
 	if (opts->name)
@@ -1467,7 +1465,7 @@ static void cgroup_free_root(struct cgroupfs_root *root)
 		/* hierarhcy ID shoulid already have been released */
 		WARN_ON_ONCE(root->hierarchy_id);
 
-		ida_destroy(&root->cgroup_ida);
+		idr_destroy(&root->cgroup_idr);
 		kfree(root);
 	}
 }
@@ -1582,6 +1580,11 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		mutex_lock(&cgroup_mutex);
 		mutex_lock(&cgroup_root_mutex);
 
+		root_cgrp->id = idr_alloc(&root->cgroup_idr, root_cgrp,
+					   0, 1, GFP_KERNEL);
+		if (root_cgrp->id < 0)
+			goto unlock_drop;
+
 		/* Check for name clashes with existing mounts */
 		ret = -EBUSY;
 		if (strlen(root->name))
@@ -4268,15 +4271,19 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	if (!cgrp)
 		return -ENOMEM;
 
+	/*
+	 * Temporarily set the pointer to NULL, so idr_find() won't return
+	 * a half-baked cgroup.
+	 */
+	cgrp->id = idr_alloc(&root->cgroup_idr, NULL, 1, 0, GFP_KERNEL);
+	if (cgrp->id < 0)
+		goto err_free_cgrp;
+
 	name = cgroup_alloc_name(dentry);
 	if (!name)
-		goto err_free_cgrp;
+		goto err_free_id;
 	rcu_assign_pointer(cgrp->name, name);
 
-	cgrp->id = ida_simple_get(&root->cgroup_ida, 1, 0, GFP_KERNEL);
-	if (cgrp->id < 0)
-		goto err_free_name;
-
 	/*
 	 * Only live parents can have children.  Note that the liveliness
 	 * check isn't strictly necessary because cgroup_mkdir() and
@@ -4286,7 +4293,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	 */
 	if (!cgroup_lock_live_group(parent)) {
 		err = -ENODEV;
-		goto err_free_id;
+		goto err_free_name;
 	}
 
 	/* Grab a reference on the superblock so the hierarchy doesn't
@@ -4371,6 +4378,8 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		}
 	}
 
+	idr_replace(&root->cgroup_idr, cgrp, cgrp->id);
+
 	err = cgroup_addrm_files(cgrp, NULL, cgroup_base_files, true);
 	if (err)
 		goto err_destroy;
@@ -4396,10 +4405,10 @@ err_free_all:
 	mutex_unlock(&cgroup_mutex);
 	/* Release the reference count that we took on the superblock */
 	deactivate_super(sb);
-err_free_id:
-	ida_simple_remove(&root->cgroup_ida, cgrp->id);
 err_free_name:
 	kfree(rcu_dereference_raw(cgrp->name));
+err_free_id:
+	idr_remove(&root->cgroup_idr, cgrp->id);
 err_free_cgrp:
 	kfree(cgrp);
 	return err;
@@ -4590,6 +4599,9 @@ static void cgroup_offline_fn(struct work_struct *work)
 	/* delete this cgroup from parent->children */
 	list_del_rcu(&cgrp->sibling);
 
+	if (cgrp->id)
+		idr_remove(&cgrp->root->cgroup_idr, cgrp->id);
+
 	dput(d);
 
 	set_bit(CGRP_RELEASABLE, &parent->flags);
@@ -4915,6 +4927,10 @@ int __init cgroup_init(void)
 
 	BUG_ON(cgroup_init_root_id(&cgroup_dummy_root, 0, 1));
 
+	err = idr_alloc(&cgroup_dummy_root.cgroup_idr, cgroup_dummy_top,
+			1, 0, GFP_KERNEL);
+	BUG_ON(err);
+
 	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
