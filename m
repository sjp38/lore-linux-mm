Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3696B0095
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 07:07:35 -0500 (EST)
Date: Mon, 29 Nov 2010 12:07:16 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v2 1/3] deactivate invalidated pages
Message-ID: <20101129120716.GE13268@csn.ul.ie>
References: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 12:02:55AM +0900, Minchan Kim wrote:
> This patch is based on mmotm-11-23. 
> 
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
> By Other approach, app developer uses POSIX_FADV_DONTNEED.
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
> sooner or later. This patch uses trick PG_reclaim so the page would
> be moved into tail of inactive list when the page writeout completes.
> 
> It can prevent writeout of pageout which is less effective than
> flusher's writeout.
> 
> This patch considers page_mappged(page) with working set.
> So the page could leave head of inactive to get a change to activate.
> 
> Originally, I reused lru_demote of Peter with some change so added
> his Signed-off-by.
> 
> Note :
> PG_reclaim trick of writeback page could race with end_page_writeback
> so this patch check PageWriteback one more. It makes race window time
> reall small. But by theoretical, it still have a race. But it's a trivial.
> 
> Quote from fe3cba17 and some modification
> "If some page PG_reclaim unintentionally, it will confuse readahead and
> make it restart the size rampup process. But it's a trivial problem, and
> can mostly be avoided by checking PageWriteback(page) first in readahead"
> 
> PG_reclaim trick of dirty page don't work now since clear_page_dirty_for_io
> always clears PG_reclaim. Next patch will fix it.
> 
> Reported-by: Ben Gamari <bgamari.foss@gmail.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Mel Gorman <mel@csn.ul.ie>
> 
> Changelog since v1:
>  - modify description
>  - correct typo
>  - add some comment
>  - change deactivation policy
> ---
>  mm/swap.c |   84 +++++++++++++++++++++++++++++++++++++++++++++---------------
>  1 files changed, 63 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 31f5ec4..345eca1 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -268,10 +268,65 @@ void add_page_to_unevictable_list(struct page *page)
>  	spin_unlock_irq(&zone->lru_lock);
>  }
>  
> -static void __pagevec_lru_deactive(struct pagevec *pvec)
> +/*
> + * This function is used by invalidate_mapping_pages.
> + * If the page can't be invalidated, this function moves the page
> + * into inative list's head or tail to reclaim ASAP and evict
> + * working set page.
> + *
> + * PG_reclaim means when the page's writeback completes, the page
> + * will move into tail of inactive for reclaiming ASAP.
> + *
> + * 1. active, mapped page -> inactive, head
> + * 2. active, dirty/writeback page -> inactive, head, PG_reclaim
> + * 3. inactive, mapped page -> none
> + * 4. inactive, dirty/writeback page -> inactive, head, PG_reclaim
> + * 5. others -> none
> + *
> + * In 4, why it moves inactive's head, the VM expects the page would
> + * be writeout by flusher. The flusher's writeout is much effective than
> + * reclaimer's random writeout.
> + */
> +static void __lru_deactivate(struct page *page, struct zone *zone)
>  {
> -	int i, lru, file;
> +	int lru, file;
> +	int active = 0;
> +
> +	if (!PageLRU(page))
> +		return;
> +
> +	if (PageActive(page))
> +		active = 1;
> +	/* Some processes are using the page */
> +	if (page_mapped(page) && !active)
> +		return;
> +

Why do we move active pages to the inactive list? I thought the decision was
that mapped pages are certainly in use so we they should be not affected by
fadvise(). In contrast, I see you leave inactive pages alone.

> +	else if (PageWriteback(page)) {
> +		SetPageReclaim(page);
> +		/* Check race with end_page_writeback */
> +		if (!PageWriteback(page))
> +			ClearPageReclaim(page);

I think this is safe but the comment could be expanded to mention that
the page is locked at this point and explain how it's impossible for
PageReclaim to be set on a !PageWriteback page here.

> +	} else if (PageDirty(page))
> +		SetPageReclaim(page);
> +
> +	file = page_is_file_cache(page);
> +	lru = page_lru_base_type(page);
> +	del_page_from_lru_list(zone, page, lru + active);
> +	ClearPageActive(page);
> +	ClearPageReferenced(page);
> +	add_page_to_lru_list(zone, page, lru);
> +	if (active)
> +		__count_vm_event(PGDEACTIVATE);
> +
> +	update_page_reclaim_stat(zone, page, file, 0);
> +}
>  
> +/*
> + * This function must be called with preemption disable.
> + */
> +static void __pagevec_lru_deactivate(struct pagevec *pvec)
> +{
> +	int i;
>  	struct zone *zone = NULL;
>  
>  	for (i = 0; i < pagevec_count(pvec); i++) {
> @@ -284,21 +339,7 @@ static void __pagevec_lru_deactive(struct pagevec *pvec)
>  			zone = pagezone;
>  			spin_lock_irq(&zone->lru_lock);
>  		}
> -
> -		if (PageLRU(page)) {
> -			if (PageActive(page)) {
> -				file = page_is_file_cache(page);
> -				lru = page_lru_base_type(page);
> -				del_page_from_lru_list(zone, page,
> -						lru + LRU_ACTIVE);
> -				ClearPageActive(page);
> -				ClearPageReferenced(page);
> -				add_page_to_lru_list(zone, page, lru);
> -				__count_vm_event(PGDEACTIVATE);
> -
> -				update_page_reclaim_stat(zone, page, file, 0);
> -			}
> -		}
> +		__lru_deactivate(page, zone);
>  	}
>  	if (zone)
>  		spin_unlock_irq(&zone->lru_lock);
> @@ -336,11 +377,13 @@ static void drain_cpu_pagevecs(int cpu)
>  
>  	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
>  	if (pagevec_count(pvec))
> -		__pagevec_lru_deactive(pvec);
> +		__pagevec_lru_deactivate(pvec);
>  }
>  
>  /*
> - * Forecfully demote a page to the tail of the inactive list.
> + * Forcefully deactivate a page.
> + * This function is used for reclaiming the page ASAP when the page
> + * can't be invalidated by Dirty/Writeback.
>   */
>  void lru_deactivate_page(struct page *page)
>  {
> @@ -348,12 +391,11 @@ void lru_deactivate_page(struct page *page)
>  		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
>  
>  		if (!pagevec_add(pvec, page))
> -			__pagevec_lru_deactive(pvec);
> +			__pagevec_lru_deactivate(pvec);
>  		put_cpu_var(lru_deactivate_pvecs);
>  	}
>  }
>  
> -

Unnecessary whitespace change there.

>  void lru_add_drain(void)
>  {
>  	drain_cpu_pagevecs(get_cpu());

Functionally, I think this will work (although I'd like a clarification
on why active pages are rotated). It'd be nice if there was a test case
for this but it's a bit of a chicken-and-egg problem :/

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
