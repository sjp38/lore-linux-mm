Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB58TeaG023126
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Dec 2008 17:29:40 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 140D945DE57
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:29:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E6C0D45DD79
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:29:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C11321DB8038
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:29:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 18D061DB8049
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:29:36 +0900 (JST)
Date: Fri, 5 Dec 2008 17:28:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/4] New css->refcnt implementation.
Message-Id: <20081205172845.2b9d89a5.kamezawa.hiroyu@jp.fujitsu.com>
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


From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujisu.com>

Now, the last check of refcnt is done after pre_destroy(), so rmdir() can fail
after pre_destroy(). But memcg set mem->obsolete to be 1 at pre_destroy.
This is a bug. So, removing memcg->obsolete flag is sane.

But there is no interface to confirm "css" is oboslete or not. I.e. there is
no flag to check whether we can increase css_refcnt or not!
This refcnt is hard to use...

Fortunately, the user of css_get()/css_put() is only memcg, now.
So influence of changing this usage is minimum.

This patch changes this css->refcnt rule as following
	- css->refcnt is no longer private counter, just point to
	  css->cgroup->css_refcnt. 
          (css can use private counter by its own routine and can have
	   pre_destroy() handler)

	- css_refcnt is initialized to 1.

	- css_tryget() is added. This only success when css_refcnt > 0.

	- after pre_destroy, before destroy(), try to drop css_refcnt to 0.

	- after css_refcnt goes down to 0, css->refcnt is replaced to
	  dummy counter. (for tryget())

	- css_is_removed() is added. This checks css_refcnt == 0 and means
	  this cgroup is under pre_destroy()-> destroy() and no rollback.

	- css_put() is changed not to call notify_on_release().

	  From documentation, notify_on_release() is called when there is no
	  tasks/children in cgroup. On implementation, notify_on_release is
	  not called if css->refcnt > 0.
	  This is problem. Memcg has css->refcnt by each page even when
	  there are no tasks. Release handler will be never called.

	  But, now, rmdir()/pre_destroy() of memcg works well and checking
	  checking css->ref is not (and shouldn't be) necessary for notifying.

Changelog: v1 -> v2
 - changed css->refcnt to be pointer.
 - added cgroup->css_refcnt.
 - addec CONFIG_DEBUG_CGROUP_SUBSYS.
 - refreshed memcg's private refcnt handling. we'll revisit this.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujisu.com>
---
 include/linux/cgroup.h |   55 ++++++++++++++++++++++++--------
 kernel/cgroup.c        |   83 ++++++++++++++++++++-----------------------------
 lib/Kconfig.debug      |    8 ++++
 mm/memcontrol.c        |   54 ++++++++++++++++++-------------
 4 files changed, 116 insertions(+), 84 deletions(-)

Index: mmotm-2.6.28-Dec03/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.28-Dec03.orig/include/linux/cgroup.h
+++ mmotm-2.6.28-Dec03/include/linux/cgroup.h
@@ -51,13 +51,8 @@ struct cgroup_subsys_state {
 	 * for subsystems that want to know about the cgroup
 	 * hierarchy structure */
 	struct cgroup *cgroup;
-
-	/* State maintained by the cgroup system to allow
-	 * subsystems to be "busy". Should be accessed via css_get()
-	 * and css_put() */
-
-	atomic_t refcnt;
-
+	/* refcnt that all subsys shares to show *cgroup is alive or not. */
+	atomic_t      *refcnt;
 	unsigned long flags;
 };
 
@@ -66,6 +61,12 @@ enum {
 	CSS_ROOT, /* This CSS is the root of the subsystem */
 };
 
+#ifdef CONFIG_DEBUG_CGROUP_SUBSYS
+#define CGROUP_SUBSYS_BUG_ON(cond)	BUG_ON(cond)
+#else
+#define CGROUP_SUBSYS_BUG_ON(cond)	do {} while (0)
+#endif
+
 /*
  * Call css_get() to hold a reference on the cgroup;
  *
@@ -73,20 +74,44 @@ enum {
 
 static inline void css_get(struct cgroup_subsys_state *css)
 {
+	atomic_t *ref = css->refcnt;
 	/* We don't need to reference count the root state */
-	if (!test_bit(CSS_ROOT, &css->flags))
-		atomic_inc(&css->refcnt);
+	if (test_bit(CSS_ROOT, &css->flags))
+		return;
+
+	CGROUP_SUBSYS_BUG_ON(ref != &css->cgroup->css_refcnt);
+	atomic_inc(ref);
 }
 /*
- * css_put() should be called to release a reference taken by
- * css_get()
+ * css_put() should be called to release a reference taken by css_get()
  */
 
