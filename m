Date: Fri, 14 Jan 2000 00:53:00 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <Pine.LNX.4.10.10001131428250.2250-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10001140040040.6274-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@nl.linux.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2000, Linus Torvalds wrote:

> >        more_work = 0;
> >        for (i = 0; i < MAX_NR_ZONES; i++) {
> > 		if (i != ZONE_HIGHMEM)
> >                		more_work |= balance_zone(zone+i)
> 
> No, the other reason for kswapd is to get "smoother" behaviour, by trying
> to keep some memory free. Also, while we don't use high-memory pages right
> now in BH and irq contexts, I don't think that is something we need to
> codify, and it may change in the future. There's no real reason per se for
> not using them (except for complexity), so I'd hate to have a special case
> for that case.

one more thing, i think there is a real possibility for the following
scenario to happen: well used server, pagecache takes up all the RAM, as
it should. Application just happens to run out of free RAM and we allocate
from the DMA zone. Then the application happens to use these DMA pages
heavily, and which pages thus become unlikely to get freed. Ie. kswapd
will feel the memory pressure in the DMA zone, without being able to help
the situation. Just running kswapd for a long time will not help the
situation, because the DMA pages are highly used.

so why cant swap_out (conceptually) accept a 'zones under pressure'
bitmask as an input, and calculate zones from the physical address it sees
in the page table. Some per-architecture thing like:

	static inline pte_in_zonemask (pte, unsigned long mask)
	{
		idx = pte_to_pagenr(pte);

		/*
		 * Pages are more likely to be in the highest zone
		 */
		for (i = ZONE_MAX-1; i--; ) {
			struct zone_t *zone = zones + i;

			if (zone->offset < idx)
				return (1 << (zone-zones)) & mask;
		}
	}

since ZONE_MAX is 2 or 3 typically, this will likely be unrolled. It's not
going to be as fast as now, but it's simple nevertheless. (and swapping
out is never fast in the first place)

so if kswapd generated a memory pressure 'zone bitmask' instead of a
single zone (single zone is definitely broken), then we could solve such
situations as well. This is at the price of kswapd looping through
pagetables, but i think we should be ready to pay this price for
predictability. Only GFP_DMA16 will pay such price, GFP_NORMAL is likely
to succeed in typical systems. Once highmem_pages/normal_pages is getting
larger, this cost goes up as well.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
