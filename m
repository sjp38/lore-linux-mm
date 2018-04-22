Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4936B0005
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 14:19:17 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h82-v6so2633578lfi.8
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 11:19:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o9sor1247878ljh.114.2018.04.22.11.19.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Apr 2018 11:19:15 -0700 (PDT)
Date: Sun, 22 Apr 2018 21:19:11 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2 10/12] mm: Iterate only over charged shrinkers during
 memcg shrink_slab()
Message-ID: <20180422181911.axqiabv3cl7qtrpc@esperanza>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
 <152399127400.3456.6644633244163904030.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152399127400.3456.6644633244163904030.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Tue, Apr 17, 2018 at 09:54:34PM +0300, Kirill Tkhai wrote:
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
>  mm/vmscan.c |   88 ++++++++++++++++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 72 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 34cd1d9b8b22..b81b8a7727b5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -169,6 +169,20 @@ unsigned long vm_total_pages;
>  static LIST_HEAD(shrinker_list);
>  static DECLARE_RWSEM(shrinker_rwsem);
>  
> +static void link_shrinker(struct shrinker *shrinker)
> +{
> +	down_write(&shrinker_rwsem);
> +	list_add_tail(&shrinker->list, &shrinker_list);
> +	up_write(&shrinker_rwsem);
> +}
> +
> +static void unlink_shrinker(struct shrinker *shrinker)
> +{
> +	down_write(&shrinker_rwsem);
> +	list_del(&shrinker->list);
> +	up_write(&shrinker_rwsem);
> +}
> +
>  #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
>  static DEFINE_IDR(shrinkers_id_idr);
>  
> @@ -221,11 +235,13 @@ static void del_memcg_shrinker(struct shrinker *shrinker)
>  #else /* CONFIG_MEMCG && !CONFIG_SLOB */
>  static int add_memcg_shrinker(struct shrinker *shrinker, int nr, va_list args)
>  {
> +	link_shrinker(shrinker);
>  	return 0;
>  }
>  
>  static void del_memcg_shrinker(struct shrinker *shrinker)
>  {
> +	unlink_shrinker(shrinker);
>  }
>  #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
>  
> @@ -382,11 +398,9 @@ int __register_shrinker(struct shrinker *shrinker, int nr, ...)
>  		va_end(args);
>  		if (ret)
>  			goto free_deferred;
> -	}
> +	} else
> +		link_shrinker(shrinker);
>  
> -	down_write(&shrinker_rwsem);
> -	list_add_tail(&shrinker->list, &shrinker_list);
> -	up_write(&shrinker_rwsem);
>  	return 0;
>  
>  free_deferred:
> @@ -405,9 +419,8 @@ void unregister_shrinker(struct shrinker *shrinker)
>  		return;
>  	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
>  		del_memcg_shrinker(shrinker);
> -	down_write(&shrinker_rwsem);
> -	list_del(&shrinker->list);
> -	up_write(&shrinker_rwsem);
> +	else
> +		unlink_shrinker(shrinker);

I really don't like that depending on the config, the shrinker_list
stores either all shrinkers or only memcg-unaware ones. I think it
should always store all shrinkers and it should be used in case of
global reclaim. That is IMO shrink_slab should look like this:

shrink_slab(memcg)
{
        if (!mem_cgroup_is_root(memcg))
                return shrink_slab_memcg()
        list_for_each(shrinker, shrinker_list, link)
                do_shrink_slab()
}

Yeah, that means that for the root mem cgroup we will always call all
shrinkers, but IMO it is OK as there's the only root mem cgroup out
there and it is visited only on global reclaim so it shouldn't degrade
performance.

>  	kfree(shrinker->nr_deferred);
>  	shrinker->nr_deferred = NULL;
>  }
> @@ -532,6 +545,53 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  	return freed;
>  }
>  
> +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
> +static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
> +				       struct mem_cgroup *memcg,
> +				       int priority)
> +{
> +	struct memcg_shrinker_map *map;
> +	unsigned long freed = 0;
> +	int ret, i;
> +
> +	if (!down_read_trylock(&shrinker_rwsem))
> +		return 0;
> +
> +	/*
> +	 * 1)Caller passes only alive memcg, so map can't be NULL.
> +	 * 2)shrinker_rwsem protects from maps expanding.
> +	 */
> +	map = rcu_dereference_protected(SHRINKERS_MAP(memcg, nid), true);
> +	BUG_ON(!map);
> +
> +	for_each_set_bit(i, map->map, shrinkers_max_nr) {
> +		struct shrink_control sc = {
> +			.gfp_mask = gfp_mask,
> +			.nid = nid,
> +			.memcg = memcg,
> +		};
> +		struct shrinker *shrinker;
> +
> +		shrinker = idr_find(&shrinkers_id_idr, i);
> +		if (!shrinker) {
> +			clear_bit(i, map->map);
> +			continue;
> +		}
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
> +#endif
> +
>  /**
>   * shrink_slab - shrink slab caches
>   * @gfp_mask: allocation context
> @@ -564,6 +624,11 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
>  		return 0;

The check above should be moved to shrink_slab_memcg.

>  
> +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)

Please don't use ifdef here - define a stub function for no-memcg case.

> +	if (memcg)
> +		return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
> +#endif
> +
>  	if (!down_read_trylock(&shrinker_rwsem))
>  		goto out;
>  
> @@ -574,15 +639,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
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
> -			continue;
> -
>  		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
>  			sc.nid = 0;
>  
> 
