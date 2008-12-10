Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBA4kRei020418
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 10 Dec 2008 13:46:28 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BC94945DE54
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 13:46:27 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9940B45DE51
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 13:46:27 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CAD91DB8043
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 13:46:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 201F91DB8042
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 13:46:27 +0900 (JST)
Date: Wed, 10 Dec 2008 13:45:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH mmotm 2/2] cgroup: add CSS_POPULATED flag to show css is in
 use.
Message-Id: <20081210134533.2e3f21e3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081210133508.3ee454ae.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081210133508.3ee454ae.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

need more reviews.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Recently, pre_destroy() was moved to outside of cgroup_lock() for avoiding
dead-lock. Because pre_destroy() handler is moved, there is a new problem.

Now, cgroup's rmdir() does following sequence.

	cgroup_lock()
	check children and tasks.
	(A)
	cgroup_unlock()
	(B)
	pre_destroy() for subsys;-----(1)
	(C)
	cgroup_lock();
	(D)
	Second check:check for -EBUSY again because we released the lock. ---(2)
	(E)
	mark cgroup as removed.
	(F)
	unlink from lists.
	cgroup_unlock();
	dput()
	=> when dentry's refcnt goes down to 0
		destroy() handers for subsys

Now, memcg marks itself as "obsolete" when pre_destroy() is called at (1).
But rmdir() can fail after pre_destroy() at (2). So marking as "obsolete" at (1) is bug.
I'd like to fix sanity of pre_destroy() in cgroup layer.

css's refcnt can be incremented again after pre_destroy()
	at (C) and (D), (E)

This patch adds "css_is_populated()" check. (better name is welcome)
After this,

	- CSS_POPULATED flag is dropped at (A)
	- If Second check fails, CSS_POPULARED flag is set, again. at (2)
	- memcg's its own obsolete flag is removed.

For memcg, the race caused by this !POPULATED check under rmdir() is found in
	- swapped-in page is charged to the current user of page
	or
	- swapped-in page is charged back to the original user of swap.

not so problematic.

Chanelog (v1) -> (v2):
 - fixed typo.
 - moved TRY_REMOVE patch out.
 - added CSS_POPULATED.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/cgroup.h |   17 +++++++++++++++++
 kernel/cgroup.c        |   22 ++++++++++++++++++++++
 mm/memcontrol.c        |   30 +++++++++++++++++++-----------
 3 files changed, 58 insertions(+), 11 deletions(-)

