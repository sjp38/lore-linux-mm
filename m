Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 8987A6B0121
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 21:57:35 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 78D4B3EE0C5
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 10:57:33 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F3E245DE53
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 10:57:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BAE045DE4E
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 10:57:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D3011DB803E
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 10:57:33 +0900 (JST)
Received: from g01jpexchkw01.g01.fujitsu.local (g01jpexchkw01.g01.fujitsu.local [10.0.194.40])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D4E361DB803A
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 10:57:32 +0900 (JST)
Message-ID: <50513D6D.3030609@jp.fujitsu.com>
Date: Thu, 13 Sep 2012 10:57:01 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: refactor out __alloc_contig_migrate_alloc
References: <1347414231-31451-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1347414231-31451-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>

2012/09/12 10:43, Minchan Kim wrote:
> __alloc_contig_migrate_alloc can be used by memory-hotplug so
> refactor out(move + rename as a common name) it into
> page_isolation.c.
> 
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> 
> This patch is intended for preparing next bug fix patch.
> 
>   include/linux/page-isolation.h |    3 ++-
>   mm/page_alloc.c                |   14 +-------------
>   mm/page_isolation.c            |   11 +++++++++++
>   3 files changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index 105077a..1c82261 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -37,6 +37,7 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
>    */
>   int set_migratetype_isolate(struct page *page);
>   void unset_migratetype_isolate(struct page *page, unsigned migratetype);
> -
> +struct page *alloc_migrate_target(struct page *page, unsigned long private,
> +				int **resultp);
>   
>   #endif
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a4ff74e..6716023 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5648,18 +5648,6 @@ static unsigned long pfn_max_align_up(unsigned long pfn)
>   				pageblock_nr_pages));
>   }
>   
> -static struct page *
> -__alloc_contig_migrate_alloc(struct page *page, unsigned long private,
> -			     int **resultp)
> -{
> -	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
> -
> -	if (PageHighMem(page))
> -		gfp_mask |= __GFP_HIGHMEM;
> -
> -	return alloc_page(gfp_mask);
> -}
> -
>   /* [start, end) must belong to a single zone. */
>   static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
>   {
> @@ -5700,7 +5688,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
>   		}
>   
>   		ret = migrate_pages(&cc.migratepages,
> -				    __alloc_contig_migrate_alloc,
> +				    alloc_migrate_target,
>   				    0, false, MIGRATE_SYNC);
>   	}
>   
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 247d1f1..6936545 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -233,3 +233,14 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
>   	spin_unlock_irqrestore(&zone->lock, flags);
>   	return ret ? 0 : -EBUSY;
>   }
> +
> +struct page *alloc_migrate_target(struct page *page, unsigned long private,
> +                             int **resultp)
> +{
> +        gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
> +
> +        if (PageHighMem(page))
> +                gfp_mask |= __GFP_HIGHMEM;
> +
> +        return alloc_page(gfp_mask);
> +}
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
