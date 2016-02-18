Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id DA3A9828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 10:01:13 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id g62so32109181wme.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 07:01:13 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id pb8si10895677wjb.141.2016.02.18.07.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 07:01:12 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id g62so29229908wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 07:01:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAmzW4N5YS3CMnXX-S1equRKw0BmbYeWrtp9kjRmDfPqzQ3esQ@mail.gmail.com>
References: <cover.1453918525.git.glider@google.com>
	<a6491b8dfc46299797e67436cc1541370e9439c9.1453918525.git.glider@google.com>
	<20160128074051.GA15426@js1304-P5Q-DELUXE>
	<CAG_fn=Uxk-Y2gVfrdLxPRFf2SQ+1VnoWNUorcDw4E18D0+NBWQ@mail.gmail.com>
	<CAG_fn=VetOrSwqseiRwCFVr-nTTemczMixbbafgEJdqDRB4p7Q@mail.gmail.com>
	<20160201025530.GD32125@js1304-P5Q-DELUXE>
	<CAG_fn=UwMgXJkgKhSa6Qsr_2jqQi8exZj7b8eoe+WK-_7aD5cA@mail.gmail.com>
	<CAG_fn=UGJG0a=Mu6-yjJSP25aoQNd9RduE-tvga-ceeAtgnaZQ@mail.gmail.com>
	<CAAmzW4N5YS3CMnXX-S1equRKw0BmbYeWrtp9kjRmDfPqzQ3esQ@mail.gmail.com>
Date: Thu, 18 Feb 2016 16:01:12 +0100
Message-ID: <CAG_fn=UV=42UQrmY9Sd4BTzX_bfFYwrN7pdBPNZKgDvu5nvbGg@mail.gmail.com>
Subject: Re: [PATCH v1 5/8] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, kasan-dev@googlegroups.com, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>

On Thu, Feb 18, 2016 at 9:13 AM, Joonsoo Kim <js1304@gmail.com> wrote:
> 2016-02-18 3:29 GMT+09:00 Alexander Potapenko <glider@google.com>:
>> On Tue, Feb 16, 2016 at 7:37 PM, Alexander Potapenko <glider@google.com>=
 wrote:
>>> On Mon, Feb 1, 2016 at 3:55 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wr=
ote:
>>>> On Thu, Jan 28, 2016 at 02:27:44PM +0100, Alexander Potapenko wrote:
>>>>> On Thu, Jan 28, 2016 at 1:51 PM, Alexander Potapenko <glider@google.c=
om> wrote:
>>>>> >
>>>>> > On Jan 28, 2016 8:40 AM, "Joonsoo Kim" <iamjoonsoo.kim@lge.com> wro=
te:
>>>>> >>
>>>>> >> Hello,
>>>>> >>
>>>>> >> On Wed, Jan 27, 2016 at 07:25:10PM +0100, Alexander Potapenko wrot=
e:
>>>>> >> > Stack depot will allow KASAN store allocation/deallocation stack=
 traces
>>>>> >> > for memory chunks. The stack traces are stored in a hash table a=
nd
>>>>> >> > referenced by handles which reside in the kasan_alloc_meta and
>>>>> >> > kasan_free_meta structures in the allocated memory chunks.
>>>>> >>
>>>>> >> Looks really nice!
>>>>> >>
>>>>> >> Could it be more generalized to be used by other feature that need=
 to
>>>>> >> store stack trace such as tracepoint or page owner?
>>>>> > Certainly yes, but see below.
>>>>> >
>>>>> >> If it could be, there is one more requirement.
>>>>> >> I understand the fact that entry is never removed from depot makes=
 things
>>>>> >> very simpler, but, for general usecases, it's better to use refere=
nce
>>>>> >> count
>>>>> >> and allow to remove. Is it possible?
>>>>> > For our use case reference counting is not really necessary, and it=
 would
>>>>> > introduce unwanted contention.
>>>>
>>>> Okay.
>>>>
>>>>> > There are two possible options, each having its advantages and draw=
backs: we
>>>>> > can let the clients store the refcounters directly in their stacks =
(more
>>>>> > universal, but harder to use for the clients), or keep the counters=
 in the
>>>>> > depot but add an API that does not change them (easier for the clie=
nts, but
>>>>> > potentially error-prone).
>>>>> > I'd say it's better to actually find at least one more user for the=
 stack
