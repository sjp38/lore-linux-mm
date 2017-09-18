Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 713A26B0033
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 15:27:17 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i50so1534872qtf.0
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 12:27:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w198sor3377019qkw.158.2017.09.18.12.27.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Sep 2017 12:27:16 -0700 (PDT)
Date: Mon, 18 Sep 2017 15:27:14 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH] mm: memcontrol: use vmalloc fallback for large kmem
 memcg arrays
Message-ID: <20170918192713.6b333yiolkrc7ofo@destiny>
References: <20170918184919.20644-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918184919.20644-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Sep 18, 2017 at 02:49:19PM -0400, Johannes Weiner wrote:
> For quick per-memcg indexing, slab caches and list_lru structures
> maintain linear arrays of descriptors. As the number of concurrent
> memory cgroups in the system goes up, this requires large contiguous
> allocations (8k cgroups = order-5, 16k cgroups = order-6 etc.) for
> every existing slab cache and list_lru, which can easily fail on
> loaded systems. E.g.:
> 
> mkdir: page allocation failure: order:5, mode:0x14040c0(GFP_KERNEL|__GFP_COMP), nodemask=(null)
> CPU: 1 PID: 6399 Comm: mkdir Not tainted 4.13.0-mm1-00065-g720bbe532b7c-dirty #481
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-20170228_101828-anatol 04/01/2014
> Call Trace:
>  dump_stack+0x70/0x9d
>  warn_alloc+0xd6/0x170
>  ? __alloc_pages_direct_compact+0x4c/0x110
>  __alloc_pages_nodemask+0xf50/0x1430
>  ? __lock_acquire+0xd19/0x1360
>  ? memcg_update_all_list_lrus+0x2e/0x2e0
>  ? __mutex_lock+0x7c/0x950
>  ? memcg_update_all_list_lrus+0x2e/0x2e0
>  alloc_pages_current+0x60/0xc0
>  kmalloc_order_trace+0x29/0x1b0
>  __kmalloc+0x1f4/0x320
>  memcg_update_all_list_lrus+0xca/0x2e0
>  mem_cgroup_css_alloc+0x612/0x670
>  cgroup_apply_control_enable+0x19e/0x360
>  cgroup_mkdir+0x322/0x490
>  kernfs_iop_mkdir+0x55/0x80
>  vfs_mkdir+0xd0/0x120
>  SyS_mkdirat+0x6c/0xe0
>  SyS_mkdir+0x14/0x20
>  entry_SYSCALL_64_fastpath+0x18/0xad
> RIP: 0033:0x7f9ff36cee87
> RSP: 002b:00007ffc7612d758 EFLAGS: 00000202 ORIG_RAX: 0000000000000053
> RAX: ffffffffffffffda RBX: 00007ffc7612da48 RCX: 00007f9ff36cee87
> RDX: 00000000000001ff RSI: 00000000000001ff RDI: 00007ffc7612de86
> RBP: 0000000000000002 R08: 00000000000001ff R09: 0000000000401db0
> R10: 00000000000001e2 R11: 0000000000000202 R12: 0000000000000000
> R13: 00007ffc7612da40 R14: 0000000000000000 R15: 0000000000000000
> Mem-Info:
> active_anon:2965 inactive_anon:19 isolated_anon:0
>  active_file:100270 inactive_file:98846 isolated_file:0
>  unevictable:0 dirty:0 writeback:0 unstable:0
>  slab_reclaimable:7328 slab_unreclaimable:16402
>  mapped:771 shmem:52 pagetables:278 bounce:0
>  free:13718 free_pcp:0 free_cma:0
> 
> This output is from an artificial reproducer, but we have repeatedly
> observed order-7 failures in production in the Facebook fleet. These
> systems become useless as they cannot run more jobs, even though there
> is plenty of memory to allocate 128 individual pages.
> 
> Use kvmalloc and kvzalloc to fall back to vmalloc space if these
> arrays prove too large for allocating them physically contiguous.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
