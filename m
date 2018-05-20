Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C0356B06F1
	for <linux-mm@kvack.org>; Sun, 20 May 2018 04:00:08 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id u13-v6so4600336lff.0
        for <linux-mm@kvack.org>; Sun, 20 May 2018 01:00:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m71-v6sor298128lfg.55.2018.05.20.01.00.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 May 2018 01:00:06 -0700 (PDT)
Date: Sun, 20 May 2018 11:00:03 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v6 14/17] mm: Iterate only over charged shrinkers during
 memcg shrink_slab()
Message-ID: <20180520080003.gfygtb6rloqpjaol@esperanza>
References: <152663268383.5308.8660992135988724014.stgit@localhost.localdomain>
 <152663304128.5308.12840831728812876902.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152663304128.5308.12840831728812876902.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Fri, May 18, 2018 at 11:44:01AM +0300, Kirill Tkhai wrote:
> Using the preparations made in previous patches, in case of memcg
> shrink, we may avoid shrinkers, which are not set in memcg's shrinkers
> bitmap. To do that, we separate iterations over memcg-aware and
> !memcg-aware shrinkers, and memcg-aware shrinkers are chosen
> via for_each_set_bit() from the bitmap. In case of big nodes,
> having many isolated environments, this gives significant
> performance growth. See next patches for the details.
> 
> Note, that the patch does not respect to empty memcg shrinkers,
> since we never clear the bitmap bits after we set it once.
> Their shrinkers will be called again, with no shrinked objects
> as result. This functionality is provided by next patches.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  mm/vmscan.c |   87 +++++++++++++++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 78 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f09ea20d7270..2fbf3b476601 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -373,6 +373,20 @@ int prealloc_shrinker(struct shrinker *shrinker)
>  			goto free_deferred;
>  	}
>  
> +	/*
> +	 * There is a window between prealloc_shrinker()
> +	 * and register_shrinker_prepared(). We don't want
> +	 * to clear bit of a shrinker in such the state
> +	 * in shrink_slab_memcg(), since this will impose
> +	 * restrictions on a code registering a shrinker
> +	 * (they would have to guarantee, their LRU lists
> +	 * are empty till shrinker is completely registered).
> +	 * So, we differ the situation, when 1)a shrinker
> +	 * is semi-registered (id is assigned, but it has
> +	 * not yet linked to shrinker_list) and 2)shrinker
> +	 * is not registered (id is not assigned).
> +	 */
> +	INIT_LIST_HEAD(&shrinker->list);
>  	return 0;
>  
>  free_deferred:
> @@ -544,6 +558,67 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  	return freed;
>  }
>  
> +#ifdef CONFIG_MEMCG_KMEM
> +static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
> +			struct mem_cgroup *memcg, int priority)
> +{
> +	struct memcg_shrinker_map *map;
> +	unsigned long freed = 0;
> +	int ret, i;
> +
> +	if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
> +		return 0;
> +
> +	if (!down_read_trylock(&shrinker_rwsem))
> +		return 0;
> +
> +	/*
> +	 * 1) Caller passes only alive memcg, so map can't be NULL.
> +	 * 2) shrinker_rwsem protects from maps expanding.
> +	 */
> +	map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
> +					true);
> +	BUG_ON(!map);
> +
> +	for_each_set_bit(i, map->map, memcg_shrinker_nr_max) {
> +		struct shrink_control sc = {
> +			.gfp_mask = gfp_mask,
> +			.nid = nid,
> +			.memcg = memcg,
> +		};
> +		struct shrinker *shrinker;
> +
> +		shrinker = idr_find(&shrinker_idr, i);
> +		if (unlikely(!shrinker)) {

Nit: I don't think 'unlikely' is required here as this is definitely not
a hot path.

> +			clear_bit(i, map->map);
> +			continue;
> +		}
> +		BUG_ON(!(shrinker->flags & SHRINKER_MEMCG_AWARE));
> +
> +		/* See comment in prealloc_shrinker() */
> +		if (unlikely(list_empty(&shrinker->list)))

Ditto.

> +			continue;
> +
> +		ret = do_shrink_slab(&sc, shrinker, priority);
> +		freed += ret;
> +
> +		if (rwsem_is_contended(&shrinker_rwsem)) {
> +			freed = freed ? : 1;
> +			break;
> +		}
> +	}
> +
> +	up_read(&shrinker_rwsem);
> +	return freed;
> +}
> +#else /* CONFIG_MEMCG_KMEM */
> +static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
> +			struct mem_cgroup *memcg, int priority)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_MEMCG_KMEM */
> +
>  /**
>   * shrink_slab - shrink slab caches
>   * @gfp_mask: allocation context
> @@ -573,8 +648,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  	struct shrinker *shrinker;
>  	unsigned long freed = 0;
>  
> -	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
> -		return 0;
> +	if (memcg && !mem_cgroup_is_root(memcg))
> +		return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
>  
>  	if (!down_read_trylock(&shrinker_rwsem))
>  		goto out;
> @@ -586,13 +661,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  			.memcg = memcg,
>  		};
>  
> -		/*
> -		 * If kernel memory accounting is disabled, we ignore
> -		 * SHRINKER_MEMCG_AWARE flag and call all shrinkers
> -		 * passing NULL for memcg.
> -		 */
> -		if (memcg_kmem_enabled() &&
> -		    !!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
> +		if (!!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
>  			continue;
>  
>  		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
> 
