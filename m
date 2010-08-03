Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2FF1E6008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 08:51:37 -0400 (EDT)
Date: Tue, 3 Aug 2010 20:59:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: stop periodic/background work on seeing
 sync works
Message-ID: <20100803125924.GA31827@localhost>
References: <20100729115142.102255590@intel.com>
 <20100729121423.332557547@intel.com>
 <20100729162027.GF12690@quack.suse.cz>
 <20100730040306.GA5694@localhost>
 <20100802205152.GL3278@quack.suse.cz>
 <20100803030125.GA12070@localhost>
 <20100803105520.GA3322@quack.suse.cz>
 <20100803123922.GC3322@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100803123922.GC3322@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 03, 2010 at 08:39:22PM +0800, Jan Kara wrote:
> On Tue 03-08-10 12:55:20, Jan Kara wrote:
> > On Tue 03-08-10 11:01:25, Wu Fengguang wrote:
> > > On Tue, Aug 03, 2010 at 04:51:52AM +0800, Jan Kara wrote:
> > > > On Fri 30-07-10 12:03:06, Wu Fengguang wrote:
> > > > > On Fri, Jul 30, 2010 at 12:20:27AM +0800, Jan Kara wrote:
> > > > > > On Thu 29-07-10 19:51:44, Wu Fengguang wrote:
> > > > > > > The periodic/background writeback can run forever. So when any
> > > > > > > sync work is enqueued, increase bdi->sync_works to notify the
> > > > > > > active non-sync works to exit. Non-sync works queued after sync
> > > > > > > works won't be affected.
> > > > > >   Hmm, wouldn't it be simpler logic to just make for_kupdate and
> > > > > > for_background work always yield when there's some other work to do (as
> > > > > > they are livelockable from the definition of the target they have) and
> > > > > > make sure any other work isn't livelockable?
> > > > > 
> > > > > Good idea!
> > > > > 
> > > > > > The only downside is that
> > > > > > non-livelockable work cannot be "fair" in the sense that we cannot switch
> > > > > > inodes after writing MAX_WRITEBACK_PAGES.
> > > > > 
> > > > > Cannot switch indoes _before_ finish with the current
> > > > > MAX_WRITEBACK_PAGES batch? 
> > > >   Well, even after writing all those MAX_WRITEBACK_PAGES. Because what you
> > > > want to do in a non-livelockable work is: take inode, write it, never look at
> > > > it again for this work. Because if you later return to the inode, it can
> > > > have newer dirty pages and thus you cannot really avoid livelock. Of
> > > > course, this all assumes .nr_to_write isn't set to something small. That
> > > > avoids the livelock as well.
> > > 
> > > I do have a poor man's solution that can handle this case.
> > > https://kerneltrap.org/mailarchive/linux-fsdevel/2009/10/7/6476473/thread
> > > It may do more extra works, but will stop livelock in theory.
> >   So I don't think sync work on it's own is a problem. There we can just
> > give up any fairness and just go inode by inode. IMHO it's much simpler that
> > way. The remaining types of work we have are "for_reclaim" and then ones
> > triggered by filesystems to get rid of delayed allocated data. These cases
> > can easily have well defined and low nr_to_write so they wouldn't be
> > livelockable either. What do you think?
>   Fengguang, how about merging also the attached simple patch together with
> my fix? With these two patches, I'm not able to trigger any sync livelock
> while without one of them I hit them quite easily...

This looks OK. However note that redirty_tail() can modify
dirtied_when unexpectedly. So the more we rely on wb_start, the more
possibility an inode is (wrongly) skipped by sync. I have a bunch of
patches to remove redirty_tail(). However they may not be good
candidates for 2.6.36..

Thanks,
Fengguang


> 								Honza
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR

> From e4b708115825bca6a1020eed2356e2aab0567e3a Mon Sep 17 00:00:00 2001
> From: Jan Kara <jack@suse.cz>
> Date: Tue, 3 Aug 2010 10:35:02 +0000
> Subject: [PATCH] mm: Avoid resetting wb_start after each writeback round
> 
> WB_SYNC_NONE writeback is done in rounds of 1024 pages so that we don't write
> out some huge inode for too long while starving writeout of other inodes. To
> avoid livelocks, we record time we started writeback in wbc->wb_start and do
> not write out inodes which were dirtied after this time. But currently,
> writeback_inodes_wb() resets wb_start each time it is called thus effectively
> invalidating this logic and making any WB_SYNC_NONE writeback prone to
> livelocks.
> 
> This patch makes sure wb_start is set only once when we start writeback.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/fs-writeback.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 6bdc924..aa59394 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -530,7 +530,8 @@ void writeback_inodes_wb(struct bdi_writeback *wb,
>  {
>  	int ret = 0;
>  
> -	wbc->wb_start = jiffies; /* livelock avoidance */
> +	if (!wbc->wb_start)
> +		wbc->wb_start = jiffies; /* livelock avoidance */
>  	spin_lock(&inode_lock);
>  	if (!wbc->for_kupdate || list_empty(&wb->b_io))
>  		queue_io(wb, wbc->older_than_this);
> @@ -559,7 +560,6 @@ static void __writeback_inodes_sb(struct super_block *sb,
>  {
>  	WARN_ON(!rwsem_is_locked(&sb->s_umount));
>  
> -	wbc->wb_start = jiffies; /* livelock avoidance */
>  	spin_lock(&inode_lock);
>  	if (!wbc->for_kupdate || list_empty(&wb->b_io))
>  		queue_io(wb, wbc->older_than_this);
> @@ -625,6 +625,7 @@ static long wb_writeback(struct bdi_writeback *wb,
>  		wbc.range_end = LLONG_MAX;
>  	}
>  
> +	wbc.wb_start = jiffies; /* livelock avoidance */
>  	for (;;) {
>  		/*
>  		 * Stop writeback when nr_pages has been consumed
> -- 
> 1.6.0.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
