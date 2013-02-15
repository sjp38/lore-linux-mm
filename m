Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 092796B0007
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 05:36:30 -0500 (EST)
Message-ID: <511E0FC1.9000208@parallels.com>
Date: Fri, 15 Feb 2013 14:36:49 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] memcg,list_lru: duplicate LRUs upon kmemcg creation
References: <1360328857-28070-1-git-send-email-glommer@parallels.com> <1360328857-28070-3-git-send-email-glommer@parallels.com> <511DFE22.4000003@jp.fujitsu.com>
In-Reply-To: <511DFE22.4000003@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Shrinnker <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On 02/15/2013 01:21 PM, Kamezawa Hiroyuki wrote:
> (2013/02/08 22:07), Glauber Costa wrote:
>> When a new memcg is created, we need to open up room for its descriptors
>> in all of the list_lrus that are marked per-memcg. The process is quite
>> similar to the one we are using for the kmem caches: we initialize the
>> new structures in an array indexed by kmemcg_id, and grow the array if
>> needed. Key data like the size of the array will be shared between the
>> kmem cache code and the list_lru code (they basically describe the same
>> thing)
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> Cc: Dave Chinner <dchinner@redhat.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Michal Hocko <mhocko@suse.cz>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>   include/linux/list_lru.h   |  47 +++++++++++++++++
>>   include/linux/memcontrol.h |   6 +++
>>   lib/list_lru.c             | 115 +++++++++++++++++++++++++++++++++++++---
>>   mm/memcontrol.c            | 128 ++++++++++++++++++++++++++++++++++++++++++---
>>   mm/slab_common.c           |   1 -
>>   5 files changed, 283 insertions(+), 14 deletions(-)
>>
>> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
>> index 02796da..370b989 100644
>> --- a/include/linux/list_lru.h
>> +++ b/include/linux/list_lru.h
>> @@ -16,11 +16,58 @@ struct list_lru_node {
>>   	long			nr_items;
>>   } ____cacheline_aligned_in_smp;
>>   
>> +struct list_lru_array {
>> +	struct list_lru_node node[1];
>> +};
> 
> size is up to nr_node_ids ?
> 

This is a dynamic quantity, so the correct way to do it is to size it to
1 (or 0 for that matter), have it be the last element of the struct, and
then allocate the right size at allocation time.

>> +
>>   struct list_lru {
>> +	struct list_head	lrus;
>>   	struct list_lru_node	node[MAX_NUMNODES];
>>   	nodemask_t		active_nodes;
>> +#ifdef CONFIG_MEMCG_KMEM
>> +	struct list_lru_array	**memcg_lrus;
>> +#endif
>>   };
> size is up to memcg_limited_groups_array_size ?
> 
ditto. This one not only is a dynamic quantity, but also changes as
new memcgs are created.

>> +/*
>> + * We will reuse the last bit of the pointer to tell the lru subsystem that
>> + * this particular lru should be replicated when a memcg comes in.
>> + */
>> +static inline void lru_memcg_enable(struct list_lru *lru)
>> +{
>> +	lru->memcg_lrus = (void *)0x1ULL;
>> +}
>> +
> 
> This "enable" is not used in this patch itself, right ?
> 
I am not sure. It is definitely used later on, I can check and move it
if necessary.

>> +int __list_lru_init(struct list_lru *lru)
>>   {
>>   	int i;
>>   
>>   	nodes_clear(lru->active_nodes);
>> -	for (i = 0; i < MAX_NUMNODES; i++) {
>> -		spin_lock_init(&lru->node[i].lock);
>> -		INIT_LIST_HEAD(&lru->node[i].list);
>> -		lru->node[i].nr_items = 0;
>> +	for (i = 0; i < MAX_NUMNODES; i++)
>> +		list_lru_init_one(&lru->node[i]);
> 
> Hmm. lru_list is up to MAX_NUMNODES, your new one is up to nr_node_ids...
>

well spotted.
Thanks.

>> +	INIT_LIST_HEAD(&lru->lrus);
>> +	mutex_lock(&all_lrus_mutex);
>> +	list_add(&lru->lrus, &all_lrus);
>> +	ret = memcg_new_lru(lru);
>> +	mutex_unlock(&all_lrus_mutex);
>> +	return ret;
>> +}
> 
>  only writer takes this mutex ?
> 
yes. IIRC, I documented that. But I might be wrong (will check)

>> +void list_lru_destroy_memcg(struct mem_cgroup *memcg)
>> +{
>> +	struct list_lru *lru;
>> +	mutex_lock(&all_lrus_mutex);
>> +	list_for_each_entry(lru, &all_lrus, lrus) {
>> +		lru->memcg_lrus[memcg_cache_id(memcg)] = NULL;
>> +		/* everybody must beaware that this memcg is no longer valid */
> 
> Hm, the object pointed by this array entry will be freed by some other func ?

They should be destroyed before we get here, but I am skimming through
the code now, and I see they are not. On a second thought, I think it
would be simpler and less error prone if I would just free them here...

>> +		new_lru_array = kzalloc(size * sizeof(void *), GFP_KERNEL);
>> +		if (!new_lru_array) {
>> +			kfree(lru_array);
>> +			return -ENOMEM;
>> +		}
>> +
>> +		for (i = 0; i < memcg_limited_groups_array_size; i++) {
>> +			if (!lru_memcg_is_assigned(lru) || lru->memcg_lrus[i])
>> +				continue;
>> +			new_lru_array[i] =  lru->memcg_lrus[i];
>> +		}
>> +
>> +		old_array = lru->memcg_lrus;
>> +		lru->memcg_lrus = new_lru_array;
>> +		/*
>> +		 * We don't need a barrier here because we are just copying
>> +		 * information over. Anybody operating in memcg_lrus will
>> +		 * either follow the new array or the old one and they contain
>> +		 * exactly the same information. The new space in the end is
>> +		 * always empty anyway.
>> +		 *
>> +		 * We do have to make sure that no more users of the old
>> +		 * memcg_lrus array exist before we free, and this is achieved
>> +		 * by the synchronize_lru below.
>> +		 */
>> +		if (lru_memcg_is_assigned(lru)) {
>> +			synchronize_rcu();
>> +			kfree(old_array);
>> +		}
>> +
>> +	}
>> +
>> +	if (lru_memcg_is_assigned(lru)) {
>> +		lru->memcg_lrus[num_groups - 1] = lru_array;
> 
> Can't this pointer already set ?
> 
If it is, it is a bug. I can set VM_BUG_ON here to catch those cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
