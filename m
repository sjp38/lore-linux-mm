Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id DB3976B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 08:34:18 -0400 (EDT)
Date: Tue, 29 May 2012 14:34:08 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] block: Convert BDI proportion calculations to
 flexible proportions
Message-ID: <20120529123408.GA23991@quack.suse.cz>
References: <1337878751-22942-1-git-send-email-jack@suse.cz>
 <1337878751-22942-3-git-send-email-jack@suse.cz>
 <1338220185.4284.19.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338220185.4284.19.camel@lappy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 28-05-12 17:49:45, Sasha Levin wrote:
> Hi Jan,
> 
> On Thu, 2012-05-24 at 18:59 +0200, Jan Kara wrote:
> > Convert calculations of proportion of writeback each bdi does to new flexible
> > proportion code. That allows us to use aging period of fixed wallclock time
> > which gives better proportion estimates given the hugely varying throughput of
> > different devices.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> 
> This patch appears to be causing lockdep warnings over here:
  Actually, this is not caused directly by my patch. Just my patch makes
the problem more likely because I use smaller counter batch in
__fprop_inc_percpu_max() than is used in original __prop_inc_percpu_max(),
so the probability that percpu counter takes spinlock (which is what
triggers the warning) is higher.

The only safe solution seems to be to create a variant of percpu counters
that can be used from an interrupt. Or do you have other idea Peter?

								Honza
