Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 8763F6B0005
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 11:11:59 -0400 (EDT)
Date: Sun, 17 Mar 2013 15:11:55 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 06/10] mm: vmscan: Have kswapd writeback pages based on
 dirty pages encountered, not priority
Message-ID: <20130317151155.GC2026@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-7-git-send-email-mgorman@suse.de>
 <m2620qjdeo.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <m2620qjdeo.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Sun, Mar 17, 2013 at 07:42:39AM -0700, Andi Kleen wrote:
> Mel Gorman <mgorman@suse.de> writes:
> 
> > @@ -495,6 +495,9 @@ typedef enum {
> >  	ZONE_CONGESTED,			/* zone has many dirty pages backed by
> >  					 * a congested BDI
> >  					 */
> > +	ZONE_DIRTY,			/* reclaim scanning has recently found
> > +					 * many dirty file pages
> > +					 */
> 
> Needs a better name. ZONE_DIRTY_CONGESTED ? 
> 

That might be confusing. The underlying BDI is not necessarily
congested. I accept your point though and will try thinking of a better
name.

> > +	 * currently being written then flag that kswapd should start
> > +	 * writing back pages.
> > +	 */
> > +	if (global_reclaim(sc) && nr_dirty &&
> > +			nr_dirty >= (nr_taken >> (DEF_PRIORITY - sc->priority)))
> > +		zone_set_flag(zone, ZONE_DIRTY);
> > +
> >  	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
> 
> I suppose you want to trace the dirty case here too.
> 

I guess it wouldn't hurt to have a new tracepoint for when the flag gets
set. A vmstat might be helpful as well.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
