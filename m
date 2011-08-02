Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D832B6B0169
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 07:25:24 -0400 (EDT)
Date: Tue, 2 Aug 2011 12:25:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 7/8] mm: vmscan: Immediately reclaim end-of-LRU dirty
 pages when writeback completes
Message-ID: <20110802112518.GE10436@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <1311265730-5324-8-git-send-email-mgorman@suse.de>
 <1311339228.27400.34.camel@twins>
 <20110722132319.GX5349@suse.de>
 <20110731152401.GE1735@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110731152401.GE1735@barrios-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>

On Mon, Aug 01, 2011 at 12:24:01AM +0900, Minchan Kim wrote:
> On Fri, Jul 22, 2011 at 02:23:19PM +0100, Mel Gorman wrote:
> > On Fri, Jul 22, 2011 at 02:53:48PM +0200, Peter Zijlstra wrote:
> > > On Thu, 2011-07-21 at 17:28 +0100, Mel Gorman wrote:
> > > > When direct reclaim encounters a dirty page, it gets recycled around
> > > > the LRU for another cycle. This patch marks the page PageReclaim
> > > > similar to deactivate_page() so that the page gets reclaimed almost
> > > > immediately after the page gets cleaned. This is to avoid reclaiming
> > > > clean pages that are younger than a dirty page encountered at the
> > > > end of the LRU that might have been something like a use-once page.
> > > > 
> > > 
> > > > @@ -834,7 +834,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > > >  			 */
> > > >  			if (page_is_file_cache(page) &&
> > > >  					(!current_is_kswapd() || priority >= DEF_PRIORITY - 2)) {
> > > > -				inc_zone_page_state(page, NR_VMSCAN_WRITE_SKIP);
> > > > +				/*
> > > > +				 * Immediately reclaim when written back.
> > > > +				 * Similar in principal to deactivate_page()
> > > > +				 * except we already have the page isolated
> > > > +				 * and know it's dirty
> > > > +				 */
> > > > +				inc_zone_page_state(page, NR_VMSCAN_INVALIDATE);
> > > > +				SetPageReclaim(page);
> > > > +
> > > 
> > > I find the invalidate name somewhat confusing. It makes me think we'll
> > > drop the page without writeback, like invalidatepage().
> > 
> > I wasn't that happy with it either to be honest but didn't think of a
> > better one at the time. nr_reclaim_deferred?
> 
> How about "NR_VMSCAN_IMMEDIATE_RECLAIM" like comment rotate_reclaimable_page?
> 

Yeah, I guess. I find it a little misleading because the reclaim does
not happen immediately at the time the counter is incremented but it's
better than "invalidate".

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
