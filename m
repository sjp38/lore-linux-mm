Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f52.google.com (mail-bk0-f52.google.com [209.85.214.52])
	by kanga.kvack.org (Postfix) with ESMTP id EC1D06B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 04:50:40 -0500 (EST)
Received: by mail-bk0-f52.google.com with SMTP id u14so775971bkz.39
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 01:50:40 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id pe1si9597497bkb.305.2013.12.12.01.50.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 01:50:39 -0800 (PST)
Message-ID: <52A986D2.6010606@parallels.com>
Date: Thu, 12 Dec 2013 13:50:10 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v13 11/16] mm: list_lru: add per-memcg lists
References: <cover.1386571280.git.vdavydov@parallels.com> <0ca62dbfbf545edb22b86bd11c50e9017a3dc4db.1386571280.git.vdavydov@parallels.com> <20131210050005.GC31386@dastard> <52A6E77B.3090106@parallels.com> <20131212014023.GG31386@dastard>
In-Reply-To: <20131212014023.GG31386@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 12/12/2013 05:40 AM, Dave Chinner wrote:
>>>> +int list_lru_grow_memcg(struct list_lru *lru, size_t new_array_size)
>>>> +{
>>>> +	int i;
>>>> +	struct list_lru_one **memcg_lrus;
>>>> +
>>>> +	memcg_lrus = kcalloc(new_array_size, sizeof(*memcg_lrus), GFP_KERNEL);
>>>> +	if (!memcg_lrus)
>>>> +		return -ENOMEM;
>>>> +
>>>> +	if (lru->memcg) {
>>>> +		for_each_memcg_cache_index(i) {
>>>> +			if (lru->memcg[i])
>>>> +				memcg_lrus[i] = lru->memcg[i];
>>>> +		}
>>>> +	}
>>> Um, krealloc()?
>> Not exactly. We have to keep the old version until we call sync_rcu.
> Ah, of course. Could you add a big comment explaining this so that
> the next reader doesn't suggest replacing it with krealloc(), too?

Sure.

>>>> +int memcg_list_lru_init(struct list_lru *lru)
>>>> +{
>>>> +	int err = 0;
>>>> +	int i;
>>>> +	struct mem_cgroup *memcg;
>>>> +
>>>> +	lru->memcg = NULL;
>>>> +	lru->memcg_old = NULL;
>>>> +
>>>> +	mutex_lock(&memcg_create_mutex);
>>>> +	if (!memcg_kmem_enabled())
>>>> +		goto out_list_add;
>>>> +
>>>> +	lru->memcg = kcalloc(memcg_limited_groups_array_size,
>>>> +			     sizeof(*lru->memcg), GFP_KERNEL);
>>>> +	if (!lru->memcg) {
>>>> +		err = -ENOMEM;
>>>> +		goto out;
>>>> +	}
>>>> +
>>>> +	for_each_mem_cgroup(memcg) {
>>>> +		int memcg_id;
>>>> +
>>>> +		memcg_id = memcg_cache_id(memcg);
>>>> +		if (memcg_id < 0)
>>>> +			continue;
>>>> +
>>>> +		err = list_lru_memcg_alloc(lru, memcg_id);
>>>> +		if (err) {
>>>> +			mem_cgroup_iter_break(NULL, memcg);
>>>> +			goto out_free_lru_memcg;
>>>> +		}
>>>> +	}
>>>> +out_list_add:
>>>> +	list_add(&lru->list, &all_memcg_lrus);
>>>> +out:
>>>> +	mutex_unlock(&memcg_create_mutex);
>>>> +	return err;
>>>> +
>>>> +out_free_lru_memcg:
>>>> +	for (i = 0; i < memcg_limited_groups_array_size; i++)
>>>> +		list_lru_memcg_free(lru, i);
>>>> +	kfree(lru->memcg);
>>>> +	goto out;
>>>> +}
>>> That will probably scale even worse. Think about what happens when we
>>> try to mount a bunch of filesystems in parallel - they will now
>>> serialise completely on this memcg_create_mutex instantiating memcg
>>> lists inside list_lru_init().
>> Yes, the scalability seems to be the main problem here. I have a couple
>> of thoughts on how it could be improved. Here they go:
>>
>> 1) We can turn memcg_create_mutex to rw-semaphore (or introduce an
>> rw-semaphore, which we would take for modifying list_lru's) and take it
>> for reading in memcg_list_lru_init() and for writing when we create a
>> new memcg (memcg_init_all_lrus()).
>> This would remove the bottleneck from the mount path, but every memcg
>> creation would still iterate over all LRUs under a memcg mutex. So I
>> guess it is not an option, isn't it?
> Right - it's not so much that there is a mutex to protect the init,
> it's how long it's held that will be the issue. I mean, we don't
> need to hold the memcg_create_mutex until we've completely
> initialised the lru structure and are ready to add it to the
> all_memcg_lrus list, right?
>
> i.e. restructing it so that you don't need to hold the mutex until
> you make the LRU list globally visible would solve the problem just
> as well. if we can iterate the memcgs lists without holding a lock,
> then we can init the per-memcg lru lists without holding a lock
> because nobody will access them through the list_lru structure
> because it's not yet been published.
>
> That keeps the locking simple, and we get scalability because we've
> reduced the lock's scope to just a few instructures instead of a
> memcg iteration and a heap of memory allocation....

Unfortunately that's not that easy as it seems to be :-(

Currently I hold the memcg_create_mutex while initializing per-memcg
LRUs in memcg_list_lru_init() in order to be sure that I won't miss a
memcg that is added during initialization.

I mean, let's try to move per-memcg LRUs allocation outside the lock and
only register the LRU there:

memcg_list_lru_init():
    1) allocate lru->memcg array
    2) for_each_kmem_active_memcg(m)
            allocate lru->memcg[m]
    3) lock memcg_create_mutex
       add lru to all_memcg_lrus_list
       unlock memcg_create_mutex

