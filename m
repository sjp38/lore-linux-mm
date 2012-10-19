Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id E7F7F6B0075
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 03:05:44 -0400 (EDT)
Date: Fri, 19 Oct 2012 09:05:37 +0200
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: mm/mmu_notifier: inconsistent lock state in
 mmu_notifier_register()
Message-ID: <20121019070537.GA2014@thinkpad>
References: <20121017215338.GA3577@thinkpad>
 <20121018122416.GA29797@shangw.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121018122416.GA29797@shangw.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 18, 2012 at 08:24:17PM +0800, Gavin Shan wrote:
> Hi Andrea,
> 
> Do you have chance to have a try on the attached patch?
> 
> Thanks,
> Gavin

Gavin, the patch looks good to me and I confirm that the lockdep splat
disappeared with it. Feel free to add my:

Tested-by: Andrea Righi <andrea@betterlinux.com>

Thanks,
-Andrea

> 
> On Wed, Oct 17, 2012 at 11:53:38PM +0200, Andrea Righi wrote:
> >Just got this on 3.7.0-rc1 (last git commit 1867353):
> >
> >[49048.262912] =================================
> >[49048.262913] [ INFO: inconsistent lock state ]
> >[49048.262916] 3.7.0-rc1+ #518 Not tainted
> >[49048.262918] ---------------------------------
> >[49048.262919] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
> >[49048.262922] kswapd0/35 [HC0[0]:SC0[0]:HE1:SE1] takes:
> >[49048.262924]  (&mapping->i_mmap_mutex){+.+.?.}, at: [<ffffffff81192fbc>] page_referenced+0x9c/0x2e0
> >[49048.262933] {RECLAIM_FS-ON-W} state was registered at:
> >[49048.262935]   [<ffffffff810ed5d6>] mark_held_locks+0x86/0x150
> >[49048.262938]   [<ffffffff810edce7>] lockdep_trace_alloc+0x67/0xc0
> >[49048.262942]   [<ffffffff811a9323>] kmem_cache_alloc_trace+0x33/0x230
> >[49048.262945]   [<ffffffff811a1a27>] do_mmu_notifier_register+0x87/0x180
> >[49048.262948]   [<ffffffff811a1b53>] mmu_notifier_register+0x13/0x20
> >[49048.262951]   [<ffffffff81006738>] kvm_dev_ioctl+0x428/0x510
> >[49048.262955]   [<ffffffff811c7ce8>] do_vfs_ioctl+0x98/0x570
> >[49048.262959]   [<ffffffff811c8251>] sys_ioctl+0x91/0xb0
> >[49048.262962]   [<ffffffff815df302>] system_call_fastpath+0x16/0x1b
> >[49048.262966] irq event stamp: 825
> >[49048.262968] hardirqs last  enabled at (825): [<ffffffff815d6fa0>] _raw_spin_unlock_irq+0x30/0x60
> >[49048.262971] hardirqs last disabled at (824): [<ffffffff815d6659>] _raw_spin_lock_irq+0x19/0x80
> >[49048.262975] softirqs last  enabled at (0): [<ffffffff81082170>] copy_process+0x630/0x17c0
> >[49048.262979] softirqs last disabled at (0): [<          (null)>]           (null)
> >[49048.262981] 
> >[49048.262981] other info that might help us debug this:
> >[49048.262983]  Possible unsafe locking scenario:
> >[49048.262983] 
> >[49048.262984]        CPU0
> >[49048.262986]        ----
> >[49048.262987]   lock(&mapping->i_mmap_mutex);
> >[49048.262989]   <Interrupt>
> >[49048.262991]     lock(&mapping->i_mmap_mutex);
> >[49048.262993] 
> >[49048.262993]  *** DEADLOCK ***
> >[49048.262993] 
> >[49048.262995] no locks held by kswapd0/35.
> >[49048.262996] 
> >[49048.262996] stack backtrace:
> >[49048.262999] Pid: 35, comm: kswapd0 Not tainted 3.7.0-rc1+ #518
> >[49048.263000] Call Trace:
> >[49048.263005]  [<ffffffff815cd988>] print_usage_bug+0x1f5/0x206
> >[49048.263008]  [<ffffffff8105a21f>] ? save_stack_trace+0x2f/0x50
> >[49048.263011]  [<ffffffff810ea865>] mark_lock+0x295/0x2f0
> >[49048.263014]  [<ffffffff810e9c70>] ? print_irq_inversion_bug.part.42+0x1f0/0x1f0
> >[49048.263017]  [<ffffffff810eae5d>] __lock_acquire+0x59d/0x1c20
> >[49048.263020]  [<ffffffff815cf163>] ? put_cpu_partial+0x65/0xbd
> >[49048.263024]  [<ffffffff81052d06>] ? native_sched_clock+0x26/0x90
> >[49048.263028]  [<ffffffff810c5555>] ? sched_clock_cpu+0xc5/0x120
> >[49048.263031]  [<ffffffff810ecbe0>] lock_acquire+0x90/0x210
> >[49048.263034]  [<ffffffff81192fbc>] ? page_referenced+0x9c/0x2e0
> >[49048.263038]  [<ffffffff815d2ea3>] mutex_lock_nested+0x73/0x3d0
> >[49048.263041]  [<ffffffff81192fbc>] ? page_referenced+0x9c/0x2e0
> >[49048.263044]  [<ffffffff81192fbc>] ? page_referenced+0x9c/0x2e0
> >[49048.263047]  [<ffffffff810e764e>] ? put_lock_stats.isra.26+0xe/0x40
> >[49048.263051]  [<ffffffff810e7a84>] ? lock_release_holdtime.part.27+0xd4/0x150
> >[49048.263055]  [<ffffffff8116edab>] ? __remove_mapping+0xab/0x120
> >[49048.263058]  [<ffffffff81192fbc>] page_referenced+0x9c/0x2e0
> >[49048.263061]  [<ffffffff81171b94>] shrink_page_list+0x3e4/0xa20
> >[49048.263064]  [<ffffffff81052d06>] ? native_sched_clock+0x26/0x90
> >[49048.263068]  [<ffffffff811726f5>] ? shrink_inactive_list+0x165/0x4b0
> >[49048.263071]  [<ffffffff815d6fa0>] ? _raw_spin_unlock_irq+0x30/0x60
> >[49048.263075]  [<ffffffff81172787>] shrink_inactive_list+0x1f7/0x4b0
> >[49048.263079]  [<ffffffff81172e8d>] shrink_lruvec+0x44d/0x550
> >[49048.263082]  [<ffffffff81173693>] kswapd+0x703/0xdf0
> >[49048.263086]  [<ffffffff810af470>] ? __init_waitqueue_head+0x60/0x60
> >[49048.263090]  [<ffffffff81172f90>] ? shrink_lruvec+0x550/0x550
> >[49048.263093]  [<ffffffff810ae98d>] kthread+0xed/0x100
> >[49048.263097]  [<ffffffff810ae8a0>] ? flush_kthread_worker+0x190/0x190
> >[49048.263100]  [<ffffffff815df25c>] ret_from_fork+0x7c/0xb0
> >[49048.263103]  [<ffffffff810ae8a0>] ? flush_kthread_worker+0x190/0x190
> >
> >Should we use a GFP_NOFS allocation in mmu_notifier_register() or is
> >there a better way to fix/avoid this?
> >
> >Thanks,
> >-Andrea
> >
> >--
> >To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >the body to majordomo@kvack.org.  For more info on Linux MM,
> >see: http://www.linux-mm.org/ .
> >Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >

