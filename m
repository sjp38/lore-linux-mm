Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 237D66B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 04:06:57 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id r71so6444076ioi.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 01:06:57 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id e191si20271495ite.66.2016.07.26.01.06.55
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 01:06:56 -0700 (PDT)
Date: Tue, 26 Jul 2016 17:11:30 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/5] Candidate fixes for premature OOM kills with
 node-lru v2
Message-ID: <20160726081129.GB15721@js1304-P5Q-DELUXE>
References: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 21, 2016 at 03:10:56PM +0100, Mel Gorman wrote:
> Both Joonsoo Kim and Minchan Kim have reported premature OOM kills.
> The common element is a zone-constrained allocation failings. Two factors
> appear to be at fault -- pgdat being considered unreclaimable prematurely
> and insufficient rotation of the active list.
> 
> The series is in three basic parts;
> 
> Patches 1-3 add per-zone stats back in. The actual stats patch is different
> 	to Minchan's as the original patch did not account for unevictable
> 	LRU which would corrupt counters. The second two patches remove
> 	approximations based on pgdat statistics. It's effectively a
> 	revert of "mm, vmstat: remove zone and node double accounting
> 	by approximating retries" but different LRU stats are used. This
> 	is better than a full revert or a reworking of the series as it
> 	preserves history of why the zone stats are necessary.
> 
> 	If this work out, we may have to leave the double accounting in
> 	place for now until an alternative cheap solution presents itself.
> 
> Patch 4 rotates inactive/active lists for lowmem allocations. This is also
> 	quite different to Minchan's patch as the original patch did not
> 	account for memcg and would rotate if *any* eligible zone needed
> 	rotation which may rotate excessively. The new patch considers the
> 	ratio for all eligible zones which is more in line with node-lru
> 	in general.
> 
> Patch 5 accounts for skipped pages as partial scanned. This avoids the pgdat
> 	being prematurely marked unreclaimable while still allowing it to
> 	be marked unreclaimable if there are no reclaimable pages.
> 
> These patches did not OOM for me on a 2G 32-bit KVM instance while running
> a stress test for an hour. Preliminary tests on a 64-bit system using a
> parallel dd workload did not show anything alarming.
> 
> If an OOM is detected then please post the full OOM message.

Before attaching OOM message, I should note that my test case also triggers
OOM in old kernel if there are four parallel file-readers. With node-lru and
patch 1~5, OOM is triggered even if there are one or more parallel file-readers.
With node-lru and patch 1~4, OOM is triggered if there are two or more
parallel file-readers.

Here goes OOM message.

fork invoked oom-killer: gfp_mask=0x24200ca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=0                                                                                                        [108/9620]
fork cpuset=/ mems_allowed=0
CPU: 0 PID: 4304 Comm: fork Not tainted 4.7.0-rc7-next-20160720+ #713
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.1-0-gb3ef39f-prebuilt.qemu-project.org 04/01/2014
 0000000000000000 ffff8800209ab960 ffffffff8142bd03 ffff8800209abb58
 ffff8800209a0000 ffff8800209ab9d8 ffffffff81241a59 ffffffff81e70020
 ffff8800209ab988 ffffffff810dddcd ffff8800209ab9a8 0000000000000206
Call Trace:
 [<ffffffff8142bd03>] dump_stack+0x85/0xc2
 [<ffffffff81241a59>] dump_header+0x5c/0x22e
 [<ffffffff810dddcd>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff811b33e1>] oom_kill_process+0x221/0x3f0
 [<ffffffff811b3a22>] out_of_memory+0x422/0x560
 [<ffffffff811b9f69>] __alloc_pages_nodemask+0x1069/0x10c0
 [<ffffffff81211a41>] ? alloc_pages_vma+0xc1/0x300
 [<ffffffff81211a41>] alloc_pages_vma+0xc1/0x300
 [<ffffffff811e851f>] ? wp_page_copy+0x7f/0x640
 [<ffffffff811e851f>] wp_page_copy+0x7f/0x640
 [<ffffffff811e974b>] do_wp_page+0x13b/0x6e0
 [<ffffffff811ec704>] handle_mm_fault+0xaf4/0x1310
 [<ffffffff811ebc4b>] ? handle_mm_fault+0x3b/0x1310
 [<ffffffff8106eb90>] ? __do_page_fault+0x160/0x4e0
 [<ffffffff8106ec19>] __do_page_fault+0x1e9/0x4e0
 [<ffffffff8106efed>] trace_do_page_fault+0x5d/0x290
 [<ffffffff810674ca>] do_async_page_fault+0x1a/0xa0
 [<ffffffff8185bee8>] async_page_fault+0x28/0x30
 [<ffffffff810a73d3>] ? __task_pid_nr_ns+0xb3/0x1b0
 [<ffffffff8143ab9c>] ? __put_user_4+0x1c/0x30
 [<ffffffff810b7205>] ? schedule_tail+0x55/0x70
 [<ffffffff81859f3c>] ret_from_fork+0xc/0x40
