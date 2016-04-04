Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6FCE36B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 05:07:32 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id ma7so79887654igc.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 02:07:32 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d7si23829738ioe.106.2016.04.04.02.07.31
        for <linux-mm@kvack.org>;
        Mon, 04 Apr 2016 02:07:31 -0700 (PDT)
Date: Mon, 4 Apr 2016 18:07:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/hwpoison: fix wrong num_poisoned_pages account
Message-ID: <20160404090738.GB12898@bbox>
References: <1459749992-7861-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459749992-7861-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, stable@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Mon, Apr 04, 2016 at 03:06:32PM +0900, Minchan Kim wrote:
> Currently, migration code increases num_poisoned_pages on failed
> migration page as well as successfully migrated one at the trial
> of memory-failure. It will make the stat wrong.
> 
> As well, it marks page as PG_HWPoison even if the migration trial
> failed. It would make we cannot recover the corrupted page using
> memory-failure facility.
> 
> This patches fixes it.
> 
> Cc: stable@vger.kernel.org
> Reported-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Hello Andrew,

This patch will make conflict with current mmotm which has
my non-lru page migration work.
It's okay to drop my non-lru page migration work to apply this
bug fix patch in current mmotm because I will try to support
userspace mapped drvier non-lru page Vlastimil pointed out
in that thread.

Thanks.

> ---
>  mm/migrate.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 6c822a7b27e0..f9dfb18a4eba 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -975,7 +975,13 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>  		dec_zone_page_state(page, NR_ISOLATED_ANON +
>  				page_is_file_cache(page));
>  		/* Soft-offlined page shouldn't go through lru cache list */
> -		if (reason == MR_MEMORY_FAILURE) {
> +		if (reason == MR_MEMORY_FAILURE && rc == MIGRATEPAGE_SUCCESS) {
> +			/*
> +			 * With this release, we free successfully migrated
> +			 * page and set PG_HWPoison on just freed page
> +			 * intentionally. Although it's rather weird, it's how
> +			 * HWPoison flag works at the moment.
> +			 */
>  			put_page(page);
>  			if (!test_set_page_hwpoison(page))
>  				num_poisoned_pages_inc();
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
