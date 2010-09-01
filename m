Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0F6916B0047
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 03:33:33 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o817XTFh008146
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Sep 2010 16:33:30 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 84F4845DE6E
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 16:33:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 550E645DE60
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 16:33:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F6861DB8040
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 16:33:29 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AE2761DB8037
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 16:33:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of NR_FREE_PAGES when memory is low and kswapd is awake
In-Reply-To: <20100901072402.GE13677@csn.ul.ie>
References: <20100901083425.971F.A69D9226@jp.fujitsu.com> <20100901072402.GE13677@csn.ul.ie>
Message-Id: <20100901163146.9755.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Sep 2010 16:33:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Sep 01, 2010 at 08:37:41AM +0900, KOSAKI Motohiro wrote:
> > > +#ifdef CONFIG_SMP
> > > +/* Called when a more accurate view of NR_FREE_PAGES is needed */
> > > +unsigned long zone_nr_free_pages(struct zone *zone)
> > > +{
> > > +	unsigned long nr_free_pages = zone_page_state(zone, NR_FREE_PAGES);
> > > +
> > > +	/*
> > > +	 * While kswapd is awake, it is considered the zone is under some
> > > +	 * memory pressure. Under pressure, there is a risk that
> > > +	 * per-cpu-counter-drift will allow the min watermark to be breached
> > > +	 * potentially causing a live-lock. While kswapd is awake and
> > > +	 * free pages are low, get a better estimate for free pages
> > > +	 */
> > > +	if (nr_free_pages < zone->percpu_drift_mark &&
> > > +			!waitqueue_active(&zone->zone_pgdat->kswapd_wait)) {
> > > +		int cpu;
> > > +
> > > +		for_each_online_cpu(cpu) {
> > > +			struct per_cpu_pageset *pset;
> > > +
> > > +			pset = per_cpu_ptr(zone->pageset, cpu);
> > > +			nr_free_pages += pset->vm_stat_diff[NR_FREE_PAGES];
> > 
> > If my understanding is correct, we have no lock when reading pset->vm_stat_diff.
> > It mean nr_free_pages can reach negative value at very rarely race. boundary
> > check is necessary?
> > 
> 
> True, well spotted.
> 
> How about the following? It records a delta and checks if delta is negative
> and would cause underflow.
> 
> unsigned long zone_nr_free_pages(struct zone *zone)
> {
>         unsigned long nr_free_pages = zone_page_state(zone, NR_FREE_PAGES);
>         long delta = 0;
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
>                 int cpu;
> 
>                 for_each_online_cpu(cpu) {
>                         struct per_cpu_pageset *pset;
> 
>                         pset = per_cpu_ptr(zone->pageset, cpu);
>                         delta += pset->vm_stat_diff[NR_FREE_PAGES];
>                 }
>         }
> 
>         /* Watch for underflow */
>         if (delta < 0 && abs(delta) > nr_free_pages)
>                 delta = -nr_free_pages;
> 
>         return nr_free_pages + delta;
> }

Looks good to me :)
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thanks.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
