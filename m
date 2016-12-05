Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5FE336B0038
	for <linux-mm@kvack.org>; Sun,  4 Dec 2016 22:39:45 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so490660742pfb.6
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 19:39:45 -0800 (PST)
Received: from out0-155.mail.aliyun.com (out0-155.mail.aliyun.com. [140.205.0.155])
        by mx.google.com with ESMTP id c22si13057972pfl.262.2016.12.04.19.39.43
        for <linux-mm@kvack.org>;
        Sun, 04 Dec 2016 19:39:44 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161202112951.23346-1-mgorman@techsingularity.net> <20161202112951.23346-2-mgorman@techsingularity.net>
In-Reply-To: <20161202112951.23346-2-mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] mm, page_alloc: Keep pcp count and list contents in sync if struct page is corrupted
Date: Mon, 05 Dec 2016 11:39:31 +0800
Message-ID: <026001d24ea9$30a895c0$91f9c140$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@techsingularity.net>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Christoph Lameter' <cl@linux.com>, 'Michal Hocko' <mhocko@suse.com>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Jesper Dangaard Brouer' <brouer@redhat.com>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, 'Linux-MM' <linux-mm@kvack.org>, 'Linux-Kernel' <linux-kernel@vger.kernel.org>

On Friday, December 02, 2016 7:30 PM Mel Gorman wrote:
> Vlastimil Babka pointed out that commit 479f854a207c ("mm, page_alloc:
> defer debugging checks of pages allocated from the PCP") will allow the
> per-cpu list counter to be out of sync with the per-cpu list contents
> if a struct page is corrupted.
> 
> The consequence is an infinite loop if the per-cpu lists get fully drained
> by free_pcppages_bulk because all the lists are empty but the count is
> positive. The infinite loop occurs here
> 
>                 do {
>                         batch_free++;
>                         if (++migratetype == MIGRATE_PCPTYPES)
>                                 migratetype = 0;
>                         list = &pcp->lists[migratetype];
>                 } while (list_empty(list));
> 
> From a user perspective, it's a bad page warning followed by a soft lockup
> with interrupts disabled in free_pcppages_bulk().
> 
> This patch keeps the accounting in sync.
> 
> Fixes: 479f854a207c ("mm, page_alloc: defer debugging checks of pages allocated from the PCP")
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> cc: stable@vger.kernel.org [4.7+]
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/page_alloc.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6de9440e3ae2..34ada718ef47 100644
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
> @@ -2217,13 +2217,21 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  		else
>  			list_add_tail(&page->lru, list);
>  		list = &page->lru;
> +		alloced++;
>  		if (is_migrate_cma(get_pcppage_migratetype(page)))
>  			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
>  					      -(1 << order));
>  	}
> +
> +	/*
> +	 * i pages were removed from the buddy list even if some leak due
> +	 * to check_pcp_refill failing so adjust NR_FREE_PAGES based
> +	 * on i. Do not confuse with 'alloced' which is the number of
> +	 * pages added to the pcp list.
> +	 */
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
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
