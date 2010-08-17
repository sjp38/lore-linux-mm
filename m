Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EC3616B01F2
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 07:07:27 -0400 (EDT)
Date: Tue, 17 Aug 2010 13:05:21 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100817110521.GC3151@cmpxchg.org>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie> <1281951733-29466-3-git-send-email-mel@csn.ul.ie> <20100816094350.GH19797@csn.ul.ie> <20100816160623.GB15103@cmpxchg.org> <20100817101655.GN19797@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100817101655.GN19797@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 17, 2010 at 11:16:55AM +0100, Mel Gorman wrote:
> On Mon, Aug 16, 2010 at 06:06:23PM +0200, Johannes Weiner wrote:
> > On Mon, Aug 16, 2010 at 10:43:50AM +0100, Mel Gorman wrote:
> > > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > > index 7759941..c95a159 100644
> > > --- a/mm/vmstat.c
> > > +++ b/mm/vmstat.c
> > > @@ -143,6 +143,9 @@ static void refresh_zone_stat_thresholds(void)
> > >  		for_each_online_cpu(cpu)
> > >  			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> > >  							= threshold;
> > > +
> > > +		zone->percpu_drift_mark = high_wmark_pages(zone) +
> > > +					num_online_cpus() * threshold;
> > >  	}
> > >  }
> > 
> > Hm, this one I don't quite get (might be the jetlag, though): we have
> > _at least_ NR_FREE_PAGES free pages, there may just be more lurking in
> > the pcp counters.
> > 
> 
> Well, the drift can be either direction because drift can be due to pages
> being either freed or allocated. e.g. it could be something like
> 
> NR_FREE_PAGES		CPU 0			CPU 1		Actual Free
> 128			-32			 +64		   160
> 
> Because CPU 0 was allocating pages while CPU 1 was freeing them but that
> is not what is important here. At any given time, the NR_FREE_PAGES can be
> wrong by as much as
> 
> num_online_cpus * (threshold - 1)

I somehow assumed the pcp cache could only be positive, but the
vm_stat_diff can indeed hold negative values.

> > So shouldn't we only collect the pcp deltas in case the high watermark
> > is breached?  Above this point, we should be fine or better, no?
> > 
> 
> Is that not what is happening in zone_nr_free_pages with this check?
> 
>         /*
>          * While kswapd is awake, it is considered the zone is under some
>          * memory pressure. Under pressure, there is a risk that
>          * per-cpu-counter-drift will allow the min watermark to be breached
>          * potentially causing a live-lock. While kswapd is awake and
>          * free pages are low, get a better estimate for free pages
>          */
>         if (nr_free_pages < zone->percpu_drift_mark &&
>                         !waitqueue_active(&zone->zone_pgdat->kswapd_wait)) {
> 
> Maybe I'm misunderstanding your question.

This was just a conclusion based on my wrong assumption: if the pcp
diff could only be positive, it would be enough to go for accurate
counts at the point NR_FREE_PAGES breaches the watermark.

As it is, however, the error margin needs to be taken into account in
both directions, as you said, so your patch makes perfect sense.

Sorry for the noise! And

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
