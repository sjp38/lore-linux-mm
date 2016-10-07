Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5F3846B0264
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 01:45:40 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fn2so18903919pad.7
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 22:45:40 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z1si320926pay.275.2016.10.06.22.45.38
        for <linux-mm@kvack.org>;
        Thu, 06 Oct 2016 22:45:39 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 0/4] use up highorder free pages before OOM
Date: Fri,  7 Oct 2016 14:45:32 +0900
Message-Id: <1475819136-24358-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Minchan Kim <minchan@kernel.org>

I got OOM report from production team with v4.4 kernel.
It has enough free memory but failed to allocate order-0 page and
finally encounter OOM kill.
I could reproduce it with my test easily. Look at below.
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

During the investigation, I found some problems with highatomic so
this patch aims to solve the problems and the final goal is to
unreserve every highatomic free pages before the OOM kill.

Patch 1 fixes accounting bug in several places of page allocators
Patch 2 fixes accounting bug caused by subtle race between freeing
function and unreserve_highatomic_pageblock.
Patch 3 changes unreseve scheme to use up every reserved pages
Patch 4 fixes accounting bug caused by mem_section shared by two zones.

Minchan Kim (4):
  mm: adjust reserved highatomic count
  mm: prevent double decrease of nr_reserved_highatomic
  mm: unreserve highatomic free pages fully before OOM
  mm: skip to reserve pageblock crossed zone boundary for HIGHATOMIC

 mm/page_alloc.c | 143 ++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 118 insertions(+), 25 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
