Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 377DB6B02A6
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 06:25:10 -0400 (EDT)
Date: Wed, 28 Jul 2010 20:24:49 +1000
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: VFS scalability git tree
Message-ID: <20100728102449.GA3573@amd>
References: <20100722190100.GA22269@amd>
 <20100726054111.GA2963@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100726054111.GA2963@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michael Neuling <mikey@neuling.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 03:41:11PM +1000, Nick Piggin wrote:
> On Fri, Jul 23, 2010 at 05:01:00AM +1000, Nick Piggin wrote:
> > I'm pleased to announce I have a git tree up of my vfs scalability work.
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
> > http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git
> 
> Pushed several fixes and improvements
> o XFS bugs fixed by Dave
> o dentry and inode stats bugs noticed by Dave
> o vmscan shrinker bugs fixed by KOSAKI san
> o compile bugs noticed by John
> o a few attempts to improve powerpc performance (eg. reducing smp_rmb())
> o scalability improvments for rename_lock

Yet another result on my small 2s8c Opteron. This time, the
re-aim benchmark configured as described here:

http://ertos.nicta.com.au/publications/papers/Chubb_Williams_05.pdf

It is using ext2 on ramdisk and an IO intensive workload, with fsync
activity.

I did 10 runs on each, and took the max jobs/sec of each run.

    N           Min           Max        Median           Avg        Stddev
x  10       2598750       2735122     2665384.6     2653353.8     46421.696
+  10     3337297.3     3484687.5     3410689.7     3397763.8     49994.631
Difference at 95.0% confidence
        744410 +/- 45327.3
        28.0554% +/- 1.7083%

Average is 2653K jobs/s for vanilla, versus 3398K jobs/s for vfs-scalem
or 28% speedup.

The profile is interesting. It is known to be inode_lock intensive, but
we also see here that it is do_lookup intensive, due to cacheline bouncing
in common elements of path lookups.

Vanilla:
# Overhead  Symbol
# ........  ......
#
     7.63%  [k] __d_lookup
            |          
            |--88.59%-- do_lookup
            |--9.75%-- __lookup_hash
            |--0.89%-- d_lookup

     7.17%  [k] _raw_spin_lock
            |          
            |--11.07%-- _atomic_dec_and_lock
            |          |          
            |          |--53.73%-- dput
            |           --46.27%-- iput
            |          
            |--9.85%-- __mark_inode_dirty
            |          |          
            |          |--46.25%-- ext2_new_inode
            |          |--25.32%-- __set_page_dirty
            |          |--18.27%-- nobh_write_end
            |          |--6.91%-- ext2_new_blocks
            |          |--3.12%-- ext2_unlink
            |          
            |--7.69%-- ext2_new_inode
            |          
            |--6.84%-- insert_inode_locked
            |          ext2_new_inode
            |          
            |--6.56%-- new_inode
            |          ext2_new_inode
            |          
            |--5.61%-- writeback_single_inode
            |          sync_inode
            |          generic_file_fsync
            |          ext2_fsync
            |          
            |--5.13%-- dput
            |--3.75%-- generic_delete_inode
            |--3.56%-- __d_lookup
            |--3.53%-- ext2_free_inode
            |--3.40%-- sync_inode
            |--2.71%-- d_instantiate
            |--2.36%-- d_delete
            |--2.25%-- inode_sub_bytes
            |--1.84%-- file_move
            |--1.52%-- file_kill
            |--1.36%-- ext2_new_blocks
            |--1.34%-- ext2_create
            |--1.34%-- d_alloc
            |--1.11%-- do_lookup
            |--1.07%-- iput
            |--1.05%-- __d_instantiate

     4.19%  [k] mutex_spin_on_owner
            |          
            |--99.92%-- __mutex_lock_slowpath
            |          mutex_lock
            |          |          
            |          |--56.45%-- do_unlinkat
            |          |          sys_unlink
            |          |          
            |           --43.55%-- do_last
            |                     do_filp_open

     2.96%  [k] _atomic_dec_and_lock
            |          
            |--58.18%-- dput
            |--31.02%-- mntput_no_expire
            |--3.30%-- path_put
            |--3.09%-- iput
            |--2.69%-- link_path_walk
            |--1.02%-- fput

     2.73%  [k] copy_user_generic_string
     2.67%  [k] __mark_inode_dirty
     2.65%  [k] link_path_walk
     2.63%  [k] mark_buffer_dirty
     1.72%  [k] __memcpy
     1.62%  [k] generic_getxattr
     1.50%  [k] acl_permission_check
     1.30%  [k] __find_get_block
     1.30%  [k] __memset
     1.17%  [k] ext2_find_entry
     1.09%  [k] ext2_new_inode
     1.06%  [k] system_call
     1.01%  [k] kmem_cache_free
     1.00%  [k] dput


