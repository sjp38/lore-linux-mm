Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1D75A6B0250
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 11:40:09 -0400 (EDT)
Date: Tue, 15 Jun 2010 16:38:38 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
	and use a_ops->writepages() where possible
Message-ID: <20100615153838.GO26788@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie> <20100615140011.GD28052@random.random> <20100615141122.GA27893@infradead.org> <20100615142219.GE28052@random.random> <20100615144342.GA3339@infradead.org> <20100615150850.GF28052@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100615150850.GF28052@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 05:08:50PM +0200, Andrea Arcangeli wrote:
> On Tue, Jun 15, 2010 at 10:43:42AM -0400, Christoph Hellwig wrote:
> > Other callers of ->writepage are fine because they come from a
> > controlled environment with relatively little stack usage.  The problem
> > with direct reclaim is that we splice multiple stack hogs ontop of each
> > other.
> 
> It's not like we're doing a stack recursive algorithm in kernel. These
> have to be "controlled hogs", so we must have space to run 4/5 of them
> on top of each other, that's the whole point.
> 
> I'm aware the ->writepage can run on any alloc_pages, but frankly I
> don't see a whole lot of difference between regular kernel code paths
> or msync. Sure they can be at higher stack usage, but not like with
> only 1000bytes left.
> 

That is pretty much what Dave is claiming here at
http://lkml.org/lkml/2010/4/13/121 where if mempool_alloc_slab() needed
to allocate a page and writepage was entered, there would have been a
a problem.

I disagreed with his fix which is what led to this series as an alternative.

> > And seriously, if the VM isn't stopped from calling ->writepage from
> > reclaim context we FS people will simply ignore any ->writepage from
> > reclaim context.  Been there, done that and never again.
> > 
> > Just wondering, what filesystems do your hugepage testing systems use?
> > If it's any of the ext4/btrfs/xfs above you're already seeing the
> > filesystem refuse ->writepage from both kswapd and direct reclaim,
> > so Mel's series will allow us to reclaim pages from more contexts
> > than before.
> 
> fs ignoring ->writepage during memory pressure (even from kswapd) is
> broken, this is not up to the fs to decide. I'm using ext4 on most of
> my testing, it works ok, but it doesn't make it right (if fact if
> performance declines without that hack, it may prove VM needs fixing,
> it doesn't justify the hack).
> 

Broken or not, it's what some of them are doing to avoid stack
overflows. Worst, they are ignoring both kswapd and direct reclaim when they
only really needed to ignore kswapd. With this series at least, the
check for PF_MEMALLOC in ->writepage can be removed

> If you don't throttle against kswapd, or if even kswapd can't turn a
> dirty page into a clean one, you can get oom false positives. Anything
> is better than that.

This series would at least allow kswapd to turn dirty pages into clean
ones so it's an improvement.

> (provided you've proper stack instrumentation to
> notice when there is risk of a stack overflow, it's ages I never seen
> a stack overflow debug detector report)
> 
> The irq stack must be enabled and this isn't about direct reclaim but
> about irqs in general and their potential nesting with softirq calls
> too.
> 
> Also note, there's nothing that prevents us from switching the stack
> to something else the moment we enter direct reclaim.

Other than a lack of code to do it :/

If you really feel strongly about this, you could follow on the series
by extending clean_page_list() to switch stack if !kswapd.

> It doesn't need
> to be physically contiguous. Just allocate a couple of 4k pages and
> switch to them every time a new hog starts in VM context. The only
> real complexity is in the stack unwind but if irqstack can cope with
> it sure stack unwind can cope with more "special" stacks too.
> 
> Ignoring ->writepage on VM invocations at best can only hide VM
> inefficiencies with the downside of breaking the VM in corner cases
> with heavy VM pressure.
> 

This has actually been the case for a while. I vaguely recall FS people
complaining about writepage from direct reclaim at some conference or
the other two years ago.

> Crippling down the kernel by vetoing ->writepage to me looks very
> wrong, but I'd be totally supportive of a "special" writepage stack or
> special iscsi stack etc...
> 

I'm not sure the complexityy is justified based on the data I've seen so
far.

                if (reclaim_can_writeback(sc)) {
                        cleaned = MAX_SWAP_CLEAN_WAIT;
                        clean_page_list(page_list, sc);
                        goto restart_dirty;
                } else {
                        cleaned++;
                        /*
                         * If lumpy reclaiming, kick the background
                         * flusher and wait
                         * for the pages to be cleaned
                         *
                         * XXX: kswapd won't find these isolated pages but the
                         *      background flusher does not prioritise pages. It'd
                         *      be nice to prioritise a list of pages somehow
                         */
                        if (sync_writeback == PAGEOUT_IO_SYNC) {
                                wakeup_flusher_threads(nr_dirty);
                                congestion_wait(BLK_RW_ASYNC, HZ/10);
                                goto restart_dirty;
                        }
                }

to

                if (reclaim_can_writeback(sc)) {
                        cleaned = MAX_SWAP_CLEAN_WAIT;
                        clean_page_list(page_list, sc);
                        goto restart_dirty;
                } else {
                        cleaned++;
                        wakeup_flusher_threads(nr_dirty);
                        congestion_wait(BLK_RW_ASYNC, HZ/10);

			/* If not in lumpy reclaim, just try these
			 * pages one more time before isolating more
			 * pages from the LRU
			 */
			if (sync_writeback != PAGEOUT_IO_SYNC)
				clean = MAX_SWAP_CLEAN_WAIT;
			goto restart_dirty;
                }

i.e. when direct reclaim encounters N dirty pages, unconditionally ask the
flusher threads to clean that number of pages, throttle by waiting for them
to be cleaned, reclaim them if they get cleaned or otherwise scan more pages
on the LRU.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
