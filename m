Date: Thu, 25 May 2000 14:17:38 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] 2.3/4 VM queues idea
In-Reply-To: <20000525185059.A20563@pcep-jamie.cern.ch>
Message-ID: <Pine.LNX.4.21.0005251405160.32434-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Matthew Dillon <dillon@apollo.backplane.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 May 2000, Jamie Lokier wrote:
> Matthew Dillon wrote:
> >     Yes, but at an unreasonable cost:  Artificially limiting the number
> >     of discrete processes able to share a given amount of memory.  Any
> >     reasonable limit would still be an order of magnitude more expensive
> >     then a physical page scan.
> 
> I disagree.  The "amount of sharing" scan-time overhead is there
> whether you do a physical or virtual scan.  For a physical scan,
> if you have a lot of sharing then you look at a lot of ptes per
> page.

Not really. If there are enough inactive pages, the active
pages will never be scanned. And when the active pages get
scanned, chances are that only a few of them (the ones near
the "end" of the queue) need to be scanned.

With virtual scanning, OTOH, you'll need to scan all pages
since you have no "candidate list" of which pages are more
likely to be suitable candidates for swapout.

> One possible goal is to limit the total number of mapped ptes in
> the system.  You can still permit a lot of sharing: the number
> does not have to be limited per task or per mm.

No. The goal is to have an efficient memory management system
which supports running a lot of applications efficiently.

This idea would place an artificial limit on the number of
shared pages between processes. If your particular workload
needs more you'll spend your time handling soft pagefaults
and finding pages to unmap. Even though the machine has
enough physical memory to hold all the pages (and their
pte mappings) and there is no memory load.

If we do NOT have such an artificial restriction, then we
could end up with slightly more scanning overhead when we
have memory pressure, but at least the system would run
fine in situations where we do have enough memory.

> >     And even with limits you still wind up with extremely non-deterministic
> >     scanning.
> 
> How so?  You're only scanning currently mapped ptes, and one
> goal is to keep that number small enough that you can gather
> good LRU stats of page usage.

Page aging may well be cheaper than continuously unmapping ptes
(including tlb flushes and cache flushes of the page tables) and
softfaulting them back in.

> Fwiw, with COW address_spaces (I posted an article a couple of
> weeks ago explaining) it should be fairly simple to find all the
> ptes for a given page without the space overhead of pte
> chaining.

But what if you have a page which is 1) mapped in multiple
addresses by different apps  and 2) COW shared by subsets
of those multiple apps?

We still need pte chaining or something similar.

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
