Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1CCED6B025E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 07:54:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a125so16479873wmd.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 04:54:19 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id o19si34366749wmg.25.2016.04.15.04.54.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 04:54:17 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id n3so28879470wmn.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 04:54:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1460718426-20915-1-git-send-email-chris@chris-wilson.co.uk>
References: <CACZ9PQXCHRC5bFqQKmtOv+GyuEmEaXDVPJdQhBt0sXPfomFTNw@mail.gmail.com>
	<1460718426-20915-1-git-send-email-chris@chris-wilson.co.uk>
Date: Fri, 15 Apr 2016 13:54:17 +0200
Message-ID: <CACZ9PQWsaS75MKBh10TWFcLzD43T1nX-4hHEP3DQ8VhLzHmYAw@mail.gmail.com>
Subject: Re: [PATCH v2] mm/vmalloc: Keep a separate lazy-free list
From: Roman Peniaev <r.peniaev@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Tvrtko Ursulin <tvrtko.ursulin@linux.intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Toshi Kani <toshi.kani@hp.com>, Shawn Lin <shawn.lin@rock-chips.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Apr 15, 2016 at 1:07 PM, Chris Wilson <chris@chris-wilson.co.uk> wrote:
> When mixing lots of vmallocs and set_memory_*() (which calls
> vm_unmap_aliases()) I encountered situations where the performance
> degraded severely due to the walking of the entire vmap_area list each
> invocation. One simple improvement is to add the lazily freed vmap_area
> to a separate lockless free list, such that we then avoid having to walk
> the full list on each purge.
>
> v2: Remove unused VM_LAZY_FREE and VM_LAZY_FREEING flags and reorder
> access of vmap_area during addition to the lazy free list to avoid
> use-after free (Roman).
>
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Tvrtko Ursulin <tvrtko.ursulin@linux.intel.com>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Roman Pen <r.peniaev@gmail.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Toshi Kani <toshi.kani@hp.com>
> Cc: Shawn Lin <shawn.lin@rock-chips.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Reviewed-by: Roman Pen <r.peniaev@gmail.com>

Thanks.

--
Roman

> ---
>  include/linux/vmalloc.h |  3 ++-
>  mm/vmalloc.c            | 40 ++++++++++++++++++++--------------------
>  2 files changed, 22 insertions(+), 21 deletions(-)
>
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 8b51df3ab334..3d9d786a943c 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -4,6 +4,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/init.h>
>  #include <linux/list.h>
> +#include <linux/llist.h>
>  #include <asm/page.h>          /* pgprot_t */
>  #include <linux/rbtree.h>
>
> @@ -45,7 +46,7 @@ struct vmap_area {
>         unsigned long flags;
>         struct rb_node rb_node;         /* address sorted rbtree */
>         struct list_head list;          /* address sorted list */
> -       struct list_head purge_list;    /* "lazy purge" list */
> +       struct llist_node purge_list;    /* "lazy purge" list */
>         struct vm_struct *vm;
>         struct rcu_head rcu_head;
>  };
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 293889d7f482..70f942832164 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -21,6 +21,7 @@
>  #include <linux/debugobjects.h>
>  #include <linux/kallsyms.h>
>  #include <linux/list.h>
> +#include <linux/llist.h>
>  #include <linux/notifier.h>
>  #include <linux/rbtree.h>
>  #include <linux/radix-tree.h>
> @@ -275,13 +276,12 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
>
>  /*** Global kva allocator ***/
>
> -#define VM_LAZY_FREE   0x01
> -#define VM_LAZY_FREEING        0x02
>  #define VM_VM_AREA     0x04
>
>  static DEFINE_SPINLOCK(vmap_area_lock);
>  /* Export for kexec only */
>  LIST_HEAD(vmap_area_list);
> +static LLIST_HEAD(vmap_purge_list);
>  static struct rb_root vmap_area_root = RB_ROOT;
>
>  /* The vmap cache globals are protected by vmap_area_lock */
> @@ -628,7 +628,7 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
>                                         int sync, int force_flush)
>  {
>         static DEFINE_SPINLOCK(purge_lock);
> -       LIST_HEAD(valist);
> +       struct llist_node *valist;
>         struct vmap_area *va;
>         struct vmap_area *n_va;
>         int nr = 0;
> @@ -647,20 +647,14 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
>         if (sync)
>                 purge_fragmented_blocks_allcpus();
>
> -       rcu_read_lock();
> -       list_for_each_entry_rcu(va, &vmap_area_list, list) {
> -               if (va->flags & VM_LAZY_FREE) {
> -                       if (va->va_start < *start)
> -                               *start = va->va_start;
> -                       if (va->va_end > *end)
> -                               *end = va->va_end;
> -                       nr += (va->va_end - va->va_start) >> PAGE_SHIFT;
> -                       list_add_tail(&va->purge_list, &valist);
> -                       va->flags |= VM_LAZY_FREEING;
> -                       va->flags &= ~VM_LAZY_FREE;
> -               }
> +       valist = llist_del_all(&vmap_purge_list);
> +       llist_for_each_entry(va, valist, purge_list) {
> +               if (va->va_start < *start)
> +                       *start = va->va_start;
> +               if (va->va_end > *end)
> +                       *end = va->va_end;
> +               nr += (va->va_end - va->va_start) >> PAGE_SHIFT;
>         }
> -       rcu_read_unlock();
>
>         if (nr)
>                 atomic_sub(nr, &vmap_lazy_nr);
> @@ -670,7 +664,7 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
>
>         if (nr) {
>                 spin_lock(&vmap_area_lock);
> -               list_for_each_entry_safe(va, n_va, &valist, purge_list)
> +               llist_for_each_entry_safe(va, n_va, valist, purge_list)
>                         __free_vmap_area(va);
>                 spin_unlock(&vmap_area_lock);
>         }
> @@ -705,9 +699,15 @@ static void purge_vmap_area_lazy(void)
>   */
>  static void free_vmap_area_noflush(struct vmap_area *va)
>  {
> -       va->flags |= VM_LAZY_FREE;
> -       atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
> -       if (unlikely(atomic_read(&vmap_lazy_nr) > lazy_max_pages()))
> +       int nr_lazy;
> +
> +       nr_lazy = atomic_add_return((va->va_end - va->va_start) >> PAGE_SHIFT,
> +                                   &vmap_lazy_nr);
> +
> +       /* After this point, we may free va at any time */
> +       llist_add(&va->purge_list, &vmap_purge_list);
> +
> +       if (unlikely(nr_lazy > lazy_max_pages()))
>                 try_purge_vmap_area_lazy();
>  }
>
> --
> 2.8.0.rc3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
