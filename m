Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id ABADE6B0037
	for <linux-mm@kvack.org>; Fri,  9 May 2014 19:47:50 -0400 (EDT)
Received: by mail-yk0-f180.google.com with SMTP id q9so4068477ykb.25
        for <linux-mm@kvack.org>; Fri, 09 May 2014 16:47:50 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id w75si7314094yhh.156.2014.05.09.16.47.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 09 May 2014 16:47:50 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 9 May 2014 17:47:49 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 287E03E4003F
	for <linux-mm@kvack.org>; Fri,  9 May 2014 17:47:47 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s49Nll2v000504
	for <linux-mm@kvack.org>; Sat, 10 May 2014 01:47:47 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s49NpbL8021436
	for <linux-mm@kvack.org>; Fri, 9 May 2014 17:51:38 -0600
Date: Fri, 9 May 2014 16:47:45 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: vmstat: On demand vmstat workers V4
Message-ID: <20140509234745.GB8754@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <alpine.DEB.2.10.1405081033090.23786@gentwo.org>
 <20140508142903.c2ef166c95d2b8acd0d7ea7d@linux-foundation.org>
 <alpine.DEB.2.02.1405090003120.6261@ionos.tec.linutronix.de>
 <alpine.DEB.2.10.1405090949170.11318@gentwo.org>
 <alpine.DEB.2.02.1405091659350.6261@ionos.tec.linutronix.de>
 <alpine.DEB.2.10.1405091027040.11318@gentwo.org>
 <alpine.DEB.2.02.1405092358390.6261@ionos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1405092358390.6261@ionos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, John Stultz <john.stultz@linaro.org>

On Sat, May 10, 2014 at 12:57:15AM +0200, Thomas Gleixner wrote:
> On Fri, 9 May 2014, Christoph Lameter wrote:
> > On Fri, 9 May 2014, Thomas Gleixner wrote:
> > > I understand why you want to get this done by a housekeeper, I just
> > > did not understand why we need this whole move it around business is
> > > required.
> > 
> > This came about because of another objection against having it simply
> > fixed to a processor. After all that processor may be disabled etc etc.
> 
> I really regret that I did not pay more attention (though my cycle
> constraints simply do not allow it).

As far as I can see, the NO_HZ_FULL timekeeping CPU is always zero.  If it
can change in NO_HZ_FULL kernels, RCU will do some very strange things!

One possible issue here is that Christoph's patch is unconditional.
It takes effect for both NO_HZ_FULL and !NO_HZ_FULL.  If I recall
correctly, the timekeeping CPU -can- change in !NO_HZ_FULL kernels,
which might be what Christoph was trying to take into account.

> This is the typical overengineering failure: 
> 
>   Before we even have a working proof that we can solve the massive
>   complex basic problem with the price of a dedicated housekeeper, we
>   try to make the housekeeper itself a moving target with the price of
>   making the problem exponential(unknown) instead of simply unknown.
> 
> I really cannot figure out why a moving housekeeper would be a
> brilliant idea at all, but I'm sure there is some magic use case in
> some other disjunct universe.
> 
> Whoever complained and came up with the NOT SO brilliant idea to make
> the housekeeper a moving target, come please forth and explain:
> 
> - How this can be done without having a working solution with a
>   dedicated housekeeper in the first place
> 
> - How this can be done without knowing what implication it has w/o
>   seing the complexity of a dedicated housekeeper upfront.
> 
> Keep it simple has always been and still is the best engineering
> principle.

If someone decides to make tick_do_timer_cpu non-constant in NO_HZ_FULL
CPUs, they will break unless/until I make RCU deal with that sort
of thing, at least for NO_HZ_FULL_SYSIDLE kernels.  ;-)

> We all know that we can do large scale overhauls in a very controlled
> way if the need arises. But going for the most complex solution while
> not knowing whether the least complex solution is feasible at all is
> outright stupid or beyond.
> 
> Unless someone comes up with a reasonable explantion for all of this I
> put a general NAK on patches which are directed to kernel/time/*
> 
> Correction:
> 
> I'm taking patches right away which undo any damage which has been
> applied w/o me noticing because I trusted the responsible developers /
> maintainers.
> 
> Preferrably those patches arrive before my return from LinuxCon Japan.

I could easily have missed something, but as far as I know, there is
nothing in the current kernel that allows tick_do_timer_cpu to move in
NO_HZ_FULL kernels.

Hmmm...  Well, I -do- have a gratuitous ACCESS_ONCE() around one fetch
of tick_do_timer_cpu that happens only in NO_HZ_FULL kernels.  I will
remove it.

							Thanx, Paul

> Thanks,
> 
> 	tglx
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
