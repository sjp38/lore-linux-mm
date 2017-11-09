Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 68ABF44043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 20:17:38 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id k190so2835849pga.10
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 17:17:38 -0800 (PST)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id g207si5322019pfb.413.2017.11.08.17.17.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 17:17:36 -0800 (PST)
Subject: Re: [PATCH for-next 2/4] RDMA/hns: Add IOMMU enable support in hip08
References: <1506763741-81429-1-git-send-email-xavier.huwei@huawei.com>
 <1506763741-81429-3-git-send-email-xavier.huwei@huawei.com>
 <20170930161023.GI2965@mtr-leonro.local> <59DF60A3.7080803@huawei.com>
 <5fe5f9b9-2c2b-ab3c-dafa-3e2add051bbb@arm.com> <59F97BBE.5070207@huawei.com>
 <fc7433af-4fa7-6b78-6bec-26941a427002@arm.com> <5A011E49.6060407@huawei.com>
 <20171107063209.GA18825@mtr-leonro.local>
From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Message-ID: <5A03AC90.30108@huawei.com>
Date: Thu, 9 Nov 2017 09:17:04 +0800
MIME-Version: 1.0
In-Reply-To: <20171107063209.GA18825@mtr-leonro.local>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@kernel.org>
Cc: Robin Murphy <robin.murphy@arm.com>, shaobo.xu@intel.com, xavier.huwei@tom.com, lijun_nudt@163.com, oulijun@huawei.com, linux-rdma@vger.kernel.org, charles.chenxin@huawei.com, linuxarm@huawei.com, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dledford@redhat.com, liuyixian@huawei.com, zhangxiping3@huawei.com, shaoboxu@tom.com



