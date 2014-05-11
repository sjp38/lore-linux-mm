Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 53D8E6B0036
	for <linux-mm@kvack.org>; Sat, 10 May 2014 21:17:15 -0400 (EDT)
Received: by mail-yh0-f54.google.com with SMTP id i57so5215266yha.27
        for <linux-mm@kvack.org>; Sat, 10 May 2014 18:17:15 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id g10si10808081yhi.12.2014.05.10.18.17.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 10 May 2014 18:17:14 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 10 May 2014 19:17:14 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 6E7401FF003D
	for <linux-mm@kvack.org>; Sat, 10 May 2014 19:17:11 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4B1HBDW3473890
	for <linux-mm@kvack.org>; Sun, 11 May 2014 03:17:11 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s4B1L2Cm014874
	for <linux-mm@kvack.org>; Sat, 10 May 2014 19:21:02 -0600
Date: Sat, 10 May 2014 18:17:08 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: vmstat: On demand vmstat workers V4
Message-ID: <20140511011708.GD4827@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20140508142903.c2ef166c95d2b8acd0d7ea7d@linux-foundation.org>
 <alpine.DEB.2.02.1405090003120.6261@ionos.tec.linutronix.de>
 <alpine.DEB.2.10.1405090949170.11318@gentwo.org>
 <alpine.DEB.2.02.1405091659350.6261@ionos.tec.linutronix.de>
 <alpine.DEB.2.10.1405091027040.11318@gentwo.org>
 <alpine.DEB.2.02.1405092358390.6261@ionos.tec.linutronix.de>
 <20140509234745.GB8754@linux.vnet.ibm.com>
 <20140510004843.GB32393@localhost.localdomain>
 <alpine.DEB.2.02.1405101423360.6261@ionos.tec.linutronix.de>
 <20140510131422.GA13660@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140510131422.GA13660@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, John Stultz <john.stultz@linaro.org>

On Sat, May 10, 2014 at 03:14:25PM +0200, Frederic Weisbecker wrote:
> On Sat, May 10, 2014 at 02:31:28PM +0200, Thomas Gleixner wrote:
> > On Sat, 10 May 2014, Frederic Weisbecker wrote:
> > > But I still have the plan to make the timekeeper use the full sysidle
> > > facility in order to adaptively get to dynticks idle.
> > > 
> > > Reminder for others: in NO_HZ_FULL, the timekeeper (always CPU 0) stays
> > > completely periodic. It can't enter in dynticks idle mode because it
> > > must maintain timekeeping on behalf of full dynticks CPUs. So that's
> > > a power issue.
> > > 
> > > But Paul has a feature in RCU that lets us know when all CPUs are idle
> > > and the timekeeper can finally sleep. Then when a full nohz CPU wakes
> > > up from idle, it sends an IPI to the timekeeper if needed so the latter
> > > restarts timekeeping maintainance.
> > >
> > > It's not complicated to add to the timer code.
> > > Most of the code is already there, in RCU, for a while already.
> > > 
> > > Are we keeping that direction? 
> > 
> > So the idea is that the timekeeper stays on cpu0, but if everything is
> > idle it is allowed to take a long nap as well. So if some other cpu
> > wakes up it updates timekeeping without taking over the time keeper
> > duty and if it has work to do, it kicks cpu0 into gear. If it just
> > goes back to sleep, then nothing to do.

Hmmm...  If RCU is supposed to ignore the fact that one of the other
CPUs woke up momentarily, we will need to adjust things a bit.

> Exactly! Except perhaps the last sentence "If it just goes back to sleep,
> then nothing to do.", I didn't think about that although this special case
> is quite frequent indeed when an interrupt fires on idle but no task is woken up.
> 
> Maybe I should move the code that fires the IPI to cpu0, if it is sleeping,
> on irq exit (the plan was to do it right away on irq enter) and fire it
> only if need_resched().

And of course if that code path contains any RCU read-side critical
sections, RCU absolutely cannot ignore that CPU's momentary wakeup.

							Thanx, Paul

> > No objections from my side.
> 
> Great! Thanks for checking that!
> 
> > 
> > Thanks,
> > 
> > 	tglx
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
