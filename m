Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DCF3F6B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 03:05:39 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b1so1238446807pgc.5
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 00:05:39 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id a2si64919409pgf.207.2017.01.02.00.05.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Jan 2017 00:05:39 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Received: from epcas1p1.samsung.com (unknown [182.195.41.45])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OJ5025S97TDW7B0@mailout4.samsung.com> for linux-mm@kvack.org;
 Mon, 02 Jan 2017 17:05:37 +0900 (KST)
Content-transfer-encoding: 8BIT
Subject: Re: [PATCH] mm: cma: print allocation failure reason and bitmap status
From: Jaewon Kim <jaewon31.kim@samsung.com>
Message-id: <586A0A05.4040708@samsung.com>
Date: Mon, 02 Jan 2017 17:06:29 +0900
In-reply-to: <xa1tmvfahscn.fsf@mina86.com>
References: 
 <CGME20161229022722epcas5p4be0e1924f3c8d906cbfb461cab8f0374@epcas5p4.samsung.com>
 <1482978482-14007-1-git-send-email-jaewon31.kim@samsung.com>
 <20161229091449.GG29208@dhcp22.suse.cz> <xa1th95m7r6w.fsf@mina86.com>
 <58660BBE.1040807@samsung.com> <20161230094411.GD13301@dhcp22.suse.cz>
 <xa1tpok6igqb.fsf@mina86.com> <5869E849.1040605@samsung.com>
 <xa1tmvfahscn.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, m.szyprowski@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com



On 2017e?? 01i?? 02i? 1/4  15:46, Michal Nazarewicz wrote:
> On Mon, Jan 02 2017, Jaewon Kim wrote:
>> There are many reasons of CMA allocation failure such as EBUSY, ENOMEM, EINTR.
>> But we did not know error reason so far. This patch prints the error value.
>>
>> Additionally if CONFIG_CMA_DEBUG is enabled, this patch shows bitmap status to
>> know available pages. Actually CMA internally tries on all available regions
>> because some regions can be failed because of EBUSY. Bitmap status is useful to
>> know in detail on both ENONEM and EBUSY;
>>  ENOMEM: not tried at all because of no available region
>>          it could be too small total region or could be fragmentation issue
>>  EBUSY:  tried some region but all failed
>>
>> This is an ENOMEM example with this patch.
>> [   12.415458]  [2:   Binder:714_1:  744] cma: cma_alloc: alloc failed, req-size: 256 pages, ret: -12
>> If CONFIG_CMA_DEBUG is enabled, avabile pages also will be shown as concatenated
>> size@position format. So 4@572 means that there are 4 available pages at 572
>> position starting from 0 position.
>> [   12.415503]  [2:   Binder:714_1:  744] cma: number of available pages: 4@572+7@585+7@601+8@632+38@730+166@1114+127@1921=> 357 free of 2048 total pages
>>
>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
>> Acked-by: Michal Nazarewicz <mina86@mina86.com>
>> ---
>>  mm/cma.c | 34 +++++++++++++++++++++++++++++++++-
>>  1 file changed, 33 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/cma.c b/mm/cma.c
>> index c960459..9e037541 100644
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -353,6 +353,32 @@ int __init cma_declare_contiguous(phys_addr_t base,
>>      return ret;
>>  }
>>  
>> +#ifdef CONFIG_CMA_DEBUG
>> +static void debug_show_cma_areas(struct cma *cma)
> Make it a??cma_debug_show_areasa??.  All other functions have a??cmaa?? as
> prefix so thata??s more consistent.
OK no problem.
>
>> +{
>> +    unsigned long next_zero_bit, next_set_bit;
>> +    unsigned long start = 0;
>> +    unsigned int nr_zero, nr_total = 0;
>> +
>> +    mutex_lock(&cma->lock);
>> +    pr_info("number of available pages: ");
>> +    for (;;) {
>> +        next_zero_bit = find_next_zero_bit(cma->bitmap, cma->count, start);
>> +        if (next_zero_bit >= cma->count)
>> +            break;
>> +        next_set_bit = find_next_bit(cma->bitmap, cma->count, next_zero_bit);
>> +        nr_zero = next_set_bit - next_zero_bit;
>> +        pr_cont("%s%u@%lu", nr_total ? "+" : "", nr_zero, next_zero_bit);
>> +        nr_total += nr_zero;
>> +        start = next_zero_bit + nr_zero;
>> +    }
>> +    pr_cont("=> %u free of %lu total pages\n", nr_total, cma->count);
>> +    mutex_unlock(&cma->lock);
>> +}
>> +#else
>> +static inline void debug_show_cma_areas(struct cma *cma) { }
>> +#endif
>> +
>>  /**
>>   * cma_alloc() - allocate pages from contiguous area
>>   * @cma:   Contiguous memory region for which the allocation is performed.
>> @@ -369,7 +395,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
>>      unsigned long start = 0;
>>      unsigned long bitmap_maxno, bitmap_no, bitmap_count;
>>      struct page *page = NULL;
>> -    int ret;
>> +    int ret = -ENOMEM;
>>  
>>      if (!cma || !cma->count)
>>          return NULL;
>> @@ -426,6 +452,12 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
>>  
>>      trace_cma_alloc(pfn, page, count, align);
>>  
>> +    if (ret) {
>> +        pr_info("%s: alloc failed, req-size: %zu pages, ret: %d\n",
>> +            __func__, count, ret);
>> +        debug_show_cma_areas(cma);
>> +    }
>> +
>>      pr_debug("%s(): returned %p\n", __func__, page);
>>      return page;
>>  }
>> -- 
>>

Added the latest.
