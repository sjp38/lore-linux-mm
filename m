Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B49726B0038
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 11:33:27 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 80so1047689lfy.5
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 08:33:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b75sor22785ljb.84.2017.09.22.08.33.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Sep 2017 08:33:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <37e3ce0e-717d-156d-fef3-27559aff980e@arm.com>
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
 <20170921085922.11659-3-ganapatrao.kulkarni@cavium.com> <37e3ce0e-717d-156d-fef3-27559aff980e@arm.com>
From: Ganapatrao Kulkarni <gklkml16@gmail.com>
Date: Fri, 22 Sep 2017 21:03:24 +0530
Message-ID: <CAKTKpr65XoLCDh1RxEq-nSpZcsSuPnHiZrp6McQBx3xrAhhxYA@mail.gmail.com>
Subject: Re: [PATCH 2/4] numa, iommu/io-pgtable-arm: Use NUMA aware memory
 allocation for smmu translation tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, Will Deacon <Will.Deacon@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Hanjun Guo <hanjun.guo@linaro.org>, Joerg Roedel <joro@8bytes.org>, vbabka@suse.cz, akpm@linux-foundation.org, mhocko@suse.com, Tomasz.Nowicki@cavium.com, Robert.Richter@cavium.com, jnair@caviumnetworks.com

On Thu, Sep 21, 2017 at 4:41 PM, Robin Murphy <robin.murphy@arm.com> wrote:
> On 21/09/17 09:59, Ganapatrao Kulkarni wrote:
>> function __arm_lpae_alloc_pages is used to allcoated memory for smmu
>> translation tables. updating function to allocate memory/pages
>> from the proximity domain of SMMU device.
>
> AFAICS, data->pgd_size always works out to a power-of-two number of
> pages, so I'm not sure why we've ever needed alloc_pages_exact() here. I
> think we could simply use alloc_pages_node() and drop patch #1.

thanks Robin, i think we can replace with alloc_pages_node.
i will change as suggested in next version.

>
> Robin.
>
>> Signed-off-by: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
>> ---
>>  drivers/iommu/io-pgtable-arm.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/iommu/io-pgtable-arm.c b/drivers/iommu/io-pgtable-arm.c
>> index e8018a3..f6d01f6 100644
>> --- a/drivers/iommu/io-pgtable-arm.c
>> +++ b/drivers/iommu/io-pgtable-arm.c
>> @@ -215,8 +215,10 @@ static void *__arm_lpae_alloc_pages(size_t size, gfp_t gfp,
>>  {
>>       struct device *dev = cfg->iommu_dev;
>>       dma_addr_t dma;
>> -     void *pages = alloc_pages_exact(size, gfp | __GFP_ZERO);
>> +     void *pages;
>>
>> +     pages = alloc_pages_exact_nid(dev_to_node(dev), size,
>> +                     gfp | __GFP_ZERO);
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
