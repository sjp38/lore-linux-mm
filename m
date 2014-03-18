Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id F06BD6B00ED
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 04:19:03 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id hr17so4441739lab.4
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 01:19:03 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id w9si12203084laj.20.2014.03.18.01.19.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Mar 2014 01:19:02 -0700 (PDT)
Message-ID: <53280174.1040507@parallels.com>
Date: Tue, 18 Mar 2014 12:19:00 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND -mm 02/12] memcg: fix race in memcg cache destruction
 path
References: <cover.1394708827.git.vdavydov@parallels.com> <94fc308b9074e45a2aac7a06cf357a33c5d97c9f.1394708827.git.vdavydov@parallels.com> <20140317164203.GC30623@dhcp22.suse.cz>
In-Reply-To: <20140317164203.GC30623@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On 03/17/2014 08:42 PM, Michal Hocko wrote:
> On Thu 13-03-14 19:06:40, Vladimir Davydov wrote:
>> We schedule memcg cache shrink+destruction work (memcg_params::destroy)
>> from two places: when we turn memcg offline
>> (mem_cgroup_destroy_all_caches) and when the last page of the cache is
>> freed (memcg_params::nr_pages reachs zero, see memcg_release_pages,
>> mem_cgroup_destroy_cache).
> This is just ugly! Why do we mem_cgroup_destroy_all_caches from the
> offline code at all? Just calling kmem_cache_shrink and then wait for
> the last pages to go away should be sufficient to fix this, no?

The problem is kmem_cache_shrink() can take the slab_mutex, and we
iterate over memcg caches to be destroyed under the memcg's
slab_caches_mutex, which is nested into the slab_mutex (see
mem_cgroup_destroy_all_caches()). So we can't call kmem_cache_shrink()
there directly due to lockdep. That's what all that trickery with using
the same work for both cache shrinking and destruction is for. I agree
this is ugly and somewhat difficult to understand. Let me share my
thoughts on this problem.

First, why do we need to call kmem_cache_shrink() there at all? AFAIU,
this is because most of memcg caches must be empty by the time the memcg
is destroyed, but since there are some pages left on the caches for
performance reasons, and those pages hold cache references
(kmem_cache::memcg_params::nr_pages) preventing it from being destroyed,
we try to shrink them to get rid of empty caches. If shrink fails (i.e.
the memcg cache is not empty) the cache will be pending for good in the
current implementation (until someone calls the shrink manually at
least). Glauber intended to fix the issue with pending caches by reaping
them on vmpressure, but he didn't have enough time to complete this,
unfortunately.

But why do we get cache references per slab? I mean why do we inc the
cache refcounter (kmem_cache::memcg_params::nr_pages currently) when
allocating a slab, not an individual object? If we took the reference to
the cache per individual object, we would not have to call
kmem_cache_shrink() on memcg offline - if the cache is empty it will be
destroyed immediately then, because its refcounter reaches 0, otherwise
we could leave it hanging around for a while and only try to shrink it
on vmpressure when we really need free mem. That would make the
destroy_work straightforward - it would simply call kmem_cache_destroy()
and that's it.

I guess I foresee the answer to the question I've just raised - using a
per cache refcounter and taking it on each alloc/free would hurt
scalability too much. However, we could use percpu refcounter to
overcome this, couldn't we?

There is one more argument for taking the cache refcount on a per-object
(not per-slab) basis. There seems to be a race in kmem allocation path.
The point is there is a time window between we get the cache to allocate
from (memcg_kmem_get_cache()) and the actual allocating from the cache
(see slab_alloc_node()). Actually, nothing prevents the cache from going
away in this time window - the task can change its cgroup and the former
cgroup can be taken offline resulting in the cache destruction. This is
very unlikely, but still possible. A similar problem with freeing
objects - currently we might continue using a cache after we actually
freed the last object and dropped the reference - look at
kmem_freepages(), there we dereference the cache pointer after calling
memcg_release_pages(), which drops the cache reference. The latter is
more-or-less easy to fix though by ensuring we always drop the reference
after we stopped using the cache, but this would imply heavy intrusion
into slab internals AFAIU, which is bad. OTOH if we took the cache
reference per allocated object, these problems would be resolved
automatically and clearly.

I haven't included that in this set, because I tried not to blow it too
much, I just wanted to introduce cache reparenting, in the meanwhile
fixing only those issues that had become really painful. Not sure if it
was the right decision though :-/

Anyway, I would appreciate if you could share your thoughts about that.

> Whether the current code is good (no it's not) is another question. But
> this should be fixed also in the stable trees (is the bug there since
> the very beginning?) so the fix should be as simple as possible IMO.
> So if there is a simpler solution I would prefer it. But I am drowning
> in the kmem trickiness spread out all over the place so I might be
> missing something very easily.

Frankly, I'm not bothering about stable trees by now, because I don't
think anybody is using kmemcg since w/o fs cache shrinking it looks
pretty useless. May be, I'm wrong :-/

Thanks.

>> Since the latter can happen while the work
>> scheduled from mem_cgroup_destroy_all_caches is in progress or still
>> pending, we need to be cautious to avoid races there - we should
>> accurately bail out in one of those functions if we see that the other
>> is in progress. Currently we only check if memcg_params::nr_pages is 0
>> in the destruction work handler and do not destroy the cache if so. But
>> that's not enough. An example of race we can get is shown below:
>>
>>   CPU0					CPU1
>>   ----					----
>>   kmem_cache_destroy_work_func:		memcg_release_pages:
>> 					  atomic_sub_and_test(1<<order, &s->
>> 							memcg_params->nr_pages)
>> 					  /* reached 0 => schedule destroy */
>>
>>     atomic_read(&cachep->memcg_params->nr_pages)
>>     /* 0 => going to destroy the cache */
>>     kmem_cache_destroy(cachep);
>>
>> 					  mem_cgroup_destroy_cache(s):
>> 					    /* the cache was destroyed on CPU0
>> 					       - use after free */
>>
>> An obvious way to fix this would be substituting the nr_pages counter
>> with a reference counter and make memcg take a reference. The cache
>> destruction would be then scheduled from that thread which decremented
>> the refcount to 0. Generally, this is what this patch does, but there is
>> one subtle thing here - the work handler serves not only for cache
>> destruction, it also shrinks the cache if it's still in use (we can't
>> call shrink directly from mem_cgroup_destroy_all_caches due to locking
>> dependencies). We handle this by noting that we should only issue shrink
>> if called from mem_cgroup_destroy_all_caches, because the cache is
>> already empty when we release its last page. And if we drop the
>> reference taken by memcg in the work handler, we can detect who exactly
>> scheduled the worker - mem_cgroup_destroy_all_caches or
>> memcg_release_pages.
>>
>> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Michal Hocko <mhocko@suse.cz>
>> Cc: Glauber Costa <glommer@gmail.com>
> [...]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
