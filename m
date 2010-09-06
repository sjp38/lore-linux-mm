Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7CB846B0047
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 00:04:02 -0400 (EDT)
Date: Mon, 6 Sep 2010 14:02:43 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
 direct reclaim allocation fails
Message-ID: <20100906040243.GA7362@dastard>
References: <20100903160026.564fdcc9.akpm@linux-foundation.org>
 <20100904022545.GD705@dastard>
 <20100903202101.f937b0bb.akpm@linux-foundation.org>
 <20100904075840.GE705@dastard>
 <20100904081414.GF705@dastard>
 <20100905015400.GA10714@localhost>
 <20100905021555.GG705@dastard>
 <20100905060539.GA17450@localhost>
 <20100905131447.GJ705@dastard>
 <20100905134554.GA7083@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100905134554.GA7083@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Linux Kernel List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 05, 2010 at 09:45:54PM +0800, Wu Fengguang wrote:
> [restoring CC list]
> 
> On Sun, Sep 05, 2010 at 09:14:47PM +0800, Dave Chinner wrote:
> > On Sun, Sep 05, 2010 at 02:05:39PM +0800, Wu Fengguang wrote:
> > > On Sun, Sep 05, 2010 at 10:15:55AM +0800, Dave Chinner wrote:
> > > > On Sun, Sep 05, 2010 at 09:54:00AM +0800, Wu Fengguang wrote:
> > > > > Dave, could you post (publicly) the kconfig and /proc/vmstat?
> > > > > 
> > > > > I'd like to check if you have swap or memory compaction enabled..
> > > > 
> > > > Swap is enabled - it has 512MB of swap space:
> > > > 
> > > > $ free
> > > >              total       used       free     shared    buffers     cached
> > > > Mem:       4054304     100928    3953376          0       4096      43108
> > > > -/+ buffers/cache:      53724    4000580
> > > > Swap:       497976          0     497976
> > > 
> > > It looks swap is not used at all.
> > 
> > It isn't 30s after boot, abut I haven't checked after a livelock.
> 
> That's fine. I see in your fs_mark-wedge-1.png that there are no
> read/write IO at all when CPUs are 100% busy. So there should be no
> swap IO at "livelock" time.
> 
> > > > And memory compaction is not enabled:
> > > > 
> > > > $ grep COMPACT .config
> > > > # CONFIG_COMPACTION is not set
> 
> Memory compaction is not likely the cause too. It will only kick in for
> order > 3 allocations.
> 
> > > > 
> > > > The .config is pretty much a 'make defconfig' and then enabling XFS and
> > > > whatever debug I need (e.g. locking, memleak, etc).
> > > 
> > > Thanks! The problem seems hard to debug -- you cannot login at all
> > > when it is doing lock contentions, so cannot get sysrq call traces.
> > 
> > Well, I don't know whether it is lock contention at all. The sets of
> > traces I have got previously have shown backtraces on all CPUs in
> > direct reclaim with several in draining queues, but no apparent lock
> > contention.
> 
> That's interesting. Do you still have the full backtraces?

Just saw one when testing some new code with CONFIG_XFS_DEBUG
enabled. The act of running 'echo t > /proc/sysrq-trigger' seems to
have got the machine unstuck, so I'm not sure if the traces are
completely representative of the livelock state. however, here are
the fs_mark processes:

