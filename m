Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id CEF696B74A4
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 08:55:04 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id h10so14900719plk.12
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 05:55:04 -0800 (PST)
Received: from mail5.wrs.com (mail5.windriver.com. [192.103.53.11])
        by mx.google.com with ESMTPS id i198si21274789pfe.289.2018.12.05.05.55.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 05:55:03 -0800 (PST)
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
 <20181123095314.hervxkxtqoixovro@linutronix.de>
 <40a63aa5-edb6-4673-b4cc-1bc10e7b3953@windriver.com>
 <20181130181956.eewrlaabtceekzyu@linutronix.de>
From: He Zhe <zhe.he@windriver.com>
Message-ID: <e7795912-7d93-8f4e-b997-67c4ac1f3549@windriver.com>
Date: Wed, 5 Dec 2018 21:53:37 +0800
MIME-Version: 1.0
In-Reply-To: <20181130181956.eewrlaabtceekzyu@linutronix.de>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: catalin.marinas@arm.com, tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org



On 2018/12/1 02:19, Sebastian Andrzej Siewior wrote:
> On 2018-11-24 22:26:46 [+0800], He Zhe wrote:
>> On latest v4.19.1-rt3, both of the call traces can be reproduced with kmemleak
>> enabied. And none can be reproduced with kmemleak disabled.
> okay. So it needs attention.
>
>> On latest mainline tree, none can be reproduced no matter kmemleak is enabled
>> or disabled.
>>
>> I don't get why kfree from a preempt-disabled section should cause a warning
>> without kmemleak, since kfree can't sleep.
> it might. It will acquire a sleeping lock if it has go down to the
> memory allocator to actually give memory back.

Got it. Thanks.

>
>> If I understand correctly, the call trace above is caused by trying to schedule
>> after preemption is disabled, which cannot be reached in mainline kernel. So
>> we might need to turn to use raw lock to keep preemption disabled.
> The buddy-allocator runs with spin locks so it is okay on !RT. So you
> can use kfree() with disabled preemption or disabled interrupts.
> I don't think that we want to use raw-locks in the buddy-allocator.

For call trace 1:

I went through the calling paths inside kfree() and found that there have already
been things using raw lock in it as follow.

1) in the path of kfree() itself
kfree -> slab_free -> do_slab_free -> __slab_free -> raw_spin_lock_irqsave

2) in the path of CONFIG_DEBUG_OBJECTS_FREE
kfree -> slab_free -> slab_free_freelist_hook -> slab_free_hook -> debug_check_no_obj_freed -> __debug_check_no_obj_freed -> raw_spin_lock_irqsave

3) in the path of CONFIG_LOCKDEP
kfree -> __free_pages -> free_unref_page -> free_unref_page_prepare -> free_pcp_prepare -> free_pages_prepare -> debug_check_no_locks_freed -> debug_check_no_locks_freed -> raw_local_irq_save

Since kmemleak would most likely be used to debug in environments where
we would not expect as great performance as without it, and kfree() has raw locks
in its main path and other debug function paths, I suppose it wouldn't hurt that
we change to raw locks.

>
>> >From what I reached above, this is RT-only and happens on v4.18 and v4.19.
>>
>> The call trace above is caused by grabbing kmemleak_lock and then getting
>> scheduled and then re-grabbing kmemleak_lock. Using raw lock can also solve
>> this problem.
> But this is a reader / writer lock. And if I understand the other part
> of the thread then it needs multiple readers.

For call trace 2:

I don't get what "it needs multiple readers" exactly means here.

In this call trace, the kmemleak_lock is grabbed as write lock, and then scheduled
away, and then grabbed again as write lock from another path. It's a
write->write locking, compared to the discussion in the other part of the thread.

This is essentially because kmemleak hooks on the very low level memory
allocation and free operations. After scheduled away, it can easily re-enter itself.
We need raw locks to prevent this from happening.

> Couldn't we just get rid of that kfree() or move it somewhere else?
> I mean if the free() memory on CPU-down and allocate it again CPU-up
> then we could skip that, rigth? Just allocate it and don't free it
> because the CPU will likely get up again.

For call trace 1:

I went through the CPU hotplug code and found that the allocation of the
problematic data, cpuc->shared_regs, is done in intel_pmu_cpu_prepare. And
the free is done in intel_pmu_cpu_dying. They are handlers triggered by two
different perf events.

It seems we can hardly form a convincing method that holds the data while
CPUs are off and then uses it again. raw locks would be easy and good enough.

Thanks,
Zhe

>
>> Thanks,
>> Zhe
> Sebastian
>
