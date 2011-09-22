Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DBFCA9000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 06:54:11 -0400 (EDT)
Date: Thu, 22 Sep 2011 11:54:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/4] mm: exclude reserved pages from dirtyable memory
Message-ID: <20110922105400.GL4849@suse.de>
References: <1316526315-16801-1-git-send-email-jweiner@redhat.com>
 <1316526315-16801-2-git-send-email-jweiner@redhat.com>
 <20110921140423.GG4849@suse.de>
 <20110921150328.GJ4849@suse.de>
 <20110922090326.GB29046@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110922090326.GB29046@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Sep 22, 2011 at 11:03:26AM +0200, Johannes Weiner wrote:
> On Wed, Sep 21, 2011 at 04:03:28PM +0100, Mel Gorman wrote:
> > On Wed, Sep 21, 2011 at 03:04:23PM +0100, Mel Gorman wrote:
> > > On Tue, Sep 20, 2011 at 03:45:12PM +0200, Johannes Weiner wrote:
> > > > The amount of dirtyable pages should not include the total number of
> > > > free pages: there is a number of reserved pages that the page
> > > > allocator and kswapd always try to keep free.
> > > > 
> > > > The closer (reclaimable pages - dirty pages) is to the number of
> > > > reserved pages, the more likely it becomes for reclaim to run into
> > > > dirty pages:
> > > > 
> > > >        +----------+ ---
> > > >        |   anon   |  |
> > > >        +----------+  |
> > > >        |          |  |
> > > >        |          |  -- dirty limit new    -- flusher new
> > > >        |   file   |  |                     |
> > > >        |          |  |                     |
> > > >        |          |  -- dirty limit old    -- flusher old
> > > >        |          |                        |
> > > >        +----------+                       --- reclaim
> > > >        | reserved |
> > > >        +----------+
> > > >        |  kernel  |
> > > >        +----------+
> > > > 
> > > > Not treating reserved pages as dirtyable on a global level is only a
> > > > conceptual fix.  In reality, dirty pages are not distributed equally
> > > > across zones and reclaim runs into dirty pages on a regular basis.
> > > > 
> > > > But it is important to get this right before tackling the problem on a
> > > > per-zone level, where the distance between reclaim and the dirty pages
> > > > is mostly much smaller in absolute numbers.
> > > > 
> > > > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> > > > ---
> > > >  include/linux/mmzone.h |    1 +
> > > >  mm/page-writeback.c    |    8 +++++---
> > > >  mm/page_alloc.c        |    1 +
> > > >  3 files changed, 7 insertions(+), 3 deletions(-)
> > > > 
> > > > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > > > index 1ed4116..e28f8e0 100644
> > > > --- a/include/linux/mmzone.h
> > > > +++ b/include/linux/mmzone.h
> > > > @@ -316,6 +316,7 @@ struct zone {
> > > >  	 * sysctl_lowmem_reserve_ratio sysctl changes.
> > > >  	 */
> > > >  	unsigned long		lowmem_reserve[MAX_NR_ZONES];
> > > > +	unsigned long		totalreserve_pages;
> > > >  
> > > 
> > > This is nit-picking but totalreserve_pages is a poor name because it's
> > > a per-zone value that is one of the lowmem_reserve[] fields instead
> > > of a total. After this patch, we have zone->totalreserve_pages and
> > > totalreserve_pages but are not related to the same thing.
> > > but they are not the same.
> > 
> > As you correctly pointed out to be on IRC, zone->totalreserve_pages
> > is not the lowmem_reserve because it takes the high_wmark into
> > account. Sorry about that, I should have kept thinking.  The name is
> > still poor though because it does not explain what the value is or
> > what it means.
> > 
> > zone->FOO value needs to be related to lowmem_reserve because this
> > 	is related to balancing zone usage.
> > 
> > zone->FOO value should also be related to the high_wmark because
> > 	this is avoiding writeback from page reclaim
> > 
> > err....... umm... this?
> > 
> > 	/*
> > 	 * When allocating a new page that is expected to be
> > 	 * dirtied soon, the number of free pages and the
> > 	 * dirty_balance reserve are taken into account. The
> > 	 * objective is that the globally allowed number of dirty
> > 	 * pages should be distributed throughout the zones such
> > 	 * that it is very unlikely that page reclaim will call
> > 	 * ->writepage.
> > 	 *
> > 	 * dirty_balance_reserve takes both lowmem_reserve and
> > 	 * the high watermark into account. The lowmem_reserve
> > 	 * is taken into account because we don't want the
> > 	 * distribution of dirty pages to unnecessarily increase
> > 	 * lowmem pressure. The watermark is taken into account
> > 	 * because it's correlated with when kswapd wakes up
> > 	 * and how long it stays awake.
> > 	 */
> > 	unsigned long		dirty_balance_reserve.
> 
> Yes, that's much better, thanks.
> 
> I assume this is meant the same for both the zone and the global level
> and we should not mess with totalreserve_pages in either case?

Yes. I'd even suggest changing the name of totalreserve_pages to make
it clear it is related to overcommit rather than pfmemalloc, dirty
or any other reserve. i.e. s/totalreserve_pages/overcommit_reserve/

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
