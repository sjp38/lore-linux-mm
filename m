Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD436B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 16:09:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b203so104316514pfb.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:09:31 -0700 (PDT)
Received: from mail-pa0-f67.google.com (mail-pa0-f67.google.com. [209.85.220.67])
        by mx.google.com with ESMTPS id pz7si6908881pab.216.2016.04.27.13.09.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 13:09:30 -0700 (PDT)
Received: by mail-pa0-f67.google.com with SMTP id yl2so5931191pac.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:09:30 -0700 (PDT)
Date: Wed, 27 Apr 2016 22:09:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1.2/2] mm: introduce memalloc_nofs_{save,restore} API
Message-ID: <20160427200927.GC22544@dhcp22.suse.cz>
References: <1461671772-1269-2-git-send-email-mhocko@kernel.org>
 <1461758075-21815-1-git-send-email-mhocko@kernel.org>
 <1461758075-21815-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461758075-21815-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

Hi Dave,

On Wed 27-04-16 13:54:35, Michal Hocko wrote:
[...]
> diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
> index 0d83f332e5c2..b35688a54c9a 100644
> --- a/fs/xfs/kmem.h
> +++ b/fs/xfs/kmem.h
> @@ -50,7 +50,7 @@ kmem_flags_convert(xfs_km_flags_t flags)
>  		lflags = GFP_ATOMIC | __GFP_NOWARN;
>  	} else {
>  		lflags = GFP_KERNEL | __GFP_NOWARN;
> -		if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
> +		if (flags & KM_NOFS)
>  			lflags &= ~__GFP_FS;
>  	}
>  

