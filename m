Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 001A36B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 06:08:52 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id j10so82547807wjb.3
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 03:08:52 -0800 (PST)
Received: from smtp29.i.mail.ru (smtp29.i.mail.ru. [94.100.177.89])
        by mx.google.com with ESMTPS id t69si11167430lfi.231.2016.12.07.03.08.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 03:08:51 -0800 (PST)
Date: Wed, 7 Dec 2016 14:08:46 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH] mm: page_idle_get_page() does not need zone_lru_lock
Message-ID: <20161207110845.GA4655@esperanza>
References: <alpine.LSU.2.11.1612052152560.13021@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1612052152560.13021@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org

Hello,

On Mon, Dec 05, 2016 at 09:55:10PM -0800, Hugh Dickins wrote:
> Rechecking PageLRU() after get_page_unless_zero() may have value, but
> holding zone_lru_lock around that serves no useful purpose: delete it.

IIRC this lock/unlock was added on purpose, by request from Minchan. It
serves as a barrier that guarantees that all page fields (specifically
->mapping in case of anonymous pages) have been properly initialized by
the time we pass it to rmap_walk(). Here's a reference to the thread
where this problem was discussed:

  http://lkml.kernel.org/r/<20150430082531.GD21771@blaptop>

> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
