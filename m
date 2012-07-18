Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id CEEB06B005D
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 07:09:15 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 18 Jul 2012 16:39:12 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6IB99aT5046774
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 16:39:09 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6IGdmU7029180
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 02:39:49 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2] mm/memcg: use exist interface to get css from memcg
Date: Wed, 18 Jul 2012 19:08:54 +0800
Message-Id: <1342609734-22437-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>

use exist interface mem_cgroup_css instead of &mem->css.

V2->V1:
* restore the mistake modify in mem_cgroup_css

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memcontrol.c |   89 ++++++++++++++++++++++++++++--------------------------
 1 files changed, 46 insertions(+), 43 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f72b5e5..f27084c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -645,7 +645,7 @@ retry:
 	 */
 	__mem_cgroup_remove_exceeded(mz->memcg, mz, mctz);
 	if (!res_counter_soft_limit_excess(&mz->memcg->res) ||
-		!css_tryget(&mz->memcg->css))
+		!css_tryget(mem_cgroup_css(mz->memcg)))
 		goto retry;
 done:
 	return mz;
@@ -899,7 +899,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 		memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
 		if (unlikely(!memcg))
 			break;
-	} while (!css_tryget(&memcg->css));
+	} while (!css_tryget(mem_cgroup_css(memcg)));
 	rcu_read_unlock();
 	return memcg;
 }
@@ -935,10 +935,10 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		root = root_mem_cgroup;
 
 	if (prev && !reclaim)
-		id = css_id(&prev->css);
+		id = css_id(mem_cgroup_css(prev));
 
 	if (prev && prev != root)
-		css_put(&prev->css);
+		css_put(mem_cgroup_css(prev));
 
 	if (!root->use_hierarchy && root != root_mem_cgroup) {
 		if (prev)
@@ -963,9 +963,10 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		}
 
 		rcu_read_lock();
-		css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
+		css = css_get_next(&mem_cgroup_subsys, id + 1,
+					mem_cgroup_css(root), &id);
 		if (css) {
-			if (css == &root->css || css_tryget(css))
+			if (css == mem_cgroup_css(root) || css_tryget(css))
 				memcg = container_of(css,
 						     struct mem_cgroup, css);
 		} else
@@ -997,7 +998,7 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
 	if (!root)
 		root = root_mem_cgroup;
 	if (prev && prev != root)
-		css_put(&prev->css);
+		css_put(mem_cgroup_css(prev));
 }
 
 /*
@@ -1150,7 +1151,8 @@ bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
 		return true;
 	if (!root_memcg->use_hierarchy || !memcg)
 		return false;
-	return css_is_ancestor(&memcg->css, &root_memcg->css);
+	return css_is_ancestor(mem_cgroup_css(memcg),
+				&root_memcg->css);
 }
 
 static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
@@ -1183,7 +1185,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
 		task_lock(task);
 		curr = mem_cgroup_from_task(task);
 		if (curr)
-			css_get(&curr->css);
+			css_get(mem_cgroup_css(curr));
 		task_unlock(task);
 	}
 	if (!curr)
@@ -1195,7 +1197,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
 	 * hierarchy(even if use_hierarchy is disabled in "memcg").
 	 */
 	ret = mem_cgroup_same_or_subtree(memcg, curr);
-	css_put(&curr->css);
+	css_put(mem_cgroup_css(curr));
 	return ret;
 }
 