> >From 8b7dcc6afd617e8b52ed1b10221195cce0c8f442 Mon Sep 17 00:00:00 2001
> From: Gavin Shan <shangw@linux.vnet.ibm.com>
> Date: Thu, 18 Oct 2012 20:14:06 +0800
> Subject: [PATCH] mm/mmu_notifier: allocate mmu_notifier in advance
> 
> While allocating mmu_notifier with parameter GFP_KERNEL, swap would
> start to work in case of tight available memory. Eventually, that
> would lead to dead-lock while swap deamon does swapping anonymous
> pages. It was caused by commit e0f3c3f78da29b114e7c1c68019036559f715948
> ("mm/mmu_notifier: init notifier if necessary").
> 
> The patch simply back out the above commit.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> ---
>  mm/mmu_notifier.c |   26 +++++++++++++-------------
>  1 files changed, 13 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index 479a1e7..8a5ac8c 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -196,28 +196,28 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
>  	BUG_ON(atomic_read(&mm->mm_users) <= 0);
>  
>  	/*
> -	* Verify that mmu_notifier_init() already run and the global srcu is
> -	* initialized.
> -	*/
> +	 * Verify that mmu_notifier_init() already run and the global srcu is
> +	 * initialized.
> +	 */
>  	BUG_ON(!srcu.per_cpu_ref);
>  
> +	ret = -ENOMEM;
> +	mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm), GFP_KERNEL);
> +	if (unlikely(!mmu_notifier_mm))
> +		goto out;
> +
>  	if (take_mmap_sem)
>  		down_write(&mm->mmap_sem);
>  	ret = mm_take_all_locks(mm);
>  	if (unlikely(ret))
> -		goto out;
> +		goto out_clean;
>  
>  	if (!mm_has_notifiers(mm)) {
> -		mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm),
> -					GFP_KERNEL);
> -		if (unlikely(!mmu_notifier_mm)) {
> -			ret = -ENOMEM;
> -			goto out_of_mem;
> -		}
>  		INIT_HLIST_HEAD(&mmu_notifier_mm->list);
>  		spin_lock_init(&mmu_notifier_mm->lock);
>  
>  		mm->mmu_notifier_mm = mmu_notifier_mm;
> +		mmu_notifier_mm = NULL;
>  	}
>  	atomic_inc(&mm->mm_count);
>  
> @@ -233,12 +233,12 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
>  	hlist_add_head(&mn->hlist, &mm->mmu_notifier_mm->list);
>  	spin_unlock(&mm->mmu_notifier_mm->lock);
>  
> -out_of_mem:
>  	mm_drop_all_locks(mm);
> -out:
> +out_clean:
>  	if (take_mmap_sem)
>  		up_write(&mm->mmap_sem);
> -
> +	kfree(mmu_notifier_mm);
> +out:
>  	BUG_ON(atomic_read(&mm->mm_users) <= 0);
>  	return ret;
>  }
> -- 
> 1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
