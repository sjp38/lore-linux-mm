Message-Id: <l03130304b72b2f631e14@[192.168.239.105]>
In-Reply-To: <OF5A705983.9566DA96-ON86256A50.00630512@hou.us.ray.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 18 May 2001 21:13:27 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: on load control / process swapping
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson@Raytheon.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>I'm not sure you have these items measured in the kernel at this point, but
>VAX/VMS used the page replacement rate to control the working set size
>(Linux term - resident set size) within three limits...
> - minimum working set size
> - maximum guaranteed working set size (under memory pressure)
> - maximum extended working set size (no memory pressure)
>The three sizes above were enforced on a per user basis. I could see using
>the existing Linux RSS limit for the maximum guarantee (or extended) and
>then ratios for the other items.

Seems reasonable, but remember RSS != working set.  Under "normal"
conditions we want all processes to have all the memory they want, then
when memory pressure encroaches we want to keep as many processes as
possible with their working set swapped in (but no more).

>There were several parameters - some on a per system basis and others on a
>per user basis [I can't recall which were which] to control this
>including...
> - amount to increase the working set size (say 5-10% of the maximum)
> - amount to decrease the working set size (usually about 1/2 the increase
>size value)
> - pages per second replaced in the working set to trigger a possible
>increase (say 10)
> - pages per second replaced in the working set to trigger a possible
>decrease (say 2 or 1)
>A new job would start at its minimum size and grow quickly to either the
>maximum limit or its natural working set size. If at the limit, it would
>thrash but not necessarily affect the other jobs on the system. I am not
>sure how the numbers I listed would apply with a fast system with huge
>memories - the values I listed were what I recall on what would be a small
>system today (4M to 64M).

Hmm, it looks to me like the algorithm above relies on a continuous rate of
paging.  This is a bad thing on a modern system where the swap device is so
much slower than main memory.  However, the idea is an interesting one and
could possibly be adapted...

The key thing is that maximum performance for a given process (particularly
a small one) is when *no* paging is occurring in relation to it.  Under
memory pressure, this is quite hard to achieve unless the working set is
already known.  Thus the VMS model (if I understood it correctly) doesn't
work so well for modern systems running Linux.

What i was really asking, to make the question clearer is "how does
page->age work?  And if it's not suitable for WS calculation in the ways
that I suspect, what else could be used - that is *already* instrumented?".

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)
big-mail: chromatix@penguinpowered.com
uni-mail: j.d.morton@lancaster.ac.uk

The key to knowledge is not to rely on people to teach you it.

Get VNC Server for Macintosh from http://www.chromatix.uklinux.net/vnc/

-----BEGIN GEEK CODE BLOCK-----
Version 3.12
GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
-----END GEEK CODE BLOCK-----


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
