Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1786B0253
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 18:21:59 -0400 (EDT)
Received: by labgo9 with SMTP id go9so37745217lab.3
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 15:21:58 -0700 (PDT)
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTP id qg4si3220231lbb.25.2015.08.05.15.21.55
        for <linux-mm@kvack.org>;
        Wed, 05 Aug 2015 15:21:56 -0700 (PDT)
Date: Thu, 6 Aug 2015 00:21:52 +0200
From: Rabin Vincent <rabin.vincent@axis.com>
Subject: [PATCH?] Non-throttling of mkfs leads to OOM
Message-ID: <20150805222151.GA24795@axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fengguang.wu@intel.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

I received some reports of mkfs.ext4 on an SD card triggering the OOM
killer on a swapless system with a low amount of free memory.  I have
made a reproducible setup of this by using null_blk with a large
completion delay.  The problem appears to be that we do not throttle to
the level of vm_dirty_ratio in throttle_vm_writeout().

I configure null_blk like this: null_blk.irqmode=2
null_blk.completion_nsec=30000000 null_blk.queue_mode=1 and run the test under
a qemu-kvm instance.

The kernel is 4.2-rc5 along with the patch I posted earlier today which fixes
the initial dirty limit after the cgroups changes
(https://lkml.org/lkml/2015/8/5/650).  The problem is not related to the
recent writeback cgroups changes though; earlier kernels show the same
behaviour.

/proc/meminfo looks like this just before run of mkfs.ext4

  MemTotal:         197032 kB
  MemFree:            4184 kB
  MemAvailable:      14376 kB
  Buffers:             332 kB
  Cached:            64528 kB
  SwapCached:            0 kB
  Active:             2840 kB
  Inactive:          62612 kB
  Active(anon):        640 kB
  Inactive(anon):    61448 kB
  Active(file):       2200 kB
  Inactive(file):     1164 kB
  Unevictable:           0 kB
  Mlocked:               0 kB
  SwapTotal:             0 kB
  SwapFree:              0 kB
  Dirty:                28 kB
  Writeback:             0 kB
  AnonPages:           660 kB
  Mapped:             2776 kB
  Shmem:             61456 kB
  Slab:              26580 kB
  SReclaimable:      12884 kB
  SUnreclaim:        13696 kB
  KernelStack:         576 kB
  PageTables:          220 kB
  NFS_Unstable:          0 kB
  Bounce:                0 kB
  WritebackTmp:          0 kB
  CommitLimit:       98516 kB
  Committed_AS:      63424 kB
  VmallocTotal:   34359738367 kB
  VmallocUsed:       68532 kB
  VmallocChunk:   34359667708 kB
  DirectMap4k:       16256 kB
  DirectMap2M:      208896 kB
  DirectMap1G:           0 kB

And mkfs.ext4 runs like this:

# mkfs.ext4 -F -O ^extent -E lazy_itable_init=0,lazy_journal_init=0 /dev/nullb0:
 mke2fs 1.42.13 (17-May-2015)
 Creating filesystem with 65536000 4k blocks and 16384000 inodes
 Filesystem UUID: 970d9572-67d4-4a1f-a4d0-8376c6235c6a
 Superblock backups stored on blocks: 
 	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
 	4096000, 7962624, 11239424, 20480000, 23887872
 
 Allocating group tables: done                            
 Writing inode tables: [    4.557641] mkfs.ext4 invoked oom-killer: gfp_mask=0x10200d0, order=0, oom_score_adj=0
 [    4.558395] mkfs.ext4 cpuset=/ mems_allowed=0
 [    4.558814] CPU: 0 PID: 667 Comm: mkfs.ext4 Not tainted 4.2.0-rc5+ #292
 [    4.559391] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
 [    4.562285] Call Trace:
 [    4.562509]  [<ffffffff81515c64>] dump_stack+0x4f/0x7b
 [    4.562957]  [<ffffffff81513eb8>] dump_header.isra.9+0x76/0x38f
 [    4.563474]  [<ffffffff8109d95d>] ? trace_hardirqs_on+0xd/0x10
 [    4.564023]  [<ffffffff8151ca2a>] ? _raw_spin_unlock_irqrestore+0x4a/0x80
 [    4.564614]  [<ffffffff81123cac>] oom_kill_process+0x38c/0x470
 [    4.565190]  [<ffffffff81057cb5>] ? has_ns_capability_noaudit+0x5/0x160
 [    4.573104]  [<ffffffff8107bc51>] ? get_parent_ip+0x11/0x50
 [    4.573608]  [<ffffffff81124145>] ? out_of_memory+0x355/0x420
 [    4.574143]  [<ffffffff811241a7>] out_of_memory+0x3b7/0x420
 [    4.574634]  [<ffffffff81128dc0>] ? __alloc_pages_nodemask+0x810/0xb10
 [    4.575203]  [<ffffffff81128fc6>] __alloc_pages_nodemask+0xa16/0xb10
 [    4.575755]  [<ffffffff8111fd91>] pagecache_get_page+0x101/0x1c0
 [    4.576287]  [<ffffffff811a2cf0>] ? I_BDEV+0x20/0x20
 [    4.576722]  [<ffffffff8112092d>] grab_cache_page_write_begin+0x2d/0x50
 [    4.577298]  [<ffffffff811a114d>] block_write_begin+0x2d/0x80
 [    4.577809]  [<ffffffff811a34f5>] ? blkdev_write_begin+0x5/0x30
 [    4.578325]  [<ffffffff811a3513>] blkdev_write_begin+0x23/0x30
 [    4.578830]  [<ffffffff81120abf>] generic_perform_write+0xaf/0x1b0
 [    4.579368]  [<ffffffff81121c60>] __generic_file_write_iter+0x190/0x1f0
 [    4.579975]  [<ffffffff811a3b28>] blkdev_write_iter+0x78/0x100
 [    4.580497]  [<ffffffff81167daa>] __vfs_write+0xaa/0xe0
 [    4.580984]  [<ffffffff811681a7>] vfs_write+0x97/0x100
 [    4.581434]  [<ffffffff811689a7>] SyS_pwrite64+0x77/0x90
 [    4.581923]  [<ffffffff8151d3ae>] entry_SYSCALL_64_fastpath+0x12/0x76
 [    4.585984] Mem-Info:
 [    4.586558] active_anon:207 inactive_anon:15363 isolated_anon:0
 [    4.586558]  active_file:295 inactive_file:347 isolated_file:0
 [    4.586558]  unevictable:0 dirty:0 writeback:0 unstable:0
 [    4.586558]  slab_reclaimable:3260 slab_unreclaimable:3452
 [    4.586558]  mapped:288 shmem:15363 pagetables:56 bounce:0
 [    4.586558]  free:1112 free_pcp:32 free_cma:0
 [    4.589928] DMA free:1032kB min:144kB low:180kB high:216kB active_anon:52kB inactive_anon:5920kB active_file:48kB inactive_file:128kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:4kB writeback:0kB mapped:88kB shmem:5920kB slab_reclaimable:164kB slab_unreclaimable:648kB kernel_stack:16kB pagetables:28kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
 [    4.594056] lowmem_reserve[]: 0 173 173 173
 [    4.596036] DMA32 free:3136kB min:1608kB low:2008kB high:2412kB active_anon:776kB inactive_anon:55532kB active_file:1132kB inactive_file:1380kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:208768kB managed:181124kB mlocked:0kB dirty:0kB writeback:0kB mapped:1176kB shmem:55532kB slab_reclaimable:12876kB slab_unreclaimable:13160kB kernel_stack:592kB pagetables:196kB unstable:0kB bounce:0kB free_pcp:140kB local_pcp:140kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
 [    4.600369] lowmem_reserve[]: 0 0 0 0
 [    4.601393] DMA: 14*4kB (UM) 20*8kB (UM) 20*16kB (UM) 13*32kB (UM) 1*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1016kB
 [    4.602710] DMA32: 44*4kB (UEM) 128*8kB (UEM) 44*16kB (UEM) 24*32kB (UEM) 3*64kB (M) 2*128kB (M) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3120kB
 [    4.604158] 16088 total pagecache pages
 [    4.604509] 56190 pages RAM
 [    4.604768] 0 pages HighMem/MovableOnly
 [    4.605148] 6932 pages reserved
 [    4.605437] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
 [    4.606238] [   75]     0    75     1134       16       8       3        0             0 klogd
 [    4.607012] [  140]     0   140     2667      140      10       3        0             0 dropbear
 [    4.607809] [  141]     0   141     1660      176       8       3        0             0 sh
 [    4.608737] [  661]     0   661     1134      167       8       3        0             0 exe
 [    4.611211] [  667]     0   667     4271      321      14       3        0             0 mkfs.ext4
 [    4.612198] Out of memory: Kill process 667 (mkfs.ext4) score 6 or sacrifice child
 [    4.614630] Killed process 667 (mkfs.ext4) total-vm:17084kB, anon-rss:184kB, file-rss:1100kB
 Killed

The last balance_dirty_pages shows that the task is within its ratelimit and so
is not paused there:

       mkfs.ext4-664   [000]     4.773565: balance_dirty_pages:  bdi 253:0: limit=9233 setpoint=4685 dirty=576 bdi_setpoint=4532 bdi_dirty=576 dirty_ratelimit=102400 task_ratelimit=181400 dirtied=58 dirtied_pause=512 paused=0 pause=-32 period=0 think=32

Then the page allocator gets called and starts direct reclaim:

       mkfs.ext4-664   [000]     4.773565: function:             blkdev_write_begin <-- generic_perform_write
       mkfs.ext4-664   [000]     4.773566: function:             __alloc_pages_nodemask <-- pagecache_get_page
       mkfs.ext4-664   [000]     4.773566: function:                __alloc_pages_direct_compact <-- __alloc_pages_nodemask
       mkfs.ext4-664   [000]     4.773566: function:                try_to_free_pages <-- __alloc_pages_nodemask
       mkfs.ext4-664   [000]     4.773567: mm_vmscan_direct_reclaim_begin: order=0 may_writepage=1 gfp_flags=GFP_USER

However, even though NR_WRITEBACK is much larger than thresh,
confgestion_wait() is not called because throttle_vm_writeout() uses the much
higher domain->dirty_limit (limit) rather that vm_dirty_ratio (thresh):

       mkfs.ext4-664   [000]     4.773567: function:             throttle_vm_writeout <-- shrink_lruvec.isra.59
       mkfs.ext4-664   [000]     4.773567: global_dirty_state:   dirty=3 writeback=573 unstable=0 bg_thresh=91 thresh=183 limit=9233 dirtied=3465 written=2889

None of the wait_iff_congested() calls have any effect since the bdi is not
detected as being congested (queue/nr_request is the default of 128 and
fewer than 30 requests are currently on it):

       mkfs.ext4-664   [000]     4.773583: function:             wait_iff_congested <-- shrink_inactive_list
       mkfs.ext4-664   [000]     4.773583: writeback_wait_iff_congested: usec_timeout=100000 usec_delayed=0

try_to_free_pages() also keeps on waking up the flusher threads:

       mkfs.ext4-664   [000]     4.776026: kmalloc:              (wb_start_writeback+0x42) call_site=ffffffff811970d2 ptr=0xffff88000d748498 bytes_req=64 bytes_alloc=392 gfp_flags=GFP_ATOMIC|GFP_ZERO
       mkfs.ext4-664   [000]     4.776026: writeback_queue:      bdi 254:0: sb_dev 0:0 nr_pages=1105 sync_mode=0 kupdate=0 range_cyclic=0 background=0 reason=try_to_free_pages
       mkfs.ext4-664   [000]     4.776032: kmalloc:              (wb_start_writeback+0x42) call_site=ffffffff811970d2 ptr=0xffff88000d749188 bytes_req=64 bytes_alloc=392 gfp_flags=GFP_ATOMIC|GFP_ZERO
       mkfs.ext4-664   [000]     4.776033: writeback_queue:      bdi 253:0: sb_dev 0:0 nr_pages=1105 sync_mode=0 kupdate=0 range_cyclic=0 background=0 reason=try_to_free_pages
       mkfs.ext4-664   [000]     4.776040: kmalloc:              (wb_start_writeback+0x42) call_site=ffffffff811970d2 ptr=0xffff88000d749620 bytes_req=64 bytes_alloc=392 gfp_flags=GFP_ATOMIC|GFP_ZERO
       mkfs.ext4-664   [000]     4.776040: writeback_queue:      bdi 254:0: sb_dev 0:0 nr_pages=1105 sync_mode=0 kupdate=0 range_cyclic=0 background=0 reason=try_to_free_pages
       mkfs.ext4-664   [000]     4.776047: kmalloc:              (wb_start_writeback+0x42) call_site=ffffffff811970d2 ptr=0xffff88000d74a498 bytes_req=64 bytes_alloc=392 gfp_flags=GFP_ATOMIC|GFP_ZERO
       mkfs.ext4-664   [000]     4.776047: writeback_queue:      bdi 253:0: sb_dev 0:0 nr_pages=1105 sync_mode=0 kupdate=0 range_cyclic=0 background=0 reason=try_to_free_pages
       mkfs.ext4-664   [000]     4.776054: kmalloc:              (wb_start_writeback+0x42) call_site=ffffffff811970d2 ptr=0xffff88000d74a620 bytes_req=64 bytes_alloc=392 gfp_flags=GFP_ATOMIC|GFP_ZERO
       mkfs.ext4-664   [000]     4.776054: writeback_queue:      bdi 254:0: sb_dev 0:0 nr_pages=1105 sync_mode=0 kupdate=0 range_cyclic=0 background=0 reason=try_to_free_pages
       mkfs.ext4-664   [000]     4.776061: kmalloc:              (wb_start_writeback+0x42) call_site=ffffffff811970d2 ptr=0xffff88000d74b310 bytes_req=64 bytes_alloc=392 gfp_flags=GFP_ATOMIC|GFP_ZERO
       mkfs.ext4-664   [000]     4.776061: writeback_queue:      bdi 253:0: sb_dev 0:0 nr_pages=1105 sync_mode=0 kupdate=0 range_cyclic=0 background=0 reason=try_to_free_pages
       mkfs.ext4-664   [000]     4.776068: kmalloc:              (wb_start_writeback+0x42) call_site=ffffffff811970d2 ptr=0xffff88000d74b620 bytes_req=64 bytes_alloc=392 gfp_flags=GFP_ATOMIC|GFP_ZERO

All to no avail since we never wait for any writes and end up OOMing
after some rounds of direct reclaim:

       mkfs.ext4-664   [000]     4.776174: mm_vmscan_direct_reclaim_end: nr_reclaimed=0
       mkfs.ext4-664   [000]     4.776192: function:             out_of_memory <-- __alloc_pages_nodemask

(A full ftrace is available at https://drive.google.com/file/d/0B4tMLbMvJ-l6MndXbG5wQmZrTm8/view)

The problem seems to be that throttle_vm_writeout() does not respect the set
vm_dirty_ratio values.  With the following change, mkfs.ext4 is able to
complete successfully every time in this scenario without triggering OOM:

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 5cccc12..47f1d09 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1916,7 +1920,6 @@ void throttle_vm_writeout(gfp_t gfp_mask)
 
         for ( ; ; ) {
 		global_dirty_limits(&background_thresh, &dirty_thresh);
-		dirty_thresh = hard_dirty_limit(&global_wb_domain, dirty_thresh);
 
                 /*
                  * Boost the allowable dirty threshold a bit for page

But this is a revert of the following commit and presumably reintroduces the
problem for the use case described there:

  commit 47a133339c332f9f8e155c70f5da401aded69948
  Author: Fengguang Wu <fengguang.wu@intel.com>
  Date:   Wed Mar 21 16:34:09 2012 -0700
  
      mm: use global_dirty_limit in throttle_vm_writeout()
  
      When starting a memory hog task, a desktop box w/o swap is found to go
      unresponsive for a long time.  It's solely caused by lots of congestion
      waits in throttle_vm_writeout():
      
      ...
      
      The root cause is, the dirty threshold is knocked down a lot by the memory
      hog task.  Fixed by using global_dirty_limit which decreases gradually on
      such events and can guarantee we stay above (the also decreasing) nr_dirty
      in the progress of following down to the new dirty threshold.

Comments?

Thanks,
/Rabin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
