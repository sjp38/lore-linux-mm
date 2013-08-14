Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 1E3736B0069
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 03:07:00 -0400 (EDT)
Date: Wed, 14 Aug 2013 16:07:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: skip the page buddy block instead of one page
Message-ID: <20130814070705.GA21133@bbox>
References: <520B0B75.4030708@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520B0B75.4030708@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, riel@redhat.com, aquini@redhat.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hello,

On Wed, Aug 14, 2013 at 12:45:41PM +0800, Xishi Qiu wrote:
> A large free page buddy block will continue many times, so if the page 
> is free, skip the whole page buddy block instead of one page.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>


Nitpick is it could change nr_scanned's result so that COMPACMIGRATE_SCANNED
of vmstat could be smaller than old. It means that compaction efficiency would
pretend to be better than old and if something on userspace have been depends
on it, it would be broken. But I don't know such usecase so I will pass the
decision to others. Anyway, I suppose this patch.
If it's real concern, we can fix it with increasing nr_scanned by page_order.

Thanks.

Acked-by: Minchan Kim <minchan@kernel.org>

> ---
>  mm/compaction.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 05ccb4c..874bae1 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -520,9 +520,10 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  			goto next_pageblock;
>  
>  		/* Skip if free */
> -		if (PageBuddy(page))
> +		if (PageBuddy(page)) {
> +			low_pfn += (1 << page_order(page)) - 1;
>  			continue;
> -
> +		}
>  		/*
>  		 * For async migration, also only scan in MOVABLE blocks. Async
>  		 * migration is optimistic to see if the minimum amount of work
> -- 
> 1.7.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
