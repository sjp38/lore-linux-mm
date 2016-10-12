Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7DCF66B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:33:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e6so32915786pfk.2
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 22:33:41 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w190si7423660pfd.17.2016.10.11.22.33.39
        for <linux-mm@kvack.org>;
        Tue, 11 Oct 2016 22:33:40 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 0/4] use up highorder free pages before OOM
Date: Wed, 12 Oct 2016 14:33:32 +0900
Message-Id: <1476250416-22733-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

I got OOM report from production team with v4.4 kernel.
It had enough free memory but failed to allocate GFP_KERNEL order-0
page and finally encountered OOM kill. It occured during QA process
which launches several apps, switching and so on. It happned rarely.
IOW, In normal situation, it was not a problem but if we are unluck
so that several apps uses peak memory at the same time, it can happen.
If we manage to pass the phase, the system can go working well.

I could reproduce it with my test(memory spike easily. Look at below.

The reason is free pages(19M) of DMA32 zone are reserved for
HIGHORDERATOMIC and doesn't unreserved before the OOM.

balloon invoked oom-killer: gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), order=0, oom_score_adj=0
balloon cpuset=/ mems_allowed=0
CPU: 1 PID: 8473 Comm: balloon Tainted: G        W  OE   4.8.0-rc7-00219-g3f74c9559583-dirty #3161
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
 0000000000000000 ffff88007f15bbc8 ffffffff8138eb13 ffff88007f15bd88
 ffff88005a72a4c0 ffff88007f15bc28 ffffffff811d2d13 ffff88007f15bc08
 ffffffff8146a5ca ffffffff81c8df60 0000000000000015 0000000000000206
Call Trace:
 [<ffffffff8138eb13>] dump_stack+0x63/0x90
 [<ffffffff811d2d13>] dump_header+0x5c/0x1ce
 [<ffffffff8146a5ca>] ? virtballoon_oom_notify+0x2a/0x80
 [<ffffffff81171e5e>] oom_kill_process+0x22e/0x400
 [<ffffffff8117222c>] out_of_memory+0x1ac/0x210
 [<ffffffff811775ce>] __alloc_pages_nodemask+0x101e/0x1040
 [<ffffffff811a245a>] handle_mm_fault+0xa0a/0xbf0
 [<ffffffff8106029d>] __do_page_fault+0x1dd/0x4d0
 [<ffffffff81060653>] trace_do_page_fault+0x43/0x130
 [<ffffffff81059bda>] do_async_page_fault+0x1a/0xa0
 [<ffffffff817a3f38>] async_page_fault+0x28/0x30
Mem-Info:
active_anon:383949 inactive_anon:106724 isolated_anon:0
 active_file:15 inactive_file:44 isolated_file:0
 unevictable:0 dirty:0 writeback:24 unstable:0
 slab_reclaimable:2483 slab_unreclaimable:3326
 mapped:0 shmem:0 pagetables:1906 bounce:0
 free:6898 free_pcp:291 free_cma:0
Node 0 active_anon:1535796kB inactive_anon:426896kB active_file:60kB inactive_file:176kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:0kB dirty:0kB writeback:96kB shmem:0kB writeback_tmp:0kB unstable:0kB pages_scanned:1418 all_unreclaimable? no
DMA free:8188kB min:44kB low:56kB high:68kB active_anon:7648kB inactive_anon:0kB active_file:0kB inactive_file:4kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:20kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]: 0 1952 1952 1952
DMA32 free:19404kB min:5628kB low:7624kB high:9620kB active_anon:1528148kB inactive_anon:426896kB active_file:60kB inactive_file:420kB unevictable:0kB writepending:96kB present:2080640kB managed:2030092kB mlocked:0kB slab_reclaimable:9932kB slab_unreclaimable:13284kB kernel_stack:2496kB pagetables:7624kB bounce:0kB free_pcp:900kB local_pcp:112kB free_cma:0kB
lowmem_reserve[]: 0 0 0 0
DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 2*4096kB (H) = 8192kB
DMA32: 7*4kB (H) 8*8kB (H) 30*16kB (H) 31*32kB (H) 14*64kB (H) 9*128kB (H) 2*256kB (H) 2*512kB (H) 4*1024kB (H) 5*2048kB (H) 0*4096kB = 19484kB
51131 total pagecache pages
50795 pages in swap cache
Swap cache stats: add 3532405601, delete 3532354806, find 124289150/1822712228
Free swap  = 8kB
Total swap = 255996kB
524158 pages RAM
0 pages HighMem/MovableOnly
12658 pages reserved
0 pages cma reserved
0 pages hwpoisoned

Another example exceeded the limit by the race is

in:imklog: page allocation failure: order:0, mode:0x2280020(GFP_ATOMIC|__GFP_NOTRACK)
CPU: 0 PID: 476 Comm: in:imklog Tainted: G            E   4.8.0-rc7-00217-g266ef83c51e5-dirty #3135
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
 0000000000000000 ffff880077c37590 ffffffff81389033 0000000000000000
 0000000000000000 ffff880077c37618 ffffffff8117519b 0228002000000000
 ffffffffffffffff ffffffff81cedb40 0000000000000000 0000000000000040
