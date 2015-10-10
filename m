Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 15C276B0038
	for <linux-mm@kvack.org>; Sat, 10 Oct 2015 05:33:46 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so98422665wic.0
        for <linux-mm@kvack.org>; Sat, 10 Oct 2015 02:33:45 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id d9si3377046wij.73.2015.10.10.02.33.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Oct 2015 02:33:44 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so98422411wic.0
        for <linux-mm@kvack.org>; Sat, 10 Oct 2015 02:33:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <560CE630.6060207@suse.cz>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
	<20150915061349.GA16485@bbox>
	<CAMJBoFM_bMvQthAJPK+w4uQznqp7eFLdk=c7ZtT-R1aoF-1SeA@mail.gmail.com>
	<560C01BF.3040604@suse.cz>
	<CAMJBoFNpqrr_5iuQ68TrRPP=Uv0SYPra6XH27NAcG+Apq=CoSg@mail.gmail.com>
	<560CE630.6060207@suse.cz>
Date: Sat, 10 Oct 2015 11:33:44 +0200
Message-ID: <CAMJBoFOuyis9JUK91m_jfPsaNN6DT1XAd-mvH0=iu3F0j9H7Sg@mail.gmail.com>
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, =?UTF-8?B?6rmA7KSA7IiY?= <iamjoonsoo.kim@lge.com>, Gioh Kim <gioh.kim@lge.com>

On Thu, Oct 1, 2015 at 9:52 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 09/30/2015 05:46 PM, Vitaly Wool wrote:
>>
>> On Wed, Sep 30, 2015 at 5:37 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>
>>> On 09/25/2015 11:54 AM, Vitaly Wool wrote:
>>>>
>>>>
>>>> Hello Minchan,
>>>>
>>>> the main use case where I see unacceptably long stalls in UI with
>>>> zsmalloc is switching between users in Android.
>>>> There is a way to automate user creation and switching between them so
>>>> the test I run both to get vmstat statistics and to profile stalls is
>>>> to create a user, switch to it and switch back. Each test cycle does
>>>> that 10 times, and all the results presented below are averages for 20
>>>> runs.
>>>>
>>>> Kernel configurations used for testing:
>>>>
>>>> (1): vanilla
>>>> (2): (1) plus "make SLUB atomic" patch [1]
>>>> (3): (1) with zbud instead of zsmalloc
>>>> (4): (2) with compaction defer logic mostly disabled
>>>
>>>
>>>
>>> Disabling compaction deferring leads to less compaction stalls? That
>>> indeed
>>> looks very weird and counter-intuitive. Also what's "mostly" disabled
>>> mean?
>>
>>
>> Not that I'm not surprised myself. However, this is how it goes.
>> Namely, I reverted the following patches:
>> - mm, compaction: defer each zone individually instead of preferred zone
>
>
> Oh, I see. Then you didn't disable compaction defer logic, but made it
> coarse again instead of per-zone. Which means that an allocation that can=
 be
> satisfied from Normal zone will use the Normal zone's deferred state to
> decide whether to compact also DMA and DMA32 zones *within the same
> allocation attempt*. So by reverting the patch you might indeed get less
> compact_stall (and success+failure) counts, but each stall will try to
> compact all three zones. With individual defer, some stall might be just =
for
> DMA32, some just for Normal, and the total number might be higher, but th=
e
> compaction overhead should be better distributed among all the attempts.

The thing is, this happens on an ARM64 and I only have one zone there.

> Looking at your latencies, looks like that's working fine:
>
>>
>> The UI is blocked after user switching for, average:
>> (1) 1.84 seconds
>> (2) 0.89 seconds
>> (3) 1.32 seconds
>> (4) 0.87 seconds
>
>
> Average for (2) vs (4) is roughly the same, I would guess within noise.

That I surely won't argue with :)

>> The UI us blocked after user switching for, worst-case:
>> (1) 2.91
>> (2) 1.12
>> (3) 1.79
>> (4) 1.34
>
>
> The worst case is actually worse without individual defer, because you en=
d
> up compacting all zones in each single stall. With individual defer, ther=
e's
> a low probability of that happening.

Okay, but in case of a single zone, isn't this more fine-grained logic
resulting in more defers and less async compactions?

>> - mm, compaction: embed migration mode in compact_control
>
>
> This probably affects just THPs.
>
>> - mm, compaction: add per-zone migration pfn cache for async compaction
>
>
> Hard to say what's the effect of this.
>
>> - =EF=BF=BCmm: compaction: encapsulate defer reset logic
>
>
> This is just code consolidation.
>
>> ~vitaly
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
