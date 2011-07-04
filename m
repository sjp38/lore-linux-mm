Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2DBE39000C2
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 23:25:41 -0400 (EDT)
Date: Mon, 4 Jul 2011 13:25:34 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback
 clustering
Message-ID: <20110704032534.GD1026@dastard>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
 <20110701154136.GA17881@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110701154136.GA17881@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jul 01, 2011 at 11:41:36PM +0800, Wu Fengguang wrote:
> Christoph,
> 
> On Fri, Jul 01, 2011 at 05:33:05PM +0800, Christoph Hellwig wrote:
> > Johannes, Mel, Wu,
> > 
> > Dave has been stressing some XFS patches of mine that remove the XFS
> > internal writeback clustering in favour of using write_cache_pages.
> > 
> > As part of investigating the behaviour he found out that we're still
> > doing lots of I/O from the end of the LRU in kswapd.  Not only is that
> > pretty bad behaviour in general, but it also means we really can't
> > just remove the writeback clustering in writepage given how much
> > I/O is still done through that.
> > 
> > Any chance we could the writeback vs kswap behaviour sorted out a bit
> > better finally?
> 
> I once tried this approach:
> 
> http://www.spinics.net/lists/linux-mm/msg09202.html
> 
> It used a list structure that is not linearly scalable, however that
> part should be independently improvable when necessary.

I don't think that handing random writeback to the flusher thread is
much better than doing random writeback directly.  Yes, you added
some clustering, but I'm still don't think writing specific pages is
the best solution.

> The real problem was, it seem to not very effective in my test runs.
> I found many ->nr_pages works queued before the ->inode works, which
> effectively makes the flusher working on more dispersed pages rather
> than focusing on the dirty pages encountered in LRU reclaim.

But that's really just an implementation issue related to how you
tried to solve the problem. That could be addressed.

However, what I'm questioning is whether we should even care what
page memory reclaim wants to write - it seems to make fundamentally
bad decisions from an IO persepctive.

We have to remember that memory reclaim is doing LRU reclaim and the
flusher threads are doing "oldest first" writeback. IOWs, both are trying
to operate in the same direction (oldest to youngest) for the same
purpose.  The fundamental problem that occurs when memory reclaim
starts writing pages back from the LRU is this:

	- memory reclaim has run ahead of IO writeback -

The LRU usually looks like this:

	oldest					youngest
	+---------------+---------------+--------------+
	clean		writeback	dirty
			^		^
			|		|
			|		Where flusher will next work from
			|		Where kswapd is working from
			|
			IO submitted by flusher, waiting on completion


If memory reclaim is hitting dirty pages on the LRU, it means it has
got ahead of writeback without being throttled - it's passed over
all the pages currently under writeback and is trying to write back
pages that are *newer* than what writeback is working on. IOWs, it
starts trying to do the job of the flusher threads, and it does that
very badly.

The $100 question is a??why is it getting ahead of writeback*?

>From a brief look at the vmscan code, it appears that scanning does
not throttle/block until reclaim priority has got pretty high. That
means at low priority reclaim, it *skips pages under writeback*.
However, if it comes across a dirty page, it will trigger writeback
of the page.

Now call me crazy, but if we've already got a large number of pages
under writeback, why would we want to *start more IO* when clearly
the system is taking care of cleaning pages already and all we have
to do is wait for a short while to get clean pages ready for
reclaim?

Indeed, I added this quick hack to prevent the VM from doing
writeback via pageout until after it starts blocking on writeback
pages:

@@ -825,6 +825,8 @@ static unsigned long shrink_page_list(struct list_head *page_l
 		if (PageDirty(page)) {
 			nr_dirty++;
 
+			if (!(sc->reclaim_mode & RECLAIM_MODE_SYNC))
+				goto keep_locked;
 			if (references == PAGEREF_RECLAIM_CLEAN)
 				goto keep_locked;
 			if (!may_enter_fs)

IOWs, we don't write pages from kswapd unless there is no IO
writeback going on at all (waited on all the writeback pages or none
exist) and there are dirty pages on the LRU.

This doesn't completely stop the IO collapse, (looks like foreground
throttling is the other cause, which IO-less write throttling fixes)
but the collapse was significantly reduced in duration and intensity
by removing kswapd writeback. In fact, the IO rate only dropped to
~60MB/s instead of 30MB/s, and the improvement is easily measured by
the runtime of the test:

			run 1	run 2	run 3
3.0-rc5-vanilla		135s	137s	138s
3.0-rc5-patched		117s	115s	115s

That's a pretty massive improvement for a 2-line patch. ;) I expect
the IO-less write throttling patchset will further improve this.

FWIW, the nr_vmscan_write values changed like this:

			run 1	run 2	run 3
3.0-rc5-vanilla		6751	6893	6465
3.0-rc5-patched		0	0	0

These results support my argument that memory reclaim should not be
doing dirty page writeback at all - defering writeback to the
writeback infrastructure and just waiting for it to complete
appropriately is the Right Thing To Do. i.e. IO-less memory reclaim
works better than the current code for the same reason IO-less write
throttling works better than the current code....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
