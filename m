Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA49QPS5019235
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 4 Nov 2008 18:26:25 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0602B45DD79
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 18:26:25 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D0DDD45DD78
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 18:26:24 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id AE7411DB8038
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 18:26:24 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 5355B1DB8037
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 18:26:21 +0900 (JST)
Date: Tue, 4 Nov 2008 18:25:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [patch 1/2] memcg: hierarchy, yet another one.
Message-Id: <20081104182547.4de8730a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081101184812.2575.68112.sendpatchset@balbir-laptop>
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Support for hierarchical memory/mem+swap limit management.
Major difference is "shared LRU". and hierarchy-per-subtree.

may cause panic or deadlock ;)

=
This patch adds hierarchy support for memcg's LRU management.

Working like following.

     /root
       |
       |-group_A  hierarchy = 1
       |   |- App_1
       |   |- App_2
       |
       |-group_B  hierarchy = 0.
           |- App_3
           |- App_4

 * group_A and App_1 and App_2 shares LRU and each one has its own limit.
   If group_A hits its limit, memory is reclaimed from group_A, App_1, App_2.
   If App_1 hits its limit, memory is reclaimed from App_1.

 * group_B and App_3 and App_4 has its own LRU and its own limit.
   if group_B hits its limit, memory is reclaimed from group_B itself.
   if App_3 hits its limit, memory is reclaimed from App_3.

 For sharing LRU, App_1 and App_2 use the LRU of group_A. They really shares
 LRU. group_B and App_3 and App_3 doesn't share anything and has its own.

 For reclaiming memory from share LRU, this works as following.
 Assume following hierachcal tree.

   group_W
     |- group_X
          |- group_Y1
               |- group_Z1
	       |- group_Z2
          |- group_Y2
               |- group_A

  All pages of W,X,Y1,Z1,Z2,Y2,A is on a LRU.

  When we hit limit in group Y1, tree is marked as following.

   group_W
     |- group_X
          |- group_Y1 (*)
               |- group_Z1 (*)
               |- group_Z2 (*)
          |- group_Y2
               |- group_A

  We reclaim memory from group Y1, Z1, Z2.

  When we hit limit in group X, tree is marked as following.

   group_W
     |- group_X (*)
          |- group_Y1 (*)
               |- group_Z1 (*)
               |- group_Z2 (*)
          |- group_Y2 (*)
               |- group_A (*)

  We reclaim memory from group Y1, Z1, Z2, Y2, A.

  Because all group under a hierarchy shares LRU, "which memory should be
  reclaimed ?" is not so far from global LRU's one.

  Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |  265 ++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 221 insertions(+), 44 deletions(-)

