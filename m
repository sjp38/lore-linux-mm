Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA236B0253
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 03:06:20 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id n186so93385495wmn.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:06:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h83si16932413wmi.37.2016.03.14.00.06.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Mar 2016 00:06:19 -0700 (PDT)
Subject: Re: Suspicious error for CMA stress test
References: <56D92595.60709@huawei.com>
 <20160304063807.GA13317@js1304-P5Q-DELUXE> <56D93ABE.9070406@huawei.com>
 <20160307043442.GB24602@js1304-P5Q-DELUXE> <56DD38E7.3050107@huawei.com>
 <56DDCB86.4030709@redhat.com> <56DE30CB.7020207@huawei.com>
 <56DF7B28.9060108@huawei.com>
 <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
 <56E2FB5C.1040602@suse.cz> <20160314064925.GA27587@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E662E8.700@suse.cz>
Date: Mon, 14 Mar 2016 08:06:16 +0100
MIME-Version: 1.0
In-Reply-To: <20160314064925.GA27587@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, Hanjun Guo <guohanjun@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/14/2016 07:49 AM, Joonsoo Kim wrote:
> On Fri, Mar 11, 2016 at 06:07:40PM +0100, Vlastimil Babka wrote:
>> On 03/11/2016 04:00 PM, Joonsoo Kim wrote:
>>
>> How about something like this? Just and idea, probably buggy (off-by-one etc.).
>> Should keep away cost from <pageblock_order iterations at the expense of the
>> relatively fewer >pageblock_order iterations.
>
> Hmm... I tested this and found that it's code size is a little bit
> larger than mine. I'm not sure why this happens exactly but I guess it would be
> related to compiler optimization. In this case, I'm in favor of my
> implementation because it looks like well abstraction. It adds one
> unlikely branch to the merge loop but compiler would optimize it to
> check it once.

I would be surprised if compiler optimized that to check it once, as 
order increases with each loop iteration. But maybe it's smart enough to 
do something like I did by hand? Guess I'll check the disassembly.

>
> Thanks.
>
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index ff1e3cbc8956..b8005a07b2a1 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -685,21 +685,13 @@ static inline void __free_one_page(struct page *page,
>>   	unsigned long combined_idx;
>>   	unsigned long uninitialized_var(buddy_idx);
>>   	struct page *buddy;
>> -	unsigned int max_order = MAX_ORDER;
>> +	unsigned int max_order = pageblock_order + 1;
>>
>>   	VM_BUG_ON(!zone_is_initialized(zone));
>>   	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
>>
>>   	VM_BUG_ON(migratetype == -1);
>> -	if (is_migrate_isolate(migratetype)) {
>> -		/*
>> -		 * We restrict max order of merging to prevent merge
>> -		 * between freepages on isolate pageblock and normal
>> -		 * pageblock. Without this, pageblock isolation
>> -		 * could cause incorrect freepage accounting.
>> -		 */
>> -		max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
>> -	} else {
>> +	if (likely(!is_migrate_isolate(migratetype))) {
>>   		__mod_zone_freepage_state(zone, 1 << order, migratetype);
>>   	}
>>
>> @@ -708,11 +700,12 @@ static inline void __free_one_page(struct page *page,
>>   	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
>>   	VM_BUG_ON_PAGE(bad_range(zone, page), page);
>>
>> +continue_merging:
>>   	while (order < max_order - 1) {
>>   		buddy_idx = __find_buddy_index(page_idx, order);
>>   		buddy = page + (buddy_idx - page_idx);
>>   		if (!page_is_buddy(page, buddy, order))
>> -			break;
>> +			goto done_merging;
>>   		/*
>>   		 * Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard page,
>>   		 * merge with it and move up one order.
>> @@ -729,6 +722,26 @@ static inline void __free_one_page(struct page *page,
>>   		page_idx = combined_idx;
>>   		order++;
>>   	}
>> +	if (max_order < MAX_ORDER) {
>> +		if (IS_ENABLED(CONFIG_CMA) &&
>> +				unlikely(has_isolate_pageblock(zone))) {
>> +
>> +			int buddy_mt;
>> +
>> +			buddy_idx = __find_buddy_index(page_idx, order);
>> +			buddy = page + (buddy_idx - page_idx);
>> +			buddy_mt = get_pageblock_migratetype(buddy);
>> +
>> +			if (migratetype != buddy_mt &&
>> +					(is_migrate_isolate(migratetype) ||
>> +					is_migrate_isolate(buddy_mt)))
>> +				goto done_merging;
>> +		}
>> +		max_order++;
>> +		goto continue_merging;
>> +	}
>> +
>> +done_merging:
>>   	set_page_order(page, order);
>>
>>   	/*
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
