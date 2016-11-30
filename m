Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DCA0E6B025E
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:59:55 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 3so29302143pgd.3
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:59:55 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id w4si7966004wmg.1.2016.11.30.06.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 06:59:55 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id he10so8311922wjc.2
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:59:54 -0800 (PST)
Date: Wed, 30 Nov 2016 15:59:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
Message-ID: <20161130145952.GI18432@dhcp22.suse.cz>
References: <20161127131954.10026-1-mgorman@techsingularity.net>
 <20161130130549.GE18432@dhcp22.suse.cz>
 <20161130141613.gnf63khbrzrps7ip@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130141613.gnf63khbrzrps7ip@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed 30-11-16 14:16:13, Mel Gorman wrote:
> On Wed, Nov 30, 2016 at 02:05:50PM +0100, Michal Hocko wrote:
[...]
> > But...  Unless I am missing something this effectively means that we do
> > not exercise high order atomic reserves. Shouldn't we fallback to
> > the locked __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC) for
> > order > 0 && ALLOC_HARDER ? Or is this just hidden in some other code
> > path which I am not seeing?
> > 
> 
> Good spot, would this be acceptable to you?

It's not a queen of beauty but it works. A more elegant solution would
require more surgery I guess which is probably not worth it at this
stage.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 91dc68c2a717..94808f565f74 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2609,9 +2609,18 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>  				int nr_pages = rmqueue_bulk(zone, order,
>  						pcp->batch, list,
>  						migratetype, cold);
> -				pcp->count += (nr_pages << order);
> -				if (unlikely(list_empty(list)))
> +				if (unlikely(list_empty(list))) {
> +					/*
> +					 * Retry high-order atomic allocs
> +					 * from the buddy list which may
> +					 * use MIGRATE_HIGHATOMIC.
> +					 */
> +					if (order && (alloc_flags & ALLOC_HARDER))
> +						goto try_buddylist;
> +
>  					goto failed;
> +				}
> +				pcp->count += (nr_pages << order);
>  			}
>  
>  			if (cold)
> @@ -2624,6 +2633,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>  
>  		} while (check_new_pcp(page));
>  	} else {
> +try_buddylist:
>  		/*
>  		 * We most definitely don't want callers attempting to
>  		 * allocate greater than order-1 page units with __GFP_NOFAIL.
> -- 
> Mel Gorman
> SUSE Labs
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
