Received: from ds02c00.directory.ray.com (ds02c00.directory.ray.com [147.25.138.118])
	by dfw-gate3.raytheon.com (8.12.9/8.12.9) with ESMTP id h3PF5eum009681
	for <linux-mm@kvack.org>; Fri, 25 Apr 2003 10:05:41 -0500 (CDT)
Received: from ds02c00.directory.ray.com (localhost [127.0.0.1])
	by ds02c00.directory.ray.com (8.12.9/8.12.1) with ESMTP id h3PF5cXb024226
	for <linux-mm@kvack.org>; Fri, 25 Apr 2003 15:05:38 GMT
Received: from rtshou-ds01.hou.us.ray.com ([192.27.45.147])
	by ds02c00.directory.ray.com (8.12.9/8.12.1) with ESMTP id h3PF5V8R024086
	for <linux-mm@kvack.org>; Fri, 25 Apr 2003 15:05:34 GMT
MIME-Version: 1.0
From: Mark_H_Johnson@Raytheon.com
Subject: Status of locked memory
Date: Fri, 25 Apr 2003 10:05:19 -0500
Message-ID: <OF2762E1C6.85ED267A-ON86256D13.0052E0B2-86256D13.0052E28C@hou.us.ray.com>
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Is there some way to determine how much memory is currently
locked in the system (not process by process)?

We have some real time applications (w/ lots of locked memory) and would
like to confirm how much is being used in the system. We can see from the
2.4.20 kernel source that the amount of locked memory appears to be stored
on a per process basis; ref:
  mm/mlock.c:195-224
  current->mm->locked_vm
is used to compare with the physical memory to provide a limit on the
amount of memory an appliation can lock.

But that does not appear to be summed on a per system basis and can
be accessed from user mode only through
  /proc/PID/status

Has any consideration been made to track locked memory on a per system
basis, and if so who could I talk to about this?

Also - in looking at the numbers reported by
  /proc/PID/status
they don't seem to add up. Here is an example from a program running
on a 2.4.16 kernel.

VmSize:   441636 kB
VmLck:    441636 kB
VmRSS:    259684 kB
VmData:   192960 kB
VmStk:      1768 kB
VmExe:     13208 kB
VmLib:      1496 kB

where mlockall() was performed (Size == Locked).
I expected Size == Locked == RSS, but that isn't close - what is
the reason for the large difference?

One reason may be the bigphysarea patch, so here's the output from that:

Big physical area, size 131072 kB
                       free list:             used list:
number of blocks:            22                     21
size of largest block:    39884 kB               34208 kB
total:                    39968 kB               91104 kB

So I might think that Size == RSS + bigphysarea, but that leaves me about
90 Meg short. Any ideas what numbers should add up to the total?

Thanks.
--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