On 2017/11/7 14:32, Leon Romanovsky wrote:
> On Tue, Nov 07, 2017 at 10:45:29AM +0800, Wei Hu (Xavier) wrote:
>>
>> On 2017/11/1 20:26, Robin Murphy wrote:
>>> On 01/11/17 07:46, Wei Hu (Xavier) wrote:
>>>> On 2017/10/12 20:59, Robin Murphy wrote:
>>>>> On 12/10/17 13:31, Wei Hu (Xavier) wrote:
>>>>>> On 2017/10/1 0:10, Leon Romanovsky wrote:
>>>>>>> On Sat, Sep 30, 2017 at 05:28:59PM +0800, Wei Hu (Xavier) wrote:
>>>>>>>> If the IOMMU is enabled, the length of sg obtained from
>>>>>>>> __iommu_map_sg_attrs is not 4kB. When the IOVA is set with the sg
>>>>>>>> dma address, the IOVA will not be page continuous. and the VA
>>>>>>>> returned from dma_alloc_coherent is a vmalloc address. However,
>>>>>>>> the VA obtained by the page_address is a discontinuous VA. Under
>>>>>>>> these circumstances, the IOVA should be calculated based on the
>>>>>>>> sg length, and record the VA returned from dma_alloc_coherent
>>>>>>>> in the struct of hem.
>>>>>>>>
>>>>>>>> Signed-off-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
>>>>>>>> Signed-off-by: Shaobo Xu <xushaobo2@huawei.com>
>>>>>>>> Signed-off-by: Lijun Ou <oulijun@huawei.com>
>>>>>>>> ---
>>>>>>> Doug,
>>>>>>>
>>>>>>> I didn't invest time in reviewing it, but having "is_vmalloc_addr" in
>>>>>>> driver code to deal with dma_alloc_coherent is most probably wrong.
>>>>>>>
>>>>>>> Thanks
>>>>>> Hi,  Leon & Doug
>>>>>>     We refered the function named __ttm_dma_alloc_page in the kernel
>>>>>> code as below:
>>>>>>     And there are similar methods in bch_bio_map and mem_to_page
>>>>>> functions in current 4.14-rcx.
>>>>>>
>>>>>>         static struct dma_page *__ttm_dma_alloc_page(struct dma_pool *pool)
>>>>>>         {
>>>>>>             struct dma_page *d_page;
>>>>>>
>>>>>>             d_page = kmalloc(sizeof(struct dma_page), GFP_KERNEL);
>>>>>>             if (!d_page)
>>>>>>                 return NULL;
>>>>>>
>>>>>>             d_page->vaddr = dma_alloc_coherent(pool->dev, pool->size,
>>>>>>                                &d_page->dma,
>>>>>>                                    pool->gfp_flags);
>>>>>>             if (d_page->vaddr) {
>>>>>>                 if (is_vmalloc_addr(d_page->vaddr))
>>>>>>                     d_page->p = vmalloc_to_page(d_page->vaddr);
>>>>>>                 else
>>>>>>                     d_page->p = virt_to_page(d_page->vaddr);
>>>>> There are cases on various architectures where neither of those is
>>>>> right. Whether those actually intersect with TTM or RDMA use-cases is
>>>>> another matter, of course.
>>>>>
>>>>> What definitely is a problem is if you ever take that page and end up
>>>>> accessing it through any virtual address other than the one explicitly
>>>>> returned by dma_alloc_coherent(). That can blow the coherency wide open
>>>>> and invite data loss, right up to killing the whole system with a
>>>>> machine check on certain architectures.
>>>>>
>>>>> Robin.
>>>> Hi, Robin
>>>>     Thanks for your comment.
>>>>
>>>>     We have one problem and the related code as below.
>>>>     1. call dma_alloc_coherent function  serval times to alloc memory.
>>>>     2. vmap the allocated memory pages.
>>>>     3. software access memory by using the return virt addr of vmap
>>>>         and hardware using the dma addr of dma_alloc_coherent.
>>> The simple answer is "don't do that". Seriously. dma_alloc_coherent()
>>> gives you a CPU virtual address and a DMA address with which to access
>>> your buffer, and that is the limit of what you may infer about it. You
>>> have no guarantee that the virtual address is either in the linear map
>>> or vmalloc, and not some other special place. You have no guarantee that
>>> the underlying memory even has an associated struct page at all.
>>>
>>>>     When IOMMU is disabled in ARM64 architecture, we use virt_to_page()
>>>>     before vmap(), it works. And when IOMMU is enabled using
>>>>     virt_to_page() will cause calltrace later, we found the return
>>>>     addr of dma_alloc_coherent is vmalloc addr, so we add the
>>>>     condition judgement statement as below, it works.
>>>>         for (i = 0; i < buf->nbufs; ++i)
>>>>                 pages[i] =
>>>>                     is_vmalloc_addr(buf->page_list[i].buf) ?
>>>>                     vmalloc_to_page(buf->page_list[i].buf) :
>>>>                     virt_to_page(buf->page_list[i].buf);
>>>>     Can you give us suggestion? better method?
>>> Oh my goodness, having now taken a closer look at this driver, I'm lost
>>> for words in disbelief. To pick just one example:
>>>
>>> 	u32 bits_per_long = BITS_PER_LONG;
>>> 	...
>>> 	if (bits_per_long == 64) {
>>> 		/* memory mapping nonsense */
>>> 	}
>>>
>>> WTF does the size of a long have to do with DMA buffer management!?
>>>
>>> Of course I can guess that it might be trying to make some tortuous
>>> inference about vmalloc space being constrained on 32-bit platforms, but
>>> still...
>>>
>>>>     The related code as below:
>>>>         buf->page_list = kcalloc(buf->nbufs, sizeof(*buf->page_list),
>>>>                      GFP_KERNEL);
>>>>         if (!buf->page_list)
>>>>             return -ENOMEM;
>>>>
>>>>         for (i = 0; i < buf->nbufs; ++i) {
>>>>             buf->page_list[i].buf = dma_alloc_coherent(dev,
>>>>                                   page_size, &t,
>>>>                                   GFP_KERNEL);
>>>>             if (!buf->page_list[i].buf)
>>>>                 goto err_free;
>>>>
>>>>             buf->page_list[i].map = t;
>>>>             memset(buf->page_list[i].buf, 0, page_size);
>>>>         }
>>>>
>>>>         pages = kmalloc_array(buf->nbufs, sizeof(*pages),
>>>>                           GFP_KERNEL);
>>>>         if (!pages)
>>>>                 goto err_free;
>>>>
>>>>         for (i = 0; i < buf->nbufs; ++i)
>>>>                 pages[i] =
>>>>                     is_vmalloc_addr(buf->page_list[i].buf) ?
>>>>                     vmalloc_to_page(buf->page_list[i].buf) :
>>>>                     virt_to_page(buf->page_list[i].buf);
>>>>
>>>>         buf->direct.buf = vmap(pages, buf->nbufs, VM_MAP,
>>>>                            PAGE_KERNEL);
>>>>         kfree(pages);
>>>>         if (!buf->direct.buf)
>>>>                 goto err_free;
>>> OK, this is complete crap. As above, you cannot assume that a struct
>>> page even exists; even if it does you cannot assume that using a
>>> PAGE_KERNEL mapping will not result in mismatched attributes,
>>> unpredictable behaviour and data loss. Trying to remap coherent DMA
>>> allocations like this is just egregiously wrong.
>>>
>>> What I do like is that you can seemingly fix all this by simply deleting
>>> hns_roce_buf::direct and all the garbage code related to it, and using
>>> the page_list entries consistently because the alternate paths involving
>>> those appear to do the right thing already.
>>>
>>> That is, of course, assuming that the buffers involved can be so large
>>> that it's not practical to just always make a single allocation and
>>> fragment it into multiple descriptors if the hardware does have some
>>> maximum length constraint - frankly I'm a little puzzled by the
>>> PAGE_SIZE * 2 threshold, given that that's not a fixed size.
>>>
>>> Robin.
>> Hii 1/4 ?Robin
>>
>>     We reconstruct the code as below:
>>             It replaces dma_alloc_coherent with __get_free_pages and
>> dma_map_single
>>     functions. So, we can vmap serveral ptrs returned by
>> __get_free_pages, right?
> Most probably not, you should get rid of your virt_to_page/vmap calls.
>
> Thanks
Hi, Leon
    Thanks for your suggestion.
    I will send a patch to fix it.

    Regards
Wei Hu
>>
>>         buf->page_list = kcalloc(buf->nbufs, sizeof(*buf->page_list),
>>                      GFP_KERNEL);
>>         if (!buf->page_list)
>>             return -ENOMEM;
>>
>>         for (i = 0; i < buf->nbufs; ++i) {
>> 		ptr = (void *)__get_free_pages(GFP_KERNEL | __GFP_ZERO,
>> 					       get_order(page_size));
>> 		if (!ptr) {
>> 			dev_err(dev, "Alloc pages error.\n");
>> 			goto err_free;
>> 		}
>>
>> 		t = dma_map_single(dev, ptr, page_size,
>> 				   DMA_BIDIRECTIONAL);
>> 		if (dma_mapping_error(dev, t)) {
>> 			dev_err(dev, "DMA mapping error.\n");
>> 			free_pages((unsigned long)ptr,
>> 				   get_order(page_size));
>> 			goto err_free;
>> 		}
>>
>> 		buf->page_list[i].buf = ptr;
>> 		buf->page_list[i].map = t;
>>         }
>>
>>         pages = kmalloc_array(buf->nbufs, sizeof(*pages),
>>                           GFP_KERNEL);
>>         if (!pages)
>>                 goto err_free;
>>
>>         for (i = 0; i < buf->nbufs; ++i)
>>                 pages[i] = virt_to_page(buf->page_list[i].buf);
>>
>>         buf->direct.buf = vmap(pages, buf->nbufs, VM_MAP,
>>                            PAGE_KERNEL);
>>         kfree(pages);
>>         if (!buf->direct.buf)
>>                 goto err_free;
>>
>>
>>     Regards
>> Wei Hu
>>>>     Regards
>>>> Wei Hu
>>>>>>             } else {
>>>>>>                 kfree(d_page);
>>>>>>                 d_page = NULL;
>>>>>>             }
>>>>>>             return d_page;
>>>>>>         }
>>>>>>
>>>>>>     Regards
>>>>>> Wei Hu
>>>>>>>>   drivers/infiniband/hw/hns/hns_roce_alloc.c |  5 ++++-
>>>>>>>>   drivers/infiniband/hw/hns/hns_roce_hem.c   | 30
>>>>>>>> +++++++++++++++++++++++++++---
>>>>>>>>   drivers/infiniband/hw/hns/hns_roce_hem.h   |  6 ++++++
>>>>>>>>   drivers/infiniband/hw/hns/hns_roce_hw_v2.c | 22 +++++++++++++++-------
>>>>>>>>   4 files changed, 52 insertions(+), 11 deletions(-)
>>>>>>>>
>>>>>>>> diff --git a/drivers/infiniband/hw/hns/hns_roce_alloc.c
>>>>>>>> b/drivers/infiniband/hw/hns/hns_roce_alloc.c
>>>>>>>> index 3e4c525..a69cd4b 100644
>>>>>>>> --- a/drivers/infiniband/hw/hns/hns_roce_alloc.c
>>>>>>>> +++ b/drivers/infiniband/hw/hns/hns_roce_alloc.c
>>>>>>>> @@ -243,7 +243,10 @@ int hns_roce_buf_alloc(struct hns_roce_dev
>>>>>>>> *hr_dev, u32 size, u32 max_direct,
>>>>>>>>                   goto err_free;
>>>>>>>>
>>>>>>>>               for (i = 0; i < buf->nbufs; ++i)
>>>>>>>> -                pages[i] = virt_to_page(buf->page_list[i].buf);
>>>>>>>> +                pages[i] =
>>>>>>>> +                    is_vmalloc_addr(buf->page_list[i].buf) ?
>>>>>>>> +                    vmalloc_to_page(buf->page_list[i].buf) :
>>>>>>>> +                    virt_to_page(buf->page_list[i].buf);
>>>>>>>>
>>>>>>>>               buf->direct.buf = vmap(pages, buf->nbufs, VM_MAP,
>>>>>>>>                              PAGE_KERNEL);
>>>>>>>> diff --git a/drivers/infiniband/hw/hns/hns_roce_hem.c
>>>>>>>> b/drivers/infiniband/hw/hns/hns_roce_hem.c
>>>>>>>> index 8388ae2..4a3d1d4 100644
>>>>>>>> --- a/drivers/infiniband/hw/hns/hns_roce_hem.c
>>>>>>>> +++ b/drivers/infiniband/hw/hns/hns_roce_hem.c
>>>>>>>> @@ -200,6 +200,7 @@ static struct hns_roce_hem
>>>>>>>> *hns_roce_alloc_hem(struct hns_roce_dev *hr_dev,
>>>>>>>>                              gfp_t gfp_mask)
>>>>>>>>   {
>>>>>>>>       struct hns_roce_hem_chunk *chunk = NULL;
>>>>>>>> +    struct hns_roce_vmalloc *vmalloc;
>>>>>>>>       struct hns_roce_hem *hem;
>>>>>>>>       struct scatterlist *mem;
>>>>>>>>       int order;
>>>>>>>> @@ -227,6 +228,7 @@ static struct hns_roce_hem
>>>>>>>> *hns_roce_alloc_hem(struct hns_roce_dev *hr_dev,
>>>>>>>>               sg_init_table(chunk->mem, HNS_ROCE_HEM_CHUNK_LEN);
>>>>>>>>               chunk->npages = 0;
>>>>>>>>               chunk->nsg = 0;
>>>>>>>> +            memset(chunk->vmalloc, 0, sizeof(chunk->vmalloc));
>>>>>>>>               list_add_tail(&chunk->list, &hem->chunk_list);
>>>>>>>>           }
>>>>>>>>
>>>>>>>> @@ -243,7 +245,15 @@ static struct hns_roce_hem
>>>>>>>> *hns_roce_alloc_hem(struct hns_roce_dev *hr_dev,
>>>>>>>>           if (!buf)
>>>>>>>>               goto fail;
>>>>>>>>
>>>>>>>> -        sg_set_buf(mem, buf, PAGE_SIZE << order);
>>>>>>>> +        if (is_vmalloc_addr(buf)) {
>>>>>>>> +            vmalloc = &chunk->vmalloc[chunk->npages];
>>>>>>>> +            vmalloc->is_vmalloc_addr = true;
>>>>>>>> +            vmalloc->vmalloc_addr = buf;
>>>>>>>> +            sg_set_page(mem, vmalloc_to_page(buf),
>>>>>>>> +                    PAGE_SIZE << order, offset_in_page(buf));
>>>>>>>> +        } else {
>>>>>>>> +            sg_set_buf(mem, buf, PAGE_SIZE << order);
>>>>>>>> +        }
>>>>>>>>           WARN_ON(mem->offset);
>>>>>>>>           sg_dma_len(mem) = PAGE_SIZE << order;
>>>>>>>>
>>>>>>>> @@ -262,17 +272,25 @@ static struct hns_roce_hem
>>>>>>>> *hns_roce_alloc_hem(struct hns_roce_dev *hr_dev,
>>>>>>>>   void hns_roce_free_hem(struct hns_roce_dev *hr_dev, struct
>>>>>>>> hns_roce_hem *hem)
>>>>>>>>   {
>>>>>>>>       struct hns_roce_hem_chunk *chunk, *tmp;
>>>>>>>> +    void *cpu_addr;
>>>>>>>>       int i;
>>>>>>>>
>>>>>>>>       if (!hem)
>>>>>>>>           return;
>>>>>>>>
>>>>>>>>       list_for_each_entry_safe(chunk, tmp, &hem->chunk_list, list) {
>>>>>>>> -        for (i = 0; i < chunk->npages; ++i)
>>>>>>>> +        for (i = 0; i < chunk->npages; ++i) {
>>>>>>>> +            if (chunk->vmalloc[i].is_vmalloc_addr)
>>>>>>>> +                cpu_addr = chunk->vmalloc[i].vmalloc_addr;
>>>>>>>> +            else
>>>>>>>> +                cpu_addr =
>>>>>>>> +                   lowmem_page_address(sg_page(&chunk->mem[i]));
>>>>>>>> +
>>>>>>>>               dma_free_coherent(hr_dev->dev,
>>>>>>>>                      chunk->mem[i].length,
>>>>>>>> -                   lowmem_page_address(sg_page(&chunk->mem[i])),
>>>>>>>> +                   cpu_addr,
>>>>>>>>                      sg_dma_address(&chunk->mem[i]));
>>>>>>>> +        }
>>>>>>>>           kfree(chunk);
>>>>>>>>       }
>>>>>>>>
>>>>>>>> @@ -774,6 +792,12 @@ void *hns_roce_table_find(struct hns_roce_dev
>>>>>>>> *hr_dev,
>>>>>>>>
>>>>>>>>               if (chunk->mem[i].length > (u32)offset) {
>>>>>>>>                   page = sg_page(&chunk->mem[i]);
>>>>>>>> +                if (chunk->vmalloc[i].is_vmalloc_addr) {
>>>>>>>> +                    mutex_unlock(&table->mutex);
>>>>>>>> +                    return page ?
>>>>>>>> +                        chunk->vmalloc[i].vmalloc_addr
>>>>>>>> +                        + offset : NULL;
>>>>>>>> +                }
>>>>>>>>                   goto out;
>>>>>>>>               }
>>>>>>>>               offset -= chunk->mem[i].length;
>>>>>>>> diff --git a/drivers/infiniband/hw/hns/hns_roce_hem.h
>>>>>>>> b/drivers/infiniband/hw/hns/hns_roce_hem.h
>>>>>>>> index af28bbf..62d712a 100644
>>>>>>>> --- a/drivers/infiniband/hw/hns/hns_roce_hem.h
>>>>>>>> +++ b/drivers/infiniband/hw/hns/hns_roce_hem.h
>>>>>>>> @@ -72,11 +72,17 @@ enum {
>>>>>>>>        HNS_ROCE_HEM_PAGE_SIZE  = 1 << HNS_ROCE_HEM_PAGE_SHIFT,
>>>>>>>>   };
>>>>>>>>
>>>>>>>> +struct hns_roce_vmalloc {
>>>>>>>> +    bool    is_vmalloc_addr;
>>>>>>>> +    void    *vmalloc_addr;
>>>>>>>> +};
>>>>>>>> +
>>>>>>>>   struct hns_roce_hem_chunk {
>>>>>>>>       struct list_head     list;
>>>>>>>>       int             npages;
>>>>>>>>       int             nsg;
>>>>>>>>       struct scatterlist     mem[HNS_ROCE_HEM_CHUNK_LEN];
>>>>>>>> +    struct hns_roce_vmalloc     vmalloc[HNS_ROCE_HEM_CHUNK_LEN];
>>>>>>>>   };
>>>>>>>>
>>>>>>>>   struct hns_roce_hem {
>>>>>>>> diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v2.c
>>>>>>>> b/drivers/infiniband/hw/hns/hns_roce_hw_v2.c
>>>>>>>> index b99d70a..9e19bf1 100644
>>>>>>>> --- a/drivers/infiniband/hw/hns/hns_roce_hw_v2.c
>>>>>>>> +++ b/drivers/infiniband/hw/hns/hns_roce_hw_v2.c
>>>>>>>> @@ -1093,9 +1093,11 @@ static int hns_roce_v2_write_mtpt(void
>>>>>>>> *mb_buf, struct hns_roce_mr *mr,
>>>>>>>>   {
>>>>>>>>       struct hns_roce_v2_mpt_entry *mpt_entry;
>>>>>>>>       struct scatterlist *sg;
>>>>>>>> +    u64 page_addr = 0;
>>>>>>>>       u64 *pages;
>>>>>>>> +    int i = 0, j = 0;
>>>>>>>> +    int len = 0;
>>>>>>>>       int entry;
>>>>>>>> -    int i;
>>>>>>>>
>>>>>>>>       mpt_entry = mb_buf;
>>>>>>>>       memset(mpt_entry, 0, sizeof(*mpt_entry));
>>>>>>>> @@ -1153,14 +1155,20 @@ static int hns_roce_v2_write_mtpt(void
>>>>>>>> *mb_buf, struct hns_roce_mr *mr,
>>>>>>>>
>>>>>>>>       i = 0;
>>>>>>>>       for_each_sg(mr->umem->sg_head.sgl, sg, mr->umem->nmap, entry) {
>>>>>>>> -        pages[i] = ((u64)sg_dma_address(sg)) >> 6;
>>>>>>>> -
>>>>>>>> -        /* Record the first 2 entry directly to MTPT table */
>>>>>>>> -        if (i >= HNS_ROCE_V2_MAX_INNER_MTPT_NUM - 1)
>>>>>>>> -            break;
>>>>>>>> -        i++;
>>>>>>>> +        len = sg_dma_len(sg) >> PAGE_SHIFT;
>>>>>>>> +        for (j = 0; j < len; ++j) {
>>>>>>>> +            page_addr = sg_dma_address(sg) +
>>>>>>>> +                    (j << mr->umem->page_shift);
>>>>>>>> +            pages[i] = page_addr >> 6;
>>>>>>>> +
>>>>>>>> +            /* Record the first 2 entry directly to MTPT table */
>>>>>>>> +            if (i >= HNS_ROCE_V2_MAX_INNER_MTPT_NUM - 1)
>>>>>>>> +                goto found;
>>>>>>>> +            i++;
>>>>>>>> +        }
>>>>>>>>       }
>>>>>>>>
>>>>>>>> +found:
>>>>>>>>       mpt_entry->pa0_l = cpu_to_le32(lower_32_bits(pages[0]));
>>>>>>>>       roce_set_field(mpt_entry->byte_56_pa0_h, V2_MPT_BYTE_56_PA0_H_M,
>>>>>>>>                  V2_MPT_BYTE_56_PA0_H_S,
>>>>>>>> --
>>>>>>>> 1.9.1
>>>>>>>>
>>>>>> _______________________________________________
>>>>>> iommu mailing list
>>>>>> iommu@lists.linux-foundation.org
>>>>>> https://lists.linuxfoundation.org/mailman/listinfo/iommu
>>>>> .
>>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> .
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
