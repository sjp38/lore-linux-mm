Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA2936B000C
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:39:42 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 3so4623916wrb.5
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 09:39:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v66sor1975947wmd.91.2018.03.22.09.39.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Mar 2018 09:39:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180322153157.10447-2-willy@infradead.org>
References: <20180322153157.10447-1-willy@infradead.org> <20180322153157.10447-2-willy@infradead.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 22 Mar 2018 09:39:40 -0700
Message-ID: <CAKgT0Ud7CcKcbwjwDU0RrUNwDaJWwZoG0k2VYANeqq679X_9Hg@mail.gmail.com>
Subject: Re: [PATCH v2 1/8] page_frag_cache: Remove pfmemalloc bool
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Thu, Mar 22, 2018 at 8:31 AM, Matthew Wilcox <willy@infradead.org> wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
>
> Save 4/8 bytes by moving the pfmemalloc indicator from its own bool
> to the top bit of pagecnt_bias.  This has no effect on the fastpath
> of the allocator since the pagecnt_bias cannot go negative.  It's
> a couple of extra instructions in the slowpath.
>
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

So I was just thinking about this and it would probably make more
sense to look at addressing this after you take care of your
conversion from size/offset to a mask. One thing with the mask is that
it should never reach 64K since that is the largest page size if I
recall. With that being the case we could look at dropping mask to a
u16 value and then add a u16 flags field where you could store things
like this. Then you could avoid having to do the masking and math you
are having to do below.

> ---
>  include/linux/mm_types.h | 4 +++-
>  mm/page_alloc.c          | 8 +++++---
>  net/core/skbuff.c        | 5 ++---
>  3 files changed, 10 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index fd1af6b9591d..a63b138ad1a4 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -218,6 +218,7 @@ struct page {
>
>  #define PAGE_FRAG_CACHE_MAX_SIZE       __ALIGN_MASK(32768, ~PAGE_MASK)
>  #define PAGE_FRAG_CACHE_MAX_ORDER      get_order(PAGE_FRAG_CACHE_MAX_SIZE)
> +#define PFC_MEMALLOC                   (1U << 31)
>
>  struct page_frag_cache {
>         void * va;
> @@ -231,9 +232,10 @@ struct page_frag_cache {
>          * containing page->_refcount every time we allocate a fragment.
>          */
>         unsigned int            pagecnt_bias;
> -       bool pfmemalloc;
>  };
>
> +#define page_frag_cache_pfmemalloc(pfc)        ((pfc)->pagecnt_bias & PFC_MEMALLOC)
> +
>  typedef unsigned long vm_flags_t;
>
>  /*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 635d7dd29d7f..61366f23e8c8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4395,16 +4395,18 @@ void *page_frag_alloc(struct page_frag_cache *nc,
>                 page_ref_add(page, size - 1);
>
>                 /* reset page count bias and offset to start of new frag */
> -               nc->pfmemalloc = page_is_pfmemalloc(page);
>                 nc->pagecnt_bias = size;
> +               if (page_is_pfmemalloc(page))
> +                       nc->pagecnt_bias |= PFC_MEMALLOC;
>                 nc->offset = size;
>         }
>
>         offset = nc->offset - fragsz;
>         if (unlikely(offset < 0)) {
> +               unsigned int pagecnt_bias = nc->pagecnt_bias & ~PFC_MEMALLOC;
>                 page = virt_to_page(nc->va);
>
> -               if (!page_ref_sub_and_test(page, nc->pagecnt_bias))
> +               if (!page_ref_sub_and_test(page, pagecnt_bias))
>                         goto refill;
>
>  #if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
> @@ -4415,7 +4417,7 @@ void *page_frag_alloc(struct page_frag_cache *nc,
>                 set_page_count(page, size);
>
>                 /* reset page count bias and offset to start of new frag */
> -               nc->pagecnt_bias = size;
> +               nc->pagecnt_bias = size | (nc->pagecnt_bias - pagecnt_bias);
>                 offset = size - fragsz;
>         }
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 0bb0d8877954..54bbde8f7541 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -412,7 +412,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int len,
>
>         nc = this_cpu_ptr(&netdev_alloc_cache);
>         data = page_frag_alloc(nc, len, gfp_mask);
> -       pfmemalloc = nc->pfmemalloc;
> +       pfmemalloc = page_frag_cache_pfmemalloc(nc);
>
>         local_irq_restore(flags);
>
> @@ -485,8 +485,7 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
>                 return NULL;
>         }
>
> -       /* use OR instead of assignment to avoid clearing of bits in mask */
> -       if (nc->page.pfmemalloc)
> +       if (page_frag_cache_pfmemalloc(&nc->page))
>                 skb->pfmemalloc = 1;
>         skb->head_frag = 1;
>
> --
> 2.16.2
>
