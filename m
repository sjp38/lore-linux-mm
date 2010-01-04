Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F34BF600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 23:10:23 -0500 (EST)
Received: by yxe36 with SMTP id 36so15932981yxe.11
        for <linux-mm@kvack.org>; Sun, 03 Jan 2010 20:10:22 -0800 (PST)
Message-ID: <4B416A28.70806@gmail.com>
Date: Mon, 04 Jan 2010 12:10:16 +0800
From: shijie8 <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm : add check for the return value
References: <1262571730-2778-1-git-send-email-shijie8@gmail.com> <20100104122138.f54b7659.minchan.kim@barrios-desktop>
In-Reply-To: <20100104122138.f54b7659.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> I think it's not desirable to add new branch in hot-path even though
> we could avoid that.
>
> How about this?
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4e4b5b3..87976ad 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1244,6 +1244,9 @@ again:
>          return page;
>
>   failed:
>    
you miss anther place where also  uses "goto failed".
> +       spin_lock(&zone->lock);
> +       __mod_zone_page_state(zone, NR_FREE_PAGES, 1<<  order);
> +       spin_unlock(&zone->lock);
>          local_irq_restore(flags);
>          put_cpu();
>          return NULL;
>
>    
I also thought  over your method before I sent the patch,  but there 
already exits a
"if (!page)" , I not sure whether my patch adds too much delay in hot-path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
