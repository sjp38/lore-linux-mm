Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 38A146B0033
	for <linux-mm@kvack.org>; Sun,  3 Dec 2017 09:48:20 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 80so3133503wmb.7
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 06:48:20 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x82si3651627wmx.84.2017.12.03.06.48.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 03 Dec 2017 06:48:19 -0800 (PST)
Date: Sun, 3 Dec 2017 15:48:14 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: BUG: workqueue lockup (2)
In-Reply-To: <CACT4Y+bGNU1WkyHW3nNBg49rhg8uN1j0sA0DxRj5cmZOSmsWSQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1712031547010.2199@nanos>
References: <94eb2c03c9bc75aff2055f70734c@google.com> <CACT4Y+bGNU1WkyHW3nNBg49rhg8uN1j0sA0DxRj5cmZOSmsWSQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Philippe Ombredanne <pombredanne@nexb.com>, syzkaller-bugs@googlegroups.com

On Sun, 3 Dec 2017, Dmitry Vyukov wrote:

> On Sun, Dec 3, 2017 at 3:31 PM, syzbot
> <bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com>
> wrote:
> > Hello,
> >
> > syzkaller hit the following crash on
> > 2db767d9889cef087149a5eaa35c1497671fa40f
> > git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
> > compiler: gcc (GCC) 7.1.1 20170620
> > .config is attached
> > Raw console output is attached.
> >
> > Unfortunately, I don't have any reproducer for this bug yet.
> >
> >
> > BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 48s!
> > BUG: workqueue lockup - pool cpus=0-1 flags=0x4 nice=0 stuck for 47s!
> > Showing busy workqueues and worker pools:
> > workqueue events: flags=0x0
> >   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
> >     pending: perf_sched_delayed, vmstat_shepherd, jump_label_update_timeout,
> > cache_reap
> > workqueue events_power_efficient: flags=0x80
> >   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
> >     pending: neigh_periodic_work, neigh_periodic_work, do_cache_clean,
> > reg_check_chans_work
> > workqueue mm_percpu_wq: flags=0x8
> >   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
> >     pending: vmstat_update
> > workqueue writeback: flags=0x4e
> >   pwq 4: cpus=0-1 flags=0x4 nice=0 active=1/256
> >     in-flight: 3401:wb_workfn
> > workqueue kblockd: flags=0x18
> >   pwq 1: cpus=0 node=0 flags=0x0 nice=-20 active=1/256
> >     pending: blk_mq_timeout_work
> > pool 4: cpus=0-1 flags=0x4 nice=0 hung=0s workers=11 idle: 3423 4249 92 21
> 
> 
> This error report does not look actionable. Perhaps if code that
> detect it would dump cpu/task stacks, it would be actionable.

That might be related to the RCU stall issue we are chasing, where a timer
does not fire for yet unknown reasons. We have a reproducer now and
hopefully a solution in the next days.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
