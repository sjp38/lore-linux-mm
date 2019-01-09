Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1E08E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 08:37:33 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id c84so6219271qkb.13
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 05:37:33 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m50sor67906443qtb.61.2019.01.09.05.37.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 05:37:32 -0800 (PST)
Subject: Re: lockdep warning while reading sysfs
References: <2c9aaa31-d0b7-bc20-f109-751a2fccfb88@lca.pw>
 <20190109084441.GF1900@hirez.programming.kicks-ass.net>
From: Qian Cai <cai@lca.pw>
Message-ID: <b7c543ce-6a2c-ac58-83f5-fd9816b77026@lca.pw>
Date: Wed, 9 Jan 2019 08:37:30 -0500
MIME-Version: 1.0
In-Reply-To: <20190109084441.GF1900@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: viro@zeniv.linux.org.uk, gregkh@linuxfoundation.org, tj@kernel.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>


> You stripped out the stack trace at the bottom that shows the inversion
> :/
> 

Sorry, I thought it is the same as in #0, but here it is the whole thing.

WARNING: possible circular locking dependency detected
5.0.0-rc1+ #60 Not tainted
------------------------------------------------------
read_all/2954 is trying to acquire lock:
00000000c63ff499 (mem_hotplug_lock.rw_sem){++++}, at: show_slab_objects+0x16c/0x450

but task is already holding lock:
0000000047ae17d7 (kn->count#70){++++}, at: kernfs_seq_start+0x79/0x170

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #3 (kn->count#70){++++}:
       __lock_acquire+0x728/0x1200
       lock_acquire+0x269/0x5a0
       __kernfs_remove+0x72f/0x9a0
       kernfs_remove_by_name_ns+0x45/0x90
       sysfs_remove_link+0x3c/0xa0
       sysfs_slab_add+0x1bd/0x330
       __kmem_cache_create+0x166/0x1c0
       create_cache+0xcf/0x1f0
       kmem_cache_create_usercopy+0x1aa/0x270
       kmem_cache_create+0x16/0x20
       mlx5_init_fs+0x195/0x1a10 [mlx5_core]
       mlx5_load_one+0x1106/0x1e90 [mlx5_core]
       init_one+0x864/0xd60 [mlx5_core]
       local_pci_probe+0xda/0x190
       work_for_cpu_fn+0x56/0xa0
       process_one_work+0xad7/0x1b80
       worker_thread+0x8ff/0x1370
       kthread+0x32c/0x3f0
       ret_from_fork+0x27/0x50

-> #2 (slab_mutex){+.+.}:
       __lock_acquire+0x728/0x1200
       lock_acquire+0x269/0x5a0
       __mutex_lock+0x168/0x1730
       mutex_lock_nested+0x1b/0x20
       kmem_cache_create_usercopy+0x45/0x270
       kmem_cache_create+0x16/0x20
       ptlock_cache_init+0x24/0x2d
       start_kernel+0x40e/0x7e0
       x86_64_start_reservations+0x24/0x26
       x86_64_start_kernel+0xef/0xf6
       secondary_startup_64+0xb6/0xc0

-> #1 (memcg_cache_ids_sem){++++}:
       __lock_acquire+0x728/0x1200
       lock_acquire+0x269/0x5a0
       down_read+0x92/0x130
       memcg_get_cache_ids+0x15/0x20
       kmem_cache_create_usercopy+0x37/0x270
       kmem_cache_create+0x16/0x20
       ptlock_cache_init+0x24/0x2d
       start_kernel+0x40e/0x7e0
       x86_64_start_reservations+0x24/0x26
       x86_64_start_kernel+0xef/0xf6
       secondary_startup_64+0xb6/0xc0

-> #0 (mem_hotplug_lock.rw_sem){++++}:
       validate_chain.isra.14+0x11af/0x3b50
       __lock_acquire+0x728/0x1200
       lock_acquire+0x269/0x5a0
       get_online_mems+0x3d/0x80
       show_slab_objects+0x16c/0x450
       total_objects_show+0x13/0x20
       slab_attr_show+0x1e/0x30
       sysfs_kf_seq_show+0x1d5/0x470
       kernfs_seq_show+0x1fa/0x2c0
       seq_read+0x3f7/0x1050
       kernfs_fop_read+0x126/0x650
       __vfs_read+0xeb/0xf20
       vfs_read+0x103/0x290
       ksys_read+0xfa/0x260
       __x64_sys_read+0x73/0xb0
       do_syscall_64+0x18f/0xd23
       entry_SYSCALL_64_after_hwframe+0x49/0xbe

other info that might help us debug this:

Chain exists of:
  lock(kn->count#70);
                               lock(slab_mutex);
                               lock(kn->count#70);
  lock(mem_hotplug_lock.rw_sem);

 *** DEADLOCK ***

3 locks held by read_all/2954:
 #0: 00000000e8745902 (&p->lock){+.+.}, at: seq_read+0x6b/0x1050
 #1: 00000000bb9fa87a (&of->mutex){+.+.}, at: kernfs_seq_start+0x4f/0x170
 #2: 0000000047ae17d7 (kn->count#70){++++}, at: kernfs_seq_start+0x79/0x170

stack backtrace:
CPU: 100 PID: 2954 Comm: read_all Kdump: loaded Not tainted 5.0.0-rc1+ #60
Hardware name: HPE ProLiant DL385 Gen10/ProLiant DL385 Gen10, BIOS A40 09/07/2018
Call Trace:
 dump_stack+0xe0/0x19a
 print_circular_bug.isra.10.cold.34+0x2f4/0x435
 check_prev_add.constprop.19+0xca1/0x15f0
 validate_chain.isra.14+0x11af/0x3b50
 __lock_acquire+0x728/0x1200
 lock_acquire+0x269/0x5a0
 get_online_mems+0x3d/0x80
 show_slab_objects+0x16c/0x450
 total_objects_show+0x13/0x20
 slab_attr_show+0x1e/0x30
 sysfs_kf_seq_show+0x1d5/0x470
 kernfs_seq_show+0x1fa/0x2c0
 seq_read+0x3f7/0x1050
 kernfs_fop_read+0x126/0x650
 __vfs_read+0xeb/0xf20
 vfs_read+0x103/0x290
 ksys_read+0xfa/0x260
 __x64_sys_read+0x73/0xb0
 do_syscall_64+0x18f/0xd23
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x7f01b0000b12
Code: 94 20 00 f7 d8 64 89 02 48 c7 c0 ff ff ff ff eb b6 0f 1f 80 00 00 00 00 f3
0f 1e fa 8b 05 36 d9 20 00 85 c0 75 12 31 c0 0f 05 <48> 3d 00 f0 ff ff 77 56 c3
0f 1f 44 00 00 41 54 49 89 d4 55 48 89
RSP: 002b:00007ffd480fc058 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
RAX: ffffffffffffffda RBX: 00007ffd480fc100 RCX: 00007f01b0000b12
RDX: 00000000000003ff RSI: 00007ffd480fc500 RDI: 0000000000000003
RBP: 00007f01b040f000 R08: 0000000000000020 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000003
R13: 00007ffd480fc500 R14: 0000000000000028 R15: 0000000000000003
