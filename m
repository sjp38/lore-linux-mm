Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31F286B0313
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 08:50:24 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 92so24616324wra.11
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 05:50:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f185si1213773wmg.188.2017.07.24.05.50.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 05:50:23 -0700 (PDT)
Date: Mon, 24 Jul 2017 14:50:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] mm, page_owner: don't grab zone->lock for
 init_pages_in_zone()
Message-ID: <20170724125015.GJ25221@dhcp22.suse.cz>
References: <20170720134029.25268-1-vbabka@suse.cz>
 <20170720134029.25268-4-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170720134029.25268-4-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>

On Thu 20-07-17 15:40:28, Vlastimil Babka wrote:
> init_pages_in_zone() is run under zone->lock, which means a long lock time and
> disabled interrupts on large machines. This is currently not an issue since it
> runs early in boot, but a later patch will change that.
> However, like other pfn scanners, we don't actually need zone->lock even when
> other cpus are running. The only potentially dangerous operation here is
> reading bogus buddy page owner due to race, and we already know how to handle
> that. The worse that can happen is that we skip some early allocated pages,
> which should not affect the debugging power of page_owner noticeably.

Makes sense to me
 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_owner.c | 16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 5aa21ca237d9..cf6568d1dc14 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -567,11 +567,17 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>  				continue;
>  
>  			/*
> -			 * We are safe to check buddy flag and order, because
> -			 * this is init stage and only single thread runs.
> +			 * To avoid having to grab zone->lock, be a little
> +			 * careful when reading buddy page order. The only
> +			 * danger is that we skip too much and potentially miss
> +			 * some early allocated pages, which is better than
> +			 * heavy lock contention.
>  			 */
>  			if (PageBuddy(page)) {
> -				pfn += (1UL << page_order(page)) - 1;
> +				unsigned long order = page_order_unsafe(page);
> +
> +				if (order > 0 && order < MAX_ORDER)
> +					pfn += (1UL << order) - 1;
>  				continue;
>  			}
>  
> @@ -590,6 +596,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>  			__set_page_owner_init(page_ext, init_handle);
>  			count++;
>  		}
> +		cond_resched();
>  	}
>  
>  	pr_info("Node %d, zone %8s: page owner found early allocated %lu pages\n",
> @@ -600,15 +607,12 @@ static void init_zones_in_node(pg_data_t *pgdat)
>  {
>  	struct zone *zone;
>  	struct zone *node_zones = pgdat->node_zones;
> -	unsigned long flags;
>  
>  	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
>  		if (!populated_zone(zone))
>  			continue;
>  
> -		spin_lock_irqsave(&zone->lock, flags);
>  		init_pages_in_zone(pgdat, zone);
> -		spin_unlock_irqrestore(&zone->lock, flags);
>  	}
>  }
>  
> -- 
> 2.13.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
