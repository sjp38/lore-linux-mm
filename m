Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 69F7F9000C2
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 21:24:09 -0400 (EDT)
Date: Wed, 6 Jul 2011 11:23:57 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback
 clustering
Message-ID: <20110706012356.GH1026@dastard>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
 <20110701154136.GA17881@localhost>
 <20110704032534.GD1026@dastard>
 <20110705143409.GB15285@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110705143409.GB15285@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jul 05, 2011 at 03:34:10PM +0100, Mel Gorman wrote:
> On Mon, Jul 04, 2011 at 01:25:34PM +1000, Dave Chinner wrote:
> > On Fri, Jul 01, 2011 at 11:41:36PM +0800, Wu Fengguang wrote:
> > > Christoph,
> > > 
> > > On Fri, Jul 01, 2011 at 05:33:05PM +0800, Christoph Hellwig wrote:
> > > > Johannes, Mel, Wu,
> > > > 
> > > > Dave has been stressing some XFS patches of mine that remove the XFS
> > > > internal writeback clustering in favour of using write_cache_pages.
> > > > 
> > > > As part of investigating the behaviour he found out that we're still
> > > > doing lots of I/O from the end of the LRU in kswapd.  Not only is that
> > > > pretty bad behaviour in general, but it also means we really can't
> > > > just remove the writeback clustering in writepage given how much
> > > > I/O is still done through that.
> > > > 
> > > > Any chance we could the writeback vs kswap behaviour sorted out a bit
> > > > better finally?
> > > 
> > > I once tried this approach:
> > > 
> > > http://www.spinics.net/lists/linux-mm/msg09202.html
> > > 
> > > It used a list structure that is not linearly scalable, however that
> > > part should be independently improvable when necessary.
> > 
> > I don't think that handing random writeback to the flusher thread is
> > much better than doing random writeback directly.  Yes, you added
> > some clustering, but I'm still don't think writing specific pages is
> > the best solution.
> > 
> > > The real problem was, it seem to not very effective in my test runs.
> > > I found many ->nr_pages works queued before the ->inode works, which
> > > effectively makes the flusher working on more dispersed pages rather
> > > than focusing on the dirty pages encountered in LRU reclaim.
> > 
> > But that's really just an implementation issue related to how you
> > tried to solve the problem. That could be addressed.
> > 
> > However, what I'm questioning is whether we should even care what
> > page memory reclaim wants to write - it seems to make fundamentally
> > bad decisions from an IO persepctive.
> > 
> 
> It sucks from an IO perspective but from the perspective of the VM that
> needs memory to be free in a particular zone or node, it's a reasonable
> request.

Sure, I'm not suggesting there is anything wrong the requirement of
being able to clean pages in a particular zone. My comments are
aimed at the fact the implementation of this feature is about as
friendly to the IO subsystem as a game of Roshambeau....

If someone comes to us complaining about an application that causes
this sort of IO behaviour, our answer is always "fix the
application" because it is not something we can fix in the
filesystem. Same here - we need to have the "application" fixed to
play well with others.

> > We have to remember that memory reclaim is doing LRU reclaim and the
> > flusher threads are doing "oldest first" writeback. IOWs, both are trying
> > to operate in the same direction (oldest to youngest) for the same
> > purpose.  The fundamental problem that occurs when memory reclaim
> > starts writing pages back from the LRU is this:
> > 
> > 	- memory reclaim has run ahead of IO writeback -
> > 
> 
> This reasoning was the basis for this patch
> http://www.gossamer-threads.com/lists/linux/kernel/1251235?do=post_view_threaded#1251235
> 
> i.e. if old pages are dirty then the flusher threads are either not
> awake or not doing enough work so wake them. It was flawed in a number
> of respects and never finished though.

But that's dealing with a different situation - you're assuming that the
writeback threads are not running or are running inefficiently.

What I'm seeing is bad behaviour when the IO subsystem is already
running flat out with perfectly formed IO. No additional IO
submission is going to make it clean pages faster than it already
is. It is in this situation that memory reclaim should never, ever
be trying to write dirty pages.

IIRC, the situation was that there were about 15,000 dirty pages and
~20,000 pages under writeback when memory reclaim started pushing
pages from the LRU. This is on a single node machine, with all IO
being single threaded (so a single source of memory pressure) and
writeback doing it's job.  Memory reclaim should *never* get ahead
of writeback under such a simple workload on such a simple
configuration....

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
> > The $100 question is ???why is it getting ahead of writeback*?
> > 
> 
> Allocating and dirtying memory faster than writeback. Large dd to USB
> stick would also trigger it.

Write throttling is supposed to prevent that situation from being
problematic. It's entire purpose is to throttle the dirtying rate to
match the writeback rate. If that's a problem, the memory reclaim
subsystem is the wrong place to be trying to fix it.

