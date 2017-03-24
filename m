Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 03EDC6B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 13:43:52 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e68so3661708wme.10
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 10:43:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i8si3969133wmb.118.2017.03.24.10.43.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Mar 2017 10:43:50 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc: use nth_page helper
References: <ab50f7fbf9826ac7275f0513ca04bf1073b41a36.1490323750.git.geliangtang@gmail.com>
 <b75be84c34466eb063bd44ee1ff7f2bf085002b2.1490323567.git.geliangtang@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c3dea6d8-4d0d-86d7-d901-398ba7e017ba@suse.cz>
Date: Fri, 24 Mar 2017 18:43:49 +0100
MIME-Version: 1.0
In-Reply-To: <b75be84c34466eb063bd44ee1ff7f2bf085002b2.1490323567.git.geliangtang@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 24.3.2017 15:10, Geliang Tang wrote:
> Use nth_page() helper instead of page_to_pfn() and pfn_to_page() to
> simplify the code.

Well I've never heard of this helper so I would have to look it up to see what
it does. Looks like there's not many users.
Anyway it's simpler to use just "page + i" if within MAX_ORDER_NR_PAGES, which
should be the case here. That can also actually save a few cycles. Otherwise it
looks like a pointless churn to me.

> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> ---
>  mm/page_alloc.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f749b7f..3354f56 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2511,9 +2511,8 @@ void mark_free_pages(struct zone *zone)
>  				&zone->free_area[order].free_list[t], lru) {
>  			unsigned long i;
>  
> -			pfn = page_to_pfn(page);
>  			for (i = 0; i < (1UL << order); i++)
> -				swsusp_set_page_free(pfn_to_page(pfn + i));
> +				swsusp_set_page_free(nth_page(page, i));
>  		}
>  	}
>  	spin_unlock_irqrestore(&zone->lock, flags);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
