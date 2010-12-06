Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 527446B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 09:54:02 -0500 (EST)
Date: Mon, 6 Dec 2010 14:53:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v4 2/7] deactivate invalidated pages
Message-ID: <20101206145336.GF21406@csn.ul.ie>
References: <cover.1291568905.git.minchan.kim@gmail.com> <d57730effe4b48012d31ceca07938ed3eb401aba.1291568905.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <d57730effe4b48012d31ceca07938ed3eb401aba.1291568905.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 06, 2010 at 02:29:10AM +0900, Minchan Kim wrote:
> Recently, there are reported problem about thrashing.
> (http://marc.info/?l=rsync&m=128885034930933&w=2)
> It happens by backup workloads(ex, nightly rsync).
> That's because the workload makes just use-once pages
> and touches pages twice. It promotes the page into
> active list so that it results in working set page eviction.
> 
> Some app developer want to support POSIX_FADV_NOREUSE.
> But other OSes don't support it, either.
> (http://marc.info/?l=linux-mm&m=128928979512086&w=2)
> 
> By other approach, app developers use POSIX_FADV_DONTNEED.
> But it has a problem. If kernel meets page is writing
> during invalidate_mapping_pages, it can't work.
> It is very hard for application programmer to use it.
> Because they always have to sync data before calling
> fadivse(..POSIX_FADV_DONTNEED) to make sure the pages could
> be discardable. At last, they can't use deferred write of kernel
> so that they could see performance loss.
> (http://insights.oetiker.ch/linux/fadvise.html)
> 
> In fact, invalidation is very big hint to reclaimer.
> It means we don't use the page any more. So let's move
> the writing page into inactive list's head.
> 
> Why I need the page to head, Dirty/Writeback page would be flushed
> sooner or later. It can prevent writeout of pageout which is less
> effective than flusher's writeout.
> 
> Originally, I reused lru_demote of Peter with some change so added
> his Signed-off-by.
> 
> Reported-by: Ben Gamari <bgamari.foss@gmail.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> Acked-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Mel Gorman <mel@csn.ul.ie>
> 
> Andrew. Before applying this series, please drop below two patches.
>  mm-deactivate-invalidated-pages.patch
>  mm-deactivate-invalidated-pages-fix.patch
> 
> Changelog since v3:
>  - Change function comments - suggested by Johannes
>  - Change function name - suggested by Johannes
>  - add only dirty/writeback pages to deactive pagevec
> 
> Changelog since v2:
>  - mapped page leaves alone - suggested by Mel
>  - pass part related PG_reclaim in next patch.
> 
> Changelog since v1:
>  - modify description
>  - correct typo
>  - add some comment
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  include/linux/swap.h |    1 +
>  mm/swap.c            |   78 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/truncate.c        |   17 ++++++++--
>  3 files changed, 92 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index eba53e7..605ab62 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -213,6 +213,7 @@ extern void mark_page_accessed(struct page *);
>  extern void lru_add_drain(void);
>  extern int lru_add_drain_all(void);
>  extern void rotate_reclaimable_page(struct page *page);
> +extern void deactivate_page(struct page *page);
>  extern void swap_setup(void);
>  
>  extern void add_page_to_unevictable_list(struct page *page);
> diff --git a/mm/swap.c b/mm/swap.c
> index d5822b0..1f36f6f 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -39,6 +39,8 @@ int page_cluster;
>  
>  static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
>  static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
> +static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
> +
>  
>  /*
>   * This path almost never happens for VM activity - pages are normally

Unnecessary whitespace change there but otherwise;

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
