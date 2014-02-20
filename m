Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id BDDC16B0037
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 19:13:57 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so1057213pdj.33
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 16:13:57 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id ey10si1385755pab.111.2014.02.19.16.13.54
        for <linux-mm@kvack.org>;
        Wed, 19 Feb 2014 16:13:55 -0800 (PST)
Date: Thu, 20 Feb 2014 11:13:29 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: mmap_sem -> isec->lock lockdep issues with shmem (was Re: [PATCH
 2/3] xfs: fix directory inode iolock lockdep false positive)
Message-ID: <20140220001329.GG4916@dastard>
References: <1392783402-4726-1-git-send-email-david@fromorbit.com>
 <1392783402-4726-3-git-send-email-david@fromorbit.com>
 <5304F70C.8070601@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5304F70C.8070601@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org, linux-security-module@vger.kernel.org

[cc linux-mm because it shmem craziness that is causing the problem]
[cc linux-security-module because it is security contexts that need
 lockdep annotations.]

On Wed, Feb 19, 2014 at 01:25:16PM -0500, Brian Foster wrote:
> On 02/18/2014 11:16 PM, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > The change to add the IO lock to protect the directory extent map
> > during readdir operations has cause lockdep to have a heart attack
> > as it now sees a different locking order on inodes w.r.t. the
> > mmap_sem because readdir has a different ordering to write().
> > 
> > Add a new lockdep class for directory inodes to avoid this false
> > positive.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> 
> Hey Dave,
> 
> I'm not terribly familiar with lockdep, but I hit the attached "possible
> circular locking dependency detected" warning when running with this patch.
> 
> (Reproduces by running generic/001 after a reboot).

Ok, you're testing on an selinux enabled system, I didn't.

> Feb 19 12:22:03 localhost kernel: [  101.487018] 
> Feb 19 12:22:03 localhost kernel: [  101.487018] -> #2 (&xfs_dir_ilock_class){++++..}:
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff810f3ec2>] lock_acquire+0xa2/0x1d0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff810ed147>] down_read_nested+0x57/0xa0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffffa05a0022>] xfs_ilock+0x122/0x250 [xfs]
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffffa05a01af>] xfs_ilock_attr_map_shared+0x1f/0x50 [xfs]
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffffa0565d50>] xfs_attr_get+0x90/0xe0 [xfs]
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffffa055b9d7>] xfs_xattr_get+0x37/0x50 [xfs]
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff812483ef>] generic_getxattr+0x4f/0x70
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff8133fd5e>] inode_doinit_with_dentry+0x1ae/0x650
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff813402d8>] sb_finish_set_opts+0xd8/0x270
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff81340702>] selinux_set_mnt_opts+0x292/0x5f0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff81340ac8>] superblock_doinit+0x68/0xd0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff81340b8d>] selinux_sb_kern_mount+0x3d/0xa0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff81335536>] security_sb_kern_mount+0x16/0x20
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff8122333a>] mount_fs+0x8a/0x1b0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff8124285b>] vfs_kern_mount+0x6b/0x150
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff8124561e>] do_mount+0x23e/0xb90
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff812462a3>] SyS_mount+0x83/0xc0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff8178ed69>] system_call_fastpath+0x16/0x1b

So, we take the ilock on the directory xattr read path during
security attribute initialisation so we have a inode->i_isec->lock -> ilock
path, which is normal.

> Feb 19 12:22:03 localhost kernel: [  101.487018] -> #1 (&isec->lock){+.+.+.}:
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff810f3ec2>] lock_acquire+0xa2/0x1d0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff81780d77>] mutex_lock_nested+0x77/0x3f0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff8133fc42>] inode_doinit_with_dentry+0x92/0x650
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff81340dcc>] selinux_d_instantiate+0x1c/0x20
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff8133517b>] security_d_instantiate+0x1b/0x30
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff81237d70>] d_instantiate+0x50/0x70
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff811bcb70>] __shmem_file_setup+0xe0/0x1d0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff811bf988>] shmem_zero_setup+0x28/0x70
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff811d8653>] mmap_region+0x543/0x5a0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff811d89b1>] do_mmap_pgoff+0x301/0x3c0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff811c18f0>] vm_mmap_pgoff+0x90/0xc0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff811d6f26>] SyS_mmap_pgoff+0x116/0x270
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff8101f9b2>] SyS_mmap+0x22/0x30
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff8178ed69>] system_call_fastpath+0x16/0x1b

