Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1236B0035
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 18:00:55 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so10682531pab.1
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 15:00:54 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ro10si7789816pbc.207.2014.07.21.15.00.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jul 2014 15:00:54 -0700 (PDT)
Message-ID: <53CD8D94.9060207@codeaurora.org>
Date: Mon, 21 Jul 2014 15:00:52 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCHv4 5/5] arm64: Add atomic pool for non-coherent and CMA
 allocations.
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org> <1404324218-4743-6-git-send-email-lauraa@codeaurora.org> <20140704133517.GA9860@ulmo>
In-Reply-To: <20140704133517.GA9860@ulmo>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thierry Reding <thierry.reding@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, David Riley <davidriley@chromium.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-arm-kernel@lists.infradead.org

On 7/4/2014 6:35 AM, Thierry Reding wrote:
> On Wed, Jul 02, 2014 at 11:03:38AM -0700, Laura Abbott wrote:
> [...]
>> diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
> [...]
>> +static struct gen_pool *atomic_pool;
>> +
>> +#define DEFAULT_DMA_COHERENT_POOL_SIZE  SZ_256K
>> +static size_t atomic_pool_size = DEFAULT_DMA_COHERENT_POOL_SIZE;
> 
> There doesn't seem to be much use for this since it can't be overridden
> via init_dma_coherent_pool_size like on ARM.
> 

There is still the command line option coherent_pool=<size> though

[...]
>> +	if (page) {
>> +		int ret;
>> +
>> +		atomic_pool = gen_pool_create(PAGE_SHIFT, -1);
>> +		if (!atomic_pool)
>> +			goto free_page;
>> +
>> +		addr = dma_common_contiguous_remap(page, atomic_pool_size,
>> +					VM_USERMAP, prot, atomic_pool_init);
>> +
>> +		if (!addr)
>> +			goto destroy_genpool;
>> +
>> +		memset(addr, 0, atomic_pool_size);
>> +		__dma_flush_range(addr, addr + atomic_pool_size);
>> +
>> +		ret = gen_pool_add_virt(atomic_pool, (unsigned long)addr,
>> +					page_to_phys(page),
>> +					atomic_pool_size, -1);
>> +		if (ret)
>> +			goto remove_mapping;
>> +
>> +		gen_pool_set_algo(atomic_pool,
>> +				  gen_pool_first_fit_order_align, NULL);
>> +
>> +		pr_info("DMA: preallocated %zd KiB pool for atomic allocations\n",
> 
> I think this should be "%zu" because atomic_pool_size is a size_t, not a
> ssize_t.
> 

Yes, will fix.

>> +			atomic_pool_size / 1024);
>> +		return 0;
>> +	}
>> +	goto out;
>> +
>> +remove_mapping:
>> +	dma_common_free_remap(addr, atomic_pool_size, VM_USERMAP);
>> +destroy_genpool:
>> +	gen_pool_destroy(atomic_pool);
>> +	atomic_pool == NULL;
> 
> This probably doesn't belong here.
> 

Dastardly typo.

>> +free_page:
>> +	if (!dma_release_from_contiguous(NULL, page, nr_pages))
>> +		__free_pages(page, get_order(atomic_pool_size));
> 
> You use get_order(atomic_pool_size) a lot, perhaps it should be a
> temporary variable?
> 

Yes, three usages is probably enough.

>> +out:
>> +	pr_err("DMA: failed to allocate %zx KiB pool for atomic coherent allocation\n",
>> +		atomic_pool_size / 1024);
> 
> Print in decimal rather than hexadecimal?
> 

I actually prefer hexadecimal but I should at least be consistent between
error and non-error paths.

> Thierry
> 

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
