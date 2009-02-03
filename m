Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0FFC45F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 04:05:50 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1395lK9020497
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Feb 2009 18:05:48 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E68045DD7B
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 18:05:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F166845DD78
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 18:05:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E5FFE1DB8040
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 18:05:46 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B6F31DB8042
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 18:05:46 +0900 (JST)
Date: Tue, 3 Feb 2009 18:04:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/6] cgroup: CSS ID support
Message-Id: <20090203180436.9780380d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090203180320.9f29aa76.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090203180320.9f29aa76.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Patch for Per-CSS(Cgroup Subsys State) ID and private hierarchy code.

This patch attaches unique ID to each css and provides following.

 - css_lookup(subsys, id)
   returns pointer to struct cgroup_subysys_state of id.
 - css_get_next(subsys, id, rootid, depth, foundid)
   returns the next css under "root" by scanning

When cgrou_subsys->use_id is set, an id for css is maintained.
The cgroup framework only parepares
	- css_id of root css for subsys
	- id is automatically attached at creation of css.
	- id is *not* freed automatically. Because the cgroup framework
	  don't know lifetime of cgroup_subsys_state.
	  free_css_id() function is provided. This must be called by subsys.

There are several reasons to develop this.
	- Saving space .... For example, memcg's swap_cgroup is array of
	  pointers to cgroup. But it is not necessary to be very fast.
	  By replacing pointers(8bytes per ent) to ID (2byes per ent), we can
	  reduce much amount of memory usage.

	- Scanning without lock.
	  CSS_ID provides "scan id under this ROOT" function. By this, scanning
	  css under root can be written without locks.
	  ex)
	  do {
		rcu_read_lock();
		next = cgroup_get_next(subsys, id, root, &found);
		/* check sanity of next here */
		css_tryget();
		rcu_read_unlock();
		id = found + 1
	 } while(...)

Characteristics: 
	- Each css has unique ID under subsys.
	- Lifetime of ID is controlled by subsys.
	- css ID contains "ID" and "Depth in hierarchy" and stack of hierarchy
	- Allowed ID is 1-65535, ID 0 is UNUSED ID.

Design Choices:
	- scan-by-ID v.s. scan-by-tree-walk.
	  As /proc's pid scan does, scan-by-ID is robust when scanning is done
	  by following kind of routine.
	  scan -> rest a while(release a lock) -> conitunue from interrupted
	  memcg's hierarchical reclaim does this.

	- When subsys->use_id is set, # of css in the system is limited to
	  65535. 

Changelog: (v7) -> (v8)
	- Update id->css pointer after cgroup is populated.

Changelog: (v6) -> (v7)
	- refcnt for CSS ID is removed. Subsys can do it by own logic.
	- New id allocation is done automatically.
	- fixed typos.
	- fixed limit check of ID.

Changelog: (v5) -> (v6)
 	- max depth is removed.
	- changed arguments to "scan"
Changelog: (v4) -> (v5)
	- Totally re-designed as per-css ID.
Changelog:(v3) -> (v4)
	- updated comments.
	- renamed hierarchy_code[] to stack[]
	- merged prepare_id routines.

Changelog (v2) -> (v3)
	- removed cgroup_id_getref().
	- added cgroup_id_tryget().

Changelog (v1) -> (v2):
	- Design change: show only ID(integer) to outside of cgroup.c
	- moved cgroup ID definition from include/ to kernel/cgroup.c
	- struct cgroup_id is freed by RCU.
	- changed interface from pointer to "int"
	- kill_sb() is handled. 
	- ID 0 as unused ID.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/cgroup.h |   50 ++++++++
 include/linux/idr.h    |    1 
 kernel/cgroup.c        |  289 ++++++++++++++++++++++++++++++++++++++++++++++++-
 lib/idr.c              |   46 +++++++
 4 files changed, 385 insertions(+), 1 deletion(-)

Index: mmotm-2.6.29-Feb02/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.29-Feb02.orig/include/linux/cgroup.h
+++ mmotm-2.6.29-Feb02/include/linux/cgroup.h
@@ -15,6 +15,7 @@
 #include <linux/cgroupstats.h>
 #include <linux/prio_heap.h>
 #include <linux/rwsem.h>
+#include <linux/idr.h>
 
 #ifdef CONFIG_CGROUPS
 
