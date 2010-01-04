Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 84299600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 11:57:07 -0500 (EST)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o04GlSHe016295
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 11:47:28 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o04Gutqj1880066
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 11:56:55 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o04GurHm015921
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 11:56:55 -0500
Date: Mon, 4 Jan 2010 08:56:52 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] asynchronous page fault.
Message-ID: <20100104165652.GC6748@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20091228093606.9f2e666c.kamezawa.hiroyu@jp.fujitsu.com> <1261989047.7135.3.camel@laptop> <27db4d47e5a95e7a85942c0278892467.squirrel@webmail-b.css.fujitsu.com> <1261996258.7135.67.camel@laptop> <1261996841.7135.69.camel@laptop> <1262448844.6408.93.camel@laptop> <20100104030234.GF32568@linux.vnet.ibm.com> <1262591604.4375.4075.camel@twins> <20100104155559.GA6748@linux.vnet.ibm.com> <1262620974.6408.169.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1262620974.6408.169.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 04, 2010 at 05:02:54PM +0100, Peter Zijlstra wrote:
> On Mon, 2010-01-04 at 07:55 -0800, Paul E. McKenney wrote:
> > > Well, I was thinking srcu to have this force quiescent state in
> > > call_srcu() much like you did for the preemptible rcu.
> > 
> > Ah, so the idea would be that you register a function with the srcu_struct
> > that is invoked when some readers are stuck for too long in their SRCU
> > read-side critical sections?  Presumably you also supply a time value for
> > "too long" as well.  Hmmm...  What do you do, cancel the corresponding
> > I/O or something? 
> 
> Hmm, I was more thinking along the lines of:
> 
> say IDX is the current counter idx.
> 
> if (pending > thresh) {
>   flush(!IDX)

This flushes pending I/Os?

>   force_flip_counter();

If this is internal to SRCU, what it would do is check for CPUs being
offline or in dyntick-idle state.  Or was your thought that this is
where I invoke callbacks into your code to do whatever can be done to
wake up the sleeping readers?

> }
> 
> Since we explicitly hold a reference on IDX, we can actually wait for !
> IDX to reach 0 and flush those callbacks.

One other thing -- if I merge SRCU into the tree-based infrastructure,
I should be able to eliminate the need for srcu_read_lock() to return
the index (and thus for srcu_read_unlock() to take it as an argument).
So the index would be strictly internal, as it currently is with the
other flavors of RCU.

> We then force-flip the counter, so that even if all callbacks (or the
> majority) were not for !IDX but part of IDX, we'd be able to flush them
> on the next call_srcu() because that will then hold a ref on the new
> counter index.

We can certainly defer callbacks to a later grace period.  What we cannot
do is advance the counter until all readers for the current grace period
have exited their SRCU read-side critical sections.

> Or am I missing something obvious?

Or maybe I am.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
