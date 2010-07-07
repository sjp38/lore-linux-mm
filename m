Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9AAB86B006A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 05:43:31 -0400 (EDT)
Date: Wed, 7 Jul 2010 10:43:11 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
Message-ID: <20100707094310.GJ13780@csn.ul.ie>
References: <20100702125155.69c02f85.akpm@linux-foundation.org> <20100705134949.GC13780@csn.ul.ie> <20100706093529.CCD1.A69D9226@jp.fujitsu.com> <20100706101235.GE13780@csn.ul.ie> <AANLkTin8FotAC1GvjuoYU9XA2eiSr6FWWh6bwypTdhq3@mail.gmail.com> <20100706152539.GG13780@csn.ul.ie> <20100706202758.GC18210@cmpxchg.org> <AANLkTimOkI95ZkJecE3jxRDDGbHvP9tRUluIoJuhqqMz@mail.gmail.com> <20100707002458.GI13780@csn.ul.ie> <20100707011533.GB3630@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100707011533.GB3630@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 06, 2010 at 09:15:33PM -0400, Christoph Hellwig wrote:
> On Wed, Jul 07, 2010 at 01:24:58AM +0100, Mel Gorman wrote:
> > What I have now is direct writeback for anon files. For files be it from
> > kswapd or direct reclaim, I kick writeback pre-emptively by an amount based
> > on the dirty pages encountered because monitoring from systemtap indicated
> > that we were getting a large percentage of the dirty file pages at the end
> > of the LRU lists (bad). Initial tests show that page reclaim writeback is
> > reduced from kswapd by 97% with this sort of pre-emptive kicking of flusher
> > threads based on these figures from sysbench.
> 
> That sounds like yet another bad aid to me.  Instead it would be much
> better to not have so many file pages at the end of LRU by tuning the
> flusher threads and VM better.
> 

Do you mean "so many dirty file pages"? I'm going to assume you do.

How do you suggest tuning this? The modification I tried was "if N dirty
pages are found during a SWAP_CLUSTER_MAX scan of pages, assume an average
dirtying density of at least that during the time those pages were inserted on
the LRU. In response, ask the flushers to flush 1.5X". This roughly responds
to the conditions it finds as they are encountered and is based on scanning
rates instead of time. It seemed like a reasonable option.

Based on what I've seen, we are generally below the dirty_ratio and the
flushers are behaving as expected so there is little tuning available there. As
new dirty pages are added to the inactive list, they are allowed to reach the
bottom of the LRU before the periodic sync kicks in. From what I can tell,
it's already the case that flusher threads are cleaning the oldest inodes
first and I'd expect there to be a rough correlation between oldest inode
and oldest pages.

We could reduce the dirty_ratio but people already complain about workloads
that do not allow enough pages to be dirtied. We could decrease the sync
time for flusher threads but then it might be starting IO sooner than it
should and it might be unnecessary if the system is under no memory pressure.

Alternatives?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
