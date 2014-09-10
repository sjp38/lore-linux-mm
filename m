Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id ACE6E6B0037
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 19:26:06 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so7928763pab.18
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:26:06 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id xg2si29803470pab.67.2014.09.10.16.26.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 16:26:05 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id p10so9176027pdj.2
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:26:05 -0700 (PDT)
Date: Wed, 10 Sep 2014 16:24:16 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: lockdep warning when logging in via ssh
In-Reply-To: <5410D3E7.2020804@redhat.com>
Message-ID: <alpine.LSU.2.11.1409101609380.3685@eggly.anvils>
References: <5410D3E7.2020804@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prarit Bhargava <prarit@redhat.com>
Cc: hughd@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Eric Sandeen <esandeen@redhat.com>

On Wed, 10 Sep 2014, Prarit Bhargava wrote:

> I see this when I attempt to login via ssh.  I do not see it if I login on
> the serial console.
> 
> [  201.054547] ======================================================
> [  201.082819] [ INFO: possible circular locking dependency detected ]
> [  201.112071] 3.17.0-rc4+ #1 Not tainted
> [  201.129705] -------------------------------------------------------
> [  201.158238] sshd/8554 is trying to acquire lock:
> [  201.179054]  (&isec->lock){+.+.+.}, at: [<ffffffff812fc885>]
> inode_doinit_with_dentry+0xc5/0x670
> [  201.219847]
> [  201.219847] but task is already holding lock:
> [  201.247255]  (&mm->mmap_sem){++++++}, at: [<ffffffff811d32bf>]
> vm_mmap_pgoff+0x8f/0xf0
> [  201.283640]
> [  201.283640] which lock already depends on the new lock.
> [  201.283640]
> [  201.321218]
> [  201.321218] the existing dependency chain (in reverse order) is:
> [  201.356331]
> -> #2 (&mm->mmap_sem){++++++}:
> [  201.377731]        [<ffffffff810e0d70>] __lock_acquire+0x380/0xb50
> [  201.406027]        [<ffffffff810e1d19>] lock_acquire+0x99/0x1d0
> [  201.432867]        [<ffffffff811e2cbc>] might_fault+0x8c/0xb0
> [  201.458823]        [<ffffffff81251361>] filldir+0x91/0x120
> [  201.483514]        [<ffffffffa01b8d7e>]
> xfs_dir2_block_getdents.isra.12+0x1be/0x220 [xfs]
> [  201.521199]        [<ffffffffa01b8fe4>] xfs_readdir+0x1a4/0x2a0 [xfs]
> [  201.550249]        [<ffffffffa01bb79b>] xfs_file_readdir+0x2b/0x30 [xfs]
> [  201.581293]        [<ffffffff8125114e>] iterate_dir+0xae/0x140
> [  201.607964]        [<ffffffff8125166d>] SyS_getdents+0x9d/0x130
> [  201.635824]        [<ffffffff81725b69>] system_call_fastpath+0x16/0x1b
> [  201.665367]
> -> #1 (&xfs_dir_ilock_class){++++.+}:
> [  201.687368]        [<ffffffff810e0d70>] __lock_acquire+0x380/0xb50
> [  201.716063]        [<ffffffff810e1d19>] lock_acquire+0x99/0x1d0
> [  201.743603]        [<ffffffff810da997>] down_read_nested+0x57/0xa0
> [  201.771960]        [<ffffffffa01ca662>] xfs_ilock+0x122/0x250 [xfs]
> [  201.800555]        [<ffffffffa01ca804>] xfs_ilock_attr_map_shared+0x34/0x40 [xfs]
> [  201.834681]        [<ffffffffa016a4f0>] xfs_attr_get+0xc0/0x1b0 [xfs]
> [  201.864877]        [<ffffffffa01dafbd>] xfs_xattr_get+0x3d/0x80 [xfs]
> [  201.895005]        [<ffffffff81265f7f>] generic_getxattr+0x4f/0x70
> [  201.923173]        [<ffffffff812fc932>] inode_doinit_with_dentry+0x172/0x670
> [  201.955329]        [<ffffffff812fcf08>] sb_finish_set_opts+0xd8/0x270
> [  201.984446]        [<ffffffff812fd36d>] selinux_set_mnt_opts+0x2cd/0x630
> [  202.015726]        [<ffffffff812fd747>] superblock_doinit+0x77/0xf0
> [  202.044073]        [<ffffffff812fd7d0>] delayed_superblock_init+0x10/0x20
> [  202.074967]        [<ffffffff8123f372>] iterate_supers+0xb2/0x110
> [  202.103173]        [<ffffffff812fefe3>] selinux_complete_init+0x33/0x40
> [  202.133771]        [<ffffffff8130eea3>] security_load_policy+0x103/0x620
> [  202.164131]        [<ffffffff81300d4b>] sel_write_load+0xbb/0x780
> [  202.191891]        [<ffffffff8123b64a>] vfs_write+0xba/0x1f0
> [  202.217918]        [<ffffffff8123c298>] SyS_write+0x58/0xd0
> [  202.243473]        [<ffffffff81725b69>] system_call_fastpath+0x16/0x1b
> [  202.273205]
> -> #0 (&isec->lock){+.+.+.}:
> [  202.292818]        [<ffffffff810dff29>] validate_chain.isra.43+0x10d9/0x1170
> [  202.324616]        [<ffffffff810e0d70>] __lock_acquire+0x380/0xb50
> [  202.352176]        [<ffffffff810e1d19>] lock_acquire+0x99/0x1d0
> [  202.379637]        [<ffffffff817209e8>] mutex_lock_nested+0x88/0x520
> [  202.408647]        [<ffffffff812fc885>] inode_doinit_with_dentry+0xc5/0x670
> [  202.440389]        [<ffffffff812fda7c>] selinux_d_instantiate+0x1c/0x20
> [  202.470704]        [<ffffffff812f138b>] security_d_instantiate+0x1b/0x30
> [  202.501868]        [<ffffffff812555f0>] d_instantiate+0x50/0x70
> [  202.528664]        [<ffffffff811cef9f>] __shmem_file_setup+0xef/0x1f0
> [  202.557658]        [<ffffffff811d2c88>] shmem_zero_setup+0x28/0x70
> [  202.585826]        [<ffffffff811ee402>] mmap_region+0x522/0x610
> [  202.613190]        [<ffffffff811ee7f1>] do_mmap_pgoff+0x301/0x3d0
> [  202.641687]        [<ffffffff811d32e0>] vm_mmap_pgoff+0xb0/0xf0
> [  202.668753]        [<ffffffff811ecce6>] SyS_mmap_pgoff+0x116/0x290
> [  202.697026]        [<ffffffff810211a2>] SyS_mmap+0x22/0x30
> [  202.722424]        [<ffffffff81725b69>] system_call_fastpath+0x16/0x1b
> [  202.751931]
> [  202.751931] other info that might help us debug this:
> [  202.751931]
> [  202.788578] Chain exists of:
>   &isec->lock --> &xfs_dir_ilock_class --> &mm->mmap_sem
> 
> [  202.824995]  Possible unsafe locking scenario:
> [  202.824995]
> [  202.851334]        CPU0                    CPU1
> [  202.872186]        ----                    ----
> [  202.892929]   lock(&mm->mmap_sem);
> [  202.908542]                                lock(&xfs_dir_ilock_class);
> [  202.938063]                                lock(&mm->mmap_sem);
> [  202.964735]   lock(&isec->lock);
> [  202.979226]
> [  202.979226]  *** DEADLOCK ***
> [  202.979226]
> [  203.006150] 1 lock held by sshd/8554:
> [  203.023836]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff811d32bf>]
> vm_mmap_pgoff+0x8f/0xf0
> [  203.062439]
> [  203.062439] stack backtrace:
> [  203.082082] CPU: 1 PID: 8554 Comm: sshd Not tainted 3.17.0-rc4+ #1
> [  203.110336] Hardware name: HP ProLiant MicroServer Gen8, BIOS J06 08/24/2013
> [  203.143994]  0000000000000 00000000d8562903 ffff88006c333a58 ffffffff8171b358
> [  203.671383]  ffffffff82accf70 ffff88006c333a98 ffffffff8171444a ffff88006c333ad0
> [  203.705097]  ffff88003507b718 ffff88003507b718 0000000000000000 ffff88003507aa10
> [  203.738777] Call Trace:
> [  203.749696]  [<ffffffff8171b358>] dump_stack+0x4d/0x66
> [  203.774113]  [<ffffffff8171444a>] print_circular_bug+0x1f9/0x207
> [  203.801532]  [<ffffffff810dff29>] validate_chain.isra.43+0x10d9/0x1170
> [  203.831325]  [<ffffffff810e0d70>] __lock_acquire+0x380/0xb50
> [  203.857340]  [<ffffffff810e1d19>] lock_acquire+0x99/0x1d0
> [  203.882653]  [<ffffffff812fc885>] ? inode_doinit_with_dentry+0xc5/0x670
> [  203.913148]  [<ffffffff817209e8>] mutex_lock_nested+0x88/0x520
> [  203.939761]  [<ffffffff812fc885>] ? inode_doinit_with_dentry+0xc5/0x670
> [  203.969908]  [<ffffffff812fc885>] ? inode_doinit_with_dentry+0xc5/0x670
> [  203.999854]  [<ffffffff810252c5>] ? native_sched_clock+0x35/0xa0
> [  204.029374]  [<ffffffff81025339>] ? sched_clock+0x9/0x10
> [  204.053170]  [<ffffffff812fc885>] inode_doinit_with_dentry+0xc5/0x670
> [  204.181571]  [<ffffffff810dc67f>] ? lock_release_holdtime.part.28+0xf/0x190
> [  204.213464]  [<ffffffff812fda7c>] selinux_d_instantiate+0x1c/0x20
> [  204.241190]  [<ffffffff812f138b>] security_d_instantiate+0x1b/0x30
> [  204.269524]  [<ffffffff812555f0>] d_instantiate+0x50/0x70
> [  204.293826]  [<ffffffff811cef9f>] __shmem_file_setup+0xef/0x1f0
> [  204.320845]  [<ffffffff811d2c88>] shmem_zero_setup+0x28/0x70
> [  204.346843]  [<ffffffff811ee402>] mmap_region+0x522/0x610
> [  204.371943]  [<ffffffff811ee7f1>] do_mmap_pgoff+0x301/0x3d0
> [  204.398095]  [<ffffffff811d32e0>] vm_mmap_pgoff+0xb0/0xf0
> [  204.422903]  [<ffffffff811ecce6>] SyS_mmap_pgoff+0x116/0x290
> [  204.448487]  [<ffffffff810e05cd>] ? trace_hardirqs_on+0xd/0x10
> [  204.475204]  [<ffffffff810211a2>] SyS_mmap+0x22/0x30
> [  204.498005]  [<ffffffff81725b69>] system_call_fastpath+0x16/0x1b
> [  204.526495] [sched_delayed] sched: RT throttling activated
> 
> According to Dave Chinner:
> 
> "It's the shmem code that is broken - instantiating an inode while
> holding the mmap_sem inverts lock orders all over the place,
> especially in the security subsystem...."

Interesting, thank you.  But it seems a bit late to accuse shmem
of doing the wrong thing here: mmap -> shmem_zero_setup worked this
way in 2.4.0 (if not before) and has done ever since.

Only now is a problem reported, so perhaps a change is needed rather
at the xfs end - unless Dave has a suggestion for how to change it
easily at the shmem end.

Or is xfs not the one to change recently, but something else in the stack?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
