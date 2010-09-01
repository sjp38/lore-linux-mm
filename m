Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 10C476B0047
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 03:24:18 -0400 (EDT)
Date: Wed, 1 Sep 2010 08:24:02 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
	NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100901072402.GE13677@csn.ul.ie>
References: <1283276257-1793-1-git-send-email-mel@csn.ul.ie> <1283276257-1793-3-git-send-email-mel@csn.ul.ie> <20100901083425.971F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100901083425.971F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 01, 2010 at 08:37:41AM +0900, KOSAKI Motohiro wrote:
> > +#ifdef CONFIG_SMP
> > +/* Called when a more accurate view of NR_FREE_PAGES is needed */
> > +unsigned long zone_nr_free_pages(struct zone *zone)
> > +{
> > +	unsigned long nr_free_pages = zone_page_state(zone, NR_FREE_PAGES);
> > +
> > +	/*
> > +	 * While kswapd is awake, it is considered the zone is under some
> > +	 * memory pressure. Under pressure, there is a risk that
> > +	 * per-cpu-counter-drift will allow the min watermark to be breached
> > +	 * potentially causing a live-lock. While kswapd is awake and
> > +	 * free pages are low, get a better estimate for free pages
> > +	 */
> > +	if (nr_free_pages < zone->percpu_drift_mark &&
> > +			!waitqueue_active(&zone->zone_pgdat->kswapd_wait)) {
> > +		int cpu;
> > +
> > +		for_each_online_cpu(cpu) {
> > +			struct per_cpu_pageset *pset;
> > +
> > +			pset = per_cpu_ptr(zone->pageset, cpu);
> > +			nr_free_pages += pset->vm_stat_diff[NR_FREE_PAGES];
> 
> If my understanding is correct, we have no lock when reading pset->vm_stat_diff.
> It mean nr_free_pages can reach negative value at very rarely race. boundary
> check is necessary?
> 

True, well spotted.

How about the following? It records a delta and checks if delta is negative
and would cause underflow.

unsigned long zone_nr_free_pages(struct zone *zone)
{
        unsigned long nr_free_pages = zone_page_state(zone, NR_FREE_PAGES);
        long delta = 0;

        /*
         * While kswapd is awake, it is considered the zone is under some
         * memory pressure. Under pressure, there is a risk that
         * per-cpu-counter-drift will allow the min watermark to be breached
         * potentially causing a live-lock. While kswapd is awake and
         * free pages are low, get a better estimate for free pages
         */
        if (nr_free_pages < zone->percpu_drift_mark &&
                        !waitqueue_active(&zone->zone_pgdat->kswapd_wait)) {
                int cpu;

                for_each_online_cpu(cpu) {
                        struct per_cpu_pageset *pset;

                        pset = per_cpu_ptr(zone->pageset, cpu);
                        delta += pset->vm_stat_diff[NR_FREE_PAGES];
                }
        }

        /* Watch for underflow */
        if (delta < 0 && abs(delta) > nr_free_pages)
                delta = -nr_free_pages;

        return nr_free_pages + delta;
}

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
