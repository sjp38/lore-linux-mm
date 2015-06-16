Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7632D6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 04:44:30 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so8639322pac.2
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 01:44:30 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ni1si515886pdb.6.2015.06.16.01.44.28
        for <linux-mm@kvack.org>;
        Tue, 16 Jun 2015 01:44:29 -0700 (PDT)
Date: Tue, 16 Jun 2015 09:44:24 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC NEXT] mm: Fix suspicious RCU usage at
 kernel/sched/core.c:7318
Message-ID: <20150616084424.GE21229@e104818-lin.cambridge.arm.com>
References: <1434403518-5308-1-git-send-email-Larry.Finger@lwfinger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434403518-5308-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Tejun Heo <tj@kernel.org>, Martin KaFai Lau <kafai@fb.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jun 15, 2015 at 10:25:18PM +0100, Larry Finger wrote:
> Beginning at commit d52d399, the following INFO splat is logged:
> 
> [    2.816564] ===============================
> [    2.816986] [ INFO: suspicious RCU usage. ]
> [    2.817402] 4.1.0-rc7-next-20150612 #1 Not tainted
> [    2.817881] -------------------------------
> [    2.818297] kernel/sched/core.c:7318 Illegal context switch in RCU-bh read-side critical section!
> [    2.819180]
> other info that might help us debug this:
> 
> [    2.819947]
> rcu_scheduler_active = 1, debug_locks = 0
> [    2.820578] 3 locks held by systemd/1:
> [    2.820954]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff815f0c8f>] rtnetlink_rcv+0x1f/0x40
> [    2.821855]  #1:  (rcu_read_lock_bh){......}, at: [<ffffffff816a34e2>] ipv6_add_addr+0x62/0x540
> [    2.822808]  #2:  (addrconf_hash_lock){+...+.}, at: [<ffffffff816a3604>] ipv6_add_addr+0x184/0x540
> [    2.823790]
> stack backtrace:
> [    2.824212] CPU: 0 PID: 1 Comm: systemd Not tainted 4.1.0-rc7-next-20150612 #1
> [    2.824932] Hardware name: TOSHIBA TECRA A50-A/TECRA A50-A, BIOS Version 4.20   04/17/2014
> [    2.825751]  0000000000000001 ffff880224e07838 ffffffff817263a4 ffffffff810ccf2a
> [    2.826560]  ffff880224e08000 ffff880224e07868 ffffffff810b6827 0000000000000000
> [    2.827368]  ffffffff81a445d3 00000000000004f4 ffff88022682e100 ffff880224e07898
> [    2.828177] Call Trace:
> [    2.828422]  [<ffffffff817263a4>] dump_stack+0x4c/0x6e
> [    2.828937]  [<ffffffff810ccf2a>] ? console_unlock+0x1ca/0x510
> [    2.829514]  [<ffffffff810b6827>] lockdep_rcu_suspicious+0xe7/0x120
> [    2.830139]  [<ffffffff8108cf05>] ___might_sleep+0x1d5/0x1f0
> [    2.830699]  [<ffffffff8108cf6d>] __might_sleep+0x4d/0x90
> [    2.831239]  [<ffffffff811f3789>] ? create_object+0x39/0x2e0
> [    2.831800]  [<ffffffff811da427>] kmem_cache_alloc+0x47/0x250
> [    2.832375]  [<ffffffff813c19ae>] ? find_next_zero_bit+0x1e/0x20
> [    2.832973]  [<ffffffff811f3789>] create_object+0x39/0x2e0
> [    2.833515]  [<ffffffff810b7eb6>] ? mark_held_locks+0x66/0x90
> [    2.834089]  [<ffffffff8172efab>] ? _raw_spin_unlock_irqrestore+0x4b/0x60
> [    2.834761]  [<ffffffff817193c1>] kmemleak_alloc_percpu+0x61/0xe0
> [    2.835369]  [<ffffffff811a26f0>] pcpu_alloc+0x370/0x630
> 
> Additional backtrace lines are truncated. In addition, the above splat is
> followed by several "BUG: sleeping function called from invalid context
> at mm/slub.c:1268" outputs. As suggested by Martin KaFai Lau, these are the
> clue to the fix. Routine kmemleak_alloc_percpu() always uses GFP_KERNEL
> for its allocations, whereas it should use the value input to pcpu_alloc().
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Martin KaFai Lau <kafai@fb.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> To: Tejun Heo <tj@kernel.org>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> ---
>  include/linux/kmemleak.h |  3 ++-
>  mm/kmemleak.c            |  9 +++++----
>  mm/kmemleak.c.rej        | 19 +++++++++++++++++++
>  mm/percpu.c              |  2 +-

