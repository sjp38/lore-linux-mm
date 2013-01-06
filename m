Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id D1C846B005D
	for <linux-mm@kvack.org>; Sun,  6 Jan 2013 07:07:01 -0500 (EST)
Date: Sun, 6 Jan 2013 12:07:00 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130106120700.GA24671@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130104160148.GB3885@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130104160148.GB3885@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Mel Gorman <mgorman@suse.de> wrote:
> Using a 3.7.1 or 3.8-rc2 kernel, can you reproduce the problem and then
> answer the following questions please?

This is on my main machine running 3.8-rc2

> 1. What are the contents of /proc/vmstat at the time it is stuck?

===> /proc/vmstat <===
nr_free_pages 40305
nr_inactive_anon 25023
nr_active_anon 85684
nr_inactive_file 2614786
nr_active_file 209440
nr_unevictable 0
nr_mlock 0
nr_anon_pages 73510
nr_mapped 6017
nr_file_pages 2843997
nr_dirty 695934
nr_writeback 629239
nr_slab_reclaimable 68414
nr_slab_unreclaimable 14178
nr_page_table_pages 3136
nr_kernel_stack 314
nr_unstable 0
nr_bounce 0
nr_vmscan_write 12220042
nr_vmscan_immediate_reclaim 31213310
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 24101
nr_dirtied 534655274
nr_written 281872191
nr_anon_transparent_hugepages 24
nr_free_cma 0
nr_dirty_threshold 2790220
nr_dirty_background_threshold 29370
pgpgin 6961109514
pgpgout 1124854772
pswpin 3940
pswpout 127109
pgalloc_dma 6
pgalloc_dma32 7750674038
pgalloc_normal 78295989795
pgalloc_movable 0
pgfree 86049272519
pgactivate 21397174
pgdeactivate 423853
pgfault 473074235
pgmajfault 20093
pgrefill_dma 0
pgrefill_dma32 158720
pgrefill_normal 233024
pgrefill_movable 0
pgsteal_kswapd_dma 0
pgsteal_kswapd_dma32 450844931
pgsteal_kswapd_normal 1288388818
pgsteal_kswapd_movable 0
pgsteal_direct_dma 0
pgsteal_direct_dma32 71774371
pgsteal_direct_normal 197326432
pgsteal_direct_movable 0
pgscan_kswapd_dma 0
pgscan_kswapd_dma32 459780161
pgscan_kswapd_normal 1334016908
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_dma32 75632525
pgscan_direct_normal 222990090
pgscan_direct_movable 0
pgscan_direct_throttle 0
pginodesteal 228906
slabs_scanned 4077568
kswapd_inodesteal 2591027
kswapd_low_wmark_hit_quickly 674289
kswapd_high_wmark_hit_quickly 39642
kswapd_skip_congestion_wait 506
pageoutrun 2908071
allocstall 431220
pgrotated 15736438
pgmigrate_success 865182
pgmigrate_fail 78157
compact_migrate_scanned 17276417
compact_free_scanned 204979571
compact_isolated 3463801
compact_stall 349792
compact_fail 160801
compact_success 188991
htlb_buddy_alloc_success 0
htlb_buddy_alloc_fail 0
unevictable_pgs_culled 0
unevictable_pgs_scanned 0
unevictable_pgs_rescued 0
unevictable_pgs_mlocked 0
unevictable_pgs_munlocked 0
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
thp_fault_alloc 720
thp_fault_fallback 1719
thp_collapse_alloc 8631
thp_collapse_alloc_failed 4110
thp_split 700
thp_zero_page_alloc 0
thp_zero_page_alloc_failed 0

> 2. What are the contents of /proc/PID/stack for every toosleepy
>    process when they are stuck?

