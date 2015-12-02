Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 56A166B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 11:32:30 -0500 (EST)
Received: by wmww144 with SMTP id w144so222409921wmw.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 08:32:30 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id a80si6180213wmd.0.2015.12.02.08.32.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 08:32:29 -0800 (PST)
Received: by wmec201 with SMTP id c201so261823210wme.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 08:32:29 -0800 (PST)
Date: Wed, 2 Dec 2015 17:32:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm/page_alloc.c: use list_for_each_entry in
 mark_free_pages()
Message-ID: <20151202163227.GL25284@dhcp22.suse.cz>
References: <db1a792ecffc24a080e130725a82f190804fdf78.1449068845.git.geliangtang@163.com>
 <7009a8fa2dba33da9bcfe60db4741139c07c8074.1449068845.git.geliangtang@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7009a8fa2dba33da9bcfe60db4741139c07c8074.1449068845.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Alexander Duyck <alexander.h.duyck@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 02-12-15 23:12:41, Geliang Tang wrote:
> Use list_for_each_entry instead of list_for_each + list_entry to
> simplify the code.
> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0d38185..1c1ad58 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2027,7 +2027,7 @@ void mark_free_pages(struct zone *zone)
>  	unsigned long pfn, max_zone_pfn;
>  	unsigned long flags;
>  	unsigned int order, t;
> -	struct list_head *curr;
> +	struct page *page;
>  
>  	if (zone_is_empty(zone))
>  		return;
> @@ -2037,17 +2037,17 @@ void mark_free_pages(struct zone *zone)
>  	max_zone_pfn = zone_end_pfn(zone);
>  	for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
>  		if (pfn_valid(pfn)) {
> -			struct page *page = pfn_to_page(pfn);
> -
> +			page = pfn_to_page(pfn);
>  			if (!swsusp_page_is_forbidden(page))
>  				swsusp_unset_page_free(page);
>  		}
>  
>  	for_each_migratetype_order(order, t) {
> -		list_for_each(curr, &zone->free_area[order].free_list[t]) {
> +		list_for_each_entry(page,
> +				&zone->free_area[order].free_list[t], lru) {
>  			unsigned long i;
>  
> -			pfn = page_to_pfn(list_entry(curr, struct page, lru));
> +			pfn = page_to_pfn(page);
>  			for (i = 0; i < (1UL << order); i++)
>  				swsusp_set_page_free(pfn_to_page(pfn + i));
>  		}
> -- 
> 2.5.0
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
