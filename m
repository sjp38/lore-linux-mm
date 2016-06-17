Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 66A8C6B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 11:11:48 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s63so156738747ioi.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:11:48 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0127.outbound.protection.outlook.com. [157.55.234.127])
        by mx.google.com with ESMTPS id o31si14054441oik.58.2016.06.17.08.11.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 08:11:46 -0700 (PDT)
Subject: Re: [PATCH v3] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
References: <1466004364-57279-1-git-send-email-glider@google.com>
 <5761873A.2020104@virtuozzo.com>
 <CAG_fn=X8szV17tk+TBGXbKy881aNBeA=7F48_wD62LHYhjpvnw@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57641364.5000001@virtuozzo.com>
Date: Fri, 17 Jun 2016 18:12:36 +0300
MIME-Version: 1.0
In-Reply-To: <CAG_fn=X8szV17tk+TBGXbKy881aNBeA=7F48_wD62LHYhjpvnw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



On 06/17/2016 05:27 PM, Alexander Potapenko wrote:
> On Wed, Jun 15, 2016 at 6:50 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>>
>>
>> On 06/15/2016 06:26 PM, Alexander Potapenko wrote:
>>> For KASAN builds:
>>>  - switch SLUB allocator to using stackdepot instead of storing the
>>>    allocation/deallocation stacks in the objects;
>>>  - define SLAB_RED_ZONE, SLAB_POISON, SLAB_STORE_USER to zero,
>>>    effectively disabling these debug features, as they're redundant in
>>>    the presence of KASAN;
>>
>> So, why we forbid these? If user wants to set these, why not? If you don't want it, just don't turn them on, that's it.
> SLAB_RED_ZONE simply doesn't work with KASAN.

Why? This sounds like a bug.

> With additional efforts it may work, but I don't think we really need
> that. Extra red zones will just bloat the heap, and won't give any
> interesting signal except "someone corrupted this object from
> non-instrumented code".
> SLAB_POISON doesn't crash on simple tests, but I am not sure there are
> no corner cases which I haven't checked, so I thought it's safer to
> disable it.
> As I said before, we can make SLAB_STORE_USER use stackdepot in a
> later CL, thus we disable it now.
> 

This doesn't explain why we need this. What's the problem you are trying to solve by this? And why it is ok to silently ignore user requests?
You think that these options are redundant, I get it. Well, then just don't turn them on.
But, when a user requests for something, he expects that such request will be fulfilled, not just ignored.

>> And sometimes POISON/REDZONE might be actually useful. KASAN doesn't catch everything,
>> e.g. corruption may happen in assembly code, or DMA by  some device.
>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
