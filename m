Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2DBE36B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 06:04:32 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id s12so11385608plp.11
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 03:04:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 71sor4280308plb.75.2017.12.21.03.04.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Dec 2017 03:04:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201712201955.BHB30282.tMSFVFFJLQHOOO@I-love.SAKURA.ne.jp>
References: <94eb2c03c9bc75aff2055f70734c@google.com> <001a113f711a528a3f0560b08e76@google.com>
 <201712192327.FIJ64026.tMQFOOVFFLHOSJ@I-love.SAKURA.ne.jp>
 <CACT4Y+ZbE5=yeb=3hL8KDpPLarHJgihsTb6xX2+4fnoLFuBTow@mail.gmail.com>
 <CACT4Y+YZ6yuZqrjAxHEadW56TVS=x=WQqrfRrvMQ=LHU3+Kd8A@mail.gmail.com> <201712201955.BHB30282.tMSFVFFJLQHOOO@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 21 Dec 2017 12:04:09 +0100
Message-ID: <CACT4Y+apEKifyUB4_vNTybetaAkXpxCaSUECrQPSWCMJgQWE0w@mail.gmail.com>
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
>
>>
>> But you can also run the reproducer. No report can possible provide
>> all possible useful information, sometimes debugging boils down to
>> manually adding printfs. That's why syzbot aims at providing a
>> reproducer as the ultimate source of details. Also since a developer
>> needs to test a proposed fix, it's easier to start with the reproducer
>> right away.
>
> I don't have information about how to run the reproducer (e.g. how many
> CPUs, how much memory, what network configuration is needed).

Usually all of that is irrelevant and these reproduce well on any machine.
FWIW, there were 2 CPUs and 2 GBs of memory. Network -- whatever GCE
provides as default network.


> Also, please explain how to interpret raw.log file. The raw.log in
> 94eb2c03c9bc75aff2055f70734c@google.com had a lot of code output and kernel
> messages but did not contain "BUG: workqueue lockup" message. On the other
> hand, the raw.log in 001a113f711a528a3f0560b08e76@google.com has only kernel
> messages and contains "BUG: workqueue lockup" message. Why they are
> significantly different?


The first raw.log does contain "BUG: workqueue lockup", I see it right there:

[  120.799119] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0
nice=0 stuck for 48s!
[  120.807313] BUG: workqueue lockup - pool cpus=0-1 flags=0x4 nice=0
stuck for 47s!
[  120.815024] Showing busy workqueues and worker pools:
[  120.820369] workqueue events: flags=0x0
[  120.824536]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
[  120.830803]     pending: perf_sched_delayed, vmstat_shepherd,
jump_label_update_timeout, cache_reap
[  120.840149] workqueue events_power_efficient: flags=0x80
[  120.845651]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
[  120.851822]     pending: neigh_periodic_work, neigh_periodic_work,
do_cache_clean, reg_check_chans_work
[  120.861447] workqueue mm_percpu_wq: flags=0x8
[  120.865947]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  120.872082]     pending: vmstat_update
[  120.875994] workqueue writeback: flags=0x4e
[  120.880416]   pwq 4: cpus=0-1 flags=0x4 nice=0 active=1/256
[  120.886164]     in-flight: 3401:wb_workfn
[  120.890358] workqueue kblockd: flags=0x18

The difference is cause by the fact that the first one was obtained
from fuzzing session when fuzzer executed lots of random programs,
while the second one was an attempt to localize a reproducer, so the
system run programs one-by-one on freshly booted machines.



> Also, can you add timestamp to all messages?
> When each message was printed is a clue for understanding relationship.

There are timestamps. each program is prefixed with timestamps:

2017/12/03 08:51:30 executing program 6:

these things allow to tie kernel and real time:

[   71.240837] QAT: Invalid ioctl
2017/12/03 08:51:30 executing program 3:



>> > At least you need to confirm that lockup lasts for a few minutes. Otherwise,
>>
>> Is it possible to increase the timeout? How? We could bump it up to 2 minutes.
>
> # echo 120 > /sys/module/workqueue/parameters/watchdog_thresh
>
> But generally, reporting multiple times rather than only once gives me
> better clue, for the former would tell me whether situation was changing.
>
> Can you try not to give up as soon as "BUG: workqueue lockup" was printed
> for the first time?


I've bumped timeout to 120 seconds with workqueue.watchdog_thresh=120
command line arg. Let's see if it still leaves any false positives, I
think 2 minutes should be enough, a CPU stalled for 2+ minutes
suggests something to fix anyway(even if just slowness somewhere). And
in the end this wasn't a false positive either, right?
Not giving up after an oops message will be hard and problematic for
several reasons.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
