Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BDE4E600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:56:07 -0500 (EST)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o04FoBJ3018921
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 10:50:11 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o04Fu0AC125712
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 10:56:00 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o04FtxpX027841
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 10:56:00 -0500
Date: Mon, 4 Jan 2010 07:55:59 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] asynchronous page fault.
Message-ID: <20100104155559.GA6748@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com> <1261915391.15854.31.camel@laptop> <20091228093606.9f2e666c.kamezawa.hiroyu@jp.fujitsu.com> <1261989047.7135.3.camel@laptop> <27db4d47e5a95e7a85942c0278892467.squirrel@webmail-b.css.fujitsu.com> <1261996258.7135.67.camel@laptop> <1261996841.7135.69.camel@laptop> <1262448844.6408.93.camel@laptop> <20100104030234.GF32568@linux.vnet.ibm.com> <1262591604.4375.4075.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1262591604.4375.4075.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 04, 2010 at 08:53:23AM +0100, Peter Zijlstra wrote:
> On Sun, 2010-01-03 at 19:02 -0800, Paul E. McKenney wrote:
> > It would not be all that hard for me to make a call_srcu(), but...
> > 
> > 1.      How are you avoiding OOM by SRCU callback?  (I am sure you
> >         have this worked out, but I do have to ask!)
> 
> Well, I was thinking srcu to have this force quiescent state in
> call_srcu() much like you did for the preemptible rcu.

Ah, so the idea would be that you register a function with the srcu_struct
that is invoked when some readers are stuck for too long in their SRCU
read-side critical sections?  Presumably you also supply a time value for
"too long" as well.  Hmmm...  What do you do, cancel the corresponding
I/O or something?

This would not be hard once I get SRCU folded into the treercu
infrastructure.  However, at the moment, SRCU has no way of tracking
which tasks are holding things up.  So not 2.6.34 material, but definitely
doable longer term.

> Alternatively we could actively throttle the call_srcu() call when we've
> got too much pending work.

This could be done with the existing SRCU implementation.  This could be
a call to a function you registered.  In theory, it would be possible
to make call_srcu() refuse to enqueue a callback when there were too
many, but that really badly violates the spirit of the call_rcu() family
of functions.

> > 2.      How many srcu_struct data structures are you envisioning?
> >         One globally?  One per process?  One per struct vma?
> >         (Not necessary to know this for call_srcu(), but will be needed
> >         as I work out how to make SRCU scale with large numbers of CPUs.)
> 
> For this patch in particular, one global one, covering all vmas.

Whew!!!  ;-)

Then it would still be feasible for the CPU-hotplug code to scan all
SRCU structures, if need be.  (The reason that SRCU gets away without
worrying about CPU hotplug now is that it doesn't keep track of which
tasks are in read-side critical sections.)

> One reason to keep the vma RCU domain separate from other RCU objects is
> that these VMA thingies can have rather long quiescent periods due to
> this sleep stuff. So mixing that in with other RCU users which have much
> better defined periods will just degrade everything bringing that OOM
> scenario much closer.

Fair enough!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
