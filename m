Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6616B0254
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 20:24:11 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so4309786pac.3
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 17:24:10 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id dl10si15904876pdb.10.2015.07.23.17.24.09
        for <linux-mm@kvack.org>;
        Thu, 23 Jul 2015 17:24:10 -0700 (PDT)
Date: Fri, 24 Jul 2015 10:11:57 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC][PATCH] ipc: Use private shmem or hugetlbfs inodes for shm
 segments.
Message-ID: <20150724001157.GF3902@dastard>
References: <1437668913-25446-1-git-send-email-sds@tycho.nsa.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437668913-25446-1-git-send-email-sds@tycho.nsa.gov>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: mstevens@fedoraproject.org, linux-kernel@vger.kernel.org, nyc@holomorphy.com, hughd@google.com, akpm@linux-foundation.org, manfred@colorfullife.com, dave@stgolabs.net, linux-mm@kvack.org, wagi@monom.org, prarit@redhat.com, torvalds@linux-foundation.org, esandeen@redhat.com, eparis@redhat.com, selinux@tycho.nsa.gov, paul@paul-moore.com, linux-security-module@vger.kernel.org

On Thu, Jul 23, 2015 at 12:28:33PM -0400, Stephen Smalley wrote:
> The shm implementation internally uses shmem or hugetlbfs inodes
> for shm segments.  As these inodes are never directly exposed to
> userspace and only accessed through the shm operations which are
> already hooked by security modules, mark the inodes with the
> S_PRIVATE flag so that inode security initialization and permission
> checking is skipped.
> 
> This was motivated by the following lockdep warning:
> ===================================================
> [ INFO: possible circular locking dependency detected ]
> 4.2.0-0.rc3.git0.1.fc24.x86_64+debug #1 Tainted: G        W
> -------------------------------------------------------
> httpd/1597 is trying to acquire lock:
> (&ids->rwsem){+++++.}, at: [<ffffffff81385354>] shm_close+0x34/0x130
> (&mm->mmap_sem){++++++}, at: [<ffffffff81386bbb>] SyS_shmdt+0x4b/0x180
>       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
>       [<ffffffff81217baa>] __might_fault+0x7a/0xa0
>       [<ffffffff81284a1e>] filldir+0x9e/0x130
>       [<ffffffffa019bb08>] xfs_dir2_block_getdents.isra.12+0x198/0x1c0 [xfs]
>       [<ffffffffa019c5b4>] xfs_readdir+0x1b4/0x330 [xfs]
>       [<ffffffffa019f38b>] xfs_file_readdir+0x2b/0x30 [xfs]
>       [<ffffffff812847e7>] iterate_dir+0x97/0x130
>       [<ffffffff81284d21>] SyS_getdents+0x91/0x120
>       [<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76
>       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
>       [<ffffffff81101e97>] down_read_nested+0x57/0xa0
>       [<ffffffffa01b0e57>] xfs_ilock+0x167/0x350 [xfs]
>       [<ffffffffa01b10b8>] xfs_ilock_attr_map_shared+0x38/0x50 [xfs]
>       [<ffffffffa014799d>] xfs_attr_get+0xbd/0x190 [xfs]
>       [<ffffffffa01c17ad>] xfs_xattr_get+0x3d/0x70 [xfs]
>       [<ffffffff8129962f>] generic_getxattr+0x4f/0x70
>       [<ffffffff8139ba52>] inode_doinit_with_dentry+0x162/0x670
>       [<ffffffff8139cf69>] sb_finish_set_opts+0xd9/0x230
>       [<ffffffff8139d66c>] selinux_set_mnt_opts+0x35c/0x660
>       [<ffffffff8139ff97>] superblock_doinit+0x77/0xf0
>       [<ffffffff813a0020>] delayed_superblock_init+0x10/0x20
>       [<ffffffff81272d23>] iterate_supers+0xb3/0x110
>       [<ffffffff813a4e5f>] selinux_complete_init+0x2f/0x40
>       [<ffffffff813b47a3>] security_load_policy+0x103/0x600
>       [<ffffffff813a6901>] sel_write_load+0xc1/0x750
>       [<ffffffff8126e817>] __vfs_write+0x37/0x100
>       [<ffffffff8126f229>] vfs_write+0xa9/0x1a0
>       [<ffffffff8126ff48>] SyS_write+0x58/0xd0
>       [<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76
>       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
>       [<ffffffff8186de8f>] mutex_lock_nested+0x7f/0x3e0
>       [<ffffffff8139b9a9>] inode_doinit_with_dentry+0xb9/0x670
>       [<ffffffff8139bf7c>] selinux_d_instantiate+0x1c/0x20
>       [<ffffffff813955f6>] security_d_instantiate+0x36/0x60
>       [<ffffffff81287c34>] d_instantiate+0x54/0x70
>       [<ffffffff8120111c>] __shmem_file_setup+0xdc/0x240
>       [<ffffffff81201290>] shmem_file_setup+0x10/0x20
>       [<ffffffff813856e0>] newseg+0x290/0x3a0
>       [<ffffffff8137e278>] ipcget+0x208/0x2d0
>       [<ffffffff81386074>] SyS_shmget+0x54/0x70
>       [<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76
>       [<ffffffff81108df8>] __lock_acquire+0x1a78/0x1d00
>       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
>       [<ffffffff8186efba>] down_write+0x5a/0xc0
>       [<ffffffff81385354>] shm_close+0x34/0x130
>       [<ffffffff812203a5>] remove_vma+0x45/0x80
>       [<ffffffff81222a30>] do_munmap+0x2b0/0x460
>       [<ffffffff81386c25>] SyS_shmdt+0xb5/0x180
>       [<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76

That's a completely screwed up stack trace. There are *4* syscall
entry points with 4 separate, unrelated syscall chains on that
stack trace, all starting at the same address. How is this a valid
stack trace and not a lockdep bug of some kind?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
