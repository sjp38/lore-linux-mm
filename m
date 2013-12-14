Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id A736A6B0031
	for <linux-mm@kvack.org>; Sat, 14 Dec 2013 15:03:59 -0500 (EST)
Received: by mail-la0-f51.google.com with SMTP id ec20so2117216lab.10
        for <linux-mm@kvack.org>; Sat, 14 Dec 2013 12:03:59 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id d9si3036609lad.30.2013.12.14.12.03.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Dec 2013 12:03:58 -0800 (PST)
Message-ID: <52ACB99F.7080102@parallels.com>
Date: Sun, 15 Dec 2013 00:03:43 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v13 11/16] mm: list_lru: add per-memcg lists
References: <cover.1386571280.git.vdavydov@parallels.com> <0ca62dbfbf545edb22b86bd11c50e9017a3dc4db.1386571280.git.vdavydov@parallels.com> <20131210050005.GC31386@dastard> <52A6E77B.3090106@parallels.com> <20131212014023.GG31386@dastard> <52A986D2.6010606@parallels.com> <52AA1B68.80302@parallels.com>
In-Reply-To: <52AA1B68.80302@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: glommer@gmail.com, Balbir Singh <bsingharora@gmail.com>, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, glommer@openvz.org, mhocko@suse.cz, linux-mm@kvack.org, devel@openvz.org, Al Viro <viro@zeniv.linux.org.uk>, dchinner@redhat.com, cgroups@vger.kernel.org, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 12/13/2013 12:24 AM, Vladimir Davydov wrote:
> On 12/12/2013 01:50 PM, Vladimir Davydov wrote:
>>>>>> +int memcg_list_lru_init(struct list_lru *lru)
>>>>>> +{
>>>>>> +	int err = 0;
>>>>>> +	int i;
>>>>>> +	struct mem_cgroup *memcg;
>>>>>> +
>>>>>> +	lru->memcg = NULL;
>>>>>> +	lru->memcg_old = NULL;
>>>>>> +
>>>>>> +	mutex_lock(&memcg_create_mutex);
>>>>>> +	if (!memcg_kmem_enabled())
>>>>>> +		goto out_list_add;
>>>>>> +
>>>>>> +	lru->memcg = kcalloc(memcg_limited_groups_array_size,
>>>>>> +			     sizeof(*lru->memcg), GFP_KERNEL);
>>>>>> +	if (!lru->memcg) {
>>>>>> +		err = -ENOMEM;
>>>>>> +		goto out;
>>>>>> +	}
>>>>>> +
>>>>>> +	for_each_mem_cgroup(memcg) {
>>>>>> +		int memcg_id;
>>>>>> +
>>>>>> +		memcg_id = memcg_cache_id(memcg);
>>>>>> +		if (memcg_id < 0)
>>>>>> +			continue;
>>>>>> +
>>>>>> +		err = list_lru_memcg_alloc(lru, memcg_id);
>>>>>> +		if (err) {
>>>>>> +			mem_cgroup_iter_break(NULL, memcg);
>>>>>> +			goto out_free_lru_memcg;
>>>>>> +		}
>>>>>> +	}
>>>>>> +out_list_add:
>>>>>> +	list_add(&lru->list, &all_memcg_lrus);
>>>>>> +out:
>>>>>> +	mutex_unlock(&memcg_create_mutex);
>>>>>> +	return err;
>>>>>> +
>>>>>> +out_free_lru_memcg:
>>>>>> +	for (i = 0; i < memcg_limited_groups_array_size; i++)
>>>>>> +		list_lru_memcg_free(lru, i);
>>>>>> +	kfree(lru->memcg);
>>>>>> +	goto out;
>>>>>> +}
>>>>> That will probably scale even worse. Think about what happens when we
>>>>> try to mount a bunch of filesystems in parallel - they will now
>>>>> serialise completely on this memcg_create_mutex instantiating memcg
>>>>> lists inside list_lru_init().
>>>> Yes, the scalability seems to be the main problem here. I have a couple
>>>> of thoughts on how it could be improved. Here they go:
>>>>
>>>> 1) We can turn memcg_create_mutex to rw-semaphore (or introduce an
>>>> rw-semaphore, which we would take for modifying list_lru's) and take it
>>>> for reading in memcg_list_lru_init() and for writing when we create a
>>>> new memcg (memcg_init_all_lrus()).
>>>> This would remove the bottleneck from the mount path, but every memcg
>>>> creation would still iterate over all LRUs under a memcg mutex. So I
>>>> guess it is not an option, isn't it?
>>> Right - it's not so much that there is a mutex to protect the init,
>>> it's how long it's held that will be the issue. I mean, we don't
>>> need to hold the memcg_create_mutex until we've completely
>>> initialised the lru structure and are ready to add it to the
>>> all_memcg_lrus list, right?
>>>
>>> i.e. restructing it so that you don't need to hold the mutex until
>>> you make the LRU list globally visible would solve the problem just
>>> as well. if we can iterate the memcgs lists without holding a lock,
>>> then we can init the per-memcg lru lists without holding a lock
>>> because nobody will access them through the list_lru structure
>>> because it's not yet been published.
>>>
>>> That keeps the locking simple, and we get scalability because we've
>>> reduced the lock's scope to just a few instructures instead of a
>>> memcg iteration and a heap of memory allocation....
>> Unfortunately that's not that easy as it seems to be :-(
>>
>> Currently I hold the memcg_create_mutex while initializing per-memcg
>> LRUs in memcg_list_lru_init() in order to be sure that I won't miss a
>> memcg that is added during initialization.
>>
>> I mean, let's try to move per-memcg LRUs allocation outside the lock and
>> only register the LRU there:
>>
>> memcg_list_lru_init():
>>     1) allocate lru->memcg array
>>     2) for_each_kmem_active_memcg(m)
>>             allocate lru->memcg[m]
>>     3) lock memcg_create_mutex
>>        add lru to all_memcg_lrus_list
>>        unlock memcg_create_mutex
>>
>> Then if a new kmem-active memcg is added after step 2 and before step 3,
>> it won't see the new lru, because it has not been registered yet, and
>> thus won't initialize its list in this lru. As a result, we will end up
>> with a partially initialized list_lru. Note that this will happen even
>> if the whole memcg initialization proceeds under the memcg_create_mutex.
>>
>> Provided we could freeze memcg_limited_groups_array_size, it would be
>> possible to fix this problem by swapping steps 2 and 3 and making step 2
>> initialize lru->memcg[m] using cmpxchg() only if it was not initialized.
>> However we still have to hold the memcg_create_mutex during the whole
>> kmemcg activation path (memcg_init_all_lrus()).
>>
>> Let's see if we can get rid of the lock in memcg_init_all_lrus() by
>> making the all_memcg_lrus RCU-protected so that we could iterate over
>> all list_lrus w/o holding any locks and turn memcg_init_all_lrus() to
>> something like this:
>>
>> memcg_init_all_lrus():
>>     1) for_each_list_lru_rcu(lru)
>>            allocate lru->memcg[new_memcg_id]
>>     2) mark new_memcg as kmem-active
>>
>> The problem is that if memcg_list_lru_init(new_lru) starts and completes
>> between steps 1 and 2, we will not initialize
>> new_lru->memcg[new_memcg_id] neither in memcg_init_all_lrus() nor in
>> memcg_list_lru_init().
>>
>> The problem here is that on kmemcg creation (memcg_init_all_lrus()) we
>> have to iterate over all list_lrus while on list_lru creation
>> (memcg_list_lru_init()) we have to iterate over all memcgs. Currently I
>> can't figure out how we can do it w/o holding any mutexes at least while
>> calling one of these functions, but I'm keep thinking on it.
>>
> Seems I got it. We could add a memcg state bit, say "activating",
> meaning that a memcg is going to become kmem-active, but it is not yet,
> so it should not be accounted to; keep all list_lrus in a rcu-protected
> list; and implement memcg_init_all_lrus() and memcg_list_lru_init() as
> follows:
>
> memcg_init_all_lrus():
>     set activating
>     for_each_list_lru_rcu(lru)
>         cmpxchg(&lru->memcg[new_memcg_id], NULL, new list_lru_node);
>     set active
>
> memcg_list_lru_init():
>     add the new_lru to the all_memcg_lrus list
>     for_each_memcg(memcg):
>         if memcg is activating or active:
>             cmpxchg(&new_lru->memcg[memcg_id], NULL, new list_lru_node)

