Received: from localhost (riel@localhost)
	by brutus.conectiva.com.br (8.11.1/8.11.1) with ESMTP id eBIDGAQ02845
	for <linux-mm@kvack.org>; Mon, 18 Dec 2000 11:16:11 -0200
Date: Sat, 16 Dec 2000 12:16:32 -0800 (PST)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200012162016.eBGKGW902633@apollo.backplane.com>
Subject: Interesting item came up while working on FreeBSD's pageout daemon
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.21.0012181116080.2595@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

    I've been working with a particular news user who runs FreeBSD very
    close to the page thrashing limit testing different pageout algorithms
    and I came up with an interesting conclusion in regards to the flushing
    of dirty pages in the pageout scan which I think may interest you.

    This particular user runs around 500-600 newsreader processes on a 512M
    machine.  The processes eat around 8MB/sec in 'new' memory from reading
    the news spool and also, of course, dirty a certain amount of memory
    updating the news history file and for their run-time VM.  The disks
    are near saturation (70-90% busy) just from normal operation.

    In testing, we've found something quite interesting - the cost of flushing
    a dirty page on a system which is already close to disk saturation
    seriously degrades performance.   Not just a little, but a lot.

    My solution is to run dirty pages through the FBsd inactive queue twice.
    i.e. the first time a dirty page shows up at the head of the queue I set
    a flag and send it to the end of the queue.  The second time it reaches
    the head of the queue I flush it.  This gives the dirty page extra time
    in memory during which it could be reactivated or reused by the process
    before the system decides to spend resources flushing it out. 

    FreeBSD-4.0			dirty pages are flushed in queue-order, but
				the number of pages laundered per pass was
				limited.  Unknown load characteristics.
				In general this worked pretty well but had
				the side effect of fragmenting the ordering
				of dirty pages in the queue.

    FreeBSD-4.1.1 and 4.2:	dirty pages are skipped unless we run out
				of clean pages.  News load: 1-2, but pageout
				activity was very inconsistent (not a smooth
				load curve).

    FreeBSD-stable:		dirty pages are flushed in queue-order.
				News load: 50-150 (i.e. it blew up). 

    (patches in development):	dirty pages are given two go-arounds in the
				queue before being flushed.  News load: 1-2.
				Very consistent pageout activity.

    My conclusion from this is that I was wrong before when I thought that
    clean and dirty pages should be treated the same, and I was also wrong
    trying to give clean pages 'ultimate' priority over dirty pages, but I
    think I may be right giving dirty pages two go-arounds in the queue
    before flushing.  Limiting the number of dirty page flushes allowed per
    pass also works but has unwanted side effects.

    --

    I have also successfully tested a low (real) memory deadlock handling
    solution, which is currently in FreeBSD-stable and FreeBSD-current.
    I'm not sure what Linux is using for low-memory deadlock handling right
    now, so this may be of interest.  The solution is as follows:

	* We operate under the assumption that I/O *must* be able to continue
	  to operate no matter what the memory circumstances.

	* All allocations made by the I/O subsystem are allowed to dig into
	  the system memory reserve.

	* No allocation outside the I/O subsystem is allowed to dig into the
	  memory reserve (i.e. such allocations block until the system has
	  freed enough pages to get out of the red area).

	* The I/O subsystem explicitly detects a severe memory shortage but
	  rather then blocking it instead simply frees I/O resources as I/O's
	  complete, allowing I/O to continue at near full bore without eating
	  additional memory.

    This solution appears to work under all load conditions. Yahoo was unable
    to crash or deadlock extremely heavily loaded FreeBSD boxes after
    I comitted this solution.

    -

    Finally, I came up with a solution to deal with heavy write loads 
    interfering with read loads.  If I remember correctly Linux tries to
    reorder reads in front of writes.  FreeBSD does not do that, because
    once FreeBSD determines that a delayed write should go out it wants it
    to go out, and because you get non-deterministic loads when you make
    that kind of ad-hoc ordering decision.  I personally do not like
    reordering reads before writes, it makes too many assumptions on
    the type of load the disks will have.

    The solution I'm testing for FreeBSD involves keeping track of the
    number of bytes that are in-transit to/from the device.  On a heavily 
    loaded system this number is typically in the 16K-512K range.  
    However, when writing out a huge file the write I/O can not only
    saturate your VM system, it can also saturate the device (even with
    your read reordering you can saturate the device with pending writes).  
    I've measured in-transit loads of up to 8 MB on FreeBSD in such cases.

    I have found a solution which prevents saturation of the VM system
    *AND* prevents saturation of the device.  Saturation of the VM system
    is prevented by immediately issuing an async write when sequential write
    operation is detected... i.e. FreeBSD's clustering code.  (Actually,
    this part of the solution was already implemented).  Device saturation
    is avoided by blocking writes at the queue-to-the-device level when
    the number of in-transit bytes already queued to the device reaches a
    high water mark. For example, 1 MB, then wakeup those blocked processes
    when the number of in-transit bytes drops to a low water mark.
    For example, 512K. 

    We never block read requests.  Read requests also have the side effect
    of 'eating into' the in-transit count, reducing the number of
    in-transit bytes available for writes before the writes block.  So
    a heavy read load automatically reduces write priority.  (since reads
    are synchronous or have only limited read-ahead, reads do not present
    the same device saturation issue as writes do).

    In my testing this solution resulted in a system that appeared to behave
    normally and efficiently even under extremely heavy write loads.  The
    system load also became much more deterministic (fewer spikes).

    (You can repost this if you want).

						Later!

						-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
