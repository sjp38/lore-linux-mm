Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 456786B0036
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 06:32:39 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id w62so8407598wes.27
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 03:32:38 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id dw7si2217841wib.14.2014.09.03.03.32.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 03 Sep 2014 03:32:38 -0700 (PDT)
Date: Wed, 3 Sep 2014 12:32:27 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 2/2] ksm: provide support to use deferrable timers
 for scanner thread
In-Reply-To: <20140903095815.GK4783@worktop.ger.corp.intel.com>
Message-ID: <alpine.DEB.2.10.1409031212300.3333@nanos>
References: <1408536628-29379-1-git-send-email-cpandya@codeaurora.org> <1408536628-29379-2-git-send-email-cpandya@codeaurora.org> <alpine.LSU.2.11.1408272258050.10518@eggly.anvils> <20140903095815.GK4783@worktop.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Chintan Pandya <cpandya@codeaurora.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Ingo Molnar <mingo@redhat.com>

On Wed, 3 Sep 2014, Peter Zijlstra wrote:
> On Wed, Aug 27, 2014 at 11:02:20PM -0700, Hugh Dickins wrote:
> > Sorry for holding you up, I'm slow. and needed to think about this more,
> > 
> > On Wed, 20 Aug 2014, Chintan Pandya wrote:
> > 
> > > KSM thread to scan pages is scheduled on definite timeout. That wakes up
> > > CPU from idle state and hence may affect the power consumption. Provide
> > > an optional support to use deferrable timer which suites low-power
> > > use-cases.
> > > 
> > > Typically, on our setup we observed, 10% less power consumption with some
> > > use-cases in which CPU goes to power collapse frequently. For example,
> > > playing audio on Soc which has HW based Audio encoder/decoder, CPU
> > > remains idle for longer duration of time. This idle state will save
> > > significant CPU power consumption if KSM don't wakes them up
> > > periodically.
> > > 
> > > Note that, deferrable timers won't be deferred if any CPU is active and
> > > not in IDLE state.

This is completely wrong. A deferrable timer enqueued on a given CPU
is deferred if that very CPU goes idle. The timer subsystem does not
care at all about the other CPUs.

And that very much explains Hughs observations. If the ksm thread
sleeps deferrable on a CPU which is idle for a very long time, it will
be deferred despite work accumulating on other CPUs.

> > > By default, deferrable timers is enabled. To disable deferrable timers,
> > > $ echo 0 > /sys/kernel/mm/ksm/deferrable_timer
> > 
> > I have now experimented.  And, much as I wanted to eliminate the
> > tunable, and just have deferrable timers on, I have come right back
> > to your original position.
> > 
> > I was impressed by how quiet ksmd goes when there's nothing much
> > happening on the machine; but equally, disappointed in how slow
> > it then is to fulfil the outstanding merge work.  I agree with your
> > original assessment, that not everybody will want deferrable timer,
> > the way it is working at present.
> > 
> > I expect that can be fixed, partly by doing more work on wakeup from
> > a deferred timer, according to how long it has been deferred; and
> > partly by not deferring on idle until two passes of the list have been
> > completed.  But that's easier said than done, and might turn out to
> 
> So why not have the timer cancel itself when there is no more work to do
> and start itself up again when there's work added?

Because that requires more work and thoughts than simply slapping a
deferrable timer at the problem and creating a sysfs variable to turn
it on/off.

So looking at Hughs test results I'm quite sure that the deferrable
timer is just another tunable bandaid with dubious value and the
potential of predictable bug/regresssion reports.

So no, I wont merge the schedule_timeout_deferrable() hackery unless
the whole mechanism is usable w/o tunables and regressions.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
