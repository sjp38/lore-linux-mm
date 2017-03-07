Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 35C1A6B038A
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 05:48:03 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y51so73607008wry.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 02:48:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p199si12197383wmd.130.2017.03.07.02.48.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 02:48:02 -0800 (PST)
Date: Tue, 7 Mar 2017 11:47:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC][PATCH 1/2] mm: use MIGRATE_HIGHATOMIC as late as possible
Message-ID: <20170307104758.GE28642@dhcp22.suse.cz>
References: <58BE8C91.20600@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58BE8C91.20600@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 07-03-17 18:33:53, Xishi Qiu wrote:
> MIGRATE_HIGHATOMIC page blocks are reserved for an atomic
> high-order allocation, so use it as late as possible.

Why is this better? Are you seeing any problem which this patch
resolves? In other words the patch description should explain why not
only what (that is usually clear from looking at the diff).

> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  mm/page_alloc.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 40d79a6..2331840 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2714,14 +2714,12 @@ struct page *rmqueue(struct zone *preferred_zone,
>  	spin_lock_irqsave(&zone->lock, flags);
>  
>  	do {
> -		page = NULL;
> -		if (alloc_flags & ALLOC_HARDER) {
> +		page = __rmqueue(zone, order, migratetype);
> +		if (!page && alloc_flags & ALLOC_HARDER) {
>  			page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
>  			if (page)
>  				trace_mm_page_alloc_zone_locked(page, order, migratetype);
>  		}
> -		if (!page)
> -			page = __rmqueue(zone, order, migratetype);
>  	} while (page && check_new_pages(page, order));
>  	spin_unlock(&zone->lock);
>  	if (!page)
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
