Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC2B6B0246
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 20:25:17 -0400 (EDT)
Date: Wed, 7 Jul 2010 01:24:58 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
Message-ID: <20100707002458.GI13780@csn.ul.ie>
References: <20100702125155.69c02f85.akpm@linux-foundation.org> <20100705134949.GC13780@csn.ul.ie> <20100706093529.CCD1.A69D9226@jp.fujitsu.com> <20100706101235.GE13780@csn.ul.ie> <AANLkTin8FotAC1GvjuoYU9XA2eiSr6FWWh6bwypTdhq3@mail.gmail.com> <20100706152539.GG13780@csn.ul.ie> <20100706202758.GC18210@cmpxchg.org> <AANLkTimOkI95ZkJecE3jxRDDGbHvP9tRUluIoJuhqqMz@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTimOkI95ZkJecE3jxRDDGbHvP9tRUluIoJuhqqMz@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 07, 2010 at 07:28:14AM +0900, Minchan Kim wrote:
> On Wed, Jul 7, 2010 at 5:27 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Tue, Jul 06, 2010 at 04:25:39PM +0100, Mel Gorman wrote:
> >> On Tue, Jul 06, 2010 at 08:24:57PM +0900, Minchan Kim wrote:
> >> > but it is still problem in case of swap file.
> >> > That's because swapout on swapfile cause file system writepage which
> >> > makes kernel stack overflow.
> >>
> >> I don't *think* this is a problem unless I missed where writing out to
> >> swap enters teh filesystem code. I'll double check.
> >
> > It bypasses the fs.  On swapon, the blocks are resolved
> > (mm/swapfile.c::setup_swap_extents) and then the writeout path uses
> > bios directly (mm/page_io.c::swap_writepage).
> >
> > (GFP_NOFS still includes __GFP_IO, so allows swapping)
> >
> >        Hannes
> 
> Thanks, Hannes. You're right.
> Extents would be resolved by setup_swap_extents.
> Sorry for confusing, Mel.
> 

No confusion. I was 99.99999% certain this was the case and had tested with
a few bug_on's just in case but confirmation is helpful. Thanks both.

What I have now is direct writeback for anon files. For files be it from
kswapd or direct reclaim, I kick writeback pre-emptively by an amount based
on the dirty pages encountered because monitoring from systemtap indicated
that we were getting a large percentage of the dirty file pages at the end
of the LRU lists (bad). Initial tests show that page reclaim writeback is
reduced from kswapd by 97% with this sort of pre-emptive kicking of flusher
threads based on these figures from sysbench.

                traceonly-v4r1  stackreduce-v4r1    flushforward-v4r4
Direct reclaims                                621        710         30928 
Direct reclaim pages scanned                141316     141184       1912093 
Direct reclaim write file async I/O          23904      28714             0 
Direct reclaim write anon async I/O            716        918            88 
Direct reclaim write file sync I/O               0          0             0 
Direct reclaim write anon sync I/O               0          0             0 
Wake kswapd requests                        713250     735588       5626413 
Kswapd wakeups                                1805       1498           641 
Kswapd pages scanned                      17065538   15605327       9524623 
Kswapd reclaim write file async I/O         715768     617225         23938  <-- Wooo
Kswapd reclaim write anon async I/O         218003     214051        198746 
Kswapd reclaim write file sync I/O               0          0             0 
Kswapd reclaim write anon sync I/O               0          0             0 
Time stalled direct reclaim (ms)              9.87      11.63        315.30 
Time kswapd awake (ms)                     1884.91    2088.23       3542.92 

This is "good" IMO because file IO from page reclaim is frowned upon because
of poor IO patterns. There isn't a launder process I can kick for anon pages
to get overall reclaim IO down but it's not clear it's worth it at this
juncture because AFAIK, IO to swap blows anyway. The biggest plus is that
direct reclaim still not call into the filesystem with my current series so
stack overflows are less of a heartache. As the number of pages encountered
for filesystem writeback are reduced, it's also less of a problem for memcg.

The direct reclaim stall latency increases because of congestion_wait
throttling but the overall tests completes 602 seconds faster or by 8% (figures
not included). Scanning rates go up but with reduced-time-to-completion,
on balance I think it works out.

Andrew has picked up some of the series but I have another modification
to the tracepoints to differenciate between anon and file IO which I now
think is a very important distinction as flushers work on one but not the
other. I also must rebase upon a mmotm based on 2.6.35-rc4 before re-posting
the series but broadly speaking, I think we are going the right direction
without needing stack-switching tricks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
