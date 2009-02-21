Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DB4506B0093
	for <linux-mm@kvack.org>; Sat, 21 Feb 2009 12:13:44 -0500 (EST)
Received: by bwz28 with SMTP id 28so3926124bwz.14
        for <linux-mm@kvack.org>; Sat, 21 Feb 2009 09:13:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <49A02A61.6060909@cs.helsinki.fi>
References: <1235223364-2097-1-git-send-email-vegard.nossum@gmail.com>
	 <1235223364-2097-4-git-send-email-vegard.nossum@gmail.com>
	 <49A02A61.6060909@cs.helsinki.fi>
Date: Sat, 21 Feb 2009 18:13:42 +0100
Message-ID: <19f34abd0902210913qe0539ebgf74c9b5e0b577786@mail.gmail.com>
Subject: Re: [PATCH] kmemcheck: add hooks for page- and sg-dma-mappings
From: Vegard Nossum <vegard.nossum@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

2009/2/21 Pekka Enberg <penberg@cs.helsinki.fi>:
> Vegard Nossum wrote:
>>
>> This is needed for page allocator support to prevent false positives
>> when accessing pages which are dma-mapped.
>>
>> Signed-off-by: Vegard Nossum <vegard.nossum@gmail.com>
>> ---
>>  arch/x86/include/asm/dma-mapping.h |    6 ++++++
>>  1 files changed, 6 insertions(+), 0 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/dma-mapping.h
>> b/arch/x86/include/asm/dma-mapping.h
>> index 830bb0e..713a002 100644
>> --- a/arch/x86/include/asm/dma-mapping.h
>> +++ b/arch/x86/include/asm/dma-mapping.h
>> @@ -117,7 +117,12 @@ dma_map_sg(struct device *hwdev, struct scatterlist
>> *sg,
>>  {
>>        struct dma_mapping_ops *ops = get_dma_ops(hwdev);
>>  +       struct scatterlist *s;
>> +       int i;
>> +
>>        BUG_ON(!valid_dma_direction(direction));
>> +       for_each_sg(sg, s, nents, i)
>> +               kmemcheck_mark_initialized(sg_virt(s), s->length);
>>        return ops->map_sg(hwdev, sg, nents, direction);
>>  }
>>  @@ -215,6 +220,7 @@ static inline dma_addr_t dma_map_page(struct device
>> *dev, struct page *page,
>>        struct dma_mapping_ops *ops = get_dma_ops(dev);
>>          BUG_ON(!valid_dma_direction(direction));
>> +       kmemcheck_mark_initialized(page_address(page) + offset, size);
>>        return ops->map_single(dev, page_to_phys(page) + offset,
>>                               size, direction);
>>  }
>
> What's with the new BUG_ON() calls here?
>

What new BUG_ON calls? Do you need glasses?


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
