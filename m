Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id A78456B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 17:08:23 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so44254217qkd.3
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 14:08:23 -0700 (PDT)
Received: from emvm-gh1-uea09.nsa.gov (emvm-gh1-uea09.nsa.gov. [63.239.67.10])
        by mx.google.com with ESMTP id e133si22501353qka.69.2015.07.27.14.08.22
        for <linux-mm@kvack.org>;
        Mon, 27 Jul 2015 14:08:22 -0700 (PDT)
Message-ID: <55B69D67.4070002@tycho.nsa.gov>
Date: Mon, 27 Jul 2015 17:06:47 -0400
From: Stephen Smalley <sds@tycho.nsa.gov>
MIME-Version: 1.0
Subject: Re: [PATCH v2] ipc: Use private shmem or hugetlbfs inodes for shm
 segments.
References: <1437741275-5388-1-git-send-email-sds@tycho.nsa.gov> <alpine.LSU.2.11.1507271212180.1028@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1507271212180.1028@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: prarit@redhat.com, david@fromorbit.com, mstevens@fedoraproject.org, manfred@colorfullife.com, esandeen@redhat.com, wagi@monom.org, linux-kernel@vger.kernel.org, eparis@redhat.com, linux-mm@kvack.org, linux-security-module@vger.kernel.org, dave@stgolabs.net, nyc@holomorphy.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, selinux@tycho.nsa.gov

