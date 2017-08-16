Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C4A136B02B4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 22:13:45 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id f23so35722773pgn.15
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 19:13:45 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id z7si6288990pff.267.2017.08.15.19.13.43
        for <linux-mm@kvack.org>;
        Tue, 15 Aug 2017 19:13:44 -0700 (PDT)
Date: Wed, 16 Aug 2017 11:13:39 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zsmalloc: zs_page_migrate: schedule free_work if
 zspage is ZS_EMPTY
Message-ID: <20170816021339.GA23451@blaptop>
References: <1502704590-3129-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502704590-3129-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, teawater@gmail.com

Hi Hui,

On Mon, Aug 14, 2017 at 05:56:30PM +0800, Hui Zhu wrote:
> After commit e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary

This patch is not merged yet so the hash is invalid.
That means we may fold this patch to [1] in current mmotm.

[1] zsmalloc-zs_page_migrate-skip-unnecessary-loops-but-not-return-ebusy-if-zspage-is-not-inuse-fix.patch

> loops but not return -EBUSY if zspage is not inuse") zs_page_migrate
> can handle the ZS_EMPTY zspage.
> 
> But I got some false in zs_page_isolate:
> 	if (get_zspage_inuse(zspage) == 0) {
> 		spin_unlock(&class->lock);
> 		return false;
> 	}

I also realized we should make zs_page_isolate succeed on empty zspage
because we allow the empty zspage migration from now on.
Could you send a patch for that as well?

> The page of this zspage was migrated in before.
> 
> The reason is commit e2846124f9a2 ("zsmalloc: zs_page_migrate: skip
> unnecessary loops but not return -EBUSY if zspage is not inuse") just
> handle the "page" but not "newpage" then it keep the "newpage" with
> a empty zspage inside system.
> Root cause is zs_page_isolate remove it from ZS_EMPTY list but not
> call zs_page_putback "schedule_work(&pool->free_work);".  Because
> zs_page_migrate done the job without "schedule_work(&pool->free_work);"
> 
> Make this patch let zs_page_migrate wake up free_work if need.
> 
> Fixes: e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary loops but not return -EBUSY if zspage is not inuse")
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
> ---
>  mm/zsmalloc.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 62457eb..c6cc77c 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -2035,8 +2035,17 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
>  	 * Page migration is done so let's putback isolated zspage to
>  	 * the list if @page is final isolated subpage in the zspage.
>  	 */
> -	if (!is_zspage_isolated(zspage))
> -		putback_zspage(class, zspage);
> +	if (!is_zspage_isolated(zspage)) {
> +		/*
> +		 * Page will be freed in following part. But newpage and
> +		 * zspage will stay in system if zspage is in ZS_EMPTY
> +		 * list.  So call free_work to free it.
> +		 * The page and class is locked, we cannot free zspage
> +		 * immediately so let's defer.
> +		 */

How about this?

                /*
                 * Since we allow empty zspage migration, putback of zspage
                 * should free empty zspage. Otherwise, it could make a leak
                 * until upcoming free_work is done, which isn't guaranteed.
                 */
> +		if (putback_zspage(class, zspage) == ZS_EMPTY)
> +			schedule_work(&pool->free_work);
> +	}
>  
>  	reset_page(page);
>  	put_page(page);
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
