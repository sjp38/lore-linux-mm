Received: from ds02c00.rsc.raytheon.com (ds02c00.rsc.raytheon.com [147.25.138.118])
	by dfw-gate2.raytheon.com (8.9.3/8.9.3) with ESMTP id JAA22009
	for <linux-mm@kvack.org>; Thu, 6 Apr 2000 09:17:28 -0500 (CDT)
From: Mark_H_Johnson@Raytheon.com
Received: from rtshou-ds01.hso.link.com (rtshou-ds01.hso.link.com [130.210.151.8])
	by ds02c00.rsc.raytheon.com (8.9.3/8.9.3) with ESMTP id JAA23439
	for <linux-mm@kvack.org>; Thu, 6 Apr 2000 09:17:03 -0500 (CDT)
Subject: Query on memory management
Message-ID: <OF65849FAF.07536636-ON862568B9.004B90AB@hso.link.com>
Date: Thu, 6 Apr 2000 09:16:47 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We are looking to port some real-time applications from a larger Unix
system to a cluster of PC's running Linux. I've read through the kernel
code a few times, on both 2.2.10 and 2.2.14, but I find it hard to
understand w/o some more information.

Some of the memory related capabilities we need include:
 - memory locking [on the order of 60-80% of real memory] on the target
system.
 - build and test large subsets on a development machine in non real time.
Perhaps run with "single cycle" or 1/10th real time performance. Swapping
is OK if it means that I don't have to wait until 3am to get time on a
target system. I'm worried about reported "out of memory" problems.
 - control of page fault handling; we currently emulate flight hardware by
trapping memory accesses to I/O devices. I see a similar issue with paging
large working sets of data from static files (e.g., for a visual system)
where smart use of page replacement algorithms can simplify implementation
of lookahead.

Questions -
(1) What hard limits are there on how much memory can be mlock'd? I see
checks [in mm/mlock.c] related to num_physpages/2, but can't tell if that
is a system wide limit or a limit per process.

(2) I've seen traffic related to "out of memory" problems. How close are we
to a permanent solution & do you need suggestions? For example, I can't
seem to find any per-process limits to the "working set or virtual size"
(could refer to either the number of physical or virtual pages a process
can use). If that was implemented, some of the problems you have seen with
rogue processes could be prevented.

(3) Re: out of memory. I also saw code in 2.2.14 [arch/i386/mm/fault.c]
prevents the init task (pid==1) from getting killed. Why can't that
solution be applied to all tasks & let kswapd (or something else) keep
moving pages to the swap file (or memory mapped files) & kill tasks if and
only if the backing store on disk is gone?

(4) Is there a "hook" for user defined page replacement or page fault
handling? I could not find one.

(5) If the answer to (4) is no, could I generate a loadable module that
handled the page fault trap, and then checked a status in the task block to
determine if I should just call the default page fault handler or handle
the fault myself?

Any feedback on these questions is appreciated. Thanks.
  --Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
