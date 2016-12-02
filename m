Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1706B0038
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 22:48:14 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x23so139978923pgx.6
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 19:48:14 -0800 (PST)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTP id s2si3101028pgd.57.2016.12.01.19.48.11
        for <linux-mm@kvack.org>;
        Thu, 01 Dec 2016 19:48:13 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161202002244.18453-1-mgorman@techsingularity.net> <20161202002244.18453-2-mgorman@techsingularity.net>
In-Reply-To: <20161202002244.18453-2-mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] mm, page_alloc: Keep pcp count and list contents in sync if struct page is corrupted
Date: Fri, 02 Dec 2016 11:47:53 +0800
Message-ID: <01d601d24c4e$dca6e190$95f4a4b0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@techsingularity.net>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Christoph Lameter' <cl@linux.com>, 'Michal Hocko' <mhocko@suse.com>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Jesper Dangaard Brouer' <brouer@redhat.com>, 'Linux-MM' <linux-mm@kvack.org>, 'Linux-Kernel' <linux-kernel@vger.kernel.org>

On Friday, December 02, 2016 8:23 AM Mel Gorman wrote:
> Vlastimil Babka pointed out that commit 479f854a207c ("mm, page_alloc:
> defer debugging checks of pages allocated from the PCP") will allow the
> per-cpu list counter to be out of sync with the per-cpu list contents
> if a struct page is corrupted. This patch keeps the accounting in sync.
> 
> Fixes: 479f854a207c ("mm, page_alloc: defer debugging checks of pages allocated from the PCP")
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> cc: stable@vger.kernel.org [4.7+]
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

Now i is a pure index, yes?

>  	spin_unlock(&zone->lock);
> -	return i;
> +	return alloced;
>  }
> 
>  #ifdef CONFIG_NUMA
> --
> 2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
