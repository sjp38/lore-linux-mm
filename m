Date: Sun, 7 May 2000 10:53:29 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [DATAPOINT] pre7-6 will not swap
In-Reply-To: <Pine.LNX.4.21.0005071418520.8605-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.10.10005071048120.30202-100000@cesium.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, Benjamin Redelings I <bredelin@ucla.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 7 May 2000, Rik van Riel wrote:

> On Sat, 6 May 2000, Linus Torvalds wrote:
> 
> >  - looking at "shrink_mmap()", my reaction would not be to add more
> >    complexity to it, but to remove the _one_ special case that looks at
> >    one specific zone:
> > 
> >         /* wrong zone?  not looped too often?    roll again... */
> >         if (page->zone != zone && count)
> >                 goto again;
> > 
> >    I would suggest just removing that test altogether. The page wasn't
> >    from a "wrong zone". It was just a different zone that also needed
> >    balancing.
> 
> The danger in this is that we could "use up" the remaining
> ticks on the count variable in do_try_to_free_pages() and
> end up with a failed rmqueue for the request...

I agree.

However, I think the logic should be
 - kswapd tries to keep all zones reasonably well balanced
 - but kswapd obviously cannot do a perfect job, especially with bursty
   allocations, so:
 - we should at some point start synchronously helping kswapd
 - if somebody has special requirements, they may not be always possibly
   under all circumstances.

Basically, it boils down to: we should try to do our best, but we cannot
do wonders and we should realize that too.

> Oh, and the return value for shrink_mmap() will still
> indicate success, even if we failed to free a page for
> the zone we intended ... we've already decided for that
> before we get into the loop or not.

You're right. The only downside to the extra test is that it unbalances
the page freeing, and can lead to (for example) not using swap very
efficiently because we're looping too much in shrink_mmap. Which actually
seems to be one of the symptoms right now, but it may of course be dueto
something else too.

It can also make the aging less efficient.

But my real reason for disliking it is that I prefer conceptually simple
approaches, and that one test just doesn't fit conceptually ;)

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
