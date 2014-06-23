Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 95C076B0039
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 14:20:33 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id t60so7501362wes.32
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 11:20:31 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id co1si18001272wib.21.2014.06.23.11.20.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 11:20:30 -0700 (PDT)
Date: Mon, 23 Jun 2014 14:20:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/4] mm: vmscan: rework compaction-ready signaling in
 direct reclaim
Message-ID: <20140623182017.GO7331@cmpxchg.org>
References: <1403282030-29915-1-git-send-email-hannes@cmpxchg.org>
 <1403282030-29915-2-git-send-email-hannes@cmpxchg.org>
 <20140623063637.GB15594@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140623063637.GB15594@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 23, 2014 at 03:36:37PM +0900, Minchan Kim wrote:
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
> Acked-by: Minchan Kim <minchan@kernel.org>

Thanks!

> > @@ -2292,15 +2295,11 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
> >  }
> >  
> >  /* Returns true if compaction should go ahead for a high-order request */
> > -static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
> > +static inline bool compaction_ready(struct zone *zone, int order)
> >  {
> >  	unsigned long balance_gap, watermark;
> >  	bool watermark_ok;
> >  
> > -	/* Do not consider compaction for orders reclaim is meant to satisfy */
> > -	if (sc->order <= PAGE_ALLOC_COSTLY_ORDER)
> > -		return false;
> > -
> >  	/*
> >  	 * Compaction takes time to run and there are potentially other
> >  	 * callers using the pages just freed. Continue reclaiming until

> > @@ -2391,22 +2384,24 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> >  			if (sc->priority != DEF_PRIORITY &&
> >  			    !zone_reclaimable(zone))
> >  				continue;	/* Let kswapd poll it */
> > -			if (IS_ENABLED(CONFIG_COMPACTION)) {
> > -				/*
> > -				 * If we already have plenty of memory free for
> > -				 * compaction in this zone, don't free any more.
> > -				 * Even though compaction is invoked for any
> > -				 * non-zero order, only frequent costly order
> > -				 * reclamation is disruptive enough to become a
> > -				 * noticeable problem, like transparent huge
> > -				 * page allocations.
> > -				 */
> > -				if ((zonelist_zone_idx(z) <= requested_highidx)
> > -				    && compaction_ready(zone, sc)) {
> > -					aborted_reclaim = true;
> > -					continue;
> > -				}
> > +
> > +			/*
> > +			 * If we already have plenty of memory free
> > +			 * for compaction in this zone, don't free any
> > +			 * more.  Even though compaction is invoked
> > +			 * for any non-zero order, only frequent
> > +			 * costly order reclamation is disruptive
> > +			 * enough to become a noticeable problem, like
> > +			 * transparent huge page allocations.
> > +			 */
> > +			if (IS_ENABLED(CONFIG_COMPACTION) &&
> > +			    sc->order > PAGE_ALLOC_COSTLY_ORDER &&
> 
> You are deleting comment sc->order <= PAGE_ALLOC_COSTLY_ORDER which was
> in compaction_ready. At least, that comment was useful for me to guess
> the intention. So if you have strong reason to remove that, I'd like to
> remain it.

There are two separate explanations for aborting reclaim early for
costly orders:

1. /* Do not consider compaction for orders reclaim is meant to satisfy */

2. /*
    * Even though compaction is invoked
    * for any non-zero order, only frequent
    * costly order reclamation is disruptive
    * enough to become a noticeable problem, like
    * transparent huge page allocations.
    */

I thought it makes sense to pick one and go with that, so I went with
2. and moved the order check out there as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
