Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 720D76B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 05:51:39 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u48so42945801wrc.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 02:51:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s10si23861267wrb.43.2017.03.13.02.51.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 02:51:38 -0700 (PDT)
Subject: Re: [RFC] mm/compaction: ignore block suitable after check large free
 page
References: <1489119648-59583-1-git-send-email-xieyisheng1@huawei.com>
 <eb3bbece-77ea-b88f-d4bf-dbf9bdf7f413@suse.cz>
 <9104271f-c90f-772c-26b2-410fa8bdfdb0@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <129003b1-bf1e-db03-6117-59657d2ae0b1@suse.cz>
Date: Mon, 13 Mar 2017 10:51:35 +0100
MIME-Version: 1.0
In-Reply-To: <9104271f-c90f-772c-26b2-410fa8bdfdb0@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mhocko@suse.com, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, rientjes@google.com, minchan@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, qiuxishi@huawei.com, liubo95@huawei.com

On 03/10/2017 10:53 AM, Yisheng Xie wrote:
> Hi Vlastimil,
> 
> Thanks for comment.
> On 2017/3/10 15:30, Vlastimil Babka wrote:
>> On 03/10/2017 05:20 AM, Yisheng Xie wrote:
>>> If the migrate target is a large free page and we ignore suitable,
>>> it may not good for defrag. So move the ignore block suitable after
>>> check large free page.
>>
>> Right. But in practice I expect close to no impact, because direct
>> compaction shouldn't have to be called if there's a >=pageblock_order
>> page already available.
>>
> Maybe you are right and this change is just based on logical analyses.

I'm not opposing the change, it might be better for future-proofing the
function, just pointing out that it most likely won't have any visible
effect right now.

> Presently, only in direct compaction, we increase the compaction priority,
> and ignore suitable at MIN_COMPACT_PRIORITY. I have a silly question, can
> we do the similar thing in kcompactd? maybe by doing most work in kcompactd,
> we can get better perf of slow path.

That would need a very good evaluation at the very least. Migrating
pages into pageblocks other than movable ones brings the danger of later
unmovable/reclaimable allocations having to fallback to movable
pageblocks and causing permanent fragmentation. For direct compaction we
decided that it's better to risk permanent fragmentation than a
premature OOM, but for kcompactd there doesn't seem to be such
compelling reason.

> Thanks
> Yisheng Xie
> 
>>> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
>>> ---
>>>  mm/compaction.c | 6 +++---
>>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/mm/compaction.c b/mm/compaction.c
>>> index 0fdfde0..4bf2a5d 100644
>>> --- a/mm/compaction.c
>>> +++ b/mm/compaction.c
>>> @@ -991,9 +991,6 @@ static bool too_many_isolated(struct zone *zone)
>>>  static bool suitable_migration_target(struct compact_control *cc,
>>>  							struct page *page)
>>>  {
>>> -	if (cc->ignore_block_suitable)
>>> -		return true;
>>> -
>>>  	/* If the page is a large free page, then disallow migration */
>>>  	if (PageBuddy(page)) {
>>>  		/*
>>> @@ -1005,6 +1002,9 @@ static bool suitable_migration_target(struct compact_control *cc,
>>>  			return false;
>>>  	}
>>>  
>>> +	if (cc->ignore_block_suitable)
>>> +		return true;
>>> +
>>>  	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
>>>  	if (migrate_async_suitable(get_pageblock_migratetype(page)))
>>>  		return true;
>>>
>>
>>
>> .
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
