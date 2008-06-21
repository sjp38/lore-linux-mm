Received: by wx-out-0506.google.com with SMTP id h29so688029wxd.11
        for <linux-mm@kvack.org>; Sat, 21 Jun 2008 05:57:39 -0700 (PDT)
Message-ID: <a4423d670806210557k1e8fcee1le3526f62962799e@mail.gmail.com>
Date: Sat, 21 Jun 2008 16:57:38 +0400
From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: Re: 2.6.26-rc: nfsd hangs for a few sec
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernel-testers@vger.kernel.org, kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>

One more try, added some CC's.

2008/6/12 Alexander Beregalov <a.beregalov@gmail.com>:
> I have bisected it and it seems introduced here:
> How could it be?
>
> 54a6eb5c4765aa573a030ceeba2c14e3d2ea5706 is first bad commit
> commit 54a6eb5c4765aa573a030ceeba2c14e3d2ea5706
> Author: Mel Gorman <mel@csn.ul.ie>
> Date:   Mon Apr 28 02:12:16 2008 -0700
>
>    mm: use two zonelist that are filtered by GFP mask
>
>    Currently a node has two sets of zonelists, one for each zone type in the
>    system and a second set for GFP_THISNODE allocations.  Based on the zones
>    allowed by a gfp mask, one of these zonelists is selected.  All of these
>    zonelists consume memory and occupy cache lines.
>
>    This patch replaces the multiple zonelists per-node with two zonelists.  The
>    first contains all populated zones in the system, ordered by distance, for
>    fallback allocations when the target/preferred node has no free pages.  The
>    second contains all populated zones in the node suitable for GFP_THISNODE
>    allocations.
>
>    An iterator macro is introduced called for_each_zone_zonelist()
> that interates
>    through each zone allowed by the GFP flags in the selected zonelist.
>
>    Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>    Acked-by: Christoph Lameter <clameter@sgi.com>
>    Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
>    Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>    Cc: Mel Gorman <mel@csn.ul.ie>
>    Cc: Christoph Lameter <clameter@sgi.com>
>    Cc: Hugh Dickins <hugh@veritas.com>
>    Cc: Nick Piggin <nickpiggin@yahoo.com.au>
>    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>
> :040000 040000 89cdad93d855fa839537454113f2716011ca0e26
> 57aa307f4bddd264e70c759a2fb2076bfde363eb M      arch
> :040000 040000 4add802178c0088a85d3738b42ec42ca33e07d60
> 126d3b170424a18b60074a7901c4e9b98f3bdee5 M      fs
> :040000 040000 9d215d6248382dab53003d230643f0169f3e3e84
> 67d196d890a27d2211b3bf7e833e6366addba739 M      include
> :040000 040000 6502d185e8ea6338953027c29cc3ab960d6f9bad
> c818e0fc538cdc40016e2d5fe33661c9c54dc8a5 M      mm
>

