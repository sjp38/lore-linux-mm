Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A7E5C6B02A3
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 17:02:05 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id t23so2344584ply.21
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 14:02:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bc8-v6sor6972plb.22.2018.02.06.14.02.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Feb 2018 14:02:04 -0800 (PST)
Date: Tue, 6 Feb 2018 14:01:59 -0800
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RFC] ashmem: Fix lockdep RECLAIM_FS false positive
Message-ID: <20180206220159.GA9680@eng-minchan1.roam.corp.google.com>
References: <20180206004903.224390-1-joelaf@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180206004903.224390-1-joelaf@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: linux-kernel@vger.kernel.org, Peter Zilstra <peterz@infradead.org>, mhocko@kernel.org, linux-mm@kvack.org

Hi Joel,

On Mon, Feb 05, 2018 at 04:49:03PM -0800, Joel Fernandes wrote:
> During invocation of ashmem shrinker under memory pressure, ashmem
> calls into VFS code via vfs_fallocate. We however make sure we
> don't enter it if the allocation was GFP_FS to prevent looping
> into filesystem code. However lockdep doesn't know this and prints
> a lockdep splat as below.
> 
> This patch fixes the issue by releasing the reclaim_fs lock after
> checking for GFP_FS but before calling into the VFS path, and
> reacquiring it after so that lockdep can continue reporting any
> reclaim issues later.

At first glance, it looks reasonable. However, Couldn't we return
just 0 in ashmem_shrink_count when the context is under FS?

