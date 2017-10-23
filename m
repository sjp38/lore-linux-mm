Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D92E46B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 07:55:52 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g6so11656830pgn.11
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 04:55:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bb11si3944808plb.330.2017.10.23.04.55.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 04:55:51 -0700 (PDT)
Date: Mon, 23 Oct 2017 13:55:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm: broken deferred calculation
Message-ID: <20171023115547.qscf33ep2lhm75pi@dhcp22.suse.cz>
References: <20171021011707.15191-1-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171021011707.15191-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri 20-10-17 21:17:07, Pavel Tatashin wrote:
> In reset_deferred_meminit we determine number of pages that must not be
> deferred. We initialize pages for at least 2G of memory, but also pages for
> reserved memory in this node.
> 
> The reserved memory is determined in this function:
> memblock_reserved_memory_within(), which operates over physical addresses,
> and returns size in bytes. However, reset_deferred_meminit() assumes that
> that this function operates with pfns, and returns page count.
> 
> The result is that in the best case machine boots slower than expected
> due to initializing more pages than needed in single thread, and in the
> worst case panics because fewer than needed pages are initialized early.

Hmm, I have definitely screwed up pfns and addresses here. I am
wondering how this could work in the end. I remember this has been
tested on the PPC machine which exhibited the problem.

> Fixes: 864b9a393dcb ("mm: consider memblock reservations for deferred memory initialization sizing")
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Thanks for catching that! The patch could have been simpler without all
the renames but I have no objections here.
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mmzone.h |  3 ++-
>  mm/page_alloc.c        | 27 ++++++++++++++++++---------
>  2 files changed, 20 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index a6f361931d52..d45ba78c7e42 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -699,7 +699,8 @@ typedef struct pglist_data {
>  	 * is the first PFN that needs to be initialised.
>  	 */
>  	unsigned long first_deferred_pfn;
> -	unsigned long static_init_size;
> +	/* Number of non-deferred pages */
> +	unsigned long static_init_pgcnt;
>  #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
>  
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 97687b38da05..16419cdbbb7a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -289,28 +289,37 @@ EXPORT_SYMBOL(nr_online_nodes);
>  int page_group_by_mobility_disabled __read_mostly;
>  
>  #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> +
> +/*
> + * Determine how many pages need to be initialized durig early boot
> + * (non-deferred initialization).
> + * The value of first_deferred_pfn will be set later, once non-deferred pages
> + * are initialized, but for now set it ULONG_MAX.
> + */
>  static inline void reset_deferred_meminit(pg_data_t *pgdat)
>  {
> -	unsigned long max_initialise;
> -	unsigned long reserved_lowmem;
> +	phys_addr_t start_addr, end_addr;
> +	unsigned long max_pgcnt;
> +	unsigned long reserved;
>  
>  	/*
>  	 * Initialise at least 2G of a node but also take into account that
>  	 * two large system hashes that can take up 1GB for 0.25TB/node.
>  	 */
> -	max_initialise = max(2UL << (30 - PAGE_SHIFT),
> -		(pgdat->node_spanned_pages >> 8));
> +	max_pgcnt = max(2UL << (30 - PAGE_SHIFT),
> +			(pgdat->node_spanned_pages >> 8));
>  
>  	/*
>  	 * Compensate the all the memblock reservations (e.g. crash kernel)
>  	 * from the initial estimation to make sure we will initialize enough
>  	 * memory to boot.
>  	 */
> -	reserved_lowmem = memblock_reserved_memory_within(pgdat->node_start_pfn,
> -			pgdat->node_start_pfn + max_initialise);
> -	max_initialise += reserved_lowmem;
> +	start_addr = PFN_PHYS(pgdat->node_start_pfn);
> +	end_addr = PFN_PHYS(pgdat->node_start_pfn + max_pgcnt);
> +	reserved = memblock_reserved_memory_within(start_addr, end_addr);
> +	max_pgcnt += PHYS_PFN(reserved);
>  
> -	pgdat->static_init_size = min(max_initialise, pgdat->node_spanned_pages);
> +	pgdat->static_init_pgcnt = min(max_pgcnt, pgdat->node_spanned_pages);
>  	pgdat->first_deferred_pfn = ULONG_MAX;
>  }
>  
> @@ -337,7 +346,7 @@ static inline bool update_defer_init(pg_data_t *pgdat,
>  	if (zone_end < pgdat_end_pfn(pgdat))
>  		return true;
>  	(*nr_initialised)++;
> -	if ((*nr_initialised > pgdat->static_init_size) &&
> +	if ((*nr_initialised > pgdat->static_init_pgcnt) &&
>  	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
>  		pgdat->first_deferred_pfn = pfn;
>  		return false;
> -- 
> 2.14.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
