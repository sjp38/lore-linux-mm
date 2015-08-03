Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5DE9003CD
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 10:55:50 -0400 (EDT)
Received: by padck2 with SMTP id ck2so91884481pad.0
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 07:55:49 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id jt12si13358210pbb.8.2015.08.03.07.55.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Aug 2015 07:55:49 -0700 (PDT)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NSI030JQHGYDU60@mailout2.samsung.com> for linux-mm@kvack.org;
 Mon, 03 Aug 2015 23:55:46 +0900 (KST)
Content-transfer-encoding: 8BIT
Message-id: <55BF80F2.2020602@samsung.com>
Date: Mon, 03 Aug 2015 23:55:46 +0900
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: Re: [PATCH] vmscan: reclaim_clean_pages_from_list() must count mlocked
 pages
References: <1438597107-18329-1-git-send-email-jaewon31.kim@samsung.com>
 <20150803122509.GA29929@bgram>
In-reply-to: <20150803122509.GA29929@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com



On 2015e?? 08i?? 03i? 1/4  21:27, Minchan Kim wrote:
> Hello,
> 
> On Mon, Aug 03, 2015 at 07:18:27PM +0900, Jaewon Kim wrote:
>> reclaim_clean_pages_from_list() decreases NR_ISOLATED_FILE by returned
>> value from shrink_page_list(). But mlocked pages in the isolated
>> clean_pages page list would be removed from the list but not counted as
>> nr_reclaimed. Fix this miscounting by returning the number of mlocked
>> pages and count it.
> 
> If there are pages not able to reclaim, VM try to migrate it and
> have to handle the stat in migrate_pages.
> If migrate_pages fails again, putback-fiends should handle it.
> 
> Is there anyting I am missing now?
> 
> Thanks.
> 
Hello

Only pages in cc->migratepages will be handled by migrate_pages or
putback_movable_pages, and NR_ISOLATED_FILE will be counted properly.
However mlocked pages will not be put back into cc->migratepages,
and also not be counted in NR_ISOLATED_FILE because putback_lru_page
in shrink_page_list does not increase NR_ISOLATED_FILE.
The current reclaim_clean_pages_from_list assumes that shrink_page_list
returns number of pages removed from the candidate list.

i.e)
isolate_migratepages_range    : NR_ISOLATED_FILE += 10
reclaim_clean_pages_from_list : NR_ISOLATED_FILE -= 5 (1 mlocked page)
migrate_pages                 : NR_ISOLATED_FILE -=4
=> NR_ISOLATED_FILE increased by 1

Thank you.
>>
>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
>> ---
>>  mm/vmscan.c | 10 ++++++++--
>>  1 file changed, 8 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 5e8eadd..5837695 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -849,6 +849,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>  				      unsigned long *ret_nr_congested,
>>  				      unsigned long *ret_nr_writeback,
>>  				      unsigned long *ret_nr_immediate,
>> +				      unsigned long *ret_nr_mlocked,
>>  				      bool force_reclaim)
>>  {
>>  	LIST_HEAD(ret_pages);
>> @@ -1158,6 +1159,7 @@ cull_mlocked:
>>  			try_to_free_swap(page);
>>  		unlock_page(page);
>>  		putback_lru_page(page);
>> +		(*ret_nr_mlocked)++;
>>  		continue;
>>  
>>  activate_locked:
>> @@ -1197,6 +1199,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>>  		.may_unmap = 1,
>>  	};
>>  	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
>> +	unsigned long nr_mlocked = 0;
>>  	struct page *page, *next;
>>  	LIST_HEAD(clean_pages);
>>  
>> @@ -1210,8 +1213,10 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>>  
>>  	ret = shrink_page_list(&clean_pages, zone, &sc,
>>  			TTU_UNMAP|TTU_IGNORE_ACCESS,
>> -			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
>> +			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5,
>> +			&nr_mlocked, true);
>>  	list_splice(&clean_pages, page_list);
>> +	ret += nr_mlocked;
>>  	mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
>>  	return ret;
>>  }
>> @@ -1523,6 +1528,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>>  	unsigned long nr_unqueued_dirty = 0;
>>  	unsigned long nr_writeback = 0;
>>  	unsigned long nr_immediate = 0;
>> +	unsigned long nr_mlocked = 0;
>>  	isolate_mode_t isolate_mode = 0;
>>  	int file = is_file_lru(lru);
>>  	struct zone *zone = lruvec_zone(lruvec);
>> @@ -1565,7 +1571,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>>  
>>  	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
>>  				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
>> -				&nr_writeback, &nr_immediate,
>> +				&nr_writeback, &nr_immediate, &nr_mlocked,
>>  				false);
>>  
>>  	spin_lock_irq(&zone->lru_lock);
>> -- 
>> 1.9.1
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
