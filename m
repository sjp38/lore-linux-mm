Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2ACED6B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 05:23:07 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v25so18139171pfg.14
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 02:23:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q1sor4617875pgn.351.2017.12.21.02.23.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Dec 2017 02:23:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201712201955.BHB30282.tMSFVFFJLQHOOO@I-love.SAKURA.ne.jp>
References: <94eb2c03c9bc75aff2055f70734c@google.com> <001a113f711a528a3f0560b08e76@google.com>
 <201712192327.FIJ64026.tMQFOOVFFLHOSJ@I-love.SAKURA.ne.jp>
 <CACT4Y+ZbE5=yeb=3hL8KDpPLarHJgihsTb6xX2+4fnoLFuBTow@mail.gmail.com>
 <CACT4Y+YZ6yuZqrjAxHEadW56TVS=x=WQqrfRrvMQ=LHU3+Kd8A@mail.gmail.com> <201712201955.BHB30282.tMSFVFFJLQHOOO@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 21 Dec 2017 11:22:45 +0100
Message-ID: <CACT4Y+YtPRSqN62TLS4OBEczFwsFg0x47v+PpZSNVJsh4_cGKw@mail.gmail.com>
Subject: Re: BUG: workqueue lockup (2)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com>, syzkaller-bugs@googlegroups.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Dec 20, 2017 at 11:55 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Dmitry Vyukov wrote:
>> On Tue, Dec 19, 2017 at 3:27 PM, Tetsuo Handa
>> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> > syzbot wrote:
>> >>
>> >> syzkaller has found reproducer for the following crash on
>> >> f3b5ad89de16f5d42e8ad36fbdf85f705c1ae051
>> >
>> > "BUG: workqueue lockup" is not a crash.
>>
>> Hi Tetsuo,
>>
>> What is the proper name for all of these collectively?
>
> I think that things which lead to kernel panic when /proc/sys/kernel/panic_on_oops
> was set to 1 are called an "oops" (or a "kerneloops").
>
> Speak of "BUG: workqueue lockup", this is not an "oops". This message was
> added by 82607adcf9cdf40f ("workqueue: implement lockup detector"), and
> this message does not always indicate a fatal problem. This message can be
> printed when the system is really out of CPU and memory. As far as I tested,
> I think that workqueue was not able to run on specific CPU due to a soft
> lockup bug.
>
>>
>>
>> >> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
>> >> compiler: gcc (GCC) 7.1.1 20170620
>> >> .config is attached
>> >> Raw console output is attached.
>> >> C reproducer is attached
>> >> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
>> >> for information about syzkaller reproducers
>> >>
>> >>
>> >> BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 37s!
>> >> BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=-20 stuck for 32s!
>> >> Showing busy workqueues and worker pools:
>> >> workqueue events: flags=0x0
>> >>    pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
>> >>      pending: cache_reap
>> >> workqueue events_power_efficient: flags=0x80
>> >>    pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
>> >>      pending: neigh_periodic_work, do_cache_clean
>> >> workqueue mm_percpu_wq: flags=0x8
>> >>    pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
>> >>      pending: vmstat_update
>> >> workqueue kblockd: flags=0x18
>> >>    pwq 3: cpus=1 node=0 flags=0x0 nice=-20 active=1/256
>> >>      pending: blk_timeout_work
>> >
>> > You gave up too early. There is no hint for understanding what was going on.
>> > While we can observe "BUG: workqueue lockup" under memory pressure, there is
>> > no hint like SysRq-t and SysRq-m. Thus, I can't tell something is wrong.
>>
>> Do you know how to send them programmatically? I tried to find a way
>> several times, but failed. Articles that I've found talk about
>> pressing some keys that don't translate directly to us-ascii.
>
> # echo t > /proc/sysrq-trigger
> # echo m > /proc/sysrq-trigger


This requires working ssh connection, but we routinely deal with
half-dead kernels. I think that sysrq over console is as reliable as
we can get in this context. But I don't know how to send them.

But thinking more about this, I am leaning towards the direction that
kernel just need to do the right thing and print that info.
In lots of cases we get a panic and as far as I understand kernel
won't react on sysrq in that state. Console is still unreliable too.
If a message is not useful, the right direction is to make it useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
