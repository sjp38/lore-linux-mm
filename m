Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 895D76B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 06:23:10 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id w16so35352609lfd.0
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 03:23:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l186si15326325wml.25.2016.06.03.03.23.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Jun 2016 03:23:09 -0700 (PDT)
Subject: Re: [PATCH v2 2/7] mm/page_owner: initialize page owner without
 holding the zone lock
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464230275-25791-2-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b548cad8-e7d1-b742-cb29-caf6263cc65d@suse.cz>
Date: Fri, 3 Jun 2016 12:23:06 +0200
MIME-Version: 1.0
In-Reply-To: <1464230275-25791-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/26/2016 04:37 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> It's not necessary to initialized page_owner with holding the zone lock.
> It would cause more contention on the zone lock although it's not
> a big problem since it is just debug feature. But, it is better
> than before so do it. This is also preparation step to use stackdepot
> in page owner feature. Stackdepot allocates new pages when there is no
> reserved space and holding the zone lock in this case will cause deadlock.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/compaction.c     | 3 +++
>  mm/page_alloc.c     | 2 --
>  mm/page_isolation.c | 9 ++++++---
>  3 files changed, 9 insertions(+), 5 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 8e013eb..6043ef8 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -20,6 +20,7 @@
>  #include <linux/kasan.h>
>  #include <linux/kthread.h>
>  #include <linux/freezer.h>
> +#include <linux/page_owner.h>
>  #include "internal.h"
>
>  #ifdef CONFIG_COMPACTION
> @@ -80,6 +81,8 @@ static void map_pages(struct list_head *list)
>  		arch_alloc_page(page, order);
>  		kernel_map_pages(page, nr_pages, 1);
>  		kasan_alloc_pages(page, order);
> +
> +		set_page_owner(page, order, __GFP_MOVABLE);
>  		if (order)
>  			split_page(page, order);
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5134f46..1b1ca57 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2507,8 +2507,6 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  	zone->free_area[order].nr_free--;
>  	rmv_page_order(page);
>
> -	set_page_owner(page, order, __GFP_MOVABLE);
> -
>  	/* Set the pageblock if the isolated page is at least a pageblock */
>  	if (order >= pageblock_order - 1) {
>  		struct page *endpage = page + (1 << order) - 1;
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 612122b..927f5ee 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -7,6 +7,7 @@
>  #include <linux/pageblock-flags.h>
>  #include <linux/memory.h>
>  #include <linux/hugetlb.h>
> +#include <linux/page_owner.h>
>  #include "internal.h"
>
>  #define CREATE_TRACE_POINTS
> @@ -108,8 +109,6 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>  			if (pfn_valid_within(page_to_pfn(buddy)) &&
>  			    !is_migrate_isolate_page(buddy)) {
>  				__isolate_free_page(page, order);
> -				kernel_map_pages(page, (1 << order), 1);
> -				set_page_refcounted(page);
>  				isolated_page = page;
>  			}
>  		}
> @@ -128,8 +127,12 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>  	zone->nr_isolate_pageblock--;
>  out:
>  	spin_unlock_irqrestore(&zone->lock, flags);
> -	if (isolated_page)
> +	if (isolated_page) {
> +		kernel_map_pages(page, (1 << order), 1);

So why we don't need the other stuff done by e.g. map_pages()? For example 
arch_alloc_page() and kasan_alloc_pages(). Maybe kasan_free_pages() (called 
below via __free_pages() I assume) now doesn't check if the allocation part was 
done. But maybe it will start doing that?

See how the multiple places doing similar stuff is fragile? :(

> +		set_page_refcounted(page);
> +		set_page_owner(page, order, __GFP_MOVABLE);
>  		__free_pages(isolated_page, order);

This mixing of "isolated_page" and "page" is not a bug, but quite ugly. Can't 
isolated_page variable just be a bool?

> +	}
>  }
>
>  static inline struct page *
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
