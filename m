Date: Sat, 6 May 2000 12:35:00 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [DATAPOINT] pre7-6 will not swap
In-Reply-To: <39145287.D8F1F0C1@sgi.com>
Message-ID: <Pine.LNX.4.10.10005061225460.1470-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: Benjamin Redelings I <bredelin@ucla.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 6 May 2000, Rajagopal Ananthanarayanan wrote:
> 
> Linus has taken in the fix to "old" vs. "young" in shrink_mmap,
> and taken out the aggressive counter change (also in shrink_mmap).
> But apparently another change in try_to_swap_out is causing problems.
> I haven't an analytical evaluation, but empericically, if I remove this
> in try_to_swap_out (mm/vmscan.c), dbench runs ok.

Yes. I was thinking some more about it, and it isusing the wrong test. It
must use the same test as the one in page_alloc.cto determine whether
azone is "interesting" or not - otherwise you get into a situation where
page_alloc.c doesn't want to allocate from a zone because it's not quite
empty enough, but at the same time vmscan doesn't want to free pages from
the zone because it's not quite full enough.

No wonder that if you get to that situation, the allocator starts getting
unhappy and says "no free pages".

> --------------- mm/vmscan.c around line 113 --------------
>         /*
>          * Don't do any of the expensive stuff if
>          * we're not really interested in this zone.
> 	 */
>         if (!page->zone->zone_wake_kswapd)
>                 goto out_unlock;

Make this test be the same as in "__alloc_pages()" in mm/page_alloc.c, and
it should be ok. The test there is:

                /* Are we supposed to free memory? Don't make it worse.. */
                if (!z->zone_wake_kswapd && z->free_pages > z->pages_low) {

and I suspect that we mightactually make the vmscan.c test more eager to
swap stuff out: my private source tree says

        /*
         * Don't do any of the expensive stuff if
         * we're not really interested in this zone.
         */
	if (z->free_pages > z->pages_high) 
		goto out_unlock;

in vmscan.c, and that seems to be quite well-behaved too (but if somebody
has the energy to test the two different versions, I'd absolutely love to
hear results..)

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
