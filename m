Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF3046B04D8
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:39:51 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r63-v6so2560002pfl.12
        for <linux-mm@kvack.org>; Thu, 17 May 2018 04:39:51 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50105.outbound.protection.outlook.com. [40.107.5.105])
        by mx.google.com with ESMTPS id s21-v6si4711819plr.143.2018.05.17.04.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 17 May 2018 04:39:50 -0700 (PDT)
Subject: Re: [PATCH v5 11/13] mm: Iterate only over charged shrinkers during
 memcg shrink_slab()
References: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
 <152594603565.22949.12428911301395699065.stgit@localhost.localdomain>
 <20180515054445.nhe4zigtelkois4p@esperanza>
 <fa35589b-0696-e029-4440-d91dc4c9ab2d@virtuozzo.com>
 <20180517043340.wmm43ynodqa3zefq@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <6ee5447f-d689-8930-3459-cfd343915aa4@virtuozzo.com>
Date: Thu, 17 May 2018 14:39:38 +0300
MIME-Version: 1.0
In-Reply-To: <20180517043340.wmm43ynodqa3zefq@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On 17.05.2018 07:33, Vladimir Davydov wrote:
> On Tue, May 15, 2018 at 01:12:20PM +0300, Kirill Tkhai wrote:
>>>> +#define root_mem_cgroup NULL
>>>
>>> Let's instead export mem_cgroup_is_root(). In case if MEMCG is disabled
>>> it will always return false.
>>
>> export == move to header file
> 
> That and adding a stub function in case !MEMCG.
> 
>>>> +static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
>>>> +			struct mem_cgroup *memcg, int priority)
>>>> +{
>>>> +	struct memcg_shrinker_map *map;
>>>> +	unsigned long freed = 0;
>>>> +	int ret, i;
>>>> +
>>>> +	if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
>>>> +		return 0;
>>>> +
>>>> +	if (!down_read_trylock(&shrinker_rwsem))
>>>> +		return 0;
>>>> +
>>>> +	/*
>>>> +	 * 1)Caller passes only alive memcg, so map can't be NULL.
>>>> +	 * 2)shrinker_rwsem protects from maps expanding.
>>>
>>>             ^^
>>> Nit: space missing here :-)
>>
>> I don't understand what you mean here. Please, clarify...
> 
> This is just a trivial remark regarding comment formatting. They usually
> put a space between the number and the first word in the sentence, i.e.
> between '1)' and 'Caller' in your case.
> 
>>
>>>> +	 */
>>>> +	map = rcu_dereference_protected(MEMCG_SHRINKER_MAP(memcg, nid), true);
>>>> +	BUG_ON(!map);
>>>> +
>>>> +	for_each_set_bit(i, map->map, memcg_shrinker_nr_max) {
>>>> +		struct shrink_control sc = {
>>>> +			.gfp_mask = gfp_mask,
>>>> +			.nid = nid,
>>>> +			.memcg = memcg,
>>>> +		};
>>>> +		struct shrinker *shrinker;
>>>> +
>>>> +		shrinker = idr_find(&shrinker_idr, i);
>>>> +		if (!shrinker) {
>>>> +			clear_bit(i, map->map);
>>>> +			continue;
>>>> +		}
>>>> +		if (list_empty(&shrinker->list))
>>>> +			continue;
>>>
>>> I don't like using shrinker->list as an indicator that the shrinker has
>>> been initialized. IMO if you do need such a check, you should split
>>> shrinker_idr registration in two steps - allocate a slot in 'prealloc'
>>> and set the pointer in 'register'. However, can we really encounter an
>>> unregistered shrinker here? AFAIU a bit can be set in the shrinker map
>>> only after the corresponding shrinker has been initialized, no?
>>
>> 1)No, it's not so. Here is a race:
>> cpu#0                        cpu#1                                   cpu#2
>> prealloc_shrinker()
>>                              prealloc_shrinker()
>>                                memcg_expand_shrinker_maps()
>>                                  memcg_expand_one_shrinker_map()
>>                                    memset(&new->map, 0xff);          
>>                                                                      do_shrink_slab() (on uninitialized LRUs)
>> init LRUs
>> register_shrinker_prepared()
>>
>> So, the check is needed.
> 
> OK, I see.
> 
>>
>> 2)Assigning NULL pointer can't be used here, since NULL pointer is already used
>> to clear unregistered shrinkers from the map. See the check right after idr_find().
> 
> But it won't break anything if we clear bit for prealloc-ed, but not yet
> registered shrinkers, will it?

This imposes restrictions on the code, which register a shrinker, because
there is no a rule or a guarantee in kernel, that list LRU can't be populated
before shrinker is completely registered. The separate subsystems of kernel
have to be modular, while clearing the bit will break the modularity and
imposes the restrictions on the users of this interface.

Also, if go another way and we delegete this to users, and they follow this rule,
this may require non-trivial locking scheme for them. So, let's keep the modularity.

Also, we can't move memset(0xff) to register_shrinker_preallocated(), since
then we would have to keep in memory the state of the fact the maps were expanded
in prealloc_shrinker().

>>
>> list_empty() is used since it's the already existing indicator, which does not
>> require additional member in struct shrinker.
> 
> It just looks rather counter-intuitive to me to use shrinker->list to
> differentiate between registered and unregistered shrinkers. May be, I'm
> wrong. If you are sure that this is OK, I'm fine with it, but then
> please add a comment here explaining what this check is needed for.

We may introduce new flag in shrinker::flags to indicate this fact instead,
but for me it seems the same.

Thanks,
Kirill