Then if a new kmem-active memcg is added after step 2 and before step 3,
it won't see the new lru, because it has not been registered yet, and
thus won't initialize its list in this lru. As a result, we will end up
with a partially initialized list_lru. Note that this will happen even
if the whole memcg initialization proceeds under the memcg_create_mutex.

Provided we could freeze memcg_limited_groups_array_size, it would be
possible to fix this problem by swapping steps 2 and 3 and making step 2
initialize lru->memcg[m] using cmpxchg() only if it was not initialized.
However we still have to hold the memcg_create_mutex during the whole
kmemcg activation path (memcg_init_all_lrus()).

Let's see if we can get rid of the lock in memcg_init_all_lrus() by
making the all_memcg_lrus RCU-protected so that we could iterate over
all list_lrus w/o holding any locks and turn memcg_init_all_lrus() to
something like this:

memcg_init_all_lrus():
    1) for_each_list_lru_rcu(lru)
           allocate lru->memcg[new_memcg_id]
    2) mark new_memcg as kmem-active

The problem is that if memcg_list_lru_init(new_lru) starts and completes
between steps 1 and 2, we will not initialize
new_lru->memcg[new_memcg_id] neither in memcg_init_all_lrus() nor in
memcg_list_lru_init().

The problem here is that on kmemcg creation (memcg_init_all_lrus()) we
have to iterate over all list_lrus while on list_lru creation
(memcg_list_lru_init()) we have to iterate over all memcgs. Currently I
can't figure out how we can do it w/o holding any mutexes at least while
calling one of these functions, but I'm keep thinking on it.

>
>> 2) We could use cmpxchg() instead of a mutex in list_lru_init_memcg()
>> and memcg_init_all_lrus() to assure a memcg LRU is initialized only
>> once. But again, this would not remove iteration over all LRUs from
>> memcg_init_all_lrus().
>>
>> 3) We can try to initialize per-memcg LRUs lazily only when we actually
>> need them, similar to how we now handle per-memcg kmem caches creation.
>> If list_lru_add() cannot find appropriate LRU, it will schedule a
>> background worker for its initialization.
> I'd prefer not to add complexity to the list_lru_add() path here.
> It's frequently called, so it's a code hot path and so we should
> keep it as simply as possible.
>
>> The benefits of this approach are clear: we do not introduce any
>> bottlenecks, and we lower memory consumption in case different memcgs
>> use different mounts exclusively.
>> However, there is one thing that bothers me. Some objects accounted to a
>> memcg will go into the global LRU, which will postpone actual memcg
>> destruction until global reclaim.
> Yeah, that's messy. best to avoid it by doing the work at list init
> time, IMO.

I also think so, because the benefits of this are rather doubtful:
1) We actually remove bottlenecks from slow paths (memcg creation and fs
mount) executed relatively rare.
2) In contrast to kmem_cache, list_lru_node is a very small structure so
that making per-memcg lists initialized lazily would not save us much
memory.
But currently I guess it would be the easiest way to get rid of the
memcg_create_mutex held in the initialization paths.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