-extern void __css_put(struct cgroup_subsys_state *css);
 static inline void css_put(struct cgroup_subsys_state *css)
 {
-	if (!test_bit(CSS_ROOT, &css->flags))
-		__css_put(css);
+	atomic_t *ref = css->refcnt;
+
+	if (test_bit(CSS_ROOT, &css->flags))
+		return;
+
+	CGROUP_SUBSYS_BUG_ON(ref != &css->cgroup->css_refcnt);
+	atomic_dec(ref);
+}
+
+/*
+ * Returns a value other than 0 at success.
+ */
+static inline int css_tryget(struct cgroup_subsys_state *css)
+{
+	if (test_bit(CSS_ROOT, &css->flags))
+		return 1;
+	return atomic_inc_not_zero(css->refcnt);
+}
+
+static inline bool css_under_removal(struct cgroup_subsys_state *css)
+{
+	if (test_bit(CSS_ROOT, &css->flags))
+		return false;
+	return atomic_read(css->refcnt) == 0;
 }
 
 /* bits in struct cgroup flags field */
@@ -145,6 +170,8 @@ struct cgroup {
 	int pids_use_count;
 	/* Length of the current tasks_pids array */
 	int pids_length;
+	/* for css_get/put */
+	atomic_t css_refcnt;
 };
 
 /* A css_set is a structure holding pointers to a set of
Index: mmotm-2.6.28-Dec03/kernel/cgroup.c
===================================================================
--- mmotm-2.6.28-Dec03.orig/kernel/cgroup.c
+++ mmotm-2.6.28-Dec03/kernel/cgroup.c
@@ -110,6 +110,8 @@ static int root_count;
 /* dummytop is a shorthand for the dummy hierarchy's top cgroup */
 #define dummytop (&rootnode.top_cgroup)
 
