Date: Thu, 22 Jun 2000 13:05:06 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] RSS guarantees and limits
In-Reply-To: <85256906.0056DB76.00@D51MTA03.pok.ibm.com>
Message-ID: <Pine.LNX.4.21.0006221252420.10785-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: frankeh@us.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jun 2000 frankeh@us.ibm.com wrote:

> I assume that in the <workstation> scenario, where there are
> limited number of processes, your approach will work just fine.
> 
> In a server scenario where you might have lots of processes
> (with limited resource requirements) this might have different
> effects This inevidably will happen when we move Linux to NUMA
> or large scale SMP systems and we apply images like that to
> webhosting.

This is exactly why I want to have the RSS guarantees and
limits auto-tune themselves, depending on the ratio between
re-faults (where we have stolen a page from the working set
of a process) and page steals (these pages were not from the
working set).

If we steal a lot of pages from a process and the process
doesn't take these same pages back, we should continue stealing
from that process since obviously it isn't using all its pages.
(or it only uses the pages once)

Also, stolen pages will stay around in memory, outside of the
working set of the process, but in one of the various caches.
If they are faulted back very quickly no disk IO is needed at
all ... and faulting them back quickly is an indication that
we're stealing too many pages from the process.

> Do you think that the resulting RSS guarantees (function of
> <mem_size/2*process_count>) will be sufficient ?

The RSS guarantee is just that, a guarantee. We guarantee that
the RSS of the process will not be shrunk below its guarantee,
but that doesn't stop any process from having a larger RSS (up
to its RSS limit).

> Or is your assumption, that for this kind of server apps with
> lots of running processes, you better don't overextent your
> memory and start paging (acceptable assumption)..

If we recycle memory pages _before_ the application can re-fault
them in from the page/swap cache, it won't be able to make the
re-fault and its RSS guarantee and limit will be shrunk...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
