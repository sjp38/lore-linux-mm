Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56CB26B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 04:26:23 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so20242379pab.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 01:26:23 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id o78si2937018pfa.103.2016.07.19.01.26.21
        for <linux-mm@kvack.org>;
        Tue, 19 Jul 2016 01:26:22 -0700 (PDT)
Date: Tue, 19 Jul 2016 17:30:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 04/31] mm, vmscan: begin reclaiming pages on a per-node
 basis
Message-ID: <20160719083031.GD17479@js1304-P5Q-DELUXE>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-5-git-send-email-mgorman@techsingularity.net>
 <20160707011211.GA27987@js1304-P5Q-DELUXE>
 <20160707094808.GP11498@techsingularity.net>
 <20160708022852.GA2370@js1304-P5Q-DELUXE>
 <20160708100532.GC11498@techsingularity.net>
 <20160714062836.GB29676@js1304-P5Q-DELUXE>
 <20160718121122.GQ9806@techsingularity.net>
 <20160718142714.GA10438@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160718142714.GA10438@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 18, 2016 at 03:27:14PM +0100, Mel Gorman wrote:
> On Mon, Jul 18, 2016 at 01:11:22PM +0100, Mel Gorman wrote:
> > The all_unreclaimable logic is related to the number of pages scanned
> > but currently pages skipped contributes to pages scanned. That is one
> > possibility. The other is that if all pages scanned are skipped then the
> > OOM killer can believe there is zero progress.
> > 
> > Try this to start with;
> > 
> 
> And if that fails, try this heavier handed version that will scan the full
> LRU potentially to isolate at least a single page if it's available for
> zone-constrained allocations. It's compile-tested only

I tested both patches but they don't work for me. Notable difference
is that all_unreclaimable is now "no".

Just attach the oops log from heavier version.

Thanks.

fork invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
fork cpuset=/ mems_allowed=0
CPU: 1 PID: 7484 Comm: fork Not tainted 4.7.0-rc7-next-20160713+ #657
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.1-0-gb3ef39f-prebuilt.qemu-project.org 04/01/2014
 0000000000000000 ffff880019f6bb18 ffffffff8142b8d3 ffff880019f6bd20
 ffff88001c2c2500 ffff880019f6bb90 ffffffff81240b7e ffffffff81e6f0e0
 ffff880019f6bb40 ffffffff810de08d ffff880019f6bb60 0000000000000206
Call Trace:
 [<ffffffff8142b8d3>] dump_stack+0x85/0xc2
 [<ffffffff81240b7e>] dump_header+0x5c/0x22e
 [<ffffffff810de08d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff811b3381>] oom_kill_process+0x221/0x3f0
 [<ffffffff810901b7>] ? has_capability_noaudit+0x17/0x20
 [<ffffffff811b3acf>] out_of_memory+0x52f/0x560
 [<ffffffff811b377c>] ? out_of_memory+0x1dc/0x560
 [<ffffffff811ba004>] __alloc_pages_nodemask+0x1154/0x11b0
 [<ffffffff810813a1>] ? copy_process.part.30+0x121/0x1bf0
 [<ffffffff810813a1>] copy_process.part.30+0x121/0x1bf0
 [<ffffffff811ebb16>] ? handle_mm_fault+0xb36/0x13d0
 [<ffffffff810fb60d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
 [<ffffffff81083066>] _do_fork+0xe6/0x6a0
 [<ffffffff810836c9>] SyS_clone+0x19/0x20
 [<ffffffff81003e13>] do_syscall_64+0x73/0x1e0
 [<ffffffff81858ec3>] entry_SYSCALL64_slow_path+0x25/0x25
Mem-Info:
active_anon:23909 inactive_anon:18 isolated_anon:0
 active_file:289985 inactive_file:101445 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:6696 slab_unreclaimable:22083
 mapped:381662 shmem:95 pagetables:21600 bounce:0
 free:8378 free_pcp:227 free_cma:0
Node 0 active_anon:95676kB inactive_anon:72kB active_file:1160056kB inactive_file:405792kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1526812kB dirty:4kB writeback:0kB shmem:0kB shmem_thp
: 0kB shmem_pmdmapped: 0kB anon_thp: 380kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
Node 0 DMA free:2176kB min:204kB low:252kB high:300kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:2328kB kernel_stack:1472kB pagetables:2940kB bounce:0kB free_pcp:0k
B local_pcp:0kB free_cma:0kB node_pages_scanned:1668
lowmem_reserve[]: 0 493 493 1955
Node 0 DMA32 free:8188kB min:6492kB low:8112kB high:9732kB present:2080632kB managed:508600kB mlocked:0kB slab_reclaimable:26784kB slab_unreclaimable:86004kB kernel_stack:40704kB pagetables:83460kB bounce:
0kB free_pcp:208kB local_pcp:0kB free_cma:0kB node_pages_scanned:12000
lowmem_reserve[]: 0 0 0 1462
Node 0 Movable free:23648kB min:19256kB low:24068kB high:28880kB present:1535864kB managed:1500964kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_
pcp:748kB local_pcp:0kB free_cma:0kB node_pages_scanned:12000
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 2*4kB (M) 0*8kB 2*16kB (UM) 2*32kB (UM) 0*64kB 2*128kB (UM) 1*256kB (U) 1*512kB (M) 1*1024kB (M) 0*2048kB 0*4096kB = 2152kB
Node 0 DMA32: 21*4kB (EH) 14*8kB (UMEH) 14*16kB (UMEH) 17*32kB (UM) 11*64kB (ME) 13*128kB (UME) 14*256kB (UME) 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 8452kB
Node 0 Movable: 87*4kB (M) 106*8kB (M) 82*16kB (M) 39*32kB (M) 11*64kB (M) 4*128kB (M) 0*256kB 1*512kB (M) 0*1024kB 1*2048kB (M) 4*4096kB (M) = 23916kB
Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
391491 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
908122 pages RAM
0 pages HighMem/MovableOnly
401754 pages reserved
0 pages cma reserved
0 pages hwpoisoned

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
