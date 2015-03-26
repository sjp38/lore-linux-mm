Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id A584C6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 18:51:02 -0400 (EDT)
Received: by igbqf9 with SMTP id qf9so5707764igb.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 15:51:02 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id w10si125270icb.106.2015.03.26.15.51.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 15:51:01 -0700 (PDT)
Received: by igcxg11 with SMTP id xg11so5785632igc.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 15:51:01 -0700 (PDT)
Date: Thu, 26 Mar 2015 15:50:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 4/4] mm, mempool: poison elements backed by page
 allocator
In-Reply-To: <CAPAsAGwipUr7NBWjQ_xjA0CfeiZ0NuYAg13M4jYmWVe4V8Jjmg@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1503261542060.16259@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com> <alpine.DEB.2.10.1503241609370.21805@chino.kir.corp.google.com> <CAPAsAGwipUr7NBWjQ_xjA0CfeiZ0NuYAg13M4jYmWVe4V8Jjmg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jfs-discussion@lists.sourceforge.net

On Thu, 26 Mar 2015, Andrey Ryabinin wrote:

> > +static void check_element(mempool_t *pool, void *element)
> > +{
> > +       /* Mempools backed by slab allocator */
> > +       if (pool->free == mempool_free_slab || pool->free == mempool_kfree)
> > +               __check_element(pool, element, ksize(element));
> > +
> > +       /* Mempools backed by page allocator */
> > +       if (pool->free == mempool_free_pages) {
> > +               int order = (int)(long)pool->pool_data;
> > +               void *addr = page_address(element);
> > +
> > +               __check_element(pool, addr, 1UL << (PAGE_SHIFT + order));
> >         }
> >  }
> >
> > -static void poison_slab_element(mempool_t *pool, void *element)
> > +static void __poison_element(void *element, size_t size)
> >  {
> > -       if (pool->alloc == mempool_alloc_slab ||
> > -           pool->alloc == mempool_kmalloc) {
> > -               size_t size = ksize(element);
> > -               u8 *obj = element;
> > +       u8 *obj = element;
> > +
> > +       memset(obj, POISON_FREE, size - 1);
> > +       obj[size - 1] = POISON_END;
> > +}
> > +
> > +static void poison_element(mempool_t *pool, void *element)
> > +{
> > +       /* Mempools backed by slab allocator */
> > +       if (pool->alloc == mempool_alloc_slab || pool->alloc == mempool_kmalloc)
> > +               __poison_element(element, ksize(element));
> > +
> > +       /* Mempools backed by page allocator */
> > +       if (pool->alloc == mempool_alloc_pages) {
> > +               int order = (int)(long)pool->pool_data;
> > +               void *addr = page_address(element);
> >
> > -               memset(obj, POISON_FREE, size - 1);
> > -               obj[size - 1] = POISON_END;
> > +               __poison_element(addr, 1UL << (PAGE_SHIFT + order));
> 
> I think, it would be better to use kernel_map_pages() here and in
> check_element().

Hmm, interesting suggestion.

> This implies that poison_element()/check_element() has to be moved out of
> CONFIG_DEBUG_SLAB || CONFIG_SLUB_DEBUG_ON ifdef (keeping only slab
> poisoning under this ifdef).

The mempool poisoning introduced here is really its own poisoning built on 
top of whatever the mempool allocator is.  Otherwise, it would have called 
into the slab subsystem to do the poisoning and include any allocated 
space beyond the object size itself.  Mempool poisoning is agnostic to the 
underlying memory just like the chain of elements is, mempools don't even 
store size.

We don't have a need to set PAGE_EXT_DEBUG_POISON on these pages sitting 
in the reserved pool, nor do we have a need to do kmap_atomic() since it's 
already mapped and must be mapped to be on the reserved pool, which is 
handled by mempool_free().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
