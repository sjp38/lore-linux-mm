Date: Sat, 6 May 2000 19:23:36 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [DATAPOINT] pre7-6 will not swap
In-Reply-To: <39149B81.B92C8741@sgi.com>
Message-ID: <Pine.LNX.4.10.10005061905180.29159-100000@cesium.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: riel@nl.linux.org, Benjamin Redelings I <bredelin@ucla.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 6 May 2000, Rajagopal Ananthanarayanan wrote:
> 
> I have a hunch. Follow this argument closely. In shrink_mmap we have:
> 
> ------------
> 	if (p_zone->free_pages > p_zone->pages_high)
>                         goto dispose_continue;
> ------
> 
> This page doesn't count against a valid try in shrink_mmap().

[ second-scan logic ]

Ugh.

This may be right, but it also gets my hackles up for being "too
contrieved". It shouldn't be this complex.

Either "shrink_mmap()" should care about the zone or it shouldn't. If it
should, then it should just check the particular zone that it was passed
in (ie basically per-zone LRU again). If it shouldn't, then it probably
should just take the LRU as-is.

Also, one thing that keeps me wondering is whether the current
"try_to_free_pages()" is right at all.

Remember: the fundamental operation isn't really "try_to_free_pages()"
Nobody really ever calls that directly. The fundamental operation we
want to have is really just "balance_zones()", and it may be that the
by isolating the "zone" we're aiming for early in balance_zones() we've
done a mistake.

My personal inclination is along the lines of
 - we never really care about any particular zone. We should make sure
   that all zones get balanced, and that is what running kswapd will
   eventually cause. 
 - things like "shrink_mmap" and "vmscan" should both free any page from
   any zone that is (a) a good candidateand (b) the zone is not yet
   well-balanced.
 - looking at "shrink_mmap()", my reaction would not be to add more
   complexity to it, but to remove the _one_ special case that looks at
   one specific zone:

        /* wrong zone?  not looped too often?    roll again... */
        if (page->zone != zone && count)
                goto again;

   I would suggest just removing that test altogether. The page wasn't
   from a "wrong zone". It was just a different zone that also needed
   balancing.

That single test stands out as being zone-specific instead of geared
towards the bigger goal of "let's balance the zones". It would also cause
"shrink_mmap()" to =return= failure, even if shrink_mmap() actually ended
up doing real work. Which just seems wrong.

So instead of making that test more complicated and adding a "phase"
counter, why not just remove it? Then "shrink_mmap()"will start failing
onlywhen it _truly_ fails - ie when it no longer can find any pages really
worth freeing. 

		Linus "gut instinct" Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
