Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E0703440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 10:39:56 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id f66so2354610oib.1
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 07:39:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d70si2189223oih.411.2017.11.08.07.39.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 07:39:55 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH RFC] mm/memory_hotplug: make it possible to offline blocks with reserved pages
References: <20171108130155.25499-1-vkuznets@redhat.com>
	<20171108142528.vsrkkqw6fihxdjio@dhcp22.suse.cz>
Date: Wed, 08 Nov 2017 16:39:49 +0100
In-Reply-To: <20171108142528.vsrkkqw6fihxdjio@dhcp22.suse.cz> (Michal Hocko's
	message of "Wed, 8 Nov 2017 15:25:28 +0100")
Message-ID: <87y3nglqyi.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Alex Ng <alexng@microsoft.com>

Michal Hocko <mhocko@kernel.org> writes:

> On Wed 08-11-17 14:01:55, Vitaly Kuznetsov wrote:
>> Hyper-V balloon driver needs to hotplug memory in smaller chunks and to
>> workaround Linux's 128Mb allignment requirement so it does a trick: partly
>> populated 128Mb blocks are added and then a custom online_page_callback
>> hook checks if the particular page is 'backed' during onlining, in case it
>> is not backed it is left in Reserved state. When the host adds more pages
>> to the block we bring them online from the driver (see
>> hv_bring_pgs_online()/hv_page_online_one() in drivers/hv/hv_balloon.c).
>> Eventually the whole block becomes fully populated and we hotplug the next
>> 128Mb. This all works for quite some time already.
>
> Why does HyperV needs to workaround the section size limit in the first
> place? We are allocation memmap for the whole section anyway so it won't
> save any memory. So the whole thing sounds rather dubious to me.
>

Memory hotplug requirements in Windows are different, they have 2Mb
granularity, not 128Mb like we have in Linux x86.

Imagine there's a request to add 32Mb of memory comming from the
Hyper-V host. What can we do? Don't add anything at all and wait till
we're suggested to add > 128Mb and then add a section or the current
approach.

>> What is not working is offlining of such partly populated blocks:
>> check_pages_isolated_cb() callback will not pass with a sinle Reserved page
>> and we end up with -EBUSY. However, there's no reason to fail offlining in
>> this case: these pages are already offline, we may just skip them. Add the
>> appropriate workaround to test_pages_isolated().
>
> How do you recognize pages reserved by other users. You cannot simply
> remove them, it would just blow up.
>

I exepcted sumothing like that, thus RFC. Is there a way to detect pages
which were never onlined? E.g. it is Reserved and count == 0?

>> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
>> ---
>> RFC part:
>> - Other usages of Reserved pages making offlining blocks with them a no-go
>>   may exist.
>> - I'm not exactly sure that adding another parameter to
>>   test_pages_isolated() is a good idea, we may go with a single flag for
>>   both Reserved and HwPoisoned pages: we have just two call sites and they
>>   have opposite needs (true, true in one case and false, false in the
>>   other).
>> ---
>>  include/linux/page-isolation.h |  2 +-
>>  mm/memory_hotplug.c            |  2 +-
>>  mm/page_alloc.c                |  8 +++++++-
>>  mm/page_isolation.c            | 11 ++++++++---
>>  4 files changed, 17 insertions(+), 6 deletions(-)
>> 
>> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
>> index 05a04e603686..daba12a59574 100644
>> --- a/include/linux/page-isolation.h
>> +++ b/include/linux/page-isolation.h
>> @@ -61,7 +61,7 @@ undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>>   * Test all pages in [start_pfn, end_pfn) are isolated or not.
>>   */
>>  int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
>> -			bool skip_hwpoisoned_pages);
>> +			bool skip_hwpoisoned_pages, bool skip_reserved_pages);
>>  
>>  struct page *alloc_migrate_target(struct page *page, unsigned long private,
>>  				int **resultp);
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index d4b5f29906b9..5b7d1482804f 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1467,7 +1467,7 @@ check_pages_isolated_cb(unsigned long start_pfn, unsigned long nr_pages,
>>  {
>>  	int ret;
>>  	long offlined = *(long *)data;
>> -	ret = test_pages_isolated(start_pfn, start_pfn + nr_pages, true);
>> +	ret = test_pages_isolated(start_pfn, start_pfn + nr_pages, true, true);
>>  	offlined = nr_pages;
>>  	if (!ret)
>>  		*(long *)data += offlined;
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 77e4d3c5c57b..b475928c476c 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -7632,7 +7632,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>>  	}
>>  
>>  	/* Make sure the range is really isolated. */
>> -	if (test_pages_isolated(outer_start, end, false)) {
>> +	if (test_pages_isolated(outer_start, end, false, false)) {
>>  		pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
>>  			__func__, outer_start, end);
>>  		ret = -EBUSY;
>> @@ -7746,6 +7746,12 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>>  			continue;
>>  		}
>>  
>> +		/* Some pages might never be online, skip them */
>> +		if (unlikely(PageReserved(page))) {
>> +			pfn++;
>> +			continue;
>> +		}
>> +
>>  		BUG_ON(page_count(page));
>>  		BUG_ON(!PageBuddy(page));
>>  		order = page_order(page);
>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>> index 44f213935bf6..fd9c18e00b92 100644
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -233,7 +233,8 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>>   */
>>  static unsigned long
>>  __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>> -				  bool skip_hwpoisoned_pages)
>> +				  bool skip_hwpoisoned_pages,
>> +				  bool skip_reserved_pages)
>>  {
>>  	struct page *page;
>>  
>> @@ -253,6 +254,9 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>>  		else if (skip_hwpoisoned_pages && PageHWPoison(page))
>>  			/* A HWPoisoned page cannot be also PageBuddy */
>>  			pfn++;
>> +		else if (skip_reserved_pages && PageReserved(page))
>> +			/* Skipping Reserved pages */
>> +			pfn++;
>>  		else
>>  			break;
>>  	}
>> @@ -262,7 +266,7 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>>  
>>  /* Caller should ensure that requested range is in a single zone */
>>  int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
>> -			bool skip_hwpoisoned_pages)
>> +			bool skip_hwpoisoned_pages, bool skip_reserved_pages)
>>  {
>>  	unsigned long pfn, flags;
>>  	struct page *page;
>> @@ -285,7 +289,8 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
>>  	zone = page_zone(page);
>>  	spin_lock_irqsave(&zone->lock, flags);
>>  	pfn = __test_page_isolated_in_pageblock(start_pfn, end_pfn,
>> -						skip_hwpoisoned_pages);
>> +						skip_hwpoisoned_pages,
>> +						skip_reserved_pages);
>>  	spin_unlock_irqrestore(&zone->lock, flags);
>>  
>>  	trace_test_pages_isolated(start_pfn, end_pfn, pfn);
>> -- 
>> 2.13.6
>> 

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
