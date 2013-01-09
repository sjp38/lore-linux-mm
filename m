Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 7C1016B0062
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 03:51:27 -0500 (EST)
Date: Wed, 9 Jan 2013 08:51:26 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130109085126.GA6931@dcvr.yhbt.net>
References: <20130106120700.GA24671@dcvr.yhbt.net>
 <20130107122516.GC3885@suse.de>
 <20130107223850.GA21311@dcvr.yhbt.net>
 <20130108224313.GA13304@suse.de>
 <20130108232325.GA5948@dcvr.yhbt.net>
 <1357697647.18156.1217.camel@edumazet-glaptop>
 <1357698749.27446.6.camel@edumazet-glaptop>
 <1357700082.27446.11.camel@edumazet-glaptop>
 <20130109035511.GA6857@dcvr.yhbt.net>
 <20130109084247.GA6545@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130109084247.GA6545@dcvr.yhbt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <erdnetdev@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Eric Wong <normalperson@yhbt.net> wrote:
> Oops, I had to restart my test :x.  However, I was able to reproduce the
> issue very quickly again with your patch.  I've double-checked I'm
> booting into the correct kernel, but I do have more load on this
> laptop host now, so maybe that made it happen more quickly...

Oops, I forgot to include the debugging output.
(Is this information still useful to you guys?)

