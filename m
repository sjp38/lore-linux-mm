Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F2EEE6B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 10:49:59 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a70-v6so5419041qkb.16
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 07:49:59 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id d17-v6si5221103qtd.64.2018.08.03.07.49.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 07:49:58 -0700 (PDT)
Subject: Re: [PATCH v2 8/9] dmapool: reduce footprint in struct page
References: <0ccfd31b-0a3f-9ae8-85c8-e176cd5453a9@cybernetics.com>
 <20180802235626.GA5773@bombadil.infradead.org>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <38967c65-4b3d-7a56-022f-bd291539e6cd@cybernetics.com>
Date: Fri, 3 Aug 2018 10:49:56 -0400
MIME-Version: 1.0
In-Reply-To: <20180802235626.GA5773@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, MPT-FusionLinux.pdl@broadcom.com

On 08/02/2018 07:56 PM, Matthew Wilcox wrote:
>
>>  struct dma_pool {		/* the pool */
>>  #define POOL_FULL_IDX   0
>>  #define POOL_AVAIL_IDX  1
>>  #define POOL_N_LISTS    2
>>  	struct list_head page_list[POOL_N_LISTS];
>>  	spinlock_t lock;
>> -	size_t size;
>>  	struct device *dev;
>> -	size_t allocation;
>> -	size_t boundary;
>> +	unsigned int size;
>> +	unsigned int allocation;
>> +	unsigned int boundary_shift;
>> +	unsigned int blks_per_boundary;
>> +	unsigned int blks_per_alloc;
> s/size_t/unsigned int/ is a good saving on 64-bit systems.  We recently
> did something similar for slab/slub.

I was trying to avoid 64-bit multiply and divide in the fast path.A  And
the rest of the code uses unsigned int in various places, so big sizes
won't work anyway.A  But without the conversion from "byte offset" to
"block index" everywhere, the overhead doesn't matter as much.A  But it
could still be done.

One place where size_t might be appropriate is in show_pools() when
adding together the memory usage of the entire pool (it currently uses
unsigned int).A  Now that it scales well. ;)

>
>> @@ -141,6 +150,7 @@ static DEVICE_ATTR(pools, 0444, show_pool
>>  struct dma_pool *dma_pool_create(const char *name, struct device *dev,
>>  				 size_t size, size_t align, size_t boundary)
>>  {
> We should change the API here too.
>
>
There are a lot of kernel API functions that take a size_t, even though
a contiguous chunk of memory >= 4 GiB is pretty rare in the kernel.A  For
example, dma_alloc_coherent() takes a size_t.A  I suppose if you take a
size_t you can return an error if the value is bigger than supported.A 
OTOH, if you take an unsigned int, a huge value could be truncated
before you perform your range check on it.A  size_t also has the benefit
of implicitly "documenting" the interface because people immediately
know what it means.
