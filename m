Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CE15B6B004D
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 21:28:35 -0400 (EDT)
Date: Thu, 11 Jun 2009 09:29:13 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/4] Properly account for the number of page cache
	pages zone_reclaim() can reclaim
Message-ID: <20090611012913.GA21619@localhost>
References: <1244566904-31470-1-git-send-email-mel@csn.ul.ie> <1244566904-31470-2-git-send-email-mel@csn.ul.ie> <20090610011939.GA5603@localhost> <20090610103152.GG25943@csn.ul.ie> <20090610115944.GB5657@localhost> <20090610134134.GN25943@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090610134134.GN25943@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "linuxram@us.ibm.com" <linuxram@us.ibm.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 10, 2009 at 09:41:34PM +0800, Mel Gorman wrote:
> On Wed, Jun 10, 2009 at 07:59:44PM +0800, Wu Fengguang wrote:
> > On Wed, Jun 10, 2009 at 06:31:53PM +0800, Mel Gorman wrote:
> > > On Wed, Jun 10, 2009 at 09:19:39AM +0800, Wu Fengguang wrote:
> > > > On Wed, Jun 10, 2009 at 01:01:41AM +0800, Mel Gorman wrote:
> > > > > On NUMA machines, the administrator can configure zone_reclaim_mode that
> > > > > is a more targetted form of direct reclaim. On machines with large NUMA
> > > > > distances for example, a zone_reclaim_mode defaults to 1 meaning that clean
> > > > > unmapped pages will be reclaimed if the zone watermarks are not being met.
> > > > > 
> > > > > There is a heuristic that determines if the scan is worthwhile but the
> > > > > problem is that the heuristic is not being properly applied and is basically
> > > > > assuming zone_reclaim_mode is 1 if it is enabled.
> > > > > 
> > > > > Historically, once enabled it was depending on NR_FILE_PAGES which may
> > > > > include swapcache pages that the reclaim_mode cannot deal with.  Patch
> > > > > vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch by
> > > > > Kosaki Motohiro noted that zone_page_state(zone, NR_FILE_PAGES) included
> > > > > pages that were not file-backed such as swapcache and made a calculation
> > > > > based on the inactive, active and mapped files. This is far superior
> > > > > when zone_reclaim==1 but if RECLAIM_SWAP is set, then NR_FILE_PAGES is a
> > > > > reasonable starting figure.
> > > > > 
> > > > > This patch alters how zone_reclaim() works out how many pages it might be
> > > > > able to reclaim given the current reclaim_mode. If RECLAIM_SWAP is set
> > > > > in the reclaim_mode it will either consider NR_FILE_PAGES as potential
> > > > > candidates or else use NR_{IN}ACTIVE}_PAGES-NR_FILE_MAPPED to discount
> > > > > swapcache and other non-file-backed pages.  If RECLAIM_WRITE is not set,
> > > > > then NR_FILE_DIRTY number of pages are not candidates. If RECLAIM_SWAP is
> > > > > not set, then NR_FILE_MAPPED are not.
> > > > > 
> > > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > > > Acked-by: Christoph Lameter <cl@linux-foundation.org>
> > > > > ---
> > > > >  mm/vmscan.c |   52 ++++++++++++++++++++++++++++++++++++++--------------
> > > > >  1 files changed, 38 insertions(+), 14 deletions(-)
> > > > > 
> > > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > > index 2ddcfc8..2bfc76e 100644
> > > > > --- a/mm/vmscan.c
> > > > > +++ b/mm/vmscan.c
> > > > > @@ -2333,6 +2333,41 @@ int sysctl_min_unmapped_ratio = 1;
> > > > >   */
> > > > >  int sysctl_min_slab_ratio = 5;
> > > > >  
> > > > > +static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
> > > > > +{
> > > > > +	return zone_page_state(zone, NR_INACTIVE_FILE) +
> > > > > +		zone_page_state(zone, NR_ACTIVE_FILE) -
> > > > > +		zone_page_state(zone, NR_FILE_MAPPED);
> > > > 
> > > > This may underflow if too many tmpfs pages are mapped.
> > > > 
> > > 
> > > You're right. This is also a bug now in mmotm for patch
> > > vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch which
> > > is where I took this code out of and didn't think deeply enough about.
> > > Well spotted.
> > > 
> > > Should this be something like?
> > > 
> > > static unsigned long zone_unmapped_file_pages(struct zone *zone)
> > > {
> > > 	unsigned long file_mapped = zone_page_state(zone, NR_FILE_MAPPED);
> > > 	unsigned long file_lru = zone_page_state(zone, NR_INACTIVE_FILE)
> > > 			zone_page_state(zone, NR_ACTIVE_FILE);
> > > 
> > > 	return (file_lru > file_mapped) ? (file_lru - file_mapped) : 0;
> > > }
> > > 
> > > ?
> > > 
> > > If that returns 0, it does mean that there are very few pages that the
> > > current reclaim_mode is going to be able to deal with so even if the
> > > count is not perfect, it should be good enough for what we need it for.
> > 
> > Agreed. We opt to give up direct zone reclaim than to risk busy looping ;)
> > 
> 
> Yep. Those busy loops doth chew up the CPU time, heat the planet and
> wear out Ye Olde Bugzilla with the wailing of unhappy users :)
> 
> > > > > +}
> > > > > +
> > > > > +/* Work out how many page cache pages we can reclaim in this reclaim_mode */
> > > > > +static inline long zone_pagecache_reclaimable(struct zone *zone)
> > > > > +{
> > > > > +	long nr_pagecache_reclaimable;
> > > > > +	long delta = 0;
> > > > > +
> > > > > +	/*
> > > > > +	 * If RECLAIM_SWAP is set, then all file pages are considered
> > > > > +	 * potentially reclaimable. Otherwise, we have to worry about
> > > > > +	 * pages like swapcache and zone_unmapped_file_pages() provides
> > > > > +	 * a better estimate
> > > > > +	 */
> > > > > +	if (zone_reclaim_mode & RECLAIM_SWAP)
> > > > > +		nr_pagecache_reclaimable = zone_page_state(zone, NR_FILE_PAGES);
> > > > > +	else
> > > > > +		nr_pagecache_reclaimable = zone_unmapped_file_pages(zone);
> > > > > +
> > > > > +	/* If we can't clean pages, remove dirty pages from consideration */
> > > > > +	if (!(zone_reclaim_mode & RECLAIM_WRITE))
> > > > > +		delta += zone_page_state(zone, NR_FILE_DIRTY);
> > > > > +
> > > > > +	/* Beware of double accounting */
> > > > 
> > > > The double accounting happens for NR_FILE_MAPPED but not
> > > > NR_FILE_DIRTY(dirty tmpfs pages won't be accounted),
> > > 
> > > I should have taken that out. In an interim version, delta was altered
> > > more than once in a way that could have caused underflow.
> > > 
> > > > so this comment
> > > > is more suitable for zone_unmapped_file_pages(). But the double
> > > > accounting does affects this abstraction. So a more reasonable
> > > > sequence could be to first substract NR_FILE_DIRTY and then
> > > > conditionally substract NR_FILE_MAPPED?
> > > 
> > > The end result is the same I believe and I prefer having the
> > > zone_unmapped_file_pages() doing just that and nothing else because it's
> > > in line with what zone_lru_pages() does.
> > 
> > OK.
> > 
> > > > Or better to introduce a new counter NR_TMPFS_MAPPED to fix this mess?
> > > > 
> > > 
> > > I considered such a counter and dismissed it but maybe it merits wider discussion.
> > > 
> > > My problem with it is that it would affect the pagecache add/remove hot paths
> > > and a few other sites and increase the amount of accouting we do within a
> > > zone. It seemed unjustified to help a seldom executed slow path that only
> > > runs on NUMA.
> > 
> > We are not talking about NR_TMPFS_PAGES, but NR_TMPFS_MAPPED :)
> > 
> > We only need to account it in page_add_file_rmap() and page_remove_rmap(),
> > I don't think they are too hot paths. And the relative cost is low enough.
> > 
> > It will look like this.
> > 
> 
> Ok, you're right, that is much simplier than what I had in mind. I was fixated
> on accounting for TMPFS pages. I think this patch has definite possibilities
> and would help us with the tmpfs problem. If the tests come back "failed",
> I'll be adding taking this logic and seeing can it be made work.

OK, thank you.

> What about ramfs pages though? They have similar problems to tmpfs but are
> not swap-backed, right?

We don't care ramfs pages because they are unevictable :)

Thanks,
Fengguang

> > ---
> >  include/linux/mmzone.h |    1 +
> >  mm/rmap.c              |    4 ++++
> >  2 files changed, 5 insertions(+)
> > 
> > --- linux.orig/include/linux/mmzone.h
> > +++ linux/include/linux/mmzone.h
> > @@ -99,6 +99,7 @@ enum zone_stat_item {
> >  	NR_VMSCAN_WRITE,
> >  	/* Second 128 byte cacheline */
> >  	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
> > +	NR_TMPFS_MAPPED,
> >  #ifdef CONFIG_NUMA
> >  	NUMA_HIT,		/* allocated in intended node */
> >  	NUMA_MISS,		/* allocated in non intended node */
> > --- linux.orig/mm/rmap.c
> > +++ linux/mm/rmap.c
> > @@ -844,6 +844,8 @@ void page_add_file_rmap(struct page *pag
> >  {
> >  	if (atomic_inc_and_test(&page->_mapcount)) {
> >  		__inc_zone_page_state(page, NR_FILE_MAPPED);
> > +		if (PageSwapBacked(page))
> > +			__inc_zone_page_state(page, NR_TMPFS_MAPPED);
> >  		mem_cgroup_update_mapped_file_stat(page, 1);
> >  	}
> >  }
> > @@ -894,6 +896,8 @@ void page_remove_rmap(struct page *page)
> >  			mem_cgroup_uncharge_page(page);
> >  		__dec_zone_page_state(page,
> >  			PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
> > +		if (!PageAnon(page) && PageSwapBacked(page))
> > +			__dec_zone_page_state(page, NR_TMPFS_MAPPED);
> >  		mem_cgroup_update_mapped_file_stat(page, -1);
> >  		/*
> >  		 * It would be tidy to reset the PageAnon mapping here,
> > 
> 
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
