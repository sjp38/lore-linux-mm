Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6EA6B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 07:55:31 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id m64so9033796lfd.1
        for <linux-mm@kvack.org>; Tue, 10 May 2016 04:55:30 -0700 (PDT)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id zk3si1289024lbb.7.2016.05.10.04.55.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 04:55:29 -0700 (PDT)
Received: by mail-lf0-x22e.google.com with SMTP id m64so11849880lfd.1
        for <linux-mm@kvack.org>; Tue, 10 May 2016 04:55:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <573085EB.5060808@virtuozzo.com>
References: <20160506114727.GA2571@cherokee.in.rdlabs.hpecorp.net>
 <573065BD.2020708@virtuozzo.com> <CACT4Y+aZyKg6ehTovDWkzw_vLQ=Td=FHh3OC6w6cOyNOrKPfTA@mail.gmail.com>
 <573085EB.5060808@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 10 May 2016 13:55:09 +0200
Message-ID: <CACT4Y+ZP=soaHzDt7JCe6ndsmgnhB+pWO+tGetRfSgaBbsQhqg@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm, kasan: improve double-free detection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, Alexander Potapenko <glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 9, 2016 at 2:43 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
>
> On 05/09/2016 01:31 PM, Dmitry Vyukov wrote:
>> On Mon, May 9, 2016 at 12:26 PM, Andrey Ryabinin
>> <aryabinin@virtuozzo.com> wrote:
>>>
>>> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
>>> index b3c122d..c2b0e51 100644
>>> --- a/mm/kasan/report.c
>>> +++ b/mm/kasan/report.c
>>> @@ -140,18 +140,12 @@ static void object_err(struct kmem_cache *cache, struct page *page,
>>>         pr_err("Object at %p, in cache %s\n", object, cache->name);
>>>         if (!(cache->flags & SLAB_KASAN))
>>>                 return;
>>> -       switch (alloc_info->state) {
>>> -       case KASAN_STATE_INIT:
>>> -               pr_err("Object not allocated yet\n");
>>> -               break;
>>> -       case KASAN_STATE_ALLOC:
>>> +       if (test_bit(KASAN_STATE_ALLOCATED, &alloc_info->state)) {
>>>                 pr_err("Object allocated with size %u bytes.\n",
>>>                        alloc_info->alloc_size);
>>>                 pr_err("Allocation:\n");
>>>                 print_track(&alloc_info->track);
>>
>> alloc_info->track is not necessary initialized when
>> KASAN_STATE_ALLOCATED is set.
>
> It should be initialized to something. If it's not initialized, than that object wasn't allocated.
> So this would be a *very* random pointer access. Also this would mean that ->state itself might be not initialized too.
> Anyway, we can't do much in such scenario since we can't trust any data.
> And I don't think that we should because very likely this will cause panic eventually.
>
>> Worse, it can be initialized to a wrong
>> stack.
>>
>
> Define "wrong stack" here.
>
> I assume that you are talking about race in the following scenario:
>
> ------
> Proccess A:                      Proccess B:
>
> p_A = kmalloc();
> /* use p_A */
> kfree(p_A);
>                                  p_A = kmalloc();
>                                       ....
>                                       set_bit(KASAN_STATE_ALLOCATED); //bit set, but stack is not saved yet.
> /* use after free p_A */
>
> if (test_bit(KASAN_STATE_ALLOCATED))
>         print_stack() // will print track from Proccess A
> -----
>
> So, would be the stack trace from A wrong in such situation? I don't think so.
> We could change ->state and save stack trace in the 'right' order with proper barriers,
> but would it prevent us from showing wrong stacktrace? - It wouldn't.
>
> Now, the only real problem with current code, is that we don't print free stack if we think that object is in
> allocated state. We should do this, because more information is always better, e.g. we might hit long-delayed use-after-free,
> in which case free stack would be useful (just like in scenario above).



If we report a use-after-free on an object, we need to print
allocation stack of that object and free object for that object. If we
report a double-free, we need to print allocation and free stacks for
the object. That's correct stacks. Everything else is wrong.

With your patch we don't print free stack on double-free. We can't
print free_info->track because it is not necessary initialized at that
point. We can't fix it by simply reversing order of stores of state
and track, because then there is a data race on track during
double-free.

I agree that if we have a use-after-free when the block is being
reused for another allocation, we can't always print the right stacks
(they are already overwritten for the new allocation). But we should
avoid printing non-matching malloc/free stacks and treating random
bytes as stack trace handle (both cases are possible with your patch).
If we print bogus info that does not make sense, we compromise trust
in the tool. Some developers postulate that a tool is totally broken
and stop looking at reports as soon as they notice any incorrect info.

Kuthonuzo's patch allows to always print matching malloc/free stacks,
never treat random bytes as stack handle and detect some cases when we
know we have stale information (due to block reuse). There well may be
ways to simplify and improve it, but it introduces and uses a
consistent discipline for header updates/reads that will be useful as
we go forward.

Re block size increase: it's not that is super big deal. But the
increase is completely unnecessary. I've checked /proc/slabinfo on my
non-instrumented machine, and most objects are exactly in 32/64-byte
objects consuming 80MB in total. We've just got rid of fat inlined
stack traces and refactored alloc/free info to occupy 16 bytes each.
Let's not start increasing them again on any occasion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
