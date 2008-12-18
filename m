Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 358F96B0044
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 03:57:57 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBI8xpJa021899
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 18 Dec 2008 17:59:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 112DC45DD74
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 17:59:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D743845DD72
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 17:59:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 46D481DB803C
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 17:59:48 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D99951DB8040
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 17:59:47 +0900 (JST)
Date: Thu, 18 Dec 2008 17:58:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/2] memcg: use css_tryget in memcg
Message-Id: <20081218175850.5bb55f3f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081218175403.40ad184a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081218175403.40ad184a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>


From:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Use css_tryget() in memcg.
Based on cgroups-add-css_tryget.patch

css_tryget() newly is added and we can know css is alive or not and
get refcnt of css in very safe way.
("alive" here means "rmdir/destroy" is not called.)

This patch replaces css_get() to css_tryget(), where I cannot explain
why css_get() is safe. And removes memcg->obsolete flag.

Changelog (v0) -> (v1):
   - fixed css_ref leak bug at swap-in.

Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: mmotm-2.6.28-Dec17/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec17.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec17/mm/memcontrol.c
@@ -162,7 +162,6 @@ struct mem_cgroup {
 	 */
 	bool use_hierarchy;
 	unsigned long	last_oom_jiffies;
-	int		obsolete;
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
@@ -283,6 +282,31 @@ struct mem_cgroup *mem_cgroup_from_task(
 				struct mem_cgroup, css);
 }
 
+static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
+{
+	struct mem_cgroup *mem = NULL;
+	/*
+	 * Because we have no locks, mm->owner's may be being moved to other
+	 * cgroup. We use css_tryget() here even if this looks
+	 * pessimistic (rather than adding locks here).
+	 */
+	rcu_read_lock();
+	do {
+		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
+		if (unlikely(!mem))
+			break;
+	} while (!css_tryget(&mem->css));
+	rcu_read_unlock();
+	return mem;
+}
+
+static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
+{
+	if (!mem)
+		return true;
+	return css_is_removed(&mem->css);
+}
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -617,8 +641,9 @@ mem_cgroup_get_first_node(struct mem_cgr
 {
 	struct cgroup *cgroup;
 	struct mem_cgroup *ret;
-	bool obsolete = (root_mem->last_scanned_child &&
-				root_mem->last_scanned_child->obsolete);
+	bool obsolete;
+
+	obsolete = mem_cgroup_is_obsolete(root_mem->last_scanned_child);
 
 	/*
 	 * Scan all children under the mem_cgroup mem
@@ -706,7 +731,7 @@ static int mem_cgroup_hierarchical_recla
 	next_mem = mem_cgroup_get_first_node(root_mem);
 
 	while (next_mem != root_mem) {
-		if (next_mem->obsolete) {
+		if (mem_cgroup_is_obsolete(next_mem)) {
 			mem_cgroup_put(next_mem);
 			next_mem = mem_cgroup_get_first_node(root_mem);
 			continue;
@@ -762,23 +787,17 @@ static int __mem_cgroup_try_charge(struc
 	 * thread group leader migrates. It's possible that mm is not
 	 * set, if so charge the init_mm (happens for pagecache usage).
 	 */
-	if (likely(!*memcg)) {
-		rcu_read_lock();
-		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-		if (unlikely(!mem)) {
-			rcu_read_unlock();
-			return 0;
-		}
-		/*
-		 * For every charge from the cgroup, increment reference count
-		 */
-		css_get(&mem->css);
+	mem = *memcg;
+	if (likely(!mem)) {
+		mem = try_get_mem_cgroup_from_mm(mm);
 		*memcg = mem;
-		rcu_read_unlock();
 	} else {
-		mem = *memcg;
 		css_get(&mem->css);
 	}
+	if (unlikely(!mem))
+		return 0;
+
+	VM_BUG_ON(mem_cgroup_is_obsolete(mem));
 
 	while (1) {
 		int ret;
@@ -1065,12 +1084,19 @@ int mem_cgroup_cache_charge(struct page 
 				MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
 }
 
+/*
+ * While swap-in, try_charge -> commit or cancel, the page is locked.
+ * And when try_charge() successfully returns, one refcnt to memcg without
+ * struct page_cgroup is aquired. This refcnt will be cumsumed by
+ * "commit()" or removed by "cancel()"
+ */
 int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 				 struct page *page,
 				 gfp_t mask, struct mem_cgroup **ptr)
 {
 	struct mem_cgroup *mem;
 	swp_entry_t     ent;
+	int ret;
 
 	if (mem_cgroup_disabled())
 		return 0;
@@ -1089,10 +1115,15 @@ int mem_cgroup_try_charge_swapin(struct 
 	ent.val = page_private(page);
 
 	mem = lookup_swap_cgroup(ent);
-	if (!mem || mem->obsolete)
+	if (!mem)
+		goto charge_cur_mm;
+	if (!css_tryget(&mem->css))
 		goto charge_cur_mm;
 	*ptr = mem;
-	return __mem_cgroup_try_charge(NULL, mask, ptr, true);
+	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true);
+	/* drop extra refcnt from tryget */
+	css_put(&mem->css);
+	return ret;
 charge_cur_mm:
 	if (unlikely(!mm))
 		mm = &init_mm;
@@ -1123,13 +1154,18 @@ int mem_cgroup_cache_charge_swapin(struc
 		ent.val = page_private(page);
 		if (do_swap_account) {
 			mem = lookup_swap_cgroup(ent);
-			if (mem && mem->obsolete)
-				mem = NULL;
-			if (mem)
-				mm = NULL;
+			if (mem) {
+				if (css_tryget(&mem->css))
+					mm = NULL; /* charge to recorded */
+				else
+					mem = NULL; /* charge to current */
+			}
 		}
 		ret = mem_cgroup_charge_common(page, mm, mask,
 				MEM_CGROUP_CHARGE_TYPE_SHMEM, mem);
+		/* drop extra refcnt from tryget */
+		if (mem)
+			css_put(&mem->css);
 
 		if (!ret && do_swap_account) {
 			/* avoid double counting */
@@ -1171,7 +1207,6 @@ void mem_cgroup_commit_charge_swapin(str
 		struct mem_cgroup *memcg;
 		memcg = swap_cgroup_record(ent, NULL);
 		if (memcg) {
-			/* If memcg is obsolete, memcg can be != ptr */
 			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
 			mem_cgroup_put(memcg);
 		}
@@ -1414,14 +1449,9 @@ int mem_cgroup_shrink_usage(struct mm_st
 	if (!mm)
 		return 0;
 
-	rcu_read_lock();
-	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-	if (unlikely(!mem)) {
-		rcu_read_unlock();
+	mem = try_get_mem_cgroup_from_mm(mm);
+	if (unlikely(!mem))
 		return 0;
-	}
-	css_get(&mem->css);
-	rcu_read_unlock();
 
 	do {
 		progress = mem_cgroup_hierarchical_reclaim(mem, gfp_mask, true);
@@ -2079,9 +2109,6 @@ static struct mem_cgroup *mem_cgroup_all
  * the number of reference from swap_cgroup and free mem_cgroup when
  * it goes down to 0.
  *
- * When mem_cgroup is destroyed, mem->obsolete will be set to 0 and
- * entry which points to this memcg will be ignore at swapin.
- *
  * Removal of cgroup itself succeeds regardless of refs from swap.
  */
 
@@ -2167,7 +2194,6 @@ static void mem_cgroup_pre_destroy(struc
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
