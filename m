Received: by rv-out-0708.google.com with SMTP id f25so4280657rvb.26
        for <linux-mm@kvack.org>; Fri, 11 Jul 2008 01:35:40 -0700 (PDT)
Message-ID: <84144f020807110135w19cb9b5erff143912e5beb78c@mail.gmail.com>
Date: Fri, 11 Jul 2008 11:35:38 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [RFC PATCH 4/5] kmemtrace: SLUB hooks.
In-Reply-To: <20080710210617.70975aed@linux360.ro>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1215712946-23572-1-git-send-email-eduard.munteanu@linux360.ro>
	 <1215712946-23572-2-git-send-email-eduard.munteanu@linux360.ro>
	 <1215712946-23572-3-git-send-email-eduard.munteanu@linux360.ro>
	 <1215712946-23572-4-git-send-email-eduard.munteanu@linux360.ro>
	 <20080710210617.70975aed@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

Christoph, can you please take a look at this?

On Thu, Jul 10, 2008 at 9:06 PM, Eduard - Gabriel Munteanu
<eduard.munteanu@linux360.ro> wrote:
> This adds hooks for the SLUB allocator, to allow tracing with kmemtrace.
>
> Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

> ---
>  include/linux/slub_def.h |    9 +++++++-
>  mm/slub.c                |   49 +++++++++++++++++++++++++++++++++++++++------
>  2 files changed, 50 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index d117ea2..d60ab10 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -10,6 +10,7 @@
>  #include <linux/gfp.h>
>  #include <linux/workqueue.h>
>  #include <linux/kobject.h>
> +#include <linux/kmemtrace.h>
>
>  enum stat_item {
>        ALLOC_FASTPATH,         /* Allocation from cpu slab */
> @@ -205,7 +206,13 @@ void *__kmalloc(size_t size, gfp_t flags);
>
>  static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
>  {
> -       return (void *)__get_free_pages(flags | __GFP_COMP, get_order(size));
> +       unsigned int order = get_order(size);
> +       void *ret = (void *) __get_free_pages(flags, order);
> +
> +       kmemtrace_mark_alloc(KMEMTRACE_KIND_KERNEL, _THIS_IP_, ret,
> +                            size, PAGE_SIZE << order, flags);
> +
> +       return ret;
>  }
>
>  static __always_inline void *kmalloc(size_t size, gfp_t flags)
> diff --git a/mm/slub.c b/mm/slub.c
> index 1a427c0..6841dfa 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -23,6 +23,7 @@
>  #include <linux/kallsyms.h>
>  #include <linux/memory.h>
>  #include <linux/math64.h>
> +#include <linux/kmemtrace.h>
>
>  /*
>  * Lock order:
> @@ -1650,14 +1651,25 @@ static __always_inline void *slab_alloc(struct kmem_cache *s,
>
>  void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
>  {
> -       return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
> +       void *ret = slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
> +
> +       kmemtrace_mark_alloc(KMEMTRACE_KIND_CACHE, _RET_IP_, ret,
> +                            s->objsize, s->size, gfpflags);
> +
> +       return ret;
>  }
>  EXPORT_SYMBOL(kmem_cache_alloc);
>
>  #ifdef CONFIG_NUMA
>  void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
>  {
> -       return slab_alloc(s, gfpflags, node, __builtin_return_address(0));
> +       void *ret = slab_alloc(s, gfpflags, node,
> +                              __builtin_return_address(0));
> +
> +       kmemtrace_mark_alloc_node(KMEMTRACE_KIND_CACHE, _RET_IP_, ret,
> +                                 s->objsize, s->size, gfpflags, node);
> +
> +       return ret;
>  }
>  EXPORT_SYMBOL(kmem_cache_alloc_node);
>  #endif
> @@ -1769,6 +1781,8 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
>        page = virt_to_head_page(x);
>
>        slab_free(s, page, x, __builtin_return_address(0));
> +
> +       kmemtrace_mark_free(KMEMTRACE_KIND_CACHE, _RET_IP_, x);
>  }
>  EXPORT_SYMBOL(kmem_cache_free);
>
> @@ -2674,6 +2688,7 @@ static struct kmem_cache *get_slab(size_t size, gfp_t flags)
>  void *__kmalloc(size_t size, gfp_t flags)
>  {
>        struct kmem_cache *s;
> +       void *ret;
>
>        if (unlikely(size > PAGE_SIZE))
>                return kmalloc_large(size, flags);
> @@ -2683,7 +2698,12 @@ void *__kmalloc(size_t size, gfp_t flags)
>        if (unlikely(ZERO_OR_NULL_PTR(s)))
>                return s;
>
> -       return slab_alloc(s, flags, -1, __builtin_return_address(0));
> +       ret = slab_alloc(s, flags, -1, __builtin_return_address(0));
> +
> +       kmemtrace_mark_alloc(KMEMTRACE_KIND_KERNEL, _RET_IP_, ret,
> +                            size, (size_t) s->size, (unsigned long) flags);
> +
> +       return ret;
>  }
>  EXPORT_SYMBOL(__kmalloc);
>
> @@ -2702,16 +2722,29 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
>  void *__kmalloc_node(size_t size, gfp_t flags, int node)
>  {
>        struct kmem_cache *s;
> -
> -       if (unlikely(size > PAGE_SIZE))
> -               return kmalloc_large_node(size, flags, node);
> +       void *ret;
> +
> +       if (unlikely(size > PAGE_SIZE)) {
> +               ret = kmalloc_large_node(size, flags, node);
> +
> +               kmemtrace_mark_alloc_node(KMEMTRACE_KIND_KERNEL, _RET_IP_, ret,
> +                                         size, PAGE_SIZE << get_order(size),
> +                                         (unsigned long) flags, node);
> +
> +               return ret;
> +       }
>
>        s = get_slab(size, flags);
>
>        if (unlikely(ZERO_OR_NULL_PTR(s)))
>                return s;
>
> -       return slab_alloc(s, flags, node, __builtin_return_address(0));
> +       ret = slab_alloc(s, flags, node, __builtin_return_address(0));
> +
> +       kmemtrace_mark_alloc_node(KMEMTRACE_KIND_KERNEL, _RET_IP_, ret,
> +                                 size, s->size, (unsigned long) flags, node);
> +
> +       return ret;
>  }
>  EXPORT_SYMBOL(__kmalloc_node);
>  #endif
> @@ -2769,6 +2802,8 @@ void kfree(const void *x)
>                return;
>        }
>        slab_free(page->slab, page, object, __builtin_return_address(0));
> +
> +       kmemtrace_mark_free(KMEMTRACE_KIND_KERNEL, _RET_IP_, x);
>  }
>  EXPORT_SYMBOL(kfree);
>
> --
> 1.5.6.1
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
