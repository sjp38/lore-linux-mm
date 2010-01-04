Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 62C62600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 22:21:50 -0500 (EST)
Received: by yxe36 with SMTP id 36so15866077yxe.11
        for <linux-mm@kvack.org>; Sun, 03 Jan 2010 19:21:48 -0800 (PST)
Date: Mon, 4 Jan 2010 12:21:38 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm : add check for the return value
Message-Id: <20100104122138.f54b7659.minchan.kim@barrios-desktop>
In-Reply-To: <1262571730-2778-1-git-send-email-shijie8@gmail.com>
References: <1262571730-2778-1-git-send-email-shijie8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Huang. 

On Mon,  4 Jan 2010 10:22:10 +0800
Huang Shijie <shijie8@gmail.com> wrote:

> When the `page' returned by __rmqueue() is NULL, the origin code
> still adds -(1 << order) to zone's NR_FREE_PAGES item.
> 
> The patch fixes it.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
> ---
>  mm/page_alloc.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4e9f5cc..620921d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1222,10 +1222,14 @@ again:
>  		}
>  		spin_lock_irqsave(&zone->lock, flags);
>  		page = __rmqueue(zone, order, migratetype);
> -		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
> -		spin_unlock(&zone->lock);
> -		if (!page)
> +		if (likely(page)) {
> +			__mod_zone_page_state(zone, NR_FREE_PAGES,
> +						-(1 << order));
> +			spin_unlock(&zone->lock);
> +		} else {
> +			spin_unlock(&zone->lock);
>  			goto failed;
> +		}
>  	}
>  
>  	__count_zone_vm_events(PGALLOC, zone, 1 << order);

I think it's not desirable to add new branch in hot-path even though
we could avoid that. 

How about this?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4e4b5b3..87976ad 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1244,6 +1244,9 @@ again:
        return page;
 
 failed:
+       spin_lock(&zone->lock);
+       __mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
+       spin_unlock(&zone->lock);
        local_irq_restore(flags);
        put_cpu();
        return NULL;




> -- 
> 1.6.5.2
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
