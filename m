Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 76A4E6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 01:50:47 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id u108so24029911wrb.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 22:50:47 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.20])
        by mx.google.com with ESMTPS id b87si1675508wmi.20.2017.03.02.22.50.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 22:50:45 -0800 (PST)
Message-ID: <1488523834.4506.25.camel@gmx.de>
Subject: Re: [PATCH v3] lockdep: Teach lockdep about memalloc_noio_save
From: Mike Galbraith <efault@gmx.de>
Date: Fri, 03 Mar 2017 07:50:34 +0100
In-Reply-To: <20170301154659.GL6515@twins.programming.kicks-ass.net>
References: <1488367797-27278-1-git-send-email-nborisov@suse.com>
	 <20170301154659.GL6515@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="windows-1251"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Nikolay Borisov <nborisov@suse.com>
Cc: linux-kernel@vger.kernel.org, mhocko@kernel.org, vbabka.lkml@gmail.com, linux-mm@kvack.org, mingo@redhat.com

On Wed, 2017-03-01 at 16:46 +0100, Peter Zijlstra wrote:
> On Wed, Mar 01, 2017 at 01:29:57PM +0200, Nikolay Borisov wrote:
> > Commit 21caf2fc1931 ("mm: teach mm by current context info to not do I/=
O
> > during memory allocation") added the memalloc_noio_(save|restore) funct=
ions
> > to enable people to modify the MM behavior by disbaling I/O during memo=
ry
> > allocation. This was further extended in Fixes: 934f3072c17c ("mm: clea=
r=20
> > __GFP_FS when PF_MEMALLOC_NOIO is set"). memalloc_noio_* functions prev=
ent=20
> > allocation paths recursing back into the filesystem without explicitly=
=20
> > changing the flags for every allocation site. However, lockdep hasn't b=
een=20
> > keeping up with the changes and it entirely misses handling the memallo=
c_noio
> > adjustments. Instead, it is left to the callers of __lockdep_trace_allo=
c to=20
> > call the functino after they have shaven the respective GFP flags.=20
> >=20
> > Let's fix this by making lockdep explicitly do the shaving of respectiv=
e
> > GFP flags.=20
>=20
> I edited that to look like the below, then my compiler said:
>=20
> ../kernel/locking/lockdep.c: In function =91lockdep_set_current_reclaim_s=
tate=92:
> ../kernel/locking/lockdep.c:3866:33: error: implicit declaration of funct=
ion =91memalloc_noio_flags=92 [-Werror=3Dimplicit-function-declaration]
>   current->lockdep_reclaim_gfp =3D memalloc_noio_flags(gfp_mask);

(ah, another shiny lockdep thingy... /me adds include, tries it)

I had hoped (silly me) that this would make annoying btrfs gripe
finally go the hell away, but alas, didn't happen.

[ 4968.346159] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[ 4968.346160] [ INFO: possible irq lock inversion dependency detected ]
[ 4968.346163] 4.11.0-rt9-rt #179 Tainted: G        W   E =20
[ 4968.346164] ---------------------------------------------------------
[ 4968.346165] kswapd3/1337 just changed the state of lock:
[ 4968.346167]  (&delayed_node->mutex){+.+.-.}, at: [<ffffffffa0389fbf>] __=
btrfs_release_delayed_node+0x3f/0x2f0 [btrfs]
[ 4968.346215] but this lock took another, RECLAIM_FS-unsafe lock in the pa=
st:
[ 4968.346215]  (pcpu_alloc_mutex){+.+.+.}
[ 4968.346216]=20
              =20
               and interrupts could create inverse lock ordering between th=
em.

[ 4968.346217]=20
               other info that might help us debug this:
[ 4968.346217] Chain exists of:
                 &delayed_node->mutex --> &fs_info->commit_root_sem --> pcp=
u_alloc_mutex

[ 4968.346218]  Possible interrupt unsafe locking scenario:

[ 4968.346219]        CPU0                    CPU1
[ 4968.346219]        ----                    ----
[ 4968.346219]   lock(pcpu_alloc_mutex);
[ 4968.346220]                                local_irq_disable();
[ 4968.346220]                                lock(&delayed_node->mutex);
[ 4968.346221]                                lock(&fs_info->commit_root_se=
m);
[ 4968.346221]   <Interrupt>
[ 4968.346221]     lock(&delayed_node->mutex);
[ 4968.346222]=20
                *** DEADLOCK ***

[ 4968.346223] 2 locks held by kswapd3/1337:
[ 4968.346223]  #0:  (shrinker_rwsem){+.+...}, at: [<ffffffff811f447a>] shr=
ink_slab+0x7a/0x6c0
[ 4968.346231]  #1:  (&type->s_umount_key#26){++++..}, at: [<ffffffff812781=
5b>] trylock_super+0x1b/0x50
[ 4968.346236]=20
               the shortest dependencies between 2nd lock and 1st lock:
[ 4968.346238]   -> (pcpu_alloc_mutex){+.+.+.} ops: 4124 {
[ 4968.346239]      HARDIRQ-ON-W at:
[ 4968.346246]                         __lock_acquire+0x8ec/0x14f0
[ 4968.346247]                         lock_acquire+0xbd/0x250
[ 4968.346252]                         _mutex_lock+0x31/0x40
[ 4968.346258]                         pcpu_alloc+0x197/0x5a0
[ 4968.346260]                         __alloc_percpu+0x15/0x20
[ 4968.346264]                         setup_zone_pageset+0x1f/0x71
[ 4968.346273]                         setup_per_cpu_pageset+0x23/0x65
[ 4968.346279]                         start_kernel+0x3d4/0x496
[ 4968.346281]                         x86_64_start_reservations+0x2a/0x2c
[ 4968.346282]                         x86_64_start_kernel+0x13d/0x14c
[ 4968.346285]                         verify_cpu+0x0/0xfc
[ 4968.346286]      SOFTIRQ-ON-W at:
[ 4968.346287]                         __lock_acquire+0x285/0x14f0
[ 4968.346288]                         lock_acquire+0xbd/0x250
[ 4968.346289]                         _mutex_lock+0x31/0x40
[ 4968.346291]                         pcpu_alloc+0x197/0x5a0
[ 4968.346292]                         __alloc_percpu+0x15/0x20
[ 4968.346293]                         setup_zone_pageset+0x1f/0x71
[ 4968.346295]                         setup_per_cpu_pageset+0x23/0x65
[ 4968.346296]                         start_kernel+0x3d4/0x496
[ 4968.346298]                         x86_64_start_reservations+0x2a/0x2c
[ 4968.346299]                         x86_64_start_kernel+0x13d/0x14c
[ 4968.346300]                         verify_cpu+0x0/0xfc
[ 4968.346301]      RECLAIM_FS-ON-W at:
[ 4968.346303]                            mark_held_locks+0x66/0x90
[ 4968.346304]                            lockdep_trace_alloc+0x7d/0xf0
[ 4968.346309]                            __kmalloc+0x4f/0x340
[ 4968.346310]                            pcpu_mem_zalloc+0x37/0x70
[ 4968.346312]                            pcpu_extend_area_map+0x2f/0xd0
[ 4968.346313]                            pcpu_alloc+0x3af/0x5a0
[ 4968.346315]                            __alloc_percpu+0x15/0x20
[ 4968.346324]                            smpcfd_prepare_cpu+0x4a/0x60
[ 4968.346327]                            cpuhp_invoke_callback+0x248/0x9d0
[ 4968.346328]                            cpuhp_up_callbacks+0x37/0xb0
[ 4968.346329]                            _cpu_up+0x7c/0xc0
[ 4968.346330]                            do_cpu_up+0x87/0xb0
[ 4968.346331]                            cpu_up+0x13/0x20
[ 4968.346332]                            smp_init+0x79/0xe1
[ 4968.346334]                            kernel_init_freeable+0x1a7/0x2c7
[ 4968.346335]                            kernel_init+0xe/0x100
[ 4968.346337]                            ret_from_fork+0x31/0x40
[ 4968.346338]      INITIAL USE at:
[ 4968.346339]                        __lock_acquire+0x2d0/0x14f0
[ 4968.346340]                        lock_acquire+0xbd/0x250
[ 4968.346341]                        _mutex_lock+0x31/0x40
[ 4968.346343]                        pcpu_alloc+0x197/0x5a0
[ 4968.346344]                        __alloc_percpu+0x15/0x20
[ 4968.346346]                        kmem_cache_open+0x316/0x3d0
[ 4968.346347]                        __kmem_cache_create+0x2d/0x160
[ 4968.346349]                        create_boot_cache+0x8b/0xb3
[ 4968.346352]                        kmem_cache_init+0xa4/0x171
[ 4968.346354]                        start_kernel+0x242/0x496
[ 4968.346355]                        x86_64_start_reservations+0x2a/0x2c
[ 4968.346357]                        x86_64_start_kernel+0x13d/0x14c
[ 4968.346357]                        verify_cpu+0x0/0xfc
[ 4968.346358]    }
[ 4968.346363]    ... key      at: [<ffffffff81c9a798>] pcpu_alloc_mutex+0x=
58/0x80
[ 4968.346363]    ... acquired at:
[ 4968.346364]    lock_acquire+0xbd/0x250
[ 4968.346365]    _mutex_lock+0x31/0x40
[ 4968.346366]    pcpu_alloc+0x197/0x5a0
[ 4968.346368]    __alloc_percpu_gfp+0x12/0x20
[ 4968.346371]    __percpu_counter_init+0x55/0xd0
[ 4968.346384]    btrfs_init_fs_root+0x9e/0x1e0 [btrfs]
[ 4968.346396]    btrfs_get_fs_root.part.51+0x5f/0x150 [btrfs]
[ 4968.346406]    btrfs_get_fs_root+0x44/0xa0 [btrfs]
[ 4968.346420]    __resolve_indirect_refs+0x155/0x880 [btrfs]
[ 4968.346433]    find_parent_nodes+0x541/0x8d0 [btrfs]
[ 4968.346445]    __btrfs_find_all_roots+0xc6/0x130 [btrfs]
[ 4968.346457]    btrfs_find_all_roots+0x55/0x70 [btrfs]
[ 4968.346469]    btrfs_qgroup_trace_extent_post+0x25/0x40 [btrfs]
[ 4968.346480]    btrfs_add_delayed_tree_ref+0x1c6/0x1f0 [btrfs]
[ 4968.346491]    btrfs_free_tree_block+0x8a/0x390 [btrfs]
[ 4968.346499]    __btrfs_cow_block+0x2dc/0x610 [btrfs]
[ 4968.346508]    btrfs_cow_block+0x11e/0x300 [btrfs]
[ 4968.346516]    btrfs_search_slot+0x1e2/0x970 [btrfs]
[ 4968.346527]    btrfs_lookup_inode+0x2f/0xa0 [btrfs]
[ 4968.346539]    __btrfs_update_delayed_inode+0x65/0x210 [btrfs]
[ 4968.346550]    btrfs_async_run_delayed_root+0x1f6/0x220 [btrfs]
[ 4968.346562]    normal_work_helper+0x1bd/0x620 [btrfs]
[ 4968.346574]    btrfs_delayed_meta_helper+0x12/0x20 [btrfs]
[ 4968.346577]    process_one_work+0x1f0/0x700
[ 4968.346578]    worker_thread+0x171/0x530
[ 4968.346579]    kthread+0x10c/0x140
[ 4968.346580]    ret_from_fork+0x31/0x40

[ 4968.346581]  -> (&fs_info->commit_root_sem){++++..} ops: 527801 {
[ 4968.346583]     HARDIRQ-ON-W at:
[ 4968.346584]                       __lock_acquire+0x8ec/0x14f0
[ 4968.346585]                       lock_acquire+0xbd/0x250
[ 4968.346588]                       rt_down_write+0x31/0x40
[ 4968.346597]                       cache_block_group+0x2ad/0x400 [btrfs]
[ 4968.346607]                       find_free_extent+0x12a5/0x1510 [btrfs]
[ 4968.346616]                       btrfs_reserve_extent+0xdb/0x190 [btrfs=
]
[ 4968.346625]                       btrfs_alloc_tree_block+0x1a1/0x4b0 [bt=
rfs]
[ 4968.346634]                       __btrfs_cow_block+0x12f/0x610 [btrfs]
[ 4968.346643]                       btrfs_cow_block+0x11e/0x300 [btrfs]
[ 4968.346651]                       btrfs_search_slot+0x1e2/0x970 [btrfs]
[ 4968.346664]                       btrfs_update_device+0x68/0x190 [btrfs]
[ 4968.346676]                       btrfs_remove_chunk+0x348/0xa30 [btrfs]
[ 4968.346686]                       btrfs_delete_unused_bgs+0x2f8/0x450 [b=
trfs]
[ 4968.346696]                       cleaner_kthread+0x16e/0x1a0 [btrfs]
[ 4968.346698]                       kthread+0x10c/0x140
[ 4968.346699]                       ret_from_fork+0x31/0x40
[ 4968.346699]     HARDIRQ-ON-R at:
[ 4968.346701]                       __lock_acquire+0x262/0x14f0
[ 4968.346702]                       lock_acquire+0xbd/0x250
[ 4968.346703]                       __rt_down_read+0x32/0x50
[ 4968.346704]                       rt_down_read+0x10/0x20
[ 4968.346713]                       caching_thread+0x64/0x4e0 [btrfs]
[ 4968.346726]                       normal_work_helper+0x1bd/0x620 [btrfs]
[ 4968.346737]                       btrfs_cache_helper+0x12/0x20 [btrfs]
[ 4968.346738]                       process_one_work+0x1f0/0x700
[ 4968.346739]                       worker_thread+0x171/0x530
[ 4968.346741]                       kthread+0x10c/0x140
[ 4968.346742]                       ret_from_fork+0x31/0x40
[ 4968.346742]     SOFTIRQ-ON-W at:
[ 4968.346743]                       __lock_acquire+0x285/0x14f0
[ 4968.346744]                       lock_acquire+0xbd/0x250
[ 4968.346746]                       rt_down_write+0x31/0x40
[ 4968.346755]                       cache_block_group+0x2ad/0x400 [btrfs]
[ 4968.346764]                       find_free_extent+0x12a5/0x1510 [btrfs]
[ 4968.346773]                       btrfs_reserve_extent+0xdb/0x190 [btrfs=
]
[ 4968.346782]                       btrfs_alloc_tree_block+0x1a1/0x4b0 [bt=
rfs]
[ 4968.346791]                       __btrfs_cow_block+0x12f/0x610 [btrfs]
[ 4968.346799]                       btrfs_cow_block+0x11e/0x300 [btrfs]
[ 4968.346808]                       btrfs_search_slot+0x1e2/0x970 [btrfs]
[ 4968.346820]                       btrfs_update_device+0x68/0x190 [btrfs]
[ 4968.346832]                       btrfs_remove_chunk+0x348/0xa30 [btrfs]
[ 4968.346841]                       btrfs_delete_unused_bgs+0x2f8/0x450 [b=
trfs]
[ 4968.346851]                       cleaner_kthread+0x16e/0x1a0 [btrfs]
[ 4968.346853]                       kthread+0x10c/0x140
[ 4968.346854]                       ret_from_fork+0x31/0x40
[ 4968.346854]     SOFTIRQ-ON-R at:
[ 4968.346856]                       __lock_acquire+0x285/0x14f0
[ 4968.346857]                       lock_acquire+0xbd/0x250
[ 4968.346858]                       __rt_down_read+0x32/0x50
[ 4968.346859]                       rt_down_read+0x10/0x20
[ 4968.346868]                       caching_thread+0x64/0x4e0 [btrfs]
[ 4968.346880]                       normal_work_helper+0x1bd/0x620 [btrfs]
[ 4968.346892]                       btrfs_cache_helper+0x12/0x20 [btrfs]
[ 4968.346893]                       process_one_work+0x1f0/0x700
[ 4968.346894]                       worker_thread+0x171/0x530
[ 4968.346895]                       kthread+0x10c/0x140
[ 4968.346896]                       ret_from_fork+0x31/0x40
[ 4968.346896]     INITIAL USE at:
[ 4968.346898]                      __lock_acquire+0x2d0/0x14f0
[ 4968.346899]                      lock_acquire+0xbd/0x250
[ 4968.346900]                      rt_down_write+0x31/0x40
[ 4968.346909]                      cache_block_group+0x2ad/0x400 [btrfs]
[ 4968.346918]                      find_free_extent+0x12a5/0x1510 [btrfs]
[ 4968.346927]                      btrfs_reserve_extent+0xdb/0x190 [btrfs]
[ 4968.346935]                      btrfs_alloc_tree_block+0x1a1/0x4b0 [btr=
fs]
[ 4968.346944]                      __btrfs_cow_block+0x12f/0x610 [btrfs]
[ 4968.346952]                      btrfs_cow_block+0x11e/0x300 [btrfs]
[ 4968.346961]                      btrfs_search_slot+0x1e2/0x970 [btrfs]
[ 4968.346973]                      btrfs_update_device+0x68/0x190 [btrfs]
[ 4968.346984]                      btrfs_remove_chunk+0x348/0xa30 [btrfs]
[ 4968.346993]                      btrfs_delete_unused_bgs+0x2f8/0x450 [bt=
rfs]
[ 4968.347003]                      cleaner_kthread+0x16e/0x1a0 [btrfs]
[ 4968.347005]                      kthread+0x10c/0x140
[ 4968.347006]                      ret_from_fork+0x31/0x40
[ 4968.347006]   }
[ 4968.347022]   ... key      at: [<ffffffffa03dd058>] __key.59194+0x0/0xff=
fffffffffd7fa8 [btrfs]
[ 4968.347022]   ... acquired at:
[ 4968.347023]    lock_acquire+0xbd/0x250
[ 4968.347025]    __rt_down_read+0x32/0x50
[ 4968.347026]    rt_down_read+0x10/0x20
[ 4968.347039]    btrfs_find_all_roots+0x3e/0x70 [btrfs]
[ 4968.347051]    btrfs_qgroup_trace_extent_post+0x25/0x40 [btrfs]
[ 4968.347063]    btrfs_add_delayed_tree_ref+0x1c6/0x1f0 [btrfs]
[ 4968.347072]    btrfs_alloc_tree_block+0x38c/0x4b0 [btrfs]
[ 4968.347080]    __btrfs_cow_block+0x12f/0x610 [btrfs]
[ 4968.347089]    btrfs_cow_block+0x11e/0x300 [btrfs]
[ 4968.347097]    btrfs_search_slot+0x1e2/0x970 [btrfs]
[ 4968.347107]    btrfs_lookup_inode+0x2f/0xa0 [btrfs]
[ 4968.347119]    __btrfs_update_delayed_inode+0x65/0x210 [btrfs]
[ 4968.347130]    btrfs_commit_inode_delayed_inode+0x123/0x130 [btrfs]
[ 4968.347142]    btrfs_evict_inode+0x4a3/0x750 [btrfs]
[ 4968.347144]    evict+0xd1/0x1a0
[ 4968.347145]    iput+0x1fe/0x320
[ 4968.347147]    do_unlinkat+0x17b/0x2a0
[ 4968.347148]    SyS_unlink+0x16/0x20
[ 4968.347149]    entry_SYSCALL_64_fastpath+0x1f/0xc2

[ 4968.347149] -> (&delayed_node->mutex){+.+.-.} ops: 12427409 {
[ 4968.347151]    HARDIRQ-ON-W at:
[ 4968.347152]                     __lock_acquire+0x8ec/0x14f0
[ 4968.347153]                     lock_acquire+0xbd/0x250
[ 4968.347154]                     _mutex_lock+0x31/0x40
[ 4968.347166]                     btrfs_delayed_update_inode+0x4a/0x820 [b=
trfs]
[ 4968.347177]                     btrfs_update_inode+0x8c/0x110 [btrfs]
[ 4968.347187]                     btrfs_dirty_inode+0x69/0xe0 [btrfs]
[ 4968.347197]                     btrfs_update_time+0x64/0xc0 [btrfs]
[ 4968.347198]                     touch_atime+0x89/0xb0
[ 4968.347200]                     generic_file_read_iter+0x750/0x8d0
[ 4968.347204]                     __vfs_read+0xc1/0x130
[ 4968.347205]                     vfs_read+0xa1/0x180
[ 4968.347207]                     SyS_read+0x49/0xa0
[ 4968.347208]                     entry_SYSCALL_64_fastpath+0x1f/0xc2
[ 4968.347208]    SOFTIRQ-ON-W at:
[ 4968.347210]                     __lock_acquire+0x285/0x14f0
[ 4968.347211]                     lock_acquire+0xbd/0x250
[ 4968.347211]                     _mutex_lock+0x31/0x40
[ 4968.347223]                     btrfs_delayed_update_inode+0x4a/0x820 [b=
trfs]
[ 4968.347232]                     btrfs_update_inode+0x8c/0x110 [btrfs]
[ 4968.347241]                     btrfs_dirty_inode+0x69/0xe0 [btrfs]
[ 4968.347250]                     btrfs_update_time+0x64/0xc0 [btrfs]
[ 4968.347251]                     touch_atime+0x89/0xb0
[ 4968.347252]                     generic_file_read_iter+0x750/0x8d0
[ 4968.347254]                     __vfs_read+0xc1/0x130
[ 4968.347255]                     vfs_read+0xa1/0x180
[ 4968.347257]                     SyS_read+0x49/0xa0
[ 4968.347258]                     entry_SYSCALL_64_fastpath+0x1f/0xc2
[ 4968.347258]    IN-RECLAIM_FS-W at:
[ 4968.347259]                        __lock_acquire+0x2b8/0x14f0
[ 4968.347260]                        lock_acquire+0xbd/0x250
[ 4968.347261]                        _mutex_lock+0x31/0x40
[ 4968.347273]                        __btrfs_release_delayed_node+0x3f/0x2=
f0 [btrfs]
[ 4968.347284]                        btrfs_remove_delayed_node+0x2a/0x30 [=
btrfs]
[ 4968.347294]                        btrfs_evict_inode+0x390/0x750 [btrfs]
[ 4968.347295]                        evict+0xd1/0x1a0
[ 4968.347296]                        dispose_list+0x4d/0x70
[ 4968.347296]                        prune_icache_sb+0x4b/0x60
[ 4968.347297]                        super_cache_scan+0x141/0x190
[ 4968.347299]                        shrink_slab+0x277/0x6c0
[ 4968.347301]                        shrink_node+0x2e3/0x2f0
[ 4968.347302]                        kswapd+0x34f/0x980
[ 4968.347304]                        kthread+0x10c/0x140
[ 4968.347305]                        ret_from_fork+0x31/0x40
[ 4968.347305]    INITIAL USE at:
[ 4968.347306]                    __lock_acquire+0x2d0/0x14f0
[ 4968.347307]                    lock_acquire+0xbd/0x250
[ 4968.347308]                    _mutex_lock+0x31/0x40
[ 4968.347319]                    btrfs_delayed_update_inode+0x4a/0x820 [bt=
rfs]
[ 4968.347329]                    btrfs_update_inode+0x8c/0x110 [btrfs]
[ 4968.347337]                    btrfs_dirty_inode+0x69/0xe0 [btrfs]
[ 4968.347346]                    btrfs_update_time+0x64/0xc0 [btrfs]
[ 4968.347347]                    touch_atime+0x89/0xb0
[ 4968.347348]                    generic_file_read_iter+0x750/0x8d0
[ 4968.347350]                    __vfs_read+0xc1/0x130
[ 4968.347351]                    vfs_read+0xa1/0x180
[ 4968.347353]                    SyS_read+0x49/0xa0
[ 4968.347354]                    entry_SYSCALL_64_fastpath+0x1f/0xc2
[ 4968.347354]  }
[ 4968.347369]  ... key      at: [<ffffffffa03e1260>] __key.55236+0x0/0xfff=
ffffffffd3da0 [btrfs]
[ 4968.347370]  ... acquired at:
[ 4968.347371]    check_usage_forwards+0x131/0x140
[ 4968.347372]    mark_lock+0x191/0x290
[ 4968.347373]    __lock_acquire+0x2b8/0x14f0
[ 4968.347374]    lock_acquire+0xbd/0x250
[ 4968.347374]    _mutex_lock+0x31/0x40
[ 4968.347386]    __btrfs_release_delayed_node+0x3f/0x2f0 [btrfs]
[ 4968.347397]    btrfs_remove_delayed_node+0x2a/0x30 [btrfs]
[ 4968.347407]    btrfs_evict_inode+0x390/0x750 [btrfs]
[ 4968.347407]    evict+0xd1/0x1a0
[ 4968.347408]    dispose_list+0x4d/0x70
[ 4968.347409]    prune_icache_sb+0x4b/0x60
[ 4968.347410]    super_cache_scan+0x141/0x190
[ 4968.347411]    shrink_slab+0x277/0x6c0
[ 4968.347413]    shrink_node+0x2e3/0x2f0
[ 4968.347414]    kswapd+0x34f/0x980
[ 4968.347416]    kthread+0x10c/0x140
[ 4968.347417]    ret_from_fork+0x31/0x40

[ 4968.347417]=20
               stack backtrace:
[ 4968.347419] CPU: 54 PID: 1337 Comm: kswapd3 Tainted: G        W   E   4.=
11.0-rt9-rt #179
[ 4968.347421] Hardware name: Intel Corporation BRICKLAND/BRICKLAND, BIOS B=
RHSXSD1.86B.0056.R01.1409242327 09/24/2014
[ 4968.347421] Call Trace:
[ 4968.347426]  dump_stack+0x85/0xc8
[ 4968.347428]  print_irq_inversion_bug.part.37+0x1ac/0x1b8
[ 4968.347430]  check_usage_forwards+0x131/0x140
[ 4968.347432]  ? check_usage_backwards+0x130/0x130
[ 4968.347434]  mark_lock+0x191/0x290
[ 4968.347435]  __lock_acquire+0x2b8/0x14f0
[ 4968.347436]  ? check_irq_usage+0x83/0xb0
[ 4968.347438]  ? __lock_acquire+0xb1b/0x14f0
[ 4968.347440]  lock_acquire+0xbd/0x250
[ 4968.347451]  ? __btrfs_release_delayed_node+0x3f/0x2f0 [btrfs]
[ 4968.347453]  _mutex_lock+0x31/0x40
[ 4968.347463]  ? __btrfs_release_delayed_node+0x3f/0x2f0 [btrfs]
[ 4968.347474]  __btrfs_release_delayed_node+0x3f/0x2f0 [btrfs]
[ 4968.347475]  ? unpin_current_cpu+0x16/0x70
[ 4968.347486]  btrfs_remove_delayed_node+0x2a/0x30 [btrfs]
[ 4968.347496]  btrfs_evict_inode+0x390/0x750 [btrfs]
[ 4968.347501]  ? debug_smp_processor_id+0x17/0x20
[ 4968.347503]  ? rt_spin_unlock+0x3d/0x50
[ 4968.347504]  evict+0xd1/0x1a0
[ 4968.347505]  dispose_list+0x4d/0x70
[ 4968.347506]  prune_icache_sb+0x4b/0x60
[ 4968.347508]  super_cache_scan+0x141/0x190
[ 4968.347510]  shrink_slab+0x277/0x6c0
[ 4968.347514]  shrink_node+0x2e3/0x2f0
[ 4968.347516]  kswapd+0x34f/0x980
[ 4968.347519]  kthread+0x10c/0x140
[ 4968.347521]  ? mem_cgroup_shrink_node+0x390/0x390
[ 4968.347523]  ? kthread_park+0x90/0x90
[ 4968.347524]  ret_from_fork+0x31/0x40

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