Mem-Info:
active_anon:26762 inactive_anon:95 isolated_anon:0
 active_file:42543 inactive_file:347438 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:5476 slab_unreclaimable:23140
 mapped:389534 shmem:95 pagetables:20927 bounce:0
 free:6948 free_pcp:222 free_cma:0
Node 0 active_anon:107048kB inactive_anon:380kB active_file:170008kB inactive_file:1389752kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1558136kB dirty:0kB writeback:0kB shmem:0kB shmem_$
hp: 0kB shmem_pmdmapped: 0kB anon_thp: 380kB writeback_tmp:0kB unstable:0kB pages_scanned:4697206 all_unreclaimable? yes
Node 0 DMA free:2168kB min:204kB low:252kB high:300kB active_anon:3544kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB sl$
b_reclaimable:0kB slab_unreclaimable:2684kB kernel_stack:1760kB pagetables:3092kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]: 0 493 493 1955
Node 0 DMA32 free:6508kB min:6492kB low:8112kB high:9732kB active_anon:81264kB inactive_anon:0kB active_file:101204kB inactive_file:228kB unevictable:0kB writepending:0kB present:2080632kB managed:508584k$
 mlocked:0kB slab_reclaimable:21904kB slab_unreclaimable:89876kB kernel_stack:46400kB pagetables:80616kB bounce:0kB free_pcp:544kB local_pcp:120kB free_cma:0kB
lowmem_reserve[]: 0 0 0 1462
Node 0 Movable free:19116kB min:19256kB low:24068kB high:28880kB active_anon:22240kB inactive_anon:380kB active_file:68812kB inactive_file:1389688kB unevictable:0kB writepending:0kB present:1535864kB mana$
ed:1500964kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:368kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 0*4kB 1*8kB (M) 1*16kB (U) 1*32kB (M) 1*64kB (U) 0*128kB 0*256kB 2*512kB (UM) 1*1024kB (U) 0*2048kB 0*4096kB = 2168kB
Node 0 DMA32: 51*4kB (UME) 96*8kB (ME) 46*16kB (UME) 41*32kB (ME) 32*64kB (ME) 11*128kB (UM) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 6476kB
Node 0 Movable: 1*4kB (M) 1*8kB (M) 1*16kB (M) 1*32kB (M) 1*64kB (M) 0*128kB 1*256kB (M) 1*512kB (M) 0*1024kB 1*2048kB (M) 4*4096kB (M) = 19324kB
Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
390134 total pagecache pages
0 pages in swap cache


> 
> Optionally please test without patch 5 if an OOM occurs.

Here goes without patch 5.

