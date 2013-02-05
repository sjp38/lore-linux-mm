Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 3B6916B00CC
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 19:59:57 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BC2F63EE0B6
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 09:59:55 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 992E245DEBA
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 09:59:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 80FE545DEB5
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 09:59:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 727EB1DB8045
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 09:59:55 +0900 (JST)
Received: from g01jpexchyt07.g01.fujitsu.local (g01jpexchyt07.g01.fujitsu.local [10.128.194.46])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 16E8A1DB803E
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 09:59:55 +0900 (JST)
Message-ID: <51105977.4090200@jp.fujitsu.com>
Date: Tue, 5 Feb 2013 09:59:35 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: use NUMA_NO_NODE
References: <alpine.DEB.2.02.1302041354470.10632@chino.kir.corp.google.com> <51105153.8090304@jp.fujitsu.com>
In-Reply-To: <51105153.8090304@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Sorry about the noise.

Thanks,
Yasuaki Ishimatsu

2013/02/05 9:24, Yasuaki Ishimatsu wrote:
> 2013/02/05 6:57, David Rientjes wrote:
>> Make a sweep through mm/ and convert code that uses -1 directly to using
>> the more appropriate NUMA_NO_NODE.
>>
>> Signed-off-by: David Rientjes <rientjes@google.com>
>> ---
>
> Reviewed-by: Yasauaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>
> Thanks,
> Yasuaki Ishimatsu
>
>>   mm/dmapool.c     |  2 +-
>>   mm/huge_memory.c |  4 ++--
>>   mm/mempolicy.c   | 10 +++++-----
>>   mm/page_alloc.c  |  2 +-
>>   mm/vmalloc.c     | 33 ++++++++++++++++++---------------
>>   5 files changed, 27 insertions(+), 24 deletions(-)
>>
>> diff --git a/mm/dmapool.c b/mm/dmapool.c
>> index 668f263..6a402c8 100644
>> --- a/mm/dmapool.c
>> +++ b/mm/dmapool.c
>> @@ -157,7 +157,7 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
>>           return NULL;
>>       }
>>
>> -    node = WARN_ON(!dev) ? -1 : dev_to_node(dev);
>> +    node = WARN_ON(!dev) ? NUMA_NO_NODE : dev_to_node(dev);
>>
>>       retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, node);
>>       if (!retval)
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index c63a21d..d41fa11 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -2376,7 +2376,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>>       struct page *page;
>>       unsigned long _address;
>>       spinlock_t *ptl;
>> -    int node = -1;
>> +    int node = NUMA_NO_NODE;
>>
>>       VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>>
>> @@ -2406,7 +2406,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>>            * be more sophisticated and look at more pages,
>>            * but isn't for now.
>>            */
>> -        if (node == -1)
>> +        if (node == NUMA_NO_NODE)
>>               node = page_to_nid(page);
>>           VM_BUG_ON(PageCompound(page));
>>           if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index 6f7979c..0a10d40 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -26,7 +26,7 @@
>>    *                the allocation to memory nodes instead
>>    *
>>    * preferred       Try a specific node first before normal fallback.
>> - *                As a special case node -1 here means do the allocation
>> + *                As a special case NUMA_NO_NODE here means do the allocation
>>    *                on the local CPU. This is normally identical to default,
>>    *                but useful to set in a VMA when you have a non default
>>    *                process policy.
>> @@ -127,7 +127,7 @@ static struct mempolicy *get_task_policy(struct task_struct *p)
>>
>>       if (!pol) {
>>           node = numa_node_id();
>> -        if (node != -1)
>> +        if (node != NUMA_NO_NODE)
>>               pol = &preferred_node_policy[node];
>>
>>           /* preferred_node_policy is not initialised early in boot */
>> @@ -258,7 +258,7 @@ static struct mempolicy *mpol_new(unsigned short mode, unsigned short flags,
>>       struct mempolicy *policy;
>>
>>       pr_debug("setting mode %d flags %d nodes[0] %lx\n",
>> -         mode, flags, nodes ? nodes_addr(*nodes)[0] : -1);
>> +         mode, flags, nodes ? nodes_addr(*nodes)[0] : NUMA_NO_NODE);
>>
>>       if (mode == MPOL_DEFAULT) {
>>           if (nodes && !nodes_empty(*nodes))
>> @@ -1223,7 +1223,7 @@ static long do_mbind(unsigned long start, unsigned long len,
>>
>>       pr_debug("mbind %lx-%lx mode:%d flags:%d nodes:%lx\n",
>>            start, start + len, mode, mode_flags,
>> -         nmask ? nodes_addr(*nmask)[0] : -1);
>> +         nmask ? nodes_addr(*nmask)[0] : NUMA_NO_NODE);
>>
>>       if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
>>
>> @@ -2491,7 +2491,7 @@ int mpol_set_shared_policy(struct shared_policy *info,
>>            vma->vm_pgoff,
>>            sz, npol ? npol->mode : -1,
>>            npol ? npol->flags : -1,
>> -         npol ? nodes_addr(npol->v.nodes)[0] : -1);
>> +         npol ? nodes_addr(npol->v.nodes)[0] : NUMA_NO_NODE);
>>
>>       if (npol) {
>>           new = sp_alloc(vma->vm_pgoff, vma->vm_pgoff + sz, npol);
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 087845c..35d4714 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3246,7 +3246,7 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
>>   {
>>       int n, val;
>>       int min_val = INT_MAX;
>> -    int best_node = -1;
>> +    int best_node = NUMA_NO_NODE;
>>       const struct cpumask *tmp = cpumask_of_node(0);
>>
>>       /* Use the local node if we haven't already */
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 5123a16..0f751f2 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1376,8 +1376,8 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
>>   struct vm_struct *__get_vm_area(unsigned long size, unsigned long flags,
>>                   unsigned long start, unsigned long end)
>>   {
>> -    return __get_vm_area_node(size, 1, flags, start, end, -1, GFP_KERNEL,
>> -                        __builtin_return_address(0));
>> +    return __get_vm_area_node(size, 1, flags, start, end, NUMA_NO_NODE,
>> +                  GFP_KERNEL, __builtin_return_address(0));
>>   }
>>   EXPORT_SYMBOL_GPL(__get_vm_area);
>>
>> @@ -1385,8 +1385,8 @@ struct vm_struct *__get_vm_area_caller(unsigned long size, unsigned long flags,
>>                          unsigned long start, unsigned long end,
>>                          const void *caller)
>>   {
>> -    return __get_vm_area_node(size, 1, flags, start, end, -1, GFP_KERNEL,
>> -                  caller);
>> +    return __get_vm_area_node(size, 1, flags, start, end, NUMA_NO_NODE,
>> +                  GFP_KERNEL, caller);
>>   }
>>
>>   /**
>> @@ -1401,14 +1401,15 @@ struct vm_struct *__get_vm_area_caller(unsigned long size, unsigned long flags,
>>   struct vm_struct *get_vm_area(unsigned long size, unsigned long flags)
>>   {
>>       return __get_vm_area_node(size, 1, flags, VMALLOC_START, VMALLOC_END,
>> -                -1, GFP_KERNEL, __builtin_return_address(0));
>> +                  NUMA_NO_NODE, GFP_KERNEL,
>> +                  __builtin_return_address(0));
>>   }
>>
>>   struct vm_struct *get_vm_area_caller(unsigned long size, unsigned long flags,
>>                   const void *caller)
>>   {
>>       return __get_vm_area_node(size, 1, flags, VMALLOC_START, VMALLOC_END,
>> -                        -1, GFP_KERNEL, caller);
>> +                  NUMA_NO_NODE, GFP_KERNEL, caller);
>>   }
>>
>>   /**
>> @@ -1650,7 +1651,7 @@ fail:
>>    *    @end:        vm area range end
>>    *    @gfp_mask:    flags for the page level allocator
>>    *    @prot:        protection mask for the allocated pages
>> - *    @node:        node to use for allocation or -1
>> + *    @node:        node to use for allocation or NUMA_NO_NODE
>>    *    @caller:    caller's return address
>>    *
>>    *    Allocate enough pages to cover @size from the page level
>> @@ -1706,7 +1707,7 @@ fail:
>>    *    @align:        desired alignment
>>    *    @gfp_mask:    flags for the page level allocator
>>    *    @prot:        protection mask for the allocated pages
>> - *    @node:        node to use for allocation or -1
>> + *    @node:        node to use for allocation or NUMA_NO_NODE
>>    *    @caller:    caller's return address
>>    *
>>    *    Allocate enough pages to cover @size from the page level
>> @@ -1723,7 +1724,7 @@ static void *__vmalloc_node(unsigned long size, unsigned long align,
>>
>>   void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
>>   {
>> -    return __vmalloc_node(size, 1, gfp_mask, prot, -1,
>> +    return __vmalloc_node(size, 1, gfp_mask, prot, NUMA_NO_NODE,
>>                   __builtin_return_address(0));
>>   }
>>   EXPORT_SYMBOL(__vmalloc);
>> @@ -1746,7 +1747,8 @@ static inline void *__vmalloc_node_flags(unsigned long size,
>>    */
>>   void *vmalloc(unsigned long size)
>>   {
>> -    return __vmalloc_node_flags(size, -1, GFP_KERNEL | __GFP_HIGHMEM);
>> +    return __vmalloc_node_flags(size, NUMA_NO_NODE,
>> +                    GFP_KERNEL | __GFP_HIGHMEM);
>>   }
>>   EXPORT_SYMBOL(vmalloc);
>>
>> @@ -1762,7 +1764,7 @@ EXPORT_SYMBOL(vmalloc);
>>    */
>>   void *vzalloc(unsigned long size)
>>   {
>> -    return __vmalloc_node_flags(size, -1,
>> +    return __vmalloc_node_flags(size, NUMA_NO_NODE,
>>                   GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO);
>>   }
>>   EXPORT_SYMBOL(vzalloc);
>> @@ -1781,7 +1783,8 @@ void *vmalloc_user(unsigned long size)
>>
>>       ret = __vmalloc_node(size, SHMLBA,
>>                    GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
>> -                 PAGE_KERNEL, -1, __builtin_return_address(0));
>> +                 PAGE_KERNEL, NUMA_NO_NODE,
>> +                 __builtin_return_address(0));
>>       if (ret) {
>>           area = find_vm_area(ret);
>>           area->flags |= VM_USERMAP;
>> @@ -1846,7 +1849,7 @@ EXPORT_SYMBOL(vzalloc_node);
>>   void *vmalloc_exec(unsigned long size)
>>   {
>>       return __vmalloc_node(size, 1, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL_EXEC,
>> -                  -1, __builtin_return_address(0));
>> +                  NUMA_NO_NODE, __builtin_return_address(0));
>>   }
>>
>>   #if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
>> @@ -1867,7 +1870,7 @@ void *vmalloc_exec(unsigned long size)
>>   void *vmalloc_32(unsigned long size)
>>   {
>>       return __vmalloc_node(size, 1, GFP_VMALLOC32, PAGE_KERNEL,
>> -                  -1, __builtin_return_address(0));
>> +                  NUMA_NO_NODE, __builtin_return_address(0));
>>   }
>>   EXPORT_SYMBOL(vmalloc_32);
>>
>> @@ -1884,7 +1887,7 @@ void *vmalloc_32_user(unsigned long size)
>>       void *ret;
>>
>>       ret = __vmalloc_node(size, 1, GFP_VMALLOC32 | __GFP_ZERO, PAGE_KERNEL,
>> -                 -1, __builtin_return_address(0));
>> +                 NUMA_NO_NODE, __builtin_return_address(0));
>>       if (ret) {
>>           area = find_vm_area(ret);
>>           area->flags |= VM_USERMAP;
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
