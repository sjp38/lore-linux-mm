Date: Wed, 9 May 2001 12:41:39 -0700 (PDT)
From: Matt Dillon <dillon@earth.backplane.com>
Message-Id: <200105091941.f49JfdD98861@earth.backplane.com>
Subject: Re: on load control / process swapping
References: <200105082052.NAA08757@beastie.mckusick.com>
 <200105090018.f490IGR87881@earth.backplane.com> <20010509120743.Y59150@gsmx07.alcatel.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Jeremy <peter.jeremy@alcatel.com.au>
Cc: Kirk McKusick <mckusick@mckusick.com>, Rik van Riel <riel@conectiva.com.br>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

:I don't think this follows.  A program that does something like:
:{
:	extern char	memory[BIG_NUMBER];
:	int		i;
:
:	for (i = 0; i < BIG_NUMBER; i += PAGE_SIZE)
:		memory[i]++;
:}
:will thrash nicely (assuming BIG_NUMBER is large compared to the
:currently available physical memory).  Occasionally, it will be
:runnable - at which stage it has a footprint of only two pages, but

    Why only two pages?  It looks to me like the footprint is BIG_NUMBER
    bytes.

:after executing a couple of instructions, it'll have another page
:fault.  Old pages will remain resident for some time before they age
:enough to be paged out.  If the VM system is stressed, swapping this
:process out completely would seem to be a win.

    Not exactly.  Page aging works both ways.  Just accessing a page
    once does not give it priority over everything else in the page
    queues.

:...
:you ignore spikes due to process initialisation etc, a process that
:faults very quickly after being given the CPU wants a working set size
:that is larger than the VM system currently allows.  The fault rate
:would seem to be proportional to the ratio between the wanted WSS and
:allowed RSS.  This would seem to be a useful parameter to help decide
:which process to swap out - in an ideal world the VM subsystem would
:swap processes to keep the WSS of all in-core processes at about the
:size of non-kernel RAM.
:
:Peter

    Fault rate isn't useful -- maybe faults that require large disk seeks
    would be useful, but just counting the faults themselves is not useful.

						-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
