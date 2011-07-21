Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DF2476B0082
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 11:30:19 -0400 (EDT)
Received: by iyb14 with SMTP id 14so1335444iyb.14
        for <linux-mm@kvack.org>; Thu, 21 Jul 2011 08:30:16 -0700 (PDT)
Date: Fri, 22 Jul 2011 00:30:07 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 4/4] mm: vmscan: Only read new_classzone_idx from pgdat
 when reclaiming successfully
Message-ID: <20110721153007.GC1713@barrios-desktop>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
 <1308926697-22475-5-git-send-email-mgorman@suse.de>
 <20110719160903.GA2978@barrios-desktop>
 <20110720104847.GI5349@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110720104847.GI5349@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, P?draig Brady <P@draigBrady.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Jul 20, 2011 at 11:48:47AM +0100, Mel Gorman wrote:
> On Wed, Jul 20, 2011 at 01:09:03AM +0900, Minchan Kim wrote:
> > Hi Mel,
> > 
> > Too late review.
> 
> Never too late.
> 
> > At that time, I had no time to look into this patch.
> > 
> > On Fri, Jun 24, 2011 at 03:44:57PM +0100, Mel Gorman wrote:
> > > During allocator-intensive workloads, kswapd will be woken frequently
> > > causing free memory to oscillate between the high and min watermark.
> > > This is expected behaviour.  Unfortunately, if the highest zone is
> > > small, a problem occurs.
> > > 
> > > When balance_pgdat() returns, it may be at a lower classzone_idx than
> > > it started because the highest zone was unreclaimable. Before checking
> > 
> > Yes.
> > 
> > > if it should go to sleep though, it checks pgdat->classzone_idx which
> > > when there is no other activity will be MAX_NR_ZONES-1. It interprets
> > 
> > Yes.
> > 
> > > this as it has been woken up while reclaiming, skips scheduling and
> > 
> > Hmm. I can't understand this part.
> > If balance_pgdat returns lower classzone and there is no other activity,
> > new_classzone_idx is always MAX_NR_ZONES - 1 so that classzone_idx would be less than
> > new_classzone_idx. It means it doesn't skip scheduling.
> > 
> > Do I miss something?
> > 
> 
> It was a few weeks ago so I don't rememember if this is the exact
> sequence I had in mind at the time of writing but an example sequence
> of events is for a node whose highest populated zone is ZONE_NORMAL,
> very small, and gets set all_unreclaimable by balance_pgdat() looks
> is below. The key is the "very small" part because pages are getting
> freed in the zone but the small size means that unreclaimable gets
> set easily.
> 
> /*
>  * kswapd is woken up for ZONE_NORMAL (as this is the preferred zone
>  * as ZONE_HIGHMEM is not populated.
>  */
> 
> order = pgdat->kswapd_max_order;
> classzone_idx = pgdat->classzone_idx;				/* classzone_idx == ZONE_NORMAL */
> pgdat->kswapd_max_order = 0;
> pgdat->classzone_idx = MAX_NR_ZONES - 1;
> order = balance_pgdat(pgdat, order, &classzone_idx);		/* classzone_idx == ZONE_NORMAL even though
> 								 * the highest zone was set unreclaimable
> 								 * and it exited scanning ZONE_DMA32
> 								 * because we did not communicate that
> 								 * information back

								Yes. It's too bad.

> 								 */
> new_order = pgdat->kswapd_max_order;				/* new_order = 0 */
> new_classzone_idx = pgdat->classzone_idx;			/* new_classzone_idx == ZONE_HIGHMEM
> 								 * because that is what classzone_idx
> 								 * gets reset to

								Yes. new_classzone_idx is ZONE_HIGHMEM.

> 								 */
> if (order < new_order || classzone_idx > new_classzone_idx) {
> 	/* does not sleep, this branch not taken */
> } else {
> 	/* tries to sleep, goes here */
> 	try_to_sleep(ZONE_NORMAL)
> 		sleeping_prematurely(ZONE_NORMAL)		/* finds zone unbalanced so skips scheduling */
>         order = pgdat->kswapd_max_order;
>         classzone_idx = pgdat->classzone_idx;			/* classzone_idx == ZONE_HIGHMEM now which
> 								 * is higher than what it was originally
> 								 * woken for
> 								 */

								But is it a problem?
								it should be reset to ZONE_NORMAL in balance_pgdat as high zone isn't populated.
> }
> 
> /* Looped around to balance_pgdat() again */
> order = balance_pgdat()
> 
> Between when all_unreclaimable is set and before before kswapd
> goes fully to sleep, a page is freed clearing all_reclaimable so
> it rechecks all the zones, find the highest one is not balanced and
> skip scheduling.

