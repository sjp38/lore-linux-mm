Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B14938E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 05:51:58 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id a18so13340229pga.16
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 02:51:58 -0800 (PST)
Received: from mail1.windriver.com (mail1.windriver.com. [147.11.146.13])
        by mx.google.com with ESMTPS id o32si13179338pld.407.2018.12.18.02.51.57
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Dec 2018 02:51:57 -0800 (PST)
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
 <20181123095314.hervxkxtqoixovro@linutronix.de>
 <40a63aa5-edb6-4673-b4cc-1bc10e7b3953@windriver.com>
 <20181130181956.eewrlaabtceekzyu@linutronix.de>
 <e7795912-7d93-8f4e-b997-67c4ac1f3549@windriver.com>
 <20181205191400.qrhim3m3ak5hcsuh@linutronix.de>
From: He Zhe <zhe.he@windriver.com>
Message-ID: <16ac893a-a080-18a5-e636-7b7668d978b0@windriver.com>
Date: Tue, 18 Dec 2018 18:51:41 +0800
MIME-Version: 1.0
In-Reply-To: <20181205191400.qrhim3m3ak5hcsuh@linutronix.de>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: catalin.marinas@arm.com, tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org



On 2018/12/6 03:14, Sebastian Andrzej Siewior wrote:
> On 2018-12-05 21:53:37 [+0800], He Zhe wrote:
>> For call trace 1:
> …
>> Since kmemleak would most likely be used to debug in environments where
>> we would not expect as great performance as without it, and kfree() has raw locks
>> in its main path and other debug function paths, I suppose it wouldn't hurt that
>> we change to raw locks.
> okay.
>
>>>> >From what I reached above, this is RT-only and happens on v4.18 and v4.19.
>>>>
>>>> The call trace above is caused by grabbing kmemleak_lock and then getting
>>>> scheduled and then re-grabbing kmemleak_lock. Using raw lock can also solve
>>>> this problem.
>>> But this is a reader / writer lock. And if I understand the other part
>>> of the thread then it needs multiple readers.
>> For call trace 2:
>>
>> I don't get what "it needs multiple readers" exactly means here.
>>
>> In this call trace, the kmemleak_lock is grabbed as write lock, and then scheduled
>> away, and then grabbed again as write lock from another path. It's a
>> write->write locking, compared to the discussion in the other part of the thread.
>>
>> This is essentially because kmemleak hooks on the very low level memory
>> allocation and free operations. After scheduled away, it can easily re-enter itself.
>> We need raw locks to prevent this from happening.
> With raw locks you wouldn't have multiple readers at the same time.
> Maybe you wouldn't have recursion but since you can't have multiple
> readers you would add lock contention where was none (because you could
> have two readers at the same time).

Sorry for slow reply.

OK. I understand your concern finally. At the commit log said, I wanted to use raw
rwlock but didn't find the DEFINE helper for it. Thinking it would not be expected to
have great performance, I turn to use raw spinlock instead. And yes, this would
introduce worse performance.

Maybe I miss the reason, but why don't we have rwlock_types_raw.h to define raw
rwlock helper for RT? With that, we can cleanly replace kmemleak_lock with a raw
rwlock.

Or should we just define a raw rwlock using basic type, like arch_rwlock_t, only in
kmemleak?

>
>>> Couldn't we just get rid of that kfree() or move it somewhere else?
>>> I mean if the free() memory on CPU-down and allocate it again CPU-up
>>> then we could skip that, rigth? Just allocate it and don't free it
>>> because the CPU will likely get up again.
>> For call trace 1:
>>
>> I went through the CPU hotplug code and found that the allocation of the
>> problematic data, cpuc->shared_regs, is done in intel_pmu_cpu_prepare. And
>> the free is done in intel_pmu_cpu_dying. They are handlers triggered by two
>> different perf events.
>>
>> It seems we can hardly form a convincing method that holds the data while
>> CPUs are off and then uses it again. raw locks would be easy and good enough.
> Why not allocate the memory in intel_pmu_cpu_prepare() if it is not
> already there (otherwise skip the allocation) and in
> intel_pmu_cpu_dying() not free it. It looks easy.

Thanks for your suggestion. I've sent the change for call trace 1 to mainline
mailing list. Hopefully it can be accepted.

Zhe

>
>> Thanks,
>> Zhe
> Sebastian
>
