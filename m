Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4F16B0036
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 10:35:53 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id u56so153969wes.38
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 07:35:52 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id xt8si2991154wjb.55.2014.09.25.07.35.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 07:35:52 -0700 (PDT)
Date: Thu, 25 Sep 2014 16:35:49 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: hrtimer deadlock caused by nohz_full
In-Reply-To: <20140925141425.GA21702@redhat.com>
Message-ID: <alpine.DEB.2.10.1409251630210.4604@nanos>
References: <20140925141425.GA21702@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: linux-mm@kvack.org, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 25 Sep 2014, Dave Jones wrote:

> Got this on a box that had been fuzzing for 12 hours or so.
> There's also some timer stuff going on htere, so cc'ing the usual suspects.

And it's a hrtimer lockup
 
>  [<ffffffffa10f95f8>] ? hrtimer_try_to_cancel+0x58/0x1f0
>  [<ffffffffa10d103d>] ? lock_release+0x1d/0x300
>  [<ffffffffa10d103d>] ? lock_release+0x1d/0x300
>  [<ffffffffa10f95f8>] ? hrtimer_try_to_cancel+0x58/0x1f0
>  [<ffffffffa10d103d>] ? lock_release+0x1d/0x300
>  <<EOE>>  <IRQ>  [<ffffffffa1823ac4>] _raw_spin_unlock_irqrestore+0x24/0x70
>  [<ffffffffa10f95f8>] hrtimer_try_to_cancel+0x58/0x1f0
>  [<ffffffffa10f97aa>] hrtimer_cancel+0x1a/0x30
>  [<ffffffffa110a0e7>] tick_nohz_restart+0x17/0x90
>  [<ffffffffa110af38>] __tick_nohz_full_check+0xc8/0xe0
>  [<ffffffffa110af5e>] nohz_full_kick_work_func+0xe/0x10
>  [<ffffffffa117c9bf>] irq_work_run_list+0x4f/0x70
>  [<ffffffffa117ca0a>] irq_work_run+0x2a/0x60
>  [<ffffffffa10f82eb>] update_process_times+0x5b/0x70
>  [<ffffffffa1109dc5>] tick_sched_handle.isra.21+0x25/0x60
>  [<ffffffffa110a0b1>] tick_sched_timer+0x41/0x60
>  [<ffffffffa10f8c71>] __run_hrtimer+0x81/0x480
>  [<ffffffffa110a070>] ? tick_sched_do_timer+0x90/0x90
>  [<ffffffffa10f9b27>] hrtimer_interrupt+0x107/0x260
>  [<ffffffffa10331a4>] local_apic_timer_interrupt+0x34/0x60
>  [<ffffffffa182734f>] smp_apic_timer_interrupt+0x3f/0x60
>  [<ffffffffa182576f>] apic_timer_interrupt+0x6f/0x80

hrtimer_interrupt
  tick_sched_timer
    tick_sched_handle
      update_process_times
        irq_work_run
	  irq_work_run_list
	    nohz_full_kick_work_func
	      __tick_nohz_full_check
	        tick_nohz_restart
                  hrtimer_cancel

And that hrtimer_cancel is:

static void tick_nohz_restart(struct tick_sched *ts, ktime_t now)
{
	hrtimer_cancel(&ts->sched_timer);

Now, that's really bad because we are in the timer callback of
ts->sched_timer. So hrtimer_cancel will loop forever waiting for the
callback to complete.

Frederic !?!?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
