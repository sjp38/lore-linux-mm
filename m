Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F2CF36B02A7
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 07:14:23 -0400 (EDT)
Date: Fri, 30 Jul 2010 21:12:44 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/5]  [RFC] transfer ASYNC vmscan writeback IO to the
 flusher threads
Message-ID: <20100730111244.GC2126@dastard>
References: <20100729115142.102255590@intel.com>
 <20100729232330.GO655@dastard>
 <20100730075819.GE8811@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100730075819.GE8811@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 30, 2010 at 03:58:19PM +0800, Wu Fengguang wrote:
> On Fri, Jul 30, 2010 at 07:23:30AM +0800, Dave Chinner wrote:
> > On Thu, Jul 29, 2010 at 07:51:42PM +0800, Wu Fengguang wrote:
> > > Andrew,
> > > 
> > > It's possible to transfer ASYNC vmscan writeback IOs to the flusher threads.
> > > This simple patchset shows the basic idea. Since it's a big behavior change,
> > > there are inevitably lots of details to sort out. I don't know where it will
> > > go after tests and discussions, so the patches are intentionally kept simple.
> > > 
> > > sync livelock avoidance (need more to be complete, but this is minimal required for the last two patches)
> > > 	[PATCH 1/5] writeback: introduce wbc.for_sync to cover the two sync stages
> > > 	[PATCH 2/5] writeback: stop periodic/background work on seeing sync works
> > > 	[PATCH 3/5] writeback: prevent sync livelock with the sync_after timestamp
> > > 
> > > let the flusher threads do ASYNC writeback for pageout()
> > > 	[PATCH 4/5] writeback: introduce bdi_start_inode_writeback()
> > > 	[PATCH 5/5] vmscan: transfer async file writeback to the flusher
> > 
> > I really do not like this - all it does is transfer random page writeback
> > from vmscan to the flusher threads rather than avoiding random page
> > writeback altogether. Random page writeback is nasty - just say no.
> 
> There are cases we have to do pageout().
> 
> - a stressed memcg with lots of dirty pages
> - a large NUMA system whose nodes have unbalanced vmscan rate and dirty pages
> 
> In the above cases, the whole system may not be that stressed,
> except for some local LRU list being busy scanned.  If the local
> memory stress lead to lots of pageout(), it could bring down the whole
> system by congesting the disks with many small seeky IO.
> 
> It may be an overkill to push global writeback (ie. it's silly to sync
> 1GB dirty data because there is a small stressed 100MB LRU list).

No it isn't. Dirty pages have to cleaned sometime and it reclaim has
a need to clean pages, we may as well start cleaning them all.
Kicking background writeback is effectively just starting work we
have already delayed into the future a little bit earlier than we
otherwise would have.

Doing this is only going to hurt performance if the same pages are
being frequently dirtied, but the cahnges to flush expired inodes
first in background writeback should avoid the worst of that
behaviour. Further, the more clean pages we have, the faster
susbequent memory reclaims are going to free up pages....


> The
> obvious solution is to keep the pageout() calls and make them more IO
> wise by doing write-around at the same time.  The write-around pages
> will likely be in the same stressed LRU list, hence will do good for
> page reclaim as well.

You've kind of already done that by telling it to writeback 1024
pages starting with a specific page. However, the big problem with
this is that it asusme that the inode has contiguous dirty pages in
the cache.  That assumption fall down in many cases e.g. when you
are writing lots of small files like kernel trees contain, and so
you still end up with random IO patterns coming out of reclaim.

> Transferring ASYNC work to the flushers helps the
> kswapd-vs-flusher priority problem too. Currently the
> kswapd/direct reclaim either have to skip dirty pages on
> congestion, or to risk being blocked in get_request_wait(), both
> are not good options. However the use of
> bdi_start_inode_writeback() do ask for a good vmscan throttling
> scheme to prevent it falsely OOM before the flusher is able to
> clean the transfered pages. This would be tricky.

I have no problem with that aspect ofthe patch - my issue is that it
does nothing to prevent the problem that causes excessive congestion
in the first place...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