> 
> [   20.545016] =================================
> [   20.545016] [ INFO: inconsistent lock state ]
> [   20.545016] 3.4.0-next-20120528-sasha-00008-g11ef39f #307 Tainted: G        W   
> [   20.545016] ---------------------------------
> [   20.545016] inconsistent {IN-HARDIRQ-W} -> {HARDIRQ-ON-W} usage.
> [   20.545016] rcu_torture_rea/2493 [HC0[0]:SC1[1]:HE1:SE0] takes:
> [   20.545016]  (key#3){?.-...}, at: [<ffffffff81993527>] __percpu_counter_sum+0x17/0xc0
> [   20.545016] {IN-HARDIRQ-W} state was registered at:
> [   20.545016]   [<ffffffff8114ffab>] mark_irqflags+0x6b/0x170
> [   20.545016]   [<ffffffff811519bb>] __lock_acquire+0x2bb/0x4c0
> [   20.545016]   [<ffffffff81151d4a>] lock_acquire+0x18a/0x1e0
> [   20.545016]   [<ffffffff8325ac9b>] _raw_spin_lock+0x3b/0x70
> [   20.545016]   [<ffffffff81993620>] __percpu_counter_add+0x50/0xb0
> [   20.545016]   [<ffffffff8195b53a>] __fprop_inc_percpu_max+0x8a/0xa0
> [   20.545016]   [<ffffffff811daf8d>] test_clear_page_writeback+0x12d/0x1c0
> [   20.545016]   [<ffffffff811ccc44>] end_page_writeback+0x24/0x50
> [   20.545016]   [<ffffffff8126ed2a>] end_buffer_async_write+0x26a/0x350
> [   20.545016]   [<ffffffff8126bfdd>] end_bio_bh_io_sync+0x3d/0x50
> [   20.545016]   [<ffffffff81270b59>] bio_endio+0x29/0x30
> [   20.545016]   [<ffffffff819330e9>] req_bio_endio+0xb9/0xd0
> [   20.545016]   [<ffffffff81936318>] blk_update_request+0x1a8/0x3c0
> [   20.545016]   [<ffffffff81936552>] blk_update_bidi_request+0x22/0x90
> [   20.545016]   [<ffffffff8193673c>] __blk_end_bidi_request+0x1c/0x40
> [   20.545016]   [<ffffffff81936788>] __blk_end_request_all+0x28/0x40
> [   20.545016]   [<ffffffff81e04f2e>] blk_done+0x9e/0xf0
> [   20.545016]   [<ffffffff81afb106>] vring_interrupt+0x86/0xa0
> [   20.680186]   [<ffffffff81187c01>] handle_irq_event_percpu+0x151/0x3e0
> [   20.680186]   [<ffffffff81187ed3>] handle_irq_event+0x43/0x70
> [   20.680186]   [<ffffffff8118b5a8>] handle_edge_irq+0xe8/0x120
> [   20.680186]   [<ffffffff81069444>] handle_irq+0x164/0x180
> [   20.680186]   [<ffffffff81068638>] do_IRQ+0x58/0xd0
> [   20.680186]   [<ffffffff8325beef>] ret_from_intr+0x0/0x1a
> [   20.680186]   [<ffffffff81937bed>] blk_queue_bio+0x30d/0x430
> [   20.680186]   [<ffffffff8193423e>] generic_make_request+0xbe/0x120
> [   20.680186]   [<ffffffff81934398>] submit_bio+0xf8/0x120
> [   20.680186]   [<ffffffff8126bf72>] submit_bh+0x122/0x150
> [   20.680186]   [<ffffffff8126ded7>] __block_write_full_page+0x287/0x3b0
> [   20.680186]   [<ffffffff8126f2cc>] block_write_full_page_endio+0xfc/0x120
> [   20.680186]   [<ffffffff8126f300>] block_write_full_page+0x10/0x20
> [   20.680186]   [<ffffffff81273d83>] blkdev_writepage+0x13/0x20
> [   20.680186]   [<ffffffff811d90c5>] __writepage+0x15/0x40
> [   20.680186]   [<ffffffff811db78f>] write_cache_pages+0x49f/0x650
> [   20.680186]   [<ffffffff811db98f>] generic_writepages+0x4f/0x70
> [   20.680186]   [<ffffffff811db9ce>] do_writepages+0x1e/0x50
> [   20.680186]   [<ffffffff811cd219>] __filemap_fdatawrite_range+0x49/0x50
> [   20.680186]   [<ffffffff811cd44a>] filemap_fdatawrite+0x1a/0x20
> [   20.680186]   [<ffffffff811cd475>] filemap_write_and_wait+0x25/0x50
> [   20.680186]   [<ffffffff812740bd>] __sync_blockdev+0x2d/0x40
> [   20.680186]   [<ffffffff812740de>] sync_blockdev+0xe/0x10
> [   20.680186]   [<ffffffff813917d2>] journal_recover+0x182/0x1c0
> [   20.680186]   [<ffffffff81396ae8>] journal_load+0x58/0xa0
> [   20.680186]   [<ffffffff8132b750>] ext3_load_journal+0x200/0x2b0
> [   20.680186]   [<ffffffff8132e2c8>] ext3_fill_super+0xc18/0x10d0
> [   20.680186]   [<ffffffff8123c636>] mount_bdev+0x176/0x210
> [   20.680186]   [<ffffffff81327e00>] ext3_mount+0x10/0x20
> [   20.680186]   [<ffffffff8123bf75>] mount_fs+0x85/0x1a0
> [   20.680186]   [<ffffffff812592a4>] vfs_kern_mount+0x74/0x100
> [   20.680186]   [<ffffffff8125b991>] do_kern_mount+0x51/0x120
> [   20.680186]   [<ffffffff8125bc34>] do_mount+0x1d4/0x240
> [   20.680186]   [<ffffffff8125bd3d>] sys_mount+0x9d/0xe0
> [   20.680186]   [<ffffffff84cb6232>] do_mount_root+0x1e/0x94
> [   20.680186]   [<ffffffff84cb64c2>] mount_block_root+0xe2/0x224
> [   20.680186]   [<ffffffff84cb672f>] mount_root+0x12b/0x136
> [   20.680186]   [<ffffffff84cb689f>] prepare_namespace+0x165/0x19e
> [   20.680186]   [<ffffffff84cb5afb>] kernel_init+0x274/0x28a
> [   20.680186]   [<ffffffff8325dd34>] kernel_thread_helper+0x4/0x10
> [   20.680186] irq event stamp: 1551906
> [   20.680186] hardirqs last  enabled at (1551906): [<ffffffff8325b7db>] _raw_spin_unlock_irq+0x2b/0x80
> [   20.680186] hardirqs last disabled at (1551905): [<ffffffff8325aea4>] _raw_spin_lock_irq+0x34/0xa0
> [   20.680186] softirqs last  enabled at (1551022): [<ffffffff810e316b>] __do_softirq+0x3db/0x460
> [   20.680186] softirqs last disabled at (1551903): [<ffffffff8325de2c>] call_softirq+0x1c/0x30
> [   20.680186] 
> [   20.680186] other info that might help us debug this:
> [   20.680186]  Possible unsafe locking scenario:
> [   20.680186] 
> [   20.680186]        CPU0
> [   20.680186]        ----
> [   20.680186]   lock(key#3);
> [   20.680186]   <Interrupt>
> [   20.680186]     lock(key#3);
> [   20.680186] 
> [   20.680186]  *** DEADLOCK ***
> [   20.680186] 
> [   20.680186] 2 locks held by rcu_torture_rea/2493:
> [   20.680186]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff811914f0>] rcu_torture_read_lock+0x0/0x80
> [   20.680186]  #1:  (mm/page-writeback.c:144){+.-...}, at: [<ffffffff810ebf90>] call_timer_fn+0x0/0x260
> [   20.680186] 
> [   20.680186] stack backtrace:
> [   20.680186] Pid: 2493, comm: rcu_torture_rea Tainted: G        W    3.4.0-next-20120528-sasha-00008-g11ef39f #307
> [   20.680186] Call Trace:
> [   20.680186]  <IRQ>  [<ffffffff8114f6b9>] print_usage_bug+0x1a9/0x1d0
> [   20.680186]  [<ffffffff8114eed0>] ? check_usage_forwards+0xf0/0xf0
> [   20.680186]  [<ffffffff8114fb99>] mark_lock_irq+0xc9/0x270
> [   20.680186]  [<ffffffff8114fe5d>] mark_lock+0x11d/0x200
> [   20.680186]  [<ffffffff81150030>] mark_irqflags+0xf0/0x170
> [   20.680186]  [<ffffffff811519bb>] __lock_acquire+0x2bb/0x4c0
> [   20.680186]  [<ffffffff81151d4a>] lock_acquire+0x18a/0x1e0
> [   20.680186]  [<ffffffff81993527>] ? __percpu_counter_sum+0x17/0xc0
> [   20.680186]  [<ffffffff811d9260>] ? laptop_io_completion+0x30/0x30
> [   20.680186]  [<ffffffff8325ac9b>] _raw_spin_lock+0x3b/0x70
> [   20.680186]  [<ffffffff81993527>] ? __percpu_counter_sum+0x17/0xc0
> [   20.680186]  [<ffffffff81993527>] __percpu_counter_sum+0x17/0xc0
> [   20.680186]  [<ffffffff810ebf90>] ? init_timer_deferrable_key+0x20/0x20
> [   20.680186]  [<ffffffff8195b5c2>] fprop_new_period+0x12/0x60
> [   20.680186]  [<ffffffff811d929d>] writeout_period+0x3d/0xa0
> [   20.680186]  [<ffffffff810ec0bf>] call_timer_fn+0x12f/0x260
> [   20.680186]  [<ffffffff810ebf90>] ? init_timer_deferrable_key+0x20/0x20
> [   20.680186]  [<ffffffff8325b7db>] ? _raw_spin_unlock_irq+0x2b/0x80
> [   20.680186]  [<ffffffff811d9260>] ? laptop_io_completion+0x30/0x30
> [   20.680186]  [<ffffffff810ecd6e>] run_timer_softirq+0x29e/0x2f0
> [   20.680186]  [<ffffffff810e2fb1>] __do_softirq+0x221/0x460
> [   20.680186]  [<ffffffff8109a516>] ? kvm_clock_read+0x46/0x80
> [   20.680186]  [<ffffffff8325de2c>] call_softirq+0x1c/0x30
> [   20.680186]  [<ffffffff81069235>] do_softirq+0x75/0x120
> [   20.680186]  [<ffffffff810e1fbb>] irq_exit+0x5b/0xf0
> [   20.680186]  [<ffffffff8108e88a>] smp_apic_timer_interrupt+0x8a/0xa0
> [   20.680186]  [<ffffffff8325d42f>] apic_timer_interrupt+0x6f/0x80
> [   20.680186]  <EOI>  [<ffffffff81151d7e>] ? lock_acquire+0x1be/0x1e0
> [   20.680186]  [<ffffffff811914f0>] ? rcu_torture_reader+0x380/0x380
> [   20.680186]  [<ffffffff81191523>] rcu_torture_read_lock+0x33/0x80
> [   20.680186]  [<ffffffff811914f0>] ? rcu_torture_reader+0x380/0x380
> [   20.680186]  [<ffffffff81191293>] rcu_torture_reader+0x123/0x380
> [   20.680186]  [<ffffffff8118ff50>] ? T.841+0x50/0x50
> [   20.680186]  [<ffffffff81191170>] ? rcu_torture_read_unlock+0x60/0x60
> [   20.680186]  [<ffffffff811071c2>] kthread+0xb2/0xc0
> [   20.680186]  [<ffffffff8325dd34>] kernel_thread_helper+0x4/0x10
> [   20.680186]  [<ffffffff8325bfb4>] ? retint_restore_args+0x13/0x13
> [   20.680186]  [<ffffffff81107110>] ? __init_kthread_worker+0x70/0x70
> [   20.680186]  [<ffffffff8325dd30>] ? gs_change+0x13/0x13
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
