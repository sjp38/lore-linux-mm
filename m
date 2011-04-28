Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 526F36B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 17:51:28 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3SLebw3007025
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 17:40:37 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3SLpPYn1261728
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 17:51:25 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3SHpDxL015951
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 14:51:14 -0300
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
From: john stultz <johnstul@us.ibm.com>
In-Reply-To: <alpine.LFD.2.02.1104282251080.3005@ionos>
References: <20110426112756.GF4308@linux.vnet.ibm.com>
	 <20110426183859.6ff6279b@neptune.home>
	 <20110426190918.01660ccf@neptune.home>
	 <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
	 <alpine.LFD.2.02.1104262314110.3323@ionos>
	 <20110427081501.5ba28155@pluto.restena.lu>
	 <20110427204139.1b0ea23b@neptune.home>
	 <alpine.LFD.2.02.1104272351290.3323@ionos>
	 <alpine.LFD.2.02.1104281051090.19095@ionos>
	 <BANLkTinB5S7q88dch78i-h28jDHx5dvfQw@mail.gmail.com>
	 <20110428102609.GJ2135@linux.vnet.ibm.com>
	 <1303997401.7819.5.camel@marge.simson.net>
	 <BANLkTik4+PAGHF-9KREYk8y+KDQLDAp2Mg@mail.gmail.com>
	 <alpine.LFD.2.02.1104282044120.3005@ionos>
	 <20110428222301.0b745a0a@neptune.home>
	 <alpine.LFD.2.02.1104282227340.3005@ionos>
	 <20110428224444.43107883@neptune.home>
	 <alpine.LFD.2.02.1104282251080.3005@ionos>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 14:51:20 -0700
Message-ID: <1304027480.2971.121.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Bruno =?ISO-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>, sedat.dilek@gmail.com, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Thu, 2011-04-28 at 23:04 +0200, Thomas Gleixner wrote:
> On Thu, 28 Apr 2011, Bruno PrA(C)mont wrote:
> > Timer List Version: v0.6
> > HRTIMER_MAX_CLOCK_BASES: 3
> > now at 1150126155286 nsecs
> > 
> > cpu: 0
> >  clock 0:
> >   .base:       c1559360
> >   .index:      0
> >   .resolution: 1 nsecs
> >   .get_time:   ktime_get_real
> >   .offset:     1304021489280954699 nsecs
> > active timers:
> >  #0: def_rt_bandwidth, sched_rt_period_timer, S:01, enqueue_task_rt, swapper/1
> >  # expires at 1304028703000000000-1304028703000000000 nsecs [in 1304027552873844714 to 1304027552873844714 nsecs]
> 
> Ok, that expiry time is obviously bogus as it does not account the offset:
> 
> So in reality it's: expires in: 6063592890015ns 
> 
> Which is still completely wrong. The timer should expire at max a
> second from now. But it's going to expire in 6063.592890015 seconds
> from now, which is pretty much explaining the after 2hrs stuff got
> going again.
> 
> But the real interesting question is why he heck is that timer on
> CLOCK_REALTIME ???? It is initalized for CLOCK_MONOTONIC.
> 
> /me suspects hrtimer changes to be the real culprit.

I'm not seeing anything on right off, but it does smell like
e06383db9ec591696a06654257474b85bac1f8cb would be where such an issue
would crop up.

Bruno, could you try checking out e06383db9ec, confirming it still
occurs (and then maybe seeing if it goes away at e06383db9ec^1)?

I'll keep digging in the meantime.

thanks
-john






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
