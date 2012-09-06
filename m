Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 380816B00C5
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 02:19:02 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B7DD53EE0BD
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 15:19:00 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 77F4245DEBA
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 15:19:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ED9645DEB2
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 15:19:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 27043E08005
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 15:19:00 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BC1EF1DB8044
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 15:18:59 +0900 (JST)
Message-ID: <50484044.1060308@jp.fujitsu.com>
Date: Thu, 06 Sep 2012 15:18:44 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] memory-hotplug: bug fix race between isolation
 and allocation
References: <1346908619-16056-1-git-send-email-minchan@kernel.org> <1346908619-16056-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1346908619-16056-4-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>

(2012/09/06 14:16), Minchan Kim wrote:
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

I agree this fix.

Maybe we (fujitsu) should revisit these logics around and make it cleaner....

Anyway, thank you!
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

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
>   			pfn += 1;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
