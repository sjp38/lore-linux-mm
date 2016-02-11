Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id DC7C06B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:45:36 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id wb13so70174284obb.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 03:45:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id vx7si8748968oeb.68.2016.02.11.03.45.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Feb 2016 03:45:34 -0800 (PST)
Subject: Re: How to handle infinite too_many_isolated() loop (for OOM detection rework v4) ?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602092349.ACG81273.OSVtMJQHLOFOFF@I-love.SAKURA.ne.jp>
	<201602111606.IIG81724.QOLFJOSMtFHOFV@I-love.SAKURA.ne.jp>
In-Reply-To: <201602111606.IIG81724.QOLFJOSMtFHOFV@I-love.SAKURA.ne.jp>
Message-Id: <201602112045.ADF05756.SOOVFFFQLOtJMH@I-love.SAKURA.ne.jp>
Date: Thu, 11 Feb 2016 20:45:10 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, david@fromorbit.com, linux-mm@kvack.org

(Adding Dave Chinner in case he has any comment although this problem is not
specific to XFS.)

Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > The result is that, we have no TIF_MEMDIE tasks but nobody is calling
> > out_of_memory(). That is, OOM livelock without invoking the OOM killer.
> > They seem to be waiting at congestion_wait() from too_many_isolated()
> > loop called from shrink_inactive_list() because nobody can make forward
> > progress. I think we must not wait forever at too_many_isolated() loop.
> 
> Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160211.txt.xz .
> ---------- console log ----------
> [  101.471027] MemAlloc-Info: stalling=46 dying=2 exiting=0, victim=0 oom_count=182
> [  117.187128] zone=DMA NR_INACTIVE_FILE=4 NR_ISOLATED_FILE=19
> [  121.199151] MemAlloc-Info: stalling=50 dying=2 exiting=0, victim=0 oom_count=182
> [  123.777398] zone=DMA NR_INACTIVE_FILE=4 NR_ISOLATED_FILE=19
> [  141.184386] MemAlloc-Info: stalling=50 dying=2 exiting=0, victim=0 oom_count=182
> [  142.944292] zone=DMA NR_INACTIVE_FILE=4 NR_ISOLATED_FILE=19
> [  161.188356] MemAlloc-Info: stalling=51 dying=2 exiting=0, victim=0 oom_count=182
> [  163.541083] zone=DMA NR_INACTIVE_FILE=4 NR_ISOLATED_FILE=19
> [  181.211690] MemAlloc-Info: stalling=51 dying=2 exiting=0, victim=0 oom_count=182
> [  189.423559] zone=DMA NR_INACTIVE_FILE=4 NR_ISOLATED_FILE=19
> [  201.404914] MemAlloc-Info: stalling=51 dying=2 exiting=0, victim=0 oom_count=182
> [  204.456970] zone=DMA NR_INACTIVE_FILE=4 NR_ISOLATED_FILE=19
> [  213.753982] MemAlloc-Info: stalling=53 dying=2 exiting=0, victim=0 oom_count=182
> [  215.117586] zone=DMA NR_INACTIVE_FILE=4 NR_ISOLATED_FILE=19
> ---------- console log ----------
> 
> The zone which causes this silent hang up is not DMA32 but DMA. Nobody except
> kswapd can escape this too_many_isolated() loop because isolated > inactive is
> always true. Unless kswapd performs operations for making isolated > inactive
> false, we will silently hang up. And I think kswapd did nothing for this zone.
> 

I used delta patch shown below for confirming that kswapd did nothing for DMA
zone in order to make isolated > inactive false.

---------- delta2 patch (for linux-next-20160209 + kmallocwd + delta) ----------
diff --git a/kernel/hung_task.c b/kernel/hung_task.c
index d804d7e..5a7ea78 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -232,7 +232,7 @@ static void check_memalloc_stalling_tasks(unsigned long timeout)
 		bool can_cont;
 		u8 type;
 
-		if (likely(!p->memalloc.type))
+		if (likely(!p->memalloc.type && !(p->flags & PF_KSWAPD)))
 			continue;
 		p->memalloc.type = 0;
 		/* Recheck in case state changed meanwhile. */
@@ -250,7 +250,7 @@ static void check_memalloc_stalling_tasks(unsigned long timeout)
 				 memalloc.sequence >> 1, memalloc.gfp, &memalloc.gfp,
 				 memalloc.order, now - memalloc.start);
 		}
