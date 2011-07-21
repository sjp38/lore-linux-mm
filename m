Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 46D8F6B00F9
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 12:37:03 -0400 (EDT)
Received: by gyg13 with SMTP id 13so885607gyg.14
        for <linux-mm@kvack.org>; Thu, 21 Jul 2011 09:36:58 -0700 (PDT)
Date: Fri, 22 Jul 2011 01:36:49 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 4/4] mm: vmscan: Only read new_classzone_idx from pgdat
 when reclaiming successfully
Message-ID: <20110721163649.GG1713@barrios-desktop>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
 <1308926697-22475-5-git-send-email-mgorman@suse.de>
 <20110719160903.GA2978@barrios-desktop>
 <20110720104847.GI5349@suse.de>
 <20110721153007.GC1713@barrios-desktop>
 <20110721160706.GS5349@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110721160706.GS5349@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, P?draig Brady <P@draigBrady.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jul 21, 2011 at 05:07:06PM +0100, Mel Gorman wrote:
> On Fri, Jul 22, 2011 at 12:30:07AM +0900, Minchan Kim wrote:
> > On Wed, Jul 20, 2011 at 11:48:47AM +0100, Mel Gorman wrote:
> > > On Wed, Jul 20, 2011 at 01:09:03AM +0900, Minchan Kim wrote:
> > > > Hi Mel,
> > > > 
> > > > Too late review.
> > > 
> > > Never too late.
> > > 
> > > > At that time, I had no time to look into this patch.
> > > > 
> > > > On Fri, Jun 24, 2011 at 03:44:57PM +0100, Mel Gorman wrote:
> > > > > During allocator-intensive workloads, kswapd will be woken frequently
> > > > > causing free memory to oscillate between the high and min watermark.
> > > > > This is expected behaviour.  Unfortunately, if the highest zone is
> > > > > small, a problem occurs.
> > > > > 
> > > > > When balance_pgdat() returns, it may be at a lower classzone_idx than
> > > > > it started because the highest zone was unreclaimable. Before checking
> > > > 
> > > > Yes.
> > > > 
> > > > > if it should go to sleep though, it checks pgdat->classzone_idx which
> > > > > when there is no other activity will be MAX_NR_ZONES-1. It interprets
> > > > 
> > > > Yes.
> > > > 
> > > > > this as it has been woken up while reclaiming, skips scheduling and
> > > > 
> > > > Hmm. I can't understand this part.
> > > > If balance_pgdat returns lower classzone and there is no other activity,
> > > > new_classzone_idx is always MAX_NR_ZONES - 1 so that classzone_idx would be less than
> > > > new_classzone_idx. It means it doesn't skip scheduling.
> > > > 
> > > > Do I miss something?
> > > > 
> > > 
> > > It was a few weeks ago so I don't rememember if this is the exact
> > > sequence I had in mind at the time of writing but an example sequence
> > > of events is for a node whose highest populated zone is ZONE_NORMAL,
> > > very small, and gets set all_unreclaimable by balance_pgdat() looks
> > > is below. The key is the "very small" part because pages are getting
> > > freed in the zone but the small size means that unreclaimable gets
> > > set easily.
> > > 
> > > /*
> > >  * kswapd is woken up for ZONE_NORMAL (as this is the preferred zone
> > >  * as ZONE_HIGHMEM is not populated.
> > >  */
> > > 
> > > order = pgdat->kswapd_max_order;
> > > classzone_idx = pgdat->classzone_idx;				/* classzone_idx == ZONE_NORMAL */
> > > pgdat->kswapd_max_order = 0;
> > > pgdat->classzone_idx = MAX_NR_ZONES - 1;
> > > order = balance_pgdat(pgdat, order, &classzone_idx);		/* classzone_idx == ZONE_NORMAL even though
> > > 								 * the highest zone was set unreclaimable
> > > 								 * and it exited scanning ZONE_DMA32
> > > 								 * because we did not communicate that
> > > 								 * information back
> > 
> > 								Yes. It's too bad.
> > 
> > > 								 */
> > > new_order = pgdat->kswapd_max_order;				/* new_order = 0 */
> > > new_classzone_idx = pgdat->classzone_idx;			/* new_classzone_idx == ZONE_HIGHMEM
> > > 								 * because that is what classzone_idx
> > > 								 * gets reset to
> > 
> > 								Yes. new_classzone_idx is ZONE_HIGHMEM.
> > 
> > > 								 */
> > > if (order < new_order || classzone_idx > new_classzone_idx) {
> > > 	/* does not sleep, this branch not taken */
> > > } else {
> > > 	/* tries to sleep, goes here */
> > > 	try_to_sleep(ZONE_NORMAL)
> > > 		sleeping_prematurely(ZONE_NORMAL)		/* finds zone unbalanced so skips scheduling */
> > >         order = pgdat->kswapd_max_order;
> > >         classzone_idx = pgdat->classzone_idx;			/* classzone_idx == ZONE_HIGHMEM now which
> > > 								 * is higher than what it was originally
> > > 								 * woken for
> > > 								 */
> > 
> > 								But is it a problem?
> > 								it should be reset to ZONE_NORMAL in balance_pgdat as high zone isn't populated.
> 
> At the very least, it's sloppy.

Agree.

> 
> > > }
> > > 
> > > /* Looped around to balance_pgdat() again */
> > > order = balance_pgdat()
> > > 
> > > Between when all_unreclaimable is set and before before kswapd
> > > goes fully to sleep, a page is freed clearing all_reclaimable so
> > > it rechecks all the zones, find the highest one is not balanced and
> > > skip scheduling.
> > 
> > Yes and it could be repeated forever.
> 
> Resulting in chewing up large amounts of CPU.
> 
> > Apparently, we should fix wit this patch but I have a qustion about this patch.
> > 
> > Quote from your patch
> > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index a76b6cc2..fe854d7 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2448,7 +2448,6 @@ loop_again:
> > >                       if (!zone_watermark_ok_safe(zone, order,
> > >                                       high_wmark_pages(zone), 0, 0)) {
> > >                               end_zone = i;
> > > -                             *classzone_idx = i;
> > >                               break;
> > >                       }
> > >               }
> > > @@ -2528,8 +2527,11 @@ loop_again:
> > >                           total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
> > >                               sc.may_writepage = 1;
> > >  
> > > -                     if (zone->all_unreclaimable)
> > > +                     if (zone->all_unreclaimable) {
> > > +                             if (end_zone && end_zone == i)
> > > +                                     end_zone--;
> > 
> > Until now, It's good.
> > 
> > >                               continue;
> > > +                     }
> > >  
> > >                       if (!zone_watermark_ok_safe(zone, order,
> > >                                       high_wmark_pages(zone), end_zone, 0)) {
> > > @@ -2709,8 +2711,8 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
> > >   */
> > >  static int kswapd(void *p)
> > >  {
> > > -     unsigned long order;
> > > -     int classzone_idx;
> > > +     unsigned long order, new_order;
> > > +     int classzone_idx, new_classzone_idx;
> > >       pg_data_t *pgdat = (pg_data_t*)p;
> > >       struct task_struct *tsk = current;
> > >  
> > > @@ -2740,17 +2742,23 @@ static int kswapd(void *p)
> > >       tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
> > >       set_freezable();
> > >  
> > > -     order = 0;
> > > -     classzone_idx = MAX_NR_ZONES - 1;
> > > +     order = new_order = 0;
> > > +     classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
> > >       for ( ; ; ) {
> > > -             unsigned long new_order;
> > > -             int new_classzone_idx;
> > >               int ret;
> > >  
> > > -             new_order = pgdat->kswapd_max_order;
> > > -             new_classzone_idx = pgdat->classzone_idx;
> > > -             pgdat->kswapd_max_order = 0;
> > > -             pgdat->classzone_idx = MAX_NR_ZONES - 1;
> > > +             /*
> > > +              * If the last balance_pgdat was unsuccessful it's unlikely a
> > > +              * new request of a similar or harder type will succeed soon
> > > +              * so consider going to sleep on the basis we reclaimed at
> > > +              */
> > > +             if (classzone_idx >= new_classzone_idx && order == new_order) {
> > > +                     new_order = pgdat->kswapd_max_order;
> > > +                     new_classzone_idx = pgdat->classzone_idx;
> > > +                     pgdat->kswapd_max_order =  0;
> > > +                     pgdat->classzone_idx = pgdat->nr_zones - 1;
> > > +             }
> > > +
> > 
> > But in this part.
> > Why do we need this?
> 
> Lets say it's a fork-heavy workload and it is routinely being woken
> for order-1 allocations and the highest zone is very small. For the
> most part, it's ok because the allocations are being satisfied from
> the lower zones which kswapd has no problem balancing.
> 
> However, by reading the information even after failing to
> balance, kswapd continues balancing for order-1 due to reading
> pgdat->kswapd_max_order, each time failing for the highest zone. It
> only takes one wakeup request per balance_pgdat() to keep kswapd
> awake trying to balance the highest zone in a continual loop.

You made balace_pgdat's classzone_idx as communicated back so classzone_idx returned
would be not high zone and in [1/4], you changed that sleeping_prematurely consider only
classzone_idx not nr_zones. So I think it should sleep if low zones is balanced.

> 
> By avoiding this read, kswapd will try and go to sleep after checking
> all the watermarks and all_unreclaimable. If the watermarks are ok, it
> will sleep until woken up due to the lower zones hitting their min
> watermarks.
> 
> -- 
> Mel Gorman
> SUSE Labs

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
