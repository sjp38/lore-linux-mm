Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C46166B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 04:31:08 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y192so123286047pgd.12
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 01:31:08 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id f11si4289715pln.472.2017.08.14.01.31.06
        for <linux-mm@kvack.org>;
        Mon, 14 Aug 2017 01:31:07 -0700 (PDT)
Date: Mon, 14 Aug 2017 17:31:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: zs_page_migrate: schedule free_work if zspage
 is ZS_EMPTY
Message-ID: <20170814083105.GC26913@bbox>
References: <1502692486-27519-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502692486-27519-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, teawater@gmail.com

Hi Hui,

On Mon, Aug 14, 2017 at 02:34:46PM +0800, Hui Zhu wrote:
> After commit e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary
> loops but not return -EBUSY if zspage is not inuse") zs_page_migrate
> can handle the ZS_EMPTY zspage.
> 
> But it will affect the free_work free the zspage.  That will make this
> ZS_EMPTY zspage stay in system until another zspage wake up free_work.
> 
> Make this patch let zs_page_migrate wake up free_work if need.
> 
> Fixes: e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary loops but not return -EBUSY if zspage is not inuse")
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>

This patch makes me remind why I didn't try to migrate empty zspage
as you did e2846124f9a2. I have forgotten it toally.

We cannot guarantee when the freeing of the page happens if we use
deferred freeing in zs_page_migrate. However, we returns
MIGRATEPAGE_SUCCESS which is totally lie.
Without instant freeing the page, it doesn't help the migration
situation. No?

I start to wonder why your patch e2846124f9a2 helped your test.
I will think over the issue with fresh mind after the holiday.

> ---
>  mm/zsmalloc.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 62457eb..48ce043 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -2035,8 +2035,14 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
>  	 * Page migration is done so let's putback isolated zspage to
>  	 * the list if @page is final isolated subpage in the zspage.
>  	 */
> -	if (!is_zspage_isolated(zspage))
> -		putback_zspage(class, zspage);
> +	if (!is_zspage_isolated(zspage)) {
> +		/*
> +		 * The page and class is locked, we cannot free zspage
> +		 * immediately so let's defer.
> +		 */
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
