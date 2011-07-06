Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 138E09000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 11:13:12 -0400 (EDT)
Date: Wed, 6 Jul 2011 17:12:29 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback clustering
Message-ID: <20110706151229.GA1998@redhat.com>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
 <20110701154136.GA17881@localhost>
 <20110704032534.GD1026@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110704032534.GD1026@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

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
> We have to remember that memory reclaim is doing LRU reclaim and the
> flusher threads are doing "oldest first" writeback. IOWs, both are trying
> to operate in the same direction (oldest to youngest) for the same
> purpose.  The fundamental problem that occurs when memory reclaim
> starts writing pages back from the LRU is this:
> 
> 	- memory reclaim has run ahead of IO writeback -
> 
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
> The $100 question is a??why is it getting ahead of writeback*?

Unless you have a purely sequential writer, the LRU order is - at
least in theory - diverging away from the writeback order.

According to the reasoning behind generational garbage collection,
they should in fact be inverse to each other.  The oldest pages still
in use are the most likely to be still needed in the future.

In practice we only make a generational distinction between used-once
and used-many, which manifests in the inactive and the active list.
But still, when reclaim starts off with a localized writer, the oldest
pages are likely to be at the end of the active list.

So pages from the inactive list are likely to be written in the right
order, but at the same time active pages are even older, thus written
before them.  Memory reclaim starts with the inactive pages, and this
is why it gets ahead.

Then there is also the case where a fast writer pushes dirty pages to
the end of the LRU list, of course, but you already said that this is
not applicable to your workload.

My point is that I don't think it's unexpected that dirty pages come
off the inactive list in practice.  It just sucks how we handle them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
