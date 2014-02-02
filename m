Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 03DDF6B0035
	for <linux-mm@kvack.org>; Sun,  2 Feb 2014 18:42:45 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id up15so6391050pbc.36
        for <linux-mm@kvack.org>; Sun, 02 Feb 2014 15:42:45 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:7])
        by mx.google.com with ESMTP id ef2si18414338pbb.131.2014.02.02.15.42.43
        for <linux-mm@kvack.org>;
        Sun, 02 Feb 2014 15:42:44 -0800 (PST)
Date: Mon, 3 Feb 2014 10:42:39 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: [livelock, 3.13.0] livelock when run out of swap space
Message-ID: <20140202234239.GX2212@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Hi folks,

I just had a test machine livelock when running a concurrent rm -rf
workload on an XFS filesystem with 64k directory block sizes. The
buffer allocation code started reporting this 5 times a second:

XFS: possible memory allocation deadlock in kmem_alloc (mode:0x8250)

Which is in GFP_NOFS|GFP_ZERO context. It is likely to have been a
high order allocation (up to 64k), but there was still lenty of free
memory available (2.8GB of 16GB):

$ free
             total       used       free     shared    buffers     cached
Mem:      16424296   13593732    2830564          0        136       3184
-/+ buffers/cache:   13590412    2833884
Swap:       497976     497976          0
$

But clearly there was no page cache being used. All of the memory in
use was in the inode/dentry caches:

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
  9486678 9483271  99%    1.19K 364874       26  11675968K xfs_inode
  4820508 4820508 100%    0.21K 130284       37   1042272K dentry
  4820224 4820224 100%    0.06K  75316       64    301264K kmalloc-64

The issue is that memory allocation was not making progress - the
shrinkers we not doing anything because they were under GFP_NOFS
allocation context, and kswapd was never woken to take over. The
system was compeltely out of swap space, and all the CPU was being
burnt in this function:

   44.91%  [kernel]  [k] scan_swap_map

The typical stack trace of a looping memory allocation is this:

[211699.924006] CPU: 2 PID: 21939 Comm: rm Not tainted 3.13.0-dgc+ #172
[211699.924006] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[211699.924006] task: ffff88041a7dde40 ti: ffff8803bbeec000 task.ti: ffff8803bbeec000
[211699.924006] RIP: 0010:[<ffffffff81187dd8>]  [<ffffffff81187dd8>] scan_swap_map+0x118/0x520
[211699.924006] RSP: 0018:ffff8803bbeed508  EFLAGS: 00000297
[211699.924006] RAX: 000000000000a1ba RBX: 0000000000000032 RCX: 0000000000000000
[211699.924006] RDX: 0000000000000001 RSI: 000000000001e64e RDI: 0000000000019def
[211699.924006] RBP: ffff8803bbeed558 R08: 00000000002c6ba0 R09: 0000000000000000
[211699.924006] R10: 57ffb90ace3d4f80 R11: 0000000000019def R12: ffff88041a682900
[211699.924006] R13: 01ffffffffffffff R14: 0000000000000040 R15: ffff88041a6829a0
[211699.924006] FS:  00007fae682c8700(0000) GS:ffff88031bc00000(0000) knlGS:0000000000000000
[211699.924006] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[211699.924006] CR2: 00000000004353b0 CR3: 00000002ea498000 CR4: 00000000000006e0
[211699.924006] Stack:
[211699.924006]  ffff8803bbeed538 ffff88031a9dc720 000000000000a1ba 0000000000004893
[211699.924006]  0000000000000000 ffff88041a682900 0000000000000000 0000000000000001
[211699.924006]  0000000000000000 ffff88041a6829a0 ffff8803bbeed598 ffffffff8118837f
[211699.924006] Call Trace:
[211699.924006]  [<ffffffff8118837f>] get_swap_page+0xef/0x1e0
[211699.924006]  [<ffffffff81184e34>] add_to_swap+0x24/0x70
[211699.924006]  [<ffffffff8115f110>] shrink_page_list+0x300/0xa20
[211699.924006]  [<ffffffff81169089>] ? __mod_zone_page_state+0x49/0x50
[211699.924006]  [<ffffffff8116a3b9>] ? wait_iff_congested+0xa9/0x150
[211699.924006]  [<ffffffff8115fe03>] shrink_inactive_list+0x243/0x480
[211699.924006]  [<ffffffff811606f1>] shrink_lruvec+0x371/0x670
[211699.924006]  [<ffffffff81cdb4ce>] ? _raw_spin_unlock+0xe/0x10
[211699.924006]  [<ffffffff81160dea>] do_try_to_free_pages+0x11a/0x360
[211699.924006]  [<ffffffff81161220>] try_to_free_pages+0x110/0x190
[211699.924006]  [<ffffffff81156422>] __alloc_pages_nodemask+0x5a2/0x8a0
[211699.924006]  [<ffffffff8118fac2>] alloc_pages_current+0xb2/0x170
[211699.924006]  [<ffffffff81151bde>] __get_free_pages+0xe/0x50
[211699.924006]  [<ffffffff8116d199>] kmalloc_order_trace+0x39/0xb0
[211699.924006]  [<ffffffff810cf4c3>] ? finish_wait+0x63/0x80
[211699.924006]  [<ffffffff81197156>] __kmalloc+0x176/0x180
[211699.924006]  [<ffffffff810cf520>] ? __init_waitqueue_head+0x40/0x40
[211699.924006]  [<ffffffff814a74f7>] kmem_alloc+0x77/0xf0
[211699.924006]  [<ffffffff814feb54>] xfs_log_commit_cil+0x3c4/0x5a0
[211699.924006]  [<ffffffff814a6be3>] xfs_trans_commit+0xc3/0x2d0
[211699.924006]  [<ffffffff814e913e>] xfs_remove+0x3be/0x440
[211699.924006]  [<ffffffff811b7d8d>] ? __d_lookup+0x11d/0x170
[211699.924006]  [<ffffffff8149b842>] xfs_vn_unlink+0x52/0xa0
[211699.924006]  [<ffffffff811acc22>] vfs_unlink+0xf2/0x160
[211699.924006]  [<ffffffff811acef0>] do_unlinkat+0x260/0x2a0
[211699.924006]  [<ffffffff811b003b>] SyS_unlinkat+0x1b/0x40
[211699.924006]  [<ffffffff81ce3ea9>] system_call_fastpath+0x16/0x1b

i.e. trying to do memory allocation during a transaction commit in
XFS, and that is looping in kmem_alloc().

THe problem in this case is that kswapd was not being started to
free slab cache memory (i.e. to handle the defered GFP_NOFS slab
reclaim).  It stayed in the livelock state for over an hour before I
broke it by running "echo 2 > /proc/sys/vm/drop_caches" manually.
That immediately freed up the slab cache as reclaim was not under
GFP_NOFS constraints and the livelock went away and the system
started to make progress again.

I haven't seen this problem before, so this may be a regression...

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
