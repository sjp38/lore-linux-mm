Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id DB4BC6B0039
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 04:30:10 -0500 (EST)
Received: by mail-la0-f42.google.com with SMTP id ec20so346087lab.29
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 01:30:10 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 6si1305326laz.140.2013.12.19.01.30.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 01:30:09 -0800 (PST)
Message-ID: <52B2BC97.4010506@parallels.com>
Date: Thu, 19 Dec 2013 13:29:59 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] memcg, slab: cleanup barrier usage when accessing
 memcg_caches
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com> <bd0a7ffc57e4a0b0c3d456c0cf8801e829e14717.1387372122.git.vdavydov@parallels.com> <20131218171411.GD31080@dhcp22.suse.cz> <52B29427.9010909@parallels.com> <20131219091007.GC9331@dhcp22.suse.cz> <52B2B951.5080809@parallels.com> <20131219092137.GG9331@dhcp22.suse.cz>
In-Reply-To: <20131219092137.GG9331@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 12/19/2013 01:21 PM, Michal Hocko wrote:
> On Thu 19-12-13 13:16:01, Vladimir Davydov wrote:
>> On 12/19/2013 01:10 PM, Michal Hocko wrote:
>>> On Thu 19-12-13 10:37:27, Vladimir Davydov wrote:
>>>> On 12/18/2013 09:14 PM, Michal Hocko wrote:
>>>>> On Wed 18-12-13 17:16:54, Vladimir Davydov wrote:
>>>>>> First, in memcg_create_kmem_cache() we should issue the write barrier
>>>>>> after the kmem_cache is initialized, but before storing the pointer to
>>>>>> it in its parent's memcg_params.
>>>>>>
>>>>>> Second, we should always issue the read barrier after
>>>>>> cache_from_memcg_idx() to conform with the write barrier.
>>>>>>
>>>>>> Third, its better to use smp_* versions of barriers, because we don't
>>>>>> need them on UP systems.
>>>>> Please be (much) more verbose on Why. Barriers are tricky and should be
>>>>> documented accordingly. So if you say that we should issue a barrier
>>>>> always be specific why we should do it.
>>>> In short, we have kmem_cache::memcg_params::memcg_caches is an array of
>>>> pointers to per-memcg caches. We access it lock-free so we should use
>>>> memory barriers during initialization. Obviously we should place a write
>>>> barrier just before we set the pointer in order to make sure nobody will
>>>> see a partially initialized structure. Besides there must be a read
>>>> barrier between reading the pointer and accessing the structure, to
>>>> conform with the write barrier. It's all that similar to rcu_assign and
>>>> rcu_deref. Currently the barrier usage looks rather strange:
>>>>
>>>> memcg_create_kmem_cache:
>>>>     initialize kmem
>>>>     set the pointer in memcg_caches
>>>>     wmb() // ???
>>>>
>>>> __memcg_kmem_get_cache:
>>>>     <...>
>>>>     read_barrier_depends() // ???
>>>>     cachep = root_cache->memcg_params->memcg_caches[memcg_id]
>>>>     <...>
>>> Why do we need explicit memory barriers when we can use RCU?
>>> __memcg_kmem_get_cache already dereferences within rcu_read_lock.
>> Because it's not RCU, IMO. RCU implies freeing the old version after a
>> grace period, while kmem_caches are freed immediately. We simply want to
>> be sure the kmem_cache is fully initialized. And we do not require
>> calling this in an RCU critical section.
> And you can use rcu_dereference and rcu_assign for that as well.

rcu_dereference() will complain if called outside an RCU critical
section, while cache_from_memcg_idx() is called w/o RCU protection from
some places.

> It hides all the juicy details about memory barriers.

IMO, a memory barrier with a good comment looks better than an
rcu_dereference() without RCU protection :-)

> Besides that nothing prevents us from freeing from rcu callback. Or?

It's an overhead we can live without there. The point is that we can
access a cache only if it is active. I mean no allocation can go from a
cache that has already been destroyed. It would be a bug. So there is no
point in introducing RCU-protection for kmem_caches there. It would only
confuse, IMO.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
