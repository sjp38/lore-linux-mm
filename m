Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 293746B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 10:25:30 -0500 (EST)
Date: Fri, 18 Jan 2013 16:25:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 2/7] memcg: split part of memcg creation to css_online
Message-ID: <20130118152526.GF10701@dhcp22.suse.cz>
References: <1357897527-15479-1-git-send-email-glommer@parallels.com>
 <1357897527-15479-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357897527-15479-3-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Fri 11-01-13 13:45:22, Glauber Costa wrote:
> Although there is arguably some value in doing this per se, the main

This begs for asking what are the other reasons but I would just leave
it alone and focus on the code reshuffling.

> goal of this patch is to make room for the locking changes to come.
> 
> With all the value assignment from parent happening in a context where
> our iterators can already be used, we can safely lock against value
> change in some key values like use_hierarchy, without resorting to the
> cgroup core at all.

Sorry but I do not understand the above. Please be more specific here.
Why the context matters if it matters at all.

Maybe something like the below?
"
mem_cgroup_css_alloc is currently responsible for the complete
initialization of a newly created memcg. Cgroup core offers another
stage of initialization - css_online - which is called after the newly
created group is already linked to the cgroup hierarchy.
All attributes inheritted from the parent group can be safely moved
into mem_cgroup_css_online because nobody can see the newly created
group yet. This has also an advantage that the parent can already see
the child group (via iterators) by the time we inherit values from it
so he can do appropriate steps (e.g. don't allow changing use_hierarchy
etc...).

This patch is a preparatory work for later locking rework to get rid of
big cgroup lock from memory controller code.
"

> Signed-off-by: Glauber Costa <glommer@parallels.com>
> ---
>  mm/memcontrol.c | 53 ++++++++++++++++++++++++++++++++++++-----------------
>  1 file changed, 36 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 18f4e76..2229945 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6090,12 +6090,41 @@ mem_cgroup_css_alloc(struct cgroup *cont)

parent becomes unused (except for parent = NULL; in the root_cgroup
branch).

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
	/*
	 * All memcg attributes which are not inherited throughout
	 * the hierarchy are initialized here
	 */
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
	/*
	 * Initialization of attributes which are inherited from parent.
	 */
> +	memcg->use_hierarchy = parent->use_hierarchy;
> +	memcg->oom_kill_disable = parent->oom_kill_disable;
> +

	/*
	 * Initialization of attributes which are linked with parent
	 * based on use_hierarchy.
	 */
>  	if (parent && parent->use_hierarchy) {

parent cannot be NULL.

>  		res_counter_init(&memcg->res, &parent->res);
>  		res_counter_init(&memcg->memsw, &parent->memsw);
> @@ -6120,15 +6149,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>  		if (parent && parent != root_mem_cgroup)
>  			mem_cgroup_subsys.broken_hierarchy = true;
>  	}
> -	memcg->last_scanned_node = MAX_NUMNODES;
> -	INIT_LIST_HEAD(&memcg->oom_notify);
>  
> -	if (parent)
> -		memcg->swappiness = mem_cgroup_swappiness(parent);
> -	atomic_set(&memcg->refcnt, 1);
> -	memcg->move_charge_at_immigrate = 0;
> -	mutex_init(&memcg->thresholds_lock);
> -	spin_lock_init(&memcg->move_lock);
> +	memcg->swappiness = mem_cgroup_swappiness(parent);

Please move this up to oom_kill_disable and use_hierarchy
initialization.

	/*
	 * kmem initialization depends on memcg->res initialization
	 * because it relies on parent_mem_cgroup
	 */
>  	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
>  	if (error) {
> @@ -6138,12 +6160,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>  		 * call __mem_cgroup_free, so return directly
>  		 */
>  		mem_cgroup_put(memcg);

Hmm, this doesn't release parent for use_hierarchy. The bug is there
from before this patch. So it should go into a separate patch.

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
> @@ -6753,6 +6771,7 @@ struct cgroup_subsys mem_cgroup_subsys = {
>  	.name = "memory",
>  	.subsys_id = mem_cgroup_subsys_id,
>  	.css_alloc = mem_cgroup_css_alloc,
> +	.css_online = mem_cgroup_css_online,
>  	.css_offline = mem_cgroup_css_offline,
>  	.css_free = mem_cgroup_css_free,
>  	.can_attach = mem_cgroup_can_attach,
> -- 
> 1.7.11.7
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
