Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5E5F96B006E
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 13:21:06 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id k14so6795621wgh.30
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 10:21:05 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id y16si24107372wju.93.2014.06.23.10.21.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 10:21:04 -0700 (PDT)
Date: Mon, 23 Jun 2014 13:20:56 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/4] mm: vmscan: rework compaction-ready signaling in
 direct reclaim
Message-ID: <20140623172056.GN7331@cmpxchg.org>
References: <1403282030-29915-1-git-send-email-hannes@cmpxchg.org>
 <1403282030-29915-2-git-send-email-hannes@cmpxchg.org>
 <20140623130705.GM10819@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140623130705.GM10819@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Mel,

On Mon, Jun 23, 2014 at 02:07:05PM +0100, Mel Gorman wrote:
> On Fri, Jun 20, 2014 at 12:33:48PM -0400, Johannes Weiner wrote:
> > Page reclaim for a higher-order page runs until compaction is ready,
> > then aborts and signals this situation through the return value of
> > shrink_zones().  This is an oddly specific signal to encode in the
> > return value of shrink_zones(), though, and can be quite confusing.
> > 
> > Introduce sc->compaction_ready and signal the compactability of the
> > zones out-of-band to free up the return value of shrink_zones() for
> > actual zone reclaimability.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  mm/vmscan.c | 67 ++++++++++++++++++++++++++++---------------------------------
> >  1 file changed, 31 insertions(+), 36 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 19b5b8016209..ed1efb84c542 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -65,6 +65,9 @@ struct scan_control {
> >  	/* Number of pages freed so far during a call to shrink_zones() */
> >  	unsigned long nr_reclaimed;
> >  
> > +	/* One of the zones is ready for compaction */
> > +	int compaction_ready;
> > +
> >  	/* How many pages shrink_list() should reclaim */
> >  	unsigned long nr_to_reclaim;
> >  
> 
> You are not the criminal here but scan_control is larger than it needs
> to be and the stack usage of reclaim has reared its head again.
> 
> Add a preparation patch that convert sc->may* and sc->hibernation_mode
> to bool and moves them towards the end of the struct. Then add
> compaction_ready as a bool.

Good idea, I'll do that.

> > @@ -2292,15 +2295,11 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
> >  }
> >  
> >  /* Returns true if compaction should go ahead for a high-order request */
> > -static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
> > +static inline bool compaction_ready(struct zone *zone, int order)
> > 
> >  {
> 
> Why did you remove the use of sc->order? In this patch there is only one
> called of compaction_ready and it looks like
> 
>                      if (IS_ENABLED(CONFIG_COMPACTION) &&
>                          sc->order > PAGE_ALLOC_COSTLY_ORDER &&
>                          zonelist_zone_idx(z) <= requested_highidx &&
>                          compaction_ready(zone, sc->order)) {
> 
> So it's unclear why you changed the signature.

Everything else in compaction_ready() is about internal compaction
requirements, like checking for free pages and deferred compaction,
whereas this order check is more of a reclaim policy rule according to
the comment in the caller:

			 ...
			 * Even though compaction is invoked for any
			 * non-zero order, only frequent costly order
			 * reclamation is disruptive enough to become a
			 * noticeable problem, like transparent huge
			 * page allocations.
			 */

But it's an unrelated in-the-area-anyway change, I can split it out -
or drop it entirely - if you prefer.

> > @@ -2500,12 +2492,15 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
> >  		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
> >  				sc->priority);
> >  		sc->nr_scanned = 0;
> > -		aborted_reclaim = shrink_zones(zonelist, sc);
> > +		shrink_zones(zonelist, sc);
> >  
> >  		total_scanned += sc->nr_scanned;
> >  		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
> >  			goto out;
> >  
> > +		if (sc->compaction_ready)
> > +			goto out;
> > +
> 
> break?
> 
> Convert the other one to break as well. out label seems unnecessary in
> this context.

Makes sense, I'll include this in v2.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
