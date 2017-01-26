Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 22E986B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 04:27:28 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d140so43911032wmd.4
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 01:27:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z38si1249543wrc.101.2017.01.26.01.27.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 01:27:26 -0800 (PST)
Date: Thu, 26 Jan 2017 10:27:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 2/2] HWPOISON: soft offlining for non-lru movable page
Message-ID: <20170126092725.GD6590@dhcp22.suse.cz>
References: <1485356738-4831-1-git-send-email-ysxie@foxmail.com>
 <1485356738-4831-3-git-send-email-ysxie@foxmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485356738-4831-3-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ysxie@foxmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

On Wed 25-01-17 23:05:38, ysxie@foxmail.com wrote:
> From: Yisheng Xie <xieyisheng1@huawei.com>
> 
> This patch is to extends soft offlining framework to support
> non-lru page, which already support migration after
> commit bda807d44454 ("mm: migrate: support non-lru movable page
> migration")
> 
> When memory corrected errors occur on a non-lru movable page,
> we can choose to stop using it by migrating data onto another
> page and disable the original (maybe half-broken) one.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Suggested-by: Minchan Kim <minchan@kernel.org>
> Reviewed-by: Minchan Kim <minchan@kernel.org>
> Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> CC: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/memory-failure.c | 26 ++++++++++++++++----------
>  1 file changed, 16 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index f283c7e..56e39f8 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1527,7 +1527,8 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
>  {
>  	int ret = __get_any_page(page, pfn, flags);
>  
> -	if (ret == 1 && !PageHuge(page) && !PageLRU(page)) {
> +	if (ret == 1 && !PageHuge(page) &&
> +	    !PageLRU(page) && !__PageMovable(page)) {
>  		/*
>  		 * Try to free it.
>  		 */

Is this sufficient? Not that I am familiar with get_any_page() but
__get_any_page doesn't seem to be aware of movable pages and neither
shake_page is.

> @@ -1649,7 +1650,10 @@ static int __soft_offline_page(struct page *page, int flags)
>  	 * Try to migrate to a new page instead. migrate.c
>  	 * handles a large number of cases for us.
>  	 */
> -	ret = isolate_lru_page(page);
> +	if (PageLRU(page))
> +		ret = isolate_lru_page(page);
> +	else if (!isolate_movable_page(page, ISOLATE_UNEVICTABLE))
> +		ret = -EBUSY;

As pointed out in the previous response isolate_movable_page should
really have the same return value contract as [__]isolate_lru_page

>  	/*
>  	 * Drop page reference which is came from get_any_page()
>  	 * successful isolate_lru_page() already took another one.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
