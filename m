Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0CFEB6B0036
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 05:55:30 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id bs8so7540758wib.1
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 02:55:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m2si12831405wix.100.2014.06.25.02.55.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 02:55:29 -0700 (PDT)
Date: Wed, 25 Jun 2014 10:55:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 2/4] mm: vmscan: rework compaction-ready signaling in
 direct reclaim
Message-ID: <20140625095526.GX10819@suse.de>
References: <1403282030-29915-1-git-send-email-hannes@cmpxchg.org>
 <1403282030-29915-2-git-send-email-hannes@cmpxchg.org>
 <20140623130705.GM10819@suse.de>
 <20140623172056.GN7331@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140623172056.GN7331@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 23, 2014 at 01:20:56PM -0400, Johannes Weiner wrote:
> Hi Mel,
> 
> On Mon, Jun 23, 2014 at 02:07:05PM +0100, Mel Gorman wrote:
> > On Fri, Jun 20, 2014 at 12:33:48PM -0400, Johannes Weiner wrote:
> > > Page reclaim for a higher-order page runs until compaction is ready,
> > > then aborts and signals this situation through the return value of
> > > shrink_zones().  This is an oddly specific signal to encode in the
> > > return value of shrink_zones(), though, and can be quite confusing.
> > > 
> > > Introduce sc->compaction_ready and signal the compactability of the
> > > zones out-of-band to free up the return value of shrink_zones() for
> > > actual zone reclaimability.
> > > 
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > ---
> > >  mm/vmscan.c | 67 ++++++++++++++++++++++++++++---------------------------------
> > >  1 file changed, 31 insertions(+), 36 deletions(-)
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 19b5b8016209..ed1efb84c542 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -65,6 +65,9 @@ struct scan_control {
> > >  	/* Number of pages freed so far during a call to shrink_zones() */
> > >  	unsigned long nr_reclaimed;
> > >  
> > > +	/* One of the zones is ready for compaction */
> > > +	int compaction_ready;
> > > +
> > >  	/* How many pages shrink_list() should reclaim */
> > >  	unsigned long nr_to_reclaim;
> > >  
> > 
> > You are not the criminal here but scan_control is larger than it needs
> > to be and the stack usage of reclaim has reared its head again.
> > 
> > Add a preparation patch that convert sc->may* and sc->hibernation_mode
> > to bool and moves them towards the end of the struct. Then add
> > compaction_ready as a bool.
> 
> Good idea, I'll do that.
> 

Thanks.

> > > @@ -2292,15 +2295,11 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
> > >  }
> > >  
> > >  /* Returns true if compaction should go ahead for a high-order request */
> > > -static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
> > > +static inline bool compaction_ready(struct zone *zone, int order)
> > > 
> > >  {
> > 
> > Why did you remove the use of sc->order? In this patch there is only one
> > called of compaction_ready and it looks like
> > 
> >                      if (IS_ENABLED(CONFIG_COMPACTION) &&
> >                          sc->order > PAGE_ALLOC_COSTLY_ORDER &&
> >                          zonelist_zone_idx(z) <= requested_highidx &&
> >                          compaction_ready(zone, sc->order)) {
> > 
> > So it's unclear why you changed the signature.
> 
> Everything else in compaction_ready() is about internal compaction
> requirements, like checking for free pages and deferred compaction,
> whereas this order check is more of a reclaim policy rule according to
> the comment in the caller:
> 
> 			 ...
> 			 * Even though compaction is invoked for any
> 			 * non-zero order, only frequent costly order
> 			 * reclamation is disruptive enough to become a
> 			 * noticeable problem, like transparent huge
> 			 * page allocations.
> 			 */
> 
> But it's an unrelated in-the-area-anyway change, I can split it out -
> or drop it entirely - if you prefer.
> 

It's ok as-is. It just seemed unrelated and seemed to do nothing. I was
wondering if this was a rebasing artifact and some other change that
required it got lost along the way by accident.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
