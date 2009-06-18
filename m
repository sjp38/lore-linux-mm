Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 61B4E6B0055
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 09:19:47 -0400 (EDT)
Date: Thu, 18 Jun 2009 09:20:20 -0400
From: Bart Trojanowski <bart@jukie.net>
Subject: Re: [v2.6.30 nfs+fscache] lockdep: inconsistent lock state
Message-ID: <20090618132020.GA21444@jukie.net>
References: <20090615123658.GC4721@jukie.net> <20090613182721.GA24072@jukie.net> <25357.1245068384@redhat.com> <25124.1245074627@redhat.com> <20090617120451.GF30951@jukie.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090617120451.GF30951@jukie.net>
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-cachefs@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi David,

I moved the cachedfilesd dir to an ext3 filesystem.

        # grep '^dir' /etc/cachefilesd.conf
        dir /var/cache/fscache
        # mount | grep /var/cache/fscache
        /dev/mapper/vg-fscache on /var/cache/fscache type ext3 (rw,user_xattr)

Here is the latest lockdep event.  I'd blame xfs, but I run other
systems with xfs, but without fscache... maybe they just don't play well
together.

-Bart

=================================
[ INFO: inconsistent lock state ]
2.6.30-kvm4-dirty #5
---------------------------------
inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
kswapd1/426 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (&(&ip->i_lock)->mr_lock){++++?+}, at: [<ffffffff80365a9b>] xfs_ilock+0x60/0x7e
{RECLAIM_FS-ON-W} state was registered at:
  [<ffffffff802694a9>] mark_held_locks+0x4d/0x6b
  [<ffffffff80269575>] lockdep_trace_alloc+0xae/0xcf
  [<ffffffff802d1838>] kmem_cache_alloc+0x27/0x10d
  [<ffffffff80380b5c>] kmem_zone_alloc+0x6c/0xb7
  [<ffffffff80380bbb>] kmem_zone_zalloc+0x14/0x35
  [<ffffffff80356eff>] xfs_da_state_alloc+0x1a/0x1c
  [<ffffffff8035e78d>] xfs_dir2_node_lookup+0x1c/0xee
  [<ffffffff8035a11a>] xfs_dir_lookup+0x10b/0x158
  [<ffffffff8037e716>] xfs_lookup+0x50/0xb3
  [<ffffffff803876f2>] xfs_vn_lookup+0x44/0x83
  [<ffffffff802e0050>] do_lookup+0xdc/0x1c0
  [<ffffffff802e231b>] __link_path_walk+0x96a/0xdf9
  [<ffffffff802e29b8>] path_walk+0x6e/0xd9
  [<ffffffff802e2c09>] do_path_lookup+0x185/0x1a6
  [<ffffffff802e391a>] do_filp_open+0x108/0x8ee
  [<ffffffff802d6345>] do_sys_open+0x5b/0xe2
  [<ffffffff802d63ff>] sys_open+0x20/0x22
  [<ffffffff80209185>] init_post+0x3a/0x18d
  [<ffffffff80a046c1>] kernel_init+0x181/0x18c
  [<ffffffff8020ce8a>] child_rip+0xa/0x20
  [<ffffffffffffffff>] 0xffffffffffffffff
irq event stamp: 228127
hardirqs last  enabled at (228127): [<ffffffff802aaaa8>] free_hot_cold_page+0x1ae/0x26b
hardirqs last disabled at (228126): [<ffffffff802aab2b>] free_hot_cold_page+0x231/0x26b
softirqs last  enabled at (227688): [<ffffffff8024a7d1>] __do_softirq+0x189/0x198
softirqs last disabled at (227683): [<ffffffff8020cf8c>] call_softirq+0x1c/0x28

other info that might help us debug this:
2 locks held by kswapd1/426:
 #0:  (shrinker_rwsem){++++..}, at: [<ffffffff802b1223>] shrink_slab+0x3d/0x159
 #1:  (iprune_mutex){+.+.-.}, at: [<ffffffff802eb18f>] shrink_icache_memory+0x50/0x246

