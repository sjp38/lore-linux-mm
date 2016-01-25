Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id DA99B6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 02:08:10 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id vt7so108973358obb.1
        for <linux-mm@kvack.org>; Sun, 24 Jan 2016 23:08:10 -0800 (PST)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id rx2si15909439oeb.11.2016.01.24.23.08.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Jan 2016 23:08:10 -0800 (PST)
Received: by mail-oi0-x22c.google.com with SMTP id w75so82008584oie.0
        for <linux-mm@kvack.org>; Sun, 24 Jan 2016 23:08:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160122163801.GA16668@cmpxchg.org>
References: <87k2n2usyf.fsf@linux.vnet.ibm.com>
	<20160122163801.GA16668@cmpxchg.org>
Date: Mon, 25 Jan 2016 16:08:09 +0900
Message-ID: <CAAmzW4OmWr1QGJn8D2c14jCPnwQ89T=YgBbg=bExgc_R6a4-bw@mail.gmail.com>
Subject: Re: [LSF/MM ATTEND] 2016: Requests to attend MM-summit
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, lsf-pc@lists.linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Peter Zijlstra <peterz@infradead.org>

Hello,

2016-01-23 1:38 GMT+09:00 Johannes Weiner <hannes@cmpxchg.org>:
> Hi,
>
> On Fri, Jan 22, 2016 at 10:11:12AM +0530, Aneesh Kumar K.V wrote:
>> * CMA allocator issues:
>>   (1) order zero allocation failures:
>>       We are observing order zero non-movable allocation failures in kernel
>> with CMA configured. We don't start a reclaim because our free memory check
>> does not consider free_cma. Hence the reclaim code assume we have enough free
>> pages. Joonsoo Kim tried to fix this with his ZOME_CMA patches. I would
>> like to discuss the challenges in getting this merged upstream.
>> https://lkml.org/lkml/2015/2/12/95 (ZONE_CMA)

As far as I know, there is no disagreement on this patchset in last year LSF/MM.
Problem may be due to my laziness... Sorry about that. I will handle it soon.
Is there anything more that you concern?

> The exclusion of cma pages from the watermark checks means that
> reclaim is happening too early, not too late, which leaves memory
> underutilized. That's what ZONE_CMA set out to fix.
>
> But unmovable allocations can still fail when the only free memory is
> inside CMA regions. I don't see how ZONE_CMA would fix that.
>
> CC Joonsoo

I understand what Aneesh's problem is.

Assume that

X = non movable free page
Y = movable free page
Z = cma free page

X < min watermark
X + Y > high watermark
Z > high watermark

If there are bunch of consecutive movable allocation requests,
Y will decrease. After some time, Y will be exhausted. At that
time, there is enough Z so movable allocation request still can be
handled in fastpath and kswapd isn't waked up. In that situation,
if atomic non-movable page allocation for order-0 comes,
it would be failed.

Although it isn't mentioned on ZONE_CMA patchset, it is also
fixed by that patchset because with that patchset, all CMA pages
are in CMA zone so freepage calculation is always precise.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
