Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 44EEA6B0256
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 04:44:46 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id o185so16331159pfb.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 01:44:46 -0800 (PST)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id x12si781998pfa.98.2016.01.28.01.44.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 01:44:45 -0800 (PST)
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 28 Jan 2016 19:44:37 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id DDEA42BB0054
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 20:44:33 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0S9iRqV12124372
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 20:44:35 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0S9i08l005912
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 20:44:01 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [LSF/MM ATTEND] 2016: Requests to attend MM-summit
In-Reply-To: <CAAmzW4OmWr1QGJn8D2c14jCPnwQ89T=YgBbg=bExgc_R6a4-bw@mail.gmail.com>
References: <87k2n2usyf.fsf@linux.vnet.ibm.com> <20160122163801.GA16668@cmpxchg.org> <CAAmzW4OmWr1QGJn8D2c14jCPnwQ89T=YgBbg=bExgc_R6a4-bw@mail.gmail.com>
Date: Thu, 28 Jan 2016 15:13:33 +0530
Message-ID: <877fiu59a2.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: lsf-pc@lists.linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Peter Zijlstra <peterz@infradead.org>

Joonsoo Kim <js1304@gmail.com> writes:

> Hello,
>
> 2016-01-23 1:38 GMT+09:00 Johannes Weiner <hannes@cmpxchg.org>:
>> Hi,
>>
>> On Fri, Jan 22, 2016 at 10:11:12AM +0530, Aneesh Kumar K.V wrote:
>>> * CMA allocator issues:
>>>   (1) order zero allocation failures:
>>>       We are observing order zero non-movable allocation failures in kernel
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

That is the issue I am hitting and if we don't have any blocker against
ZONE_CMA then we can drop this topic.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
