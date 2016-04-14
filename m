Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05DB06B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 09:13:29 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id d19so46182431lfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 06:13:28 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 139si34776424wmv.120.2016.04.14.06.13.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 06:13:27 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id l6so22768790wml.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 06:13:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1460444239-22475-1-git-send-email-chris@chris-wilson.co.uk>
References: <1460444239-22475-1-git-send-email-chris@chris-wilson.co.uk>
Date: Thu, 14 Apr 2016 15:13:26 +0200
Message-ID: <CACZ9PQV+H+i11E-GEfFeMD3cXWXOF1yPGJH8j7BLXQVqFB3oGw@mail.gmail.com>
Subject: Re: [PATCH] mm/vmalloc: Keep a separate lazy-free list
From: Roman Peniaev <r.peniaev@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Tvrtko Ursulin <tvrtko.ursulin@linux.intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Toshi Kani <toshi.kani@hp.com>, Shawn Lin <shawn.lin@rock-chips.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi, Chris.

Is it made on purpose not to drop VM_LAZY_FREE flag in
__purge_vmap_area_lazy()?  With your patch va->flags
will have two bits set: VM_LAZY_FREE | VM_LAZY_FREEING.
Seems it is not that bad, because all other code paths
do not care, but still the change is not clear.

Also, did you consider to avoid taking static purge_lock
in __purge_vmap_area_lazy() ? Because, with your change
it seems that you can avoid taking this lock at all.
Just be careful when you observe llist as empty, i.e.
nr == 0.

And one comment is below:

On Tue, Apr 12, 2016 at 8:57 AM, Chris Wilson <chris@chris-wilson.co.uk> wrote:
> When mixing lots of vmallocs and set_memory_*() (which calls
> vm_unmap_aliases()) I encountered situations where the performance
> degraded severely due to the walking of the entire vmap_area list each
> invocation. One simple improvement is to add the lazily freed vmap_area
> to a separate lockless free list, such that we then avoid having to walk
> the full list on each purge.
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
> ---
>  include/linux/vmalloc.h |  3 ++-
>  mm/vmalloc.c            | 29 ++++++++++++++---------------
>  2 files changed, 16 insertions(+), 16 deletions(-)
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
> index 293889d7f482..5388bf64dc32 100644
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
> @@ -282,6 +283,7 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
>  static DEFINE_SPINLOCK(vmap_area_lock);
>  /* Export for kexec only */
>  LIST_HEAD(vmap_area_list);
> +static LLIST_HEAD(vmap_purge_list);
>  static struct rb_root vmap_area_root = RB_ROOT;
>
>  /* The vmap cache globals are protected by vmap_area_lock */
> @@ -628,7 +630,7 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
>                                         int sync, int force_flush)
>  {
>         static DEFINE_SPINLOCK(purge_lock);
> -       LIST_HEAD(valist);
> +       struct llist_node *valist;
>         struct vmap_area *va;
>         struct vmap_area *n_va;
>         int nr = 0;
> @@ -647,20 +649,15 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
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
> +               va->flags |= VM_LAZY_FREEING;
>         }
> -       rcu_read_unlock();
>
>         if (nr)
>                 atomic_sub(nr, &vmap_lazy_nr);
> @@ -670,7 +667,7 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
>
>         if (nr) {
>                 spin_lock(&vmap_area_lock);
> -               list_for_each_entry_safe(va, n_va, &valist, purge_list)
> +               llist_for_each_entry_safe(va, n_va, valist, purge_list)
>                         __free_vmap_area(va);
>                 spin_unlock(&vmap_area_lock);
>         }
> @@ -706,6 +703,8 @@ static void purge_vmap_area_lazy(void)
>  static void free_vmap_area_noflush(struct vmap_area *va)
>  {
>         va->flags |= VM_LAZY_FREE;
> +       llist_add(&va->purge_list, &vmap_purge_list);
> +
>         atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);

it seems to me that this a very long-standing problem: when you mark
va->flags as VM_LAZY_FREE, va can be immediately freed from another CPU.
If so, the line:

    atomic_add((va->va_end - va->va_start)....

 does use-after-free access.

So I would also fix it with careful line reordering with barrier:
(probably barrier is excess here, because llist_add implies cmpxchg,
 but I simply want to be explicit here, showing that marking va as
 VM_LAZY_FREE and adding it to the list should be at the end)

-       va->flags |= VM_LAZY_FREE;
        atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
+       smp_mb__after_atomic();
+       va->flags |= VM_LAZY_FREE;
+       llist_add(&va->purge_list, &vmap_purge_list);

What do you think?

--
Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