2724 process stuck!
===> /proc/vmstat <===
nr_free_pages 2401
nr_inactive_anon 3242
nr_active_anon 3044
nr_inactive_file 103091
nr_active_file 4305
nr_unevictable 0
nr_mlock 0
nr_anon_pages 6204
nr_mapped 2332
nr_file_pages 107533
nr_dirty 144
nr_writeback 0
nr_slab_reclaimable 1440
nr_slab_unreclaimable 5202
nr_page_table_pages 773
nr_kernel_stack 167
nr_unstable 0
nr_bounce 0
nr_vmscan_write 0
nr_vmscan_immediate_reclaim 0
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 115
nr_dirtied 340718
nr_written 4979
nr_anon_transparent_hugepages 0
nr_free_cma 0
nr_dirty_threshold 22904
nr_dirty_background_threshold 11452
pgpgin 43068
pgpgout 20484
pswpin 0
pswpout 0
pgalloc_dma 57018
pgalloc_dma32 9428296
pgalloc_normal 0
pgalloc_movable 0
pgfree 9488417
pgactivate 5151
pgdeactivate 3251
pgfault 751069
pgmajfault 272
pgrefill_dma 115
pgrefill_dma32 3136
pgrefill_normal 0
pgrefill_movable 0
pgsteal_kswapd_dma 2865
pgsteal_kswapd_dma32 209744
pgsteal_kswapd_normal 0
pgsteal_kswapd_movable 0
pgsteal_direct_dma 568
pgsteal_direct_dma32 31692
pgsteal_direct_normal 0
pgsteal_direct_movable 0
pgscan_kswapd_dma 2865
pgscan_kswapd_dma32 210678
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 568
pgscan_direct_dma32 31760
pgscan_direct_normal 0
pgscan_direct_movable 0
pgscan_direct_throttle 0
pginodesteal 0
slabs_scanned 0
kswapd_inodesteal 0
kswapd_low_wmark_hit_quickly 666
kswapd_high_wmark_hit_quickly 2
kswapd_skip_congestion_wait 0
pageoutrun 3135
allocstall 566
pgrotated 2
pgmigrate_success 348
pgmigrate_fail 0
compact_migrate_scanned 335538
compact_free_scanned 144705
compact_isolated 11328
compact_stall 451
compact_fail 279
compact_success 172
unevictable_pgs_culled 1064
unevictable_pgs_scanned 0
unevictable_pgs_rescued 1632
unevictable_pgs_mlocked 1632
unevictable_pgs_munlocked 1632
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
thp_fault_alloc 0
thp_fault_fallback 0
thp_collapse_alloc 0
thp_collapse_alloc_failed 0
thp_split 0
thp_zero_page_alloc 0
thp_zero_page_alloc_failed 0
===> 2724[2724]/stack <===
[<ffffffff81077300>] futex_wait_queue_me+0xc0/0xf0
[<ffffffff81077a9d>] futex_wait+0x17d/0x280
[<ffffffff8107988c>] do_futex+0x11c/0xae0
[<ffffffff8107a2d8>] sys_futex+0x88/0x180
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2724[2725]/stack <===
[<ffffffff810f5904>] poll_schedule_timeout+0x44/0x60
[<ffffffff810f6d54>] do_sys_poll+0x374/0x4b0
[<ffffffff810f718e>] sys_ppoll+0x19e/0x1b0
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2724[2726]/stack <===
[<ffffffff810f5904>] poll_schedule_timeout+0x44/0x60
[<ffffffff810f6d54>] do_sys_poll+0x374/0x4b0
[<ffffffff810f718e>] sys_ppoll+0x19e/0x1b0
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2724[2727]/stack <===
[<ffffffff81310078>] sk_stream_wait_memory+0x1b8/0x250
[<ffffffff8134be87>] tcp_sendmsg+0x697/0xd80
[<ffffffff81370cee>] inet_sendmsg+0x5e/0xa0
[<ffffffff81300a77>] sock_sendmsg+0x87/0xa0
[<ffffffff81303a59>] sys_sendto+0x119/0x160
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2724[2728]/stack <===
[<ffffffff810400b8>] do_wait+0x1f8/0x220
[<ffffffff81040ea0>] sys_wait4+0x70/0xf0
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2773[2773]/stack <===
[<ffffffff81077300>] futex_wait_queue_me+0xc0/0xf0
[<ffffffff81077a9d>] futex_wait+0x17d/0x280
[<ffffffff8107988c>] do_futex+0x11c/0xae0
[<ffffffff8107a2d8>] sys_futex+0x88/0x180
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2773[2774]/stack <===
[<ffffffff810f5904>] poll_schedule_timeout+0x44/0x60
[<ffffffff810f6d54>] do_sys_poll+0x374/0x4b0
[<ffffffff810f718e>] sys_ppoll+0x19e/0x1b0
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2773[2775]/stack <===
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2773[2776]/stack <===
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2773[2777]/stack <===
[<ffffffff8105d02c>] hrtimer_nanosleep+0x9c/0x150
[<ffffffff8105d13e>] sys_nanosleep+0x5e/0x80
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
SysRq : Show Memory
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  72
CPU    1: hi:  186, btch:  31 usd: 100
active_anon:3130 inactive_anon:3283 isolated_anon:0
 active_file:4305 inactive_file:101390 isolated_file:0
 unevictable:0 dirty:103 writeback:0 unstable:0
 free:3675 slab_reclaimable:1453 slab_unreclaimable:5186
 mapped:2332 shmem:115 pagetables:754 bounce:0
 free_cma:0
DMA free:2116kB min:84kB low:104kB high:124kB active_anon:0kB inactive_anon:16kB active_file:0kB inactive_file:13692kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15644kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:4kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 488 488 488
DMA32 free:12584kB min:2784kB low:3480kB high:4176kB active_anon:12520kB inactive_anon:13116kB active_file:17220kB inactive_file:391868kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:499960kB managed:491256kB mlocked:0kB dirty:420kB writeback:0kB mapped:9328kB shmem:460kB slab_reclaimable:5812kB slab_unreclaimable:20740kB kernel_stack:1336kB pagetables:3016kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 4*4kB (UMR) 1*8kB (M) 1*16kB (M) 3*32kB (MR) 1*64kB (R) 1*128kB (R) 1*256kB (R) 1*512kB (R) 1*1024kB (R) 0*2048kB 0*4096kB = 2120kB
DMA32: 411*4kB (UEM) 359*8kB (UEM) 207*16kB (UM) 84*32kB (UM) 25*64kB (UM) 4*128kB (M) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 12628kB
105835 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 392188kB
Total swap = 392188kB
131054 pages RAM
3820 pages reserved
276721 pages shared
117464 pages non-shared

