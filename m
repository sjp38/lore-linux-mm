Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F27E36B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 20:54:53 -0500 (EST)
Received: by yxe10 with SMTP id 10so18204400yxe.12
        for <linux-mm@kvack.org>; Tue, 12 Jan 2010 17:54:52 -0800 (PST)
Subject: Re: [PATCH -mmotm-2010-01-06-14-34] check high watermark after
 shrink zone
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100112150152.78604b78.akpm@linux-foundation.org>
References: <20100108141235.ef56b567.minchan.kim@barrios-desktop>
	 <20100112150152.78604b78.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 13 Jan 2010 10:51:47 +0900
Message-Id: <1263347507.23507.108.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-01-12 at 15:01 -0800, Andrew Morton wrote:
> On Fri, 8 Jan 2010 14:12:35 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > Kswapd check that zone have enough free by zone_water_mark.
> > If any zone doesn't have enough page, it set all_zones_ok to zero.
> > all_zone_ok makes kswapd retry not sleeping.
> > 
> > I think the watermark check before shrink zone is pointless.
> > Kswapd try to shrink zone then the check is meaningul.
> > 
> > This patch move the check after shrink zone.
> 
> The changelog is rather hard to understand.  I changed it to
> 
> : Kswapd checks that zone has sufficient pages free via zone_watermark_ok().
> : 
> : If any zone doesn't have enough pages, we set all_zones_ok to zero. 
> : !all_zone_ok makes kswapd retry rather than sleeping.
> : 
> : I think the watermark check before shrink_zone() is pointless.  Only after
> : kswapd has tried to shrink the zone is the check meaningful.
> : 
> : Move the check to after the call to shrink_zone().
> 

Thanks, Andrew. 

> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > CC: Mel Gorman <mel@csn.ul.ie>
> > CC: Rik van Riel <riel@redhat.com>
> > ---
> >  mm/vmscan.c |   21 +++++++++++----------
> >  1 files changed, 11 insertions(+), 10 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 885207a..b81adf8 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2057,9 +2057,6 @@ loop_again:
> >  					priority != DEF_PRIORITY)
> >  				continue;
> >  
> > -			if (!zone_watermark_ok(zone, order,
> > -					high_wmark_pages(zone), end_zone, 0))
> > -				all_zones_ok = 0;
> 
> This will make kswapd stop doing reclaim if all zones have
> zone_is_all_unreclaimable():
> 
> 			if (zone_is_all_unreclaimable(zone))
> 				continue;
> 
> This seems bad.

Do you mean zone_is_all_unreclaimable in front of if (nr_slab ==0 && ..)?

                        reclaim_state->reclaimed_slab = 0;
                        nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
                                                lru_pages);
                        sc.nr_reclaimed += reclaim_state->reclaimed_slab;
                        total_scanned += sc.nr_scanned;
                        if (zone_is_all_unreclaimable(zone)) <=== 
                                continue;


Actually I think the check is pointless, too. 
We set ZONE_ALL_UNRECLAIMABLE after the check and increase next zone in
loop. 
The check is a little bit effective in just case concurrent zone
reclaim. But if we remove the check, it's one more call
zone_watermark_ok and it's okay, I think. 

In addition, we check zone_is_all_unreclaimable in start in loop
following as. 

                for (i = 0; i <= end_zone; i++) {
                        struct zone *zone = pgdat->node_zones + i; 
                        int nr_slab;
                        int nid, zid; 

                        if (!populated_zone(zone))
                                continue;

                        if (zone_is_all_unreclaimable(zone) && <===
                                        priority != DEF_PRIORITY)
                                continue;

so the check in higher priority is effective if anyone doesn't free any
page. 


> 
> >  			temp_priority[i] = priority;
> >  			sc.nr_scanned = 0;
> >  			note_zone_scanning_priority(zone, priority);
> > @@ -2099,13 +2096,17 @@ loop_again:
> >  			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
> >  				sc.may_writepage = 1;
> >  
> > -			/*
> > -			 * We are still under min water mark. it mean we have
> > -			 * GFP_ATOMIC allocation failure risk. Hurry up!
> > -			 */
> > -			if (!zone_watermark_ok(zone, order, min_wmark_pages(zone),
> > -					      end_zone, 0))
> > -				has_under_min_watermark_zone = 1;
> > +			if (!zone_watermark_ok(zone, order,
> > +					high_wmark_pages(zone), end_zone, 0)) {
> > +				all_zones_ok = 0;
> > +				/*
> > +				 * We are still under min water mark. it mean we have
> > +				 * GFP_ATOMIC allocation failure risk. Hurry up!
> > +				 */
> > +				if (!zone_watermark_ok(zone, order, min_wmark_pages(zone),
> > +						      end_zone, 0))
> > +					has_under_min_watermark_zone = 1;
> > +			}
> >  
> 
> The vmscan.c code makes an effort to look nice in an 80-col display.

Okay. I will keep in mind. 
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
