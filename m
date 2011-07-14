Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 82F886B007E
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 20:09:49 -0400 (EDT)
Date: Thu, 14 Jul 2011 10:09:44 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 5/5] mm: writeback: Prioritise dirty inodes encountered
 by direct reclaim for background flushing
Message-ID: <20110714000944.GY23038@dastard>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
 <1310567487-15367-6-git-send-email-mgorman@suse.de>
 <20110713213947.GC21787@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110713213947.GC21787@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Wed, Jul 13, 2011 at 11:39:47PM +0200, Jan Kara wrote:
> On Wed 13-07-11 15:31:27, Mel Gorman wrote:
> > It is preferable that no dirty pages are dispatched from the page
> > reclaim path. If reclaim is encountering dirty pages, it implies that
> > either reclaim is getting ahead of writeback or use-once logic has
> > prioritise pages for reclaiming that are young relative to when the
> > inode was dirtied.
> > 
> > When dirty pages are encounted on the LRU, this patch marks the inodes
> > I_DIRTY_RECLAIM and wakes the background flusher. When the background
> > flusher runs, it moves such inodes immediately to the dispatch queue
> > regardless of inode age. There is no guarantee that pages reclaim
> > cares about will be cleaned first but the expectation is that the
> > flusher threads will clean the page quicker than if reclaim tried to
> > clean a single page.
>   Hmm, I was looking through your numbers but I didn't see any significant
> difference this patch would make. Do you?
> 
> I was thinking about the problem and actually doing IO from kswapd would be
> a small problem if we submitted more than just a single page. Just to give
> you idea - time to write a single page on plain SATA drive might be like 4
> ms. Time to write sequential 4 MB of data is like 80 ms (I just made up
> these numbers but the orders should be right).

I'm not so concerned about single drives - the numbers look far worse
when you have a high throughput filesystem. For arguments sake, lets
call that 1GB/s (even though I know of plenty of 10+GB/s XFS
filesystems out there). That gives you 4ms for a 4k IO, and 4MB of
data in 4ms seek + 4ms data transfer time, for 8ms total IO time.

> So to write 1000 times more
> data you just need like 20 times longer. That's a factor of 50 in IO
> efficiency.

In the case I tend to care about, it's more like factor of 1000 in
IO efficiency - 3 orders of magnitude or greater difference in
performance.

> So when reclaim/kswapd submits a single page IO once every
> couple of miliseconds, your IO throughput just went close to zero...
> BTW: I just checked your numbers in fsmark test with vanilla kernel.  You
> wrote like 14500 pages from reclaim in 567 seconds. That is about one page
> per 39 ms. That is going to have noticeable impact on IO throughput (not
> with XFS because it plays tricks with writing more than asked but with ext2
> or ext3 you would see it I guess).
> 
> So when kswapd sees high percentage of dirty pages at the end of LRU, it
> could call something like fdatawrite_range() for the range of 4 MB
> (provided the file is large enough) containing that page and IO thoughput
> would not be hit that much and you will get reasonably bounded time when
> the page gets cleaned... If you wanted to be clever, you could possibly be
> more sophisticated in picking the file and range to write so that you get
> rid of the most pages at the end of LRU but I'm not sure it's worth the CPU
> cycles. Does this sound reasonable to you?

That's what Wu's patch did - it pushed it off to the bdi-flusher
because you can't call iput() in memory reclaim context and you need
a reference to the inode before calling fdatawrite_range().

As I mentioned for that patch, writing 4MB instead of a single page
will cause different problems - after just 25 dirty pages, we've
queued 100MB of IO and on a typical desktop system that will take at
least a second to complete. Now we get the opposite problem of IO
latency to clean a specific page and the potential to stall normal
background expired inode writeback forever if we keep hitting dirty
pages during page reclaim.

It's just yet another reason I'd really like to see numbers showing
that not doing IO from memory reclaim causes problems in the cases
where it is said to be needed (like reclaiming memory from a
specific node) and that issuing IO is the -only- solution. If numbers
can't be produced showing that we *need* to do IO from memory
reclaim, then why jump through hoops like we currently are trying to
fix all the nasty corner cases?

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
