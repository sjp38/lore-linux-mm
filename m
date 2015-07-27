Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id ADD436B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 18:02:18 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so58566480pdr.2
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 15:02:18 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id y5si33981098pdf.59.2015.07.27.15.02.16
        for <linux-mm@kvack.org>;
        Mon, 27 Jul 2015 15:02:17 -0700 (PDT)
Date: Tue, 28 Jul 2015 08:01:53 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2] ipc: Use private shmem or hugetlbfs inodes for shm
 segments.
Message-ID: <20150727220153.GI3902@dastard>
References: <1437741275-5388-1-git-send-email-sds@tycho.nsa.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437741275-5388-1-git-send-email-sds@tycho.nsa.gov>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: mstevens@fedoraproject.org, linux-kernel@vger.kernel.org, nyc@holomorphy.com, hughd@google.com, akpm@linux-foundation.org, manfred@colorfullife.com, dave@stgolabs.net, linux-mm@kvack.org, wagi@monom.org, prarit@redhat.com, torvalds@linux-foundation.org, esandeen@redhat.com, eparis@redhat.com, selinux@tycho.nsa.gov, paul@paul-moore.com, linux-security-module@vger.kernel.org

On Fri, Jul 24, 2015 at 08:34:35AM -0400, Stephen Smalley wrote:
> The shm implementation internally uses shmem or hugetlbfs inodes
> for shm segments.  As these inodes are never directly exposed to
> userspace and only accessed through the shm operations which are
> already hooked by security modules, mark the inodes with the
> S_PRIVATE flag so that inode security initialization and permission
> checking is skipped.
> 
> This was motivated by the following lockdep warning:
> Jul 22 14:36:40 fc23 kernel:
> ======================================================
> Jul 22 14:36:40 fc23 kernel: [ INFO: possible circular locking
> dependency detected ]
> Jul 22 14:36:40 fc23 kernel: 4.2.0-0.rc3.git0.1.fc24.x86_64+debug #1
> Tainted: G        W
> Jul 22 14:36:40 fc23 kernel:
> -------------------------------------------------------
> Jul 22 14:36:40 fc23 kernel: httpd/1597 is trying to acquire lock:
> Jul 22 14:36:40 fc23 kernel: (&ids->rwsem){+++++.}, at:
> [<ffffffff81385354>] shm_close+0x34/0x130
> Jul 22 14:36:40 fc23 kernel: #012but task is already holding lock:
> Jul 22 14:36:40 fc23 kernel: (&mm->mmap_sem){++++++}, at:
> [<ffffffff81386bbb>] SyS_shmdt+0x4b/0x180
> Jul 22 14:36:40 fc23 kernel: #012which lock already depends on the new lock.
> Jul 22 14:36:40 fc23 kernel: #012the existing dependency chain (in
> reverse order) is:
> Jul 22 14:36:40 fc23 kernel: #012-> #3 (&mm->mmap_sem){++++++}:
> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81217baa>] __might_fault+0x7a/0xa0
> Jul 22 14:36:40 fc23 kernel:       [<ffffffff81284a1e>] filldir+0x9e/0x130
> Jul 22 14:36:40 fc23 kernel:       [<ffffffffa019bb08>]
> xfs_dir2_block_getdents.isra.12+0x198/0x1c0 [xfs]
> Jul 22 14:36:40 fc23 kernel:       [<ffffffffa019c5b4>]
[....]

This was send via git-send-email, which means that you've mangled
the line wrapping when you pasted the stack trace into the git
commit message.  I strongly suggest that you trim the data/kernel
part of these traces as it is unneccessary information, and it makes
it harder to read. i.e the trace in the commit message should look
more like:

======================================================
 [ INFO: possible circular locking dependency detected ]
 4.2.0-0.rc3.git0.1.fc24.x86_64+debug #1 Tainted: G        W
-------------------------------------------------------
 httpd/1597 is trying to acquire lock:
 (&ids->rwsem){+++++.}, at: [<ffffffff81385354>] shm_close+0x34/0x130
 #012but task is already holding lock:
 (&mm->mmap_sem){++++++}, at: [<ffffffff81386bbb>] SyS_shmdt+0x4b/0x180
 #012which lock already depends on the new lock.
 #012the existing dependency chain (in reverse order) is:
 #012-> #3 (&mm->mmap_sem){++++++}:
       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
       [<ffffffff81217baa>] __might_fault+0x7a/0xa0
       [<ffffffff81284a1e>] filldir+0x9e/0x130
       [<ffffffffa019bb08>] xfs_dir2_block_getdents.isra.12+0x198/0x1c0 [xfs]
       [<ffffffffa019c5b4>] xfs_readdir+0x1b4/0x330 [xfs]
       [<ffffffffa019f38b>] xfs_file_readdir+0x2b/0x30 [xfs]
       [<ffffffff812847e7>] iterate_dir+0x97/0x130
       [<ffffffff81284d21>] SyS_getdents+0x91/0x120
       [<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76
 #012-> #2 (&xfs_dir_ilock_class){++++.+}:
       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
       [<ffffffff81101e97>] down_read_nested+0x57/0xa0
       [<ffffffffa01b0e57>] xfs_ilock+0x167/0x350 [xfs]
       [<ffffffffa01b10b8>] xfs_ilock_attr_map_shared+0x38/0x50 [xfs]
       [<ffffffffa014799d>] xfs_attr_get+0xbd/0x190 [xfs]
       [<ffffffffa01c17ad>] xfs_xattr_get+0x3d/0x70 [xfs]
       [<ffffffff8129962f>] generic_getxattr+0x4f/0x70
       [<ffffffff8139ba52>] inode_doinit_with_dentry+0x162/0x670
       [<ffffffff8139cf69>] sb_finish_set_opts+0xd9/0x230
       [<ffffffff8139d66c>] selinux_set_mnt_opts+0x35c/0x660
       [<ffffffff8139ff97>] superblock_doinit+0x77/0xf0
       [<ffffffff813a0020>] delayed_superblock_init+0x10/0x20
       [<ffffffff81272d23>] iterate_supers+0xb3/0x110
       [<ffffffff813a4e5f>] selinux_complete_init+0x2f/0x40
       [<ffffffff813b47a3>] security_load_policy+0x103/0x600
       [<ffffffff813a6901>] sel_write_load+0xc1/0x750
       [<ffffffff8126e817>] __vfs_write+0x37/0x100
       [<ffffffff8126f229>] vfs_write+0xa9/0x1a0
       [<ffffffff8126ff48>] SyS_write+0x58/0xd0
       [<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76
....

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
