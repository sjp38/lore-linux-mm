Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 833F56B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 03:12:20 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w13so1663340wmw.0
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 00:12:20 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id fi2si4135275wjb.206.2016.12.02.00.12.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 00:12:19 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id kp2so29220751wjc.0
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 00:12:19 -0800 (PST)
Date: Fri, 2 Dec 2016 09:12:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, page_alloc: Keep pcp count and list contents in
 sync if struct page is corrupted
Message-ID: <20161202081216.GA6830@dhcp22.suse.cz>
References: <20161202002244.18453-1-mgorman@techsingularity.net>
 <20161202002244.18453-2-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161202002244.18453-2-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Fri 02-12-16 00:22:43, Mel Gorman wrote:
> Vlastimil Babka pointed out that commit 479f854a207c ("mm, page_alloc:
> defer debugging checks of pages allocated from the PCP") will allow the
> per-cpu list counter to be out of sync with the per-cpu list contents
> if a struct page is corrupted. This patch keeps the accounting in sync.
>
> Fixes: 479f854a207c ("mm, page_alloc: defer debugging checks of pages allocated from the PCP")
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> cc: stable@vger.kernel.org [4.7+]

I am trying to think about what would happen if we did go out of sync
and cannot spot a problem. Vlastimil has mentioned something about
free_pcppages_bulk looping for ever but I cannot see it happening right
now. So why is this worth stable backport?

Anyway the patch looks correct
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6de9440e3ae2..777ed59570df 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2192,7 +2192,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  			unsigned long count, struct list_head *list,
>  			int migratetype, bool cold)
>  {
> -	int i;
> +	int i, alloced = 0;
>  
>  	spin_lock(&zone->lock);
>  	for (i = 0; i < count; ++i) {
> @@ -2217,13 +2217,14 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  		else
>  			list_add_tail(&page->lru, list);
>  		list = &page->lru;
> +		alloced++;
>  		if (is_migrate_cma(get_pcppage_migratetype(page)))
>  			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
>  					      -(1 << order));
>  	}
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));

I guess this deserves a comment (i vs. alloced is confusing and I bet
somebody will come up with a cleanup...). We leak corrupted pages
intentionally so we should uncharge them from the NR_FREE_PAGES.

>  	spin_unlock(&zone->lock);
> -	return i;
> +	return alloced;
>  }
>  
>  #ifdef CONFIG_NUMA
> -- 
> 2.10.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
