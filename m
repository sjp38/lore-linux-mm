Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1996A6B004D
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 21:04:34 -0400 (EDT)
Date: Fri, 3 Sep 2010 18:17:46 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
In-Reply-To: <20100903155537.41f1a3a7.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1009031811090.16264@router.home>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie> <1283504926-2120-3-git-send-email-mel@csn.ul.ie> <20100903155537.41f1a3a7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Sep 2010, Andrew Morton wrote:

> Can someone remind me why per_cpu_pageset went and reimplemented
> percpu_counters rather than just using them?

The vm counters are per zone and per cpu and have a flow from per cpu /
zone deltas to zone counters and then also into global counters.

> Is this really the best way of doing it?  The way we usually solve
> this problem (and boy, was this bug a newbie mistake!) is:
>
> 	foo = percpu_counter_read(x);
>
> 	if (foo says something bad) {
> 		/* Bad stuff: let's get a more accurate foo */
> 		foo = percpu_counter_sum(x);
> 	}
>
> 	if (foo still says something bad)
> 		do_bad_thing();
>
> In other words, don't do all this stuff with percpu_drift_mark and the
> kswapd heuristic.  Just change zone_watermark_ok() to use the more
> accurate read if it's about to return "no".

percpu counters must always be added up when their value is determined. We
cannot really affort that for the VM. Counters are always available
without looping over all cpus.

vm counters are continually kept up to date (but may have delta limited by
time and counter values).

This seems to be a special case here where Mel does not want to have to
cost to bring the counters up to date nor reduce the delta/time limits to
get some more accuracy but wants take some sort of snapshot of the whole
situation for this particular case.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
