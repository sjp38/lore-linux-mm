Date: Mon, 7 May 2001 15:50:20 -0700 (PDT)
From: Matt Dillon <dillon@earth.backplane.com>
Message-Id: <200105072250.f47MoKe68863@earth.backplane.com>
Subject: Re: on load control / process swapping
References: <Pine.LNX.4.21.0105061924160.582-100000@imladris.rielhome.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: arch@freebsd.org, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

    This is accomplished as a side effect to the way the page queues
    are handled.  A page placed in the active queue is not allowed
    to be moved out of that queue for a minimum period of time based
    on page aging.  See line 500 or so of vm_pageout.c (in -stable) .

    Thus when a process wakes up and pages a bunch of pages in, those
    pages are guarenteed to stay in-core for a period of time no matter
    what level of memory stress is occuring.

:2) make sure the resident processes aren't thrashing,
:   that is, don't let new processes back in memory if
:   none of the currently resident processes is "ready"
:   to be suspended

    When a process is swapped out, the process is removed from the run
    queue and the P_INMEM flag is cleared.  The process is only woken up
    when faultin() is called (vm_glue.c line 312).  faultin() is only
    called from the scheduler() (line 340 of vm_glue.c) and the scheduler
    only runs when the VM system indicates a minimum number of free pages
    are available (vm_page_count_min()), which you can adjust with
    the vm.v_free_min sysctl (usually represents 1-9 megabytes, dependings
    on how much memory the system has).

    So what occurs is that the system comes under extreme memory pressure
    and starts to swapout blocked processes.  This reduces memory pressure
    over time.  When memory pressure is sufficiently reudced the scheduler
    wakes up a swapped-out process (one at a time).

    There might be some fine tuning that we can do here, such as try to
    choose a better process to swapout (right now it's priority based which
    isn't the best way to do it).

:3) have a mechanism to detect thrashing in a VM
:   subsystem which isn't rate-limited  (hard?)

    In FreeBSD, rate-limiting is a function of a lightly loaded system.
    We rate-limit page laundering (pageouts).  However, if the rate-limited
    laundering is not sufficient to reach our free + cache page targets,
    we take another laundering loop and this time do not limit it at all.

    Thus under heavy memory pressure, no real rate limiting occurs.  The
    system will happily pagein and pageout megabytes/sec.  The reason we
    do this is because David Greenman and John Dyson found a long time
    ago that attempting to rate limit paging does not actually solve the
    thrashing problem, it actually makes it worse... So they solved the
    problem another way (see my answers for #1 and #2).  It isn't the
    paging operations themselves that cause thrashing.

:and, for extra brownie points:
:4) fairness, small processes can be paged in and out
:   faster, so we can suspend&resume them faster; this
:   has the side effect of leaving the proverbial root
:   shell more usable

    Small process can contribute to thrashing as easily as large
    processes can under extreme memory pressure... for example,
    take an overloaded shell machine.  *ALL* processes are 'small'
    processes in that case, or most of them are, and in great numbers
    they can be the cause.  So no test that specifically checks the
    size of the process can be used to give it any sort of priority.

    Additionally, *idle* small processes are also great contributers 
    to the VM subsystem in regards to clearing out idle pages.  For
    example, on a heavily loaded shell machine more then 80% of the
    'small processes' have been idle for long periods of time and it
    is exactly our ability to page them out that allows us to extend
    the machine's operational life and move the thrashing threshold
    farther away.  The last thing we want to do is make a 'fix' that
    prevents us from paging out idle small processes.  It would kill
    the machine.

:5) make sure already resident processes cannot create
:   a situation that'll keep the swapped out tasks out
:   of memory forever ... but don't kill performance either,
:   since bad performance means we cannot get out of the
:   bad situation we're in

    When the system starts swapping processes out, it continues to swap
    them out until memory pressure goes down.  With memory pressure down
    processes are swapped back in again one at a time, typically in FIFO
    order.  So this situation will generally not occur.

    Basically we have all the algorithms in place to deal with thrashing.
    I'm sure that there are a few places where we can optimize things...
    for example, we can certainly tune the swapout algorithm itself.

						-Matt

:regards,
:
:Rik
:--
:Virtual memory is like a game you can't win;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
