Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 119296B00E0
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 12:57:42 -0500 (EST)
Date: Tue, 5 Jan 2010 09:55:43 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <87wrzwbh0z.fsf@basil.nowhere.org>
Message-ID: <alpine.LFD.2.00.1001050950500.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com> <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com> <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain> <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com> <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
 <alpine.LFD.2.00.1001050810380.3630@localhost.localdomain> <87wrzwbh0z.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Tue, 5 Jan 2010, Andi Kleen wrote:
> 
> > Oh well. Somebody who is bored might look at trying to make the wrapper 
> > code in arch/x86/lib/semaphore_32.S work on x86-64 too. It should make the 
> > successful rwsem cases much faster.
> 
> Maybe, maybe not.

If there is actual contention on the lock, but mainly just readers (which 
is what the profile indicates: since there is no scheduler footprint, the 
actual writer-vs-reader case is probably very rare), then the xadd is 
likely to be _much_ faster than the spinlock.

Sure, the cacheline is going to bounce regardless (since it's a shared 
per-mm data structure), but the spinlock is going to bounce wildly 
back-and-forth between everybody who _tries_ to get it, while the regular 
xadd is going to bounce just once per actual successful xadd.

So a spinlock is as cheap as an atomic when there is no contention (which 
is the common single-thread case - the real cost of both lock and atomic 
is simply the fact that CPU serialization is expensive), but when there is 
actual lock contention, I bet the atomic xadd is going to be shown to be 
superior.

Remember: we commonly claim that 'spin_unlock' is basically free on x86 - 
and that's true, but it is _only_ true for the uncontended state. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
