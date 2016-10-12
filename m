Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 243F56B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:36:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o81so2976890wma.7
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 22:36:09 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id is8si8346461wjb.208.2016.10.11.22.36.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 22:36:08 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id AF17E1C204A
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 06:36:07 +0100 (IST)
Date: Wed, 12 Oct 2016 06:36:03 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/4] mm: adjust reserved highatomic count
Message-ID: <20161012053602.GA22174@techsingularity.net>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-2-git-send-email-minchan@kernel.org>
 <7ac7c0d8-4b7b-e362-08e7-6d62ee20f4c3@suse.cz>
 <20161007142919.GA3060@bbox>
 <c0920ac2-fe63-567e-e24c-eb6d638143b0@suse.cz>
 <20161011041916.GA30973@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161011041916.GA30973@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Tue, Oct 11, 2016 at 01:19:16PM +0900, Minchan Kim wrote:
> From 4a0b6a74ebf1af7f90720b0028da49e2e2a2b679 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Thu, 6 Oct 2016 13:38:35 +0900
> Subject: [PATCH] mm: don't steal highatomic pageblock
> 
> In page freeing path, migratetype is racy so that a highorderatomic
> page could free into non-highorderatomic free list. If that page
> is allocated, VM can change the pageblock from higorderatomic to
> something. In that case, highatomic pageblock accounting is broken
> so it doesn't work(e.g., VM cannot reserve highorderatomic pageblocks
> any more although it doesn't reach 1% limit).
> 
> So, this patch prohibits the changing from highatomic to other type.
> It's no problem because MIGRATE_HIGHATOMIC is not listed in fallback
> array so stealing will only happen due to unexpected races which is
> really rare. Also, such prohibiting keeps highatomic pageblock more
> longer so it would be better for highorderatomic page allocation.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/page_alloc.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 55ad0229ebf3..79853b258211 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2154,7 +2154,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>  
>  		page = list_first_entry(&area->free_list[fallback_mt],
>  						struct page, lru);
> -		if (can_steal)
> +		if (can_steal &&
> +			get_pageblock_migratetype(page) != MIGRATE_HIGHATOMIC)
>  			steal_suitable_fallback(zone, page, start_migratetype);
>  
>  		/* Remove the page from the freelists */
> @@ -2555,7 +2556,8 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  		struct page *endpage = page + (1 << order) - 1;
>  		for (; page < endpage; page += pageblock_nr_pages) {
>  			int mt = get_pageblock_migratetype(page);
> -			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt))
> +			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt)
> +				&& mt != MIGRATE_HIGHATOMIC)
>  				set_pageblock_migratetype(page,
>  							  MIGRATE_MOVABLE);
>  		}

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
