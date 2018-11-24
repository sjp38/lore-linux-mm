Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 982E16B36E2
	for <linux-mm@kvack.org>; Sat, 24 Nov 2018 09:27:00 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 4so17770526plc.5
        for <linux-mm@kvack.org>; Sat, 24 Nov 2018 06:27:00 -0800 (PST)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id v19si34747235pfa.80.2018.11.24.06.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 24 Nov 2018 06:26:59 -0800 (PST)
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
 <20181123095314.hervxkxtqoixovro@linutronix.de>
From: He Zhe <zhe.he@windriver.com>
Message-ID: <40a63aa5-edb6-4673-b4cc-1bc10e7b3953@windriver.com>
Date: Sat, 24 Nov 2018 22:26:46 +0800
MIME-Version: 1.0
In-Reply-To: <20181123095314.hervxkxtqoixovro@linutronix.de>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: catalin.marinas@arm.com, tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org



On 2018/11/23 17:53, Sebastian Andrzej Siewior wrote:
> On 2018-11-22 17:04:19 [+0800], zhe.he@windriver.com wrote:
>> From: He Zhe <zhe.he@windriver.com>
>>
>> kmemleak_lock, as a rwlock on RT, can possibly be held in atomic context and
>> causes the follow BUG.
>>
>> BUG: scheduling while atomic: migration/15/132/0x00000002
> …
>> Preemption disabled at:
>> [<ffffffff8c927c11>] cpu_stopper_thread+0x71/0x100
>> CPU: 15 PID: 132 Comm: migration/15 Not tainted 4.19.0-rt1-preempt-rt #1
>> Hardware name: Intel Corp. Harcuvar/Server, BIOS HAVLCRB1.X64.0015.D62.1708310404 08/31/2017
>> Call Trace:
>>  dump_stack+0x4f/0x6a
>>  ? cpu_stopper_thread+0x71/0x100
>>  __schedule_bug.cold.16+0x38/0x55
>>  __schedule+0x484/0x6c0
>>  schedule+0x3d/0xe0
>>  rt_spin_lock_slowlock_locked+0x118/0x2a0
>>  rt_spin_lock_slowlock+0x57/0x90
>>  __rt_spin_lock+0x26/0x30
>>  __write_rt_lock+0x23/0x1a0
>>  ? intel_pmu_cpu_dying+0x67/0x70
>>  rt_write_lock+0x2a/0x30
>>  find_and_remove_object+0x1e/0x80
>>  delete_object_full+0x10/0x20
>>  kmemleak_free+0x32/0x50
>>  kfree+0x104/0x1f0
>>  ? x86_pmu_starting_cpu+0x30/0x30
>>  intel_pmu_cpu_dying+0x67/0x70
>>  x86_pmu_dying_cpu+0x1a/0x30
>>  cpuhp_invoke_callback+0x92/0x700
>>  take_cpu_down+0x70/0xa0
>>  multi_cpu_stop+0x62/0xc0
>>  ? cpu_stop_queue_work+0x130/0x130
>>  cpu_stopper_thread+0x79/0x100
>>  smpboot_thread_fn+0x20f/0x2d0
>>  kthread+0x121/0x140
>>  ? sort_range+0x30/0x30
>>  ? kthread_park+0x90/0x90
>>  ret_from_fork+0x35/0x40
> If this is the only problem? kfree() from a preempt-disabled section
> should cause a warning even without kmemleak.

Thanks for your review. I just did some tests aginst the latest code.

On latest v4.19.1-rt3, both of the call traces can be reproduced with kmemleak
enabied. And none can be reproduced with kmemleak disabled.

On latest mainline tree, none can be reproduced no matter kmemleak is enabled
or disabled.

I don't get why kfree from a preempt-disabled section should cause a warning
without kmemleak, since kfree can't sleep.

If I understand correctly, the call trace above is caused by trying to schedule
after preemption is disabled, which cannot be reached in mainline kernel. So
we might need to turn to use raw lock to keep preemption disabled.

>
>> And on v4.18 stable tree the following call trace, caused by grabbing
>> kmemleak_lock again, is also observed.
>>
>> kernel BUG at kernel/locking/rtmutex.c:1048! 
>> invalid opcode: 0000 [#1] PREEMPT SMP PTI 
>> CPU: 5 PID: 689 Comm: mkfs.ext4 Not tainted 4.18.16-rt9-preempt-rt #1 
> …
>> Call Trace: 
>>  ? preempt_count_add+0x74/0xc0 
>>  rt_spin_lock_slowlock+0x57/0x90 
>>  ? __kernel_text_address+0x12/0x40 
>>  ? __save_stack_trace+0x75/0x100 
>>  __rt_spin_lock+0x26/0x30 
>>  __write_rt_lock+0x23/0x1a0 
>>  rt_write_lock+0x2a/0x30 
>>  create_object+0x17d/0x2b0 
> …
>
> is this an RT-only problem? Because mainline should not allow read->read
> locking or read->write locking for reader-writer locks. If this only
> happens on v4.18 and not on v4.19 then something must have fixed it.

>From what I reached above, this is RT-only and happens on v4.18 and v4.19.

The call trace above is caused by grabbing kmemleak_lock and then getting
scheduled and then re-grabbing kmemleak_lock. Using raw lock can also solve
this problem.

Thanks,
Zhe

>  
>
> Sebastian
>
