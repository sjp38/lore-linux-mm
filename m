Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 699466B00EC
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 13:55:56 -0500 (EST)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o05ImECw028272
	for <linux-mm@kvack.org>; Tue, 5 Jan 2010 13:48:14 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o05Itjvj1466576
	for <linux-mm@kvack.org>; Tue, 5 Jan 2010 13:55:45 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o05ItgWo030167
	for <linux-mm@kvack.org>; Tue, 5 Jan 2010 13:55:45 -0500
Date: Tue, 5 Jan 2010 10:55:42 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-ID: <20100105185542.GH6714@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain> <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com> <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain> <alpine.LFD.2.00.1001050810380.3630@localhost.localdomain> <87wrzwbh0z.fsf@basil.nowhere.org> <alpine.LFD.2.00.1001050950500.3630@localhost.localdomain> <alpine.DEB.2.00.1001051211000.2246@router.home> <alpine.LFD.2.00.1001051019280.3630@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1001051019280.3630@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 05, 2010 at 10:25:43AM -0800, Linus Torvalds wrote:
> 
> 
> On Tue, 5 Jan 2010, Christoph Lameter wrote:
> > 
> > If the critical section protected by the spinlock is small then the
> > delay will keep the cacheline exclusive until we hit the unlock. This
> > is the case here as far as I can tell.
> 
> I hope somebody can time it. Because I think the idle reads on all the 
> (unsuccessful) spinlocks will kill it.

But on many systems, it does take some time for the idle reads to make
their way to the CPU that just acquired the lock.  My (admittedly dated)
experience is that the CPU acquiring the lock has a few bus clocks
before the cache line containing the lock gets snatched away.

> Think of it this way: under heavy contention, you'll see a lot of people 
> waiting for the spinlocks and one of them succeeds at writing it, reading 
> the line. So you get an O(n^2) bus traffic access pattern. In contrast, 
> with an xadd, you get O(n) behavior - everybody does _one_ acquire-for- 
> write bus access.

xadd (and xchg) certainly are nicer where they apply!

> Remember: the critical section is small, but since you're contending on 
> the spinlock, that doesn't much _help_. The readers are all hitting the 
> lock (and you can try to solve the O(n*2) issue with back-off, but quite 
> frankly, anybody who does that has basically already lost - I'm personally 
> convinced you should never do lock backoff, and instead look at what you 
> did wrong at a higher level instead).

Music to my ears!  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
