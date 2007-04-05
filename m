Date: Thu, 5 Apr 2007 12:27:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: preemption and rwsems (was: Re: missing madvise functionality)
Message-Id: <20070405122724.b1712aa6.akpm@linux-foundation.org>
In-Reply-To: <19526.1175777338@redhat.com>
References: <20070404160006.8d81a533.akpm@linux-foundation.org>
	<46128051.9000609@redhat.com>
	<p73648dz5oa.fsf@bingen.suse.de>
	<46128CC2.9090809@redhat.com>
	<20070403172841.GB23689@one.firstfloor.org>
	<20070403125903.3e8577f4.akpm@linux-foundation.org>
	<4612B645.7030902@redhat.com>
	<20070403202937.GE355@devserv.devel.redhat.com>
	<19526.1175777338@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 05 Apr 2007 13:48:58 +0100
David Howells <dhowells@redhat.com> wrote:

> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > 
> > What we effectively have is 32 threads on a single CPU all doing
> > 
> > 	for (ever) {
> > 		down_write()
> > 		up_write()
> > 		down_read()
> > 		up_read();
> > 	}
> 
> That's not quite so.  In that test program, most loops do two d/u writes and
> then a slew of d/u reads with virtually no delay between them.  One of the
> write-locked periods possibly lasts a relatively long time (it frees a bunch
> of pages), and the read-locked periods last a potentially long time (have to
> allocate a page).

Whatever.  I think it is still the case that the queueing behaviour of
rwsems causes us to get into this abababababab scenario.  And a single,
sole, solitary cond_resched() is sufficient to trigger the whole process
happening, and once it has started, it is sustained.

> If they weren't, you'd have to expect writer starvation in this situation.  As
> it is, you're guaranteed progress on all threads.
> 
> > CONFIG_PREEMPT_VOLUNTARY=y
> 
> Which means the periods of lock-holding can be extended by preemption of the
> lock holder(s), making the whole situation that much worse.  You have to
> remember, you *can* be preempted whilst you hold a semaphore, rwsem or mutex.

Of course - the same thing happens with CONFIG_PREEMPT=y.

> > I run it all on a single CPU under `taskset -c 0' on the 8-way and it still
> > causes 160,000 context switches per second and takes 9.5 seconds (after
> > s/100000/1000).
> 
> How about if you have a UP kernel?  (ie: spinlocks -> nops)

dunno.

> > the context switch rate falls to zilch and total runtime falls to 6.4
> > seconds.
> 
> I presume you don't mean literally zero.

I do.  At least, I was unable to discern any increase in the context-switch
column in the `vmstat 1' output.

> > If that cond_resched() was not there, none of this would ever happen - each
> > thread merrily chugs away doing its ups and downs until it expires its
> > timeslice.  Interesting, in a sad sort of way.
> 
> The trouble is, I think, that you spend so much more time holding (or
> attempting to hold) locks than not, and preemption just exacerbates things.

No.  Preemption *triggers* things.  We're talking about an increase in
context switch rate by a factor of at least 10,000.  Something changed in a
fundamental way.

> I suspect that the reason the problem doesn't seem so obvious when you've got
> 8 CPUs crunching their way through at once is probably because you can make
> progress on several read loops simultaneously fast enough that the preemption
> is lost in the things having to stop to give everyone writelocks.

The context switch rate is enormous on SMP on all kernel configs.  Perhaps
a better way of looking at it is to observe that the special case of a
single processor running a non-preemptible kernel simply got lucky.

> But short of recording the lock sequence, I don't think there's anyway to find
> out for sure.  printk probably won't cut it as a recording mechanism because
> its overheads are too great.

I think any code sequence which does

	for ( ; ; ) {
		down_write()
		up_write()
		down_read()
		up_read()
	}

is vulnerable to the artifact which I described.


I don't think we can (or should) do anything about it at the lock
implementation level.  It's more a matter of being aware of the possible
failure modes of rwsems, and being more careful to avoid that situation in
the code which uses rwsems.  And, of course, being careful about when and
where we use rwsems as opposed to other types of locks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
