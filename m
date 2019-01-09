Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BCD848E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 03:44:46 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id e89so4739077pfb.17
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 00:44:46 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m1si70823767pfi.286.2019.01.09.00.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 Jan 2019 00:44:44 -0800 (PST)
Date: Wed, 9 Jan 2019 09:44:41 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: lockdep warning while reading sysfs
Message-ID: <20190109084441.GF1900@hirez.programming.kicks-ass.net>
References: <2c9aaa31-d0b7-bc20-f109-751a2fccfb88@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2c9aaa31-d0b7-bc20-f109-751a2fccfb88@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: viro@zeniv.linux.org.uk, gregkh@linuxfoundation.org, tj@kernel.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Tue, Jan 08, 2019 at 11:43:19PM -0500, Qian Cai wrote:
> ======================================================
> WARNING: possible circular locking dependency detected
> 5.0.0-rc1+ #60 Not tainted
> ------------------------------------------------------
> read_all/7952 is trying to acquire lock:
> 0000000019f12603 (mem_hotplug_lock.rw_sem){++++}, at: show_slab_objects+0x16c/0x450
> 
> but task is already holding lock:
> 000000008804717f (kn->count#69){++++}, at: kernfs_seq_start+0x79/0x170
> 
> which lock already depends on the new lock.
> 
> 
> the existing dependency chain (in reverse order) is:
> 
> -> #3 (kn->count#69){++++}:
>        __lock_acquire+0x728/0x1200
>        lock_acquire+0x269/0x5a0
>        __kernfs_remove+0x72f/0x9a0
>        kernfs_remove_by_name_ns+0x45/0x90
>        sysfs_remove_link+0x3c/0xa0
>        sysfs_slab_add+0x1bd/0x330
>        __kmem_cache_create+0x166/0x1c0
>        create_cache+0xcf/0x1f0
>        kmem_cache_create_usercopy+0x1aa/0x270
>        kmem_cache_create+0x16/0x20
>        mlx5_init_fs+0x195/0x1a10 [mlx5_core]
>        mlx5_load_one+0x1106/0x1e90 [mlx5_core]
>        init_one+0x864/0xd60 [mlx5_core]
>        local_pci_probe+0xda/0x190
>        work_for_cpu_fn+0x56/0xa0
>        process_one_work+0xad7/0x1b80
>        worker_thread+0x8ff/0x1370
>        kthread+0x32c/0x3f0
>        ret_from_fork+0x27/0x50
> 
> -> #2 (slab_mutex){+.+.}:
>        __lock_acquire+0x728/0x1200
>        lock_acquire+0x269/0x5a0
>        __mutex_lock+0x168/0x1730
>        mutex_lock_nested+0x1b/0x20
>        kmem_cache_create_usercopy+0x45/0x270
>        kmem_cache_create+0x16/0x20
>        ptlock_cache_init+0x24/0x2d
>        start_kernel+0x40e/0x7e0
>        x86_64_start_reservations+0x24/0x26
>        x86_64_start_kernel+0xef/0xf6
>        secondary_startup_64+0xb6/0xc0
> 
> -> #1 (memcg_cache_ids_sem){++++}:
>        ptlock_cache_init+0x24/0x2d
>        start_kernel+0x40e/0x7e0
>        x86_64_start_reservations+0x24/0x26
>        x86_64_start_kernel+0xef/0xf6
>        secondary_startup_64+0xb6/0xc0
> 
> -> #0 (mem_hotplug_lock.rw_sem){++++}:
>        validate_chain.isra.14+0x11af/0x3b50
>        __lock_acquire+0x728/0x1200
>        lock_acquire+0x269/0x5a0
>        get_online_mems+0x3d/0x80
>        show_slab_objects+0x16c/0x450
>        total_objects_show+0x13/0x20
>        slab_attr_show+0x1e/0x30
>        sysfs_kf_seq_show+0x1d5/0x470
>        kernfs_seq_show+0x1fa/0x2c0
>        seq_read+0x3f7/0x1050
>        kernfs_fop_read+0x126/0x650
>        __vfs_read+0xeb/0xf20
>        vfs_read+0x103/0x290
>        ksys_read+0xfa/0x260
>        __x64_sys_read+0x73/0xb0
>        do_syscall_64+0x18f/0xd23
>        entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> other info that might help us debug this:
> 
> Chain exists of:
>   mem_hotplug_lock.rw_sem --> slab_mutex --> kn->count#69
> 
>  Possible unsafe locking scenario:
> 
>        CPU0                    CPU1
>        CPU0                    CPU1
>        ----                    ----
>   lock(kn->count#69);
>                                lock(slab_mutex);
>                                lock(kn->count#69);
>   lock(mem_hotplug_lock.rw_sem);
> 
> 
> 3 locks held by read_all/7952:
>  #0: 0000000005c4ddec (&p->lock){+.+.}, at: seq_read+0x6b/0x1050
>  #1: 00000000c2f2e854 (&of->mutex){+.+.}, at: kernfs_seq_start+0x4f/0x170
>  #2: 000000008804717f (kn->count#69){++++}, at: kernfs_seq_start+0x79/0x170
> 
> 

You stripped out the stack trace at the bottom that shows the inversion
:/
