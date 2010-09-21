Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0E53F6B004A
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 05:39:50 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8L9dlE6004427
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Sep 2010 18:39:47 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B1E1845DE51
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:39:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E4E545DE50
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:39:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DC891DB8050
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:39:46 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B4E71DB8046
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:39:46 +0900 (JST)
Date: Tue, 21 Sep 2010 18:34:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v2 1/3][-mm] memcg: use for_each_mem_cgroup
Message-Id: <20100921183437.06790a7c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100921183127.1c4c2bc1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100921183127.1c4c2bc1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

In memory cgroup management, we sometimes have to walk through 
subhierarchy of cgroup to gather informaiton, or lock something, etc.

Now, to do that, mem_cgroup_walk_tree() function is provided. It calls given
callback function per cgroup found. But the bad thing is that it has to pass
a fixed style function and argument, "void*" and it adds much type casting to
memcontrol.c.

To make the code clean, this patch replaces walk_tree() with

  for_each_mem_cgroup_tree(iter, root)

An iterator style call. The good point is that iterator call doesn't
have to assume what kind of function is called under it. A bad point
is that it may cause reference-count leak if a caller use "break" from the
loop by mistake.

I think the benefit is larger. The modified code seems straigtforward
and easy to read because we don't have misterious callbacks and pointer
cast.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  172 +++++++++++++++++++++++++++-----------------------------
 1 file changed, 84 insertions(+), 88 deletions(-)

Index: mmotm-0915/mm/memcontrol.c
===================================================================
--- mmotm-0915.orig/mm/memcontrol.c
+++ mmotm-0915/mm/memcontrol.c
@@ -660,40 +660,57 @@ static struct mem_cgroup *try_get_mem_cg
 	return mem;
 }
 
-/*
- * Call callback function against all cgroup under hierarchy tree.
- */
-static int mem_cgroup_walk_tree(struct mem_cgroup *root, void *data,
-			  int (*func)(struct mem_cgroup *, void *))
+/* The caller has to guarantee "mem" exists before calling this */
+static struct mem_cgroup *mem_cgroup_start_loop(struct mem_cgroup *mem)
 {
-	int found, ret, nextid;
+	if (mem && css_tryget(&mem->css))
+		return mem;
+	return NULL;
+}
+
+static struct mem_cgroup *mem_cgroup_get_next(struct mem_cgroup *iter,
+					struct mem_cgroup *root,
+					bool cond)
+{
+	int nextid = css_id(&iter->css) + 1;
+	int found;
+	int hierarchy_used;
 	struct cgroup_subsys_state *css;
-	struct mem_cgroup *mem;
 
-	if (!root->use_hierarchy)
-		return (*func)(root, data);
+	hierarchy_used = iter->use_hierarchy;
 
-	nextid = 1;
-	do {
-		ret = 0;
-		mem = NULL;
+	css_put(&iter->css);
+	if (!cond || !hierarchy_used)
+		return NULL;
 
+	do {
+		iter = NULL;
 		rcu_read_lock();
-		css = css_get_next(&mem_cgroup_subsys, nextid, &root->css,
-				   &found);
+
+		css = css_get_next(&mem_cgroup_subsys, nextid,
+				&root->css, &found);
 		if (css && css_tryget(css))
-			mem = container_of(css, struct mem_cgroup, css);
+			iter = container_of(css, struct mem_cgroup, css);
 		rcu_read_unlock();
-
-		if (mem) {
-			ret = (*func)(mem, data);
-			css_put(&mem->css);
-		}
+		/* If css is NULL, no more cgroups will be found */
 		nextid = found + 1;
-	} while (!ret && css);
+	} while (css && !iter);
 
-	return ret;
+	return iter;
 }
