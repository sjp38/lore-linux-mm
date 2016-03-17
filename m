Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id E2AED6B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 11:52:55 -0400 (EDT)
Received: by mail-ob0-f171.google.com with SMTP id fz5so88791030obc.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:52:55 -0700 (PDT)
Received: from mail-ob0-x22b.google.com (mail-ob0-x22b.google.com. [2607:f8b0:4003:c01::22b])
        by mx.google.com with ESMTPS id xs2si6181073oec.3.2016.03.17.08.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 08:52:55 -0700 (PDT)
Received: by mail-ob0-x22b.google.com with SMTP id m7so87771768obh.3
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:52:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <56EAD0B4.2060807@suse.cz>
References: <56DD38E7.3050107@huawei.com>
	<56DDCB86.4030709@redhat.com>
	<56DE30CB.7020207@huawei.com>
	<56DF7B28.9060108@huawei.com>
	<CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
	<56E2FB5C.1040602@suse.cz>
	<20160314064925.GA27587@js1304-P5Q-DELUXE>
	<56E662E8.700@suse.cz>
	<20160314071803.GA28094@js1304-P5Q-DELUXE>
	<56E92AFC.9050208@huawei.com>
	<20160317065426.GA10315@js1304-P5Q-DELUXE>
	<56EA77BC.2090702@huawei.com>
	<56EAD0B4.2060807@suse.cz>
Date: Fri, 18 Mar 2016 00:52:54 +0900
Message-ID: <CAAmzW4MNdFHSSTpCfWqy7oDtkR_Hfu2dZa_LW97W8J5vr5m4tg@mail.gmail.com>
Subject: Re: Suspicious error for CMA stress test
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hanjun Guo <guohanjun@huawei.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-03-18 0:43 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 03/17/2016 10:24 AM, Hanjun Guo wrote:
>>
>> On 2016/3/17 14:54, Joonsoo Kim wrote:
>>>
>>> On Wed, Mar 16, 2016 at 05:44:28PM +0800, Hanjun Guo wrote:
>>>>
>>>> On 2016/3/14 15:18, Joonsoo Kim wrote:
>>>>>
>>>>> On Mon, Mar 14, 2016 at 08:06:16AM +0100, Vlastimil Babka wrote:
>>>>>>
>>>>>> On 03/14/2016 07:49 AM, Joonsoo Kim wrote:
>>>>>>>
>>>>>>> On Fri, Mar 11, 2016 at 06:07:40PM +0100, Vlastimil Babka wrote:
>>>>>>>>
>>>>>>>> On 03/11/2016 04:00 PM, Joonsoo Kim wrote:
>>>>>>>>
>>>>>>>> How about something like this? Just and idea, probably buggy
>>>>>>>> (off-by-one etc.).
>>>>>>>> Should keep away cost from <pageblock_order iterations at the
>>>>>>>> expense of the
>>>>>>>> relatively fewer >pageblock_order iterations.
>>>>>>>
>>>>>>> Hmm... I tested this and found that it's code size is a little bit
>>>>>>> larger than mine. I'm not sure why this happens exactly but I guess
>>>>>>> it would be
>>>>>>> related to compiler optimization. In this case, I'm in favor of my
>>>>>>> implementation because it looks like well abstraction. It adds one
>>>>>>> unlikely branch to the merge loop but compiler would optimize it to
>>>>>>> check it once.
>>>>>>
>>>>>> I would be surprised if compiler optimized that to check it once, as
>>>>>> order increases with each loop iteration. But maybe it's smart
>>>>>> enough to do something like I did by hand? Guess I'll check the
>>>>>> disassembly.
>>>>>
>>>>> Okay. I used following slightly optimized version and I need to
>>>>> add 'max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1)'
>>>>> to yours. Please consider it, too.
>>>>
>>>> Hmm, this one is not work, I still can see the bug is there after
>>>> applying
>>>> this patch, did I miss something?
>>>
>>> I may find that there is a bug which was introduced by me some time
>>> ago. Could you test following change in __free_one_page() on top of
>>> Vlastimil's patch?
>>>
>>> -page_idx = pfn & ((1 << max_order) - 1);
>>> +page_idx = pfn & ((1 << MAX_ORDER) - 1);
>>
>>
>> I tested Vlastimil's patch + your change with stress for more than half
>> hour, the bug
>> I reported is gone :)
>
>
> Oh, ok, will try to send proper patch, once I figure out what to write in
> the changelog :)

Thanks in advance!

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
