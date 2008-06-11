Received: by rv-out-0708.google.com with SMTP id f25so4608671rvb.26
        for <linux-mm@kvack.org>; Wed, 11 Jun 2008 14:18:54 -0700 (PDT)
Message-ID: <a4423d670806111418v1a158974l5c42d2bd9207a2e1@mail.gmail.com>
Date: Thu, 12 Jun 2008 01:18:42 +0400
From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: Re: 2.6.26-rc1: possible circular locking dependency
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernel-testers@vger.kernel.org, kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have bisected it and it seems introduced here:
How could it be?

54a6eb5c4765aa573a030ceeba2c14e3d2ea5706 is first bad commit
commit 54a6eb5c4765aa573a030ceeba2c14e3d2ea5706
Author: Mel Gorman <mel@csn.ul.ie>
Date:   Mon Apr 28 02:12:16 2008 -0700

    mm: use two zonelist that are filtered by GFP mask

    Currently a node has two sets of zonelists, one for each zone type in the
    system and a second set for GFP_THISNODE allocations.  Based on the zones
    allowed by a gfp mask, one of these zonelists is selected.  All of these
    zonelists consume memory and occupy cache lines.

    This patch replaces the multiple zonelists per-node with two zonelists.  The
    first contains all populated zones in the system, ordered by distance, for
    fallback allocations when the target/preferred node has no free pages.  The
    second contains all populated zones in the node suitable for GFP_THISNODE
    allocations.

    An iterator macro is introduced called for_each_zone_zonelist()
that interates
    through each zone allowed by the GFP flags in the selected zonelist.

    Signed-off-by: Mel Gorman <mel@csn.ul.ie>
    Acked-by: Christoph Lameter <clameter@sgi.com>
    Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
    Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
    Cc: Mel Gorman <mel@csn.ul.ie>
    Cc: Christoph Lameter <clameter@sgi.com>
    Cc: Hugh Dickins <hugh@veritas.com>
    Cc: Nick Piggin <nickpiggin@yahoo.com.au>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

:040000 040000 89cdad93d855fa839537454113f2716011ca0e26
57aa307f4bddd264e70c759a2fb2076bfde363eb M      arch
:040000 040000 4add802178c0088a85d3738b42ec42ca33e07d60
126d3b170424a18b60074a7901c4e9b98f3bdee5 M      fs
:040000 040000 9d215d6248382dab53003d230643f0169f3e3e84
67d196d890a27d2211b3bf7e833e6366addba739 M      include
:040000 040000 6502d185e8ea6338953027c29cc3ab960d6f9bad
c818e0fc538cdc40016e2d5fe33661c9c54dc8a5 M      mm

