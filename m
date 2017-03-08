Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C454E6B03A2
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 02:07:08 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g8so8427121wmg.7
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 23:07:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z23si3121415wrz.218.2017.03.07.23.07.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 23:07:07 -0800 (PST)
Subject: Re: [RFC v2 10/10] mm, page_alloc: introduce MIGRATE_MIXED
 migratetype
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-11-vbabka@suse.cz>
 <2743b3d4-743a-33db-fdbd-fa95edd35611@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0a7c2eb0-e01b-10b0-7419-e6e5b1fa0e0b@suse.cz>
Date: Wed, 8 Mar 2017 08:07:04 +0100
MIME-Version: 1.0
In-Reply-To: <2743b3d4-743a-33db-fdbd-fa95edd35611@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Hanjun Guo <guohanjun@huawei.com>

On 03/08/2017 03:16 AM, Yisheng Xie wrote:
> Hi Vlastimil ,
> 
> On 2017/2/11 1:23, Vlastimil Babka wrote:
>> @@ -1977,7 +1978,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>>  	unsigned int current_order = page_order(page);
>>  	struct free_area *area;
>>  	int free_pages, good_pages;
>> -	int old_block_type;
>> +	int old_block_type, new_block_type;
>>  
>>  	/* Take ownership for orders >= pageblock_order */
>>  	if (current_order >= pageblock_order) {
>> @@ -1991,11 +1992,27 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>>  	if (!whole_block) {
>>  		area = &zone->free_area[current_order];
>>  		list_move(&page->lru, &area->free_list[start_type]);
>> -		return;
>> +		free_pages = 1 << current_order;
>> +		/* TODO: We didn't scan the block, so be pessimistic */
>> +		good_pages = 0;
>> +	} else {
>> +		free_pages = move_freepages_block(zone, page, start_type,
>> +							&good_pages);
>> +		/*
>> +		 * good_pages is now the number of movable pages, but if we
>> +		 * want UNMOVABLE or RECLAIMABLE, we consider all non-movable
>> +		 * as good (but we can't fully distinguish them)
>> +		 */
>> +		if (start_type != MIGRATE_MOVABLE)
>> +			good_pages = pageblock_nr_pages - free_pages -
>> +								good_pages;
>>  	}
>>  
>>  	free_pages = move_freepages_block(zone, page, start_type,
>>  						&good_pages);
> It seems this move_freepages_block() should be removed, if we can steal whole block
> then just  do it. If not we can check whether we can set it as mixed mt, right?
> Please let me know if I miss something..

Right. My results suggested this patch was buggy, so this might be the
bug (or one of the bugs), thanks for pointing it out. I've reposted v3
without the RFC patches 9 and 10 and will return to them later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
