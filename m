Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 307FA6B01F2
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 11:05:28 -0400 (EDT)
Date: Tue, 17 Aug 2010 16:05:10 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
	NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100817150509.GR19797@csn.ul.ie>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie> <1281951733-29466-3-git-send-email-mel@csn.ul.ie> <20100816094350.GH19797@csn.ul.ie> <20100816160623.GB15103@cmpxchg.org> <AANLkTikWzkUkkghJcPBcuPsquyw-CodbH5z1DLbOiWP9@mail.gmail.com> <20100817104246.GO19797@csn.ul.ie> <20100817150144.GD3884@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100817150144.GD3884@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 18, 2010 at 12:01:44AM +0900, Minchan Kim wrote:
> On Tue, Aug 17, 2010 at 11:42:46AM +0100, Mel Gorman wrote:
> > On Tue, Aug 17, 2010 at 11:26:05AM +0900, Minchan Kim wrote:
> > > On Tue, Aug 17, 2010 at 1:06 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > > [npiggin@suse.de bounces, switched to yahoo address]
> > > >
> > > > On Mon, Aug 16, 2010 at 10:43:50AM +0100, Mel Gorman wrote:
> > > 
> > > <snip>
> > > 
> > > >> +      * potentially causing a live-lock. While kswapd is awake and
> > > >> +      * free pages are low, get a better estimate for free pages
> > > >> +      */
> > > >> +     if (nr_free_pages < zone->percpu_drift_mark &&
> > > >> +                     !waitqueue_active(&zone->zone_pgdat->kswapd_wait)) {
> > > >> +             int cpu;
> > > >> +
> > > >> +             for_each_online_cpu(cpu) {
> > > >> +                     struct per_cpu_pageset *pset;
> > > >> +
> > > >> +                     pset = per_cpu_ptr(zone->pageset, cpu);
> > > >> +                     nr_free_pages += pset->vm_stat_diff[NR_FREE_PAGES];
> > > 
> > > We need to consider CONFIG_SMP.
> > > 
> > 
> > We do.
> > 
> > #ifdef CONFIG_SMP
> > unsigned long zone_nr_free_pages(struct zone *zone);
> > #else
> > #define zone_nr_free_pages(zone) zone_page_state(zone, NR_FREE_PAGES)
> > #endif /* CONFIG_SMP */
> > 
> > and a wrapping of CONFIG_SMP around the function in mmzone.c .
> 
> I can't find it in this patch series. 

My bad. What I meant is "You're right, we do need to consider
CONFIG_SMP, how about something like the following";

I've made such a change to my local tree but it was not part of the
released series.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
