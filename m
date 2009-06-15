Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB336B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 06:05:41 -0400 (EDT)
Date: Mon, 15 Jun 2009 11:05:45 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] Properly account for the number of page cache
	pages zone_reclaim() can reclaim
Message-ID: <20090615100545.GB23198@csn.ul.ie>
References: <20090611203349.6D68.A69D9226@jp.fujitsu.com> <20090612101735.GA14498@csn.ul.ie> <20090615134406.B422.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090615134406.B422.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 01:51:16PM +0900, KOSAKI Motohiro wrote:
> > > > +/* Work out how many page cache pages we can reclaim in this reclaim_mode */
> > > > +static long zone_pagecache_reclaimable(struct zone *zone)
> > > > +{
> > > > +	long nr_pagecache_reclaimable;
> > > > +	long delta = 0;
> > > > +
> > > > +	/*
> > > > +	 * If RECLAIM_SWAP is set, then all file pages are considered
> > > > +	 * potentially reclaimable. Otherwise, we have to worry about
> > > > +	 * pages like swapcache and zone_unmapped_file_pages() provides
> > > > +	 * a better estimate
> > > > +	 */
> > > > +	if (zone_reclaim_mode & RECLAIM_SWAP)
> > > > +		nr_pagecache_reclaimable = zone_page_state(zone, NR_FILE_PAGES);
> > > > +	else
> > > > +		nr_pagecache_reclaimable = zone_unmapped_file_pages(zone);
> > > > +
> > > > +	/* If we can't clean pages, remove dirty pages from consideration */
> > > > +	if (!(zone_reclaim_mode & RECLAIM_WRITE))
> > > > +		delta += zone_page_state(zone, NR_FILE_DIRTY);
> > > 
> > > no use delta?
> > > 
> > 
> > delta was used twice in an interim version when it was possible to overflow
> > the counter. I left it as is because if another counter is added that must
> > be subtracted from nr_pagecache_reclaimable, it'll be tidier to patch in if
> > delta was there. I can take it out if you prefer.
> 
> Honestly, I'm confusing now.
> 
> your last version have following usage of "delta"
> 
> 	/* Beware of double accounting */
> 	if (delta < nr_pagecache_reclaimable)
> 		nr_pagecache_reclaimable -= delta;
> 
> but current your patch don't have it.
> IOW, nobody use delta variable. I'm not sure about you forget to
> accurate to nr_pagecache_reclaimable or forget to remove 
> "delta += zone_page_state(zone, NR_FILE_DIRTY);" line.
> 
> Or, Am I missing anything?
> Now, I don't oppose this change. I only hope to clarify your intention.
> 

You're not missing anything. I accidentally removed where delta was
being used. Sorry.

> 
> 
> > > > -	nr_unmapped_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
> > > > -				 zone_page_state(zone, NR_ACTIVE_FILE) -
> > > > -				 zone_page_state(zone, NR_FILE_MAPPED);
> > > > -
> > > > -	if (nr_unmapped_file_pages > zone->min_unmapped_pages) {
> > > > +	if (zone_pagecache_reclaimable(zone) > zone->min_unmapped_pages) {
> > > 
> > > Documentation/sysctl/vm.txt says
> > > =============================================================
> > > 
> > > min_unmapped_ratio:
> > > 
> > > This is available only on NUMA kernels.
> > > 
> > > A percentage of the total pages in each zone.  Zone reclaim will only
> > > occur if more than this percentage of pages are file backed and unmapped.
> > > This is to insure that a minimal amount of local pages is still available for
> > > file I/O even if the node is overallocated.
> > > 
> > > The default is 1 percent.
> > > 
> > > ==============================================================
> > > 
> > > but your code condider more addional thing. Can you please change document too?
> > > 
> > 
> > How does this look?
> > 
> > ==============================================================
> > min_unmapped_ratio:
> > 
> > This is available only on NUMA kernels.
> > 
> > This is a percentage of the total pages in each zone. Zone reclaim will only
> > occur if more than this percentage are in a state that zone_reclaim_mode
> > allows to be reclaimed.
> > 
> > If zone_reclaim_mode has the value 4 OR'd, then the percentage is compared
> > against all file-backed unmapped pages including swapcache pages and tmpfs
> > files. Otherwise, only unmapped pages backed by normal files but not tmpfs
> > files and similar are considered.
> > 
> > The default is 1 percent.
> > ==============================================================
> 
> Great! thanks.
> 

I'll prepare two patches after reviewing mmotm. The first will use delta
properly and the second will fix the documentation. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
