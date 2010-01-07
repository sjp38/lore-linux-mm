Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E15E4600580
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 11:37:15 -0500 (EST)
Date: Thu, 7 Jan 2010 10:36:52 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <alpine.LFD.2.00.1001070814080.7821@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1001071025450.901@router.home>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105054536.44bf8002@infradead.org> <alpine.DEB.2.00.1001050916300.1074@router.home> <20100105192243.1d6b2213@infradead.org> <alpine.DEB.2.00.1001071007210.901@router.home>
 <alpine.LFD.2.00.1001070814080.7821@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Arjan van de Ven <arjan@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 2010, Linus Torvalds wrote:

> You're missing what Arjan said - the jav workload does a lot of memory
> allocations too, causing mmap/munmap.

Well isnt that tunable on the app level? Get bigger chunks of memory in
order to reduce the frequency of mmap operations? If you want concurrency
of faults then mmap_sem write locking currently needs to be limited.

> So now some paths are indeed holding it for writing (or need to wait for
> it to become writable). And the fairness of rwsems quite possibly then
> impacts throughput a _lot_..

Very true. Doing range locking (maybe using the split pte lock
boundaries, shifting some state from mm_struct into vmas) may be a way to
avoid hold mmap_sem for write in that case.

> (Side note: I wonder if we should wake up _all_ readers when we wake up
> any. Right now, we wake up all readers - but only until we hit a writer.
> Which is the _fair_ thing to do, but it does mean that we can end up in
> horrible patterns of alternating readers/writers, when it could be much
> better to just say "release the hounds" and let all pending readers go
> after a writer has had its turn).

Have a cycle with concurrent readers followed by a cycle of serialized
writers may be best under heavy load. The writers need to be limited in
frequency otherwise they will starve the readers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
