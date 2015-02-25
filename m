Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 90D606B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 09:31:32 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so5687900pab.1
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 06:31:32 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e9si1937886pas.9.2015.02.25.06.31.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 06:31:31 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201502172057.GCD09362.FtHQMVSLJOFFOO@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1502231347510.21127@chino.kir.corp.google.com>
	<201502242020.IDI64912.tOOQSVJFOFLHMF@I-love.SAKURA.ne.jp>
	<20150224152033.GA3782@thunk.org>
	<20150224210244.GA13666@dastard>
In-Reply-To: <20150224210244.GA13666@dastard>
Message-Id: <201502252331.IEJ78629.OOOFSLFMHQtFVJ@I-love.SAKURA.ne.jp>
Date: Wed, 25 Feb 2015 23:31:17 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: tytso@mit.edu, rientjes@google.com, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, fernando_b1@lab.ntt.co.jp

Dave Chinner wrote:
> This exact discussion is already underway.
> 
> My initial proposal:
> 
> http://oss.sgi.com/archives/xfs/2015-02/msg00314.html
> 
> Why mempools don't work but transaction based reservations will:
> 
> http://oss.sgi.com/archives/xfs/2015-02/msg00339.html
> 
> Reservation needs to be an accounting mechanisms, not preallocation:
> 
> http://oss.sgi.com/archives/xfs/2015-02/msg00456.html
> http://oss.sgi.com/archives/xfs/2015-02/msg00457.html
> http://oss.sgi.com/archives/xfs/2015-02/msg00458.html
> 
> And that's where the discussion currently sits.

