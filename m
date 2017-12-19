Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D19426B025F
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 09:41:05 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x24so12715941pgv.5
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 06:41:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r80sor4358640pfd.94.2017.12.19.06.41.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 06:41:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201712192327.FIJ64026.tMQFOOVFFLHOSJ@I-love.SAKURA.ne.jp>
References: <94eb2c03c9bc75aff2055f70734c@google.com> <001a113f711a528a3f0560b08e76@google.com>
 <201712192327.FIJ64026.tMQFOOVFFLHOSJ@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 19 Dec 2017 15:40:43 +0100
Message-ID: <CACT4Y+ZbE5=yeb=3hL8KDpPLarHJgihsTb6xX2+4fnoLFuBTow@mail.gmail.com>
Subject: Re: BUG: workqueue lockup (2)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com>, syzkaller-bugs@googlegroups.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Dec 19, 2017 at 3:27 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> syzbot wrote:
>>
>> syzkaller has found reproducer for the following crash on
>> f3b5ad89de16f5d42e8ad36fbdf85f705c1ae051
>
> "BUG: workqueue lockup" is not a crash.

Hi Tetsuo,

What is the proper name for all of these collectively?


>> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
>> compiler: gcc (GCC) 7.1.1 20170620
>> .config is attached
>> Raw console output is attached.
>> C reproducer is attached
>> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
>> for information about syzkaller reproducers
>>
>>
>> BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 37s!
>> BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=-20 stuck for 32s!
>> Showing busy workqueues and worker pools:
>> workqueue events: flags=0x0
>>    pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
>>      pending: cache_reap
>> workqueue events_power_efficient: flags=0x80
>>    pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
>>      pending: neigh_periodic_work, do_cache_clean
>> workqueue mm_percpu_wq: flags=0x8
>>    pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
>>      pending: vmstat_update
>> workqueue kblockd: flags=0x18
>>    pwq 3: cpus=1 node=0 flags=0x0 nice=-20 active=1/256
>>      pending: blk_timeout_work
>
> You gave up too early. There is no hint for understanding what was going on.
> While we can observe "BUG: workqueue lockup" under memory pressure, there is
> no hint like SysRq-t and SysRq-m. Thus, I can't tell something is wrong.

Do you know how to send them programmatically? I tried to find a way
several times, but failed. Articles that I've found talk about
pressing some keys that don't translate directly to us-ascii.

But you can also run the reproducer. No report can possible provide
all possible useful information, sometimes debugging boils down to
manually adding printfs. That's why syzbot aims at providing a
reproducer as the ultimate source of details. Also since a developer
needs to test a proposed fix, it's easier to start with the reproducer
right away.


> At least you need to confirm that lockup lasts for a few minutes. Otherwise,

Is it possible to increase the timeout? How? We could bump it up to 2 minutes.


> this might be just overstressing. (According to repro.c , 12 threads are
> created and soon SEGV follows? According to above message, only 2 CPUs?
> Triggering SEGV suggests memory was low due to saving coredump?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
