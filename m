Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F30C76B04A7
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 04:41:29 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q186so3498251pga.23
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 01:41:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si4735427pgc.765.2018.01.06.01.41.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 06 Jan 2018 01:41:28 -0800 (PST)
Date: Sat, 6 Jan 2018 10:41:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: ratelimit end_swap_bio_write() error
Message-ID: <20180106094124.GB16576@dhcp22.suse.cz>
References: <20180106043407.25193-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180106043407.25193-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 06-01-18 13:34:07, Sergey Senozhatsky wrote:
> Use the ratelimited printk() version for swap-device write error
> reporting. We can use ZRAM as a swap-device, and the tricky part
> here is that zsmalloc() stores compressed objects in memory, thus
> it has to allocates pages during swap-out. If the system is short
> on memory, then we begin to flood printk() log buffer with the
> same "Write-error on swap-device XXX" error messages and sometimes
> simply lockup the system.

Should we print an error in such a situation at all? Write-error
certainly sounds scare and it suggests something went really wrong.
My understading is that zram failed swap-out is not critical and
therefore the error message is not really useful. Or what should an
admin do when seeing it?

> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  mm/page_io.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_io.c b/mm/page_io.c
> index e93f1a4cacd7..422cd49bcba8 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -63,7 +63,7 @@ void end_swap_bio_write(struct bio *bio)
>  		 * Also clear PG_reclaim to avoid rotate_reclaimable_page()
>  		 */
>  		set_page_dirty(page);
> -		pr_alert("Write-error on swap-device (%u:%u:%llu)\n",
> +		pr_alert_ratelimited("Write-error on swap-device (%u:%u:%llu)\n",
>  			 MAJOR(bio_dev(bio)), MINOR(bio_dev(bio)),
>  			 (unsigned long long)bio->bi_iter.bi_sector);
>  		ClearPageReclaim(page);
> -- 
> 2.15.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