Index: mmotm-2.6.28-rc2+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-rc2+.orig/mm/memcontrol.c
+++ mmotm-2.6.28-rc2+/mm/memcontrol.c
@@ -150,6 +150,12 @@ struct mem_cgroup {
 	 */
 	int	prev_priority;	/* for recording reclaim priority */
 	/*
+	 * For supporing multilevel memory reclaim.
+	 */
+	int		is_root; /* This cgroup is the master of LRU */
+	int		use_hierarchy; /* This cgroup is under some hierarchy */
+	atomic_t	in_reclaim; /* This cgroup is the target of reclaim */
+	/*
 	 * used for counting reference from swap_cgroup.
 	 */
 	int		obsolete;
@@ -158,6 +164,18 @@ struct mem_cgroup {
 
 static struct mem_cgroup init_mem_cgroup;
 
+
+static struct mem_cgroup *mem_cgroup_from_res(struct res_counter *res)
+{
+	return container_of(res, struct mem_cgroup, res);
+}
+
+static struct mem_cgroup *mem_cgroup_from_memsw(struct res_counter *res)
+{
+	return container_of(res, struct mem_cgroup, memsw);
+}
+
+
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
@@ -186,6 +204,8 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 #define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
 #define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
+/* Special File Name */
+#define MEMCG_FILE_HIERARCHY	(0xab01)
 
 static void mem_cgroup_forget_swapref(struct mem_cgroup *mem);
 
@@ -452,6 +472,9 @@ unsigned long mem_cgroup_isolate_pages(u
 		if (unlikely(!PageLRU(page)))
 			continue;
 
+		/* Is this target of this reclaim ? */
+		if (!atomic_read(&pc->mem_cgroup->in_reclaim))
+			continue;
 		scan++;
 		if (__isolate_lru_page(page, mode, file) == 0) {
 			list_move(&page->lru, dst);
@@ -463,6 +486,56 @@ unsigned long mem_cgroup_isolate_pages(u
 	return nr_taken;
 }
 
+static void inc_dec_reclaim_counter(struct cgroup *cg, bool set)
+{
+	struct cgroup *tmp;
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cg);
+
+	if (set)
+		atomic_inc(&mem->in_reclaim);
+	else
+		atomic_dec(&mem->in_reclaim);
+
+	if (!list_empty(&cg->children)) {
+	    list_for_each_entry(tmp, &cg->children, sibling)
+		    inc_dec_reclaim_counter(tmp, set);
+	}
+}
+
+
+static void set_hierarchy_mask(struct mem_cgroup *mem,
+			      struct mem_cgroup *root, bool set)
+{
+	/*
+	 * we recalaim memory from all cgroups under "fail".
+	 * set target marker to them
+	 */
+	/* SHOULD BE FIXED: Need some magic to avoid this mutex.... */
+	cgroup_lock();
+	inc_dec_reclaim_counter(root->css.cgroup, set);
+	cgroup_unlock();
+}
+
+static int __try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
+					  gfp_t gfp_mask, bool noswap,
+					  struct mem_cgroup *root)
+{
+	int ret;
+
+	atomic_inc(&mem->in_reclaim);
+	/* If we already get cgroup_lock(), root must be NULL */
+	if (mem->use_hierarchy && root)
+		set_hierarchy_mask(mem, root, true);
+
+	ret = try_to_free_mem_cgroup_pages(mem, gfp_mask, noswap);
+
+	if (mem->use_hierarchy && root)
+		set_hierarchy_mask(mem, root, false);
+
+	atomic_dec(&mem->in_reclaim);
+
+	return ret;
+}
 /*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
  * oom-killer can be invoked.
@@ -499,22 +572,31 @@ static int __mem_cgroup_try_charge(struc
 	while (1) {
 		int ret;
 		bool noswap = false;
+		struct res_counter *hit;
+		struct mem_cgroup *fail;
 
-		ret = res_counter_charge(&mem->res, PAGE_SIZE);
+		ret = res_counter_charge_hierarchy(&mem->res, PAGE_SIZE, &hit);
 		if (likely(!ret)) {
 			if (!do_swap_account)
 				break;
-			ret = res_counter_charge(&mem->memsw, PAGE_SIZE);
+			ret = res_counter_charge_hierarchy(&mem->memsw,
+						PAGE_SIZE, &hit);
 			if (likely(!ret))
 				break;
+			fail = mem_cgroup_from_memsw(hit);
 			/* mem+swap counter fails */
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
+			res_counter_uncharge_hierarchy(&mem->res, PAGE_SIZE);
 			noswap = true;
-		}
+
+		} else
+			fail = mem_cgroup_from_res(hit);
+
 		if (!(gfp_mask & __GFP_WAIT))
 			goto nomem;
 
-		if (try_to_free_mem_cgroup_pages(mem, gfp_mask, noswap))
+
+		if (__try_to_free_mem_cgroup_pages(mem, gfp_mask,
+						   noswap, fail))
 			continue;
 
 		/*
@@ -579,9 +661,9 @@ static void __mem_cgroup_commit_charge(s
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		res_counter_uncharge_hierarchy(&mem->res, PAGE_SIZE);
 		if (do_swap_account)
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+			res_counter_uncharge_hierarchy(&mem->memsw, PAGE_SIZE);
 		css_put(&mem->css);
 		return;
 	}
@@ -635,10 +717,10 @@ static int mem_cgroup_move_account(struc
 		goto out;
 
 	css_put(&from->css);
-	res_counter_uncharge(&from->res, PAGE_SIZE);
+	res_counter_uncharge_hierarchy(&from->res, PAGE_SIZE);
 	mem_cgroup_charge_statistics(from, pc, false);
 	if (do_swap_account)
-		res_counter_uncharge(&from->memsw, PAGE_SIZE);
+		res_counter_uncharge_hierarchy(&from->memsw, PAGE_SIZE);
 	pc->mem_cgroup = to;
 	mem_cgroup_charge_statistics(to, pc, true);
 	css_get(&to->css);
@@ -687,15 +769,16 @@ static int mem_cgroup_move_parent(struct
 	/* drop extra refcnt by try_charge() (move_account increment one) */
 	css_put(&parent->css);
 	putback_lru_page(page);
