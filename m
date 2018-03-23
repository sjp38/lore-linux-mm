Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 780246B0008
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 09:33:34 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id g61-v6so4437487plb.10
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 06:33:34 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10113.outbound.protection.outlook.com. [40.107.1.113])
        by mx.google.com with ESMTPS id e4si6083328pgu.623.2018.03.23.06.33.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Mar 2018 06:33:33 -0700 (PDT)
Subject: Re: [PATCH 3/4] mm: Add free()
References: <20180322195819.24271-1-willy@infradead.org>
 <20180322195819.24271-4-willy@infradead.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <6fd1bba1-e60c-e5b3-58be-52e991cda74f@virtuozzo.com>
Date: Fri, 23 Mar 2018 16:33:24 +0300
MIME-Version: 1.0
In-Reply-To: <20180322195819.24271-4-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Hi, Matthew,

On 22.03.2018 22:58, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> free() can free many different kinds of memory.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  include/linux/kernel.h |  2 ++
>  mm/util.c              | 39 +++++++++++++++++++++++++++++++++++++++
>  2 files changed, 41 insertions(+)
> 
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index 3fd291503576..8bb578938e65 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -933,6 +933,8 @@ static inline void ftrace_dump(enum ftrace_dump_mode oops_dump_mode) { }
>  			 "pointer type mismatch in container_of()");	\
>  	((type *)(__mptr - offsetof(type, member))); })
>  
> +void free(const void *);
> +
>  /* Rebuild everything on CONFIG_FTRACE_MCOUNT_RECORD */
>  #ifdef CONFIG_FTRACE_MCOUNT_RECORD
>  # define REBUILD_DUE_TO_FTRACE_MCOUNT_RECORD
> diff --git a/mm/util.c b/mm/util.c
> index dc4c7b551aaf..8aa2071059b0 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -26,6 +26,45 @@ static inline int is_kernel_rodata(unsigned long addr)
>  		addr < (unsigned long)__end_rodata;
>  }
>  
> +/**
> + * free() - Free memory
> + * @ptr: Pointer to memory
> + *
> + * This function can free almost any type of memory.  It can safely be
> + * called on:
> + * * NULL pointers.
> + * * Pointers to read-only data (will do nothing).
> + * * Pointers to memory allocated from kmalloc().
> + * * Pointers to memory allocated from kmem_cache_alloc().
> + * * Pointers to memory allocated from vmalloc().
> + * * Pointers to memory allocated from alloc_percpu().
> + * * Pointers to memory allocated from __get_free_pages().
> + * * Pointers to memory allocated from page_frag_alloc().
> + *
> + * It cannot free memory allocated by dma_pool_alloc() or dma_alloc_coherent().
> + */
> +void free(const void *ptr)
> +{
> +	struct page *page;
> +
> +	if (unlikely(ZERO_OR_NULL_PTR(ptr)))
> +		return;
> +	if (is_kernel_rodata((unsigned long)ptr))
> +		return;
> +
> +	page = virt_to_head_page(ptr);
> +	if (likely(PageSlab(page)))
> +		return kmem_cache_free(page->slab_cache, (void *)ptr);

It seems slab_cache is not generic for all types of slabs. SLOB does not care about it:

~/linux-next$ git grep -w slab_cache mm include | grep -v kasan
include/linux/mm.h:	 * slab code uses page->slab_cache, which share storage with page->ptl.
include/linux/mm_types.h:		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
mm/slab.c:	return page->slab_cache;
mm/slab.c:	cachep = page->slab_cache;
mm/slab.c:	page->slab_cache = cache;
mm/slab.c:	cachep = page->slab_cache;
mm/slab.h:	cachep = page->slab_cache;
mm/slub.c:	if (unlikely(s != page->slab_cache)) {
mm/slub.c:		} else if (!page->slab_cache) {
mm/slub.c:	page->slab_cache = s;
mm/slub.c:	__free_slab(page->slab_cache, page);
mm/slub.c:		df->s = page->slab_cache;
mm/slub.c:	s = page->slab_cache;
mm/slub.c:	return slab_ksize(page->slab_cache);
mm/slub.c:	slab_free(page->slab_cache, page, object, NULL, 1, _RET_IP_);
mm/slub.c:			p->slab_cache = s;
mm/slub.c:			p->slab_cache = s;

Also, using kmem_cache_free() for kmalloc()'ed memory will connect them hardly,
and this may be difficult to maintain in the future. One more thing, there is
some kasan checks on the main way of kfree(), and there is no guarantee they
reflected in kmem_cache_free() identical.

Maybe, we will use kfree() for now, and skip kmemcache free() support? If there is
no different way to differ kmemcache memory from kmalloc()'ed memory, of course.

Kirill
