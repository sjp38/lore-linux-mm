Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 21E856B004D
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 16:17:05 -0400 (EDT)
Date: Wed, 1 Sep 2010 15:16:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
In-Reply-To: <20100901163146.9755.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009011512190.16322@router.home>
References: <20100901083425.971F.A69D9226@jp.fujitsu.com> <20100901072402.GE13677@csn.ul.ie> <20100901163146.9755.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Sep 2010, KOSAKI Motohiro wrote:

> > How about the following? It records a delta and checks if delta is negative
> > and would cause underflow.
> >
> > unsigned long zone_nr_free_pages(struct zone *zone)
> > {
> >         unsigned long nr_free_pages = zone_page_state(zone, NR_FREE_PAGES);
> >         long delta = 0;
> >
> >         /*
> >          * While kswapd is awake, it is considered the zone is under some
> >          * memory pressure. Under pressure, there is a risk that
> >          * per-cpu-counter-drift will allow the min watermark to be breached
> >          * potentially causing a live-lock. While kswapd is awake and
> >          * free pages are low, get a better estimate for free pages
> >          */
> >         if (nr_free_pages < zone->percpu_drift_mark &&
> >                         !waitqueue_active(&zone->zone_pgdat->kswapd_wait)) {
> >                 int cpu;
> >
> >                 for_each_online_cpu(cpu) {
> >                         struct per_cpu_pageset *pset;
> >
> >                         pset = per_cpu_ptr(zone->pageset, cpu);
> >                         delta += pset->vm_stat_diff[NR_FREE_PAGES];
> >                 }
> >         }
> >
> >         /* Watch for underflow */
> >         if (delta < 0 && abs(delta) > nr_free_pages)
> >                 delta = -nr_free_pages;

Not sure what the point here is. If the delta is going below zero then
there was a concurrent operation updating the counters negatively while
we summed up the counters. It is then safe to assume a value of zero. We
cannot really be more accurate than that.

so

	if (delta < 0)
		delta = 0;

would be correct. See also handling of counter underflow in
vmstat.h:zone_page_state(). As I have said before: I would rather have the
counter handling in one place to avoid creating differences in counter
handling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
