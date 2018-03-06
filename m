Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA316B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 12:39:45 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a3so6487660wme.1
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 09:39:45 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 26si495786edw.197.2018.03.06.09.39.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 09:39:44 -0800 (PST)
Subject: Re: [PATCH 1/7] genalloc: track beginning of allocations
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-2-igor.stoppa@huawei.com>
 <6a31164a-af3f-91ea-d385-7c6d1888b28c@gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <05bde73d-6c0a-8309-4150-7225862c28e0@huawei.com>
Date: Tue, 6 Mar 2018 19:39:41 +0200
MIME-Version: 1.0
In-Reply-To: <6a31164a-af3f-91ea-d385-7c6d1888b28c@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J Freyensee <why2jjj.linux@gmail.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 05/03/2018 21:00, J Freyensee wrote:
> .
> .
> 
> 
> On 2/28/18 12:06 PM, Igor Stoppa wrote:
>> +
>> +/**
>> + * gen_pool_dma_alloc() - allocate special memory from the pool for DMA usage
>> + * @pool: pool to allocate from
>> + * @size: number of bytes to allocate from the pool
>> + * @dma: dma-view physical address return value.  Use NULL if unneeded.
>> + *
>> + * Allocate the requested number of bytes from the specified pool.
>> + * Uses the pool allocation function (with first-fit algorithm by default).
>> + * Can not be used in NMI handler on architectures without
>> + * NMI-safe cmpxchg implementation.
>> + *
>> + * Return:
>> + * * address of the memory allocated	- success
>> + * * NULL				- error
>> + */
>> +void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma);
>> +
> 
> OK, so gen_pool_dma_alloc() is defined here, which believe is the API 
> line being drawn for this series.
> 
> so,
> .
> .
> .
>>
>>   
>>   /**
>> - * gen_pool_dma_alloc - allocate special memory from the pool for DMA usage
>> + * gen_pool_dma_alloc() - allocate special memory from the pool for DMA usage
>>    * @pool: pool to allocate from
>>    * @size: number of bytes to allocate from the pool
>>    * @dma: dma-view physical address return value.  Use NULL if unneeded.
>> @@ -342,14 +566,15 @@ EXPORT_SYMBOL(gen_pool_alloc_algo);
>>    * Uses the pool allocation function (with first-fit algorithm by default).
>>    * Can not be used in NMI handler on architectures without
>>    * NMI-safe cmpxchg implementation.
>> + *
>> + * Return:
>> + * * address of the memory allocated	- success
>> + * * NULL				- error
>>    */
>>   void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma)
>>   {
>>   	unsigned long vaddr;
>>   
>> -	if (!pool)
>> -		return NULL;
>> -
> why is this being removed?A  I don't believe this code was getting 
> removed from your v17 series patches.

Because, as Matthew Wilcox pointed out [1] (well, that's how I
understood it) de-referencing a NULL pointer will cause the kernel to
complain loudly.

Where is the NULL pointer coming from?

a) from a bug in the user of the API - in that case it will be noticed,
reported and fixed, that is how also other in-kernel APIs work

b) from an attacker - it will still trigger an error from the kernel,
but it cannot really do much else, besides crashing repeatedly and
causing a DOS. However, there are so many other places that could be
under similar attack, that it doesn't seem to make a difference having a
check here only.

If the value was coming from userspace, that would be a completely
different case and some sort of sanitation would be mandatory.

> Otherwise, looks good,
> 
> Reviewed-by: Jay Freyensee <why2jjj.linux@gmail.com>

thanks


[1] http://www.openwall.com/lists/kernel-hardening/2018/02/26/16


--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