@@ -1251,7 +1253,7 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
 
 int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 {
-	struct cgroup *cgrp = memcg->css.cgroup;
+	struct cgroup *cgrp = mem_cgroup_css(memcg)->cgroup;
 
 	/* root ? */
 	if (cgrp->parent == NULL)
@@ -1396,7 +1398,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 
 	rcu_read_lock();
 
-	mem_cgrp = memcg->css.cgroup;
+	mem_cgrp = mem_cgroup_css(memcg)->cgroup;
 	task_cgrp = task_cgroup(p, mem_cgroup_subsys_id);
 
 	ret = cgroup_path(task_cgrp, memcg_name, PATH_MAX);
@@ -2275,12 +2277,12 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 again:
 	if (*ptr) { /* css should be a valid one */
 		memcg = *ptr;
-		VM_BUG_ON(css_is_removed(&memcg->css));
+		VM_BUG_ON(css_is_removed(mem_cgroup_css(memcg)));
 		if (mem_cgroup_is_root(memcg))
 			goto done;
 		if (nr_pages == 1 && consume_stock(memcg))
 			goto done;
-		css_get(&memcg->css);
+		css_get(mem_cgroup_css(memcg));
 	} else {
 		struct task_struct *p;
 
@@ -2316,7 +2318,7 @@ again:
 			goto done;
 		}
 		/* after here, we may be blocked. we need to get refcnt */
-		if (!css_tryget(&memcg->css)) {
+		if (!css_tryget(mem_cgroup_css(memcg))) {
 			rcu_read_unlock();
 			goto again;
 		}
@@ -2328,7 +2330,7 @@ again:
 
 		/* If killed, bypass charge */
 		if (fatal_signal_pending(current)) {
-			css_put(&memcg->css);
+			css_put(mem_cgroup_css(memcg));
 			goto bypass;
 		}
 
@@ -2344,29 +2346,29 @@ again:
 			break;
 		case CHARGE_RETRY: /* not in OOM situation but retry */
 			batch = nr_pages;
-			css_put(&memcg->css);
+			css_put(mem_cgroup_css(memcg));
 			memcg = NULL;
 			goto again;
 		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
-			css_put(&memcg->css);
+			css_put(mem_cgroup_css(memcg));
 			goto nomem;
 		case CHARGE_NOMEM: /* OOM routine works */
 			if (!oom) {
-				css_put(&memcg->css);
+				css_put(mem_cgroup_css(memcg));
 				goto nomem;
 			}
 			/* If oom, we never return -ENOMEM */
 			nr_oom_retries--;
 			break;
 		case CHARGE_OOM_DIE: /* Killed by OOM Killer */
-			css_put(&memcg->css);
+			css_put(mem_cgroup_css(memcg));
 			goto bypass;
 		}
 	} while (ret != CHARGE_OK);
 
 	if (batch > nr_pages)
 		refill_stock(memcg, batch - nr_pages);
-	css_put(&memcg->css);
+	css_put(mem_cgroup_css(memcg));
 done:
 	*ptr = memcg;
 	return 0;
@@ -2445,14 +2447,14 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
 		memcg = pc->mem_cgroup;
-		if (memcg && !css_tryget(&memcg->css))
+		if (memcg && !css_tryget(mem_cgroup_css(memcg)))
 			memcg = NULL;
 	} else if (PageSwapCache(page)) {
 		ent.val = page_private(page);
 		id = lookup_swap_cgroup_id(ent);
 		rcu_read_lock();
 		memcg = mem_cgroup_lookup(id);
-		if (memcg && !css_tryget(&memcg->css))
+		if (memcg && !css_tryget(mem_cgroup_css(memcg)))
 			memcg = NULL;
 		rcu_read_unlock();
 	}
@@ -2795,7 +2797,7 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 		goto charge_cur_mm;
 	*memcgp = memcg;
 	ret = __mem_cgroup_try_charge(NULL, mask, 1, memcgp, true);
-	css_put(&memcg->css);
+	css_put(mem_cgroup_css(memcg));
 	if (ret == -EINTR)
 		ret = 0;
 	return ret;
@@ -2816,7 +2818,7 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *memcg,
 		return;
 	if (!memcg)
 		return;
-	cgroup_exclude_rmdir(&memcg->css);
+	cgroup_exclude_rmdir(mem_cgroup_css(memcg));
 
 	__mem_cgroup_commit_charge(memcg, page, 1, ctype, true);
 	/*
@@ -2835,7 +2837,7 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *memcg,
 	 * So, rmdir()->pre_destroy() can be called while we do this charge.
 	 * In that case, we need to call pre_destroy() again. check it here.
 	 */
-	cgroup_release_and_wakeup_rmdir(&memcg->css);
+	cgroup_release_and_wakeup_rmdir(mem_cgroup_css(memcg));
 }
 
 void mem_cgroup_commit_charge_swapin(struct page *page,
@@ -3083,7 +3085,7 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
 	 * mem_cgroup_get() was called in uncharge().
 	 */
 	if (do_swap_account && swapout && memcg)
-		swap_cgroup_record(ent, css_id(&memcg->css));
+		swap_cgroup_record(ent, css_id(mem_cgroup_css(memcg)));
 }
 #endif
 
