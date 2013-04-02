Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id D74C06B0006
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 04:26:52 -0400 (EDT)
Date: Tue, 2 Apr 2013 10:26:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Message-ID: <20130402082648.GB24345@dhcp22.suse.cz>
References: <1364373399-17397-1-git-send-email-mhocko@suse.cz>
 <20130327145727.GD29052@cmpxchg.org>
 <20130327151104.GK16579@dhcp22.suse.cz>
 <51530E1E.3010100@parallels.com>
 <20130327153220.GL16579@dhcp22.suse.cz>
 <20130327173223.GQ16579@dhcp22.suse.cz>
 <20130328074814.GA3018@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130328074814.GA3018@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Tejun,
could you take this one please?

On Thu 28-03-13 08:48:14, Michal Hocko wrote:
> On Wed 27-03-13 18:32:23, Michal Hocko wrote:
> [...]
> > Removed WARN_ON_ONCE as suggested by Johannes and kept kmalloc with
> > PATH_MAX used instead of PAGE_SIZE. I've kept Glauber's acked-by but I
> > can remove it.
> 
> And hopefully the last version. I forgot to s/PAGE_SIZE/MAX_PATH/ in
> snprintf.
> ---
> From 551d7b5960904503da8f050faa533278a1d1bc6c Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 28 Mar 2013 08:46:49 +0100
> Subject: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
> 
> As cgroup supports rename, it's unsafe to dereference dentry->d_name
> without proper vfs locks. Fix this by using cgroup_name() rather than
> dentry directly.
> 
> Also open code memcg_cache_name because it is called only from
> kmem_cache_dup which frees the returned name right after
> kmem_cache_create_memcg makes a copy of it. Such a short-lived
> allocation doesn't make too much sense. So replace it by a static
> buffer as kmem_cache_dup is called with memcg_cache_mutex.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: Glauber Costa <glommer@parallels.com>
> ---
>  mm/memcontrol.c |   63 ++++++++++++++++++++++++++++---------------------------
>  1 file changed, 32 insertions(+), 31 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 53b8201..9715c0c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3214,52 +3214,53 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
>  	schedule_work(&cachep->memcg_params->destroy);
>  }
>  
> -static char *memcg_cache_name(struct mem_cgroup *memcg, struct kmem_cache *s)
> -{
> -	char *name;
> -	struct dentry *dentry;
> -
> -	rcu_read_lock();
> -	dentry = rcu_dereference(memcg->css.cgroup->dentry);
> -	rcu_read_unlock();
> -
> -	BUG_ON(dentry == NULL);
> -
> -	name = kasprintf(GFP_KERNEL, "%s(%d:%s)", s->name,
> -			 memcg_cache_id(memcg), dentry->d_name.name);
> -
> -	return name;
> -}
> +/*
> + * This lock protects updaters, not readers. We want readers to be as fast as
> + * they can, and they will either see NULL or a valid cache value. Our model
> + * allow them to see NULL, in which case the root memcg will be selected.
> + *
> + * We need this lock because multiple allocations to the same cache from a non
> + * will span more than one worker. Only one of them can create the cache.
> + */
> +static DEFINE_MUTEX(memcg_cache_mutex);
>  
> +/*
> + * Called with memcg_cache_mutex held
> + */
>  static struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
>  					 struct kmem_cache *s)
>  {
> -	char *name;
>  	struct kmem_cache *new;
> +	static char *tmp_name = NULL;
>  
> -	name = memcg_cache_name(memcg, s);
> -	if (!name)
> -		return NULL;
> +	lockdep_assert_held(&memcg_cache_mutex);
> +
> +	/*
> +	 * kmem_cache_create_memcg duplicates the given name and
> +	 * cgroup_name for this name requires RCU context.
> +	 * This static temporary buffer is used to prevent from
> +	 * pointless shortliving allocation.
> +	 */
> +	if (!tmp_name) {
> +		tmp_name = kmalloc(PATH_MAX, GFP_KERNEL);
> +		if (!tmp_name)
> +			return NULL;
> +	}
> +
> +	rcu_read_lock();
> +	snprintf(tmp_name, PATH_MAX, "%s(%d:%s)", s->name,
> +			 memcg_cache_id(memcg), cgroup_name(memcg->css.cgroup));
> +	rcu_read_unlock();
>  
> -	new = kmem_cache_create_memcg(memcg, name, s->object_size, s->align,
> +	new = kmem_cache_create_memcg(memcg, tmp_name, s->object_size, s->align,
>  				      (s->flags & ~SLAB_PANIC), s->ctor, s);
>  
>  	if (new)
>  		new->allocflags |= __GFP_KMEMCG;
>  
> -	kfree(name);
>  	return new;
>  }
>  
> -/*
> - * This lock protects updaters, not readers. We want readers to be as fast as
> - * they can, and they will either see NULL or a valid cache value. Our model
> - * allow them to see NULL, in which case the root memcg will be selected.
> - *
> - * We need this lock because multiple allocations to the same cache from a non
> - * will span more than one worker. Only one of them can create the cache.
> - */
> -static DEFINE_MUTEX(memcg_cache_mutex);
>  static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
>  						  struct kmem_cache *cachep)
>  {
> -- 
> 1.7.10.4
> 
> -- 
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
