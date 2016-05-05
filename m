Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 62D566B007E
	for <linux-mm@kvack.org>; Thu,  5 May 2016 01:34:25 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 68so5803810lfq.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 22:34:25 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id gk7si9353101wjb.5.2016.05.04.22.34.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 22:34:24 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id g17so9103219wme.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 22:34:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20E775CA4D599049A25800DE5799F6DD1F624B08@G4W3225.americas.hpqcorp.net>
References: <20160502094920.GA3005@cherokee.in.rdlabs.hpecorp.net>
 <CACT4Y+YV4A_YbDq5asowLJPUODottNHAKScWoRdUx6uy+TN-Uw@mail.gmail.com>
 <CACT4Y+Z_+crRUm0U89YwW3x99dtx9cfPoO+L6mD-uyzfZAMkKw@mail.gmail.com>
 <20E775CA4D599049A25800DE5799F6DD1F61F1B2@G9W0752.americas.hpqcorp.net>
 <CACT4Y+azLKpGXSqs2=7PKZLNHd61LN7FiAQeWLhw3yApVHadXQ@mail.gmail.com> <20E775CA4D599049A25800DE5799F6DD1F624B08@G4W3225.americas.hpqcorp.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 5 May 2016 07:34:03 +0200
Message-ID: <CACT4Y+bow7r43x=OR+1tyn7p_eMDKuAfH+LG1uROU2+Lc45Ctg@mail.gmail.com>
Subject: Re: [PATCH] kasan: improve double-free detection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 4, 2016 at 10:13 PM, Luruo, Kuthonuzo
<kuthonuzo.luruo@hpe.com> wrote:
>> >> I missed that Alexander already landed patches that reduce header size
>> >> to 16 bytes.
>> >> It is not OK to increase them again. Please leave state as bitfield
>> >> and update it with CAS (if we introduce helper functions for state
>> >> manipulation, they will hide the CAS loop, which is nice).
>> >>
>> >
>> > Available CAS primitives/compiler do not support CAS with bitfield. I propose
>> > to change kasan_alloc_meta to:
>> >
>> > struct kasan_alloc_meta {
>> >         struct kasan_track track;
>> >         u16 size_delta;         /* object_size - alloc size */
>> >         u8 state;                    /* enum kasan_state */
>> >         u8 reserved1;
>> >         u32 reserved2;
>> > }
>> >
>> > This shrinks _used_ meta object by 1 byte wrt the original. (btw, patch v1 does
>> > not increase overall alloc meta object size). "Alloc size", where needed, is
>> > easily calculated as a delta from cache->object_size.
>>
>>
>> What is the maximum size that slab can allocate?
>> I remember seeing slabs as large as 4MB some time ago (or did I
>> confuse it with something else?). If there are such large objects,
>> that 2 bytes won't be able to hold even delta.
>> However, now on my desktop I don't see slabs larger than 16KB in
>> /proc/slabinfo.
>
> max size for SLAB's slab is 32MB; default is 4MB. I must have gotten confused by
> SLUB's 8KB limit. Anyway, new kasan_alloc_meta in patch V2:
>
> struct kasan_alloc_meta {
>         struct kasan_track track;
>         union {
>                 u8 lock;
>                 struct {
>                         u32 dummy : 8;
>                         u32 size_delta : 24;    /* object_size - alloc size */
>                 };
>         };
>         u32 state : 2;                          /* enum kasan_alloc_state */
>         u32 unused : 30;
> };
>
> This uses 2 more bits than current, but given the constraints I think this is
> close to optimal.


We plan to use the unused part for another depot_stack_handle_t (u32)
to memorize stack of the last call_rcu on the object (this will
greatly simplify debugging of use-after-free for objects freed by
rcu). So we need that unused part.

I would would simply put all these fields into a single u32:

struct kasan_alloc_meta {
        struct kasan_track track;
        u32 status;  // contains lock, state and size
        u32 unused;  // reserved for call_rcu stack handle
};

And then separately a helper type to pack/unpack status:

union kasan_alloc_status {
        u32 raw;
        struct {
                   u32 lock : 1;
                   u32 state : 2;
                   u32 unused : 5;
                   u32 size : 24;
        };
};


Then, when we need to read/update the header we do something like:

kasan_alloc_status status, new_status;

for (;;) {
    status.raw = READ_ONCE(header->status);
    // read status, form new_status, for example:
    if (status.lock)
          continue;
    new_status.raw = status.raw;
    new_status.lock = 1;
    if (cas(&header->status, status.raw, new_status.raw))
             break;
}


This will probably make state manipulation functions few lines longer,
but since there are like 3 such functions I don't afraid that. And we
still can use bitfield magic to extract fields and leave whole 5 bits
unused bits for future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
