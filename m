Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B71BE6B0253
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 11:44:53 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l196so1072535lfl.2
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 08:44:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b68sor27428lfb.109.2017.09.22.08.44.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Sep 2017 08:44:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <9d65676f-e4e8-e0a6-602c-361d83ce83c1@arm.com>
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
 <20170921085922.11659-5-ganapatrao.kulkarni@cavium.com> <9d65676f-e4e8-e0a6-602c-361d83ce83c1@arm.com>
From: Ganapatrao Kulkarni <gklkml16@gmail.com>
Date: Fri, 22 Sep 2017 21:14:51 +0530
Message-ID: <CAKTKpr6O9OpT+WgWStYda3EZcbwbs5dzp10SnEfDEt8Z-ZaAhA@mail.gmail.com>
Subject: Re: [PATCH 4/4] iommu/dma, numa: Use NUMA aware memory allocations in __iommu_dma_alloc_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, Will Deacon <Will.Deacon@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Hanjun Guo <hanjun.guo@linaro.org>, Joerg Roedel <joro@8bytes.org>, vbabka@suse.cz, akpm@linux-foundation.org, mhocko@suse.com, Tomasz.Nowicki@cavium.com, Robert.Richter@cavium.com, jnair@caviumnetworks.com

Hi Robin,


On Thu, Sep 21, 2017 at 5:11 PM, Robin Murphy <robin.murphy@arm.com> wrote:
> On 21/09/17 09:59, Ganapatrao Kulkarni wrote:
>> Change function __iommu_dma_alloc_pages to allocate memory/pages
>> for dma from respective device numa node.
>>
>> Signed-off-by: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
>> ---
>>  drivers/iommu/dma-iommu.c | 17 ++++++++++-------
>>  1 file changed, 10 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
>> index 9d1cebe..0626b58 100644
>> --- a/drivers/iommu/dma-iommu.c
>> +++ b/drivers/iommu/dma-iommu.c
>> @@ -428,20 +428,21 @@ static void __iommu_dma_free_pages(struct page **pages, int count)
>>       kvfree(pages);
>>  }
>>
>> -static struct page **__iommu_dma_alloc_pages(unsigned int count,
>> -             unsigned long order_mask, gfp_t gfp)
>> +static struct page **__iommu_dma_alloc_pages(struct device *dev,
>> +             unsigned int count, unsigned long order_mask, gfp_t gfp)
>>  {
>>       struct page **pages;
>>       unsigned int i = 0, array_size = count * sizeof(*pages);
>> +     int numa_node = dev_to_node(dev);
>>
>>       order_mask &= (2U << MAX_ORDER) - 1;
>>       if (!order_mask)
>>               return NULL;
>>
>>       if (array_size <= PAGE_SIZE)
>> -             pages = kzalloc(array_size, GFP_KERNEL);
>> +             pages = kzalloc_node(array_size, GFP_KERNEL, numa_node);
>>       else
>> -             pages = vzalloc(array_size);
>> +             pages = vzalloc_node(array_size, numa_node);
>
> kvzalloc{,_node}() didn't exist when this code was first written, but it
> does now - since you're touching it you may as well get rid of the whole
> if-else and array_size local.

thanks, i will update in next version.
>
> Further nit: some of the indentation below is a bit messed up.

ok, will fix it.
>
> Robin.
>
>>       if (!pages)
>>               return NULL;
>>
>> @@ -462,8 +463,9 @@ static struct page **__iommu_dma_alloc_pages(unsigned int count,
>>                       unsigned int order = __fls(order_mask);
>>
>>                       order_size = 1U << order;
>> -                     page = alloc_pages((order_mask - order_size) ?
>> -                                        gfp | __GFP_NORETRY : gfp, order);
>> +                     page = alloc_pages_node(numa_node,
>> +                                     (order_mask - order_size) ?
>> +                                gfp | __GFP_NORETRY : gfp, order);
>>                       if (!page)
>>                               continue;
>>                       if (!order)
>> @@ -548,7 +550,8 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
>>               alloc_sizes = min_size;
>>
>>       count = PAGE_ALIGN(size) >> PAGE_SHIFT;
>> -     pages = __iommu_dma_alloc_pages(count, alloc_sizes >> PAGE_SHIFT, gfp);
>> +     pages = __iommu_dma_alloc_pages(dev, count, alloc_sizes >> PAGE_SHIFT,
>> +                     gfp);
>>       if (!pages)
>>               return NULL;
>>
>>
>

thanks
Ganapat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