I got two problems (one is stall at io_schedule(), the other is kernel panic
due to xfs's assertion failure) using Linux 3.19. I guess those problems are
caused by not retrying !GFP_FS allocations under OOM. Will those problems go
away by using transaction based reservations? And if yes, are they simple
enough to backport to vendor's kernels?

(From http://I-love.SAKURA.ne.jp/tmp/serial-20150225-1.txt.xz )
----------
[ 1225.773411] kworker/3:0H    D ffff88007cadb4f8 11632    27      2 0x00000000
[ 1225.776911]  ffff88007cadb4f8 ffff88007cadb508 ffff88007cac6740 0000000000014080
[ 1225.780670]  ffffffff8101cd19 ffff88007cadbfd8 0000000000014080 ffff88007c28b740
[ 1225.784431]  ffff88007cac6740 ffff88007cadb540 ffff88007f8d4998 ffff88007cadb540
[ 1225.788766] Call Trace:
[ 1225.789988]  [<ffffffff8101cd19>] ? read_tsc+0x9/0x10
[ 1225.792444]  [<ffffffff812acbd9>] ? xfs_iunpin_wait+0x19/0x20
[ 1225.795228]  [<ffffffff816b2590>] io_schedule+0xa0/0x130
[ 1225.797802]  [<ffffffff812a9569>] __xfs_iunpin_wait+0xe9/0x140
[ 1225.800621]  [<ffffffff810af3b0>] ? autoremove_wake_function+0x40/0x40
[ 1225.803770]  [<ffffffff812acbd9>] xfs_iunpin_wait+0x19/0x20
[ 1225.806471]  [<ffffffff812a209c>] xfs_reclaim_inode+0x7c/0x360
[ 1225.809283]  [<ffffffff812a25d7>] xfs_reclaim_inodes_ag+0x257/0x370
[ 1225.812308]  [<ffffffff81340839>] ? radix_tree_gang_lookup_tag+0x89/0xd0
[ 1225.815532]  [<ffffffff8116fe58>] ? list_lru_walk_node+0x148/0x190
[ 1225.817951]  [<ffffffff812a2783>] xfs_reclaim_inodes_nr+0x33/0x40
[ 1225.819373]  [<ffffffff812b3545>] xfs_fs_free_cached_objects+0x15/0x20
[ 1225.820898]  [<ffffffff811c29e9>] super_cache_scan+0x169/0x170
[ 1225.822245]  [<ffffffff8115aed6>] shrink_node_slabs+0x1d6/0x370
[ 1225.823588]  [<ffffffff8115dd2a>] shrink_zone+0x20a/0x240
[ 1225.824830]  [<ffffffff8115e0dc>] do_try_to_free_pages+0x16c/0x460
[ 1225.826230]  [<ffffffff8115e48a>] try_to_free_pages+0xba/0x150
[ 1225.827570]  [<ffffffff81151542>] __alloc_pages_nodemask+0x5b2/0x9d0
[ 1225.829030]  [<ffffffff8119ecbc>] kmem_getpages+0x8c/0x200
[ 1225.830277]  [<ffffffff811a122b>] fallback_alloc+0x17b/0x230
[ 1225.831561]  [<ffffffff811a107b>] ____cache_alloc_node+0x18b/0x1c0
[ 1225.833061]  [<ffffffff811a3b00>] kmem_cache_alloc+0x330/0x5c0
[ 1225.834435]  [<ffffffff8133c9d9>] ? ida_pre_get+0x69/0x100
[ 1225.835719]  [<ffffffff8133c9d9>] ida_pre_get+0x69/0x100
[ 1225.836963]  [<ffffffff8133d312>] ida_simple_get+0x42/0xf0
[ 1225.838248]  [<ffffffff81086211>] create_worker+0x31/0x1c0
[ 1225.839519]  [<ffffffff81087831>] worker_thread+0x3d1/0x4d0
[ 1225.840800]  [<ffffffff81087460>] ? rescuer_thread+0x3a0/0x3a0
[ 1225.842123]  [<ffffffff8108c5e2>] kthread+0xd2/0xf0
[ 1225.843234]  [<ffffffff81010000>] ? perf_trace_xen_mmu_ptep_modify_prot+0x90/0xf0
[ 1225.844978]  [<ffffffff8108c510>] ? kthread_create_on_node+0x180/0x180
[ 1225.846481]  [<ffffffff816b63fc>] ret_from_fork+0x7c/0xb0
[ 1225.847718]  [<ffffffff8108c510>] ? kthread_create_on_node+0x180/0x180
[ 1225.849279] kswapd0         D ffff88007708f998 11552    45      2 0x00000000
[ 1225.850977]  ffff88007708f998 0000000000000000 ffff88007c28b740 0000000000014080
[ 1225.852798]  0000000000000003 ffff88007708ffd8 0000000000014080 ffff880077ff2740
[ 1225.854575]  ffff88007c28b740 0000000000000000 ffff88007948e3a8 ffff88007948e3ac
[ 1225.856358] Call Trace:
[ 1225.856928]  [<ffffffff816b2799>] schedule_preempt_disabled+0x29/0x70
[ 1225.858384]  [<ffffffff816b43d5>] __mutex_lock_slowpath+0x95/0x100
[ 1225.859799]  [<ffffffff816b4463>] mutex_lock+0x23/0x37
[ 1225.860983]  [<ffffffff812a264c>] xfs_reclaim_inodes_ag+0x2cc/0x370
[ 1225.862403]  [<ffffffff8109eb48>] ? __enqueue_entity+0x78/0x80
[ 1225.863742]  [<ffffffff810a5f37>] ? enqueue_entity+0x237/0x8f0
[ 1225.865100]  [<ffffffff81340839>] ? radix_tree_gang_lookup_tag+0x89/0xd0
[ 1225.866659]  [<ffffffff8116fe58>] ? list_lru_walk_node+0x148/0x190
[ 1225.868106]  [<ffffffff812a2783>] xfs_reclaim_inodes_nr+0x33/0x40
[ 1225.869522]  [<ffffffff812b3545>] xfs_fs_free_cached_objects+0x15/0x20
[ 1225.871015]  [<ffffffff811c29e9>] super_cache_scan+0x169/0x170
[ 1225.872338]  [<ffffffff8115aed6>] shrink_node_slabs+0x1d6/0x370
[ 1225.873679]  [<ffffffff8115dd2a>] shrink_zone+0x20a/0x240
[ 1225.874920]  [<ffffffff8115ed2d>] kswapd+0x4fd/0x9c0
[ 1225.876049]  [<ffffffff8115e830>] ? mem_cgroup_shrink_node_zone+0x140/0x140
[ 1225.877654]  [<ffffffff8108c5e2>] kthread+0xd2/0xf0
[ 1225.878762]  [<ffffffff81010000>] ? perf_trace_xen_mmu_ptep_modify_prot+0x90/0xf0
[ 1225.880495]  [<ffffffff8108c510>] ? kthread_create_on_node+0x180/0x180
[ 1225.881996]  [<ffffffff816b63fc>] ret_from_fork+0x7c/0xb0
[ 1225.883336]  [<ffffffff8108c510>] ? kthread_create_on_node+0x180/0x180
----------

(From http://I-love.SAKURA.ne.jp/tmp/serial-20150225-2.txt.xz +
http://I-love.SAKURA.ne.jp/tmp/crash-20150225-2.log.xz )
----------
[  189.586204] Out of memory: Kill process 3701 (a.out) score 834 or sacrifice child
[  189.586205] Killed process 3701 (a.out) total-vm:2167392kB, anon-rss:1465820kB, file-rss:4kB
[  189.586210] Kill process 3702 (a.out) sharing same memory
[  189.586211] Kill process 3714 (a.out) sharing same memory
[  189.586212] Kill process 3748 (a.out) sharing same memory
[  189.586213] Kill process 3755 (a.out) sharing same memory
[  189.593470] XFS: Assertion failed: XFS_FORCED_SHUTDOWN(mp), file: fs/xfs/xfs_inode.c, line: 1701
[  189.593491] ------------[ cut here ]------------
[  189.593492] kernel BUG at fs/xfs/xfs_message.c:106!
[  189.593493] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[  189.593511] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_raw iptable_filter ip_tables coretemp crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel glue_helper lrw gf128mul ablk_helper cryptd dm_mirror dm_region_hash dm_log microcode dm_mod ppdev parport_pc pcspkr vmw_balloon serio_raw vmw_vmci parport shpchp i2c_piix4 nfsd auth_rpcgss nfs_acl lockd grace sunrpc uinput ata_generic pata_acpi sd_mod ata_piix mptspi libata scsi_transport_spi e1000 mptscsih mptbase floppy
[  189.593512] CPU: 1 PID: 3755 Comm: a.out Not tainted 3.19.0 #42
[  189.593512] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  189.593513] task: ffff88007a848740 ti: ffff88005c064000 task.ti: ffff88005c064000
[  189.593517] RIP: 0010:[<ffffffff812af992>]  [<ffffffff812af992>] assfail+0x22/0x30
[  189.593517] RSP: 0000:ffff88005c067af8  EFLAGS: 00010292
[  189.593518] RAX: 0000000000000054 RBX: ffff880079349c00 RCX: 0000000000000050
[  189.593518] RDX: 0000000000005050 RSI: 0000000000000282 RDI: 0000000000000282
[  189.593519] RBP: ffff88005c067af8 R08: 0000000000000282 R09: 0000000000000000
[  189.593519] R10: ffffffff81ec95c8 R11: 656c696166206e6f R12: ffff88005ee92800
[  189.593519] R13: 00000000fffffff4 R14: ffffffff81838140 R15: ffff880064505390
[  189.593520] FS:  00007f62d93e0740(0000) GS:ffff88007f840000(0000) knlGS:0000000000000000
[  189.593521] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  189.593521] CR2: 00007fb901282763 CR3: 0000000077b00000 CR4: 00000000000407e0
[  189.593562] Stack:
[  189.593564]  ffff88005c067b38 ffffffff812ab2d7 ffff880079349e48 ffff88007a6feef0
[  189.593564]  ffff88005c067b38 ffff880079349c00 0000000000000001 ffff880079349db8
[  189.593565]  ffff88005c067b58 ffffffff812acb98 ffff880079349db8 ffff880079349c00
[  189.593565] Call Trace:
[  189.593568]  [<ffffffff812ab2d7>] xfs_inactive_truncate+0x67/0x150
[  189.593569]  [<ffffffff812acb98>] xfs_inactive+0x1c8/0x1f0
[  189.593570]  [<ffffffff812b3216>] xfs_fs_evict_inode+0x86/0xd0
[  189.593572]  [<ffffffff811da0f8>] evict+0xb8/0x190
[  189.593574]  [<ffffffff811daa15>] iput+0xf5/0x180
[  189.593575]  [<ffffffff811d5b58>] __dentry_kill+0x188/0x1f0
[  189.593576]  [<ffffffff811d5c65>] dput+0xa5/0x170
[  189.593577]  [<ffffffff811c0dbd>] __fput+0x16d/0x1e0
[  189.593578]  [<ffffffff811c0e7e>] ____fput+0xe/0x10
[  189.593580]  [<ffffffff8108ac9f>] task_work_run+0xaf/0xf0
[  189.593582]  [<ffffffff81071638>] do_exit+0x2d8/0xbe0
[  189.593583]  [<ffffffff8107a5df>] ? recalc_sigpending+0x1f/0x60
[  189.593584]  [<ffffffff81071fcf>] do_group_exit+0x3f/0xa0
[  189.593585]  [<ffffffff8107d322>] get_signal+0x1d2/0x6f0
[  189.593588]  [<ffffffff810134e8>] do_signal+0x28/0x720
[  189.593589]  [<ffffffff811c1825>] ? __sb_end_write+0x35/0x70
[  189.593591]  [<ffffffff811bf362>] ? vfs_write+0x172/0x1f0
[  189.593592]  [<ffffffff81013c2c>] do_notify_resume+0x4c/0x90
[  189.593594]  [<ffffffff816b6747>] int_signal+0x12/0x17
[  189.593602] Code: 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 f1 41 89 d0 48 c7 c6 48 8b 97 81 48 89 fa 31 c0 48 89 e5 31 ff e8 de fb ff ff <0f> 0b 66 66 66 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 
[  189.593603] RIP  [<ffffffff812af992>] assfail+0x22/0x30
[  189.593604]  RSP <ffff88005c067af8>
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
