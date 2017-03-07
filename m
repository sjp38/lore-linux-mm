Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2B566B0387
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 06:05:44 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w37so73968989wrc.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 03:05:44 -0800 (PST)
Received: from dggrg03-dlp.huawei.com ([45.249.212.189])
        by mx.google.com with ESMTPS id v25si11166537wra.330.2017.03.07.03.05.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 03:05:43 -0800 (PST)
Message-ID: <58BE938B.9020908@huawei.com>
Date: Tue, 7 Mar 2017 19:03:39 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] mm: use MIGRATE_HIGHATOMIC as late as possible
References: <58BE8C91.20600@huawei.com> <20170307104758.GE28642@dhcp22.suse.cz>
In-Reply-To: <20170307104758.GE28642@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2017/3/7 18:47, Michal Hocko wrote:

> On Tue 07-03-17 18:33:53, Xishi Qiu wrote:
>> MIGRATE_HIGHATOMIC page blocks are reserved for an atomic
>> high-order allocation, so use it as late as possible.
> 
> Why is this better? Are you seeing any problem which this patch
> resolves? In other words the patch description should explain why not
> only what (that is usually clear from looking at the diff).
> 

Hi Michal,

I have not see any problem yet, I think if we reserve more high order
pageblocks, the more success rate we will get when meet an atomic
high-order allocation, right?

Thanks,
Xishi Qiu

>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> ---
>>  mm/page_alloc.c | 6 ++----
>>  1 file changed, 2 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 40d79a6..2331840 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2714,14 +2714,12 @@ struct page *rmqueue(struct zone *preferred_zone,
>>  	spin_lock_irqsave(&zone->lock, flags);
>>  
>>  	do {
>> -		page = NULL;
>> -		if (alloc_flags & ALLOC_HARDER) {
>> +		page = __rmqueue(zone, order, migratetype);
>> +		if (!page && alloc_flags & ALLOC_HARDER) {
>>  			page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
>>  			if (page)
>>  				trace_mm_page_alloc_zone_locked(page, order, migratetype);
>>  		}
>> -		if (!page)
>> -			page = __rmqueue(zone, order, migratetype);
>>  	} while (page && check_new_pages(page, order));
>>  	spin_unlock(&zone->lock);
>>  	if (!page)
>> -- 
>> 1.8.3.1
>>
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
