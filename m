Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32D136B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 07:41:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e201so73633748wme.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 04:41:41 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id a136si20462585wmd.61.2016.05.02.04.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 04:41:40 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id g17so137732570wme.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 04:41:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+YV4A_YbDq5asowLJPUODottNHAKScWoRdUx6uy+TN-Uw@mail.gmail.com>
References: <20160502094920.GA3005@cherokee.in.rdlabs.hpecorp.net> <CACT4Y+YV4A_YbDq5asowLJPUODottNHAKScWoRdUx6uy+TN-Uw@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 2 May 2016 13:41:20 +0200
Message-ID: <CACT4Y+Z_+crRUm0U89YwW3x99dtx9cfPoO+L6mD-uyzfZAMkKw@mail.gmail.com>
Subject: Re: [PATCH] kasan: improve double-free detection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 2, 2016 at 12:09 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Mon, May 2, 2016 at 11:49 AM, Kuthonuzo Luruo
> <kuthonuzo.luruo@hpe.com> wrote:
>> Hi Alexander/Andrey/Dmitry,
>>
>> For your consideration/review. Thanks!
>>
>> Kuthonuzo Luruo
>>
>> Currently, KASAN may fail to detect concurrent deallocations of the same
>> object due to a race in kasan_slab_free(). This patch makes double-free
>> detection more reliable by atomically setting allocation state for object
>> to KASAN_STATE_QUARANTINE iff current state is KASAN_STATE_ALLOC.
>>
>> Tested using a modified version of the 'slab_test' microbenchmark where
>> allocs occur on CPU 0; then all other CPUs concurrently attempt to free the
>> same object.
>>
>> Signed-off-by: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
>> ---
>>  mm/kasan/kasan.c |   32 ++++++++++++++++++--------------
>>  mm/kasan/kasan.h |    5 ++---
>>  2 files changed, 20 insertions(+), 17 deletions(-)
>>
>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>> index ef2e87b..4fc4e76 100644
>> --- a/mm/kasan/kasan.c
>> +++ b/mm/kasan/kasan.c
>> @@ -511,23 +511,28 @@ void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
>>  bool kasan_slab_free(struct kmem_cache *cache, void *object)
>>  {
>>  #ifdef CONFIG_SLAB
>> +       struct kasan_alloc_meta *alloc_info;
>> +       struct kasan_free_meta *free_info;
>> +
>>         /* RCU slabs could be legally used after free within the RCU period */
>>         if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
>>                 return false;
>>
>> -       if (likely(cache->flags & SLAB_KASAN)) {
>> -               struct kasan_alloc_meta *alloc_info =
>> -                       get_alloc_info(cache, object);
>> -               struct kasan_free_meta *free_info =
>> -                       get_free_info(cache, object);
>> -
>> -               switch (alloc_info->state) {
>> -               case KASAN_STATE_ALLOC:
>> -                       alloc_info->state = KASAN_STATE_QUARANTINE;
>> -                       quarantine_put(free_info, cache);
>> -                       set_track(&free_info->track, GFP_NOWAIT);
>> -                       kasan_poison_slab_free(cache, object);
>> -                       return true;
>> +       if (unlikely(!(cache->flags & SLAB_KASAN)))
>> +               return false;
>> +
>> +       alloc_info = get_alloc_info(cache, object);
>> +
>> +       if (cmpxchg(&alloc_info->state, KASAN_STATE_ALLOC,
>> +                               KASAN_STATE_QUARANTINE) == KASAN_STATE_ALLOC) {
>> +               free_info = get_free_info(cache, object);
>> +               quarantine_put(free_info, cache);
>> +               set_track(&free_info->track, GFP_NOWAIT);
>> +               kasan_poison_slab_free(cache, object);
>> +               return true;
>> +       }
>> +
>> +       switch (alloc_info->state) {
>>                 case KASAN_STATE_QUARANTINE:
>>                 case KASAN_STATE_FREE:
>>                         pr_err("Double free");
>> @@ -535,7 +540,6 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
>>                         break;
>>                 default:
>>                         break;
>> -               }
>>         }
>>         return false;
>>  #else
>> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
>> index 7da78a6..8c22a96 100644
>> --- a/mm/kasan/kasan.h
>> +++ b/mm/kasan/kasan.h
>> @@ -75,9 +75,8 @@ struct kasan_track {
>>
>>  struct kasan_alloc_meta {
>>         struct kasan_track track;
>> -       u32 state : 2;  /* enum kasan_state */
>> -       u32 alloc_size : 30;
>> -       u32 reserved;
>> +       u32 state;      /* enum kasan_state */
>> +       u32 alloc_size;
>>  };
>>
>>  struct kasan_free_meta {
>
>
> Hi Kuthonuzo,
>
> I agree that it's something we need to fix (user-space ASAN does
> something along these lines). My only concern is increase of
> kasan_alloc_meta size. It's unnecessary large already and we have a
> plan to reduce both alloc and free into to 16 bytes. However, it can
> make sense to land this and then reduce size of headers in a separate
> patch using a CAS-loop on state. Alexander, what's the state of your
> patches that reduce header size?


I missed that Alexander already landed patches that reduce header size
to 16 bytes.
It is not OK to increase them again. Please leave state as bitfield
and update it with CAS (if we introduce helper functions for state
manipulation, they will hide the CAS loop, which is nice).


> I think there is another race. If we have racing frees, one thread
> sets state to KASAN_STATE_QUARANTINE but does not fill
> free_info->track yet, at this point another thread does free and
> reports double-free, but the track is wrong so we will print a bogus
> stack. The same is true for all other state transitions (e.g.
> use-after-free racing with the object being pushed out of the
> quarantine).  We could introduce 2 helper functions like:
>
> /* Sets status to KASAN_STATE_LOCKED if the current status is equal to
> old_state, returns current state. Waits while current state equals
> KASAN_STATE_LOCKED. */
> u32 kasan_lock_if_state_equals(struct kasan_alloc_meta *meta, u32 old_state);
>
> /* Changes state from KASAN_STATE_LOCKED to new_state */
> void kasan_unlock_and_set_status(struct kasan_alloc_meta *meta, u32 new_state);
>
> Then free can be expressed as:
>
> if (kasan_lock_if_state_equals(meta, KASAN_STATE_ALLOC) == KASAN_STATE_ALLOC) {
>                free_info = get_free_info(cache, object);
>                quarantine_put(free_info, cache);
>                set_track(&free_info->track, GFP_NOWAIT);
>                kasan_poison_slab_free(cache, object);
>                kasan_unlock_and_set_status(meta, KASAN_STATE_QUARANTINE);
>                return true;
> }
>
> And on the reporting path we would need to lock the header, read all
> state, unlock the header.
>
> Does it make sense?
>
> Please add the test as well. We need to start collecting tests for all
> these tricky corner cases.
>
> Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
