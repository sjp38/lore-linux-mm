Date: Tue, 17 Jul 2001 04:55:34 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: [PATCH] Separate global/perzone inactive/free shortage
In-Reply-To: <20010716193033.H28023@redhat.com>
Message-ID: <Pine.LNX.4.33.0107170450360.486-100000@mikeg.weiden.de>
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
> On Mon, Jul 16, 2001 at 05:44:17PM +0200, Mike Galbraith wrote:
>
> > > Why not just round-robin between the eligible zones when allocating,
> > > biasing each zone based on size?
>
> > What prevents this from happening, and lets make ZONE_DINKY _really_
> > dinky just for the sake of argument.  ZONE_DINKY will have say 4 pages,
> > one for active, dirty, clean and free.  Balanced is 2 dirty and 2 free,
> > or 1 free, 1 clean and 1 dirty.  2 tasks are running, and both are giant
> > economy size, with very nearly 2gig of vm allocated each.
> >
> > ZONE_DINKY, ZONE_BIG, and ZONE_MONDO are all fully engaged and under
> > pressure.  ZONE_DINKY gets aged/laundered such that it is in balance.
> > Task A is using 1 ZONE_DINKY page.  Task B requests a page to do pagein,
> > and reclaims a page from ZONE_DINKY because there's only 1 free page.
> > We are back to inactive shortage instantly, so we have to walk 4gig of
> > vm looking for one ZONE_DINKY page to activate/age/deactivate.  During
> > the aging process, any other in use page from that zone is fair game.
>
> Agreed, but in that sort of case, if we have (say) close 1GB in
> ZONE_NORMAL and 16MB in ZONE_DMA, then only one allocation in 64 will
> even _try_ to allocate from the DMA zone.  Replace the DMA zone with a
> hypothetical DINKY 4-page zone and it goes down to one allocation in
> 65536.  You don't reduce the cost of a DINKY allocation, but you
> reduce the change that such an allocation will happen.
>
> The balanced round-robin still seems like a helpful next step here
> even if it doesn't cure all the balance problems immediately.

Yes, this should mitigate the effect.  I think something will still
end up having to be done about the search time though.  Dirk's case
seems to be the pathalogical one.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
