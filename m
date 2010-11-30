Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 41DD46B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 09:28:20 -0500 (EST)
Received: by gxk5 with SMTP id 5so1848023gxk.14
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 06:28:18 -0800 (PST)
Date: Tue, 30 Nov 2010 23:01:52 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/3] Reclaim invalidated page ASAP
Message-ID: <20101130140152.GA1528@barrios-desktop>
References: <cover.1291043273.git.minchan.kim@gmail.com>
 <053e6a3308160a8992af5a47fb4163796d033b08.1291043274.git.minchan.kim@gmail.com>
 <20101130100933.82E9.A69D9226@jp.fujitsu.com>
 <20101130091822.GJ13268@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101130091822.GJ13268@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 30, 2010 at 09:18:22AM +0000, Mel Gorman wrote:
> On Tue, Nov 30, 2010 at 10:10:20AM +0900, KOSAKI Motohiro wrote:
> > > invalidate_mapping_pages is very big hint to reclaimer.
> > > It means user doesn't want to use the page any more.
> > > So in order to prevent working set page eviction, this patch
> > > move the page into tail of inactive list by PG_reclaim.
> > > 
> > > Please, remember that pages in inactive list are working set
> > > as well as active list. If we don't move pages into inactive list's
> > > tail, pages near by tail of inactive list can be evicted although
> > > we have a big clue about useless pages. It's totally bad.
> > > 
> > > Now PG_readahead/PG_reclaim is shared.
> > > fe3cba17 added ClearPageReclaim into clear_page_dirty_for_io for
> > > preventing fast reclaiming readahead marker page.
> > > 
> > > In this series, PG_reclaim is used by invalidated page, too.
> > > If VM find the page is invalidated and it's dirty, it sets PG_reclaim
> > > to reclaim asap. Then, when the dirty page will be writeback,
> > > clear_page_dirty_for_io will clear PG_reclaim unconditionally.
> > > It disturbs this serie's goal.
> > > 
> > > I think it's okay to clear PG_readahead when the page is dirty, not
> > > writeback time. So this patch moves ClearPageReadahead.
> > > 
> > > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > > Acked-by: Rik van Riel <riel@redhat.com>
> > > Cc: Wu Fengguang <fengguang.wu@intel.com>
> > > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > Cc: Nick Piggin <npiggin@kernel.dk>
> > > Cc: Mel Gorman <mel@csn.ul.ie>
> > 
> > I still dislike this one. I doubt this trick makes much benefit in real
> > world workload.
> > 
> 
> I would agree except as said elsewhere, it's a chicken and egg problem.
> We don't have a real world test because fadvise is not useful in its
> current iteration. I'm hoping that there will be a test comparing
> 
> rsync		on vanilla kernel
> rsync		on patched kernel
> rsync+patch	on vanilla kernel
> rsync+patch	on patched kernel
> 
> Are the results of such a test likely to happen?

Ben, Could you get the rsync execution time(user/sys) and 
'cat /proc/vmstat' result before/after?
If Ben is busy, I will try to get a data. but I need enough time.

I expect rsync+patch on patched kernel should have a less allocstall, less pgscan 
so fast execution time.

> 
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
