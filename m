Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 44E3D8E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 11:32:12 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id 32so4890975ots.15
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 08:32:12 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d17si5070143oth.75.2018.12.10.08.32.10
        for <linux-mm@kvack.org>;
        Mon, 10 Dec 2018 08:32:10 -0800 (PST)
Subject: Re: [PATCH v3 2/9] arch/arm/mm/dma-mapping.c: Convert to use
 vm_insert_range
References: <20181206184103.GA25872@jordon-HP-15-Notebook-PC>
 <CAFqt6zY9JjGhedtmhYh-+mxSMrYs6P5vtQDMSzCfL02CbLys=g@mail.gmail.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <217b80f9-e02c-d02c-3c82-425c550e4ed7@arm.com>
Date: Mon, 10 Dec 2018 16:32:06 +0000
MIME-Version: 1.0
In-Reply-To: <CAFqt6zY9JjGhedtmhYh-+mxSMrYs6P5vtQDMSzCfL02CbLys=g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org

On 08/12/2018 20:01, Souptick Joarder wrote:
> Hi Robin,
> 
> On Fri, Dec 7, 2018 at 12:07 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>>
>> Convert to use vm_insert_range() to map range of kernel
>> memory to user vma.
>>
>> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>> ---
>>   arch/arm/mm/dma-mapping.c | 21 +++++++--------------
>>   1 file changed, 7 insertions(+), 14 deletions(-)
>>
>> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
>> index 661fe48..4eec323 100644
>> --- a/arch/arm/mm/dma-mapping.c
>> +++ b/arch/arm/mm/dma-mapping.c
>> @@ -1582,31 +1582,24 @@ static int __arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma
>>                      void *cpu_addr, dma_addr_t dma_addr, size_t size,
>>                      unsigned long attrs)
>>   {
>> -       unsigned long uaddr = vma->vm_start;
>> -       unsigned long usize = vma->vm_end - vma->vm_start;
>> +       unsigned long page_count = vma_pages(vma);
>>          struct page **pages = __iommu_get_pages(cpu_addr, attrs);
>>          unsigned long nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
>>          unsigned long off = vma->vm_pgoff;
>> +       int err;
>>
>>          if (!pages)
>>                  return -ENXIO;
>>
>> -       if (off >= nr_pages || (usize >> PAGE_SHIFT) > nr_pages - off)
>> +       if (off >= nr_pages || page_count > nr_pages - off)
>>                  return -ENXIO;
>>
>>          pages += off;
>> +       err = vm_insert_range(vma, vma->vm_start, pages, page_count);
> 
> Just to clarify, do we need to adjust page_count with vma->vm_pgoff as
> original code
> have not consider it and run the loop for entire range irrespective of
> vma->vm_pgoff value ?

In this instance, page_count is the size of the VMA, not the size of the 
pages array itself, so as I understand things this patch is true to the 
original code as-is.

Robin.

> 
>> +       if (err)
>> +               pr_err("Remapping memory failed: %d\n", err);
>>
>> -       do {
>> -               int ret = vm_insert_page(vma, uaddr, *pages++);
>> -               if (ret) {
>> -                       pr_err("Remapping memory failed: %d\n", ret);
>> -                       return ret;
>> -               }
>> -               uaddr += PAGE_SIZE;
>> -               usize -= PAGE_SIZE;
>> -       } while (usize > 0);
>> -
>> -       return 0;
>> +       return err;
>>   }
>>   static int arm_iommu_mmap_attrs(struct device *dev,
>>                  struct vm_area_struct *vma, void *cpu_addr,
>> --
>> 1.9.1
>>
