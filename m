Content-return: prohibited
Date: Wed, 09 May 2001 12:07:43 +1000
From: Peter Jeremy <peter.jeremy@alcatel.com.au>
Subject: Re: on load control / process swapping
In-reply-to: <200105090018.f490IGR87881@earth.backplane.com>; from
 dillon@earth.backplane.com on Tue, May 08, 2001 at 05:18:16PM -0700
Message-id: <20010509120743.Y59150@gsmx07.alcatel.com.au>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-disposition: inline
References: <200105082052.NAA08757@beastie.mckusick.com>
 <200105090018.f490IGR87881@earth.backplane.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>
Cc: Kirk McKusick <mckusick@mckusick.com>, Rik van Riel <riel@conectiva.com.br>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

On 2001-May-08 17:18:16 -0700, Matt Dillon <dillon@earth.backplane.com> wrote:
>    I don't think we want to kick out running processes.  Thrashing
>    by definition means that many of the processes are stuck in 
>    disk-wait, usually from a VM fault, and not running.  The other 
>    effect of thrashing is, of course, the the cpu idle time goes way
>    up due to all the process stalls.  A process that is actually able 
>    to run under these circumstances probably has a small run-time footprint
>    (at least for whatever operation it is currently doing), so it should
>    definitely be allowed to continue to run.

I don't think this follows.  A program that does something like:
{
	extern char	memory[BIG_NUMBER];
	int		i;

	for (i = 0; i < BIG_NUMBER; i += PAGE_SIZE)
		memory[i]++;
}
will thrash nicely (assuming BIG_NUMBER is large compared to the
currently available physical memory).  Occasionally, it will be
runnable - at which stage it has a footprint of only two pages, but
after executing a couple of instructions, it'll have another page
fault.  Old pages will remain resident for some time before they age
enough to be paged out.  If the VM system is stressed, swapping this
process out completely would seem to be a win.

Whilst this code is artificial, a process managing a very large hash
table will have similar behaviour.

Given that most (all?) recent CPU's have cheap hi-resolution clocks,
would it be worthwhile for the VM system to maintain a per-process
page fault rate?  (average clock cycles before a process faults).  If
you ignore spikes due to process initialisation etc, a process that
faults very quickly after being given the CPU wants a working set size
that is larger than the VM system currently allows.  The fault rate
would seem to be proportional to the ratio between the wanted WSS and
allowed RSS.  This would seem to be a useful parameter to help decide
which process to swap out - in an ideal world the VM subsystem would
swap processes to keep the WSS of all in-core processes at about the
size of non-kernel RAM.

Peter
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