@@ -22,6 +23,7 @@ struct cgroupfs_root;
 struct cgroup_subsys;
 struct inode;
 struct cgroup;
+struct css_id;
 
 extern int cgroup_init_early(void);
 extern int cgroup_init(void);
@@ -63,6 +65,8 @@ struct cgroup_subsys_state {
 	atomic_t refcnt;
 
 	unsigned long flags;
+	/* ID for this css, if possible */
+	struct css_id *id;
 };
 
 /* bits in struct cgroup_subsys_state flags field */
@@ -373,6 +377,11 @@ struct cgroup_subsys {
 	int active;
 	int disabled;
 	int early_init;
+	/*
+	 * True if this subsys uses ID. ID is not available before cgroup_init()
+	 * (not available in early_init time.)
+	 */
+	bool use_id;
 #define MAX_CGROUP_TYPE_NAMELEN 32
 	const char *name;
 
@@ -394,6 +403,9 @@ struct cgroup_subsys {
 	 */
 	struct cgroupfs_root *root;
 	struct list_head sibling;
+	/* used when use_id == true */
+	struct idr idr;
+	spinlock_t id_lock;
 };
 
 #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
@@ -449,6 +461,44 @@ void cgroup_iter_end(struct cgroup *cgrp
 int cgroup_scan_tasks(struct cgroup_scanner *scan);
 int cgroup_attach_task(struct cgroup *, struct task_struct *);
 
+/*
+ * CSS ID is ID for cgroup_subsys_state structs under subsys. This only works
+ * if cgroup_subsys.use_id == true. It can be used for looking up and scanning.
+ * CSS ID is assigned at cgroup allocation (create) automatically
+ * and removed when subsys calls free_css_id() function. This is because
+ * the lifetime of cgroup_subsys_state is subsys's matter.
+ *
+ * Looking up and scanning function should be called under rcu_read_lock().
+ * Taking cgroup_mutex()/hierarchy_mutex() is not necessary for following calls.
+ * But the css returned by this routine can be "not populated yet" or "being
+ * destroyed". The caller should check css and cgroup's status.
+ */
+
+/*
+ * Typically Called at ->destroy(), or somewhere the subsys frees
+ * cgroup_subsys_state.
+ */
+void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css);
+
+/* Find a cgroup_subsys_state which has given ID */
+
+struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id);
+
+/*
+ * Get a cgroup whose id is greater than or equal to id under tree of root.
+ * Returning a cgroup_subsys_state or NULL.
+ */
+struct cgroup_subsys_state *css_get_next(struct cgroup_subsys *ss, int id,
+		struct cgroup_subsys_state *root, int *foundid);
+
+/* Returns true if root is ancestor of cg */
+bool css_is_ancestor(struct cgroup_subsys_state *cg,
+		     struct cgroup_subsys_state *root);
+
+/* Get id and depth of css */
+unsigned short css_id(struct cgroup_subsys_state *css);
+unsigned short css_depth(struct cgroup_subsys_state *css);
+
 #else /* !CONFIG_CGROUPS */
 
 static inline int cgroup_init_early(void) { return 0; }
Index: mmotm-2.6.29-Feb02/kernel/cgroup.c
===================================================================
--- mmotm-2.6.29-Feb02.orig/kernel/cgroup.c
+++ mmotm-2.6.29-Feb02/kernel/cgroup.c
@@ -94,7 +94,6 @@ struct cgroupfs_root {
 	char release_agent_path[PATH_MAX];
 };
 
-
 /*
  * The "rootnode" hierarchy is the "dummy hierarchy", reserved for the
  * subsystems that are otherwise unattached - it never has more than a
@@ -102,6 +101,39 @@ struct cgroupfs_root {
  */
 static struct cgroupfs_root rootnode;
 
