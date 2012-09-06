Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 8B4CF6B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 03:18:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BCCA13EE0BD
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 16:18:14 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A1DD945DE50
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 16:18:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 88B6345DE4D
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 16:18:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 72E3CE08003
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 16:18:14 +0900 (JST)
Received: from g01jpexchyt08.g01.fujitsu.local (g01jpexchyt08.g01.fujitsu.local [10.128.194.47])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 202511DB803C
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 16:18:14 +0900 (JST)
Message-ID: <50484E22.5010304@jp.fujitsu.com>
Date: Thu, 6 Sep 2012 16:17:54 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] memory-hotplug: bug fix race between isolation
 and allocation
References: <1346908619-16056-1-git-send-email-minchan@kernel.org> <1346908619-16056-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1346908619-16056-4-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>

Hi Minchan,

2012/09/06 14:16, Minchan Kim wrote:
> Like below, memory-hotplug makes race between page-isolation
> and page-allocation so it can hit BUG_ON in __offline_isolated_pages.
> 
> 	CPU A					CPU B
> 
> start_isolate_page_range
> set_migratetype_isolate
> spin_lock_irqsave(zone->lock)
> 
> 				free_hot_cold_page(Page A)
> 				/* without zone->lock */
> 				migratetype = get_pageblock_migratetype(Page A);
> 				/*
> 				 * Page could be moved into MIGRATE_MOVABLE
> 				 * of per_cpu_pages
> 				 */
> 				list_add_tail(&page->lru, &pcp->lists[migratetype]);
> 
> set_pageblock_isolate
> move_freepages_block
> drain_all_pages
> 
> 				/* Page A could be in MIGRATE_MOVABLE of free_list. */
> 
> check_pages_isolated
> __test_page_isolated_in_pageblock
> /*
>   * We can't catch freed page which
>   * is free_list[MIGRATE_MOVABLE]
>   */
> if (PageBuddy(page A))
> 	pfn += 1 << page_order(page A);
> 
> 				/* So, Page A could be allocated */
> 
> __offline_isolated_pages
> /*
>   * BUG_ON hit or offline page
>   * which is used by someone
>   */
> BUG_ON(!PageBuddy(page A));
> 
> This patch checks page's migratetype in freelist in __test_page_isolated_in_pageblock.
> So now __test_page_isolated_in_pageblock can check the page caused by above race and
> can fail of memory offlining.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>   mm/page_isolation.c |    5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 87a7929..7ba7405 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -193,8 +193,11 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
>   			continue;
>   		}
>   		page = pfn_to_page(pfn);
> -		if (PageBuddy(page))
> +		if (PageBuddy(page)) {
> +			if (get_freepage_migratetype(page) != MIGRATE_ISOLATE)
> +				break;
>   			pfn += 1 << page_order(page);
> +		}

>   		else if (page_count(page) == 0 &&
>   			get_freepage_migratetype(page) == MIGRATE_ISOLATE)

When do the if statement, the page may be used by someone.
In this case, page->index may have some number. If the number is same as
MIGRATE_ISOLATE, the code goes worng.

Thanks,
Yasuaki Ishimatsu

>   			pfn += 1;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
