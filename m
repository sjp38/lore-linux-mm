Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 182266B0039
	for <linux-mm@kvack.org>; Sat, 20 Sep 2014 16:00:50 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id fb4so1066106wid.3
        for <linux-mm@kvack.org>; Sat, 20 Sep 2014 13:00:50 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w7si6301892wja.61.2014.09.20.13.00.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Sep 2014 13:00:49 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/3] mm: memcontrol: continue cache reclaim from offlined groups
Date: Sat, 20 Sep 2014 16:00:35 -0400
Message-Id: <1411243235-24680-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1411243235-24680-1-git-send-email-hannes@cmpxchg.org>
References: <1411243235-24680-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On cgroup deletion, outstanding page cache charges are moved to the
parent group so that they're not lost and can be reclaimed during
pressure on/inside said parent.  But this reparenting is fairly tricky
and its synchroneous nature has led to several lock-ups in the past.

Since css iterators now also include offlined css, memcg iterators can
be changed to include offlined children during reclaim of a group, and
leftover cache can just stay put.

There is a slight change of behavior in that charges of deleted groups
no longer show up as local charges in the parent.  But they are still
included in the parent's hierarchical statistics.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 260 ++------------------------------------------------------
 1 file changed, 5 insertions(+), 255 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 019a44ac25d6..48531433a2fc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -736,8 +736,6 @@ static void disarm_static_keys(struct mem_cgroup *memcg)
 	disarm_kmem_keys(memcg);
 }
 
-static void drain_all_stock_async(struct mem_cgroup *memcg);
-
 static struct mem_cgroup_per_zone *
 mem_cgroup_zone_zoneinfo(struct mem_cgroup *memcg, struct zone *zone)
 {
@@ -1208,7 +1206,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				goto out_unlock;
 			continue;
 		}
-		if (css == &root->css || css_tryget_online(css)) {
+		if (css == &root->css || css_tryget(css)) {
 			memcg = mem_cgroup_from_css(css);
 			break;
 		}
@@ -2349,10 +2347,12 @@ static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
  * of the hierarchy under it. sync flag says whether we should block
  * until the work is done.
  */
-static void drain_all_stock(struct mem_cgroup *root_memcg, bool sync)
+static void drain_all_stock(struct mem_cgroup *root_memcg)
 {
 	int cpu, curcpu;
 
+	if (!mutex_trylock(&percpu_charge_mutex))
+		return;
 	/* Notify other cpus that system-wide "drain" is running */
 	get_online_cpus();
 	curcpu = get_cpu();
@@ -2373,41 +2373,7 @@ static void drain_all_stock(struct mem_cgroup *root_memcg, bool sync)
 		}
 	}
 	put_cpu();
-
-	if (!sync)
-		goto out;
-
-	for_each_online_cpu(cpu) {
-		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
-		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
-			flush_work(&stock->work);
-	}
-out:
 	put_online_cpus();
-}
-
-/*
- * Tries to drain stocked charges in other cpus. This function is asynchronous
- * and just put a work per cpu for draining localy on each cpu. Caller can
- * expects some charges will be back later but cannot wait for it.
- */
-static void drain_all_stock_async(struct mem_cgroup *root_memcg)
-{
-	/*
-	 * If someone calls draining, avoid adding more kworker runs.
-	 */
-	if (!mutex_trylock(&percpu_charge_mutex))
-		return;
-	drain_all_stock(root_memcg, false);
-	mutex_unlock(&percpu_charge_mutex);
-}
-
-/* This is a synchronous drain interface. */
-static void drain_all_stock_sync(struct mem_cgroup *root_memcg)
-{
-	/* called when force_empty is called */
-	mutex_lock(&percpu_charge_mutex);
-	drain_all_stock(root_memcg, true);
 	mutex_unlock(&percpu_charge_mutex);
 }
 
@@ -2515,7 +2481,7 @@ retry:
 		goto retry;
 
 	if (!drained) {
-		drain_all_stock_async(mem_over_limit);
+		drain_all_stock(mem_over_limit);
 		drained = true;
 		goto retry;
 	}
