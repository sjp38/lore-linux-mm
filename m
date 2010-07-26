Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CB4496B02A9
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 05:26:34 -0400 (EDT)
Date: Mon, 26 Jul 2010 10:26:16 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 8/8] vmscan: Kick flusher threads to clean pages when
	reclaim is encountering dirty pages
Message-ID: <20100726092616.GG5300@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-9-git-send-email-mel@csn.ul.ie> <20100726072832.GB13076@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100726072832.GB13076@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 03:28:32PM +0800, Wu Fengguang wrote:
> On Mon, Jul 19, 2010 at 09:11:30PM +0800, Mel Gorman wrote:
> > There are a number of cases where pages get cleaned but two of concern
> > to this patch are;
> >   o When dirtying pages, processes may be throttled to clean pages if
> >     dirty_ratio is not met.
> >   o Pages belonging to inodes dirtied longer than
> >     dirty_writeback_centisecs get cleaned.
> > 
> > The problem for reclaim is that dirty pages can reach the end of the LRU
> > if pages are being dirtied slowly so that neither the throttling cleans
> > them or a flusher thread waking periodically.
> > 
> > Background flush is already cleaning old or expired inodes first but the
> > expire time is too far in the future at the time of page reclaim. To mitigate
> > future problems, this patch wakes flusher threads to clean 1.5 times the
> > number of dirty pages encountered by reclaimers. The reasoning is that pages
> > were being dirtied at a roughly constant rate recently so if N dirty pages
> > were encountered in this scan block, we are likely to see roughly N dirty
> > pages again soon so try keep the flusher threads ahead of reclaim.
> > 
> > This is unfortunately very hand-wavy but there is not really a good way of
> > quantifying how bad it is when reclaim encounters dirty pages other than
> > "down with that sort of thing". Similarly, there is not an obvious way of
> > figuring how what percentage of dirty pages are old in terms of LRU-age and
> > should be cleaned. Ideally, the background flushers would only be cleaning
> > pages belonging to the zone being scanned but it's not clear if this would
> > be of benefit (less IO) or not (potentially less efficient IO if an inode
> > is scattered across multiple zones).
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/vmscan.c |   18 +++++++++++-------
> >  1 files changed, 11 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index bc50937..5763719 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -806,6 +806,8 @@ restart_dirty:
> >  		}
> >  
> >  		if (PageDirty(page))  {
> > +			nr_dirty++;
> > +
> >  			/*
> >  			 * If the caller cannot writeback pages, dirty pages
> >  			 * are put on a separate list for cleaning by either
> > @@ -814,7 +816,6 @@ restart_dirty:
> >  			if (!reclaim_can_writeback(sc, page)) {
> >  				list_add(&page->lru, &dirty_pages);
> >  				unlock_page(page);
> > -				nr_dirty++;
> >  				goto keep_dirty;
> >  			}
> >  
> > @@ -933,13 +934,16 @@ keep_dirty:
> >  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
> >  	}
> >  
> > +	/*
> > +	 * If reclaim is encountering dirty pages, it may be because
> > +	 * dirty pages are reaching the end of the LRU even though
> > +	 * the dirty_ratio may be satisified. In this case, wake
> > +	 * flusher threads to pro-actively clean some pages
> > +	 */
> > +	wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty + nr_dirty / 2);
> 
> Ah it's very possible that nr_dirty==0 here! Then you are hitting the
> number of dirty pages down to 0 whether or not pageout() is called.
> 

True, this has been fixed to only wakeup flusher threads when this is
the file LRU, dirty pages have been encountered and the caller has
sc->may_writepage.

> Another minor issue is, the passed (nr_dirty + nr_dirty / 2) is
> normally a small number, much smaller than MAX_WRITEBACK_PAGES.
> The flusher will sync at least MAX_WRITEBACK_PAGES pages, this is good
> for efficiency.
> And it seems good to let the flusher write much more
> than nr_dirty pages to safeguard a reasonable large
> vmscan-head-to-first-dirty-LRU-page margin. So it would be enough to
> update the comments.
> 

Ok, the reasoning had been to flush a number of pages that was related
to the scanning rate but if that is inefficient for the flusher, I'll
use MAX_WRITEBACK_PAGES.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
