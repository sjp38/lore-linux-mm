Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2D96B0035
	for <linux-mm@kvack.org>; Sun,  9 Oct 2011 04:02:07 -0400 (EDT)
Received: by pzk4 with SMTP id 4so14949573pzk.6
        for <linux-mm@kvack.org>; Sun, 09 Oct 2011 01:02:04 -0700 (PDT)
Date: Sun, 9 Oct 2011 17:01:56 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch v2]vmscan: correctly detect GFP_ATOMIC allocation failure
Message-ID: <20111009080156.GB23003@barrios-desktop>
References: <1317108187.29510.201.camel@sli10-conroe>
 <20110927112810.GA3897@tiehlicka.suse.cz>
 <1317170933.22361.5.camel@sli10-conroe>
 <20110928092751.GA15062@tiehlicka.suse.cz>
 <1318043674.22361.38.camel@sli10-conroe>
 <alpine.DEB.2.00.1110072014040.13992@chino.kir.corp.google.com>
 <1318044928.22361.41.camel@sli10-conroe>
 <1318053412.22361.51.camel@sli10-conroe>
 <20111008102531.GC8679@barrios-desktop>
 <1318139591.22361.56.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1318139591.22361.56.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm <linux-mm@kvack.org>

On Sun, Oct 09, 2011 at 01:53:11PM +0800, Shaohua Li wrote:
> On Sat, 2011-10-08 at 18:25 +0800, Minchan Kim wrote:
> > On Sat, Oct 08, 2011 at 01:56:52PM +0800, Shaohua Li wrote:
> > > On Sat, 2011-10-08 at 11:35 +0800, Shaohua Li wrote:
> > > > On Sat, 2011-10-08 at 11:19 +0800, David Rientjes wrote:
> > > > > On Sat, 8 Oct 2011, Shaohua Li wrote:
> > > > > 
> > > > > > has_under_min_watermark_zone is used to detect if there is GFP_ATOMIC allocation
> > > > > > failure risk. For a high end_zone, if any zone below or equal to it has min
> > > > > > matermark ok, we have no risk. But current logic is any zone has min watermark
> > > > > > not ok, then we have risk. This is wrong to me.
> > > > > > 
> > > > > > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > > > > > ---
> > > > > >  mm/vmscan.c |    7 ++++---
> > > > > >  1 file changed, 4 insertions(+), 3 deletions(-)
> > > > > > 
> > > > > > Index: linux/mm/vmscan.c
> > > > > > ===================================================================
> > > > > > --- linux.orig/mm/vmscan.c	2011-09-27 15:09:29.000000000 +0800
> > > > > > +++ linux/mm/vmscan.c	2011-09-27 15:14:45.000000000 +0800
> > > > > > @@ -2463,7 +2463,7 @@ loop_again:
> > > > > >  
> > > > > >  	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> > > > > >  		unsigned long lru_pages = 0;
> > > > > > -		int has_under_min_watermark_zone = 0;
> > > > > > +		int has_under_min_watermark_zone = 1;
> > > > > 
> > > > > bool
> > > > > 
> > > > > >  
> > > > > >  		/* The swap token gets in the way of swapout... */
> > > > > >  		if (!priority)
> > > > > > @@ -2594,9 +2594,10 @@ loop_again:
> > > > > >  				 * means that we have a GFP_ATOMIC allocation
> > > > > >  				 * failure risk. Hurry up!
> > > > > >  				 */
> > > > > > -				if (!zone_watermark_ok_safe(zone, order,
> > > > > > +				if (has_under_min_watermark_zone &&
> > > > > > +					    zone_watermark_ok_safe(zone, order,
> > > > > >  					    min_wmark_pages(zone), end_zone, 0))
> > > > > > -					has_under_min_watermark_zone = 1;
> > > > > > +					has_under_min_watermark_zone = 0;
> > > > > >  			} else {
> > > > > >  				/*
> > > > > >  				 * If a zone reaches its high watermark,
> > > > > 
> > > > > Ignore checking the min watermark for a moment and consider if all zones 
> > > > > are above the high watermark (a situation where kswapd does not need to 
> > > > > do aggressive reclaim), then has_under_min_watermark_zone doesn't get 
> > > > > cleared and never actually stalls on congestion_wait().  Notice this is 
> > > > > congestion_wait() and not wait_iff_congested(), so the clearing of 
> > > > > ZONE_CONGESTED doesn't prevent this.
> > > > if all zones are above the high watermark, we will have i < 0 when
> > > > detecting the highest imbalanced zone, and the whole loop will end
> > > > without run into congestion_wait().
> > > > or I can add a clearing has_under_min_watermark_zone in the else block
> > > > to be safe.
> > > Subject: vmscan: correctly detect GFP_ATOMIC allocation failure -v2
> > > 
> > > has_under_min_watermark_zone is used to detect if there is GFP_ATOMIC allocation
> > > failure risk. For a high end_zone, if any zone below or equal to it has min
> > > matermark ok, we have no risk. But current logic is any zone has min watermark
> > > not ok, then we have risk. This is wrong to me.
> > 
> > I think it's not a right or wrong problem but a policy stuff.
> > If we are going to start busy reclaiming for atomic allocation
> > after we see all lower zones' min water mark pages are already consumed
> > It could make you go through long latency and is likely to fail atomic allocation
> > stream(Because, there is nothing to do for aotmic allocation fail in direct reclaim
> > so kswapd should always do best effort for it)
> > 
> > I don't mean you are wrong but we are very careful about this
> > and at least need some experiments with atomic allocaion stream, I think.
> yes. this is a policy problem. I just don't want the kswapd keep running
> even there is no immediate risk of atomic allocation fail.
> One problem here is end_zone could be high, and low zone always doesn't
> meet min watermark. So kswapd keeps running without a wait and builds
> big priority.

It could be but I think it's a mistake of admin if he handles such rare system.
Couldn't he lower the reserved pages for highmem?

> 
> Thanks,
> Shaohua
> 

-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
