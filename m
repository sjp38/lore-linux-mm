Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id BF6DB6B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 11:47:41 -0400 (EDT)
Date: Fri, 9 Aug 2013 17:47:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [HEADSUP] conflicts between cgroup/for-3.12 and memcg
Message-ID: <20130809154737.GA25957@dhcp22.suse.cz>
References: <20130809003402.GC13427@mtj.dyndns.org>
 <20130809072207.GA16531@dhcp22.suse.cz>
 <20130809141933.GG20515@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="lrZ03NoBR/3+SXJZ"
Content-Disposition: inline
In-Reply-To: <20130809141933.GG20515@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri 09-08-13 10:19:33, Tejun Heo wrote:
> Hello, Michal.
> 
> On Fri, Aug 09, 2013 at 09:22:07AM +0200, Michal Hocko wrote:
> > I have just tried to merge cgroups/for-3.12 into my memcg tree and there
> > were some conflicts indeed. They are attached for reference. The
> > resolving is trivial. I've just picked up HEAD as all the conflicts are
> > for added resp. removed code in mmotm.
> 
> Oops, that's me messing up the branches.  I was trying to reset
> for-next but instead reset for-3.12 so that it didn't include the API
> updates.  Can you please try to rebase on top of the current for-3.12
> bd8815a6d802fc16a7a106e170593aa05dc17e72 ("cgroup: make
> css_for_each_descendant() and friends include the origin css in the
> iteration")?  At least the iterator update wouldn't be trivial, I
> think.

Very quick and untested attempt for resolving is attached. I will be
shortly offline and I am not sure how much I will be available during
weekend.

Andrew, if you prefer then drop the series and I will rebase it on top
of linux-next after Tejun's changes are merged and post it again early
next week.
-- 
Michal Hocko
SUSE Labs

--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="memcontrol.conflicts-resolved"

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b73988a..e8e313c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -474,10 +474,9 @@ enum res_type {
  */
 static DEFINE_MUTEX(memcg_create_mutex);
 
-static inline
 struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
 {
-	return container_of(s, struct mem_cgroup, css);
+	return s ? container_of(s, struct mem_cgroup, css) : NULL;
 }
 
 /* Some nice accessors for the vmpressure. */
@@ -910,12 +909,6 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 		preempt_enable();
 }
 
-struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
-{
-	return mem_cgroup_from_css(
-		cgroup_subsys_state(cont, mem_cgroup_subsys_id));
-}
-
 struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 {
 	/*
@@ -926,7 +919,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 	if (unlikely(!p))
 		return NULL;
 
-	return mem_cgroup_from_css(task_subsys_state(p, mem_cgroup_subsys_id));
+	return mem_cgroup_from_css(task_css(p, mem_cgroup_subsys_id));
 }
 
 struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
@@ -968,28 +961,11 @@ mem_cgroup_filter(struct mem_cgroup *memcg, struct mem_cgroup *root,
 static struct mem_cgroup *__mem_cgroup_iter_next(struct mem_cgroup *root,
 		struct mem_cgroup *last_visited, mem_cgroup_iter_filter cond)
 {
-	struct cgroup *prev_cgroup, *next_cgroup;
-
-	/*
-	 * Root is not visited by cgroup iterators so it needs an
-	 * explicit visit.
-	 */
-	if (!last_visited) {
-		switch (mem_cgroup_filter(root, root, cond)) {
-		case VISIT:
-			return root;
-		case SKIP:
-			break;
-		case SKIP_TREE:
-			return NULL;
-		}
-	}
+	struct cgroup_subsys_state *prev_css, *next_css;
 
-	prev_cgroup = (last_visited == root || !last_visited) ? NULL
-		: last_visited->css.cgroup;
+	prev_css = last_visited ? &last_visited->css : NULL;
 skip_node:
-	next_cgroup = cgroup_next_descendant_pre(
-			prev_cgroup, root->css.cgroup);
+	next_css = css_next_descendant_pre(prev_css, &root->css);
 
 	/*
 	 * Even if we found a group we have to make sure it is
@@ -998,15 +974,16 @@ skip_node:
 	 * last_visited css is safe to use because it is
 	 * protected by css_get and the tree walk is rcu safe.
 	 */
-	if (next_cgroup) {
-		struct mem_cgroup *mem = mem_cgroup_from_cont(
-				next_cgroup);
+	if (next_css) {
+		struct mem_cgroup *mem = mem_cgroup_from_css(next_css);
 
 		switch (mem_cgroup_filter(mem, root, cond)) {
 		case SKIP:
 			prev_cgroup = next_cgroup;
 			goto skip_node;
 		case SKIP_TREE:
+			if (mem == root)
+				return NULL;
 			/*
 			 * cgroup_rightmost_descendant is not an optimal way to
 			 * skip through a subtree (especially for imbalanced
@@ -1015,7 +992,7 @@ skip_node:
 			 * right-up for first non-NULL without calling
 			 * cgroup_next_descendant_pre afterwards.
 			 */
-			prev_cgroup = cgroup_rightmost_descendant(next_cgroup);
+			prev_css = css_rightmost_descendant(next_css);
 			goto skip_node;
 		case VISIT:
 			if (css_tryget(&mem->css))
@@ -1444,10 +1421,8 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
 
 int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 {
-	struct cgroup *cgrp = memcg->css.cgroup;
-
 	/* root ? */
-	if (cgrp->parent == NULL)
+	if (!css_parent(&memcg->css))
 		return vm_swappiness;
 
 	return memcg->swappiness;
@@ -1724,12 +1699,11 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
 	totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
-		struct cgroup *cgroup = iter->css.cgroup;
-		struct cgroup_iter it;
+		struct css_task_iter it;
 		struct task_struct *task;
 
-		cgroup_iter_start(cgroup, &it);
-		while ((task = cgroup_iter_next(cgroup, &it))) {
+		css_task_iter_start(&iter->css, &it);
+		while ((task = css_task_iter_next(&it))) {
 			switch (oom_scan_process_thread(task, totalpages, NULL,
 							false)) {
 			case OOM_SCAN_SELECT:
@@ -1742,7 +1716,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 			case OOM_SCAN_CONTINUE:
 				continue;
 			case OOM_SCAN_ABORT:
-				cgroup_iter_end(cgroup, &it);
+				css_task_iter_end(&it);
 				mem_cgroup_iter_break(memcg, iter);
 				if (chosen)
 					put_task_struct(chosen);
@@ -1759,7 +1733,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				get_task_struct(chosen);
 			}
 		}
-		cgroup_iter_end(cgroup, &it);
+		css_task_iter_end(&it);
 	}
 
 	if (!chosen)
@@ -2885,10 +2859,10 @@ static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
 }
 
 #ifdef CONFIG_SLABINFO
-static int mem_cgroup_slabinfo_read(struct cgroup *cont, struct cftype *cft,
-					struct seq_file *m)
+static int mem_cgroup_slabinfo_read(struct cgroup_subsys_state *css,
+				    struct cftype *cft, struct seq_file *m)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct memcg_cache_params *params;
 
 	if (!memcg_can_account_kmem(memcg))
@@ -4782,10 +4756,10 @@ static void mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
  */
 static inline bool __memcg_has_children(struct mem_cgroup *memcg)
 {
-	struct cgroup *pos;
+	struct cgroup_subsys_state *pos;
 
 	/* bounce at first found */
-	cgroup_for_each_child(pos, memcg->css.cgroup)
+	css_for_each_child(pos, &memcg->css)
 		return true;
 	return false;
 }
@@ -4841,9 +4815,10 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 	return 0;
 }
 
-static int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
+static int mem_cgroup_force_empty_write(struct cgroup_subsys_state *css,
+					unsigned int event)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
 	if (mem_cgroup_is_root(memcg))
 		return -EINVAL;
@@ -4851,21 +4826,18 @@ static int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
 }
 
 
-static u64 mem_cgroup_hierarchy_read(struct cgroup *cont, struct cftype *cft)
+static u64 mem_cgroup_hierarchy_read(struct cgroup_subsys_state *css,
+				     struct cftype *cft)
 {
-	return mem_cgroup_from_cont(cont)->use_hierarchy;
+	return mem_cgroup_from_css(css)->use_hierarchy;
 }
 
-static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
-					u64 val)
+static int mem_cgroup_hierarchy_write(struct cgroup_subsys_state *css,
+				      struct cftype *cft, u64 val)
 {
 	int retval = 0;
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
-	struct cgroup *parent = cont->parent;
-	struct mem_cgroup *parent_memcg = NULL;
-
-	if (parent)
-		parent_memcg = mem_cgroup_from_cont(parent);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	struct mem_cgroup *parent_memcg = mem_cgroup_from_css(css_parent(&memcg->css));
 
 	mutex_lock(&memcg_create_mutex);
 
@@ -4935,11 +4907,11 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 	return val << PAGE_SHIFT;
 }
 
-static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
-			       struct file *file, char __user *buf,
-			       size_t nbytes, loff_t *ppos)
+static ssize_t mem_cgroup_read(struct cgroup_subsys_state *css,
+			       struct cftype *cft, struct file *file,
+			       char __user *buf, size_t nbytes, loff_t *ppos)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	char str[64];
 	u64 val;
 	int name, len;
@@ -4972,11 +4944,11 @@ static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
 	return simple_read_from_buffer(buf, nbytes, ppos, str, len);
 }
 
