Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id C96486B007D
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 03:51:31 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id a108so2267914qge.2
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 00:51:31 -0700 (PDT)
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
        by mx.google.com with ESMTPS id o7si339569qah.89.2014.08.06.00.51.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 Aug 2014 00:51:30 -0700 (PDT)
Received: by mail-qg0-f43.google.com with SMTP id a108so2321067qge.30
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 00:51:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140805130646.GZ19379@twins.programming.kicks-ass.net>
References: <20140804103025.478913141@infradead.org>
	<CALFYKtBo2p5uNtkJZOy_rN7JbdFs1RbB1OfcF7TR+qDaMU0Kvg@mail.gmail.com>
	<20140805130646.GZ19379@twins.programming.kicks-ass.net>
Date: Wed, 6 Aug 2014 11:51:29 +0400
Message-ID: <CALFYKtAVQ9Rgu_QWCqUkNHk4-wbiVK0FeiwLDttaxZC5bnnG5w@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/7] nested sleeps, fixes and debug infra
From: Ilya Dryomov <ilya.dryomov@inktank.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, oleg@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>, tglx@linutronix.de, Mike Galbraith <umgwanakikbuti@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org

On Tue, Aug 5, 2014 at 5:06 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Tue, Aug 05, 2014 at 12:33:16PM +0400, Ilya Dryomov wrote:
>> On Mon, Aug 4, 2014 at 2:30 PM, Peter Zijlstra <peterz@infradead.org> wrote:
>> > Hi,
>> >
>> > Ilya recently tripped over a nested sleep which made Ingo suggest we should
>> > have debug checks for that. So I did some, see patch 7. Of course that
>> > triggered a whole bunch of fail the instant I tried to boot my machine.
>> >
>> > With this series I can boot my test box and build a kernel on it, I'm fairly
>> > sure that's far too limited a test to have found all, but its a start.
>>
>> FWIW, I'm getting a lot of these during light rbd testing.  CC'ed
>> netdev and linux-mm.
>
> Both are cond_resched() calls, and that's not blocking as such, just a
> preemption point, so lets exclude those.

OK, this one is a bit different.

WARNING: CPU: 1 PID: 1744 at kernel/sched/core.c:7104 __might_sleep+0x58/0x90()
do not call blocking ops when !TASK_RUNNING; state=1 set at
[<ffffffff81070e10>] prepare_to_wait+0x50 /0xa0
Modules linked in:
CPU: 1 PID: 1744 Comm: lt-ceph_test_li Not tainted 3.16.0-vm+ #113
Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
 0000000000001bc0 ffff88006c4479d8 ffffffff8156f455 0000000000000000
 ffff88006c447a28 ffff88006c447a18 ffffffff81033357 0000000000000001
 0000000000000000 0000000000000950 ffffffff817ee48a ffff88006dba6120
Call Trace:
 [<ffffffff8156f455>] dump_stack+0x4f/0x7c
 [<ffffffff81033357>] warn_slowpath_common+0x87/0xb0
 [<ffffffff81033421>] warn_slowpath_fmt+0x41/0x50
 [<ffffffff81078bb2>] ? trace_hardirqs_on_caller+0x182/0x1f0
 [<ffffffff81070e10>] ? prepare_to_wait+0x50/0xa0
 [<ffffffff81070e10>] ? prepare_to_wait+0x50/0xa0
 [<ffffffff8105bc38>] __might_sleep+0x58/0x90
 [<ffffffff8148c671>] lock_sock_nested+0x31/0xb0
 [<ffffffff8148dfeb>] ? release_sock+0x1bb/0x200
 [<ffffffff81498aaa>] sk_stream_wait_memory+0x18a/0x2d0
 [<ffffffff810709a0>] ? woken_wake_function+0x10/0x10
 [<ffffffff814e058f>] tcp_sendmsg+0xb6f/0xd70
 [<ffffffff81509e9f>] inet_sendmsg+0xdf/0x100
 [<ffffffff81509dc0>] ? inet_recvmsg+0x100/0x100
 [<ffffffff81489f07>] sock_sendmsg+0x67/0x90
 [<ffffffff810fe391>] ? might_fault+0x51/0xb0
 [<ffffffff8148a252>] ___sys_sendmsg+0x2d2/0x2e0
 [<ffffffff811428a0>] ? do_dup2+0xd0/0xd0
 [<ffffffff811428a0>] ? do_dup2+0xd0/0xd0
 [<ffffffff8105bfe0>] ? finish_task_switch+0x50/0x100
 [<ffffffff811429d5>] ? __fget_light+0x45/0x60
 [<ffffffff811429fe>] ? __fdget+0xe/0x10
 [<ffffffff8148ad14>] __sys_sendmsg+0x44/0x70
 [<ffffffff8148ad49>] SyS_sendmsg+0x9/0x10
 [<ffffffff815764d2>] system_call_fastpath+0x16/0x1b

Thanks,

                Ilya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