+
 	if (!ret) {
 		put_page(page);
 		return 0;
 	}
 	/* uncharge if move fails */
 cancel:
-	res_counter_uncharge(&parent->res, PAGE_SIZE);
+	res_counter_uncharge_hierarchy(&parent->res, PAGE_SIZE);
 	if (do_swap_account)
-		res_counter_uncharge(&parent->memsw, PAGE_SIZE);
+		res_counter_uncharge_hierarchy(&parent->memsw, PAGE_SIZE);
 	put_page(page);
 	return ret;
 }
@@ -857,7 +940,7 @@ int mem_cgroup_cache_charge_swapin(struc
 		 */
 		mem = swap_cgroup_record(ent, NULL);
 		if (mem) {
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+			res_counter_uncharge_hierarchy(&mem->memsw, PAGE_SIZE);
 			mem_cgroup_forget_swapref(mem);
 		}
 	}
@@ -892,7 +975,8 @@ void mem_cgroup_commit_charge_swapin(str
 		memcg = swap_cgroup_record(ent, NULL);
 		if (memcg) {
 			/* If memcg is obsolete, memcg can be != ptr */
-			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+			res_counter_uncharge_hierarchy(&memcg->memsw,
+							PAGE_SIZE);
 			mem_cgroup_forget_swapref(memcg);
 		}
 
@@ -906,8 +990,8 @@ void mem_cgroup_cancel_charge_swapin(str
 		return;
 	if (!mem)
 		return;
-	res_counter_uncharge(&mem->res, PAGE_SIZE);
-	res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+	res_counter_uncharge_hierarchy(&mem->res, PAGE_SIZE);
+	res_counter_uncharge_hierarchy(&mem->memsw, PAGE_SIZE);
 	css_put(&mem->css);
 }
 
@@ -958,9 +1042,9 @@ __mem_cgroup_uncharge_common(struct page
 		break;
 	}
 
-	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	res_counter_uncharge_hierarchy(&mem->res, PAGE_SIZE);
 	if (do_swap_account && (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
-		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+		res_counter_uncharge_hierarchy(&mem->memsw, PAGE_SIZE);
 
 	mem_cgroup_charge_statistics(mem, pc, false);
 	ClearPageCgroupUsed(pc);
@@ -1025,7 +1109,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
 
 	memcg = swap_cgroup_record(ent, NULL);
 	if (memcg) {
-		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+		res_counter_uncharge_hierarchy(&memcg->memsw, PAGE_SIZE);
 		mem_cgroup_forget_swapref(memcg);
 	}
 }
@@ -1119,9 +1203,10 @@ void mem_cgroup_end_migration(struct mem
  */
 int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *mem, *root;
 	int progress = 0;
 	int retry = MEM_CGROUP_RECLAIM_RETRIES;
+	struct res_counter *hit;
 
 	if (mem_cgroup_subsys.disabled)
 		return 0;
@@ -1136,10 +1221,13 @@ int mem_cgroup_shrink_usage(struct mm_st
 	}
 	css_get(&mem->css);
 	rcu_read_unlock();
-
+	root = mem;
 	do {
-		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask, true);
-		progress += res_counter_check_under_limit(&mem->res);
+		progress = __try_to_free_mem_cgroup_pages(mem,
+					gfp_mask, true, root);
+		progress += res_counter_check_under_limit_hierarchy(&mem->res,
+					&hit);
+		root = mem_cgroup_from_res(hit);
 	} while (!progress && --retry);
 
 	css_put(&mem->css);
@@ -1164,8 +1252,9 @@ int mem_cgroup_resize_limit(struct mem_c
 			ret = -EBUSY;
 			break;
 		}
-		progress = try_to_free_mem_cgroup_pages(memcg,
-				GFP_HIGHUSER_MOVABLE, false);
+		/* reclaim memory from all children. */
+		progress = __try_to_free_mem_cgroup_pages(memcg,
+					  GFP_HIGHUSER_MOVABLE, false, memcg);
 		if (!progress)
 			retry_count--;
 	}
@@ -1206,7 +1295,8 @@ int mem_cgroup_resize_memsw_limit(struct
 
 		if (!ret)
 			break;
-		try_to_free_mem_cgroup_pages(memcg, GFP_HIGHUSER_MOVABLE, true);
+		__try_to_free_mem_cgroup_pages(memcg,
+				       GFP_HIGHUSER_MOVABLE, true, memcg);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		if (curusage >= oldusage)
 			retry_count--;
@@ -1243,16 +1333,25 @@ static int mem_cgroup_force_empty_list(s
 			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			break;
 		}
-		pc = list_entry(list->prev, struct page_cgroup, lru);
+		list_for_each_entry(pc, list, lru) {
+			/* check is not done under lock. fixed up later */
+			if (pc->mem_cgroup == mem)
+				break;
+		}
+		if (&pc->lru == list) { /* empty ? */
+			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			break;
+		}
 		if (busy == pc) {
-			list_move(&pc->lru, list);
-			busy = 0;
+			list_move_tail(&pc->lru, list);
+			busy = NULL;
 			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			continue;
 		}
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
 		ret = mem_cgroup_move_parent(pc, mem, GFP_HIGHUSER_MOVABLE);
+
 		if (ret == -ENOMEM)
 			break;
 
@@ -1264,8 +1363,6 @@ static int mem_cgroup_force_empty_list(s
 			busy = NULL;
 	}
 
-	if (!ret && !list_empty(list))
-		return -EBUSY;
 	return ret;
 }
 
@@ -1287,7 +1384,8 @@ move_account:
 		ret = -EBUSY;
 		if (atomic_read(&mem->css.cgroup->count) > 0)
 			goto out;
-
+		if (signal_pending(current))
+			goto out;
 		/* This is for making all *used* pages to be on LRU. */
 		lru_add_drain_all();
 		ret = 0;
@@ -1324,8 +1422,8 @@ try_to_free:
 	shrink = 1;
 	while (nr_retries && mem->res.usage > 0) {
 		int progress;
-		progress = try_to_free_mem_cgroup_pages(mem,
-						  GFP_HIGHUSER_MOVABLE, false);
+		progress = __try_to_free_mem_cgroup_pages(mem,
+					  GFP_HIGHUSER_MOVABLE, false, NULL);
 		if (!progress)
 			nr_retries--;
 
@@ -1346,6 +1444,10 @@ static u64 mem_cgroup_read(struct cgroup
 
 	type = MEMFILE_TYPE(cft->private);
 	name = MEMFILE_ATTR(cft->private);
+	/* something special ? */
+	if (name == MEMCG_FILE_HIERARCHY) {
+		return mem->use_hierarchy;
+	}
 	switch (type) {
 	case _MEM:
 		val = res_counter_read_u64(&mem->res, name);
@@ -1360,6 +1462,28 @@ static u64 mem_cgroup_read(struct cgroup
 	}
 	return val;
 }
+
+
+static int mem_cgroup_set_hierarchy(struct mem_cgroup *mem,
+                                     unsigned long long val)
+{
+	struct cgroup *cg = mem->css.cgroup;
+	int ret = 0;
+
+	cgroup_lock();
+	if (!list_empty(&cg->children)) {
+		ret =  -EBUSY;
+	} else {
+		if (val)
+			mem->use_hierarchy = 1;
+		else
+			mem->use_hierarchy = 0;
+	}
+	cgroup_unlock();
+
+	return ret;
+}
+
 /*
  * The user of this function is...
  * RES_LIMIT.
@@ -1385,6 +1509,12 @@ static int mem_cgroup_write(struct cgrou
 		else
 			ret = mem_cgroup_resize_memsw_limit(memcg, val);
 		break;
+	case MEMCG_FILE_HIERARCHY:
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (ret)
+			break;
+		ret = mem_cgroup_set_hierarchy(memcg, val);
+		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
 		break;
@@ -1441,8 +1571,11 @@ static int mem_control_stat_show(struct 
 		val *= mem_cgroup_stat_desc[i].unit;
 		cb->fill(cb, mem_cgroup_stat_desc[i].msg, val);
 	}
-	/* showing # of active pages */
-	{
+	/*
+	 * showing # of active pages if it's root cgroup of hierarchy.
+	 * LRU is shared under a tree.
+	 */
+	if (mem_cont->is_root) {
 		unsigned long active_anon, inactive_anon;
 		unsigned long active_file, inactive_file;
 		unsigned long unevictable;
@@ -1499,6 +1632,12 @@ static struct cftype mem_cgroup_files[] 
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
+	{
+		.name = "hierarchy",
+		.private = MEMCG_FILE_HIERARCHY,
+		.write_string = mem_cgroup_write,
+		.read_u64  = mem_cgroup_read,
+	},
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 	{
 		.name = "memsw.usage_in_bytes",
@@ -1562,6 +1701,19 @@ static void free_mem_cgroup_per_zone_inf
 	kfree(mem->info.nodeinfo[node]);
 }
 
+static void mem_cgroup_share_node_info(struct mem_cgroup *mem,
+				       struct mem_cgroup *parent)
+{
+	struct mem_cgroup_per_node *pn;
+	int node;
+
+	for_each_node_state(node, N_POSSIBLE) {
+		pn = parent->info.nodeinfo[node];
+		if (pn)
+			mem->info.nodeinfo[node] = pn;
+	}
+}
+
 static struct mem_cgroup *mem_cgroup_alloc(void)
 {
 	struct mem_cgroup *mem;
@@ -1599,9 +1751,10 @@ static void mem_cgroup_free(struct mem_c
 			return;
 	}
 
-
-	for_each_node_state(node, N_POSSIBLE)
-		free_mem_cgroup_per_zone_info(mem, node);
+	if (mem->is_root) {
+		for_each_node_state(node, N_POSSIBLE)
+			free_mem_cgroup_per_zone_info(mem, node);
+	}
 
 	if (sizeof(*mem) < PAGE_SIZE)
 		kfree(mem);
@@ -1636,24 +1789,48 @@ static void __init enable_swap_cgroup(vo
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *mem, *parent;
 	int node;
 
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
 		enable_swap_cgroup();
+		parent = NULL;
+		atomic_set(&mem->in_reclaim, 0);
 	} else {
 		mem = mem_cgroup_alloc();
 		if (!mem)
 			return ERR_PTR(-ENOMEM);
+		parent = mem_cgroup_from_cont(cont->parent);
 	}
 
-	res_counter_init(&mem->res);
-	res_counter_init(&mem->memsw);
+	/* If parent uses hierarchy, children do. */
+	if (parent)
+		mem->use_hierarchy = parent->use_hierarchy;
+	else /* default is no hierarchy */
+		mem->use_hierarchy = 0;
 
-	for_each_node_state(node, N_POSSIBLE)
-		if (alloc_mem_cgroup_per_zone_info(mem, node))
-			goto free_out;
+	if (!mem->use_hierarchy) {
+		mem->is_root = 1;
+		parent = NULL;
+		res_counter_init(&mem->res);
+		res_counter_init(&mem->memsw);
+	} else {
+		res_counter_init_hierarchy(&mem->res, &parent->res);
+		res_counter_init_hierarchy(&mem->memsw, &parent->memsw);
+	}
+	/*
+	 * If this memcg is hierarchy root, use its own LRU.
+	 * If not, share parent's(root's) one.
+	 */
+	if (mem->is_root) {
+		for_each_node_state(node, N_POSSIBLE)
+			if (alloc_mem_cgroup_per_zone_info(mem, node))
+				goto free_out;
+	} else {
+		for_each_node_state(node, N_POSSIBLE)
+			mem_cgroup_share_node_info(mem, parent);
+	}
 
 	return &mem->css;
 free_out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
