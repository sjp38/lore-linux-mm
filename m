Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 36F499003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 08:39:37 -0400 (EDT)
Received: by qkfc129 with SMTP id c129so13210067qkf.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 05:39:37 -0700 (PDT)
Received: from emvm-gh1-uea08.nsa.gov (emvm-gh1-uea08.nsa.gov. [63.239.67.9])
        by mx.google.com with ESMTP id j15si6296767qhc.33.2015.07.24.05.39.35
        for <linux-mm@kvack.org>;
        Fri, 24 Jul 2015 05:39:36 -0700 (PDT)
Message-ID: <55B231BE.6090304@tycho.nsa.gov>
Date: Fri, 24 Jul 2015 08:38:22 -0400
From: Stephen Smalley <sds@tycho.nsa.gov>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] ipc: Use private shmem or hugetlbfs inodes for shm
 segments.
References: <1437668913-25446-1-git-send-email-sds@tycho.nsa.gov> <20150724001157.GF3902@dastard>
In-Reply-To: <20150724001157.GF3902@dastard>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: prarit@redhat.com, mstevens@fedoraproject.org, manfred@colorfullife.com, esandeen@redhat.com, wagi@monom.org, hughd@google.com, linux-kernel@vger.kernel.org, eparis@redhat.com, linux-mm@kvack.org, linux-security-module@vger.kernel.org, dave@stgolabs.net, nyc@holomorphy.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, selinux@tycho.nsa.gov

On 07/23/2015 08:11 PM, Dave Chinner wrote:
> On Thu, Jul 23, 2015 at 12:28:33PM -0400, Stephen Smalley wrote:
>> The shm implementation internally uses shmem or hugetlbfs inodes
>> for shm segments.  As these inodes are never directly exposed to
>> userspace and only accessed through the shm operations which are
>> already hooked by security modules, mark the inodes with the
>> S_PRIVATE flag so that inode security initialization and permission
>> checking is skipped.
>>
>> This was motivated by the following lockdep warning:
>> ===================================================
>> [ INFO: possible circular locking dependency detected ]
>> 4.2.0-0.rc3.git0.1.fc24.x86_64+debug #1 Tainted: G        W
>> -------------------------------------------------------
>> httpd/1597 is trying to acquire lock:
>> (&ids->rwsem){+++++.}, at: [<ffffffff81385354>] shm_close+0x34/0x130
>> (&mm->mmap_sem){++++++}, at: [<ffffffff81386bbb>] SyS_shmdt+0x4b/0x180
>>       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
>>       [<ffffffff81217baa>] __might_fault+0x7a/0xa0
>>       [<ffffffff81284a1e>] filldir+0x9e/0x130
>>       [<ffffffffa019bb08>] xfs_dir2_block_getdents.isra.12+0x198/0x1c0 [xfs]
>>       [<ffffffffa019c5b4>] xfs_readdir+0x1b4/0x330 [xfs]
>>       [<ffffffffa019f38b>] xfs_file_readdir+0x2b/0x30 [xfs]
>>       [<ffffffff812847e7>] iterate_dir+0x97/0x130
>>       [<ffffffff81284d21>] SyS_getdents+0x91/0x120
>>       [<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76
>>       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
>>       [<ffffffff81101e97>] down_read_nested+0x57/0xa0
>>       [<ffffffffa01b0e57>] xfs_ilock+0x167/0x350 [xfs]
>>       [<ffffffffa01b10b8>] xfs_ilock_attr_map_shared+0x38/0x50 [xfs]
>>       [<ffffffffa014799d>] xfs_attr_get+0xbd/0x190 [xfs]
>>       [<ffffffffa01c17ad>] xfs_xattr_get+0x3d/0x70 [xfs]
>>       [<ffffffff8129962f>] generic_getxattr+0x4f/0x70
>>       [<ffffffff8139ba52>] inode_doinit_with_dentry+0x162/0x670
>>       [<ffffffff8139cf69>] sb_finish_set_opts+0xd9/0x230
>>       [<ffffffff8139d66c>] selinux_set_mnt_opts+0x35c/0x660
>>       [<ffffffff8139ff97>] superblock_doinit+0x77/0xf0
>>       [<ffffffff813a0020>] delayed_superblock_init+0x10/0x20
>>       [<ffffffff81272d23>] iterate_supers+0xb3/0x110
>>       [<ffffffff813a4e5f>] selinux_complete_init+0x2f/0x40
>>       [<ffffffff813b47a3>] security_load_policy+0x103/0x600
>>       [<ffffffff813a6901>] sel_write_load+0xc1/0x750
>>       [<ffffffff8126e817>] __vfs_write+0x37/0x100
>>       [<ffffffff8126f229>] vfs_write+0xa9/0x1a0
>>       [<ffffffff8126ff48>] SyS_write+0x58/0xd0
>>       [<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76
>>       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
>>       [<ffffffff8186de8f>] mutex_lock_nested+0x7f/0x3e0
>>       [<ffffffff8139b9a9>] inode_doinit_with_dentry+0xb9/0x670
>>       [<ffffffff8139bf7c>] selinux_d_instantiate+0x1c/0x20
>>       [<ffffffff813955f6>] security_d_instantiate+0x36/0x60
>>       [<ffffffff81287c34>] d_instantiate+0x54/0x70
>>       [<ffffffff8120111c>] __shmem_file_setup+0xdc/0x240
>>       [<ffffffff81201290>] shmem_file_setup+0x10/0x20
>>       [<ffffffff813856e0>] newseg+0x290/0x3a0
>>       [<ffffffff8137e278>] ipcget+0x208/0x2d0
>>       [<ffffffff81386074>] SyS_shmget+0x54/0x70
>>       [<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76
>>       [<ffffffff81108df8>] __lock_acquire+0x1a78/0x1d00
>>       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
>>       [<ffffffff8186efba>] down_write+0x5a/0xc0
>>       [<ffffffff81385354>] shm_close+0x34/0x130
>>       [<ffffffff812203a5>] remove_vma+0x45/0x80
>>       [<ffffffff81222a30>] do_munmap+0x2b0/0x460
>>       [<ffffffff81386c25>] SyS_shmdt+0xb5/0x180
>>       [<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76
> 
> That's a completely screwed up stack trace. There are *4* syscall
> entry points with 4 separate, unrelated syscall chains on that
> stack trace, all starting at the same address. How is this a valid
> stack trace and not a lockdep bug of some kind?

Sorry, I mangled it when I tried to reformat it from Morten Steven's
original report.  Fixed in v2.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
