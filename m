Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B49696B0007
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 21:21:17 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x24so9462030pge.13
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 18:21:17 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id n10-v6si920215plp.698.2018.01.30.18.21.15
        for <linux-mm@kvack.org>;
        Tue, 30 Jan 2018 18:21:16 -0800 (PST)
Date: Wed, 31 Jan 2018 13:22:09 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: freezing system for several second on high I/O [kernel 4.15]
Message-ID: <20180131022209.lmhespbauhqtqrxg@destitution>
References: <1517337604.9211.13.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1517337604.9211.13.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mikhail <mikhail.v.gavrilov@gmail.com>
Cc: "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jan 30, 2018 at 11:40:04PM +0500, mikhail wrote:
> Hi.
> 
> I  launched several application which highly use I/O on start and it
> caused freezing system for several second.
> 
> All traces lead to xfs.
> 
> Whether there is a useful info in trace or just it means that disk is slow?

Could be a disk that is slow, or could be many other
things. More information required:

http://xfs.org/index.php/XFS_FAQ#Q:_What_information_should_I_include_when_reporting_a_problem.3F

....
> [  369.301111] disk_cache:0    D12928  5241   5081 0x00000000

Your "disk_cache" process is walking the inobt during inode
allocation:

> [  369.301118] Call Trace:
> [  369.301124]  __schedule+0x2dc/0xba0
> [  369.301133]  ? wait_for_completion+0x10e/0x1a0
> [  369.301137]  schedule+0x33/0x90
> [  369.301140]  schedule_timeout+0x25a/0x5b0
> [  369.301146]  ? mark_held_locks+0x5f/0x90
> [  369.301150]  ? _raw_spin_unlock_irq+0x2c/0x40
> [  369.301153]  ? wait_for_completion+0x10e/0x1a0
> [  369.301157]  ? trace_hardirqs_on_caller+0xf4/0x190
> [  369.301162]  ? wait_for_completion+0x10e/0x1a0
> [  369.301166]  wait_for_completion+0x136/0x1a0
> [  369.301172]  ? wake_up_q+0x80/0x80
> [  369.301203]  ? _xfs_buf_read+0x23/0x30 [xfs]
> [  369.301232]  xfs_buf_submit_wait+0xb2/0x530 [xfs]
> [  369.301262]  _xfs_buf_read+0x23/0x30 [xfs]
> [  369.301290]  xfs_buf_read_map+0x14b/0x300 [xfs]
> [  369.301324]  ? xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
> [  369.301360]  xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
> [  369.301390]  xfs_btree_read_buf_block.constprop.36+0x72/0xc0 [xfs]
> [  369.301423]  xfs_btree_lookup_get_block+0x88/0x180 [xfs]
> [  369.301454]  xfs_btree_lookup+0xcd/0x410 [xfs]
> [  369.301462]  ? rcu_read_lock_sched_held+0x79/0x80
> [  369.301495]  ? kmem_zone_alloc+0x6c/0xf0 [xfs]
> [  369.301530]  xfs_dialloc_ag_update_inobt+0x49/0x120 [xfs]
> [  369.301557]  ? xfs_inobt_init_cursor+0x3e/0xe0 [xfs]
> [  369.301588]  xfs_dialloc_ag+0x17c/0x260 [xfs]
> [  369.301616]  ? xfs_dialloc+0x236/0x270 [xfs]
> [  369.301652]  xfs_dialloc+0x59/0x270 [xfs]
> [  369.301718]  xfs_ialloc+0x6a/0x520 [xfs]
> [  369.301724]  ? find_held_lock+0x3c/0xb0
> [  369.301757]  xfs_dir_ialloc+0x67/0x210 [xfs]
> [  369.301792]  xfs_create+0x514/0x840 [xfs]
> [  369.301833]  xfs_generic_create+0x1fa/0x2d0 [xfs]
> [  369.301865]  xfs_vn_mknod+0x14/0x20 [xfs]
> [  369.301889]  xfs_vn_mkdir+0x16/0x20 [xfs]
> [  369.301893]  vfs_mkdir+0x10c/0x1d0
> [  369.301900]  SyS_mkdir+0x7e/0xf0
> [  369.301909]  entry_SYSCALL_64_fastpath+0x1f/0x96

And everything else is backed up behind it trying to allocate
inodes. There could be many, many reasons for that, and that's why
we need more information to begin to isolate the cause.

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
