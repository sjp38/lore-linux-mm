Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 757AB6B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:59:38 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a192so2885332pge.1
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 06:59:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k66si3381877pgk.665.2017.10.26.06.59.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 06:59:37 -0700 (PDT)
Date: Thu, 26 Oct 2017 15:59:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Message-ID: <20171026135932.p5st4z7t6akmmxkf@dhcp22.suse.cz>
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
 <20171013120013.698-1-mhocko@kernel.org>
 <20171019025111.GA3852@js1304-P5Q-DELUXE>
 <20171019071503.e7w5fo35lsq6ca54@dhcp22.suse.cz>
 <20171019073355.GA4486@js1304-P5Q-DELUXE>
 <20171019082041.5zudpqacaxjhe4gw@dhcp22.suse.cz>
 <20171019122118.y6cndierwl2vnguj@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019122118.y6cndierwl2vnguj@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 19-10-17 14:21:18, Michal Hocko wrote:
[...]
> From 8cbd811d741f5dd93d1b21bb3ef94482a4d0bd32 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 19 Oct 2017 14:14:02 +0200
> Subject: [PATCH] mm: distinguish CMA and MOVABLE isolation in
>  has_unmovable_pages
> 
> Joonsoo has noticed that "mm: drop migrate type checks from
> has_unmovable_pages" would break CMA allocator because it relies on
> has_unmovable_pages returning false even for CMA pageblocks which in
> fact don't have to be movable:
> alloc_contig_range
>   start_isolate_page_range
>     set_migratetype_isolate
>       has_unmovable_pages
> 
> This is a result of the code sharing between CMA and memory hotplug
> while each one has a different idea of what has_unmovable_pages should
> return. This is unfortunate but fixing it properly would require a lot
> of code duplication.
> 
> Fix the issue by introducing the requested migrate type argument
> and special case MIGRATE_CMA case where CMA page blocks are handled
> properly. This will work for memory hotplug because it requires
> MIGRATE_MOVABLE.
> 
> Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---

Andrew,
could you add this one to the bundle as well? After
mm-drop-migrate-type-checks-from-has_unmovable_pages.patch, please.

Joonsoo would like to see a larger change in this area [1] but I think
we need to think those much more through [2] and Joonsoo agreed to take
the simpler patch first [3].

Thanks!

[1] http://lkml.kernel.org/r/20171024044423.GA31424@js1304-P5Q-DELUXE
[2] http://lkml.kernel.org/r/20171024122526.3kmabkcbmj4johli@dhcp22.suse.cz
[3] http://lkml.kernel.org/r/20171026024707.GA11791@js1304-P5Q-DELUXE

>  include/linux/page-isolation.h |  2 +-
>  mm/page_alloc.c                | 12 +++++++++++-
>  mm/page_isolation.c            | 10 +++++-----
>  3 files changed, 17 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index d4cd2014fa6f..fa9db0c7b54e 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -30,7 +30,7 @@ static inline bool is_migrate_isolate(int migratetype)
>  #endif
>  
>  bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
> -			 bool skip_hwpoisoned_pages);
> +			 int migratetype, bool skip_hwpoisoned_pages);
>  void set_pageblock_migratetype(struct page *page, int migratetype);
>  int move_freepages_block(struct zone *zone, struct page *page,
>  				int migratetype, int *num_movable);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5b4d85ae445c..259aeb22462f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7344,6 +7344,7 @@ void *__init alloc_large_system_hash(const char *tablename,
>   * race condition. So you can't expect this function should be exact.
>   */
>  bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
> +			 int migratetype,
>  			 bool skip_hwpoisoned_pages)
>  {
>  	unsigned long pfn, iter, found;
> @@ -7356,6 +7357,15 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	if (zone_idx(zone) == ZONE_MOVABLE)
>  		return false;
>  
> +	/*
> +	 * CMA allocations (alloc_contig_range) really need to mark isolate
> +	 * CMA pageblocks even when they are not movable in fact so consider
> +	 * them movable here.
> +	 */
> +	if (is_migrate_cma(migratetype) &&
> +			is_migrate_cma(get_pageblock_migratetype(page)))
> +		return false;
> +
>  	pfn = page_to_pfn(page);
>  	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
>  		unsigned long check = pfn + iter;
> @@ -7441,7 +7451,7 @@ bool is_pageblock_removable_nolock(struct page *page)
>  	if (!zone_spans_pfn(zone, pfn))
>  		return false;
>  
> -	return !has_unmovable_pages(zone, page, 0, true);
> +	return !has_unmovable_pages(zone, page, 0, MIGRATE_MOVABLE, true);
>  }
>  
>  #if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 757410d9f758..8616f5332c77 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -14,7 +14,7 @@
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/page_isolation.h>
>  
> -static int set_migratetype_isolate(struct page *page,
> +static int set_migratetype_isolate(struct page *page, int migratetype,
>  				bool skip_hwpoisoned_pages)
>  {
>  	struct zone *zone;
> @@ -51,7 +51,7 @@ static int set_migratetype_isolate(struct page *page,
>  	 * FIXME: Now, memory hotplug doesn't call shrink_slab() by itself.
>  	 * We just check MOVABLE pages.
>  	 */
> -	if (!has_unmovable_pages(zone, page, arg.pages_found,
> +	if (!has_unmovable_pages(zone, page, arg.pages_found, migratetype,
>  				 skip_hwpoisoned_pages))
>  		ret = 0;
>  
> @@ -63,14 +63,14 @@ static int set_migratetype_isolate(struct page *page,
>  out:
>  	if (!ret) {
>  		unsigned long nr_pages;
> -		int migratetype = get_pageblock_migratetype(page);
> +		int mt = get_pageblock_migratetype(page);
>  
>  		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
>  		zone->nr_isolate_pageblock++;
>  		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE,
>  									NULL);
>  
> -		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
> +		__mod_zone_freepage_state(zone, -nr_pages, mt);
>  	}
>  
>  	spin_unlock_irqrestore(&zone->lock, flags);
> @@ -182,7 +182,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  	     pfn += pageblock_nr_pages) {
>  		page = __first_valid_page(pfn, pageblock_nr_pages);
>  		if (page &&
> -		    set_migratetype_isolate(page, skip_hwpoisoned_pages)) {
> +		    set_migratetype_isolate(page, migratetype, skip_hwpoisoned_pages)) {
>  			undo_pfn = pfn;
>  			goto undo;
>  		}
> -- 
> 2.14.2
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