Index: mmotm-2.6.28-Dec09/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.28-Dec09.orig/include/linux/cgroup.h
+++ mmotm-2.6.28-Dec09/include/linux/cgroup.h
@@ -64,6 +64,7 @@ struct cgroup_subsys_state {
 /* bits in struct cgroup_subsys_state flags field */
 enum {
 	CSS_ROOT, /* This CSS is the root of the subsystem */
+	CSS_POPULATED, /* This CSS will be used by tasks. */
 };
 
 /*
@@ -89,6 +90,22 @@ static inline void css_put(struct cgroup
 		__css_put(css);
 }
 
+/*
+ * POPULATED is true while...
+ * after mkdir() returns success and before rmdir()=>pre_destroy() is called.
+ * If rmdir() fails, POPULATED is set again.
+ * If !POPULATED, someone tries to rmdir() now or rmdir() is now going on.
+ * Or css->cgroup is obsolete.
+ */
+static inline bool
+css_is_populated(struct cgroup_subsys_state *css)
+{
+	if (test_bit(CSS_POPULATED, &css->flags))
+		return true;
+	return false;
+}
+
+
 /* bits in struct cgroup flags field */
 enum {
 	/* Control Group is dead */
Index: mmotm-2.6.28-Dec09/kernel/cgroup.c
===================================================================
--- mmotm-2.6.28-Dec09.orig/kernel/cgroup.c
+++ mmotm-2.6.28-Dec09/kernel/cgroup.c
@@ -2335,6 +2335,21 @@ static void init_cgroup_css(struct cgrou
 	cgrp->subsys[ss->subsys_id] = css;
 }
 
+static void populate_css(struct cgroup *cgrp, bool set)
+{
+	struct cgroup_subsys *ss;
+
+	for_each_subsys(cgrp->root, ss) {
+		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+
+		if (set)
+			set_bit(CSS_POPULATED, &css->flags);
+		else
+			clear_bit(CSS_POPULATED, &css->flags);
+	}
+}
+
+
 /*
  * cgroup_create - create a cgroup
  * @parent: cgroup that will be parent of the new cgroup
@@ -2396,6 +2411,7 @@ static long cgroup_create(struct cgroup 
 	err = cgroup_populate_dir(cgrp);
 	/* If err < 0, we have a half-filled directory - oh well ;) */
 
+	populate_css(cgrp, true);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 
@@ -2479,6 +2495,9 @@ static int cgroup_rmdir(struct inode *un
 		return -EBUSY;
 	}
 	set_bit(CGRP_TRY_REMOVE, &cgrp->flags);
+
+	/* set css to be !POPULATED state before calling pre_destroy */
+	populate_css(cgrp, false);
 	mutex_unlock(&cgroup_mutex);
 
 	/*
@@ -2493,6 +2512,7 @@ static int cgroup_rmdir(struct inode *un
 	if (atomic_read(&cgrp->count)
 	    || !list_empty(&cgrp->children)
 	    || cgroup_has_css_refs(cgrp)) {
+		populate_css(cgrp, true);
 		clear_bit(CGRP_TRY_REMOVE, &cgrp->flags);
 		mutex_unlock(&cgroup_mutex);
 		return -EBUSY;
@@ -2547,6 +2567,8 @@ static void __init cgroup_init_subsys(st
 	BUG_ON(!list_empty(&init_task.tasks));
 
 	ss->active = 1;
+
+	set_bit(CSS_POPULATED, &css->flags);
 }
 
 /**
Index: mmotm-2.6.28-Dec09/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec09.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec09/mm/memcontrol.c
@@ -162,7 +162,6 @@ struct mem_cgroup {
 	 */
 	bool use_hierarchy;
 	unsigned long	last_oom_jiffies;
-	int		obsolete;
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
@@ -207,6 +206,20 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 
+static bool memcg_is_obsolete(struct mem_cgroup *mem)
+{
+	/*
+	 * "!Populated" means pre_destroy() handler is called.
+	 * While "pre_destroy" handler is called, memcg should not
+	 * have any additional charges.
+	 */
+
+	if (!mem || !css_is_populated(&mem->css))
+		return true;
+	return false;
+}
+
+
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 					 struct page_cgroup *pc,
 					 bool charge)
@@ -592,8 +605,7 @@ mem_cgroup_get_first_node(struct mem_cgr
 {
 	struct cgroup *cgroup;
 	struct mem_cgroup *ret;
-	bool obsolete = (root_mem->last_scanned_child &&
-				root_mem->last_scanned_child->obsolete);
+	bool obsolete = memcg_is_obsolete(root_mem->last_scanned_child);
 
 	/*
 	 * Scan all children under the mem_cgroup mem
@@ -681,7 +693,7 @@ static int mem_cgroup_hierarchical_recla
 	next_mem = mem_cgroup_get_first_node(root_mem);
 
 	while (next_mem != root_mem) {
-		if (next_mem->obsolete) {
+		if (memcg_is_obsolete(next_mem)) {
 			mem_cgroup_put(next_mem);
 			cgroup_lock();
 			next_mem = mem_cgroup_get_first_node(root_mem);
@@ -1066,7 +1078,7 @@ int mem_cgroup_try_charge_swapin(struct 
 	ent.val = page_private(page);
 
 	mem = lookup_swap_cgroup(ent);
-	if (!mem || mem->obsolete)
+	if (memcg_is_obsolete(mem))
 		goto charge_cur_mm;
 	*ptr = mem;
 	return __mem_cgroup_try_charge(NULL, mask, ptr, true);
@@ -1100,7 +1112,7 @@ int mem_cgroup_cache_charge_swapin(struc
 		ent.val = page_private(page);
 		if (do_swap_account) {
 			mem = lookup_swap_cgroup(ent);
-			if (mem && mem->obsolete)
+			if (memcg_is_obsolete(mem))
 				mem = NULL;
 			if (mem)
 				mm = NULL;
@@ -2046,9 +2058,6 @@ static struct mem_cgroup *mem_cgroup_all
  * the number of reference from swap_cgroup and free mem_cgroup when
  * it goes down to 0.
  *
- * When mem_cgroup is destroyed, mem->obsolete will be set to 0 and
- * entry which points to this memcg will be ignore at swapin.
- *
  * Removal of cgroup itself succeeds regardless of refs from swap.
  */
 
@@ -2077,7 +2086,7 @@ static void mem_cgroup_get(struct mem_cg
 static void mem_cgroup_put(struct mem_cgroup *mem)
 {
 	if (atomic_dec_and_test(&mem->refcnt)) {
-		if (!mem->obsolete)
+		if (!memcg_is_obsolete(mem))
 			return;
 		mem_cgroup_free(mem);
 	}
@@ -2144,7 +2153,6 @@ static void mem_cgroup_pre_destroy(struc
 					struct cgroup *cont)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
-	mem->obsolete = 1;
 	mem_cgroup_force_empty(mem, false);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
