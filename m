Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 57BB96B016A
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 05:53:33 -0400 (EDT)
Date: Wed, 31 Aug 2011 10:53:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/7] mm: vmscan: Throttle reclaim if encountering too
 many dirty pages under writeback
Message-ID: <20110831095326.GD14369@suse.de>
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
> arithmetic.

How about this?

==== CUT HERE ====
mm: vmscan: Throttle reclaim if encountering too many dirty pages under writeback -fix1

This patch expands on a comment on how we throttle from reclaim context.
It should be merged with
mm-vmscan-throttle-reclaim-if-encountering-too-many-dirty-pages-under-writeback.patch

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   26 +++++++++++++++++++++-----
 1 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 33882a3..5ff3e26 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1491,11 +1491,27 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
 
 	/*
-	 * If we have encountered a high number of dirty pages under writeback
-	 * then we are reaching the end of the LRU too quickly and global
-	 * limits are not enough to throttle processes due to the page
-	 * distribution throughout zones. Scale the number of dirty pages that
-	 * must be under writeback before being throttled to priority.
+	 * If reclaim is isolating dirty pages under writeback, it implies
+	 * that the long-lived page allocation rate is exceeding the page
+	 * laundering rate. Either the global limits are not being effective
+	 * at throttling processes due to the page distribution throughout
+	 * zones or there is heavy usage of a slow backing device. The
+	 * only option is to throttle from reclaim context which is not ideal
+	 * as there is no guarantee the dirtying process is throttled in the
+	 * same way balance_dirty_pages() manages.
+	 *
+	 * This scales the number of dirty pages that must be under writeback
+	 * before throttling depending on priority. It is a simple backoff
+	 * function that has the most effect in the range DEF_PRIORITY to
+	 * DEF_PRIORITY-2 which is the priority reclaim is considered to be
+	 * in trouble and reclaim is considered to be in trouble.
+	 *
+	 * DEF_PRIORITY   100% isolated pages must be PageWriteback to throttle
+	 * DEF_PRIORITY-1  50% must be PageWriteback
+	 * DEF_PRIORITY-2  25% must be PageWriteback, kswapd in trouble
+	 * ...
+	 * DEF_PRIORITY-6 For SWAP_CLUSTER_MAX isolated pages, throttle if any
+	 *                     isolated page is PageWriteback
 	 */
 	if (nr_writeback && nr_writeback >= (nr_taken >> (DEF_PRIORITY-priority)))
 		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
