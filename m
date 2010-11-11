Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A68B06B004A
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 05:30:16 -0500 (EST)
Date: Thu, 11 Nov 2010 10:29:57 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch]vmscan: avoid set zone congested if no page dirty
Message-ID: <20101111102956.GE19679@csn.ul.ie>
References: <1288831858.23014.129.camel@sli10-conroe> <20101110151637.69393904.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101110151637.69393904.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2010 at 03:16:37PM -0800, Andrew Morton wrote:
> On Thu, 04 Nov 2010 08:50:58 +0800
> Shaohua Li <shaohua.li@intel.com> wrote:
> 
> > nr_dirty and nr_congested are increased only when page is dirty. So if all pages
> > are clean, both them will be zero. In this case, we should not mark the zone
> > congested.
> > 
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index b8a6fdc..d31d7ce 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -913,7 +913,7 @@ keep_lumpy:
> >  	 * back off and wait for congestion to clear because further reclaim
> >  	 * will encounter the same problem
> >  	 */
> > -	if (nr_dirty == nr_congested)
> > +	if (nr_dirty == nr_congested && nr_dirty != 0)
> >  		zone_set_flag(zone, ZONE_CONGESTED);
> >  
> >  	free_page_list(&free_pages);
> 
> In a way, this was a really big bug.  Reclaim will set the zone as
> congested a *lot* - when reclaiming simple, clean pagecache. 

This is true and you're right, it was a bad mistake on my part. My test
machines are tied up at the moment but I intend to run this patch through
the same tests as were used to introduce wait_iff_congested to ensure nothing
bad has happened.

> It does
> appear that kswapd will unset it a lot too, so the net effect isn't
> obvious.
>

The unset log is more straight-forward. The flag is cleared when the watermark
is met. Granted, there might be still congestion in there but not congestion
that a called of alloc_pages() should use congestion_wait() for.

> However most of the time, the atomic_read(&nr_bdi_congested[sync]) in
> wait_iff_congested() will prevent this bug from causing harm.
> 

Bit of a happy coincidence though. You'd think that if the congestion
settting/clearing logic was perfect that nr_bdi_congested[] might become
unnecessary.

> btw, it's irritating that we have this asymmetry:
> 
> setter: zone_set_flag(zone, ZONE_CONGESTED)
> getter: zone_is_reclaim_congested(zone)
> 

I struggled with this. Early versions used a simple getter but I
eventually decided to match functions like zone_is_reclaim_locked() and
zone_is_oom_locked().

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
