Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D406F6B00F4
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 14:24:15 -0500 (EST)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o05JEErC001131
	for <linux-mm@kvack.org>; Tue, 5 Jan 2010 14:14:14 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o05JNvek141592
	for <linux-mm@kvack.org>; Tue, 5 Jan 2010 14:23:57 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o05JNua7013517
	for <linux-mm@kvack.org>; Tue, 5 Jan 2010 14:23:56 -0500
Date: Tue, 5 Jan 2010 11:23:55 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-ID: <20100105192355.GK6714@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com> <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain> <alpine.LFD.2.00.1001050810380.3630@localhost.localdomain> <87wrzwbh0z.fsf@basil.nowhere.org> <alpine.LFD.2.00.1001050950500.3630@localhost.localdomain> <alpine.DEB.2.00.1001051211000.2246@router.home> <alpine.LFD.2.00.1001051019280.3630@localhost.localdomain> <20100105185542.GH6714@linux.vnet.ibm.com> <alpine.LFD.2.00.1001051059480.3630@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1001051059480.3630@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 05, 2010 at 11:08:46AM -0800, Linus Torvalds wrote:
> 
> 
> On Tue, 5 Jan 2010, Paul E. McKenney wrote:
> > 
> > But on many systems, it does take some time for the idle reads to make
> > their way to the CPU that just acquired the lock.
> 
> Yes. But the point is that there is lots of them.
> 
> So think of it this way: every time _one_ CPU acquires a lock (and 
> then releases it), _all_ CPU's will read the new value. Imagine the 
> cross-socket traffic.

Yep, been there, and with five-microsecond cross-"socket" latencies.
Of course, the CPU clock frequencies were a bit slower back then.

> In contrast, doing just a single xadd (which replaces the whole 
> "spin_lock+non-atomics+spin_unlock"), every times _once_ CPU cquires a 
> lock, that's it. The other CPU's arent' all waiting in line for the lock 
> to be released, and reading the cacheline to see if it's their turn.
> 
> Sure, after they got the lock they'll all eventually end up reading from 
> that cacheline that contains 'struct mm_struct', but that's something we 
> could even think about trying to minimize by putting the mmap_sem as far 
> away from the other fields as possible.
> 
> Now, it's very possible that if you have a broadcast model of cache 
> coherency, none of this much matters and you end up with almost all the 
> same bus traffic anyway. But I do think it could matter a lot.

I have seen systems that work both ways.  If the CPU has enough time
between getting the cache line in unlocked state to lock it, do the
modification, and release the lock before the first in the flurry of
reads arrives, then performance will be just fine.  Each reader will
see the cache line with an unlocked lock and life will be good.

On the other hand, as you say, if the first in the flurry of reads arrives
before the CPU has managed to make its way through the critical section,
then your n^2 nightmare comes true.

If the critical section operates only on the cache line containing the
lock, and if the critical section has only a handful of instructions,
I bet you win on almost all platforms.  But, like you, I would still
prefer the xadd (or xchg or whatever) to the lock, where feasible.
But you cannot expect all systems to see a major performance boost from
switching from locks to xadds.  Often, all you get is sounder sleep.
Which is valuable in its own right.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
