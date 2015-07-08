Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 77ACF6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 11:25:14 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so15982368pdr.2
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 08:25:14 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id pa10si4639482pdb.114.2015.07.08.08.25.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 08:25:13 -0700 (PDT)
Date: Wed, 8 Jul 2015 17:25:07 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [mm: meminit]  WARNING: CPU: 1 PID: 15 at
 kernel/locking/lockdep.c:3382 lock_release()
Message-ID: <20150708152507.GG12596@twins.programming.kicks-ass.net>
References: <559be1ee.oKzhDxqT1ZZpBUZm%fengguang.wu@intel.com>
 <20150708103213.GO6812@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150708103213.GO6812@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: kernel test robot <fengguang.wu@intel.com>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nicolai Stange <nicstange@gmail.com>

On Wed, Jul 08, 2015 at 11:32:13AM +0100, Mel Gorman wrote:
> From: Nicolai Stange <nicstange@gmail.com>
> Subject: Re: [PATCH] mm/page_alloc: deferred meminit: replace rwsem with completion
> 
> Commit 0e1cc95b4cc7
>   ("mm: meminit: finish initialisation of struct pages before basic setup")
> introduced a rwsem to signal completion of the initialization workers.
> 
> Lockdep complains about possible recursive locking:
>   =============================================
>   [ INFO: possible recursive locking detected ]
>   4.1.0-12802-g1dc51b8 #3 Not tainted
>   ---------------------------------------------
>   swapper/0/1 is trying to acquire lock:
>   (pgdat_init_rwsem){++++.+},
>     at: [<ffffffff8424c7fb>] page_alloc_init_late+0xc7/0xe6
> 
>   but task is already holding lock:
>   (pgdat_init_rwsem){++++.+},
>     at: [<ffffffff8424c772>] page_alloc_init_late+0x3e/0xe6
> 
> Replace the rwsem by a completion together with an atomic
> "outstanding work counter".
> 
> Signed-off-by: Nicolai Stange <nicstange@gmail.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/page_alloc.c | 34 +++++++++++++++++++++++++++-------
>  1 file changed, 27 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 506eac8..3886e66 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -18,7 +18,9 @@
>  #include <linux/mm.h>
>  #include <linux/swap.h>
>  #include <linux/interrupt.h>
> -#include <linux/rwsem.h>
> +#include <linux/completion.h>
> +#include <linux/atomic.h>
> +#include <asm/barrier.h>
>  #include <linux/pagemap.h>
>  #include <linux/jiffies.h>
>  #include <linux/bootmem.h>
> @@ -1062,7 +1064,20 @@ static void __init deferred_free_range(struct page *page,
>  		__free_pages_boot_core(page, pfn, 0);
>  }
>  
> -static __initdata DECLARE_RWSEM(pgdat_init_rwsem);
> +/* counter and completion tracking outstanding deferred_init_memmap()
> +   threads */

Wrong comment style.

> +static atomic_t pgdat_init_n_undone __initdata;
> +static __initdata DECLARE_COMPLETION(pgdat_init_all_done_comp);
> +
> +static inline void __init pgdat_init_report_one_done(void)
> +{
> +	/* Write barrier is paired with read barrier in
> +	   page_alloc_init_late(). It makes all writes visible to
> +	   readers seeing our decrement on pgdat_init_n_undone. */

Wrong comment style.

> +	smp_wmb();

Pointless barrier, because

> +	if (atomic_dec_and_test(&pgdat_init_n_undone))

implies a full memory barrier, furthermore see below.

> +		complete(&pgdat_init_all_done_comp);
> +}
>  
>  /* Initialise remaining memory on a node */
>  static int __init deferred_init_memmap(void *data)


> @@ -1187,14 +1203,18 @@ void __init page_alloc_init_late(void)
>  {
>  	int nid;
>  
> +	/* There will be num_node_state(N_MEMORY) threads */
> +	atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
>  	for_each_node_state(nid, N_MEMORY) {
> -		down_read(&pgdat_init_rwsem);
>  		kthread_run(deferred_init_memmap, NODE_DATA(nid), "pgdatinit%d", nid);
>  	}
>  
>  	/* Block until all are initialised */
> -	down_write(&pgdat_init_rwsem);
> -	up_write(&pgdat_init_rwsem);
> +	wait_for_completion(&pgdat_init_all_done_comp);
> +
> +	/* Paired with write barrier in deferred_init_memmap(),
> +	   ensures a consistent view of all its writes. */

Wrong comment style

> +	smp_rmb();

Wrong barrier, IF you want a barrier it should be before
wait_for_completion, such that if you observe complete, you then must
also observe whatever happened prior to the completion.

But I would argue a completion had better imply that anyway.

>  }
>  #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
