Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id C0E6D6B0080
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 05:05:16 -0400 (EDT)
Date: Thu, 12 Jul 2012 18:05:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/3 v3] mm: bug fix free page check in zone_watermark_ok
Message-ID: <20120712090519.GA30892@bbox>
References: <1342061449-29590-1-git-send-email-minchan@kernel.org>
 <1342061449-29590-2-git-send-email-minchan@kernel.org>
 <20120712081922.GA21018@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120712081922.GA21018@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Aaditya Kumar <aaditya.kumar@ap.sony.com>

Hi Michal,

On Thu, Jul 12, 2012 at 10:19:23AM +0200, Michal Hocko wrote:
> On Thu 12-07-12 11:50:48, Minchan Kim wrote:
> > In __zone_watermark_ok, free and min are signed long type
> > while z->lowmem_reserve[classzone_idx] is unsigned long type.
> > So comparision of them could be wrong due to type conversion
> > to unsigned although free_pages is minus value.
> 
> Agreed on that
> but
> > 
> > It could return true instead of false in case of order-0 check
> > so that kswapd could sleep forever. 
> 
> I am kind of lost here. How can we have negative free_pages with
> order-0? It would need to come with a negative value because 
> free_pages -= (1 << order) - 1;
> won't make it negative.

Right you are. I missed that part.

The reason Aaditya reported this problem is caused by my patch[1] in
this series. zone_watermark_ok_safe didn't reset free_pages to zero
although free_pages becomes minus value(Please, look at [1])

[1] memory-hotplug: fix kswapd looping forever problem

I think we have no problem in current code because if order isn't zero 
and free_pages is minus value, it could exit in the middle of loop with
false.

So I think it was totally patch's problem. :(
But I agree auto type casting problem is subtle error-prone so it's valuable
to fix, too. As you mentiond, I should rewrite description and subject for it.

Thanks for the review!

> 
> > It means livelock because direct reclaimer loops forever until kswapd
> > set zone->all_unreclaimable.
> > 
> > Aaditya reported this problem when he test my hotplug patch.
> > 
> > Reported-off-by: Aaditya Kumar <aaditya.kumar@ap.sony.com>
> > Tested-by: Aaditya Kumar <aaditya.kumar@ap.sony.com>
> > Signed-off-by: Aaditya Kumar <aaditya.kumar@ap.sony.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> So you can add my Reviewed-by: Michal Hocko <mhocko@suse.cz>
> but the changelog could be more clear.
> 
> > ---
> > This patch isn't dependent with this series.
> > It seems to be candidate for -stable but I'm not sure because of this part.
> > So, pass the decision to akpm.
> > 
> > " - It must fix a real bug that bothers people (not a, "This could be a
> >    problem..." type thing)."
> 
> I am wondering what Testted-by means if "This could be a problem..."
> type thing)."

He reported it during testing this series so I don't think it will happen
in current code because zone_page_state and zone_page_state_snapshot
can't set free_pages to minus.

> 
> > 
> >  mm/page_alloc.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index f17e6e4..627653c 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1594,6 +1594,7 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> >  {
> >  	/* free_pages my go negative - that's OK */
> >  	long min = mark;
> > +	long lowmem_reserve = z->lowmem_reserve[classzone_idx];
> >  	int o;
> >  
> >  	free_pages -= (1 << order) - 1;
> > @@ -1602,7 +1603,7 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> >  	if (alloc_flags & ALLOC_HARDER)
> >  		min -= min / 4;
> >  
> > -	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
> > +	if (free_pages <= min + lowmem_reserve)
> >  		return false;
> >  	for (o = 0; o < order; o++) {
> >  		/* At the next order, this order's pages become unavailable */
> > -- 
> > 1.7.9.5
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9    
> Czech Republic
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
