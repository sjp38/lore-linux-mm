Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7E15B6B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 07:49:39 -0400 (EDT)
Date: Fri, 23 Jul 2010 19:49:15 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
 writeback
Message-ID: <20100723114915.GA5125@localhost>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-8-git-send-email-mel@csn.ul.ie>
 <20100719142145.GD12510@infradead.org>
 <20100719144046.GR13117@csn.ul.ie>
 <20100722085210.GA26714@localhost>
 <20100722092155.GA28425@localhost>
 <20100722104823.GF13117@csn.ul.ie>
 <20100723094515.GD5043@localhost>
 <20100723105719.GE5300@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100723105719.GE5300@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andreas Mohr <andi@lisas.de>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 06:57:19PM +0800, Mel Gorman wrote:
> On Fri, Jul 23, 2010 at 05:45:15PM +0800, Wu Fengguang wrote:
> > On Thu, Jul 22, 2010 at 06:48:23PM +0800, Mel Gorman wrote:
> > > On Thu, Jul 22, 2010 at 05:21:55PM +0800, Wu Fengguang wrote:
> > > > > I guess this new patch is more problem oriented and acceptable:
> > > > > 
> > > > > --- linux-next.orig/mm/vmscan.c	2010-07-22 16:36:58.000000000 +0800
> > > > > +++ linux-next/mm/vmscan.c	2010-07-22 16:39:57.000000000 +0800
> > > > > @@ -1217,7 +1217,8 @@ static unsigned long shrink_inactive_lis
> > > > >  			count_vm_events(PGDEACTIVATE, nr_active);
> > > > >  
> > > > >  			nr_freed += shrink_page_list(&page_list, sc,
> > > > > -							PAGEOUT_IO_SYNC);
> > > > > +					priority < DEF_PRIORITY / 3 ?
> > > > > +					PAGEOUT_IO_SYNC : PAGEOUT_IO_ASYNC);
> > > > >  		}
> > > > >  
> > > > >  		nr_reclaimed += nr_freed;
> > > > 
> > > > This one looks better:
> > > > ---
> > > > vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
> > > > 
> > > > Fix "system goes totally unresponsive with many dirty/writeback pages"
> > > > problem:
> > > > 
> > > > 	http://lkml.org/lkml/2010/4/4/86
> > > > 
> > > > The root cause is, wait_on_page_writeback() is called too early in the
> > > > direct reclaim path, which blocks many random/unrelated processes when
> > > > some slow (USB stick) writeback is on the way.
> > > > 
> > > 
> > > So, what's the bet if lumpy reclaim is a factor that it's
> > > high-order-but-low-cost such as fork() that are getting caught by this since
> > > [78dc583d: vmscan: low order lumpy reclaim also should use PAGEOUT_IO_SYNC]
> > > was introduced?
> > 
> > Sorry I'm a bit confused by your wording..
> > 
> 
> After reading the thread, I realised that fork() stalling could be a
> factor. That commit allows lumpy reclaim and PAGEOUT_IO_SYNC to be used for
> high-order allocations such as those used by fork(). It might have been an
> oversight to allow order-1 to use PAGEOUT_IO_SYNC too easily.

That reads much clear. Thanks! I have the same feeling, hence the
proposed patch.

> > > That could manifest to the user as stalls creating new processes when under
> > > heavy IO. I would be surprised it would freeze the entire system but certainly
> > > any new work would feel very slow.
> > > 
> > > > A simple dd can easily create a big range of dirty pages in the LRU
> > > > list. Therefore priority can easily go below (DEF_PRIORITY - 2) in a
> > > > typical desktop, which triggers the lumpy reclaim mode and hence
> > > > wait_on_page_writeback().
> > > > 
> > > 
> > > which triggers the lumpy reclaim mode for high-order allocations.
> > 
> > Exactly. Changelog updated.
> > 
> > > lumpy reclaim mode is not something that is triggered just because priority
> > > is high.
> > 
> > Right.
> > 
> > > I think there is a second possibility for causing stalls as well that is
> > > unrelated to lumpy reclaim. Once dirty_limit is reached, new page faults may
> > > also result in stalls. If it is taking a long time to writeback dirty data,
> > > random processes could be getting stalled just because they happened to dirty
> > > data at the wrong time.  This would be the case if the main dirtying process
> > > (e.g. dd) is not calling sync and dropping pages it's no longer using.
> > 
> > The dirty_limit throttling will slow down the dirty process to the
> > writeback throughput. If a process is dirtying files on sda (HDD),
> > it will be throttled at 80MB/s. If another process is dirtying files
> > on sdb (USB 1.1), it will be throttled at 1MB/s.
> > 
> 
> It will slow down the dirty process doing the dd, but can it also slow
> down other processes that just happened to dirty pages at the wrong
> time.

