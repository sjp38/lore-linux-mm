Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 501806B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 16:58:17 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id n20-v6so1415562pgv.14
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 13:58:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p5-v6si1688647pgq.126.2018.07.03.13.58.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 13:58:15 -0700 (PDT)
Date: Tue, 3 Jul 2018 13:58:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 14/17] mm: Iterate only over charged shrinkers during
 memcg shrink_slab()
Message-Id: <20180703135813.ed4eef6a4a2df32fa1085e4c@linux-foundation.org>
In-Reply-To: <153063066653.1818.976035462801487910.stgit@localhost.localdomain>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
	<153063066653.1818.976035462801487910.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Tue, 03 Jul 2018 18:11:06 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

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
> ...
>
> @@ -541,6 +555,67 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
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

Why trylock?  Presumably some other code path is known to hold the lock
for long periods?  Dunno.  Comment it, please.

> +	/*
> +	 * 1) Caller passes only alive memcg, so map can't be NULL.
> +	 * 2) shrinker_rwsem protects from maps expanding.
> +	 */
> +	map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
> +					true);
> +	BUG_ON(!map);
> +
> +	for_each_set_bit(i, map->map, shrinker_nr_max) {
> +		struct shrink_control sc = {
> +			.gfp_mask = gfp_mask,
> +			.nid = nid,
> +			.memcg = memcg,
> +		};
> +		struct shrinker *shrinker;
> +
> +		shrinker = idr_find(&shrinker_idr, i);
> +		if (unlikely(!shrinker)) {
> +			clear_bit(i, map->map);
> +			continue;
> +		}
> +		BUG_ON(!(shrinker->flags & SHRINKER_MEMCG_AWARE));

Fair enough as a development-time sanity check but we shouldn't need
this in production code.  Or make it VM_BUG_ON(), at least.

> +		/* See comment in prealloc_shrinker() */
> +		if (unlikely(list_empty(&shrinker->list)))
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
