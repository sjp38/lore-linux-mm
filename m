Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D39A66B0038
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 07:36:14 -0400 (EDT)
Received: by pddn5 with SMTP id n5so42078670pdd.2
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 04:36:14 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id m1si6270840pdd.9.2015.04.06.04.36.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 06 Apr 2015 04:36:13 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NMD0059UV31K750@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 06 Apr 2015 12:40:13 +0100 (BST)
Message-id: <55226FA7.30505@samsung.com>
Date: Mon, 06 Apr 2015 14:36:07 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm, mempool: kasan: poison mempool elements
References: <1428072467-21668-1-git-send-email-a.ryabinin@samsung.com>
 <20150403150719.b2197f71260fee25434e49fc@linux-foundation.org>
In-reply-to: <20150403150719.b2197f71260fee25434e49fc@linux-foundation.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, Dmitry Chernenkov <drcheren@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>

On 04/04/2015 01:07 AM, Andrew Morton wrote:
> On Fri, 03 Apr 2015 17:47:47 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> 
>> Mempools keep allocated objects in reserved for situations
>> when ordinary allocation may not be possible to satisfy.
>> These objects shouldn't be accessed before they leave
>> the pool.
>> This patch poison elements when get into the pool
>> and unpoison when they leave it. This will let KASan
>> to detect use-after-free of mempool's elements.
>>
>> ...
>>
>> +static void kasan_poison_element(mempool_t *pool, void *element)
>> +{
>> +	if (pool->alloc == mempool_alloc_slab)
>> +		kasan_slab_free(pool->pool_data, element);
>> +	if (pool->alloc == mempool_kmalloc)
>> +		kasan_kfree(element);
>> +	if (pool->alloc == mempool_alloc_pages)
>> +		kasan_free_pages(element, (unsigned long)pool->pool_data);
>> +}
> 
> We recently discovered that mempool pages (from alloc_pages, not slab)
> can be in highmem.  But kasan apepars to handle highmem pages (by
> baling out) so we should be OK with that.
> 
> Can kasan be taught to use kmap_atomic() or is it more complicated than
> that?  It probably isn't worthwhile - highmem pages don'[t get used by the
> kernel much and most bugs will be found using 64-bit testing anyway.
> 

kasan could only tell whether it's ok to use some virtual address or not.
So it can't be used for catching use after free of highmem page.
If highmem page was kmapped at some address than it's ok to dereference that address.
However, kasan can be used to unpoison/poison kmapped/kunmapped addresses to find use-after-kunmap bugs.
AFAIK kunmap has some sort of lazy unmap logic and kunmaped page might be still accessible for some time.

Another idea - poison lowmem pages if they were allocated with __GFP_HIGHMEM, unpoison them only on kmap, and poison back on kunmap.
Generally such pages shouldn't be accessed without mapping them first.
However it might be some false-positives. User could check if page is in lowmem and don't use kmap in that case.
It probably isn't worthwhile as well - 32bit testing will find these bugs without kasan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
