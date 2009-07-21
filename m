Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 032A06B0055
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 05:33:14 -0400 (EDT)
Date: Tue, 21 Jul 2009 10:33:13 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch 1/4] mm: drop unneeded double negations
Message-ID: <20090721093312.GA25383@csn.ul.ie>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 21, 2009 at 10:56:31AM +0200, Johannes Weiner wrote:
> Remove double negations where the operand is already boolean.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c |    2 +-
>  mm/memory.c     |    2 +-
>  mm/vmscan.c     |   10 +++++-----
>  3 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 38ad840..8ad148a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -655,7 +655,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  	int nid = z->zone_pgdat->node_id;
>  	int zid = zone_idx(z);
>  	struct mem_cgroup_per_zone *mz;
> -	int lru = LRU_FILE * !!file + !!active;
> +	int lru = LRU_FILE * file + active;
>  	int ret;
>  

Ok, this should be ok as file and active appear to be 1 and 0.

>  	BUG_ON(!mem_cont);
> diff --git a/mm/memory.c b/mm/memory.c
> index 6521619..dd8eb26 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -596,7 +596,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  	if (page) {
>  		get_page(page);
>  		page_dup_rmap(page, vma, addr);
> -		rss[!!PageAnon(page)]++;
> +		rss[PageAnon(page)]++;
>  	}

Similarly, seems ok.

>  
>  out_set_pte:
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 07fd8aa..46ec6a5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -516,7 +516,7 @@ int remove_mapping(struct address_space *mapping, struct page *page)
>  void putback_lru_page(struct page *page)
>  {
>  	int lru;
> -	int active = !!TestClearPageActive(page);
> +	int active = TestClearPageActive(page);
>  	int was_unevictable = PageUnevictable(page);
>  

But are you *sure* about this change?

active it used as an array offset later in this function for evictable pages
so it needs to be 1 or 0 but IIRC, the TestClear functions are not guaranteed
to return 0 or 1 on all architectures. They return 0 or non-zero. I'm 99.999%
certain I've been bitten before by test_bit returning the word with the one
bit set instead of 1. Maybe things have changed since or it's my
imagination but can you double check please?

>  	VM_BUG_ON(PageLRU(page));
> @@ -966,7 +966,7 @@ static unsigned long isolate_pages_global(unsigned long nr,
>  	if (file)
>  		lru += LRU_FILE;
>  	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
> -								mode, !!file);
> +								mode, file);
>  }
>  
>  /*
> @@ -1204,7 +1204,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
>  			lru = page_lru(page);
>  			add_page_to_lru_list(zone, page, lru);
>  			if (is_active_lru(lru)) {
> -				int file = !!is_file_lru(lru);
> +				int file = is_file_lru(lru);
>  				reclaim_stat->recent_rotated[file]++;
>  			}
>  			if (!pagevec_add(&pvec, page)) {
> @@ -1310,7 +1310,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	if (scanning_global_lru(sc)) {
>  		zone->pages_scanned += pgscanned;
>  	}
> -	reclaim_stat->recent_scanned[!!file] += nr_taken;
> +	reclaim_stat->recent_scanned[file] += nr_taken;
>  
>  	__count_zone_vm_events(PGREFILL, zone, pgscanned);
>  	if (file)
> @@ -1364,7 +1364,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	 * helps balance scan pressure between file and anonymous pages in
>  	 * get_scan_ratio.
>  	 */
> -	reclaim_stat->recent_rotated[!!file] += nr_rotated;
> +	reclaim_stat->recent_rotated[file] += nr_rotated;
>  	__count_vm_events(PGDEACTIVATE, nr_deactivate);
>  
>  	move_active_pages_to_lru(zone, &l_active,
> -- 
> 1.6.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
