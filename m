Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 83BD66B00EE
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 13:57:19 -0500 (EST)
Date: Tue, 5 Jan 2010 10:56:37 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <alpine.DEB.2.00.1001051235200.2246@router.home>
Message-ID: <alpine.LFD.2.00.1001051052150.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com> <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com> <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain> <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com> <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
 <alpine.LFD.2.00.1001050810380.3630@localhost.localdomain> <87wrzwbh0z.fsf@basil.nowhere.org> <alpine.LFD.2.00.1001050950500.3630@localhost.localdomain> <alpine.DEB.2.00.1001051211000.2246@router.home> <alpine.LFD.2.00.1001051019280.3630@localhost.localdomain>
 <alpine.DEB.2.00.1001051235200.2246@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Tue, 5 Jan 2010, Christoph Lameter wrote:
> 
> There will not be much spinning. The cacheline will be held exclusively by
> one processor. A request by other processors for shared access to the
> cacheline will effectively stop the execution on those processors until
> the cacheline is available.

AT WHICH POINT THEY ALL RACE TO GET IT TO SHARED MODE, only to then have 
one of them actually see that it got a ticket!

Don't you see the problem? The spinlock (with ticket locks) essentially 
does the "xadd" atomic increment anyway, but then it _waits_ for it. All 
totally pointless, and all just making for problems, and wasting CPU time 
and causing more cross-node traffic.

In contrast, a native xadd-based rwsem will basically do the atomic 
increment (that ticket spinlocks also do) and then just go on with its 
life. Never waiting for all the other CPU's to also do their ticket 
spinlocks.

The "short critical region" you talk about is totally meaningless, since 
the contention will mean that everybody is waiting and hitting that 
cacheline for a long time regardless - they'll be waiting for O(n) 
_other_ CPU's to get the lock first!

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
