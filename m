Date: Sat, 12 May 2001 16:58:14 -0700 (PDT)
From: Matt Dillon <dillon@earth.backplane.com>
Message-Id: <200105122358.f4CNwEr20137@earth.backplane.com>
Subject: Re: on load control / process swapping
References: <Pine.LNX.4.21.0105121109210.5468-100000@imladris.rielhome.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: arch@freebsd.org, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

    Consider the case where you have one large process and many small
    processes.  If you were to skew things to allow the large process to
    run at the cost of all the small processes, you have just inconvenienced
    98% of your users so one ozob can run a big job.  Not only that, but 
    there is no guarentee that the 'big job' will ever finish (a topic of
    many a paper on scheduling, BTW)... what if it's been running for hours
    and still has hours to go?  Do we blow away the rest of the system to
    let it run?  

    What if there are several big jobs?  If you skew things in favor of
    one the others could take 60 seconds *just* to recover their RSS when
    they are finally allowed to run.  So much for timesharing... you
    would have to run each job exclusively for 5-10 minutes at a time
    to get any sort of effiency, which is not practical in a timeshare
    system.  So there is really very little that you can do.

:Indeed, the speed limiting of the pageout scanning takes care of
:this. But still, having the swapout threshold defined as being
:short of inactive pages while the swapin threshold uses the number
:of free+cache pages as an indication could lead to the situation
:where you suspend and wake up processes while it isn't needed.
:
:Or worse, suspending one process which easily fit in memory and
:then waking up another process, which cannot be swapped in because
:the first process' memory is still sitting in RAM and cannot be
:removed yet due to the pageout scan speed limiting (and also cannot
:be used, because we suspended the process).

    We don't suspend running processes, but I do believe FreeBSD is still
    vulnerable to this issue.  Suspending the marked process when it hits the
    vm_fault code is a good idea and would solve the problem.  If the process
    never takes an allocation fault, it probably doesn't have to be swapped
    out.  The normal pageout would suffice for that process.

:>     The pagein and pageout rates have nothing to do with thrashing, per say,
:>     and should never be arbitrarily limited.
:
:But they are, with the pageout daemon going to sleep for half a
:second if it doesn't succeed in freeing enough memory at once.
:It even does this if a large part of the memory on the active
:list belongs to a process which has just been suspended because
:of thrashing...

    No.  I did say the code was complex.  A process which has been
    suspended for thrashing gets all of its pages depressed in priority.
    The page daemon would have no problem recovering the pages.   See
    line 1458 of vm_pageout.c.  This code also enforces the 'memoryuse'
    resource limit (which is perhaps even more important).  It is not
    necessary to try to launder the pages immediately.  Simply depressing
    their priority is sufficient and it allows for quicker recovery when
    the thrashing goes away.  It also allows us to implement the 
    vm.swap_idle_{threshold1,threshold2,enabled} sysctls trivially, which
    results in proactive swapping that is extremely useful in certain
    situations (like shell machines with lots of idle users).

    The pagedaemon gets behind when there are too many
    active pages in the system and the pagedaemon is unable to move them
    to the inactive queue due to the pages still being very active... that is,
    when the active resident set for all processes in the system exceeds
    available memory.  This is what triggers thrashing.  Swapping has the
    side effect of reducing the total active resident set for the system
    as a whole, fixing the thrashing problem. 

						-Matt

:>     I don't think it's possible to write a nice neat thrash-handling
:>     algorithm.  It's a bunch of algorithms all working together, all
:>     closely tied to the VM page cache.  Each taken alone is fairly easy
:>     to describe and understand.  All of them together result in complex
:>     interactions that are very easy to break if you make a mistake.
:
:Heheh, certainly true ;)
:
:cheers,
:
:Rik
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