+/*
+ * CSS ID -- ID per subsys's Cgroup Subsys State(CSS). used only when
+ * cgroup_subsys->use_id != 0.
+ */
+#define CSS_ID_MAX	(65535)
+struct css_id {
+	/*
+	 * The css to which this ID points. This pointer is set to valid value
+	 * after cgroup is populated. If cgroup is removed, this will be NULL.
+	 * This pointer is expected to be RCU-safe because destroy()
+	 * is called after synchronize_rcu(). But for safe use, css_is_removed()
+	 * css_tryget() should be used for avoiding race.
+	 */
+	struct cgroup_subsys_state *css;
+	/*
+	 * ID of this css.
+	 */
+	unsigned short id;
+	/*
+	 * Depth in hierarchy which this ID belongs to.
+	 */
+	unsigned short depth;
+	/*
+	 * ID is freed by RCU. (and lookup routine is RCU safe.)
+	 */
+	struct rcu_head rcu_head;
+	/*
+	 * Hierarchy of CSS ID belongs to.
+	 */
+	unsigned short stack[0]; /* Array of Length (depth+1) */
+};
+
+
 /* The list of hierarchy roots */
 
 static LIST_HEAD(roots);
@@ -185,6 +217,8 @@ struct cg_cgroup_link {
 static struct css_set init_css_set;
 static struct cg_cgroup_link init_css_set_link;
 
+static int cgroup_subsys_init_idr(struct cgroup_subsys *ss);
+
 /* css_set_lock protects the list of css_set objects, and the
  * chain of tasks off each css_set.  Nests outside task->alloc_lock
  * due to cgroup_iter_start() */
@@ -567,6 +601,9 @@ static struct backing_dev_info cgroup_ba
 	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
 };
 
+static int alloc_css_id(struct cgroup_subsys *ss,
+			struct cgroup *parent, struct cgroup *child);
+
 static struct inode *cgroup_new_inode(mode_t mode, struct super_block *sb)
 {
 	struct inode *inode = new_inode(sb);
@@ -2326,6 +2363,17 @@ static int cgroup_populate_dir(struct cg
 		if (ss->populate && (err = ss->populate(ss, cgrp)) < 0)
 			return err;
 	}
+	/* This cgroup is ready now */
+	for_each_subsys(cgrp->root, ss) {
+		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+		/*
+		 * Update id->css pointer and make this css visible from
+		 * CSS ID functions. This pointer will be dereferened
+		 * from RCU-read-side without locks.
+		 */
+		if (css->id)
+			rcu_assign_pointer(css->id->css, css);
+	}
 
 	return 0;
 }
@@ -2337,6 +2385,7 @@ static void init_cgroup_css(struct cgrou
 	css->cgroup = cgrp;
 	atomic_set(&css->refcnt, 1);
 	css->flags = 0;
+	css->id = NULL;
 	if (cgrp == dummytop)
 		set_bit(CSS_ROOT, &css->flags);
 	BUG_ON(cgrp->subsys[ss->subsys_id]);
@@ -2412,6 +2461,10 @@ static long cgroup_create(struct cgroup 
 			goto err_destroy;
 		}
 		init_cgroup_css(css, ss, cgrp);
+		if (ss->use_id)
+			if (alloc_css_id(ss, parent, cgrp))
+				goto err_destroy;
+		/* At error, ->destroy() callback has to free assigned ID. */
 	}
 
 	cgroup_lock_hierarchy(root);
@@ -2706,6 +2759,8 @@ int __init cgroup_init(void)
 		struct cgroup_subsys *ss = subsys[i];
 		if (!ss->early_init)
 			cgroup_init_subsys(ss);
+		if (ss->use_id)
+			cgroup_subsys_init_idr(ss);
 	}
 
 	/* Add init_css_set to the hash table */
@@ -3240,3 +3295,235 @@ static int __init cgroup_disable(char *s
 	return 1;
 }
 __setup("cgroup_disable=", cgroup_disable);
