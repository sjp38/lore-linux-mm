Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 982276B004F
	for <linux-mm@kvack.org>; Mon, 12 Jan 2009 07:14:31 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id n0CCEOmW031000
	for <linux-mm@kvack.org>; Mon, 12 Jan 2009 17:44:24 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0CCCcf73580016
	for <linux-mm@kvack.org>; Mon, 12 Jan 2009 17:42:38 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n0CCENfN027959
	for <linux-mm@kvack.org>; Mon, 12 Jan 2009 17:44:23 +0530
Date: Mon, 12 Jan 2009 17:44:24 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 2/4] memcg: use CSS ID in memcg
Message-ID: <20090112121424.GC27129@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com> <20090108183003.accef865.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090108183003.accef865.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-08 18:30:03]:

> 
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Use css ID in memcg.
> 
> Assigning CSS ID for each memcg and use css_get_next() for scanning hierarchy.
> 
> 	Assume folloing tree.
> 
> 	group_A (ID=3)
> 		/01 (ID=4)
> 		   /0A (ID=7)
> 		/02 (ID=10)
> 	group_B (ID=5)
> 	and task in group_A/01/0A hits limit at group_A.
> 
> 	reclaim will be done in following order (round-robin).
> 	group_A(3) -> group_A/01 (4) -> group_A/01/0A (7) -> group_A/02(10)
> 	-> group_A -> .....
> 
> 	Round robin by ID. The last visited cgroup is recorded and restart
> 	from it when it start reclaim again.
> 	(More smart algorithm can be implemented..)
> 
> 	No cgroup_mutex or hierarchy_mutex is required.
> 
> Changelog (v1) -> (v2)
>   - Updated texts.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  mm/memcontrol.c |  219 ++++++++++++++++++++------------------------------------
>  1 file changed, 81 insertions(+), 138 deletions(-)
> 
> Index: mmotm-2.6.28-Jan7/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.28-Jan7.orig/mm/memcontrol.c
> +++ mmotm-2.6.28-Jan7/mm/memcontrol.c
> @@ -154,9 +154,10 @@ struct mem_cgroup {
> 
>  	/*
>  	 * While reclaiming in a hiearchy, we cache the last child we
> -	 * reclaimed from. Protected by hierarchy_mutex
> +	 * reclaimed from.
>  	 */
> -	struct mem_cgroup *last_scanned_child;
> +	int last_scanned_child;
> +	unsigned long scan_age;

A comment describing what scan_age represents and how it impacts
reclaim would be nice to have

>  	/*
>  	 * Should the accounting and control be hierarchical, per subtree?
>  	 */
> @@ -613,103 +614,6 @@ unsigned long mem_cgroup_isolate_pages(u
>  #define mem_cgroup_from_res_counter(counter, member)	\
>  	container_of(counter, struct mem_cgroup, member)
> 
> -/*
> - * This routine finds the DFS walk successor. This routine should be
> - * called with hierarchy_mutex held
> - */
> -static struct mem_cgroup *
> -mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
> -{
> -	struct cgroup *cgroup, *curr_cgroup, *root_cgroup;
> -
> -	curr_cgroup = curr->css.cgroup;
> -	root_cgroup = root_mem->css.cgroup;
> -
> -	if (!list_empty(&curr_cgroup->children)) {
> -		/*
> -		 * Walk down to children
> -		 */
> -		mem_cgroup_put(curr);
> -		cgroup = list_entry(curr_cgroup->children.next,
> -						struct cgroup, sibling);
> -		curr = mem_cgroup_from_cont(cgroup);
> -		mem_cgroup_get(curr);
> -		goto done;
> -	}
> -
> -visit_parent:
> -	if (curr_cgroup == root_cgroup) {
> -		mem_cgroup_put(curr);
> -		curr = root_mem;
> -		mem_cgroup_get(curr);
> -		goto done;
> -	}
> -
> -	/*
> -	 * Goto next sibling
> -	 */
> -	if (curr_cgroup->sibling.next != &curr_cgroup->parent->children) {
> -		mem_cgroup_put(curr);
> -		cgroup = list_entry(curr_cgroup->sibling.next, struct cgroup,
> -						sibling);
> -		curr = mem_cgroup_from_cont(cgroup);
> -		mem_cgroup_get(curr);
> -		goto done;
> -	}
> -
> -	/*
> -	 * Go up to next parent and next parent's sibling if need be
> -	 */
> -	curr_cgroup = curr_cgroup->parent;
> -	goto visit_parent;
> -
> -done:
> -	root_mem->last_scanned_child = curr;
> -	return curr;
> -}
> -
> -/*
> - * Visit the first child (need not be the first child as per the ordering
> - * of the cgroup list, since we track last_scanned_child) of @mem and use
> - * that to reclaim free pages from.
> - */
> -static struct mem_cgroup *
> -mem_cgroup_get_first_node(struct mem_cgroup *root_mem)
> -{
> -	struct cgroup *cgroup;
> -	struct mem_cgroup *ret;
> -	bool obsolete;
> -
> -	obsolete = mem_cgroup_is_obsolete(root_mem->last_scanned_child);
> -
> -	/*
> -	 * Scan all children under the mem_cgroup mem
> -	 */
> -	mutex_lock(&mem_cgroup_subsys.hierarchy_mutex);
> -	if (list_empty(&root_mem->css.cgroup->children)) {
> -		ret = root_mem;
> -		goto done;
> -	}
> -
> -	if (!root_mem->last_scanned_child || obsolete) {
> -
> -		if (obsolete && root_mem->last_scanned_child)
> -			mem_cgroup_put(root_mem->last_scanned_child);
> -
> -		cgroup = list_first_entry(&root_mem->css.cgroup->children,
> -				struct cgroup, sibling);
> -		ret = mem_cgroup_from_cont(cgroup);
> -		mem_cgroup_get(ret);
> -	} else
> -		ret = mem_cgroup_get_next_node(root_mem->last_scanned_child,
> -						root_mem);
> -
> -done:
> -	root_mem->last_scanned_child = ret;
> -	mutex_unlock(&mem_cgroup_subsys.hierarchy_mutex);
> -	return ret;
> -}
> -
>  static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
>  {
>  	if (do_swap_account) {
> @@ -739,49 +643,84 @@ static unsigned int get_swappiness(struc
>  }
> 
>  /*
> - * Dance down the hierarchy if needed to reclaim memory. We remember the
> - * last child we reclaimed from, so that we don't end up penalizing
> - * one child extensively based on its position in the children list.
> + * Visit the first child (need not be the first child as per the ordering
> + * of the cgroup list, since we track last_scanned_child) of @mem and use
> + * that to reclaim free pages from.
> + */
> +static struct mem_cgroup *
> +mem_cgroup_select_victim(struct mem_cgroup *root_mem)
> +{
> +	struct mem_cgroup *ret = NULL;
> +	struct cgroup_subsys_state *css;
> +	int nextid, found;
> +
> +	if (!root_mem->use_hierarchy) {
> +		spin_lock(&root_mem->reclaim_param_lock);
> +		root_mem->scan_age++;
> +		spin_unlock(&root_mem->reclaim_param_lock);
> +		css_get(&root_mem->css);
> +		ret = root_mem;
> +	}
> +
> +	while (!ret) {
> +		rcu_read_lock();
> +		nextid = root_mem->last_scanned_child + 1;
> +		css = css_get_next(&mem_cgroup_subsys, nextid, &root_mem->css,
> +				   &found);
> +		if (css && css_tryget(css))
> +			ret = container_of(css, struct mem_cgroup, css);
> +
> +		rcu_read_unlock();
> +		/* Updates scanning parameter */
> +		spin_lock(&root_mem->reclaim_param_lock);
> +		if (!css) {
> +			/* this means start scan from ID:1 */
> +			root_mem->last_scanned_child = 0;
> +			root_mem->scan_age++;
> +		} else
> +			root_mem->last_scanned_child = found;
> +		spin_unlock(&root_mem->reclaim_param_lock);
> +	}
> +
> +	return ret;
> +}
> +
> +/*
> + * Scan the hierarchy if needed to reclaim memory. We remember the last child
> + * we reclaimed from, so that we don't end up penalizing one child extensively
> + * based on its position in the children list.
>   *
>   * root_mem is the original ancestor that we've been reclaim from.
> + *
> + * scan_age is updated every time when select_victim returns "root" and
> + * it's shared under system (per hierarchy root).
> + *
> + * We give up and return to the caller when scan_age is increased by 2. This
> + * means try_to_free_mem_cgroup_pages() is called against all children cgroup,
> + * at least once. The caller itself will do further retry if necessary.
>   */
>  static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  						gfp_t gfp_mask, bool noswap)
>  {
> -	struct mem_cgroup *next_mem;
> -	int ret = 0;
> -
> -	/*
> -	 * Reclaim unconditionally and don't check for return value.
> -	 * We need to reclaim in the current group and down the tree.
> -	 * One might think about checking for children before reclaiming,
> -	 * but there might be left over accounting, even after children
> -	 * have left.
> -	 */
> -	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap,
> -					   get_swappiness(root_mem));
> -	if (mem_cgroup_check_under_limit(root_mem))
> -		return 0;
> -	if (!root_mem->use_hierarchy)
> -		return ret;
> -
> -	next_mem = mem_cgroup_get_first_node(root_mem);
> -
> -	while (next_mem != root_mem) {
> -		if (mem_cgroup_is_obsolete(next_mem)) {
> -			mem_cgroup_put(next_mem);
> -			next_mem = mem_cgroup_get_first_node(root_mem);
> -			continue;
> -		}
> -		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap,
> -						   get_swappiness(next_mem));
> +	struct mem_cgroup *victim;
> +	unsigned long start_age;
> +	int ret, total = 0;
> +	/*
> +	 * Reclaim memory from cgroups under root_mem in round robin.
> +	 */
> +	start_age = root_mem->scan_age;
> +
> +	while (time_after((start_age + 2UL), root_mem->scan_age)) {

This is confusing, why do we use time_after with scan_age. scan_age
seems to be incremented every time we scan and has no relationship
with time. The second thing is what happens if time_after() always
returns 0, if we've been aggressively scanning? The logic needs some
commenting, why the magic number 2?

> +		victim = mem_cgroup_select_victim(root_mem);
> +		/* we use swappiness of local cgroup */
> +		ret = try_to_free_mem_cgroup_pages(victim, gfp_mask, noswap,
> +						   get_swappiness(victim));
> +		css_put(&victim->css);
> +		total += ret;
>  		if (mem_cgroup_check_under_limit(root_mem))
> -			return 0;
> -		mutex_lock(&mem_cgroup_subsys.hierarchy_mutex);
> -		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);
> -		mutex_unlock(&mem_cgroup_subsys.hierarchy_mutex);
> +			return 1 + total;
>  	}
> -	return ret;
> +	return total;
>  }
> 
>  bool mem_cgroup_oom_called(struct task_struct *task)
> @@ -1298,7 +1237,6 @@ __mem_cgroup_uncharge_common(struct page
>  	default:
>  		break;
>  	}
> -
>  	res_counter_uncharge(&mem->res, PAGE_SIZE);
>  	if (do_swap_account && (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
>  		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> @@ -2148,6 +2086,8 @@ static void __mem_cgroup_free(struct mem
>  {
>  	int node;
> 
> +	free_css_id(&mem_cgroup_subsys, &mem->css);
> +
>  	for_each_node_state(node, N_POSSIBLE)
>  		free_mem_cgroup_per_zone_info(mem, node);
> 
> @@ -2185,11 +2125,12 @@ static struct cgroup_subsys_state *
>  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  {
>  	struct mem_cgroup *mem, *parent;
> +	long error = -ENOMEM;
>  	int node;
> 
>  	mem = mem_cgroup_alloc();
>  	if (!mem)
> -		return ERR_PTR(-ENOMEM);
> +		return ERR_PTR(error);
> 
>  	for_each_node_state(node, N_POSSIBLE)
>  		if (alloc_mem_cgroup_per_zone_info(mem, node))
> @@ -2210,7 +2151,8 @@ mem_cgroup_create(struct cgroup_subsys *
>  		res_counter_init(&mem->res, NULL);
>  		res_counter_init(&mem->memsw, NULL);
>  	}
> -	mem->last_scanned_child = NULL;
> +	mem->last_scanned_child = 0;
> +	mem->scan_age = 0;
>  	spin_lock_init(&mem->reclaim_param_lock);
> 
>  	if (parent)
> @@ -2219,7 +2161,7 @@ mem_cgroup_create(struct cgroup_subsys *
>  	return &mem->css;
>  free_out:
>  	__mem_cgroup_free(mem);
> -	return ERR_PTR(-ENOMEM);
> +	return ERR_PTR(error);
>  }
> 
>  static void mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
> @@ -2270,6 +2212,7 @@ struct cgroup_subsys mem_cgroup_subsys =
>  	.populate = mem_cgroup_populate,
>  	.attach = mem_cgroup_move_task,
>  	.early_init = 0,
> +	.use_id = 1,
>  };
> 
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
