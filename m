Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 8BC076B0068
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 19:36:07 -0400 (EDT)
Date: Fri, 7 Sep 2012 08:37:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 3/3] memory-hotplug: bug fix race between isolation
 and allocation
Message-ID: <20120906233745.GE16231@bbox>
References: <1346908619-16056-1-git-send-email-minchan@kernel.org>
 <1346908619-16056-4-git-send-email-minchan@kernel.org>
 <50484E22.5010304@jp.fujitsu.com>
 <20120906073020.GB16231@bbox>
 <5048697F.5060200@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5048697F.5060200@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>

Hello Yasuaki,

On Thu, Sep 06, 2012 at 06:14:39PM +0900, Yasuaki Ishimatsu wrote:
> Hi, Minchan,
> 
> 2012/09/06 16:30, Minchan Kim wrote:
> >Hello Yasuaki,
> >
> >On Thu, Sep 06, 2012 at 04:17:54PM +0900, Yasuaki Ishimatsu wrote:
> >>Hi Minchan,
> >>
> >>2012/09/06 14:16, Minchan Kim wrote:
> >>>Like below, memory-hotplug makes race between page-isolation
> >>>and page-allocation so it can hit BUG_ON in __offline_isolated_pages.
> >>>
> >>>	CPU A					CPU B
> >>>
> >>>start_isolate_page_range
> >>>set_migratetype_isolate
> >>>spin_lock_irqsave(zone->lock)
> >>>
> >>>				free_hot_cold_page(Page A)
> >>>				/* without zone->lock */
> >>>				migratetype = get_pageblock_migratetype(Page A);
> >>>				/*
> >>>				 * Page could be moved into MIGRATE_MOVABLE
> >>>				 * of per_cpu_pages
> >>>				 */
> >>>				list_add_tail(&page->lru, &pcp->lists[migratetype]);
> >>>
> >>>set_pageblock_isolate
> >>>move_freepages_block
> >>>drain_all_pages
> >>>
> >>>				/* Page A could be in MIGRATE_MOVABLE of free_list. */
> >>>
> >>>check_pages_isolated
> >>>__test_page_isolated_in_pageblock
> >>>/*
> >>>   * We can't catch freed page which
> >>>   * is free_list[MIGRATE_MOVABLE]
> >>>   */
> >>>if (PageBuddy(page A))
> >>>	pfn += 1 << page_order(page A);
> >>>
> >>>				/* So, Page A could be allocated */
> >>>
> >>>__offline_isolated_pages
> >>>/*
> >>>   * BUG_ON hit or offline page
> >>>   * which is used by someone
> >>>   */
> >>>BUG_ON(!PageBuddy(page A));
> >>>
> >>>This patch checks page's migratetype in freelist in __test_page_isolated_in_pageblock.
> >>>So now __test_page_isolated_in_pageblock can check the page caused by above race and
> >>>can fail of memory offlining.
> >>>
> >>>Signed-off-by: Minchan Kim <minchan@kernel.org>
> >>>---
> >>>   mm/page_isolation.c |    5 ++++-
> >>>   1 file changed, 4 insertions(+), 1 deletion(-)
> >>>
> >>>diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> >>>index 87a7929..7ba7405 100644
> >>>--- a/mm/page_isolation.c
> >>>+++ b/mm/page_isolation.c
> >>>@@ -193,8 +193,11 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
> >>>   			continue;
> >>>   		}
> >>>   		page = pfn_to_page(pfn);
> >>>-		if (PageBuddy(page))
> >>>+		if (PageBuddy(page)) {
> >>>+			if (get_freepage_migratetype(page) != MIGRATE_ISOLATE)
> >>>+				break;
> >>>   			pfn += 1 << page_order(page);
> >>>+		}
> >>
> >>>   		else if (page_count(page) == 0 &&
> >>>   			get_freepage_migratetype(page) == MIGRATE_ISOLATE)
> >>
> >>When do the if statement, the page may be used by someone.
> >
> >I can't understand your point.
> >We already hold zone->lock so that allocator and this function should be atomic
> >when the page is in free_list.
> >If I miss something, could you elaborate it more?
> 
> According to your description, the page might be allocated by someone
> at this point. So some value might be set the page->index by the

It seems you are misunderstanding my point.
Before my patch, Yes. It could be allocated by someone but
after my patch, it couldn't be allocated and inconsistency between
pageblock's migratetype and page's migratetype is detected so that
memory offline would be just failed simply.

> intended purpose. Thus page->index has the potential to become
> MIGRATE_ISOLATE value.
> 
> Thanks,
> Yasuaki Ishimatsu
> 
> >
> >>In this case, page->index may have some number. If the number is same as
> >>MIGRATE_ISOLATE, the code goes worng.
> >>
> >>Thanks,
> >>Yasuaki Ishimatsu
> >>
> >>>   			pfn += 1;
> >>>
> >>
> >>
> >>--
> >>To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >>the body to majordomo@kvack.org.  For more info on Linux MM,
> >>see: http://www.linux-mm.org/ .
> >>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
