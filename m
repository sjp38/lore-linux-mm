Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 09F7E6B00FA
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 08:15:01 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id y1so4778715lam.9
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 05:15:01 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id w9si13393996laj.230.2014.03.18.05.14.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Mar 2014 05:15:00 -0700 (PDT)
Message-ID: <532838C2.4050303@parallels.com>
Date: Tue, 18 Mar 2014 16:14:58 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND -mm 02/12] memcg: fix race in memcg cache destruction
 path
References: <cover.1394708827.git.vdavydov@parallels.com> <94fc308b9074e45a2aac7a06cf357a33c5d97c9f.1394708827.git.vdavydov@parallels.com> <20140317164203.GC30623@dhcp22.suse.cz> <53280174.1040507@parallels.com> <20140318100147.GC3191@dhcp22.suse.cz>
In-Reply-To: <20140318100147.GC3191@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On 03/18/2014 02:01 PM, Michal Hocko wrote:
> On Tue 18-03-14 12:19:00, Vladimir Davydov wrote:
>> On 03/17/2014 08:42 PM, Michal Hocko wrote:
>>> On Thu 13-03-14 19:06:40, Vladimir Davydov wrote:
>>>> We schedule memcg cache shrink+destruction work (memcg_params::destroy)
>>>> from two places: when we turn memcg offline
>>>> (mem_cgroup_destroy_all_caches) and when the last page of the cache is
>>>> freed (memcg_params::nr_pages reachs zero, see memcg_release_pages,
>>>> mem_cgroup_destroy_cache).
>>> This is just ugly! Why do we mem_cgroup_destroy_all_caches from the
>>> offline code at all? Just calling kmem_cache_shrink and then wait for
>>> the last pages to go away should be sufficient to fix this, no?
>> The problem is kmem_cache_shrink() can take the slab_mutex, and we
>> iterate over memcg caches to be destroyed under the memcg's
>> slab_caches_mutex, which is nested into the slab_mutex (see
>> mem_cgroup_destroy_all_caches()). So we can't call kmem_cache_shrink()
>> there directly due to lockdep. That's what all that trickery with using
>> the same work for both cache shrinking and destruction is for. I agree
>> this is ugly and somewhat difficult to understand. Let me share my
>> thoughts on this problem.
> Nothing prevents mem_cgroup_destroy_all_caches to call kmem_cache_shrink
> from the workqueue context, no? And then we can move all caches which
> still have some pages to the parent memcg

Currently, when reparenting memcg caches (see patch 11), I move memcg
caches from the memcg_slab_caches list of the memcg being offlined to
its parent under both memcg's slab_caches_mutexes held - this makes
synchronization with kmem_cache_destroy easier. However, if we could
take the reference to the root cache there protecting it from being
destroyed, I guess we could safely release memcg::slab_caches_mutex
between removal the caches from the old list (of the memcg being
destroyed) and inserting them to the new list (parent). That said, you
must be right. It seems that introducing full-fledged refcounting for
kmem_caches would simplify the code a lot.

> + update back-pointers from respective page_cgroups.

As Johannes mentioned, we don't need page_cgroups for kmem pages since
we can track kmem objects through page->slab_cache, and this set gets
rid of them (patch 7).

>> First, why do we need to call kmem_cache_shrink() there at all? AFAIU,
>> this is because most of memcg caches must be empty by the time the memcg
>> is destroyed, but since there are some pages left on the caches for
>> performance reasons, and those pages hold cache references
>> (kmem_cache::memcg_params::nr_pages) preventing it from being destroyed,
>> we try to shrink them to get rid of empty caches. If shrink fails (i.e.
>> the memcg cache is not empty) the cache will be pending for good in the
>> current implementation (until someone calls the shrink manually at
>> least). Glauber intended to fix the issue with pending caches by reaping
>> them on vmpressure, but he didn't have enough time to complete this,
>> unfortunately.
>>
>> But why do we get cache references per slab?
> I guess this is natural from the charging point of view. It is also less
> intrusive because this is a slow path.
>
>> I mean why do we inc the
>> cache refcounter (kmem_cache::memcg_params::nr_pages currently) when
>> allocating a slab, not an individual object? If we took the reference to
>> the cache per individual object, we would not have to call
>> kmem_cache_shrink() on memcg offline - if the cache is empty it will be
>> destroyed immediately then, because its refcounter reaches 0, otherwise
>> we could leave it hanging around for a while and only try to shrink it
>> on vmpressure when we really need free mem. That would make the
>> destroy_work straightforward - it would simply call kmem_cache_destroy()
>> and that's it.
>>
>> I guess I foresee the answer to the question I've just raised - using a
>> per cache refcounter and taking it on each alloc/free would hurt
>> scalability too much. However, we could use percpu refcounter to
>> overcome this, couldn't we?
> I am afraid this would still be too invasive for the fast path. That
> would be a question for slab guys though.

