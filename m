Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB746B025E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 07:35:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so74543559wme.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 04:35:55 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id d65si20472173wme.62.2016.05.02.04.35.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 04:35:54 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id g17so137513173wme.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 04:35:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20E775CA4D599049A25800DE5799F6DD1F61EF48@G9W0752.americas.hpqcorp.net>
References: <20160502094920.GA3005@cherokee.in.rdlabs.hpecorp.net>
 <CACT4Y+YV4A_YbDq5asowLJPUODottNHAKScWoRdUx6uy+TN-Uw@mail.gmail.com> <20E775CA4D599049A25800DE5799F6DD1F61EF48@G9W0752.americas.hpqcorp.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 2 May 2016 13:35:34 +0200
Message-ID: <CACT4Y+Y5n0u=qLA9A=89B07gMVRiQ+6nQaob2_rk_mOOt57iQw@mail.gmail.com>
Subject: Re: [PATCH] kasan: improve double-free detection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 2, 2016 at 1:30 PM, Luruo, Kuthonuzo
<kuthonuzo.luruo@hpe.com> wrote:
> Hi Dmitry,
>
> Thanks very much for your response/review.
>
>> I agree that it's something we need to fix (user-space ASAN does
>> something along these lines). My only concern is increase of
>> kasan_alloc_meta size. It's unnecessary large already and we have a
>> plan to reduce both alloc and free into to 16 bytes. However, it can
>> make sense to land this and then reduce size of headers in a separate
>> patch using a CAS-loop on state.
>
> ok.
>
>>  Alexander, what's the state of your
>> patches that reduce header size?
>>
>> I think there is another race. If we have racing frees, one thread
>> sets state to KASAN_STATE_QUARANTINE but does not fill
>> free_info->track yet, at this point another thread does free and
>> reports double-free, but the track is wrong so we will print a bogus
>> stack. The same is true for all other state transitions (e.g.
>> use-after-free racing with the object being pushed out of the
>> quarantine).
>
> Yes, I've noticed this too. For the double-free, in my local tests, the error
> reports from the bad frees get printed only after the successful "good"
> free set the new track info. But then, I was using kasan_report() on the
> error path to get sane reports from the multiple concurrent frees so that
> may have "slowed" down the error paths enough until the good free was
> done. Agreed, the window still exists for a stale (or missing) deallocation
> stack in error report.
>
>>  We could introduce 2 helper functions like:
>>
>> /* Sets status to KASAN_STATE_LOCKED if the current status is equal to
>> old_state, returns current state. Waits while current state equals
>> KASAN_STATE_LOCKED. */
>> u32 kasan_lock_if_state_equals(struct kasan_alloc_meta *meta, u32 old_state);
>>
>> /* Changes state from KASAN_STATE_LOCKED to new_state */
>> void kasan_unlock_and_set_status(struct kasan_alloc_meta *meta, u32
>> new_state);
>>
>> Then free can be expressed as:
>>
>> if (kasan_lock_if_state_equals(meta, KASAN_STATE_ALLOC) ==
>> KASAN_STATE_ALLOC) {
>>                free_info = get_free_info(cache, object);
>>                quarantine_put(free_info, cache);
>>                set_track(&free_info->track, GFP_NOWAIT);
>>                kasan_poison_slab_free(cache, object);
>>                kasan_unlock_and_set_status(meta, KASAN_STATE_QUARANTINE);
>>                return true;
>> }
>>
>> And on the reporting path we would need to lock the header, read all
>> state, unlock the header.
>>
>> Does it make sense?
>
> It does, thanks! I'll try to hack up something, though right now, it's not entirely
> clear to me how to achieve this without resorting to a global lock (which would
> be unacceptable).


We can use per-header lock by setting status to KASAN_STATE_LOCKED.  A
thread can CAS any status to KASAN_STATE_LOCKED which means that it
locked the header. If any thread tried to modify/read the status and
the status is KASAN_STATE_LOCKED, then the thread waits.


>> Please add the test as well. We need to start collecting tests for all
>> these tricky corner cases.
>
> Sure, a new test can be added for test_kasan.ko. Unlike the other tests, a
> double-free would likely panic the system due to slab corruption. Would it still
> be "KASANic" for kasan_slab_free() to return true after reporting double-free
> attempt error so thread will not call into __cache_free()? How does ASAN
> handle this?

Yes, sure, it is OK to return true from kasan_slab_free() in such case.
Use-space ASAN terminates the process after the first report. We've
decided that in kernel we better continue in best-effort manner. But
after the first report all bets are mostly off (leaking an object is
definitely OK).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