fork invoked oom-killer: gfp_mask=0x26000c0(GFP_KERNEL|__GFP_NOTRACK), order=0, oom_score_adj=0                                                                                                    [2[2/9152]
fork cpuset=/ mems_allowed=0
CPU: 5 PID: 1269 Comm: fork Not tainted 4.7.0-rc7-next-20160720+ #714
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.1-0-gb3ef39f-prebuilt.qemu-project.org 04/01/2014
 0000000000000000 ffff8800136138e8 ffffffff8142bd23 ffff880013613ae0
 ffff88000fa6ca00 ffff880013613960 ffffffff81241a79 ffffffff81e70020
 ffff880013613910 ffffffff810dddcd ffff880013613930 0000000000000206
Call Trace:
 [<ffffffff8142bd23>] dump_stack+0x85/0xc2
 [<ffffffff81241a79>] dump_header+0x5c/0x22e
 [<ffffffff810dddcd>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff811b33e1>] oom_kill_process+0x221/0x3f0
 [<ffffffff811b3a22>] out_of_memory+0x422/0x560
 [<ffffffff811b9f69>] __alloc_pages_nodemask+0x1069/0x10c0
 [<ffffffff8120fb01>] ? alloc_pages_current+0xa1/0x1f0
 [<ffffffff8120fb01>] alloc_pages_current+0xa1/0x1f0
 [<ffffffff81219f33>] ? new_slab+0x473/0x5e0
 [<ffffffff81219f33>] new_slab+0x473/0x5e0
 [<ffffffff8121b16f>] ___slab_alloc+0x27f/0x550
 [<ffffffff8121b491>] ? __slab_alloc+0x51/0x90
 [<ffffffff81081e11>] ? copy_process.part.29+0xc11/0x1b90
 [<ffffffff81081e11>] ? copy_process.part.29+0xc11/0x1b90
 [<ffffffff8121b491>] __slab_alloc+0x51/0x90
 [<ffffffff8121b6dc>] kmem_cache_alloc+0x20c/0x2b0
 [<ffffffff81081e11>] ? copy_process.part.29+0xc11/0x1b90
 [<ffffffff81081e11>] copy_process.part.29+0xc11/0x1b90
 [<ffffffff81082f86>] _do_fork+0xe6/0x6a0
 [<ffffffff810835e9>] SyS_clone+0x19/0x20
 [<ffffffff81003e13>] do_syscall_64+0x73/0x1e0
 [<ffffffff81859dc3>] entry_SYSCALL64_slow_path+0x25/0x25
Mem-Info:
active_anon:26003 inactive_anon:95 isolated_anon:0
 active_file:289026 inactive_file:96101 isolated_file:21
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:6056 slab_unreclaimable:23737
 mapped:384788 shmem:95 pagetables:23282 bounce:0
 free:7815 free_pcp:179 free_cma:0
Node 0 active_anon:104012kB inactive_anon:380kB active_file:1156104kB inactive_file:384404kB unevictable:0kB isolated(anon):0kB isolated(file):84kB mapped:1539152kB dirty:0kB writeback:0kB shmem:0kB shmem_
thp: 0kB shmem_pmdmapped: 2048kB anon_thp: 380kB writeback_tmp:0kB unstable:0kB pages_scanned:2512936 all_unreclaimable? yes
Node 0 DMA free:2172kB min:204kB low:252kB high:300kB active_anon:3204kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB sla
b_reclaimable:16kB slab_unreclaimable:2944kB kernel_stack:1584kB pagetables:3188kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]: 0 493 493 1955
Node 0 DMA32 free:6320kB min:6492kB low:8112kB high:9732kB active_anon:79128kB inactive_anon:0kB active_file:69016kB inactive_file:15872kB unevictable:0kB writepending:0kB present:2080632kB managed:508584k
B mlocked:0kB slab_reclaimable:24208kB slab_unreclaimable:92004kB kernel_stack:44064kB pagetables:89940kB bounce:0kB free_pcp:264kB local_pcp:100kB free_cma:0kB
lowmem_reserve[]: 0 0 0 1462
Node 0 Movable free:22768kB min:19256kB low:24068kB high:28880kB active_anon:21676kB inactive_anon:380kB active_file:1085592kB inactive_file:369724kB unevictable:0kB writepending:0kB present:1535864kB mana
ged:1500964kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:452kB local_pcp:80kB free_cma:0kB
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 3*4kB (M) 0*8kB 1*16kB (M) 1*32kB (M) 1*64kB (M) 0*128kB 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 0*4096kB = 2172kB
Node 0 DMA32: 94*4kB (ME) 48*8kB (ME) 22*16kB (ME) 10*32kB (UME) 3*64kB (ME) 1*128kB (M) 0*256kB 2*512kB (UM) 4*1024kB (M) 0*2048kB 0*4096kB = 6872kB
Node 0 Movable: 0*4kB 0*8kB 1*16kB (M) 3*32kB (M) 4*64kB (M) 1*128kB (M) 10*256kB (M) 3*512kB (M) 0*1024kB 1*2048kB (M) 4*4096kB (M) = 23024kB
Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
385234 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0

Thanks.

>  include/linux/mm_inline.h | 19 ++---------
>  include/linux/mmzone.h    |  7 ++++
>  include/linux/swap.h      |  1 +
>  mm/compaction.c           | 20 +----------
>  mm/migrate.c              |  2 ++
>  mm/page-writeback.c       | 17 +++++-----
>  mm/page_alloc.c           | 59 +++++++++++----------------------
>  mm/vmscan.c               | 84 ++++++++++++++++++++++++++++++++++++++---------
>  mm/vmstat.c               |  6 ++++
>  9 files changed, 116 insertions(+), 99 deletions(-)
> 
> -- 
> 2.6.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