Yes and it could be repeated forever.
Apparently, we should fix wit this patch but I have a qustion about this patch.

Quote from your patch

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a76b6cc2..fe854d7 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2448,7 +2448,6 @@ loop_again:
>                       if (!zone_watermark_ok_safe(zone, order,
>                                       high_wmark_pages(zone), 0, 0)) {
>                               end_zone = i;
> -                             *classzone_idx = i;
>                               break;
>                       }
>               }
> @@ -2528,8 +2527,11 @@ loop_again:
>                           total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
>                               sc.may_writepage = 1;
>  
> -                     if (zone->all_unreclaimable)
> +                     if (zone->all_unreclaimable) {
> +                             if (end_zone && end_zone == i)
> +                                     end_zone--;

Until now, It's good.

>                               continue;
> +                     }
>  
>                       if (!zone_watermark_ok_safe(zone, order,
>                                       high_wmark_pages(zone), end_zone, 0)) {
> @@ -2709,8 +2711,8 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
>   */
>  static int kswapd(void *p)
>  {
> -     unsigned long order;
> -     int classzone_idx;
> +     unsigned long order, new_order;
> +     int classzone_idx, new_classzone_idx;
>       pg_data_t *pgdat = (pg_data_t*)p;
>       struct task_struct *tsk = current;
>  
> @@ -2740,17 +2742,23 @@ static int kswapd(void *p)
>       tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
>       set_freezable();
>  
> -     order = 0;
> -     classzone_idx = MAX_NR_ZONES - 1;
> +     order = new_order = 0;
> +     classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
>       for ( ; ; ) {
> -             unsigned long new_order;
> -             int new_classzone_idx;
>               int ret;
>  
> -             new_order = pgdat->kswapd_max_order;
> -             new_classzone_idx = pgdat->classzone_idx;
> -             pgdat->kswapd_max_order = 0;
> -             pgdat->classzone_idx = MAX_NR_ZONES - 1;
> +             /*
> +              * If the last balance_pgdat was unsuccessful it's unlikely a
> +              * new request of a similar or harder type will succeed soon
> +              * so consider going to sleep on the basis we reclaimed at
> +              */
> +             if (classzone_idx >= new_classzone_idx && order == new_order) {
> +                     new_order = pgdat->kswapd_max_order;
> +                     new_classzone_idx = pgdat->classzone_idx;
> +                     pgdat->kswapd_max_order =  0;
> +                     pgdat->classzone_idx = pgdat->nr_zones - 1;
> +             }
> +

But in this part.
Why do we need this?
Although we pass high zone instead of zone we reclaimed at, it would be reset to
ZONE_NORMAL if it's not populated. If high zone is populated and it couldn't meet
watermark, it could be balanced and next normal zone would be balanced, too.

Could you explain what's problem happen without this part?

>               if (order < new_order || classzone_idx > new_classzone_idx) {
>                       /*
>                        * Don't sleep if someone wants a larger 'order'
> @@ -2763,7 +2771,7 @@ static int kswapd(void *p)
>                       order = pgdat->kswapd_max_order;
>                       classzone_idx = pgdat->classzone_idx;
>                       pgdat->kswapd_max_order = 0;
> -                     pgdat->classzone_idx = MAX_NR_ZONES - 1;
> +                     pgdat->classzone_idx = pgdat->nr_zones - 1;
>               }
>  
>               ret = try_to_freeze();
> -- 
> 1.7.3.4
> 



> 
> A variation is that it the lower zones are above the low watermark so
> the page allocator is not waking kswapd and it should sleep on the
> waitqueue. However, it only schedules for HZ/10 during which a page
> is freed, the highest zone gets all_unreclaimable cleared and so it
> stays awake. In this case, it has reached a scheduling point but it
> is not going fully to sleep on the waitqueue as it should.
> 
> I see now the problem with the changelog, it sucks and could have
> been a lot better at explaining why kswapd stays awake when the
> information is not communicated back and why classzone_idx being set
> to MAX_NR_ZONES-1 is sloppy :(
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
