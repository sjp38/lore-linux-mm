Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0271C6B0069
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 08:59:18 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s185so3512394oif.16
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 05:59:17 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 31si7127534otf.43.2017.10.12.05.59.15
        for <linux-mm@kvack.org>;
        Thu, 12 Oct 2017 05:59:16 -0700 (PDT)
Subject: Re: [PATCH for-next 2/4] RDMA/hns: Add IOMMU enable support in hip08
References: <1506763741-81429-1-git-send-email-xavier.huwei@huawei.com>
 <1506763741-81429-3-git-send-email-xavier.huwei@huawei.com>
 <20170930161023.GI2965@mtr-leonro.local> <59DF60A3.7080803@huawei.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <5fe5f9b9-2c2b-ab3c-dafa-3e2add051bbb@arm.com>
Date: Thu, 12 Oct 2017 13:59:11 +0100
MIME-Version: 1.0
In-Reply-To: <59DF60A3.7080803@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>, Leon Romanovsky <leon@kernel.org>
Cc: shaobo.xu@intel.com, xavier.huwei@tom.com, lijun_nudt@163.com, oulijun@huawei.com, linux-rdma@vger.kernel.org, charles.chenxin@huawei.com, linuxarm@huawei.com, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dledford@redhat.com, liuyixian@huawei.com, zhangxiping3@huawei.com, shaoboxu@tom.com