> I remind the log message (it still happens on -rc5):
> Machine hangs for few seconds.
> I can caught such thing during the first hour of running.
>
>  [ INFO: possible circular locking dependency detected ]
>  2.6.26-rc5-00084-g39b945a #3
>  -------------------------------------------------------
>  nfsd/3457 is trying to acquire lock:
>  (iprune_mutex){--..}, at: [<c016fb6c>] shrink_icache_memory+0x38/0x19b
>
>  but task is already holding lock:
>  (&(&ip->i_iolock)->mr_lock){----}, at: [<c021108f>] xfs_ilock+0xa2/0xd6
>
>  which lock already depends on the new lock.
>
>
>  the existing dependency chain (in reverse order) is:
>
>  -> #1 (&(&ip->i_iolock)->mr_lock){----}:
>        [<c0135416>] __lock_acquire+0xa0c/0xbc6
>        [<c013563a>] lock_acquire+0x6a/0x86
>        [<c012c4f2>] down_write_nested+0x33/0x6a
>        [<c0211068>] xfs_ilock+0x7b/0xd6
>        [<c02111e1>] xfs_ireclaim+0x1d/0x59
>        [<c022f342>] xfs_finish_reclaim+0x173/0x195
>        [<c0231496>] xfs_reclaim+0xb3/0x138
>        [<c023ba0f>] xfs_fs_clear_inode+0x55/0x8e
>        [<c016f830>] clear_inode+0x83/0xd2
>        [<c016faaf>] dispose_list+0x3c/0xc1
>        [<c016fca7>] shrink_icache_memory+0x173/0x19b
>        [<c014a7fa>] shrink_slab+0xda/0x153
>        [<c014aa53>] try_to_free_pages+0x1e0/0x2a1
>        [<c0146ad7>] __alloc_pages_internal+0x23f/0x3a7
>        [<c0146c56>] __alloc_pages+0xa/0xc
>        [<c015b8c2>] __slab_alloc+0x1c7/0x513
>        [<c015beef>] kmem_cache_alloc+0x45/0xb3
>        [<c01a5afe>] reiserfs_alloc_inode+0x12/0x23
>        [<c016f308>] alloc_inode+0x14/0x1a9
>        [<c016f5ed>] iget5_locked+0x47/0x133
>        [<c019dffd>] reiserfs_iget+0x29/0x7d
>        [<c019b655>] reiserfs_lookup+0xb1/0xee
>        [<c01657c2>] do_lookup+0xa9/0x146
>        [<c0166deb>] __link_path_walk+0x734/0xb2f
>        [<c016722f>] path_walk+0x49/0x96
>        [<c01674e0>] do_path_lookup+0x12f/0x149
>        [<c0167d08>] __user_walk_fd+0x2f/0x48
>        [<c0162157>] vfs_lstat_fd+0x16/0x3d
>        [<c01621e9>] vfs_lstat+0x11/0x13
>        [<c01621ff>] sys_lstat64+0x14/0x28
>        [<c0102bb9>] sysenter_past_esp+0x6a/0xb1
>        [<ffffffff>] 0xffffffff
>
>  -> #0 (iprune_mutex){--..}:
>        [<c0135333>] __lock_acquire+0x929/0xbc6
>        [<c013563a>] lock_acquire+0x6a/0x86
>        [<c037db3e>] mutex_lock_nested+0xba/0x232
>        [<c016fb6c>] shrink_icache_memory+0x38/0x19b
>        [<c014a7fa>] shrink_slab+0xda/0x153
>        [<c014aa53>] try_to_free_pages+0x1e0/0x2a1
>        [<c0146ad7>] __alloc_pages_internal+0x23f/0x3a7
>        [<c0146c56>] __alloc_pages+0xa/0xc
>        [<c01484f2>] __do_page_cache_readahead+0xaa/0x16a
>        [<c01487ac>] ondemand_readahead+0x119/0x127
>        [<c014880c>] page_cache_async_readahead+0x52/0x5d
>        [<c0179410>] generic_file_splice_read+0x290/0x4a8
>        [<c023a46a>] xfs_splice_read+0x4b/0x78
>        [<c0237c78>] xfs_file_splice_read+0x24/0x29
>        [<c0178712>] do_splice_to+0x45/0x63
>        [<c017899e>] splice_direct_to_actor+0xc3/0x190
>        [<c01ceddd>] nfsd_vfs_read+0x1ed/0x2d0
>        [<c01cf24c>] nfsd_read+0x82/0x99
>        [<c01d47b8>] nfsd3_proc_read+0xdf/0x12a
>        [<c01cb907>] nfsd_dispatch+0xcf/0x19e
>        [<c036356c>] svc_process+0x3b3/0x68b
>        [<c01cbe35>] nfsd+0x168/0x26b
>        [<c01037db>] kernel_thread_helper+0x7/0x10
>        [<ffffffff>] 0xffffffff
>
>  other info that might help us debug this:
>
>  3 locks held by nfsd/3457:
>  #0:  (hash_sem){..--}, at: [<c01d1a34>] exp_readlock+0xd/0xf
>  #1:  (&(&ip->i_iolock)->mr_lock){----}, at: [<c021108f>] xfs_ilock+0xa2/0xd6
>  #2:  (shrinker_rwsem){----}, at: [<c014a744>] shrink_slab+0x24/0x153
>
>  stack backtrace:
>  Pid: 3457, comm: nfsd Not tainted 2.6.26-rc5-00084-g39b945a #3
>  [<c01335c8>] print_circular_bug_tail+0x5a/0x65
>  [<c0133ec9>] ? print_circular_bug_header+0xa8/0xb3
>  [<c0135333>] __lock_acquire+0x929/0xbc6
>  [<c013563a>] lock_acquire+0x6a/0x86
>  [<c016fb6c>] ? shrink_icache_memory+0x38/0x19b
>  [<c037db3e>] mutex_lock_nested+0xba/0x232
>  [<c016fb6c>] ? shrink_icache_memory+0x38/0x19b
>  [<c016fb6c>] ? shrink_icache_memory+0x38/0x19b
>  [<c016fb6c>] shrink_icache_memory+0x38/0x19b
>  [<c014a7fa>] shrink_slab+0xda/0x153
>  [<c014aa53>] try_to_free_pages+0x1e0/0x2a1
>  [<c0149993>] ? isolate_pages_global+0x0/0x3e
>  [<c0146ad7>] __alloc_pages_internal+0x23f/0x3a7
>  [<c0146c56>] __alloc_pages+0xa/0xc
>  [<c01484f2>] __do_page_cache_readahead+0xaa/0x16a
>  [<c01487ac>] ondemand_readahead+0x119/0x127
>  [<c014880c>] page_cache_async_readahead+0x52/0x5d
>  [<c0179410>] generic_file_splice_read+0x290/0x4a8
>  [<c037f425>] ? _spin_unlock+0x27/0x3c
>  [<c025140d>] ? _atomic_dec_and_lock+0x25/0x30
>  [<c01355b4>] ? __lock_acquire+0xbaa/0xbc6
>  [<c01787d5>] ? spd_release_page+0x0/0xf
>  [<c023a46a>] xfs_splice_read+0x4b/0x78
>  [<c0237c78>] xfs_file_splice_read+0x24/0x29
>  [<c0178712>] do_splice_to+0x45/0x63
>  [<c017899e>] splice_direct_to_actor+0xc3/0x190
>  [<c01ceec0>] ? nfsd_direct_splice_actor+0x0/0xf
>  [<c01ceddd>] nfsd_vfs_read+0x1ed/0x2d0
>  [<c01cf24c>] nfsd_read+0x82/0x99
>  [<c01d47b8>] nfsd3_proc_read+0xdf/0x12a
>  [<c01cb907>] nfsd_dispatch+0xcf/0x19e
>  [<c036356c>] svc_process+0x3b3/0x68b
>  [<c01cbe35>] nfsd+0x168/0x26b
>  [<c01cbccd>] ? nfsd+0x0/0x26b
>  [<c01037db>] kernel_thread_helper+0x7/0x10
>  =======================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
