Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3D756B0033
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 08:43:29 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q186so23681779pga.23
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 05:43:29 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y83sor9740371pfj.91.2017.12.28.05.43.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Dec 2017 05:43:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201712212207.GHD30218.MtFFVSOOQLHFJO@I-love.SAKURA.ne.jp>
References: <201712192327.FIJ64026.tMQFOOVFFLHOSJ@I-love.SAKURA.ne.jp>
 <CACT4Y+ZbE5=yeb=3hL8KDpPLarHJgihsTb6xX2+4fnoLFuBTow@mail.gmail.com>
 <CACT4Y+YZ6yuZqrjAxHEadW56TVS=x=WQqrfRrvMQ=LHU3+Kd8A@mail.gmail.com>
 <201712201955.BHB30282.tMSFVFFJLQHOOO@I-love.SAKURA.ne.jp>
 <CACT4Y+apEKifyUB4_vNTybetaAkXpxCaSUECrQPSWCMJgQWE0w@mail.gmail.com> <201712212207.GHD30218.MtFFVSOOQLHFJO@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 28 Dec 2017 14:43:06 +0100
Message-ID: <CACT4Y+bC+1XbNjVM_qwVG6qdivnsG9kF+YUL_jj8qjseP51-oA@mail.gmail.com>
Subject: Re: BUG: workqueue lockup (2)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com>, syzkaller-bugs@googlegroups.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Dec 21, 2017 at 2:07 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Dmitry Vyukov wrote:
>> On Wed, Dec 20, 2017 at 11:55 AM, Tetsuo Handa
>> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> > Dmitry Vyukov wrote:
>> >> On Tue, Dec 19, 2017 at 3:27 PM, Tetsuo Handa
>> >> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> >> > syzbot wrote:
>> >> >>
>> >> >> syzkaller has found reproducer for the following crash on
>> >> >> f3b5ad89de16f5d42e8ad36fbdf85f705c1ae051
>> >> >
>> >> > "BUG: workqueue lockup" is not a crash.
>> >>
>> >> Hi Tetsuo,
>> >>
>> >> What is the proper name for all of these collectively?
>> >
>> > I think that things which lead to kernel panic when /proc/sys/kernel/panic_on_oops
>> > was set to 1 are called an "oops" (or a "kerneloops").
>> >
>> > Speak of "BUG: workqueue lockup", this is not an "oops". This message was
>> > added by 82607adcf9cdf40f ("workqueue: implement lockup detector"), and
>> > this message does not always indicate a fatal problem. This message can be
>> > printed when the system is really out of CPU and memory. As far as I tested,
>> > I think that workqueue was not able to run on specific CPU due to a soft
>> > lockup bug.
>>
>> There are also warnings which don't panic normally, unless
>> panic_on_warn is set. There are also cases when we suddenly lost a
>> machine and have no idea what happened with it. And also cases when we
>> are kind-a connected, and nothing bad is printed on console, but it's
>> still un-operable.
>
> Configuring netconsole might be helpful, for I use udplogger at
> https://osdn.net/projects/akari/scm/svn/tree/head/branches/udplogger/
> in order to collect all messages (not only kernel messages but also
> any text messages which can be sent as UDP packets) with timestamp added.
>
> An example of timestamp added to each line is
> http://I-love.SAKURA.ne.jp/tmp/20171018-deflate.log.xz .
>
> You can combine kernel messages from netconsole and output from shell
> session using bash's
>
>   $ (command1; command2; command3) > /dev/udp/$remote_ip/$remote_port
>
> syntax.

syzkaller already sends everything over network to a reliable host. So
this part is already working.



>> The only collective name I can think of is bug. We could change it to
>> bug. Otherwise since there are multiple names, I don't think it's
>> worth spending more time on this.
>
> What I care is whether the report is useful.
>
>>
>> >> >
>> >> > You gave up too early. There is no hint for understanding what was going on.
>> >> > While we can observe "BUG: workqueue lockup" under memory pressure, there is
>> >> > no hint like SysRq-t and SysRq-m. Thus, I can't tell something is wrong.
>> >>
>> >> Do you know how to send them programmatically? I tried to find a way
>> >> several times, but failed. Articles that I've found talk about
>> >> pressing some keys that don't translate directly to us-ascii.
>> >
>> > # echo t > /proc/sysrq-trigger
>> > # echo m > /proc/sysrq-trigger
>>
>>
>> This requires working ssh connection, but we routinely deal with
>> half-dead kernels. I think that sysrq over console is as reliable as
>> we can get in this context. But I don't know how to send them.
>
> I can't understand your question. If the machine is running in a
> virtualized environment, doesn't hypervisor provide a mean to send
> SysRq commands to a guest remotely (e.g. "virsh send-keys sysrq") ?