[  596.628086] fs_mark       R  running task        0  2373   2163 0x00000008
[  596.628086]  0000000000000000 ffffffff81bb8610 00000000000008fc 0000000000000002
[  596.628086]  0000000000000000 0000000000000296 0000000000000297 ffffffffffffff10
[  596.628086]  ffffffff810b48c2 0000000000000010 0000000000000202 ffff880116b61798
[  596.628086] Call Trace:
[  596.628086]  [<ffffffff810b48c2>] ? smp_call_function_many+0x1a2/0x210
[  596.628086]  [<ffffffff810b48a5>] ? smp_call_function_many+0x185/0x210
[  596.628086]  [<ffffffff81109ff0>] ? drain_local_pages+0x0/0x20
[  596.628086]  [<ffffffff810b4952>] ? smp_call_function+0x22/0x30
[  596.628086]  [<ffffffff81084934>] ? on_each_cpu+0x24/0x50
[  596.628086]  [<ffffffff81108a8c>] ? drain_all_pages+0x1c/0x20
[  596.628086]  [<ffffffff81108fad>] ? __alloc_pages_nodemask+0x42d/0x700
[  596.628086]  [<ffffffff8113d0f2>] ? kmem_getpages+0x62/0x160
[  596.628086]  [<ffffffff8113dce6>] ? fallback_alloc+0x196/0x240
[  596.628086]  [<ffffffff8113da68>] ? ____cache_alloc_node+0x98/0x180
[  596.628086]  [<ffffffff8113e643>] ? __kmalloc+0x193/0x230
[  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
[  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
[  596.628086]  [<ffffffff8131092e>] ? kmem_zalloc+0x1e/0x50
[  596.628086]  [<ffffffff812fac80>] ? xfs_log_commit_cil+0x500/0x590
[  596.628086]  [<ffffffff81310943>] ? kmem_zalloc+0x33/0x50
[  596.628086]  [<ffffffff813082d6>] ? _xfs_trans_commit+0x156/0x2f0
[  596.628086]  [<ffffffff8130d50e>] ? xfs_create+0x58e/0x700
[  596.628086]  [<ffffffff8131c587>] ? xfs_vn_mknod+0xa7/0x1c0
[  596.628086]  [<ffffffff8131c6d0>] ? xfs_vn_create+0x10/0x20
[  596.628086]  [<ffffffff81151f48>] ? vfs_create+0xb8/0xf0
[  596.628086]  [<ffffffff8115273c>] ? do_last+0x4dc/0x5d0
[  596.628086]  [<ffffffff81154937>] ? do_filp_open+0x207/0x5e0
[  596.628086]  [<ffffffff8115b7bc>] ? d_lookup+0x3c/0x60
[  596.628086]  [<ffffffff8105fc58>] ? pvclock_clocksource_read+0x58/0xd0
[  596.628086]  [<ffffffff813fd98e>] ? do_raw_spin_unlock+0x5e/0xb0
[  596.628086]  [<ffffffff8115f8fa>] ? alloc_fd+0xfa/0x140
[  596.628086]  [<ffffffff811448a5>] ? do_sys_open+0x65/0x130
[  596.628086]  [<ffffffff811449b0>] ? sys_open+0x20/0x30
[  596.628086]  [<ffffffff81036032>] ? system_call_fastpath+0x16/0x1b
[  596.628086] fs_mark       R  running task        0  2374   2163 0x00000000
[  596.628086]  0000000000000000 0000000000000002 ffff88011ad619b0 ffff88011fc050c0
[  596.628086]  ffff88011ad619e8 ffffffff8113dce6 ffff88011fc028c0 ffff88011fc02900
[  596.628086]  ffff88011ad619e8 0000025000000000 ffff880100001c08 0000001000000000
[  596.628086] Call Trace:
[  596.628086]  [<ffffffff8113dce6>] ? fallback_alloc+0x196/0x240
[  596.628086]  [<ffffffff8113da68>] ? ____cache_alloc_node+0x98/0x180
[  596.628086]  [<ffffffff8113e643>] ? __kmalloc+0x193/0x230
[  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
[  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
[  596.628086]  [<ffffffff8131092e>] ? kmem_zalloc+0x1e/0x50
[  596.628086]  [<ffffffff812fac80>] ? xfs_log_commit_cil+0x500/0x590
[  596.628086]  [<ffffffff81310943>] ? kmem_zalloc+0x33/0x50
[  596.628086]  [<ffffffff813082d6>] ? _xfs_trans_commit+0x156/0x2f0
[  596.628086]  [<ffffffff8130d50e>] ? xfs_create+0x58e/0x700
[  596.628086]  [<ffffffff8131c587>] ? xfs_vn_mknod+0xa7/0x1c0
[  596.628086]  [<ffffffff8131c6d0>] ? xfs_vn_create+0x10/0x20
[  596.628086]  [<ffffffff81151f48>] ? vfs_create+0xb8/0xf0
[  596.628086]  [<ffffffff8115273c>] ? do_last+0x4dc/0x5d0
[  596.628086]  [<ffffffff81154937>] ? do_filp_open+0x207/0x5e0
[  596.628086]  [<ffffffff8115b7bc>] ? d_lookup+0x3c/0x60
[  596.628086]  [<ffffffff8105fc58>] ? pvclock_clocksource_read+0x58/0xd0
[  596.628086]  [<ffffffff813fd98e>] ? do_raw_spin_unlock+0x5e/0xb0
[  596.628086]  [<ffffffff8115f8fa>] ? alloc_fd+0xfa/0x140
[  596.628086]  [<ffffffff811448a5>] ? do_sys_open+0x65/0x130
[  596.628086]  [<ffffffff811449b0>] ? sys_open+0x20/0x30
[  596.628086]  [<ffffffff81036032>] ? system_call_fastpath+0x16/0x1b
[  596.628086] fs_mark       R  running task        0  2375   2163 0x00000000
[  596.628086]  ffff8801198f96f8 ffff880100000000 0000000000000001 0000000000000002
[  596.628086]  ffff8801198f9708 ffffffff8110758a 0000000001320122 0000000000000002
[  596.628086]  ffff8801198f8000 ffff880100000000 0000000000000007 0000000000000250
[  596.628086] Call Trace:
[  596.628086]  [<ffffffff8110758a>] ? zone_watermark_ok+0x2a/0xf0
[  596.628086]  [<ffffffff8103694e>] ? apic_timer_interrupt+0xe/0x20
[  596.628086]  [<ffffffff810b48c6>] ? smp_call_function_many+0x1a6/0x210
[  596.628086]  [<ffffffff810b48a5>] ? smp_call_function_many+0x185/0x210
[  596.628086]  [<ffffffff81109ff0>] ? drain_local_pages+0x0/0x20
[  596.628086]  [<ffffffff810b4952>] ? smp_call_function+0x22/0x30
[  596.628086]  [<ffffffff81084934>] ? on_each_cpu+0x24/0x50
[  596.628086]  [<ffffffff81108a8c>] ? drain_all_pages+0x1c/0x20
[  596.628086]  [<ffffffff81108fad>] ? __alloc_pages_nodemask+0x42d/0x700
[  596.628086]  [<ffffffff8113d0f2>] ? kmem_getpages+0x62/0x160
[  596.628086]  [<ffffffff8113dce6>] ? fallback_alloc+0x196/0x240
[  596.628086]  [<ffffffff8113da68>] ? ____cache_alloc_node+0x98/0x180
[  596.628086]  [<ffffffff8113e643>] ? __kmalloc+0x193/0x230
[  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
[  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
[  596.628086]  [<ffffffff8131092e>] ? kmem_zalloc+0x1e/0x50
[  596.628086]  [<ffffffff812fac80>] ? xfs_log_commit_cil+0x500/0x590
[  596.628086]  [<ffffffff81310943>] ? kmem_zalloc+0x33/0x50
[  596.628086]  [<ffffffff813082d6>] ? _xfs_trans_commit+0x156/0x2f0
[  596.628086]  [<ffffffff8130d50e>] ? xfs_create+0x58e/0x700
[  596.628086]  [<ffffffff8131c587>] ? xfs_vn_mknod+0xa7/0x1c0
[  596.628086]  [<ffffffff8131c6d0>] ? xfs_vn_create+0x10/0x20
[  596.628086]  [<ffffffff81151f48>] ? vfs_create+0xb8/0xf0
[  596.628086]  [<ffffffff8115273c>] ? do_last+0x4dc/0x5d0
[  596.628086]  [<ffffffff81154937>] ? do_filp_open+0x207/0x5e0
[  596.628086]  [<ffffffff8115b7bc>] ? d_lookup+0x3c/0x60
[  596.628086]  [<ffffffff8105fc58>] ? pvclock_clocksource_read+0x58/0xd0
[  596.628086]  [<ffffffff813fd98e>] ? do_raw_spin_unlock+0x5e/0xb0
[  596.628086]  [<ffffffff8115f8fa>] ? alloc_fd+0xfa/0x140
[  596.628086]  [<ffffffff811448a5>] ? do_sys_open+0x65/0x130
[  596.628086]  [<ffffffff811449b0>] ? sys_open+0x20/0x30
[  596.628086]  [<ffffffff81036032>] ? system_call_fastpath+0x16/0x1b
[  596.628086] fs_mark       R  running task        0  2376   2163 0x00000000
[  596.628086]  ffff88011d303708 ffffffff8110758a 0000000001320122 0000000000000002
[  596.628086]  ffff88011d302000 ffff880100000000 0000000000000007 0000000000000250
[  596.628086]  ffffffff8103694e ffff88011d3037d8 ffff88011c9808f8 0000000000000001
[  596.628086] Call Trace:
[  596.628086]  [<ffffffff8110758a>] ? zone_watermark_ok+0x2a/0xf0
[  596.628086]  [<ffffffff8103694e>] ? apic_timer_interrupt+0xe/0x20
[  596.628086]  [<ffffffff810b48c2>] ? smp_call_function_many+0x1a2/0x210
[  596.628086]  [<ffffffff810b48a5>] ? smp_call_function_many+0x185/0x210
[  596.628086]  [<ffffffff81109ff0>] ? drain_local_pages+0x0/0x20
[  596.628086]  [<ffffffff810b4952>] ? smp_call_function+0x22/0x30
[  596.628086]  [<ffffffff81084934>] ? on_each_cpu+0x24/0x50
[  596.628086]  [<ffffffff81108a8c>] ? drain_all_pages+0x1c/0x20
[  596.628086]  [<ffffffff81108fad>] ? __alloc_pages_nodemask+0x42d/0x700
[  596.628086]  [<ffffffff8113d0f2>] ? kmem_getpages+0x62/0x160
[  596.628086]  [<ffffffff8113dce6>] ? fallback_alloc+0x196/0x240
[  596.628086]  [<ffffffff8113da68>] ? ____cache_alloc_node+0x98/0x180
[  596.628086]  [<ffffffff8113e643>] ? __kmalloc+0x193/0x230
[  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
[  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
[  596.628086]  [<ffffffff8131092e>] ? kmem_zalloc+0x1e/0x50
[  596.628086]  [<ffffffff812fac80>] ? xfs_log_commit_cil+0x500/0x590
[  596.628086]  [<ffffffff81310943>] ? kmem_zalloc+0x33/0x50
[  596.628086]  [<ffffffff813082d6>] ? _xfs_trans_commit+0x156/0x2f0
[  596.628086]  [<ffffffff8130d50e>] ? xfs_create+0x58e/0x700
[  596.628086]  [<ffffffff8131c587>] ? xfs_vn_mknod+0xa7/0x1c0
[  596.628086]  [<ffffffff8131c6d0>] ? xfs_vn_create+0x10/0x20
[  596.628086]  [<ffffffff81151f48>] ? vfs_create+0xb8/0xf0
[  596.628086]  [<ffffffff8115273c>] ? do_last+0x4dc/0x5d0
[  596.628086]  [<ffffffff81154937>] ? do_filp_open+0x207/0x5e0
[  596.628086]  [<ffffffff8115b7bc>] ? d_lookup+0x3c/0x60
[  596.628086]  [<ffffffff8105fc58>] ? pvclock_clocksource_read+0x58/0xd0
[  596.628086]  [<ffffffff813fd98e>] ? do_raw_spin_unlock+0x5e/0xb0
[  596.628086]  [<ffffffff8115f8fa>] ? alloc_fd+0xfa/0x140
[  596.628086]  [<ffffffff811448a5>] ? do_sys_open+0x65/0x130
[  596.628086]  [<ffffffff811449b0>] ? sys_open+0x20/0x30
[  596.628086]  [<ffffffff81036032>] ? system_call_fastpath+0x16/0x1b
[  596.628086] fs_mark       R  running task        0  2377   2163 0x00000008
[  596.628086]  0000000000000000 ffff880103dd9528 ffffffff813f2deb 000000000000003f
[  596.628086]  ffff88011c9806e0 ffff880103dd95a4 ffff880103dd9518 ffffffff813fd98e
[  596.628086]  ffff880103dd95a4 ffff88011ce51800 ffff880103dd9528 ffffffff8180722e
[  596.628086] Call Trace:
[  596.628086]  [<ffffffff813f2deb>] ? radix_tree_gang_lookup_tag+0x8b/0x100
[  596.628086]  [<ffffffff813fd98e>] ? do_raw_spin_unlock+0x5e/0xb0
[  596.628086]  [<ffffffff8180722e>] ? _raw_spin_unlock+0xe/0x10
[  596.628086]  [<ffffffff8131f318>] ? xfs_inode_ag_iter_next_pag+0x108/0x110
[  596.628086]  [<ffffffff8132018c>] ? xfs_reclaim_inode_shrink+0x4c/0x90
[  596.628086]  [<ffffffff81119d02>] ? zone_nr_free_pages+0xa2/0xc0
[  596.628086]  [<ffffffff8110758a>] ? zone_watermark_ok+0x2a/0xf0
[  596.628086]  [<ffffffff8103694e>] ? apic_timer_interrupt+0xe/0x20
[  596.628086]  [<ffffffff810b48c2>] ? smp_call_function_many+0x1a2/0x210
[  596.628086]  [<ffffffff810b48a5>] ? smp_call_function_many+0x185/0x210
[  596.628086]  [<ffffffff81109ff0>] ? drain_local_pages+0x0/0x20
[  596.628086]  [<ffffffff810b4952>] ? smp_call_function+0x22/0x30
[  596.628086]  [<ffffffff81084934>] ? on_each_cpu+0x24/0x50
[  596.628086]  [<ffffffff81108a8c>] ? drain_all_pages+0x1c/0x20
[  596.628086]  [<ffffffff81108fad>] ? __alloc_pages_nodemask+0x42d/0x700
[  596.628086]  [<ffffffff8113d0f2>] ? kmem_getpages+0x62/0x160
[  596.628086]  [<ffffffff8113dce6>] ? fallback_alloc+0x196/0x240
[  596.628086]  [<ffffffff8113da68>] ? ____cache_alloc_node+0x98/0x180
[  596.628086]  [<ffffffff8113e643>] ? __kmalloc+0x193/0x230
[  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
[  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
[  596.628086]  [<ffffffff8131092e>] ? kmem_zalloc+0x1e/0x50
[  596.628086]  [<ffffffff812fac80>] ? xfs_log_commit_cil+0x500/0x590
[  596.628086]  [<ffffffff81310943>] ? kmem_zalloc+0x33/0x50
[  596.628086]  [<ffffffff813082d6>] ? _xfs_trans_commit+0x156/0x2f0
[  596.628086]  [<ffffffff8130b2f9>] ? xfs_dir_ialloc+0x139/0x340
[  596.628086]  [<ffffffff812f9cc7>] ? xfs_log_reserve+0x167/0x1e0
[  596.628086]  [<ffffffff8130d35c>] ? xfs_create+0x3dc/0x700
[  596.628086]  [<ffffffff8131c587>] ? xfs_vn_mknod+0xa7/0x1c0
[  596.628086]  [<ffffffff8131c6d0>] ? xfs_vn_create+0x10/0x20
[  596.628086]  [<ffffffff81151f48>] ? vfs_create+0xb8/0xf0
[  596.628086]  [<ffffffff8115273c>] ? do_last+0x4dc/0x5d0
[  596.628086]  [<ffffffff81154937>] ? do_filp_open+0x207/0x5e0
[  596.628086]  [<ffffffff8115b7bc>] ? d_lookup+0x3c/0x60
[  596.628086]  [<ffffffff8105fc58>] ? pvclock_clocksource_read+0x58/0xd0
[  596.628086]  [<ffffffff813fd98e>] ? do_raw_spin_unlock+0x5e/0xb0
[  596.628086]  [<ffffffff8115f8fa>] ? alloc_fd+0xfa/0x140
[  596.628086]  [<ffffffff811448a5>] ? do_sys_open+0x65/0x130
[  596.628086]  [<ffffffff811449b0>] ? sys_open+0x20/0x30
[  596.628086]  [<ffffffff81036032>] ? system_call_fastpath+0x16/0x1b
[  596.628086] fs_mark       R  running task        0  2378   2163 0x00000000
[  596.628086]  ffff880103d53a78 0000000000000086 ffff8800a3fc6cc0 0000000000000caf
[  596.628086]  ffff880103d53a18 00000000000135c0 ffff88011f119040 00000000000135c0
[  596.628086]  ffff88011f1193a8 ffff880103d53fd8 ffff88011f1193b0 ffff880103d53fd8
[  596.628086] Call Trace8f/0xe0
[  596.628086]  [<ffffffff810773ca>] __cond_resched+0x2a/0x40
[  596.628086]  [<ffffffff8113e4f8>] ? __kmalloc+0x48/0x230
[  596.628086]  [<ffffffff81804d90>] _cond_resched+0x30/0x40
[  596.628086]  [<ffffffff8113e5e1>] __kmalloc+0x131/0x230
[  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
[  596.628086]  [<ffffffff8131083f>] kmem_alloc+0x8f/0xe0
[  596.628086]  [<ffffffff8131092e>] kmem_zalloc+0x1e/0x50
[  596.628086]  [<ffffffff81306b75>] xfs_trans_alloc_log_vecs+0xa5/0xe0
[  596.628086]  [<ffffffff813082b8>] _xfs_trans_commit+0x138/0x2f0
[  596.628086]  [<ffffffff8130d50e>] xfs_create+0x58e/0x700
[  596.628086]  [<ffffffff8131c587>] xfs_vn_mknod+0xa7/0x1c0
[  596.628086]  [<ffffffff8131c6d0>] xfs_vn_create+0x10/0x20
[  596.628086]  [<ffffffff81151f48>] vfs_create+0xb8/0xf0
[  596.628086]  [<ffffffff8115273c>] do_last+0x4dc/0x5d0
[  596.628086]  [<ffffffff81154937>] do_filp_open+0x207/0x5e0
[  596.628086]  [<ffffffff8115b7bc>] ? d_lookup+0x3c/0x60
[  596.628086]  [<ffffffff8105fc58>] ? pvclock_clocksource_read+0x58/0xd0
[  596.628086]  [<ffffffff813fd98e>] ? do_raw_spin_unlock+0x5e/0xb0
[  596.628086]  [<ffffffff8115f8fa>] ? alloc_fd+0xfa/0x140
[  596.628086]  [<ffffffff811448a5>] do_sys_open+0x65/0x130
[  596.628086]  [<ffffffff811449b0>] sys_open+0x20/0x30
[  596.628086]  [<ffffffff81036032>] system_call_fastpath+0x16/0x1b
[  596.628086] fs_mark       R  running task        0  2379   2163 0x00000000
[  596.628086]  ffff88011f0ddd80 ffff880103da5eb8 000001b600008243 ffff88008652ca80
[  596.628086]  ffffffff8115f8fa 00007fff71ba9370 ffff880000000005 ffff88011e35cb80
[  596.628086]  ffff880076835ed0 ffff880103da5f18 0000000000000005 ffff88006d30b000
[  596.628086] Call Trace:
[  596.628086]  [<ffffffff8115f8fa>] ? alloc_fd+0xfa/0x140
[  596.628086]  [<ffffffff811448a5>] ? do_sys_open+0x65/0x130
[  596.628086]  [<ffffffff811449b0>] ? sys_open+0x20/0x30
[  596.628086]  [<ffffffff81036032>] ? system_call_fastpath+0x16/0x1b
[  596.628086] fs_mark       R  running task        0  2380   2163 0x00000000
[  596.628086]  00000000000008fc 0000000000000001 0000000000000000 0000000000000296
[  596.628086]  0000000000000293 ffffffffffffff10 ffffffff810b48c2 0000000000000010
[  596.628086]  0000000000000202 ffff880103c05798 0000000000000018 ffffffff810b48a5
[  596.628086] Call Trace:
[  596.628086]  [<ffffffff810b48c2>] ? smp_call_function_many+0x1a2/0x210
[  596.628086]  [<ffffffff810b48a5>] ? smp_call_function_many+0x185/0x210
[  596.628086]  [<ffffffff81109ff0>] ? drain_local_pages+0x0/0x20
[  596.628086]  [<ffffffff810b4952>] ? smp_call_function+0x22/0x30
[  596.628086]  [<ffffffff81084934>] ? on_each_cpu+0x24/0x50
[  596.628086]  [<ffffffff81108a8c>] ? drain_all_pages+0x1c/0x20
[  596.628086]  [<ffffffff81108fad>] ? __alloc_pages_nodemask+0x42d/0x700
[  596.628086]  [<ffffffff8113d0f2>] ? kmem_getpages+0x62/0x160
[  596.628086]  [<ffffffff8113dce6>] ? fallback_alloc+0x196/0x240
[  596.628086]  [<ffffffff8113da68>] ? ____cache_alloc_node+0x98/0x180
[  596.628086]  [<ffffffff8113e643>] ? __kmalloc+0x193/0x230
[  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
[  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
[  596.628086]  [<ffffffff8131092e>] ? kmem_zalloc+0x1e/0x50
[  596.628086]  [<ffffffff812fac80>] ? xfs_log_commit_cil+0x500/0x590
[  596.628086]  [<ffffffff81310943>] ? kmem_zalloc+0x33/0x50
[  596.628086]  [<ffffffff813082d6>] ? _xfs_trans_commit+0x156/0x2f0
[  596.628086]  [<ffffffff8130d50e>] ? xfs_create+0x58e/0x700
[  596.628086]  [<ffffffff8131c587>] ? xfs_vn_mknod+0xa7/0x1c0
[  596.628086]  [<ffffffff8131c6d0>] ? xfs_vn_create+0x10/0x20
[  596.628086]  [<ffffffff81151f48>] ? vfs_create+0xb8/0xf0
[  596.628086]  [<ffffffff8115273c>] ? do_last+0x4dc/0x5d0
[  596.628086]  [<ffffffff81154937>] ? do_filp_open+0x207/0x5e0
[  596.628086]  [<ffffffff8115b7bc>] ? d_lookup+0x3c/0x60
[  596.628086]  [<ffffffff8105fc58>] ? pvclock_clocksource_read+0x58/0xd0
[  596.628086]  [<ffffffff813fd98e>] ? do_raw_spin_unlock+0x5e/0xb0
[  596.628086]  [<ffffffff8115f8fa>] ? alloc_fd+0xfa/0x140
[  596.628086]  [<ffffffff811448a5>] ? do_sys_open+0x65/0x130
[  596.628086]  [<ffffffff811449b0>] ? sys_open+0x20/0x30
[  596.628086]  [<ffffffff81036032>] ? system_call_fastpath+0x16/0x1b

and the kswapd thread:

[  596.628086] kswapd0       R  running task        0   547      2 0x00000000
[  596.628086]  ffff88011e78fbc0 0000000000000046 0000000000000000 ffffffff8103694e
[  596.628086]  ffff88011e78fbf0 00000000000135c0 ffff88011f17c040 00000000000135c0
[  596.628086]  ffff88011f17c3a8 ffff88011e78ffd8 ffff88011f17c3b0 ffff88011e78ffd8
[  596.628086] Call Trace:
[  596.628086]  [<ffffffff8103694e>] ? apic_timer_interrupt+0xe/0x20
[  596.628086]  [<ffffffff8103694e>] ? apic_timer_interrupt+0xe/0x20
[  596.628086]  [<ffffffff810773ca>] __cond_resched+0x2a/0x40
[  596.628086]  [<ffffffff81077422>] __cond_resched_lock+0x42/0x60
[  596.628086]  [<ffffffff811593a0>] __shrink_dcache_sb+0xf0/0x380
[  596.628086]  [<ffffffff811597c6>] shrink_dcache_memory+0x176/0x200
[  596.628086]  [<ffffffff81110bf4>] shrink_slab+0x124/0x180
[  596.628086]  [<ffffffff811125d2>] balance_pgdat+0x2e2/0x540
[  596.628086]  [<ffffffff8111295d>] kswapd+0x12d/0x390
[  596.628086]  [<ffffffff8109e8c0>] ? autoremove_wake_function+0x0/0x40
[  596.628086]  [<ffffffff81112830>] ? kswapd+0x0/0x390
[  596.628086]  [<ffffffff8109e396>] kthread+0x96/0xa0
[  596.628086]  [<ffffffff81036da4>] kernel_thread_helper+0x4/0x10
[  596.628086]  [<ffffffff8109e300>] ? kthread+0x0/0xa0
[  596.628086]  [<ffffffff81036da0>] ? kernel_thread_helper+0x0/0x10

I just went to grab the CAL counters, and found the system in
another livelock.  This time I managed to start the sysrq-trigger
dump while the livelock was in progress - I basN?cally got one shot
at a command before everything stopped responding. Now I'm waiting
for the livelock to pass.... 5min.... the fs_mark workload
has stopped (ctrl-c finally responded), still livelocked....
10min.... 15min.... 20min.... OK, back now.

Interesting - all the fs_mark processes are in D state waiting on IO
completion processing. And the only running processes are the
kworker threads, which are all processing either vmstat updates
(3 CPUs):

 kworker/6:1   R  running task        0   376      2 0x00000000
  ffff88011f255cf0 0000000000000046 ffff88011f255c90 ffffffff813fda34
  ffff88003c969588 00000000000135c0 ffff88011f27c7f0 00000000000135c0
  ffff88011f27cb58 ffff88011f255fd8 ffff88011f27cb60 ffff88011f255fd8
 Call Trace:
  [<ffffffff813fda34>] ? do_raw_spin_lock+0x54/0x160
  [<ffffffff810773ca>] __cond_resched+0x2a/0x40
  [<ffffffff81804d90>] _cond_resched+0x30/0x40
  [<ffffffff8111ab12>] refresh_cpu_vm_stats+0xc2/0x160
  [<ffffffff8111abb0>] ? vmstat_update+0x0/0x40
  [<ffffffff8111abc6>] vmstat_update+0x16/0x40
  [<ffffffff810978a0>] process_one_work+0x130/0x470
  [<ffffffff81099e72>] worker_thread+0x172/0x3f0
  [<ffffffff81099d00>] ? worker_thread+0x0/0x3f0
  [<ffffffff8109e396>] kthread+0x96/0xa0
  [<ffffffff81036da4>] kernel_thread_helper+0x4/0x10
  [<ffffffff8109e300>] ? kthread+0x0/0xa0
  [<ffffffff81036da0>] ? kernel_thread_helper+0x0/0x10

Or doing inode IO completion processing:

 kworker/7:1   R  running task        0   377      2 0x00000000
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  ffffffffffffff10 0000000000000001 ffffffffffffff10 ffffffff813f8062
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  0000000000000010 0000000000000202 ffff88011f0ffc80 ffffffff813f8067
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  00000000000ac613 ffff88011ba08280 00000000871803d0 0000000000000001
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017] Call Trace:
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff813f8062>] ? delay_tsc+0x22/0x80
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff813f808a>] ? delay_tsc+0x4a/0x80
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff813f7fdf>] ? __delay+0xf/0x20
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff813fdb03>] ? do_raw_spin_lock+0x123/0x160
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff818072be>] ? _raw_spin_lock+0xe/0x10
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff812f0244>] ? xfs_iflush_done+0x84/0xb0
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff813157c0>] ? xfs_buf_iodone_work+0x0/0x100
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff812cee54>] ? xfs_buf_do_callbacks+0x54/0x70
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff812cf0c0>] ? xfs_buf_iodone_callbacks+0x1a0/0x2a0
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff813fda34>] ? do_raw_spin_lock+0x54/0x160
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff813157c0>] ? xfs_buf_iodone_work+0x0/0x100
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff81315805>] ? xfs_buf_iodone_work+0x45/0x100
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff813157c0>] ? xfs_buf_iodone_work+0x0/0x100
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff810978a0>] ? process_one_work+0x130/0x470
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff81099e72>] ? worker_thread+0x172/0x3f0
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff81099d00>] ? worker_thread+0x0/0x3f0
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff8109e396>] ? kthread+0x96/0xa0
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff81036da4>] ? kernel_thread_helper+0x4/0x10
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff8109e300>] ? kthread+0x0/0xa0
 Sep  6 13:20:47 test-4 kernel: [ 2114.056017]  [<ffffffff81036da0>] ? kernel_thread_helper+0x0/0x10

