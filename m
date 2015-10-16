Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 249936B0038
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 08:00:05 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so7272695wic.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 05:00:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hg7si23467494wjb.140.2015.10.16.05.00.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Oct 2015 05:00:03 -0700 (PDT)
Subject: Re: [PATCH] mm: reset migratetype if the range spans two pageblocks
References: <5620CC36.4090107@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5620E6BF.7090602@suse.cz>
Date: Fri, 16 Oct 2015 13:59:59 +0200
MIME-Version: 1.0
In-Reply-To: <5620CC36.4090107@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, mhocko@suse.com, js1304@gmail.com, Johannes Weiner <hannes@cmpxchg.org>, alexander.h.duyck@redhat.com, zhongjiang@huawei.com
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/16/2015 12:06 PM, Xishi Qiu wrote:
> __rmqueue_fallback() will change the migratetype of pageblock,
> so it is possible that two continuous pageblocks have different
> migratetypes.
>
> When freeing all pages of the two blocks, they will be merged
> to 4M, and added to the buddy list which the migratetype is the
> first pageblock's.
>
> If later alloc some pages and split the 4M, the second pageblock
> will be added to the buddy list, and the migratetype is the first
> pageblock's, so it is different from the its pageblock's.
>
> That means the page in buddy list's migratetype is different from
> the page in pageblock's migratetype. This will make confusion.

So what will be the bad effects of this confusion? There are many 
situations where a free page (of any size) will be on different list 
than the pageblock's migratetype.

In case of full free pageblock, it IIRC doesn't really matter on which 
freelist it is, as the fallback scenarios for all migratetypes are 
trivial and non-fragmenting (just grab the whole pageblock, which means 
the migratetype is updated).

Maybe compaction will get it wrong when deciding which pageblocks are 
suitable for scanning, but that's not critical.

> However,if we change the hotpath, it will be performance degradation,
> so any better ideas?

I don't see immediately a way to fix that outside of hotpath, and don't 
see the reasons being strong enough to fix it in the hotpath.

>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>   mm/page_alloc.c | 3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 48aaf7b..5c91348 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -726,6 +726,9 @@ static inline void __free_one_page(struct page *page,
>   	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
>   out:
>   	zone->free_area[order].nr_free++;
> +	/* If the range spans two pageblocks, reset the migratetype. */
> +	if (order > pageblock_order)
> +		change_pageblock_range(page, order, migratetype);
>   }
>
>   static inline int free_pages_check(struct page *page)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
