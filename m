Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5C43A6B0022
	for <linux-mm@kvack.org>; Mon, 30 May 2011 11:37:54 -0400 (EDT)
Date: Mon, 30 May 2011 16:37:49 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110530153748.GS5044@csn.ul.ie>
References: <20110530131300.GQ5044@csn.ul.ie>
 <20110530143109.GH19505@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110530143109.GH19505@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Mon, May 30, 2011 at 04:31:09PM +0200, Andrea Arcangeli wrote:
> Hi Mel and everyone,
> 
> On Mon, May 30, 2011 at 02:13:00PM +0100, Mel Gorman wrote:
> > Asynchronous compaction is used when promoting to huge pages. This is
> > all very nice but if there are a number of processes in compacting
> > memory, a large number of pages can be isolated. An "asynchronous"
> > process can stall for long periods of time as a result with a user
> > reporting that firefox can stall for 10s of seconds. This patch aborts
> > asynchronous compaction if too many pages are isolated as it's better to
> > fail a hugepage promotion than stall a process.
> > 
> > If accepted, this should also be considered for 2.6.39-stable. It should
> > also be considered for 2.6.38-stable but ideally [11bc82d6: mm:
> > compaction: Use async migration for __GFP_NO_KSWAPD and enforce no
> > writeback] would be applied to 2.6.38 before consideration.
> 
> Is this supposed to fix the stall with khugepaged in D state and other
> processes in D state?
> 

Other processes. khugepaged might be getting stuck in the same loop but
I do not have a specific case in mind.

> zoneinfo showed a nr_isolated_file = -1, I don't think that meant
> compaction had 4g pages isolated really considering it moves from
> -1,0, 1. So I'm unsure if this fix could be right if the problem is
> the hang with khugepaged in D state reported, so far that looked more
> like a bug with PREEMPT in the vmstat accounting of nr_isolated_file
> that trips in too_many_isolated of both vmscan.c and compaction.c with
> PREEMPT=y. Or are you fixing a different problem?
> 

I'm not familiar with this problem. I either missed it or forgot about
it entirely. I was considering only Ury's report whereby firefox was
getting stalled for 10s of seconds in congestion_wait. It's possible the
root cause was isolated counters being broken but I didn't pick up on
it.

> Or how do you explain this -1 value out of nr_isolated_file? Clearly
> when that value goes to -1, compaction.c:too_many_isolated will hang,
> I think we should fix the -1 value before worrying about the rest...
> 
> grep nr_isolated_file zoneinfo-khugepaged 
>     nr_isolated_file 1
>     nr_isolated_file 4294967295

Can you point me at the thread that this file appears on and what the
conditions were? If vmstat is going to -1, it is indeed a problem
because it implies an imbalance in increments and decrements to the
isolated counters. Even with that fixed though, this patch still makes
sense as why would an asynchronous user of compaction stall on
congestion_wait?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