Call Trace:
 [<ffffffff81389033>] dump_stack+0x63/0x90
 [<ffffffff8117519b>] warn_alloc_failed+0xdb/0x130
 [<ffffffff81175746>] __alloc_pages_nodemask+0x4d6/0xdb0
 [<ffffffff8120c149>] ? bdev_write_page+0xa9/0xd0
 [<ffffffff811a97b3>] ? __page_check_address+0xd3/0x130
 [<ffffffff811ba4ea>] ? deactivate_slab+0x12a/0x3e0
 [<ffffffff811b9549>] new_slab+0x339/0x490
 [<ffffffff811bad37>] ___slab_alloc.constprop.74+0x367/0x480
 [<ffffffff814601ad>] ? alloc_indirect.isra.14+0x1d/0x50
 [<ffffffff8109d0c2>] ? default_wake_function+0x12/0x20
 [<ffffffff811bae70>] __slab_alloc.constprop.73+0x20/0x40
 [<ffffffff811bb034>] __kmalloc+0x1a4/0x1e0
 [<ffffffff814601ad>] alloc_indirect.isra.14+0x1d/0x50
 [<ffffffff81460434>] virtqueue_add_sgs+0x1c4/0x470
 [<ffffffff81365075>] ? __bt_get.isra.8+0xe5/0x1c0
 [<ffffffff8150973e>] __virtblk_add_req+0xae/0x1f0
 [<ffffffff810b37d0>] ? wake_atomic_t_function+0x60/0x60
 [<ffffffff810337b9>] ? sched_clock+0x9/0x10
 [<ffffffff81360afb>] ? __blk_mq_alloc_request+0x10b/0x230
 [<ffffffff8135e293>] ? blk_rq_map_sg+0x213/0x550
 [<ffffffff81509a1d>] virtio_queue_rq+0x12d/0x290
 [<ffffffff813629c9>] __blk_mq_run_hw_queue+0x239/0x370
 [<ffffffff8136276f>] blk_mq_run_hw_queue+0x8f/0xb0
 [<ffffffff8136397c>] blk_mq_insert_requests+0x18c/0x1a0
 [<ffffffff81364865>] blk_mq_flush_plug_list+0x125/0x140
 [<ffffffff813596a7>] blk_flush_plug_list+0xc7/0x220
 [<ffffffff81359bec>] blk_finish_plug+0x2c/0x40
 [<ffffffff8117b836>] __do_page_cache_readahead+0x196/0x230
 [<ffffffffa00006ba>] ? zram_free_page+0x3a/0xb0 [zram]
 [<ffffffff8116f928>] filemap_fault+0x448/0x4f0
 [<ffffffff8119e9e4>] ? alloc_set_pte+0xe4/0x350
 [<ffffffff8125fa16>] ext4_filemap_fault+0x36/0x50
 [<ffffffff8119be35>] __do_fault+0x75/0x140
 [<ffffffff8119f6cd>] handle_mm_fault+0x84d/0xbe0
 [<ffffffff812483e4>] ? kmsg_read+0x44/0x60
 [<ffffffff8106029d>] __do_page_fault+0x1dd/0x4d0
 [<ffffffff81060653>] trace_do_page_fault+0x43/0x130
 [<ffffffff81059bda>] do_async_page_fault+0x1a/0xa0
 [<ffffffff8179dcb8>] async_page_fault+0x28/0x30
Mem-Info:
active_anon:363826 inactive_anon:121283 isolated_anon:32
 active_file:65 inactive_file:152 isolated_file:0
 unevictable:0 dirty:0 writeback:46 unstable:0
 slab_reclaimable:2778 slab_unreclaimable:3070
 mapped:112 shmem:0 pagetables:1822 bounce:0
 free:9469 free_pcp:231 free_cma:0
Node 0 active_anon:1455304kB inactive_anon:485132kB active_file:260kB inactive_file:608kB unevictable:0kB isolated(anon):128kB isolated(file):0kB mapped:448kB dirty:0kB writeback:184kB shmem:0kB writeback_tmp:0kB unstable:0kB pages_scanned:13641 all_unreclaimable? no
DMA free:7748kB min:44kB low:56kB high:68kB active_anon:7944kB inactive_anon:104kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:108kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]: 0 1952 1952 1952
DMA32 free:30128kB min:5628kB low:7624kB high:9620kB active_anon:1447360kB inactive_anon:485028kB active_file:260kB inactive_file:608kB unevictable:0kB writepending:184kB present:2080640kB managed:2030132kB mlocked:0kB slab_reclaimable:11112kB slab_unreclaimable:12172kB kernel_stack:2400kB pagetables:7284kB bounce:0kB free_pcp:924kB local_pcp:72kB free_cma:0kB
lowmem_reserve[]: 0 0 0 0
DMA: 7*4kB (UE) 3*8kB (UH) 1*16kB (M) 0*32kB 2*64kB (U) 1*128kB (M) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (U) 1*4096kB (H) = 7748kB
DMA32: 10*4kB (H) 3*8kB (H) 47*16kB (H) 38*32kB (H) 5*64kB (H) 1*128kB (H) 2*256kB (H) 3*512kB (H) 3*1024kB (H) 3*2048kB (H) 4*4096kB (H) = 30128kB
2775 total pagecache pages
2536 pages in swap cache
Swap cache stats: add 206786828, delete 206784292, find 7323106/106686077
Free swap  = 108744kB
Total swap = 255996kB
524158 pages RAM
0 pages HighMem/MovableOnly
12648 pages reserved
0 pages cma reserved
0 pages hwpoisoned

During the investigation, I found some problems with highatomic so
this patch aims to solve the problems and the final goal is to
unreserve every highatomic free pages before the OOM kill.

Minchan Kim (4):
  mm: don't steal highatomic pageblock
  mm: prevent double decrease of nr_reserved_highatomic
  mm: try to exhaust highatomic reserve before the OOM
  mm: make unreserve highatomic functions reliable

 mm/page_alloc.c | 63 ++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 47 insertions(+), 16 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