-		if (unlikely(!type))
+		if (unlikely(!type && !(p->flags & PF_KSWAPD)))
 			continue;
 		/*
 		 * Victim tasks get pending SIGKILL removed before arriving at
---------- delta2 patch (for linux-next-20160209 + kmallocwd + delta) ----------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160211-2.txt.xz .
---------- console log ----------
[   89.960570] MemAlloc-Info: stalling=466 dying=1 exiting=0, victim=0 oom_count=17
[   90.056315] MemAlloc: kswapd0(47) flags=0xa60840 uninterruptible
[   90.058146] kswapd0         D ffff88007a2d3188     0    47      2 0x00000000
[   90.059998]  ffff88007a2d3188 ffff880066421640 ffff88007cbf42c0 ffff88007a2d4000
[   90.061942]  ffff88007a9ff4b0 ffff88007cbf42c0 ffff880079dd1600 0000000000000000
[   90.063820]  ffff88007a2d31a0 ffffffff81701fa7 7fffffffffffffff ffff88007a2d3240
[   90.065843] Call Trace:
[   90.066803]  [<ffffffff81701fa7>] schedule+0x37/0x90
[   90.068233]  [<ffffffff817063e8>] schedule_timeout+0x178/0x1c0
[   90.070040]  [<ffffffff813b2259>] ? find_next_bit+0x19/0x20
[   90.071635]  [<ffffffff8139d88f>] ? cpumask_next_and+0x2f/0x40
[   90.073223]  [<ffffffff81705258>] __down+0x7c/0xc3
[   90.074629]  [<ffffffff81706b63>] ? _raw_spin_lock_irqsave+0x53/0x60
[   90.076230]  [<ffffffff810ba36c>] down+0x3c/0x50
[   90.077624]  [<ffffffff812b21f1>] xfs_buf_lock+0x21/0x50
[   90.079058]  [<ffffffff812b23cf>] _xfs_buf_find+0x1af/0x2c0
[   90.080637]  [<ffffffff812b2505>] xfs_buf_get_map+0x25/0x150
[   90.082131]  [<ffffffff812b2ac9>] xfs_buf_read_map+0x29/0xd0
[   90.083602]  [<ffffffff812dce27>] xfs_trans_read_buf_map+0x97/0x1a0
[   90.085267]  [<ffffffff8127a945>] xfs_read_agf+0x75/0xb0
[   90.086776]  [<ffffffff8127a9a4>] xfs_alloc_read_agf+0x24/0xd0
[   90.088217]  [<ffffffff8127ad75>] xfs_alloc_fix_freelist+0x325/0x3e0
[   90.089796]  [<ffffffff813a398a>] ? __radix_tree_lookup+0xda/0x140
[   90.091335]  [<ffffffff8127b02e>] xfs_alloc_vextent+0x19e/0x480
[   90.092922]  [<ffffffff81288caf>] xfs_bmap_btalloc+0x3bf/0x710
[   90.094437]  [<ffffffff81289009>] xfs_bmap_alloc+0x9/0x10
[   90.096775]  [<ffffffff812899fa>] xfs_bmapi_write+0x47a/0xa10
[   90.098328]  [<ffffffff812bee97>] xfs_iomap_write_allocate+0x167/0x370
[   90.100013]  [<ffffffff812abf3a>] xfs_map_blocks+0x15a/0x170
[   90.101466]  [<ffffffff812acf57>] xfs_vm_writepage+0x187/0x5c0
[   90.103025]  [<ffffffff81153a7f>] pageout.isra.43+0x18f/0x250
[   90.104570]  [<ffffffff8115548e>] shrink_page_list+0x82e/0xb10
[   90.106057]  [<ffffffff81155ed7>] shrink_inactive_list+0x207/0x550
[   90.107531]  [<ffffffff81156bd6>] shrink_zone_memcg+0x5b6/0x780
[   90.109004]  [<ffffffff81156e72>] shrink_zone+0xd2/0x2f0
[   90.110318]  [<ffffffff81157dbc>] kswapd+0x4cc/0x920
[   90.111561]  [<ffffffff811578f0>] ? mem_cgroup_shrink_node_zone+0xb0/0xb0
[   90.113229]  [<ffffffff81090989>] kthread+0xf9/0x110
[   90.114502]  [<ffffffff81707672>] ret_from_fork+0x22/0x50
[   90.115900]  [<ffffffff81090890>] ? kthread_create_on_node+0x230/0x230
[  105.775213] zone=DMA NR_INACTIVE_FILE=6 NR_ISOLATED_FILE=32
[  129.472341] MemAlloc-Info: stalling=474 dying=1 exiting=0, victim=0 oom_count=17
---------- console log ----------

Although there are memory allocating tasks passing gfp flags with
__GFP_KSWAPD_RECLAIM, kswapd is unable to make forward progress because
it is blocked at down() called from memory reclaim path. And since it is
legal to block kswapd from memory reclaim path (am I correct?), I think
we must not assume that current_is_kswapd() check will break the infinite
loop condition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