git-bisect start
# bad: [28a4acb48586dc21d2d14a75a7aab7be78b7c83b] Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
git-bisect bad 28a4acb48586dc21d2d14a75a7aab7be78b7c83b
# good: [4b119e21d0c66c22e8ca03df05d9de623d0eb50f] Linux 2.6.25
git-bisect good 4b119e21d0c66c22e8ca03df05d9de623d0eb50f
# good: [fdfc7452f17eb65eb29a143cf992ea2b8d262c7a] V4L/DVB (7626):
Kconfig: VIDEO_AU0828 should select DVB_AU8522 and DVB_TUNER_XC5000
git-bisect good fdfc7452f17eb65eb29a143cf992ea2b8d262c7a
# bad: [96fffeb4b413a4f8f65bb627d59b7dfc97ea0b39] make
CC_OPTIMIZE_FOR_SIZE non-experimental
git-bisect bad 96fffeb4b413a4f8f65bb627d59b7dfc97ea0b39
# good: [ce1d5b23a8d1e19866ab82bdec0dc41fde5273d8] Merge branch
'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/dtor/input
git-bisect good ce1d5b23a8d1e19866ab82bdec0dc41fde5273d8
# good: [69a9f69bb24d6d3dbf3d2ba542ddceeda40536d5] KVM: Move some x86
specific constants and structures to include/asm-x86
git-bisect good 69a9f69bb24d6d3dbf3d2ba542ddceeda40536d5
# bad: [e26831814998cee8e6d9f0a9854cb46c516f5547] pageflags: use an
enum for the flags
git-bisect bad e26831814998cee8e6d9f0a9854cb46c516f5547
# good: [42cadc86008aae0fd9ff31642dc01ed50723cf32] Merge branch
'kvm-updates-2.6.26' of
git://git.kernel.org/pub/scm/linux/kernel/git/avi/kvm
git-bisect good 42cadc86008aae0fd9ff31642dc01ed50723cf32
# good: [e5fc9cc0266e5babcf84c81908ec8843b7e3349f] rtc-pcf8563: new
style conversion
git-bisect good e5fc9cc0266e5babcf84c81908ec8843b7e3349f
# bad: [797df5749032c2286bc7ff3a52de41fde0cdf0a5] mm: try both
endianess when checking for endianess
git-bisect bad 797df5749032c2286bc7ff3a52de41fde0cdf0a5
# good: [488514d1798289f56f80ed018e246179fe500383] Remove set_migrateflags()
git-bisect good 488514d1798289f56f80ed018e246179fe500383
# good: [dac1d27bc8d5ca636d3014ecfdf94407031d1970] mm: use zonelists
instead of zones when direct reclaiming pages
git-bisect good dac1d27bc8d5ca636d3014ecfdf94407031d1970
# bad: [54a6eb5c4765aa573a030ceeba2c14e3d2ea5706] mm: use two zonelist
that are filtered by GFP mask
git-bisect bad 54a6eb5c4765aa573a030ceeba2c14e3d2ea5706
# good: [18ea7e710d2452fa726814a406779188028cf1bf] mm: remember what
the preferred zone is for zone_statistics
git-bisect good 18ea7e710d2452fa726814a406779188028cf1bf