stack backtrace:
Pid: 426, comm: kswapd1 Not tainted 2.6.30-kvm4-dirty #5
Call Trace:
 [<ffffffff80268f0e>] print_usage_bug+0x1bc/0x1cd
 [<ffffffff802168ae>] ? save_stack_trace+0x2f/0x4d
 [<ffffffff80269b4c>] ? check_usage_forwards+0x0/0x9c
 [<ffffffff80269217>] mark_lock+0x2f8/0x53d
 [<ffffffff8026ac54>] __lock_acquire+0x812/0x16b4
 [<ffffffff8026bbbd>] lock_acquire+0xc7/0xf3
 [<ffffffff80365a9b>] ? xfs_ilock+0x60/0x7e
 [<ffffffff8025d911>] down_write_nested+0x34/0x67
 [<ffffffff80365a9b>] ? xfs_ilock+0x60/0x7e
 [<ffffffff80365a9b>] xfs_ilock+0x60/0x7e
 [<ffffffff8037d0b1>] xfs_reclaim+0x64/0xae
 [<ffffffff80389a82>] xfs_fs_destroy_inode+0x3c/0x5c
 [<ffffffff802eb017>] destroy_inode+0x3f/0x54
 [<ffffffff802eb10b>] dispose_list+0xdf/0x113
 [<ffffffff802eb34f>] shrink_icache_memory+0x210/0x246
 [<ffffffff802b12ca>] shrink_slab+0xe4/0x159
 [<ffffffff802b1a9c>] kswapd+0x4a7/0x646
 [<ffffffff802af2ae>] ? isolate_pages_global+0x0/0x232
 [<ffffffff8025a2f7>] ? autoremove_wake_function+0x0/0x3d
 [<ffffffff8026976d>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff802b15f5>] ? kswapd+0x0/0x646
 [<ffffffff802b15f5>] ? kswapd+0x0/0x646
 [<ffffffff80259ee8>] kthread+0x5b/0x88
 [<ffffffff8020ce8a>] child_rip+0xa/0x20
 [<ffffffff8020c850>] ? restore_args+0x0/0x30
 [<ffffffff8023fcf8>] ? finish_task_switch+0x40/0x111
 [<ffffffff80259e68>] ? kthreadd+0x10f/0x134
 [<ffffffff80259e8d>] ? kthread+0x0/0x88
 [<ffffffff8020ce80>] ? child_rip+0x0/0x20
Pid: 29607, comm: kslowd Not tainted 2.6.30-kvm4-dirty #5
Call Trace:
 [<ffffffff80235b69>] ? __wake_up+0x27/0x55
 [<ffffffffa02575cc>] cachefiles_read_waiter+0x5d/0x102 [cachefiles]
 [<ffffffff80233a55>] __wake_up_common+0x4b/0x7a
 [<ffffffff80235b7f>] __wake_up+0x3d/0x55
 [<ffffffff8025a2cd>] __wake_up_bit+0x31/0x33
 [<ffffffff802a51c6>] unlock_page+0x27/0x2b
 [<ffffffffa0234fba>] ext3_truncate+0x4bb/0x8fd [ext3]
 [<ffffffff802ba7d7>] ? unmap_mapping_range+0x232/0x241
 [<ffffffff8026976d>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff802ba987>] vmtruncate+0xc4/0xe4
 [<ffffffff802ebfae>] inode_setattr+0x30/0x12a
 [<ffffffffa023299f>] ext3_setattr+0x198/0x1ff [ext3]
 [<ffffffff802ec241>] notify_change+0x199/0x2e4
 [<ffffffffa02545b1>] cachefiles_attr_changed+0x10c/0x181 [cachefiles]
 [<ffffffffa0256110>] ? cachefiles_walk_to_object+0x68b/0x798 [cachefiles]
 [<ffffffffa0254c72>] cachefiles_lookup_object+0xac/0xd4 [cachefiles]
 [<ffffffffa017450f>] fscache_lookup_object+0x136/0x14e [fscache]
 [<ffffffffa0174aad>] fscache_object_slow_work_execute+0x243/0x814 [fscache]
 [<ffffffff802a4092>] slow_work_thread+0x278/0x43a
 [<ffffffff8025a2f7>] ? autoremove_wake_function+0x0/0x3d
 [<ffffffff802a3e1a>] ? slow_work_thread+0x0/0x43a
 [<ffffffff802a3e1a>] ? slow_work_thread+0x0/0x43a
 [<ffffffff80259ee8>] kthread+0x5b/0x88
 [<ffffffff8020ce8a>] child_rip+0xa/0x20
 [<ffffffff805a1968>] ? _spin_unlock_irq+0x30/0x3b
 [<ffffffff8020c850>] ? restore_args+0x0/0x30
 [<ffffffff8023fcf8>] ? finish_task_switch+0x40/0x111
 [<ffffffff80259e68>] ? kthreadd+0x10f/0x134
 [<ffffffff80259e8d>] ? kthread+0x0/0x88
 [<ffffffff8020ce80>] ? child_rip+0x0/0x20
CacheFiles: I/O Error: Readpage failed on backing file c0000000000830
FS-Cache: Cache cachefiles stopped due to I/O error

-- 
				WebSig: http://www.jukie.net/~bart/sig/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