These particular machines were GCE instances. I can't find any info
about special GCE capabilities to send sysrqs.


> If no means available, running
>
> ----------
> #/bin/sh
>
> while :
> do
> echo t > /proc/sysrq-trigger
> echo m > /proc/sysrq-trigger
> sleep 60
> done
> ----------
>
> in the background might be used.

This has good chances of missing the interesting stacks. Thinking of
this more, I think kernel should dump that info on bugs. The current
"BUG: workqueue lockup" report is not actionable, it's not directly
related to syzbot, it's related to kernel.


>> But thinking more about this, I am leaning towards the direction that
>> kernel just need to do the right thing and print that info.
>> In lots of cases we get a panic and as far as I understand kernel
>> won't react on sysrq in that state. Console is still unreliable too.
>> If a message is not useful, the right direction is to make it useful.
>>
>
> Then, configure kdump and analyze the vmcore. Kernel panic message
> alone is not so helpful. You can feed commands to crash utility from
> stdin and save stdout to a file. Then, the result file will provide
> more information than SysRq-t + SysRq-m (apart from lack of ability to
> understand whether situation has changed over time).

I've filed https://github.com/google/syzkaller/issues/491 for kdump
cores. But there are lots to learn. And this also needs to be done not
once by an intelligent human, but programmed to work fully
automatically, which is usually much harder to do.
The general idea, is that the reproducer is the ultimate source of
details. kdump can well be not helpful as well. Lots of people won't
look at them at all for various reasons. Sometimes you need to add
additional printf's and re-run and then repeat this multiple times. I
don't think there a magical piece of information that will shed light
on just any kernel issue.


>> >> But you can also run the reproducer. No report can possible provide
>> >> all possible useful information, sometimes debugging boils down to
>> >> manually adding printfs. That's why syzbot aims at providing a
>> >> reproducer as the ultimate source of details. Also since a developer
>> >> needs to test a proposed fix, it's easier to start with the reproducer
>> >> right away.
>> >
>> > I don't have information about how to run the reproducer (e.g. how many
>> > CPUs, how much memory, what network configuration is needed).
>>
>> Usually all of that is irrelevant and these reproduce well on any machine.
>> FWIW, there were 2 CPUs and 2 GBs of memory. Network -- whatever GCE
>> provides as default network.
>
> The reproducer contained network addresses.
> If the bug depends on network, how to configure network is important.

