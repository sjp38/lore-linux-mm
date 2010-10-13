Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8B30F6B00E2
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 23:23:46 -0400 (EDT)
Date: Wed, 13 Oct 2010 11:23:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/17] [RFC] soft and dynamic dirty throttling limits
Message-ID: <20101013032342.GA10020@localhost>
References: <20100912154945.758129106@intel.com>
 <20101012141716.GA26702@infradead.org>
 <20101013030733.GV4681@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101013030733.GV4681@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 13, 2010 at 11:07:33AM +0800, Dave Chinner wrote:
> On Tue, Oct 12, 2010 at 10:17:16AM -0400, Christoph Hellwig wrote:
> > Wu, what's the state of this series?  It looks like we'll need it
> > rather sooner than later - try to get at least the preparations in
> > ASAP would be really helpful.
> 
> Not ready in it's current form. This load (creating millions of 1
> byte files in parallel):
> 
> $ /usr/bin/time ./fs_mark -D 10000 -S0 -n 100000 -s 1 -L 63 \
> > -d /mnt/scratch/0 -d /mnt/scratch/1 \
> > -d /mnt/scratch/2 -d /mnt/scratch/3 \
> > -d /mnt/scratch/4 -d /mnt/scratch/5 \
> > -d /mnt/scratch/6 -d /mnt/scratch/7
> 
> Locks up all the fs_mark processes spinning in traces like the
> following and no further progress is made when the inode cache
> fills memory.
 
Dave, thanks for the testing! I'll try to reproduce it and check
what's going on.

Thanks,
Fengguang

> [ 2601.452017] fs_mark       R  running task        0  2303   2235 0x00000008
> [ 2601.452017]  ffff8801188f7878 ffffffff8103e2c9 ffff8801188f78a8 0000000000000000
> [ 2601.452017]  0000000000000002 ffff8801129e21c0 ffff880002fd44c0 0000000000000000
> [ 2601.452017]  ffff8801188f78b8 ffffffff810a9a08 ffff8801188f78e8 ffffffff810a98e5
> [ 2601.452017] Call Trace:
> [ 2601.452017]  [<ffffffff81060edc>] ? kvm_clock_read+0x1c/0x20
> [ 2601.452017]  [<ffffffff8103e2c9>] ? sched_clock+0x9/0x10
> [ 2601.452017]  [<ffffffff810a98e5>] ? sched_clock_local+0x25/0x90
> [ 2601.452017]  [<ffffffff810b9e00>] ? __lock_acquire+0x330/0x14d0
> [ 2601.452017]  [<ffffffff810a9a94>] ? local_clock+0x34/0x80
> [ 2601.452017]  [<ffffffff81061cc8>] ? pvclock_clocksource_read+0x58/0xd0
> [ 2601.452017]  [<ffffffff81061cc8>] ? pvclock_clocksource_read+0x58/0xd0
> [ 2601.452017]  [<ffffffff81060edc>] ? kvm_clock_read+0x1c/0x20
> [ 2601.452017]  [<ffffffff8103e2c9>] ? sched_clock+0x9/0x10
> [ 2601.452017]  [<ffffffff810bb054>] ? lock_acquire+0xb4/0x140
> [ 2601.452017]  [<ffffffff8103e2c9>] ? sched_clock+0x9/0x10
> [ 2601.452017]  [<ffffffff810a98e5>] ? sched_clock_local+0x25/0x90
> [ 2601.452017]  [<ffffffff81698ea2>] ? prop_get_global+0x32/0x50
> [ 2601.452017]  [<ffffffff81699230>] ? prop_fraction_percpu+0x30/0xa0
> [ 2601.452017]  [<ffffffff8111af3b>] ? bdi_dirty_limit+0x9b/0xe0
> [ 2601.452017]  [<ffffffff8111bbd8>] ? balance_dirty_pages_ratelimited_nr+0x178/0x580
> [ 2601.452017]  [<ffffffff81ad440b>] ? _raw_spin_unlock+0x2b/0x40
> [ 2601.452017]  [<ffffffff8117ccd5>] ? __mark_inode_dirty+0xc5/0x230
> [ 2601.452017]  [<ffffffff811114d5>] ? iov_iter_copy_from_user_atomic+0x95/0x170
> [ 2601.452017]  [<ffffffff811118fc>] ? generic_file_buffered_write+0x1cc/0x270
> [ 2601.452017]  [<ffffffff81492f2f>] ? xfs_file_aio_write+0x79f/0xaf0
> [ 2601.452017]  [<ffffffff81060edc>] ? kvm_clock_read+0x1c/0x20
> [ 2601.452017]  [<ffffffff81060edc>] ? kvm_clock_read+0x1c/0x20
> [ 2601.452017]  [<ffffffff8103e2c9>] ? sched_clock+0x9/0x10
> [ 2601.452017]  [<ffffffff810a98e5>] ? sched_clock_local+0x25/0x90
> [ 2601.452017]  [<ffffffff81157cca>] ? do_sync_write+0xda/0x120
> [ 2601.452017]  [<ffffffff8112e20c>] ? might_fault+0x5c/0xb0
> [ 2601.452017]  [<ffffffff81669f7f>] ? security_file_permission+0x1f/0x80
> [ 2601.452017]  [<ffffffff81157fb8>] ? vfs_write+0xc8/0x180
> [ 2601.452017]  [<ffffffff81158904>] ? sys_write+0x54/0x90
> [ 2601.452017]  [<ffffffff81037072>] ? system_call_fastpath+0x16/0x1b
> 
> This is on an 8p/4GB RAM VM.
> 
> FWIW, this one test now has a proven record of exposing writeback,
> VM and filesystem regressions, so I'd suggest that anyone doing any
> sort of work that affects writeback adds it to their test matrix....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
