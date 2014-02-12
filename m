Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF946B0031
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 13:05:52 -0500 (EST)
Received: by mail-la0-f46.google.com with SMTP id b8so7298667lan.19
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 10:05:51 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id l9si14677681lbd.29.2014.02.12.10.05.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Feb 2014 10:05:49 -0800 (PST)
Message-ID: <52FBB7F7.4050005@parallels.com>
Date: Wed, 12 Feb 2014 22:05:43 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v15 00/13] kmemcg shrinkers
References: <cover.1391624021.git.vdavydov@parallels.com> <52FA3E8E.2080601@parallels.com> <20140211201946.GI4407@cmpxchg.org>
In-Reply-To: <20140211201946.GI4407@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: dchinner@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, glommer@gmail.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On 02/12/2014 12:19 AM, Johannes Weiner wrote:
> On Tue, Feb 11, 2014 at 07:15:26PM +0400, Vladimir Davydov wrote:
>> Hi Michal, Johannes, David,
>>
>> Could you please take a look at this if you have time? Without your
>> review, it'll never get committed.
> There is simply no review bandwidth for new features as long as we are
> fixing fundamental bugs in memcg.
>
>> On 02/05/2014 10:39 PM, Vladimir Davydov wrote:
>>> Hi,
>>>
>>> This is the 15th iteration of Glauber Costa's patch-set implementing slab
>>> shrinking on memcg pressure. The main idea is to make the list_lru structure
>>> used by most FS shrinkers per-memcg. When adding or removing an element from a
>>> list_lru, we use the page information to figure out which memcg it belongs to
>>> and relay it to the appropriate list. This allows scanning kmem objects
>>> accounted to different memcgs independently.
>>>
>>> Please note that this patch-set implements slab shrinking only when we hit the
>>> user memory limit so that kmem allocations will still fail if we are below the
>>> user memory limit, but close to the kmem limit. I am going to fix this in a
>>> separate patch-set, but currently it is only worthwhile setting the kmem limit
>>> to be greater than the user mem limit just to enable per-memcg slab accounting
>>> and reclaim.
>>>
>>> The patch-set is based on top of v3.14-rc1-mmots-2014-02-04-16-48 (there are
>>> some vmscan cleanups that I need committed there) and organized as follows:
>>>  - patches 1-4 introduce some minor changes to memcg needed for this set;
>>>  - patches 5-7 prepare fs for per-memcg list_lru;
>>>  - patch 8 implement kmemcg reclaim core;
>>>  - patch 9 make list_lru per-memcg and patch 10 marks sb shrinker memcg-aware;
>>>  - patch 10 is trivial - it issues shrinkers on memcg destruction;
>>>  - patches 12 and 13 introduce shrinking of dead kmem caches to facilitate
>>>    memcg destruction.
> In the context of the ongoing discussions about charge reparenting I
> was curious how you deal with charges becoming unreclaimable after a
> memcg has been offlined.
>
> Patch #11 drops all charged objects at offlining by just invoking
> shrink_slab() in a loop until "only a few" (10) objects are remaining.
> How long is this going to take?  And why is it okay to destroy these
> caches when somebody else might still be using them?

IMHO, on container destruction we have to drop as many objects accounted
to this container as we can, because otherwise any container will be
able to get access to any number of unaccounted objects by fetching them
and then rebooting.

> That still leaves you with the free objects that slab caches retain
> for allocation efficiency, so now you put all dead memcgs in the
> system on a global list, and on a vmpressure event on root_mem_cgroup
> you walk the global list and drain the freelist of all remaining
> caches.
>
> This is a lot of complexity and scalability problems for less than
> desirable behavior.
>
> Please think about how we can properly reparent kmemcg charges during
> memcg teardown.  That would simplify your code immensely and help
> clean up this unholy mess of css pinning.
>
> Slab caches are already collected in the memcg and on destruction
> could be reassigned to the parent.  Kmemcg uncharge from slab freeing
> would have to be updated to use the memcg from the cache, not from the
> individual page, but I don't see why this wouldn't work right now.

I don't think I understand what you mean by reassigning slab caches to
the parent.

If you mean moving all pages (slabs) from the cache of the memcg being
destroyed to the corresponding root cache (or the parent memcg's cache)
and then destroying the memcg's cache, I don't think this is feasible,
because slub free's fast path is lockless, so AFAIU we can't remove a
partial slab from a cache w/o risking to race with kmem_cache_free.

If you mean clearing all pointers from the memcg's cache to the memcg
(changing them to the parent or root memcg), then AFAIU this won't solve
the problem with "dangling" caches - we will still have to shrink them
on vmpressure. So although this would allow us to put the reference to
the memcg from kmem caches on memcg's death, it wouldn't simplify the
code at all, in fact, it would even make it more complicated, because we
would have to handle various corner cases like reparenting vs
list_lru_{add,remove}.

> Charged thread stack pages could be reassigned when the task itself is
> migrated out of a cgroup.

Thread info pages are only a part of the problem. If a process kmalloc's
an object of size >= KMALLOC_MAX_CACHE_SIZE, it will be given a compound
page accounted to kmemcg, and we won't be able to find this page given
the memcg it is accounted to (except for walking the whole page range).
Thus we will have to organize those pages in per-memcg lists, won't we?
Again, even more complexity.

Although I agree with you that it would be nice to reparent kmem on
memcg destruction, currently I don't see a way to implement this w/o
significantly complicating the code, but I keep thinking.

Thanks.

> It would mean that you can't simply use __GFP_KMEMCG and just pin the
> css until you can be bothered to return it.  There must be a way for
> any memcg charge to be reparented on demand.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
