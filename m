Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E359A6B0292
	for <linux-mm@kvack.org>; Mon, 22 May 2017 17:38:18 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id i206so97300515ita.10
        for <linux-mm@kvack.org>; Mon, 22 May 2017 14:38:18 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 195sor239924itl.70.2017.05.22.14.38.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 May 2017 14:38:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170519103811.2183-2-igor.stoppa@huawei.com>
References: <20170519103811.2183-1-igor.stoppa@huawei.com> <20170519103811.2183-2-igor.stoppa@huawei.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 22 May 2017 14:38:16 -0700
Message-ID: <CAGXu5j+3-CZpZ4Vj2fHH+0UPAa_jOdJQxHtrQ=F_FvvzWvE00Q@mail.gmail.com>
Subject: Re: [PATCH 1/1] Sealable memory support
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>, Daniel Micay <danielmicay@gmail.com>

On Fri, May 19, 2017 at 3:38 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
> Dynamically allocated variables can be made read only,
> after they have been initialized, provided that they reside in memory
> pages devoid of any RW data.
>
> The implementation supplies means to create independent pools of memory,
> which can be individually created, sealed/unsealed and destroyed.

This would be a welcome addition, thanks for posting it! I have a
bunch of feedback, here and below:

For the first bit of bikeshedding, should this really be called
seal/unseal? My mind is probably just broken from having read TPM
documentation, but this isn't really "sealing" as I'd understand it
(it's not tied to a credential, for example). It's "only" rw/ro.
Perhaps "protect/unprotect" or just simply "readonly/writable", and
call the base function "romalloc"?

This is fundamentally a heap allocator, with linked lists, etc. I'd
like to see as much attention as possible given to hardening it
against attacks, especially adding redzoning around the metadata at
least, and perhaps requiring that CONFIG_DEBUG_LIST be enabled. And as
part of that, I'd like hardened usercopy to grow knowledge of these
allocations so we can bounds-check objects. Right now, mm/usercopy.c
just looks at PageSlab(page) to decide if it should do slab checks. I
think adding a check for this type of object would be very important
there.

The ro/rw granularity here is the _entire_ pool, not a specific
allocation (or page containing the allocation). I'm concerned that
makes this very open to race conditions where, especially in the
global pool, one thread can be trying to write to ro data in a pool
and another has made the pool writable.

> A global pool is made available for those kernel modules that do not
> need to manage an independent pool.
>
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>  mm/Makefile  |   2 +-
>  mm/smalloc.c | 200 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/smalloc.h |  61 ++++++++++++++++++
>  3 files changed, 262 insertions(+), 1 deletion(-)
>  create mode 100644 mm/smalloc.c
>  create mode 100644 mm/smalloc.h
>
> diff --git a/mm/Makefile b/mm/Makefile
> index 026f6a8..737c42a 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -39,7 +39,7 @@ obj-y                 := filemap.o mempool.o oom_kill.o \
>                            mm_init.o mmu_context.o percpu.o slab_common.o \
>                            compaction.o vmacache.o swap_slots.o \
>                            interval_tree.o list_lru.o workingset.o \
> -                          debug.o $(mmu-y)
> +                          debug.o smalloc.o $(mmu-y)
>
>  obj-y += init-mm.o
>
> diff --git a/mm/smalloc.c b/mm/smalloc.c
> new file mode 100644
> index 0000000..fa04cc5
> --- /dev/null
> +++ b/mm/smalloc.c
> @@ -0,0 +1,200 @@
> +/*
> + * smalloc.c: Sealable Memory Allocator
> + *
> + * (C) Copyright 2017 Huawei Technologies Co. Ltd.
> + * Author: Igor Stoppa <igor.stoppa@huawei.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; version 2
> + * of the License.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/printk.h>
> +#include <linux/kobject.h>
> +#include <linux/sysfs.h>
> +#include <linux/init.h>
> +#include <linux/fs.h>
> +#include <linux/string.h>
> +
> +
> +#include <linux/vmalloc.h>
> +#include <asm/cacheflush.h>
> +#include "smalloc.h"

Shouldn't this just be <linux/smalloc.h> ?

> +#define page_roundup(size) (((size) + !(size) - 1 + PAGE_SIZE) & PAGE_MASK)
> +
> +#define pages_nr(size) (page_roundup(size) / PAGE_SIZE)
> +
> +static struct smalloc_pool *global_pool;
> +
> +struct smalloc_node *__smalloc_create_node(unsigned long words)
> +{
> +       struct smalloc_node *node;
> +       unsigned long size;
> +
> +       /* Calculate the size to ask from vmalloc, page aligned. */
> +       size = page_roundup(NODE_HEADER_SIZE + words * sizeof(align_t));
> +       node = vmalloc(size);
> +       if (!node) {
> +               pr_err("No memory for allocating smalloc node.");
> +               return NULL;
> +       }
> +       /* Initialize the node.*/
> +       INIT_LIST_HEAD(&node->list);
> +       node->free = node->data;
> +       node->available_words = (size - NODE_HEADER_SIZE) / sizeof(align_t);
> +       return node;
> +}
> +
> +static __always_inline
> +void *node_alloc(struct smalloc_node *node, unsigned long words)
> +{
> +       register align_t *old_free = node->free;
> +
> +       node->available_words -= words;
> +       node->free += words;
> +       return old_free;
> +}
> +
> +void *smalloc(unsigned long size, struct smalloc_pool *pool)
> +{
> +       struct list_head *pos;
> +       struct smalloc_node *node;
> +       void *ptr;
> +       unsigned long words;
> +
> +       /* If no pool specified, use the global one. */
> +       if (!pool)
> +               pool = global_pool;

It should be impossible, but this should check for global_pool == NULL too, IMO.

> +       mutex_lock(&pool->lock);
> +
> +       /* If the pool is sealed, then return NULL. */
> +       if (pool->seal == SMALLOC_SEALED) {
> +               mutex_unlock(&pool->lock);
> +               return NULL;
> +       }
> +
> +       /* Calculate minimum number of words required. */
> +       words = (size + sizeof(align_t) - 1) / sizeof(align_t);
> +
> +       /* Look for slot that is large enough, in the existing pool.*/
> +       list_for_each(pos, &pool->list) {
> +               node = list_entry(pos, struct smalloc_node, list);
> +               if (node->available_words >= words) {
> +                       ptr = node_alloc(node, words);
> +                       mutex_unlock(&pool->lock);
> +                       return ptr;
> +               }
> +       }
> +
> +       /* No slot found, get a new chunk of virtual memory. */
> +       node = __smalloc_create_node(words);
> +       if (!node) {
> +               mutex_unlock(&pool->lock);
> +               return NULL;
> +       }
> +
> +       list_add(&node->list, &pool->list);
> +       ptr = node_alloc(node, words);
> +       mutex_unlock(&pool->lock);
> +       return ptr;
> +}
> +
> +static __always_inline
> +unsigned long get_node_size(struct smalloc_node *node)
> +{
> +       if (!node)
> +               return 0;
> +       return page_roundup((((void *)node->free) - (void *)node) +
> +                           node->available_words * sizeof(align_t));
> +}
> +
> +static __always_inline
> +unsigned long get_node_pages_nr(struct smalloc_node *node)
> +{
> +       return pages_nr(get_node_size(node));
> +}
> +void smalloc_seal_set(enum seal_t seal, struct smalloc_pool *pool)
> +{
> +       struct list_head *pos;
> +       struct smalloc_node *node;
> +
> +       if (!pool)
> +               pool = global_pool;
> +       mutex_lock(&pool->lock);
> +       if (pool->seal == seal) {
> +               mutex_unlock(&pool->lock);
> +               return;

I actually think this should be a BUG condition, since this means a
mismatched seal/unseal happened. The pool should never be left
writable at rest, a user should create a pool, write to it, seal. Any
updates should unseal, write, seal. To attempt an unseal and find it
already unsealed seems bad.

Finding a user for this would help clarify its protection properties,
too. (The LSM example is likely not the best starting point for that,
as it would depend on other changes that are under discussion.)

> +       }
> +       list_for_each(pos, &pool->list) {
> +               node = list_entry(pos, struct smalloc_node, list);
> +               if (seal == SMALLOC_SEALED)
> +                       set_memory_ro((unsigned long)node,
> +                                     get_node_pages_nr(node));
> +               else if (seal == SMALLOC_UNSEALED)
> +                       set_memory_rw((unsigned long)node,
> +                                     get_node_pages_nr(node));
> +       }
> +       pool->seal = seal;
> +       mutex_unlock(&pool->lock);
> +}
> +
> +int smalloc_initialize(struct smalloc_pool *pool)
> +{
> +       if (!pool)
> +               return -EINVAL;
> +       INIT_LIST_HEAD(&pool->list);
> +       pool->seal = SMALLOC_UNSEALED;
> +       mutex_init(&pool->lock);
> +       return 0;
> +}
> +
> +struct smalloc_pool *smalloc_create(void)
> +{
> +       struct smalloc_pool *pool = vmalloc(sizeof(struct smalloc_pool));
> +
> +       if (!pool) {
> +               pr_err("No memory for allocating pool.");

It might be handy to have pools named like they are for the slab allocator.

> +               return NULL;
> +       }
> +       smalloc_initialize(pool);
> +       return pool;
> +}
> +
> +int smalloc_destroy(struct smalloc_pool *pool)
> +{
> +       struct list_head *pos, *q;
> +       struct smalloc_node *node;
> +
> +       if (!pool)
> +               return -EINVAL;
> +       list_for_each_safe(pos, q, &pool->list) {
> +               node = list_entry(pos, struct smalloc_node, list);
> +               list_del(pos);
> +               vfree(node);
> +       }
> +       return 0;
> +}
> +
> +static int __init smalloc_init(void)
> +{
> +       global_pool = smalloc_create();
> +       if (!global_pool) {
> +               pr_err("Module smalloc initialization failed: no memory.\n");
> +               return -ENOMEM;
> +       }
> +       pr_info("Module smalloc initialized successfully.\n");
> +       return 0;
> +}
> +
> +static void __exit smalloc_exit(void)
> +{
> +       pr_info("Module smalloc un initialized successfully.\n");

typo: space after "un"

> +}
> +
> +module_init(smalloc_init);
> +module_exit(smalloc_exit);
> +MODULE_LICENSE("GPL");
> diff --git a/mm/smalloc.h b/mm/smalloc.h
> new file mode 100644
> index 0000000..344d962
> --- /dev/null
> +++ b/mm/smalloc.h
> @@ -0,0 +1,61 @@
> +/*
> + * smalloc.h: Header for Sealable Memory Allocator
> + *
> + * (C) Copyright 2017 Huawei Technologies Co. Ltd.
> + * Author: Igor Stoppa <igor.stoppa@huawei.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; version 2
> + * of the License.
> + */
> +
> +#ifndef _SMALLOC_H
> +#define _SMALLOC_H
> +
> +#include <linux/list.h>
> +#include <linux/mutex.h>
> +
> +typedef uint64_t align_t;
> +
> +enum seal_t {
> +       SMALLOC_UNSEALED,
> +       SMALLOC_SEALED,
> +};
> +
> +#define __SMALLOC_ALIGNED__ __aligned(sizeof(align_t))
> +
> +#define NODE_HEADER                                    \
> +       struct {                                        \
> +               __SMALLOC_ALIGNED__ struct {            \
> +                       struct list_head list;          \
> +                       align_t *free;                  \
> +                       unsigned long available_words;  \
> +               };                                      \
> +       }
> +
> +#define NODE_HEADER_SIZE sizeof(NODE_HEADER)
> +
> +struct smalloc_pool {
> +       struct list_head list;
> +       struct mutex lock;
> +       enum seal_t seal;
> +};
> +
> +struct smalloc_node {
> +       NODE_HEADER;
> +       __SMALLOC_ALIGNED__ align_t data[];
> +};
> +
> +#define smalloc_seal(pool) \
> +       smalloc_seal_set(SMALLOC_SEALED, pool)
> +
> +#define smalloc_unseal(pool) \
> +       smalloc_seal_set(SMALLOC_UNSEALED, pool)
> +
> +struct smalloc_pool *smalloc_create(void);
> +int smalloc_destroy(struct smalloc_pool *pool);
> +int smalloc_initialize(struct smalloc_pool *pool);
> +void *smalloc(unsigned long size, struct smalloc_pool *pool);
> +void smalloc_seal_set(enum seal_t seal, struct smalloc_pool *pool);

I'd really like to see kernel-doc for the API functions (likely in the .c file).

> +#endif
> --
> 2.9.3

Thanks again for working on this! If you can find examples of file
operations living in the heap, those would be great examples for using
this API (assuming the other properties can be improved).

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
