Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 78CAE6B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 01:57:47 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id c11so9609703lbj.23
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 22:57:46 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ww4si20936608lbb.12.2013.12.04.22.57.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 22:57:46 -0800 (PST)
Message-ID: <52A023BD.9000706@parallels.com>
Date: Thu, 5 Dec 2013 10:57:01 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v12 09/18] vmscan: shrink slab on memcg pressure
References: <cover.1385974612.git.vdavydov@parallels.com> <be01fd9afeedb7d5c7979347f4d6ddaf67c9082d.1385974612.git.vdavydov@parallels.com> <20131203104849.GD8803@dastard> <529DCB7D.10205@parallels.com> <20131204045147.GN10988@dastard> <529ECC44.8040508@parallels.com> <20131205050118.GM8803@dastard>
In-Reply-To: <20131205050118.GM8803@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 12/05/2013 09:01 AM, Dave Chinner wrote:
> On Wed, Dec 04, 2013 at 10:31:32AM +0400, Vladimir Davydov wrote:
>> On 12/04/2013 08:51 AM, Dave Chinner wrote:
>>> On Tue, Dec 03, 2013 at 04:15:57PM +0400, Vladimir Davydov wrote:
>>>> On 12/03/2013 02:48 PM, Dave Chinner wrote:
>>>>>> @@ -236,11 +236,17 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
>>>>>>  		return 0;
>>>>>>  
>>>>>>  	/*
>>>>>> -	 * copy the current shrinker scan count into a local variable
>>>>>> -	 * and zero it so that other concurrent shrinker invocations
>>>>>> -	 * don't also do this scanning work.
>>>>>> +	 * Do not touch global counter of deferred objects on memcg pressure to
>>>>>> +	 * avoid isolation issues. Ideally the counter should be per-memcg.
>>>>>>  	 */
>>>>>> -	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
>>>>>> +	if (!shrinkctl->target_mem_cgroup) {
>>>>>> +		/*
>>>>>> +		 * copy the current shrinker scan count into a local variable
>>>>>> +		 * and zero it so that other concurrent shrinker invocations
>>>>>> +		 * don't also do this scanning work.
>>>>>> +		 */
>>>>>> +		nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
>>>>>> +	}
>>>>> That's ugly. Effectively it means that memcg reclaim is going to be
>>>>> completely ineffective when large numbers of allocations and hence
>>>>> reclaim attempts are done under GFP_NOFS context.
>>>>>
>>>>> The only thing that keeps filesystem caches in balance when there is
>>>>> lots of filesystem work going on (i.e. lots of GFP_NOFS allocations)
>>>>> is the deferal of reclaim work to a context that can do something
>>>>> about it.
>>>> Imagine the situation: a memcg issues a GFP_NOFS allocation and goes to
>>>> shrink_slab() where it defers them to the global counter; then another
>>>> memcg issues a GFP_KERNEL allocation, also goes to shrink_slab() where
>>>> it sees a huge number of deferred objects and starts shrinking them,
>>>> which is not good IMHO.
>>> That's exactly what the deferred mechanism is for - we know we have
>>> to do the work, but we can't do it right now so let someone else do
>>> it who can.
>>>
>>> In most cases, deferral is handled by kswapd, because when a
>>> filesystem workload is causing memory pressure then most allocations
>>> are done in GFP_NOFS conditions. Hence the only memory reclaim that
>>> can make progress here is kswapd.
>>>
>>> Right now, you aren't deferring any of this memory pressure to some
>>> other agent, so it just does not get done. That's a massive problem
>>> - it's a design flaw - and instead I see lots of crazy hacks being
>>> added to do stuff that should simply be deferred to kswapd like is
>>> done for global memory pressure.
>>>
>>> Hell, kswapd shoul dbe allowed to walk memcg LRU lists and trim
>>> them, just like it does for the global lists. We only need a single
>>> "deferred work" counter per node for that - just let kswapd
>>> proportion the deferred work over the per-node LRU and the
>>> memcgs....
>> Seems I misunderstand :-(
>>
>> Let me try. You mean we have the only nr_deferred counter per-node, and
>> kswapd scans
>>
>> nr_deferred*memcg_kmem_size/total_kmem_size
>>
>> objects in each memcg, right?
>>
>> Then if there were a lot of objects deferred on memcg (not global)
>> pressure due to a memcg issuing a lot of GFP_NOFS allocations, kswapd
>> will reclaim objects from all, even unlimited, memcgs. This looks like
>> an isolation issue :-/
> Which, when you are running out of memory, is a much less of an
> issue than not being able to make progress reclaiming memory.
>
> Besides, the "isolation" argument runs both ways. e.g. when there
> isn't memory available, it's entirely possible it's because there is
> actually no free memory, not because we've hit a memcg limit. e.g.
> all the memory has been consumed by an unlimited memcg, and we need to
> reclaim from it so this memcg can make progress.
>
> In those situations we need to reclaim from everyone, not
> just the memcg that can't find free memory to allocate....

Agree, on global overcommit we have to reclaim from all. I guess it
would be also nice to balance the reclaim proportionally to memlimit
somehow then.

>> Currently we have a per-node nr_deferred counter for each shrinker. If
>> we add per-memcg reclaim, we have to make it per-memcg per-node, don't we?
> Think about what you just said for a moment. We have how many memcg
> shrinkers?  And we can support how many nodes? And we can support
> how many memcgs? And when we multiply that all together, how much
> memory do we need to track that?

But we could grow nr_deferred dynamically as the number of kmem-active
memcgs grows just like we're going to grow list_lru. Then the overhead
would not be that big, it would be practically 0 if there is no
kmem-active memcgs.

I mean, per memcg nr_deferred wouldn't hinder the global reclaim and
it's not that much of overhead comparing to several per memcg lrus for
each superblock, but it would make the reclaimer fairer on memcg
pressure, wouldn't it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
