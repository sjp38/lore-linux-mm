Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f42.google.com (mail-lf0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id BAF026B0038
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 06:18:02 -0400 (EDT)
Received: by lffy185 with SMTP id y185so77319467lff.2
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 03:18:02 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id u129si12393319lfd.130.2015.10.16.03.17.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 16 Oct 2015 03:18:01 -0700 (PDT)
Message-ID: <5620CDA3.9050006@huawei.com>
Date: Fri, 16 Oct 2015 18:12:51 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: reset migratetype if the range spans two pageblocks
References: <5620CC36.4090107@huawei.com>
In-Reply-To: <5620CC36.4090107@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, mhocko@suse.com, js1304@gmail.com, Johannes Weiner <hannes@cmpxchg.org>, alexander.h.duyck@redhat.com, zhongjiang@huawei.com
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/10/16 18:06, Xishi Qiu wrote:

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
> 
> However,if we change the hotpath, it will be performance degradation,
> so any better ideas?
> 

How about using get_pfnblock_migratetype() to get the pageblock's
migratetype first, and compare them?

Thanks,
Xishi Qiu

> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  mm/page_alloc.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 48aaf7b..5c91348 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -726,6 +726,9 @@ static inline void __free_one_page(struct page *page,
>  	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
>  out:
>  	zone->free_area[order].nr_free++;
> +	/* If the range spans two pageblocks, reset the migratetype. */
> +	if (order > pageblock_order)
> +		change_pageblock_range(page, order, migratetype);
>  }
>  
>  static inline int free_pages_check(struct page *page)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
