Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 46815828DF
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 03:13:37 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id jq7so55180109obb.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 00:13:37 -0800 (PST)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id xw4si7618866oec.89.2016.02.18.00.13.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 00:13:36 -0800 (PST)
Received: by mail-ob0-x231.google.com with SMTP id wb13so55661569obb.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 00:13:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=UGJG0a=Mu6-yjJSP25aoQNd9RduE-tvga-ceeAtgnaZQ@mail.gmail.com>
References: <cover.1453918525.git.glider@google.com>
	<a6491b8dfc46299797e67436cc1541370e9439c9.1453918525.git.glider@google.com>
	<20160128074051.GA15426@js1304-P5Q-DELUXE>
	<CAG_fn=Uxk-Y2gVfrdLxPRFf2SQ+1VnoWNUorcDw4E18D0+NBWQ@mail.gmail.com>
	<CAG_fn=VetOrSwqseiRwCFVr-nTTemczMixbbafgEJdqDRB4p7Q@mail.gmail.com>
	<20160201025530.GD32125@js1304-P5Q-DELUXE>
	<CAG_fn=UwMgXJkgKhSa6Qsr_2jqQi8exZj7b8eoe+WK-_7aD5cA@mail.gmail.com>
	<CAG_fn=UGJG0a=Mu6-yjJSP25aoQNd9RduE-tvga-ceeAtgnaZQ@mail.gmail.com>
Date: Thu, 18 Feb 2016 17:13:36 +0900
Message-ID: <CAAmzW4N5YS3CMnXX-S1equRKw0BmbYeWrtp9kjRmDfPqzQ3esQ@mail.gmail.com>
Subject: Re: [PATCH v1 5/8] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, kasan-dev@googlegroups.com, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>

2016-02-18 3:29 GMT+09:00 Alexander Potapenko <glider@google.com>:
> On Tue, Feb 16, 2016 at 7:37 PM, Alexander Potapenko <glider@google.com> wrote:
>> On Mon, Feb 1, 2016 at 3:55 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>>> On Thu, Jan 28, 2016 at 02:27:44PM +0100, Alexander Potapenko wrote:
>>>> On Thu, Jan 28, 2016 at 1:51 PM, Alexander Potapenko <glider@google.com> wrote:
>>>> >
>>>> > On Jan 28, 2016 8:40 AM, "Joonsoo Kim" <iamjoonsoo.kim@lge.com> wrote:
>>>> >>
>>>> >> Hello,
>>>> >>
>>>> >> On Wed, Jan 27, 2016 at 07:25:10PM +0100, Alexander Potapenko wrote:
>>>> >> > Stack depot will allow KASAN store allocation/deallocation stack traces
>>>> >> > for memory chunks. The stack traces are stored in a hash table and
>>>> >> > referenced by handles which reside in the kasan_alloc_meta and
>>>> >> > kasan_free_meta structures in the allocated memory chunks.
>>>> >>
>>>> >> Looks really nice!
>>>> >>
>>>> >> Could it be more generalized to be used by other feature that need to
>>>> >> store stack trace such as tracepoint or page owner?
>>>> > Certainly yes, but see below.
>>>> >
>>>> >> If it could be, there is one more requirement.
>>>> >> I understand the fact that entry is never removed from depot makes things
>>>> >> very simpler, but, for general usecases, it's better to use reference
>>>> >> count
>>>> >> and allow to remove. Is it possible?
>>>> > For our use case reference counting is not really necessary, and it would
>>>> > introduce unwanted contention.
>>>
>>> Okay.
>>>
>>>> > There are two possible options, each having its advantages and drawbacks: we
>>>> > can let the clients store the refcounters directly in their stacks (more
>>>> > universal, but harder to use for the clients), or keep the counters in the
>>>> > depot but add an API that does not change them (easier for the clients, but
>>>> > potentially error-prone).
>>>> > I'd say it's better to actually find at least one more user for the stack
>>>> > depot in order to understand the requirements, and refactor the code after
>>>> > that.
>>>
>>> I re-think the page owner case and it also may not need refcount.
>>> For now, just moving this stuff to /lib would be helpful for other future user.
>> I agree this code may need to be moved to /lib someday, but I wouldn't
>> hurry with that.
>> Right now it is quite KASAN-specific, and it's unclear yet whether
>> anyone else is going to use it.
>> I suggest we keep it in mm/kasan for now, and factor the common parts
>> into /lib when the need arises.
>>
>>> BTW, is there any performance number? I guess that it could affect
>>> the performance.
>> I've compared the performance of KASAN with SLAB allocator on a small
>> synthetic benchmark in two modes: with stack depot enabled and with
>> kasan_save_stack() unconditionally returning 0.
>> In the former case 8% more time was spent in the kernel than in the latter case.
>>
>> If I am not mistaking, for SLUB allocator the bookkeeping (enabled
>> with the slub_debug=UZ boot options) take only 1.5 time, so the
>> difference is worth looking into (at least before we switch SLUB to
>> stack depot).
>
> I've made additional measurements.
> Previously I had been using a userspace benchmark that created and
> destroyed pipes in a loop
> (https://github.com/google/sanitizers/blob/master/address-sanitizer/kernel_buildbot/slave/bench_pipes.c).
>
> Now I've made a kernel module that allocated and deallocated memory
> chunks of different sizes in a loop.
> There were two modes of operation:
> 1) all the allocations were made from the same function, therefore all
> allocation/deallocation stacks were similar and there always was a hit
> in the stackdepot hashtable
> 2) The allocations were made from 2^16 different stacks.
>
> In the first case SLAB+stackdepot turned out to be 13% faster than
> SLUB+slub_debug, in the second SLAB was 11% faster.

I don't know what version of kernel you tested but, until recently,
slub_debug=UZ has a side effect not to using fastpath of SLUB. So,
comparison between them isn't appropriate. Today's linux-next branch
would have some improvements on this area so use it to compare them.

> Note that in both cases and for both allocators most of the time (more
> than 90%) was spent in the x86 stack unwinder, which is common for
> both approaches.

If more than 90% time is spent in stack unwinder which is common for
both cases, how something is better than the other by 13%?

> Yet another observation regarding stackdepot: under a heavy load
> (running Trinity for a hour, 101M allocations) the depot saturates at
> around 20K records with the hashtable miss rate of 0.02%.
> That said, I still cannot justify the results of the userspace
> benchmark, but the slowdown of the stackdepot approach for SLAB sounds
> acceptable, especially given the memory gain compared to SLUB
> bookkeeping (which requires 128 bytes per memory allocation) and the
> fact we'll be dealing with the fast path most of the time.

In fact, I don't have much concern about performance because saving
memory has enough merit to be merged. Anyway, it looks acceptable
even for performance.

> It will certainly be nice to compare SLUB+slub_debug to
> SLUB+stackdepot once we start switching SLUB to stackdepot.

Okay.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
