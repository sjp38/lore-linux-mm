Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2FA6B0006
	for <linux-mm@kvack.org>; Mon, 21 May 2018 05:17:18 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id a5-v6so9679483plp.8
        for <linux-mm@kvack.org>; Mon, 21 May 2018 02:17:18 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0118.outbound.protection.outlook.com. [104.47.2.118])
        by mx.google.com with ESMTPS id y7-v6si10816513pgv.409.2018.05.21.02.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 May 2018 02:17:17 -0700 (PDT)
Subject: Re: [PATCH v6 14/17] mm: Iterate only over charged shrinkers during
 memcg shrink_slab()
References: <152663268383.5308.8660992135988724014.stgit@localhost.localdomain>
 <152663304128.5308.12840831728812876902.stgit@localhost.localdomain>
 <20180520080003.gfygtb6rloqpjaol@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <9eae0da6-5981-1ab2-af86-0a62ee31ba17@virtuozzo.com>
Date: Mon, 21 May 2018 12:17:07 +0300
MIME-Version: 1.0
In-Reply-To: <20180520080003.gfygtb6rloqpjaol@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On 20.05.2018 11:00, Vladimir Davydov wrote:
> On Fri, May 18, 2018 at 11:44:01AM +0300, Kirill Tkhai wrote:
>> Using the preparations made in previous patches, in case of memcg
>> shrink, we may avoid shrinkers, which are not set in memcg's shrinkers
>> bitmap. To do that, we separate iterations over memcg-aware and
>> !memcg-aware shrinkers, and memcg-aware shrinkers are chosen
>> via for_each_set_bit() from the bitmap. In case of big nodes,
>> having many isolated environments, this gives significant
>> performance growth. See next patches for the details.
>>
>> Note, that the patch does not respect to empty memcg shrinkers,
>> since we never clear the bitmap bits after we set it once.
>> Their shrinkers will be called again, with no shrinked objects
>> as result. This functionality is provided by next patches.
>>
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> ---
>>  mm/vmscan.c |   87 +++++++++++++++++++++++++++++++++++++++++++++++++++++------
>>  1 file changed, 78 insertions(+), 9 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index f09ea20d7270..2fbf3b476601 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -373,6 +373,20 @@ int prealloc_shrinker(struct shrinker *shrinker)
>>  			goto free_deferred;
>>  	}
>>  
>> +	/*
>> +	 * There is a window between prealloc_shrinker()
>> +	 * and register_shrinker_prepared(). We don't want
>> +	 * to clear bit of a shrinker in such the state
>> +	 * in shrink_slab_memcg(), since this will impose
>> +	 * restrictions on a code registering a shrinker
>> +	 * (they would have to guarantee, their LRU lists
>> +	 * are empty till shrinker is completely registered).
>> +	 * So, we differ the situation, when 1)a shrinker
>> +	 * is semi-registered (id is assigned, but it has
>> +	 * not yet linked to shrinker_list) and 2)shrinker
>> +	 * is not registered (id is not assigned).
>> +	 */
>> +	INIT_LIST_HEAD(&shrinker->list);
>>  	return 0;
>>  
>>  free_deferred:
>> @@ -544,6 +558,67 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>>  	return freed;
>>  }
>>  
>> +#ifdef CONFIG_MEMCG_KMEM
>> +static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
>> +			struct mem_cgroup *memcg, int priority)
>> +{
>> +	struct memcg_shrinker_map *map;
>> +	unsigned long freed = 0;
>> +	int ret, i;
>> +
>> +	if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
>> +		return 0;
>> +
>> +	if (!down_read_trylock(&shrinker_rwsem))
>> +		return 0;
>> +
>> +	/*
>> +	 * 1) Caller passes only alive memcg, so map can't be NULL.
>> +	 * 2) shrinker_rwsem protects from maps expanding.
>> +	 */
>> +	map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
>> +					true);
>> +	BUG_ON(!map);
>> +
>> +	for_each_set_bit(i, map->map, memcg_shrinker_nr_max) {
>> +		struct shrink_control sc = {
>> +			.gfp_mask = gfp_mask,
>> +			.nid = nid,
>> +			.memcg = memcg,
>> +		};
>> +		struct shrinker *shrinker;
>> +
>> +		shrinker = idr_find(&shrinker_idr, i);
>> +		if (unlikely(!shrinker)) {
> 
> Nit: I don't think 'unlikely' is required here as this is definitely not
> a hot path.

In case of big machines with many containers and overcommit, shrink_slab()
in general is very hot path. See the patchset description. There are configurations,
when only shrink_slab() is executing and occupies cpu for 100%, it's the reason
of this patchset is made for.

Here is the place we are absolutely sure shrinker is NULL in case if race with parallel
registering, so I don't see anything wrong to give compiler some information about branch
prediction.

>> +			clear_bit(i, map->map);
>> +			continue;
>> +		}
>> +		BUG_ON(!(shrinker->flags & SHRINKER_MEMCG_AWARE));
>> +
>> +		/* See comment in prealloc_shrinker() */
>> +		if (unlikely(list_empty(&shrinker->list)))
> 
> Ditto.
> 
>> +			continue;
>> +
>> +		ret = do_shrink_slab(&sc, shrinker, priority);
>> +		freed += ret;
>> +
>> +		if (rwsem_is_contended(&shrinker_rwsem)) {
>> +			freed = freed ? : 1;
>> +			break;
>> +		}
>> +	}
>> +
>> +	up_read(&shrinker_rwsem);
>> +	return freed;
>> +}
>> +#else /* CONFIG_MEMCG_KMEM */
>> +static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
>> +			struct mem_cgroup *memcg, int priority)
>> +{
>> +	return 0;
>> +}
>> +#endif /* CONFIG_MEMCG_KMEM */
>> +
>>  /**
>>   * shrink_slab - shrink slab caches
>>   * @gfp_mask: allocation context
>> @@ -573,8 +648,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>>  	struct shrinker *shrinker;
>>  	unsigned long freed = 0;
>>  
>> -	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
>> -		return 0;
>> +	if (memcg && !mem_cgroup_is_root(memcg))
>> +		return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
>>  
>>  	if (!down_read_trylock(&shrinker_rwsem))
>>  		goto out;
>> @@ -586,13 +661,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>>  			.memcg = memcg,
>>  		};
>>  
>> -		/*
>> -		 * If kernel memory accounting is disabled, we ignore
>> -		 * SHRINKER_MEMCG_AWARE flag and call all shrinkers
>> -		 * passing NULL for memcg.
>> -		 */
>> -		if (memcg_kmem_enabled() &&
>> -		    !!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
>> +		if (!!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
>>  			continue;
>>  
>>  		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
>>
