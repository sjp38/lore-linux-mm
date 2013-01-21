Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 545DD6B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 08:56:38 -0500 (EST)
Date: Mon, 21 Jan 2013 14:56:34 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 2/6] memcg: split part of memcg creation to css_online
Message-ID: <20130121135634.GM7798@dhcp22.suse.cz>
References: <1358766813-15095-1-git-send-email-glommer@parallels.com>
 <1358766813-15095-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358766813-15095-3-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On Mon 21-01-13 15:13:29, Glauber Costa wrote:
> This patch is a preparatory work for later locking rework to get rid of
> big cgroup lock from memory controller code.
> 
> The memory controller uses some tunables to adjust its operation. Those
> tunables are inherited from parent to children upon children
> intialization. For most of them, the value cannot be changed after the
> parent has a new children.
> 
> cgroup core splits initialization in two phases: css_alloc and css_online.
> After css_alloc, the memory allocation and basic initialization are
> done. But the new group is not yet visible anywhere, not even for cgroup
> core code. It is only somewhere between css_alloc and css_online that it
> is inserted into the internal children lists. Copying tunable values in
> css_alloc will lead to inconsistent values: the children will copy the
> old parent values, that can change between the copy and the moment in
> which the groups is linked to any data structure that can indicate the
> presence of children.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!
> ---
>  mm/memcontrol.c | 61 ++++++++++++++++++++++++++++++++++++---------------------
>  1 file changed, 39 insertions(+), 22 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 91d90a0..6c72204 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6063,7 +6063,7 @@ err_cleanup:
>  static struct cgroup_subsys_state * __ref
>  mem_cgroup_css_alloc(struct cgroup *cont)
>  {
> -	struct mem_cgroup *memcg, *parent;
> +	struct mem_cgroup *memcg;
>  	long error = -ENOMEM;
>  	int node;
>  
> @@ -6079,7 +6079,6 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>  	if (cont->parent == NULL) {
>  		int cpu;
>  		enable_swap_cgroup();
> -		parent = NULL;
>  		if (mem_cgroup_soft_limit_tree_init())
>  			goto free_out;
>  		root_mem_cgroup = memcg;
> @@ -6088,13 +6087,43 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>  						&per_cpu(memcg_stock, cpu);
>  			INIT_WORK(&stock->work, drain_local_stock);
>  		}
> -	} else {
> -		parent = mem_cgroup_from_cont(cont->parent);
> -		memcg->use_hierarchy = parent->use_hierarchy;
> -		memcg->oom_kill_disable = parent->oom_kill_disable;
> +
> +		res_counter_init(&memcg->res, NULL);
> +		res_counter_init(&memcg->memsw, NULL);
> +		res_counter_init(&memcg->kmem, NULL);
>  	}
>  
> -	if (parent && parent->use_hierarchy) {
> +	memcg->last_scanned_node = MAX_NUMNODES;
> +	INIT_LIST_HEAD(&memcg->oom_notify);
> +	atomic_set(&memcg->refcnt, 1);
> +	memcg->move_charge_at_immigrate = 0;
> +	mutex_init(&memcg->thresholds_lock);
> +	spin_lock_init(&memcg->move_lock);
> +
> +	return &memcg->css;
> +
> +free_out:
> +	__mem_cgroup_free(memcg);
> +	return ERR_PTR(error);
> +}
> +
> +static int
> +mem_cgroup_css_online(struct cgroup *cont)
> +{
> +	struct mem_cgroup *memcg, *parent;
> +	int error = 0;
> +
> +	if (!cont->parent)
> +		return 0;
> +
> +	memcg = mem_cgroup_from_cont(cont);
> +	parent = mem_cgroup_from_cont(cont->parent);
> +
> +	memcg->use_hierarchy = parent->use_hierarchy;
> +	memcg->oom_kill_disable = parent->oom_kill_disable;
> +	memcg->swappiness = mem_cgroup_swappiness(parent);
> +
> +	if (parent->use_hierarchy) {
>  		res_counter_init(&memcg->res, &parent->res);
>  		res_counter_init(&memcg->memsw, &parent->memsw);
>  		res_counter_init(&memcg->kmem, &parent->kmem);
> @@ -6115,18 +6144,9 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>  		 * much sense so let cgroup subsystem know about this
>  		 * unfortunate state in our controller.
>  		 */
> -		if (parent && parent != root_mem_cgroup)
> +		if (parent != root_mem_cgroup)
>  			mem_cgroup_subsys.broken_hierarchy = true;
>  	}
> -	memcg->last_scanned_node = MAX_NUMNODES;
> -	INIT_LIST_HEAD(&memcg->oom_notify);
> -
> -	if (parent)
> -		memcg->swappiness = mem_cgroup_swappiness(parent);
> -	atomic_set(&memcg->refcnt, 1);
> -	memcg->move_charge_at_immigrate = 0;
> -	mutex_init(&memcg->thresholds_lock);
> -	spin_lock_init(&memcg->move_lock);
>  
>  	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
>  	if (error) {
> @@ -6136,12 +6156,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>  		 * call __mem_cgroup_free, so return directly
>  		 */
>  		mem_cgroup_put(memcg);
> -		return ERR_PTR(error);
>  	}
> -	return &memcg->css;
> -free_out:
> -	__mem_cgroup_free(memcg);
> -	return ERR_PTR(error);
> +	return error;
>  }
>  
>  static void mem_cgroup_css_offline(struct cgroup *cont)
> @@ -6751,6 +6767,7 @@ struct cgroup_subsys mem_cgroup_subsys = {
>  	.name = "memory",
>  	.subsys_id = mem_cgroup_subsys_id,
>  	.css_alloc = mem_cgroup_css_alloc,
> +	.css_online = mem_cgroup_css_online,
>  	.css_offline = mem_cgroup_css_offline,
>  	.css_free = mem_cgroup_css_free,
>  	.can_attach = mem_cgroup_can_attach,
> -- 
> 1.8.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
