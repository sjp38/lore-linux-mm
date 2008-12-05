Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB58UpXs016187
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Dec 2008 17:30:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B9C3045DE4F
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:30:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CAF645DE4E
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:30:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 85D641DB803C
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:30:51 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F34B1DB8037
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:30:51 +0900 (JST)
Date: Fri, 5 Dec 2008 17:29:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/4] cgroup ID
Message-Id: <20081205172959.8285271f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081205172642.565661b1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081205172642.565661b1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>


From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Patch for Cgroup ID and hierarchy code.

This patch tries to assign a ID to each cgroup. Attach unique ID to each
cgroup and provides following functions.

 - cgroup_lookup(id)
   returns struct cgroup of id.
 - cgroup_get_next(id, rootid, depth, foundid)
   returns the next cgroup under "root" by scanning bitmap (not by tree-walk)
 - cgroup_id_put/getref()
   used when subsystem want to prevent reuse of ID.

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


Characteristics: 
	- Each cgroup get new ID when created.
	- cgroup ID contains "ID" and "Depth in tree" and hierarchy code.
	- hierarchy code is array of IDs of ancestors.
	- ID 0 is UNUSED ID.

Consideration:
	- I'd like to use  "short" to cgroup_id for saving space...
	- MAX_DEPTH is small ? (making this depend on boot option is easy.)
TODO:
	- Documentation.

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
 include/linux/cgroup.h |   24 ++++
 include/linux/idr.h    |    1 
 kernel/cgroup.c        |  285 ++++++++++++++++++++++++++++++++++++++++++++++++-
 lib/idr.c              |   46 +++++++
 4 files changed, 352 insertions(+), 4 deletions(-)

Index: mmotm-2.6.28-Dec03/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.28-Dec03.orig/include/linux/cgroup.h
+++ mmotm-2.6.28-Dec03/include/linux/cgroup.h
@@ -22,6 +22,7 @@ struct cgroupfs_root;
 struct cgroup_subsys;
 struct inode;
 struct cgroup;
+struct cgroup_id;
 
 extern int cgroup_init_early(void);
 extern int cgroup_init(void);
@@ -56,6 +57,12 @@ struct cgroup_subsys_state {
 	unsigned long flags;
 };
 
