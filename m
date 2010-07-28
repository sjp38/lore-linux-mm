Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CB5336007FC
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 07:30:43 -0400 (EDT)
Date: Wed, 28 Jul 2010 12:30:26 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 9/9] writeback: Prioritise dirty inodes encountered by
	reclaim for background flushing
Message-ID: <20100728113026.GH5300@csn.ul.ie>
References: <1280312843-11789-1-git-send-email-mel@csn.ul.ie> <1280312843-11789-10-git-send-email-mel@csn.ul.ie> <20100728110807.GB31360@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100728110807.GB31360@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2010 at 07:08:07AM -0400, Christoph Hellwig wrote:
> On Wed, Jul 28, 2010 at 11:27:23AM +0100, Mel Gorman wrote:
> > It is preferable that as few dirty pages are dispatched for cleaning from
> > the page reclaim path. When dirty pages are encountered by page reclaim,
> > this patch marks the inodes that they should be dispatched immediately. When
> > the background flusher runs, it moves such inodes immediately to the dispatch
> > queue regardless of inode age.
> 
> Thus whole thing looks rather hacky to me.  Does it really give a large
> enough benefit to be worth all the hacks?
> 

Not enough benefit in enough situations - at least based on my tests but
it's possible my systems are just not large enough to detect anything.
The figures in the leader show that the patch does reduce the number of dirty
pages encountered by page reclaim in many cases but only in one instance,
PPC64 running sysbench, was it a really big difference.

I included this patch because Wu suggested that that page reclaim
waking threads to clean X pages depends on luck to get the right pages.
He suggested prioritising inodes with known dirty LRU pages and this was a
first prototype. It only takes inodes into account and the figures didn't
really hold up on the hardware I was using. He suggested ways that page
offset could be taken into account with some invasiveness so I'm inclined
to drop this patch for now because better ideas exist.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
