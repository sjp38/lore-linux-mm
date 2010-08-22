Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DAE6B6007D6
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 19:48:15 -0400 (EDT)
Date: Mon, 23 Aug 2010 09:48:11 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: [2.6.35-rc1, bug] mm: minute-long livelocks in memory reclaim
Message-ID: <20100822234811.GF31488@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Folks,

I've been testing parallel create workloads over the weekend, and
I've seen this a couple of times now under 8 thread parallel creates
with XFS. I'm running on an 8p VM with 4GB RAM and a fast disk
subsystem. Basically I am seeing the create rate drop to zero
with all 8 CPUs stuck spinning for up to 2 minutes. 'echo t >
/proc/sysrq-trigger' while this is occurring gives the following
trace for all the fs-mark processes:

[49506.624018] fs_mark       R  running task        0  8376   7917 0x00000008
[49506.624018]  0000000000000000 ffffffff81b94590 00000000000008fc 0000000000000002
[49506.624018]  0000000000000000 0000000000000286 0000000000000297 ffffffffffffff10
[49506.624018]  ffffffff810b3d02 0000000000000010 0000000000000202 ffff88011df777a8
[49506.624018] Call Trace:
[49506.624018]  [<ffffffff810b3d02>] ? smp_call_function_many+0x1a2/0x210
[49506.624018]  [<ffffffff810b3ce5>] ? smp_call_function_many+0x185/0x210
[49506.624018]  [<ffffffff81109170>] ? drain_local_pages+0x0/0x20
[49506.624018]  [<ffffffff810b3d92>] ? smp_call_function+0x22/0x30
[49506.624018]  [<ffffffff810849a4>] ? on_each_cpu+0x24/0x50
[49506.624018]  [<ffffffff81107bec>] ? drain_all_pages+0x1c/0x20
[49506.624018]  [<ffffffff8110825a>] ? __alloc_pages_nodemask+0x57a/0x730
[49506.624018]  [<ffffffff8113c6d2>] ? kmem_getpages+0x62/0x160
[49506.624018]  [<ffffffff8113d2b2>] ? fallback_alloc+0x192/0x240
[49506.624018]  [<ffffffff8113cce1>] ? cache_grow+0x2d1/0x300
[49506.624018]  [<ffffffff8113d04a>] ? ____cache_alloc_node+0x9a/0x170
[49506.624018]  [<ffffffff8113cf6c>] ? cache_alloc_refill+0x25c/0x2a0
[49506.624018]  [<ffffffff8113ddb3>] ? __kmalloc+0x193/0x230
[49506.624018]  [<ffffffff812f59af>] ? kmem_alloc+0x8f/0xe0
[49506.624018]  [<ffffffff812f59af>] ? kmem_alloc+0x8f/0xe0
[49506.624018]  [<ffffffff812f5a9e>] ? kmem_zalloc+0x1e/0x50
[49506.624018]  [<ffffffff812e2f4d>] ? xfs_log_commit_cil+0x9d/0x440
[49506.624018]  [<ffffffff812eeec6>] ? _xfs_trans_commit+0x1e6/0x2b0
[49506.624018]  [<ffffffff812f2b6f>] ? xfs_create+0x51f/0x690
[49506.624018]  [<ffffffff812ffdb7>] ? xfs_vn_mknod+0xa7/0x1c0
[49506.624018]  [<ffffffff812fff00>] ? xfs_vn_create+0x10/0x20
[49506.624018]  [<ffffffff811510b8>] ? vfs_create+0xb8/0xf0
[49506.624018]  [<ffffffff81151d2c>] ? do_last+0x4dc/0x5d0
[49506.624018]  [<ffffffff81153bd7>] ? do_filp_open+0x207/0x5e0
[49506.624018]  [<ffffffff8105fc58>] ? pvclock_clocksource_read+0x58/0xd0
[49506.624018]  [<ffffffff8115eaca>] ? alloc_fd+0x10a/0x150
[49506.624018]  [<ffffffff81144005>] ? do_sys_open+0x65/0x130
[49506.624018]  [<ffffffff81144110>] ? sys_open+0x20/0x30
[49506.624018]  [<ffffffff81036072>] ? system_call_fastpath+0x16/0x1b

Eventually the problem goes away, and the system goes back to
performing at the normal rate. Any ideas on how to avoid this
problem? I'm using CONFIG_SLAB=y is that is relevant....

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
