Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id F360C6B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 10:37:18 -0500 (EST)
Date: Fri, 18 Jan 2013 16:37:15 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 3/7] memcg: provide online test for memcg
Message-ID: <20130118153715.GG10701@dhcp22.suse.cz>
References: <1357897527-15479-1-git-send-email-glommer@parallels.com>
 <1357897527-15479-4-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357897527-15479-4-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Fri 11-01-13 13:45:23, Glauber Costa wrote:
> Since we are now splitting the memcg creation in two parts, following
> the cgroup standard, it would be helpful to be able to determine if a
> created memcg is already online.
> 
> We can do this by initially forcing the refcnt to 0, and waiting until
> the last minute to flip it to 1.

Is this useful, though? What does it tell you? mem_cgroup_online can say
false even though half of the attributes have been already copied for
example. I think it should be vice versa. It should mark the point when
we _start_ copying values. mem_cgroup_online is not the best name then
of course. It depends what it is going to be used for...

> During memcg's lifetime, this value
> will vary. But if it ever reaches 0 again, memcg will be destructed. We
> can therefore be sure that any value different than 0 will mean that
> our group is online.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> ---
>  mm/memcontrol.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2229945..2ac2808 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -475,6 +475,11 @@ enum res_type {
>  static void mem_cgroup_get(struct mem_cgroup *memcg);
>  static void mem_cgroup_put(struct mem_cgroup *memcg);
>  
> +static inline bool mem_cgroup_online(struct mem_cgroup *memcg)
> +{
> +	return atomic_read(&memcg->refcnt) > 0;
> +}
> +
>  static inline
>  struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
>  {
> @@ -6098,7 +6103,7 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>  
>  	memcg->last_scanned_node = MAX_NUMNODES;
>  	INIT_LIST_HEAD(&memcg->oom_notify);
> -	atomic_set(&memcg->refcnt, 1);
> +	atomic_set(&memcg->refcnt, 0);

I would prefer a comment rather than an explicit atomic_set. The value
is zero already.

>  	memcg->move_charge_at_immigrate = 0;
>  	mutex_init(&memcg->thresholds_lock);
>  	spin_lock_init(&memcg->move_lock);
> @@ -6116,10 +6121,13 @@ mem_cgroup_css_online(struct cgroup *cont)
>  	struct mem_cgroup *memcg, *parent;
>  	int error = 0;
>
	
as I said above atomic_set(&memc->refcnt, 1) should be set here before
we start copying anything.

But maybe I have missed your intention and later patches in the series
will convince me...

> -	if (!cont->parent)
> +	memcg = mem_cgroup_from_cont(cont);
> +	if (!cont->parent) {
> +		/* no need to lock, since this is the root cgroup */
> +		atomic_set(&memcg->refcnt, 1);
>  		return 0;
> +	}
>  
> -	memcg = mem_cgroup_from_cont(cont);
>  	parent = mem_cgroup_from_cont(cont->parent);
>  
>  	memcg->use_hierarchy = parent->use_hierarchy;
> @@ -6151,6 +6159,7 @@ mem_cgroup_css_online(struct cgroup *cont)
>  	}
>  
>  	memcg->swappiness = mem_cgroup_swappiness(parent);
> +	atomic_set(&memcg->refcnt, 1);
>  
>  	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
>  	if (error) {
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
