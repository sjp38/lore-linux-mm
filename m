Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D735B6B0362
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 03:18:21 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id f4so1656342wre.9
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 00:18:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si774644edi.36.2017.12.06.00.18.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 00:18:16 -0800 (PST)
Subject: Re: [patch 13/15] mm/page_owner: align with pageblock_nr pages
References: <5a208318./AHclpWAWggUsQYT%akpm@linux-foundation.org>
 <8c2af1ab-e64f-21da-f295-ea1ead343206@suse.cz>
 <20171201171517.lyqukuvuh4cswnla@dhcp22.suse.cz>
 <5A2536B0.5060804@huawei.com>
 <20171204120114.iezicg6pmyj2z6lq@dhcp22.suse.cz>
 <5A253E55.7040706@huawei.com>
 <20171204123546.lhhcbpulihz3upm6@dhcp22.suse.cz>
 <5A25460F.9050206@huawei.com> <687fc876-c610-2ceb-6b91-5e400816bb32@suse.cz>
 <5A269613.5090405@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6e599005-392a-38e1-481e-72ff4195e749@suse.cz>
Date: Wed, 6 Dec 2017 09:18:14 +0100
MIME-Version: 1.0
In-Reply-To: <5A269613.5090405@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Michal Hocko <mhocko@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/05/2017 01:50 PM, zhong jiang wrote:
>>>  yes,   limited by my knowledge and english.  Maybe Vlastimil  can  address it  in detail.  
>> Hi, on a fresh look, I believe this patch doesn't improve anything in
>> practice. It potentially makes init_pages_in_zone() catch more early
>> allocations, if a hole happens to be placed in the beginning of
>> MAX_ORDER block, and the following pageblock within the block was early
>> allocated.
>  Hi, Vlastimil
> 
>   I have a stupid question about holes
> 
>   because a hole is possible to have within a MAX_ORDER_NR_PAGES, it indeed
>   exist in first pfn. it that is true, why we must skip the whole MAX_ORDER block?
>   Any limit ?  I can not find the answer.

It's not that we "must skip". If I understand it correctly, on kernels
without CONFIG_HOLES_IN_ZONE, we can skip a MAX_ORDER block if *any* pfn
(including the first pfn) is invalid, because we know that the whole
block is invalid. On CONFIG_HOLES_IN_ZONE, there is no such guarantee.

So if we see that the first pfn is valid, we continue with the block,
but use pfn_valid_within() (which is defined as pfn_valid() on
CONFIG_HOLES_IN_ZONE and hardcoded "true" elsewhere) to validate each
pfn. This is slow, but the arches pay the price for CONFIG_HOLES_IN_ZONE.

If we see that first pfn is invalid, we are safe to skip the MAX_ORDER
block when CONFIG_HOLES_IN_ZONE=n and we know we won't miss anything. On
CONFIG_HOLES_IN_ZONE we might miss something, so to be sure we don't
miss something, we should validate each pfn. The potential price there
is probably worse, because we might be validating arbitrary large holes
not limited by physical amount of RAM. So e.g. compaction doesn't pay
this price, and MAX_ORDER blocks that would have hole at the beginning
and end (with valid pages in the middle) are skipped.

page_owner on the other hand is a debugging feature not normally
enabled, with significant overhead, so paying the price there might not
be an issue. But it means rewriting both init_pages_in_zone() and
read_page_owner() to not skip MAX_ORDER block (nor pageblock_order) when
CONFIG_HOLES_IN_ZONE=y. I don't think there's a simple wrapper similar
to pfn_valid_within() for that, but it could be created (input: current
pfn, output: start pfn of next MAX_ORDER block if
CONFIG_HOLES_IN_ZONE=n, pfn+1 when CONFIG_HOLES_IN_ZONE=y).

>   Thanks
>   zhongjiang
>> However, read_page_owner() skips whole MAX_ORDER block as well in this
>> situation, so we won't be able to read the info anyway...
>>
>> Also the problem is not as simple as documenting MAX_ORDER_NR_PAGES vs
>> pabeblock_nr_pages. We discussed it year ago when this patch was first
>> posted, how skipping over holes would have to be made more robust, and
>> how architectures should define hole granularity to avoid checking each
>> individual pfn in what appears to be a hole, to see if the hole has ended.
>>
>>> Thanks
>>> zhongjiang
>>>
>>
>> .
>>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