-static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
+static int memcg_update_kmem_limit(struct cgroup_subsys_state *css, u64 val)
 {
 	int ret = -EINVAL;
 #ifdef CONFIG_MEMCG_KMEM
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	/*
 	 * For simplicity, we won't allow this to be disabled.  It also can't
 	 * be changed if the cgroup has children already, or if tasks had
@@ -4992,7 +4964,7 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 	mutex_lock(&memcg_create_mutex);
 	mutex_lock(&set_limit_mutex);
 	if (!memcg->kmem_account_flags && val != RES_COUNTER_MAX) {
-		if (cgroup_task_count(cont) || memcg_has_children(memcg)) {
+		if (cgroup_task_count(css->cgroup) || memcg_has_children(memcg)) {
 			ret = -EBUSY;
 			goto out;
 		}
@@ -5062,10 +5034,10 @@ out:
  * The user of this function is...
  * RES_LIMIT.
  */
-static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
+static int mem_cgroup_write(struct cgroup_subsys_state *css, struct cftype *cft,
 			    const char *buffer)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	enum res_type type;
 	int name;
 	unsigned long long val;
@@ -5089,7 +5061,7 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 		else if (type == _MEMSWAP)
 			ret = mem_cgroup_resize_memsw_limit(memcg, val);
 		else if (type == _KMEM)
-			ret = memcg_update_kmem_limit(cont, val);
+			ret = memcg_update_kmem_limit(css, val);
 		else
 			return -EINVAL;
 		break;
@@ -5117,18 +5089,15 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
 		unsigned long long *mem_limit, unsigned long long *memsw_limit)
 {
-	struct cgroup *cgroup;
 	unsigned long long min_limit, min_memsw_limit, tmp;
 
 	min_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
 	min_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
-	cgroup = memcg->css.cgroup;
 	if (!memcg->use_hierarchy)
 		goto out;
 
-	while (cgroup->parent) {
-		cgroup = cgroup->parent;
-		memcg = mem_cgroup_from_cont(cgroup);
+	while (css_parent(&memcg->css)) {
+		memcg = mem_cgroup_from_css(css_parent(&memcg->css));
 		if (!memcg->use_hierarchy)
 			break;
 		tmp = res_counter_read_u64(&memcg->res, RES_LIMIT);
@@ -5141,9 +5110,9 @@ out:
 	*memsw_limit = min_memsw_limit;
 }
 
-static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
+static int mem_cgroup_reset(struct cgroup_subsys_state *css, unsigned int event)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	int name;
 	enum res_type type;
 
@@ -5176,17 +5145,17 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 	return 0;
 }
 
-static u64 mem_cgroup_move_charge_read(struct cgroup *cgrp,
+static u64 mem_cgroup_move_charge_read(struct cgroup_subsys_state *css,
 					struct cftype *cft)
 {
-	return mem_cgroup_from_cont(cgrp)->move_charge_at_immigrate;
+	return mem_cgroup_from_css(css)->move_charge_at_immigrate;
 }
 
 #ifdef CONFIG_MMU
-static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
+static int mem_cgroup_move_charge_write(struct cgroup_subsys_state *css,
 					struct cftype *cft, u64 val)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
 	if (val >= (1 << NR_MOVE_TYPE))
 		return -EINVAL;
@@ -5201,7 +5170,7 @@ static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
 	return 0;
 }
 #else
-static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
+static int mem_cgroup_move_charge_write(struct cgroup_subsys_state *css,
 					struct cftype *cft, u64 val)
 {
 	return -ENOSYS;
@@ -5209,13 +5178,13 @@ static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
 #endif
 
 #ifdef CONFIG_NUMA
-static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
-				      struct seq_file *m)
+static int memcg_numa_stat_show(struct cgroup_subsys_state *css,
+				struct cftype *cft, struct seq_file *m)
 {
 	int nid;
 	unsigned long total_nr, file_nr, anon_nr, unevictable_nr;
 	unsigned long node_nr;
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
 	total_nr = mem_cgroup_nr_lru_pages(memcg, LRU_ALL);
 	seq_printf(m, "total=%lu", total_nr);
@@ -5260,10 +5229,10 @@ static inline void mem_cgroup_lru_names_not_uptodate(void)
 	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
 }
 
-static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
+static int memcg_stat_show(struct cgroup_subsys_state *css, struct cftype *cft,
 				 struct seq_file *m)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup *mi;
 	unsigned int i;
 
@@ -5347,27 +5316,23 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 	return 0;
 }
 
