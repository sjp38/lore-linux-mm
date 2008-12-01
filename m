Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB162wYW021364
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 1 Dec 2008 15:02:58 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BA92345DE50
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 15:02:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BB9345DE4E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 15:02:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CCE41DB803A
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 15:02:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D0C45E18002
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 15:02:56 +0900 (JST)
Date: Mon, 1 Dec 2008 15:02:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/3] cgroup: fix pre_destroy and semantics of css->refcnt
Message-Id: <20081201150208.6b24506b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081201145907.e6d63d61.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081201145907.e6d63d61.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Now, final check of refcnt is done after pre_destroy(), so rmdir() can fail
after pre_destroy().
memcg set mem->obsolete to be 1 at pre_destroy and this is buggy..

Several ways to fix this can be considered. This is an idea.

Fortunately, the user of css_get()/css_put() is only memcg, now.
And it seems assumption on css_ref in cgroup.c is a bit complicated.
I'd like to reuse it.
This patch changes this css->refcnt usage and action as following
	- css->refcnt is initialized to 1.

	- after pre_destroy, before destroy(), try to drop css->refcnt to 0.

	- css_tryget() is added. This only success when css->refcnt > 0.

	- css_is_removed() is added. This checks css->refcnt == 0 and means
	  this cgroup is under destroy() or not.

	- css_put() is changed not to call notify_on_release().
	  From documentation, notify_on_release() is called when there is no
	  tasks/children in cgroup. On implementation, notify_on_release is
	  not called if css->refcnt > 0.
	  This is problematic. memcg has css->refcnt by each page even when
	  there are no tasks. release handler will be never called.
	  But, now, rmdir()/pre_destroy() of memcg works well and checking
	  checking css->ref is not (and shouldn't be) necessary for notifying.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujisu.com>


 include/linux/cgroup.h |   21 +++++++++++++++++--
 kernel/cgroup.c        |   53 +++++++++++++++++++++++++++++++++++--------------
 mm/memcontrol.c        |   40 +++++++++++++++++++++++++-----------
 3 files changed, 85 insertions(+), 29 deletions(-)

Index: mmotm-2.6.28-Nov29/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.28-Nov29.orig/include/linux/cgroup.h
+++ mmotm-2.6.28-Nov29/include/linux/cgroup.h
@@ -54,7 +54,9 @@ struct cgroup_subsys_state {
 
 	/* State maintained by the cgroup system to allow
 	 * subsystems to be "busy". Should be accessed via css_get()
-	 * and css_put() */
+	 * and css_put(). If this value is 0, css is now under removal and
+	 * destroy() will be called soon. (and there is no roll-back.)
+	 */
 
 	atomic_t refcnt;
 
@@ -86,7 +88,22 @@ extern void __css_put(struct cgroup_subs
 static inline void css_put(struct cgroup_subsys_state *css)
 {
 	if (!test_bit(CSS_ROOT, &css->flags))
-		__css_put(css);
+		atomic_dec(&css->refcnt);
+}
+
+/* returns not-zero if success */
+static inline int css_tryget(struct cgroup_subsys_state *css)
+{
+	if (!test_bit(CSS_ROOT, &css->flags))
+		return atomic_inc_not_zero(&css->refcnt);
+	return 1;
+}
+
+static inline bool css_under_removal(struct cgroup_subsys_state *css)
+{
+	if (test_bit(CSS_ROOT, &css->flags))
+		return false;
+	return atomic_read(&css->refcnt) == 0;
 }
 
 /* bits in struct cgroup flags field */
Index: mmotm-2.6.28-Nov29/kernel/cgroup.c
===================================================================
--- mmotm-2.6.28-Nov29.orig/kernel/cgroup.c
+++ mmotm-2.6.28-Nov29/kernel/cgroup.c
@@ -589,6 +589,32 @@ static void cgroup_call_pre_destroy(stru
 	return;
 }
 
+/*
+ * Try to set all subsys's refcnt to be 0.
+ * css->refcnt==0 means this subsys will be destroy()'d.
+ */
+static bool cgroup_set_subsys_removed(struct cgroup *cgrp)
+{
+	struct cgroup_subsys *ss;
+	struct cgroup_subsys_state *css, *tmp;
+
+	for_each_subsys(cgrp->root, ss) {
+		css = cgrp->subsys[ss->subsys_id];
+		if (!atomic_dec_and_test(&css->refcnt))
+			goto rollback;
+	}
+	return true;
+rollback:
+	for_each_subsys(cgrp->root, ss) {
+		tmp = cgrp->subsys[ss->subsys_id];
+		atomic_inc(&tmp->refcnt);
+		if (tmp == css)
+			break;
+	}
+	return false;
+}
+
+
 static void cgroup_diput(struct dentry *dentry, struct inode *inode)
 {
 	/* is dentry a directory ? if so, kfree() associated cgroup */
@@ -2310,7 +2336,7 @@ static void init_cgroup_css(struct cgrou
 			       struct cgroup *cgrp)
 {
 	css->cgroup = cgrp;
-	atomic_set(&css->refcnt, 0);
+	atomic_set(&css->refcnt, 1);
 	css->flags = 0;
 	if (cgrp == dummytop)
 		set_bit(CSS_ROOT, &css->flags);
@@ -2438,7 +2464,7 @@ static int cgroup_has_css_refs(struct cg
 		 * matter, since it can only happen if the cgroup
 		 * has been deleted and hence no longer needs the
 		 * release agent to be called anyway. */
-		if (css && atomic_read(&css->refcnt))
+		if (css && (atomic_read(&css->refcnt) > 1))
 			return 1;
 	}
 	return 0;
@@ -2465,7 +2491,8 @@ static int cgroup_rmdir(struct inode *un
 
 	/*
 	 * Call pre_destroy handlers of subsys. Notify subsystems
-	 * that rmdir() request comes.
+	 * that rmdir() request comes. pre_destroy() is expected to drop all
+	 * extra refcnt to css. (css->refcnt == 1)
 	 */
 	cgroup_call_pre_destroy(cgrp);
 
@@ -2479,8 +2506,15 @@ static int cgroup_rmdir(struct inode *un
 		return -EBUSY;
 	}
 
+	/* last check ! */
+	if (!cgroup_set_subsys_removed(cgrp)) {
+		mutex_unlock(&cgroup_mutex);
+		return -EBUSY;
+	}
+
 	spin_lock(&release_list_lock);
 	set_bit(CGRP_REMOVED, &cgrp->flags);
+
 	if (!list_empty(&cgrp->release_list))
 		list_del(&cgrp->release_list);
 	spin_unlock(&release_list_lock);
@@ -3003,7 +3037,7 @@ static void check_for_release(struct cgr
 	/* All of these checks rely on RCU to keep the cgroup
 	 * structure alive */
 	if (cgroup_is_releasable(cgrp) && !atomic_read(&cgrp->count)
-	    && list_empty(&cgrp->children) && !cgroup_has_css_refs(cgrp)) {
+	    && list_empty(&cgrp->children)) {
 		/* Control Group is currently removeable. If it's not
 		 * already queued for a userspace notification, queue
 		 * it now */
@@ -3020,17 +3054,6 @@ static void check_for_release(struct cgr
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
Index: mmotm-2.6.28-Nov29/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Nov29.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Nov29/mm/memcontrol.c
@@ -154,7 +154,6 @@ struct mem_cgroup {
 	 */
 	bool use_hierarchy;
 	unsigned long	last_oom_jiffies;
-	int		obsolete;
 	atomic_t	refcnt;
 	/*
 	 * statistics. This must be placed at the end of memcg.
@@ -540,8 +539,14 @@ mem_cgroup_get_first_node(struct mem_cgr
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
@@ -598,7 +603,7 @@ static int mem_cgroup_hierarchical_recla
 	next_mem = mem_cgroup_get_first_node(root_mem);
 
 	while (next_mem != root_mem) {
-		if (next_mem->obsolete) {
+		if (css_under_removal(&next_mem->css)) {
 			mem_cgroup_put(next_mem);
 			cgroup_lock();
 			next_mem = mem_cgroup_get_first_node(root_mem);
@@ -985,6 +990,7 @@ int mem_cgroup_try_charge_swapin(struct 
 {
 	struct mem_cgroup *mem;
 	swp_entry_t     ent;
+	int ret;
 
 	if (mem_cgroup_disabled())
 		return 0;
@@ -1003,10 +1009,18 @@ int mem_cgroup_try_charge_swapin(struct 
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
@@ -1037,14 +1051,16 @@ int mem_cgroup_cache_charge_swapin(struc
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
@@ -1886,8 +1902,8 @@ static struct mem_cgroup *mem_cgroup_all
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
@@ -1917,7 +1933,7 @@ static void mem_cgroup_get(struct mem_cg
 static void mem_cgroup_put(struct mem_cgroup *mem)
 {
 	if (atomic_dec_and_test(&mem->refcnt)) {
-		if (!mem->obsolete)
+		if (!css_under_removal(&mem->css))
 			return;
 		mem_cgroup_free(mem);
 	}
@@ -1980,7 +1996,7 @@ static void mem_cgroup_pre_destroy(struc
 					struct cgroup *cont)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
-	mem->obsolete = 1;
+	/* dentry's mutex makes this safe. */
 	mem_cgroup_force_empty(mem, false);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