Yeah, that's bothering me too. I guess I'll try to send it as RFC in a
separate patch to get more feedback, because this would be a great
simplification, IMO.

>> There is one more argument for taking the cache refcount on a per-object
>> (not per-slab) basis. There seems to be a race in kmem allocation path.
>> The point is there is a time window between we get the cache to allocate
>> from (memcg_kmem_get_cache()) and the actual allocating from the cache
>> (see slab_alloc_node()). Actually, nothing prevents the cache from going
>> away in this time window
> By "the cache" you mean the memcg variant or the global one?

memcg one

>> - the task can change its cgroup and the former cgroup can be taken
>> offline resulting in the cache destruction.
> With a proper synchronization this shouldn't be a big deal I suppose.
> kmem_cache_create_memcg should check that the memcg is still alive. We
> mark caches dead and we would need something like that per-memcg as well
> during css_offline (after all memcg_slab_caches were shrunk). The create
> worker would then back off and fail when trying to register the cache.

Let's consider the following scenario:

1) A process inside a memcg calls kmem_cache_alloc(). Suppose the
memcg's cache already exists and is empty.
2) kmem_cache_alloc() calls memcg_kmem_get_cache(), which returns the
pointer to the memcg cache to allocate from.
3) At this time, the process is moved out of the memcg, and the memcg is
destroyed along with its empty caches.
4) The process then proceeds to an object allocation from the cache it
was given by memcg_kmem_get_cache() on step 2, but the cache was freed.

Does it make sense?

>> This is very unlikely, but still possible.
>> A similar problem with freeing
>> objects - currently we might continue using a cache after we actually
>> freed the last object and dropped the reference - look at
>> kmem_freepages(), there we dereference the cache pointer after calling
>> memcg_release_pages(), which drops the cache reference.
> This sounds like an ordering issue. memcg_release_pages should be called
> as the last. I do not see why the ordering was done this way.

Fixing ordering only in this function wouldn't solve the problem
completely. Look at slab's cache_free_alien() - it unlocks
cachep->node[nodeid].list_lock after calling free_block() that might
schedule the cache destruction. I mean the problem is that
kmem_freepages and __free_slab(), which issue memcg_release_pages(), are
not necessarily the last functions using the cache - the code issuing
them may still want to touch the cache.

>> The latter is
>> more-or-less easy to fix though by ensuring we always drop the reference
>> after we stopped using the cache, but this would imply heavy intrusion
>> into slab internals AFAIU, which is bad. OTOH if we took the cache
>> reference per allocated object, these problems would be resolved
>> automatically and clearly.
>>
>> I haven't included that in this set, because I tried not to blow it too
>> much, I just wanted to introduce cache reparenting, in the meanwhile
>> fixing only those issues that had become really painful. Not sure if it
>> was the right decision though :-/
> I would really prefer to go with simplifications first and build
> reparenting on top of that.

Agree, but first we need to come to agreement about what simplifications
we should go with.

IMO, the most confusing part of kmemcg is how memcg cache
creation/destruction is handled. I mean all those synchronization tricks
between kmem_cache_destroy, kmem_cache_create of root cache, memcg
cache, etc. I think we would benefit if we introduced fully-fledged
refcounting for kmem caches. This would also solve the problems first
three patches of this set address.

Next, as I've already mentioned we can handle kmem w/o using
page_cgroups provided we don't charge kmalloc large allocations. See
patches 7-10 - they remove ~270 lines of code while adding only ~70.
When looking at those patches now, I start to think it would be better
if I sent them first in a separate set.

Currently, nothing else springs to my mind. I guess I need to think a
bit more...

Thanks.

>> Anyway, I would appreciate if you could share your thoughts about that.
>>
>>> Whether the current code is good (no it's not) is another question. But
>>> this should be fixed also in the stable trees (is the bug there since
>>> the very beginning?) so the fix should be as simple as possible IMO.
>>> So if there is a simpler solution I would prefer it. But I am drowning
>>> in the kmem trickiness spread out all over the place so I might be
>>> missing something very easily.
>> Frankly, I'm not bothering about stable trees by now, because I don't
>> think anybody is using kmemcg since w/o fs cache shrinking it looks
>> pretty useless. May be, I'm wrong :-/
> OK, it is all opt-in so there shouldn't be any harm for those who do not
> use the feature which makes it less urgent but I can still imagine that
> somebody might want to use the feature even on older kernels.
>
> You are right that the feature is really dubious without proper
> shrinking. Which was btw. my objection at the time when we have
> discussed that at LSF (before it got merged).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
