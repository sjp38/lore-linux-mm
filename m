Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 05D096B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 10:10:44 -0400 (EDT)
Received: by mail-oi0-f43.google.com with SMTP id m82so133799249oif.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 07:10:44 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id c126si12946852oia.29.2016.03.14.07.10.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 07:10:42 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id d205so133772413oia.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 07:10:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <56E6AED1.6060703@suse.cz>
References: <56D93ABE.9070406@huawei.com>
	<20160307043442.GB24602@js1304-P5Q-DELUXE>
	<56DD38E7.3050107@huawei.com>
	<56DDCB86.4030709@redhat.com>
	<56DE30CB.7020207@huawei.com>
	<56DF7B28.9060108@huawei.com>
	<CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
	<56E2FB5C.1040602@suse.cz>
	<20160314064925.GA27587@js1304-P5Q-DELUXE>
	<56E662E8.700@suse.cz>
	<20160314071803.GA28094@js1304-P5Q-DELUXE>
	<56E6AED1.6060703@suse.cz>
Date: Mon, 14 Mar 2016 23:10:41 +0900
Message-ID: <CAAmzW4OKQHJ06Bi86jqVFGxqWsW7h_EWeGPAFB9K1aY754C4aQ@mail.gmail.com>
Subject: Re: Suspicious error for CMA stress test
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, Hanjun Guo <guohanjun@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-03-14 21:30 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 03/14/2016 08:18 AM, Joonsoo Kim wrote:
>>
>> On Mon, Mar 14, 2016 at 08:06:16AM +0100, Vlastimil Babka wrote:
>>>
>>> On 03/14/2016 07:49 AM, Joonsoo Kim wrote:
>>>>
>>>> On Fri, Mar 11, 2016 at 06:07:40PM +0100, Vlastimil Babka wrote:
>>>>>
>>>>> On 03/11/2016 04:00 PM, Joonsoo Kim wrote:
>>>>>
>>>>> How about something like this? Just and idea, probably buggy
>>>>> (off-by-one etc.).
>>>>> Should keep away cost from <pageblock_order iterations at the expense
>>>>> of the
>>>>> relatively fewer >pageblock_order iterations.
>>>>
>>>>
>>>> Hmm... I tested this and found that it's code size is a little bit
>>>> larger than mine. I'm not sure why this happens exactly but I guess it
>>>> would be
>>>> related to compiler optimization. In this case, I'm in favor of my
>>>> implementation because it looks like well abstraction. It adds one
>>>> unlikely branch to the merge loop but compiler would optimize it to
>>>> check it once.
>>>
>>>
>>> I would be surprised if compiler optimized that to check it once, as
>>> order increases with each loop iteration. But maybe it's smart
>>> enough to do something like I did by hand? Guess I'll check the
>>> disassembly.
>>
>>
>> Okay. I used following slightly optimized version and I need to
>> add 'max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1)'
>> to yours. Please consider it, too.
>
>
> Hmm, so this is bloat-o-meter on x86_64, gcc 5.3.1. CONFIG_CMA=y
>
> next-20160310 vs my patch (with added min_t as you pointed out):
> add/remove: 0/0 grow/shrink: 1/1 up/down: 69/-5 (64)
> function                                     old     new   delta
> free_one_page                                833     902     +69
> free_pcppages_bulk                          1333    1328      -5
>
> next-20160310 vs your patch:
> add/remove: 0/0 grow/shrink: 2/0 up/down: 577/0 (577)
> function                                     old     new   delta
> free_one_page                                833    1187    +354
> free_pcppages_bulk                          1333    1556    +223
>
> my patch vs your patch:
> add/remove: 0/0 grow/shrink: 2/0 up/down: 513/0 (513)
> function                                     old     new   delta
> free_one_page                                902    1187    +285
> free_pcppages_bulk                          1328    1556    +228
>
> The increase of your version is surprising, wonder what the compiler did.
> Otherwise I would like simpler/maintainable version, but this is crazy.
> Can you post your results? I wonder if your compiler e.g. decided to stop
> inlining page_is_buddy() or something.

Now I see why this happen. I enabled CONFIG_DEBUG_PAGEALLOC
and it makes difference.

I tested on x86_64, gcc (Ubuntu 4.8.4-2ubuntu1~14.04.1) 4.8.4.

With CONFIG_CMA + CONFIG_DEBUG_PAGEALLOC
./scripts/bloat-o-meter page_alloc_base.o page_alloc_vlastimil_orig.o
add/remove: 0/0 grow/shrink: 2/0 up/down: 510/0 (510)
function                                     old     new   delta
free_one_page                               1050    1334    +284
free_pcppages_bulk                          1396    1622    +226

./scripts/bloat-o-meter page_alloc_base.o page_alloc_mine.o
add/remove: 0/0 grow/shrink: 2/0 up/down: 351/0 (351)
function                                     old     new   delta
free_one_page                               1050    1230    +180
free_pcppages_bulk                          1396    1567    +171


With CONFIG_CMA + !CONFIG_DEBUG_PAGEALLOC
(pa_b is base, pa_v is yours and pa_m is mine)

./scripts/bloat-o-meter pa_b.o pa_v.o
add/remove: 0/0 grow/shrink: 1/1 up/down: 88/-23 (65)
function                                     old     new   delta
free_one_page                                761     849     +88
free_pcppages_bulk                          1117    1094     -23

./scripts/bloat-o-meter pa_b.o pa_m.o
add/remove: 0/0 grow/shrink: 2/0 up/down: 329/0 (329)
function                                     old     new   delta
free_one_page                                761    1031    +270
free_pcppages_bulk                          1117    1176     +59

Still, it has difference but less than before.
Maybe, we are still using different configuration. Could you
check if CONFIG_DEBUG_VM is enabled or not? In my case, it's not
enabled. And, do you think this bloat isn't acceptable?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
