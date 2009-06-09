Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3E6C16B0055
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 07:32:41 -0400 (EDT)
Date: Tue, 9 Jun 2009 20:08:02 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] Properly account for the number of page cache
	pages zone_reclaim() can reclaim
Message-ID: <20090609120802.GA5589@localhost>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-3-git-send-email-mel@csn.ul.ie> <20090609022549.GB6740@localhost> <20090609082728.GF18380@csn.ul.ie> <20090609084550.GB7108@localhost> <20090609104809.GQ18380@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090609104809.GQ18380@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "linuxram@us.ibm.com" <linuxram@us.ibm.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 06:48:10PM +0800, Mel Gorman wrote:
> On Tue, Jun 09, 2009 at 04:45:50PM +0800, Wu Fengguang wrote:
> > On Tue, Jun 09, 2009 at 04:27:29PM +0800, Mel Gorman wrote:
> > > On Tue, Jun 09, 2009 at 10:25:49AM +0800, Wu Fengguang wrote:
> > > > On Mon, Jun 08, 2009 at 09:01:29PM +0800, Mel Gorman wrote:
> > > > > On NUMA machines, the administrator can configure zone_relcaim_mode that
> > > > > is a more targetted form of direct reclaim. On machines with large NUMA
> > > > > distances for example, a zone_reclaim_mode defaults to 1 meaning that clean
> > > > > unmapped pages will be reclaimed if the zone watermarks are not being met.
> > > > > 
> > > > > There is a heuristic that determines if the scan is worthwhile but the
> > > > > problem is that the heuristic is not being properly applied and is basically
> > > > > assuming zone_reclaim_mode is 1 if it is enabled.
> > > > > 
> > > > > This patch makes zone_reclaim() makes a better attempt at working out how
> > > > > many pages it might be able to reclaim given the current reclaim_mode. If it
> > > > > cannot clean pages, then NR_FILE_DIRTY number of pages are not candidates. If
> > > > > it cannot swap, then NR_FILE_MAPPED are not. This indirectly addresses tmpfs
> > > > > as those pages tend to be dirty as they are not cleaned by pdflush or sync.
> > > > 
> > > > No, tmpfs pages are not accounted in NR_FILE_DIRTY because of the
> > > > BDI_CAP_NO_ACCT_AND_WRITEBACK bits.
> > > > 
> > > 
> > > Ok, that explains why the dirty page count was not as high as I was
> > > expecting. Thanks.
> > > 
> > > > > The ideal would be that the number of tmpfs pages would also be known
> > > > > and account for like NR_FILE_MAPPED as swap is required to discard them.
> > > > > A means of working this out quickly was not obvious but a comment is added
> > > > > noting the problem.
> > > > 
> > > > I'd rather prefer it be accounted separately than to muck up NR_FILE_MAPPED :)
> > > > 
> > > 
> > > Maybe I used a poor choice of words. What I meant was that the ideal would
> > > be we had a separate count for tmpfs pages. As tmpfs pages and mapped pages
> > > both have to be unmapped and potentially, they are "like" each other with
> > > respect to the zone_reclaim_mode and how it behaves. We would end up
> > > with something like
> > > 
> > > 	pagecache_reclaimable -= zone_page_state(zone, NR_FILE_MAPPED);
> > > 	pagecache_reclaimable -= zone_page_state(zone, NR_FILE_TMPFS);
> > 
> > OK. But tmpfs pages may be mapped, so there will be double counting.
> > We must at least make sure pagecache_reclaimable won't get underflowed.
> 
> True. What vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
> does might be better overall.

Yup.

> > (Or make another LRU list for tmpfs pages?)
> > 
> 
> Another LRU won't help the accounting and will changes too significantly
> how reclaim works.

OK.

> > > > > +	int pagecache_reclaimable;
> > > > > +
> > > > > +	/*
> > > > > +	 * Work out how many page cache pages we can reclaim in this mode.
> > > > > +	 *
> > > > > +	 * NOTE: Ideally, tmpfs pages would be accounted as if they were
> > > > > +	 *       NR_FILE_MAPPED as swap is required to discard those
> > > > > +	 *       pages even when they are clean. However, there is no
> > > > > +	 *       way of quickly identifying the number of tmpfs pages
> > > > > +	 */
> > > > 
> > > > So can you remove the note on NR_FILE_MAPPED?
> > > > 
> > > 
> > > Why would I remove the note? I can alter the wording but the intention is
> > > to show we cannot count the number of tmpfs pages quickly and it would be
> > > nice if we could. Maybe this is clearer?
> > > 
> > > Note: Ideally tmpfs pages would be accounted for as NR_FILE_TMPFS or
> > > 	similar and treated similar to NR_FILE_MAPPED as both require
> > > 	unmapping from page tables and potentially swap to reclaim.
> > > 	However, no such counter exists.
> > 
> > That's better. Thanks.
> > 
> > > > > +	pagecache_reclaimable = zone_page_state(zone, NR_FILE_PAGES);
> > > > > +	if (!(zone_reclaim_mode & RECLAIM_WRITE))
> > > > > +		pagecache_reclaimable -= zone_page_state(zone, NR_FILE_DIRTY);
> > > > 
> > > > > +	if (!(zone_reclaim_mode & RECLAIM_SWAP))
> > > > > +		pagecache_reclaimable -= zone_page_state(zone, NR_FILE_MAPPED);
> > > > 
> > > > So the "if" can be removed because NR_FILE_MAPPED is not related to swapping?
> > > > 
> > > 
> > > It's partially related with respect to what zone_reclaim() is doing.
> > > Once something is mapped, we need RECLAIM_SWAP set on the
> > > zone_reclaim_mode to do anything useful with them.
> > 
> > You are referring to mapped anonymous/tmpfs pages? But I mean
> > NR_FILE_MAPPED pages won't goto swap when unmapped.
> > 
> 
> Not all of them. But some of them backed by real files will be discarded
> if clean at the next pass

Right.

Thanks,
Fengguang

> > > > >  	/*
> > > > >  	 * Zone reclaim reclaims unmapped file backed pages and
> > > > > @@ -2391,8 +2406,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> > > > >  	 * if less than a specified percentage of the zone is used by
> > > > >  	 * unmapped file backed pages.
> > > > >  	 */
> > > > > -	if (zone_page_state(zone, NR_FILE_PAGES) -
> > > > > -	    zone_page_state(zone, NR_FILE_MAPPED) <= zone->min_unmapped_pages
> > > > > +	if (pagecache_reclaimable <= zone->min_unmapped_pages
> > > > >  	    && zone_page_state(zone, NR_SLAB_RECLAIMABLE)
> > > > >  			<= zone->min_slab_pages)
> > > > >  		return 0;
> > > > > -- 
> > > > > 1.5.6.5
> > > > 
> > > 
> > > -- 
> > > Mel Gorman
> > > Part-time Phd Student                          Linux Technology Center
> > > University of Limerick                         IBM Dublin Software Lab
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
