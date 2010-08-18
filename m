Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AC6056B01F1
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 23:04:47 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7I34iNm030591
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 18 Aug 2010 12:04:44 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B1EA945DE6E
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:04:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 85B0E45DE7E
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:04:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 285A0E3800B
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:04:43 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B2C01E38006
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:04:42 +0900 (JST)
Date: Wed, 18 Aug 2010 11:59:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
Message-Id: <20100818115949.c840c937.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1281951733-29466-3-git-send-email-mel@csn.ul.ie>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
	<1281951733-29466-3-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "cl@linux-foundation.org" <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 2010 10:42:12 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> Ordinarily watermark checks are made based on the vmstat NR_FREE_PAGES as
> it is cheaper than scanning a number of lists. To avoid synchronization
> overhead, counter deltas are maintained on a per-cpu basis and drained both
> periodically and when the delta is above a threshold. On large CPU systems,
> the difference between the estimated and real value of NR_FREE_PAGES can be
> very high. If the system is under both load and low memory, it's possible
> for watermarks to be breached. In extreme cases, the number of free pages
> can drop to 0 leading to the possibility of system livelock.
> 
> This patch introduces zone_nr_free_pages() to take a slightly more accurate
> estimate of NR_FREE_PAGES while kswapd is awake.  The estimate is not perfect
> and may result in cache line bounces but is expected to be lighter than the
> IPI calls necessary to continually drain the per-cpu counters while kswapd
> is awake.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

BTW, a nitpick.

> @@ -143,6 +143,9 @@ static void refresh_zone_stat_thresholds(void)
>  		for_each_online_cpu(cpu)
>  			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
>  							= threshold;
> +
> +		zone->percpu_drift_mark = high_wmark_pages(zone) +
> +					num_online_cpus() * threshold;
>  	}
>  }

This function is now called only at CPU_DEAD. IOW, not called at CPU_UP_PREPARE

It's done by this patch....but the reason is unclear to me.
==
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=d1187ed21026fd512b87851d0ca26d9ae16f9059
==

Christoph ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