I remind the log message (it still happens on -rc5):
Machine hangs for few seconds and that is all bad things, but even
that should not happen.
I can caught such thing during the first hour of running.

 [ INFO: possible circular locking dependency detected ]
 2.6.26-rc5-00084-g39b945a #3
 -------------------------------------------------------
 nfsd/3457 is trying to acquire lock:
  (iprune_mutex){--..}, at: [<c016fb6c>] shrink_icache_memory+0x38/0x19b

 but task is already holding lock:
  (&(&ip->i_iolock)->mr_lock){----}, at: [<c021108f>] xfs_ilock+0xa2/0xd6

 which lock already depends on the new lock.


 the existing dependency chain (in reverse order) is:

 -> #1 (&(&ip->i_iolock)->mr_lock){----}:
        [<c0135416>] __lock_acquire+0xa0c/0xbc6
        [<c013563a>] lock_acquire+0x6a/0x86
        [<c012c4f2>] down_write_nested+0x33/0x6a
        [<c0211068>] xfs_ilock+0x7b/0xd6
        [<c02111e1>] xfs_ireclaim+0x1d/0x59
        [<c022f342>] xfs_finish_reclaim+0x173/0x195
        [<c0231496>] xfs_reclaim+0xb3/0x138
        [<c023ba0f>] xfs_fs_clear_inode+0x55/0x8e
        [<c016f830>] clear_inode+0x83/0xd2
        [<c016faaf>] dispose_list+0x3c/0xc1
        [<c016fca7>] shrink_icache_memory+0x173/0x19b
        [<c014a7fa>] shrink_slab+0xda/0x153
        [<c014aa53>] try_to_free_pages+0x1e0/0x2a1
        [<c0146ad7>] __alloc_pages_internal+0x23f/0x3a7
        [<c0146c56>] __alloc_pages+0xa/0xc
        [<c015b8c2>] __slab_alloc+0x1c7/0x513
        [<c015beef>] kmem_cache_alloc+0x45/0xb3
        [<c01a5afe>] reiserfs_alloc_inode+0x12/0x23
        [<c016f308>] alloc_inode+0x14/0x1a9
        [<c016f5ed>] iget5_locked+0x47/0x133
        [<c019dffd>] reiserfs_iget+0x29/0x7d
        [<c019b655>] reiserfs_lookup+0xb1/0xee
        [<c01657c2>] do_lookup+0xa9/0x146
        [<c0166deb>] __link_path_walk+0x734/0xb2f
        [<c016722f>] path_walk+0x49/0x96
        [<c01674e0>] do_path_lookup+0x12f/0x149
        [<c0167d08>] __user_walk_fd+0x2f/0x48
        [<c0162157>] vfs_lstat_fd+0x16/0x3d
        [<c01621e9>] vfs_lstat+0x11/0x13
        [<c01621ff>] sys_lstat64+0x14/0x28
        [<c0102bb9>] sysenter_past_esp+0x6a/0xb1
        [<ffffffff>] 0xffffffff

 -> #0 (iprune_mutex){--..}:
        [<c0135333>] __lock_acquire+0x929/0xbc6
        [<c013563a>] lock_acquire+0x6a/0x86
        [<c037db3e>] mutex_lock_nested+0xba/0x232
        [<c016fb6c>] shrink_icache_memory+0x38/0x19b
        [<c014a7fa>] shrink_slab+0xda/0x153
        [<c014aa53>] try_to_free_pages+0x1e0/0x2a1
        [<c0146ad7>] __alloc_pages_internal+0x23f/0x3a7
        [<c0146c56>] __alloc_pages+0xa/0xc
        [<c01484f2>] __do_page_cache_readahead+0xaa/0x16a
        [<c01487ac>] ondemand_readahead+0x119/0x127
        [<c014880c>] page_cache_async_readahead+0x52/0x5d
        [<c0179410>] generic_file_splice_read+0x290/0x4a8
        [<c023a46a>] xfs_splice_read+0x4b/0x78
        [<c0237c78>] xfs_file_splice_read+0x24/0x29
        [<c0178712>] do_splice_to+0x45/0x63
        [<c017899e>] splice_direct_to_actor+0xc3/0x190
        [<c01ceddd>] nfsd_vfs_read+0x1ed/0x2d0
        [<c01cf24c>] nfsd_read+0x82/0x99
        [<c01d47b8>] nfsd3_proc_read+0xdf/0x12a
        [<c01cb907>] nfsd_dispatch+0xcf/0x19e
        [<c036356c>] svc_process+0x3b3/0x68b
        [<c01cbe35>] nfsd+0x168/0x26b
        [<c01037db>] kernel_thread_helper+0x7/0x10
        [<ffffffff>] 0xffffffff

 other info that might help us debug this:

 3 locks held by nfsd/3457:
  #0:  (hash_sem){..--}, at: [<c01d1a34>] exp_readlock+0xd/0xf
  #1:  (&(&ip->i_iolock)->mr_lock){----}, at: [<c021108f>] xfs_ilock+0xa2/0xd6
  #2:  (shrinker_rwsem){----}, at: [<c014a744>] shrink_slab+0x24/0x153

 stack backtrace:
 Pid: 3457, comm: nfsd Not tainted 2.6.26-rc5-00084-g39b945a #3
  [<c01335c8>] print_circular_bug_tail+0x5a/0x65
  [<c0133ec9>] ? print_circular_bug_header+0xa8/0xb3
  [<c0135333>] __lock_acquire+0x929/0xbc6
  [<c013563a>] lock_acquire+0x6a/0x86
  [<c016fb6c>] ? shrink_icache_memory+0x38/0x19b
  [<c037db3e>] mutex_lock_nested+0xba/0x232
  [<c016fb6c>] ? shrink_icache_memory+0x38/0x19b
  [<c016fb6c>] ? shrink_icache_memory+0x38/0x19b
  [<c016fb6c>] shrink_icache_memory+0x38/0x19b
  [<c014a7fa>] shrink_slab+0xda/0x153
  [<c014aa53>] try_to_free_pages+0x1e0/0x2a1
  [<c0149993>] ? isolate_pages_global+0x0/0x3e
  [<c0146ad7>] __alloc_pages_internal+0x23f/0x3a7
  [<c0146c56>] __alloc_pages+0xa/0xc
  [<c01484f2>] __do_page_cache_readahead+0xaa/0x16a
  [<c01487ac>] ondemand_readahead+0x119/0x127
  [<c014880c>] page_cache_async_readahead+0x52/0x5d
  [<c0179410>] generic_file_splice_read+0x290/0x4a8
  [<c037f425>] ? _spin_unlock+0x27/0x3c
  [<c025140d>] ? _atomic_dec_and_lock+0x25/0x30
  [<c01355b4>] ? __lock_acquire+0xbaa/0xbc6
  [<c01787d5>] ? spd_release_page+0x0/0xf
  [<c023a46a>] xfs_splice_read+0x4b/0x78
  [<c0237c78>] xfs_file_splice_read+0x24/0x29
  [<c0178712>] do_splice_to+0x45/0x63
  [<c017899e>] splice_direct_to_actor+0xc3/0x190
  [<c01ceec0>] ? nfsd_direct_splice_actor+0x0/0xf
  [<c01ceddd>] nfsd_vfs_read+0x1ed/0x2d0
  [<c01cf24c>] nfsd_read+0x82/0x99
  [<c01d47b8>] nfsd3_proc_read+0xdf/0x12a
  [<c01cb907>] nfsd_dispatch+0xcf/0x19e
  [<c036356c>] svc_process+0x3b3/0x68b
  [<c01cbe35>] nfsd+0x168/0x26b
  [<c01cbccd>] ? nfsd+0x0/0x26b
  [<c01037db>] kernel_thread_helper+0x7/0x10
  =======================

