Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id CCAA36B0039
	for <linux-mm@kvack.org>; Mon, 19 May 2014 14:27:58 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pn19so4354119lab.6
        for <linux-mm@kvack.org>; Mon, 19 May 2014 11:27:57 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id lk8si14479555lac.99.2014.05.19.11.27.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 May 2014 11:27:56 -0700 (PDT)
Message-ID: <537A4D27.1050909@parallels.com>
Date: Mon, 19 May 2014 22:27:51 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg offline
References: <cover.1399982635.git.vdavydov@parallels.com> <6eafe1e95d9a934228e9af785f5b5de38955aa6a.1399982635.git.vdavydov@parallels.com> <alpine.DEB.2.10.1405141119320.16512@gentwo.org> <20140515071650.GB32113@esperanza> <alpine.DEB.2.10.1405151015330.24665@gentwo.org> <20140516132234.GF32113@esperanza> <alpine.DEB.2.10.1405160957100.32249@gentwo.org> <20140519152437.GB25889@esperanza> <alpine.DEB.2.10.1405191056580.22956@gentwo.org>
In-Reply-To: <alpine.DEB.2.10.1405191056580.22956@gentwo.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

19.05.2014 20:03, Christoph Lameter:
> On Mon, 19 May 2014, Vladimir Davydov wrote:
>
>>> I doubt that. The accounting occurs when a new cpu slab page is allocated.
>>> But the individual allocations in the fastpath are not accounted to a
>>> specific group. Thus allocation in a slab page can belong to various
>>> cgroups.
>>
>> On each kmalloc, we pick the cache that belongs to the current memcg,
>> and allocate objects from that cache (see memcg_kmem_get_cache()). And
>> all slab pages allocated for a per memcg cache are accounted to the
>> memcg the cache belongs to (see memcg_charge_slab). So currently, each
>> kmem cache, i.e. each slab of it, can only have objects of one cgroup,
>> namely its owner.
>
> Ok that works for kmalloc. What about dentry/inodes and so on?

The same. Actually, by kmalloc I meant kmem_cache_alloc, or
slab_alloc_node, to be more exact.

>> OK, it seems we have no choice but keeping dead caches left after memcg
>> offline until they have active slabs. How can we get rid of them then?
>
> Then they are moved to a list and therefore you can move them to yours I
> think.
>
>> Simply counting slabs on cache and destroying cache when the count goes
>> to 0 isn't enough, because slub may keep some free slabs by default (if
>> they are frozen e.g.) Reaping them periodically doesn't look nice.
>
> But those are only limited to one slab per cpu ( plus eventual cpu partial
> ones but you can switch that feature off).

AFAIU slub can keep free slabs in:

1) One per cpu slab. This is the easiest thing to handle - we only need
to shrink the cache, because this slab can only be added on allocation,
not on free.

2) Per node partial slab lists. Free slabs can be added there on frees,
but only if min_partial > 0, so setting min_partial = 0 would solve
that, just as you pointed below.

3) Per cpu partial slabs. We can disable this feature for dead caches by
adding appropriate check to kmem_cache_has_cpu_partial.

So far, everything looks very simple - it seems we don't have to modify
__slab_free at all if we follow the instruction above.

However, there is one thing regarding preemptable kernels. The problem
is after forbidding the cache store free slabs in per-cpu/node partial
lists by setting min_partial=0 and kmem_cache_has_cpu_partial=false
(i.e. marking the cache as dead), we have to make sure that all frees
that saw the cache as alive are over, otherwise they can occasionally
add a free slab to a per-cpu/node partial list *after* the cache was
marked dead. For instance,

CPU0                            CPU1
----                            ----
memcg offline:                  __slab_free:
                                   // let the slab we're freeing the obj
                                   // to is full, so we are considering
                                   // freezing it;
                                   // since kmem_cache_has_cpu_partial
                                   // returns true, we'll try to freeze
                                   // it;
                                   new.frozen=1

                                   // but before proceeding to cmpxchg
                                   // we get preempted
   mark cache s dead:
     s->min_partial=0
     make kmem_cache_has_cpu_partial return false

   kmem_cache_shrink(s) // this removes all empty slabs from
                        // per cpu/node partial lists

                                   // when this thread continues to
                                   // __slab_free, the cache is dead
                                   // and no slabs must be added to
                                   // per-cpu partial list, but the
                                   // following cmpxchg may succeed
                                   // in freezing the slab
                                   cmpxchg_double_slab(s, page,
                                       prior, counters,
                                       object, new.counters)

As a result, we'll eventually end up with a free slab on a per-cpu
partial list, so that the cache refcounter will never drop to zero and
the cache leaks.

This is very unlikely, but still possible. To avoid that, we should
assure all __slab_free's like that running on CPU1 are over before
proceeding to kmem_cache_shrink on memcg offline. Currently, it is
impossible to achieve that on fully preemptable kernels w/o modifying
__slab_free, AFAIU. That's what all that trickery in __slab_free about.

Makes sense or am I missing something?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
