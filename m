Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C87E6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 07:34:53 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o123so8793910pga.16
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 04:34:53 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0132.outbound.protection.outlook.com. [104.47.2.132])
        by mx.google.com with ESMTPS id b21si4050193pgi.115.2017.03.29.04.34.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 04:34:51 -0700 (PDT)
Subject: Re: [PATCH v3] mm: Allow calling vfree() from non-schedulable
 context.
References: <1490784712-4991-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <0065385b-8cf9-aec6-22bb-9e6d21501a8c@virtuozzo.com>
Date: Wed, 29 Mar 2017 14:36:10 +0300
MIME-Version: 1.0
In-Reply-To: <1490784712-4991-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Chris Wilson <chris@chris-wilson.co.uk>, Christoph Hellwig <hch@lst.de>, Ingo Molnar <mingo@elte.hu>, Jisheng Zhang <jszhang@marvell.com>, Joel Fernandes <joelaf@google.com>, John Dias <joaodias@google.com>, Matthew Wilcox <willy@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On 03/29/2017 01:51 PM, Tetsuo Handa wrote:

> But these commits did not take appropriate precautions for changing
> non-sleeping API to sleeping API. Only two callers are updated to use
> non-sleeping version, and remaining callers are silently using sleeping
> version which might cause problems. For example, if we try
> 
> ----------
>  void kvfree(const void *addr)
>  {
> +	/* Detect errors before kvmalloc() falls back to vmalloc(). */
> +	if (addr) {
> +		WARN_ON(in_nmi());
> +		if (likely(!in_interrupt()))
> +			might_sleep();
> +	}
>  	if (is_vmalloc_addr(addr))
>  		vfree(addr);
>  	else
> ----------
> 
> change, we can find a caller who is calling kvfree() with a spinlock held.
> 

Frankly speaking this call trace shouldn't be a real problem because xfs_extent_busy_clear_one()
frees 'struct xfs_extent_busy' which is small so we never go into vfree() here.



> [   23.635540] BUG: sleeping function called from invalid context at mm/util.c:338
> [   23.638701] in_atomic(): 1, irqs_disabled(): 0, pid: 478, name: kworker/0:1H
> [   23.641516] 3 locks held by kworker/0:1H/478:
> [   23.643476]  #0:  ("xfs-log/%s"mp->m_fsname){.+.+..}, at: [<ffffffffb20d1e64>] process_one_work+0x194/0x6c0
> [   23.647176]  #1:  ((&bp->b_ioend_work)){+.+...}, at: [<ffffffffb20d1e64>] process_one_work+0x194/0x6c0
> [   23.650939]  #2:  (&(&pag->pagb_lock)->rlock){+.+...}, at: [<ffffffffc02b42ee>] xfs_extent_busy_clear+0x9e/0xe0 [xfs]
> [   23.655132] CPU: 0 PID: 478 Comm: kworker/0:1H Not tainted 4.11.0-rc4+ #212
> [   23.657974] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> [   23.662041] Workqueue: xfs-log/sda1 xfs_buf_ioend_work [xfs]
> [   23.664463] Call Trace:
> [   23.665866]  dump_stack+0x85/0xc9
> [   23.667538]  ___might_sleep+0x184/0x250
> [   23.669371]  __might_sleep+0x4a/0x90
> [   23.671137]  kvfree+0x41/0x90
> [   23.672748]  xfs_extent_busy_clear_one+0x51/0x190 [xfs]
> [   23.675110]  xfs_extent_busy_clear+0xbb/0xe0 [xfs]
> [   23.677278]  xlog_cil_committed+0x241/0x420 [xfs]
> [   23.679431]  xlog_state_do_callback+0x170/0x2d0 [xfs]
> [   23.681717]  xlog_state_done_syncing+0x7f/0xa0 [xfs]
> [   23.683971]  ? xfs_buf_ioend_work+0x15/0x20 [xfs]
> [   23.686112]  xlog_iodone+0x86/0xc0 [xfs]
> [   23.688007]  xfs_buf_ioend+0xd3/0x440 [xfs]
> [   23.689999]  xfs_buf_ioend_work+0x15/0x20 [xfs]
> [   23.692060]  process_one_work+0x21c/0x6c0



> ---
>  mm/vmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 0b05762..36334ff 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1589,7 +1589,7 @@ void vfree(const void *addr)
>  
>  	if (!addr)
>  		return;
> -	if (unlikely(in_interrupt()))
> +	if (!preemptible() || rcu_preempt_depth())

!preemptible() basically means that we always defer vfree() in non-preemptimble kernel. I'm not sure
if this is a good idea. Also I have no idea what is this rcu_preempt_depth() for and nothing explains it.

So I just get a better idea. How about just always deferring __purge_vmap_area_lazy()?


diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 68eb002..a02a250 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -701,7 +701,7 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
  * Kick off a purge of the outstanding lazy areas. Don't bother if somebody
  * is already purging.
  */
-static void try_purge_vmap_area_lazy(void)
+static void try_purge_vmap_area_lazy(struct work_struct *work)
 {
        if (mutex_trylock(&vmap_purge_lock)) {
                __purge_vmap_area_lazy(ULONG_MAX, 0);
@@ -720,6 +720,8 @@ static void purge_vmap_area_lazy(void)
        mutex_unlock(&vmap_purge_lock);
 }
 
+static DECLARE_WORK(purge_vmap_work, try_purge_vmap_area_lazy);
+
 /*
  * Free a vmap area, caller ensuring that the area has been unmapped
  * and flush_cache_vunmap had been called for the correct range
@@ -735,8 +737,9 @@ static void free_vmap_area_noflush(struct vmap_area *va)
        /* After this point, we may free va at any time */
        llist_add(&va->purge_list, &vmap_purge_list);
 
-       if (unlikely(nr_lazy > lazy_max_pages()))
-               try_purge_vmap_area_lazy();
+       if (unlikely(nr_lazy > lazy_max_pages())
+           && !work_pending(&purge_vmap_work))
+               schedule_work(&purge_vmap_work);
 }
 
 /*
@@ -1125,7 +1128,6 @@ void vm_unmap_ram(const void *mem, unsigned int count)
        unsigned long addr = (unsigned long)mem;
        struct vmap_area *va;
 
-       might_sleep();
        BUG_ON(!addr);
        BUG_ON(addr < VMALLOC_START);
        BUG_ON(addr > VMALLOC_END);
@@ -1477,8 +1479,6 @@ struct vm_struct *remove_vm_area(const void *addr)
 {
        struct vmap_area *va;
 
-       might_sleep();
-
        va = find_vmap_area((unsigned long)addr);
        if (va && va->flags & VM_VM_AREA) {
                struct vm_struct *vm = va->vm;

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