2773 process stuck!
===> /proc/vmstat <===
nr_free_pages 1579
nr_inactive_anon 3302
nr_active_anon 3078
nr_inactive_file 103991
nr_active_file 4357
nr_unevictable 0
nr_mlock 0
nr_anon_pages 6260
nr_mapped 2319
nr_file_pages 108478
nr_dirty 648
nr_writeback 0
nr_slab_reclaimable 1603
nr_slab_unreclaimable 5380
nr_page_table_pages 748
nr_kernel_stack 171
nr_unstable 0
nr_bounce 0
nr_vmscan_write 0
nr_vmscan_immediate_reclaim 0
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 115
nr_dirtied 841467
nr_written 15931
nr_anon_transparent_hugepages 0
nr_free_cma 0
nr_dirty_threshold 22949
nr_dirty_background_threshold 11474
pgpgin 43832
pgpgout 64464
pswpin 0
pswpout 0
pgalloc_dma 105241
pgalloc_dma32 12655633
pgalloc_normal 0
pgalloc_movable 0
pgfree 12763390
pgactivate 5358
pgdeactivate 3607
pgfault 1011343
pgmajfault 302
pgrefill_dma 407
pgrefill_dma32 3200
pgrefill_normal 0
pgrefill_movable 0
pgsteal_kswapd_dma 10785
pgsteal_kswapd_dma32 612431
pgsteal_kswapd_normal 0
pgsteal_kswapd_movable 0
pgsteal_direct_dma 2159
pgsteal_direct_dma32 120797
pgsteal_direct_normal 0
pgsteal_direct_movable 0
pgscan_kswapd_dma 10785
pgscan_kswapd_dma32 613376
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 2159
pgscan_direct_dma32 120866
pgscan_direct_normal 0
pgscan_direct_movable 0
pgscan_direct_throttle 0
pginodesteal 0
slabs_scanned 3072
kswapd_inodesteal 0
kswapd_low_wmark_hit_quickly 1810
kswapd_high_wmark_hit_quickly 13
kswapd_skip_congestion_wait 0
pageoutrun 9178
allocstall 2157
pgrotated 2
pgmigrate_success 509
pgmigrate_fail 0
compact_migrate_scanned 818935
compact_free_scanned 214217
compact_isolated 27006
compact_stall 1014
compact_fail 674
compact_success 340
unevictable_pgs_culled 1064
unevictable_pgs_scanned 0
unevictable_pgs_rescued 1632
unevictable_pgs_mlocked 1632
unevictable_pgs_munlocked 1632
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
thp_fault_alloc 0
thp_fault_fallback 0
thp_collapse_alloc 0
thp_collapse_alloc_failed 0
thp_split 0
thp_zero_page_alloc 0
thp_zero_page_alloc_failed 0
===> 2724[2724]/stack <===
[<ffffffff81077300>] futex_wait_queue_me+0xc0/0xf0
[<ffffffff81077a9d>] futex_wait+0x17d/0x280
[<ffffffff8107988c>] do_futex+0x11c/0xae0
[<ffffffff8107a2d8>] sys_futex+0x88/0x180
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2724[2725]/stack <===
[<ffffffff810f5904>] poll_schedule_timeout+0x44/0x60
[<ffffffff810f6d54>] do_sys_poll+0x374/0x4b0
[<ffffffff810f718e>] sys_ppoll+0x19e/0x1b0
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2724[2726]/stack <===
[<ffffffff810f5904>] poll_schedule_timeout+0x44/0x60
[<ffffffff810f6d54>] do_sys_poll+0x374/0x4b0
[<ffffffff810f718e>] sys_ppoll+0x19e/0x1b0
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2724[2727]/stack <===
[<ffffffff81310078>] sk_stream_wait_memory+0x1b8/0x250
[<ffffffff8134be87>] tcp_sendmsg+0x697/0xd80
[<ffffffff81370cee>] inet_sendmsg+0x5e/0xa0
[<ffffffff81300a77>] sock_sendmsg+0x87/0xa0
[<ffffffff81303a59>] sys_sendto+0x119/0x160
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2724[2728]/stack <===
[<ffffffff8105d02c>] hrtimer_nanosleep+0x9c/0x150
[<ffffffff8105d13e>] sys_nanosleep+0x5e/0x80
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2773[2773]/stack <===
[<ffffffff81077300>] futex_wait_queue_me+0xc0/0xf0
[<ffffffff81077a9d>] futex_wait+0x17d/0x280
[<ffffffff8107988c>] do_futex+0x11c/0xae0
[<ffffffff8107a2d8>] sys_futex+0x88/0x180
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2773[2774]/stack <===
[<ffffffff810f5904>] poll_schedule_timeout+0x44/0x60
[<ffffffff810f6d54>] do_sys_poll+0x374/0x4b0
[<ffffffff810f718e>] sys_ppoll+0x19e/0x1b0
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2773[2775]/stack <===
[<ffffffff810f5904>] poll_schedule_timeout+0x44/0x60
[<ffffffff810f6d54>] do_sys_poll+0x374/0x4b0
[<ffffffff810f718e>] sys_ppoll+0x19e/0x1b0
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2773[2776]/stack <===
[<ffffffff81310078>] sk_stream_wait_memory+0x1b8/0x250
[<ffffffff8134be87>] tcp_sendmsg+0x697/0xd80
[<ffffffff81370cee>] inet_sendmsg+0x5e/0xa0
[<ffffffff81300a77>] sock_sendmsg+0x87/0xa0
[<ffffffff81303a59>] sys_sendto+0x119/0x160
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2773[2777]/stack <===
[<ffffffff810400b8>] do_wait+0x1f8/0x220
[<ffffffff81040ea0>] sys_wait4+0x70/0xf0
[<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
<redundant "SysRq : Show Memory" from previous process omitted>
SysRq : Show Memory
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 164
CPU    1: hi:  186, btch:  31 usd: 117
active_anon:3016 inactive_anon:3281 isolated_anon:0
 active_file:4357 inactive_file:104163 isolated_file:0
 unevictable:0 dirty:142 writeback:0 unstable:0
 free:1582 slab_reclaimable:1598 slab_unreclaimable:5380
 mapped:2316 shmem:115 pagetables:773 bounce:0
 free_cma:0
DMA free:2332kB min:84kB low:104kB high:124kB active_anon:8kB inactive_anon:8kB active_file:0kB inactive_file:13476kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15644kB managed:15900kB mlocked:0kB dirty:12kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:12kB kernel_stack:0kB pagetables:8kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 488 488 488
DMA32 free:3996kB min:2784kB low:3480kB high:4176kB active_anon:12056kB inactive_anon:13116kB active_file:17428kB inactive_file:403176kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:499960kB managed:491256kB mlocked:0kB dirty:556kB writeback:0kB mapped:9264kB shmem:460kB slab_reclaimable:6392kB slab_unreclaimable:21508kB kernel_stack:1360kB pagetables:3084kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 19*4kB (UER) 20*8kB (U) 7*16kB (U) 2*32kB (R) 0*64kB 3*128kB (R) 0*256kB 1*512kB (R) 1*1024kB (R) 0*2048kB 0*4096kB = 2332kB
DMA32: 151*4kB (UEM) 210*8kB (UE) 108*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4012kB
108629 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 392188kB
Total swap = 392188kB
131054 pages RAM
3820 pages reserved
275952 pages shared
119896 pages non-shared

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
