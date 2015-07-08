Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 09C306B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 16:37:09 -0400 (EDT)
Received: by wiclp1 with SMTP id lp1so91457553wic.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 13:37:08 -0700 (PDT)
Received: from mx02.imt-systems.com (mx02.imt-systems.com. [212.224.83.171])
        by mx.google.com with ESMTPS id le4si5998665wjc.18.2015.07.08.13.37.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 13:37:07 -0700 (PDT)
Received: from ucsinet10.imt-systems.com (ucsinet10.imt-systems.com [212.224.83.165])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx02.imt-systems.com (Postfix) with ESMTPS id 3mRXVk5GrTzMwm4L
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 22:37:02 +0200 (CEST)
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	(authenticated bits=0)
	by ucsinet10.imt-systems.com (8.14.7/8.14.7) with ESMTP id t68Kb2SY089135
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 8 Jul 2015 22:37:02 +0200
Received: by wgov12 with SMTP id v12so21404120wgo.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 13:37:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <559D51C2.7060603@tycho.nsa.gov>
References: <alpine.LSU.2.11.1506140944380.11018@eggly.anvils>
	<CAB9W1A2ekXaqHfcUxpmx_5rwxfP+wMHA17BdrA7f=Ey-rp0Lvw@mail.gmail.com>
	<559D51C2.7060603@tycho.nsa.gov>
Date: Wed, 8 Jul 2015 22:37:01 +0200
Message-ID: <CAKSJeF+t5-iKrya_bBFRwLYw2+P4o2mxx6b+zmoD-9yVd0Y0KQ@mail.gmail.com>
Subject: Re: mm: shmem_zero_setup skip security check and lockdep conflict
 with XFS
From: Morten Stevens <mstevens@fedoraproject.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: Stephen Smalley <stephen.smalley@gmail.com>, Hugh Dickins <hughd@google.com>, Prarit Bhargava <prarit@redhat.com>, Morten Stevens <mstevens@fedoraproject.org>, Eric Sandeen <esandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, Daniel Wagner <wagi@monom.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>, linux-mm@kvack.org, selinux <selinux@tycho.nsa.gov>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

2015-07-08 18:37 GMT+02:00 Stephen Smalley <sds@tycho.nsa.gov>:
> On 07/08/2015 09:13 AM, Stephen Smalley wrote:
>> On Sun, Jun 14, 2015 at 12:48 PM, Hugh Dickins <hughd@google.com> wrote:
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
>>
>> This causes a regression for SELinux (please, in the future, cc
>> selinux list and Paul Moore on SELinux-related changes).  In
>> particular, this change disables SELinux checking of mprotect
>> PROT_EXEC on shared anonymous mappings, so we lose the ability to
>> control executable mappings.  That said, we are only getting that
>> check today as a side effect of our file execute check on the tmpfs
>> inode, whereas it would be better (and more consistent with the
>> mmap-time checks) to apply an execmem check in that case, in which
>> case we wouldn't care about the inode-based check.  However, I am
>> unclear on how to correctly detect that situation from
>> selinux_file_mprotect() -> file_map_prot_check(), because we do have a
>> non-NULL vma->vm_file so we treat it as a file execute check.  In
>> contrast, if directly creating an anonymous shared mapping with
>> PROT_EXEC via mmap(...PROT_EXEC...),  selinux_mmap_file is called with
>> a NULL file and therefore we end up applying an execmem check.
>
> Also, can you provide the lockdep traces that motivated this change?

Yes, here is it:

[   28.177939] ======================================================
[   28.177959] [ INFO: possible circular locking dependency detected ]
[   28.177980] 4.1.0-0.rc7.git0.1.fc23.x86_64+debug #1 Tainted: G        W
[   28.178002] -------------------------------------------------------
[   28.178022] sshd/1764 is trying to acquire lock:
[   28.178037]  (&isec->lock){+.+.+.}, at: [<ffffffff813b52c5>]
inode_doinit_with_dentry+0xc5/0x6a0
[   28.178078]
               but task is already holding lock:
[   28.178097]  (&mm->mmap_sem){++++++}, at: [<ffffffff81216a0f>]
vm_mmap_pgoff+0x8f/0xf0
[   28.178131]
               which lock already depends on the new lock.

[   28.178157]
               the existing dependency chain (in reverse order) is:
[   28.178180]
               -> #2 (&mm->mmap_sem){++++++}:
[   28.178201]        [<ffffffff81114017>] lock_acquire+0xc7/0x2a0
[   28.178225]        [<ffffffff8122853c>] might_fault+0x8c/0xb0
[   28.178248]        [<ffffffff8129af3a>] filldir+0x9a/0x130
[   28.178269]        [<ffffffffa019cfd6>]
xfs_dir2_block_getdents.isra.12+0x1a6/0x1d0 [xfs]
[   28.178330]        [<ffffffffa019dae4>] xfs_readdir+0x1c4/0x360 [xfs]
[   28.178368]        [<ffffffffa01a0a5b>] xfs_file_readdir+0x2b/0x30 [xfs]
[   28.178404]        [<ffffffff8129ad0a>] iterate_dir+0x9a/0x140
[   28.178425]        [<ffffffff8129b241>] SyS_getdents+0x91/0x120
[   28.178447]        [<ffffffff818a016e>] system_call_fastpath+0x12/0x76
[   28.178471]
               -> #1 (&xfs_dir_ilock_class){++++.+}:
