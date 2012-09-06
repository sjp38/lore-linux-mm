Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 4FF6B6B00AD
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 22:35:52 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so2034690pbb.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 19:35:51 -0700 (PDT)
Message-ID: <50480BFB.8050501@gmail.com>
Date: Thu, 06 Sep 2012 10:35:39 +0800
From: qiuxishi <qiuxishi@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] memory-hotplug: bug fix race between isolation and
 allocation
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: Minchan Kim <minchan@kernel.org>, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, qiuxishi@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2012/9/5 17:40, Mel Gorman wrote:

> On Wed, Sep 05, 2012 at 04:26:02PM +0900, Minchan Kim wrote:
>> Like below, memory-hotplug makes race between page-isolation
>> and page-allocation so it can hit BUG_ON in __offline_isolated_pages.
>>
>> 	CPU A					CPU B
>>
>> start_isolate_page_range
>> set_migratetype_isolate
>> spin_lock_irqsave(zone->lock)
>>
>> 				free_hot_cold_page(Page A)
>> 				/* without zone->lock */
>> 				migratetype = get_pageblock_migratetype(Page A);
>> 				/*
>> 				 * Page could be moved into MIGRATE_MOVABLE
>> 				 * of per_cpu_pages
>> 				 */
>> 				list_add_tail(&page->lru, &pcp->lists[migratetype]);
>>
>> set_pageblock_isolate
>> move_freepages_block
>> drain_all_pages

I think here is the problem you want to fix, it is not sure that pcp will be moved
into MIGRATE_ISOLATE list. They may be moved into MIGRATE_MOVABLE list because
page_private() maybe 2, it uses page_private() not get_pageblock_migratetype()

So when finish migrating pages, the free pages from pcp may be allocated again, and
failed in check_pages_isolated().

drain_all_pages()
	drain_local_pages()
		drain_pages()
			free_pcppages_bulk()
				__free_one_page(page, zone, 0, page_private(page))

I reported this problem too. http://marc.info/?l=linux-mm&m=134555113706068&w=2
How about this change:
	free_pcppages_bulk()
		__free_one_page(page, zone, 0, get_pageblock_migratetype(page))

Thanks
Xishi Qiu

>>
>> 				/* Page A could be in MIGRATE_MOVABLE of free_list. */
>>
>> check_pages_isolated
>> __test_page_isolated_in_pageblock
>> /*
>>  * We can't catch freed page which
>>  * is free_list[MIGRATE_MOVABLE]
>>  */
>> if (PageBuddy(page A))
>> 	pfn += 1 << page_order(page A);
>>
>> 				/* So, Page A could be allocated */
>>
>> __offline_isolated_pages
>> /*
>>  * BUG_ON hit or offline page
>>  * which is used by someone
>>  */
>> BUG_ON(!PageBuddy(page A));
>>
>
> offline_page calling BUG_ON because someone allocated the page is
> ridiculous. I did not spot where that check is but it should be changed. The
> correct action is to retry the isolation.
>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>
> At no point in the changelog do you actually say what he patch does :/
>
>> ---
>>  mm/page_isolation.c |    5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>> index acf65a7..4699d1f 100644
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -196,8 +196,11 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
>>  			continue;
>>  		}
>>  		page = pfn_to_page(pfn);
>> -		if (PageBuddy(page))
>> +		if (PageBuddy(page)) {
>> +			if (get_page_migratetype(page) != MIGRATE_ISOLATE)
>> +				break;
>>  			pfn += 1 << page_order(page);
>> +		}
>
> It is possible the page is moved to the MIGRATE_ISOLATE list between when
> the page was freed to the buddy allocator and this check was made. The
> page->index information is stale and the impact is that the hotplug
> operation fails when it could have succeeded. That said, I think it is a
> very unlikely race that will never happen in practice.
>
> More importantly, the effect of this path is that EBUSY gets bubbled all
> the way up and the hotplug operations fails. This is fine but as the page
> is free at the time this problem is detected you also have the option
> of moving the PageBuddy page to the MIGRATE_ISOLATE list at this time
> if you take the zone lock. This will mean you need to change the name of
> test_pages_isolated() of course.
>
>>  		else if (page_count(page) == 0 &&
>>  				get_page_migratetype(page) == MIGRATE_ISOLATE)
>>  			pfn += 1;
>> --
>> 1.7.9.5
>>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
