Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 888BA6B0009
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 18:37:11 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id o11so121944307qge.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 15:37:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y69si27135511qka.73.2016.01.25.15.37.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 15:37:10 -0800 (PST)
Subject: Re: [LSF/MM ATTEND] 2016: Requests to attend MM-summit
References: <87k2n2usyf.fsf@linux.vnet.ibm.com>
 <20160122163801.GA16668@cmpxchg.org>
 <CAAmzW4OmWr1QGJn8D2c14jCPnwQ89T=YgBbg=bExgc_R6a4-bw@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56A6B1A2.40903@redhat.com>
Date: Mon, 25 Jan 2016 15:37:06 -0800
MIME-Version: 1.0
In-Reply-To: <CAAmzW4OmWr1QGJn8D2c14jCPnwQ89T=YgBbg=bExgc_R6a4-bw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, lsf-pc@lists.linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Peter Zijlstra <peterz@infradead.org>

On 01/24/2016 11:08 PM, Joonsoo Kim wrote:
> Hello,
>
> 2016-01-23 1:38 GMT+09:00 Johannes Weiner <hannes@cmpxchg.org>:
>> Hi,
>>
>> On Fri, Jan 22, 2016 at 10:11:12AM +0530, Aneesh Kumar K.V wrote:
>>> * CMA allocator issues:
>>>    (1) order zero allocation failures:
>>>        We are observing order zero non-movable allocation failures in kernel
>>> with CMA configured. We don't start a reclaim because our free memory check
>>> does not consider free_cma. Hence the reclaim code assume we have enough free
>>> pages. Joonsoo Kim tried to fix this with his ZOME_CMA patches. I would
>>> like to discuss the challenges in getting this merged upstream.
>>> https://lkml.org/lkml/2015/2/12/95 (ZONE_CMA)
>
> As far as I know, there is no disagreement on this patchset in last year LSF/MM.
> Problem may be due to my laziness... Sorry about that. I will handle it soon.
> Is there anything more that you concern?
>

Is that series going to conflict with the work done for ZONE_DEVICE or run
into similar problems?
033fbae988fcb67e5077203512181890848b8e90 (mm: ZONE_DEVICE for "device memory")
has commit text about running out of ZONE_SHIFT bits and needing to get
rid of ZONE_DMA instead so it seems like ZONE_CMA would run into the same
problem.

Thanks,
Laura
  
>> The exclusion of cma pages from the watermark checks means that
>> reclaim is happening too early, not too late, which leaves memory
>> underutilized. That's what ZONE_CMA set out to fix.
>>
>> But unmovable allocations can still fail when the only free memory is
>> inside CMA regions. I don't see how ZONE_CMA would fix that.
>>
>> CC Joonsoo
>
> I understand what Aneesh's problem is.
>
> Assume that
>
> X = non movable free page
> Y = movable free page
> Z = cma free page
>
> X < min watermark
> X + Y > high watermark
> Z > high watermark
>
> If there are bunch of consecutive movable allocation requests,
> Y will decrease. After some time, Y will be exhausted. At that
> time, there is enough Z so movable allocation request still can be
> handled in fastpath and kswapd isn't waked up. In that situation,
> if atomic non-movable page allocation for order-0 comes,
> it would be failed.
>
> Although it isn't mentioned on ZONE_CMA patchset, it is also
> fixed by that patchset because with that patchset, all CMA pages
> are in CMA zone so freepage calculation is always precise.
>
> Thanks.
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