On 07/27/2015 03:32 PM, Hugh Dickins wrote:
> On Fri, 24 Jul 2015, Stephen Smalley wrote:
> 
>> The shm implementation internally uses shmem or hugetlbfs inodes
>> for shm segments.  As these inodes are never directly exposed to
>> userspace and only accessed through the shm operations which are
>> already hooked by security modules, mark the inodes with the
>> S_PRIVATE flag so that inode security initialization and permission
>> checking is skipped.
>>
>> This was motivated by the following lockdep warning:
>> Jul 22 14:36:40 fc23 kernel:
>> ======================================================
>> Jul 22 14:36:40 fc23 kernel: [ INFO: possible circular locking
>> dependency detected ]
>> Jul 22 14:36:40 fc23 kernel: 4.2.0-0.rc3.git0.1.fc24.x86_64+debug #1
>> Tainted: G        W
>> Jul 22 14:36:40 fc23 kernel:
>> -------------------------------------------------------
>> Jul 22 14:36:40 fc23 kernel: httpd/1597 is trying to acquire lock:
>> Jul 22 14:36:40 fc23 kernel: (&ids->rwsem){+++++.}, at:
>> [<ffffffff81385354>] shm_close+0x34/0x130
>> Jul 22 14:36:40 fc23 kernel: #012but task is already holding lock:
>> Jul 22 14:36:40 fc23 kernel: (&mm->mmap_sem){++++++}, at:
>> [<ffffffff81386bbb>] SyS_shmdt+0x4b/0x180
>> Jul 22 14:36:40 fc23 kernel: #012which lock already depends on the new lock.
>> Jul 22 14:36:40 fc23 kernel: #012the existing dependency chain (in
>> reverse order) is:
>> Jul 22 14:36:40 fc23 kernel: #012-> #3 (&mm->mmap_sem){++++++}:
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81217baa>] __might_fault+0x7a/0xa0
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81284a1e>] filldir+0x9e/0x130
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffffa019bb08>]
>> xfs_dir2_block_getdents.isra.12+0x198/0x1c0 [xfs]
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffffa019c5b4>]
>> xfs_readdir+0x1b4/0x330 [xfs]
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffffa019f38b>]
>> xfs_file_readdir+0x2b/0x30 [xfs]
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff812847e7>] iterate_dir+0x97/0x130
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81284d21>] SyS_getdents+0x91/0x120
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81871d2e>]
>> entry_SYSCALL_64_fastpath+0x12/0x76
>> Jul 22 14:36:40 fc23 kernel: #012-> #2 (&xfs_dir_ilock_class){++++.+}:
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81101e97>]
>> down_read_nested+0x57/0xa0
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffffa01b0e57>]
>> xfs_ilock+0x167/0x350 [xfs]
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffffa01b10b8>]
>> xfs_ilock_attr_map_shared+0x38/0x50 [xfs]
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffffa014799d>]
>> xfs_attr_get+0xbd/0x190 [xfs]
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffffa01c17ad>]
>> xfs_xattr_get+0x3d/0x70 [xfs]
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff8129962f>]
>> generic_getxattr+0x4f/0x70
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff8139ba52>]
>> inode_doinit_with_dentry+0x162/0x670
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff8139cf69>]
>> sb_finish_set_opts+0xd9/0x230
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff8139d66c>]
>> selinux_set_mnt_opts+0x35c/0x660
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff8139ff97>]
>> superblock_doinit+0x77/0xf0
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff813a0020>]
>> delayed_superblock_init+0x10/0x20
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81272d23>]
>> iterate_supers+0xb3/0x110
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff813a4e5f>]
>> selinux_complete_init+0x2f/0x40
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff813b47a3>]
>> security_load_policy+0x103/0x600
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff813a6901>]
>> sel_write_load+0xc1/0x750
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff8126e817>] __vfs_write+0x37/0x100
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff8126f229>] vfs_write+0xa9/0x1a0
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff8126ff48>] SyS_write+0x58/0xd0
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81871d2e>]
>> entry_SYSCALL_64_fastpath+0x12/0x76
>> Jul 22 14:36:40 fc23 kernel: #012-> #1 (&isec->lock){+.+.+.}:
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff8186de8f>]
>> mutex_lock_nested+0x7f/0x3e0
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff8139b9a9>]
>> inode_doinit_with_dentry+0xb9/0x670
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff8139bf7c>]
>> selinux_d_instantiate+0x1c/0x20
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff813955f6>]
>> security_d_instantiate+0x36/0x60
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81287c34>] d_instantiate+0x54/0x70
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff8120111c>]
>> __shmem_file_setup+0xdc/0x240
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81201290>]
>> shmem_file_setup+0x10/0x20
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff813856e0>] newseg+0x290/0x3a0
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff8137e278>] ipcget+0x208/0x2d0
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81386074>] SyS_shmget+0x54/0x70
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81871d2e>]
>> entry_SYSCALL_64_fastpath+0x12/0x76
>> Jul 22 14:36:40 fc23 kernel: #012-> #0 (&ids->rwsem){+++++.}:
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81108df8>]
>> __lock_acquire+0x1a78/0x1d00
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff8186efba>] down_write+0x5a/0xc0
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81385354>] shm_close+0x34/0x130
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff812203a5>] remove_vma+0x45/0x80
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81222a30>] do_munmap+0x2b0/0x460
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81386c25>] SyS_shmdt+0xb5/0x180
>> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81871d2e>]
>> entry_SYSCALL_64_fastpath+0x12/0x76
>> Jul 22 14:36:40 fc23 kernel: #012other info that might help us debug this:
>> Jul 22 14:36:40 fc23 kernel: Chain exists of:#012  &ids->rwsem -->
>> &xfs_dir_ilock_class --> &mm->mmap_sem
>> Jul 22 14:36:40 fc23 kernel: Possible unsafe locking scenario:
>> Jul 22 14:36:40 fc23 kernel:       CPU0                    CPU1
>> Jul 22 14:36:40 fc23 kernel:       ----                    ----
>> Jul 22 14:36:40 fc23 kernel:  lock(&mm->mmap_sem);
>> Jul 22 14:36:40 fc23 kernel:
>> lock(&xfs_dir_ilock_class);
>> Jul 22 14:36:40 fc23 kernel:                               lock(&mm->mmap_sem);
>> Jul 22 14:36:40 fc23 kernel:  lock(&ids->rwsem);
>> Jul 22 14:36:40 fc23 kernel: #012 *** DEADLOCK ***
>> Jul 22 14:36:40 fc23 kernel: 1 lock held by httpd/1597:
>> Jul 22 14:36:40 fc23 kernel: #0:  (&mm->mmap_sem){++++++}, at:
>> [<ffffffff81386bbb>] SyS_shmdt+0x4b/0x180
>> Jul 22 14:36:40 fc23 kernel: #012stack backtrace:
>> Jul 22 14:36:40 fc23 kernel: CPU: 7 PID: 1597 Comm: httpd Tainted: G
>>      W       4.2.0-0.rc3.git0.1.fc24.x86_64+debug #1
>> Jul 22 14:36:40 fc23 kernel: Hardware name: VMware, Inc. VMware
>> Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00
>> 05/20/2014
>> Jul 22 14:36:40 fc23 kernel: 0000000000000000 000000006cb6fe9d
>> ffff88019ff07c58 ffffffff81868175
>> Jul 22 14:36:40 fc23 kernel: 0000000000000000 ffffffff82aea390
>> ffff88019ff07ca8 ffffffff81105903
>> Jul 22 14:36:40 fc23 kernel: ffff88019ff07c78 ffff88019ff07d08
>> 0000000000000001 ffff8800b75108f0
>> Jul 22 14:36:40 fc23 kernel: Call Trace:
>> Jul 22 14:36:40 fc23 kernel: [<ffffffff81868175>] dump_stack+0x4c/0x65
>> Jul 22 14:36:40 fc23 kernel: [<ffffffff81105903>] print_circular_bug+0x1e3/0x250
>> Jul 22 14:36:40 fc23 kernel: [<ffffffff81108df8>] __lock_acquire+0x1a78/0x1d00
>> Jul 22 14:36:40 fc23 kernel: [<ffffffff81220c33>] ? unlink_file_vma+0x33/0x60
>> Jul 22 14:36:40 fc23 kernel: [<ffffffff81109a07>] lock_acquire+0xc7/0x270
>> Jul 22 14:36:40 fc23 kernel: [<ffffffff81385354>] ? shm_close+0x34/0x130
>> Jul 22 14:36:40 fc23 kernel: [<ffffffff8186efba>] down_write+0x5a/0xc0
>> Jul 22 14:36:40 fc23 kernel: [<ffffffff81385354>] ? shm_close+0x34/0x130
>> Jul 22 14:36:40 fc23 kernel: [<ffffffff81385354>] shm_close+0x34/0x130
>> Jul 22 14:36:40 fc23 kernel: [<ffffffff812203a5>] remove_vma+0x45/0x80
>> Jul 22 14:36:40 fc23 kernel: [<ffffffff81222a30>] do_munmap+0x2b0/0x460
>> Jul 22 14:36:40 fc23 kernel: [<ffffffff81386bbb>] ? SyS_shmdt+0x4b/0x180
>> Jul 22 14:36:40 fc23 kernel: [<ffffffff81386c25>] SyS_shmdt+0xb5/0x180
>> Jul 22 14:36:40 fc23 kernel: [<ffffffff81871d2e>]
>> entry_SYSCALL_64_fastpath+0x12/0x76
>>
>> Reported-by: Morten Stevens <mstevens@fedoraproject.org>
>> Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
> 
> Acked-by: Hugh Dickins <hughd@google.com>
> but with one reservation below...
> 
>> ---
>> This version only differs in the patch description, which restores
>> the original lockdep trace from Morten Stevens.  It was unfortunately
>> mangled in the prior version.
>>
>>  fs/hugetlbfs/inode.c | 2 ++
>>  ipc/shm.c            | 2 +-
>>  mm/shmem.c           | 4 ++--
>>  3 files changed, 5 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index 0cf74df..973c24c 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -1010,6 +1010,8 @@ struct file *hugetlb_file_setup(const char *name, size_t size,
>>  	inode = hugetlbfs_get_inode(sb, NULL, S_IFREG | S_IRWXUGO, 0);
>>  	if (!inode)
>>  		goto out_dentry;
>> +	if (creat_flags == HUGETLB_SHMFS_INODE)
>> +		inode->i_flags |= S_PRIVATE;
> 
> I wonder if you would do better just to set S_PRIVATE unconditionally
> there.
> 
> hugetlb_file_setup() has two callsites, neither of which exposes an fd.
> One of them is shm.c's newseg(), which is getting us into the lockdep
> trouble that you're fixing here.
> 
> The other is mmap.c's mmap_pgoff().  Now I don't think that will ever
> get into lockdep trouble (no mutex or rwsem has been taken at that
> point), but might your change above introduce (perhaps now or perhaps
> in future) an inconsistency between how SElinux checks are applied to
> a SHM area, and how they are applied to a MAP_ANONYMOUS|MAP_HUGETLB
> area, and how they are applied to a straight MAP_ANONYMOUS area?
> 
> I think your patch as it stands brings SHM into line with
> MAP_ANONYMOUS, but leaves MAP_ANONYMOUS|MAP_HUGETLB going the old way.
> Perhaps an anomaly would appear when mprotect() is used?
> 
> It's up to you: I think your patch is okay as is,
> but I just wonder if it has a surprise in store for the future.

That sounds reasonable, although there is the concern that
hugetlb_file_setup() might be used in the future for files that are
exposed as fds, unless we rename it to hugetlb_kernel_file_setup() or
similar to match shmem_kernel_file_setup().  Also should probably be
done as a separate change on top since it isn't directly related to
ipc/shm or fixing this lockdep.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
