Date: Tue, 2 May 2000 14:37:28 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
In-Reply-To: <390F188F.8D3C35E1@norran.net>
Message-ID: <Pine.LNX.4.21.0005021432040.10610-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 May 2000, Roger Larsson wrote:
> Rik van Riel wrote:
> > On Tue, 2 May 2000, Roger Larsson wrote:
> > 
> > > I have been playing with the idea to have a lru for each zone.
> > > It should be trivial to do since page contains a pointer to zone.
> > >
> > > With this change you will shrink_mmap only check among relevant pages.
> > > (the caller will need to call shrink_mmap for other zone if call failed)
> > 
> > That's a very bad idea.
> 
> Has it been tested?

Yes, and it was quite bad. We ended up only freeing pages from
zones where there was memory pressure, leaving idle pages in the
other zone(s).

> I think the problem with searching for a DMA page among lots and
> lots of normal and high pages might be worse...

It'll cost you some CPU time, but you don't need to do this very
often (and freeing pages on a global basis, up to zone->pages_high
free pages per zone will let __alloc_pages() take care of balancing
the load between zones).

> > In this case you can end up constantly cycling through the pages of
> > one zone while the pages in another zone remain idle.
> 
> Yes you might. But concidering the possible no of pages in each
> zone, it might not be that a bad idea.

So we count the number of inactive pages in every zone, keeping them
at a certain minimum. Problem solved.

> You usually needs normal pages and there are more normal pages.
> You rarely needs DMA pages but there are less.
> => recycle rate might be about the same...

Then again, it might not. Think about a 1GB machine, which has
a 900MB "normal" zone and a ~64MB highmem zone.

> Anyway I think it is up to the caller of shrink_mmap to be
> intelligent about which zone it requests.

That's bull. The only place where we have information about which
page is the best one to free is in the "lru" queue. Splitting the
queue into local queues per zone removes that information.

> > Local page replacement is worse than global page replacement and
> > has always been...

(let me repeat this just in case)

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
