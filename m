Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9668D6B0036
	for <linux-mm@kvack.org>; Sat, 10 May 2014 21:39:01 -0400 (EDT)
Received: by mail-yh0-f52.google.com with SMTP id z6so4778994yhz.39
        for <linux-mm@kvack.org>; Sat, 10 May 2014 18:39:01 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id a24si10786574yha.151.2014.05.10.18.39.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 10 May 2014 18:39:01 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 10 May 2014 19:39:00 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 8EF3919D803E
	for <linux-mm@kvack.org>; Sat, 10 May 2014 19:38:51 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4B1c7vw8847732
	for <linux-mm@kvack.org>; Sun, 11 May 2014 03:38:07 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s4B1gm4w013719
	for <linux-mm@kvack.org>; Sat, 10 May 2014 19:42:49 -0600
Date: Sat, 10 May 2014 18:38:54 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: vmstat: On demand vmstat workers V4
Message-ID: <20140511013854.GL4827@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <alpine.DEB.2.10.1405090949170.11318@gentwo.org>
 <alpine.DEB.2.02.1405091659350.6261@ionos.tec.linutronix.de>
 <alpine.DEB.2.10.1405091027040.11318@gentwo.org>
 <alpine.DEB.2.02.1405092358390.6261@ionos.tec.linutronix.de>
 <20140509234745.GB8754@linux.vnet.ibm.com>
 <20140510004843.GB32393@localhost.localdomain>
 <alpine.DEB.2.02.1405101423360.6261@ionos.tec.linutronix.de>
 <20140510131422.GA13660@localhost.localdomain>
 <20140511011708.GD4827@linux.vnet.ibm.com>
 <20140511013029.GC13660@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140511013029.GC13660@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, John Stultz <john.stultz@linaro.org>

On Sun, May 11, 2014 at 03:30:31AM +0200, Frederic Weisbecker wrote:
> On Sat, May 10, 2014 at 06:17:08PM -0700, Paul E. McKenney wrote:
> > On Sat, May 10, 2014 at 03:14:25PM +0200, Frederic Weisbecker wrote:
> > > On Sat, May 10, 2014 at 02:31:28PM +0200, Thomas Gleixner wrote:
> > > > On Sat, 10 May 2014, Frederic Weisbecker wrote:
> > > > > But I still have the plan to make the timekeeper use the full sysidle
> > > > > facility in order to adaptively get to dynticks idle.
> > > > > 
> > > > > Reminder for others: in NO_HZ_FULL, the timekeeper (always CPU 0) stays
> > > > > completely periodic. It can't enter in dynticks idle mode because it
> > > > > must maintain timekeeping on behalf of full dynticks CPUs. So that's
> > > > > a power issue.
> > > > > 
> > > > > But Paul has a feature in RCU that lets us know when all CPUs are idle
> > > > > and the timekeeper can finally sleep. Then when a full nohz CPU wakes
> > > > > up from idle, it sends an IPI to the timekeeper if needed so the latter
> > > > > restarts timekeeping maintainance.
> > > > >
> > > > > It's not complicated to add to the timer code.
> > > > > Most of the code is already there, in RCU, for a while already.
> > > > > 
> > > > > Are we keeping that direction? 
> > > > 
> > > > So the idea is that the timekeeper stays on cpu0, but if everything is
> > > > idle it is allowed to take a long nap as well. So if some other cpu
> > > > wakes up it updates timekeeping without taking over the time keeper
> > > > duty and if it has work to do, it kicks cpu0 into gear. If it just
> > > > goes back to sleep, then nothing to do.
> > 
> > Hmmm...  If RCU is supposed to ignore the fact that one of the other
> > CPUs woke up momentarily, we will need to adjust things a bit.
> 
> Maybe not that much actually.
> 
> > 
> > > Exactly! Except perhaps the last sentence "If it just goes back to sleep,
> > > then nothing to do.", I didn't think about that although this special case
> > > is quite frequent indeed when an interrupt fires on idle but no task is woken up.
> > > 
> > > Maybe I should move the code that fires the IPI to cpu0, if it is sleeping,
> > > on irq exit (the plan was to do it right away on irq enter) and fire it
> > > only if need_resched().
> > 
> > And of course if that code path contains any RCU read-side critical
> > sections, RCU absolutely cannot ignore that CPU's momentary wakeup.
> 
> Sure the core RCU still needs to know that the CPU went out of dynticks the
> time of the irq, so we keep the rcu_irq_enter/rcu_irq_exit calls.
> 
> But if the CPU only wakes up to serve an IRQ, it doesn't need to tell the RCU
> sysidle detection about it. The irq entry fixup jiffies on dynticks idle mode,
> this should be enough.

As long as you pass me in a hint so that RCU knows which case it is
dealing with.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