It looks like there is spinlock contention occurring here on the xfs
AIL lock, so I'll need to look into this further. A second set of
traces I got during the livelock also showed this:

fs_mark       R  running task        0  2713      1 0x00000004
 ffff88011851b518 ffffffff81804669 ffff88011851b4d8 ffff880100000700
 0000000000000000 00000000000135c0 ffff88011f05b7f0 00000000000135c0
 ffff88011f05bb58 ffff88011851bfd8 ffff88011f05bb60 ffff88011851bfd8
Call Trace:
 [<ffffffff81804669>] ? schedule+0x3c9/0x9f0
 [<ffffffff81805235>] schedule_timeout+0x1d5/0x2a0
 [<ffffffff81119d02>] ? zone_nr_free_pages+0xa2/0xc0
 [<ffffffff813fda34>] ? do_raw_spin_lock+0x54/0x160
 [<ffffffff8110758a>] ? zone_watermark_ok+0x2a/0xf0
 [<ffffffff813fda34>] ? do_raw_spin_lock+0x54/0x160
 [<ffffffff81807275>] ? _raw_spin_lock_irq+0x15/0x20
 [<ffffffff81806638>] __down+0x78/0xb0
 [<ffffffff813fd98e>] ? do_raw_spin_unlock+0x5e/0xb0
 [<ffffffff8180722e>] ? _raw_spin_unlock+0xe/0x10
 [<ffffffff8113d8e6>] cache_alloc_refill+0x1c6/0x2b0
 [<ffffffff813fda34>] do_raw_spin_lock+0x54/0x160
 [<ffffffff812e9672>] ? xfs_iext_bno_to_irec+0xb2/0x100
 [<ffffffff811022ce>] ? find_get_page+0x1e/0xa0
 [<ffffffff81103dd7>] ? find_lock_page+0x37/0x80
 [<ffffffff8110438f>] ? find_or_create_page+0x3f/0xb0
 [<ffffffff811025e7>] ? unlock_page+0x27/0x30
 [<ffffffff81315167>] ? _xfs_buf_lookup_pages+0x297/0x370
 [<ffffffff813f808a>] ? delay_tsc+0x4a/0x80
 [<ffffffff813f7fdf>] ? __delay+0xf/0x20
 [<ffffffff813fda34>] ? do_raw_spin_lock+0x54/0x160
 [<ffffffff813fd98e>] ? do_raw_spin_unlock+0x5e/0xb0
 [<ffffffff8180722e>] ? _raw_spin_unlock+0xe/0x10
 [<ffffffff81109e69>] ? free_pcppages_bulk+0x369/0x400
 [<ffffffff813fda34>] ? do_raw_spin_lock+0x54/0x160
 [<ffffffff813fd98e>] ? do_raw_spin_unlock+0x5e/0xb0
 [<ffffffff813fd98e>] ? do_raw_spin_unlock+0x5e/0xb0
 [<ffffffff8180722e>] ? _raw_spin_unlock+0xe/0x10
 [<ffffffff81109e69>] ? free_pcppages_bulk+0x369/0x400
 [<ffffffff8110a508>] ? __pagevec_free+0x58/0xb0
 [<ffffffff813fd98e>] ? do_raw_spin_unlock+0x5e/0xb0
 [<ffffffff810af53c>] ? debug_mutex_add_waiter+0x2c/0x70
 [<ffffffff81805d70>] ? __mutex_lock_slowpath+0x1e0/0x280
 [<ffffffff813fda34>] ? do_raw_spin_lock+0x54/0x160
 [<ffffffff813fda34>] ? do_raw_spin_lock+0x54/0x160
 [<ffffffff813fda34>] ? do_raw_spin_lock+0x54/0x160
 [<ffffffff8180722e>] ? _raw_spin_unlock+0xe/0x10
 [<ffffffff813fda34>] ? do_raw_spin_lock+0x54/0x160
 [<ffffffff810fdac2>] ? perf_event_exit_task+0x32/0x160
 [<ffffffff813fd772>] ? do_raw_write_lock+0x42/0xa0
 [<ffffffff81807015>] ? _raw_write_lock_irq+0x15/0x20
 [<ffffffff81082315>] ? do_exit+0x195/0x7c0
 [<ffffffff813fda34>] ? do_raw_spin_lock+0x54/0x160
 [<ffffffff81082991>] ? do_group_exit+0x51/0xc0
 [<ffffffff81092d8c>] ? get_signal_to_deliver+0x27c/0x430
 [<ffffffff810352b5>] ? do_signal+0x75/0x7c0
 [<ffffffff8105fc58>] ? pvclock_clocksource_read+0x58/0xd0
 [<ffffffff813fda34>] ? do_raw_spin_lock+0x54/0x160
 [<ffffffff813fd98e>] ? do_raw_spin_unlock+0x5e/0xb0
 [<ffffffff8180722e>] ? _raw_spin_unlock+0xe/0x10
 [<ffffffff81035a65>] ? do_notify_resume+0x65/0x90
 [<ffffffff81036283>] ? int_signal+0x12/0x17

Because I tried to ctrl-c the fs_mark workload. All those lock
traces on the stack aren't related to XFS, so I'm wondering exactly
where they have come from....

Finally, /proc/interrupts shows:

CAL:      12156      12039      12676      12478      12919    12177      12767      12460   Function call interrupts

Which shows that this wasn't an IPI storm that caused this
particular livelock.

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