+/*
+ * for_eacn_mem_cgroup_tree() for visiting all cgroup under tree. Please
+ * be careful that "break" loop is not allowed. We have reference count.
+ * Instead of that modify "cond" to be false and "continue" to exit the loop.
+ */
+#define for_each_mem_cgroup_tree_cond(iter, root, cond)	\
+	for (iter = mem_cgroup_start_loop(root);\
+	     iter != NULL;\
+	     iter = mem_cgroup_get_next(iter, root, cond))
+
+#define for_each_mem_cgroup_tree(iter, root) \
+	for_each_mem_cgroup_tree_cond(iter, root, true)
+
 
 static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
 {
@@ -1132,13 +1149,6 @@ static bool mem_cgroup_wait_acct_move(st
 	return false;
 }
 
-static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
-{
-	int *val = data;
-	(*val)++;
-	return 0;
-}
-
 /**
  * mem_cgroup_print_oom_info: Called from OOM with tasklist_lock held in read mode.
  * @memcg: The memory cgroup that went over limit
@@ -1213,7 +1223,10 @@ done:
 static int mem_cgroup_count_children(struct mem_cgroup *mem)
 {
 	int num = 0;
- 	mem_cgroup_walk_tree(mem, &num, mem_cgroup_count_children_cb);
+	struct mem_cgroup *iter;
+
+	for_each_mem_cgroup_tree(iter, mem)
+		num++;
 	return num;
 }
 
@@ -1362,49 +1375,39 @@ static int mem_cgroup_hierarchical_recla
 	return total;
 }
 
-static int mem_cgroup_oom_lock_cb(struct mem_cgroup *mem, void *data)
-{
-	int *val = (int *)data;
-	int x;
-	/*
-	 * Logically, we can stop scanning immediately when we find
-	 * a memcg is already locked. But condidering unlock ops and
-	 * creation/removal of memcg, scan-all is simple operation.
-	 */
-	x = atomic_inc_return(&mem->oom_lock);
-	*val = max(x, *val);
-	return 0;
-}
 /*
  * Check OOM-Killer is already running under our hierarchy.
  * If someone is running, return false.
  */
 static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
 {
-	int lock_count = 0;
+	int x, lock_count = 0;
+	struct mem_cgroup *iter;
 
-	mem_cgroup_walk_tree(mem, &lock_count, mem_cgroup_oom_lock_cb);
+	for_each_mem_cgroup_tree(iter, mem) {
+		x = atomic_inc_return(&iter->oom_lock);
+		lock_count = max(x, lock_count);
+	}
 
 	if (lock_count == 1)
 		return true;
 	return false;
 }
 
-static int mem_cgroup_oom_unlock_cb(struct mem_cgroup *mem, void *data)
+static int mem_cgroup_oom_unlock(struct mem_cgroup *mem)
 {
+	struct mem_cgroup *iter;
+
 	/*
 	 * When a new child is created while the hierarchy is under oom,
 	 * mem_cgroup_oom_lock() may not be called. We have to use
 	 * atomic_add_unless() here.
 	 */
-	atomic_add_unless(&mem->oom_lock, -1, 0);
+	for_each_mem_cgroup_tree(iter, mem)
+		atomic_add_unless(&iter->oom_lock, -1, 0);
 	return 0;
 }
 
-static void mem_cgroup_oom_unlock(struct mem_cgroup *mem)
-{
-	mem_cgroup_walk_tree(mem, NULL,	mem_cgroup_oom_unlock_cb);
-}
 
 static DEFINE_MUTEX(memcg_oom_mutex);
 static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
@@ -3207,33 +3210,25 @@ static int mem_cgroup_hierarchy_write(st
 	return retval;
 }
 
-struct mem_cgroup_idx_data {
-	s64 val;
-	enum mem_cgroup_stat_index idx;
-};
 
-static int
-mem_cgroup_get_idx_stat(struct mem_cgroup *mem, void *data)
+static u64 mem_cgroup_get_recursive_idx_stat(struct mem_cgroup *mem,
+				enum mem_cgroup_stat_index idx)
 {
-	struct mem_cgroup_idx_data *d = data;
-	d->val += mem_cgroup_read_stat(mem, d->idx);
-	return 0;
-}
+	struct mem_cgroup *iter;
+	s64 val = 0;
 
