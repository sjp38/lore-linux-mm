Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4D55C6B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 11:00:27 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id z11so3230409lbi.36
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 08:00:26 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id oc6si24429124lbb.31.2014.04.21.08.00.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Apr 2014 08:00:25 -0700 (PDT)
Message-ID: <53553283.7020709@parallels.com>
Date: Mon, 21 Apr 2014 19:00:19 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] how should we deal with dead memcgs' kmem caches?
References: <5353A3E3.4020302@parallels.com> <20140421121840.GA11622@cmpxchg.org>
In-Reply-To: <20140421121840.GA11622@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, devel@openvz.org

On 04/21/2014 04:18 PM, Johannes Weiner wrote:
> On Sun, Apr 20, 2014 at 02:39:31PM +0400, Vladimir Davydov wrote:
>> * Way #2 - reap caches periodically or on vmpressure *
>>
>> We can remove the async work scheduling from kmem_cache_free completely,
>> and instead walk over all dead kmem caches either periodically or on
>> vmpressure to shrink and destroy those of them that become empty.
>>
>> That is what I had in mind when submitting the patch set titled "kmemcg:
>> simplify work-flow":
>> 	https://lkml.org/lkml/2014/4/18/42
>>
>> Pros: easy to implement
>> Cons: instead of being destroyed asap, dead caches will hang around
>> until some point in time or, even worse, memory pressure condition.
> 
> This would continue to pin css after cgroup destruction indefinitely,
> or at least for an arbitrary amount of time.  To reduce the waste from
> such pinning, we currently have to tear down other parts of the memcg
> optimistically from css_offline(), which is called before the last
> reference disappears and out of hierarchy order, making the teardown
> unnecessarily complicated and error prone.

I don't think that re-parenting kmem caches on css offline would be
complicated in such a scheme. We just need to walk over the memcg's
memcg_slab_caches list and move them to the list of its parent along
with changing the memcg_params::memcg ptr. Also, we have to assure that
all readers of memcg_params::memcg are protected with RCU and handle
re-parenting properly. AFAIU, we'd have to do approximately the same if
we decided to go with individual slabs reparenting.

To me the most disgusting part is that after css offline we'll have
pointless dead caches hanging for indefinite time w/o any chance to get
reused.

> So I think "easy to implement" is misleading.  What we really care
> about is "easy to maintain", and this basically excludes any async
> schemes.
> 
> As far as synchronous cache teardown goes, I think everything that
> introduces object accounting into the slab hotpaths will also be a
> tough sell.

Agree, so ways #1 and #4 don't seem to be an option.

> Personally, I would prefer the cache merging, where remaining child
> slab pages are moved to the parent's cache on cgroup destruction.

Your point is clear to me and sounds quite reasonable, but I'm afraid
that moving slabs from one active kmem cache to another would be really
difficult to implement, since kmem_cache_free is mostly lock-less. Also
we'll have to intrude into the free fast path to handle concurrent cache
merging. That's why I'm trying to find another way around.

There is another idea that has just sprung into my mind. Actually, it's
based on Way #2, but has one significant difference - dead caches can be
reused. Below goes the full picture.

First, for re-parenting of kmem charges, there will be a kmem context
object per each kmem-enabled memcg. All kmem pages (including slabs)
that are charged to a memcg will point to the context object of the
memcg through the page cgroup, not to the memcg itself as it works now.
When a kmem page is freed, it will be discharged against the memcg of
the context it points to. The context will look like this:

struct memcg_kmem_context {
	struct mem_cgroup *memcg; /* owner memcg */
	atomic_long_t nr_pages;   /* nr pages charged to the memcg
				     through this context */
	struct list_head list;	  /* list of all memcg's contexts */
};

struct mem_cgroup {
	[...]
	struct memcg_kmem_context *kmem_ctx;

On memcg offline we'll reparent its context to the parent memcg by
changing the memcg_kmem_context::memcg ptr to the parent so that all
previously allocated objects will be discharged properly against its
parent. Regarding the memcg's caches, no re-parenting is necessary -
we'll just mark them as orphaned (e.g. by clearing memcg_params::memcg).
We won't clear the orphaned caches from root caches'
memcg_params::memcg_caches arrays although we will release the dead
memcg along with its kmemcg_id. The orphaned caches won't have any
references to the dead memcg and therefore won't pin the css.

Then, if the kmemcg_id is relocated to another memcg, the new memcg will
just adopt such an orphaned cache and allocate objects from it. Note,
some of the pages the new memcg will be allocating from may be accounted
to the parent of the previous owner memcg.

On vmpressure we will walk over orphaned caches to shrink them and
optionally destroy those of them that become empty.

To sum up what we will have in such a design:
Pros:
 - no css pinning: kmem caches just marked orphaned while the kmem
   context is re-parented, so that the dead css can go away
 - simple teardown procedure on css offline: re-parenting of kmem
   contexts would be just changing memcg_kmem_context::memcg while
   orphaning the caches is just clearing the pointer to the owner memcg;
   since no concurrent allocations from the caches is possible, no
   sophisticated synchronizations is needed
 - reaping of orphaned caches on vmpressure will look quite natural,
   because the caches may be reused at any time
 - slab internals independent
Cons:
 - objects belonging to different memcgs may be located on the same
   slab of the same cache - the slab will be accounted to only one of
   the cgroups though; AFAIU we would have the same picture if we moved
   slabs from dead cache to its parent
 - kmem context objects will hang around until all pages accounted
   through them are gone, which may take indefinitely long, but that
   shouldn't be a big problem, because their size is rather small.

What do you think about that?

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