[   28.178494]        [<ffffffff81114017>] lock_acquire+0xc7/0x2a0
[   28.178515]        [<ffffffff8110bee7>] down_read_nested+0x57/0xa0
[   28.178538]        [<ffffffffa01b2ed1>] xfs_ilock+0x171/0x390 [xfs]
[   28.178579]        [<ffffffffa01b3168>]
xfs_ilock_attr_map_shared+0x38/0x50 [xfs]
[   28.178618]        [<ffffffffa0145d8d>] xfs_attr_get+0xbd/0x1b0 [xfs]
[   28.178651]        [<ffffffffa01c44ad>] xfs_xattr_get+0x3d/0x80 [xfs]
[   28.178688]        [<ffffffff812b022f>] generic_getxattr+0x4f/0x70
[   28.178711]        [<ffffffff813b5372>] inode_doinit_with_dentry+0x172/0x6a0
[   28.178737]        [<ffffffff813b68db>] sb_finish_set_opts+0xdb/0x260
[   28.178759]        [<ffffffff813b6ff1>] selinux_set_mnt_opts+0x331/0x670
[   28.178783]        [<ffffffff813b9b47>] superblock_doinit+0x77/0xf0
[   28.178804]        [<ffffffff813b9bd0>] delayed_superblock_init+0x10/0x20
[   28.178849]        [<ffffffff8128691a>] iterate_supers+0xba/0x120
[   28.178872]        [<ffffffff813bef23>] selinux_complete_init+0x33/0x40
[   28.178897]        [<ffffffff813cf313>] security_load_policy+0x103/0x640
[   28.178920]        [<ffffffff813c0a76>] sel_write_load+0xb6/0x790
[   28.179482]        [<ffffffff812821f7>] __vfs_write+0x37/0x110
[   28.180047]        [<ffffffff81282c89>] vfs_write+0xa9/0x1c0
[   28.180630]        [<ffffffff81283a1c>] SyS_write+0x5c/0xd0
[   28.181168]        [<ffffffff818a016e>] system_call_fastpath+0x12/0x76
[   28.181740]
               -> #0 (&isec->lock){+.+.+.}:
[   28.182808]        [<ffffffff81113331>] __lock_acquire+0x1b31/0x1e40
[   28.183347]        [<ffffffff81114017>] lock_acquire+0xc7/0x2a0
[   28.183897]        [<ffffffff8189c10d>] mutex_lock_nested+0x7d/0x460
[   28.184427]        [<ffffffff813b52c5>] inode_doinit_with_dentry+0xc5/0x6a0
[   28.184944]        [<ffffffff813b58bc>] selinux_d_instantiate+0x1c/0x20
[   28.185470]        [<ffffffff813b07ab>] security_d_instantiate+0x1b/0x30
[   28.185980]        [<ffffffff8129e8c4>] d_instantiate+0x54/0x80
[   28.186495]        [<ffffffff81211edc>] __shmem_file_setup+0xdc/0x250
[   28.186990]        [<ffffffff812164a8>] shmem_zero_setup+0x28/0x70
[   28.187500]        [<ffffffff8123471c>] mmap_region+0x66c/0x680
[   28.188006]        [<ffffffff81234a53>] do_mmap_pgoff+0x323/0x410
[   28.188500]        [<ffffffff81216a30>] vm_mmap_pgoff+0xb0/0xf0
[   28.189005]        [<ffffffff81232bf6>] SyS_mmap_pgoff+0x116/0x2b0
[   28.189490]        [<ffffffff810232bb>] SyS_mmap+0x1b/0x30
[   28.189975]        [<ffffffff818a016e>] system_call_fastpath+0x12/0x76
[   28.190474]
               other info that might help us debug this:

[   28.191901] Chain exists of:
                 &isec->lock --> &xfs_dir_ilock_class --> &mm->mmap_sem

[   28.193327]  Possible unsafe locking scenario:

[   28.194297]        CPU0                    CPU1
[   28.194774]        ----                    ----
[   28.195254]   lock(&mm->mmap_sem);
[   28.195709]                                lock(&xfs_dir_ilock_class);
[   28.196174]                                lock(&mm->mmap_sem);
[   28.196654]   lock(&isec->lock);
[   28.197108]
                *** DEADLOCK ***

[   28.198451] 1 lock held by sshd/1764:
[   28.198900]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81216a0f>]
vm_mmap_pgoff+0x8f/0xf0
[   28.199370]
               stack backtrace:
