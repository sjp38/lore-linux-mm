Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5FE6B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 01:19:22 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w13so1277546wmw.0
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 22:19:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h13si3791731wjs.271.2016.12.01.22.19.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Dec 2016 22:19:21 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, page_alloc: Keep pcp count and list contents in
 sync if struct page is corrupted
References: <20161202002244.18453-1-mgorman@techsingularity.net>
 <20161202002244.18453-2-mgorman@techsingularity.net>
 <01d601d24c4e$dca6e190$95f4a4b0$@alibaba-inc.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55e1d640-72cf-d7b5-695b-87863ca7a843@suse.cz>
Date: Fri, 2 Dec 2016 07:19:16 +0100
MIME-Version: 1.0
In-Reply-To: <01d601d24c4e$dca6e190$95f4a4b0$@alibaba-inc.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Mel Gorman' <mgorman@techsingularity.net>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Christoph Lameter' <cl@linux.com>, 'Michal Hocko' <mhocko@suse.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Jesper Dangaard Brouer' <brouer@redhat.com>, 'Linux-MM' <linux-mm@kvack.org>, 'Linux-Kernel' <linux-kernel@vger.kernel.org>

On 12/02/2016 04:47 AM, Hillf Danton wrote:
> On Friday, December 02, 2016 8:23 AM Mel Gorman wrote:
>> Vlastimil Babka pointed out that commit 479f854a207c ("mm, page_alloc:
>> defer debugging checks of pages allocated from the PCP") will allow the
>> per-cpu list counter to be out of sync with the per-cpu list contents
>> if a struct page is corrupted. This patch keeps the accounting in sync.
>>
>> Fixes: 479f854a207c ("mm, page_alloc: defer debugging checks of pages allocated from the PCP")
>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>> cc: stable@vger.kernel.org [4.7+]

Acked-by: Vlastimil Babka <vbabka@suse.cz>

>> ---
>>  mm/page_alloc.c | 5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 6de9440e3ae2..777ed59570df 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2192,7 +2192,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>>  			unsigned long count, struct list_head *list,
>>  			int migratetype, bool cold)
>>  {
>> -	int i;
>> +	int i, alloced = 0;
>>
>>  	spin_lock(&zone->lock);
>>  	for (i = 0; i < count; ++i) {
>> @@ -2217,13 +2217,14 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>>  		else
>>  			list_add_tail(&page->lru, list);
>>  		list = &page->lru;
>> +		alloced++;
>>  		if (is_migrate_cma(get_pcppage_migratetype(page)))
>>  			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
>>  					      -(1 << order));
>>  	}
>>  	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
>
> Now i is a pure index, yes?

No, even if a page fails the check_pcp_refill() check and is not 
"allocated", it is also no longer a free page, so it's correct to 
subtract it from NR_FREE_PAGES.

>>  	spin_unlock(&zone->lock);
>> -	return i;
>> +	return alloced;
>>  }
>>
>>  #ifdef CONFIG_NUMA
>> --
>> 2.10.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
