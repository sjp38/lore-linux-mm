Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA5516B0033
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 23:34:32 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id v85so71814315oia.4
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 20:34:32 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id g77si13692140otg.222.2017.02.05.20.34.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 05 Feb 2017 20:34:31 -0800 (PST)
Subject: Re: [PATCH v6 4/4] mm/hotplug: enable memory hotplug for non-lru
 movable pages
References: <1486108770-630-1-git-send-email-xieyisheng1@huawei.com>
 <1486108770-630-5-git-send-email-xieyisheng1@huawei.com>
 <20170206032951.GA1659@hori1.linux.bs1.fc.nec.co.jp>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <58cd9f5c-9a66-ea12-89dd-182650dfe323@huawei.com>
Date: Mon, 6 Feb 2017 12:25:12 +0800
MIME-Version: 1.0
In-Reply-To: <20170206032951.GA1659@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "minchan@kernel.org" <minchan@kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "arbab@linux.vnet.ibm.com" <arbab@linux.vnet.ibm.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, "vkuznets@redhat.com" <vkuznets@redhat.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>

Hi Naoya Horiguchi,
Thanks for reviewing.

On 2017/2/6 11:29, Naoya Horiguchi wrote:
> On Fri, Feb 03, 2017 at 03:59:30PM +0800, Yisheng Xie wrote:
>> We had considered all of the non-lru pages as unmovable before commit
>> bda807d44454 ("mm: migrate: support non-lru movable page migration").  But
>> now some of non-lru pages like zsmalloc, virtio-balloon pages also become
>> movable.  So we can offline such blocks by using non-lru page migration.
>>
>> This patch straightforwardly adds non-lru migration code, which means
>> adding non-lru related code to the functions which scan over pfn and
>> collect pages to be migrated and isolate them before migration.
>>
>> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Andi Kleen <ak@linux.intel.com>
>> Cc: Hanjun Guo <guohanjun@huawei.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Mel Gorman <mgorman@techsingularity.net>
>> Cc: Reza Arbab <arbab@linux.vnet.ibm.com>
>> Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
>> Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
>> Cc: Xishi Qiu <qiuxishi@huawei.com>
>> ---
>>  mm/memory_hotplug.c | 28 +++++++++++++++++-----------
>>  mm/page_alloc.c     |  8 ++++++--
>>  2 files changed, 23 insertions(+), 13 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index ca2723d..ea1be08 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1516,10 +1516,10 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
>>  }
>>  
>>  /*
>> - * Scan pfn range [start,end) to find movable/migratable pages (LRU pages
>> - * and hugepages). We scan pfn because it's much easier than scanning over
>> - * linked list. This function returns the pfn of the first found movable
>> - * page if it's found, otherwise 0.
>> + * Scan pfn range [start,end) to find movable/migratable pages (LRU pages,
>> + * non-lru movable pages and hugepages). We scan pfn because it's much
>> + * easier than scanning over linked list. This function returns the pfn
>> + * of the first found movable page if it's found, otherwise 0.
>>   */
>>  static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>>  {
>> @@ -1530,6 +1530,8 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>>  			page = pfn_to_page(pfn);
>>  			if (PageLRU(page))
>>  				return pfn;
>> +			if (__PageMovable(page))
>> +				return pfn;
>>  			if (PageHuge(page)) {
>>  				if (page_huge_active(page))
>>  					return pfn;
>> @@ -1606,21 +1608,25 @@ static struct page *new_node_page(struct page *page, unsigned long private,
>>  		if (!get_page_unless_zero(page))
>>  			continue;
>>  		/*
>> -		 * We can skip free pages. And we can only deal with pages on
>> -		 * LRU.
>> +		 * We can skip free pages. And we can deal with pages on
>> +		 * LRU and non-lru movable pages.
>>  		 */
>> -		ret = isolate_lru_page(page);
>> +		if (PageLRU(page))
>> +			ret = isolate_lru_page(page);
>> +		else
>> +			ret = isolate_movable_page(page, ISOLATE_UNEVICTABLE);
>>  		if (!ret) { /* Success */
>>  			put_page(page);
>>  			list_add_tail(&page->lru, &source);
>>  			move_pages--;
>> -			inc_node_page_state(page, NR_ISOLATED_ANON +
>> -					    page_is_file_cache(page));
>> +			if (!__PageMovable(page))
> 
> If this check is identical with "if (PageLRU(page))" in this context,
> PageLRU(page) looks better because you already add same "if" above.
> 
After isolated lru page, the PageLRU will be cleared, so use !__PageMovable
instead here for LRU page's mapping cannot have PAGE_MAPPING_MOVABLE.

I have add the comment in PATCH[3/4] HWPOISON: soft offlining for non-lru
movable page, so I do not add the same comment here.

Thanks
Yisheng Xie

> Otherwise, looks good to me.
> 
> Thanks,
> Naoya Horiguchi
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
