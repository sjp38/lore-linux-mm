Date: Mon, 7 May 2001 17:56:01 -0700 (PDT)
From: Matt Dillon <dillon@earth.backplane.com>
Message-Id: <200105080056.f480u1Q71866@earth.backplane.com>
Subject: Re: on load control / process swapping
References: <Pine.LNX.4.33.0105071956180.18102-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: arch@freebsd.org, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

:>     to be moved out of that queue for a minimum period of time based
:>     on page aging.  See line 500 or so of vm_pageout.c (in -stable) .
:>
:>     Thus when a process wakes up and pages a bunch of pages in, those
:>     pages are guarenteed to stay in-core for a period of time no matter
:>     what level of memory stress is occuring.
:
:I don't see anything limiting the speed at which the active list
:is scanned over and over again. OTOH, you are right that a failure
:to deactivate enough pages will trigger the swapout code .....
:
:This sure is a subtle interaction ;)

    Look at the loop line 1362 of vm_pageout.c.  Note that it enforces
    a HZ/2 tsleep (2 scans per second) if the pageout daemon is unable
    to clean sufficient pages in two loops.  The tsleep is not woken up
    by anyone while waiting that 1/2 second becuase vm_pages_needed has
    not been cleared yet.  This is what is limiting the page queue scan.

:>     When a process is swapped out, the process is removed from the run
:>     queue and the P_INMEM flag is cleared.  The process is only woken up
:>     when faultin() is called (vm_glue.c line 312).  faultin() is only
:>     called from the scheduler() (line 340 of vm_glue.c) and the scheduler
:>     only runs when the VM system indicates a minimum number of free pages
:>     are available (vm_page_count_min()), which you can adjust with
:>     the vm.v_free_min sysctl (usually represents 1-9 megabytes, dependings
:>     on how much memory the system has).
:
:But ... is this a good enough indication that the processes
:currently resident have enough memory available to make any
:progress ?

    Yes.  Consider detecting the difference between a large process accessing
    its pages randomly, and a small process accessing a relatively small
    set of pages over and over again.  Now consider what happens when the
    system gets overloaded.  The small process will be able to access its
    pages enough that they will get page priority over the larger process.
    The larger process, due to the more random accesses (or simply the fact
    that it is accessing a larger set of pages) will tend to stall more on
    pagein I/O which has the side effect of reducing the large process's
    access rate on all of its pages.  The result:  small processes get more
    priority just by being small.

:Especially if all the currently resident processes are waiting
:in page faults, won't that make it easier for the system to find
:pages to swap out, etc... ?
:
:One thing I _am_ wondering though: the pageout and the pagein
:thresholds are different. Can't this lead to problems where we
:always hit both the pageout threshold -and- the pagein threshold
:and the system thrashes swapping processes in and out ?

    The system will not page out a page it has just paged in due to the
    center-of-the-road initialization of act_count (the page aging).
    My experience at BEST was that both pagein and pageout activity
    occured simultaniously, but the fact had no detrimental effect on
    the system.  You have to treat the pagein and pageout operations
    independantly because, in fact, they are only weakly related to each
    other.  The only optimization you make, to reduce thrashing, is to
    not allow a just-paged-in page to immediately turn around and be paged
    out.

    I could probably make this work even better by setting the vm_page_t's
    act_count to its max value when paging in from swap.  I'll think about
    doing that.

    The pagein and pageout rates have nothing to do with thrashing, per say,
    and should never be arbitrarily limited.   Consider the difference
    between a system that is paing heavily and a system with only two small
    processes (like cp's) competing for disk I/O.  Insofar as I/O goes,
    there is no difference.  You can have a perfectly running system with
    high pagein and pageout rates.  It's only when the paging I/O starts
    to eat into pages that are in active use where thrashing begins to occur.
    Think of a hotdog being eaten from both ends by two lovers.  Memory
    pressure (active VM pages) eat away at one end, pageout I/O eats away
    at the other.  You don't get fireworks until they meet.

:>     ago that attempting to rate limit paging does not actually solve the
:>     thrashing problem, it actually makes it worse... So they solved the
:>     problem another way (see my answers for #1 and #2).  It isn't the
:>     paging operations themselves that cause thrashing.
:
:Agreed on all points ... I'm just wondering how well 1) and 2)
:still work after all the changes that were made to the VM in
:the last few years.  They sure are subtle ...

    The algorithms mostly stayed the same.  Much of the work was to remove
    artificial limitations that were reducing performance (due to the
    existance of greater amounts of memory, faster disks, and so forth...).
    I also spent a good deal of time removing 'restart' cases from the code
    that was causing a lot of cpu-wasteage in certain cases.  What few
    restart cases remain just don't occur all that often.  And I've done
    other things like extend the heuristics we already use for read()/write()
    to the VM system and change heuristic variables into per-vm-map elements
    rather then sharing them with read/write within the vnode.  Etc.

:>     Small process can contribute to thrashing as easily as large
:>     processes can under extreme memory pressure... for example,
:>     take an overloaded shell machine.  *ALL* processes are 'small'
:>     processes in that case, or most of them are, and in great numbers
:>     they can be the cause.  So no test that specifically checks the
:>     size of the process can be used to give it any sort of priority.
:
:There's a test related to 2) though ... A small process needs
:to be in memory less time than a big process in order to make
:progress, so it can be swapped out earlier.

    Not necessarily.  It depends whether the small process is cpu-bound
    or interactive.  A cpu-bound small process should be allowed to run
    and not swapped out.  An interactive small process can be safely
    swapped if idle for a period of time, because it can be swapped back
    in very quickly.  It should not be swapped if it isn't idle (someone is
    typing, for example), because that would just waste disk I/O paging out
    and then paging right back in.  You never want to swapout a small
    process gratuitously simply because it is small.

:It can also be swapped back in earlier, giving small processes
:shorter "time slices" for swapping than what large processes
:have.  I'm not quite sure how much this would matter, though...

    Both swapin and swapout activities are demand paged, but will be
    clustered if possible.  I don't think there would be any point
    trying to conditionalize the algorithm based on the size of the
    process.  The size has its own indirect positive effects which I
    think are sufficient.

:Interesting, FreeBSD indeed _does_ seem to have all of the things in
:place (though the interactions between the various parts seem to be
:carefully hidden ;)).
:
:They indeed should work for lots of scenarios, but things like the
:subtlety of some of the code and the fact that the swapin and
:swapout thresholds are fairly unrelated look a bit worrying...
:
:regards,
:
:Rik

    I don't think it's possible to write a nice neat thrash-handling
    algorithm.  It's a bunch of algorithms all working together, all
    closely tied to the VM page cache.  Each taken alone is fairly easy
    to describe and understand.  All of them together result in complex
    interactions that are very easy to break if you make a mistake.  It
    usually takes me a couple of tries to get a solution to a problem in
    place without breaking something else (performance-wise) in the
    process.  For example, I fubar'd heavy load performance for a month
    in FreeBSD-4.2 when I 'fixed' the pageout scan laundering algorithm.

						-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
