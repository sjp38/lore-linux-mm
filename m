Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D52F6B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 07:04:26 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id q75so114617084itc.6
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 04:04:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id pa3si29371664pac.20.2016.10.18.04.04.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 04:04:25 -0700 (PDT)
Subject: How to make warn_alloc() reliable?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201610182004.AEF87559.FOOHVLJOQFFtSM@I-love.SAKURA.ne.jp>
Date: Tue, 18 Oct 2016 20:04:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit 63f53dea0c9866e9 ("mm: warn about allocations which stall for
too long") is a great step for reducing possibility of silent hang up
problem caused by memory allocation stalls. For example, below is a
report where write() request got stuck because it cannot invoke the
OOM killer due to GFP_NOFS allocation request.

---------- From http://I-love.SAKURA.ne.jp/tmp/serial-20161017-xfs-loop.txt.xz ----------
[  351.824548] oom_reaper: reaped process 4727 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  362.309509] warn_alloc: 96 callbacks suppressed
(...snipped...)
[  707.833650] a.out: page alloction stalls for 370009ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  707.833653] CPU: 3 PID: 4746 Comm: a.out Tainted: G        W       4.9.0-rc1+ #80
[  707.833653] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  707.833656]  ffffc90006d27950 ffffffff812e9777 ffffffff8197c438 0000000000000001
[  707.833657]  ffffc90006d279d8 ffffffff8112a114 0342004a7fffd720 ffffffff8197c438
[  707.833658]  ffffc90006d27978 ffffffff00000010 ffffc90006d279e8 ffffc90006d27998
[  707.833658] Call Trace:
[  707.833662]  [<ffffffff812e9777>] dump_stack+0x4f/0x68
[  707.833665]  [<ffffffff8112a114>] warn_alloc+0x144/0x160
[  707.833666]  [<ffffffff8112aad6>] __alloc_pages_nodemask+0x936/0xe80
[  707.833670]  [<ffffffff81177f07>] alloc_pages_current+0x87/0x110
[  707.833672]  [<ffffffff8111f33c>] __page_cache_alloc+0xdc/0x120
[  707.833673]  [<ffffffff8111fe58>] pagecache_get_page+0x88/0x2b0
[  707.833675]  [<ffffffff81120f5b>] grab_cache_page_write_begin+0x1b/0x40
[  707.833677]  [<ffffffff812036ab>] iomap_write_begin+0x4b/0x100
[  707.833678]  [<ffffffff81203932>] iomap_write_actor+0xb2/0x190
[  707.833680]  [<ffffffff81285dcb>] ? xfs_trans_commit+0xb/0x10
[  707.833681]  [<ffffffff81203880>] ? iomap_write_end+0x70/0x70
[  707.833682]  [<ffffffff81203f5e>] iomap_apply+0xae/0x130
[  707.833683]  [<ffffffff81204043>] iomap_file_buffered_write+0x63/0xa0
[  707.833684]  [<ffffffff81203880>] ? iomap_write_end+0x70/0x70
[  707.833686]  [<ffffffff8126bd0f>] xfs_file_buffered_aio_write+0xcf/0x1f0
[  707.833689]  [<ffffffff816152a8>] ? _raw_spin_lock_irqsave+0x18/0x40
[  707.833690]  [<ffffffff81615053>] ? _raw_spin_unlock_irqrestore+0x13/0x30
[  707.833692]  [<ffffffff8126beb5>] xfs_file_write_iter+0x85/0x120
[  707.833694]  [<ffffffff811a802d>] __vfs_write+0xdd/0x140
[  707.833695]  [<ffffffff811a8c7d>] vfs_write+0xad/0x1a0
[  707.833697]  [<ffffffff810021f0>] ? syscall_trace_enter+0x1b0/0x240
[  707.833698]  [<ffffffff811aa090>] SyS_write+0x50/0xc0
[  707.833700]  [<ffffffff811d6b78>] ? do_fsync+0x38/0x60
[  707.833701]  [<ffffffff8100241c>] do_syscall_64+0x5c/0x170
[  707.833702]  [<ffffffff81615786>] entry_SYSCALL64_slow_path+0x25/0x25
[  707.833703] Mem-Info:
[  707.833706] active_anon:451061 inactive_anon:2097 isolated_anon:0
[  707.833706]  active_file:13 inactive_file:115 isolated_file:27
[  707.833706]  unevictable:0 dirty:80 writeback:1 unstable:0
[  707.833706]  slab_reclaimable:3291 slab_unreclaimable:21028
[  707.833706]  mapped:416 shmem:2162 pagetables:3734 bounce:0
[  707.833706]  free:13182 free_pcp:125 free_cma:0
[  707.833708] Node 0 active_anon:1804244kB inactive_anon:8388kB active_file:52kB inactive_file:460kB unevictable:0kB isolated(anon):0kB isolated(file):108kB mapped:1664kB dirty:320kB writeback:4kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 1472512kB anon_thp: 8648kB writeback_tmp:0kB unstable:0kB pages_scanned:1255 all_unreclaimable? yes
[  707.833710] Node 0 DMA free:8192kB min:352kB low:440kB high:528kB active_anon:7656kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:24kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  707.833712] lowmem_reserve[]: 0 1963 1963 1963
[  707.833714] Node 0 DMA32 free:44536kB min:44700kB low:55872kB high:67044kB active_anon:1796588kB inactive_anon:8388kB active_file:52kB inactive_file:460kB unevictable:0kB writepending:324kB present:2080640kB managed:2010816kB mlocked:0kB slab_reclaimable:13164kB slab_unreclaimable:84080kB kernel_stack:7312kB pagetables:14912kB bounce:0kB free_pcp:500kB local_pcp:168kB free_cma:0kB
[  707.833715] lowmem_reserve[]: 0 0 0 0
[  707.833720] Node 0 DMA: 4*4kB (M) 2*8kB (UM) 0*16kB 1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 1*512kB (M) 1*1024kB (U) 1*2048kB (M) 1*4096kB (M) = 8192kB
[  707.833725] Node 0 DMA32: 4*4kB (UME) 41*8kB (MEH) 692*16kB (UME) 653*32kB (UME) 135*64kB (UMEH) 16*128kB (UMH) 2*256kB (H) 0*512kB 1*1024kB (H) 0*2048kB 0*4096kB = 44536kB
[  707.833726] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  707.833727] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  707.833727] 2317 total pagecache pages
[  707.833728] 0 pages in swap cache
[  707.833729] Swap cache stats: add 0, delete 0, find 0/0
[  707.833729] Free swap  = 0kB
[  707.833729] Total swap = 0kB
[  707.833730] 524157 pages RAM
[  707.833730] 0 pages HighMem/MovableOnly
[  707.833730] 17477 pages reserved
[  707.833730] 0 pages hwpoisoned
---------- From http://I-love.SAKURA.ne.jp/tmp/serial-20161017-xfs-loop.txt.xz ----------

