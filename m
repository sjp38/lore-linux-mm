Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 59D456B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 04:51:45 -0400 (EDT)
Message-ID: <51B04DD0.4060600@parallels.com>
Date: Thu, 6 Jun 2013 12:52:32 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 26/35] memcg,list_lru: duplicate LRUs upon kmemcg
 creation
References: <1370287804-3481-1-git-send-email-glommer@openvz.org> <1370287804-3481-27-git-send-email-glommer@openvz.org> <20130605160828.1ec9f3538258d9a6d6c74083@linux-foundation.org>
In-Reply-To: <20130605160828.1ec9f3538258d9a6d6c74083@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>

On 06/06/2013 03:08 AM, Andrew Morton wrote:
> On Mon,  3 Jun 2013 23:29:55 +0400 Glauber Costa <glommer@openvz.org> wrote:
> 
>> When a new memcg is created, we need to open up room for its descriptors
>> in all of the list_lrus that are marked per-memcg. The process is quite
>> similar to the one we are using for the kmem caches: we initialize the
>> new structures in an array indexed by kmemcg_id, and grow the array if
>> needed. Key data like the size of the array will be shared between the
>> kmem cache code and the list_lru code (they basically describe the same
>> thing)
> 
> Gee this is a big patchset.
> 
>>
>> ...
>>
>> --- a/include/linux/list_lru.h
>> +++ b/include/linux/list_lru.h
>> @@ -24,6 +24,23 @@ struct list_lru_node {
>>  	long			nr_items;
>>  } ____cacheline_aligned_in_smp;
>>  
>> +/*
>> + * This is supposed to be M x N matrix, where M is kmem-limited memcg, and N is
>> + * the number of nodes. Both dimensions are likely to be very small, but are
>> + * potentially very big. Therefore we will allocate or grow them dynamically.
>> + *
>> + * The size of M will increase as new memcgs appear and can be 0 if no memcgs
>> + * are being used. This is done in mm/memcontrol.c in a way quite similar than
> 
> "similar to"
> 
>> + * the way we use for the slab cache management.
>> + *
>> + * The size o N can't be determined at compile time, but won't increase once we
> 
> "value of N"
> 
>> + * determine it. It is nr_node_ids, the firmware-provided maximum number of
>> + * nodes in a system.
> 
> 
>> + */
>> +struct list_lru_array {
>> +	struct list_lru_node node[1];
>> +};
>> +
>>  struct list_lru {
>>  	/*
>>  	 * Because we use a fixed-size array, this struct can be very big if
>> @@ -37,9 +54,38 @@ struct list_lru {
>>  	 */
>>  	struct list_lru_node	node[MAX_NUMNODES];
>>  	nodemask_t		active_nodes;
>> +#ifdef CONFIG_MEMCG_KMEM
>> +	/* All memcg-aware LRUs will be chained in the lrus list */
>> +	struct list_head	lrus;
>> +	/* M x N matrix as described above */
>> +	struct list_lru_array	**memcg_lrus;
>> +#endif
>>  };
> 
> It's here where I decided "this code shouldn't be in lib/" ;)
> 
>> -int list_lru_init(struct list_lru *lru);
>> +struct mem_cgroup;
>> +#ifdef CONFIG_MEMCG_KMEM
>> +struct list_lru_array *lru_alloc_array(void);
> 
> Experience teaches it that it is often a mistake for callees to assume
> they will always be called in GFP_KERNEL context.  For high-level init
> code we can usually get away with it, but I do think that the decision
> to not provide a gfp_t argument should be justfied up-front, and that
> this restriction should be mentioned in the interface documentation
> (when it is written ;)).
> 
>>
>> ...
>>
>> @@ -163,18 +168,97 @@ list_lru_dispose_all(
>>  	return total;
>>  }
>>  
>> -int
>> -list_lru_init(
>> -	struct list_lru	*lru)
>> +/*
>> + * This protects the list of all LRU in the system. One only needs
>> + * to take when registering an LRU, or when duplicating the list of lrus.
> 
> That isn't very grammatical.
> 
>> + * Transversing an LRU can and should be done outside the lock
>> + */
>> +static DEFINE_MUTEX(all_memcg_lrus_mutex);
>> +static LIST_HEAD(all_memcg_lrus);
>> +
>> +static void list_lru_init_one(struct list_lru_node *lru)
>>  {
>> +	spin_lock_init(&lru->lock);
>> +	INIT_LIST_HEAD(&lru->list);
>> +	lru->nr_items = 0;
>> +}
>> +
>> +struct list_lru_array *lru_alloc_array(void)
>> +{
>> +	struct list_lru_array *lru_array;
>>  	int i;
>>  
>> -	nodes_clear(lru->active_nodes);
>> -	for (i = 0; i < MAX_NUMNODES; i++) {
>> -		spin_lock_init(&lru->node[i].lock);
>> -		INIT_LIST_HEAD(&lru->node[i].list);
>> -		lru->node[i].nr_items = 0;
>> +	lru_array = kzalloc(nr_node_ids * sizeof(struct list_lru_node),
>> +				GFP_KERNEL);
> 
> Could use kcalloc() here.
> 
>> +	if (!lru_array)
>> +		return NULL;
>> +
>> +	for (i = 0; i < nr_node_ids; i++)
>> +		list_lru_init_one(&lru_array->node[i]);
>> +
>> +	return lru_array;
>> +}
>> +
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
>> +
>> +int memcg_update_all_lrus(unsigned long num)
>> +{
>> +	int ret = 0;
>> +	struct list_lru *lru;
>> +
>> +	mutex_lock(&all_memcg_lrus_mutex);
>> +	list_for_each_entry(lru, &all_memcg_lrus, lrus) {
>> +		ret = memcg_kmem_update_lru_size(lru, num, false);
>> +		if (ret)
>> +			goto out;
>> +	}
>> +out:
>> +	mutex_unlock(&all_memcg_lrus_mutex);
>> +	return ret;
>> +}
>> +
>> +void list_lru_destroy(struct list_lru *lru)
> 
> This is a memcg-specific function (which lives in lib/list_lru.c!) and
> hence should be called, say, memcg_list_lru_destroy().
> 
>> +{
>> +	mutex_lock(&all_memcg_lrus_mutex);
>> +	list_del(&lru->lrus);
>> +	mutex_unlock(&all_memcg_lrus_mutex);
>> +}
>> +
>> +void memcg_destroy_all_lrus(struct mem_cgroup *memcg)
>> +{
>> +	struct list_lru *lru;
>> +	mutex_lock(&all_memcg_lrus_mutex);
>> +	list_for_each_entry(lru, &all_memcg_lrus, lrus) {
>> +		kfree(lru->memcg_lrus[memcg_cache_id(memcg)]);
>> +		lru->memcg_lrus[memcg_cache_id(memcg)] = NULL;
> 
> Some common-subexpression-elimination-by-hand would probably improve
> the output code here.
> 
>> +		/* everybody must beaware that this memcg is no longer valid */
> 
> "be aware"
> 
>> +		wmb();
> 
> The code implies that other code paths can come in here and start
> playing with the pointer without taking all_memcg_lrus_mutex?  If so,
> where, how why, etc?
> 
> I'd be more confortable if the sequence was something like
> 
> 	lru->memcg_lrus[memcg_cache_id(memcg)] = NULL;
> 	wmb();
> 	kfree(lru->memcg_lrus[memcg_cache_id(memcg)]);
> 
> but that still has holes and is still scary.
> 
> 
> What's going on here?
> 
>>  	}
>> +	mutex_unlock(&all_memcg_lrus_mutex);
>> +}
>> +#endif
>> +
>> +int __list_lru_init(struct list_lru *lru, bool memcg_enabled)
>> +{
>> +	int i;
>> +
>> +	nodes_clear(lru->active_nodes);
>> +	for (i = 0; i < MAX_NUMNODES; i++)
>> +		list_lru_init_one(&lru->node[i]);
>> +
>> +	if (memcg_enabled)
>> +		return memcg_init_lru(lru);
> 
> OK, this is weird.  list_lru.c calls into a memcg initialisation
> function!  That memcg initialisation function then calls into
> list_lru.c stuff, as expected.
> 
> Seems screwed up.  What's going on here?
> 

I documented this in the memcg side.

/*
 * We need to call back and forth from memcg to LRU because of the lock
 * ordering.  This complicates the flow a little bit, but since the
memcg mutex
 * is held through the whole duration of memcg creation, we need to hold it
 * before we hold the LRU-side mutex in the case of a new list creation as
 * well.
 */

>>  	return 0;
>>  }
>> -EXPORT_SYMBOL_GPL(list_lru_init);
>> +EXPORT_SYMBOL_GPL(__list_lru_init);
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 27af2d1..5d31b4a 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -3163,16 +3163,30 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
>>  	memcg_kmem_set_activated(memcg);
>>  
>>  	ret = memcg_update_all_caches(num+1);
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
> 
> What's the locking here, to prevent concurrent array-resizers?
> 

the hammer-like set limit mutex is protecting all of this.

>> +	ret = memcg_update_all_lrus(num + 1);
>> +	if (ret)
>> +		goto out;
>>  
>>  	memcg->kmemcg_id = num;
>> +
>> +	memcg_update_array_size(num + 1);
>> +
>>  	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
>>  	mutex_init(&memcg->slab_caches_mutex);
>> +
>>  	return 0;
>> +out:
>> +	ida_simple_remove(&kmem_limited_groups, num);
>> +	memcg_kmem_clear_activated(memcg);
>> +	return ret;
>>  }
>>  
>>  static size_t memcg_caches_array_size(int num_groups)
>> @@ -3254,6 +3268,129 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
>>  	return 0;
>>  }
>>  
>> +/*
>> + * memcg_kmem_update_lru_size - fill in kmemcg info into a list_lru
>> + *
>> + * @lru: the lru we are operating with
>> + * @num_groups: how many kmem-limited cgroups we have
>> + * @new_lru: true if this is a new_lru being created, false if this
>> + * was triggered from the memcg side
>> + *
>> + * Returns 0 on success, and an error code otherwise.
>> + *
>> + * This function can be called either when a new kmem-limited memcg appears,
>> + * or when a new list_lru is created. The work is roughly the same in two cases,
> 
> "both cases"
> 
>> + * but in the later we never have to expand the array size.
> 
> "latter"
> 
>> + *
>> + * This is always protected by the all_lrus_mutex from the list_lru side.  But
>> + * a race can still exists if a new memcg becomes kmem limited at the same time
> 
> "exist"
> 
>> + * that we are registering a new memcg. Creation is protected by the
>> + * memcg_mutex, so the creation of a new lru have to be protected by that as
> 
> "has"
> 
>> + * well.
>> + *
>> + * The lock ordering is that the memcg_mutex needs to be acquired before the
>> + * lru-side mutex.
> 
> It's nice to provide the C name of this "lru-side mutex".
> 
>> + */
> 
> This purports to be a kerneldoc comment, but it doesn't start with the
> kerneldoc /** token.  Please review the entire patchset for this
> (common) oddity.
> 
>> +int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
>> +			       bool new_lru)
>> +{
>> +	struct list_lru_array **new_lru_array;
>> +	struct list_lru_array *lru_array;
>> +
>> +	lru_array = lru_alloc_array();
>> +	if (!lru_array)
>> +		return -ENOMEM;
>> +
>> +	/*
>> +	 * When a new LRU is created, we still need to update all data for that
>> +	 * LRU. The procedure for late LRUs and new memcgs are quite similar, we
> 
> "procedures"
> 
>> +	 * only need to make sure we get into the loop even if num_groups <
>> +	 * memcg_limited_groups_array_size.
> 
> This sentence is hard to follow.  Particularly the "even if" part. 
> Rework it?
> 
>> +	 */
>> +	if ((num_groups > memcg_limited_groups_array_size) || new_lru) {
>> +		int i;
>> +		struct list_lru_array **old_array;
>> +		size_t size = memcg_caches_array_size(num_groups);
>> +		int num_memcgs = memcg_limited_groups_array_size;
>> +
>> +		new_lru_array = kzalloc(size * sizeof(void *), GFP_KERNEL);
> 
> Could use kcalloc().
> 
> What are the implications of that GFP_KERNEL?  That we cannot take
> memcg_mutex and "the lru-side mutex" on the direct reclaim -> shrink
> codepaths.  Is that honoured?  Any other potential problems here?
> 

This has nothing to do with the mutex. You cannot register a new LRU,
and you cannot create a new memcg.

Both of those operations are always done - at least so far - in
GFP_KERNEL contexts.

>> +		if (!new_lru_array) {
>> +			kfree(lru_array);
>> +			return -ENOMEM;
>> +		}
>> +
>> +		for (i = 0; lru->memcg_lrus && (i < num_memcgs); i++) {
>> +			if (lru->memcg_lrus && lru->memcg_lrus[i])
>> +				continue;
>> +			new_lru_array[i] =  lru->memcg_lrus[i];
>> +		}
>> +
>> +		old_array = lru->memcg_lrus;
>> +		lru->memcg_lrus = new_lru_array;
>> +		/*
>> +		 * We don't need a barrier here because we are just copying
>> +		 * information over. Anybody operating in memcg_lrus will
> 
> s/in/on/
> 
>> +		 * either follow the new array or the old one and they contain
>> +		 * exactly the same information. The new space in the end is
> 
> s/in/at/
> 
>> +		 * always empty anyway.
>> +		 */
>> +		if (lru->memcg_lrus)
>> +			kfree(old_array);
>> +	}
>> +
>> +	if (lru->memcg_lrus) {
>> +		lru->memcg_lrus[num_groups - 1] = lru_array;
>> +		/*
>> +		 * Here we do need the barrier, because of the state transition
>> +		 * implied by the assignment of the array. All users should be
>> +		 * able to see it
>> +		 */
>> +		wmb();
> 
> Am worried about this lockless concurrency stuff.  Perhaps putting a
> description of the overall design somewhere would be sensible.
> 

I can do that. But in here it is really not a substitute for a lock, as
Tejun has been complaining. We would just like to make sure that the
change is immediately visible.
>> +	}
>> +	return 0;
>> +}
>> +
>> +/*
>> + * This is called with the LRU-mutex being held.
> 
> That's "all_memcg_lrus_mutex", yes?  Not "all_lrus_mutex".  Clear as mud :(
> 
yes.

>> + */
>> +int memcg_new_lru(struct list_lru *lru)
>> +{
>> +	struct mem_cgroup *iter;
>> +
>> +	if (!memcg_kmem_enabled())
>> +		return 0;
> 
> So the caller took all_memcg_lrus_mutex needlessly in this case.  Could
> be optimised.
> 
ok, but this is a registering function, is hardly worth it.


>> +	for_each_mem_cgroup(iter) {
>> +		int ret;
>> +		int memcg_id = memcg_cache_id(iter);
>> +		if (memcg_id < 0)
>> +			continue;
>> +
>> +		ret = memcg_kmem_update_lru_size(lru, memcg_id + 1, true);
>> +		if (ret) {
>> +			mem_cgroup_iter_break(root_mem_cgroup, iter);
>> +			return ret;
>> +		}
>> +	}
>> +	return 0;
>> +}
>> +
>> +/*
>> + * We need to call back and forth from memcg to LRU because of the lock
>> + * ordering.  This complicates the flow a little bit, but since the memcg mutex
> 
> "the memcg mutex" is named... what?
> 
As you have noticed, I have been avoiding using the names of the
mutexes, because they are internal to "the other" file (lru.c in the
case of memcg, memcontrol.c in the case of lru).

It is so easy to get this out of sync, and lead to an even more
confusing "wth is this memcg_mutex that does not exist??", that I
decided to write a generic "memcg side mutex" instead.

I will of course flip it, if you prefer, master.

>> + * is held through the whole duration of memcg creation, we need to hold it
>> + * before we hold the LRU-side mutex in the case of a new list creation as
> 
> "LRU-side mutex" has a name?
> 
Yes, it has.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
