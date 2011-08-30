Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id AC0A8900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 09:49:13 -0400 (EDT)
Date: Tue, 30 Aug 2011 14:49:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/7] mm: vmscan: Throttle reclaim if encountering too
 many dirty pages under writeback
Message-ID: <20110830134900.GC14369@suse.de>
References: <1312973240-32576-1-git-send-email-mgorman@suse.de>
 <1312973240-32576-7-git-send-email-mgorman@suse.de>
 <20110818165428.4f01a1b9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110818165428.4f01a1b9.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Aug 18, 2011 at 04:54:28PM -0700, Andrew Morton wrote:
> On Wed, 10 Aug 2011 11:47:19 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > The percentage that must be in writeback depends on the priority. At
> > default priority, all of them must be dirty. At DEF_PRIORITY-1, 50%
> > of them must be, DEF_PRIORITY-2, 25% etc. i.e. as pressure increases
> > the greater the likelihood the process will get throttled to allow
> > the flusher threads to make some progress.
> 
> It'd be nice if the code comment were to capture this piece of implicit
> arithmetic.  After all, it's a magic number and magic numbers should
> stick out like sore thumbs.
> 
> And.. how do we know that the chosen magic numbers were optimal?

Good question. The short answer "we don't know but it's not important
to get this particular decision perfect because the real throttling
should happen earlier".

Now the long answer;

For the value to be used, pages under writeback must be reaching the
end of the LRU. This implies that the rate of page consumption is
exceeding the writing speed of the backing storage. Regardless of
what decision is made, the rate of page allocation must be reduced
as the the system is already in a sub-optimal state of requiring more
resources than are available.

The values are based on a simple expontial backoff function with useful
ranges of DEF_PRIORITY to DEF_PRIORITY-2 which is the point where
"kswapd is getting into trouble". However, any decreasing function
within that range is sufficient because while there might be an optimal
choice, it makes little difference overall as the decision is made
too late with no guarantee the process doing the dirtying is throttled.

The truly optimal decision is to throttle writers to slow storage
earlier in balance_dirty_pages() and have dirty_ratio scaled
proportional to the estimate writeback speed of the underlying storage
but we do not have that yet. This patches throttling decision is
fairly close to the best we can do from reclaim context.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
