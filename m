Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2596B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 10:33:30 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id w62so4348927wes.15
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 07:33:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6si8464675wjf.133.2014.02.04.07.33.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 07:33:29 -0800 (PST)
Date: Tue, 4 Feb 2014 16:33:27 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg, slab: cleanup memcg cache creation
Message-ID: <20140204153327.GK4890@dhcp22.suse.cz>
References: <52F08842.8050906@parallels.com>
 <1391499547-1426-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391499547-1426-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On Tue 04-02-14 11:39:07, Vladimir Davydov wrote:
> This patch cleanups the memcg cache creation path as follows:
>  - Move memcg cache name creation to a separate function to be called
>    from kmem_cache_create_memcg(). This allows us to get rid of the
>    mutex protecting the temporary buffer used for the name formatting,
>    because the whole cache creation path is protected by the slab_mutex.
>  - Get rid of memcg_create_kmem_cache(). This function serves as a proxy
>    to kmem_cache_create_memcg(). After separating the cache name
>    creation path, it would be reduced to a function call, so let's
>    inline it.

OK, this looks better but it will still conflict with Tejun's cleanup
now? Can we wait until mmotm settles down a bit and sees those changes?
Maybe we can get rid of the static buffer altogether?

> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> ---
>  include/linux/memcontrol.h |    9 +++++
>  mm/memcontrol.c            |   89 ++++++++++++++++++++------------------------
>  mm/slab_common.c           |    5 ++-
>  3 files changed, 54 insertions(+), 49 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index abd0113b6620..84e4801fc36c 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -497,6 +497,9 @@ void __memcg_kmem_commit_charge(struct page *page,
>  void __memcg_kmem_uncharge_pages(struct page *page, int order);
>  
>  int memcg_cache_id(struct mem_cgroup *memcg);
> +
> +char *memcg_create_cache_name(struct mem_cgroup *memcg,
> +			      struct kmem_cache *root_cache);
>  int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
>  			     struct kmem_cache *root_cache);
>  void memcg_free_cache_params(struct kmem_cache *s);
> @@ -641,6 +644,12 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
>  	return -1;
>  }
>  
> +static inline char *memcg_create_cache_name(struct mem_cgroup *memcg,
> +					    struct kmem_cache *root_cache)
> +{
> +	return NULL;
> +}
> +
>  static inline int memcg_alloc_cache_params(struct mem_cgroup *memcg,
>  		struct kmem_cache *s, struct kmem_cache *root_cache)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 53385cd4e6f0..43e08b7bb365 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3193,6 +3193,32 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
>  	return 0;
>  }
>  
> +char *memcg_create_cache_name(struct mem_cgroup *memcg,
> +			      struct kmem_cache *root_cache)
> +{
> +	static char *buf = NULL;
> +
> +	/*
> +	 * We need a mutex here to protect the shared buffer. Since this is
> +	 * expected to be called only on cache creation, we can employ the
> +	 * slab_mutex for that purpose.
> +	 */
> +	lockdep_assert_held(&slab_mutex);
> +
> +	if (!buf) {
> +		buf = kmalloc(PATH_MAX, GFP_KERNEL);
> +		if (!buf)
> +			return NULL;
> +	}
> +
> +	rcu_read_lock();
> +	snprintf(buf, PATH_MAX, "%s(%d:%s)", root_cache->name,
> +		 memcg_cache_id(memcg), cgroup_name(memcg->css.cgroup));
> +	rcu_read_unlock();
> +
> +	return kstrdup(buf, GFP_KERNEL);
> +}
> +
>  int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
>  			     struct kmem_cache *root_cache)
>  {
> @@ -3397,44 +3423,6 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
>  	schedule_work(&cachep->memcg_params->destroy);
>  }
>  
> -static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
> -						  struct kmem_cache *s)
> -{
> -	struct kmem_cache *new = NULL;
> -	static char *tmp_name = NULL;
> -	static DEFINE_MUTEX(mutex);	/* protects tmp_name */
> -
> -	BUG_ON(!memcg_can_account_kmem(memcg));
> -
> -	mutex_lock(&mutex);
> -	/*
> -	 * kmem_cache_create_memcg duplicates the given name and
> -	 * cgroup_name for this name requires RCU context.
> -	 * This static temporary buffer is used to prevent from
> -	 * pointless shortliving allocation.
> -	 */
> -	if (!tmp_name) {
> -		tmp_name = kmalloc(PATH_MAX, GFP_KERNEL);
> -		if (!tmp_name)
> -			goto out;
> -	}
> -
> -	rcu_read_lock();
> -	snprintf(tmp_name, PATH_MAX, "%s(%d:%s)", s->name,
> -			 memcg_cache_id(memcg), cgroup_name(memcg->css.cgroup));
> -	rcu_read_unlock();
> -
> -	new = kmem_cache_create_memcg(memcg, tmp_name, s->object_size, s->align,
> -				      (s->flags & ~SLAB_PANIC), s->ctor, s);
> -	if (new)
> -		new->allocflags |= __GFP_KMEMCG;
> -	else
> -		new = s;
> -out:
> -	mutex_unlock(&mutex);
> -	return new;
> -}
> -
>  void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
>  {
>  	struct kmem_cache *c;
> @@ -3481,12 +3469,6 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
>  	mutex_unlock(&activate_kmem_mutex);
>  }
>  
> -struct create_work {
> -	struct mem_cgroup *memcg;
> -	struct kmem_cache *cachep;
> -	struct work_struct work;
> -};
> -
>  static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
>  {
>  	struct kmem_cache *cachep;
> @@ -3504,13 +3486,24 @@ static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
>  	mutex_unlock(&memcg->slab_caches_mutex);
>  }
>  
> +struct create_work {
> +	struct mem_cgroup *memcg;
> +	struct kmem_cache *cachep;
> +	struct work_struct work;
> +};
> +
>  static void memcg_create_cache_work_func(struct work_struct *w)
>  {
> -	struct create_work *cw;
> +	struct create_work *cw = container_of(w, struct create_work, work);
> +	struct mem_cgroup *memcg = cw->memcg;
> +	struct kmem_cache *s = cw->cachep;
> +	struct kmem_cache *new;
>  
> -	cw = container_of(w, struct create_work, work);
> -	memcg_create_kmem_cache(cw->memcg, cw->cachep);
> -	css_put(&cw->memcg->css);
> +	new = kmem_cache_create_memcg(memcg, s->name, s->object_size, s->align,
> +				      (s->flags & ~SLAB_PANIC), s->ctor, s);
> +	if (new)
> +		new->allocflags |= __GFP_KMEMCG;
> +	css_put(&memcg->css);
>  	kfree(cw);
>  }
>  
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index e77b51eb7347..11857abf7057 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -215,7 +215,10 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
>  	s->align = calculate_alignment(flags, align, size);
>  	s->ctor = ctor;
>  
> -	s->name = kstrdup(name, GFP_KERNEL);
> +	if (memcg)
> +		s->name = memcg_create_cache_name(memcg, parent_cache);
> +	else
> +		s->name = kstrdup(name, GFP_KERNEL);
>  	if (!s->name)
>  		goto out_free_cache;
>  
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
