Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 71A006B0253
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 17:59:34 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id yy13so35931393pab.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 14:59:34 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id 82si15361155pfn.23.2016.02.11.14.59.32
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 14:59:33 -0800 (PST)
Date: Fri, 12 Feb 2016 09:59:29 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle infinite too_many_isolated() loop (for OOM
 detection rework v4) ?
Message-ID: <20160211225929.GU14668@dastard>
References: <201602092349.ACG81273.OSVtMJQHLOFOFF@I-love.SAKURA.ne.jp>
 <201602111606.IIG81724.QOLFJOSMtFHOFV@I-love.SAKURA.ne.jp>
 <201602112045.ADF05756.SOOVFFFQLOtJMH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602112045.ADF05756.SOOVFFFQLOtJMH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, rientjes@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

On Thu, Feb 11, 2016 at 08:45:10PM +0900, Tetsuo Handa wrote:
> (Adding Dave Chinner in case he has any comment although this problem is not
> specific to XFS.)

....

> Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160211-2.txt.xz .
> ---------- console log ----------
> [   89.960570] MemAlloc-Info: stalling=466 dying=1 exiting=0, victim=0 oom_count=17
> [   90.056315] MemAlloc: kswapd0(47) flags=0xa60840 uninterruptible
> [   90.058146] kswapd0         D ffff88007a2d3188     0    47      2 0x00000000
> [   90.059998]  ffff88007a2d3188 ffff880066421640 ffff88007cbf42c0 ffff88007a2d4000
> [   90.061942]  ffff88007a9ff4b0 ffff88007cbf42c0 ffff880079dd1600 0000000000000000
> [   90.063820]  ffff88007a2d31a0 ffffffff81701fa7 7fffffffffffffff ffff88007a2d3240
> [   90.065843] Call Trace:
> [   90.066803]  [<ffffffff81701fa7>] schedule+0x37/0x90
> [   90.068233]  [<ffffffff817063e8>] schedule_timeout+0x178/0x1c0
> [   90.070040]  [<ffffffff813b2259>] ? find_next_bit+0x19/0x20
> [   90.071635]  [<ffffffff8139d88f>] ? cpumask_next_and+0x2f/0x40
> [   90.073223]  [<ffffffff81705258>] __down+0x7c/0xc3
> [   90.074629]  [<ffffffff81706b63>] ? _raw_spin_lock_irqsave+0x53/0x60
> [   90.076230]  [<ffffffff810ba36c>] down+0x3c/0x50
> [   90.077624]  [<ffffffff812b21f1>] xfs_buf_lock+0x21/0x50
> [   90.079058]  [<ffffffff812b23cf>] _xfs_buf_find+0x1af/0x2c0
> [   90.080637]  [<ffffffff812b2505>] xfs_buf_get_map+0x25/0x150
> [   90.082131]  [<ffffffff812b2ac9>] xfs_buf_read_map+0x29/0xd0
> [   90.083602]  [<ffffffff812dce27>] xfs_trans_read_buf_map+0x97/0x1a0
> [   90.085267]  [<ffffffff8127a945>] xfs_read_agf+0x75/0xb0
> [   90.086776]  [<ffffffff8127a9a4>] xfs_alloc_read_agf+0x24/0xd0
> [   90.088217]  [<ffffffff8127ad75>] xfs_alloc_fix_freelist+0x325/0x3e0
> [   90.089796]  [<ffffffff813a398a>] ? __radix_tree_lookup+0xda/0x140
> [   90.091335]  [<ffffffff8127b02e>] xfs_alloc_vextent+0x19e/0x480
> [   90.092922]  [<ffffffff81288caf>] xfs_bmap_btalloc+0x3bf/0x710
> [   90.094437]  [<ffffffff81289009>] xfs_bmap_alloc+0x9/0x10
> [   90.096775]  [<ffffffff812899fa>] xfs_bmapi_write+0x47a/0xa10
> [   90.098328]  [<ffffffff812bee97>] xfs_iomap_write_allocate+0x167/0x370
> [   90.100013]  [<ffffffff812abf3a>] xfs_map_blocks+0x15a/0x170
> [   90.101466]  [<ffffffff812acf57>] xfs_vm_writepage+0x187/0x5c0
> [   90.103025]  [<ffffffff81153a7f>] pageout.isra.43+0x18f/0x250
> [   90.104570]  [<ffffffff8115548e>] shrink_page_list+0x82e/0xb10
> [   90.106057]  [<ffffffff81155ed7>] shrink_inactive_list+0x207/0x550
> [   90.107531]  [<ffffffff81156bd6>] shrink_zone_memcg+0x5b6/0x780
> [   90.109004]  [<ffffffff81156e72>] shrink_zone+0xd2/0x2f0
> [   90.110318]  [<ffffffff81157dbc>] kswapd+0x4cc/0x920
> [   90.111561]  [<ffffffff811578f0>] ? mem_cgroup_shrink_node_zone+0xb0/0xb0
> [   90.113229]  [<ffffffff81090989>] kthread+0xf9/0x110
> [   90.114502]  [<ffffffff81707672>] ret_from_fork+0x22/0x50
> [   90.115900]  [<ffffffff81090890>] ? kthread_create_on_node+0x230/0x230
> [  105.775213] zone=DMA NR_INACTIVE_FILE=6 NR_ISOLATED_FILE=32
> [  129.472341] MemAlloc-Info: stalling=474 dying=1 exiting=0, victim=0 oom_count=17
> ---------- console log ----------

So the problem here is that dirty page writeback is being done by
kswapd. We all know that dirty page writeback can (and does) block
on filesystem locks, and as such it can get blocked on locks held by
other threads that are already blocked waiting for memory reclaim
whilst holding those filesystem locks (i.e. in GFP_NOFS allocation).

> Although there are memory allocating tasks passing gfp flags with
> __GFP_KSWAPD_RECLAIM, kswapd is unable to make forward progress because
> it is blocked at down() called from memory reclaim path. And since it is
> legal to block kswapd from memory reclaim path (am I correct?), I think
> we must not assume that current_is_kswapd() check will break the infinite
> loop condition.

Right, the threads that are blocked in writeback waiting on memory
reclaim will be using GFP_NOFS to prevent recursion deadlocks, but
that does not avoid the problem that kswapd can then get stuck
on those locks, too. Hence there is no guarantee that kswapd can
make reclaim progress if it does dirty page writeback...

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
