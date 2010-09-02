Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D5A8B6B004A
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 20:24:57 -0400 (EDT)
Date: Wed, 1 Sep 2010 19:24:52 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
In-Reply-To: <20100901203422.GA19519@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1009011919110.20518@router.home>
References: <20100901083425.971F.A69D9226@jp.fujitsu.com> <20100901072402.GE13677@csn.ul.ie> <20100901163146.9755.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009011512190.16322@router.home> <20100901203422.GA19519@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Sep 2010, Mel Gorman wrote:

> > > >         if (delta < 0 && abs(delta) > nr_free_pages)
> > > >                 delta = -nr_free_pages;
> >
> > Not sure what the point here is. If the delta is going below zero then
> > there was a concurrent operation updating the counters negatively while
> > we summed up the counters.
>
> The point is if the negative delta is greater than the current value of
> nr_free_pages then nr_free_pages would underflow when delta is applied to it.

Ok. then

	nr_free_pages += delta;
	if (nr_free_pages < 0)
		nr_free_pages = 0;

> > would be correct.
>
> Lets say the reading at the start for nr_free_pages is 120 and the delta is
> -20, then the estimated true value of nr_free_pages is 100. If we used your
> logic, the estimate would be 120. Maybe I'm missing what you're saying.

Well yes the sum of the counter needs to be checked not just the sum of
the deltas. This is the same as the counter determination in vmstat.h

> > See also handling of counter underflow in
> > vmstat.h:zone_page_state().
>
> I'm not seeing the relation. zone_nr_free_pages() is trying to
> reconcile the reading from zone_page_state() with the contents of
> vm_stat_diff[].

Both are determinations of a counter value. The global or zone counters
can also temporarily go below zero due to deferred updates. If
this happens then 0 will be returned(!). zonr_nr_free_pages need to work
in the same way.

> > As I have said before: I would rather have the
> > counter handling in one place to avoid creating differences in counter
> > handling.
> >
>
> And I'd rather not hurt the paths for every counter unnecessarily
> without good cause. I can move zone_nr_free_pages() to mm/vmstat.c if
> you'd prefer?

Generalize it on the way please to work with any counter?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
