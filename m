Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8160F9003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 08:46:47 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so170724326wib.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 05:46:46 -0700 (PDT)
Received: from mx03.imt-systems.com (mx03.imt-systems.com. [212.224.83.172])
        by mx.google.com with ESMTPS id pr9si2299573wjc.194.2015.07.22.05.46.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 05:46:44 -0700 (PDT)
Received: from ucsinet10.imt-systems.com (ucsinet10.imt-systems.com [212.224.83.165])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx03.imt-systems.com (Postfix) with ESMTPS id 3mbxPZ243Gz3xG4
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 14:46:42 +0200 (CEST)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	(authenticated bits=0)
	by ucsinet10.imt-systems.com (8.14.7/8.14.7) with ESMTP id t6MCkeis018053
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 14:46:42 +0200
Received: by wibud3 with SMTP id ud3so152568114wib.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 05:46:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKSJeFKR+jWYiMiexvqGyBQe-=hGmq0DO0TZK-EQszTwcbmG4A@mail.gmail.com>
References: <alpine.LSU.2.11.1506140944380.11018@eggly.anvils>
	<557E6C0C.3050802@monom.org>
	<CAKSJeFKR+jWYiMiexvqGyBQe-=hGmq0DO0TZK-EQszTwcbmG4A@mail.gmail.com>
Date: Wed, 22 Jul 2015 14:46:40 +0200
Message-ID: <CAKSJeFK3ZxWRDg5pwBqgMWXkzatHu+cp5Gx9W+7cyaNMx5qTFA@mail.gmail.com>
Subject: Re: mm: shmem_zero_setup skip security check and lockdep conflict
 with XFS
From: Morten Stevens <mstevens@fedoraproject.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Morten Stevens <mstevens@fedoraproject.org>, Stephen Smalley <sds@tycho.nsa.gov>
Cc: Daniel Wagner <wagi@monom.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Prarit Bhargava <prarit@redhat.com>, Dave Chinner <david@fromorbit.com>, Eric Paris <eparis@redhat.com>, Eric Sandeen <esandeen@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

2015-06-17 13:45 GMT+02:00 Morten Stevens <mstevens@fedoraproject.org>:
> 2015-06-15 8:09 GMT+02:00 Daniel Wagner <wagi@monom.org>:
>> On 06/14/2015 06:48 PM, Hugh Dickins wrote:
>>> It appears that, at some point last year, XFS made directory handling
>>> changes which bring it into lockdep conflict with shmem_zero_setup():
>>> it is surprising that mmap() can clone an inode while holding mmap_sem,
>>> but that has been so for many years.
>>>
>>> Since those few lockdep traces that I've seen all implicated selinux,
>>> I'm hoping that we can use the __shmem_file_setup(,,,S_PRIVATE) which
>>> v3.13's commit c7277090927a ("security: shmem: implement kernel private
>>> shmem inodes") introduced to avoid LSM checks on kernel-internal inodes:
>>> the mmap("/dev/zero") cloned inode is indeed a kernel-internal detail.
>>>
>>> This also covers the !CONFIG_SHMEM use of ramfs to support /dev/zero
>>> (and MAP_SHARED|MAP_ANONYMOUS).  I thought there were also drivers
>>> which cloned inode in mmap(), but if so, I cannot locate them now.
>>>
>>> Reported-and-tested-by: Prarit Bhargava <prarit@redhat.com>
>>> Reported-by: Daniel Wagner <wagi@monom.org>
>>
>> Reported-and-tested-by: Daniel Wagner <wagi@monom.org>
>>
>> Sorry for the long delay. It took me a while to figure out my original
>> setup. I could verify that this patch made the lockdep message go away
>> on 4.0-rc6 and also on 4.1-rc8.
>
> Yes, it's also fixed for me after applying this patch to 4.1-rc8.

Here is another deadlock with the latest 4.2.0-rc3:

Jul 22 14:36:40 fc23 kernel:
======================================================
Jul 22 14:36:40 fc23 kernel: [ INFO: possible circular locking
dependency detected ]
Jul 22 14:36:40 fc23 kernel: 4.2.0-0.rc3.git0.1.fc24.x86_64+debug #1
Tainted: G        W
Jul 22 14:36:40 fc23 kernel:
-------------------------------------------------------
Jul 22 14:36:40 fc23 kernel: httpd/1597 is trying to acquire lock:
Jul 22 14:36:40 fc23 kernel: (&ids->rwsem){+++++.}, at:
[<ffffffff81385354>] shm_close+0x34/0x130
Jul 22 14:36:40 fc23 kernel: #012but task is already holding lock:
Jul 22 14:36:40 fc23 kernel: (&mm->mmap_sem){++++++}, at:
[<ffffffff81386bbb>] SyS_shmdt+0x4b/0x180
Jul 22 14:36:40 fc23 kernel: #012which lock already depends on the new lock.
Jul 22 14:36:40 fc23 kernel: #012the existing dependency chain (in
reverse order) is:
Jul 22 14:36:40 fc23 kernel: #012-> #3 (&mm->mmap_sem){++++++}:
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81217baa>] __might_fault+0x7a/0xa0
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81284a1e>] filldir+0x9e/0x130
Jul 22 14:36:40 fc23 kernel:       [<ffffffffa019bb08>]
xfs_dir2_block_getdents.isra.12+0x198/0x1c0 [xfs]
Jul 22 14:36:40 fc23 kernel:       [<ffffffffa019c5b4>]
xfs_readdir+0x1b4/0x330 [xfs]
Jul 22 14:36:40 fc23 kernel:       [<ffffffffa019f38b>]
xfs_file_readdir+0x2b/0x30 [xfs]
Jul 22 14:36:40 fc23 kernel:       [<ffffffff812847e7>] iterate_dir+0x97/0x130
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81284d21>] SyS_getdents+0x91/0x120
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81871d2e>]
entry_SYSCALL_64_fastpath+0x12/0x76
Jul 22 14:36:40 fc23 kernel: #012-> #2 (&xfs_dir_ilock_class){++++.+}:
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81101e97>]
down_read_nested+0x57/0xa0
Jul 22 14:36:40 fc23 kernel:       [<ffffffffa01b0e57>]
xfs_ilock+0x167/0x350 [xfs]
Jul 22 14:36:40 fc23 kernel:       [<ffffffffa01b10b8>]
xfs_ilock_attr_map_shared+0x38/0x50 [xfs]
Jul 22 14:36:40 fc23 kernel:       [<ffffffffa014799d>]
xfs_attr_get+0xbd/0x190 [xfs]
Jul 22 14:36:40 fc23 kernel:       [<ffffffffa01c17ad>]
xfs_xattr_get+0x3d/0x70 [xfs]
Jul 22 14:36:40 fc23 kernel:       [<ffffffff8129962f>]
generic_getxattr+0x4f/0x70
Jul 22 14:36:40 fc23 kernel:       [<ffffffff8139ba52>]
inode_doinit_with_dentry+0x162/0x670
Jul 22 14:36:40 fc23 kernel:       [<ffffffff8139cf69>]
sb_finish_set_opts+0xd9/0x230
Jul 22 14:36:40 fc23 kernel:       [<ffffffff8139d66c>]
selinux_set_mnt_opts+0x35c/0x660
Jul 22 14:36:40 fc23 kernel:       [<ffffffff8139ff97>]
superblock_doinit+0x77/0xf0
Jul 22 14:36:40 fc23 kernel:       [<ffffffff813a0020>]
delayed_superblock_init+0x10/0x20
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81272d23>]
iterate_supers+0xb3/0x110
Jul 22 14:36:40 fc23 kernel:       [<ffffffff813a4e5f>]
selinux_complete_init+0x2f/0x40
Jul 22 14:36:40 fc23 kernel:       [<ffffffff813b47a3>]
security_load_policy+0x103/0x600
Jul 22 14:36:40 fc23 kernel:       [<ffffffff813a6901>]
sel_write_load+0xc1/0x750
Jul 22 14:36:40 fc23 kernel:       [<ffffffff8126e817>] __vfs_write+0x37/0x100
Jul 22 14:36:40 fc23 kernel:       [<ffffffff8126f229>] vfs_write+0xa9/0x1a0
Jul 22 14:36:40 fc23 kernel:       [<ffffffff8126ff48>] SyS_write+0x58/0xd0
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81871d2e>]
entry_SYSCALL_64_fastpath+0x12/0x76
Jul 22 14:36:40 fc23 kernel: #012-> #1 (&isec->lock){+.+.+.}:
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
Jul 22 14:36:40 fc23 kernel:       [<ffffffff8186de8f>]
mutex_lock_nested+0x7f/0x3e0
Jul 22 14:36:40 fc23 kernel:       [<ffffffff8139b9a9>]
inode_doinit_with_dentry+0xb9/0x670
Jul 22 14:36:40 fc23 kernel:       [<ffffffff8139bf7c>]
selinux_d_instantiate+0x1c/0x20
Jul 22 14:36:40 fc23 kernel:       [<ffffffff813955f6>]
security_d_instantiate+0x36/0x60
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81287c34>] d_instantiate+0x54/0x70
Jul 22 14:36:40 fc23 kernel:       [<ffffffff8120111c>]
__shmem_file_setup+0xdc/0x240
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81201290>]
shmem_file_setup+0x10/0x20
Jul 22 14:36:40 fc23 kernel:       [<ffffffff813856e0>] newseg+0x290/0x3a0
Jul 22 14:36:40 fc23 kernel:       [<ffffffff8137e278>] ipcget+0x208/0x2d0
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81386074>] SyS_shmget+0x54/0x70
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81871d2e>]
entry_SYSCALL_64_fastpath+0x12/0x76
Jul 22 14:36:40 fc23 kernel: #012-> #0 (&ids->rwsem){+++++.}:
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81108df8>]
__lock_acquire+0x1a78/0x1d00
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81109a07>] lock_acquire+0xc7/0x270
Jul 22 14:36:40 fc23 kernel:       [<ffffffff8186efba>] down_write+0x5a/0xc0
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81385354>] shm_close+0x34/0x130
Jul 22 14:36:40 fc23 kernel:       [<ffffffff812203a5>] remove_vma+0x45/0x80
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81222a30>] do_munmap+0x2b0/0x460
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81386c25>] SyS_shmdt+0xb5/0x180
Jul 22 14:36:40 fc23 kernel:       [<ffffffff81871d2e>]
entry_SYSCALL_64_fastpath+0x12/0x76
Jul 22 14:36:40 fc23 kernel: #012other info that might help us debug this:
Jul 22 14:36:40 fc23 kernel: Chain exists of:#012  &ids->rwsem -->
&xfs_dir_ilock_class --> &mm->mmap_sem
Jul 22 14:36:40 fc23 kernel: Possible unsafe locking scenario:
Jul 22 14:36:40 fc23 kernel:       CPU0                    CPU1
Jul 22 14:36:40 fc23 kernel:       ----                    ----
Jul 22 14:36:40 fc23 kernel:  lock(&mm->mmap_sem);
Jul 22 14:36:40 fc23 kernel:
lock(&xfs_dir_ilock_class);
Jul 22 14:36:40 fc23 kernel:                               lock(&mm->mmap_sem);
Jul 22 14:36:40 fc23 kernel:  lock(&ids->rwsem);
Jul 22 14:36:40 fc23 kernel: #012 *** DEADLOCK ***
Jul 22 14:36:40 fc23 kernel: 1 lock held by httpd/1597:
Jul 22 14:36:40 fc23 kernel: #0:  (&mm->mmap_sem){++++++}, at:
[<ffffffff81386bbb>] SyS_shmdt+0x4b/0x180
Jul 22 14:36:40 fc23 kernel: #012stack backtrace:
Jul 22 14:36:40 fc23 kernel: CPU: 7 PID: 1597 Comm: httpd Tainted: G
     W       4.2.0-0.rc3.git0.1.fc24.x86_64+debug #1
