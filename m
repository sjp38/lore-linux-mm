Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5DCEC6B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 04:28:44 -0500 (EST)
Date: Tue, 23 Nov 2010 09:28:26 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC 1/2] deactive invalidated pages
Message-ID: <20101123092826.GD19571@csn.ul.ie>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 21, 2010 at 11:30:23PM +0900, Minchan Kim wrote:
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
> In fact, invalidate is very big hint to reclaimer.
> It means we don't use the page any more. So let's move
> the writing page into inactive list's head.
> 
> If it is real working set, it could have a enough time to
> activate the page since we always try to keep many pages in
> inactive list.
> 
> I reuse lru_demote of Peter with some change.
> 
> Reported-by: Ben Gamari <bgamari.foss@gmail.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nick Piggin <npiggin@kernel.dk>
> 
> Ben, Remain thing is to modify rsync and use
> fadvise(POSIX_FADV_DONTNEED). Could you test it?
> ---
>  include/linux/swap.h |    1 +
>  mm/swap.c            |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/truncate.c        |   11 +++++---
>  3 files changed, 69 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index eba53e7..a3c9248 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -213,6 +213,7 @@ extern void mark_page_accessed(struct page *);
>  extern void lru_add_drain(void);
>  extern int lru_add_drain_all(void);
>  extern void rotate_reclaimable_page(struct page *page);
> +extern void lru_deactive_page(struct page *page);
>  extern void swap_setup(void);
>  
>  extern void add_page_to_unevictable_list(struct page *page);
> diff --git a/mm/swap.c b/mm/swap.c
> index 3f48542..56fa298 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -39,6 +39,8 @@ int page_cluster;
>  
>  static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
>  static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
> +static DEFINE_PER_CPU(struct pagevec, lru_deactive_pvecs);
> +
>  
>  /*
>   * This path almost never happens for VM activity - pages are normally
> @@ -266,6 +268,45 @@ void add_page_to_unevictable_list(struct page *page)
>  	spin_unlock_irq(&zone->lru_lock);
>  }
>  
> +static void __pagevec_lru_deactive(struct pagevec *pvec)
> +{

Might be worth commenting that this function must be called with pre-emption
disabled. FWIW, I am reasonably sure your implementation is prefectly safe
but a note wouldn't hurt.

> +	int i, lru, file;
> +
> +	struct zone *zone = NULL;
> +
> +	for (i = 0; i < pagevec_count(pvec); i++) {
> +		struct page *page = pvec->pages[i];
> +		struct zone *pagezone = page_zone(page);
> +
> +		if (pagezone != zone) {
> +			if (zone)
> +				spin_unlock_irq(&zone->lru_lock);
> +			zone = pagezone;
> +			spin_lock_irq(&zone->lru_lock);
> +		}
> +
> +		if (PageLRU(page)) {
> +			if (PageActive(page)) {
> +				file = page_is_file_cache(page);
> +				lru = page_lru_base_type(page);
> +				del_page_from_lru_list(zone, page,
> +						lru + LRU_ACTIVE);
> +				ClearPageActive(page);
> +				ClearPageReferenced(page);
> +				add_page_to_lru_list(zone, page, lru);
> +				__count_vm_event(PGDEACTIVATE);
> +

What about memcg, do we not need to be calling mem_cgroup_add_lru_list() here
as well? I'm looking at the differences between what move_active_pages_to_lru()
is doing and this. I'm wondering if it'd be worth your whole building a list
of active pages that are to be moved to the inactive list and passing them
to move_active_pages_to_lru() ? I confuess I have not thought about it deeply
so it might be a terrible suggestion but it might reduce duplication of code.

> +				update_page_reclaim_stat(zone, page, file, 0);
> +			}
> +		}
> +	}
> +	if (zone)
> +		spin_unlock_irq(&zone->lru_lock);
> +
> +	release_pages(pvec->pages, pvec->nr, pvec->cold);
> +	pagevec_reinit(pvec);
> +}
> +
>  /*
>   * Drain pages out of the cpu's pagevecs.
>   * Either "cpu" is the current CPU, and preemption has already been
> @@ -292,8 +333,28 @@ static void drain_cpu_pagevecs(int cpu)
>  		pagevec_move_tail(pvec);
>  		local_irq_restore(flags);
>  	}
> +
> +	pvec = &per_cpu(lru_deactive_pvecs, cpu);
> +	if (pagevec_count(pvec))
> +		__pagevec_lru_deactive(pvec);
> +}
> +
> +/*
> + * Function used to forecefully demote a page to the head of the inactive
> + * list.

s/forecefully/forcefully/

The comment should also state *why* and under what circumstances we move
pages to the inactive list like this. Also based on the discussions
elsewhere in this thread, it'd be nice to include a comment why it's the
head of the inactive list and not the tail.

> + */
> +void lru_deactive_page(struct page *page)
> +{
> +	if (likely(get_page_unless_zero(page))) {
> +		struct pagevec *pvec = &get_cpu_var(lru_deactive_pvecs);
> +
> +		if (!pagevec_add(pvec, page))
> +			__pagevec_lru_deactive(pvec);
> +		put_cpu_var(lru_deactive_pvecs);
> +	}
>  }
>  
> +
>  void lru_add_drain(void)
>  {
>  	drain_cpu_pagevecs(get_cpu());
> diff --git a/mm/truncate.c b/mm/truncate.c
> index cd94607..c73fb19 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -332,7 +332,8 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  {
>  	struct pagevec pvec;
>  	pgoff_t next = start;
> -	unsigned long ret = 0;
> +	unsigned long ret;
> +	unsigned long count = 0;
>  	int i;
>  
>  	pagevec_init(&pvec, 0);
> @@ -359,8 +360,10 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  			if (lock_failed)
>  				continue;
>  
> -			ret += invalidate_inode_page(page);
> -
> +			ret = invalidate_inode_page(page);
> +			if (!ret)
> +				lru_deactive_page(page);
> +			count += ret;
>  			unlock_page(page);
>  			if (next > end)
>  				break;
> @@ -369,7 +372,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  		mem_cgroup_uncharge_end();
>  		cond_resched();
>  	}
> -	return ret;
> +	return count;
>  }
>  EXPORT_SYMBOL(invalidate_mapping_pages);
>  

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