Do you mean getsockopt$inet_sctp6_SCTP_GET_LOCAL_ADDRS call? But it
only obtains addresses and I think it fails, because it's called on a
local file. Generally, network communication of these programs is
self-contained. If they use network, they bring up interfaces.
There are lots of bits to full reproducibility. For example, you would
also need to use GCE VMs. As I said, in 95% of cases these are
reproducible without any special measures (.config obviously matters,
but it's supplied).




>> > Also, please explain how to interpret raw.log file. The raw.log in
>> > 94eb2c03c9bc75aff2055f70734c@google.com had a lot of code output and kernel
>> > messages but did not contain "BUG: workqueue lockup" message. On the other
>> > hand, the raw.log in 001a113f711a528a3f0560b08e76@google.com has only kernel
>> > messages and contains "BUG: workqueue lockup" message. Why they are
>> > significantly different?
>>
>>
>> The first raw.log does contain "BUG: workqueue lockup", I see it right there:
>>
>> [  120.799119] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0
>> nice=0 stuck for 48s!
>> [  120.807313] BUG: workqueue lockup - pool cpus=0-1 flags=0x4 nice=0
>> stuck for 47s!
>> [  120.815024] Showing busy workqueues and worker pools:
>> [  120.820369] workqueue events: flags=0x0
>> [  120.824536]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
>> [  120.830803]     pending: perf_sched_delayed, vmstat_shepherd,
>> jump_label_update_timeout, cache_reap
>> [  120.840149] workqueue events_power_efficient: flags=0x80
>> [  120.845651]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
>> [  120.851822]     pending: neigh_periodic_work, neigh_periodic_work,
>> do_cache_clean, reg_check_chans_work
>> [  120.861447] workqueue mm_percpu_wq: flags=0x8
>> [  120.865947]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
>> [  120.872082]     pending: vmstat_update
>> [  120.875994] workqueue writeback: flags=0x4e
>> [  120.880416]   pwq 4: cpus=0-1 flags=0x4 nice=0 active=1/256
>> [  120.886164]     in-flight: 3401:wb_workfn
>> [  120.890358] workqueue kblockd: flags=0x18
>
> Where?
>
> I'm talking about https://marc.info/?l=linux-mm&m=151231146619948&q=p4
> at http://lkml.kernel.org/r/94eb2c03c9bc75aff2055f70734c@google.com .

Interesting. Looks like LKML bug, the file is truncated half way. You
can see the full raw.log here:
https://groups.google.com/d/msg/syzkaller-bugs/vwcINLkXTVQ/fuzYSNeXAwAJ

I've tried to find LKML and kernel bugzilla admins, but can't find any
real people. If you know how to contact them, we can talk to them.



>> The difference is cause by the fact that the first one was obtained
>> from fuzzing session when fuzzer executed lots of random programs,
>> while the second one was an attempt to localize a reproducer, so the
>> system run programs one-by-one on freshly booted machines.
>>
>
> I see. But context is too limited to know that.

Yes. But there is also a problem of too much context. We have hard
time making some people read even the minimal amount of concentrated
information. Having a 100-page [outdated] manual won't be helpful
either, and as it usually happens these manuals tend to contain
everything but the bit of information you are actually looking for.
That's why I an answering questions.


>> > Also, can you add timestamp to all messages?
>> > When each message was printed is a clue for understanding relationship.
>>
>> There are timestamps. each program is prefixed with timestamps:
>>
>> 2017/12/03 08:51:30 executing program 6:
>>
>> these things allow to tie kernel and real time:
>>
>> [   71.240837] QAT: Invalid ioctl
>> 2017/12/03 08:51:30 executing program 3:
>>
>
> What I want is something like
>
>   timestamp kernel message 1
>   timestamp kernel message 2
>   timestamp kernel message 3
>   timestamp shell session message 1
>   timestamp kernel message 4
>   timestamp kernel message 5
>   timestamp shell session message 2
>   timestamp shell session message 3
>   timestamp kernel message 6
>   timestamp kernel message 7
>
> which can be done using udplogger above.
>
>>
>>
>> >> > At least you need to confirm that lockup lasts for a few minutes. Otherwise,
>> >>
>> >> Is it possible to increase the timeout? How? We could bump it up to 2 minutes.
>> >
>> > # echo 120 > /sys/module/workqueue/parameters/watchdog_thresh
>> >
>> > But generally, reporting multiple times rather than only once gives me
>> > better clue, for the former would tell me whether situation was changing.
>> >
>> > Can you try not to give up as soon as "BUG: workqueue lockup" was printed
>> > for the first time?
>>
>>
>> I've bumped timeout to 120 seconds with workqueue.watchdog_thresh=120
>> command line arg. Let's see if it still leaves any false positives, I
>> think 2 minutes should be enough, a CPU stalled for 2+ minutes
>> suggests something to fix anyway(even if just slowness somewhere). And
>> in the end this wasn't a false positive either, right?
>
> Regarding this bug, the report should include soft lockups rather than
> workqueue lockups, for workqueue was not able to run for long due to
> soft lockup in progress.
>
>> Not giving up after an oops message will be hard and problematic for
>> several reasons.
>>
>
> But reports which cannot understand what was happening is not actionable.
> Again, "BUG: workqueue lockup" is not an "oops".
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/201712212207.GHD30218.MtFFVSOOQLHFJO%40I-love.SAKURA.ne.jp.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