-static u64 mem_cgroup_swappiness_read(struct cgroup *cgrp, struct cftype *cft)
+static u64 mem_cgroup_swappiness_read(struct cgroup_subsys_state *css,
+				      struct cftype *cft)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
 	return mem_cgroup_swappiness(memcg);
 }
 
-static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
-				       u64 val)
+static int mem_cgroup_swappiness_write(struct cgroup_subsys_state *css,
+				       struct cftype *cft, u64 val)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
-	struct mem_cgroup *parent;
-
-	if (val > 100)
-		return -EINVAL;
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(&memcg->css));
 
-	if (cgrp->parent == NULL)
+	if (val > 100 || !parent)
 		return -EINVAL;
 
-	parent = mem_cgroup_from_cont(cgrp->parent);
-
 	mutex_lock(&memcg_create_mutex);
 
 	/* If under hierarchy, only empty-root can set this value */
@@ -5470,10 +5435,10 @@ static void mem_cgroup_oom_notify(struct mem_cgroup *memcg)
 		mem_cgroup_oom_notify_cb(iter);
 }
 
-static int mem_cgroup_usage_register_event(struct cgroup *cgrp,
+static int mem_cgroup_usage_register_event(struct cgroup_subsys_state *css,
 	struct cftype *cft, struct eventfd_ctx *eventfd, const char *args)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_thresholds *thresholds;
 	struct mem_cgroup_threshold_ary *new;
 	enum res_type type = MEMFILE_TYPE(cft->private);
@@ -5553,10 +5518,10 @@ unlock:
 	return ret;
 }
 