For the case of of a heavy dirtier (dd) and concurrent light dirtiers
(some random processes), the light dirtiers won't be easily throttled.
task_dirty_limit() handles that case well. It will give light dirtiers
higher threshold than heavy dirtiers so that only the latter will be
dirty throttled.

> > So dirty throttling will slow things down. However the slow down
> > should be smooth (a series of 100ms stalls instead of a sudden 10s
> > stall), and won't impact random processes (which does no read/write IO
> > at all).
> > 
> 
> Ok.
> 
> > > > In Andreas' case, 512MB/1024 = 512KB, this is way too low comparing to
> > > > the 22MB writeback and 190MB dirty pages. There can easily be a
> > > > continuous range of 512KB dirty/writeback pages in the LRU, which will
> > > > trigger the wait logic.
> > > > 
> > > > To make it worse, when there are 50MB writeback pages and USB 1.1 is
> > > > writing them in 1MB/s, wait_on_page_writeback() may stuck for up to 50
> > > > seconds.
> > > > 
> > > > So only enter sync write&wait when priority goes below DEF_PRIORITY/3,
> > > > or 6.25% LRU. As the default dirty throttle ratio is 20%, sync write&wait
> > > > will hardly be triggered by pure dirty pages.
> > > > 
> > > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > > ---
> > > >  mm/vmscan.c |    4 ++--
> > > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > > > 
> > > > --- linux-next.orig/mm/vmscan.c	2010-07-22 16:36:58.000000000 +0800
> > > > +++ linux-next/mm/vmscan.c	2010-07-22 17:03:47.000000000 +0800
> > > > @@ -1206,7 +1206,7 @@ static unsigned long shrink_inactive_lis
> > > >  		 * but that should be acceptable to the caller
> > > >  		 */
> > > >  		if (nr_freed < nr_taken && !current_is_kswapd() &&
> > > > -		    sc->lumpy_reclaim_mode) {
> > > > +		    sc->lumpy_reclaim_mode && priority < DEF_PRIORITY / 3) {
> > > >  			congestion_wait(BLK_RW_ASYNC, HZ/10);
> > > >  
> > > 
> > > This will also delay waiting on congestion for really high-order
> > > allocations such as huge pages, some video decoder and the like which
> > > really should be stalling.
> > 
> > I absolutely agree that high order allocators should be somehow throttled.

> > However given that one can easily create a large _continuous_ range of
> > dirty LRU pages, let someone bumping all the way through the range
> > sounds a bit cruel..

Hmm. If such large range of dirty pages are approaching the end of LRU,
it means the LRU lists are being scanned pretty fast, indicating a
busy system and/or high memory pressure. So it seems reasonable to act
cruel to really high order allocators -- they won't perform well under
memory pressure after all, and only make things worse.

> > > How about the following compile-tested diff?
> > > It takes the cost of the high-order allocation into account and the
> > > priority when deciding whether to synchronously wait or not.
> > 
> > Very nice patch. Thanks!
> > 
> 
> Will you be picking it up or should I? The changelog should be more or less
> the same as yours and consider it
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Thanks. I'll post the patch.

> It'd be nice if the original tester is still knocking around and willing
> to confirm the patch resolves his/her problem. I am running this patch on
> my desktop at the moment and it does feel a little smoother but it might be
> my imagination. I had trouble with odd stalls that I never pinned down and
> was attributing to the machine being commonly heavily loaded but I haven't
> noticed them today.

Great. Just added CC to Andreas Mohr.

> It also needs an Acked-by or Reviewed-by from Kosaki Motohiro as it alters
> logic he introduced in commit [78dc583: vmscan: low order lumpy reclaim also
> should use PAGEOUT_IO_SYNC]

And Minchan, he has been following this issue too :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