I was trying to reproduce the false positives you mentioned in other
email by reverting b17cb364dbbb ("xfs: fix missing KM_NOFS tags to keep
lockdep happy"). I could really hit the one below but then it turned out
that it is this hunk above which causes the lockdep warning. Now I am
trying to understand how is this possible as ~__GFP_FS happens at the
page allocation level so we should never leak the __GFP_FS context when
the PF flag is set.

One possible explanation would be that some code path hands over to
a kworker which then loses the PF flag but it would get a gfp_mask which
would have the FS flag cleared with the original code.
xfs_btree_split_worker is using PF_MEMALLOC_NOFS directly so it should
be OK and xfs_reclaim_worker resp. xfs_eofblocks_worker use struct
xfs_mount as a context which doesn't contain gfp_mask. The stack trace
also doesn't indicate any kworker involvement. Do you have an idea what
else might get wrong or what am I missing?

---
[   53.990821] =================================
[   53.991672] [ INFO: inconsistent lock state ]
[   53.992419] 4.5.0-nofs5-00004-g35ad69a8eb83-dirty #902 Not tainted
[   53.993458] ---------------------------------
[   53.993480] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-R} usage.
[   53.993480] kswapd0/467 [HC0[0]:SC0[0]:HE1:SE1] takes:
[   53.993480]  (&xfs_nondir_ilock_class){+++++-}, at: [<ffffffffa0066897>] xfs_ilock+0x18a/0x205 [xfs]
[   53.993480] {RECLAIM_FS-ON-W} state was registered at:
[   53.993480]   [<ffffffff810945e3>] mark_held_locks+0x5e/0x74
[   53.993480]   [<ffffffff8109722c>] lockdep_trace_alloc+0xb2/0xb5
[   53.993480]   [<ffffffff81174e56>] kmem_cache_alloc+0x36/0x2b0
[   53.993480]   [<ffffffffa0073422>] kmem_zone_alloc+0x65/0xc1 [xfs]
[   54.003925]   [<ffffffffa007a701>] xfs_buf_item_init+0x40/0x147 [xfs]
[   54.003925]   [<ffffffffa0084451>] _xfs_trans_bjoin+0x23/0x53 [xfs]
[   54.003925]   [<ffffffffa0084ea5>] xfs_trans_read_buf_map+0x2e9/0x5b3 [xfs]
[   54.003925]   [<ffffffffa001427c>] xfs_read_agf+0x141/0x1d4 [xfs]
[   54.003925]   [<ffffffffa0014413>] xfs_alloc_read_agf+0x104/0x223 [xfs]
[   54.003925]   [<ffffffffa001482f>] xfs_alloc_pagf_init+0x1a/0x3a [xfs]
[   54.003925]   [<ffffffffa001e1f2>] xfs_bmap_longest_free_extent+0x4c/0x9c [xfs]
[   54.003925]   [<ffffffffa0026225>] xfs_bmap_btalloc_nullfb+0x7a/0xc6 [xfs]
[   54.003925]   [<ffffffffa00289fc>] xfs_bmap_btalloc+0x21a/0x59d [xfs]
[   54.003925]   [<ffffffffa0028d8d>] xfs_bmap_alloc+0xe/0x10 [xfs]
[   54.003925]   [<ffffffffa0029612>] xfs_bmapi_write+0x401/0x80f [xfs]
[   54.003925]   [<ffffffffa0064209>] xfs_iomap_write_allocate+0x1bf/0x2b3 [xfs]
[   54.003925]   [<ffffffffa004be66>] xfs_map_blocks+0x141/0x3c9 [xfs]
[   54.003925]   [<ffffffffa004d8f1>] xfs_vm_writepage+0x3f6/0x612 [xfs]
[   54.003925]   [<ffffffff8112e6b4>] __writepage+0x16/0x34
[   54.003925]   [<ffffffff8112ecdb>] write_cache_pages+0x35d/0x4b4
[   54.003925]   [<ffffffff8112ee82>] generic_writepages+0x50/0x6f
[   54.003925]   [<ffffffffa004bbc2>] xfs_vm_writepages+0x44/0x4c [xfs]
[   54.003925]   [<ffffffff81130b7c>] do_writepages+0x23/0x2c
[   54.003925]   [<ffffffff81124395>] __filemap_fdatawrite_range+0x84/0x8b
[   54.003925]   [<ffffffff8112445f>] filemap_write_and_wait_range+0x2d/0x5b
[   54.003925]   [<ffffffffa0059512>] xfs_file_fsync+0x113/0x29a [xfs]
[   54.003925]   [<ffffffff811bd269>] vfs_fsync_range+0x8c/0x9e
[   54.003925]   [<ffffffff811bd297>] vfs_fsync+0x1c/0x1e
[   54.003925]   [<ffffffff811bd2ca>] do_fsync+0x31/0x4a
[   54.003925]   [<ffffffff811bd50c>] SyS_fsync+0x10/0x14
[   54.003925]   [<ffffffff81618197>] entry_SYSCALL_64_fastpath+0x12/0x6b
[   54.003925] irq event stamp: 2998549
[   54.003925] hardirqs last  enabled at (2998549): [<ffffffff81617997>] _raw_spin_unlock_irq+0x2c/0x4a
[   54.003925] hardirqs last disabled at (2998548): [<ffffffff81617805>] _raw_spin_lock_irq+0x13/0x47
[   54.003925] softirqs last  enabled at (2994888): [<ffffffff8161afbf>] __do_softirq+0x38f/0x4d5
[   54.003925] softirqs last disabled at (2994867): [<ffffffff810542ea>] irq_exit+0x6f/0xd1
[   54.003925] 
[   54.003925] other info that might help us debug this:
[   54.003925]  Possible unsafe locking scenario:
[   54.003925] 
[   54.003925]        CPU0
[   54.003925]        ----
[   54.003925]   lock(&xfs_nondir_ilock_class);
[   54.003925]   <Interrupt>
[   54.003925]     lock(&xfs_nondir_ilock_class);
[   54.003925] 
[   54.003925]  *** DEADLOCK ***
[   54.003925] 
[   54.003925] 2 locks held by kswapd0/467:
[   54.003925]  #0:  (shrinker_rwsem){++++..}, at: [<ffffffff81136350>] shrink_slab+0x7a/0x518
[   54.003925]  #1:  (&type->s_umount_key#25){.+.+..}, at: [<ffffffff81192b74>] trylock_super+0x1b/0x4b
[   54.003925] 
[   54.003925] stack backtrace:
[   54.003925] CPU: 0 PID: 467 Comm: kswapd0 Not tainted 4.5.0-nofs5-00004-g35ad69a8eb83-dirty #902
[   54.003925] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[   54.003925]  0000000000000000 ffff8800065678b8 ffffffff81308ded ffffffff825caa70
[   54.003925]  ffff880007328000 ffff8800065678f0 ffffffff81121489 0000000000000009
[   54.003925]  ffff8800073288a0 ffff880007328000 ffffffff810936a7 0000000000000009
[   54.003925] Call Trace:
[   54.003925]  [<ffffffff81308ded>] dump_stack+0x67/0x90
[   54.003925]  [<ffffffff81121489>] print_usage_bug.part.24+0x259/0x268
[   54.003925]  [<ffffffff810936a7>] ? print_shortest_lock_dependencies+0x180/0x180
[   54.003925]  [<ffffffff8109439f>] mark_lock+0x381/0x567
[   54.003925]  [<ffffffff810953ff>] __lock_acquire+0x9f7/0x190c
[   54.003925]  [<ffffffffa0066897>] ? xfs_ilock+0x18a/0x205 [xfs]
[   54.003925]  [<ffffffff81093f2c>] ? check_irq_usage+0x99/0xaa
[   54.003925]  [<ffffffff81092c77>] ? add_lock_to_list.isra.8.constprop.25+0x82/0x8d
[   54.003925]  [<ffffffff810961b1>] ? __lock_acquire+0x17a9/0x190c
[   54.003925]  [<ffffffff81096ae2>] lock_acquire+0x139/0x1e1
[   54.003925]  [<ffffffff81096ae2>] ? lock_acquire+0x139/0x1e1
[   54.003925]  [<ffffffffa0066897>] ? xfs_ilock+0x18a/0x205 [xfs]
[   54.003925]  [<ffffffffa0050df2>] ? xfs_free_eofblocks+0x84/0x1ce [xfs]
[   54.003925]  [<ffffffff81090e34>] down_read_nested+0x29/0x3e
[   54.003925]  [<ffffffffa0066897>] ? xfs_ilock+0x18a/0x205 [xfs]
[   54.003925]  [<ffffffffa0066897>] xfs_ilock+0x18a/0x205 [xfs]
[   54.003925]  [<ffffffffa0050df2>] xfs_free_eofblocks+0x84/0x1ce [xfs]
[   54.003925]  [<ffffffff81094765>] ? trace_hardirqs_on_caller+0x16c/0x188
[   54.003925]  [<ffffffffa0069ef7>] xfs_inactive+0x55/0xc6 [xfs]
[   54.003925]  [<ffffffffa006ef1b>] xfs_fs_evict_inode+0x14b/0x1bd [xfs]
[   54.003925]  [<ffffffff811a7db9>] evict+0xb0/0x165
[   54.003925]  [<ffffffff811a7eaa>] dispose_list+0x3c/0x4a
[   54.003925]  [<ffffffff811a9241>] prune_icache_sb+0x4a/0x55
[   54.003925]  [<ffffffff81192cd3>] super_cache_scan+0x12f/0x179
[   54.003925]  [<ffffffff811365a1>] shrink_slab+0x2cb/0x518
[   54.003925]  [<ffffffff81139b97>] shrink_zone+0x175/0x263
[   54.003925]  [<ffffffff8113b175>] kswapd+0x7dc/0x948
[   54.003925]  [<ffffffff8113a999>] ? mem_cgroup_shrink_node_zone+0x305/0x305
[   54.003925]  [<ffffffff8106c911>] kthread+0xed/0xf5
[   54.003925]  [<ffffffff81617997>] ? _raw_spin_unlock_irq+0x2c/0x4a
[   54.003925]  [<ffffffff8106c824>] ? kthread_create_on_node+0x1bd/0x1bd
[   54.003925]  [<ffffffff816184ef>] ret_from_fork+0x3f/0x70
[   54.003925]  [<ffffffff8106c824>] ? kthread_create_on_node+0x1bd/0x1bd
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