@@ -3366,79 +3332,6 @@ out:
 	return ret;
 }
 
-/**
- * mem_cgroup_move_parent - moves page to the parent group
- * @page: the page to move
- * @pc: page_cgroup of the page
- * @child: page's cgroup
- *
- * move charges to its parent or the root cgroup if the group has no
- * parent (aka use_hierarchy==0).
- * Although this might fail (get_page_unless_zero, isolate_lru_page or
- * mem_cgroup_move_account fails) the failure is always temporary and
- * it signals a race with a page removal/uncharge or migration. In the
- * first case the page is on the way out and it will vanish from the LRU
- * on the next attempt and the call should be retried later.
- * Isolation from the LRU fails only if page has been isolated from
- * the LRU since we looked at it and that usually means either global
- * reclaim or migration going on. The page will either get back to the
- * LRU or vanish.
- * Finaly mem_cgroup_move_account fails only if the page got uncharged
- * (!PageCgroupUsed) or moved to a different group. The page will
- * disappear in the next attempt.
- */
-static int mem_cgroup_move_parent(struct page *page,
-				  struct page_cgroup *pc,
-				  struct mem_cgroup *child)
-{
-	struct mem_cgroup *parent;
-	unsigned int nr_pages;
-	unsigned long uninitialized_var(flags);
-	int ret;
-
-	VM_BUG_ON(mem_cgroup_is_root(child));
-
-	ret = -EBUSY;
-	if (!get_page_unless_zero(page))
-		goto out;
-	if (isolate_lru_page(page))
-		goto put;
-
-	nr_pages = hpage_nr_pages(page);
-
-	parent = parent_mem_cgroup(child);
-	/*
-	 * If no parent, move charges to root cgroup.
-	 */
-	if (!parent)
-		parent = root_mem_cgroup;
-
-	if (nr_pages > 1) {
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-		flags = compound_lock_irqsave(page);
-	}
-
-	ret = mem_cgroup_move_account(page, nr_pages,
-				pc, child, parent);
-	if (!ret) {
-		if (!mem_cgroup_is_root(parent))
-			css_get_many(&parent->css, nr_pages);
-		/* Take charge off the local counters */
-		page_counter_cancel(&child->memory, nr_pages);
-		if (do_swap_account)
-			page_counter_cancel(&child->memsw, nr_pages);
-		css_put_many(&child->css, nr_pages);
-	}
-
-	if (nr_pages > 1)
-		compound_unlock_irqrestore(page, flags);
-	putback_lru_page(page);
-put:
-	put_page(page);
-out:
-	return ret;
-}
-
 #ifdef CONFIG_MEMCG_SWAP
 static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
 					 bool charge)
@@ -3732,105 +3625,6 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 	return nr_reclaimed;
 }
 
