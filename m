From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200001132140.NAA27848@google.engr.sgi.com>
Subject: Re: [RFC] 2.3.39 zone balancing
Date: Thu, 13 Jan 2000 13:40:09 -0800 (PST)
In-Reply-To: <Pine.LNX.4.21.0001132059590.981-100000@alpha.random> from "Andrea Arcangeli" at Jan 13, 2000 09:13:41 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@nl.linux.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> On Thu, 13 Jan 2000, Rik van Riel wrote:
> 
> >Now we'll only want to build something into kswapd
> >so that rebalancing the high memory zones is done in
> >the background.
> 
> You never need to rebance the bigmem between 1g and 64g withing kswapd.
> This because bh/irq handlers are not going to use it. So kswapd has to
> care only about the memory below the bigmem boundary.
>

Ohh, then there's another problem. Note that try_to_swap_out() currently
does
        if (PageReserved(page)
            || PageLocked(page)
            || (zone && (!memclass(page->zone, zone))))
                goto out_failed;

kswapd passes in a zone = 0 argument. 

This (and all similar places) will need to be changed to
        if (PageReserved(page)
            || PageLocked(page)
            || (zone && (!memclass(page->zone, zone)))
            || ((zone == 0) && PageHighMem(page)))

Either that, or we should teach kswapd about zones, then kswapd can
pass in the zone pointer it is trying to get balanced. For 2.3, kswapd
will not pass in the highmem zone pointer. That would also mean that
Andrea's patch below will not be needed.

I will create a zone-aware kswapd patch, built on top of the one I
already put out, and send that out asap.

Kanoj
 
> BTW I just noticed currently (2.3.40pre1) kswapd is completly
> screwedup. kswapd should still do:
> 
> 		while (nr_free_pages - nr_free_bigpages < freepages.high)
> 
> exactly like in our early 2.3.18 bigmem code because _nothing_ is changed
> is the basic MM design since that time.
> 
> The fix against 2.3.40pre1 to re-activate kswapd is this:
> 
> --- 2.3.40pre1/mm/vmscan.c	Sun Jan  9 20:45:31 2000
> +++ /tmp/vmscan.c	Thu Jan 13 21:09:33 2000
> @@ -503,7 +503,7 @@
>  		do {
>  			/* kswapd is critical to provide GFP_ATOMIC
>  			   allocations (not GFP_HIGHMEM ones). */
> -			if (nr_free_buffer_pages() >= freepages.high)
> +			if (nr_free_pages() - nr_free_highpages() >= freepages.high)
>  				break;
>  			if (!do_try_to_free_pages(GFP_KSWAPD, 0))
>  				break;
> 
> 
> Andrea
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
