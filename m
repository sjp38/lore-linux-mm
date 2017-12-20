Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7E36B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 05:55:20 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id x1so9313244plb.2
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 02:55:20 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q3si12974076pfl.322.2017.12.20.02.55.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 02:55:18 -0800 (PST)
Subject: Re: BUG: workqueue lockup (2)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <94eb2c03c9bc75aff2055f70734c@google.com>
	<001a113f711a528a3f0560b08e76@google.com>
	<201712192327.FIJ64026.tMQFOOVFFLHOSJ@I-love.SAKURA.ne.jp>
	<CACT4Y+ZbE5=yeb=3hL8KDpPLarHJgihsTb6xX2+4fnoLFuBTow@mail.gmail.com>
	<CACT4Y+YZ6yuZqrjAxHEadW56TVS=x=WQqrfRrvMQ=LHU3+Kd8A@mail.gmail.com>
In-Reply-To: <CACT4Y+YZ6yuZqrjAxHEadW56TVS=x=WQqrfRrvMQ=LHU3+Kd8A@mail.gmail.com>
Message-Id: <201712201955.BHB30282.tMSFVFFJLQHOOO@I-love.SAKURA.ne.jp>
Date: Wed, 20 Dec 2017 19:55:10 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com
Cc: bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com, syzkaller-bugs@googlegroups.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, tglx@linutronix.de

Dmitry Vyukov wrote:
> On Tue, Dec 19, 2017 at 3:27 PM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > syzbot wrote:
> >>
> >> syzkaller has found reproducer for the following crash on
> >> f3b5ad89de16f5d42e8ad36fbdf85f705c1ae051
> >
> > "BUG: workqueue lockup" is not a crash.
> 
> Hi Tetsuo,
> 
> What is the proper name for all of these collectively?

I think that things which lead to kernel panic when /proc/sys/kernel/panic_on_oops
was set to 1 are called an "oops" (or a "kerneloops").

Speak of "BUG: workqueue lockup", this is not an "oops". This message was
added by 82607adcf9cdf40f ("workqueue: implement lockup detector"), and
this message does not always indicate a fatal problem. This message can be
printed when the system is really out of CPU and memory. As far as I tested,
I think that workqueue was not able to run on specific CPU due to a soft
lockup bug.

> 
> 
> >> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
> >> compiler: gcc (GCC) 7.1.1 20170620
> >> .config is attached
> >> Raw console output is attached.
> >> C reproducer is attached
> >> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> >> for information about syzkaller reproducers
> >>
> >>
> >> BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 37s!
> >> BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=-20 stuck for 32s!
> >> Showing busy workqueues and worker pools:
> >> workqueue events: flags=0x0
> >>    pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
> >>      pending: cache_reap
> >> workqueue events_power_efficient: flags=0x80
> >>    pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
> >>      pending: neigh_periodic_work, do_cache_clean
> >> workqueue mm_percpu_wq: flags=0x8
> >>    pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
> >>      pending: vmstat_update
> >> workqueue kblockd: flags=0x18
> >>    pwq 3: cpus=1 node=0 flags=0x0 nice=-20 active=1/256
> >>      pending: blk_timeout_work
> >
> > You gave up too early. There is no hint for understanding what was going on.
> > While we can observe "BUG: workqueue lockup" under memory pressure, there is
> > no hint like SysRq-t and SysRq-m. Thus, I can't tell something is wrong.
> 
> Do you know how to send them programmatically? I tried to find a way
> several times, but failed. Articles that I've found talk about
> pressing some keys that don't translate directly to us-ascii.

# echo t > /proc/sysrq-trigger
# echo m > /proc/sysrq-trigger

> 
> But you can also run the reproducer. No report can possible provide
> all possible useful information, sometimes debugging boils down to
> manually adding printfs. That's why syzbot aims at providing a
> reproducer as the ultimate source of details. Also since a developer
> needs to test a proposed fix, it's easier to start with the reproducer
> right away.

I don't have information about how to run the reproducer (e.g. how many
CPUs, how much memory, what network configuration is needed).

Also, please explain how to interpret raw.log file. The raw.log in
94eb2c03c9bc75aff2055f70734c@google.com had a lot of code output and kernel
messages but did not contain "BUG: workqueue lockup" message. On the other
hand, the raw.log in 001a113f711a528a3f0560b08e76@google.com has only kernel
messages and contains "BUG: workqueue lockup" message. Why they are
significantly different?

Also, can you add timestamp to all messages?
When each message was printed is a clue for understanding relationship.

> 
> 
> > At least you need to confirm that lockup lasts for a few minutes. Otherwise,
> 
> Is it possible to increase the timeout? How? We could bump it up to 2 minutes.

# echo 120 > /sys/module/workqueue/parameters/watchdog_thresh

But generally, reporting multiple times rather than only once gives me
better clue, for the former would tell me whether situation was changing.

Can you try not to give up as soon as "BUG: workqueue lockup" was printed
for the first time?

> 
> 
> > this might be just overstressing. (According to repro.c , 12 threads are
> > created and soon SEGV follows? According to above message, only 2 CPUs?
> > Triggering SEGV suggests memory was low due to saving coredump?)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
