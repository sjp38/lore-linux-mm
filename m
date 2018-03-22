Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 96A6D6B0028
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:22:33 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j3so4455757wrb.18
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 09:22:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r75sor700790wmg.17.2018.03.22.09.22.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Mar 2018 09:22:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180322153157.10447-7-willy@infradead.org>
References: <20180322153157.10447-1-willy@infradead.org> <20180322153157.10447-7-willy@infradead.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 22 Mar 2018 09:22:31 -0700
Message-ID: <CAKgT0UfcYLm3UZcq536cNOczVhR60qoFDHh_gcXqqyqdViuLzw@mail.gmail.com>
Subject: Re: [PATCH v2 6/8] page_frag_cache: Use a mask instead of offset
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Thu, Mar 22, 2018 at 8:31 AM, Matthew Wilcox <willy@infradead.org> wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
>
> By combining 'va' and 'offset' into 'addr' and using a mask instead,
> we can save a compare-and-branch in the fast-path of the allocator.
> This removes 4 instructions on x86 (both 32 and 64 bit).

What is the point of renaming "va"? I'm seeing a lot of unneeded
renaming in these patches that doesn't really seem needed and is just
making things harder to review.

> We can avoid storing the mask at all if we know that we're only allocating
> a single page.  This shrinks page_frag_cache from 12 to 8 bytes on 32-bit
> CONFIG_BASE_SMALL build.
>
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

So I am not really a fan of CONFIG_BASE_SMALL in general, so
advertising gains in size is just going back down the reducing size at
the expense of performance train of thought.

Do we know for certain that a higher order page is always aligned to
the size of the higher order page itself? That is one thing I have
never been certain about. I know for example there are head and tail
pages so I was never certain if it was possible to create a higher
order page that is not aligned to to the size of the page itself.

If we can get away with making that assumption then yes I would say
this is probably an optimization, though I think we would be better
off without the CONFIG_BASE_SMALL bits.

> ---
>  include/linux/mm_types.h | 12 +++++++-----
>  mm/page_alloc.c          | 40 +++++++++++++++-------------------------
>  2 files changed, 22 insertions(+), 30 deletions(-)
>
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 0defff9e3c0e..ebe93edec752 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -225,12 +225,9 @@ struct page {
>  #define PFC_MEMALLOC                   (1U << 31)
>
>  struct page_frag_cache {
> -       void * va;
> +       void *addr;
>  #if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
> -       __u16 offset;
> -       __u16 size;
> -#else
> -       __u32 offset;
> +       unsigned int mask;

So this is just an akward layout. You now have essentially:
#if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
#else
    unsigned int mask;
#endif

>  #endif
>         /* we maintain a pagecount bias, so that we dont dirty cache line
>          * containing page->_refcount every time we allocate a fragment.
> @@ -239,6 +236,11 @@ struct page_frag_cache {
>  };
>
>  #define page_frag_cache_pfmemalloc(pfc)        ((pfc)->pagecnt_bias & PFC_MEMALLOC)
> +#if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
> +#define page_frag_cache_mask(pfc)      (pfc)->mask
> +#else
> +#define page_frag_cache_mask(pfc)      (~PAGE_MASK)
> +#endif
>
>  typedef unsigned long vm_flags_t;
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5a2e3e293079..d15a5348a8e4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4336,22 +4336,19 @@ EXPORT_SYMBOL(free_pages);
>   * drivers to provide a backing region of memory for use as either an
>   * sk_buff->head, or to be used in the "frags" portion of skb_shared_info.
>   */
> -static struct page *__page_frag_cache_refill(struct page_frag_cache *pfc,
> +static void *__page_frag_cache_refill(struct page_frag_cache *pfc,
>                                              gfp_t gfp_mask)
>  {
>         unsigned int size = PAGE_SIZE;
>         struct page *page = NULL;
> -       struct page *old = pfc->va ? virt_to_page(pfc->va) : NULL;
> +       struct page *old = pfc->addr ? virt_to_head_page(pfc->addr) : NULL;
>         gfp_t gfp = gfp_mask;
>         unsigned int pagecnt_bias = pfc->pagecnt_bias & ~PFC_MEMALLOC;
>
>         /* If all allocations have been freed, we can reuse this page */
>         if (old && page_ref_sub_and_test(old, pagecnt_bias)) {
>                 page = old;
> -#if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
> -               /* if size can vary use size else just use PAGE_SIZE */
> -               size = pfc->size;
> -#endif
> +               size = page_frag_cache_mask(pfc) + 1;
>                 /* Page count is 0, we can safely set it */
>                 set_page_count(page, size);
>                 goto reset;
> @@ -4364,27 +4361,24 @@ static struct page *__page_frag_cache_refill(struct page_frag_cache *pfc,
>                                 PAGE_FRAG_CACHE_MAX_ORDER);PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
>         if (page)
>                 size = PAGE_FRAG_CACHE_MAX_SIZE;
> -       pfc->size = size;
> +       pfc->mask = size - 1;
>  #endif
>         if (unlikely(!page))
>                 page = alloc_pages_node(NUMA_NO_NODE, gfp, 0);
>         if (!page) {
> -               pfc->va = NULL;
> +               pfc->addr = NULL;
>                 return NULL;
>         }
>
> -       pfc->va = page_address(page);
> -
>         /* Using atomic_set() would break get_page_unless_zero() users. */
>         page_ref_add(page, size - 1);

You could just use the pfc->mask here instead of size - 1 just to
avoid having to do the subtraction more than once assuming the
compiler doesn't optimize it.

>  reset:
> -       /* reset page count bias and offset to start of new frag */
>         pfc->pagecnt_bias = size;
>         if (page_is_pfmemalloc(page))
>                 pfc->pagecnt_bias |= PFC_MEMALLOC;
> -       pfc->offset = size;
> +       pfc->addr = page_address(page) + size;
>
> -       return page;
> +       return pfc->addr;
>  }
>
>  void __page_frag_cache_drain(struct page *page, unsigned int count)
> @@ -4405,24 +4399,20 @@ EXPORT_SYMBOL(__page_frag_cache_drain);
>  void *page_frag_alloc(struct page_frag_cache *pfc,
>                       unsigned int size, gfp_t gfp_mask)
>  {
> -       struct page *page;
> -       int offset;
> +       void *addr = pfc->addr;
> +       unsigned int offset = (unsigned long)addr & page_frag_cache_mask(pfc);
>
> -       if (unlikely(!pfc->va)) {
> -refill:
> -               page = __page_frag_cache_refill(pfc, gfp_mask);
> -               if (!page)
> +       if (unlikely(offset < size)) {
> +               addr = __page_frag_cache_refill(pfc, gfp_mask);
> +               if (!addr)
>                         return NULL;
>         }
>
> -       offset = pfc->offset - size;
> -       if (unlikely(offset < 0))
> -               goto refill;
> -
> +       addr -= size;
> +       pfc->addr = addr;
>         pfc->pagecnt_bias--;
> -       pfc->offset = offset;
>
> -       return pfc->va + offset;
> +       return addr;
>  }
>  EXPORT_SYMBOL(page_frag_alloc);
>
> --
> 2.16.2
>
