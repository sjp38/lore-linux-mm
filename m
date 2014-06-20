Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8966F6B0037
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 16:24:58 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id x13so4143346wgg.33
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 13:24:58 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id cb3si9100282wjc.67.2014.06.20.13.24.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 13:24:57 -0700 (PDT)
Date: Fri, 20 Jun 2014 16:24:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/4] mm: vmscan: rework compaction-ready signaling in
 direct reclaim
Message-ID: <20140620202449.GA30849@cmpxchg.org>
References: <1403282030-29915-1-git-send-email-hannes@cmpxchg.org>
 <1403282030-29915-2-git-send-email-hannes@cmpxchg.org>
 <53A467A3.1050008@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53A467A3.1050008@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 20, 2014 at 06:56:03PM +0200, Vlastimil Babka wrote:
> On 06/20/2014 06:33 PM, Johannes Weiner wrote:
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
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks, Vlastimil!

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
> 
> You moved this comment block left, yet you further shortened the individual lines, despite
> there is now more space to prolong them.

This is a result of using emacs' auto-fill all the time when writing
comments, I have to watch my reflexes while moving stuff around :-)

Updated patch:

---
