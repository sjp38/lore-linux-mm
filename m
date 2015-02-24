Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id CE54A6B0038
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 11:14:11 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id l15so26672399wiw.5
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 08:14:11 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lg8si68249885wjb.183.2015.02.24.08.14.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Feb 2015 08:14:09 -0800 (PST)
Date: Tue, 24 Feb 2015 17:14:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC 3/4] mm: move lazy free pages to inactive list
Message-ID: <20150224161408.GB14939@dhcp22.suse.cz>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <1424765897-27377-3-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424765897-27377-3-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com

On Tue 24-02-15 17:18:16, Minchan Kim wrote:
> MADV_FREE is hint that it's okay to discard pages if memory is
> pressure and we uses reclaimers(ie, kswapd and direct reclaim)

s@if memory is pressure@if there is memory pressure@

> to free them so there is no worth to remain them in active
> anonymous LRU list so this patch moves them to inactive LRU list.

Makes sense to me.

> A arguable issue for the approach is whether we should put it
> head or tail in inactive list

Is it really arguable? Why should active MADV_FREE pages appear before
those which were living on the inactive list. This doesn't make any
sense to me.

> and selected it as head because
> kernel cannot make sure it's really cold or warm for every usecase
> but at least we know it's not hot so landing of inactive head
> would be comprimise if it stayed in active LRU.

This is really hard to read. What do you think about the following
wording?
"
The active status of those pages is cleared and they are moved to the
head of the inactive LRU. This means that MADV_FREE-ed pages which
were living on the inactive list are reclaimed first because they
are more likely to be cold rather than recently active pages.
"

> As well, if we put recent hinted pages to inactive's tail,
> VM could discard cache hot pages, which would be bad.
> 
> As a bonus, we don't need to move them back and forth in inactive
> list whenever MADV_SYSCALL syscall is called.
> 
> As drawback, VM should scan more pages in inactive anonymous LRU
> to discard but it has happened all the time if recent reference
> happens on those pages in inactive LRU list so I don't think
> it's not a main drawback.

Rather than the above paragraphs I would like to see a description why
this is needed. Something like the following?
"
This is fixing a suboptimal behavior of MADV_FREE when pages living on
the active list will sit there for a long time even under memory
pressure while the inactive list is reclaimed heavily. This basically
breaks the whole purpose of using MADV_FREE to help the system to free
memory which is might not be used.
"

> Signed-off-by: Minchan Kim <minchan@kernel.org>

Other than that the patch looks good to me.
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/swap.h |  1 +
>  mm/madvise.c         |  2 ++
>  mm/swap.c            | 35 +++++++++++++++++++++++++++++++++++
>  3 files changed, 38 insertions(+)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index cee108cbe2d5..0428e4c84e1d 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -308,6 +308,7 @@ extern void lru_add_drain_cpu(int cpu);
>  extern void lru_add_drain_all(void);
>  extern void rotate_reclaimable_page(struct page *page);
>  extern void deactivate_file_page(struct page *page);
> +extern void deactivate_page(struct page *page);
>  extern void swap_setup(void);
>  
>  extern void add_page_to_unevictable_list(struct page *page);
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 81bb26ecf064..6176039c69e4 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -324,6 +324,8 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  		ptent = pte_mkold(ptent);
>  		ptent = pte_mkclean(ptent);
>  		set_pte_at(mm, addr, pte, ptent);
> +		if (PageActive(page))
> +			deactivate_page(page);
>  		tlb_remove_tlb_entry(tlb, pte, addr);
>  	}
>  	arch_leave_lazy_mmu_mode();
> diff --git a/mm/swap.c b/mm/swap.c
> index 5b2a60578f9c..393968c33667 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -43,6 +43,7 @@ int page_cluster;
>  static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
>  static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
>  static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
> +static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
>  
>  /*
>   * This path almost never happens for VM activity - pages are normally
> @@ -789,6 +790,23 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
>  	update_page_reclaim_stat(lruvec, file, 0);
>  }
>  
> +
> +static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
> +			    void *arg)
> +{
> +	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
> +		int file = page_is_file_cache(page);
> +		int lru = page_lru_base_type(page);
> +
> +		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
> +		ClearPageActive(page);
> +		add_page_to_lru_list(page, lruvec, lru);
> +
> +		__count_vm_event(PGDEACTIVATE);
> +		update_page_reclaim_stat(lruvec, file, 0);
> +	}
> +}
> +
>  /*
>   * Drain pages out of the cpu's pagevecs.
>   * Either "cpu" is the current CPU, and preemption has already been
> @@ -815,6 +833,10 @@ void lru_add_drain_cpu(int cpu)
>  	if (pagevec_count(pvec))
>  		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
>  
> +	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
> +	if (pagevec_count(pvec))
> +		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
> +
>  	activate_page_drain(cpu);
>  }
>  
> @@ -844,6 +866,18 @@ void deactivate_file_page(struct page *page)
>  	}
>  }
>  
> +void deactivate_page(struct page *page)
> +{
> +	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
> +		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
> +
> +		page_cache_get(page);
> +		if (!pagevec_add(pvec, page))
> +			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
> +		put_cpu_var(lru_deactivate_pvecs);
> +	}
> +}
> +
>  void lru_add_drain(void)
>  {
>  	lru_add_drain_cpu(get_cpu());
> @@ -873,6 +907,7 @@ void lru_add_drain_all(void)
>  		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
>  		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
>  		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
> +		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
>  		    need_activate_page_drain(cpu)) {
>  			INIT_WORK(work, lru_add_drain_per_cpu);
>  			schedule_work_on(cpu, work);
> -- 
> 1.9.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
