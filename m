Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4909B6B026E
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 08:13:27 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c206so45009599wme.3
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 05:13:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si1966747wra.193.2017.01.26.05.13.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 05:13:25 -0800 (PST)
Date: Thu, 26 Jan 2017 14:13:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/5] mm: vmscan: scan dirty pages even in laptop mode
Message-ID: <20170126131322.GA7827@dhcp22.suse.cz>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-2-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170123181641.23938-2-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon 23-01-17 13:16:37, Johannes Weiner wrote:
> We have an elaborate dirty/writeback throttling mechanism inside the
> reclaim scanner, but for that to work the pages have to go through
> shrink_page_list() and get counted for what they are. Otherwise, we
> mess up the LRU order and don't match reclaim speed to writeback.
> 
> Especially during deactivation, there is never a reason to skip dirty
> pages; nothing is even trying to write them out from there. Don't mess
> up the LRU order for nothing, shuffle these pages along.

absolutely agreed.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mmzone.h |  2 --
>  mm/vmscan.c            | 14 ++------------
>  2 files changed, 2 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index df992831fde7..338a786a993f 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -236,8 +236,6 @@ struct lruvec {
>  #define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
>  #define LRU_ALL	     ((1 << NR_LRU_LISTS) - 1)
>  
> -/* Isolate clean file */
> -#define ISOLATE_CLEAN		((__force isolate_mode_t)0x1)
>  /* Isolate unmapped file */
>  #define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x2)
>  /* Isolate for asynchronous migration */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7bb23ff229b6..0d05f7f3b532 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -87,6 +87,7 @@ struct scan_control {
>  	/* The highest zone to isolate pages for reclaim from */
>  	enum zone_type reclaim_idx;
>  
> +	/* Writepage batching in laptop mode; RECLAIM_WRITE */
>  	unsigned int may_writepage:1;
>  
>  	/* Can mapped pages be reclaimed? */
> @@ -1373,13 +1374,10 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
>  	 * wants to isolate pages it will be able to operate on without
>  	 * blocking - clean pages for the most part.
>  	 *
> -	 * ISOLATE_CLEAN means that only clean pages should be isolated. This
> -	 * is used by reclaim when it is cannot write to backing storage
> -	 *
>  	 * ISOLATE_ASYNC_MIGRATE is used to indicate that it only wants to pages
>  	 * that it is possible to migrate without blocking
>  	 */
> -	if (mode & (ISOLATE_CLEAN|ISOLATE_ASYNC_MIGRATE)) {
> +	if (mode & ISOLATE_ASYNC_MIGRATE) {
>  		/* All the caller can do on PageWriteback is block */
>  		if (PageWriteback(page))
>  			return ret;
> @@ -1387,10 +1385,6 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
>  		if (PageDirty(page)) {
>  			struct address_space *mapping;
>  
> -			/* ISOLATE_CLEAN means only clean pages */
> -			if (mode & ISOLATE_CLEAN)
> -				return ret;
> -
>  			/*
>  			 * Only pages without mappings or that have a
>  			 * ->migratepage callback are possible to migrate
> @@ -1731,8 +1725,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  
>  	if (!sc->may_unmap)
>  		isolate_mode |= ISOLATE_UNMAPPED;
> -	if (!sc->may_writepage)
> -		isolate_mode |= ISOLATE_CLEAN;
>  
>  	spin_lock_irq(&pgdat->lru_lock);
>  
> @@ -1929,8 +1921,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  
>  	if (!sc->may_unmap)
>  		isolate_mode |= ISOLATE_UNMAPPED;
> -	if (!sc->may_writepage)
> -		isolate_mode |= ISOLATE_CLEAN;
>  
>  	spin_lock_irq(&pgdat->lru_lock);
>  
> -- 
> 2.11.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
