Date: Tue, 8 May 2001 17:18:16 -0700 (PDT)
From: Matt Dillon <dillon@earth.backplane.com>
Message-Id: <200105090018.f490IGR87881@earth.backplane.com>
Subject: Re: on load control / process swapping 
References: <200105082052.NAA08757@beastie.mckusick.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kirk McKusick <mckusick@mckusick.com>
Cc: Rik van Riel <riel@conectiva.com.br>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

    I looked at the code fairly carefully last night... it doesn't
    swap out running processes and it also does not appear to swap
    out processes blocked in a page-fault (on I/O).  Now, of course
    we can't swap a process out right then (it might be holding locks),
    but I think it would be beneficial to be able to mark the process
    as 'requesting a swapout on return to user mode' or something
    like that.  At the moment what gets picked for swapping is
    hit-or-miss due to the wait states.

:As to the size issue, we used to be biased towards the processes
:with large resident set sizes in kicking things out. In general,
:swapping out small things does not buy you much memory and it

    The VM system does enforce the 'memoryuse' resource limit when
    the memory load gets heavy.  But once the load goes beyond that
    the VM system doesn't appear to care how big the process is.

:...
:biggest processes. Also note that this is a last ditch algorithm
:used only after there are no more idle processes available to
:kick out. Our decision that we had had to kick out running
:processes was: (1) no idle processes available to swap, (2) load
:average over one (if there is just one process, kicking it out
:does not solve the problem :-), (3) paging rate above a specified
:threshhold over the entire previous 30 seconds (e.g., been bad 
:for a long time and not getting better in the short term), and
:(4) paging rate to/from swap area using more than half the 
:available disk bandwidth (if your filesystems are on the same
:disk as you swap areas, you can get a false sense of success
:because all your process stop paging while they are blocked
:waiting for their file data.
:
:	Kirk

    I don't think we want to kick out running processes.  Thrashing
    by definition means that many of the processes are stuck in 
    disk-wait, usually from a VM fault, and not running.  The other 
    effect of thrashing is, of course, the the cpu idle time goes way
    up due to all the process stalls.  A process that is actually able 
    to run under these circumstances probably has a small run-time footprint
    (at least for whatever operation it is currently doing), so it should
    definitely be allowed to continue to run.

						-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
