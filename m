Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9316B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 05:19:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c187-v6so8970309pfa.20
        for <linux-mm@kvack.org>; Mon, 21 May 2018 02:19:24 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0106.outbound.protection.outlook.com. [104.47.0.106])
        by mx.google.com with ESMTPS id q75-v6si13964629pfk.268.2018.05.21.02.19.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 May 2018 02:19:23 -0700 (PDT)
Subject: Re: [PATCH v6 15/17] mm: Generalize shrink_slab() calls in
 shrink_node()
References: <152663268383.5308.8660992135988724014.stgit@localhost.localdomain>
 <152663305153.5308.14479673190611499656.stgit@localhost.localdomain>
 <20180520080822.hqish62iahbonlht@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <1105a543-08f8-5284-81a9-3ea6739b489b@virtuozzo.com>
Date: Mon, 21 May 2018 12:19:12 +0300
MIME-Version: 1.0
In-Reply-To: <20180520080822.hqish62iahbonlht@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On 20.05.2018 11:08, Vladimir Davydov wrote:
> On Fri, May 18, 2018 at 11:44:11AM +0300, Kirill Tkhai wrote:
>> From: Vladimir Davydov <vdavydov.dev@gmail.com>
>>
>> The patch makes shrink_slab() be called for root_mem_cgroup
>> in the same way as it's called for the rest of cgroups.
>> This simplifies the logic and improves the readability.
>>
>> Signed-off-by: Vladimir Davydov <vdavydov.dev@gmail.com>
>> ktkhai: Description written.
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> ---
>>  mm/vmscan.c |   13 +++----------
>>  1 file changed, 3 insertions(+), 10 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 2fbf3b476601..f1d23e2df988 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
> 
> You forgot to patch the comment to shrink_slab(). Please take a closer
> look at the diff I sent you:
> 
> @@ -486,10 +486,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>   * @nid is passed along to shrinkers with SHRINKER_NUMA_AWARE set,
>   * unaware shrinkers will receive a node id of 0 instead.
>   *
> - * @memcg specifies the memory cgroup to target. If it is not NULL,
> - * only shrinkers with SHRINKER_MEMCG_AWARE set will be called to scan
> - * objects from the memory cgroup specified. Otherwise, only unaware
> - * shrinkers are called.
> + * @memcg specifies the memory cgroup to target. Unaware shrinkers
> + * are called only if it is the root cgroup.
>   *
>   * @priority is sc->priority, we take the number of objects and >> by priority
>   * in order to get the scan target.
> 
>> @@ -661,9 +661,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>>  			.memcg = memcg,
>>  		};
> 
> If you made !MEMCG version of mem_cgroup_is_root return true, as I
> suggested in reply to patch 13, you could also simplify the memcg
> related check in the beginning of shrink_slab() as in case of
> CONFIG_MEMCG 'memcg' is now guaranteed to be != NULL in this function
> while in case if !CONFIG_MEMCG mem_cgroup_is_root() would always
> return true:
> 
> @@ -501,7 +501,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  	struct shrinker *shrinker;
>  	unsigned long freed = 0;
>  
> -	if (memcg && !mem_cgroup_is_root(memcg))
> +	if (!mem_cgroup_is_root(memcg))

Yeah, we can do this. root_mem_cgroup is also initialized in case of memory
controller is disabled via boot parameters, so this works in all situations.

>  		return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
>  
>  	if (!down_read_trylock(&shrinker_rwsem))
> 
>>  
>> -		if (!!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
>> -			continue;
>> -
>>  		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
>>  			sc.nid = 0;
>>  
>> @@ -693,6 +690,7 @@ void drop_slab_node(int nid)
>>  		struct mem_cgroup *memcg = NULL;
>>  
>>  		freed = 0;
>> +		memcg = mem_cgroup_iter(NULL, NULL, NULL);
>>  		do {
>>  			freed += shrink_slab(GFP_KERNEL, nid, memcg, 0);
>>  		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
>> @@ -2712,9 +2710,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>>  			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
>>  			node_lru_pages += lru_pages;
>>  
>> -			if (memcg)
>> -				shrink_slab(sc->gfp_mask, pgdat->node_id,
>> -					    memcg, sc->priority);
>> +			shrink_slab(sc->gfp_mask, pgdat->node_id,
>> +				    memcg, sc->priority);
>>  
>>  			/* Record the group's reclaim efficiency */
>>  			vmpressure(sc->gfp_mask, memcg, false,
>> @@ -2738,10 +2735,6 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>>  			}
>>  		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
>>  
>> -		if (global_reclaim(sc))
>> -			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
>> -				    sc->priority);
>> -
>>  		if (reclaim_state) {
>>  			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
>>  			reclaim_state->reclaimed_slab = 0;
>>