-static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
+static void mem_cgroup_usage_unregister_event(struct cgroup_subsys_state *css,
 	struct cftype *cft, struct eventfd_ctx *eventfd)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_thresholds *thresholds;
 	struct mem_cgroup_threshold_ary *new;
 	enum res_type type = MEMFILE_TYPE(cft->private);
@@ -5632,10 +5597,10 @@ unlock:
 	mutex_unlock(&memcg->thresholds_lock);
 }
 
-static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
+static int mem_cgroup_oom_register_event(struct cgroup_subsys_state *css,
 	struct cftype *cft, struct eventfd_ctx *eventfd, const char *args)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_eventfd_list *event;
 	enum res_type type = MEMFILE_TYPE(cft->private);
 
@@ -5657,10 +5622,10 @@ static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
 	return 0;
 }
 
-static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
+static void mem_cgroup_oom_unregister_event(struct cgroup_subsys_state *css,
 	struct cftype *cft, struct eventfd_ctx *eventfd)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_eventfd_list *ev, *tmp;
 	enum res_type type = MEMFILE_TYPE(cft->private);
 
@@ -5678,10 +5643,10 @@ static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
 	spin_unlock(&memcg_oom_lock);
 }
 
-static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
+static int mem_cgroup_oom_control_read(struct cgroup_subsys_state *css,
 	struct cftype *cft,  struct cgroup_map_cb *cb)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
 	cb->fill(cb, "oom_kill_disable", memcg->oom_kill_disable);
 
@@ -5692,18 +5657,16 @@ static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
 	return 0;
 }
 
-static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
+static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
 	struct cftype *cft, u64 val)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
-	struct mem_cgroup *parent;
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(&memcg->css));
 
 	/* cannot set to root cgroup and only 0 and 1 are allowed */
-	if (!cgrp->parent || !((val == 0) || (val == 1)))
+	if (!parent || !((val == 0) || (val == 1)))
 		return -EINVAL;
 
