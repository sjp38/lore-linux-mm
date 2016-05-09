Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE016B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 08:43:32 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id i75so412515638ioa.3
        for <linux-mm@kvack.org>; Mon, 09 May 2016 05:43:32 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0113.outbound.protection.outlook.com. [157.56.112.113])
        by mx.google.com with ESMTPS id v53si12064831otv.211.2016.05.09.05.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 May 2016 05:43:31 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm, kasan: improve double-free detection
References: <20160506114727.GA2571@cherokee.in.rdlabs.hpecorp.net>
 <573065BD.2020708@virtuozzo.com>
 <CACT4Y+aZyKg6ehTovDWkzw_vLQ=Td=FHh3OC6w6cOyNOrKPfTA@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <573085EB.5060808@virtuozzo.com>
Date: Mon, 9 May 2016 15:43:23 +0300
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aZyKg6ehTovDWkzw_vLQ=Td=FHh3OC6w6cOyNOrKPfTA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, Alexander Potapenko <glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 05/09/2016 01:31 PM, Dmitry Vyukov wrote:
> On Mon, May 9, 2016 at 12:26 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>>
>> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
>> index b3c122d..c2b0e51 100644
>> --- a/mm/kasan/report.c
>> +++ b/mm/kasan/report.c
>> @@ -140,18 +140,12 @@ static void object_err(struct kmem_cache *cache, struct page *page,
>>         pr_err("Object at %p, in cache %s\n", object, cache->name);
>>         if (!(cache->flags & SLAB_KASAN))
>>                 return;
>> -       switch (alloc_info->state) {
>> -       case KASAN_STATE_INIT:
>> -               pr_err("Object not allocated yet\n");
>> -               break;
>> -       case KASAN_STATE_ALLOC:
>> +       if (test_bit(KASAN_STATE_ALLOCATED, &alloc_info->state)) {
>>                 pr_err("Object allocated with size %u bytes.\n",
>>                        alloc_info->alloc_size);
>>                 pr_err("Allocation:\n");
>>                 print_track(&alloc_info->track);
> 
> alloc_info->track is not necessary initialized when
> KASAN_STATE_ALLOCATED is set.

It should be initialized to something. If it's not initialized, than that object wasn't allocated.
So this would be a *very* random pointer access. Also this would mean that ->state itself might be not initialized too.
Anyway, we can't do much in such scenario since we can't trust any data.
And I don't think that we should because very likely this will cause panic eventually.

> Worse, it can be initialized to a wrong
> stack.
> 

Define "wrong stack" here.

I assume that you are talking about race in the following scenario:

------
Proccess A:                      Proccess B:

p_A = kmalloc();
/* use p_A */
kfree(p_A);
                                 p_A = kmalloc();
                                      ....
                                      set_bit(KASAN_STATE_ALLOCATED); //bit set, but stack is not saved yet.
/* use after free p_A */

if (test_bit(KASAN_STATE_ALLOCATED))
        print_stack() // will print track from Proccess A
-----

So, would be the stack trace from A wrong in such situation? I don't think so.
We could change ->state and save stack trace in the 'right' order with proper barriers,
but would it prevent us from showing wrong stacktrace? - It wouldn't.

Now, the only real problem with current code, is that we don't print free stack if we think that object is in
allocated state. We should do this, because more information is always better, e.g. we might hit long-delayed use-after-free,
in which case free stack would be useful (just like in scenario above).




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
