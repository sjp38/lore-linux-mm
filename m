Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ACB906B000D
	for <linux-mm@kvack.org>; Tue, 15 May 2018 06:12:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r63-v6so12775869pfl.12
        for <linux-mm@kvack.org>; Tue, 15 May 2018 03:12:31 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0108.outbound.protection.outlook.com. [104.47.2.108])
        by mx.google.com with ESMTPS id d31-v6si533721pld.23.2018.05.15.03.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 May 2018 03:12:30 -0700 (PDT)
Subject: Re: [PATCH v5 11/13] mm: Iterate only over charged shrinkers during
 memcg shrink_slab()
References: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
 <152594603565.22949.12428911301395699065.stgit@localhost.localdomain>
 <20180515054445.nhe4zigtelkois4p@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <fa35589b-0696-e029-4440-d91dc4c9ab2d@virtuozzo.com>
Date: Tue, 15 May 2018 13:12:20 +0300
MIME-Version: 1.0
In-Reply-To: <20180515054445.nhe4zigtelkois4p@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On 15.05.2018 08:44, Vladimir Davydov wrote:
> On Thu, May 10, 2018 at 12:53:55PM +0300, Kirill Tkhai wrote:
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
>>  include/linux/memcontrol.h |    1 +
>>  mm/vmscan.c                |   70 ++++++++++++++++++++++++++++++++++++++------
>>  2 files changed, 62 insertions(+), 9 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 82f892e77637..436691a66500 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -760,6 +760,7 @@ void mem_cgroup_split_huge_fixup(struct page *head);
>>  #define MEM_CGROUP_ID_MAX	0
>>  
>>  struct mem_cgroup;
>> +#define root_mem_cgroup NULL
> 
> Let's instead export mem_cgroup_is_root(). In case if MEMCG is disabled
> it will always return false.

export == move to header file

>>  
>>  static inline bool mem_cgroup_disabled(void)
>>  {
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index d8a2870710e0..a2e38e05adb5 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -376,6 +376,7 @@ int prealloc_shrinker(struct shrinker *shrinker)
>>  			goto free_deferred;
>>  	}
>>  
>> +	INIT_LIST_HEAD(&shrinker->list);
> 
> IMO this shouldn't be here, see my comment below.
> 
>>  	return 0;
>>  
>>  free_deferred:
>> @@ -547,6 +548,63 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>>  	return freed;
>>  }
>>  
>> +#ifdef CONFIG_MEMCG_SHRINKER
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
>> +	 * 1)Caller passes only alive memcg, so map can't be NULL.
>> +	 * 2)shrinker_rwsem protects from maps expanding.
> 
>             ^^
> Nit: space missing here :-)

I don't understand what you mean here. Please, clarify...

>> +	 */
>> +	map = rcu_dereference_protected(MEMCG_SHRINKER_MAP(memcg, nid), true);
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
>> +		if (!shrinker) {
>> +			clear_bit(i, map->map);
>> +			continue;
>> +		}
> 
> The shrinker must be memcg aware so please add
> 
>   BUG_ON((shrinker->flags & SHRINKER_MEMCG_AWARE) == 0);
> 
>> +		if (list_empty(&shrinker->list))
>> +			continue;
> 
> I don't like using shrinker->list as an indicator that the shrinker has
> been initialized. IMO if you do need such a check, you should split
> shrinker_idr registration in two steps - allocate a slot in 'prealloc'
> and set the pointer in 'register'. However, can we really encounter an
> unregistered shrinker here? AFAIU a bit can be set in the shrinker map
> only after the corresponding shrinker has been initialized, no?

1)No, it's not so. Here is a race:
cpu#0                        cpu#1                                   cpu#2
prealloc_shrinker()
                             prealloc_shrinker()
                               memcg_expand_shrinker_maps()
                                 memcg_expand_one_shrinker_map()
                                   memset(&new->map, 0xff);          
                                                                     do_shrink_slab() (on uninitialized LRUs)
init LRUs
register_shrinker_prepared()

So, the check is needed.

2)Assigning NULL pointer can't be used here, since NULL pointer is already used
to clear unregistered shrinkers from the map. See the check right after idr_find().

list_empty() is used since it's the already existing indicator, which does not
require additional member in struct shrinker.

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
>> +#else /* CONFIG_MEMCG_SHRINKER */
>> +static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
>> +			struct mem_cgroup *memcg, int priority)
>> +{
>> +	return 0;
>> +}
>> +#endif /* CONFIG_MEMCG_SHRINKER */
>> +
>>  /**
>>   * shrink_slab - shrink slab caches
>>   * @gfp_mask: allocation context
>> @@ -576,8 +634,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>>  	struct shrinker *shrinker;
>>  	unsigned long freed = 0;
>>  
>> -	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
>> -		return 0;
>> +	if (memcg && memcg != root_mem_cgroup)
> 
> if (!mem_cgroup_is_root(memcg))
> 
>> +		return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
>>  
>>  	if (!down_read_trylock(&shrinker_rwsem))
>>  		goto out;
>> @@ -589,13 +647,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
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
> 
> I want this check gone. It's easy to achieve, actually - just remove the
> following lines from shrink_node()
> 
> 		if (global_reclaim(sc))
> 			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
> 				    sc->priority);
> 
>>  
>>  		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
>>
