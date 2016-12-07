Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E2A406B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 03:33:13 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id o2so73916067wje.5
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 00:33:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bd8si23447562wjb.101.2016.12.07.00.33.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 00:33:12 -0800 (PST)
Subject: Re: [PATCH] mm: page_idle_get_page() does not need zone_lru_lock
References: <alpine.LSU.2.11.1612052152560.13021@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fad1e67f-46cf-0eab-346a-79d36d0757f1@suse.cz>
Date: Wed, 7 Dec 2016 09:32:58 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1612052152560.13021@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org

On 12/06/2016 06:55 AM, Hugh Dickins wrote:
> Rechecking PageLRU() after get_page_unless_zero() may have value, but
> holding zone_lru_lock around that serves no useful purpose: delete it.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
> 
>  mm/page_idle.c |    4 ----
>  1 file changed, 4 deletions(-)
> 
> --- 4.9-rc8/mm/page_idle.c	2016-10-02 16:24:33.000000000 -0700
> +++ linux/mm/page_idle.c	2016-12-05 19:44:32.646625435 -0800
> @@ -30,7 +30,6 @@
>  static struct page *page_idle_get_page(unsigned long pfn)
>  {
>  	struct page *page;
> -	struct zone *zone;
>  
>  	if (!pfn_valid(pfn))
>  		return NULL;
> @@ -40,13 +39,10 @@ static struct page *page_idle_get_page(u
>  	    !get_page_unless_zero(page))
>  		return NULL;
>  
> -	zone = page_zone(page);
> -	spin_lock_irq(zone_lru_lock(zone));
>  	if (unlikely(!PageLRU(page))) {
>  		put_page(page);
>  		page = NULL;
>  	}
> -	spin_unlock_irq(zone_lru_lock(zone));
>  	return page;
>  }
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
