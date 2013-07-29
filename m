Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 955816B005C
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 03:10:52 -0400 (EDT)
Message-ID: <51F61558.7050002@huawei.com>
Date: Mon, 29 Jul 2013 15:10:16 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v3 8/8] cgroup: kill css_id
References: <51F614B2.6010503@huawei.com>
In-Reply-To: <51F614B2.6010503@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

The only user of css_id was memcg, and it has been convered to use
cgroup->id, so kill css_id.

Signed-off-by: Li Zefan <lizefan@huwei.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/cgroup.h |  37 --------
 kernel/cgroup.c        | 252 +------------------------------------------------
 2 files changed, 1 insertion(+), 288 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index e8eb361..ec8c380 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -599,11 +599,6 @@ struct cgroup_subsys {
 	int subsys_id;
 	int disabled;
 	int early_init;
-	/*
-	 * True if this subsys uses ID. ID is not available before cgroup_init()
-	 * (not available in early_init time.)
-	 */
-	bool use_id;
 
 	/*
 	 * If %false, this subsystem is properly hierarchical -
@@ -629,9 +624,6 @@ struct cgroup_subsys {
 	 */
 	struct cgroupfs_root *root;
 	struct list_head sibling;
-	/* used when use_id == true */
-	struct idr idr;
-	spinlock_t id_lock;
 
 	/* list of cftype_sets */
 	struct list_head cftsets;
@@ -858,35 +850,6 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan);
 int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
 