What the hell?  We instantiate an shmem filesystem *inode* under the
mmap_sem? 

And so we have a mmap_sem -> inode->i_isec->lock path on a *shmem* inode.


> Feb 19 12:22:03 localhost kernel: [  101.487018] 
> Feb 19 12:22:03 localhost kernel: [  101.487018] -> #0 (&mm->mmap_sem){++++++}:
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff810f351c>] __lock_acquire+0x18ec/0x1aa0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff810f3ec2>] lock_acquire+0xa2/0x1d0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff811cc8fc>] might_fault+0x8c/0xb0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff812341c1>] filldir+0x91/0x120
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffffa053f2f7>] xfs_dir2_sf_getdents+0x317/0x380 [xfs]
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffffa054001b>] xfs_readdir+0x16b/0x230 [xfs]
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffffa05427fb>] xfs_file_readdir+0x2b/0x40 [xfs]
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff81234008>] iterate_dir+0xa8/0xe0
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff812344b3>] SyS_getdents+0x93/0x120
> Feb 19 12:22:03 localhost kernel: [  101.487018]        [<ffffffff8178ed69>] system_call_fastpath+0x16/0x1b

And then we have the mmap_sem in readdir, which inode->ilock ->
mmap_sem.


> Feb 19 12:22:03 localhost kernel: [  101.487018] 
> Feb 19 12:22:03 localhost kernel: [  101.487018] other info that might help us debug this:
> Feb 19 12:22:03 localhost kernel: [  101.487018] 
> Feb 19 12:22:03 localhost kernel: [  101.487018] Chain exists of:
> Feb 19 12:22:03 localhost kernel: [  101.487018]   &mm->mmap_sem --> &isec->lock --> &xfs_dir_ilock_class
> Feb 19 12:22:03 localhost kernel: [  101.487018] 
> Feb 19 12:22:03 localhost kernel: [  101.487018]  Possible unsafe locking scenario:
> Feb 19 12:22:03 localhost kernel: [  101.487018] 
> Feb 19 12:22:03 localhost kernel: [  101.487018]        CPU0                    CPU1
> Feb 19 12:22:03 localhost kernel: [  101.487018]        ----                    ----
> Feb 19 12:22:03 localhost kernel: [  101.487018]   lock(&xfs_dir_ilock_class);
> Feb 19 12:22:03 localhost kernel: [  101.487018]                                lock(&isec->lock);
> Feb 19 12:22:03 localhost kernel: [  101.487018]                                lock(&xfs_dir_ilock_class);
> Feb 19 12:22:03 localhost kernel: [  101.487018]   lock(&mm->mmap_sem);

So that's just another goddamn false positive.

The problem here is that it's many, many layers away from XFS, and
really doesn't involve XFS at all. It's caused by shmem
instantiating an inode under the mmap_sem...

Basically, the only way I can see that this is even remotely
preventable is that inode->isec->ilock needs a per-sb lockdep
context so that lockdep doesn't confuse the lock heirarchies of
completely unrelated filesystems when someone does something crazy
like the page fault path is currently doing.

Fmeh:

struct super_block {
....
#ifdef CONFIG_SECURITY
        void                    *s_security;
#endif

So I can't even isolate it to the security subsystem pointer in
the superblock because there isn't a generic structure to abstract
security specific stuff from the superblock without having to
implement the same lockdep annotations in every security module
uses xattrs to store security information.

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
