Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBBCiLHs016271
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Dec 2008 21:44:21 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AA8845DE4F
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 21:44:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 21DE345DD72
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 21:44:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 01E181DB803A
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 21:44:21 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 897241DB8037
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 21:44:20 +0900 (JST)
Date: Thu, 11 Dec 2008 21:43:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
Message-Id: <20081211214327.5936a90a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830812101624i5ba31d04o38d4b39f2d4857d6@mail.gmail.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
	<20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830812100240g5e549a5cqe29cbea736788865@mail.gmail.com>
	<29741.10.75.179.61.1228908581.squirrel@webmail-b.css.fujitsu.com>
	<6599ad830812101035v33dbc6cfh57aa5510f6d65d54@mail.gmail.com>
	<6599ad830812101100v4dc7f124jded0d767b92e541a@mail.gmail.com>
	<20081211092150.b62f8c20.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830812101624i5ba31d04o38d4b39f2d4857d6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Dec 2008 16:24:44 -0800
Paul Menage <menage@google.com> wrote:

> On Wed, Dec 10, 2008 at 4:21 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > If per-css, looking up function will be
> > ==
> > struct cgroup_subsys_state *cgroup_css_lookup(subsys_id, id)
> > ==
> > Do you mean this ?
> 
> Yes, plausibly. And we can presumably have a separate idr per subsystem.
> 

this is my temporal patch. this look and interface is ok ?
(still under test)
==

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Patch for Per-CSS ID and private hierarchy code.

This patch tries to assign a ID to each css. Attach unique ID to each
css and provides following functions.

 - css_lookup(subsys, id)
   returns struct cgroup of id.
 - css_get_next(subsys, id, rootid, depth, foundid)
   returns the next cgroup under "root" by scanning bitmap (not by tree-walk)

When cgrou_subsys->use_id is set, id field for css is maintained.
kernel/cgroup.c just parepare
	- css_id of root css for subsys
	- alloc/free id functions.
So, each subsys should allocate ID in attach() callback if necessary.

There is several reasons to develop this.

	- While trying to implement hierarchy in memory cgroup, we have to
	  implement "walk under hierarchy" code.
	  Now it's consists of cgroup_lock and tree up-down code. Because
	  Because memory cgroup have to do hierarchy walk in other places,
	  intelligent processing, we'll reuse the "walk" code.
	  But taking "cgroup_lock" in walking tree can cause deadlocks.
	  Easier way is helpful.

 	- SwapCgroup uses array of "pointer" to record the owner of swaps.
	  By ID, we can reduce this to "short" or "int". This means ID is 
	  useful for reducing space consumption by pointer if the access cost
	  is not problem.
	  (I hear bio-cgroup will use the same kind of...)

Example) OOM-Killer under hierarchy.
	do {
		rcu_read_lock();
		next = cgroup_get_next(id, root, nextid);
		/* check sanity of next here */
		css_tryget();
		rcu_read_unlock();
		if (!next)
			break;
		cgroup_scan_tasks(select_bad_process?);
		/* record score here...*/
	} while (1);


Characteristics: 
	- Each css should have unique ID under subsys.
	- css ID contains "ID" and "Depth in hierarchy" and stack of hierarchy
	- Allowed ID is 1-65535, ID 0 is UNUSED ID.
	- 

Design Choices:
	- scan-by-ID v.s. scan-by-tree-walk.
	  As /proc's pid scan does, scan-by-ID is robust when scanning is done
	  by following kind of routine.
	  scan -> rest a while(release a lock) -> conitunue from interrupted
	  memcg's hierarchical reclaim does this.

	- When subsys->use_id is set, # of css in the system is limited to
	  65534. 
	- max depth of hierarchy is also limited.

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
 include/linux/cgroup.h |   51 +++++++++
 include/linux/idr.h    |    1 
 kernel/cgroup.c        |  251 ++++++++++++++++++++++++++++++++++++++++++++++++-
 lib/idr.c              |   46 ++++++++
 4 files changed, 347 insertions(+), 2 deletions(-)

