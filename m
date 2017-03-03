Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD5046B0398
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 08:18:26 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w67so6223546wmd.3
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 05:18:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 135si2944568wmh.53.2017.03.03.05.18.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Mar 2017 05:18:25 -0800 (PST)
Date: Fri, 3 Mar 2017 14:18:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: use is_migrate_isolate_page() to simplify the
 code
Message-ID: <20170303131824.GI31499@dhcp22.suse.cz>
References: <58B94F15.6060606@huawei.com>
 <58B94FB1.8020802@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58B94FB1.8020802@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 03-03-17 19:12:49, Xishi Qiu wrote:
> Use is_migrate_isolate_page() to simplify the code, no functional changes.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_isolation.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index f4e17a5..7927bbb 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -88,7 +88,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>  
>  	zone = page_zone(page);
>  	spin_lock_irqsave(&zone->lock, flags);
> -	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
> +	if (!is_migrate_isolate_page(page))
>  		goto out;
>  
>  	/*
> @@ -205,7 +205,7 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  	     pfn < end_pfn;
>  	     pfn += pageblock_nr_pages) {
>  		page = __first_valid_page(pfn, pageblock_nr_pages);
> -		if (!page || get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
> +		if (!page || !is_migrate_isolate_page(page))
>  			continue;
>  		unset_migratetype_isolate(page, migratetype);
>  	}
> @@ -262,7 +262,7 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
>  	 */
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
>  		page = __first_valid_page(pfn, pageblock_nr_pages);
> -		if (page && get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
> +		if (page && !is_migrate_isolate_page(page))
>  			break;
>  	}
>  	page = __first_valid_page(start_pfn, end_pfn - start_pfn);
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
