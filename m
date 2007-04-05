From: David Howells <dhowells@redhat.com>
In-Reply-To: <20070404160006.8d81a533.akpm@linux-foundation.org> 
References: <20070404160006.8d81a533.akpm@linux-foundation.org>  <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403202937.GE355@devserv.devel.redhat.com> 
Subject: Re: preemption and rwsems (was: Re: missing madvise functionality) 
Date: Thu, 05 Apr 2007 13:48:58 +0100
Message-ID: <19526.1175777338@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> What we effectively have is 32 threads on a single CPU all doing
> 
> 	for (ever) {
> 		down_write()
> 		up_write()
> 		down_read()
> 		up_read();
> 	}

That's not quite so.  In that test program, most loops do two d/u writes and
then a slew of d/u reads with virtually no delay between them.  One of the
write-locked periods possibly lasts a relatively long time (it frees a bunch
of pages), and the read-locked periods last a potentially long time (have to
allocate a page).

Though, to be fair, as long as you've got way more than 16MB of RAM, the
memory stuff shouldn't take too long, but the locks will be being held for a
long time compared to the periods when you're not holding a lock of any sort.

> and rwsems are "fair".

If they weren't, you'd have to expect writer starvation in this situation.  As
it is, you're guaranteed progress on all threads.

> CONFIG_PREEMPT_VOLUNTARY=y

Which means the periods of lock-holding can be extended by preemption of the
lock holder(s), making the whole situation that much worse.  You have to
remember, you *can* be preempted whilst you hold a semaphore, rwsem or mutex.

> I run it all on a single CPU under `taskset -c 0' on the 8-way and it still
> causes 160,000 context switches per second and takes 9.5 seconds (after
> s/100000/1000).

How about if you have a UP kernel?  (ie: spinlocks -> nops)

> the context switch rate falls to zilch and total runtime falls to 6.4
> seconds.

I presume you don't mean literally zero.

> If that cond_resched() was not there, none of this would ever happen - each
> thread merrily chugs away doing its ups and downs until it expires its
> timeslice.  Interesting, in a sad sort of way.

The trouble is, I think, that you spend so much more time holding (or
attempting to hold) locks than not, and preemption just exacerbates things.

I suspect that the reason the problem doesn't seem so obvious when you've got
8 CPUs crunching their way through at once is probably because you can make
progress on several read loops simultaneously fast enough that the preemption
is lost in the things having to stop to give everyone writelocks.

But short of recording the lock sequence, I don't think there's anyway to find
out for sure.  printk probably won't cut it as a recording mechanism because
its overheads are too great.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
