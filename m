Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 01C31828DF
	for <linux-mm@kvack.org>; Sat, 19 Mar 2016 03:29:21 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id x3so197552916pfb.1
        for <linux-mm@kvack.org>; Sat, 19 Mar 2016 00:29:20 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id x14si2504218par.197.2016.03.19.00.29.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 19 Mar 2016 00:29:20 -0700 (PDT)
Subject: Re: Suspicious error for CMA stress test
References: <56DD38E7.3050107@huawei.com> <56DDCB86.4030709@redhat.com>
 <56DE30CB.7020207@huawei.com> <56DF7B28.9060108@huawei.com>
 <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
 <56E2FB5C.1040602@suse.cz> <20160314064925.GA27587@js1304-P5Q-DELUXE>
 <56E662E8.700@suse.cz> <20160314071803.GA28094@js1304-P5Q-DELUXE>
 <56E92AFC.9050208@huawei.com> <20160317065426.GA10315@js1304-P5Q-DELUXE>
 <56EA77BC.2090702@huawei.com> <56EAD0B4.2060807@suse.cz>
 <CAAmzW4MNdFHSSTpCfWqy7oDtkR_Hfu2dZa_LW97W8J5vr5m4tg@mail.gmail.com>
 <56EC0C41.70503@suse.cz>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <56ECFEAC.3010606@huawei.com>
Date: Sat, 19 Mar 2016 15:24:28 +0800
MIME-Version: 1.0
In-Reply-To: <56EC0C41.70503@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lucas Stach <l.stach@pengutronix.de>

On 2016/3/18 22:10, Vlastimil Babka wrote:
> On 03/17/2016 04:52 PM, Joonsoo Kim wrote:
>> 2016-03-18 0:43 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
>>>>>>> Okay. I used following slightly optimized version and I need to
>>>>>>> add 'max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1)'
>>>>>>> to yours. Please consider it, too.
>>>>>> Hmm, this one is not work, I still can see the bug is there after
>>>>>> applying
>>>>>> this patch, did I miss something?
>>>>> I may find that there is a bug which was introduced by me some time
>>>>> ago. Could you test following change in __free_one_page() on top of
>>>>> Vlastimil's patch?
>>>>>
>>>>> -page_idx = pfn & ((1 << max_order) - 1);
>>>>> +page_idx = pfn & ((1 << MAX_ORDER) - 1);
>>>>
>>>> I tested Vlastimil's patch + your change with stress for more than half
>>>> hour, the bug
>>>> I reported is gone :)
>>>
>>> Oh, ok, will try to send proper patch, once I figure out what to write in
>>> the changelog :)
>> Thanks in advance!
>>
> OK, here it is. Hanjun can you please retest this, as I'm not sure if you had

I tested this new patch with stress for more than one hour, and it works!
Since Lucas has comments on it, I'm willing to test further versions if needed.

One minor comments below,

> the same code due to the followup one-liner patches in the thread. Lucas, see if
> it helps with your issue as well. Laura and Joonsoo, please also test and review
> and check changelog if my perception of the problem is accurate :)
>
> Thanks
>
[...]
> +	if (max_order < MAX_ORDER) {
> +		/* If we are here, it means order is >= pageblock_order.
> +		 * We want to prevent merge between freepages on isolate
> +		 * pageblock and normal pageblock. Without this, pageblock
> +		 * isolation could cause incorrect freepage or CMA accounting.
> +		 *
> +		 * We don't want to hit this code for the more frequent
> +		 * low-order merging.
> +		 */
> +		if (unlikely(has_isolate_pageblock(zone))) {

In the first version of your patch, it's

+		if (IS_ENABLED(CONFIG_CMA) &&
+				unlikely(has_isolate_pageblock(zone))) {

Why remove the IS_ENABLED(CONFIG_CMA) in the new version?

Thanks
Hanjun


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