Index: mmotm-2.6.28-Dec10/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.28-Dec10.orig/include/linux/cgroup.h
+++ mmotm-2.6.28-Dec10/include/linux/cgroup.h
@@ -15,13 +15,14 @@
 #include <linux/cgroupstats.h>
 #include <linux/prio_heap.h>
 #include <linux/rwsem.h>
-
+#include <linux/idr.h>
 #ifdef CONFIG_CGROUPS
 
 struct cgroupfs_root;
 struct cgroup_subsys;
 struct inode;
 struct cgroup;
+struct css_id;
 
 extern int cgroup_init_early(void);
 extern int cgroup_init(void);
@@ -59,6 +60,8 @@ struct cgroup_subsys_state {
 	atomic_t refcnt;
 
 	unsigned long flags;
+	/* ID for this css, if possible */
+	struct css_id *id;
 };
 
 /* bits in struct cgroup_subsys_state flags field */
@@ -360,6 +363,13 @@ struct cgroup_subsys {
 	int active;
 	int disabled;
 	int early_init;
+	/*
+	 * set 1 if subsys uses ID. ID is not available before cgroup_init()
+	 * (not available in early_init time.
+	 */
+	int use_id;
+	/* this defines max depth of hierarchy of this subsys if using ID. */
+	int max_depth;
 #define MAX_CGROUP_TYPE_NAMELEN 32
 	const char *name;
 
@@ -373,6 +383,9 @@ struct cgroup_subsys {
 	/* Protected by this->hierarchy_mutex and cgroup_lock() */
 	struct cgroupfs_root *root;
 	struct list_head sibling;
+	/* used when use_id == 1 */
+	struct idr idr;
+	spinlock_t id_lock;
 };
 
 #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
@@ -426,6 +439,42 @@ void cgroup_iter_end(struct cgroup *cgrp
 int cgroup_scan_tasks(struct cgroup_scanner *scan);
 int cgroup_attach_task(struct cgroup *, struct task_struct *);
 
+/*
+ * CSS ID is a ID for all css struct under subsys. Only works when
+ * cgroup_subsys->use_id != 0. It can be used for look up and scanning
+ * Cgroup ID is assined at cgroup allocation (create) and removed
+ * when refcnt to ID goes down to 0. Refcnt is inremented when subsys want to
+ * avoid reuse of ID for persistent objects. In usual, refcnt to ID will be 0
+ * when cgroup is removed.
+ * This look-up and scan function should be called under rcu_read_lock().
+ * cgroup_lock() is not necessary.
+ *
+ * Note: At using ID, max depth of the hierarchy is determined by
+ * cgroup_subsys->max_id_depth.
+ */
+
+/* called at create() */
+int css_id_alloc(struct cgroup_subsys *ss, struct cgroup_subsys_state *parent,
+		 struct cgroup_subsys_state *css);
+/* called at destroy(), or somewhere we can free ID */
+void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css);
+
+/* Find a cgroup which the "ID" is attached. */
+struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id);
+/*
+ * Get next cgroup under tree. Returning a cgroup which has equal or greater
+ * ID than "id" in argument.
+ */
+struct cgroup_subsys_state *css_get_next(struct cgroup_subsys *ss,
+		int id, int rootid, int depth, int *foundid);
+
+/* get id and depth of css */
+unsigned short css_id(struct cgroup_subsys_state *css);
+unsigned short css_depth(struct cgroup_subsys_state *css);
+/* returns non-zero if root is ancestor of cg */
+int css_is_ancestor(struct cgroup_subsys_state *cg,
+		struct cgroup_subsys_state *root);
+
 #else /* !CONFIG_CGROUPS */
 
 static inline int cgroup_init_early(void) { return 0; }
Index: mmotm-2.6.28-Dec10/kernel/cgroup.c
===================================================================
--- mmotm-2.6.28-Dec10.orig/kernel/cgroup.c
+++ mmotm-2.6.28-Dec10/kernel/cgroup.c
@@ -46,7 +46,7 @@
 #include <linux/cgroupstats.h>
 #include <linux/hash.h>
 #include <linux/namei.h>
