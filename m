Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0CD228E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 04:52:34 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id p21so19049234iog.0
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 01:52:34 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n191si1150663itn.141.2019.01.07.01.52.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 Jan 2019 01:52:33 -0800 (PST)
Date: Mon, 7 Jan 2019 10:52:17 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: possible deadlock in __wake_up_common_lock
Message-ID: <20190107095217.GB2861@worktop.programming.kicks-ass.net>
References: <000000000000f67ca2057e75bec3@google.com>
 <1194004c-f176-6253-a5fd-682472dccacc@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1194004c-f176-6253-a5fd-682472dccacc@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: syzbot <syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com>, aarcange@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, xieyisheng1@huawei.com, zhongjiang@huawei.com, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>, hannes@cmpxchg.org

On Wed, Jan 02, 2019 at 01:51:01PM +0100, Vlastimil Babka wrote:
> > -> #3 (&base->lock){-.-.}:
> >         __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
> >         _raw_spin_lock_irqsave+0x99/0xd0 kernel/locking/spinlock.c:152
> >         lock_timer_base+0xbb/0x2b0 kernel/time/timer.c:937
> >         __mod_timer kernel/time/timer.c:1009 [inline]
> >         mod_timer kernel/time/timer.c:1101 [inline]
> >         add_timer+0x895/0x1490 kernel/time/timer.c:1137
> >         __queue_delayed_work+0x249/0x380 kernel/workqueue.c:1533
> >         queue_delayed_work_on+0x1a2/0x1f0 kernel/workqueue.c:1558
> >         queue_delayed_work include/linux/workqueue.h:527 [inline]
> >         schedule_delayed_work include/linux/workqueue.h:628 [inline]
> >         psi_group_change kernel/sched/psi.c:485 [inline]
> >         psi_task_change+0x3f1/0x5f0 kernel/sched/psi.c:534
> >         psi_enqueue kernel/sched/stats.h:82 [inline]
> >         enqueue_task kernel/sched/core.c:727 [inline]
> >         activate_task+0x21a/0x430 kernel/sched/core.c:751
> >         wake_up_new_task+0x527/0xd20 kernel/sched/core.c:2423
> >         _do_fork+0x33b/0x11d0 kernel/fork.c:2247
> >         kernel_thread+0x34/0x40 kernel/fork.c:2281
> >         rest_init+0x28/0x372 init/main.c:409
> >         arch_call_rest_init+0xe/0x1b
> >         start_kernel+0x873/0x8ae init/main.c:741
> >         x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:470
> >         x86_64_start_kernel+0x76/0x79 arch/x86/kernel/head64.c:451
> >         secondary_startup_64+0xa4/0xb0 arch/x86/kernel/head_64.S:243

That thing is fairly new; I don't think we used to have this dependency
prior to PSI.

Johannes, can we move that mod_timer out from under rq->lock? At worst
we can use an irq_work to self-ipi.
