Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f177.google.com (mail-ea0-f177.google.com [209.85.215.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB836B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 12:14:13 -0500 (EST)
Received: by mail-ea0-f177.google.com with SMTP id n15so3721190ead.8
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 09:14:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w6si853762eeg.195.2013.12.18.09.14.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 09:14:12 -0800 (PST)
Date: Wed, 18 Dec 2013 18:14:11 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/6] memcg, slab: cleanup barrier usage when accessing
 memcg_caches
Message-ID: <20131218171411.GD31080@dhcp22.suse.cz>
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
 <bd0a7ffc57e4a0b0c3d456c0cf8801e829e14717.1387372122.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bd0a7ffc57e4a0b0c3d456c0cf8801e829e14717.1387372122.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed 18-12-13 17:16:54, Vladimir Davydov wrote:
> First, in memcg_create_kmem_cache() we should issue the write barrier
> after the kmem_cache is initialized, but before storing the pointer to
> it in its parent's memcg_params.
> 
> Second, we should always issue the read barrier after
> cache_from_memcg_idx() to conform with the write barrier.
> 
> Third, its better to use smp_* versions of barriers, because we don't
> need them on UP systems.

Please be (much) more verbose on Why. Barriers are tricky and should be
documented accordingly. So if you say that we should issue a barrier
always be specific why we should do it.

> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Glauber Costa <glommer@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  mm/memcontrol.c |   24 ++++++++++--------------
>  mm/slab.h       |    6 +++++-
>  2 files changed, 15 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e6ad6ff..e37fdb5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3429,12 +3429,14 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
>  
>  	atomic_set(&new_cachep->memcg_params->nr_pages , 0);
>  
> -	cachep->memcg_params->memcg_caches[idx] = new_cachep;
>  	/*
> -	 * the readers won't lock, make sure everybody sees the updated value,
> -	 * so they won't put stuff in the queue again for no reason
> +	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
> +	 * barrier here to ensure nobody will see the kmem_cache partially
> +	 * initialized.
>  	 */
> -	wmb();
> +	smp_wmb();
> +
> +	cachep->memcg_params->memcg_caches[idx] = new_cachep;
>  out:
>  	mutex_unlock(&memcg_cache_mutex);
>  	return new_cachep;
> @@ -3573,7 +3575,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
>  					  gfp_t gfp)
>  {
>  	struct mem_cgroup *memcg;
> -	int idx;
> +	struct kmem_cache *memcg_cachep;
>  
>  	VM_BUG_ON(!cachep->memcg_params);
>  	VM_BUG_ON(!cachep->memcg_params->is_root_cache);
> @@ -3587,15 +3589,9 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
>  	if (!memcg_can_account_kmem(memcg))
>  		goto out;
>  
> -	idx = memcg_cache_id(memcg);
> -
> -	/*
> -	 * barrier to mare sure we're always seeing the up to date value.  The
> -	 * code updating memcg_caches will issue a write barrier to match this.
> -	 */
> -	read_barrier_depends();
> -	if (likely(cache_from_memcg_idx(cachep, idx))) {
> -		cachep = cache_from_memcg_idx(cachep, idx);
> +	memcg_cachep = cache_from_memcg_idx(cachep, memcg_cache_id(memcg));
> +	if (likely(memcg_cachep)) {
> +		cachep = memcg_cachep;
>  		goto out;
>  	}
>  
> diff --git a/mm/slab.h b/mm/slab.h
> index 0859c42..1d8b53f 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -163,9 +163,13 @@ static inline const char *cache_name(struct kmem_cache *s)
>  static inline struct kmem_cache *
>  cache_from_memcg_idx(struct kmem_cache *s, int idx)
>  {
> +	struct kmem_cache *cachep;
> +
>  	if (!s->memcg_params)
>  		return NULL;
> -	return s->memcg_params->memcg_caches[idx];
> +	cachep = s->memcg_params->memcg_caches[idx];
> +	smp_read_barrier_depends();	/* see memcg_register_cache() */
> +	return cachep;
>  }
>  
>  static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
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
