Date: Tue, 25 Apr 2000 22:19:05 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: 2.3.x mem balancing
In-Reply-To: <Pine.LNX.4.10.10004251656150.1145-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0004252203040.14340-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Apr 2000, Linus Torvalds wrote:
> On Tue, 25 Apr 2000, Rik van Riel wrote:
> > 
> > The only bug I can see is that page _freeing_ in the current
> > code is done on a per-zone basis, so that we could end up with
> > a whole bunch of underused pages in one zone and too much
> > memory pressure in the other zone.
> 
> 	/* Don't free a page if the zone in question is fine */
> 	if (!page->zone->zone_wake_kswapd)
> 		return 0;

This will only start freeing memory from a zone *after*
it has been low on memory, which could take ages if the
memory movement in that zone is very low...

if (page->zone->free_pages > page->zone->pages_high)
	return 0;

This way we'll always free the least used pages from
other zones, up to zone->pages_high, regardless of
memory pressure on that zone. This means that the
allocator has an easier job of identifying "idle" zones
and that load balancing between zones is way faster.

I've been running this code (in shrink_mmap()) for almost
one week now and it seems to work pretty well.

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
