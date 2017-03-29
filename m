Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E4F5D6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 07:47:09 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z109so2380808wrb.1
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 04:47:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z7si8181432wrz.204.2017.03.29.04.47.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 04:47:08 -0700 (PDT)
Date: Wed, 29 Mar 2017 13:47:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm: Allow calling vfree() from non-schedulable
 context.
Message-ID: <20170329114705.GL27994@dhcp22.suse.cz>
References: <1490784712-4991-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <0065385b-8cf9-aec6-22bb-9e6d21501a8c@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0065385b-8cf9-aec6-22bb-9e6d21501a8c@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Chris Wilson <chris@chris-wilson.co.uk>, Christoph Hellwig <hch@lst.de>, Ingo Molnar <mingo@elte.hu>, Jisheng Zhang <jszhang@marvell.com>, Joel Fernandes <joelaf@google.com>, John Dias <joaodias@google.com>, Matthew Wilcox <willy@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On Wed 29-03-17 14:36:10, Andrey Ryabinin wrote:
[...]
> So I just get a better idea. How about just always deferring
> __purge_vmap_area_lazy()?

I didn't get to look closer but from the high level POV this makes a lot
of sense. __purge_vmap_area_lazy shouldn't be called all that often that
the deferred mode would matter.

> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 68eb002..a02a250 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -701,7 +701,7 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
>   * Kick off a purge of the outstanding lazy areas. Don't bother if somebody
>   * is already purging.
>   */
> -static void try_purge_vmap_area_lazy(void)
> +static void try_purge_vmap_area_lazy(struct work_struct *work)
>  {
>         if (mutex_trylock(&vmap_purge_lock)) {
>                 __purge_vmap_area_lazy(ULONG_MAX, 0);
> @@ -720,6 +720,8 @@ static void purge_vmap_area_lazy(void)
>         mutex_unlock(&vmap_purge_lock);
>  }
>  
> +static DECLARE_WORK(purge_vmap_work, try_purge_vmap_area_lazy);
> +
>  /*
>   * Free a vmap area, caller ensuring that the area has been unmapped
>   * and flush_cache_vunmap had been called for the correct range
> @@ -735,8 +737,9 @@ static void free_vmap_area_noflush(struct vmap_area *va)
>         /* After this point, we may free va at any time */
>         llist_add(&va->purge_list, &vmap_purge_list);
>  
> -       if (unlikely(nr_lazy > lazy_max_pages()))
> -               try_purge_vmap_area_lazy();
> +       if (unlikely(nr_lazy > lazy_max_pages())
> +           && !work_pending(&purge_vmap_work))
> +               schedule_work(&purge_vmap_work);
>  }
>  
>  /*
> @@ -1125,7 +1128,6 @@ void vm_unmap_ram(const void *mem, unsigned int count)
>         unsigned long addr = (unsigned long)mem;
>         struct vmap_area *va;
>  
> -       might_sleep();
>         BUG_ON(!addr);
>         BUG_ON(addr < VMALLOC_START);
>         BUG_ON(addr > VMALLOC_END);
> @@ -1477,8 +1479,6 @@ struct vm_struct *remove_vm_area(const void *addr)
>  {
>         struct vmap_area *va;
>  
> -       might_sleep();
> -
>         va = find_vmap_area((unsigned long)addr);
>         if (va && va->flags & VM_VM_AREA) {
>                 struct vm_struct *vm = va->vm;
> 
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
