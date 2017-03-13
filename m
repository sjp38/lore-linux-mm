Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id DCDBF2808C0
	for <linux-mm@kvack.org>; Sun, 12 Mar 2017 22:19:56 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h89so82850945lfi.6
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 19:19:56 -0700 (PDT)
Received: from dggrg02-dlp.huawei.com ([45.249.212.188])
        by mx.google.com with ESMTPS id f23si5614957lfa.239.2017.03.12.19.19.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 12 Mar 2017 19:19:54 -0700 (PDT)
Subject: Re: [RFC v2 10/10] mm, page_alloc: introduce MIGRATE_MIXED
 migratetype
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-11-vbabka@suse.cz>
 <2743b3d4-743a-33db-fdbd-fa95edd35611@huawei.com>
 <0a7c2eb0-e01b-10b0-7419-e6e5b1fa0e0b@suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <296cb740-f04d-6e2b-6480-4a426d2e57ce@huawei.com>
Date: Mon, 13 Mar 2017 10:16:18 +0800
MIME-Version: 1.0
In-Reply-To: <0a7c2eb0-e01b-10b0-7419-e6e5b1fa0e0b@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Hanjun Guo <guohanjun@huawei.com>

Hi, Vlastimil,

On 2017/3/8 15:07, Vlastimil Babka wrote:
> On 03/08/2017 03:16 AM, Yisheng Xie wrote:
>> Hi Vlastimil ,
>>
>> On 2017/2/11 1:23, Vlastimil Babka wrote:
>>> @@ -1977,7 +1978,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>>>  	unsigned int current_order = page_order(page);
>>>  	struct free_area *area;
>>>  	int free_pages, good_pages;
>>> -	int old_block_type;
>>> +	int old_block_type, new_block_type;
>>>  
>>>  	/* Take ownership for orders >= pageblock_order */
>>>  	if (current_order >= pageblock_order) {
>>> @@ -1991,11 +1992,27 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>>>  	if (!whole_block) {
>>>  		area = &zone->free_area[current_order];
>>>  		list_move(&page->lru, &area->free_list[start_type]);
>>> -		return;
>>> +		free_pages = 1 << current_order;
>>> +		/* TODO: We didn't scan the block, so be pessimistic */
>>> +		good_pages = 0;
>>> +	} else {
>>> +		free_pages = move_freepages_block(zone, page, start_type,
>>> +							&good_pages);
>>> +		/*
>>> +		 * good_pages is now the number of movable pages, but if we
>>> +		 * want UNMOVABLE or RECLAIMABLE, we consider all non-movable
>>> +		 * as good (but we can't fully distinguish them)
>>> +		 */
>>> +		if (start_type != MIGRATE_MOVABLE)
>>> +			good_pages = pageblock_nr_pages - free_pages -
>>> +								good_pages;
>>>  	}
>>>  
>>>  	free_pages = move_freepages_block(zone, page, start_type,
>>>  						&good_pages);
>> It seems this move_freepages_block() should be removed, if we can steal whole block
>> then just  do it. If not we can check whether we can set it as mixed mt, right?
>> Please let me know if I miss something..
> 
> Right. My results suggested this patch was buggy, so this might be the
> bug (or one of the bugs), thanks for pointing it out. I've reposted v3
> without the RFC patches 9 and 10 and will return to them later.
Yes, I also have test about this patch on v4.1, but can not get better perf.
And it would be much appreciative if you can Cc me when send patchs about 9,10 later.

Thanks
Yisheng Xie.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
