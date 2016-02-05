Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id AECEA440441
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 12:04:58 -0500 (EST)
Received: by mail-oi0-f46.google.com with SMTP id s2so45232462oie.2
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 09:04:58 -0800 (PST)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id d1si5207705oeo.79.2016.02.05.09.04.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 09:04:57 -0800 (PST)
Received: by mail-oi0-x22a.google.com with SMTP id j125so44836656oih.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 09:04:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160205103248.GA5210@techsingularity.net>
References: <1454571612-9486-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20160205103248.GA5210@techsingularity.net>
Date: Sat, 6 Feb 2016 02:04:57 +0900
Message-ID: <CAAmzW4N-dg6h+nT7bMavAyxzmvF1M5mY+MmfPen327zY6rzKEQ@mail.gmail.com>
Subject: Re: [PATCH] mm/slab: re-implement pfmemalloc support
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-02-05 19:33 GMT+09:00 Mel Gorman <mgorman@techsingularity.net>:
> On Thu, Feb 04, 2016 at 04:40:12PM +0900, Joonsoo Kim wrote:
>> Current implementation of pfmemalloc handling in SLAB has some problems.
>>
>> 1) pfmemalloc_active is set to true when there is just one or more
>> pfmemalloc slabs in the system, but it is cleared when there is
>> no pfmemalloc slab in one arbitrary kmem_cache. So, pfmemalloc_active
>> could be wrongly cleared.
>>
>
> Ok.
>
>> 2) Search to partial and free list doesn't happen when non-pfmemalloc
>> object are not found in cpu cache. Instead, allocating new slab happens
>> and it is not optimal.
>>
>
> It was intended to be conservative on the use of slabs that are
> potentially pfmemalloc.
>
>> 3) Even after sk_memalloc_socks() is disabled, cpu cache would keep
>> pfmemalloc objects tagged with SLAB_OBJ_PFMEMALLOC. It isn't cleared if
>> sk_memalloc_socks() is disabled so it could cause problem.
>>
>
> Ok.
>
>> 4) If cpu cache is filled with pfmemalloc objects, it would cause slow
>> down non-pfmemalloc allocation.
>>
>
> It may slow down non-pfmemalloc allocations but the alternative is
> potentially livelocking the system if it cannot allocate the memory it
> needs to swap over the network. It was expected that a system that really
> wants to swap over the network is not going to be worried about slowdowns
> when it happens.

Okay.

>> To me, current pointer tagging approach looks complex and fragile
>> so this patch re-implement whole thing instead of fixing problems
>> one by one.
>>
>> Design principle for new implementation is that
>>
>> 1) Don't disrupt non-pfmemalloc allocation in fast path even if
>> sk_memalloc_socks() is enabled. It's more likely case than pfmemalloc
>> allocation.
>>
>> 2) Ensure that pfmemalloc slab is used only for pfmemalloc allocation.
>>
>> 3) Don't consider performance of pfmemalloc allocation in memory
>> deficiency state.
>>
>> As a result, all pfmemalloc alloc/free in memory tight state will
>> be handled in slow-path. If there is non-pfmemalloc free object,
>> it will be returned first even for pfmemalloc user in fast-path so that
>> performance of pfmemalloc user isn't affected in normal case and
>> pfmemalloc objects will be kept as long as possible.
>>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Just out of curiousity, is there any measurable impact to this patch? It
> seems that it only has an impact when swap over network is used.

No, I didn't measure that.

>> ---
>>  mm/slab.c | 285 ++++++++++++++++++++++++++------------------------------------
>>  1 file changed, 118 insertions(+), 167 deletions(-)
>>
>> Hello, Mel.
>>
>> May I ask you to review the patch and test it on your swap over nbd setup
>> in order to check that it has no regression? For me, it's not easy
>> to setup this environment.
>>
>
> Unfortunately I do not have that setup available at this time as the
> machine that co-ordinated it has died. It's on my todo list to setup a
> replacement for it but it will take time.

Okay.

