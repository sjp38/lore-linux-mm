Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 4A3D86B0062
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 18:23:26 -0500 (EST)
Date: Tue, 8 Jan 2013 23:23:25 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130108232325.GA5948@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130104160148.GB3885@suse.de>
 <20130106120700.GA24671@dcvr.yhbt.net>
 <20130107122516.GC3885@suse.de>
 <20130107223850.GA21311@dcvr.yhbt.net>
 <20130108224313.GA13304@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130108224313.GA13304@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Mel Gorman <mgorman@suse.de> wrote:
> Please try the following patch. However, even if it works the benefit of
> capture may be so marginal that partially reverting it and simplifying
> compaction.c is the better decision.

I already got my VM stuck on this one.  I had two twosleepy instances,
2774 was the one that got stuck (also confirmed by watching top).

Btw, have you been able to reproduce this on your end?

I think the easiest reproduction on my 2-core VM is by running 2
twosleepy processes and doing the following to dirty a lot of pages:

  while time find $LARGISH_NFS_MOUNT -type f -print0 | \
    xargs -0 -n1 -P4 sh -c 'cat "$1" >> /tmp/z; > /tmp/z' --; do date; done

I've updated git://bogomips.org/toosleepy.git to automate the reporting
for me.

===> /proc/vmstat <===
nr_free_pages 2035
nr_inactive_anon 4044
nr_active_anon 3913
nr_inactive_file 98877
nr_active_file 4373
nr_unevictable 0
nr_mlock 0
nr_anon_pages 7839
nr_mapped 2350
nr_file_pages 103382
nr_dirty 512
nr_writeback 0
nr_slab_reclaimable 1578
nr_slab_unreclaimable 5642
nr_page_table_pages 800
nr_kernel_stack 170
nr_unstable 0
nr_bounce 0
nr_vmscan_write 0
nr_vmscan_immediate_reclaim 0
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 115
nr_dirtied 889731
nr_written 25225
nr_anon_transparent_hugepages 0
nr_free_cma 0
nr_dirty_threshold 22336
nr_dirty_background_threshold 11168
pgpgin 45284
pgpgout 101948
pswpin 0
pswpout 0
pgalloc_dma 299007
pgalloc_dma32 24235925
pgalloc_normal 0
pgalloc_movable 0
pgfree 24539843
pgactivate 5440
pgdeactivate 4476
pgfault 1072378
pgmajfault 338
pgrefill_dma 508
pgrefill_dma32 3968
pgrefill_normal 0
pgrefill_movable 0
pgsteal_kswapd_dma 22463
pgsteal_kswapd_dma32 553340
pgsteal_kswapd_normal 0
pgsteal_kswapd_movable 0
pgsteal_direct_dma 3956
pgsteal_direct_dma32 220354
pgsteal_direct_normal 0
pgsteal_direct_movable 0
pgscan_kswapd_dma 22463
pgscan_kswapd_dma32 554313
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 3956
pgscan_direct_dma32 220397
pgscan_direct_normal 0
pgscan_direct_movable 0
pgscan_direct_throttle 0
pginodesteal 0
slabs_scanned 4096
kswapd_inodesteal 0
kswapd_low_wmark_hit_quickly 1726
kswapd_high_wmark_hit_quickly 21
kswapd_skip_congestion_wait 0
pageoutrun 9065
allocstall 4004
pgrotated 0
pgmigrate_success 1242
pgmigrate_fail 0
compact_migrate_scanned 141232
compact_free_scanned 181666
compact_isolated 52638
compact_stall 2024
compact_fail 1450
compact_success 574
unevictable_pgs_culled 1063
unevictable_pgs_scanned 0
unevictable_pgs_rescued 1653
unevictable_pgs_mlocked 1653
unevictable_pgs_munlocked 1652
unevictable_pgs_cleared 1
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
[<ffffffff813b0729>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2724[2725]/stack <===
[<ffffffff810f5944>] poll_schedule_timeout+0x44/0x60
[<ffffffff810f6d94>] do_sys_poll+0x374/0x4b0
[<ffffffff810f71ce>] sys_ppoll+0x19e/0x1b0
[<ffffffff813b0729>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2724[2726]/stack <===
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2724[2727]/stack <===
[<ffffffff81310098>] sk_stream_wait_memory+0x1b8/0x250
[<ffffffff8134bea7>] tcp_sendmsg+0x697/0xd80
[<ffffffff81370d0e>] inet_sendmsg+0x5e/0xa0
[<ffffffff81300ab7>] sock_sendmsg+0x87/0xa0
[<ffffffff81303a99>] sys_sendto+0x119/0x160
[<ffffffff813b0729>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2724[2728]/stack <===
[<ffffffff8105d02c>] hrtimer_nanosleep+0x9c/0x150
[<ffffffff8105d13e>] sys_nanosleep+0x5e/0x80
[<ffffffff813b0729>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2774[2774]/stack <===
[<ffffffff81077300>] futex_wait_queue_me+0xc0/0xf0
[<ffffffff81077a9d>] futex_wait+0x17d/0x280
[<ffffffff8107988c>] do_futex+0x11c/0xae0
[<ffffffff8107a2d8>] sys_futex+0x88/0x180
[<ffffffff813b0729>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2774[2775]/stack <===
[<ffffffff810f5944>] poll_schedule_timeout+0x44/0x60
[<ffffffff810f6d94>] do_sys_poll+0x374/0x4b0
[<ffffffff810f71ce>] sys_ppoll+0x19e/0x1b0
[<ffffffff813b0729>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2774[2776]/stack <===
[<ffffffff81310098>] sk_stream_wait_memory+0x1b8/0x250
[<ffffffff8134bea7>] tcp_sendmsg+0x697/0xd80
[<ffffffff81370d0e>] inet_sendmsg+0x5e/0xa0
[<ffffffff81300ab7>] sock_sendmsg+0x87/0xa0
[<ffffffff81303a99>] sys_sendto+0x119/0x160
[<ffffffff813b0729>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2774[2777]/stack <===
[<ffffffff81310098>] sk_stream_wait_memory+0x1b8/0x250
[<ffffffff8134bea7>] tcp_sendmsg+0x697/0xd80
[<ffffffff81370d0e>] inet_sendmsg+0x5e/0xa0
[<ffffffff81300ab7>] sock_sendmsg+0x87/0xa0
[<ffffffff81303a99>] sys_sendto+0x119/0x160
[<ffffffff813b0729>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 2774[2778]/stack <===
[<ffffffff810400b8>] do_wait+0x1f8/0x220
[<ffffffff81040ea0>] sys_wait4+0x70/0xf0
[<ffffffff813b0729>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
SysRq : Show Memory
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 108
CPU    1: hi:  186, btch:  31 usd: 162
active_anon:3990 inactive_anon:4042 isolated_anon:0
 active_file:4362 inactive_file:98536 isolated_file:0
 unevictable:0 dirty:513 writeback:0 unstable:0
 free:1896 slab_reclaimable:1530 slab_unreclaimable:5661
 mapped:2342 shmem:115 pagetables:784 bounce:0
 free_cma:0
DMA free:2080kB min:84kB low:104kB high:124kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:12168kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15644kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:16kB slab_unreclaimable:192kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 488 488 488
DMA32 free:5568kB min:2784kB low:3480kB high:4176kB active_anon:15960kB inactive_anon:16168kB active_file:17448kB inactive_file:381976kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:499960kB managed:491256kB mlocked:0kB dirty:2052kB writeback:0kB mapped:9368kB shmem:460kB slab_reclaimable:6104kB slab_unreclaimable:22452kB kernel_stack:1416kB pagetables:3136kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 6*4kB (UR) 5*8kB (UR) 2*16kB (U) 0*32kB 11*64kB (R) 2*128kB (R) 0*256kB 0*512kB 1*1024kB (R) 0*2048kB 0*4096kB = 2080kB
DMA32: 280*4kB (UEM) 66*8kB (UEM) 99*16kB (U) 40*32kB (UM) 16*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5536kB
103002 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 392188kB
Total swap = 392188kB
131054 pages RAM
3820 pages reserved
411919 pages shared
116133 pages non-shared

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