+static atomic_t	dummy_css_refcnt; /* should be 0 forever. */
+
 /* This flag indicates whether tasks in the fork and exit paths should
  * check for fork/exit handlers to call. This avoids us having to do
  * extra work in the fork/exit path if none of the subsystems need to
@@ -589,6 +591,27 @@ static void cgroup_call_pre_destroy(stru
 	return;
 }
 
+/*
+ * Try to set subsys's refcnt to be 0.
+ */
+static int cgroup_set_subsys_removed(struct cgroup *cgrp)
+{
+	/* can refcnt goes down to 0 ? */
+	if (atomic_dec_and_test(&cgrp->css_refcnt)) {
+		struct cgroup_subsys *ss;
+		struct cgroup_subsys_state *css;
+		/* replace refcnt with dummy */
+		for_each_subsys(cgrp->root, ss) {
+			css = cgrp->subsys[ss->subsys_id];
+			css->refcnt = &dummy_css_refcnt;
+		}
+		return true;
+	} else
+		atomic_inc(&cgrp->css_refcnt);
+
+	return false;
+}
+
 static void cgroup_diput(struct dentry *dentry, struct inode *inode)
 {
 	/* is dentry a directory ? if so, kfree() associated cgroup */
@@ -869,6 +892,7 @@ static void init_cgroup_housekeeping(str
 	INIT_LIST_HEAD(&cgrp->css_sets);
 	INIT_LIST_HEAD(&cgrp->release_list);
 	init_rwsem(&cgrp->pids_mutex);
+	atomic_set(&cgrp->css_refcnt, 1);
 }
 static void init_cgroup_root(struct cgroupfs_root *root)
 {
@@ -2310,7 +2334,7 @@ static void init_cgroup_css(struct cgrou
 			       struct cgroup *cgrp)
 {
 	css->cgroup = cgrp;
-	atomic_set(&css->refcnt, 0);
+	css->refcnt = &cgrp->css_refcnt;
 	css->flags = 0;
 	if (cgrp == dummytop)
 		set_bit(CSS_ROOT, &css->flags);
@@ -2413,37 +2437,6 @@ static int cgroup_mkdir(struct inode *di
 	return cgroup_create(c_parent, dentry, mode | S_IFDIR);
 }
 
-static int cgroup_has_css_refs(struct cgroup *cgrp)
-{
-	/* Check the reference count on each subsystem. Since we
-	 * already established that there are no tasks in the
-	 * cgroup, if the css refcount is also 0, then there should
-	 * be no outstanding references, so the subsystem is safe to
-	 * destroy. We scan across all subsystems rather than using
-	 * the per-hierarchy linked list of mounted subsystems since
-	 * we can be called via check_for_release() with no
-	 * synchronization other than RCU, and the subsystem linked
-	 * list isn't RCU-safe */
-	int i;
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		struct cgroup_subsys *ss = subsys[i];
-		struct cgroup_subsys_state *css;
-		/* Skip subsystems not in this hierarchy */
-		if (ss->root != cgrp->root)
-			continue;
-		css = cgrp->subsys[ss->subsys_id];
-		/* When called from check_for_release() it's possible
-		 * that by this point the cgroup has been removed
-		 * and the css deleted. But a false-positive doesn't
-		 * matter, since it can only happen if the cgroup
-		 * has been deleted and hence no longer needs the
-		 * release agent to be called anyway. */
-		if (css && atomic_read(&css->refcnt))
-			return 1;
-	}
-	return 0;
-}
-
 static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 {
 	struct cgroup *cgrp = dentry->d_fsdata;
@@ -2465,16 +2458,21 @@ static int cgroup_rmdir(struct inode *un
 
 	/*
 	 * Call pre_destroy handlers of subsys. Notify subsystems
-	 * that rmdir() request comes.
+	 * that rmdir() request comes. pre_destroy() is expected to drop all
+	 * extra refcnt to css. (css->refcnt == 1)
 	 */
 	cgroup_call_pre_destroy(cgrp);
 
 	mutex_lock(&cgroup_mutex);
 	parent = cgrp->parent;
 
-	if (atomic_read(&cgrp->count)
-	    || !list_empty(&cgrp->children)
-	    || cgroup_has_css_refs(cgrp)) {
+	if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
+		mutex_unlock(&cgroup_mutex);
+		return -EBUSY;
+	}
+
+	/* last check ! */
+	if (!cgroup_set_subsys_removed(cgrp)) {
 		mutex_unlock(&cgroup_mutex);
 		return -EBUSY;
 	}
@@ -3003,7 +3001,7 @@ static void check_for_release(struct cgr
 	/* All of these checks rely on RCU to keep the cgroup
 	 * structure alive */
 	if (cgroup_is_releasable(cgrp) && !atomic_read(&cgrp->count)
-	    && list_empty(&cgrp->children) && !cgroup_has_css_refs(cgrp)) {
+	    && list_empty(&cgrp->children)) {
 		/* Control Group is currently removeable. If it's not
 		 * already queued for a userspace notification, queue
 		 * it now */
@@ -3020,17 +3018,6 @@ static void check_for_release(struct cgr
 	}
 }
 
-void __css_put(struct cgroup_subsys_state *css)
-{
-	struct cgroup *cgrp = css->cgroup;
-	rcu_read_lock();
-	if (atomic_dec_and_test(&css->refcnt) && notify_on_release(cgrp)) {
-		set_bit(CGRP_RELEASABLE, &cgrp->flags);
-		check_for_release(cgrp);
-	}
-	rcu_read_unlock();
-}
-
 /*
  * Notify userspace when a cgroup is released, by running the
  * configured release agent with the name of the cgroup (path
Index: mmotm-2.6.28-Dec03/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec03.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec03/mm/memcontrol.c
@@ -165,7 +165,6 @@ struct mem_cgroup {
 	 */
 	bool use_hierarchy;
 	unsigned long	last_oom_jiffies;
-	int		obsolete;
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
@@ -594,8 +593,14 @@ mem_cgroup_get_first_node(struct mem_cgr
 {
 	struct cgroup *cgroup;
 	struct mem_cgroup *ret;
-	bool obsolete = (root_mem->last_scanned_child &&
-				root_mem->last_scanned_child->obsolete);
+	struct mem_cgroup *last_scan = root_mem->last_scanned_child;
+	bool obsolete = false;
+
+	if (last_scan) {
+		if (css_under_removal(&last_scan->css))
+			obsolete = true;
+	} else
+		obsolete = true;
 
 	/*
 	 * Scan all children under the mem_cgroup mem
@@ -683,7 +688,7 @@ static int mem_cgroup_hierarchical_recla
 	next_mem = mem_cgroup_get_first_node(root_mem);
 
 	while (next_mem != root_mem) {
-		if (next_mem->obsolete) {
+		if (css_under_removal(&next_mem->css)) {
 			mem_cgroup_put(next_mem);
 			cgroup_lock();
 			next_mem = mem_cgroup_get_first_node(root_mem);
@@ -744,14 +749,13 @@ static int __mem_cgroup_try_charge(struc
 	if (likely(!*memcg)) {
 		rcu_read_lock();
 		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-		if (unlikely(!mem)) {
+		if (unlikely(!mem) || !css_tryget(&mem->css)) {
 			rcu_read_unlock();
 			return 0;
 		}
 		/*
 		 * For every charge from the cgroup, increment reference count
 		 */
-		css_get(&mem->css);
 		*memcg = mem;
 		rcu_read_unlock();
 	} else {
@@ -1067,6 +1071,7 @@ int mem_cgroup_try_charge_swapin(struct 
 {
 	struct mem_cgroup *mem;
 	swp_entry_t     ent;
+	int ret;
 
 	if (mem_cgroup_disabled())
 		return 0;
@@ -1085,10 +1090,18 @@ int mem_cgroup_try_charge_swapin(struct 
 	ent.val = page_private(page);
 
 	mem = lookup_swap_cgroup(ent);
-	if (!mem || mem->obsolete)
+	/*
+	 * Because we can't assume "mem" is alive now, use tryget() and
+	 * drop extra count later
+	 */
+	if (!mem || !css_tryget(&mem->css))
 		goto charge_cur_mm;
 	*ptr = mem;
-	return __mem_cgroup_try_charge(NULL, mask, ptr, true);
+	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true);
+	/* drop extra count */
+	css_put(&mem->css);
+
+	return ret;
 charge_cur_mm:
 	if (unlikely(!mm))
 		mm = &init_mm;
@@ -1119,14 +1132,16 @@ int mem_cgroup_cache_charge_swapin(struc
 		ent.val = page_private(page);
 		if (do_swap_account) {
 			mem = lookup_swap_cgroup(ent);
-			if (mem && mem->obsolete)
+			if (mem && !css_tryget(&mem->css))
 				mem = NULL;
 			if (mem)
 				mm = NULL;
 		}
 		ret = mem_cgroup_charge_common(page, mm, mask,
 				MEM_CGROUP_CHARGE_TYPE_SHMEM, mem);
-
+		/* drop extra ref */
+		if (mem)
+			css_put(&mem->css);
 		if (!ret && do_swap_account) {
 			/* avoid double counting */
 			mem = swap_cgroup_record(ent, NULL);
@@ -1411,11 +1426,10 @@ int mem_cgroup_shrink_usage(struct mm_st
 
 	rcu_read_lock();
 	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-	if (unlikely(!mem)) {
+	if (unlikely(!mem) || !css_tryget(&mem->css)) {
 		rcu_read_unlock();
 		return 0;
 	}
-	css_get(&mem->css);
 	rcu_read_unlock();
 
 	do {
@@ -2058,6 +2072,7 @@ static struct mem_cgroup *mem_cgroup_all
 
 	if (mem)
 		memset(mem, 0, size);
+	atomic_set(&mem->refcnt, 1);
 	return mem;
 }
 
@@ -2069,8 +2084,8 @@ static struct mem_cgroup *mem_cgroup_all
  * the number of reference from swap_cgroup and free mem_cgroup when
  * it goes down to 0.
  *
- * When mem_cgroup is destroyed, mem->obsolete will be set to 0 and
- * entry which points to this memcg will be ignore at swapin.
+ * When mem_cgroup is destroyed, css_under_removal() is true and entry which
+ * points to this memcg will be ignore at swapin.
  *
  * Removal of cgroup itself succeeds regardless of refs from swap.
  */
@@ -2079,10 +2094,6 @@ static void mem_cgroup_free(struct mem_c
 {
 	int node;
 
-	if (atomic_read(&mem->refcnt) > 0)
-		return;
-
-
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 
@@ -2100,8 +2111,7 @@ static void mem_cgroup_get(struct mem_cg
 static void mem_cgroup_put(struct mem_cgroup *mem)
 {
 	if (atomic_dec_and_test(&mem->refcnt)) {
-		if (!mem->obsolete)
-			return;
+		BUG(!css_under_removal(&mem->css));
 		mem_cgroup_free(mem);
 	}
 }
@@ -2167,14 +2177,14 @@ static void mem_cgroup_pre_destroy(struc
 					struct cgroup *cont)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
-	mem->obsolete = 1;
+	/* dentry's mutex makes this safe. */
 	mem_cgroup_force_empty(mem, false);
 }
 
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
-	mem_cgroup_free(mem_cgroup_from_cont(cont));
+	mem_cgroup_put(mem_cgroup_from_cont(cont));
 }
 
 static int mem_cgroup_populate(struct cgroup_subsys *ss,
Index: mmotm-2.6.28-Dec03/lib/Kconfig.debug
===================================================================
--- mmotm-2.6.28-Dec03.orig/lib/Kconfig.debug
+++ mmotm-2.6.28-Dec03/lib/Kconfig.debug
@@ -353,6 +353,14 @@ config DEBUG_LOCK_ALLOC
 	 spin_lock_init()/mutex_init()/etc., or whether there is any lock
 	 held during task exit.
 
+config DEBUG_CGROUP_SUBSYS
+	bool "Debugginug Cgroup Subsystems"
+	depends on DEBUG_KERNEL && CGROUP
+	help
+	 This feature will check cgroup_subsys_state behavior. Currently, this
+	 checks reference count management.
+
+
 config PROVE_LOCKING
 	bool "Lock debugging: prove locking correctness"
 	depends on DEBUG_KERNEL && TRACE_IRQFLAGS_SUPPORT && STACKTRACE_SUPPORT && LOCKDEP_SUPPORT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