-/**
- * mem_cgroup_force_empty_list - clears LRU of a group
- * @memcg: group to clear
- * @node: NUMA node
- * @zid: zone id
- * @lru: lru to to clear
- *
- * Traverse a specified page_cgroup list and try to drop them all.  This doesn't
- * reclaim the pages page themselves - pages are moved to the parent (or root)
- * group.
- */
-static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
-				int node, int zid, enum lru_list lru)
-{
-	struct lruvec *lruvec;
-	unsigned long flags;
-	struct list_head *list;
-	struct page *busy;
-	struct zone *zone;
-
-	zone = &NODE_DATA(node)->node_zones[zid];
-	lruvec = mem_cgroup_zone_lruvec(zone, memcg);
-	list = &lruvec->lists[lru];
-
-	busy = NULL;
-	do {
-		struct page_cgroup *pc;
-		struct page *page;
-
-		spin_lock_irqsave(&zone->lru_lock, flags);
-		if (list_empty(list)) {
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
-			break;
-		}
-		page = list_entry(list->prev, struct page, lru);
-		if (busy == page) {
-			list_move(&page->lru, list);
-			busy = NULL;
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
-			continue;
-		}
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
-
-		pc = lookup_page_cgroup(page);
-
-		if (mem_cgroup_move_parent(page, pc, memcg)) {
-			/* found lock contention or "pc" is obsolete. */
-			busy = page;
-		} else
-			busy = NULL;
-		cond_resched();
-	} while (!list_empty(list));
-}
-
-/*
- * make mem_cgroup's charge to be 0 if there is no task by moving
- * all the charges and pages to the parent.
- * This enables deleting this mem_cgroup.
- *
- * Caller is responsible for holding css reference on the memcg.
- */
-static void mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
-{
-	int node, zid;
-
-	do {
-		/* This is for making all *used* pages to be on LRU. */
-		lru_add_drain_all();
-		drain_all_stock_sync(memcg);
-		mem_cgroup_start_move(memcg);
-		for_each_node_state(node, N_MEMORY) {
-			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-				enum lru_list lru;
-				for_each_lru(lru) {
-					mem_cgroup_force_empty_list(memcg,
-							node, zid, lru);
-				}
-			}
-		}
-		mem_cgroup_end_move(memcg);
-		memcg_oom_recover(memcg);
-		cond_resched();
-
-		/*
-		 * Kernel memory may not necessarily be trackable to a specific
-		 * process. So they are not migrated, and therefore we can't
-		 * expect their value to drop to 0 here.
-		 * Having res filled up with kmem only is enough.
-		 *
-		 * This is a safety check because mem_cgroup_force_empty_list
-		 * could have raced with mem_cgroup_replace_page_cache callers
-		 * so the lru seemed empty but the page could have been added
-		 * right after the check. RES_USAGE should be safe as we always
-		 * charge before adding to the LRU.
-		 */
-	} while (atomic_long_read(&memcg->memory.count) -
-		 atomic_long_read(&memcg->kmem.count) > 0);
-}
-
 /*
  * Test whether @memcg has children, dead or alive.  Note that this
  * function doesn't care whether @memcg has use_hierarchy enabled and
@@ -5359,7 +5153,6 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_event *event, *tmp;
-	struct cgroup_subsys_state *iter;
 
 	/*
 	 * Unregister events and notify userspace.
@@ -5373,13 +5166,6 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	}
 	spin_unlock(&memcg->event_list_lock);
 
-	/*
-	 * This requires that offlining is serialized.  Right now that is
-	 * guaranteed because css_killed_work_fn() holds the cgroup_mutex.
-	 */
-	css_for_each_descendant_post(iter, css)
-		mem_cgroup_reparent_charges(mem_cgroup_from_css(iter));
-
 	memcg_unregister_all_caches(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
 }
@@ -5387,42 +5173,6 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
-	/*
-	 * XXX: css_offline() would be where we should reparent all
-	 * memory to prepare the cgroup for destruction.  However,
-	 * memcg does not do css_tryget_online() and page_counter charging
-	 * under the same RCU lock region, which means that charging
-	 * could race with offlining.  Offlining only happens to
-	 * cgroups with no tasks in them but charges can show up
-	 * without any tasks from the swapin path when the target
-	 * memcg is looked up from the swapout record and not from the
-	 * current task as it usually is.  A race like this can leak
-	 * charges and put pages with stale cgroup pointers into
-	 * circulation:
-	 *
-	 * #0                        #1
-	 *                           lookup_swap_cgroup_id()
-	 *                           rcu_read_lock()
-	 *                           mem_cgroup_lookup()
-	 *                           css_tryget_online()
-	 *                           rcu_read_unlock()
-	 * disable css_tryget_online()
-	 * call_rcu()
-	 *   offline_css()
-	 *     reparent_charges()
-	 *                           page_counter_charge()
-	 *                           css_put()
-	 *                             css_free()
-	 *                           pc->mem_cgroup = dead memcg
-	 *                           add page to lru
-	 *
-	 * The bulk of the charges are still moved in offline_css() to
-	 * avoid pinning a lot of pages in case a long-term reference
-	 * like a swapout record is deferring the css_free() to long
-	 * after offlining.  But this makes sure we catch any charges
-	 * made after offlining:
-	 */
-	mem_cgroup_reparent_charges(memcg);
 
 	memcg_destroy_kmem(memcg);
 	__mem_cgroup_free(memcg);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
