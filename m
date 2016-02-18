Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 48C9B6B0255
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 02:58:50 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id gc3so54023774obb.3
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 23:58:50 -0800 (PST)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com. [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id mr2si7555362obb.80.2016.02.17.23.58.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 23:58:49 -0800 (PST)
Received: by mail-ob0-x235.google.com with SMTP id xk3so55001903obc.2
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 23:58:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=UwMgXJkgKhSa6Qsr_2jqQi8exZj7b8eoe+WK-_7aD5cA@mail.gmail.com>
References: <cover.1453918525.git.glider@google.com>
	<a6491b8dfc46299797e67436cc1541370e9439c9.1453918525.git.glider@google.com>
	<20160128074051.GA15426@js1304-P5Q-DELUXE>
	<CAG_fn=Uxk-Y2gVfrdLxPRFf2SQ+1VnoWNUorcDw4E18D0+NBWQ@mail.gmail.com>
	<CAG_fn=VetOrSwqseiRwCFVr-nTTemczMixbbafgEJdqDRB4p7Q@mail.gmail.com>
	<20160201025530.GD32125@js1304-P5Q-DELUXE>
	<CAG_fn=UwMgXJkgKhSa6Qsr_2jqQi8exZj7b8eoe+WK-_7aD5cA@mail.gmail.com>
Date: Thu, 18 Feb 2016 16:58:49 +0900
Message-ID: <CAAmzW4O9kLzzdj5mfSEJHmCVj=0-BqJ_jHqF5bH6vaggaE=FJg@mail.gmail.com>
Subject: Re: [PATCH v1 5/8] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, kasan-dev@googlegroups.com, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>

2016-02-17 3:37 GMT+09:00 Alexander Potapenko <glider@google.com>:
> On Mon, Feb 1, 2016 at 3:55 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>> On Thu, Jan 28, 2016 at 02:27:44PM +0100, Alexander Potapenko wrote:
>>> On Thu, Jan 28, 2016 at 1:51 PM, Alexander Potapenko <glider@google.com> wrote:
>>> >
>>> > On Jan 28, 2016 8:40 AM, "Joonsoo Kim" <iamjoonsoo.kim@lge.com> wrote:
>>> >>
>>> >> Hello,
>>> >>
>>> >> On Wed, Jan 27, 2016 at 07:25:10PM +0100, Alexander Potapenko wrote:
>>> >> > Stack depot will allow KASAN store allocation/deallocation stack traces
>>> >> > for memory chunks. The stack traces are stored in a hash table and
>>> >> > referenced by handles which reside in the kasan_alloc_meta and
>>> >> > kasan_free_meta structures in the allocated memory chunks.
>>> >>
>>> >> Looks really nice!
>>> >>
>>> >> Could it be more generalized to be used by other feature that need to
>>> >> store stack trace such as tracepoint or page owner?
>>> > Certainly yes, but see below.
>>> >
>>> >> If it could be, there is one more requirement.
>>> >> I understand the fact that entry is never removed from depot makes things
>>> >> very simpler, but, for general usecases, it's better to use reference
>>> >> count
>>> >> and allow to remove. Is it possible?
>>> > For our use case reference counting is not really necessary, and it would
>>> > introduce unwanted contention.
>>
>> Okay.
>>
>>> > There are two possible options, each having its advantages and drawbacks: we
>>> > can let the clients store the refcounters directly in their stacks (more
>>> > universal, but harder to use for the clients), or keep the counters in the
>>> > depot but add an API that does not change them (easier for the clients, but
>>> > potentially error-prone).
>>> > I'd say it's better to actually find at least one more user for the stack
>>> > depot in order to understand the requirements, and refactor the code after
>>> > that.
>>
>> I re-think the page owner case and it also may not need refcount.
>> For now, just moving this stuff to /lib would be helpful for other future user.
> I agree this code may need to be moved to /lib someday, but I wouldn't
> hurry with that.
> Right now it is quite KASAN-specific, and it's unclear yet whether
> anyone else is going to use it.
> I suggest we keep it in mm/kasan for now, and factor the common parts
> into /lib when the need arises.

Please consider it one more time. I really have a plan to use it on page owner,
because using page owner requires too many memory for stack trace and
it changes system behaviour a lot.

Page owner uses following structure to store stack trace.

struct page_ext {
        unsigned long flags;
#ifdef CONFIG_PAGE_OWNER
        unsigned int order;
        gfp_t gfp_mask;
        unsigned int nr_entries;
        int last_migrate_reason;
        unsigned long trace_entries[8];
#endif
};

Using stack depot in page owner would be straight forward if stack depot
is in /lib. It is possible to move it when needed but it requires moving
a file and it would not be desirable.

>> BTW, is there any performance number? I guess that it could affect
>> the performance.
> I've compared the performance of KASAN with SLAB allocator on a small
> synthetic benchmark in two modes: with stack depot enabled and with
> kasan_save_stack() unconditionally returning 0.
> In the former case 8% more time was spent in the kernel than in the latter case.
>
> If I am not mistaking, for SLUB allocator the bookkeeping (enabled
> with the slub_debug=UZ boot options) take only 1.5 time, so the
> difference is worth looking into (at least before we switch SLUB to
> stack depot).

Okay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