While trying to implement this I understood I was mistaken :-(
The point is that we can't iterate the RCU-protected list of list_lrus
allocating per-memcg lists in the meantime.

So, the situation we have looks as follows. On kmemcg creation we need
to iterate over all list_lrus and allocate a list_lru_node for the new
kmemsg. If we keep all list_lrus in a linked list we could use
RCU-iteration, but still we could not do something like this:

rcu_read_lock()
list_for_each_entry_rcu(lru)
    lru->memcg[id] = kmalloc()
rcu_read_lock()

because it is incorrect to sleep in an RCU critical section.

Since the list_lru structure cannot be made ref-counted (it is usually
built in other structure), we cannot leave the RCU critical section for
kmalloc() in the middle of the list_for_each loop.

Of course, we could preallocate all per-memcg LRUs before entering the
RCU critical section, i.e.

rcu_read_lock()
list_for_each_entry_rcu(lru) {
    if (have to allocate lru->memcg[id])
        nr_to_alloc++;
}
rcu_read_unlock()
// allocate nr_to_alloc list_lru_node objects
rcu_read_lock()
list_for_each_entry_rcu(lru) {
    if (had to allocate lru->memcg[id])
        init lru->memcg[id] with preallocated list_lru_node
}
rcu_read_unlock()

but for doing this we would need to allocate a temporary buffer for
holding list_lru_node references, which can be very big - not good.
Plus, the code would be complicated.

That said we have to iterate over the list of list_lrus under a mutex -
at least this is my current understanding :-(

So, what I am going to do for the next iteration of this patchset is to
introduce an rw semaphore and take it for reading on list_lru creation
and for writing on kmemcg creation. This will make concurrent mounts
possible, but mounting an fs will serialize with kmemcg creation on the
semaphore. I don't think it is that bad though, because creation of
kmemcgs is rather a rare event (isn't it?)

If anybody has a better idea, please share.

Thanks.

>
> At first glance, it looks correct, because:
>
> If we skip an lru while iterating over all_memcg_lrus in
> memcg_init_all_lrus(), it means it was created after the "activating"
> bit had been set and thus the per-memcg lru will be initialized in
> memcg_list_lru_init(). If we skip a memcg in memcg_list_lru_init(), this
> memg will "see" this lru while iterating over the all_memcg_lrus list,
> because the lru must have been created before the "activating" bit set.
>
> Although it is to be elaborated, because I haven't examined the
> destruction paths yet, and this doesn't take into account the fact that
> memcg_limited_groups_array_size is not a constant (I guess I'll have to
> introduce an rw semaphore for it, but it'll be OK, because its updates
> are very-very rare), I guess I am on the right way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
