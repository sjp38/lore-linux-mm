Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A78539000C2
	for <linux-mm@kvack.org>; Fri,  8 Jul 2011 05:55:02 -0400 (EDT)
Date: Fri, 8 Jul 2011 19:54:56 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback
 clustering
Message-ID: <20110708095456.GI1026@dastard>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
 <20110701154136.GA17881@localhost>
 <20110704032534.GD1026@dastard>
 <20110706151229.GA1998@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110706151229.GA1998@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Jul 06, 2011 at 05:12:29PM +0200, Johannes Weiner wrote:
> On Mon, Jul 04, 2011 at 01:25:34PM +1000, Dave Chinner wrote:
> > On Fri, Jul 01, 2011 at 11:41:36PM +0800, Wu Fengguang wrote:
> > We have to remember that memory reclaim is doing LRU reclaim and the
> > flusher threads are doing "oldest first" writeback. IOWs, both are trying
> > to operate in the same direction (oldest to youngest) for the same
> > purpose.  The fundamental problem that occurs when memory reclaim
> > starts writing pages back from the LRU is this:
> > 
> > 	- memory reclaim has run ahead of IO writeback -
> > 
> > The LRU usually looks like this:
> > 
> > 	oldest					youngest
> > 	+---------------+---------------+--------------+
> > 	clean		writeback	dirty
> > 			^		^
> > 			|		|
> > 			|		Where flusher will next work from
> > 			|		Where kswapd is working from
> > 			|
> > 			IO submitted by flusher, waiting on completion
> > 
> > 
> > If memory reclaim is hitting dirty pages on the LRU, it means it has
> > got ahead of writeback without being throttled - it's passed over
> > all the pages currently under writeback and is trying to write back
> > pages that are *newer* than what writeback is working on. IOWs, it
> > starts trying to do the job of the flusher threads, and it does that
> > very badly.
> > 
> > The $100 question is a??why is it getting ahead of writeback*?
> 
> Unless you have a purely sequential writer, the LRU order is - at
> least in theory - diverging away from the writeback order.

Which is the root cause of the IO collapse that writeback from the
LRU causes, yes?

> According to the reasoning behind generational garbage collection,
> they should in fact be inverse to each other.  The oldest pages still
> in use are the most likely to be still needed in the future.
> 
> In practice we only make a generational distinction between used-once
> and used-many, which manifests in the inactive and the active list.
> But still, when reclaim starts off with a localized writer, the oldest
> pages are likely to be at the end of the active list.

Yet the file pages on the active list are unlikely to be dirty -
overwrite-in-place cache hot workloads are pretty scarce in my
experience. hence writeback of dirty pages from the active LRU is
unlikely to be a problem.

That leaves all the use-once pages cycling through the inactive
list. The oldest pages on this list are the ones that get reclaimed,
and if we are getting lots of dirty pages here it seems pretty clear
that memory demand is mostly for pages being rapidly dirtied. In
which case, trying to speed up the rate at which they are cleaned by
issuing IO is only effective if there is no IO already in progress.

Who knows if Io is already in progress? The writeback subsystem....

> So pages from the inactive list are likely to be written in the right
> order, but at the same time active pages are even older, thus written
> before them.  Memory reclaim starts with the inactive pages, and this
> is why it gets ahead.

All right, if the design is such that you can't avoid having reclaim
write back dirty pages as it encounters them on the inactive LRU,
should the dirty pages even be on that LRU?

That is, dirty pages cannot be reclaimed immediately but they are
intertwined with pages that can be reclaimed immediately. We really
want to reclaim pages that can be reclaimed quickly while not
blocking on or continually having to skip over pages that cannot be
reclaimed.

So why not make a distinction between clean and dirty file pages on
the inactive list? That is, consider dirty pages to still be "in
use" and "owned" by the writeback subsystem. while pages are dirty
they are kept on a separate "dirty file page LRU" that memory
reclaim does not ever touch unless it runs out of clean pages on the
inactive list to reclaim. And then when it runs out of clean pages,
it can go find pages under writeback on the dirty list and block on
them before going back to reclaiming off the clean list....

And given that cgroups have their own LRUs for reclaim now, this
problem of dirty pages being written from the LRUs has a much larger
scope.  It's not just whether the global LRU reclaim is hitting
dirty pages, it's a per-cgroup problem and they are much more likely
to have low memory limits that lead to such problems. And
concurrently at that, too.  Writeback simply does't scale to having
multiple sources of random page IO being despatched concurrently.

> Then there is also the case where a fast writer pushes dirty pages to
> the end of the LRU list, of course, but you already said that this is
> not applicable to your workload.
> 
> My point is that I don't think it's unexpected that dirty pages come
> off the inactive list in practice.  It just sucks how we handle them.

Exactly what I've been saying.

And what I'm also trying to say is the way to fix the "we do shitty
IO on dirty pages" problem is *not to do IO*. That's -exactly- why
the IO-less write throttling is a significant improvement: we've
turned shitty IO into good IO by *waiting for IO* during throttling
rather than submitting IO.

Fundamentally, scaling to N IO waiters is far easier and more
efficient than scaling to N IO submitters. All I'm asking is that
you apply that same principle to memory reclaim, please.

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
