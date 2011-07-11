Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 700F86B004A
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 13:21:38 -0400 (EDT)
Date: Mon, 11 Jul 2011 19:20:50 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback clustering
Message-ID: <20110711172050.GA2849@redhat.com>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
 <20110701154136.GA17881@localhost>
 <20110704032534.GD1026@dastard>
 <20110706151229.GA1998@redhat.com>
 <20110708095456.GI1026@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110708095456.GI1026@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jul 08, 2011 at 07:54:56PM +1000, Dave Chinner wrote:
> On Wed, Jul 06, 2011 at 05:12:29PM +0200, Johannes Weiner wrote:
> > On Mon, Jul 04, 2011 at 01:25:34PM +1000, Dave Chinner wrote:
> > > On Fri, Jul 01, 2011 at 11:41:36PM +0800, Wu Fengguang wrote:
> > > We have to remember that memory reclaim is doing LRU reclaim and the
> > > flusher threads are doing "oldest first" writeback. IOWs, both are trying
> > > to operate in the same direction (oldest to youngest) for the same
> > > purpose.  The fundamental problem that occurs when memory reclaim
> > > starts writing pages back from the LRU is this:
> > > 
> > > 	- memory reclaim has run ahead of IO writeback -
> > > 
> > > The LRU usually looks like this:
> > > 
> > > 	oldest					youngest
> > > 	+---------------+---------------+--------------+
> > > 	clean		writeback	dirty
> > > 			^		^
> > > 			|		|
> > > 			|		Where flusher will next work from
> > > 			|		Where kswapd is working from
> > > 			|
> > > 			IO submitted by flusher, waiting on completion
> > > 
> > > 
> > > If memory reclaim is hitting dirty pages on the LRU, it means it has
> > > got ahead of writeback without being throttled - it's passed over
> > > all the pages currently under writeback and is trying to write back
> > > pages that are *newer* than what writeback is working on. IOWs, it
> > > starts trying to do the job of the flusher threads, and it does that
> > > very badly.
> > > 
> > > The $100 question is a??why is it getting ahead of writeback*?
> > 
> > Unless you have a purely sequential writer, the LRU order is - at
> > least in theory - diverging away from the writeback order.
> 
> Which is the root cause of the IO collapse that writeback from the
> LRU causes, yes?
> 
> > According to the reasoning behind generational garbage collection,
> > they should in fact be inverse to each other.  The oldest pages still
> > in use are the most likely to be still needed in the future.
> > 
> > In practice we only make a generational distinction between used-once
> > and used-many, which manifests in the inactive and the active list.
> > But still, when reclaim starts off with a localized writer, the oldest
> > pages are likely to be at the end of the active list.
> 
> Yet the file pages on the active list are unlikely to be dirty -
> overwrite-in-place cache hot workloads are pretty scarce in my
> experience. hence writeback of dirty pages from the active LRU is
> unlikely to be a problem.

Just to clarify, I looked at this too much from the reclaim POV, where
use-once applies to full pages, not bytes.

Even if you do not overwrite the same bytes over and over again,
issuing two subsequent write()s that end up against the same page will
have it activated.

Are your workloads writing in perfectly page-aligned chunks?

This effect may build up slowly, but every page that is written from
the active list makes room for a dirty page on the inactive list wrt
the dirty limit.  I.e. without the active pages, you have 10-20% dirty
pages at the head of the inactive list (default dirty ratio), or a
80-90% clean tail, and for every page cleaned, a new dirty page can
appear at the inactive head.

But taking the active list into account, some of these clean pages are
taken away from the headstart the flusher has over the reclaimer, they
sit on the active list.  For every page cleaned, a new dirty page can
appear at the inactive head, plus a few deactivated clean pages.

Now, the active list is not scanned anymore until it is bigger than
the inactive list, giving the flushers plenty of time to clean the
pages on it and let them accumulate even while memory pressure is
already occurring.  For every page cleaned, a new dirty page can
appear at the inactive head, plus a LOT of deactivated clean pages.

So when memory needs to be reclaimed, the LRU lists in those three
scenarios look like this:

	inactive-only: [CCCCCCCCDD][]

	active-small:  [CCCCCCDD][CC]

	active-huge:   [CCCDD][CCCCC]

where the third scenario is the most likely for the reclaimer to run
into dirty pages.

I CC'd Rik for reclaim-wizardry.  But if I am not completly off with
this there is a chance that the change that let the active list grow
unscanned may actually have contributed to this single-page writing
problem becoming worse?

commit 56e49d218890f49b0057710a4b6fef31f5ffbfec
Author: Rik van Riel <riel@redhat.com>
Date:   Tue Jun 16 15:32:28 2009 -0700

    vmscan: evict use-once pages first
    
    When the file LRU lists are dominated by streaming IO pages, evict those
    pages first, before considering evicting other pages.
    
    This should be safe from deadlocks or performance problems
    because only three things can happen to an inactive file page:
    
    1) referenced twice and promoted to the active list
    2) evicted by the pageout code
    3) under IO, after which it will get evicted or promoted
    
    The pages freed in this way can either be reused for streaming IO, or
    allocated for something else.  If the pages are used for streaming IO,
    this pageout pattern continues.  Otherwise, we will fall back to the
    normal pageout pattern.
    
    Signed-off-by: Rik van Riel <riel@redhat.com>
    Reported-by: Elladan <elladan@eskimo.com>
    Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
    Cc: Peter Zijlstra <peterz@infradead.org>
    Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
    Acked-by: Johannes Weiner <hannes@cmpxchg.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