-
+#include <linux/idr.h>
 #include <asm/atomic.h>
 
 static DEFINE_MUTEX(cgroup_mutex);
@@ -185,6 +185,8 @@ struct cg_cgroup_link {
 static struct css_set init_css_set;
 static struct cg_cgroup_link init_css_set_link;
 
+static int cgroup_subsys_init_idr(struct cgroup_subsys *ss);
+
 /* css_set_lock protects the list of css_set objects, and the
  * chain of tasks off each css_set.  Nests outside task->alloc_lock
  * due to cgroup_iter_start() */
@@ -2684,6 +2686,8 @@ int __init cgroup_init(void)
 		struct cgroup_subsys *ss = subsys[i];
 		if (!ss->early_init)
 			cgroup_init_subsys(ss);
+		if (ss->use_id)
+			cgroup_subsys_init_idr(ss);
 	}
 
 	/* Add init_css_set to the hash table */
@@ -3215,3 +3219,248 @@ static int __init cgroup_disable(char *s
 	return 1;
 }
 __setup("cgroup_disable=", cgroup_disable);
+
+/*
+ * CSS ID
+ */
+struct css_id {
+	/*
+	 * The cgroup to whiech this ID points. If cgroup is removed,
+	 * this will point to NULL.
+	 */
+	struct cgroup_subsys_state *css;
+	/*
+	 * ID of this css.
+	 */
+	unsigned short  id;
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
+	unsigned short  stack[0];
+};
+
+/*
+ * To get ID other than 0, this should be called when !cgroup_is_removed().
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
+int css_is_ancestor(struct cgroup_subsys_state *css,
+		    struct cgroup_subsys_state *root)
+{
+	struct css_id *id = css->id;
+	struct css_id *ans = root->id;
+
+	if (!id || !ans)
+		return 0;
+	return id->stack[ans->depth] == ans->id;
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
+
+static int __get_and_prepare_newid(struct cgroup_subsys *ss,
+			       struct css_id **ret)
+{
+	struct css_id *newid;
+	int myid, error, size;
+
+	BUG_ON(!ss->use_id);
+
+	size = sizeof(*newid) + sizeof(unsigned short) * ss->max_depth;
+	newid = kzalloc(size, GFP_KERNEL);
+	if (!newid)
+		return -ENOMEM;
+	/* get id */
+	if (unlikely(!idr_pre_get(&ss->idr, GFP_KERNEL))) {
+		error = -ENOMEM;
+		goto err_out;
+	}
+	spin_lock(&ss->id_lock);
+	/* Don't use 0 */
+	error = idr_get_new_above(&ss->idr, newid, 1, &myid);
+	spin_unlock(&ss->id_lock);
+
+	/* Returns error when there are no free spaces for new ID.*/
+	if (error) {
+		error = -ENOSPC;
+		goto err_out;
+	}
+
+	newid->id = myid;
+	*ret = newid;
+	return 0;
+err_out:
+	kfree(newid);
+	return error;
+
+}
+
+
+static int __init cgroup_subsys_init_idr(struct cgroup_subsys *ss)
+{
+	struct css_id *newid;
+	struct cgroup_subsys_state *rootcss;
+	int err = -ENOMEM;
+
+	spin_lock_init(&ss->id_lock);
+	idr_init(&ss->idr);
+
+	rootcss = init_css_set.subsys[ss->subsys_id];
+	err = __get_and_prepare_newid(ss, &newid);
+	if (err)
+		return err;
+
+	newid->depth = 0;
+	newid->stack[0] = newid->id;
+	newid->css = rootcss;
+	rootcss->id = newid;
+	return 0;
+}
+
+int css_id_alloc(struct cgroup_subsys *ss,
+		    struct cgroup_subsys_state *parent,
+		    struct cgroup_subsys_state *css)
+{
+	int i, depth = 0;
+	struct css_id *cssid, *parent_id = NULL;
+	int error;
+
+	if (parent) {
+		parent_id = parent->id;
+		depth = parent_id->depth + 1;
+	}
+
+	if (depth >= ss->max_depth)
+		return -ENOSPC;
+
+	error = __get_and_prepare_newid(ss, &cssid);
+	if (error)
+		return error;
+
+	for (i = 0; i < depth; i++)
+		cssid->stack[i] = parent_id->stack[i];
+	cssid->stack[depth] = cssid->id;
+	cssid->depth = depth;
+
+	rcu_assign_pointer(cssid->css, css);
+	rcu_assign_pointer(css->id, cssid);
+
+	return 0;
+}
+
+/**
+ * css_lookup - lookup css by id
+ * @id: the id of cgroup to be looked up
+ *
+ * Returns pointer to css if there is valid css with id, NULL if not.
+ * Should be called under rcu_read_lock()
+ */
+
+struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id)
+{
+	struct cgroup_subsys_state *css = NULL;
+	struct css_id *cssid = NULL;
+
+	BUG_ON(!ss->use_id);
+	rcu_read_lock();
+	cssid = idr_find(&ss->idr, id);
+
+	if (unlikely(!cssid))
+		goto out;
+
+	css = rcu_dereference(cssid->css);
+out:
+	rcu_read_unlock();
+	return css;
+}
+
+/**
+ * css_get_next - lookup next cgroup under specified hierarchy.
+ * @ss: pointer to subsystem
+ * @id: current position of iteration.
+ * @rootid: search tree under this.
+ * @depth: depth of root id.
+ * @foundid: position of found object.
+ *
+ * Search next css under the specified hierarchy of rootid. Calling under
+ * rcu_read_lock() is necessary. Returns NULL if it reaches the end.
+ */
+struct cgroup_subsys_state *
+css_get_next(struct cgroup_subsys *ss,
+	     int id, int rootid, int depth, int *foundid)
+{
+	struct cgroup_subsys_state *ret = NULL;
+	struct css_id *tmp;
+	int tmpid;
+
+	BUG_ON(!ss->use_id);
+	rcu_read_lock();
+	tmpid = id;
+	while (1) {
+		/* scan next entry from bitmap(tree) */
+		spin_lock(&ss->id_lock);
+		tmp = idr_get_next(&ss->idr, &tmpid);
+		spin_unlock(&ss->id_lock);
+
+		if (!tmp) {
+			ret = NULL;
+			break;
+		}
+		if (tmp->stack[depth] == rootid) {
+			ret = rcu_dereference(tmp->css);
+			/* Sanity check and check hierarchy */
+			if (ret && !css_is_removed(ret))
+				break;
+		}
+		tmpid = tmpid + 1;
+	}
+
+	rcu_read_unlock();
+	*foundid = tmpid;
+	return ret;
+}
+
Index: mmotm-2.6.28-Dec10/include/linux/idr.h
===================================================================
--- mmotm-2.6.28-Dec10.orig/include/linux/idr.h
+++ mmotm-2.6.28-Dec10/include/linux/idr.h
@@ -106,6 +106,7 @@ int idr_get_new(struct idr *idp, void *p
 int idr_get_new_above(struct idr *idp, void *ptr, int starting_id, int *id);
 int idr_for_each(struct idr *idp,
 		 int (*fn)(int id, void *p, void *data), void *data);
+void *idr_get_next(struct idr *idp, int *nextid);
 void *idr_replace(struct idr *idp, void *ptr, int id);
 void idr_remove(struct idr *idp, int id);
 void idr_remove_all(struct idr *idp);
Index: mmotm-2.6.28-Dec10/lib/idr.c
===================================================================
--- mmotm-2.6.28-Dec10.orig/lib/idr.c
+++ mmotm-2.6.28-Dec10/lib/idr.c
@@ -573,6 +573,52 @@ int idr_for_each(struct idr *idp,
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
