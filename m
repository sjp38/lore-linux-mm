Date: Sat, 12 May 2001 11:23:43 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: on load control / process swapping
In-Reply-To: <200105080056.f480u1Q71866@earth.backplane.com>
Message-ID: <Pine.LNX.4.21.0105121109210.5468-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>
Cc: arch@freebsd.org, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

On Mon, 7 May 2001, Matt Dillon wrote:

>     Look at the loop line 1362 of vm_pageout.c.  Note that it enforces
>     a HZ/2 tsleep (2 scans per second) if the pageout daemon is unable
>     to clean sufficient pages in two loops.  The tsleep is not woken up
>     by anyone while waiting that 1/2 second becuase vm_pages_needed has
>     not been cleared yet.  This is what is limiting the page queue scan.

Ahhh, so FreeBSD _does_ have a maxscan equivalent, just one that
only kicks in when the system is under very heavy memory pressure.

That explains why FreeBSD's thrashing detection code works... ;)

(I'm not convinced, though, that limiting the speed at which we
scan the active list is a good thing. There are some arguments
in favour of speed limiting, but it mostly seems to come down
to a short-cut to thrashing detection...)

> :But ... is this a good enough indication that the processes
> :currently resident have enough memory available to make any
> :progress ?
> 
>     Yes.  Consider detecting the difference between a large process accessing
>     its pages randomly, and a small process accessing a relatively small
>     set of pages over and over again.  Now consider what happens when the
>     system gets overloaded.  The small process will be able to access its
>     pages enough that they will get page priority over the larger process.
>     The larger process, due to the more random accesses (or simply the fact
>     that it is accessing a larger set of pages) will tend to stall more on
>     pagein I/O which has the side effect of reducing the large process's
>     access rate on all of its pages.  The result:  small processes get more
>     priority just by being small.

But if the larger processes never get a chance to make decent
progress without thrashing, won't your system be slowed down
forever by these (thrashing) large processes?

It's nice to protect your small processes from the large ones,
but if the large processes don't get to run to completion the
system will never get out of thrashing...

> :Especially if all the currently resident processes are waiting
> :in page faults, won't that make it easier for the system to find
> :pages to swap out, etc... ?
> :
> :One thing I _am_ wondering though: the pageout and the pagein
> :thresholds are different. Can't this lead to problems where we
> :always hit both the pageout threshold -and- the pagein threshold
> :and the system thrashes swapping processes in and out ?
> 
>     The system will not page out a page it has just paged in due to the
>     center-of-the-road initialization of act_count (the page aging).

Indeed, the speed limiting of the pageout scanning takes care of
this. But still, having the swapout threshold defined as being
short of inactive pages while the swapin threshold uses the number
of free+cache pages as an indication could lead to the situation
where you suspend and wake up processes while it isn't needed.

Or worse, suspending one process which easily fit in memory and
then waking up another process, which cannot be swapped in because
the first process' memory is still sitting in RAM and cannot be
removed yet due to the pageout scan speed limiting (and also cannot
be used, because we suspended the process).

The chance of this happening could be quite big in some situations
because the swapout and swapin thresholds are measuring things that
are only indirectly related...

>     The pagein and pageout rates have nothing to do with thrashing, per say,
>     and should never be arbitrarily limited.

But they are, with the pageout daemon going to sleep for half a
second if it doesn't succeed in freeing enough memory at once.
It even does this if a large part of the memory on the active
list belongs to a process which has just been suspended because
of thrashing...


>     I don't think it's possible to write a nice neat thrash-handling
>     algorithm.  It's a bunch of algorithms all working together, all
>     closely tied to the VM page cache.  Each taken alone is fairly easy
>     to describe and understand.  All of them together result in complex
>     interactions that are very easy to break if you make a mistake.

Heheh, certainly true ;)

cheers,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
