Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id CC9466B0038
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 04:54:08 -0400 (EDT)
Received: by pddn5 with SMTP id n5so53192345pdd.2
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 01:54:08 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id kz7si1947847pbc.151.2015.03.30.01.54.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 30 Mar 2015 01:54:07 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NM000I3BOWU6M90@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 30 Mar 2015 09:58:06 +0100 (BST)
Message-id: <55190F23.4020009@samsung.com>
Date: Mon, 30 Mar 2015 11:53:55 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [patch v2 4/4] mm, mempool: poison elements backed by page
 allocator
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1503241609370.21805@chino.kir.corp.google.com>
 <CAPAsAGwipUr7NBWjQ_xjA0CfeiZ0NuYAg13M4jYmWVe4V8Jjmg@mail.gmail.com>
 <alpine.DEB.2.10.1503261542060.16259@chino.kir.corp.google.com>
In-reply-to: <alpine.DEB.2.10.1503261542060.16259@chino.kir.corp.google.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jfs-discussion@lists.sourceforge.net

On 03/27/2015 01:50 AM, David Rientjes wrote:
> On Thu, 26 Mar 2015, Andrey Ryabinin wrote:
> 
>>> +static void check_element(mempool_t *pool, void *element)
>>> +{
>>> +       /* Mempools backed by slab allocator */
>>> +       if (pool->free == mempool_free_slab || pool->free == mempool_kfree)
>>> +               __check_element(pool, element, ksize(element));
>>> +
>>> +       /* Mempools backed by page allocator */
>>> +       if (pool->free == mempool_free_pages) {
>>> +               int order = (int)(long)pool->pool_data;
>>> +               void *addr = page_address(element);
>>> +
>>> +               __check_element(pool, addr, 1UL << (PAGE_SHIFT + order));
>>>         }
>>>  }
>>>
>>> -static void poison_slab_element(mempool_t *pool, void *element)
>>> +static void __poison_element(void *element, size_t size)
>>>  {
>>> -       if (pool->alloc == mempool_alloc_slab ||
>>> -           pool->alloc == mempool_kmalloc) {
>>> -               size_t size = ksize(element);
>>> -               u8 *obj = element;
>>> +       u8 *obj = element;
>>> +
>>> +       memset(obj, POISON_FREE, size - 1);
>>> +       obj[size - 1] = POISON_END;
>>> +}
>>> +
>>> +static void poison_element(mempool_t *pool, void *element)
>>> +{
>>> +       /* Mempools backed by slab allocator */
>>> +       if (pool->alloc == mempool_alloc_slab || pool->alloc == mempool_kmalloc)
>>> +               __poison_element(element, ksize(element));
>>> +
>>> +       /* Mempools backed by page allocator */
>>> +       if (pool->alloc == mempool_alloc_pages) {
>>> +               int order = (int)(long)pool->pool_data;
>>> +               void *addr = page_address(element);
>>>
>>> -               memset(obj, POISON_FREE, size - 1);
>>> -               obj[size - 1] = POISON_END;
>>> +               __poison_element(addr, 1UL << (PAGE_SHIFT + order));
>>
>> I think, it would be better to use kernel_map_pages() here and in
>> check_element().
> 
> Hmm, interesting suggestion.
> 
>> This implies that poison_element()/check_element() has to be moved out of
>> CONFIG_DEBUG_SLAB || CONFIG_SLUB_DEBUG_ON ifdef (keeping only slab
>> poisoning under this ifdef).
> 
> The mempool poisoning introduced here is really its own poisoning built on 
> top of whatever the mempool allocator is.  Otherwise, it would have called 
> into the slab subsystem to do the poisoning and include any allocated 
> space beyond the object size itself. 

Perhaps, that would be a good thing to do. I mean it makes sense to check redzone
for corruption.

> Mempool poisoning is agnostic to the 
> underlying memory just like the chain of elements is, mempools don't even 
> store size.
> 
> We don't have a need to set PAGE_EXT_DEBUG_POISON on these pages sitting 
> in the reserved pool, nor do we have a need to do kmap_atomic() since it's 
> already mapped and must be mapped to be on the reserved pool, which is 
> handled by mempool_free().
> 

Well, yes. But this applies only to architectures that don't have ARCH_SUPPORTS_DEBUG_PAGEALLOC.
The rest of arches will only benefit from this as kernel_map_pages() potentially could find more bugs.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
