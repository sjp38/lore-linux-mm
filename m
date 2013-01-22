Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 6303E6B0006
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 09:00:30 -0500 (EST)
Date: Tue, 22 Jan 2013 15:00:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4 4/6] memcg: replace cgroup_lock with memcg specific
 memcg_lock
Message-ID: <20130122140026.GE28525@dhcp22.suse.cz>
References: <1358862461-18046-1-git-send-email-glommer@parallels.com>
 <1358862461-18046-5-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358862461-18046-5-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On Tue 22-01-13 17:47:39, Glauber Costa wrote:
> After the preparation work done in earlier patches, the cgroup_lock can
> be trivially replaced with a memcg-specific lock. This is an automatic
> translation in every site the values involved were queried.
> 
> The sites were values are written, however, used to be naturally called
> under cgroup_lock. This is the case for instance of the css_online
> callback. For those, we now need to explicitly add the memcg lock.
> 
> With this, all the calls to cgroup_lock outside cgroup core are gone.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!
> ---
>  mm/memcontrol.c | 37 ++++++++++++++++++++-----------------
>  1 file changed, 20 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6d3ad21..f5decb7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -470,6 +470,13 @@ enum res_type {
>  #define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
>  #define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
>  
> +/*
> + * The memcg_create_mutex will be held whenever a new cgroup is created.
> + * As a consequence, any change that needs to protect against new child cgroups
> + * appearing has to hold it as well.
> + */
> +static DEFINE_MUTEX(memcg_create_mutex);
> +
>  static void mem_cgroup_get(struct mem_cgroup *memcg);
>  static void mem_cgroup_put(struct mem_cgroup *memcg);
>  
> @@ -4730,8 +4737,8 @@ static inline bool __memcg_has_children(struct mem_cgroup *memcg)
>  }
>  
>  /*
> - * must be called with cgroup_lock held, unless the cgroup is guaranteed to be
> - * already dead (like in mem_cgroup_force_empty, for instance).  This is
> + * must be called with memcg_create_mutex held, unless the cgroup is guaranteed
> + * to be already dead (like in mem_cgroup_force_empty, for instance).  This is
>   * different than mem_cgroup_count_children, in the sense that we don't really
>   * care how many children we have, we only need to know if we have any. It is
>   * also count any memcg without hierarchy as infertile for that matter.
> @@ -4811,7 +4818,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>  	if (parent)
>  		parent_memcg = mem_cgroup_from_cont(parent);
>  
> -	cgroup_lock();
> +	mutex_lock(&memcg_create_mutex);
>  
>  	if (memcg->use_hierarchy == val)
>  		goto out;
> @@ -4834,7 +4841,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>  		retval = -EINVAL;
>  
>  out:
> -	cgroup_unlock();
> +	mutex_unlock(&memcg_create_mutex);
>  
>  	return retval;
>  }
> @@ -4933,14 +4940,8 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
>  	 *
>  	 * After it first became limited, changes in the value of the limit are
>  	 * of course permitted.
> -	 *
> -	 * Taking the cgroup_lock is really offensive, but it is so far the only
> -	 * way to guarantee that no children will appear. There are plenty of
> -	 * other offenders, and they should all go away. Fine grained locking
> -	 * is probably the way to go here. When we are fully hierarchical, we
> -	 * can also get rid of the use_hierarchy check.
>  	 */
> -	cgroup_lock();
> +	mutex_lock(&memcg_create_mutex);
>  	mutex_lock(&set_limit_mutex);
>  	if (!memcg->kmem_account_flags && val != RESOURCE_MAX) {
>  		if (cgroup_task_count(cont) || memcg_has_children(memcg)) {
> @@ -4967,7 +4968,7 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
>  		ret = res_counter_set_limit(&memcg->kmem, val);
>  out:
>  	mutex_unlock(&set_limit_mutex);
> -	cgroup_unlock();
> +	mutex_unlock(&memcg_create_mutex);
>  
>  	/*
>  	 * We are by now familiar with the fact that we can't inc the static
> @@ -5356,17 +5357,17 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  
>  	parent = mem_cgroup_from_cont(cgrp->parent);
>  
> -	cgroup_lock();
> +	mutex_lock(&memcg_create_mutex);
>  
>  	/* If under hierarchy, only empty-root can set this value */
>  	if ((parent->use_hierarchy) || memcg_has_children(memcg)) {
> -		cgroup_unlock();
> +		mutex_unlock(&memcg_create_mutex);
>  		return -EINVAL;
>  	}
>  
>  	memcg->swappiness = val;
>  
> -	cgroup_unlock();
> +	mutex_unlock(&memcg_create_mutex);
>  
>  	return 0;
>  }
> @@ -5692,7 +5693,7 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
>  
>  	parent = mem_cgroup_from_cont(cgrp->parent);
>  
> -	cgroup_lock();
> +	mutex_lock(&memcg_create_mutex);
>  	/* oom-kill-disable is a flag for subhierarchy. */
>  	if ((parent->use_hierarchy) ||
>  	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
> @@ -5702,7 +5703,7 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
>  	memcg->oom_kill_disable = val;
>  	if (!val)
>  		memcg_oom_recover(memcg);
> -	cgroup_unlock();
> +	mutex_unlock(&memcg_create_mutex);
>  	return 0;
>  }
>  
> @@ -6140,6 +6141,7 @@ mem_cgroup_css_online(struct cgroup *cont)
>  	if (!cont->parent)
>  		return 0;
>  
> +	mutex_lock(&memcg_create_mutex);
>  	memcg = mem_cgroup_from_cont(cont);
>  	parent = mem_cgroup_from_cont(cont->parent);
>  
> @@ -6173,6 +6175,7 @@ mem_cgroup_css_online(struct cgroup *cont)
>  	}
>  
>  	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
> +	mutex_unlock(&memcg_create_mutex);
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
