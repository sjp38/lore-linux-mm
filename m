Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 59F246B0069
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 07:30:01 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 36so3866507plb.18
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 04:30:01 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 89sor605539pfs.116.2018.01.15.04.30.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 04:30:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201801151944.FII09821.FMVQFJtHOOOSLF@I-love.SAKURA.ne.jp>
References: <CACT4Y+baPvzHB7w8gv=Cger80qoiyOKWO-KPgBAd7mcMD9QNLA@mail.gmail.com>
 <201801020027.GIG26598.OFSMVLQtFHJOOF@I-love.SAKURA.ne.jp>
 <CACT4Y+ZPHerom6rNYj8HL8vSySi7n4ArySnpFbxQX31n-QumNg@mail.gmail.com>
 <201801081948.HAE82801.FQOSHtMOFVLFOJ@I-love.SAKURA.ne.jp>
 <CACT4Y+bkuk3dkwdn7QCbWWWJ=R_nW8Qi6+y35VofLEHYu+6m7w@mail.gmail.com> <201801151944.FII09821.FMVQFJtHOOOSLF@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 15 Jan 2018 13:29:39 +0100
Message-ID: <CACT4Y+ZkqOWY7FtpvoSyYyxF=q+DLre5kNhQ8Jw0yqbZSY2_gA@mail.gmail.com>
Subject: Re: INFO: task hung in filemap_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <bot+980f5e5fc060c37505bd65abb49a963518b269d9@syzkaller.appspotmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, Jens Axboe <axboe@kernel.dk>, Ming Lei <tom.leiming@gmail.com>, Hannes Reinecke <hare@suse.de>, Omar Sandoval <osandov@fb.com>, shli@fb.com

On Mon, Jan 15, 2018 at 11:44 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Dmitry Vyukov wrote:
>> On Mon, Jan 8, 2018 at 11:48 AM, Tetsuo Handa
>> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> > Dmitry Vyukov wrote:
>> >> >> Hi Tetsuo,
>> >> >>
>> >> >> syzbot always re-runs the same workload on a new machine. If it
>> >> >> manages to reproduce the problem, it provides a reproducer. In this
>> >> >> case it didn't.
>> >> >
>> >> > Even if it did not manage to reproduce the problem, showing raw.log in
>> >> > C format is helpful for me. For example,
>> >> >
>> >> >   ioctl$LOOP_CHANGE_FD(r3, 0x4c00, r1)
>> >> >
>> >> > is confusing. 0x4c00 is not LOOP_CHANGE_FD but LOOP_SET_FD.
>> >> > If the message were
>> >> >
>> >> >   ioctl(r3, 0x4c00, r1)
>> >> >
>> >> > more people will be able to read what the program tried to do.
>> >> > There are many operations done on loop devices, but are too hard
>> >> > for me to pick up only loop related actions.
>> >>
>> >>
>> >> Hi Tetsuo,
>> >>
>> >> The main purpose of this format is different, this is a complete
>> >> representation of programs that allows replaying them using syzkaller
>> >> tools.
>> >
>> > What is ioctl$LOOP_CHANGE_FD(r3, 0x4c00, r1) ?
>> > 0x4c00 is LOOP_SET_FD. Why LOOP_CHANGE_FD is there?
>>
>>
>> In short, it specifies exact discrimination of the syscall which
>> affects parsing of the rest of the arguments. For some syscalls
>> (ioctl/setsockopt/sendmsg) kernel has hundreds of different
>> discriminations with radically different arguments.
>> Now if you are asking why the discrimination is LOOP_CHANGE_FD, but
>> the actual command is LOOP_SET_FD, that's because this is a fuzzer,
>> it's sole purpose is to mess things in unexpected ways.
>
> ??? I can't catch what you want to say.
>
> I understand that a fuzzer intentionally tests various cases.
> My question is simple. Why don't you use actual command name like
> ioctl$LOOP_SET_FD(r3, 0x4c00, r1) ?
> Writing like ioctl$LOOP_CHANGE_FD is confusing. I consider it as a bug.

To answer this I need to dive a bit into syzkaller internals.
There are 2 main operations with programs: generation and mutations.
During these operations consts specified in syscall discriminations
always match (we don't get LOOP_CHANGE_FD which is actually
LOOP_SET_FD). However, there are some additional operations, in
particular argument changes based on intercepted comparison arguments
in kernel code. Say, we execute LOOP_CHANGE_FD and collect all
comparison arguments and then alter syscall arguments that match one
argument to another argument. That's when we can get discrimination X
which is actually discrimination Y. There is bunch of open questions
associated with this process. First of which is -- should we ever
mutate arguments that are specified as const in a discrimination.
Mutating consts is useful, because that's what allows fuzzer to get to
all of these undescribed ioctls/setsockopts/netlink messages/network
packet protocols, etc. But then, should we also change the
discrimination? What to do if 2 disciminations have completely
different arguments, which are not possible to translate? What if we
don't have a discrimination for the new value at all? What if we have
a partial const match for 2 discriminations, but no exact match for
any discrimination. Also note that it's usually more complex than this
ioctl change because consts can be buried deep into sendmsg's data.
Even in this case, the actual ioctl depends on the file type, but we
can as well have an unknown fd type, so even when we do
ioctl$LOOP_SET_FD(r3, 0x4c00, r1), that's not necessasry LOOP_SET_FD.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
