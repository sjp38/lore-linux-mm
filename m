Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB9A6B0035
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 04:33:18 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id f12so589871qad.17
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 01:33:18 -0700 (PDT)
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
        by mx.google.com with ESMTPS id g35si1581441qgf.104.2014.08.05.01.33.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 05 Aug 2014 01:33:17 -0700 (PDT)
Received: by mail-qg0-f45.google.com with SMTP id f51so626393qge.32
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 01:33:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140804103025.478913141@infradead.org>
References: <20140804103025.478913141@infradead.org>
Date: Tue, 5 Aug 2014 12:33:16 +0400
Message-ID: <CALFYKtBo2p5uNtkJZOy_rN7JbdFs1RbB1OfcF7TR+qDaMU0Kvg@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/7] nested sleeps, fixes and debug infra
From: Ilya Dryomov <ilya.dryomov@inktank.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, oleg@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>, tglx@linutronix.de, Mike Galbraith <umgwanakikbuti@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org

On Mon, Aug 4, 2014 at 2:30 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> Hi,
>
> Ilya recently tripped over a nested sleep which made Ingo suggest we should
> have debug checks for that. So I did some, see patch 7. Of course that
> triggered a whole bunch of fail the instant I tried to boot my machine.
>
> With this series I can boot my test box and build a kernel on it, I'm fairly
> sure that's far too limited a test to have found all, but its a start.

FWIW, I'm getting a lot of these during light rbd testing.  CC'ed
netdev and linux-mm.

WARNING: CPU: 2 PID: 1978 at kernel/sched/core.c:7094 __might_sleep+0x5b/0x1e0()
do not call blocking ops when !TASK_RUNNING; state=1 set at
[<ffffffff81070640>] prepare_to_wait+0x50/0xa0
Modules linked in:
CPU: 2 PID: 1978 Comm: ceph-osd Not tainted 3.16.0-vm+ #109
Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
 0000000000001bb6 ffff8800126739e8 ffffffff8156ec1d 0000000000000000
 ffff880012673a38 ffff880012673a28 ffffffff81032c27 ffff880012673a58
 0000000000000200 ffff8800150fa060 00000000000007ad ffffffff817ed352
Call Trace:
 [<ffffffff8156ec1d>] dump_stack+0x4f/0x7c
 [<ffffffff81032c27>] warn_slowpath_common+0x87/0xb0
 [<ffffffff81032cf1>] warn_slowpath_fmt+0x41/0x50
 [<ffffffff814f23cf>] ? tcp_v4_do_rcv+0x10f/0x4a0
 [<ffffffff81070640>] ? prepare_to_wait+0x50/0xa0
 [<ffffffff81070640>] ? prepare_to_wait+0x50/0xa0
 [<ffffffff8105b53b>] __might_sleep+0x5b/0x1e0
 [<ffffffff8148d73d>] release_sock+0x13d/0x200
 [<ffffffff81498223>] sk_stream_wait_memory+0x133/0x2d0
 [<ffffffff810701d0>] ? woken_wake_function+0x10/0x10
 [<ffffffff814dfdbf>] tcp_sendmsg+0xb6f/0xd70
 [<ffffffff815096cf>] inet_sendmsg+0xdf/0x100
 [<ffffffff815095f0>] ? inet_recvmsg+0x100/0x100
 [<ffffffff814896d7>] sock_sendmsg+0x67/0x90
 [<ffffffff810fd961>] ? might_fault+0x51/0xb0
 [<ffffffff81489a22>] ___sys_sendmsg+0x2d2/0x2e0
 [<ffffffff81095e58>] ? futex_wake+0x128/0x140
 [<ffffffff81095d31>] ? futex_wake+0x1/0x140
 [<ffffffff81141dd0>] ? do_dup2+0xd0/0xd0
 [<ffffffff8105fa31>] ? get_parent_ip+0x11/0x50
 [<ffffffff813cea27>] ? debug_smp_processor_id+0x17/0x20
 [<ffffffff813c33c5>] ? delay_tsc+0x85/0xb0
 [<ffffffff81141ead>] ? __fget+0xdd/0xf0
 [<ffffffff81141dd0>] ? do_dup2+0xd0/0xd0
 [<ffffffff81141f05>] ? __fget_light+0x45/0x60
 [<ffffffff81141f2e>] ? __fdget+0xe/0x10
 [<ffffffff8148a4e4>] __sys_sendmsg+0x44/0x70
 [<ffffffff8148a519>] SyS_sendmsg+0x9/0x10
 [<ffffffff81575b92>] system_call_fastpath+0x16/0x1b

WARNING: CPU: 0 PID: 380 at kernel/sched/core.c:7094 __might_sleep+0x5b/0x1e0()
do not call blocking ops when !TASK_RUNNING; state=1 set at
[<ffffffff81070640>] prepare_to_wait+0x50/0xa0
Modules linked in:
CPU: 0 PID: 380 Comm: kswapd0 Tainted: G        W     3.16.0-vm+ #109
Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
 0000000000001bb6 ffff88007b64bc68 ffffffff8156ec1d 0000000000000000
 ffff88007b64bcb8 ffff88007b64bca8 ffffffff81032c27 0000000000000000
 0000000000000000 ffff88007c062060 0000000000000065 ffffffff8179ca1f
Call Trace:
 [<ffffffff8156ec1d>] dump_stack+0x4f/0x7c
 [<ffffffff81032c27>] warn_slowpath_common+0x87/0xb0
 [<ffffffff81032cf1>] warn_slowpath_fmt+0x41/0x50
 [<ffffffff81070640>] ? prepare_to_wait+0x50/0xa0
 [<ffffffff81070640>] ? prepare_to_wait+0x50/0xa0
 [<ffffffff8105b53b>] __might_sleep+0x5b/0x1e0
 [<ffffffff810f7fd3>] __reset_isolation_suitable+0x83/0x140
 [<ffffffff810f83f3>] reset_isolation_suitable+0x33/0x50
 [<ffffffff810eb717>] kswapd+0x2e7/0x4d0
 [<ffffffff810701d0>] ? woken_wake_function+0x10/0x10
 [<ffffffff810eb430>] ? balance_pgdat+0x5b0/0x5b0
 [<ffffffff810539ab>] kthread+0xfb/0x110
 [<ffffffff810538b0>] ? flush_kthread_worker+0x130/0x130
 [<ffffffff81575aec>] ret_from_fork+0x7c/0xb0
 [<ffffffff810538b0>] ? flush_kthread_worker+0x130/0x130

Thanks,

                Ilya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