But that commit does not cover all possibilities caused by memory
allocation stalls. For example, without below patch,

----------
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 744f926..bbd0769 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1554,7 +1554,7 @@ int isolate_lru_page(struct page *page)
  * the LRU list will go small and be scanned faster than necessary, leading to
  * unnecessary swapping, thrashing and OOM.
  */
-static int too_many_isolated(struct pglist_data *pgdat, int file,
+static long too_many_isolated(struct pglist_data *pgdat, int file,
 		struct scan_control *sc)
 {
 	unsigned long inactive, isolated;
@@ -1581,7 +1581,7 @@ static int too_many_isolated(struct pglist_data *pgdat, int file,
 	if ((sc->gfp_mask & (__GFP_IO | __GFP_FS)) == (__GFP_IO | __GFP_FS))
 		inactive >>= 3;
 
-	return isolated > inactive;
+	return isolated - inactive;
 }
 
 static noinline_for_stack void
@@ -1697,11 +1697,25 @@ static bool inactive_reclaimable_pages(struct lruvec *lruvec,
 	int file = is_file_lru(lru);
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
+	unsigned long wait_start = jiffies;
+	unsigned int wait_timeout = 10 * HZ;
+	long last_diff = 0;
+	long diff;
 
 	if (!inactive_reclaimable_pages(lruvec, sc, lru))
 		return 0;
 
-	while (unlikely(too_many_isolated(pgdat, file, sc))) {
+	while (unlikely((diff = too_many_isolated(pgdat, file, sc)) > 0)) {
+		if (diff < last_diff) {
+			wait_start = jiffies;
+			wait_timeout = 10 * HZ;
+		} else if (time_after(jiffies, wait_start + wait_timeout)) {
+			warn_alloc(sc->gfp_mask,
+				   "shrink_inactive_list() stalls for %ums",
+				   jiffies_to_msecs(jiffies - wait_start));
+			wait_timeout += 10 * HZ;
+		}
+		last_diff = diff;
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/* We are about to die and free our memory. Return now. */
----------

we cannot report a OOM livelock (shown below) where all ___GFP_DIRECT_RECLAIM
allocation requests got stuck at too_many_isolated() from shrink_inactive_list()
waiting for kswapd which got stuck waiting for a lock.

---------- From http://I-love.SAKURA.ne.jp/tmp/serial-20161017-shrink-loop.txt.xz ----------
[  853.591933] oom_reaper: reaped process 7091 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[  888.994101] a.out: shrink_inactive_list() stalls for 10032ms, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  888.996601] CPU: 2 PID: 7107 Comm: a.out Tainted: G        W       4.9.0-rc1+ #80
[  888.998543] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  889.001075]  ffffc90007ecf788 ffffffff812e9777 ffffffff8197ce18 0000000000000000
[  889.003140]  ffffc90007ecf810 ffffffff8112a114 024201ca00000064 ffffffff8197ce18
[  889.005216]  ffffc90007ecf7b0 ffffc90000000010 ffffc90007ecf820 ffffc90007ecf7d0
[  889.007289] Call Trace:
[  889.008295]  [<ffffffff812e9777>] dump_stack+0x4f/0x68
[  889.009842]  [<ffffffff8112a114>] warn_alloc+0x144/0x160
[  889.011389]  [<ffffffff810a4b40>] ? wake_up_bit+0x30/0x30
[  889.012956]  [<ffffffff81137af3>] shrink_inactive_list+0x593/0x5a0
[  889.014659]  [<ffffffff81138389>] shrink_node_memcg+0x509/0x7b0
[  889.016330]  [<ffffffff811ab200>] ? super_cache_count+0x30/0xd0
[  889.018008]  [<ffffffff8113870c>] shrink_node+0xdc/0x320
[  889.019564]  [<ffffffff81138c56>] do_try_to_free_pages+0xd6/0x330
[  889.021276]  [<ffffffff81138f6b>] try_to_free_pages+0xbb/0xf0
[  889.022937]  [<ffffffff8112a8b6>] __alloc_pages_nodemask+0x716/0xe80
[  889.024684]  [<ffffffff812c2197>] ? blk_finish_plug+0x27/0x40
[  889.026322]  [<ffffffff812efa04>] ? __radix_tree_lookup+0x84/0xf0
[  889.028019]  [<ffffffff81177f07>] alloc_pages_current+0x87/0x110
[  889.029706]  [<ffffffff8111f33c>] __page_cache_alloc+0xdc/0x120
[  889.031392]  [<ffffffff81123233>] filemap_fault+0x333/0x570
[  889.033026]  [<ffffffff8126b519>] xfs_filemap_fault+0x39/0x60
[  889.034668]  [<ffffffff8114f774>] __do_fault+0x74/0x180
[  889.036218]  [<ffffffff811559f2>] handle_mm_fault+0xe82/0x1660
[  889.037878]  [<ffffffff8104da40>] __do_page_fault+0x180/0x550
[  889.039493]  [<ffffffff8104de31>] do_page_fault+0x21/0x70
[  889.040963]  [<ffffffff81002525>] ? do_syscall_64+0x165/0x170
[  889.042526]  [<ffffffff81616db2>] page_fault+0x22/0x30
[  889.044118] a.out: shrink_inactive_list() stalls for 10082ms[  889.044789] Mem-Info:
[  889.044793] active_anon:390112 inactive_anon:3030 isolated_anon:0
[  889.044793]  active_file:63 inactive_file:66 isolated_file:32
[  889.044793]  unevictable:0 dirty:5 writeback:3 unstable:0
[  889.044793]  slab_reclaimable:3306 slab_unreclaimable:17523
[  889.044793]  mapped:1012 shmem:4210 pagetables:2823 bounce:0
[  889.044793]  free:13235 free_pcp:31 free_cma:0
[  889.044796] Node 0 active_anon:1560448kB inactive_anon:12120kB active_file:252kB inactive_file:264kB unevictable:0kB isolated(anon):0kB isolated(file):128kB mapped:4048kB dirty:20kB writeback:12kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 1095680kB anon_thp: 16840kB writeback_tmp:0kB unstable:0kB pages_scanned:995 all_unreclaimable? yes
[  889.044796] Node 0 
[  889.044799] DMA free:7208kB min:404kB low:504kB high:604kB active_anon:8456kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:224kB kernel_stack:16kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]:
[  889.044799]  0 1707 1707 1707
Node 0 
[  889.044803] DMA32 free:45732kB min:44648kB low:55808kB high:66968kB active_anon:1551992kB inactive_anon:12120kB active_file:252kB inactive_file:264kB unevictable:0kB writepending:32kB present:2080640kB managed:1748672kB mlocked:0kB slab_reclaimable:13224kB slab_unreclaimable:69868kB kernel_stack:5584kB pagetables:11292kB bounce:0kB free_pcp:124kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]:
[  889.044803]  0 0 0 0
Node 0 
[  889.044805] DMA: 0*4kB 1*8kB (M) 4*16kB (UM) 5*32kB (UM) 9*64kB (UM) 4*128kB (UM) 3*256kB (U) 4*512kB (UM) 1*1024kB (M) 1*2048kB (E) 0*4096kB = 7208kB
Node 0 
[  889.044811] DMA32: 873*4kB (UME) 1010*8kB (UMEH) 717*16kB (UMEH) 445*32kB (UMEH) 100*64kB (UMH) 8*128kB (UMH) 0*256kB 0*512kB 1*1024kB (H) 0*2048kB 0*4096kB = 45732kB
[  889.044817] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  889.044818] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  889.044818] 4379 total pagecache pages
[  889.044820] 0 pages in swap cache
[  889.044820] Swap cache stats: add 0, delete 0, find 0/0
[  889.044821] Free swap  = 0kB
[  889.044821] Total swap = 0kB
[  889.044821] 524157 pages RAM
[  889.044821] 0 pages HighMem/MovableOnly
[  889.044822] 83013 pages reserved
[  889.044822] 0 pages hwpoisoned
(...snipped...)
[  939.150914] INFO: task kswapd0:60 blocked for more than 60 seconds.
[  939.152922]       Tainted: G        W       4.9.0-rc1+ #80
[  939.154891] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  939.157296] kswapd0         D ffffffff816111f7     0    60      2 0x00000000
[  939.159659]  ffff88007a8c9438 ffff880077ff34c0 ffff88007ac93c40 ffff88007a8c8f40
[  939.162131]  ffff88007f816d80 ffffc9000053b780 ffffffff816111f7 000000009b1d7cf9
[  939.164582]  ffff88007a8c8f40 ffff8800776fda18 ffffc9000053b7b0 ffff8800776fda30
[  939.167053] Call Trace:
[  939.168450]  [<ffffffff816111f7>] ? __schedule+0x177/0x550
[  939.170417]  [<ffffffff8161160b>] schedule+0x3b/0x90
[  939.172285]  [<ffffffff81614064>] rwsem_down_read_failed+0xf4/0x160
[  939.174411]  [<ffffffff812bf7ec>] ? get_request+0x43c/0x770
[  939.176429]  [<ffffffff812f6818>] call_rwsem_down_read_failed+0x18/0x30
[  939.178615]  [<ffffffff816133c2>] down_read+0x12/0x30
[  939.180544]  [<ffffffff81277dae>] xfs_ilock+0x3e/0xa0
[  939.182427]  [<ffffffff81261a70>] xfs_map_blocks+0x80/0x180
[  939.184415]  [<ffffffff81262bd8>] xfs_do_writepage+0x1c8/0x710
[  939.186458]  [<ffffffff81261ec9>] ? xfs_setfilesize_trans_alloc.isra.31+0x39/0x90
[  939.189711]  [<ffffffff81263156>] xfs_vm_writepage+0x36/0x70
[  939.192094]  [<ffffffff81134a47>] pageout.isra.42+0x1a7/0x2b0
[  939.194191]  [<ffffffff81136b47>] shrink_page_list+0x7c7/0xb70
[  939.196254]  [<ffffffff81137798>] shrink_inactive_list+0x238/0x5a0
[  939.198541]  [<ffffffff81138389>] shrink_node_memcg+0x509/0x7b0
[  939.200611]  [<ffffffff8113870c>] shrink_node+0xdc/0x320
[  939.202522]  [<ffffffff8113949a>] kswapd+0x2ca/0x620
[  939.204271]  [<ffffffff811391d0>] ? mem_cgroup_shrink_node+0xb0/0xb0
[  939.206243]  [<ffffffff81081234>] kthread+0xd4/0xf0
[  939.207904]  [<ffffffff81081160>] ? kthread_park+0x60/0x60
[  939.209848]  [<ffffffff81615922>] ret_from_fork+0x22/0x30
---------- From http://I-love.SAKURA.ne.jp/tmp/serial-20161017-shrink-loop.txt.xz ----------

This means that, unless we scatter around warn_alloc() to all locations
which might depend on somebody else to make forward progress, we may
fail to get a clue.

The code will look messy if we scatter around warn_alloc() calls.
Also, it is more likely that multiple concurrent warn_alloc() calls race.
Even if we guard warn_alloc() with mutex_lock(&oom_lock)/mutex_unlock(&oom_lock),
messages from hung task watchdog and messages from warn_alloc() calls will race.

There is an alternative approach I proposed at
http://lkml.kernel.org/r/1462630604-23410-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
which serializes both hung task watchdog and warn_alloc().

So, how can we make warn_alloc() reliable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
