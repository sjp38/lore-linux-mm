Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8076B006E
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 16:38:33 -0400 (EDT)
Received: by obcjt1 with SMTP id jt1so55896487obc.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 13:38:32 -0700 (PDT)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id jl4si4506778oeb.19.2015.03.26.13.38.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 13:38:31 -0700 (PDT)
Received: by oifl3 with SMTP id l3so59941855oif.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 13:38:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1503241609370.21805@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1503241609370.21805@chino.kir.corp.google.com>
Date: Thu, 26 Mar 2015 23:38:31 +0300
Message-ID: <CAPAsAGwipUr7NBWjQ_xjA0CfeiZ0NuYAg13M4jYmWVe4V8Jjmg@mail.gmail.com>
Subject: Re: [patch v2 4/4] mm, mempool: poison elements backed by page allocator
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jfs-discussion@lists.sourceforge.net

2015-03-25 2:10 GMT+03:00 David Rientjes <rientjes@google.com>:

...
>
> +
> +static void check_element(mempool_t *pool, void *element)
> +{
> +       /* Mempools backed by slab allocator */
> +       if (pool->free == mempool_free_slab || pool->free == mempool_kfree)
> +               __check_element(pool, element, ksize(element));
> +
> +       /* Mempools backed by page allocator */
> +       if (pool->free == mempool_free_pages) {
> +               int order = (int)(long)pool->pool_data;
> +               void *addr = page_address(element);
> +
> +               __check_element(pool, addr, 1UL << (PAGE_SHIFT + order));
>         }
>  }
>
> -static void poison_slab_element(mempool_t *pool, void *element)
> +static void __poison_element(void *element, size_t size)
>  {
> -       if (pool->alloc == mempool_alloc_slab ||
> -           pool->alloc == mempool_kmalloc) {
> -               size_t size = ksize(element);
> -               u8 *obj = element;
> +       u8 *obj = element;
> +
> +       memset(obj, POISON_FREE, size - 1);
> +       obj[size - 1] = POISON_END;
> +}
> +
> +static void poison_element(mempool_t *pool, void *element)
> +{
> +       /* Mempools backed by slab allocator */
> +       if (pool->alloc == mempool_alloc_slab || pool->alloc == mempool_kmalloc)
> +               __poison_element(element, ksize(element));
> +
> +       /* Mempools backed by page allocator */
> +       if (pool->alloc == mempool_alloc_pages) {
> +               int order = (int)(long)pool->pool_data;
> +               void *addr = page_address(element);
>
> -               memset(obj, POISON_FREE, size - 1);
> -               obj[size - 1] = POISON_END;
> +               __poison_element(addr, 1UL << (PAGE_SHIFT + order));

I think, it would be better to use kernel_map_pages() here and in
check_element().
This implies that poison_element()/check_element() has to be moved out of
CONFIG_DEBUG_SLAB || CONFIG_SLUB_DEBUG_ON ifdef (keeping only slab
poisoning under this ifdef).
After these changes it might be a good idea to rename
poison_element()/check_element()
to something like debug_add_element()/debug_remove_element() respectively.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
