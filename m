Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id DADC316B20
	for <linux-mm@kvack.org>; Mon,  7 May 2001 20:35:25 -0300 (EST)
Date: Mon, 7 May 2001 20:35:25 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: on load control / process swapping
In-Reply-To: <200105072250.f47MoKe68863@earth.backplane.com>
Message-ID: <Pine.LNX.4.33.0105071956180.18102-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>
Cc: arch@freebsd.org, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

On Mon, 7 May 2001, Matt Dillon wrote:

> :1) allow the resident processes to stay resident long
> :   enough to make progess
>
>     This is accomplished as a side effect to the way the page queues
>     are handled.  A page placed in the active queue is not allowed
>     to be moved out of that queue for a minimum period of time based
>     on page aging.  See line 500 or so of vm_pageout.c (in -stable) .
>
>     Thus when a process wakes up and pages a bunch of pages in, those
>     pages are guarenteed to stay in-core for a period of time no matter
>     what level of memory stress is occuring.

I don't see anything limiting the speed at which the active list
is scanned over and over again. OTOH, you are right that a failure
to deactivate enough pages will trigger the swapout code .....

This sure is a subtle interaction ;)

> :2) make sure the resident processes aren't thrashing,
> :   that is, don't let new processes back in memory if
> :   none of the currently resident processes is "ready"
> :   to be suspended
>
>     When a process is swapped out, the process is removed from the run
>     queue and the P_INMEM flag is cleared.  The process is only woken up
>     when faultin() is called (vm_glue.c line 312).  faultin() is only
>     called from the scheduler() (line 340 of vm_glue.c) and the scheduler
>     only runs when the VM system indicates a minimum number of free pages
>     are available (vm_page_count_min()), which you can adjust with
>     the vm.v_free_min sysctl (usually represents 1-9 megabytes, dependings
>     on how much memory the system has).

But ... is this a good enough indication that the processes
currently resident have enough memory available to make any
progress ?

Especially if all the currently resident processes are waiting
in page faults, won't that make it easier for the system to find
pages to swap out, etc... ?

One thing I _am_ wondering though: the pageout and the pagein
thresholds are different. Can't this lead to problems where we
always hit both the pageout threshold -and- the pagein threshold
and the system thrashes swapping processes in and out ?

> :3) have a mechanism to detect thrashing in a VM
> :   subsystem which isn't rate-limited  (hard?)
>
>     In FreeBSD, rate-limiting is a function of a lightly loaded system.
>     We rate-limit page laundering (pageouts).  However, if the rate-limited
>     laundering is not sufficient to reach our free + cache page targets,
>     we take another laundering loop and this time do not limit it at all.
>
>     Thus under heavy memory pressure, no real rate limiting occurs.  The
>     system will happily pagein and pageout megabytes/sec.  The reason we
>     do this is because David Greenman and John Dyson found a long time
>     ago that attempting to rate limit paging does not actually solve the
>     thrashing problem, it actually makes it worse... So they solved the
>     problem another way (see my answers for #1 and #2).  It isn't the
>     paging operations themselves that cause thrashing.

Agreed on all points ... I'm just wondering how well 1) and 2)
still work after all the changes that were made to the VM in
the last few years.  They sure are subtle ...

> :and, for extra brownie points:
> :4) fairness, small processes can be paged in and out
> :   faster, so we can suspend&resume them faster; this
> :   has the side effect of leaving the proverbial root
> :   shell more usable
>
>     Small process can contribute to thrashing as easily as large
>     processes can under extreme memory pressure... for example,
>     take an overloaded shell machine.  *ALL* processes are 'small'
>     processes in that case, or most of them are, and in great numbers
>     they can be the cause.  So no test that specifically checks the
>     size of the process can be used to give it any sort of priority.

There's a test related to 2) though ... A small process needs
to be in memory less time than a big process in order to make
progress, so it can be swapped out earlier.

It can also be swapped back in earlier, giving small processes
shorter "time slices" for swapping than what large processes
have.  I'm not quite sure how much this would matter, though...

> :5) make sure already resident processes cannot create
> :   a situation that'll keep the swapped out tasks out
> :   of memory forever ... but don't kill performance either,
> :   since bad performance means we cannot get out of the
> :   bad situation we're in
>
>     When the system starts swapping processes out, it continues to swap
>     them out until memory pressure goes down.  With memory pressure down
>     processes are swapped back in again one at a time, typically in FIFO
>     order.  So this situation will generally not occur.
>
>     Basically we have all the algorithms in place to deal with thrashing.
>     I'm sure that there are a few places where we can optimize things...
>     for example, we can certainly tune the swapout algorithm itself.

Interesting, FreeBSD indeed _does_ seem to have all of the things in
place (though the interactions between the various parts seem to be
carefully hidden ;)).

They indeed should work for lots of scenarios, but things like the
subtlety of some of the code and the fact that the swapin and
swapout thresholds are fairly unrelated look a bit worrying...

regards,

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