Jul 22 14:36:40 fc23 kernel: Hardware name: VMware, Inc. VMware
Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00
05/20/2014
Jul 22 14:36:40 fc23 kernel: 0000000000000000 000000006cb6fe9d
ffff88019ff07c58 ffffffff81868175
Jul 22 14:36:40 fc23 kernel: 0000000000000000 ffffffff82aea390
ffff88019ff07ca8 ffffffff81105903
Jul 22 14:36:40 fc23 kernel: ffff88019ff07c78 ffff88019ff07d08
0000000000000001 ffff8800b75108f0
Jul 22 14:36:40 fc23 kernel: Call Trace:
Jul 22 14:36:40 fc23 kernel: [<ffffffff81868175>] dump_stack+0x4c/0x65
Jul 22 14:36:40 fc23 kernel: [<ffffffff81105903>] print_circular_bug+0x1e3/0x250
Jul 22 14:36:40 fc23 kernel: [<ffffffff81108df8>] __lock_acquire+0x1a78/0x1d00
Jul 22 14:36:40 fc23 kernel: [<ffffffff81220c33>] ? unlink_file_vma+0x33/0x60
Jul 22 14:36:40 fc23 kernel: [<ffffffff81109a07>] lock_acquire+0xc7/0x270
Jul 22 14:36:40 fc23 kernel: [<ffffffff81385354>] ? shm_close+0x34/0x130
Jul 22 14:36:40 fc23 kernel: [<ffffffff8186efba>] down_write+0x5a/0xc0
Jul 22 14:36:40 fc23 kernel: [<ffffffff81385354>] ? shm_close+0x34/0x130
Jul 22 14:36:40 fc23 kernel: [<ffffffff81385354>] shm_close+0x34/0x130
Jul 22 14:36:40 fc23 kernel: [<ffffffff812203a5>] remove_vma+0x45/0x80
Jul 22 14:36:40 fc23 kernel: [<ffffffff81222a30>] do_munmap+0x2b0/0x460
Jul 22 14:36:40 fc23 kernel: [<ffffffff81386bbb>] ? SyS_shmdt+0x4b/0x180
Jul 22 14:36:40 fc23 kernel: [<ffffffff81386c25>] SyS_shmdt+0xb5/0x180
Jul 22 14:36:40 fc23 kernel: [<ffffffff81871d2e>]
entry_SYSCALL_64_fastpath+0x12/0x76

Best regards,

Morten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
