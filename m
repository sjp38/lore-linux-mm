Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA4966B0389
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:04:40 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id i50so221069723otd.3
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 04:04:40 -0700 (PDT)
Received: from dggrg02-dlp.huawei.com ([45.249.212.188])
        by mx.google.com with ESMTPS id u42si4441286oth.195.2017.03.13.04.04.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 04:04:39 -0700 (PDT)
Message-ID: <58C67A2E.9020201@huawei.com>
Date: Mon, 13 Mar 2017 18:53:34 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, page_alloc: fix the duplicate save/ressave irq
References: <1489392174-11794-1-git-send-email-zhongjiang@huawei.com> <7fe42f09-27cc-db21-58d5-affa4aff2849@suse.cz> <43acc363-45ac-db63-b7a0-14eeb8dfcfab@suse.cz>
In-Reply-To: <43acc363-45ac-db63-b7a0-14eeb8dfcfab@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: mgorman@techsingularity.net, akpm@linux-foundation.org, linux-mm@kvack.org

On 2017/3/13 18:08, Vlastimil Babka wrote:
> On 03/13/2017 09:31 AM, Vlastimil Babka wrote:
>> On 03/13/2017 09:02 AM, zhongjiang wrote:
>>> From: zhong jiang <zhongjiang@huawei.com>
>>>
>>> when commit 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
>>> introduced to the mainline, free_pcppages_bulk irq_save/resave to protect
>>> the IRQ context. but drain_pages_zone fails to clear away the irq. because
>>> preempt_disable have take effect. so it safely remove the code.
>>>
>>> Fixes: 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>>> ---
>>>  mm/page_alloc.c | 3 ---
>>>  1 file changed, 3 deletions(-)
>>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index 05c3956..7b16095 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -2294,11 +2294,9 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
>>>   */
>>>  static void drain_pages_zone(unsigned int cpu, struct zone *zone)
>>>  {
>>> -	unsigned long flags;
>>>  	struct per_cpu_pageset *pset;
>>>  	struct per_cpu_pages *pcp;
>>>  
>>> -	local_irq_save(flags);
>>>  	pset = per_cpu_ptr(zone->pageset, cpu);
>> NAK. we have to make sure that pset corresponds to the cpu we are
>> running on.
> Sorry, I was thinking about other callers, such as drain_local_pages(),
> but seems like all have the cpu pinned prerequisity.
>
> But do we know that there can't be an interrupt updating pcp->count
> between the moment we read it and we call free_pcppages_bulk? This
> should be also discussed in the changelog. Also the "Fixes:" tag is not
> necessary for a performance optimization.
 The title is misunderstanding. it is just for performence optimization.
 I will resent it in v2.

 Thanks
 zhongjiang
>>>  
>>>  	pcp = &pset->pcp;
>>> @@ -2306,7 +2304,6 @@ static void drain_pages_zone(unsigned int cpu, struct zone *zone)
>>>  		free_pcppages_bulk(zone, pcp->count, pcp);
>>>  		pcp->count = 0;
>>>  	}
>>> -	local_irq_restore(flags);
>>>  }
>>>  
>>>  /*
>>>
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
