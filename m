Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1AD6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 01:51:38 -0400 (EDT)
Received: by oiag65 with SMTP id g65so27903917oia.2
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 22:51:38 -0700 (PDT)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id eq2si8737804obb.47.2015.03.17.22.51.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 22:51:37 -0700 (PDT)
Received: by oier21 with SMTP id r21so27974719oie.1
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 22:51:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1426248777-19768-3-git-send-email-r.peniaev@gmail.com>
References: <1426248777-19768-1-git-send-email-r.peniaev@gmail.com>
	<1426248777-19768-3-git-send-email-r.peniaev@gmail.com>
Date: Wed, 18 Mar 2015 14:51:37 +0900
Message-ID: <CAAmzW4OKd9xG8x2N3YshbQO+QvSxY9CXOb5mnQZZ2+cmtPi38w@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm/vmalloc: occupy newly allocated vmap block just
 after allocation
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Pen <r.peniaev@gmail.com>
Cc: Nick Piggin <npiggin@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <edumazet@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Gioh Kim <gioh.kim@lge.com>, Rob Jones <rob.jones@codethink.co.uk>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2015-03-13 21:12 GMT+09:00 Roman Pen <r.peniaev@gmail.com>:
> Previous implementation allocates new vmap block and repeats search of a free
> block from the very beginning, iterating over the CPU free list.
>
> Why it can be better??
>
> 1. Allocation can happen on one CPU, but search can be done on another CPU.
>    In worst case we preallocate amount of vmap blocks which is equal to
>    CPU number on the system.
>
> 2. In previous patch I added newly allocated block to the tail of free list
>    to avoid soon exhaustion of virtual space and give a chance to occupy
>    blocks which were allocated long time ago.  Thus to find newly allocated
>    block all the search sequence should be repeated, seems it is not efficient.
>
> In this patch newly allocated block is occupied right away, address of virtual
> space is returned to the caller, so there is no any need to repeat the search
> sequence, allocation job is done.
>
> Signed-off-by: Roman Pen <r.peniaev@gmail.com>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: WANG Chao <chaowang@redhat.com>
> Cc: Fabian Frederick <fabf@skynet.be>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Gioh Kim <gioh.kim@lge.com>
> Cc: Rob Jones <rob.jones@codethink.co.uk>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/vmalloc.c | 57 ++++++++++++++++++++++++++++++++++++---------------------
>  1 file changed, 36 insertions(+), 21 deletions(-)
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index db6bffb..9759c92 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -791,13 +791,30 @@ static unsigned long addr_to_vb_idx(unsigned long addr)
>         return addr;
>  }
>
> -static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
> +static void *vmap_block_vaddr(unsigned long va_start, unsigned long pages_off)
> +{
> +       unsigned long addr = va_start + (pages_off << PAGE_SHIFT);
> +       BUG_ON(addr_to_vb_idx(addr) != addr_to_vb_idx(va_start));

Need one blank line between above two lines.
Please run script/checkpatch.pl.

> +       return (void *)addr;
> +}
> +
> +/**
> + * new_vmap_block - allocates new vmap_block and occupies 2^order pages in this
> + *                  block. Of course pages number can't exceed VMAP_BBMAP_BITS
> + * @order:    how many 2^order pages should be occupied in newly allocated block
> + * @gfp_mask: flags for the page level allocator
> + * @addr:     output virtual address of a newly allocator block
> + *
> + * Returns: address of virtual space in a block or ERR_PTR
> + */
> +static void *new_vmap_block(unsigned int order, gfp_t gfp_mask)
>  {
>         struct vmap_block_queue *vbq;
>         struct vmap_block *vb;
>         struct vmap_area *va;
>         unsigned long vb_idx;
>         int node, err;
> +       void *vaddr;
>
>         node = numa_node_id();
>
> @@ -821,9 +838,12 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
>                 return ERR_PTR(err);
>         }
>
> +       vaddr = vmap_block_vaddr(va->va_start, 0);
>         spin_lock_init(&vb->lock);
>         vb->va = va;
> -       vb->free = VMAP_BBMAP_BITS;
> +       /* At least something should be left free */
> +       BUG_ON(VMAP_BBMAP_BITS <= (1UL << order));
> +       vb->free = VMAP_BBMAP_BITS - (1UL << order);
>         vb->dirty = 0;
>         bitmap_zero(vb->dirty_map, VMAP_BBMAP_BITS);
>         INIT_LIST_HEAD(&vb->free_list);
> @@ -841,7 +861,7 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
>         spin_unlock(&vbq->lock);
>         put_cpu_var(vmap_block_queue);
>
> -       return vb;
> +       return vaddr;
>  }
>
>  static void free_vmap_block(struct vmap_block *vb)
> @@ -905,7 +925,7 @@ static void *vb_alloc(unsigned long size, gfp_t gfp_mask)
>  {
>         struct vmap_block_queue *vbq;
>         struct vmap_block *vb;
> -       unsigned long addr = 0;
> +       void *vaddr = NULL;
>         unsigned int order;
>
>         BUG_ON(size & ~PAGE_MASK);
> @@ -920,43 +940,38 @@ static void *vb_alloc(unsigned long size, gfp_t gfp_mask)
>         }
>         order = get_order(size);
>
> -again:
>         rcu_read_lock();
>         vbq = &get_cpu_var(vmap_block_queue);
>         list_for_each_entry_rcu(vb, &vbq->free, free_list) {
> -               int i;
> +               unsigned long pages_nr;

I think that pages_off is better. Is there any reason to use this naming?

Anyway, patch looks okay to me.

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
