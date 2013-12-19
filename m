Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id AED1B6B003A
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 04:21:58 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id w7so327435lbi.38
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 01:21:58 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id jh8si1298886lbc.123.2013.12.19.01.21.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 01:21:57 -0800 (PST)
Message-ID: <52B2BAAA.40801@parallels.com>
Date: Thu, 19 Dec 2013 13:21:46 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/6] memcg, slab: check and init memcg_cahes under slab_mutex
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com> <afc6d5e85d805c7313e928497b4ebcf1815703dd.1387372122.git.vdavydov@parallels.com> <20131218174105.GE31080@dhcp22.suse.cz> <52B29B2F.7050909@parallels.com> <CAA6-i6r=hW+Y2+kdKME=GTWN6sCbi37kh4sX5dT3AKkatpQzGg@mail.gmail.com>
In-Reply-To: <CAA6-i6r=hW+Y2+kdKME=GTWN6sCbi37kh4sX5dT3AKkatpQzGg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@gmail.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hi, Christoph

We have a problem with memcg-vs-slab interactions. Currently we set the
pointer to a new kmem_cache in its parent's memcg_caches array inside
memcg_create_kmem_cache() (mm/memcontrol.c):

memcg_create_kmem_cache():
    new_cachep = cache_from_memcg_idx(cachep, idx);
    if (new_cachep)
        goto out;
    new_cachep = kmem_cache_dup(memcg, cachep);
    cachep->memcg_params->memcg_caches[idx] = new_cachep;

It seems to be prone to a race as explained in the comment to this
patch. To fix the race, we need to move the assignment of new_cachep to
memcg_caches[idx] to be called under the slab_mutex protection.

There are basically two ways of doing this:

1. Move the assignment to kmem_cache_create_memcg() defined in
mm/slab.c. This is how this patch handles it.
2. Move taking of the slab_mutex, along with some memcg-specific
initialization bits, from kmem_cache_create_memcg() to
memcg_create_kmem_cache().

The second way, although looks clearer, will break the convention not to
take the slab_mutex inside mm/memcontrol.c, Glauber tried to observe
while implementing kmemcg.

So the question is: what do you think about taking the slab_mutex
directly from mm/memcontrol.c w/o using helper functions (confusing call
paths, IMO)?

Thanks.

On 12/19/2013 12:00 PM, Glauber Costa wrote:
> On Thu, Dec 19, 2013 at 11:07 AM, Vladimir Davydov
> <vdavydov@parallels.com> wrote:
>> On 12/18/2013 09:41 PM, Michal Hocko wrote:
>>> On Wed 18-12-13 17:16:55, Vladimir Davydov wrote:
>>>> The memcg_params::memcg_caches array can be updated concurrently from
>>>> memcg_update_cache_size() and memcg_create_kmem_cache(). Although both
>>>> of these functions take the slab_mutex during their operation, the
>>>> latter checks if memcg's cache has already been allocated w/o taking the
>>>> mutex. This can result in a race as described below.
>>>>
>>>> Asume two threads schedule kmem_cache creation works for the same
>>>> kmem_cache of the same memcg from __memcg_kmem_get_cache(). One of the
>>>> works successfully creates it. Another work should fail then, but if it
>>>> interleaves with memcg_update_cache_size() as follows, it does not:
>>> I am not sure I understand the race. memcg_update_cache_size is called
>>> when we start accounting a new memcg or a child is created and it
>>> inherits accounting from the parent. memcg_create_kmem_cache is called
>>> when a new cache is first allocated from, right?
>> memcg_update_cache_size() is called when kmem accounting is activated
>> for a memcg, no matter how.
>>
>> memcg_create_kmem_cache() is scheduled from __memcg_kmem_get_cache().
>> It's OK to have a bunch of such methods trying to create the same memcg
>> cache concurrently, but only one of them should succeed.
>>
>>> Why cannot we simply take slab_mutex inside memcg_create_kmem_cache?
>>> it is running from the workqueue context so it should clash with other
>>> locks.
>> Hmm, Glauber's code never takes the slab_mutex inside memcontrol.c. I
>> have always been wondering why, because it could simplify flow paths
>> significantly (e.g. update_cache_sizes() -> update_all_caches() ->
>> update_cache_size() - from memcontrol.c to slab_common.c and back again
>> just to take the mutex).
>>
> Because that is a layering violation and exposes implementation
> details of the slab to
> the outside world. I agree this would make things a lot simpler, but
> please check with Christoph
> if this is acceptable before going forward.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