-/*
- * CSS ID is ID for cgroup_subsys_state structs under subsys. This only works
- * if cgroup_subsys.use_id == true. It can be used for looking up and scanning.
- * CSS ID is assigned at cgroup allocation (create) automatically
- * and removed when subsys calls free_css_id() function. This is because
- * the lifetime of cgroup_subsys_state is subsys's matter.
- *
- * Looking up and scanning function should be called under rcu_read_lock().
- * Taking cgroup_mutex is not necessary for following calls.
- * But the css returned by this routine can be "not populated yet" or "being
- * destroyed". The caller should check css and cgroup's status.
- */
-
-/*
- * Typically Called at ->destroy(), or somewhere the subsys frees
- * cgroup_subsys_state.
- */
-void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css);
-
-/* Find a cgroup_subsys_state which has given ID */
-
-struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id);
-
-/* Returns true if root is ancestor of cg */
-bool css_is_ancestor(struct cgroup_subsys_state *cg,
-		     const struct cgroup_subsys_state *root);
-
-/* Get id and depth of css */
-unsigned short css_id(struct cgroup_subsys_state *css);
 struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id);
 
 #else /* !CONFIG_CGROUPS */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index dc4a749..26caaa1 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -123,38 +123,6 @@ struct cfent {
 };
 
 /*
- * CSS ID -- ID per subsys's Cgroup Subsys State(CSS). used only when
- * cgroup_subsys->use_id != 0.
- */
-#define CSS_ID_MAX	(65535)
-struct css_id {
-	/*
-	 * The css to which this ID points. This pointer is set to valid value
-	 * after cgroup is populated. If cgroup is removed, this will be NULL.
-	 * This pointer is expected to be RCU-safe because destroy()
-	 * is called after synchronize_rcu(). But for safe use, css_tryget()
-	 * should be used for avoiding race.
-	 */
-	struct cgroup_subsys_state __rcu *css;
-	/*
-	 * ID of this css.
-	 */
-	unsigned short id;
-	/*
-	 * Depth in hierarchy which this ID belongs to.
-	 */
-	unsigned short depth;
-	/*
-	 * ID is freed by RCU. (and lookup routine is RCU safe.)
-	 */
-	struct rcu_head rcu_head;
-	/*
-	 * Hierarchy of CSS ID belongs to.
-	 */
-	unsigned short stack[0]; /* Array of Length (depth+1) */
-};
-
-/*
  * cgroup_event represents events which userspace want to receive.
  */
 struct cgroup_event {
@@ -364,9 +332,6 @@ struct cgrp_cset_link {
 static struct css_set init_css_set;
 static struct cgrp_cset_link init_cgrp_cset_link;
 
-static int cgroup_init_idr(struct cgroup_subsys *ss,
-			   struct cgroup_subsys_state *css);
-
 /* css_set_lock protects the list of css_set objects, and the
  * chain of tasks off each css_set.  Nests outside task->alloc_lock
  * due to cgroup_iter_start() */
@@ -815,9 +780,6 @@ static struct backing_dev_info cgroup_backing_dev_info = {
 	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
 };
 
-static int alloc_css_id(struct cgroup_subsys *ss,
-			struct cgroup *parent, struct cgroup *child);
-
 static struct inode *cgroup_new_inode(umode_t mode, struct super_block *sb)
 {
 	struct inode *inode = new_inode(sb);
@@ -4160,20 +4122,6 @@ static int cgroup_populate_dir(struct cgroup *cgrp, unsigned long subsys_mask)
 		}
 	}
 
-	/* This cgroup is ready now */
-	for_each_root_subsys(cgrp->root, ss) {
-		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
-		struct css_id *id = rcu_dereference_protected(css->id, true);
-
-		/*
-		 * Update id->css pointer and make this css visible from
-		 * CSS ID functions. This pointer will be dereferened
-		 * from RCU-read-side without locks.
-		 */
-		if (id)
-			rcu_assign_pointer(id->css, css);
-	}
-
 	return 0;
 err:
 	cgroup_clear_dir(cgrp, subsys_mask);
@@ -4202,7 +4150,6 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 {
 	css->cgroup = cgrp;
 	css->flags = 0;
-	css->id = NULL;
 	if (cgrp == cgroup_dummy_top)
 		css->flags |= CSS_ROOT;
 	BUG_ON(cgrp->subsys[ss->subsys_id]);
@@ -4331,12 +4278,6 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 			goto err_free_all;
 
 		init_cgroup_css(css, ss, cgrp);
-
-		if (ss->use_id) {
-			err = alloc_css_id(ss, parent, cgrp);
-			if (err)
-				goto err_free_all;
-		}
 	}
 
 	/*
@@ -4741,12 +4682,6 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 
 	/* our new subsystem will be attached to the dummy hierarchy. */
 	init_cgroup_css(css, ss, cgroup_dummy_top);
-	/* init_idr must be after init_cgroup_css because it sets css->id. */
-	if (ss->use_id) {
-		ret = cgroup_init_idr(ss, css);
-		if (ret)
-			goto err_unload;
-	}
 
 	/*
 	 * Now we need to entangle the css into the existing css_sets. unlike
@@ -4812,9 +4747,6 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 
 	offline_css(ss, cgroup_dummy_top);
 
-	if (ss->use_id)
-		idr_destroy(&ss->idr);
-
 	/* deassign the subsys_id */
 	cgroup_subsys[ss->subsys_id] = NULL;
 
@@ -4841,8 +4773,7 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	/*
 	 * remove subsystem's css from the cgroup_dummy_top and free it -
 	 * need to free before marking as null because ss->css_free needs
-	 * the cgrp->subsys pointer to find their state. note that this
-	 * also takes care of freeing the css_id.
+	 * the cgrp->subsys pointer to find their state.
 	 */
 	ss->css_free(cgroup_dummy_top);
 	cgroup_dummy_top->subsys[ss->subsys_id] = NULL;
@@ -4913,8 +4844,6 @@ int __init cgroup_init(void)
 	for_each_builtin_subsys(ss, i) {
 		if (!ss->early_init)
 			cgroup_init_subsys(ss);
-		if (ss->use_id)
-			cgroup_init_idr(ss, init_css_set.subsys[ss->subsys_id]);
 	}
 
 	/* allocate id for the dummy hierarchy */
@@ -5335,185 +5264,6 @@ static int __init cgroup_disable(char *str)
 __setup("cgroup_disable=", cgroup_disable);
 
 /*
- * Functons for CSS ID.
- */
-
-/* to get ID other than 0, this should be called when !cgroup_is_dead() */
-unsigned short css_id(struct cgroup_subsys_state *css)
-{
-	struct css_id *cssid;
-
-	/*
-	 * This css_id() can return correct value when somone has refcnt
-	 * on this or this is under rcu_read_lock(). Once css->id is allocated,
-	 * it's unchanged until freed.
-	 */
-	cssid = rcu_dereference_raw(css->id);
-
-	if (cssid)
-		return cssid->id;
-	return 0;
-}
-EXPORT_SYMBOL_GPL(css_id);
-
-/**
- *  css_is_ancestor - test "root" css is an ancestor of "child"
- * @child: the css to be tested.
- * @root: the css supporsed to be an ancestor of the child.
- *
- * Returns true if "root" is an ancestor of "child" in its hierarchy. Because
- * this function reads css->id, the caller must hold rcu_read_lock().
- * But, considering usual usage, the csses should be valid objects after test.
- * Assuming that the caller will do some action to the child if this returns
- * returns true, the caller must take "child";s reference count.
- * If "child" is valid object and this returns true, "root" is valid, too.
- */
-
-bool css_is_ancestor(struct cgroup_subsys_state *child,
-		    const struct cgroup_subsys_state *root)
-{
-	struct css_id *child_id;
-	struct css_id *root_id;
-
-	child_id  = rcu_dereference(child->id);
-	if (!child_id)
-		return false;
-	root_id = rcu_dereference(root->id);
-	if (!root_id)
-		return false;
-	if (child_id->depth < root_id->depth)
-		return false;
-	if (child_id->stack[root_id->depth] != root_id->id)
-		return false;
-	return true;
-}
-
-void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css)
-{
-	struct css_id *id = rcu_dereference_protected(css->id, true);
-
-	/* When this is called before css_id initialization, id can be NULL */
-	if (!id)
-		return;
-
-	BUG_ON(!ss->use_id);
-
-	rcu_assign_pointer(id->css, NULL);
-	rcu_assign_pointer(css->id, NULL);
-	spin_lock(&ss->id_lock);
-	idr_remove(&ss->idr, id->id);
-	spin_unlock(&ss->id_lock);
-	kfree_rcu(id, rcu_head);
-}
-EXPORT_SYMBOL_GPL(free_css_id);
-
-/*
- * This is called by init or create(). Then, calls to this function are
- * always serialized (By cgroup_mutex() at create()).
- */
-
-static struct css_id *get_new_cssid(struct cgroup_subsys *ss, int depth)
-{
-	struct css_id *newid;
-	int ret, size;
-
-	BUG_ON(!ss->use_id);
-
-	size = sizeof(*newid) + sizeof(unsigned short) * (depth + 1);
-	newid = kzalloc(size, GFP_KERNEL);
-	if (!newid)
-		return ERR_PTR(-ENOMEM);
-
-	idr_preload(GFP_KERNEL);
-	spin_lock(&ss->id_lock);
-	/* Don't use 0. allocates an ID of 1-65535 */
-	ret = idr_alloc(&ss->idr, newid, 1, CSS_ID_MAX + 1, GFP_NOWAIT);
-	spin_unlock(&ss->id_lock);
-	idr_preload_end();
-
-	/* Returns error when there are no free spaces for new ID.*/
-	if (ret < 0)
-		goto err_out;
-
-	newid->id = ret;
-	newid->depth = depth;
-	return newid;
-err_out:
-	kfree(newid);
-	return ERR_PTR(ret);
-
-}
-
-static int __init_or_module cgroup_init_idr(struct cgroup_subsys *ss,
-					    struct cgroup_subsys_state *rootcss)
-{
-	struct css_id *newid;
-
-	spin_lock_init(&ss->id_lock);
-	idr_init(&ss->idr);
-
-	newid = get_new_cssid(ss, 0);
-	if (IS_ERR(newid))
-		return PTR_ERR(newid);
-
-	newid->stack[0] = newid->id;
-	RCU_INIT_POINTER(newid->css, rootcss);
-	RCU_INIT_POINTER(rootcss->id, newid);
-	return 0;
-}
-
-static int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *parent,
-			struct cgroup *child)
-{
-	int subsys_id, i, depth = 0;
-	struct cgroup_subsys_state *parent_css, *child_css;
-	struct css_id *child_id, *parent_id;
-
-	subsys_id = ss->subsys_id;
-	parent_css = parent->subsys[subsys_id];
-	child_css = child->subsys[subsys_id];
-	parent_id = rcu_dereference_protected(parent_css->id, true);
-	depth = parent_id->depth + 1;
-
-	child_id = get_new_cssid(ss, depth);
-	if (IS_ERR(child_id))
-		return PTR_ERR(child_id);
-
-	for (i = 0; i < depth; i++)
-		child_id->stack[i] = parent_id->stack[i];
-	child_id->stack[depth] = child_id->id;
-	/*
-	 * child_id->css pointer will be set after this cgroup is available
-	 * see cgroup_populate_dir()
-	 */
-	rcu_assign_pointer(child_css->id, child_id);
-
-	return 0;
-}
-
-/**
- * css_lookup - lookup css by id
- * @ss: cgroup subsys to be looked into.
- * @id: the id
- *
- * Returns pointer to cgroup_subsys_state if there is valid one with id.
- * NULL if not. Should be called under rcu_read_lock()
- */
-struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id)
-{
-	struct css_id *cssid = NULL;
-
-	BUG_ON(!ss->use_id);
-	cssid = idr_find(&ss->idr, id);
-
-	if (unlikely(!cssid))
-		return NULL;
-
-	return rcu_dereference(cssid->css);
-}
-EXPORT_SYMBOL_GPL(css_lookup);
-
-/*
  * get corresponding css from file open on cgroupfs directory
  */
 struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id)
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
