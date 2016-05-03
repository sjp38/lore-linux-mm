Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 59CBF6B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 13:50:46 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so26481848wme.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 10:50:46 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id j124si288666wmg.99.2016.05.03.10.50.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 May 2016 10:50:45 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id g17so30145114wme.0
        for <linux-mm@kvack.org>; Tue, 03 May 2016 10:50:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20E775CA4D599049A25800DE5799F6DD1F61F2B7@G9W0752.americas.hpqcorp.net>
References: <20160502094920.GA3005@cherokee.in.rdlabs.hpecorp.net>
 <CACT4Y+YV4A_YbDq5asowLJPUODottNHAKScWoRdUx6uy+TN-Uw@mail.gmail.com>
 <20E775CA4D599049A25800DE5799F6DD1F61EF48@G9W0752.americas.hpqcorp.net>
 <CACT4Y+Y5n0u=qLA9A=89B07gMVRiQ+6nQaob2_rk_mOOt57iQw@mail.gmail.com> <20E775CA4D599049A25800DE5799F6DD1F61F2B7@G9W0752.americas.hpqcorp.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 3 May 2016 19:50:25 +0200
Message-ID: <CACT4Y+b9yo58kgkQR5JD+k5N-LNmEF-rPP8OGzoiKkzYUho6FQ@mail.gmail.com>
Subject: Re: [PATCH] kasan: improve double-free detection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, May 3, 2016 at 11:24 AM, Luruo, Kuthonuzo
<kuthonuzo.luruo@hpe.com> wrote:
>>
>> We can use per-header lock by setting status to KASAN_STATE_LOCKED.  A
>> thread can CAS any status to KASAN_STATE_LOCKED which means that it
>> locked the header. If any thread tried to modify/read the status and
>> the status is KASAN_STATE_LOCKED, then the thread waits.
>
> Thanks, Dmitry. I've successfully tested with the concurrent free slab_test test
> (alloc on cpu 0; then concurrent frees on all other cpus on a 12-vcpu KVM) using:
>
> static inline bool kasan_alloc_state_lock(struct kasan_alloc_meta *alloc_info)
> {
>         if (cmpxchg(&alloc_info->state, KASAN_STATE_ALLOC,
>                                 KASAN_STATE_LOCKED) == KASAN_STATE_ALLOC)
>                 return true;
>         return false;
> }
>
> static inline void kasan_alloc_state_unlock_wait(struct kasan_alloc_meta
>                 *alloc_info)
> {
>         while (alloc_info->state == KASAN_STATE_LOCKED)
>                 cpu_relax();
> }
>
> Race "winner" sets state to quarantine as the last step:
>
>         if (kasan_alloc_state_lock(alloc_info)) {
>                 free_info = get_free_info(cache, object);
>                 quarantine_put(free_info, cache);
>                 set_track(&free_info->track, GFP_NOWAIT);
>                 kasan_poison_slab_free(cache, object);
>                 alloc_info->state = KASAN_STATE_QUARANTINE;
>                 return true;
>         } else
>                 kasan_alloc_state_unlock_wait(alloc_info);
>
> Now, I'm not sure whether on current KASAN-supported archs, state byte load in
> the busy-wait loop is atomic wrt the KASAN_STATE_QUARANTINE byte store.
> Would you advise using CAS primitives for load/store here too?

Store to state needs to use smp_store_release function, otherwise
stores to free_info->track can sink below the store to state.
Similarly, loads of state in kasan_alloc_state_unlock_wait need to use
smp_store_acquire.

A function similar to kasan_alloc_state_lock will also be needed for
KASAN_STATE_QUARANTINE -> KASAN_STATE_ALLOC state transition (when we
reuse the object). If a thread tried to report use-after-free when
another thread pushes the object out of quarantine and overwrites
alloc_info->track, the thread will print a bogus stack.

kasan_alloc_state_unlock_wait is not enough to prevent the races.
Consider that a thread executes kasan_alloc_state_unlock_wait and
proceeds to reporting, at this point another thread pushes the object
to quarantine or out of the quarantine and overwrites tracks. The
first thread will read inconsistent data from the header. Any thread
that reads/writes header needs to (1) wait while status is
KASAN_STATE_LOCKED, (2) CAS status to KASAN_STATE_LOCKED, (3)
read/write header, (4) restore/update status and effectively unlock
the header.
Alternatively, we can introduce LOCKED bit to header. Then it will be
simpler for readers to set/unset the bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
