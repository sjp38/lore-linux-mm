From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200001132213.OAA37225@google.engr.sgi.com>
Subject: Re: [RFC] 2.3.39 zone balancing
Date: Thu, 13 Jan 2000 14:13:49 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.10001131347490.2250-100000@penguin.transmeta.com> from "Linus Torvalds" at Jan 13, 2000 02:01:27 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@nl.linux.org>, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> 
> On Thu, 13 Jan 2000, Alan Cox wrote:
> >
> > > doc. If you have a large number of free regular pages, and the dma
> > > zone is completely exhausted, the 2.2 decision of balacing the dma
> > > zone might never fetch an "yes" answer, because it is based on total
> > > number of free pages, not also the per zone free pages. Right? Things 
> > > will get worse the more non-dma pages there are.
> > 
> > We might not make good choices to free ISA DMA pages, you are correct yes
> 
> What I think needs to happen is something like
>  - global page table aging logic (it would be surreal to try to age the
>    page table entries on a per-zone basis, because page tables do not have
>    zones)
>  - per-zone page freeing logic
> 
> Right now we do neither. Out page table aging thing (swap_out()) looks at
> the zone (which I don't think it should), while our shrink_mmap() is often
> completely zone-unaware (ie kswapd uses a NULL zone).
> 
> The reason swap_out() looks at the zone is that a long time ago the logic
> was that you should avoid swapping normal pages out if you really only
> needed DMA pages. I think that logic is broken in the larger picture (when
> there are multiple kinds of zones), and is unnecessary even in the old
> sense, because these days the swap cache works just fine for us, and
> should make the impact of "wrong zone" swapouts be insignificant.

Okay, no big code change there. try_to_swap_out() can probably still accept 
a "zone" argument, like it currently does, except that it does not need
to use it. I assume this would also hold for shm_swap()?

> 
> So, I'd like somebody to _try_ to (a) rip out the zone-awareness from
> swap_out() completely and (b) make kswapd do something more like
> 
> 	more_work = 0;
> 	for (i = 0; i < NR_ZONES; i++) {
> 		more_work |= balance_zone(zone+i)
> 	}		
> 	if (!more_work)
> 		sleep()
> 
> where "balance_zone()" would really be a per-zone "shrink_mmap()" with the
> free page logic taken into account.
>

Yes, that's what everyone seems to be pointing at. As I mentioned, I am
looking into this as I type. The only thing is, as Andrea points out, 
2.3 bh/irq handlers do not request HIGHMEM pages, so shouldn't the
2.3 kswapd do something more like: 

       more_work = 0;
       for (i = 0; i < MAX_NR_ZONES; i++) {
		if (i != ZONE_HIGHMEM)
               		more_work |= balance_zone(zone+i)
       }
       if (!more_work)
               sleep()


Kanoj

> Sounds reasonable?
> 
> 		Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.nl.linux.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
