Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 69C936B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 06:21:35 -0400 (EDT)
Date: Fri, 12 Jun 2009 11:22:11 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH for mmotm 2/5]
Message-ID: <20090612102211.GB14498@csn.ul.ie>
References: <20090611192600.6D50.A69D9226@jp.fujitsu.com> <20090611111341.GE7302@csn.ul.ie> <20090611204208.6D6B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090611204208.6D6B.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 11, 2009 at 08:50:06PM +0900, KOSAKI Motohiro wrote:
> > On Thu, Jun 11, 2009 at 07:26:48PM +0900, KOSAKI Motohiro wrote:
> > > Changes since Wu's original patch
> > >   - adding vmstat
> > >   - rename NR_TMPFS_MAPPED to NR_SWAP_BACKED_FILE_MAPPED
> > > 
> > > 
> > > ----------------------
> > > Subject: [PATCH] introduce NR_SWAP_BACKED_FILE_MAPPED zone stat
> > 
> > This got lost in the actual subject line.
> > 
> > > Desirable zone reclaim implementaion want to know the number of
> > > file-backed and unmapped pages.
> > > 
> > 
> > There needs to be more justification for this. We need an example
> > failure case that this addresses. For example, Patch 1 of my series was
> > to address the following problem included with the patchset leader
> > 
> > "The reported problem was that malloc() stalled for a long time (minutes
> > in some cases) if a large tmpfs mount was occupying a large percentage of
> > memory overall. The pages did not get cleaned or reclaimed by zone_reclaim()
> > because the zone_reclaim_mode was unsuitable, but the lists are uselessly
> > scanned frequencly making the CPU spin at near 100%."
> > 
> > We should have a similar case.
> > 
> > What "desirable" zone_reclaim() should be spelled out as well. Minimally
> > something like
> > 
> > "For zone_reclaim() to be efficient, it must be able to detect in advance
> > if the LRU scan will reclaim the necessary pages with the limitations of
> > the current zone_reclaim_mode. Otherwise, the CPU usage is increases as
> > zone_reclaim() uselessly scans the LRU list.
> > 
> > The problem with the heuristic is ....
> > 
> > This patch fixes the heuristic by ...."
> > 
> > etc?
> > 
> > I'm not trying to be awkward. I believe I provided similar reasoning
> > with my own patchset.
> 
> You are right. my intention is not actual issue, it only fix
> documentation lie.
> 
> Documentation/sysctl/vm.txt says
> =============================================================
> 
> min_unmapped_ratio:
> 
> This is available only on NUMA kernels.
> 
> A percentage of the total pages in each zone.  Zone reclaim will only
> occur if more than this percentage of pages are file backed and unmapped.
> This is to insure that a minimal amount of local pages is still available for
> file I/O even if the node is overallocated.
> 
> The default is 1 percent.
> ==============================================================
> 
> but actual code don't account "percentage of file backed and unmapped".
> Administrator can't imazine current implementation form this documentation.
> 

That's a good point. I've suggested alternative documentation in another
thread.

> Plus, I don't think this patch is too messy. thus I did decide to make
> this fix.
> 
> if anyone provide good documentation fix, my worry will vanish.
> 

Hopefully your worry has vanished.

While I have no objection to the patch as such, I would like to know
what it's fixing. Believe me, if the scan-heuristic breaks again, this
patch would be one of the first things I considered as a fix :/

> 
> 
> > > Thus, we need to know number of swap-backed mapped pages for
> > > calculate above number.
> > > 
> > > 
> > > Cc: Mel Gorman <mel@csn.ul.ie>
> > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > ---
> > >  include/linux/mmzone.h |    2 ++
> > >  mm/rmap.c              |    7 +++++++
> > >  mm/vmstat.c            |    1 +
> > >  3 files changed, 10 insertions(+)
> > > 
> > > Index: b/include/linux/mmzone.h
> > > ===================================================================
> > > --- a/include/linux/mmzone.h
> > > +++ b/include/linux/mmzone.h
> > > @@ -88,6 +88,8 @@ enum zone_stat_item {
> > >  	NR_ANON_PAGES,	/* Mapped anonymous pages */
> > >  	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
> > >  			   only modified from process context */
> > > +	NR_SWAP_BACKED_FILE_MAPPED, /* Similar to NR_FILE_MAPPED. but
> > > +				       only account swap-backed pages */
> > >  	NR_FILE_PAGES,
> > >  	NR_FILE_DIRTY,
> > >  	NR_WRITEBACK,
> > > Index: b/mm/rmap.c
> > > ===================================================================
> > > --- a/mm/rmap.c
> > > +++ b/mm/rmap.c
> > > @@ -829,6 +829,10 @@ void page_add_file_rmap(struct page *pag
> > >  {
> > >  	if (atomic_inc_and_test(&page->_mapcount)) {
> > >  		__inc_zone_page_state(page, NR_FILE_MAPPED);
> > > +		if (PageSwapBacked(page))
> > > +			__inc_zone_page_state(page,
> > > +					      NR_SWAP_BACKED_FILE_MAPPED);
> > > +
> > >  		mem_cgroup_update_mapped_file_stat(page, 1);
> > >  	}
> > >  }
> > > @@ -884,6 +888,9 @@ void page_remove_rmap(struct page *page)
> > >  		__dec_zone_page_state(page, NR_ANON_PAGES);
> > >  	} else {
> > >  		__dec_zone_page_state(page, NR_FILE_MAPPED);
> > > +		if (PageSwapBacked(page))
> > > +			__dec_zone_page_state(page,
> > > +					NR_SWAP_BACKED_FILE_MAPPED);
> > >  	}
> > >  	mem_cgroup_update_mapped_file_stat(page, -1);
> > >  	/*
> > > Index: b/mm/vmstat.c
> > > ===================================================================
> > > --- a/mm/vmstat.c
> > > +++ b/mm/vmstat.c
> > > @@ -633,6 +633,7 @@ static const char * const vmstat_text[] 
> > >  	"nr_mlock",
> > >  	"nr_anon_pages",
> > >  	"nr_mapped",
> > > +	"nr_swap_backed_file_mapped",
> > >  	"nr_file_pages",
> > >  	"nr_dirty",
> > >  	"nr_writeback",
> > > 
> > 
> > Otherwise the patch seems reasonable.
> > 
> > -- 
> > Mel Gorman
> > Part-time Phd Student                          Linux Technology Center
> > University of Limerick                         IBM Dublin Software Lab
> 
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