>>>>> > depot in order to understand the requirements, and refactor the cod=
e after
>>>>> > that.
>>>>
>>>> I re-think the page owner case and it also may not need refcount.
>>>> For now, just moving this stuff to /lib would be helpful for other fut=
ure user.
>>> I agree this code may need to be moved to /lib someday, but I wouldn't
>>> hurry with that.
>>> Right now it is quite KASAN-specific, and it's unclear yet whether
>>> anyone else is going to use it.
>>> I suggest we keep it in mm/kasan for now, and factor the common parts
>>> into /lib when the need arises.
>>>
>>>> BTW, is there any performance number? I guess that it could affect
>>>> the performance.
>>> I've compared the performance of KASAN with SLAB allocator on a small
>>> synthetic benchmark in two modes: with stack depot enabled and with
>>> kasan_save_stack() unconditionally returning 0.
>>> In the former case 8% more time was spent in the kernel than in the lat=
ter case.
>>>
>>> If I am not mistaking, for SLUB allocator the bookkeeping (enabled
>>> with the slub_debug=3DUZ boot options) take only 1.5 time, so the
>>> difference is worth looking into (at least before we switch SLUB to
>>> stack depot).
>>
>> I've made additional measurements.
>> Previously I had been using a userspace benchmark that created and
>> destroyed pipes in a loop
>> (https://github.com/google/sanitizers/blob/master/address-sanitizer/kern=
el_buildbot/slave/bench_pipes.c).
>>
>> Now I've made a kernel module that allocated and deallocated memory
>> chunks of different sizes in a loop.
>> There were two modes of operation:
>> 1) all the allocations were made from the same function, therefore all
>> allocation/deallocation stacks were similar and there always was a hit
>> in the stackdepot hashtable
>> 2) The allocations were made from 2^16 different stacks.
>>
>> In the first case SLAB+stackdepot turned out to be 13% faster than
>> SLUB+slub_debug, in the second SLAB was 11% faster.
>
> I don't know what version of kernel you tested but, until recently,
> slub_debug=3DUZ has a side effect not to using fastpath of SLUB. So,
> comparison between them isn't appropriate. Today's linux-next branch
> would have some improvements on this area so use it to compare them.
>
That's good to know.
I've been using https://github.com/torvalds/linux.git, which probably
didn't have those improvements.

>> Note that in both cases and for both allocators most of the time (more
>> than 90%) was spent in the x86 stack unwinder, which is common for
>> both approaches.
>
> If more than 90% time is spent in stack unwinder which is common for
> both cases, how something is better than the other by 13%?
On the second glance, this number (90%) may be inaccurate, because I
measured the stack unwinding times separately, which could have
introduced deviation (not to mention it was incorrect for SLUB).
Yet we're talking about a significant amount of time spent in the unwinder.
My numbers were 26.111 seconds for 1024K SLAB allocation/deallocation
pairs and 30.278 seconds for 1024K alloc/dealloc pairs with SLUB.
When measured separately in the same routine that did the allocations,
2048K calls to save_stack_trace() took 25.487 seconds.

>> Yet another observation regarding stackdepot: under a heavy load
>> (running Trinity for a hour, 101M allocations) the depot saturates at
>> around 20K records with the hashtable miss rate of 0.02%.
>> That said, I still cannot justify the results of the userspace
>> benchmark, but the slowdown of the stackdepot approach for SLAB sounds
>> acceptable, especially given the memory gain compared to SLUB
>> bookkeeping (which requires 128 bytes per memory allocation) and the
>> fact we'll be dealing with the fast path most of the time.
>
> In fact, I don't have much concern about performance because saving
> memory has enough merit to be merged. Anyway, it looks acceptable
> even for performance.
>
>> It will certainly be nice to compare SLUB+slub_debug to
>> SLUB+stackdepot once we start switching SLUB to stackdepot.
>
> Okay.
>
> Thanks.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat sind,
leiten Sie diese bitte nicht weiter, informieren Sie den
Absender und l=C3=B6schen Sie die E-Mail und alle Anh=C3=A4nge. Vielen Dank=
.
This e-mail is confidential. If you are not the right addressee please
do not forward it, please inform the sender, and please erase this
e-mail including any attachments. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