> 
> [ 2115.359650] -(1)[106:kswapd0]=================================
> [ 2115.359665] -(1)[106:kswapd0][ INFO: inconsistent lock state ]
> [ 2115.359684] -(1)[106:kswapd0]4.9.60+ #2 Tainted: G        W  O
> [ 2115.359699] -(1)[106:kswapd0]---------------------------------
> [ 2115.359715] -(1)[106:kswapd0]inconsistent {RECLAIM_FS-ON-W} ->
> {IN-RECLAIM_FS-W} usage.
> [ 2115.359732] -(1)[106:kswapd0]kswapd0/106 [HC0[0]:SC0[0]:HE1:SE1]
> takes:
> [ 2115.359748] (&sb->s_type->i_mutex_key#9){++++?+}, at:
> [<ffffff9008470644>] shmem_fallocate+0x104/0x880
> [ 2115.359809] -(1)[106:kswapd0]{RECLAIM_FS-ON-W} state was registered
> at:
> [ 2115.359828] -(1)[106:kswapd0]  mark_lock+0x2a4/0x10c0
> [ 2115.359845] -(1)[106:kswapd0]  mark_held_locks+0xc0/0x128
> [ 2115.359862] -(1)[106:kswapd0]  lockdep_trace_alloc+0x284/0x368
> [ 2115.359881] -(1)[106:kswapd0]  kmem_cache_alloc+0x3c/0x368
> [ 2115.359900] -(1)[106:kswapd0]  __d_alloc+0x3c/0x7a8
> [ 2115.359917] -(1)[106:kswapd0]  d_alloc+0x34/0x140
> [ 2115.359934] -(1)[106:kswapd0]  d_alloc_parallel+0xfc/0x1480
> [ 2115.359953] -(1)[106:kswapd0]  lookup_open+0x3c4/0x12a8
> [ 2115.359971] -(1)[106:kswapd0]  path_openat+0xb40/0x1dc0
> [ 2115.359987] -(1)[106:kswapd0]  do_filp_open+0x170/0x258
> [ 2115.360006] -(1)[106:kswapd0]  do_sys_open+0x1b8/0x2f0
> [ 2115.360023] -(1)[106:kswapd0]  SyS_openat+0x10/0x18
> [ 2115.360041] -(1)[106:kswapd0]  el0_svc_naked+0x24/0x28
> [ 2115.360056] -(1)[106:kswapd0]irq event stamp: 2437365
> [ 2115.360079] -(1)[106:kswapd0]hardirqs last  enabled at (2437365):
> [<ffffff900a0ec6ec>] mutex_trylock+0x224/0x460
> [ 2115.360098] -(1)[106:kswapd0]hardirqs last disabled at (2437364):
> [<ffffff900a0ec5b0>] mutex_trylock+0xe8/0x460
> [ 2115.360116] -(1)[106:kswapd0]softirqs last  enabled at (2436534):
> [<ffffff90080822a0>] __do_softirq+0xc38/0x1190
> [ 2115.360138] -(1)[106:kswapd0]softirqs last disabled at (2436515):
> [<ffffff90080de05c>] irq_exit+0x1ac/0x228
> [ 2115.360153] -(1)[106:kswapd0]\x0aother info that might help us debug
> this:
> [ 2115.360169] -(1)[106:kswapd0] Possible unsafe locking scenario:\x0a
> [ 2115.360184] -(1)[106:kswapd0]       CPU0
> [ 2115.360198] -(1)[106:kswapd0]       ----
> [ 2115.360211] -(1)[106:kswapd0]  lock(&sb->s_type->i_mutex_key#9);
> [ 2115.360252] -(1)[106:kswapd0]  <Interrupt>
> [ 2115.360265] -(1)[106:kswapd0]    lock(&sb->s_type->i_mutex_key#9);
> [ 2115.360304] -(1)[106:kswapd0]\x0a *** DEADLOCK ***\x0a
> [ 2115.360322] -(1)[106:kswapd0] #0:  (shrinker_rwsem){++++..}, at:
> [<ffffff9008459e08>] shrink_slab.part.15.constprop.28+0xb0/0xe10
> [ 2115.360382] -(1)[106:kswapd0] #1:  (ashmem_mutex){+.+.+.}, at:
> [<ffffff90098c4ba0>] ashmem_shrink_scan+0x80/0x308
> [ 2115.360439] -(1)[106:kswapd0]\x0astack backtrace:
> [ 2115.360462] -(1)[106:kswapd0]CPU: 1 PID: 106 Comm: kswapd0 Tainted: G
> W  O    4.9.60+ #2
> [ 2115.360478] -(1)[106:kswapd0]Hardware name: MT6765 (DT)
> [ 2115.360494] -(1)[106:kswapd0]Call trace:
> [ 2115.360515] -(1)[106:kswapd0][<ffffff9008092938>]
> dump_backtrace+0x0/0x400
> [ 2115.360533] -(1)[106:kswapd0][<ffffff900809302c>]
> show_stack+0x14/0x20
> [ 2115.360555] -(1)[106:kswapd0][<ffffff9008988bc0>]
> dump_stack+0xb0/0xe8
> [ 2115.360576] -(1)[106:kswapd0][<ffffff900841e8b0>]
> print_usage_bug.part.24+0x548/0x568
> [ 2115.360595] -(1)[106:kswapd0][<ffffff90082398bc>]
> mark_lock+0x494/0x10c0
> [ 2115.360613] -(1)[106:kswapd0][<ffffff900823bf1c>]
> __lock_acquire+0xc94/0x58e8
> [ 2115.360630] -(1)[106:kswapd0][<ffffff9008241ba0>]
> lock_acquire+0x1d0/0x708
> [ 2115.360650] -(1)[106:kswapd0][<ffffff900a0f27a8>]
> down_write+0x48/0xd0
> [ 2115.360669] -(1)[106:kswapd0][<ffffff9008470644>]
> shmem_fallocate+0x104/0x880
> [ 2115.360688] -(1)[106:kswapd0][<ffffff90098c4cc4>]
> ashmem_shrink_scan+0x1a4/0x308
> [ 2115.360709] -(1)[106:kswapd0][<ffffff900845a088>]
> shrink_slab.part.15.constprop.28+0x330/0xe10
> [ 2115.360729] -(1)[106:kswapd0][<ffffff9008463b34>]
> shrink_node+0x1b4/0x588
> [ 2115.360747] -(1)[106:kswapd0][<ffffff90084655f4>] kswapd+0x774/0x1640
> [ 2115.360767] -(1)[106:kswapd0][<ffffff9008128a4c>] kthread+0x28c/0x310
> [ 2115.360786] -(1)[106:kswapd0][<ffffff9008083f00>]
> ret_from_fork+0x10/0x50
> 
> Cc: Peter Zilstra <peterz@infradead.org>
> Cc: mhocko@kernel.org
> Cc: minchan@kernel.org
> Cc: linux-mm@kvack.org
> Signed-off-by: Joel Fernandes <joelaf@google.com>
> ---
>  drivers/staging/android/ashmem.c | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
> index 372ce9913e6d..7e060f32aaa8 100644
> --- a/drivers/staging/android/ashmem.c
> +++ b/drivers/staging/android/ashmem.c
> @@ -32,6 +32,7 @@
>  #include <linux/bitops.h>
>  #include <linux/mutex.h>
>  #include <linux/shmem_fs.h>
> +#include <linux/sched/mm.h>
>  #include "ashmem.h"
>  
>  #define ASHMEM_NAME_PREFIX "dev/ashmem/"
> @@ -446,8 +447,17 @@ ashmem_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>  	if (!(sc->gfp_mask & __GFP_FS))
>  		return SHRINK_STOP;
>  
> -	if (!mutex_trylock(&ashmem_mutex))
> +	/*
> +	 * Release reclaim-fs marking since we've already checked GFP_FS, This
> +	 * will prevent lockdep's reclaim recursion deadlock false positives.
> +	 * We'll renable it before returning from this function.
> +	 */
> +	fs_reclaim_release(sc->gfp_mask);
> +
> +	if (!mutex_trylock(&ashmem_mutex)) {
> +		fs_reclaim_acquire(sc->gfp_mask);
>  		return -1;
> +	}
>  
>  	list_for_each_entry_safe(range, next, &ashmem_lru_list, lru) {
>  		loff_t start = range->pgstart * PAGE_SIZE;
> @@ -464,6 +474,8 @@ ashmem_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>  			break;
>  	}
>  	mutex_unlock(&ashmem_mutex);
> +
> +	fs_reclaim_acquire(sc->gfp_mask);
>  	return freed;
>  }
>  
> -- 
> 2.16.0.rc1.238.g530d649a79-goog
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