-static void
-mem_cgroup_get_recursive_idx_stat(struct mem_cgroup *mem,
-				enum mem_cgroup_stat_index idx, s64 *val)
-{
-	struct mem_cgroup_idx_data d;
-	d.idx = idx;
-	d.val = 0;
-	mem_cgroup_walk_tree(mem, &d, mem_cgroup_get_idx_stat);
-	*val = d.val;
+	/* each per cpu's value can be minus.Then, use s64 */
+	for_each_mem_cgroup_tree(iter, mem)
+		val += mem_cgroup_read_stat(iter, idx);
+
+	if (val < 0) /* race ? */
+		val = 0;
+	return val;
 }
 
 static inline u64 mem_cgroup_usage(struct mem_cgroup *mem, bool swap)
 {
-	u64 idx_val, val;
+	u64 val;
 
 	if (!mem_cgroup_is_root(mem)) {
 		if (!swap)
@@ -3242,16 +3237,12 @@ static inline u64 mem_cgroup_usage(struc
 			return res_counter_read_u64(&mem->memsw, RES_USAGE);
 	}
 
-	mem_cgroup_get_recursive_idx_stat(mem, MEM_CGROUP_STAT_CACHE, &idx_val);
-	val = idx_val;
-	mem_cgroup_get_recursive_idx_stat(mem, MEM_CGROUP_STAT_RSS, &idx_val);
-	val += idx_val;
-
-	if (swap) {
-		mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_SWAPOUT, &idx_val);
-		val += idx_val;
-	}
+	val = mem_cgroup_get_recursive_idx_stat(mem, MEM_CGROUP_STAT_CACHE);
+	val += mem_cgroup_get_recursive_idx_stat(mem, MEM_CGROUP_STAT_RSS);
+
+	if (swap)
+		val += mem_cgroup_get_recursive_idx_stat(mem,
+				MEM_CGROUP_STAT_SWAPOUT);
 
 	return val << PAGE_SHIFT;
 }
@@ -3459,9 +3450,9 @@ struct {
 };
 
 
-static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
+static void
+mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 {
-	struct mcs_total_stat *s = data;
 	s64 val;
 
 	/* per cpu stat */
@@ -3491,13 +3482,15 @@ static int mem_cgroup_get_local_stat(str
 	s->stat[MCS_ACTIVE_FILE] += val * PAGE_SIZE;
 	val = mem_cgroup_get_local_zonestat(mem, LRU_UNEVICTABLE);
 	s->stat[MCS_UNEVICTABLE] += val * PAGE_SIZE;
-	return 0;
 }
 
 static void
 mem_cgroup_get_total_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 {
-	mem_cgroup_walk_tree(mem, s, mem_cgroup_get_local_stat);
+	struct mem_cgroup *iter;
+
+	for_each_mem_cgroup_tree(iter, mem)
+		mem_cgroup_get_local_stat(iter, s);
 }
 
 static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
@@ -3670,7 +3663,7 @@ static int compare_thresholds(const void
 	return _a->threshold - _b->threshold;
 }
 
-static int mem_cgroup_oom_notify_cb(struct mem_cgroup *mem, void *data)
+static int mem_cgroup_oom_notify_cb(struct mem_cgroup *mem)
 {
 	struct mem_cgroup_eventfd_list *ev;
 
@@ -3681,7 +3674,10 @@ static int mem_cgroup_oom_notify_cb(stru
 
 static void mem_cgroup_oom_notify(struct mem_cgroup *mem)
 {
-	mem_cgroup_walk_tree(mem, NULL, mem_cgroup_oom_notify_cb);
+	struct mem_cgroup *iter;
+
+	for_each_mem_cgroup_tree(iter, mem)
+		mem_cgroup_oom_notify_cb(iter);
 }
 
 static int mem_cgroup_usage_register_event(struct cgroup *cgrp,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
