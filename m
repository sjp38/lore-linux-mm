Date: Mon, 15 May 2000 11:36:03 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] VM stable again?
In-Reply-To: <Pine.LNX.4.10.10005151729430.6248-100000@elte.hu>
Message-ID: <Pine.LNX.4.10.10005151132360.3637-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 15 May 2000, Ingo Molnar wrote:
> 
> yep, this should work. A minor comment:
> 
> > +		if (atomic_read(&free_before_allocate))
> 
> i believe this needs to be per-zone and should preferably be read within
> the zone spinlock - not atomic operations. Updating a global counter is a
> big time problem on SMP.

Nope.

It can't be per zone, because there is no "zone". There is only a generic
balance between different zones.

And the critical path actually only reads the counter, which is fine on
SMP: most of the time the counter should be quiescent, with every CPU just
having a shared copy in their caches. 

However, I do think that it might make sense to make this per-zonelist, so
that if a DMA request (or a request on another node in a NUMA environment)
causes another zone-list to be low-on-memory, that should not affect the
other zone-lists.

(The per-zonelist version should have pretty much the same behaviour as a
global one in the normal cases, it's just that it doesn't have the bad
behaviour in the uncommon cases).

Rik, mind cleaning that up, and fixing the leak? After that it looks
fine..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