On 12/10/17 13:31, Wei Hu (Xavier) wrote:
> 
> 
> On 2017/10/1 0:10, Leon Romanovsky wrote:
>> On Sat, Sep 30, 2017 at 05:28:59PM +0800, Wei Hu (Xavier) wrote:
>>> If the IOMMU is enabled, the length of sg obtained from
>>> __iommu_map_sg_attrs is not 4kB. When the IOVA is set with the sg
>>> dma address, the IOVA will not be page continuous. and the VA
>>> returned from dma_alloc_coherent is a vmalloc address. However,
>>> the VA obtained by the page_address is a discontinuous VA. Under
>>> these circumstances, the IOVA should be calculated based on the
>>> sg length, and record the VA returned from dma_alloc_coherent
>>> in the struct of hem.
>>>
>>> Signed-off-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
>>> Signed-off-by: Shaobo Xu <xushaobo2@huawei.com>
>>> Signed-off-by: Lijun Ou <oulijun@huawei.com>
>>> ---
>> Doug,
>>
>> I didn't invest time in reviewing it, but having "is_vmalloc_addr" in
>> driver code to deal with dma_alloc_coherent is most probably wrong.
>>
>> Thanks
> Hi,A  Leon & Doug
> A A A  We refered the function named __ttm_dma_alloc_page in the kernel
> code as below:
> A A A  And there are similar methods in bch_bio_map and mem_to_page
> functions in current 4.14-rcx.
> 
> A A A A A A A  static struct dma_page *__ttm_dma_alloc_page(struct dma_pool *pool)
> A A A A A A A  {
> A A A A A A A A A A A  struct dma_page *d_page;
> 
> A A A A A A A A A A A  d_page = kmalloc(sizeof(struct dma_page), GFP_KERNEL);
> A A A A A A A A A A A  if (!d_page)
> A A A A A A A A A A A A A A A  return NULL;
> 
> A A A A A A A A A A A  d_page->vaddr = dma_alloc_coherent(pool->dev, pool->size,
> A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  &d_page->dma,
> A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  pool->gfp_flags);
> A A A A A A A A A A A  if (d_page->vaddr) {
> A A A A A A A A A A A A A A A  if (is_vmalloc_addr(d_page->vaddr))
> A A A A A A A A A A A A A A A A A A A  d_page->p = vmalloc_to_page(d_page->vaddr);
> A A A A A A A A A A A A A A A  else
> A A A A A A A A A A A A A A A A A A A  d_page->p = virt_to_page(d_page->vaddr);

There are cases on various architectures where neither of those is
right. Whether those actually intersect with TTM or RDMA use-cases is
another matter, of course.

What definitely is a problem is if you ever take that page and end up
accessing it through any virtual address other than the one explicitly
returned by dma_alloc_coherent(). That can blow the coherency wide open
and invite data loss, right up to killing the whole system with a
machine check on certain architectures.

Robin.

> A A A A A A A A A A A  } else {
> A A A A A A A A A A A A A A A  kfree(d_page);
> A A A A A A A A A A A A A A A  d_page = NULL;
> A A A A A A A A A A A  }
> A A A A A A A A A A A  return d_page;
> A A A A A A A  }
> 
> A A A  Regards
> Wei Hu
>>
>>> A  drivers/infiniband/hw/hns/hns_roce_alloc.c |A  5 ++++-
>>> A  drivers/infiniband/hw/hns/hns_roce_hem.cA A  | 30
>>> +++++++++++++++++++++++++++---
>>> A  drivers/infiniband/hw/hns/hns_roce_hem.hA A  |A  6 ++++++
>>> A  drivers/infiniband/hw/hns/hns_roce_hw_v2.c | 22 +++++++++++++++-------
>>> A  4 files changed, 52 insertions(+), 11 deletions(-)
>>>
>>> diff --git a/drivers/infiniband/hw/hns/hns_roce_alloc.c
>>> b/drivers/infiniband/hw/hns/hns_roce_alloc.c
>>> index 3e4c525..a69cd4b 100644
>>> --- a/drivers/infiniband/hw/hns/hns_roce_alloc.c
>>> +++ b/drivers/infiniband/hw/hns/hns_roce_alloc.c
>>> @@ -243,7 +243,10 @@ int hns_roce_buf_alloc(struct hns_roce_dev
>>> *hr_dev, u32 size, u32 max_direct,
>>> A A A A A A A A A A A A A A A A A  goto err_free;
>>>
>>> A A A A A A A A A A A A A  for (i = 0; i < buf->nbufs; ++i)
>>> -A A A A A A A A A A A A A A A  pages[i] = virt_to_page(buf->page_list[i].buf);
>>> +A A A A A A A A A A A A A A A  pages[i] =
>>> +A A A A A A A A A A A A A A A A A A A  is_vmalloc_addr(buf->page_list[i].buf) ?
>>> +A A A A A A A A A A A A A A A A A A A  vmalloc_to_page(buf->page_list[i].buf) :
>>> +A A A A A A A A A A A A A A A A A A A  virt_to_page(buf->page_list[i].buf);
>>>
>>> A A A A A A A A A A A A A  buf->direct.buf = vmap(pages, buf->nbufs, VM_MAP,
>>> A A A A A A A A A A A A A A A A A A A A A A A A A A A A  PAGE_KERNEL);
>>> diff --git a/drivers/infiniband/hw/hns/hns_roce_hem.c
>>> b/drivers/infiniband/hw/hns/hns_roce_hem.c
>>> index 8388ae2..4a3d1d4 100644
>>> --- a/drivers/infiniband/hw/hns/hns_roce_hem.c
>>> +++ b/drivers/infiniband/hw/hns/hns_roce_hem.c
>>> @@ -200,6 +200,7 @@ static struct hns_roce_hem
>>> *hns_roce_alloc_hem(struct hns_roce_dev *hr_dev,
>>> A A A A A A A A A A A A A A A A A A A A A A A A A A A A  gfp_t gfp_mask)
>>> A  {
>>> A A A A A  struct hns_roce_hem_chunk *chunk = NULL;
>>> +A A A  struct hns_roce_vmalloc *vmalloc;
>>> A A A A A  struct hns_roce_hem *hem;
>>> A A A A A  struct scatterlist *mem;
>>> A A A A A  int order;
>>> @@ -227,6 +228,7 @@ static struct hns_roce_hem
>>> *hns_roce_alloc_hem(struct hns_roce_dev *hr_dev,
>>> A A A A A A A A A A A A A  sg_init_table(chunk->mem, HNS_ROCE_HEM_CHUNK_LEN);
>>> A A A A A A A A A A A A A  chunk->npages = 0;
>>> A A A A A A A A A A A A A  chunk->nsg = 0;
>>> +A A A A A A A A A A A  memset(chunk->vmalloc, 0, sizeof(chunk->vmalloc));
>>> A A A A A A A A A A A A A  list_add_tail(&chunk->list, &hem->chunk_list);
>>> A A A A A A A A A  }
>>>
>>> @@ -243,7 +245,15 @@ static struct hns_roce_hem
>>> *hns_roce_alloc_hem(struct hns_roce_dev *hr_dev,
>>> A A A A A A A A A  if (!buf)
>>> A A A A A A A A A A A A A  goto fail;
>>>
>>> -A A A A A A A  sg_set_buf(mem, buf, PAGE_SIZE << order);
>>> +A A A A A A A  if (is_vmalloc_addr(buf)) {
>>> +A A A A A A A A A A A  vmalloc = &chunk->vmalloc[chunk->npages];
>>> +A A A A A A A A A A A  vmalloc->is_vmalloc_addr = true;
>>> +A A A A A A A A A A A  vmalloc->vmalloc_addr = buf;
>>> +A A A A A A A A A A A  sg_set_page(mem, vmalloc_to_page(buf),
>>> +A A A A A A A A A A A A A A A A A A A  PAGE_SIZE << order, offset_in_page(buf));
>>> +A A A A A A A  } else {
>>> +A A A A A A A A A A A  sg_set_buf(mem, buf, PAGE_SIZE << order);
>>> +A A A A A A A  }
>>> A A A A A A A A A  WARN_ON(mem->offset);
>>> A A A A A A A A A  sg_dma_len(mem) = PAGE_SIZE << order;
>>>
>>> @@ -262,17 +272,25 @@ static struct hns_roce_hem
>>> *hns_roce_alloc_hem(struct hns_roce_dev *hr_dev,
>>> A  void hns_roce_free_hem(struct hns_roce_dev *hr_dev, struct
>>> hns_roce_hem *hem)
>>> A  {
>>> A A A A A  struct hns_roce_hem_chunk *chunk, *tmp;
>>> +A A A  void *cpu_addr;
>>> A A A A A  int i;
>>>
>>> A A A A A  if (!hem)
>>> A A A A A A A A A  return;
>>>
>>> A A A A A  list_for_each_entry_safe(chunk, tmp, &hem->chunk_list, list) {
>>> -A A A A A A A  for (i = 0; i < chunk->npages; ++i)
>>> +A A A A A A A  for (i = 0; i < chunk->npages; ++i) {
>>> +A A A A A A A A A A A  if (chunk->vmalloc[i].is_vmalloc_addr)
>>> +A A A A A A A A A A A A A A A  cpu_addr = chunk->vmalloc[i].vmalloc_addr;
>>> +A A A A A A A A A A A  else
>>> +A A A A A A A A A A A A A A A  cpu_addr =
>>> +A A A A A A A A A A A A A A A A A A  lowmem_page_address(sg_page(&chunk->mem[i]));
>>> +
>>> A A A A A A A A A A A A A  dma_free_coherent(hr_dev->dev,
>>> A A A A A A A A A A A A A A A A A A A A  chunk->mem[i].length,
>>> -A A A A A A A A A A A A A A A A A A  lowmem_page_address(sg_page(&chunk->mem[i])),
>>> +A A A A A A A A A A A A A A A A A A  cpu_addr,
>>> A A A A A A A A A A A A A A A A A A A A  sg_dma_address(&chunk->mem[i]));
>>> +A A A A A A A  }
>>> A A A A A A A A A  kfree(chunk);
>>> A A A A A  }
>>>
>>> @@ -774,6 +792,12 @@ void *hns_roce_table_find(struct hns_roce_dev
>>> *hr_dev,
>>>
>>> A A A A A A A A A A A A A  if (chunk->mem[i].length > (u32)offset) {
>>> A A A A A A A A A A A A A A A A A  page = sg_page(&chunk->mem[i]);
>>> +A A A A A A A A A A A A A A A  if (chunk->vmalloc[i].is_vmalloc_addr) {
>>> +A A A A A A A A A A A A A A A A A A A  mutex_unlock(&table->mutex);
>>> +A A A A A A A A A A A A A A A A A A A  return page ?
>>> +A A A A A A A A A A A A A A A A A A A A A A A  chunk->vmalloc[i].vmalloc_addr
>>> +A A A A A A A A A A A A A A A A A A A A A A A  + offset : NULL;
>>> +A A A A A A A A A A A A A A A  }
>>> A A A A A A A A A A A A A A A A A  goto out;
>>> A A A A A A A A A A A A A  }
>>> A A A A A A A A A A A A A  offset -= chunk->mem[i].length;
>>> diff --git a/drivers/infiniband/hw/hns/hns_roce_hem.h
>>> b/drivers/infiniband/hw/hns/hns_roce_hem.h
>>> index af28bbf..62d712a 100644
>>> --- a/drivers/infiniband/hw/hns/hns_roce_hem.h
>>> +++ b/drivers/infiniband/hw/hns/hns_roce_hem.h
>>> @@ -72,11 +72,17 @@ enum {
>>> A A A A A A  HNS_ROCE_HEM_PAGE_SIZEA  = 1 << HNS_ROCE_HEM_PAGE_SHIFT,
>>> A  };
>>>
>>> +struct hns_roce_vmalloc {
>>> +A A A  boolA A A  is_vmalloc_addr;
>>> +A A A  voidA A A  *vmalloc_addr;
>>> +};
>>> +
>>> A  struct hns_roce_hem_chunk {
>>> A A A A A  struct list_headA A A A  list;
>>> A A A A A  intA A A A A A A A A A A A  npages;
>>> A A A A A  intA A A A A A A A A A A A  nsg;
>>> A A A A A  struct scatterlistA A A A  mem[HNS_ROCE_HEM_CHUNK_LEN];
>>> +A A A  struct hns_roce_vmallocA A A A  vmalloc[HNS_ROCE_HEM_CHUNK_LEN];
>>> A  };
>>>
>>> A  struct hns_roce_hem {
>>> diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v2.c
>>> b/drivers/infiniband/hw/hns/hns_roce_hw_v2.c
>>> index b99d70a..9e19bf1 100644
>>> --- a/drivers/infiniband/hw/hns/hns_roce_hw_v2.c
>>> +++ b/drivers/infiniband/hw/hns/hns_roce_hw_v2.c
>>> @@ -1093,9 +1093,11 @@ static int hns_roce_v2_write_mtpt(void
>>> *mb_buf, struct hns_roce_mr *mr,
>>> A  {
>>> A A A A A  struct hns_roce_v2_mpt_entry *mpt_entry;
>>> A A A A A  struct scatterlist *sg;
>>> +A A A  u64 page_addr = 0;
>>> A A A A A  u64 *pages;
>>> +A A A  int i = 0, j = 0;
>>> +A A A  int len = 0;
>>> A A A A A  int entry;
>>> -A A A  int i;
>>>
>>> A A A A A  mpt_entry = mb_buf;
>>> A A A A A  memset(mpt_entry, 0, sizeof(*mpt_entry));
>>> @@ -1153,14 +1155,20 @@ static int hns_roce_v2_write_mtpt(void
>>> *mb_buf, struct hns_roce_mr *mr,
>>>
>>> A A A A A  i = 0;
>>> A A A A A  for_each_sg(mr->umem->sg_head.sgl, sg, mr->umem->nmap, entry) {
>>> -A A A A A A A  pages[i] = ((u64)sg_dma_address(sg)) >> 6;
>>> -
>>> -A A A A A A A  /* Record the first 2 entry directly to MTPT table */
>>> -A A A A A A A  if (i >= HNS_ROCE_V2_MAX_INNER_MTPT_NUM - 1)
>>> -A A A A A A A A A A A  break;
>>> -A A A A A A A  i++;
>>> +A A A A A A A  len = sg_dma_len(sg) >> PAGE_SHIFT;
>>> +A A A A A A A  for (j = 0; j < len; ++j) {
>>> +A A A A A A A A A A A  page_addr = sg_dma_address(sg) +
>>> +A A A A A A A A A A A A A A A A A A A  (j << mr->umem->page_shift);
>>> +A A A A A A A A A A A  pages[i] = page_addr >> 6;
>>> +
>>> +A A A A A A A A A A A  /* Record the first 2 entry directly to MTPT table */
>>> +A A A A A A A A A A A  if (i >= HNS_ROCE_V2_MAX_INNER_MTPT_NUM - 1)
>>> +A A A A A A A A A A A A A A A  goto found;
>>> +A A A A A A A A A A A  i++;
>>> +A A A A A A A  }
>>> A A A A A  }
>>>
>>> +found:
>>> A A A A A  mpt_entry->pa0_l = cpu_to_le32(lower_32_bits(pages[0]));
>>> A A A A A  roce_set_field(mpt_entry->byte_56_pa0_h, V2_MPT_BYTE_56_PA0_H_M,
>>> A A A A A A A A A A A A A A A A  V2_MPT_BYTE_56_PA0_H_S,
>>> -- 
>>> 1.9.1
>>>
> 
> 
> _______________________________________________
> iommu mailing list
> iommu@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/iommu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
