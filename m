Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id AA1406B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 00:54:30 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro8so4049744pbb.13
        for <linux-mm@kvack.org>; Mon, 28 Oct 2013 21:54:30 -0700 (PDT)
Received: from psmtp.com ([74.125.245.113])
        by mx.google.com with SMTP id gj2si14819915pac.254.2013.10.28.21.54.28
        for <linux-mm@kvack.org>;
        Mon, 28 Oct 2013 21:54:29 -0700 (PDT)
Date: Tue, 29 Oct 2013 13:54:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: cma: free cma page to buddy instead of being cpu hot
 page
Message-ID: <20131029045430.GE17038@bbox>
References: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhang.mingjun@linaro.org
Cc: m.szyprowski@samsung.com, akpm@linux-foundation.org, mgorman@suse.de, haojian.zhuang@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mingjun Zhang <troy.zhangmingjun@linaro.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hello,

On Mon, Oct 28, 2013 at 07:42:49PM +0800, zhang.mingjun@linaro.org wrote:
> From: Mingjun Zhang <troy.zhangmingjun@linaro.org>
> 
> free_contig_range frees cma pages one by one and MIGRATE_CMA pages will be
> used as MIGRATE_MOVEABLE pages in the pcp list, it causes unnecessary
> migration action when these pages reused by CMA.

You are saying about the overhead but I'm not sure how much it is
because it wouldn't be frequent. Although it's frequent, migration is
already slow path and CMA migration is worse so I really wonder how much
pain is and how much this patch improve.

Having said that, it makes CMA allocation policy consistent which
is that CMA migration type is last fallback to minimize number of migration
and code peice you are adding is already low hit path so that I think
it has no problem.

> 
> Signed-off-by: Mingjun Zhang <troy.zhangmingjun@linaro.org>
> ---
>  mm/page_alloc.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0ee638f..84b9d84 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1362,7 +1362,8 @@ void free_hot_cold_page(struct page *page, int cold)
>  	 * excessively into the page allocator
>  	 */
>  	if (migratetype >= MIGRATE_PCPTYPES) {
> -		if (unlikely(is_migrate_isolate(migratetype))) {
> +		if (unlikely(is_migrate_isolate(migratetype))
> +			|| is_migrate_cma(migratetype))

The concern is likely/unlikely usage is proper in this code peice.
If we don't use memory isolation, the code path is used for only
MIGRATE_RESERVE which is very rare allocation in normal workload.

Even, in memory isolation environement, I'm not sure how many
CMA/HOTPLUG is used compared to normal alloc/free.
So, I think below is more proper?

if (unlikely(migratetype >= MIGRATE_PCPTYPES)) {
        if (is_migrate_isolate(migratetype) || is_migrate_cma(migratetype))

I know it's an another topic but I'd like to disucss it in this time because
we will forget such trivial thing later, again.

}

>  			free_one_page(zone, page, 0, migratetype);
>  			goto out;
>  		}
> -- 
> 1.7.9.5
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