+
+/*
+ * Functons for CSS ID.
+ */
+
+/*
+ *To get ID other than 0, this should be called when !cgroup_is_removed().
+ */
+unsigned short css_id(struct cgroup_subsys_state *css)
+{
+	struct css_id *cssid = rcu_dereference(css->id);
+
+	if (cssid)
+		return cssid->id;
+	return 0;
+}
+
+unsigned short css_depth(struct cgroup_subsys_state *css)
+{
+	struct css_id *cssid = rcu_dereference(css->id);
+
+	if (cssid)
+		return cssid->depth;
+	return 0;
+}
+
+bool css_is_ancestor(struct cgroup_subsys_state *child,
+		    struct cgroup_subsys_state *root)
+{
+	struct css_id *child_id = rcu_dereference(child->id);
+	struct css_id *root_id = rcu_dereference(root->id);
+
+	if (!child_id || !root_id || (child_id->depth < root_id->depth))
+		return false;
+	return child_id->stack[root_id->depth] == root_id->id;
+}
+
+static void __free_css_id_cb(struct rcu_head *head)
+{
+	struct css_id *id;
+
+	id = container_of(head, struct css_id, rcu_head);
+	kfree(id);
+}
+
+void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css)
+{
+	struct css_id *id = css->id;
+	/* When this is called before css_id initialization, id can be NULL */
+	if (!id)
+		return;
+
+	BUG_ON(!ss->use_id);
+
+	rcu_assign_pointer(id->css, NULL);
+	rcu_assign_pointer(css->id, NULL);
+	spin_lock(&ss->id_lock);
+	idr_remove(&ss->idr, id->id);
+	spin_unlock(&ss->id_lock);
+	call_rcu(&id->rcu_head, __free_css_id_cb);
+}
+
+/*
+ * This is called by init or create(). Then, calls to this function are
+ * always serialized (By cgroup_mutex() at create()).
+ */
+
+static struct css_id *get_new_cssid(struct cgroup_subsys *ss, int depth)
+{
+	struct css_id *newid;
+	int myid, error, size;
+
+	BUG_ON(!ss->use_id);
+
+	size = sizeof(*newid) + sizeof(unsigned short) * (depth + 1);
+	newid = kzalloc(size, GFP_KERNEL);
+	if (!newid)
+		return ERR_PTR(-ENOMEM);
+	/* get id */
+	if (unlikely(!idr_pre_get(&ss->idr, GFP_KERNEL))) {
+		error = -ENOMEM;
+		goto err_out;
+	}
+	spin_lock(&ss->id_lock);
+	/* Don't use 0. allocates an ID of 1-65535 */
+	error = idr_get_new_above(&ss->idr, newid, 1, &myid);
+	spin_unlock(&ss->id_lock);
+
+	/* Returns error when there are no free spaces for new ID.*/
+	if (error) {
+		error = -ENOSPC;
+		goto err_out;
+	}
+	if (myid > CSS_ID_MAX)
+		goto remove_idr;
+
+	newid->id = myid;
+	newid->depth = depth;
+	return newid;
+remove_idr:
+	error = -ENOSPC;
+	spin_lock(&ss->id_lock);
+	idr_remove(&ss->idr, myid);
+	spin_unlock(&ss->id_lock);
+err_out:
+	kfree(newid);
+	return ERR_PTR(error);
+
+}
+
+static int __init cgroup_subsys_init_idr(struct cgroup_subsys *ss)
+{
+	struct css_id *newid;
+	struct cgroup_subsys_state *rootcss;
+
+	spin_lock_init(&ss->id_lock);
+	idr_init(&ss->idr);
+
+	rootcss = init_css_set.subsys[ss->subsys_id];
+	newid = get_new_cssid(ss, 0);
+	if (IS_ERR(newid))
+		return PTR_ERR(newid);
+
+	newid->stack[0] = newid->id;
+	newid->css = rootcss;
+	rootcss->id = newid;
+	return 0;
+}
+
+static int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *parent,
+			struct cgroup *child)
+{
+	int subsys_id, i, depth = 0;
+	struct cgroup_subsys_state *parent_css, *child_css;
+	struct css_id *child_id, *parent_id = NULL;
+
+	subsys_id = ss->subsys_id;
+	parent_css = parent->subsys[subsys_id];
+	child_css = child->subsys[subsys_id];
+	depth = css_depth(parent_css) + 1;
+	parent_id = parent_css->id;
+
+	child_id = get_new_cssid(ss, depth);
+	if (IS_ERR(child_id))
+		return PTR_ERR(child_id);
+
+	for (i = 0; i < depth; i++)
+		child_id->stack[i] = parent_id->stack[i];
+	child_id->stack[depth] = child_id->id;
+	/*
+	 * child_id->css pointer will be set after this cgroup is available
+	 * see cgroup_populate_dir()
+	 */
+	rcu_assign_pointer(child_css->id, child_id);
+
+	return 0;
+}
+
+/**
+ * css_lookup - lookup css by id
+ * @ss: cgroup subsys to be looked into.
+ * @id: the id
+ *
+ * Returns pointer to cgroup_subsys_state if there is valid one with id.
+ * NULL if not. Should be called under rcu_read_lock()
+ */
+struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id)
+{
+	struct css_id *cssid = NULL;
+
+	BUG_ON(!ss->use_id);
+	cssid = idr_find(&ss->idr, id);
+
+	if (unlikely(!cssid))
+		return NULL;
+
+	return rcu_dereference(cssid->css);
+}
+
+/**
+ * css_get_next - lookup next cgroup under specified hierarchy.
+ * @ss: pointer to subsystem
+ * @id: current position of iteration.
+ * @root: pointer to css. search tree under this.
+ * @foundid: position of found object.
+ *
+ * Search next css under the specified hierarchy of rootid. Calling under
+ * rcu_read_lock() is necessary. Returns NULL if it reaches the end.
+ */
+struct cgroup_subsys_state *
+css_get_next(struct cgroup_subsys *ss, int id,
+	     struct cgroup_subsys_state *root, int *foundid)
+{
+	struct cgroup_subsys_state *ret = NULL;
+	struct css_id *tmp;
+	int tmpid;
+	int rootid = css_id(root);
+	int depth = css_depth(root);
+
+	if (!rootid)
+		return NULL;
+
+	BUG_ON(!ss->use_id);
+	rcu_read_lock();
+	/* fill start point for scan */
+	tmpid = id;
+	while (1) {
+		/*
+		 * scan next entry from bitmap(tree), tmpid is updated after
+		 * idr_get_next().
+		 */
+		spin_lock(&ss->id_lock);
+		tmp = idr_get_next(&ss->idr, &tmpid);
+		spin_unlock(&ss->id_lock);
+
+		if (!tmp)
+			break;
+		if (tmp->depth >= depth && tmp->stack[depth] == rootid) {
+			ret = rcu_dereference(tmp->css);
+			if (ret) {
+				*foundid = tmpid;
+				break;
+			}
+		}
+		/* continue to scan from next id */
+		tmpid = tmpid + 1;
+	}
+
+	rcu_read_unlock();
+	return ret;
+}
+
Index: mmotm-2.6.29-Feb02/include/linux/idr.h
===================================================================
--- mmotm-2.6.29-Feb02.orig/include/linux/idr.h
+++ mmotm-2.6.29-Feb02/include/linux/idr.h
@@ -106,6 +106,7 @@ int idr_get_new(struct idr *idp, void *p
 int idr_get_new_above(struct idr *idp, void *ptr, int starting_id, int *id);
 int idr_for_each(struct idr *idp,
 		 int (*fn)(int id, void *p, void *data), void *data);
+void *idr_get_next(struct idr *idp, int *nextid);
 void *idr_replace(struct idr *idp, void *ptr, int id);
 void idr_remove(struct idr *idp, int id);
 void idr_remove_all(struct idr *idp);
Index: mmotm-2.6.29-Feb02/lib/idr.c
===================================================================
--- mmotm-2.6.29-Feb02.orig/lib/idr.c
+++ mmotm-2.6.29-Feb02/lib/idr.c
@@ -579,6 +579,52 @@ int idr_for_each(struct idr *idp,
 EXPORT_SYMBOL(idr_for_each);
 
 /**
+ * idr_get_next - lookup next object of id to given id.
+ * @idp: idr handle
+ * @id:  pointer to lookup key
+ *
+ * Returns pointer to registered object with id, which is next number to
+ * given id.
+ */
+
+void *idr_get_next(struct idr *idp, int *nextidp)
+{
+	struct idr_layer *p, *pa[MAX_LEVEL];
+	struct idr_layer **paa = &pa[0];
+	int id = *nextidp;
+	int n, max;
+
+	/* find first ent */
+	n = idp->layers * IDR_BITS;
+	max = 1 << n;
+	p = rcu_dereference(idp->top);
+	if (!p)
+		return NULL;
+
+	while (id < max) {
+		while (n > 0 && p) {
+			n -= IDR_BITS;
+			*paa++ = p;
+			p = rcu_dereference(p->ary[(id >> n) & IDR_MASK]);
+		}
+
+		if (p) {
+			*nextidp = id;
+			return p;
+		}
+
+		id += 1 << n;
+		while (n < fls(id)) {
+			n += IDR_BITS;
+			p = *--paa;
+		}
+	}
+	return NULL;
+}
+
+
+
+/**
  * idr_replace - replace pointer for given id
  * @idp: idr handle
  * @ptr: pointer you want associated with the id

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