And as such, that is not the case here; foreground throttling is
definitely occurring and works fine for 70-80s, then memory reclaim
gets ahead of writeback and it all goes to shit.

> > From a brief look at the vmscan code, it appears that scanning does
> > not throttle/block until reclaim priority has got pretty high. That
> > means at low priority reclaim, it *skips pages under writeback*.
> > However, if it comes across a dirty page, it will trigger writeback
> > of the page.
> > 
> > Now call me crazy, but if we've already got a large number of pages
> > under writeback, why would we want to *start more IO* when clearly
> > the system is taking care of cleaning pages already and all we have
> > to do is wait for a short while to get clean pages ready for
> > reclaim?
> > 
> 
> It doesnt' check how many pages are under writeback.

Isn't that an indication of a design flaw? You want to clean
pages, but you don't even bother to check on how many pages are
currently being cleaned and will soon be reclaimable?

> Direct reclaim
> will check if the block device is congested but that is about
> it.

FWIW, we've removed all the congestion logic from the writeback
subsystem because IO throttling never really worked well that way.
Writeback IO throttling now works by foreground blocking during IO
submission on request queue slots in the elevator. That's why we
have flusher threads per-bdi - so writeback can block on a congested
bdi and not block writeback to other bdis. It's simpler, more
extensible and far more scalable than the old method.

Anyway, it's a moot point because direct reclaim can't issue IO
through xfs, ext4 or btrfs and as such I have doubts that the
throttling logic in vmscan is completely robust.

> Otherwise the expectation was the elevator would handle the
> merging of requests into a sensible patter. Also, while filesystem
> pages are getting cleaned by flushs, that does not cover anonymous
> pages being written to swap.

Anonymous pages written to swap are not the issue here - I couldn't
care less what you do with them. It's writeback of dirty file pages
that I care about...

> 
> > Indeed, I added this quick hack to prevent the VM from doing
> > writeback via pageout until after it starts blocking on writeback
> > pages:
> > 
> > @@ -825,6 +825,8 @@ static unsigned long shrink_page_list(struct list_head *page_l
> >  		if (PageDirty(page)) {
> >  			nr_dirty++;
> >  
> > +			if (!(sc->reclaim_mode & RECLAIM_MODE_SYNC))
> > +				goto keep_locked;
> >  			if (references == PAGEREF_RECLAIM_CLEAN)
> >  				goto keep_locked;
> >  			if (!may_enter_fs)
> > 
> > IOWs, we don't write pages from kswapd unless there is no IO
> > writeback going on at all (waited on all the writeback pages or none
> > exist) and there are dirty pages on the LRU.
> > 
> 
> A side effect of this patch is that kswapd is no longer writing
> anonymous pages to swap and possibly never will.

For dirty anon pages to still get written, all that needs to be
done is pass the file parameter to shrink_page_list() and change the
test to: 

+			if (file && (sc->reclaim_mode & RECLAIM_MODE_SYNC))
+				goto keep_locked;

As it is, I haven't had any of my test systems (which run tests that
deliberately cause OOM conditions) fail with this patch. While I
agree it is just a hack, it's naivety has also demonstrated that a
working system does not need to write back dirty file pages from
memory reclaim -at all-. i.e. it makes my argument stronger, not
weaker....

> RECLAIM_MODE_SYNC is
> only set for lumpy reclaim which if you have CONFIG_COMPACTION set, will
> never happen.

Which means that memory reclaim does not throttle reliably on
writeback in progress. Even when the priority has ratcheted right up
and it is obvious that the zone in question has pages being cleaned
and will soon be available for reclaim, memory reclaim won't wait
for them directly.

Once again this points to the throttling mechanism being sub-optimal
- it relies on second order effects (congestion_wait) to try to
block long enough for pages to be cleaned in the zone being
reclaimed from before doing another scan to find those pages. It's a
"wait and hope" approach to throttling, and that's one of the
reasons it never worked well in the writeback subsystem.

Instead, if memory reclaim waits directly on a page on the given LRU
under writeback it guarantees that when you are woken that there was
at least some progress made by the IO subsystem that would allow the
memory reclaim subsystem to move forward.

What it comes down to is the fact that you can scan tens of
thousands of pages in the time it takes for IO on a single page to
complete. If there are pages already under IO, then why start more
IO when what ends up getting reclaimed is one of the pages that is
already under IO when the new IO was issued?

BTW:

# CONFIG_COMPACTION is not set

> I see your figures and know why you want this but it never was that
> straight-forward :/

If the code is complex enough that implementing a basic policy such
as "don't writeback pages if there are already pages under
writeback" is difficult, then maybe the code needs to be
simplified....

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
