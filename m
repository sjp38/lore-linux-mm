Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B8B166B03A8
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:05:18 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f53so22136148qte.15
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 07:05:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u127si9612974qkb.233.2017.04.21.07.05.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 07:05:17 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 14/14] cgroup: Enable separate control knobs for thread root internal processes
Date: Fri, 21 Apr 2017 10:04:12 -0400
Message-Id: <1492783452-12267-15-git-send-email-longman@redhat.com>
In-Reply-To: <1492783452-12267-1-git-send-email-longman@redhat.com>
References: <1492783452-12267-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de, Waiman Long <longman@redhat.com>

Internal processes are allowed in a thread root of the cgroup v2
default hierarchy. For those resource domain controllers that don't
want to deal with resource competition between internal processes and
child cgroups, there is now the option of specifying the sep_res_domain
flag in their cgroup_subsys data structure. This flag will tell the
cgroup core to create a special directory "cgroup.self" under the
thread root to hold their resource control knobs for all the processes
within the threaded subtree.

User applications can then tune the control knobs in the "cgroup.self"
directory as if all the threaded subtree processes are under it for
resoruce tracking and controlling purpose.

This directory name is reserved and so it cannot be created or deleted
directly. Moreover, sub-directory cannot be created under it.

This sep_res_domain flag is turned on in the memcg to showcase
its effect.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/cgroup-v2.txt |  20 ++++++++
 include/linux/cgroup-defs.h |  15 ++++++
 kernel/cgroup/cgroup.c      | 122 +++++++++++++++++++++++++++++++++++++++-----
 kernel/cgroup/debug.c       |   6 +++
 mm/memcontrol.c             |   1 +
 5 files changed, 150 insertions(+), 14 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index 4d1c24d..e4c25ec 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -393,6 +393,26 @@ cgroup must create children and transfer all its processes to the
 children before enabling controllers in its "cgroup.subtree_control"
 file.
 
+2-4-4. Resource Domain Controllers
+
+As internal processes are allowed in a threaded subtree, a non-threaded
+controller at a thread root cgroup has to properly manage resource
+competition between internal processes and other child non-threaded
+cgroups. However, a controller can specify that it wants to have
+separate resource domain to manage the resources of the processes in
+the threaded subtree instead of each process individually. In this
+case, a "cgroup.self" directory will be created at the thread root
+to hold the resource control knobs for the processes in the threaded
+subtree as if those internal processes are all under the cgroup.self
+child cgroup for resource tracking and controlling purpose.
+
+The "cgroup.self" directory is a special directory which cannot
+be created or deleted directly. No sub-directory can be created
+under it and special files like "cgroup.procs" are not present so
+tasks cannot be moved directly into it.  It is created when a cgroup
+becomes the thread root and have controllers that request separate
+resource domains. It will be removed when that cgroup is not a thread
+root anymore.
 
 2-5. Delegation
 
diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index 7be1a90..e383f10 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -65,6 +65,7 @@ enum {
 enum {
 	CGRP_ROOT_NOPREFIX	= (1 << 1), /* mounted subsystems have no named prefix */
 	CGRP_ROOT_XATTR		= (1 << 2), /* supports extended attributes */
+	CGRP_RESOURCE_DOMAIN	= (1 << 3), /* thread root resource domain */
 };
 
 /* cftype->flags */
@@ -293,6 +294,9 @@ struct cgroup {
 
 	struct cgroup_root *root;
 
+	/* Pointer to separate resource domain for thread root */
+	struct cgroup *resource_domain;
+
 	/*
 	 * List of cgrp_cset_links pointing at css_sets with tasks in this
 	 * cgroup.  Protected by css_set_lock.
@@ -516,6 +520,17 @@ struct cgroup_subsys {
 	bool threaded:1;
 
 	/*
+	 * If %true, the controller will need a separate resource domain in
+	 * a thread root to avoid internal processes associated with the
+	 * threaded subtree to compete with other child cgroups. This is done
+	 * by having a separate set of knobs in the cgroup.self directory.
+	 * These knobs will control how much resources are allocated to the
+	 * processes in the threaded subtree. Only !thread controllers should
+	 * have this flag turned on.
+	 */
+	bool sep_res_domain:1;
+
+	/*
 	 * If %false, this subsystem is properly hierarchical -
 	 * configuration, resource accounting and restriction on a parent
 	 * cgroup cover those of its children.  If %true, hierarchy support
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 50577c5..3ff3ff5 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -61,6 +61,11 @@
 
 #define CGROUP_FILE_NAME_MAX		(MAX_CGROUP_TYPE_NAMELEN +	\
 					 MAX_CFTYPE_NAME + 2)
+/*
+ * Reserved cgroup directory name for resource domain controllers. Users
+ * are not allowed to create child cgroup of that name.
+ */
+#define CGROUP_SELF	"cgroup.self"
 
 /*
  * cgroup_mutex is the master lock.  Any modification to cgroup or its
@@ -165,6 +170,12 @@ struct cgroup_subsys *cgroup_subsys[] = {
 /* some controllers can be threaded on the default hierarchy */
 static u16 cgrp_dfl_threaded_ss_mask;
 
+/*
+ * Some controllers need separate resource domain on thread root of the
+ * default hierarchy
+ */
+static u16 cgrp_dfl_rdomain_ss_mask;
+
 /* The list of hierarchy roots */
 LIST_HEAD(cgroup_roots);
 static int cgroup_root_count;
@@ -337,7 +348,9 @@ static u16 cgroup_control(struct cgroup *cgrp)
 	if (parent) {
 		u16 ss_mask = parent->subtree_control;
 
-		if (cgroup_is_threaded(cgrp))
+		if (cgrp->flags & CGRP_RESOURCE_DOMAIN)
+			ss_mask &= cgrp_dfl_rdomain_ss_mask;
+		else if (cgroup_is_threaded(cgrp))
 			ss_mask &= cgrp_dfl_threaded_ss_mask;
 		return ss_mask;
 	}
@@ -356,7 +369,9 @@ static u16 cgroup_ss_mask(struct cgroup *cgrp)
 	if (parent) {
 		u16 ss_mask = parent->subtree_ss_mask;
 
-		if (cgroup_is_threaded(cgrp))
+		if (cgrp->flags & CGRP_RESOURCE_DOMAIN)
+			ss_mask &= cgrp_dfl_rdomain_ss_mask;
+		else if (cgroup_is_threaded(cgrp))
 			ss_mask &= cgrp_dfl_threaded_ss_mask;
 		return ss_mask;
 	}
@@ -413,6 +428,18 @@ static struct cgroup_subsys_state *cgroup_e_css(struct cgroup *cgrp,
 			return NULL;
 	}
 
+	/*
+	 * On a thread root with a resource domain, use the css in the
+	 * resource domain, if enabled.
+	 */
+	if (cgrp->resource_domain &&
+	   (cgroup_ss_mask(cgrp->resource_domain) & (1 << ss->id))) {
+		struct cgroup_subsys_state *css;
+
+		css = cgroup_css(cgrp->resource_domain, ss);
+		if (css)
+			return css;
+	}
 	return cgroup_css(cgrp, ss);
 }
 
@@ -3039,8 +3066,21 @@ static int cgroup_enable_threaded(struct cgroup *cgrp)
 		goto setup_child;
 
 	/*
+	 * Create a resource domain child cgroup, if necessary.
+	 * Update the css association if controllers are enabled in
+	 * the resource domain child cgroup.
+	 */
+	if (cgrp->root->subsys_mask & cgrp_dfl_rdomain_ss_mask) {
+		cgroup_mkdir(cgrp->kn, NULL, 0755);
+		if (cgrp->resource_domain &&
+		    cgroup_ss_mask(cgrp->resource_domain))
+			cgroup_update_dfl_csses(cgrp);
+	}
+
+	/*
 	 * For the parent cgroup, we need to find all csets which need
-	 * ->proc_cset updated
+	 * ->proc_cset updated. The updated csets will also pick up the
+	 * new resource domain css'es along the way.
 	 */
 	spin_lock_irq(&css_set_lock);
 	list_for_each_entry(link, &cgrp->cset_links, cset_link) {
@@ -3132,6 +3172,7 @@ static int cgroup_disable_threaded(struct cgroup *cgrp)
 {
 	struct cgrp_cset_link *link;
 	struct cgroup *parent = cgroup_parent(cgrp);
+	struct cgroup *rdomain = NULL;
 
 	lockdep_assert_held(&cgroup_mutex);
 
@@ -3182,6 +3223,8 @@ static int cgroup_disable_threaded(struct cgroup *cgrp)
 	/*
 	 * Check remaining threaded children count to see if the threaded
 	 * csets of the parent need to be removed and ->proc_cset reset.
+	 * If valid css'es are present in the resource domain cgroup, we
+	 * need to migrate the csets away from those css'es.
 	 */
 	spin_lock_irq(&css_set_lock);
 
@@ -3189,6 +3232,14 @@ static int cgroup_disable_threaded(struct cgroup *cgrp)
 		goto out_unlock;	/* still have threaded children left */
 
 	cgrp = parent;
+
+	/*
+	 * Prepare to remove the resource domain child cgroup.
+	 */
+	rdomain = cgrp->resource_domain;
+	if (rdomain)
+		cgrp->resource_domain = NULL;
+
 	list_for_each_entry(link, &cgrp->cset_links, cset_link) {
 		struct css_set *cset = link->cset;
 
@@ -3214,6 +3265,16 @@ static int cgroup_disable_threaded(struct cgroup *cgrp)
 out_unlock:
 	spin_unlock_irq(&css_set_lock);
 
+	if (rdomain) {
+		/*
+		 * Update the css association if controllers are enabled
+		 * in the resource domain child cgroup before destroying
+		 * that resource domain.
+		 */
+		if (cgroup_ss_mask(rdomain))
+			cgroup_update_dfl_csses(cgrp);
+		cgroup_destroy_locked(rdomain);
+	}
 	return 0;
 }
 
@@ -4660,21 +4721,41 @@ int cgroup_mkdir(struct kernfs_node *parent_kn, const char *name, umode_t mode)
 {
 	struct cgroup *parent, *cgrp;
 	struct kernfs_node *kn;
+	bool create_self = (name == NULL);
 	int ret;
 
-	/* do not accept '\n' to prevent making /proc/<pid>/cgroup unparsable */
-	if (strchr(name, '\n'))
-		return -EINVAL;
+	/*
+	 * Do not accept '\n' to prevent making /proc/<pid>/cgroup unparsable.
+	 * The reserved resource domain directory name cannot be used. A NULL
+	 * name parameter, however, is used internally to create that
+	 * resource domain directory. A sub-directory cannot be created
+	 * under a resource domain directory.
+	 */
+	if (create_self) {
+		name = CGROUP_SELF;
+		parent = parent_kn->priv;
+	} else {
+		if (strchr(name, '\n') || !strcmp(name, CGROUP_SELF))
+			return -EINVAL;
 
-	parent = cgroup_kn_lock_live(parent_kn, false);
-	if (!parent)
-		return -ENODEV;
+		parent = cgroup_kn_lock_live(parent_kn, false);
+		if (!parent)
+			return -ENODEV;
+		if (parent->flags & CGRP_RESOURCE_DOMAIN) {
+			ret = -EINVAL;
+			goto out_unlock;
+		}
+	}
 
 	cgrp = cgroup_create(parent);
 	if (IS_ERR(cgrp)) {
 		ret = PTR_ERR(cgrp);
 		goto out_unlock;
 	}
+	if (create_self) {
+		parent->resource_domain = cgrp;
+		cgrp->flags |= CGRP_RESOURCE_DOMAIN;
+	}
 
 	/* create the directory */
 	kn = kernfs_create_dir(parent->kn, name, mode, cgrp);
@@ -4694,9 +4775,11 @@ int cgroup_mkdir(struct kernfs_node *parent_kn, const char *name, umode_t mode)
 	if (ret)
 		goto out_destroy;
 
-	ret = css_populate_dir(&cgrp->self);
-	if (ret)
-		goto out_destroy;
+	if (!create_self) {
+		ret = css_populate_dir(&cgrp->self);
+		if (ret)
+			goto out_destroy;
+	}
 
 	ret = cgroup_apply_control_enable(cgrp);
 	if (ret)
@@ -4713,7 +4796,8 @@ int cgroup_mkdir(struct kernfs_node *parent_kn, const char *name, umode_t mode)
 out_destroy:
 	cgroup_destroy_locked(cgrp);
 out_unlock:
-	cgroup_kn_unlock(parent_kn);
+	if (!create_self)
+		cgroup_kn_unlock(parent_kn);
 	return ret;
 }
 
@@ -4883,7 +4967,15 @@ int cgroup_rmdir(struct kernfs_node *kn)
 	if (!cgrp)
 		return 0;
 
-	ret = cgroup_destroy_locked(cgrp);
+	/*
+	 * A resource domain cgroup cannot be removed directly by users.
+	 * It can only be done internally when its parent directory is
+	 * no longer a thread root.
+	 */
+	if (cgrp->flags & CGRP_RESOURCE_DOMAIN)
+		ret = -EINVAL;
+	else
+		ret = cgroup_destroy_locked(cgrp);
 
 	if (!ret)
 		trace_cgroup_rmdir(cgrp);
@@ -5070,6 +5162,8 @@ int __init cgroup_init(void)
 
 		if (ss->threaded)
 			cgrp_dfl_threaded_ss_mask |= 1 << ss->id;
+		if (ss->sep_res_domain)
+			cgrp_dfl_rdomain_ss_mask |= 1 << ss->id;
 
 		if (ss->dfl_cftypes == ss->legacy_cftypes) {
 			WARN_ON(cgroup_add_cftypes(ss, ss->dfl_cftypes));
diff --git a/kernel/cgroup/debug.c b/kernel/cgroup/debug.c
index 4d74458..51ee2c9 100644
--- a/kernel/cgroup/debug.c
+++ b/kernel/cgroup/debug.c
@@ -269,10 +269,16 @@ static u64 releasable_read(struct cgroup_subsys_state *css, struct cftype *cft)
 	{ }	/* terminate */
 };
 
+/*
+ * Normally, threaded & sep_res_domain are mutually exclusive.
+ * Both are enabled here in the debug controller to enable better internal
+ * status tracking.
+ */
 struct cgroup_subsys debug_cgrp_subsys = {
 	.css_alloc	= debug_css_alloc,
 	.css_free	= debug_css_free,
 	.legacy_cftypes	= debug_files,
 	.dfl_cftypes	= debug_files,
 	.threaded	= true,
+	.sep_res_domain = true,
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f28ab8d..9682bbb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5292,6 +5292,7 @@ struct cgroup_subsys memory_cgrp_subsys = {
 	.dfl_cftypes = memory_files,
 	.legacy_cftypes = mem_cgroup_legacy_files,
 	.early_init = 0,
+	.sep_res_domain = true,
 };
 
 /**
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