2008/5/16 David Chinner <dgc@sgi.com>:
> On Thu, May 15, 2008 at 09:45:55PM +0400, Alexander Beregalov wrote:
>> 2008/5/12 David Chinner <dgc@sgi.com>:
>> > On Sun, May 11, 2008 at 09:18:07AM +0530, Kamalesh Babulal wrote:
>> >> Kamalesh Babulal wrote:
>> >> > Adding the cc to kernel-list, Ingo Molnar and Peter Zijlstra
>> >> >
>> >> > Alexander Beregalov wrote:
>> >> >> [ INFO: possible circular locking dependency detected ]
>> >> >> 2.6.26-rc1-00279-g28a4acb #13
>> >> >> -------------------------------------------------------
>> >> >> nfsd/3087 is trying to acquire lock:
>> >> >>  (iprune_mutex){--..}, at: [<c016f947>] shrink_icache_memory+0x38/0x19b
>> >> >>
>> >> >> but task is already holding lock:
>> >> >>  (&(&ip->i_iolock)->mr_lock){----}, at: [<c0210b83>] xfs_ilock+0xa2/0xd6
>
> [snip]
>
>> > Oh, yeah, that. Direct inode reclaim through memory pressure.
>> >
>> > Effectively memory reclaim inverts locking order w.r.t. iprune_mutex
>> > when it recurses into the filesystem. False positive - can never
>> > cause a deadlock on XFS. Can't be solved from the XFS side of things
>> > without effectively turning off lockdep checking for xfs inode
>> > locking.
>> Yes, it is not a deadlock, but machine hangs for few seconds.
>> It still happens about once a day for me. Every kernel report looks
>> similar to the above.
>
> That hang is just memory reclaim running, I think you'll find.
> It can take some time for reclaim to find pages to use, and meanwhile
> everything in the machine will back up behind it....
>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> Principal Engineer
> SGI Australian Software Group
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
