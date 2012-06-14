Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id E40426B005C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 21:49:07 -0400 (EDT)
Date: Thu, 14 Jun 2012 09:49:02 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH] mm: add gfp_mask parameter to vm_map_ram()
Message-ID: <20120614014902.GB7289@localhost>
References: <20120612012134.GA7706@localhost>
 <20120613123932.GA1445@localhost>
 <20120614012026.GL3019@devil.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120614012026.GL3019@devil.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, xfs@oss.sgi.com

On Thu, Jun 14, 2012 at 11:20:26AM +1000, Dave Chinner wrote:
> On Wed, Jun 13, 2012 at 08:39:32PM +0800, Fengguang Wu wrote:
> > Hi Christoph, Dave,
> > 
> > I got this lockdep warning on XFS when running the xfs tests:
> > 
> > [  704.832019] =================================
> > [  704.832019] [ INFO: inconsistent lock state ]
> > [  704.832019] 3.5.0-rc1+ #8 Tainted: G        W   
> > [  704.832019] ---------------------------------
> > [  704.832019] inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W} usage.
> > [  704.832019] fsstress/11619 [HC0[0]:SC0[0]:HE1:SE1] takes:
> > [  704.832019]  (&(&ip->i_lock)->mr_lock){++++?.}, at: [<ffffffff8143953d>] xfs_ilock_nowait+0xd7/0x1d0
> > [  704.832019] {IN-RECLAIM_FS-W} state was registered at:
> > [  704.832019]   [<ffffffff810e30a2>] mark_irqflags+0x12d/0x13e
> > [  704.832019]   [<ffffffff810e32f6>] __lock_acquire+0x243/0x3f9
> > [  704.832019]   [<ffffffff810e3a1c>] lock_acquire+0x112/0x13d
> > [  704.832019]   [<ffffffff810b8931>] down_write_nested+0x54/0x8b
> > [  704.832019]   [<ffffffff81438fab>] xfs_ilock+0xd8/0x17d
> > [  704.832019]   [<ffffffff814431b8>] xfs_reclaim_inode+0x4a/0x2cb
> > [  704.832019]   [<ffffffff814435ee>] xfs_reclaim_inodes_ag+0x1b5/0x28e
> > [  704.832019]   [<ffffffff814437d7>] xfs_reclaim_inodes_nr+0x33/0x3a
> > [  704.832019]   [<ffffffff8144050e>] xfs_fs_free_cached_objects+0x15/0x17
> > [  704.832019]   [<ffffffff81196076>] prune_super+0x103/0x154
> > [  704.832019]   [<ffffffff81152fa7>] shrink_slab+0x1ec/0x316
> > [  704.832019]   [<ffffffff8115574f>] balance_pgdat+0x308/0x618
> > [  704.832019]   [<ffffffff81155c22>] kswapd+0x1c3/0x1dc
> > [  704.832019]   [<ffffffff810b3f77>] kthread+0xaf/0xb7
> > [  704.832019]   [<ffffffff82f480b4>] kernel_thread_helper+0x4/0x10
> 
> ......
> > [  704.832019] stack backtrace:
> > [  704.832019] Pid: 11619, comm: fsstress Tainted: G        W    3.5.0-rc1+ #8
> > [  704.832019] Call Trace:
> > [  704.832019]  [<ffffffff82e92243>] print_usage_bug+0x1f5/0x206
> > [  704.832019]  [<ffffffff810e2220>] ? check_usage_forwards+0xa6/0xa6
> > [  704.832019]  [<ffffffff82e922c3>] mark_lock_irq+0x6f/0x120
> > [  704.832019]  [<ffffffff810e2f02>] mark_lock+0xaf/0x122
> > [  704.832019]  [<ffffffff810e3d4e>] mark_held_locks+0x6d/0x95
> > [  704.832019]  [<ffffffff810c5cd1>] ? local_clock+0x36/0x4d
> > [  704.832019]  [<ffffffff810e3de3>] __lockdep_trace_alloc+0x6d/0x6f
> > [  704.832019]  [<ffffffff810e42e7>] lockdep_trace_alloc+0x3d/0x57
> > [  704.832019]  [<ffffffff811837c8>] kmem_cache_alloc_node_trace+0x47/0x1b4
> > [  704.832019]  [<ffffffff810e377d>] ? lock_release_nested+0x9f/0xa6
> > [  704.832019]  [<ffffffff81431650>] ? _xfs_buf_find+0xaa/0x302
> > [  704.832019]  [<ffffffff811710a2>] ? new_vmap_block.constprop.18+0x3a/0x1de
> > [  704.832019]  [<ffffffff811710a2>] new_vmap_block.constprop.18+0x3a/0x1de
> > [  704.832019]  [<ffffffff8117144a>] vb_alloc.constprop.16+0x204/0x225
> > [  704.832019]  [<ffffffff8117149d>] vm_map_ram+0x32/0xaa
> > [  704.832019]  [<ffffffff81430c95>] _xfs_buf_map_pages+0xb3/0xf5
> > [  704.832019]  [<ffffffff81431a6a>] xfs_buf_get+0xd3/0x1ac
> > [  704.832019]  [<ffffffff81492dd9>] xfs_trans_get_buf+0x180/0x244
> > [  704.832019]  [<ffffffff8146947a>] xfs_da_do_buf+0x2a0/0x5cc
> > [  704.832019]  [<ffffffff81469826>] xfs_da_get_buf+0x21/0x23
> > [  704.832019]  [<ffffffff8146f894>] xfs_dir2_data_init+0x44/0xf9
> > [  704.832019]  [<ffffffff8146e94f>] xfs_dir2_sf_to_block+0x1ef/0x5d8
> 
> Bug in vm_map_ram - it does an unconditional GFP_KERNEL allocation
> here, and we are in a GFP_NOFS context. We can't pass a gfp_mask to
> vm_map_ram(), so until vm_map_ram() grows that we can't fix it...

This trivial patch should fix it.

The only behavior change is the XFS part:

@@ -406,7 +406,7 @@ _xfs_buf_map_pages(
 
                do {
                        bp->b_addr = vm_map_ram(bp->b_pages, bp->b_page_count,
-                                               -1, PAGE_KERNEL);
+                                               -1, GFP_NOFS, PAGE_KERNEL);
                        if (bp->b_addr)
                                break;
                        vm_unmap_aliases();

Does that look fine to you?

Thanks,
Fengguang
---