> As a general approach, I like what you did. The pfmemalloc slabs may be
> slower to manage but that is not a concern because someone concerned with
> the performance of swap over network needs their head examined.  However,
> it needs testing because I think there is at least one leak in there.

Okay.

>> <SNIP>
>>
>> @@ -2820,7 +2695,46 @@ static inline void fixup_slab_list(struct kmem_cache *cachep,
>>               list_add(&page->lru, &n->slabs_partial);
>>  }
>>
>> -static struct page *get_first_slab(struct kmem_cache_node *n)
>> +/* Try to find non-pfmemalloc slab if needed */
>> +static noinline struct page *get_valid_first_slab(struct kmem_cache_node *n,
>> +                                     struct page *page, bool pfmemalloc)
>> +{
>> +     if (!page)
>> +             return NULL;
>> +
>> +     if (pfmemalloc)
>> +             return page;
>> +
>> +     if (!PageSlabPfmemalloc(page))
>> +             return page;
>> +
>> +     /* No need to keep pfmemalloc slab if we have enough free objects */
>> +     if (n->free_objects > n->free_limit) {
>> +             ClearPageSlabPfmemalloc(page);
>> +             return page;
>> +     }
>> +
>
> This seems a bit arbitrary. It's not known in advance how much memory
> will be needed by the network but if PageSlabPfmemalloc is set, then at
> least that much was needed in the past. I don't see what the
> relationship is betwewen n->free_limit and the memory requirements for
> swapping over a network.

n->free_limit is the criteria that we decide to keep a frees slab or free it to
page allocator. Over this number imply that we cache too much memory so
we don't need to keep pfmemalloc memory, too. *Used* pfmemalloc memory
could grow over this number sometimes, but, it doesn't mean that we need to
keep that much *free* memory continuously. Pfmemalloc memory can only be
used by pfmemalloc user so it will be in cache too long. Clearing it
and using it
by non-pfmemalloc user in this enough free memory situation will help
not to cache too much memory.

>> +     /* Move pfmemalloc slab to the end of list to speed up next search */
>> +     list_del(&page->lru);
>> +     if (!page->active)
>> +             list_add_tail(&page->lru, &n->slabs_free);
>> +     else
>> +             list_add_tail(&page->lru, &n->slabs_partial);
>> +
>
> Potentially this is a premature optimisation. We really don't care about
> the performance of swap over network as long as it works.

Why premature? This case only happens, there are some pfmemalloc slab
and some non-pfmemalloc slab. Moving pfmemalloc slab to the end of list will
help to use non-pfmemalloc slab first and to find it quickly.

>> -static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags,
>> -                                                     bool force_refill)
>> +static noinline void *cache_alloc_pfmemalloc(struct kmem_cache *cachep,
>> +                             struct kmem_cache_node *n, gfp_t flags)
>> +{
>> +     struct page *page;
>> +     void *obj;
>> +     void *list = NULL;
>> +
>> +     if (!gfp_pfmemalloc_allowed(flags))
>> +             return NULL;
>> +
>> +     /* Racy check if there is free objects */
>> +     if (!n->free_objects)
>> +             return NULL;
>> +
>
> Yes, it's racy. Just take the lock and check it. Sure there may be
> contention but being slow is ok in this particular case.

Okay.

>> @@ -3407,7 +3353,12 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
>>               cache_flusharray(cachep, ac);
>>       }
>>
>> -     ac_put_obj(cachep, ac, objp);
>> +     if (sk_memalloc_socks()) {
>> +             cache_free_pfmemalloc(cachep, objp);
>> +             return;
>> +     }
>> +
>> +     ac->entry[ac->avail++] = objp;
>
> cache_free_pfmemalloc() only handles PageSlabPfmemalloc() pages so it
> appears this thing is leaking objects on !PageSlabPfmemalloc pages.
> Either cache_free_pfmemalloc needs update ac->entry or it needs to
> return bool to indicate whether __cache_free needs to handle it.

Oops... I will fix it.

> I'll look into setting up some sort of test rig in case a v2 comes
> along.

Thanks for detailed review and trying to rig test machine.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
