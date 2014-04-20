Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id D7DA26B0038
	for <linux-mm@kvack.org>; Sun, 20 Apr 2014 06:39:37 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id n15so2485647lbi.13
        for <linux-mm@kvack.org>; Sun, 20 Apr 2014 03:39:37 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id g7si22133970lag.81.2014.04.20.03.39.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Apr 2014 03:39:36 -0700 (PDT)
Message-ID: <5353A3E3.4020302@parallels.com>
Date: Sun, 20 Apr 2014 14:39:31 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: [RFC] how should we deal with dead memcgs' kmem caches?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory
 Management List <linux-mm@kvack.org>, devel@openvz.org

Hi,

>From my pov one of the biggest problems in kmemcg implementation is how
to handle per memcg kmem caches that have objects when the owner memcg
is turned offline. Actually there are two issues here. First, when and
where we should initiate cache destruction (e.g. schedule destruction
work from kmem_cache_free when the last object goes away, or reap them
periodically). Second, how to prevent races between kmem_cache_destroy
and kmem_cache_free for a dead cache: the point is kmem_cache_free may
want to access the kmem_cache structure after it releases the object
potentially making the cache destroyable.

Here I'd like to present possible ways of sorting out this problem,
their pros and cons, in the hope that you will share your thoughts on
them and perhaps we will be able to come to a consensus about which way
we should choose.


* How it works now *

We count pages (slabs) allocated to a per memcg cache in
memcg_cache_params::nr_pages. When a memcg is turned offline, we set the
memcg_cache_params::dead flag, which makes slab freeing functions
schedule the memcg_cache_params::destroy work, which destroys the cache
(see memcg_release_pages), as soon as nr_pages reaches 0.

Actually, it does not work as expected: kmem caches that have objects on
memcg offline will be leaked, because both slab and slub designs never
free all pages on kmem_cache_free to speed up further allocs/frees.

Furthermore, currently we don't handle possible races between
kmem_cache_free/shrink and the destruction work - we can still use the
cache in kmem_cache_free/shrink after we freed the last page and
initiated destruction.


* Way #1 - prevent dead kmem caches from caching slabs on free *

We can modify sl[au]b implementation so that it won't cache any objects
on free if the kmem cache belongs to a dead memcg. Then it'd be enough
to drain per-cpu pools of all dead kmem caches on css offline - no new
slabs will be added there on further frees, and the last object will go
away along with the last slab.

Pros: don't see any
Cons:
 - have to intrude into sl[au]b internals
 - frees to dead caches will be noticeably slowed down

We still have to solve kmem_cache_free vs destroy race somehow, e.g. by
rearranging operations in kmem_cache_free so that nr_pages is always
decremented in the end.


* Way #2 - reap caches periodically or on vmpressure *

We can remove the async work scheduling from kmem_cache_free completely,
and instead walk over all dead kmem caches either periodically or on
vmpressure to shrink and destroy those of them that become empty.

That is what I had in mind when submitting the patch set titled "kmemcg:
simplify work-flow":
	https://lkml.org/lkml/2014/4/18/42

Pros: easy to implement
Cons: instead of being destroyed asap, dead caches will hang around
until some point in time or, even worse, memory pressure condition.

Again, it has nothing to say about the free-vs-destroy race. I was
planning to rearrange operations in kmem_cache_free as I described above.


* Way #3 - re-parent individual slabs *

Theoretically, we could move all slab pages belonging to a kmem cache of
a dead memcg to its parent memcg's cache. Then we could remove all dead
caches immediately on css offline.

Pros:
 - slabs of dead caches could be reused by parent memcg
 - should solve the cache free-vs-destroy race
Cons:
 - difficult to implement - requires deep knowledge of sl[au]b design
   and individual approach to both algorithms
 - will require heavy intrusion into sl[au]b internals


* Way #4 - count active objects per memcg cache *

We could count not pages allocated to per memcg kmem caches, but
individual objects. To minimize performance impact we could use percpu
counters (something like percpu_ref).

Pros:
 - very simple and clear implementation independent of slab algorithm
 - caches are destroyed as soon as they become empty
 - solves the problem with free-vs-destroy race automatically - cache
   destruction will be initiated in the end of the last kfree, so that
   no races are possible
Cons:
 - will impact performance of alloc/free for per memcg caches,
   especially for dead ones, for which we have to switch to an atomic
   counter
 - existing implementation of percpu_ref can only hold 2^31-1 values;
   although currently we can hardly have 2G kmem objects of one kind
   even in a global cache, not speaking of per memcg, we should use
   long counter to avoid overflows in future; therefore we should
   either extend the existing implementation or introduce new percpu
   long counter or use in-place solution


I'd appreciate if you could vote for the solution you like most or
propose other approaches.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
