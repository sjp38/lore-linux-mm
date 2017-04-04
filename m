Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3C86B039F
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 05:38:36 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k6so27755797wre.3
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 02:38:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h2si23740824wrc.165.2017.04.04.02.38.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 02:38:34 -0700 (PDT)
Date: Tue, 4 Apr 2017 11:38:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm/vmalloc: allow to call vfree() in atomic context
Message-ID: <20170404093831.GH15132@dhcp22.suse.cz>
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170330102719.13119-1-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de, thellstrom@vmware.com, stable@vger.kernel.org

On Thu 30-03-17 13:27:16, Andrey Ryabinin wrote:
> Commit 5803ed292e63 ("mm: mark all calls into the vmalloc subsystem
> as potentially sleeping") added might_sleep() to remove_vm_area() from
> vfree(), and commit 763b218ddfaf ("mm: add preempt points into
> __purge_vmap_area_lazy()") actually made vfree() potentially sleeping.
> 
> This broke vmwgfx driver which calls vfree() under spin_lock().
> 
>     BUG: sleeping function called from invalid context at mm/vmalloc.c:1480
>     in_atomic(): 1, irqs_disabled(): 0, pid: 341, name: plymouthd
>     2 locks held by plymouthd/341:
>      #0:  (drm_global_mutex){+.+.+.}, at: [<ffffffffc01c274b>] drm_release+0x3b/0x3b0 [drm]
>      #1:  (&(&tfile->lock)->rlock){+.+...}, at: [<ffffffffc0173038>] ttm_object_file_release+0x28/0x90 [ttm]
> 
>     Call Trace:
>      dump_stack+0x86/0xc3
>      ___might_sleep+0x17d/0x250
>      __might_sleep+0x4a/0x80
>      remove_vm_area+0x22/0x90
>      __vunmap+0x2e/0x110
>      vfree+0x42/0x90
>      kvfree+0x2c/0x40
>      drm_ht_remove+0x1a/0x30 [drm]
>      ttm_object_file_release+0x50/0x90 [ttm]
>      vmw_postclose+0x47/0x60 [vmwgfx]
>      drm_release+0x290/0x3b0 [drm]
>      __fput+0xf8/0x210
>      ____fput+0xe/0x10
>      task_work_run+0x85/0xc0
>      exit_to_usermode_loop+0xb4/0xc0
>      do_syscall_64+0x185/0x1f0
>      entry_SYSCALL64_slow_path+0x25/0x25
> 
> This can be fixed in vmgfx, but it would be better to make vfree()
> non-sleeping again because we may have other bugs like this one.
> 
> __purge_vmap_area_lazy() is the only function in the vfree() path that
> wants to be able to sleep. So it make sense to schedule
> __purge_vmap_area_lazy() via schedule_work() so it runs only in sleepable
> context. This will have a minimal effect on the regular vfree() path.
> since __purge_vmap_area_lazy() is rarely called.
> 
> Fixes: 5803ed292e63 ("mm: mark all calls into the vmalloc subsystem as
>                       potentially sleeping")
> Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: <stable@vger.kernel.org>

Yes I believe this is an enhancements. 
Acked-by: Michal Hocko <mhocko@suse.com>

Crawling over all vfree users is just unfeasible.

> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>  mm/vmalloc.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 68eb002..ea1b4ab 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -701,7 +701,7 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
>   * Kick off a purge of the outstanding lazy areas. Don't bother if somebody
>   * is already purging.
>   */
> -static void try_purge_vmap_area_lazy(void)
> +static void try_purge_vmap_area_lazy(struct work_struct *work)
>  {
>  	if (mutex_trylock(&vmap_purge_lock)) {
>  		__purge_vmap_area_lazy(ULONG_MAX, 0);
> @@ -720,6 +720,8 @@ static void purge_vmap_area_lazy(void)
>  	mutex_unlock(&vmap_purge_lock);
>  }
>  
> +static DECLARE_WORK(purge_vmap_work, try_purge_vmap_area_lazy);
> +
>  /*
>   * Free a vmap area, caller ensuring that the area has been unmapped
>   * and flush_cache_vunmap had been called for the correct range
> @@ -736,7 +738,7 @@ static void free_vmap_area_noflush(struct vmap_area *va)
>  	llist_add(&va->purge_list, &vmap_purge_list);
>  
>  	if (unlikely(nr_lazy > lazy_max_pages()))
> -		try_purge_vmap_area_lazy();
> +		schedule_work(&purge_vmap_work);
>  }
>  
>  /*
> @@ -1125,7 +1127,6 @@ void vm_unmap_ram(const void *mem, unsigned int count)
>  	unsigned long addr = (unsigned long)mem;
>  	struct vmap_area *va;
>  
> -	might_sleep();
>  	BUG_ON(!addr);
>  	BUG_ON(addr < VMALLOC_START);
>  	BUG_ON(addr > VMALLOC_END);
> @@ -1477,8 +1478,6 @@ struct vm_struct *remove_vm_area(const void *addr)
>  {
>  	struct vmap_area *va;
>  
> -	might_sleep();
> -
>  	va = find_vmap_area((unsigned long)addr);
>  	if (va && va->flags & VM_VM_AREA) {
>  		struct vm_struct *vm = va->vm;
> -- 
> 2.10.2
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
