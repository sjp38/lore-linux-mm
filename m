Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id F206D6B025B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 09:32:48 -0500 (EST)
Received: by wmvv187 with SMTP id v187so264717935wmv.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 06:32:48 -0800 (PST)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id y187si4141211wme.46.2015.12.09.06.32.47
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 06:32:47 -0800 (PST)
Subject: Re: [PATCH] MIPS: Fix DMA contiguous allocation
References: <1449569930-2118-1-git-send-email-qais.yousef@imgtec.com>
 <20151208141939.d0edbb72b3c15844c5ac25ea@linux-foundation.org>
 <20151209113635.GA15910@techsingularity.net>
From: Qais Yousef <qais.yousef@imgtec.com>
Message-ID: <56683B8E.2000600@imgtec.com>
Date: Wed, 9 Dec 2015 14:32:46 +0000
MIME-Version: 1.0
In-Reply-To: <20151209113635.GA15910@techsingularity.net>
Content-Type: text/plain; charset="iso-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mips@linux-mips.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ralf@linux-mips.org

On 12/09/2015 11:36 AM, Mel Gorman wrote:
> On Tue, Dec 08, 2015 at 02:19:39PM -0800, Andrew Morton wrote:
>> On Tue, 8 Dec 2015 10:18:50 +0000 Qais Yousef <qais.yousef@imgtec.com> wrote:
>>
>>> --- a/arch/mips/mm/dma-default.c
>>> +++ b/arch/mips/mm/dma-default.c
>>> @@ -145,7 +145,7 @@ static void *mips_dma_alloc_coherent(struct device *dev, size_t size,
>>>   
>>>   	gfp = massage_gfp_flags(dev, gfp);
>>>   
>>> -	if (IS_ENABLED(CONFIG_DMA_CMA) && !(gfp & GFP_ATOMIC))
>>> +	if (IS_ENABLED(CONFIG_DMA_CMA) && ((gfp & GFP_ATOMIC) != GFP_ATOMIC))
>>>   		page = dma_alloc_from_contiguous(dev,
>>>   					count, get_order(size));
>>>   	if (!page)
>> hm.  It seems that the code is asking "can I do a potentially-sleeping
>> memory allocation"?
>>
>> The way to do that under the new regime is
>>
>> 	if (IS_ENABLED(CONFIG_DMA_CMA) && gfpflags_allow_blocking(gfp))
>>
>> Mel, can you please confirm?
> Yes, this is the correct way it should be checked. The full flags cover
> watermark and kswapd treatment which potentially could be altered by
> the caller.
>

OK thanks both. I'll send a revised version with this change.

Thanks,
Qais

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
