Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id EA2EE6B0009
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 22:43:02 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id l18so176419lfe.21
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 19:43:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u64sor518192lja.58.2018.02.14.19.43.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 19:43:00 -0800 (PST)
Message-ID: <1518666178.6070.25.camel@gmail.com>
Subject: Re: freezing system for several second on high I/O [kernel 4.15]
From: mikhail <mikhail.v.gavrilov@gmail.com>
Date: Thu, 15 Feb 2018 08:42:58 +0500
In-Reply-To: <20180214215245.GI7000@dastard>
References: <20180131022209.lmhespbauhqtqrxg@destitution>
	 <1517888875.7303.3.camel@gmail.com>
	 <20180206060840.kj2u6jjmkuk3vie6@destitution>
	 <CABXGCsOgcYyj8Xukn7Pi_M2qz2aJ1MJZTaxaSgYno7f_BtZH6w@mail.gmail.com>
	 <1517974845.4352.8.camel@gmail.com>
	 <20180207065520.66f6gocvxlnxmkyv@destitution>
	 <1518255240.31843.6.camel@gmail.com> <1518255352.31843.8.camel@gmail.com>
	 <20180211225657.GA6778@dastard> <1518643669.6070.21.camel@gmail.com>
	 <20180214215245.GI7000@dastard>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 2018-02-15 at 08:52 +1100, Dave Chinner wrote:
> On Thu, Feb 15, 2018 at 02:27:49AM +0500, mikhail wrote:
> > On Mon, 2018-02-12 at 09:56 +1100, Dave Chinner wrote:
> > > IOWs, this is not an XFS problem. It's exactly what I'd expect
> > > to see when you try to run a very IO intensive workload on a
> > > cheap SATA drive that can't keep up with what is being asked of
> > > it....
> > > 
> > 
> > I am understand that XFS is not culprit here. But I am worried
> > about of interface freezing and various kernel messages with
> > traces which leads to XFS. This is my only clue, and I do not know
> > where to dig yet.
> 
> I've already told you the problem: sustained storage subsystem
> overload. You can't "tune" you way around that. i.e. You need a
> faster disk subsystem to maintian the load you are putting on your
> system - either add more disks (e.g. RAID 0/5/6) or to move to SSDs.
> 


I know that you are bored already, but:
- But it not a reason send false positive messages in log, because next time when a real problems will occurs I would ignore all messages.
- I am not believe that for mouse pointer moving needed disk throughput. Very wildly that mouse pointer freeze I never seen this on Windows even I then I create such workload. So it look like on real
blocking vital processes for GUI.

After receiving your message I got another lock message and it looking different:

