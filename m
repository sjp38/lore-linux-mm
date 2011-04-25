Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 580BA8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:26:39 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3PH0qq2020818
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:00:52 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3PHQXAB092222
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:26:33 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3PHQXQK017968
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:26:33 -0400
Date: Mon, 25 Apr 2011 10:26:32 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110425172632.GA2468@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20110424202158.45578f31@neptune.home>
 <20110424235928.71af51e0@neptune.home>
 <20110425114429.266A.A69D9226@jp.fujitsu.com>
 <BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
 <20110425111705.786ef0c5@neptune.home>
 <BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
 <20110425180450.1ede0845@neptune.home>
 <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Mon, Apr 25, 2011 at 09:31:03AM -0700, Linus Torvalds wrote:
> 2011/4/25 Bruno Premont <bonbons@linux-vserver.org>:
> >
> > kmemleak reports 86681 new leaks between shortly after boot and -2 state.
> > (and 2348 additional ones between -2 and -4).
> 
> I wouldn't necessarily trust kmemleak with the whole RCU-freeing
> thing. In your slubinfo reports, the kmemleak data itself also tends
> to overwhelm everything else - none of it looks unreasonable per se.
> 
> That said, you clearly have a *lot* of filp entries. I wouldn't
> consider it unreasonable, though, because depending on load those may
> well be fine. Perhaps you really do have some application(s) that hold
> thousands of files open. The default file limit is 1024 (I think), but
> you can raise it, and some programs do end up opening tens of
> thousands of files for filesystem scanning purposes.
> 
> That said, I would suggest simply trying a saner kernel configuration,
> and seeing if that makes a difference:
> 
> > Yes, it's uni-processor system, so SMP=n.
> > TINY_RCU=y, PREEMPT_VOLUNTARY=y (whole /proc/config.gz attached keeping
> > compression)
> 
> I'm not at all certain that TINY_RCU is appropriate for
> general-purpose loads. I'd call it more of a "embedded low-performance
> option".
> 
> The _real_ RCU implementation ("tree rcu") forces quiescent states
> every few jiffies and has logic to handle "I've got tons of RCU
> events, I really need to start handling them now". All of which I
> think tiny-rcu lacks.
> 
> So right now I suspect that you have a situation where you just have a
> simple load that just ends up never triggering any RCU cleanup, and
> the tiny-rcu thing just keeps on gathering events and delays freeing
> stuff almost arbitrarily long.
> 
> So try CONFIG_PREEMPT and CONFIG_TREE_PREEMPT_RCU to see if the
> behavior goes away. That would confirm the "it's just tinyrcu being
> too dang stupid" hypothesis.

CONFIG_TINY_RCU is a bit more stupid than CONFIG_TREE_RCU, and ditto
for both PREEMPT versions.  CONFIG_TREE_RCU will throttle RCU callback
invocation.  It defaults to invoking no more than 10 at a time, until
the number of outstanding callbacks on a given CPU exceeds 10,000,
at which point it goes into emergency mode and just processes all the
remaining callbacks.

In contrast, the TINY versions always process all the remaining
callbacks.  There are two reasons for the difference:

1.	The fact that TINY has but one CPU speeds up the grace periods
	(particularly for synchronize_rcu() in CONFIG_TINY_RCU, which
	is essentially a no-op), so that callbacks should be invoked in
	a more timely manner.

2.	There is only one CPU for TINY, so the scenarios where one
	CPU keeps another CPU totally busy invoking RCU callbacks
	cannot happen.

3.	TINY is supposed to be TINY, so I figured I should add RCU
	callback-throttling smarts when and if they proved to be needed.
	(It is not clear to me that this problem means that more smarts
	are needed, but if they are, I will of course add them.)

It is quite possible that some adjustments are needed in the defaults
for CONFIG_TREE_RCU and CONFIG_TREE_PREEMPT_RCU due to the heavier
load from the tree-walking changes.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
