Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 992946B004A
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 21:16:27 -0400 (EDT)
Date: Fri, 3 Sep 2010 16:28:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
Message-Id: <20100903162821.48ec57cc.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1009031811090.16264@router.home>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie>
	<1283504926-2120-3-git-send-email-mel@csn.ul.ie>
	<20100903155537.41f1a3a7.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1009031811090.16264@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Sep 2010 18:17:46 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Fri, 3 Sep 2010, Andrew Morton wrote:
> 
> > Can someone remind me why per_cpu_pageset went and reimplemented
> > percpu_counters rather than just using them?
> 
> The vm counters are per zone and per cpu and have a flow from per cpu /
> zone deltas to zone counters and then also into global counters.

hm.  percpu counters would require overflow-time hooks to do that. 
Might be worth looking at.

> > Is this really the best way of doing it?  The way we usually solve
> > this problem (and boy, was this bug a newbie mistake!) is:
> >
> > 	foo = percpu_counter_read(x);
> >
> > 	if (foo says something bad) {
> > 		/* Bad stuff: let's get a more accurate foo */
> > 		foo = percpu_counter_sum(x);
> > 	}
> >
> > 	if (foo still says something bad)
> > 		do_bad_thing();
> >
> > In other words, don't do all this stuff with percpu_drift_mark and the
> > kswapd heuristic.  Just change zone_watermark_ok() to use the more
> > accurate read if it's about to return "no".
> 
> percpu counters must always be added up when their value is determined.

Nope.  That's the difference between percpu_counter_read() and
percpu_counter_sum().

> This seems to be a special case here where Mel does not want to have to
> cost to bring the counters up to date nor reduce the delta/time limits to
> get some more accuracy but wants take some sort of snapshot of the whole
> situation for this particular case.

My suggestion didn't actually have anything to do with percpu_counters.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
