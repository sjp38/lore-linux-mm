Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 22FB36B003A
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 07:24:55 -0400 (EDT)
Date: Tue, 9 Apr 2013 12:13:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/10] mm: vmscan: Have kswapd shrink slab only once per
 priority
Message-ID: <20130409111358.GB2002@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-9-git-send-email-mgorman@suse.de>
 <20130409065325.GA4411@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130409065325.GA4411@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 09, 2013 at 03:53:25PM +0900, Joonsoo Kim wrote:
> Hello, Mel.
> Sorry for too late question.
> 

No need to apologise at all.

> On Sun, Mar 17, 2013 at 01:04:14PM +0000, Mel Gorman wrote:
> > If kswaps fails to make progress but continues to shrink slab then it'll
> > either discard all of slab or consume CPU uselessly scanning shrinkers.
> > This patch causes kswapd to only call the shrinkers once per priority.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  mm/vmscan.c | 28 +++++++++++++++++++++-------
> >  1 file changed, 21 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 7d5a932..84375b2 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2661,9 +2661,10 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
> >   */
> >  static bool kswapd_shrink_zone(struct zone *zone,
> >  			       struct scan_control *sc,
> > -			       unsigned long lru_pages)
> > +			       unsigned long lru_pages,
> > +			       bool shrinking_slab)
> >  {
> > -	unsigned long nr_slab;
> > +	unsigned long nr_slab = 0;
> >  	struct reclaim_state *reclaim_state = current->reclaim_state;
> >  	struct shrink_control shrink = {
> >  		.gfp_mask = sc->gfp_mask,
> > @@ -2673,9 +2674,15 @@ static bool kswapd_shrink_zone(struct zone *zone,
> >  	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
> >  	shrink_zone(zone, sc);
> >  
> > -	reclaim_state->reclaimed_slab = 0;
> > -	nr_slab = shrink_slab(&shrink, sc->nr_scanned, lru_pages);
> > -	sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> > +	/*
> > +	 * Slabs are shrunk for each zone once per priority or if the zone
> > +	 * being balanced is otherwise unreclaimable
> > +	 */
> > +	if (shrinking_slab || !zone_reclaimable(zone)) {
> > +		reclaim_state->reclaimed_slab = 0;
> > +		nr_slab = shrink_slab(&shrink, sc->nr_scanned, lru_pages);
> > +		sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> > +	}
> >  
> >  	if (nr_slab == 0 && !zone_reclaimable(zone))
> >  		zone->all_unreclaimable = 1;
> 
> Why shrink_slab() is called here?

Preserves existing behaviour.

> I think that outside of zone loop is better place to run shrink_slab(),
> because shrink_slab() is not directly related to a specific zone.
> 

This is true and has been the case for a long time. The slab shrinkers
are not zone aware and it is complicated by the fact that slab usage can
indirectly pin memory on other zones. Consider for example a slab object
that is an inode entry that is allocated from the Normal zone on a
32-bit machine. Reclaiming may free memory from the Highmem zone.

It's less obvious a problem on 64-bit machines but freeing slab objects
from a zone like DMA32 can indirectly free memory from the Normal zone or
even another node entirely.

> And this is a question not related to this patch.
> Why nr_slab is used here to decide zone->all_unreclaimable?

Slab is not directly associated with a slab but as reclaiming slab can
free memory from unpredictable zones we do not consider a zone to be
fully unreclaimable until we cannot shrink slab any more.

You may be thinking that this is extremely heavy handed and you're
right, it is.

> nr_slab is not directly related whether a specific zone is reclaimable
> or not, and, moreover, nr_slab is not directly related to number of
> reclaimed pages. It just say some objects in the system are freed.
> 

All true, it's the indirect relation between slab objects and the memory
that is freed when slab objects are reclaimed that has to be taken into
account.

> This question comes from my ignorance, so please enlighten me.
> 

I hope this clarifies matters.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