[101309.501423] ======================================================
[101309.501424] WARNING: possible circular locking dependency detected
[101309.501425] 4.15.2-300.fc27.x86_64+debug #1 Not tainted
[101309.501426] ------------------------------------------------------
[101309.501427] gnome-shell/1978 is trying to acquire lock:
[101309.501428]  (sb_internal#2){.+.+}, at: [<00000000df1d676f>] xfs_trans_alloc+0xe2/0x120 [xfs]
[101309.501465] 
                but task is already holding lock:
[101309.501466]  (fs_reclaim){+.+.}, at: [<000000002ed6959d>] fs_reclaim_acquire.part.74+0x5/0x30
[101309.501470] 
                which lock already depends on the new lock.

[101309.501471] 
                the existing dependency chain (in reverse order) is:
[101309.501472] 
                -> #1 (fs_reclaim){+.+.}:
[101309.501476]        kmem_cache_alloc+0x29/0x2f0
[101309.501496]        kmem_zone_alloc+0x61/0xe0 [xfs]
[101309.501513]        xfs_trans_alloc+0x67/0x120 [xfs]
[101309.501531]        xlog_recover_process_intents.isra.40+0x217/0x270 [xfs]
[101309.501550]        xlog_recover_finish+0x1f/0xb0 [xfs]
[101309.501573]        xfs_log_mount_finish+0x5b/0xe0 [xfs]
[101309.501597]        xfs_mountfs+0x62d/0xa30 [xfs]
[101309.501620]        xfs_fs_fill_super+0x49b/0x620 [xfs]
[101309.501623]        mount_bdev+0x17b/0x1b0
[101309.501625]        mount_fs+0x35/0x150
[101309.501628]        vfs_kern_mount.part.25+0x54/0x150
[101309.501630]        do_mount+0x620/0xd60
[101309.501633]        SyS_mount+0x80/0xd0
[101309.501636]        do_syscall_64+0x7a/0x220
[101309.501640]        entry_SYSCALL_64_after_hwframe+0x26/0x9b
[101309.501641] 
                -> #0 (sb_internal#2){.+.+}:
[101309.501647]        __sb_start_write+0x125/0x1a0
[101309.501662]        xfs_trans_alloc+0xe2/0x120 [xfs]
[101309.501678]        xfs_free_eofblocks+0x130/0x1f0 [xfs]
[101309.501693]        xfs_fs_destroy_inode+0xb6/0x2d0 [xfs]
[101309.501695]        dispose_list+0x51/0x80
[101309.501697]        prune_icache_sb+0x52/0x70
[101309.501699]        super_cache_scan+0x12a/0x1a0
[101309.501700]        shrink_slab.part.48+0x202/0x5a0
[101309.501702]        shrink_node+0x123/0x300
[101309.501703]        do_try_to_free_pages+0xca/0x350
[101309.501705]        try_to_free_pages+0x140/0x350
[101309.501707]        __alloc_pages_slowpath+0x43c/0x1080
[101309.501708]        __alloc_pages_nodemask+0x3af/0x440
[101309.501711]        dma_generic_alloc_coherent+0x89/0x150
[101309.501714]        x86_swiotlb_alloc_coherent+0x20/0x50
[101309.501718]        ttm_dma_pool_get_pages+0x21b/0x620 [ttm]
[101309.501720]        ttm_dma_populate+0x24d/0x340 [ttm]
[101309.501723]        ttm_tt_bind+0x29/0x60 [ttm]
[101309.501725]        ttm_bo_handle_move_mem+0x59a/0x5d0 [ttm]
[101309.501728]        ttm_bo_validate+0x1a2/0x1c0 [ttm]
[101309.501730]        ttm_bo_init_reserved+0x46b/0x520 [ttm]
[101309.501760]        amdgpu_bo_do_create+0x1b0/0x4f0 [amdgpu]
[101309.501776]        amdgpu_bo_create+0x50/0x2b0 [amdgpu]
[101309.501792]        amdgpu_gem_object_create+0x7f/0x110 [amdgpu]
[101309.501807]        amdgpu_gem_create_ioctl+0x1e8/0x280 [amdgpu]
[101309.501817]        drm_ioctl_kernel+0x5b/0xb0 [drm]
[101309.501822]        drm_ioctl+0x2d5/0x370 [drm]
[101309.501835]        amdgpu_drm_ioctl+0x49/0x80 [amdgpu]
[101309.501837]        do_vfs_ioctl+0xa5/0x6e0
[101309.501838]        SyS_ioctl+0x74/0x80
[101309.501840]        do_syscall_64+0x7a/0x220
[101309.501841]        entry_SYSCALL_64_after_hwframe+0x26/0x9b
[101309.501842] 
                other info that might help us debug this:

[101309.501843]  Possible unsafe locking scenario:

[101309.501845]        CPU0                    CPU1
[101309.501845]        ----                    ----
[101309.501846]   lock(fs_reclaim);
[101309.501847]                                lock(sb_internal#2);
[101309.501849]                                lock(fs_reclaim);
[101309.501850]   lock(sb_internal#2);
[101309.501852] 
                 *** DEADLOCK ***

[101309.501854] 4 locks held by gnome-shell/1978:
[101309.501854]  #0:  (reservation_ww_class_mutex){+.+.}, at: [<0000000054425eb5>] ttm_bo_init_reserved+0x44d/0x520 [ttm]
[101309.501859]  #1:  (fs_reclaim){+.+.}, at: [<000000002ed6959d>] fs_reclaim_acquire.part.74+0x5/0x30
[101309.501862]  #2:  (shrinker_rwsem){++++}, at: [<00000000e7c011bc>] shrink_slab.part.48+0x5b/0x5a0
[101309.501866]  #3:  (&type->s_umount_key#63){++++}, at: [<00000000192e0857>] trylock_super+0x16/0x50
[101309.501870] 
                stack backtrace:
[101309.501872] CPU: 1 PID: 1978 Comm: gnome-shell Not tainted 4.15.2-300.fc27.x86_64+debug #1
[101309.501873] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[101309.501874] Call Trace:
[101309.501878]  dump_stack+0x85/0xbf
[101309.501881]  print_circular_bug.isra.37+0x1ce/0x1db
[101309.501883]  __lock_acquire+0x1299/0x1340
[101309.501886]  ? lock_acquire+0x9f/0x200
[101309.501888]  lock_acquire+0x9f/0x200
[101309.501906]  ? xfs_trans_alloc+0xe2/0x120 [xfs]
[101309.501908]  __sb_start_write+0x125/0x1a0
[101309.501924]  ? xfs_trans_alloc+0xe2/0x120 [xfs]
[101309.501939]  xfs_trans_alloc+0xe2/0x120 [xfs]
[101309.501956]  xfs_free_eofblocks+0x130/0x1f0 [xfs]
[101309.501972]  xfs_fs_destroy_inode+0xb6/0x2d0 [xfs]
[101309.501975]  dispose_list+0x51/0x80
[101309.501977]  prune_icache_sb+0x52/0x70
[101309.501979]  super_cache_scan+0x12a/0x1a0
[101309.501981]  shrink_slab.part.48+0x202/0x5a0
[101309.501984]  shrink_node+0x123/0x300
[101309.501987]  do_try_to_free_pages+0xca/0x350
[101309.501990]  try_to_free_pages+0x140/0x350
[101309.501993]  __alloc_pages_slowpath+0x43c/0x1080
[101309.501998]  __alloc_pages_nodemask+0x3af/0x440
[101309.502001]  dma_generic_alloc_coherent+0x89/0x150
[101309.502004]  x86_swiotlb_alloc_coherent+0x20/0x50
[101309.502009]  ttm_dma_pool_get_pages+0x21b/0x620 [ttm]
[101309.502013]  ttm_dma_populate+0x24d/0x340 [ttm]
[101309.502017]  ttm_tt_bind+0x29/0x60 [ttm]
[101309.502021]  ttm_bo_handle_move_mem+0x59a/0x5d0 [ttm]
[101309.502025]  ttm_bo_validate+0x1a2/0x1c0 [ttm]
[101309.502029]  ? kmemleak_alloc_percpu+0x6d/0xd0
[101309.502034]  ttm_bo_init_reserved+0x46b/0x520 [ttm]
[101309.502055]  amdgpu_bo_do_create+0x1b0/0x4f0 [amdgpu]
[101309.502076]  ? amdgpu_fill_buffer+0x310/0x310 [amdgpu]
[101309.502098]  amdgpu_bo_create+0x50/0x2b0 [amdgpu]
[101309.502120]  amdgpu_gem_object_create+0x7f/0x110 [amdgpu]
[101309.502136]  ? amdgpu_gem_object_close+0x210/0x210 [amdgpu]
[101309.502151]  amdgpu_gem_create_ioctl+0x1e8/0x280 [amdgpu]
[101309.502166]  ? amdgpu_gem_object_close+0x210/0x210 [amdgpu]
[101309.502172]  drm_ioctl_kernel+0x5b/0xb0 [drm]
[101309.502177]  drm_ioctl+0x2d5/0x370 [drm]
[101309.502191]  ? amdgpu_gem_object_close+0x210/0x210 [amdgpu]
[101309.502194]  ? __pm_runtime_resume+0x54/0x90
[101309.502196]  ? trace_hardirqs_on_caller+0xed/0x180
[101309.502210]  amdgpu_drm_ioctl+0x49/0x80 [amdgpu]
[101309.502212]  do_vfs_ioctl+0xa5/0x6e0
[101309.502214]  SyS_ioctl+0x74/0x80
[101309.502216]  do_syscall_64+0x7a/0x220
[101309.502218]  entry_SYSCALL_64_after_hwframe+0x26/0x9b
[101309.502220] RIP: 0033:0x7f51ddada8e7
[101309.502221] RSP: 002b:00007ffd6c1855a8 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
[101309.502223] RAX: ffffffffffffffda RBX: 000056452ad39d50 RCX: 00007f51ddada8e7
[101309.502224] RDX: 00007ffd6c1855f0 RSI: 00000000c0206440 RDI: 000000000000000c
[101309.502225] RBP: 00007ffd6c1855f0 R08: 000056452ad39d50 R09: 0000000000000004
[101309.502226] R10: ffffffffffffffb0 R11: 0000000000000246 R12: 00000000c0206440
[101309.502227] R13: 000000000000000c R14: 00007ffd6c185688 R15: 0000564535658220


Of course I am not ready for collect traces for such situations.

$ vmstat 
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 2  0      0 2193440 298908 11193932    0    0    14  2511   13   18 25 12 61  2  0

$ free -h
              total        used        free      shared  buff/cache   available
Mem:            30G         17G        2,1G        1,4G         10G         12G
Swap:           59G          0B         59G

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