[   28.200276] CPU: 2 PID: 1764 Comm: sshd Tainted: G        W
4.1.0-0.rc7.git0.1.fc23.x86_64+debug #1
[   28.200753] Hardware name: VMware, Inc. VMware Virtual
Platform/440BX Desktop Reference Platform, BIOS 6.00 05/20/2014
[   28.201246]  0000000000000000 00000000eda89a94 ffff8800a86a39c8
ffffffff81896375
[   28.201771]  0000000000000000 ffffffff82a910d0 ffff8800a86a3a18
ffffffff8110fbd6
[   28.202275]  0000000000000002 ffff8800a86a3a78 0000000000000001
ffff8800a897b008
[   28.203099] Call Trace:
[   28.204237]  [<ffffffff81896375>] dump_stack+0x4c/0x65
[   28.205362]  [<ffffffff8110fbd6>] print_circular_bug+0x206/0x280
[   28.206502]  [<ffffffff81113331>] __lock_acquire+0x1b31/0x1e40
[   28.207650]  [<ffffffff81114017>] lock_acquire+0xc7/0x2a0
[   28.208758]  [<ffffffff813b52c5>] ? inode_doinit_with_dentry+0xc5/0x6a0
[   28.209902]  [<ffffffff8189c10d>] mutex_lock_nested+0x7d/0x460
[   28.211023]  [<ffffffff813b52c5>] ? inode_doinit_with_dentry+0xc5/0x6a0
[   28.212162]  [<ffffffff813b52c5>] ? inode_doinit_with_dentry+0xc5/0x6a0
[   28.213283]  [<ffffffff81027e7d>] ? native_sched_clock+0x2d/0xa0
[   28.214403]  [<ffffffff81027ef9>] ? sched_clock+0x9/0x10
[   28.215514]  [<ffffffff813b52c5>] inode_doinit_with_dentry+0xc5/0x6a0
[   28.216656]  [<ffffffff813b58bc>] selinux_d_instantiate+0x1c/0x20
[   28.217776]  [<ffffffff813b07ab>] security_d_instantiate+0x1b/0x30
[   28.218902]  [<ffffffff8129e8c4>] d_instantiate+0x54/0x80
[   28.219992]  [<ffffffff81211edc>] __shmem_file_setup+0xdc/0x250
[   28.221112]  [<ffffffff812164a8>] shmem_zero_setup+0x28/0x70
[   28.222234]  [<ffffffff8123471c>] mmap_region+0x66c/0x680
[   28.223362]  [<ffffffff81234a53>] do_mmap_pgoff+0x323/0x410
[   28.224493]  [<ffffffff81216a0f>] ? vm_mmap_pgoff+0x8f/0xf0
[   28.225643]  [<ffffffff81216a30>] vm_mmap_pgoff+0xb0/0xf0
[   28.226771]  [<ffffffff81232bf6>] SyS_mmap_pgoff+0x116/0x2b0
[   28.227900]  [<ffffffff812996ce>] ? SyS_fcntl+0x5de/0x760
[   28.229042]  [<ffffffff810232bb>] SyS_mmap+0x1b/0x30
[   28.230156]  [<ffffffff818a016e>] system_call_fastpath+0x12/0x76
[   46.520367] Adjusting tsc more than 11% (5419175 vs 7179037)


Best regards,

Morten

>
>>
>>>
>>> Reported-and-tested-by: Prarit Bhargava <prarit@redhat.com>
>>> Reported-by: Daniel Wagner <wagi@monom.org>
>>> Reported-by: Morten Stevens <mstevens@fedoraproject.org>
>>> Signed-off-by: Hugh Dickins <hughd@google.com>
>>> ---
>>>
>>>  mm/shmem.c |    8 +++++++-
>>>  1 file changed, 7 insertions(+), 1 deletion(-)
>>>
>>> --- 4.1-rc7/mm/shmem.c  2015-04-26 19:16:31.352191298 -0700
>>> +++ linux/mm/shmem.c    2015-06-14 09:26:49.461120166 -0700
>>> @@ -3401,7 +3401,13 @@ int shmem_zero_setup(struct vm_area_stru
>>>         struct file *file;
>>>         loff_t size = vma->vm_end - vma->vm_start;
>>>
>>> -       file = shmem_file_setup("dev/zero", size, vma->vm_flags);
>>> +       /*
>>> +        * Cloning a new file under mmap_sem leads to a lock ordering conflict
>>> +        * between XFS directory reading and selinux: since this file is only
>>> +        * accessible to the user through its mapping, use S_PRIVATE flag to
>>> +        * bypass file security, in the same way as shmem_kernel_file_setup().
>>> +        */
>>> +       file = __shmem_file_setup("dev/zero", size, vma->vm_flags, S_PRIVATE);
>>>         if (IS_ERR(file))
>>>                 return PTR_ERR(file);
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at  http://www.tux.org/lkml/
>> _______________________________________________
>> Selinux mailing list
>> Selinux@tycho.nsa.gov
>> To unsubscribe, send email to Selinux-leave@tycho.nsa.gov.
>> To get help, send an email containing "help" to Selinux-request@tycho.nsa.gov.
>>
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
