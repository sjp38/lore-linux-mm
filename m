Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 008646B028B
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 04:09:04 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x24so1424116pge.13
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 01:09:04 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f31sor4142484plf.19.2018.01.08.01.09.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 01:09:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201801020027.GIG26598.OFSMVLQtFHJOOF@I-love.SAKURA.ne.jp>
References: <001a11444d0e7bfd7f05609956c6@google.com> <82d89066-7dd2-12fe-3cc0-c8d624fe0d51@I-love.SAKURA.ne.jp>
 <CACT4Y+baPvzHB7w8gv=Cger80qoiyOKWO-KPgBAd7mcMD9QNLA@mail.gmail.com> <201801020027.GIG26598.OFSMVLQtFHJOOF@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 8 Jan 2018 10:08:40 +0100
Message-ID: <CACT4Y+ZPHerom6rNYj8HL8vSySi7n4ArySnpFbxQX31n-QumNg@mail.gmail.com>
Subject: Re: INFO: task hung in filemap_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <bot+980f5e5fc060c37505bd65abb49a963518b269d9@syzkaller.appspotmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, Jens Axboe <axboe@kernel.dk>, Ming Lei <tom.leiming@gmail.com>, Hannes Reinecke <hare@suse.de>, Omar Sandoval <osandov@fb.com>, shli@fb.com

On Mon, Jan 1, 2018 at 4:27 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Dmitry Vyukov wrote:
>> On Mon, Dec 18, 2017 at 3:52 PM, Tetsuo Handa
>> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> > On 2017/12/18 17:43, syzbot wrote:
>> >> Hello,
>> >>
>> >> syzkaller hit the following crash on 6084b576dca2e898f5c101baef151f7bfdbb606d
>> >> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
>> >> compiler: gcc (GCC) 7.1.1 20170620
>> >> .config is attached
>> >> Raw console output is attached.
>> >>
>> >> Unfortunately, I don't have any reproducer for this bug yet.
>> >>
>> >
>> > This log has a lot of mmap() but also has Android's binder messages.
>> >
>> > r9 = syz_open_dev$binder(&(0x7f0000000000)='/dev/binder#\x00', 0x0, 0x800)
>> >
>> > [   49.200735] binder: 9749:9755 IncRefs 0 refcount change on invalid ref 2 ret -22
>> > [   49.221514] binder: 9749:9755 Acquire 1 refcount change on invalid ref 4 ret -22
>> > [   49.233325] binder: 9749:9755 Acquire 1 refcount change on invalid ref 0 ret -22
>> > [   49.241979] binder: binder_mmap: 9749 205a3000-205a7000 bad vm_flags failed -1
>> > [   49.256949] binder: 9749:9755 unknown command 0
>> > [   49.262470] binder: 9749:9755 ioctl c0306201 20000fd0 returned -22
>> > [   49.293365] binder: 9749:9755 IncRefs 0 refcount change on invalid ref 2 ret -22
>> > [   49.301297] binder: binder_mmap: 9749 205a3000-205a7000 bad vm_flags failed -1
>> > [   49.314146] binder: 9749:9755 Acquire 1 refcount change on invalid ref 4 ret -22
>> > [   49.322732] binder: 9749:9755 Acquire 1 refcount change on invalid ref 0 ret -22
>> > [   49.332063] binder: 9749:9755 Release 1 refcount change on invalid ref 1 ret -22
>> > [   49.340796] binder: 9749:9755 Acquire 1 refcount change on invalid ref 2 ret -22
>> > [   49.349457] binder: 9749:9755 BC_DEAD_BINDER_DONE 0000000000000001 not found
>> > [   49.349462] binder: 9749:9755 BC_DEAD_BINDER_DONE 0000000000000000 not found
>> >
>> > [  246.752088] INFO: task syz-executor7:10280 blocked for more than 120 seconds.
>> >
>> > Anything that hung in 126.75 >= uptime > 6.75 can be reported at uptime = 246.75, can't it?
>> > khungtaskd warning with 120 seconds check interval can be delayed for up to 240 seconds.
>> >
>> > Is it possible to reproduce this problem by running the same program?
>>
>>
>> Hi Tetsuo,
>>
>> syzbot always re-runs the same workload on a new machine. If it
>> manages to reproduce the problem, it provides a reproducer. In this
>> case it didn't.
>
> Even if it did not manage to reproduce the problem, showing raw.log in
> C format is helpful for me. For example,
>
>   ioctl$LOOP_CHANGE_FD(r3, 0x4c00, r1)
>
> is confusing. 0x4c00 is not LOOP_CHANGE_FD but LOOP_SET_FD.
> If the message were
>
>   ioctl(r3, 0x4c00, r1)
>
> more people will be able to read what the program tried to do.
> There are many operations done on loop devices, but are too hard
> for me to pick up only loop related actions.


Hi Tetsuo,

The main purpose of this format is different, this is a complete
representation of programs that allows replaying them using syzkaller
tools. We can't simply drop info from there. Do you propose to add
another attached file that contains the same info in a different
format? What is the exact format you are proposing? Is it just
dropping the syscall name part after $ sign? Note that it's still not
C, more complex syscall generally look as follows:

perf_event_open(&(0x7f0000b5a000)={0x4000000002, 0x78, 0x1e2, 0x0,
0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffff, 0x0,
0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
@perf_bp={&(0x7f0000000000)=0x0, 0x0}, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
0x0, 0x0}, 0x0, 0x0, 0xffffffffffffffff, 0x0)
recvmmsg(0xffffffffffffffff, &(0x7f0000003000)=[{{0x0, 0x0,
&(0x7f0000002000)=[{&(0x7f000000a000)=""/193, 0xc1},
{&(0x7f0000007000-0x3d)=""/61, 0x3d}], 0x2,
&(0x7f0000005000-0x67)=""/103, 0x67, 0x0}, 0x0}], 0x1, 0x0,
&(0x7f0000003000-0x10)={0x77359400, 0x0})
bpf$PROG_LOAD(0x5, &(0x7f0000000000)={0x1, 0x5,
&(0x7f0000002000)=@framed={{0x18, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
0x0}, [@jmp={0x5, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0}], {0x95, 0x0, 0x0,
0x0}}, &(0x7f0000004000-0xa)='syzkaller\x00', 0x3, 0xc3,
&(0x7f0000386000)=""/195, 0x0, 0x0, [0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0], 0x0}, 0x48)

Note: you can convert any syzkaller program to equivalent C code using
syz-prog2c utility that comes with syzkaller.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