As Kamalesh already pointed out, you added the mm/kmemleak.c.rej file to
this patch.

> diff --git a/include/linux/kmemleak.h b/include/linux/kmemleak.h
> index e705467..ec4437b 100644
> --- a/include/linux/kmemleak.h
> +++ b/include/linux/kmemleak.h
> @@ -28,7 +28,8 @@
>  extern void kmemleak_init(void) __ref;
>  extern void kmemleak_alloc(const void *ptr, size_t size, int min_count,
>  			   gfp_t gfp) __ref;
> -extern void kmemleak_alloc_percpu(const void __percpu *ptr, size_t size) __ref;
> +extern void kmemleak_alloc_percpu(const void __percpu *ptr, size_t size,
> +				  gfp_t gfp) __ref;
>  extern void kmemleak_free(const void *ptr) __ref;
>  extern void kmemleak_free_part(const void *ptr, size_t size) __ref;
>  extern void kmemleak_free_percpu(const void __percpu *ptr) __ref;
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index ca9e5a5..b5f5129 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -930,12 +930,13 @@ EXPORT_SYMBOL_GPL(kmemleak_alloc);
>   * kmemleak_alloc_percpu - register a newly allocated __percpu object
>   * @ptr:	__percpu pointer to beginning of the object
>   * @size:	size of the object
> + * @gfp:	kmalloc() flags used for kmemleak internal memory allocations

Nitpick: since this is triggered by percpu_alloc_gfp(), I would just
remove the "kmalloc()" here.

>   *
>   * This function is called from the kernel percpu allocator when a new object
> - * (memory block) is allocated (alloc_percpu). It assumes GFP_KERNEL
> - * allocation.
> + * (memory block) is allocated (alloc_percpu).
>   */
> -void __ref kmemleak_alloc_percpu(const void __percpu *ptr, size_t size)
> +void __ref kmemleak_alloc_percpu(const void __percpu *ptr, size_t size,
> +				 gfp_t gfp)
>  {
>  	unsigned int cpu;
>  
> @@ -948,7 +949,7 @@ void __ref kmemleak_alloc_percpu(const void __percpu *ptr, size_t size)
>  	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
>  		for_each_possible_cpu(cpu)
>  			create_object((unsigned long)per_cpu_ptr(ptr, cpu),
> -				      size, 0, GFP_KERNEL);
> +				      size, 0, gfp);
>  	else if (kmemleak_early_log)
>  		log_early(KMEMLEAK_ALLOC_PERCPU, ptr, size, 0);
>  }
[... mm/kmemleak.c.rej removed ...]
> diff --git a/mm/percpu.c b/mm/percpu.c
> index dfd0248..2dd7448 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -1030,7 +1030,7 @@ area_found:
>  		memset((void *)pcpu_chunk_addr(chunk, cpu, 0) + off, 0, size);
>  
>  	ptr = __addr_to_pcpu_ptr(chunk->base_addr + off);
> -	kmemleak_alloc_percpu(ptr, size);
> +	kmemleak_alloc_percpu(ptr, size, gfp);
>  	return ptr;
>  
>  fail_unlock:

Apart from the minor comment above (and the kmemleak.c.rej file):

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
