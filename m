Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AEE6C6B00E7
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 13:46:43 -0500 (EST)
Date: Tue, 5 Jan 2010 12:46:17 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <alpine.LFD.2.00.1001051019280.3630@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1001051235200.2246@router.home>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com> <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com> <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain> <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com> <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
 <alpine.LFD.2.00.1001050810380.3630@localhost.localdomain> <87wrzwbh0z.fsf@basil.nowhere.org> <alpine.LFD.2.00.1001050950500.3630@localhost.localdomain> <alpine.DEB.2.00.1001051211000.2246@router.home>
 <alpine.LFD.2.00.1001051019280.3630@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Jan 2010, Linus Torvalds wrote:

> I hope somebody can time it. Because I think the idle reads on all the
> (unsuccessful) spinlocks will kill it.
>
> Think of it this way: under heavy contention, you'll see a lot of people
> waiting for the spinlocks and one of them succeeds at writing it, reading
> the line. So you get an O(n^2) bus traffic access pattern. In contrast,
> with an xadd, you get O(n) behavior - everybody does _one_ acquire-for-
> write bus access.

There will not be much spinning. The cacheline will be held exclusively by
one processor. A request by other processors for shared access to the
cacheline will effectively stop the execution on those processors until
the cacheline is available.

Access to main memory is mediated by the cache controller anyways. As
long as the cacheline has not been invalidated it will be reused. Maybe
Andi can give us more details on the exact behavior on recent Intel
processors?

One thing that could change with the removal of the spinlock is that the
initial request for the cacheline will not be for read anymore but for
write. This saves us the upgrade from read / shared state to exclusive access.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
