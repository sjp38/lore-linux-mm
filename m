Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AC6C46B01AF
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 10:17:00 -0400 (EDT)
Date: Mon, 5 Jul 2010 15:16:40 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 14/14] fs,xfs: Allow kswapd to writeback pages
Message-ID: <20100705141640.GD13780@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie> <1277811288-5195-15-git-send-email-mel@csn.ul.ie> <20100629123722.GA725@infradead.org> <20100629125143.GB31561@csn.ul.ie> <20100630091411.49f92cff.kamezawa.hiroyu@jp.fujitsu.com> <20100701103032.GG31741@csn.ul.ie> <20100702152643.36019b4e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100702152643.36019b4e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 02, 2010 at 03:26:43PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 1 Jul 2010 11:30:32 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> > > memcg shouldn't
> > > depends on it. If so, memcg should depends on some writeback-thread (as kswapd).
> > > ok.
> > > 
> > > Then, my concern here is that which kswapd we should wake up and how it can stop.
> > 
> > And also what the consequences are of kswapd being occupied with containers
> > instead of the global lists for a time.
> > 
>
> yes, we may have to add a thread or workqueue for memcg for isolating workloads.
> 

Possibly, and the closer it is to kswapd behaviour the better I would
imagine but I must warn that I do not have much familiar with the
behaviour of large numbers of memcg entering reclaim.

> > A slightly greater concern is that clean pages can be temporarily "lost"
> > on the cleaning list. If a direct reclaimer moves pages to the LRU_CLEANING
> > list, it's no longer considering those pages even if a flusher thread
> > happened to clean those pages before kswapd had a chance. Lets say under
> > heavy memory pressure a lot of pages are being dirties and encountered on
> > the LRU list. They move to LRU_CLEANING where dirty balancing starts making
> > sure they get cleaned but are no longer being reclaimed.
> > 
> > Of course, I might be wrong but it's not a trivial direction to take.
> > 
> 
> I hope dirty_ratio at el may help us. But I agree this "hiding" can cause
> issue.
> IIRC, someone wrote a patch to prevent too many threads enter vmscan..
> such kinds of work may be necessary.
> 

Using systemtap, I have found in global reclaim at least that the ratio of
dirty to clean pages is not a problem. What does appear to be a problem is
that dirty pages are getting to the end of the inactive file list while
still dirty but I haven't formulated a theory as to why yet - maybe it's
because the dirty balancing is cleaning new pages first?  Right now, I
believe dirty_ratio is working as expected but old dirty pages is a problem.

> > > <SNIP>
> > > @@ -2275,7 +2422,9 @@ static int kswapd(void *p)
> > >  		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> > >  		new_order = pgdat->kswapd_max_order;
> > >  		pgdat->kswapd_max_order = 0;
> > > -		if (order < new_order) {
> > > +		if (need_to_cleaning_node(pgdat)) {
> > > +			launder_pgdat(pgdat);
> > > +		} else if (order < new_order) {
> > >  			/*
> > >  			 * Don't sleep if someone wants a larger 'order'
> > >  			 * allocation
> > 
> > I see the direction you are thinking of but I have big concerns about clean
> > pages getting delayed for too long on the LRU_CLEANING pages before kswapd
> > puts them back in the right place. I think a safer direction would be for
> > memcg people to investigate Andrea's "switch stack" suggestion.
> > 
>
> Hmm, I may have to consider that. My concern is that IRQ's switch-stack works
> well just because no-task-switch in IRQ routine. (I'm sorry if I misunderstand.)
> 
> One possibility for memcg will be limit the number of reclaimers who can use
> __GFP_FS and use shared stack per cpu per memcg.
> 
> Hmm. yet another per-memcg memory shrinker may sound good. 2 years ago, I wrote
> a patch to do high-low-watermark memory shirker thread for memcg.
>   
>   - limit
>   - high
>   - low
> 
> start memory reclaim/writeback when usage exceeds "high" and stop it is below
> "low". Implementing this with thread pool can be a choice.
> 

Indeed, maybe something like a kswapd-memcg thread that is shared between
a configurable number of containers?

> 
> > In the meantime for my own series, memcg now treats dirty pages similar to
> > lumpy reclaim. It asks flusher threads to clean pages but stalls waiting
> > for those pages to be cleaned for a time. This is an untested patch on top
> > of the current series.
> > 
> 
> Wow...Doesn't this make memcg too slow ?

It depends heavily on how often dirty pages are being written back by direct
reclaim. It's not ideal but stalling briefly is better than crashing.
Ideally, the number of dirty pages encountered by direct reclaim would
be so small that it wouldn't matter so I'm looking into that.

> Anyway, memcg should kick flusher
> threads..or something, needs other works, too.
> 

With this patch, the flusher threads get kicked when direct reclaim encounters
pages it cannot clean.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