-	parent = mem_cgroup_from_cont(cgrp->parent);
-
 	mutex_lock(&memcg_create_mutex);
 	/* oom-kill-disable is a flag for subhierarchy. */
 	if ((parent->use_hierarchy) || memcg_has_children(memcg)) {
@@ -6036,7 +5999,7 @@ struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
 EXPORT_SYMBOL(parent_mem_cgroup);
 
 static struct cgroup_subsys_state * __ref
-mem_cgroup_css_alloc(struct cgroup *cont)
+mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct mem_cgroup *memcg;
 	long error = -ENOMEM;
@@ -6051,7 +6014,7 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 			goto free_out;
 
 	/* root ? */
-	if (cont->parent == NULL) {
+	if (parent_css == NULL) {
 		root_mem_cgroup = memcg;
 		res_counter_init(&memcg->res, NULL);
 		res_counter_init(&memcg->memsw, NULL);
@@ -6074,17 +6037,16 @@ free_out:
 }
 
 static int
-mem_cgroup_css_online(struct cgroup *cont)
+mem_cgroup_css_online(struct cgroup_subsys_state *css)
 {
-	struct mem_cgroup *memcg, *parent;
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(css));
 	int error = 0;
 
-	if (!cont->parent)
+	if (!parent)
 		return 0;
 
 	mutex_lock(&memcg_create_mutex);
-	memcg = mem_cgroup_from_cont(cont);
-	parent = mem_cgroup_from_cont(cont->parent);
 
 	memcg->use_hierarchy = parent->use_hierarchy;
 	memcg->oom_kill_disable = parent->oom_kill_disable;
@@ -6135,9 +6097,11 @@ static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)
 		mem_cgroup_iter_invalidate(root_mem_cgroup);
 }
 
-static void mem_cgroup_css_offline(struct cgroup *cont)
+static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	kmem_cgroup_css_offline(memcg);
 
 	kmem_cgroup_css_offline(memcg);
 
@@ -6154,9 +6118,9 @@ static void mem_cgroup_css_offline(struct cgroup *cont)
 	vmpressure_cleanup(&memcg->vmpressure);
 }
 
-static void mem_cgroup_css_free(struct cgroup *cont)
+static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
 	memcg_destroy_kmem(memcg);
 	__mem_cgroup_free(memcg);
@@ -6526,12 +6490,12 @@ static void mem_cgroup_clear_mc(void)
 	mem_cgroup_end_move(from);
 }
 
-static int mem_cgroup_can_attach(struct cgroup *cgroup,
+static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 				 struct cgroup_taskset *tset)
 {
 	struct task_struct *p = cgroup_taskset_first(tset);
 	int ret = 0;
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	unsigned long move_charge_at_immigrate;
 
 	/*
@@ -6573,7 +6537,7 @@ static int mem_cgroup_can_attach(struct cgroup *cgroup,
 	return ret;
 }
 
-static void mem_cgroup_cancel_attach(struct cgroup *cgroup,
+static void mem_cgroup_cancel_attach(struct cgroup_subsys_state *css,
 				     struct cgroup_taskset *tset)
 {
 	mem_cgroup_clear_mc();
@@ -6721,7 +6685,7 @@ retry:
 	up_read(&mm->mmap_sem);
 }
 
-static void mem_cgroup_move_task(struct cgroup *cont,
+static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
 				 struct cgroup_taskset *tset)
 {
 	struct task_struct *p = cgroup_taskset_first(tset);
@@ -6736,16 +6700,16 @@ static void mem_cgroup_move_task(struct cgroup *cont,
 		mem_cgroup_clear_mc();
 }
 #else	/* !CONFIG_MMU */
-static int mem_cgroup_can_attach(struct cgroup *cgroup,
+static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 				 struct cgroup_taskset *tset)
 {
 	return 0;
 }
-static void mem_cgroup_cancel_attach(struct cgroup *cgroup,
+static void mem_cgroup_cancel_attach(struct cgroup_subsys_state *css,
 				     struct cgroup_taskset *tset)
 {
 }
-static void mem_cgroup_move_task(struct cgroup *cont,
+static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
 				 struct cgroup_taskset *tset)
 {
 }
@@ -6755,15 +6719,15 @@ static void mem_cgroup_move_task(struct cgroup *cont,
  * Cgroup retains root cgroups across [un]mount cycles making it necessary
  * to verify sane_behavior flag on each mount attempt.
  */
-static void mem_cgroup_bind(struct cgroup *root)
+static void mem_cgroup_bind(struct cgroup_subsys_state *root_css)
 {
 	/*
 	 * use_hierarchy is forced with sane_behavior.  cgroup core
 	 * guarantees that @root doesn't have any children, so turning it
 	 * on for the root memcg is enough.
 	 */
-	if (cgroup_sane_behavior(root))
-		mem_cgroup_from_cont(root)->use_hierarchy = true;
+	if (cgroup_sane_behavior(root_css->cgroup))
+		mem_cgroup_from_css(root_css)->use_hierarchy = true;
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {

--lrZ03NoBR/3+SXJZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
