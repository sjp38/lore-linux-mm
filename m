Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id D13026B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 04:50:44 -0400 (EDT)
Message-ID: <51594A8A.7020704@parallels.com>
Date: Mon, 1 Apr 2013 12:51:22 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 21/28] vmscan: also shrink slab in memcg pressure
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-22-git-send-email-glommer@parallels.com> <51593B70.6080003@jp.fujitsu.com>
In-Reply-To: <51593B70.6080003@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

Hi Kame,

>>   /*
>>    * In general, we'll do everything in our power to not incur in any overhead
>>    * for non-memcg users for the kmem functions. Not even a function call, if we
>> @@ -562,6 +573,12 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
>>   	return __memcg_kmem_get_cache(cachep, gfp);
>>   }
>>   #else
>> +
>> +static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
>> +{
>> +	return false;
>> +}
>> +
>>   #define for_each_memcg_cache_index(_idx)	\
>>   	for (; NULL; )
>>   
>> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
>> index d4636a0..4e9e53b 100644
>> --- a/include/linux/shrinker.h
>> +++ b/include/linux/shrinker.h
>> @@ -20,6 +20,9 @@ struct shrink_control {
>>   
>>   	/* shrink from these nodes */
>>   	nodemask_t nodes_to_scan;
>> +
>> +	/* reclaim from this memcg only (if not NULL) */
>> +	struct mem_cgroup *target_mem_cgroup;
>>   };
> 
> Does this works only with kmem ? If so, please rename to some explicit
> name for now.
> 
>   shrink_slab_memcg_target or some ?

No, this is not kmem specific. It will be used (so far) to determine
which shrinkers to shrink from, but since we are now including
shrink_slab in user pressure as well, this can very well be filled by
user memory pressure code. (This will be the case, for instance, if umem
== kmem)

Therefore, it is the same target_mem_cgroup context we are already
passing around in other vmscan functions. But shrink_control had none,
and now we are attaching it there.

Therefore I would like to maintain it neutral, just as memcg.
> 

>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 2b55222..ecdae39 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -386,7 +386,7 @@ static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
>>   	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
>>   }
>>   
>> -static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
>> +bool memcg_kmem_is_active(struct mem_cgroup *memcg)
>>   {
>>   	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
>>   }
>> @@ -942,6 +942,20 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
>>   	return ret;
>>   }
>>   
>> +unsigned long
>> +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)
>> +{
>> +	int nid = zone_to_nid(zone);
>> +	int zid = zone_idx(zone);
>> +	unsigned long val;
>> +
>> +	val = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid, LRU_ALL_FILE);
>> +	if (do_swap_account)
>> +		val += mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
>> +						    LRU_ALL_ANON);
>> +	return val;
>> +}
>> +
>>   static unsigned long
>>   mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
>>   			int nid, unsigned int lru_mask)
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 232dfcb..43928fd 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -138,11 +138,42 @@ static bool global_reclaim(struct scan_control *sc)
>>   {
>>   	return !sc->target_mem_cgroup;
>>   }
>> +
>> +/*
>> + * kmem reclaim should usually not be triggered when we are doing targetted
>> + * reclaim. It is only valid when global reclaim is triggered, or when the
>> + * underlying memcg has kmem objects.
>> + */
>> +static bool has_kmem_reclaim(struct scan_control *sc)
>> +{
>> +	return !sc->target_mem_cgroup ||
>> +		memcg_kmem_is_active(sc->target_mem_cgroup);
>> +}
> 
> Is this test hierarchy aware ?
> 
> For example, in following case,
> 
>   A      no kmem limit
>    \
>     B    kmem limit=XXX
>      \
>       C  kmem limit=XXX
> 
> what happens when A is the target.
> 

When A is under pressure, we won't scan A. I coded it like this because
the slabs are local, even if the charges are not.

In other words, because I won't scan the memcgs hierarchically, I didn't
bother noticing about their kmem awareness hierarchically.

But I am still thinking about that, and your input is very welcome.

In one hand, A won't have a kmem res_counter, so we won't be able to
uncharge anything from it. On the other hand, the charges are also
accumulated on the user res_counter of A. Under user pressure, it may be
important to free this memory. So I am inclined to change that.

Do you agree?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
