Message-ID: <3B00CECF.9A3DEEFA@mindspring.com>
Date: Mon, 14 May 2001 23:38:07 -0700
From: Terry Lambert <tlambert2@mindspring.com>
Reply-To: tlambert2@mindspring.com
MIME-Version: 1.0
Subject: Re: on load control / process swapping
References: <Pine.LNX.4.21.0105131417550.5468-100000@imladris.rielhome.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Matt Dillon <dillon@earth.backplane.com>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> So we should not allow just one single large job to take all
> of memory, but we should allow some small jobs in memory too.

Historically, this problem is solved with a "working set
quota".

> If you don't do this very slow swapping, NONE of the big tasks
> will have the opportunity to make decent progress and the system
> will never get out of thrashing.
> 
> If we simply make the "swap time slices" for larger processes
> larger than for smaller processes we:
> 
> 1) have a better chance of the large jobs getting any work done
> 2) won't have the large jobs artificially increase memory load,
>    because all time will be spent removing each other's RSS
> 3) can have more small jobs in memory at once, due to 2)
> 4) can be better for interactive performance due to 3)
> 5) have a better chance of getting out of the overload situation
>    sooner
> 
> I realise this would make the scheduling algorithm slightly
> more complex and I'm not convinced doing this would be worth
> it myself, but we may want to do some brainstorming over this ;)

A per vnode working set quota with a per use count adjust
would resolve most load thrashing issues.  Programs with
large working sets can either be granted a case by case
exception (via rlimit), or, more likely just have their
pages thrashed out more often.

You only ever need to do this when you have exhausted
memory to the point you are swapping, and then only when
you want to reap cached clean pages; when all you have
left is dirty pages in memory and swap, you are well and
truly thrashing -- for the right reason: your system load
is too high.

It's also relatively easy to implement something like a
per vnode working set quota, which can be self-enforced,
without making the scheduler so ugly that you will never
be able to do things like have per-CPU run queues for a
very efficient SMP that deals with the cache locality
issue naturally and easily (by merely setting migration
policies for moving from one run queue to another, and
by threads in a thread group having negative affinity for
each other's CPUs, to maximize real concurrency).

Psuedo code:

	IF THRASH_CONDITIONS
		IF (COPY_ON_WRITE_FAULT OR
		   PAGE_FILL_OF_SBRKED_PAGE_FAULT)
			IF VNODE_OVER_WORKING_SET_QUOTA
				STEAL_PAGE_FROM_VNODE_LRU
	ELSE
		GET_PAGE_FROM_SYSTEM

Obviously, this would work for vnodes that were acting as
backing store for programs, just as they would prevent a
large mmap() with a traversal from thrashing everyone else's
data and code out of core (which is, I think, a much worse
and much more common problem).

Doing extremely complicated things is only going to get
you into trouble... in particular, you don't want to
have policy in effect to deal with border load conditions
unless you are under those conditions in the first place.
The current scheduling algorithms are quite simple,
relatively speaking, and it makes much more sense to
make the thrasher fight with themselves, rather than them
peeing in everyone's pool.

I think that badly written programs taking more time, as
a result, is not a problem; if it is, it's one I could
live with much more easily than cache-busting for no good
reason, and slowing well behaved code down.  You need to
penalize the culprit.

It's possible to do a more complicated working set quota,
which actually applies to a process' working set, instead
of to vnodes, out of context with the process, but I think
that the vnode approach, particularly when you bump the
working set up per each additional opener, using the count
I suggested, to ensure proper locality of reference, is
good enough to solve the problem.

At the very least, the system would not "freeze" with this
approach, even if it could later recover.

-- Terry
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
