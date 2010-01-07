Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E00C1600580
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 12:50:04 -0500 (EST)
Date: Thu, 7 Jan 2010 09:49:45 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <alpine.LFD.2.00.1001070934060.7821@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.1001070937180.7821@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>  <20100104182813.753545361@chello.nl>  <20100105054536.44bf8002@infradead.org>  <alpine.DEB.2.00.1001050916300.1074@router.home>  <20100105192243.1d6b2213@infradead.org>  <alpine.DEB.2.00.1001071007210.901@router.home>
  <alpine.LFD.2.00.1001070814080.7821@localhost.localdomain> <1262884960.4049.106.camel@laptop> <alpine.LFD.2.00.1001070934060.7821@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Thu, 7 Jan 2010, Linus Torvalds wrote:
> 
> Well, I have yet to hear a realistic scenario of _how_ to do it all 
> speculatively in the first place, at least not without horribly subtle 
> complexity issues. So I'd really rather see how far we can possibly get by 
> just improving mmap_sem.

For an example of this: it's entirely possible that one avenue of mmap_sem 
improvement would be to look at the _writer_ side, and see how that can be 
improved. 

An example of where we've done that is in madvise(): we used to always 
take it for writing (because _some_ madvise versions needed the exclusive 
access). And suddenly some operations got way more scalable, and work in 
the presense of concurrent page faults.

And quite frankly, I'd _much_ rather look at that kind of simple and 
logically fairly straightforward solutions, instead of doing the whole 
speculative page fault work.

For example: there's no real reason why we take mmap_sem for writing when 
extending an existing vma. And while 'brk()' is a very oldfashioned way of 
doing memory management, it's still quite common. So rather than looking 
at subtle lockless algorithms, why not look at doing the common cases of 
an extending brk? Make that one take the mmap_sem for _reading_, and then 
do the extending of the brk area with a simple cmpxchg or something?

And "extending brk" is actually a lot more common than shrinking it, and 
is common for exactly the kind of workloads that are often nasty right now 
(threaded allocators with lots and lots of smallish allocations)

The thing is, I can pretty much _guarantee_ that the speculative page 
fault is going to end up doing a lot of nasty stuff that still needs 
almost-global locking, and it's likely to be more complicated and slower 
for the single-threaded case (you end up needing refcounts, a new "local" 
lock or something).

Sure, moving to a per-vma lock can help, but it doesn't help a lot. It 
doesn't help AT ALL for the single-threaded case, and for the 
multi-threaded case I will bet you that a _lot_ of cases will have one 
very hot vma - the regular data vma that gets shared for normal malloc() 
etc. 

So I'm personally rather doubtful about the whole speculative work. It's a 
fair amount of complexity without any really obvious upside. Yes, the 
mmap_sem can be very annoying, but nobody can really honestly claim that 
we've really optimized it all that much.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