@@ -3135,8 +3137,8 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
 {
 	unsigned short old_id, new_id;
 
-	old_id = css_id(&from->css);
-	new_id = css_id(&to->css);
+	old_id = css_id(mem_cgroup_css(from));
+	new_id = css_id(mem_cgroup_css(to));
 
 	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
 		mem_cgroup_swap_statistics(from, false);
@@ -3184,7 +3186,7 @@ int mem_cgroup_prepare_migration(struct page *page,
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
 		memcg = pc->mem_cgroup;
-		css_get(&memcg->css);
+		css_get(mem_cgroup_css(memcg));
 		/*
 		 * At migrating an anonymous page, its mapcount goes down
 		 * to 0 and uncharge() will be called. But, even if it's fully
@@ -3227,7 +3229,7 @@ int mem_cgroup_prepare_migration(struct page *page,
 
 	*memcgp = memcg;
 	ret = __mem_cgroup_try_charge(NULL, gfp_mask, 1, memcgp, false);
-	css_put(&memcg->css);/* drop extra refcnt */
+	css_put(mem_cgroup_css(memcg));/* drop extra refcnt */
 	if (ret) {
 		if (PageAnon(page)) {
 			lock_page_cgroup(pc);
@@ -3268,7 +3270,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 	if (!memcg)
 		return;
 	/* blocks rmdir() */
-	cgroup_exclude_rmdir(&memcg->css);
+	cgroup_exclude_rmdir(mem_cgroup_css(memcg));
 	if (!migration_ok) {
 		used = oldpage;
 		unused = newpage;
@@ -3306,7 +3308,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 	 * So, rmdir()->pre_destroy() can be called while we do this charge.
 	 * In that case, we need to call pre_destroy() again. check it here.
 	 */
-	cgroup_release_and_wakeup_rmdir(&memcg->css);
+	cgroup_release_and_wakeup_rmdir(mem_cgroup_css(memcg));
 }
 
 /*
@@ -3575,7 +3577,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 				next_mz =
 				__mem_cgroup_largest_soft_limit_node(mctz);
 				if (next_mz == mz)
-					css_put(&next_mz->memcg->css);
+					css_put(mem_cgroup_css(next_mz->memcg));
 				else /* next_mz == NULL or other memcg */
 					break;
 			} while (1);
@@ -3593,7 +3595,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 		/* If excess == 0, no tree ops */
 		__mem_cgroup_insert_exceeded(mz->memcg, mz, mctz, excess);
 		spin_unlock(&mctz->lock);
-		css_put(&mz->memcg->css);
+		css_put(mem_cgroup_css(mz->memcg));
 		loop++;
 		/*
 		 * Could not reclaim anything and there are no more
@@ -3606,7 +3608,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 			break;
 	} while (!nr_reclaimed);
 	if (next_mz)
-		css_put(&next_mz->memcg->css);
+		css_put(mem_cgroup_css(next_mz->memcg));
 	return nr_reclaimed;
 }
 
@@ -3679,9 +3681,9 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_all)
 	int ret;
 	int node, zid, shrink;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	struct cgroup *cgrp = memcg->css.cgroup;
+	struct cgroup *cgrp = mem_cgroup_css(memcg)->cgroup;
 
-	css_get(&memcg->css);
+	css_get(mem_cgroup_css(memcg));
 
 	shrink = 0;
 	/* should free all ? */
@@ -3722,7 +3724,7 @@ move_account:
 	/* "ret" should also be checked to ensure all lists are empty. */
 	} while (res_counter_read_u64(&memcg->res, RES_USAGE) > 0 || ret);
 out:
-	css_put(&memcg->css);
+	css_put(mem_cgroup_css(memcg));
 	return ret;
 
 try_to_free:
@@ -3933,7 +3935,7 @@ static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
 
 	min_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
 	min_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
-	cgroup = memcg->css.cgroup;
+	cgroup = mem_cgroup_css(memcg)->cgroup;
 	if (!memcg->use_hierarchy)
 		goto out;
 
@@ -4770,7 +4772,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	int node;
 
 	mem_cgroup_remove_from_trees(memcg);
-	free_css_id(&mem_cgroup_subsys, &memcg->css);
+	free_css_id(&mem_cgroup_subsys, mem_cgroup_css(memcg));
 
 	for_each_node(node)
 		free_mem_cgroup_per_zone_info(memcg, node);
@@ -4926,7 +4928,7 @@ mem_cgroup_create(struct cgroup *cont)
 		mem_cgroup_put(memcg);
 		return ERR_PTR(error);
 	}
-	return &memcg->css;
+	return mem_cgroup_css(memcg);
 free_out:
 	__mem_cgroup_free(memcg);
 	return ERR_PTR(error);
@@ -5145,7 +5147,8 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 	}
 	/* There is a swap entry and a page doesn't exist or isn't charged */
 	if (ent.val && !ret &&
-			css_id(&mc.from->css) == lookup_swap_cgroup_id(ent)) {
+			css_id(mem_cgroup_css(mc.from)) ==
+					lookup_swap_cgroup_id(ent)) {
 		ret = MC_TARGET_SWAP;
 		if (target)
 			target->ent = ent;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
