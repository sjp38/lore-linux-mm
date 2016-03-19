Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A33636B007E
	for <linux-mm@kvack.org>; Sat, 19 Mar 2016 18:11:32 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id p65so110622317wmp.1
        for <linux-mm@kvack.org>; Sat, 19 Mar 2016 15:11:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g8si5102165wmf.40.2016.03.19.15.11.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 19 Mar 2016 15:11:31 -0700 (PDT)
Subject: Re: Suspicious error for CMA stress test
References: <56DD38E7.3050107@huawei.com> <56DDCB86.4030709@redhat.com>
 <56DE30CB.7020207@huawei.com> <56DF7B28.9060108@huawei.com>
 <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
 <56E2FB5C.1040602@suse.cz> <20160314064925.GA27587@js1304-P5Q-DELUXE>
 <56E662E8.700@suse.cz> <20160314071803.GA28094@js1304-P5Q-DELUXE>
 <56E92AFC.9050208@huawei.com> <20160317065426.GA10315@js1304-P5Q-DELUXE>
 <56EA77BC.2090702@huawei.com> <56EAD0B4.2060807@suse.cz>
 <CAAmzW4MNdFHSSTpCfWqy7oDtkR_Hfu2dZa_LW97W8J5vr5m4tg@mail.gmail.com>
 <56EC0C41.70503@suse.cz> <56ECFEAC.3010606@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56EDCE8C.8030607@suse.cz>
Date: Sat, 19 Mar 2016 23:11:24 +0100
MIME-Version: 1.0
In-Reply-To: <56ECFEAC.3010606@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <guohanjun@huawei.com>, Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lucas Stach <l.stach@pengutronix.de>

On 03/19/2016 08:24 AM, Hanjun Guo wrote:
> On 2016/3/18 22:10, Vlastimil Babka wrote:
>>>>
>>>> Oh, ok, will try to send proper patch, once I figure out what to write in
>>>> the changelog :)
>>> Thanks in advance!
>>>
>> OK, here it is. Hanjun can you please retest this, as I'm not sure if you had
>
> I tested this new patch with stress for more than one hour, and it works!

That's good news, thanks!

> Since Lucas has comments on it, I'm willing to test further versions if needed.
>
> One minor comments below,
>
>> the same code due to the followup one-liner patches in the thread. Lucas, see if
>> it helps with your issue as well. Laura and Joonsoo, please also test and review
>> and check changelog if my perception of the problem is accurate :)
>>
>> Thanks
>>
> [...]
>> +	if (max_order < MAX_ORDER) {
>> +		/* If we are here, it means order is >= pageblock_order.
>> +		 * We want to prevent merge between freepages on isolate
>> +		 * pageblock and normal pageblock. Without this, pageblock
>> +		 * isolation could cause incorrect freepage or CMA accounting.
>> +		 *
>> +		 * We don't want to hit this code for the more frequent
>> +		 * low-order merging.
>> +		 */
>> +		if (unlikely(has_isolate_pageblock(zone))) {
>
> In the first version of your patch, it's
>
> +		if (IS_ENABLED(CONFIG_CMA) &&
> +				unlikely(has_isolate_pageblock(zone))) {
>
> Why remove the IS_ENABLED(CONFIG_CMA) in the new version?

Previously I thought the problem was CMA-specific, but after more detailed look 
I think it's not, as start_isolate_page_range() releases zone lock between 
pageblocks, so unexpected merging due to races can happen also between isolated 
and non-isolated non-CMA pageblocks. This function is called from memory hotplug 
code, and recently also alloc_contig_range() itself is outside CONFIG_CMA for 
allocating gigantic hugepages. Joonsoo's original commit 3c60509 was also not 
restricted to CMA, and same with his patch earlier in this thread.

Hmm I guess another alternate solution would indeed be to modify 
start_isolate_page_range() and undo_isolate_page_range() to hold zone->lock 
across MAX_ORDER blocks (not whole requested range, as that could lead to 
hardlockups). But that still wouldn't help Lucas, IUUC.


> Thanks
> Hanjun
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
