Received: from northrelay01.pok.ibm.com (northrelay01.pok.ibm.com [9.117.200.21])
	by e3.ny.us.ibm.com (8.9.3/8.9.3) with ESMTP id MAA42364
	for <linux-mm@kvack.org>; Thu, 22 Jun 2000 12:20:03 -0400
From: frankeh@us.ibm.com
Received: from D51MTA03.pok.ibm.com (d51mta03.pok.ibm.com [9.117.200.31])
	by northrelay01.pok.ibm.com (8.8.8m3/NCO v2.07) with SMTP id MAA193262
	for <linux-mm@kvack.org>; Thu, 22 Jun 2000 12:21:54 -0400
Message-ID: <85256906.0059E21B.00@D51MTA03.pok.ibm.com>
Date: Thu, 22 Jun 2000 12:22:55 -0400
Subject: Re: [RFC] RSS guarantees and limits
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Now I understand this much better. The RSS guarantee is a function of the
refault-rate <clever>.
This in principle implements a decay of the limit based on usage.... I like
that approach.
Is there a hardstop RSS limit below you will not evict pages from a process
(e.g.   mem_size / MAX_PROCESSES ?) to give some interactivity for
processes that haven't executed for a while, or you just let it go down
based on the refault-rate...

-- Hubertus




Rik van Riel <riel@conectiva.com.br>@kvack.org on 06/22/2000 12:35:06 PM

Sent by:  owner-linux-mm@kvack.org


To:   Hubertus Franke/Watson/IBM@IBMUS
cc:   linux-mm@kvack.org
Subject:  Re: [RFC] RSS guarantees and limits



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
http://www.conectiva.com/          http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
