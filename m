Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47D3C6B0009
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 13:16:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g13so10183163wrh.23
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 10:16:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s60sor7306352wrc.5.2018.03.26.10.16.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 10:16:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180324131131.blg3eqsfjc6issp2@esperanza>
References: <20180321224301.142879-1-shakeelb@google.com> <20180324131131.blg3eqsfjc6issp2@esperanza>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 26 Mar 2018 10:16:37 -0700
Message-ID: <CALvZod7=LDppfsXihxuwivVhpzT0eRh5REbUe4codni0TTCaWw@mail.gmail.com>
Subject: Re: [PATCH] mm, slab: eagerly delete inactive offlined SLABs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

+Tejun, Johannes

Hi Vladimir,

On Sat, Mar 24, 2018 at 6:11 AM, Vladimir Davydov
<vdavydov.dev@gmail.com> wrote:
> Hello Shakeel,
>
> The patch makes sense to me, but I have a concern about synchronization
> of cache destruction vs concurrent kmem_cache_free. Please, see my
> comments inline.
>
> On Wed, Mar 21, 2018 at 03:43:01PM -0700, Shakeel Butt wrote:
>> With kmem cgroup support, high memcgs churn can leave behind a lot of
>> empty kmem_caches. Usually such kmem_caches will be destroyed when the
>> corresponding memcg gets released but the memcg release can be
>> arbitrarily delayed. These empty kmem_caches wastes cache_reaper's time.
>> So, the reaper should destroy such empty offlined kmem_caches.
>
>> diff --git a/mm/slab.c b/mm/slab.c
>> index 66f2db98f026..9c174a799ffb 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -4004,6 +4004,16 @@ static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
>>       slabs_destroy(cachep, &list);
>>  }
>>
>> +static bool is_slab_active(struct kmem_cache *cachep)
>> +{
>> +     int node;
>> +     struct kmem_cache_node *n;
>> +
>> +     for_each_kmem_cache_node(cachep, node, n)
>> +             if (READ_ONCE(n->total_slabs) - n->free_slabs)
>
> Why READ_ONCE total_slabs, but not free_slabs?
>
> Anyway, AFAIU there's no guarantee that this CPU sees the two fields
> updated in the same order as they were actually updated on another CPU.
> For example, suppose total_slabs is 2 and free_slabs is 1, and another
> CPU is freeing a slab page concurrently from kmem_cache_free, i.e.
> subtracting 1 from both total_slabs and free_slabs. Then this CPU might
> see a transient state, when total_slabs is already updated (set to 1),
> but free_slabs is not (still equals 1), and decide that it's safe to
> destroy this slab cache while in fact it isn't.
>
> Such a race will probably not result in any serious problems, because
> shutdown_cache() checks that the cache is empty and does nothing if it
> isn't, but still it looks suspicious and at least deserves a comment.
> To eliminate the race, we should check total_slabs vs free_slabs with
> kmem_cache_node->list_lock held. Alternatively, I think we could just
> check if total_slabs is 0 - sooner or later cache_reap() will release
> all empty slabs anyway.
>

Checking total_slabs is 0 seems much simpler, I will test that.

>> +                     return true;
>> +     return false;
>> +}
>
>> @@ -4061,6 +4071,10 @@ static void cache_reap(struct work_struct *w)
>>                               5 * searchp->num - 1) / (5 * searchp->num));
>>                       STATS_ADD_REAPED(searchp, freed);
>>               }
>> +
>> +             /* Eagerly delete inactive kmem_cache of an offlined memcg. */
>> +             if (!is_memcg_online(searchp) && !is_slab_active(searchp))
>
> I don't think we need to define is_memcg_online in generic code.
> I would merge is_memcg_online and is_slab_active, and call the
> resulting function cache_is_active.
>

Ack.

>> +                     shutdown_cache(searchp);
>>  next:
>>               cond_resched();
>>       }


Currently I am holding off this patch as Greg Thelen has pointed out
(offline) a race condition this patch will introduce between
memcg_kmem_get_cache and the cache reaper. The memcg of the cache
returned by memcg_kmem_get_cache() can get offline while the
allocation is happening on that cache (allocation can take long time
due to reclaim or memory pressure). The reaper will see that the memcg
of this cache is offlined and let's say at the moment s->total_slabs
is 0, the reaper will delete the cache while parallel allocation is
going on.

I was thinking of adding an API to force a memcg to be online (or
rather delay the call to css_offline), something like
css_tryget_stay_online()/css_put_online() and use it in
memcg_kmem_get_cache() and memcg_kmem_put_cache(). However Tejun has
advised to not go through that route, more specifically not to tie
on/offling a css with accounting artifacts.

I am still exploring more solutions.

thanks,
Shakeel
