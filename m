Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id B5C766B0062
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 19:21:30 -0500 (EST)
Date: Tue, 8 Jan 2013 00:21:29 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130108002129.GA7331@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130104160148.GB3885@suse.de>
 <20130106120700.GA24671@dcvr.yhbt.net>
 <20130107122516.GC3885@suse.de>
 <1357598315.6919.3969.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357598315.6919.3969.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> It would not surprise me if sk_stream_wait_memory() have plain bug(s) or
> race(s).
> 
> In 2010, in commit 482964e56e132 Nagendra Tomar fixed a pretty severe
> long standing bug.
> 
> This path is not taken very often on most machines.
> 
> I would try the following patch :

With your patch alone (on top of 3.8-rc2) running on my VM,
I was able to get toosleepy stuck within a few minutes.

===> /proc/vmstat <===
nr_free_pages 3251
nr_inactive_anon 3974
nr_active_anon 3638
nr_inactive_file 100973
nr_active_file 4669
nr_unevictable 0
nr_mlock 0
nr_anon_pages 7515
nr_mapped 2328
nr_file_pages 105739
nr_dirty 6
nr_writeback 0
nr_slab_reclaimable 1703
nr_slab_unreclaimable 5465
nr_page_table_pages 735
nr_kernel_stack 161
nr_unstable 0
nr_bounce 0
nr_vmscan_write 0
nr_vmscan_immediate_reclaim 17
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 115
nr_dirtied 1575304
nr_written 95797
nr_anon_transparent_hugepages 0
nr_free_cma 0
nr_dirty_threshold 22988
nr_dirty_background_threshold 11494
pgpgin 61164
pgpgout 385372
pswpin 0
pswpout 0
pgalloc_dma 123943
pgalloc_dma32 15694247
pgalloc_normal 0
pgalloc_movable 0
pgfree 15823064
pgactivate 6119
pgdeactivate 5134
pgfault 1439865
pgmajfault 495
pgrefill_dma 1230
pgrefill_dma32 3904
pgrefill_normal 0
pgrefill_movable 0
pgsteal_kswapd_dma 22875
pgsteal_kswapd_dma32 1272136
pgsteal_kswapd_normal 0
pgsteal_kswapd_movable 0
pgsteal_direct_dma 3351
pgsteal_direct_dma32 187467
pgsteal_direct_normal 0
pgsteal_direct_movable 0
pgscan_kswapd_dma 22879
pgscan_kswapd_dma32 1273059
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 3351
pgscan_direct_dma32 187566
pgscan_direct_normal 0
pgscan_direct_movable 0
pgscan_direct_throttle 0
pginodesteal 8
slabs_scanned 14336
kswapd_inodesteal 91
kswapd_low_wmark_hit_quickly 2797
kswapd_high_wmark_hit_quickly 65
kswapd_skip_congestion_wait 3
pageoutrun 18900
allocstall 3350
pgrotated 10
pgmigrate_success 278
pgmigrate_fail 0
compact_migrate_scanned 68864
compact_free_scanned 118486
compact_isolated 6958
compact_stall 306
compact_fail 128
compact_success 178
unevictable_pgs_culled 1063
unevictable_pgs_scanned 0
unevictable_pgs_rescued 1669
unevictable_pgs_mlocked 1669
unevictable_pgs_munlocked 1666
unevictable_pgs_cleared 3
unevictable_pgs_stranded 0
thp_fault_alloc 0
thp_fault_fallback 0
thp_collapse_alloc 0
thp_collapse_alloc_failed 0
thp_split 0
thp_zero_page_alloc 0
thp_zero_page_alloc_failed 0
===> 6018[6018]/stack <===
[<ffffffff81077300>] futex_wait_queue_me+0xc0/0xf0
[<ffffffff81077a9d>] futex_wait+0x17d/0x280
[<ffffffff8107988c>] do_futex+0x11c/0xae0
[<ffffffff8107a2d8>] sys_futex+0x88/0x180
[<ffffffff813b06a9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 6018[6019]/stack <===
[<ffffffff810f5904>] poll_schedule_timeout+0x44/0x60
[<ffffffff810f6d54>] do_sys_poll+0x374/0x4b0
[<ffffffff810f718e>] sys_ppoll+0x19e/0x1b0
[<ffffffff813b06a9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 6018[6020]/stack <===
[<ffffffff810f5904>] poll_schedule_timeout+0x44/0x60
[<ffffffff810f6d54>] do_sys_poll+0x374/0x4b0
[<ffffffff810f718e>] sys_ppoll+0x19e/0x1b0
[<ffffffff813b06a9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 6018[6021]/stack <===
[<ffffffff81310058>] sk_stream_wait_memory+0x1b8/0x250
[<ffffffff8134be67>] tcp_sendmsg+0x697/0xd80
[<ffffffff81370cce>] inet_sendmsg+0x5e/0xa0
[<ffffffff81300a77>] sock_sendmsg+0x87/0xa0
[<ffffffff81303a59>] sys_sendto+0x119/0x160
[<ffffffff813b06a9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 6018[6022]/stack <===
[<ffffffff810400b8>] do_wait+0x1f8/0x220
[<ffffffff81040ea0>] sys_wait4+0x70/0xf0
[<ffffffff813b06a9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
SysRq : Show Memory
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 156
CPU    1: hi:  186, btch:  31 usd: 158
active_anon:3546 inactive_anon:3645 isolated_anon:0
 active_file:4327 inactive_file:101560 isolated_file:0
 unevictable:0 dirty:1 writeback:0 unstable:0
 free:3057 slab_reclaimable:1435 slab_unreclaimable:5441
 mapped:2308 shmem:115 pagetables:798 bounce:0
 free_cma:0
DMA free:2080kB min:84kB low:104kB high:124kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:13428kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15644kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:32kB slab_unreclaimable:84kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 488 488 488
DMA32 free:10148kB min:2784kB low:3480kB high:4176kB active_anon:14184kB inactive_anon:14580kB active_file:17308kB inactive_file:392812kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:499960kB managed:491256kB mlocked:0kB dirty:4kB writeback:0kB mapped:9232kB shmem:460kB slab_reclaimable:5708kB slab_unreclaimable:21680kB kernel_stack:1352kB pagetables:3192kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 10*4kB (UR) 0*8kB 2*16kB (U) 3*32kB (R) 2*64kB (R) 0*128kB 1*256kB (R) 1*512kB (R) 1*1024kB (R) 0*2048kB 0*4096kB = 2088kB
DMA32: 370*4kB (UEM) 194*8kB (UM) 72*16kB (UM) 33*32kB (UM) 25*64kB (UEM) 18*128kB (EM) 4*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10168kB
105998 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 392188kB
Total swap = 392188kB
131054 pages RAM
3820 pages reserved
276280 pages shared
118656 pages non-shared
SysRq : Show Memory
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 158
CPU    1: hi:  186, btch:  31 usd: 176
active_anon:3376 inactive_anon:3666 isolated_anon:0
 active_file:4331 inactive_file:101207 isolated_file:0
 unevictable:0 dirty:0 writeback:38 unstable:0
 free:3683 slab_reclaimable:1460 slab_unreclaimable:5398
 mapped:2306 shmem:115 pagetables:762 bounce:0
 free_cma:0
DMA free:2168kB min:84kB low:104kB high:124kB active_anon:0kB inactive_anon:16kB active_file:0kB inactive_file:13348kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15644kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:40kB slab_unreclaimable:76kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 488 488 488
DMA32 free:12564kB min:2784kB low:3480kB high:4176kB active_anon:13504kB inactive_anon:14648kB active_file:17324kB inactive_file:391480kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:499960kB managed:491256kB mlocked:0kB dirty:0kB writeback:152kB mapped:9224kB shmem:460kB slab_reclaimable:5800kB slab_unreclaimable:21516kB kernel_stack:1368kB pagetables:3048kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 25*4kB (MR) 1*8kB (R) 3*16kB (R) 3*32kB (R) 2*64kB (R) 0*128kB 1*256kB (R) 1*512kB (R) 1*1024kB (R) 0*2048kB 0*4096kB = 2172kB
DMA32: 427*4kB (UM) 336*8kB (UEM) 126*16kB (UEM) 49*32kB (UEM) 40*64kB (UEM) 10*128kB (UM) 3*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 12588kB
105658 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 392188kB
Total swap = 392188kB
131054 pages RAM
3820 pages reserved
275229 pages shared
118788 pages non-shared
SysRq : Show Memory
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 108
CPU    1: hi:  186, btch:  31 usd: 166
active_anon:3022 inactive_anon:3664 isolated_anon:0
 active_file:4405 inactive_file:69838 isolated_file:0
 unevictable:0 dirty:5 writeback:4813 unstable:0
 free:34429 slab_reclaimable:1723 slab_unreclaimable:5522
 mapped:2322 shmem:115 pagetables:748 bounce:0
 free_cma:0
DMA free:3616kB min:84kB low:104kB high:124kB active_anon:0kB inactive_anon:20kB active_file:0kB inactive_file:10480kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15644kB managed:15900kB mlocked:0kB dirty:0kB writeback:560kB mapped:0kB shmem:0kB slab_reclaimable:108kB slab_unreclaimable:328kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 488 488 488
DMA32 free:134100kB min:2784kB low:3480kB high:4176kB active_anon:12088kB inactive_anon:14636kB active_file:17620kB inactive_file:268872kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:499960kB managed:491256kB mlocked:0kB dirty:20kB writeback:18692kB mapped:9288kB shmem:460kB slab_reclaimable:6784kB slab_unreclaimable:21760kB kernel_stack:1328kB pagetables:2992kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 136*4kB (UEMR) 89*8kB (UMR) 42*16kB (UMR) 7*32kB (UMR) 3*64kB (R) 0*128kB 1*256kB (R) 0*512kB 1*1024kB (R) 0*2048kB 0*4096kB = 3624kB
DMA32: 4839*4kB (UEM) 4648*8kB (UEM) 2853*16kB (UEM) 868*32kB (UEM) 65*64kB (UEM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 134124kB
74344 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 392188kB
Total swap = 392188kB
131054 pages RAM
3820 pages reserved
285651 pages shared
82395 pages non-shared
SysRq : Show Memory
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 166
CPU    1: hi:  186, btch:  31 usd:  28
active_anon:3729 inactive_anon:3974 isolated_anon:0
 active_file:4669 inactive_file:101127 isolated_file:0
 unevictable:0 dirty:6 writeback:0 unstable:0
 free:3244 slab_reclaimable:1703 slab_unreclaimable:5465
 mapped:2328 shmem:115 pagetables:754 bounce:0
 free_cma:0
DMA free:2360kB min:84kB low:104kB high:124kB active_anon:0kB inactive_anon:4kB active_file:20kB inactive_file:9756kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15644kB managed:15900kB mlocked:0kB dirty:12kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:368kB slab_unreclaimable:324kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 488 488 488
DMA32 free:10616kB min:2784kB low:3480kB high:4176kB active_anon:14916kB inactive_anon:15892kB active_file:18656kB inactive_file:394752kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:499960kB managed:491256kB mlocked:0kB dirty:12kB writeback:0kB mapped:9312kB shmem:460kB slab_reclaimable:6444kB slab_unreclaimable:21536kB kernel_stack:1288kB pagetables:3016kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 43*4kB (UMR) 16*8kB (UMR) 19*16kB (MR) 23*32kB (UR) 8*64kB (R) 2*128kB (R) 1*256kB (R) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2364kB
DMA32: 634*4kB (UEM) 615*8kB (UEM) 199*16kB (UEM) 1*32kB (M) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10672kB
105892 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 392188kB
Total swap = 392188kB
131054 pages RAM
3820 pages reserved
274934 pages shared
119600 pages non-shared

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