In vfs-scale, most of the spinlock contention and path lookup cost is
gone. Contention for parent i_mutex (and d_lock) for creat/unlink
operations is now at the top of the profile.

A lot of the spinlock overhead seems to be not contention so much as
the the cost of the atomics. Down at 3% it is much less a problem than
it was though.

We may run into a bit of contention on the per-bdi inode dirty/io
list lock, with just a single ramdisk device (dirty/fsync activity
will hit this lock), but it is really not worth worrying about at
the moment.

# Overhead  Symbol
# ........  ......
#
     5.67%  [k] mutex_spin_on_owner
            |          
            |--99.96%-- __mutex_lock_slowpath
            |          mutex_lock
            |          |          
            |          |--58.63%-- do_unlinkat
            |          |          sys_unlink
            |          |          
            |           --41.37%-- do_last
            |                     do_filp_open

     3.93%  [k] __mark_inode_dirty
     3.43%  [k] copy_user_generic_string
     3.31%  [k] link_path_walk
     3.15%  [k] mark_buffer_dirty
     3.11%  [k] _raw_spin_lock
            |          
            |--11.03%-- __mark_inode_dirty
            |--10.54%-- ext2_new_inode
            |--7.60%-- ext2_free_inode
            |--6.33%-- inode_sub_bytes
            |--6.27%-- ext2_new_blocks
            |--5.80%-- generic_delete_inode
            |--4.09%-- ext2_create
            |--3.62%-- writeback_single_inode
            |--2.92%-- sync_inode
            |--2.81%-- generic_drop_inode
            |--2.46%-- iput
            |--1.86%-- dput
            |--1.80%-- __dquot_alloc_space
            |--1.61%-- __mutex_unlock_slowpath
            |--1.59%-- generic_file_fsync
            |--1.57%-- __d_instantiate
            |--1.55%-- __set_page_dirty_buffers
            |--1.36%-- d_alloc_and_lookup
            |--1.23%-- do_path_lookup
            |--1.10%-- ext2_free_blocks

     2.13%  [k] __memset
     2.12%  [k] __memcpy
     1.98%  [k] __d_lookup_rcu
     1.46%  [k] generic_getxattr
     1.44%  [k] ext2_find_entry
     1.41%  [k] __find_get_block
     1.27%  [k] kmem_cache_free
     1.25%  [k] ext2_new_inode
     1.23%  [k] system_call
     1.02%  [k] ext2_add_link
     1.01%  [k] strncpy_from_user
     0.96%  [k] kmem_cache_alloc
     0.95%  [k] find_get_page
     0.94%  [k] sysret_check
     0.88%  [k] __d_lookup
     0.75%  [k] ext2_delete_entry
     0.70%  [k] generic_file_aio_read
     0.67%  [k] generic_file_buffered_write
     0.63%  [k] ext2_new_blocks
     0.62%  [k] __percpu_counter_add
     0.59%  [k] __bread
     0.58%  [k] __wake_up_bit
     0.58%  [k] __mutex_lock_slowpath
     0.56%  [k] __ext2_write_inode
     0.55%  [k] ext2_get_blocks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
