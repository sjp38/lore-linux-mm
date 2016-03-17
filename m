Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5298E6B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 11:43:54 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id l68so31945653wml.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:43:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dd9si10841245wjc.207.2016.03.17.08.43.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Mar 2016 08:43:53 -0700 (PDT)
Subject: Re: Suspicious error for CMA stress test
References: <56DD38E7.3050107@huawei.com> <56DDCB86.4030709@redhat.com>
 <56DE30CB.7020207@huawei.com> <56DF7B28.9060108@huawei.com>
 <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
 <56E2FB5C.1040602@suse.cz> <20160314064925.GA27587@js1304-P5Q-DELUXE>
 <56E662E8.700@suse.cz> <20160314071803.GA28094@js1304-P5Q-DELUXE>
 <56E92AFC.9050208@huawei.com> <20160317065426.GA10315@js1304-P5Q-DELUXE>
 <56EA77BC.2090702@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56EAD0B4.2060807@suse.cz>
Date: Thu, 17 Mar 2016 16:43:48 +0100
MIME-Version: 1.0
In-Reply-To: <56EA77BC.2090702@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <guohanjun@huawei.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/17/2016 10:24 AM, Hanjun Guo wrote:
> On 2016/3/17 14:54, Joonsoo Kim wrote:
>> On Wed, Mar 16, 2016 at 05:44:28PM +0800, Hanjun Guo wrote:
>>> On 2016/3/14 15:18, Joonsoo Kim wrote:
>>>> On Mon, Mar 14, 2016 at 08:06:16AM +0100, Vlastimil Babka wrote:
>>>>> On 03/14/2016 07:49 AM, Joonsoo Kim wrote:
>>>>>> On Fri, Mar 11, 2016 at 06:07:40PM +0100, Vlastimil Babka wrote:
>>>>>>> On 03/11/2016 04:00 PM, Joonsoo Kim wrote:
>>>>>>>
>>>>>>> How about something like this? Just and idea, probably buggy (off-by-one etc.).
>>>>>>> Should keep away cost from <pageblock_order iterations at the expense of the
>>>>>>> relatively fewer >pageblock_order iterations.
>>>>>> Hmm... I tested this and found that it's code size is a little bit
>>>>>> larger than mine. I'm not sure why this happens exactly but I guess it would be
>>>>>> related to compiler optimization. In this case, I'm in favor of my
>>>>>> implementation because it looks like well abstraction. It adds one
>>>>>> unlikely branch to the merge loop but compiler would optimize it to
>>>>>> check it once.
>>>>> I would be surprised if compiler optimized that to check it once, as
>>>>> order increases with each loop iteration. But maybe it's smart
>>>>> enough to do something like I did by hand? Guess I'll check the
>>>>> disassembly.
>>>> Okay. I used following slightly optimized version and I need to
>>>> add 'max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1)'
>>>> to yours. Please consider it, too.
>>> Hmm, this one is not work, I still can see the bug is there after applying
>>> this patch, did I miss something?
>> I may find that there is a bug which was introduced by me some time
>> ago. Could you test following change in __free_one_page() on top of
>> Vlastimil's patch?
>>
>> -page_idx = pfn & ((1 << max_order) - 1);
>> +page_idx = pfn & ((1 << MAX_ORDER) - 1);
>
> I tested Vlastimil's patch + your change with stress for more than half hour, the bug
> I reported is gone :)

Oh, ok, will try to send proper patch, once I figure out what to write 
in the changelog :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
