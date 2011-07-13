Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4756B004A
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 17:39:55 -0400 (EDT)
Date: Wed, 13 Jul 2011 23:39:47 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/5] mm: writeback: Prioritise dirty inodes encountered
 by direct reclaim for background flushing
Message-ID: <20110713213947.GC21787@quack.suse.cz>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
 <1310567487-15367-6-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1310567487-15367-6-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Wed 13-07-11 15:31:27, Mel Gorman wrote:
> It is preferable that no dirty pages are dispatched from the page
> reclaim path. If reclaim is encountering dirty pages, it implies that
> either reclaim is getting ahead of writeback or use-once logic has
> prioritise pages for reclaiming that are young relative to when the
> inode was dirtied.
> 
> When dirty pages are encounted on the LRU, this patch marks the inodes
> I_DIRTY_RECLAIM and wakes the background flusher. When the background
> flusher runs, it moves such inodes immediately to the dispatch queue
> regardless of inode age. There is no guarantee that pages reclaim
> cares about will be cleaned first but the expectation is that the
> flusher threads will clean the page quicker than if reclaim tried to
> clean a single page.
  Hmm, I was looking through your numbers but I didn't see any significant
difference this patch would make. Do you?

I was thinking about the problem and actually doing IO from kswapd would be
a small problem if we submitted more than just a single page. Just to give
you idea - time to write a single page on plain SATA drive might be like 4
ms. Time to write sequential 4 MB of data is like 80 ms (I just made up
these numbers but the orders should be right). So to write 1000 times more
data you just need like 20 times longer. That's a factor of 50 in IO
efficiency. So when reclaim/kswapd submits a single page IO once every
couple of miliseconds, your IO throughput just went close to zero...
BTW: I just checked your numbers in fsmark test with vanilla kernel.  You
wrote like 14500 pages from reclaim in 567 seconds. That is about one page
per 39 ms. That is going to have noticeable impact on IO throughput (not
with XFS because it plays tricks with writing more than asked but with ext2
or ext3 you would see it I guess).

So when kswapd sees high percentage of dirty pages at the end of LRU, it
could call something like fdatawrite_range() for the range of 4 MB
(provided the file is large enough) containing that page and IO thoughput
would not be hit that much and you will get reasonably bounded time when
the page gets cleaned... If you wanted to be clever, you could possibly be
more sophisticated in picking the file and range to write so that you get
rid of the most pages at the end of LRU but I'm not sure it's worth the CPU
cycles. Does this sound reasonable to you?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
