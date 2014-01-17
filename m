Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 77AE46B0031
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 13:40:54 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so1923521eae.33
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 10:40:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id p46si22164555eem.189.2014.01.17.10.40.52
        for <linux-mm@kvack.org>;
        Fri, 17 Jan 2014 10:40:53 -0800 (PST)
Date: Fri, 17 Jan 2014 16:40:42 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] mm: Improve documentation of page_order
Message-ID: <20140117184041.GA7449@localhost.localdomain>
References: <520B0B75.4030708@huawei.com>
 <20130814085711.GK2296@suse.de>
 <20130814155205.GA2706@gmail.com>
 <20130814132602.814a88e991e29c5b93bbe22c@linux-foundation.org>
 <20130814222241.GQ2296@suse.de>
 <20140117143221.GA24851@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140117143221.GA24851@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, riel@redhat.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 17, 2014 at 02:32:21PM +0000, Mel Gorman wrote:
> Developers occasionally try and optimise PFN scanners by using page_order
> but miss that in general it requires zone->lock. This has happened twice for
> compaction.c and rejected both times.  This patch clarifies the documentation
> of page_order and adds a note to compaction.c why page_order is not used.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/compaction.c | 5 ++++-
>  mm/internal.h   | 8 +++++---
>  2 files changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index f58bcd0..f91d26b 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -522,7 +522,10 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  		if (!isolation_suitable(cc, page))
>  			goto next_pageblock;
>  
> -		/* Skip if free */
> +		/*
> +		 * Skip if free. page_order cannot be used without zone->lock
> +		 * as nothing prevents parallel allocations or buddy merging.
> +		 */
>  		if (PageBuddy(page))
>  			continue;
>  
> diff --git a/mm/internal.h b/mm/internal.h
> index 684f7aa..09cd8be 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -144,9 +144,11 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  #endif
>  
>  /*
> - * function for dealing with page's order in buddy system.
> - * zone->lock is already acquired when we use these.
> - * So, we don't need atomic page->flags operations here.
> + * This functions returns the order of a free page in the buddy system.
> + * In general, page_zone(page)->lock must be held by the caller to prevent
> + * the page being allocated in parallel and returning garbage as the order.
> + * If the caller does not hold page_zone(page), they must guarantee that
> + * the page cannot be allocated or merged in parallel.
>   */
>  static inline unsigned long page_order(struct page *page)
>  {

Acked-by: Rafael Aquini <aquini@redhat.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
