Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id E85B06B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 09:49:23 -0500 (EST)
Date: Mon, 21 Jan 2013 15:49:19 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 4/6] memcg: replace cgroup_lock with memcg specific
 memcg_lock
Message-ID: <20130121144919.GO7798@dhcp22.suse.cz>
References: <1358766813-15095-1-git-send-email-glommer@parallels.com>
 <1358766813-15095-5-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358766813-15095-5-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On Mon 21-01-13 15:13:31, Glauber Costa wrote:
> After the preparation work done in earlier patches, the cgroup_lock can
> be trivially replaced with a memcg-specific lock. This is an automatic
> translation in every site the values involved were queried.
> 
> The sites were values are written, however, used to be naturally called
> under cgroup_lock. This is the case for instance of the css_online
> callback. For those, we now need to explicitly add the memcg_lock.
> 
> Also, now that the memcg_mutex is available, there is no need to abuse
> the set_limit mutex in kmemcg value setting. The memcg_mutex will do a
> better job, and we now resort to it.

You will hate me for this because I should have said that in the
previous round already (but I will use "I shown a mercy on you and
that blinded me" for my defense).
I am not so sure it will do a better job (it is only kmem that uses both
locks). I thought that memcg_mutex is just a first step and that we move
to a more finer grained locking later (a too general documentation of
the lock even asks for it).  So I would keep the limit mutex and figure
whether memcg_mutex could be split up even further.

Other than that the patch looks good to me
 
> With this, all the calls to cgroup_lock outside cgroup core are gone.

OK, Tejun will be happy ;)

