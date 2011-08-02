Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 060046B0169
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 07:21:53 -0400 (EDT)
Date: Tue, 2 Aug 2011 12:21:46 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/8] mm: vmscan: Do not writeback filesystem pages in
 direct reclaim
Message-ID: <20110802112146.GD10436@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <1311265730-5324-2-git-send-email-mgorman@suse.de>
 <20110731150606.GB1735@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110731150606.GB1735@barrios-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>

On Mon, Aug 01, 2011 at 12:06:06AM +0900, Minchan Kim wrote:
> On Thu, Jul 21, 2011 at 05:28:43PM +0100, Mel Gorman wrote:
> > From: Mel Gorman <mel@csn.ul.ie>
> > 
> > When kswapd is failing to keep zones above the min watermark, a process
> > will enter direct reclaim in the same manner kswapd does. If a dirty
> > page is encountered during the scan, this page is written to backing
> > storage using mapping->writepage.
> > 
> > This causes two problems. First, it can result in very deep call
> > stacks, particularly if the target storage or filesystem are complex.
> > Some filesystems ignore write requests from direct reclaim as a result.
> > The second is that a single-page flush is inefficient in terms of IO.
> > While there is an expectation that the elevator will merge requests,
> > this does not always happen. Quoting Christoph Hellwig;
> > 
> > 	The elevator has a relatively small window it can operate on,
> > 	and can never fix up a bad large scale writeback pattern.
> > 
> > This patch prevents direct reclaim writing back filesystem pages by
> > checking if current is kswapd. Anonymous pages are still written to
> > swap as there is not the equivalent of a flusher thread for anonymous
> > pages. If the dirty pages cannot be written back, they are placed
> > back on the LRU lists. There is now a direct dependency on dirty page
> > balancing to prevent too many pages in the system being dirtied which
> > would prevent reclaim making forward progress.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 

Thanks

> Nitpick.
> We can change description of should_reclaim_stall.
> 
> "Returns true if the caller should wait to clean dirty/writeback pages"
> ->
> "Returns true if direct reclaimer should wait to clean writeback pages"
> 

Not a nitpick. At least one check for RECLAIM_MODE_SYNC is no longer
reachable. I've added a new patch that updates the comment and has
synchronous direct reclaim wait on pages under writeback.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
