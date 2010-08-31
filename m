Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E99596B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 19:37:48 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7VNbjQ5019330
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Sep 2010 08:37:45 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 997FD45DE4E
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 08:37:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 77D8945DE4D
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 08:37:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FAC01DB8038
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 08:37:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CCA91DB803E
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 08:37:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of NR_FREE_PAGES when memory is low and kswapd is awake
In-Reply-To: <1283276257-1793-3-git-send-email-mel@csn.ul.ie>
References: <1283276257-1793-1-git-send-email-mel@csn.ul.ie> <1283276257-1793-3-git-send-email-mel@csn.ul.ie>
Message-Id: <20100901083425.971F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Sep 2010 08:37:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> +#ifdef CONFIG_SMP
> +/* Called when a more accurate view of NR_FREE_PAGES is needed */
> +unsigned long zone_nr_free_pages(struct zone *zone)
> +{
> +	unsigned long nr_free_pages = zone_page_state(zone, NR_FREE_PAGES);
> +
> +	/*
> +	 * While kswapd is awake, it is considered the zone is under some
> +	 * memory pressure. Under pressure, there is a risk that
> +	 * per-cpu-counter-drift will allow the min watermark to be breached
> +	 * potentially causing a live-lock. While kswapd is awake and
> +	 * free pages are low, get a better estimate for free pages
> +	 */
> +	if (nr_free_pages < zone->percpu_drift_mark &&
> +			!waitqueue_active(&zone->zone_pgdat->kswapd_wait)) {
> +		int cpu;
> +
> +		for_each_online_cpu(cpu) {
> +			struct per_cpu_pageset *pset;
> +
> +			pset = per_cpu_ptr(zone->pageset, cpu);
> +			nr_free_pages += pset->vm_stat_diff[NR_FREE_PAGES];

If my understanding is correct, we have no lock when reading pset->vm_stat_diff.
It mean nr_free_pages can reach negative value at very rarely race. boundary
check is necessary?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