> Signed-off-by: Glauber Costa <glommer@parallels.com>
> ---
>  mm/memcontrol.c | 52 ++++++++++++++++++++++++++++------------------------
>  1 file changed, 28 insertions(+), 24 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6d3ad21..d3b78b9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -470,6 +470,13 @@ enum res_type {
>  #define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
>  #define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
>  
> +/*
> + * The memcg mutex needs to be held for any globally visible cgroup change.
> + * Group creation and tunable propagation, as well as any change that depends
> + * on the tunables being in a consistent state.
> + */
> +static DEFINE_MUTEX(memcg_mutex);
> +
>  static void mem_cgroup_get(struct mem_cgroup *memcg);
>  static void mem_cgroup_put(struct mem_cgroup *memcg);
>  
> @@ -2902,7 +2909,7 @@ int memcg_cache_id(struct mem_cgroup *memcg)
>   * operation, because that is its main call site.
>   *
>   * But when we create a new cache, we can call this as well if its parent
> - * is kmem-limited. That will have to hold set_limit_mutex as well.
> + * is kmem-limited. That will have to hold memcg_mutex as well.
>   */
>  int memcg_update_cache_sizes(struct mem_cgroup *memcg)
>  {
> @@ -2917,7 +2924,7 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
>  	 * the beginning of this conditional), is no longer 0. This
>  	 * guarantees only one process will set the following boolean
>  	 * to true. We don't need test_and_set because we're protected
> -	 * by the set_limit_mutex anyway.
> +	 * by the memcg_mutex anyway.
>  	 */
>  	memcg_kmem_set_activated(memcg);
>  
> @@ -3258,9 +3265,9 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
>  	 *
>  	 * Still, we don't want anyone else freeing memcg_caches under our
>  	 * noses, which can happen if a new memcg comes to life. As usual,
> -	 * we'll take the set_limit_mutex to protect ourselves against this.
> +	 * we'll take the memcg_mutex to protect ourselves against this.
>  	 */
> -	mutex_lock(&set_limit_mutex);
> +	mutex_lock(&memcg_mutex);
>  	for (i = 0; i < memcg_limited_groups_array_size; i++) {
>  		c = s->memcg_params->memcg_caches[i];
>  		if (!c)
> @@ -3283,7 +3290,7 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
>  		cancel_work_sync(&c->memcg_params->destroy);
>  		kmem_cache_destroy(c);
>  	}
> -	mutex_unlock(&set_limit_mutex);
> +	mutex_unlock(&memcg_mutex);
>  }
>  
>  struct create_work {
> @@ -4730,7 +4737,7 @@ static inline bool __memcg_has_children(struct mem_cgroup *memcg)
>  }
>  
>  /*
> - * must be called with cgroup_lock held, unless the cgroup is guaranteed to be
> + * must be called with memcg_mutex held, unless the cgroup is guaranteed to be
>   * already dead (like in mem_cgroup_force_empty, for instance).  This is
>   * different than mem_cgroup_count_children, in the sense that we don't really
>   * care how many children we have, we only need to know if we have any. It is
> @@ -4811,7 +4818,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>  	if (parent)
>  		parent_memcg = mem_cgroup_from_cont(parent);
>  
> -	cgroup_lock();
> +	mutex_lock(&memcg_mutex);
>  
>  	if (memcg->use_hierarchy == val)
>  		goto out;
> @@ -4834,7 +4841,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>  		retval = -EINVAL;
>  
>  out:
> -	cgroup_unlock();
> +	mutex_unlock(&memcg_mutex);
>  
>  	return retval;
>  }
> @@ -4934,14 +4941,10 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
>  	 * After it first became limited, changes in the value of the limit are
>  	 * of course permitted.
>  	 *
> -	 * Taking the cgroup_lock is really offensive, but it is so far the only
> -	 * way to guarantee that no children will appear. There are plenty of
> -	 * other offenders, and they should all go away. Fine grained locking
> -	 * is probably the way to go here. When we are fully hierarchical, we
> -	 * can also get rid of the use_hierarchy check.
> +	 * We are protected by the memcg_mutex, so no other cgroups can appear
> +	 * in the mean time.
>  	 */
> -	cgroup_lock();
> -	mutex_lock(&set_limit_mutex);
> +	mutex_lock(&memcg_mutex);
>  	if (!memcg->kmem_account_flags && val != RESOURCE_MAX) {
>  		if (cgroup_task_count(cont) || memcg_has_children(memcg)) {
>  			ret = -EBUSY;
> @@ -4966,8 +4969,7 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
>  	} else
>  		ret = res_counter_set_limit(&memcg->kmem, val);
>  out:
> -	mutex_unlock(&set_limit_mutex);
> -	cgroup_unlock();
> +	mutex_unlock(&memcg_mutex);
>  
>  	/*
>  	 * We are by now familiar with the fact that we can't inc the static
> @@ -5024,9 +5026,9 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
>  	mem_cgroup_get(memcg);
>  	static_key_slow_inc(&memcg_kmem_enabled_key);
>  
> -	mutex_lock(&set_limit_mutex);
> +	mutex_lock(&memcg_mutex);
>  	ret = memcg_update_cache_sizes(memcg);
> -	mutex_unlock(&set_limit_mutex);
> +	mutex_unlock(&memcg_mutex);
>  #endif
>  out:
>  	return ret;
> @@ -5356,17 +5358,17 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  
>  	parent = mem_cgroup_from_cont(cgrp->parent);
>  
> -	cgroup_lock();
> +	mutex_lock(&memcg_mutex);
>  
>  	/* If under hierarchy, only empty-root can set this value */
>  	if ((parent->use_hierarchy) || memcg_has_children(memcg)) {
> -		cgroup_unlock();
> +		mutex_unlock(&memcg_mutex);
>  		return -EINVAL;
>  	}
>  
>  	memcg->swappiness = val;
>  
> -	cgroup_unlock();
> +	mutex_unlock(&memcg_mutex);
>  
>  	return 0;
>  }
> @@ -5692,7 +5694,7 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
>  
>  	parent = mem_cgroup_from_cont(cgrp->parent);
>  
> -	cgroup_lock();
> +	mutex_lock(&memcg_mutex);
>  	/* oom-kill-disable is a flag for subhierarchy. */
>  	if ((parent->use_hierarchy) ||
>  	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
> @@ -5702,7 +5704,7 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
>  	memcg->oom_kill_disable = val;
>  	if (!val)
>  		memcg_oom_recover(memcg);
> -	cgroup_unlock();
> +	mutex_unlock(&memcg_mutex);
>  	return 0;
>  }
>  
> @@ -6140,6 +6142,7 @@ mem_cgroup_css_online(struct cgroup *cont)
>  	if (!cont->parent)
>  		return 0;
>  
> +	mutex_lock(&memcg_mutex);
>  	memcg = mem_cgroup_from_cont(cont);
>  	parent = mem_cgroup_from_cont(cont->parent);
>  
> @@ -6173,6 +6176,7 @@ mem_cgroup_css_online(struct cgroup *cont)
>  	}
>  
>  	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
> +	mutex_unlock(&memcg_mutex);
>  	if (error) {
>  		/*
>  		 * We call put now because our (and parent's) refcnts
> -- 
> 1.8.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
