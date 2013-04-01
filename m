Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 1D7C46B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 04:22:03 -0400 (EDT)
Message-ID: <515943CE.9070709@parallels.com>
Date: Mon, 1 Apr 2013 12:22:38 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 22/28] memcg,list_lru: duplicate LRUs upon kmemcg creation
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-23-git-send-email-glommer@parallels.com> <51593FD0.9080502@jp.fujitsu.com>
In-Reply-To: <51593FD0.9080502@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

Hi Kame,

>>   
>> +/*
>> + * This is supposed to be M x N matrix, where M is kmem-limited memcg,
>> + * and N is the number of nodes.
>> + */
> 
> Could you add a comment that M can be changed and the array can be resized.
Yes, I can.

> 
>> +struct list_lru_array {
>> +	struct list_lru_node node[1];
>> +};
>> +
>>   struct list_lru {
>>   	struct list_lru_node	node[MAX_NUMNODES];
>>   	nodemask_t		active_nodes;
>> +#ifdef CONFIG_MEMCG_KMEM
>> +	struct list_head	lrus;
>> +	struct list_lru_array	**memcg_lrus;
>> +#endif
> 
> please add comments, for what ....
> 
ok.

>> +struct list_lru_array *lru_alloc_array(void)
>> +{
>> +	struct list_lru_array *lru_array;
>>   	int i;
>>   
>> -	nodes_clear(lru->active_nodes);
>> -	for (i = 0; i < MAX_NUMNODES; i++) {
>> -		spin_lock_init(&lru->node[i].lock);
>> -		INIT_LIST_HEAD(&lru->node[i].list);
>> -		lru->node[i].nr_items = 0;
>> +	lru_array = kzalloc(nr_node_ids * sizeof(struct list_lru_node),
>> +				GFP_KERNEL);
> 
> A nitpick...you can use kmalloc() here. All field will be overwritten.
It is, however, not future-proof if anyone wants to add more fields, and
forget to zero out the structure. If you really feel strongly for
kmalloc I can change. But I don't see this as a big issue, specially
this not being a fast path.

>> +#ifdef CONFIG_MEMCG_KMEM
>> +int __memcg_init_lru(struct list_lru *lru)
>> +{
>> +	int ret;
>> +
>> +	INIT_LIST_HEAD(&lru->lrus);
>> +	mutex_lock(&all_memcg_lrus_mutex);
>> +	list_add(&lru->lrus, &all_memcg_lrus);
>> +	ret = memcg_new_lru(lru);
>> +	mutex_unlock(&all_memcg_lrus_mutex);
>> +	return ret;
>> +}
> 
> returns 0 at success ? what kind of error can be shown here ?
> 

memcg_new_lru will allocate memory, and therefore can fail with ENOMEM.
It will already return 0 itself on success, so just forwarding its
return value is around.

>> -EXPORT_SYMBOL_GPL(list_lru_init);
>> +EXPORT_SYMBOL_GPL(__list_lru_init);
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index ecdae39..c6c90d8 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2988,16 +2988,30 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
>>   	memcg_kmem_set_activated(memcg);
>>   
>>   	ret = memcg_update_all_caches(num+1);
>> -	if (ret) {
>> -		ida_simple_remove(&kmem_limited_groups, num);
>> -		memcg_kmem_clear_activated(memcg);
>> -		return ret;
>> -	}
>> +	if (ret)
>> +		goto out;
>> +
>> +	/*
>> +	 * We should make sure that the array size is not updated until we are
>> +	 * done; otherwise we have no easy way to know whether or not we should
>> +	 * grow the array.
>> +	 */
>> +	ret = memcg_update_all_lrus(num + 1);
>> +	if (ret)
>> +		goto out;
>>   
>>   	memcg->kmemcg_id = num;
>> +
>> +	memcg_update_array_size(num + 1);
>> +
>>   	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
>>   	mutex_init(&memcg->slab_caches_mutex);
>> +
>>   	return 0;
>> +out:
>> +	ida_simple_remove(&kmem_limited_groups, num);
>> +	memcg_kmem_clear_activated(memcg);
>> +	return ret;
> 
> When this failure can happens ? This happens only when the user
> tries to set kmem_limit and doesn't affect kernel internal logic ?
> 

There are 2 points of failure for this:
1) setting kmem limit from a previously unset scenario,
2) creating a new child memcg, as a child of a kmem limited memcg

Those are the same as the slab, and indeed they are attempted right
after it.

LRU initialization failures can still exist in a 3rd way, when a new LRU
is created and we have no memory available to hold its structures. But
this will not be called from here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
