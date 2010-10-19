Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AC7ED5F0047
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 05:08:19 -0400 (EDT)
Date: Tue, 19 Oct 2010 10:08:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: zone state overhead
Message-ID: <20101019090803.GF30667@csn.ul.ie>
References: <20101014120804.8B8F.A69D9226@jp.fujitsu.com> <20101018103941.GX30667@csn.ul.ie> <20101019100658.A1B3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101019100658.A1B3.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 10:16:42AM +0900, KOSAKI Motohiro wrote:
> > > In this case, wakeup_kswapd() don't wake kswapd because
> > > 
> > > ---------------------------------------------------------------------------------
> > > void wakeup_kswapd(struct zone *zone, int order)
> > > {
> > >         pg_data_t *pgdat;
> > > 
> > >         if (!populated_zone(zone))
> > >                 return;
> > > 
> > >         pgdat = zone->zone_pgdat;
> > >         if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
> > >                 return;                          // HERE
> > > ---------------------------------------------------------------------------------
> > > 
> > > So, if we take your approach, we need to know exact free pages in this.
> > 
> > Good point!
> > 
> > > But, zone_page_state_snapshot() is slow. that's dilemma.
> > > 
> > 
> > Very true. I'm prototyping a version of the patch that keeps
> > zone_page_state_snapshot but only uses is in wakeup_kswapd and
> > sleeping_prematurely.
> 
> Ok, this might works. but note, if we are running IO intensive workload, wakeup_kswapd()
> is called very frequently.

This is true. It is also necessary to alter wakeup_kswapd to minimise
the number of times it calls zone_watermark_ok_safe(). It'll need
careful review to be sure the new function is equivalent.

> because it is called even though allocation is succeed. we need to
> request Shaohua run and mesure his problem workload. and can you please cc me
> when you post next version? I hope to review it too.
> 

Of course. I have the prototype ready but am waiting on tests at the
moment. Unfortunately the necessary infrastructure has been unavailable for
the last 18 hours to run the test but I'm hoping it gets fixed soon.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
