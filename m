Message-Id: <200105082052.NAA08757@beastie.mckusick.com>
Subject: Re: on load control / process swapping 
In-Reply-To: Your message of "Mon, 07 May 2001 15:50:20 PDT."
             <200105072250.f47MoKe68863@earth.backplane.com>
Date: Tue, 08 May 2001 13:52:58 -0700
From: Kirk McKusick <mckusick@mckusick.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>
Cc: Rik van Riel <riel@conectiva.com.br>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

I know that FreeBSD will swap out sleeping processes, but will it
ever swap out running processes? The old BSD VM system would do so
(we called it hard swapping). It is possible to get a set of running
processes that simply do not all fit in memory, and the only way
for them to make forward progress is to cycle them through memory.

As to the size issue, we used to be biased towards the processes
with large resident set sizes in kicking things out. In general,
swapping out small things does not buy you much memory and it
annoys more users. To avoid picking on the biggest, each time we
needed to kick something out, we would find the five biggest, and 
kick out the one that had been memory resident the longest. The
effect is to go round-robin among the big processes. Note that
this algorithm allows you to kick out shells, if they are the
biggest processes. Also note that this is a last ditch algorithm
used only after there are no more idle processes available to
kick out. Our decision that we had had to kick out running
processes was: (1) no idle processes available to swap, (2) load
average over one (if there is just one process, kicking it out
does not solve the problem :-), (3) paging rate above a specified
threshhold over the entire previous 30 seconds (e.g., been bad 
for a long time and not getting better in the short term), and
(4) paging rate to/from swap area using more than half the 
available disk bandwidth (if your filesystems are on the same
disk as you swap areas, you can get a false sense of success
because all your process stop paging while they are blocked
waiting for their file data.

	Kirk
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
