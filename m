Date: Mon, 16 Jul 2001 17:44:17 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: [PATCH] Separate global/perzone inactive/free shortage
In-Reply-To: <20010716141915.C28023@redhat.com>
Message-ID: <Pine.LNX.4.33.0107161606330.328-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Dirk Wetter <dirkw@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Jul 2001, Stephen C. Tweedie wrote:

> Hi,
>
> > On Sat, 14 Jul 2001, Marcelo Tosatti wrote:
>
> > On highmem machines, wouldn't it save a LOT of time to prevent allocation
> > of ZONE_DMA as VM pages?  Or, if we really need to, get those pages into
> > the swapcache instantly?  Crawling through nearly 4 gig of VM looking for
> > 16 MB of ram has got to be very expensive.  Besides, those pages are just
> > too precious to allow some user task to sit on them.
>
> Can't we balance that automatically?
>
> Why not just round-robin between the eligible zones when allocating,
> biasing each zone based on size?  On a 4GB box you'd basically end up
> doing 3 times as many allocations from the highmem zone as the normal
> zone and only very occasionally would you try to dig into the dma
> zone.  But on a 32MB box you would automatically spread allocations
> 50/50 between normal and dma, and on a 20MB box you would be biased in
> favour of allocating dma pages.

Parceling them out biased according to size would distribute pressure
equally.. except on task vm.. I think.

What prevents this from happening, and lets make ZONE_DINKY _really_
dinky just for the sake of argument.  ZONE_DINKY will have say 4 pages,
one for active, dirty, clean and free.  Balanced is 2 dirty and 2 free,
or 1 free, 1 clean and 1 dirty.  2 tasks are running, and both are giant
economy size, with very nearly 2gig of vm allocated each.

ZONE_DINKY, ZONE_BIG, and ZONE_MONDO are all fully engaged and under
pressure.  ZONE_DINKY gets aged/laundered such that it is in balance.
Task A is using 1 ZONE_DINKY page.  Task B requests a page to do pagein,
and reclaims a page from ZONE_DINKY because there's only 1 free page.
We are back to inactive shortage instantly, so we have to walk 4gig of
vm looking for one ZONE_DINKY page to activate/age/deactivate.  During
the aging process, any other in use page from that zone is fair game.

Merely posessing pages from a small zone implies a higher turnover rate,
and that has to be bad.  In this made up case, it would be horrible.
ZONE_DINKY pages in mondo task's vm would shred them.

To kill the search overhead, you could flag areas with possession info,
but that won't stop the turnover differential problem when your resources
are all engaged.

Is there anything wrong with this logic?  If not, it's just a matter
of scaling the problem to real life numbers.

(maybe I should stop thinking about vm.. makes me dizzy;)

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