+/*
+ * Cgroup ID for *internal* identification and lookup. For user-land,"path"
+ * of cgroup works well.
+ */
+#define MAX_CGROUP_DEPTH	(10)
+
 /* bits in struct cgroup_subsys_state flags field */
 enum {
 	CSS_ROOT, /* This CSS is the root of the subsystem */
@@ -172,6 +179,8 @@ struct cgroup {
 	int pids_length;
 	/* for css_get/put */
 	atomic_t css_refcnt;
+	/* for cgroup ID */
+	struct cgroup_id	*id;
 };
 
 /* A css_set is a structure holding pointers to a set of
@@ -420,6 +429,21 @@ void cgroup_iter_end(struct cgroup *cgrp
 int cgroup_scan_tasks(struct cgroup_scanner *scan);
 int cgroup_attach_task(struct cgroup *, struct task_struct *);
 
+/*
+ * For supporting cgroup lookup and hierarchy management.
+ */
+/* An interface for usual lookup */
+struct cgroup *cgroup_lookup(int id);
+/* get next cgroup under tree (for scan) */
+struct cgroup *
+cgroup_get_next(int id, int rootid, int depth, int *foundid);
+/* get id and depth of cgroup */
+int cgroup_id(struct cgroup *cgroup);
+int cgroup_depth(struct cgroup *cgroup);
+/* For delayed freeing of IDs */
+int cgroup_id_tryget(int id);
+void cgroup_id_put(int id);
+
 #else /* !CONFIG_CGROUPS */
 
 static inline int cgroup_init_early(void) { return 0; }
Index: mmotm-2.6.28-Dec03/kernel/cgroup.c
===================================================================
--- mmotm-2.6.28-Dec03.orig/kernel/cgroup.c
+++ mmotm-2.6.28-Dec03/kernel/cgroup.c
@@ -46,7 +46,7 @@
 #include <linux/cgroupstats.h>
 #include <linux/hash.h>
 #include <linux/namei.h>
-
+#include <linux/idr.h>
 #include <asm/atomic.h>
 
 static DEFINE_MUTEX(cgroup_mutex);
@@ -547,6 +547,266 @@ void cgroup_unlock(void)
 }
 
 /*
+ * CGROUP ID
+ */
+struct cgroup_id {
+	struct cgroup *myself;
+	unsigned int  id;
+	unsigned int  depth;
+	atomic_t      refcnt;
+	struct rcu_head rcu_head;
+	unsigned int  hierarchy_code[MAX_CGROUP_DEPTH];
+};
+
+void free_cgroupid_cb(struct rcu_head *head)
+{
+	struct cgroup_id *id;
+
+	id = container_of(head, struct cgroup_id, rcu_head);
+	kfree(id);
+}
+
+void free_cgroupid(struct cgroup_id *id)
+{
+	call_rcu(&id->rcu_head, free_cgroupid_cb);
+}
+
+/*
+ * Cgroup ID and lookup functions.
+ * cgid->myself pointer is safe under rcu_read_lock() because d_put() of
+ * cgroup, which finally frees cgroup pointer, uses rcu_synchronize().
+ */
+static DEFINE_IDR(cgroup_idr);
+DEFINE_SPINLOCK(cgroup_idr_lock);
+
+static int cgrouproot_setup_idr(struct cgroupfs_root *root)
+{
+	struct cgroup_id *newid;
+	int err = -ENOMEM;
+	int myid;
+
+	newid = kzalloc(sizeof(*newid), GFP_KERNEL);
+	if (!newid)
+		goto out;
+	if (!idr_pre_get(&cgroup_idr, GFP_KERNEL))
+		goto free_out;
+
+	spin_lock_irq(&cgroup_idr_lock);
+	err = idr_get_new_above(&cgroup_idr, newid, 1, &myid);
+	spin_unlock_irq(&cgroup_idr_lock);
+
+	/* This one is new idr....*/
+	BUG_ON(err);
+	newid->id = myid;
+	newid->depth = 0;
+	newid->hierarchy_code[0] = myid;
+	atomic_set(&newid->refcnt, 1);
+	rcu_assign_pointer(newid->myself, &root->top_cgroup);
+	root->top_cgroup.id = newid;
+	return 0;
+
+free_out:
+	kfree(newid);
+out:
+	return err;
+}
+
+/*
+ * should be called while "cgrp" is valid.
+ */
+int cgroup_id(struct cgroup *cgrp)
+{
+	struct cgroup_id *cgid = rcu_dereference(cgrp->id);
+
+	if (cgid)
+		return cgid->id;
+	return 0;
+}
+
+int cgroup_depth(struct cgroup *cgrp)
+{
+	struct cgroup_id *cgid = rcu_dereference(cgrp->id);
+
+	if (cgid)
+		return cgid->depth;
+	return 0;
+}
+
+static int cgroup_prepare_id(struct cgroup *parent, struct cgroup_id **id)
+{
+	struct cgroup_id *newid;
+	int myid, error;
+
+	/* check depth */
+	if (parent->id->depth + 1 >= MAX_CGROUP_DEPTH)
+		return -ENOSPC;
+	newid = kzalloc(sizeof(*newid), GFP_KERNEL);
+	if (!newid)
+		return -ENOMEM;
+	/* get id */
+	if (unlikely(!idr_pre_get(&cgroup_idr, GFP_KERNEL))) {
+		error = -ENOMEM;
+		goto err_out;
+	}
+	spin_lock_irq(&cgroup_idr_lock);
+	/* Don't use 0 */
+	error = idr_get_new_above(&cgroup_idr, newid, 1, &myid);
+	spin_unlock_irq(&cgroup_idr_lock);
+	if (error)
+		goto err_out;
+
+	newid->id = myid;
+	atomic_set(&newid->refcnt, 1);
+	*id = newid;
+	return 0;
+err_out:
+	kfree(newid);
+	return error;
+}
+
+
+static void cgroup_id_attach(struct cgroup_id *cgid,
+			     struct cgroup *cg, struct cgroup *parent)
+{
+	struct cgroup_id *parent_id = rcu_dereference(parent->id);
+	int i;
+
+	cgid->depth = parent_id->depth + 1;
+	/* Inherit hierarchy code from parent */
+	for (i = 0; i < cgid->depth; i++) {
+		cgid->hierarchy_code[i] =
+			parent_id->hierarchy_code[i];
+		cgid->hierarchy_code[cgid->depth] = cgid->id;
+	}
+	rcu_assign_pointer(cgid->myself, cg);
+	rcu_assign_pointer(cg->id, cgid);
+
+	return;
+}
+
+void cgroup_id_put(int id)
+{
+	struct cgroup_id *cgid;
+	unsigned long flags;
+
+	rcu_read_lock();
+	cgid = idr_find(&cgroup_idr, id);
+	BUG_ON(!cgid);
+	if (atomic_dec_and_test(&cgid->refcnt)) {
+		spin_lock_irqsave(&cgroup_idr_lock, flags);
+		idr_remove(&cgroup_idr, cgid->id);
+		spin_unlock_irq(&cgroup_idr_lock);
+		free_cgroupid(cgid);
+	}
+	rcu_read_unlock();
+}
+
+static void cgroup_id_detach(struct cgroup *cg)
+{
+	struct cgroup_id *id = rcu_dereference(cg->id);
+
+	rcu_assign_pointer(id->myself, NULL);
+	cgroup_id_put(id->id);
+	rcu_assign_pointer(cg->id, NULL);
+}
+/**
+ * cgroup_id_tryget() -- try to get refcnt of ID.
+ * @id: the ID to be kept for a while.
+ *
+ * Increment refcnt of ID and prevent reuse. Useful for subsys which remember
+ * cgroup by ID rather than pointer to struct cgroup (or subsys). Returns
+ * value other than zero at success.
+ */
+int cgroup_id_tryget(int id)
+{
+	struct cgroup_id *cgid;
+	int ret = 0;
+
+	rcu_read_lock();
+	cgid = idr_find(&cgroup_idr, id);
+	if (cgid)
+		ret = atomic_inc_not_zero(&cgid->refcnt);
+	rcu_read_unlock();
+	return ret;
+}
+
+/**
+ * cgroup_lookup - lookup cgroup by id
+ * @id: the id of cgroup to be looked up
+ *
+ * Returns pointer to cgroup if there is valid cgroup with id, NULL if not.
+ * Should be called under rcu_read_lock() or cgroup_lock.
+ * If subsys is not used, returns NULL.
+ */
+
+struct cgroup *cgroup_lookup(int id)
+{
+	struct cgroup *cgrp = NULL;
+	struct cgroup_id *cgid = NULL;
+
+	rcu_read_lock();
+	cgid = idr_find(&cgroup_idr, id);
+
+	if (unlikely(!cgid))
+		goto out;
+
+	cgrp = rcu_dereference(cgid->myself);
+	if (unlikely(!cgrp || cgroup_is_removed(cgrp)))
+		cgrp = NULL;
+out:
+	rcu_read_unlock();
+	return cgrp;
+}
+
+/**
+ * cgroup_get_next - lookup next cgroup under specified hierarchy.
+ * @id: current position of iteration.
+ * @rootid: search tree under this.
+ * @depth: depth of root id.
+ * @foundid: position of found object.
+ *
+ * Search next cgroup under the specified hierarchy. If "cur" is NULL,
+ * start from root cgroup. Called under rcu_read_lock() or cgroup_lock()
+ * is necessary (to access a found cgroup.).
+ * If subsys is not used, returns NULL. If used, it's guaranteed that there is
+ * a used cgroup ID (root).
+ */
+struct cgroup *
+cgroup_get_next(int id, int rootid, int depth, int *foundid)
+{
+	struct cgroup *ret = NULL;
+	struct cgroup_id *tmp;
+	int tmpid;
+	unsigned long flags;
+
+	rcu_read_lock();
+	tmpid = id;
+	while (1) {
+		/* scan next entry from bitmap(tree) */
+		spin_lock_irqsave(&cgroup_idr_lock, flags);
+		tmp = idr_get_next(&cgroup_idr, &tmpid);
+		spin_unlock_irqrestore(&cgroup_idr_lock, flags);
+
+		if (!tmp) {
+			ret = NULL;
+			break;
+		}
+
+		if (tmp->hierarchy_code[depth] == rootid) {
+			ret = rcu_dereference(tmp->myself);
+			/* Sanity check and check hierarchy */
+			if (ret && !cgroup_is_removed(ret))
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
+/*
  * A couple of forward declarations required, due to cyclic reference loop:
  * cgroup_mkdir -> cgroup_create -> cgroup_populate_dir ->
  * cgroup_add_file -> cgroup_create_file -> cgroup_dir_inode_operations
@@ -1037,6 +1297,13 @@ static int cgroup_get_sb(struct file_sys
 			mutex_unlock(&inode->i_mutex);
 			goto drop_new_super;
 		}
+		/* Setup Cgroup ID for this fs */
+		ret = cgrouproot_setup_idr(root);
+		if (ret) {
+			mutex_unlock(&cgroup_mutex);
+			mutex_unlock(&inode->i_mutex);
+			goto drop_new_super;
+		}
 
 		ret = rebind_subsystems(root, root->subsys_bits);
 		if (ret == -EBUSY) {
@@ -1123,9 +1390,10 @@ static void cgroup_kill_sb(struct super_
 
 	list_del(&root->root_list);
 	root_count--;
-
+	if (root->top_cgroup.id)
+		cgroup_id_detach(&root->top_cgroup);
 	mutex_unlock(&cgroup_mutex);
-
+	synchronize_rcu();
 	kfree(root);
 	kill_litter_super(sb);
 }
@@ -2358,11 +2626,18 @@ static long cgroup_create(struct cgroup 
 	int err = 0;
 	struct cgroup_subsys *ss;
 	struct super_block *sb = root->sb;
+	struct cgroup_id *cgid = NULL;
 
 	cgrp = kzalloc(sizeof(*cgrp), GFP_KERNEL);
 	if (!cgrp)
 		return -ENOMEM;
 
+	err = cgroup_prepare_id(parent, &cgid);
+	if (err) {
+		kfree(cgrp);
+		return err;
+	}
+
 	/* Grab a reference on the superblock so the hierarchy doesn't
 	 * get deleted on unmount if there are child cgroups.  This
 	 * can be done outside cgroup_mutex, since the sb can't
@@ -2402,7 +2677,7 @@ static long cgroup_create(struct cgroup 
 
 	err = cgroup_populate_dir(cgrp);
 	/* If err < 0, we have a half-filled directory - oh well ;) */
-
+	cgroup_id_attach(cgid, cgrp, parent);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 
@@ -2477,6 +2752,8 @@ static int cgroup_rmdir(struct inode *un
 		return -EBUSY;
 	}
 
+	cgroup_id_detach(cgrp);
+
 	spin_lock(&release_list_lock);
 	set_bit(CGRP_REMOVED, &cgrp->flags);
 	if (!list_empty(&cgrp->release_list))
Index: mmotm-2.6.28-Dec03/include/linux/idr.h
===================================================================
--- mmotm-2.6.28-Dec03.orig/include/linux/idr.h
+++ mmotm-2.6.28-Dec03/include/linux/idr.h
@@ -106,6 +106,7 @@ int idr_get_new(struct idr *idp, void *p
 int idr_get_new_above(struct idr *idp, void *ptr, int starting_id, int *id);
 int idr_for_each(struct idr *idp,
 		 int (*fn)(int id, void *p, void *data), void *data);
+void *idr_get_next(struct idr *idp, int *nextid);
 void *idr_replace(struct idr *idp, void *ptr, int id);
 void idr_remove(struct idr *idp, int id);
 void idr_remove_all(struct idr *idp);
Index: mmotm-2.6.28-Dec03/lib/idr.c
===================================================================
--- mmotm-2.6.28-Dec03.orig/lib/idr.c
+++ mmotm-2.6.28-Dec03/lib/idr.c
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
