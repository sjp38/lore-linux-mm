Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1150B6B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 14:09:21 -0500 (EST)
Received: by mail-lb0-f172.google.com with SMTP id c11so9643765lbj.17
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 11:09:21 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id mq2si9974437lbb.32.2014.02.14.11.09.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Feb 2014 11:09:19 -0800 (PST)
Message-ID: <52FE69DA.3050208@parallels.com>
Date: Fri, 14 Feb 2014 23:09:14 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v15 00/13] kmemcg shrinkers
References: <cover.1391624021.git.vdavydov@parallels.com> <52FA3E8E.2080601@parallels.com> <20140211201946.GI4407@cmpxchg.org> <52FBB7F7.4050005@parallels.com> <20140212220110.GN6963@cmpxchg.org> <52FD01EC.2030000@parallels.com> <20140213212015.GO6963@cmpxchg.org>
In-Reply-To: <20140213212015.GO6963@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: dchinner@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, glommer@gmail.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On 02/14/2014 01:20 AM, Johannes Weiner wrote:
> On Thu, Feb 13, 2014 at 09:33:32PM +0400, Vladimir Davydov wrote:
>> On 02/13/2014 02:01 AM, Johannes Weiner wrote:
>>> On Wed, Feb 12, 2014 at 10:05:43PM +0400, Vladimir Davydov wrote:
>>>> On 02/12/2014 12:19 AM, Johannes Weiner wrote:
>>>>> On Tue, Feb 11, 2014 at 07:15:26PM +0400, Vladimir Davydov wrote:
>>>>>> Hi Michal, Johannes, David,
>>>>>>
>>>>>> Could you please take a look at this if you have time? Without your
>>>>>> review, it'll never get committed.
>>>>> There is simply no review bandwidth for new features as long as we are
>>>>> fixing fundamental bugs in memcg.
>>>>>
>>>>>> On 02/05/2014 10:39 PM, Vladimir Davydov wrote:
>>>>>>> Hi,
>>>>>>>
>>>>>>> This is the 15th iteration of Glauber Costa's patch-set implementing slab
>>>>>>> shrinking on memcg pressure. The main idea is to make the list_lru structure
>>>>>>> used by most FS shrinkers per-memcg. When adding or removing an element from a
>>>>>>> list_lru, we use the page information to figure out which memcg it belongs to
>>>>>>> and relay it to the appropriate list. This allows scanning kmem objects
>>>>>>> accounted to different memcgs independently.
>>>>>>>
>>>>>>> Please note that this patch-set implements slab shrinking only when we hit the
>>>>>>> user memory limit so that kmem allocations will still fail if we are below the
>>>>>>> user memory limit, but close to the kmem limit. I am going to fix this in a
>>>>>>> separate patch-set, but currently it is only worthwhile setting the kmem limit
>>>>>>> to be greater than the user mem limit just to enable per-memcg slab accounting
>>>>>>> and reclaim.
>>>>>>>
>>>>>>> The patch-set is based on top of v3.14-rc1-mmots-2014-02-04-16-48 (there are
>>>>>>> some vmscan cleanups that I need committed there) and organized as follows:
>>>>>>>  - patches 1-4 introduce some minor changes to memcg needed for this set;
>>>>>>>  - patches 5-7 prepare fs for per-memcg list_lru;
>>>>>>>  - patch 8 implement kmemcg reclaim core;
>>>>>>>  - patch 9 make list_lru per-memcg and patch 10 marks sb shrinker memcg-aware;
>>>>>>>  - patch 10 is trivial - it issues shrinkers on memcg destruction;
>>>>>>>  - patches 12 and 13 introduce shrinking of dead kmem caches to facilitate
>>>>>>>    memcg destruction.
>>>>> In the context of the ongoing discussions about charge reparenting I
>>>>> was curious how you deal with charges becoming unreclaimable after a
>>>>> memcg has been offlined.
>>>>>
>>>>> Patch #11 drops all charged objects at offlining by just invoking
>>>>> shrink_slab() in a loop until "only a few" (10) objects are remaining.
>>>>> How long is this going to take?  And why is it okay to destroy these
>>>>> caches when somebody else might still be using them?
>>>> IMHO, on container destruction we have to drop as many objects accounted
>>>> to this container as we can, because otherwise any container will be
>>>> able to get access to any number of unaccounted objects by fetching them
>>>> and then rebooting.
>>> They're accounted to and subject to the limit of the parent.  I don't
>>> see how this is different than page cache.
>>>
>>>>> That still leaves you with the free objects that slab caches retain
>>>>> for allocation efficiency, so now you put all dead memcgs in the
>>>>> system on a global list, and on a vmpressure event on root_mem_cgroup
>>>>> you walk the global list and drain the freelist of all remaining
>>>>> caches.
>>>>>
>>>>> This is a lot of complexity and scalability problems for less than
>>>>> desirable behavior.
>>>>>
>>>>> Please think about how we can properly reparent kmemcg charges during
>>>>> memcg teardown.  That would simplify your code immensely and help
>>>>> clean up this unholy mess of css pinning.
>>>>>
>>>>> Slab caches are already collected in the memcg and on destruction
>>>>> could be reassigned to the parent.  Kmemcg uncharge from slab freeing
>>>>> would have to be updated to use the memcg from the cache, not from the
>>>>> individual page, but I don't see why this wouldn't work right now.
>>>> I don't think I understand what you mean by reassigning slab caches to
>>>> the parent.
>>>>
>>>> If you mean moving all pages (slabs) from the cache of the memcg being
>>>> destroyed to the corresponding root cache (or the parent memcg's cache)
>>>> and then destroying the memcg's cache, I don't think this is feasible,
>>>> because slub free's fast path is lockless, so AFAIU we can't remove a
>>>> partial slab from a cache w/o risking to race with kmem_cache_free.
>>>>
>>>> If you mean clearing all pointers from the memcg's cache to the memcg
>>>> (changing them to the parent or root memcg), then AFAIU this won't solve
>>>> the problem with "dangling" caches - we will still have to shrink them
>>>> on vmpressure. So although this would allow us to put the reference to
>>>> the memcg from kmem caches on memcg's death, it wouldn't simplify the
>>>> code at all, in fact, it would even make it more complicated, because we
>>>> would have to handle various corner cases like reparenting vs
>>>> list_lru_{add,remove}.
>>> I think we have different concepts of what's complicated.  There is an
>>> existing model of what to do with left-over cache memory when a cgroup
>>> is destroyed, which is reparenting.  The rough steps will be the same,
>>> the object lifetime will be the same, the css refcounting will be the
>>> same, the user-visible behavior will be the same.  Any complexity from
>>> charge vs. reparent races will be contained to a few lines of code.
>>>
>>> Weird refcounting tricks during offline, trashing kmem caches instead
>>> of moving them to the parent like other memory, a global list of dead
>>> memcgs and sudden freelist thrashing on a vmpressure event, that's what
>>> adds complexity and what makes this code unpredictable, fragile, and
>>> insanely hard to work with.  It's not acceptable.
>>>
>>> By reparenting I meant reassigning the memcg cache parameter pointer
>>> from the slab cache such that it points to the parent.  This should be
>>> an atomic operation.  All css lookups already require RCU (I think slab
>>> does not follow this yet because we guarantee that css reference, but
>>> it should be changed).  So switch the cache param pointer, insert an
>>> RCU graceperiod to wait for all the ongoing charges and uncharges until
>>> nobody sees the memcg anymore, then safely reparent all the remaining
>>> memcg objects to the parent.  Maybe individually, maybe we can just
>>> splice the lists to the parent's list_lru lists.
>> But what should we do with objects that do not reside on any list_lru?
>> How can we reparent them?
> If there are no actual list_lru objects, we only have to make sure
> that any allocations are properly uncharged against the parent when
> they get freed later.
>
> If the slab freeing path would uncharge against the per-memcg cache's
> backpointer (s->memcg_params->memcg) instead of the per-page memcg
> association, then we could reparent whole caches with a single pointer
> update, without touching each individual slab page.  The kmemcg
> interface for slab would have to be reworked to not use
> lookup_page_cgroup() but have slab pass s->memcg_params->memcg.
>
> Once that is in place, css_free() can walk memcg->memcg_slab_caches
> and move all the items to the parent's memcg_slab_caches, and while
> doing that change the memcg pointer of each item, memcg_params->memcg,
> to point to the parent.  The cache is now owned by the parent and will
> stay alive until the last page is freed.
>
> There won't be any new allocations in these caches because there are
> no tasks in the group anymore, so no races from that side, and the
> perfect time to shrink the freelists.
>
> There will be racing frees of outstanding allocations, but we can deal
> with that.  Frees use page->slab_cache to look up the proper per-memcg
> cache, which may or may not have been reparented at this time.  If it
> has not, the cache's memcg backpointer (s->memcg_params->memcg) will
> point to the dying child (rcu protected) and uncharge the child's
> res_counter and the parent's.  If the backpointer IS already pointing
> to the parent, it will uncharge the res_counter of the parent without
> the child's but we don't care, it's dying anyway.
>
> If there are no list_lru tracked objects, we are done at this point.
> The css can be freed, the freelists have been purged, and any pages
> still in the cache will get unaccounted properly from the parent.
>
> If there are list_lru objects, they have to be moved to the parent's
> list_lru so that they can be reclaimed properly on memory pressure.
>
> Does this make sense?

Definitely. Thank you very much for such a detailed explanation! I guess
I'll try to implement this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
