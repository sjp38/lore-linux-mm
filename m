Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA1276B0022
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 16:11:14 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id f194-v6so4808120lff.6
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 13:11:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t130-v6sor2928048lff.33.2018.03.24.13.11.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Mar 2018 13:11:13 -0700 (PDT)
Date: Sat, 24 Mar 2018 23:11:10 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 09/10] mm: Iterate only over charged shrinkers during
 memcg shrink_slab()
Message-ID: <20180324201109.r4udxibbg4t23apg@esperanza>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163857170.21546.16040899989532143840.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152163857170.21546.16040899989532143840.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

On Wed, Mar 21, 2018 at 04:22:51PM +0300, Kirill Tkhai wrote:
> Using the preparations made in previous patches, in case of memcg
> shrink, we may avoid shrinkers, which are not set in memcg's shrinkers
> bitmap. To do that, we separate iterations over memcg-aware and
> !memcg-aware shrinkers, and memcg-aware shrinkers are chosen
> via for_each_set_bit() from the bitmap. In case of big nodes,
> having many isolated environments, this gives significant
> performance growth. See next patch for the details.
> 
> Note, that the patch does not respect to empty memcg shrinkers,
> since we never clear the bitmap bits after we set it once.
> Their shrinkers will be called again, with no shrinked objects
> as result. This functionality is provided by next patch.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  mm/vmscan.c |   54 +++++++++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 41 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 265cf069b470..e1fd16bc7a9b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -327,6 +327,8 @@ static int alloc_shrinker_id(struct shrinker *shrinker)
>  
>  	if (!(shrinker->flags & SHRINKER_MEMCG_AWARE))
>  		return 0;
> +	BUG_ON(!(shrinker->flags & SHRINKER_NUMA_AWARE));
> +
>  retry:
>  	ida_pre_get(&bitmap_id_ida, GFP_KERNEL);
>  	down_write(&bitmap_rwsem);
> @@ -366,7 +368,8 @@ static void add_shrinker(struct shrinker *shrinker)
>  	down_write(&shrinker_rwsem);
>  	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
>  		mcg_shrinkers[shrinker->id] = shrinker;
> -	list_add_tail(&shrinker->list, &shrinker_list);
> +	else
> +		list_add_tail(&shrinker->list, &shrinker_list);

I don't think we should remove per-memcg shrinkers from the global
shrinker list - this is confusing. It won't be critical if we iterate
over all shrinkers on global reclaim, will it?

>  	up_write(&shrinker_rwsem);
>  }
>  
> @@ -701,6 +705,39 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  	if (!down_read_trylock(&shrinker_rwsem))
>  		goto out;
>  
> +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
> +	if (!memcg_kmem_enabled() || memcg) {
> +		struct shrinkers_map *map;
> +		int i;
> +
> +		map = rcu_dereference_protected(SHRINKERS_MAP(memcg), true);
> +		if (map) {
> +			for_each_set_bit(i, map->map[nid], bitmap_nr_ids) {
> +				struct shrink_control sc = {
> +					.gfp_mask = gfp_mask,
> +					.nid = nid,
> +					.memcg = memcg,
> +				};
> +
> +				shrinker = mcg_shrinkers[i];
> +				if (!shrinker) {
> +					clear_bit(i, map->map[nid]);
> +					continue;
> +				}
> +				freed += do_shrink_slab(&sc, shrinker, priority);
> +
> +				if (rwsem_is_contended(&shrinker_rwsem)) {
> +					freed = freed ? : 1;
> +					goto unlock;
> +				}
> +			}
> +		}
> +
> +		if (memcg_kmem_enabled() && memcg)
> +			goto unlock;

May be, factor this out to a separate function, say shrink_slab_memcg?
Just for the sake of code legibility.
