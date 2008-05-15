Received: from larry.melbourne.sgi.com (larry.melbourne.sgi.com [134.14.52.130])
	by relay1.corp.sgi.com (Postfix) with SMTP id 31A1C8F8117
	for <linux-mm@kvack.org>; Thu, 15 May 2008 15:08:12 -0700 (PDT)
Date: Fri, 16 May 2008 08:07:57 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: [xfs-masters] lockdep report (2.6.26-rc2)
Message-ID: <20080515220757.GS155679365@sgi.com>
References: <1210858590.3900.1.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1210858590.3900.1.camel@johannes.berg>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: xfs-masters@oss.sgi.com
Cc: xfs <xfs@oss.sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 15, 2008 at 03:36:30PM +0200, Johannes Berg wrote:
> On 64-bit powerpc, the extra version is just wireless patches.
> [ 1533.995346] 
> [ 1533.995351] =======================================================
> [ 1533.995371] [ INFO: possible circular locking dependency detected ]
> [ 1533.995379] 2.6.26-rc2-wl-07523-g4079cb5-dirty #35
> [ 1533.995385] -------------------------------------------------------
> [ 1533.995393] nautilus/4053 is trying to acquire lock:
> [ 1533.995401]  (&mm->mmap_sem){----}, at: [<c0000000000280f4>] .do_page_fault+0x1fc/0x5b0
> [ 1533.995431] 
> [ 1533.995433] but task is already holding lock:
> [ 1533.995441]  (&(&ip->i_iolock)->mr_lock){----}, at: [<c0000000001d1510>] .xfs_ilock+0x54/0xa8
> [ 1533.995470] 
> [ 1533.995472] which lock already depends on the new lock.
> [ 1533.995474] 
> [ 1533.995481] 
> [ 1533.995482] the existing dependency chain (in reverse order) is:
> [ 1533.995489] 
> [ 1533.995491] -> #1 (&(&ip->i_iolock)->mr_lock){----}:
> [ 1533.995511]        [<c00000000007d0e8>] .__lock_acquire+0xd74/0xfdc
> [ 1533.995553]        [<c00000000007d414>] .lock_acquire+0xc4/0x110
> [ 1533.995591]        [<c00000000006f760>] .down_write_nested+0x74/0x114
> [ 1533.995630]        [<c0000000001d14f4>] .xfs_ilock+0x38/0xa8
> [ 1533.995667]        [<c0000000001f4524>] .xfs_free_eofblocks+0x158/0x2a8
> [ 1533.995703]        [<c0000000001f51c0>] .xfs_release+0x1a4/0x1d4
> [ 1533.995741]        [<c0000000001fe004>] .xfs_file_release+0x1c/0x3c
> [ 1533.995779]        [<c0000000000e265c>] .__fput+0x118/0x204
> [ 1533.995814]        [<c0000000000e2784>] .fput+0x3c/0x50
> [ 1533.995850]        [<c0000000000c697c>] .remove_vma+0x84/0xd8
> [ 1533.995886]        [<c0000000000c7f44>] .do_munmap+0x2f4/0x344
> [ 1533.995923]        [<c0000000000c7ff0>] .sys_munmap+0x5c/0x94
> [ 1533.995958]        [<c0000000000076d4>] syscall_exit+0x0/0x40
> [ 1533.995996] 
> [ 1533.995997] -> #0 (&mm->mmap_sem){----}:
> [ 1533.996014]        [<c00000000007cfe8>] .__lock_acquire+0xc74/0xfdc
> [ 1533.996049]        [<c00000000007d414>] .lock_acquire+0xc4/0x110
> [ 1533.996084]        [<c0000000003e1af8>] .down_read+0x60/0x114
> [ 1533.996121]        [<c0000000000280f4>] .do_page_fault+0x1fc/0x5b0
> [ 1533.996157]        [<c000000000004eb0>] handle_page_fault+0x20/0x5c
> [ 1533.996192]        [<c0000000000ac448>] .file_read_actor+0x7c/0x208
> [ 1533.996230]        [<c0000000000af9e0>] .generic_file_aio_read+0x2c8/0x5e8
> [ 1533.996265]        [<c000000000202bf0>] .xfs_read+0x1c0/0x278
> [ 1533.996299]        [<c0000000001fdf1c>] .xfs_file_aio_read+0x6c/0x84
> [ 1533.996335]        [<c0000000000e0bb8>] .do_sync_read+0xd4/0x13c
> [ 1533.996372]        [<c0000000000e19e8>] .vfs_read+0xd8/0x1b0
> [ 1533.996408]        [<c0000000000e1bd4>] .sys_read+0x5c/0xa8
> [ 1533.996443]        [<c0000000000076d4>] syscall_exit+0x0/0x40
> [ 1533.996479] 
> [ 1533.996480] other info that might help us debug this:

Fundamentally  - if a filesystem takes the same lock in
->file_aio_read as it does in ->release, then this will happen.
The lock outside the filesystem (the mmap lock) is can be taken
before we enter the filesystem or while we are inside a filesystem
method reading or writing data.

In this case, XFS uses the iolock to serialise I/O vs truncate.
We hold the iolock shared over read I/O, and exclusive when we
do a truncate. The truncate in this case is a truncate of blocks
past EOF on ->release. 

Whether this can deadlock depends on whether these two things can
happen on the same mmap->sem and same inode at the same time.
I know they can happen onteh same inode at the same time, but
can this happen on the same mmap->sem? VM gurus?

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
