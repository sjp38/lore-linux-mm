Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4086B00F2
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 14:17:52 -0500 (EST)
Date: Tue, 5 Jan 2010 11:08:46 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <20100105185542.GH6714@linux.vnet.ibm.com>
Message-ID: <alpine.LFD.2.00.1001051059480.3630@localhost.localdomain>
References: <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain> <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com> <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain> <alpine.LFD.2.00.1001050810380.3630@localhost.localdomain> <87wrzwbh0z.fsf@basil.nowhere.org> <alpine.LFD.2.00.1001050950500.3630@localhost.localdomain> <alpine.DEB.2.00.1001051211000.2246@router.home>
 <alpine.LFD.2.00.1001051019280.3630@localhost.localdomain> <20100105185542.GH6714@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Tue, 5 Jan 2010, Paul E. McKenney wrote:
> 
> But on many systems, it does take some time for the idle reads to make
> their way to the CPU that just acquired the lock.

Yes. But the point is that there is lots of them.

So think of it this way: every time _one_ CPU acquires a lock (and 
then releases it), _all_ CPU's will read the new value. Imagine the 
cross-socket traffic.

In contrast, doing just a single xadd (which replaces the whole 
"spin_lock+non-atomics+spin_unlock"), every times _once_ CPU cquires a 
lock, that's it. The other CPU's arent' all waiting in line for the lock 
to be released, and reading the cacheline to see if it's their turn.

Sure, after they got the lock they'll all eventually end up reading from 
that cacheline that contains 'struct mm_struct', but that's something we 
could even think about trying to minimize by putting the mmap_sem as far 
away from the other fields as possible.

Now, it's very possible that if you have a broadcast model of cache 
coherency, none of this much matters and you end up with almost all the 
same bus traffic anyway. But I do think it could matter a lot.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
