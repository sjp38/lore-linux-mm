Date: Mon, 16 Jul 2001 16:56:55 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] Separate global/perzone inactive/free shortage
Message-ID: <20010716165655.D28023@redhat.com>
References: <OF11D0664E.20E72543-ON85256A8B.004B248D@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF11D0664E.20E72543-ON85256A8B.004B248D@pok.ibm.com>; from abali@us.ibm.com on Mon, Jul 16, 2001 at 09:56:58AM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bulent Abali <abali@us.ibm.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Mike Galbraith <mikeg@wen-online.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Dirk Wetter <dirkw@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 16, 2001 at 09:56:58AM -0400, Bulent Abali wrote:
> >
> >Why not just round-robin between the eligible zones when allocating,
> >biasing each zone based on size?  On a 4GB box you'd basically end up
> >doing 3 times as many allocations from the highmem zone as the normal
> >zone and only very occasionally would you try to dig into the dma
> >zone.
> >Cheers,
> > Stephen
> 
> If I understood page_alloc.c:build_zonelists() correctly
> ZONE_HIGHMEM includes ZONE_NORMAL which includes ZONE_DMA.
> Memory allocators (other than ZONE_DMA) will dip in to the dma zone
> only when there are no highmem and/or normal zone pages available.
> So, the current method is more conservative (better) than round-robin
> it seems to me.

On a 20MB box with 16MB DMA zone and 4MB NORMAL zone, a low rate of
allocations will be continually satisfied from the NORMAL zone
resulting in constant aging and pageout within that zone, but with no
pressure at all on the larger 16MB DMA zone.  That's hardly fair.

Likewise for the small 100MB HIGHMEM zone you get at the top of memory
on a 1GB box.

Weighted round-robin has the advantage of not needing to be
special-cased for different sizes of machine.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