pid and tid stack info, 28018 is the thread I used to automate
reporting (pushed to git://bogomips.org/toosleepy.git)

===> 28014[28014]/stack <===
[<ffffffff8105a97b>] futex_wait_queue_me+0xb7/0xd2
[<ffffffff8105b7fc>] futex_wait+0xf6/0x1f6
[<ffffffff811bb3af>] cpumask_next_and+0x2b/0x37
[<ffffffff8104ebfa>] select_task_rq_fair+0x518/0x59a
[<ffffffff8105c8f1>] do_futex+0xa9/0x88f
[<ffffffff810509a4>] check_preempt_wakeup+0x10d/0x1a7
[<ffffffff8104757d>] check_preempt_curr+0x25/0x62
[<ffffffff8104d4cc>] wake_up_new_task+0x96/0xc2
[<ffffffff8105d1e9>] sys_futex+0x112/0x14d
[<ffffffff81322a49>] stub_clone+0x69/0x90
[<ffffffff81322769>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 28014[28015]/stack <===
[<ffffffff812ae316>] dev_hard_start_xmit+0x281/0x3f1
[<ffffffff81041010>] add_wait_queue+0x14/0x40
[<ffffffff810de0bc>] poll_schedule_timeout+0x43/0x5d
[<ffffffff810deb46>] do_sys_poll+0x314/0x39b
[<ffffffff810de220>] pollwake+0x0/0x4e
[<ffffffff8129fc1d>] release_sock+0xe5/0x11b
[<ffffffff812d7f61>] tcp_recvmsg+0x713/0x846
[<ffffffff812f432c>] inet_recvmsg+0x64/0x75
[<ffffffff8129a26b>] sock_recvmsg+0x86/0x9e
[<ffffffff8100541c>] emulate_vsyscall+0x1e6/0x28e
[<ffffffff8129a3bc>] sockfd_lookup_light+0x1a/0x50
[<ffffffff8129c18b>] sys_recvfrom+0x110/0x128
[<ffffffff81000e34>] __switch_to+0x235/0x3c5
[<ffffffff810ca402>] kmem_cache_free+0x32/0xb9
[<ffffffff810b809d>] remove_vma+0x44/0x4c
[<ffffffff810df0a5>] sys_ppoll+0xaf/0x123
[<ffffffff81322769>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 28014[28016]/stack <===
[<ffffffff812ae7ad>] dev_queue_xmit+0x327/0x336
[<ffffffff8102cb9f>] _local_bh_enable_ip+0x7a/0x8b
[<ffffffff81041010>] add_wait_queue+0x14/0x40
[<ffffffff810de0bc>] poll_schedule_timeout+0x43/0x5d
[<ffffffff810deb46>] do_sys_poll+0x314/0x39b
[<ffffffff810de220>] pollwake+0x0/0x4e
[<ffffffff8129fc1d>] release_sock+0xe5/0x11b
[<ffffffff812d7f61>] tcp_recvmsg+0x713/0x846
[<ffffffff812f432c>] inet_recvmsg+0x64/0x75
[<ffffffff8129a26b>] sock_recvmsg+0x86/0x9e
[<ffffffff8100541c>] emulate_vsyscall+0x1e6/0x28e
[<ffffffff8129a3bc>] sockfd_lookup_light+0x1a/0x50
[<ffffffff8129c18b>] sys_recvfrom+0x110/0x128
[<ffffffff81000e34>] __switch_to+0x235/0x3c5
[<ffffffff810df0a5>] sys_ppoll+0xaf/0x123
[<ffffffff81322769>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 28014[28017]/stack <===
[<ffffffff8129fc1d>] release_sock+0xe5/0x11b
[<ffffffff812a642c>] sk_stream_wait_memory+0x1f7/0x1fc
[<ffffffff81040d5e>] autoremove_wake_function+0x0/0x2a
[<ffffffff812d8fc3>] tcp_sendmsg+0x710/0x86d
[<ffffffff8129a33e>] sock_sendmsg+0x7b/0x93
[<ffffffff8129a642>] sys_sendto+0xee/0x145
[<ffffffff8129a3bc>] sockfd_lookup_light+0x1a/0x50
[<ffffffff8129a668>] sys_sendto+0x114/0x145
[<ffffffff81000e34>] __switch_to+0x235/0x3c5
[<ffffffff81322769>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
===> 28014[28018]/stack <===
[<ffffffff8102b23e>] do_wait+0x1a6/0x21a
[<ffffffff8104757d>] check_preempt_curr+0x25/0x62
[<ffffffff8102b34a>] sys_wait4+0x98/0xb5
[<ffffffff81026321>] do_fork+0x12c/0x1a7
[<ffffffff810297b0>] child_wait_callback+0x0/0x48
[<ffffffff8131c688>] page_fault+0x28/0x30
[<ffffffff81322769>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

> 3. Can you do a sysrq+m and post the resulting dmesg?

SysRq : Show Memory
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:   4
CPU    1: hi:  186, btch:  31 usd: 181
CPU    2: hi:  186, btch:  31 usd:  46
CPU    3: hi:  186, btch:  31 usd:  13
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 106
CPU    1: hi:  186, btch:  31 usd: 183
CPU    2: hi:  186, btch:  31 usd:  20
CPU    3: hi:  186, btch:  31 usd:  76
active_anon:85782 inactive_anon:25023 isolated_anon:0
 active_file:209440 inactive_file:2610279 isolated_file:0
 unevictable:0 dirty:696664 writeback:629020 unstable:0
 free:44152 slab_reclaimable:68414 slab_unreclaimable:14178
 mapped:6017 shmem:24101 pagetables:3136 bounce:0
 free_cma:0
DMA free:15872kB min:84kB low:104kB high:124kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15640kB managed:15896kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:24kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 3132 12078 12078
DMA32 free:85264kB min:17504kB low:21880kB high:26256kB active_anon:46808kB inactive_anon:21212kB active_file:122040kB inactive_file:2833064kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3208020kB managed:3185856kB mlocked:0kB dirty:92120kB writeback:225356kB mapped:356kB shmem:6776kB slab_reclaimable:67156kB slab_unreclaimable:7412kB kernel_stack:80kB pagetables:816kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 8946 8946
Normal free:75472kB min:49988kB low:62484kB high:74980kB active_anon:296320kB inactive_anon:78880kB active_file:715720kB inactive_file:7608052kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:9160704kB managed:9084264kB mlocked:0kB dirty:2694536kB writeback:2290724kB mapped:23712kB shmem:89628kB slab_reclaimable:206500kB slab_unreclaimable:49276kB kernel_stack:2432kB pagetables:11728kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 0*4kB 0*8kB 0*16kB 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15872kB
DMA32: 1681*4kB (UEM) 3196*8kB (UEM) 3063*16kB (UEM) 63*32kB (UEM) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB (R) 0*4096kB = 85364kB
Normal: 8874*4kB (UEM) 1885*8kB (UEM) 581*16kB (UEM) 412*32kB (UM) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB (R) 0*4096kB = 75104kB
2839464 total pagecache pages
891 pages in swap cache
Swap cache stats: add 131049, delete 130158, find 1103447/1103954
Free swap  = 4152384kB
Total swap = 4194300kB
3145712 pages RAM
73642 pages reserved
3313060 pages shared
1432170 pages non-shared

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
