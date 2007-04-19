Date: Thu, 19 Apr 2007 10:01:57 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: dio_get_page() lockdep complaints
Message-ID: <20070419080157.GC20928@kernel.dk>
References: <20070419073828.GB20928@kernel.dk> <20070419010142.5b7b00cd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070419010142.5b7b00cd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-aio@kvack.org, reiserfs-dev@namesys.com, "Vladimir V. Saveliev" <vs@namesys.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 19 2007, Andrew Morton wrote:
> On Thu, 19 Apr 2007 09:38:30 +0200 Jens Axboe <jens.axboe@oracle.com> wrote:
> 
> > Hi,
> > 
> > Doing some testing on CFQ, I ran into this 100% reproducible report:
> > 
> > =======================================================
> > [ INFO: possible circular locking dependency detected ]
> > 2.6.21-rc7 #5
> > -------------------------------------------------------
> > fio/9741 is trying to acquire lock:
> >  (&mm->mmap_sem){----}, at: [<b018cb34>] dio_get_page+0x54/0x161
> > 
> > but task is already holding lock:
> >  (&inode->i_mutex){--..}, at: [<b038c6e5>] mutex_lock+0x1c/0x1f
> > 
> > which lock already depends on the new lock.
> > 
> 
> This is the correct ranking: i_mutex outside mmap_sem.
> 
> > 
> > the existing dependency chain (in reverse order) is:
> > 
> > -> #1 (&inode->i_mutex){--..}:
> >        [<b013e3fb>] __lock_acquire+0xdee/0xf9c
> >        [<b013e600>] lock_acquire+0x57/0x70
> >        [<b038c4a5>] __mutex_lock_slowpath+0x73/0x297
> >        [<b038c6e5>] mutex_lock+0x1c/0x1f
> >        [<b01b17e9>] reiserfs_file_release+0x54/0x447
> >        [<b016afe7>] __fput+0x53/0x101
> >        [<b016b0ee>] fput+0x19/0x1c
> >        [<b015bcd5>] remove_vma+0x3b/0x4d
> >        [<b015c659>] do_munmap+0x17f/0x1cf
> >        [<b015c6db>] sys_munmap+0x32/0x42
> >        [<b0103f04>] sysenter_past_esp+0x5d/0x99
> >        [<ffffffff>] 0xffffffff
> > 
> > -> #0 (&mm->mmap_sem){----}:
> >        [<b013e259>] __lock_acquire+0xc4c/0xf9c
> >        [<b013e600>] lock_acquire+0x57/0x70
> >        [<b0137b92>] down_read+0x3a/0x4c
> >        [<b018cb34>] dio_get_page+0x54/0x161
> >        [<b018d7a9>] __blockdev_direct_IO+0x514/0xe2a
> >        [<b01cf449>] ext3_direct_IO+0x98/0x1e5
> >        [<b014e8df>] generic_file_direct_IO+0x63/0x133
> >        [<b01500e9>] generic_file_aio_read+0x16b/0x222
> >        [<b017f8b6>] aio_rw_vect_retry+0x5a/0x116
> >        [<b0180147>] aio_run_iocb+0x69/0x129
> >        [<b0180a78>] io_submit_one+0x194/0x2eb
> >        [<b0181331>] sys_io_submit+0x92/0xe7
> >        [<b0103f90>] syscall_call+0x7/0xb
> >        [<ffffffff>] 0xffffffff
> 
> But here reiserfs is taking i_mutex in its file_operations.release(),
> which can be called under mmap_sem.
> 
> Vladimir's recent de14569f94513279e3d44d9571a421e9da1759ae.
> "resierfs: avoid tail packing if an inode was ever mmapped" comes real
> close to this code, but afaict it did not cause this bug.
> 
> I can't think of anything which we've done in the 2.6.21 cycle which
> would have caused this to start happening.  Odd.

The bug may be holder, let me know if you want me to check 2.6.20 or
earlier.

> > The test run was fio, the job file used is:
> > 
> > # fio job file snip below
> > [global]
> > bs=4k
> > buffered=0
> > ioengine=libaio
> > iodepth=4
> > thread
> > 
> > [readers]
> > numjobs=8
> > size=128m
> > rw=read
> > # fio job file snip above
> > 
> > Filesystem was ext3, default mkfs and mount options. Kernel was
> > 2.6.21-rc7 as of this morning, with some CFQ patches applied.
> > 
> 
> It's interesting that lockdep learned the (wrong) ranking from a reiserfs
> operation then later detected it being violated by ext3.

It's a scratch test box, which for some reason has reiserfs as the
rootfs. So reiser gets to run first :-)

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
