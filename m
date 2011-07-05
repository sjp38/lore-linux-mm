Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A484A900134
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 10:34:16 -0400 (EDT)
Date: Tue, 5 Jul 2011 15:34:10 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback clustering
Message-ID: <20110705143409.GB15285@suse.de>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
 <20110701154136.GA17881@localhost>
 <20110704032534.GD1026@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110704032534.GD1026@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jul 04, 2011 at 01:25:34PM +1000, Dave Chinner wrote:
> On Fri, Jul 01, 2011 at 11:41:36PM +0800, Wu Fengguang wrote:
> > Christoph,
> > 
> > On Fri, Jul 01, 2011 at 05:33:05PM +0800, Christoph Hellwig wrote:
> > > Johannes, Mel, Wu,
> > > 
> > > Dave has been stressing some XFS patches of mine that remove the XFS
> > > internal writeback clustering in favour of using write_cache_pages.
> > > 
> > > As part of investigating the behaviour he found out that we're still
> > > doing lots of I/O from the end of the LRU in kswapd.  Not only is that
> > > pretty bad behaviour in general, but it also means we really can't
> > > just remove the writeback clustering in writepage given how much
> > > I/O is still done through that.
> > > 
> > > Any chance we could the writeback vs kswap behaviour sorted out a bit
> > > better finally?
> > 
> > I once tried this approach:
> > 
> > http://www.spinics.net/lists/linux-mm/msg09202.html
> > 
> > It used a list structure that is not linearly scalable, however that
> > part should be independently improvable when necessary.
> 
> I don't think that handing random writeback to the flusher thread is
> much better than doing random writeback directly.  Yes, you added
> some clustering, but I'm still don't think writing specific pages is
> the best solution.
> 
> > The real problem was, it seem to not very effective in my test runs.
> > I found many ->nr_pages works queued before the ->inode works, which
> > effectively makes the flusher working on more dispersed pages rather
> > than focusing on the dirty pages encountered in LRU reclaim.
> 
> But that's really just an implementation issue related to how you
> tried to solve the problem. That could be addressed.
> 
> However, what I'm questioning is whether we should even care what
> page memory reclaim wants to write - it seems to make fundamentally
> bad decisions from an IO persepctive.
> 

It sucks from an IO perspective but from the perspective of the VM that
needs memory to be free in a particular zone or node, it's a reasonable
request.

> We have to remember that memory reclaim is doing LRU reclaim and the
> flusher threads are doing "oldest first" writeback. IOWs, both are trying
> to operate in the same direction (oldest to youngest) for the same
> purpose.  The fundamental problem that occurs when memory reclaim
> starts writing pages back from the LRU is this:
> 
> 	- memory reclaim has run ahead of IO writeback -
> 

This reasoning was the basis for this patch
http://www.gossamer-threads.com/lists/linux/kernel/1251235?do=post_view_threaded#1251235

i.e. if old pages are dirty then the flusher threads are either not
awake or not doing enough work so wake them. It was flawed in a number
of respects and never finished though.

> The LRU usually looks like this:
> 
> 	oldest					youngest
> 	+---------------+---------------+--------------+
> 	clean		writeback	dirty
> 			^		^
> 			|		|
> 			|		Where flusher will next work from
> 			|		Where kswapd is working from
> 			|
> 			IO submitted by flusher, waiting on completion
> 
> 
> If memory reclaim is hitting dirty pages on the LRU, it means it has
> got ahead of writeback without being throttled - it's passed over
> all the pages currently under writeback and is trying to write back
> pages that are *newer* than what writeback is working on. IOWs, it
> starts trying to do the job of the flusher threads, and it does that
> very badly.
> 
> The $100 question is ???why is it getting ahead of writeback*?
> 

Allocating and dirtying memory faster than writeback. Large dd to USB
stick would also trigger it.

> From a brief look at the vmscan code, it appears that scanning does
> not throttle/block until reclaim priority has got pretty high. That
> means at low priority reclaim, it *skips pages under writeback*.
> However, if it comes across a dirty page, it will trigger writeback
> of the page.
> 
> Now call me crazy, but if we've already got a large number of pages
> under writeback, why would we want to *start more IO* when clearly
> the system is taking care of cleaning pages already and all we have
> to do is wait for a short while to get clean pages ready for
> reclaim?
> 

It doesnt' check how many pages are under writeback. Direct reclaim
will check if the block device is congested but that is about
it. Otherwise the expectation was the elevator would handle the
merging of requests into a sensible patter. Also, while filesystem
pages are getting cleaned by flushs, that does not cover anonymous
pages being written to swap.

> Indeed, I added this quick hack to prevent the VM from doing
> writeback via pageout until after it starts blocking on writeback
> pages:
> 
> @@ -825,6 +825,8 @@ static unsigned long shrink_page_list(struct list_head *page_l
>  		if (PageDirty(page)) {
>  			nr_dirty++;
>  
> +			if (!(sc->reclaim_mode & RECLAIM_MODE_SYNC))
> +				goto keep_locked;
>  			if (references == PAGEREF_RECLAIM_CLEAN)
>  				goto keep_locked;
>  			if (!may_enter_fs)
> 
> IOWs, we don't write pages from kswapd unless there is no IO
> writeback going on at all (waited on all the writeback pages or none
> exist) and there are dirty pages on the LRU.
> 

A side effect of this patch is that kswapd is no longer writing
anonymous pages to swap and possibly never will. RECLAIM_MODE_SYNC is
only set for lumpy reclaim which if you have CONFIG_COMPACTION set, will
never happen.

I see your figures and know why you want this but it never was that
straight-forward :/

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
