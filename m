Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4F17A28029C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 08:14:47 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b193so3950439wmd.7
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 05:14:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p4si3633504wmd.264.2018.01.17.05.14.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Jan 2018 05:14:45 -0800 (PST)
Subject: Re: [RFC] mm: why vfree() do not free page table memory?
References: <5A4603AB.8060809@huawei.com>
 <0ffd113e-84da-bd49-2b63-3d27d2702580@suse.cz> <5A5F1C09.9040000@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6598f55a-49c6-c5df-974a-e697317ade9b@suse.cz>
Date: Wed, 17 Jan 2018 14:14:42 +0100
MIME-Version: 1.0
In-Reply-To: <5A5F1C09.9040000@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "Wujiangtao (A)" <wu.wujiangtao@huawei.com>

On 01/17/2018 10:48 AM, Xishi Qiu wrote:
> On 2018/1/17 17:16, Vlastimil Babka wrote:
> 
>> On 12/29/2017 09:58 AM, Xishi Qiu wrote:
>>> When calling vfree(), it calls unmap_vmap_area() to clear page table,
>>> but do not free the memory of page table, why? just for performance?
>>
>> I guess it's expected that the free virtual range and associated page
>> tables it might be reused later.
>>
> 
> Hi Vlastimili 1/4 ?
> 
> If use vmalloc/vfree different size, then there will be some hols during 
> VMALLOC_START to VMALLOC_END, and this holes takes page table memory, right?

Possibly. But to free a page table page, there has to be contiguous
aligned 2MB hole.

>>> If a driver use vmalloc() and vfree() frequently, we will lost much
>>> page table memory, maybe oom later.
>>
>> If it's reused, then not really.
>>
>> Did you notice an actual issue, or is this just theoretical concern.
>>
> 
> Yes, we have this problem on our production line.
> I find the page table memory takes 200-300M.

Well, can you verify that it's really due to vmalloc holes? And that the
holes are there because of an unfortunate sequence of vmalloc/vfree, and
not due to some bug in vmalloc failing to reuse freed areas properly?
And do the holes contain enough 2MB aligned ranges to make it possible
to free the page tables?

Vlastimil

> Thanks,
> Xishi Qiu
> 
>>> Thanks,
>>> Xishi Qiu
>>>
>>
>>
>> .
>>
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
