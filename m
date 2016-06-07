Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id CCE826B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 22:16:58 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id q18so131410228igr.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 19:16:58 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id p15si19862619iod.80.2016.06.06.19.16.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Jun 2016 19:16:58 -0700 (PDT)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0O8D010IYQC8H540@mailout3.samsung.com> for linux-mm@kvack.org;
 Tue, 07 Jun 2016 11:16:56 +0900 (KST)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: Re: Re: [RESEND][PATCH] drivers: of: of_reserved_mem: fixup the CMA
 alignment not to affect dma-coherent
Message-id: <57562EA9.3030201@samsung.com>
Date: Tue, 07 Jun 2016 11:17:13 +0900
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robh+dt@kernel.org, m.szyprowski@samsung.com
Cc: r64343@freescale.com, grant.likely@linaro.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaewon31.kim@gmail.com

>> From: Jaewon <jaewon31.kim@samsung.com>
>>
>> There was an alignment mismatch issue for CMA and it was fixed by
>> commit 1cc8e3458b51 ("drivers: of: of_reserved_mem: fixup the alignment with CMA setup").
>> However the way of the commit considers not only dma-contiguous(CMA) but also
>> dma-coherent which has no that requirement.
>>
>> This patch checks more to distinguish dma-contiguous(CMA) from dma-coherent.
>>
>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
>> ---
>>  drivers/of/of_reserved_mem.c | 5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/of/of_reserved_mem.c b/drivers/of/of_reserved_mem.c
>> index ed01c01..45b873e 100644
>> --- a/drivers/of/of_reserved_mem.c
>> +++ b/drivers/of/of_reserved_mem.c
>> @@ -127,7 +127,10 @@ static int __init __reserved_mem_alloc_size(unsigned long node,
>>         }
>>
>>         /* Need adjust the alignment to satisfy the CMA requirement */
>> -       if (IS_ENABLED(CONFIG_CMA) && of_flat_dt_is_compatible(node, "shared-dma-pool"))
>> +       if (IS_ENABLED(CONFIG_CMA)
>> +           && of_flat_dt_is_compatible(node, "shared-dma-pool")
>> +           && of_get_flat_dt_prop(node, "reusable", NULL)
>> +           && !of_get_flat_dt_prop(node, "no-map", NULL)) {
>
>This won't actually compile as you add a bracket here, but no closing bracket...
>
>I've fixed up and applied.
Thank you very much for your correction.
I might add debug code with the bracket.
Please let me know if any issue in submitting this patch
>
>>                 align = max(align, (phys_addr_t)PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order));
>>
>>         prop = of_get_flat_dt_prop(node, "alloc-ranges", &len);
>> --
>> 1.9.1
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
