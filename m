Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 237906B0038
	for <linux-mm@kvack.org>; Sat, 15 Oct 2016 18:59:37 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y138so11251344wme.7
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 15:59:37 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id f190si4845280wma.31.2016.10.15.15.59.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Oct 2016 15:59:35 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id d128so43929861wmf.1
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 15:59:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161015165405.GA31568@infradead.org>
References: <1476535979-27467-1-git-send-email-joelaf@google.com>
 <20161015164613.GA26079@infradead.org> <20161015165405.GA31568@infradead.org>
From: Joel Fernandes <joelaf@google.com>
Date: Sat, 15 Oct 2016 15:59:34 -0700
Message-ID: <CAJWu+opcYnvYXwLcOz49u9N7ZFpsLaqzccG7MZV2w85pgsR0Bw@mail.gmail.com>
Subject: Re: [PATCH v3] mm: vmalloc: Replace purge_lock spinlock with atomic refcount
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-rt-users@vger.kernel.org, Chris Wilson <chris@chris-wilson.co.uk>, Jisheng Zhang <jszhang@marvell.com>, John Dias <joaodias@google.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Hi Christoph,

On Sat, Oct 15, 2016 at 9:54 AM, Christoph Hellwig <hch@infradead.org> wrote:
> And now with a proper changelog, and the accidentall dropped call to
> flush_tlb_kernel_range reinstated:
>
> ---
> From f720cc324498ab5e7931c7ccb1653bd9b8cddc63 Mon Sep 17 00:00:00 2001
> From: Christoph Hellwig <hch@lst.de>
> Date: Sat, 15 Oct 2016 18:39:44 +0200
> Subject: mm: rewrite __purge_vmap_area_lazy
>
> Remove the purge lock, there was nothing left to be protected:
>
>   - purge_fragmented_blocks seems to has it's own local protection.
>   - all handling of of valist is implicity protected by the atomic
>     list deletion in llist_del_all, which also avoids multiple callers
>     stomping on each other here.
>   - the manipulation of vmap_lazy_nr already is atomic
>   - flush_tlb_kernel_range does not require any synchronization
>   - the calls to __free_vmap_area are sychronized by vmap_area_lock
>   - *start and *end always point to on-stack variables, never mind
>     that the caller never looks at the updated values anyway.
>
> Once that is done we can remove the sync argument by moving the calls
> to purge_fragmented_blocks_allcpus into the callers that need it,
> and the forced flush_tlb_kernel_range call even if no entries were
> found into the one caller that cares, and we can also pass start and
> end by reference.

Your patch changes the behavior of the original code I think. With the
patch, for the case where you have 2 concurrent tasks executing
alloc_vmap_area function, say both hit the overflow label and enter
the __purge_vmap_area_lazy at the same time. The first task empties
the purge list and sets nr to the total number of pages of all the
vmap areas in the list. Say the first task has just emptied the list
but hasn't started freeing the vmap areas and is preempted at this
point. Now the second task runs and since the purge list is empty, the
second task doesn't have anything to do and immediately returns to
alloc_vmap_area. Once it returns, it sets purged to 1 in
alloc_vmap_area and retries. Say it hits overflow label again in the
retry path. Now because purged was set to 1, it goes to err_free.
Without your patch, it would have waited on the spin_lock (sync = 1)
instead of just erroring out, so your patch does change the behavior
of the original code by not using the purge_lock. I realize my patch
also changes the behavior, but in mine I think we can make it behave
like the original code by spinning until purging=0 (if sync = 1)
because I still have the purging variable..

Some more comments below:

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  mm/vmalloc.c | 84 +++++++++++++++++++-----------------------------------------
>  1 file changed, 26 insertions(+), 58 deletions(-)
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index f2481cb..c3ca992 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -613,82 +613,44 @@ void set_iounmap_nonlazy(void)
>         atomic_set(&vmap_lazy_nr, lazy_max_pages()+1);
>  }
>
> -/*
> - * Purges all lazily-freed vmap areas.
> - *
> - * If sync is 0 then don't purge if there is already a purge in progress.
> - * If force_flush is 1, then flush kernel TLBs between *start and *end even
> - * if we found no lazy vmap areas to unmap (callers can use this to optimise
> - * their own TLB flushing).
> - * Returns with *start = min(*start, lowest purged address)
> - *              *end = max(*end, highest purged address)
> - */
> -static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
> -                                       int sync, int force_flush)
> +static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
>  {
> -       static DEFINE_SPINLOCK(purge_lock);
>         struct llist_node *valist;
>         struct vmap_area *va;
>         struct vmap_area *n_va;
>         int nr = 0;
>
> -       /*
> -        * If sync is 0 but force_flush is 1, we'll go sync anyway but callers
> -        * should not expect such behaviour. This just simplifies locking for
> -        * the case that isn't actually used at the moment anyway.
> -        */
> -       if (!sync && !force_flush) {
> -               if (!spin_trylock(&purge_lock))
> -                       return;
> -       } else
> -               spin_lock(&purge_lock);
> -
> -       if (sync)
> -               purge_fragmented_blocks_allcpus();
> -
>         valist = llist_del_all(&vmap_purge_list);
>         llist_for_each_entry(va, valist, purge_list) {
> -               if (va->va_start < *start)
> -                       *start = va->va_start;
> -               if (va->va_end > *end)
> -                       *end = va->va_end;
> +               if (va->va_start < start)
> +                       start = va->va_start;
> +               if (va->va_end > end)
> +                       end = va->va_end;
>                 nr += (va->va_end - va->va_start) >> PAGE_SHIFT;
>         }
>
> -       if (nr)
> -               atomic_sub(nr, &vmap_lazy_nr);
> -
> -       if (nr || force_flush)
> -               flush_tlb_kernel_range(*start, *end);
> -
> -       if (nr) {
> -               spin_lock(&vmap_area_lock);
> -               llist_for_each_entry_safe(va, n_va, valist, purge_list)
> -                       __free_vmap_area(va);
> -               spin_unlock(&vmap_area_lock);
> -       }
> -       spin_unlock(&purge_lock);
> -}
> +       if (!nr)
> +               return false;
>
> -/*
> - * Kick off a purge of the outstanding lazy areas. Don't bother if somebody
> - * is already purging.
> - */
> -static void try_purge_vmap_area_lazy(void)
> -{
> -       unsigned long start = ULONG_MAX, end = 0;
> +       atomic_sub(nr, &vmap_lazy_nr);
> +       flush_tlb_kernel_range(start, end);
>
> -       __purge_vmap_area_lazy(&start, &end, 0, 0);
> +       spin_lock(&vmap_area_lock);
> +       llist_for_each_entry_safe(va, n_va, valist, purge_list)
> +               __free_vmap_area(va);
> +       spin_unlock(&vmap_area_lock);

You should add a cond_resched_lock here as Chris Wilson suggested. I
tried your patch both with and without cond_resched_lock in this loop,
and without it I see the same problems my patch solves (high latencies
on cyclic test). With cond_resched_lock, your patch does solve my
problem although as I was worried above - that it changes the original
behavior.

Also, could you share your concerns about use of atomic_t in my patch?
I believe that since this is not a contented variable, the question of
lock fairness is not a concern. It is also not a lock really the way
I'm using it, it just keeps track of how many purges are in progress..

Thanks,
Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
