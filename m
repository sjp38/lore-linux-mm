Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E548A6B0260
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 17:26:52 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so401500wmr.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 14:26:52 -0700 (PDT)
Received: from mail.sig21.net (mail.sig21.net. [80.244.240.74])
        by mx.google.com with ESMTPS id w6si653445wma.71.2016.06.16.14.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 14:26:50 -0700 (PDT)
Date: Thu, 16 Jun 2016 23:26:41 +0200
From: Johannes Stezenbach <js@sig21.net>
Subject: 4.6.2 frequent crashes under memory + IO pressure
Message-ID: <20160616212641.GA3308@sig21.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Hi,

a man's got to have a hobby, thus I'm running Android AOSP
builds on my home PC which has 4GB of RAM, 4GB swap.
Apparently it is not really adequate for the job but used to
work with a 4.4.10 kernel.  Now I upgraded to 4.6.2
and it crashes usually within 30mins during compilation.
The crash is a hard hang, mouse doesn't move, no reaction
to keyboard, nothing in logs (systemd journal) after reboot.

Then I tried 4.5.7, it seems to be stable so far.

I'm using dm-crypt + lvm + ext4 (swap also in lvm).

Now I hooked up a laptop to the serial port and captured
some logs of the crash which seems to be repeating

[ 2240.842567] swapper/3: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
or
[ 2241.167986] SLUB: Unable to allocate memory on node -1, gfp=0x2080020(GFP_ATOMIC)

over and over.  Based on the backtraces in the log I decided
to hot-unplug USB devices, and twice the kernel came
back to live, but on the 3rd crash it was dead for good.
Before I pressed the reset button I used SysRq-W.  At the bottom
is a "BUG: workqueue lockup", it could be the result of
the log spew on serial console taking so long but it looks
like some IO is never completing.

Below I'm pasting some log snippets, let me know if you like
it so much you want more of it ;-/  The total log is about 1.7MB.


Thanks,
Johannes


[ 2240.837431] warn_alloc_failed: 13 callbacks suppressed
[ 2240.842567] swapper/3: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
[ 2240.852384] CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.6.2 #2
[ 2240.858215] Hardware name: System manufacturer System Product Name/P8H77-V, BIOS 1905 10/27/2014
[ 2240.866985]  0000000000000086 8d325b5c895ad90b ffff88011b603a90 ffffffff81368f0c
[ 2240.874437]  0000000000000000 0000000000000000 ffff88011b603b30 ffffffff811659de
[ 2240.881907]  ffff88011b603b40 0220002000000001 ffff88011b603b18 ffffffff81f58240
[ 2240.889396] Call Trace:
[ 2240.891839]  <IRQ>  [<ffffffff81368f0c>] dump_stack+0x85/0xbe
[ 2240.897611]  [<ffffffff811659de>] warn_alloc_failed+0x134/0x15c
[ 2240.903531]  [<ffffffff8116850a>] __alloc_pages_nodemask+0x7bd/0x978
[ 2240.909884]  [<ffffffff8119fb97>] new_slab+0x129/0x3bb
[ 2240.915030]  [<ffffffff811a1acd>] ___slab_alloc.constprop.22+0x2fb/0x37b
[ 2240.921730]  [<ffffffff816cb6c6>] ? __alloc_skb+0x55/0x1b4
[ 2240.927224]  [<ffffffff816cc8dc>] ? skb_release_data+0xc0/0xd0
[ 2240.933046]  [<ffffffff811a3507>] ? kfree+0x1c0/0x216
[ 2240.938089]  [<ffffffff811a1ba4>] __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2240.945214]  [<ffffffff811a1ba4>] ? __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2240.952520]  [<ffffffff816cb6c6>] ? __alloc_skb+0x55/0x1b4
[ 2240.957997]  [<ffffffff811a1c78>] kmem_cache_alloc+0xa0/0x1d6
[ 2240.963734]  [<ffffffff816cb6c6>] ? __alloc_skb+0x55/0x1b4
[ 2240.969210]  [<ffffffff816cb6c6>] __alloc_skb+0x55/0x1b4
[ 2240.974524]  [<ffffffffc0299ca7>] ath9k_hif_usb_reg_in_cb+0xd4/0x181 [ath9k_htc]
[ 2240.981925]  [<ffffffff815b12f2>] __usb_hcd_giveback_urb+0xa6/0x10b
[ 2240.988215]  [<ffffffff815b1e60>] usb_giveback_urb_bh+0x9a/0xe4
[ 2240.994134]  [<ffffffff81088185>] tasklet_hi_action+0x10c/0x11b
[ 2241.000063]  [<ffffffff8184da9a>] __do_softirq+0x182/0x377
[ 2241.005548]  [<ffffffff81087be8>] irq_exit+0x54/0xa8
[ 2241.010521]  [<ffffffff8184d727>] do_IRQ+0xc7/0xdf
[ 2241.015321]  [<ffffffff8184b94c>] common_interrupt+0x8c/0x8c
[ 2241.020981]  <EOI>  [<ffffffff8164d6e9>] ? cpuidle_enter_state+0x1ae/0x251
[ 2241.027888]  [<ffffffff8164d7b8>] cpuidle_enter+0x17/0x19
[ 2241.033280]  [<ffffffff810be208>] call_cpuidle+0x44/0x46
[ 2241.038600]  [<ffffffff810be5b4>] cpu_startup_entry+0x2a7/0x378
[ 2241.044524]  [<ffffffff810320cf>] start_secondary+0x17c/0x192
[ 2241.050265] Mem-Info:
[ 2241.052543] active_anon:654174 inactive_anon:208849 isolated_anon:64
[ 2241.052543]  active_file:4782 inactive_file:3878 isolated_file:0
[ 2241.052543]  unevictable:1156 dirty:8 writeback:28052 unstable:0
[ 2241.052543]  slab_reclaimable:13827 slab_unreclaimable:25768
[ 2241.052543]  mapped:6794 shmem:3939 pagetables:5299 bounce:0
[ 2241.052543]  free:424 free_pcp:39 free_cma:0
[ 2241.086414] DMA free:12kB min:32kB low:44kB high:56kB active_anon:28kB inactive_anon:84kB active_file:68kB inactive_file:40kB unevictable:124kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:124kB dirty:0kB writeback:0kB mapped:228kB shmem:36kB slab_reclaimable:552kB slab_unreclaimable:14656kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 2241.128265] lowmem_reserve[]: 0 3156 3592 3592
[ 2241.132792] DMA32 free:2120kB min:6724kB low:9956kB high:13188kB active_anon:2414116kB inactive_anon:629228kB active_file:15184kB inactive_file:13336kB unevictable:3624kB isolated(anon):256kB isolated(file):0kB present:3334492kB managed:3243420kB mlocked:3624kB dirty:24kB writeback:104760kB mapped:21988kB shmem:13936kB slab_reclaimable:46356kB slab_unreclaimable:74196kB kernel_stack:4144kB pagetables:17708kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:92 all_unreclaimable? no
[ 2241.167769] kworker/u8:3: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
[ 2241.167771] CPU: 2 PID: 1470 Comm: kworker/u8:3 Not tainted 4.6.2 #2
[ 2241.167772] Hardware name: System manufacturer System Product Name/P8H77-V, BIOS 1905 10/27/2014
[ 2241.167777] Workqueue: phy1 ath9k_htc_ani_work [ath9k_htc]
[ 2241.167779]  0000000000000086 00000000e4a12a00 ffff8800c6397860 ffffffff81368f0c
[ 2241.167780]  0000000000000000 0000000000000000 ffff8800c6397900 ffffffff811659de
[ 2241.167782]  ffff8800c6397910 0220002000000001 ffffffff810c2fc4 ffffffff81f58240
[ 2241.167782] Call Trace:
[ 2241.167785]  [<ffffffff81368f0c>] dump_stack+0x85/0xbe
[ 2241.167787]  [<ffffffff811659de>] warn_alloc_failed+0x134/0x15c
[ 2241.167789]  [<ffffffff810c2fc4>] ? cpuacct_charge+0x88/0x93
[ 2241.167791]  [<ffffffff8116850a>] __alloc_pages_nodemask+0x7bd/0x978
[ 2241.167794]  [<ffffffff8119fb97>] new_slab+0x129/0x3bb
[ 2241.167795]  [<ffffffff811a1acd>] ___slab_alloc.constprop.22+0x2fb/0x37b
[ 2241.167797]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2241.167799]  [<ffffffff816cb6c6>] ? __alloc_skb+0x55/0x1b4
[ 2241.167801]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2241.167802]  [<ffffffff810c6438>] ? __lock_acquire.isra.16+0x55e/0xb4c
[ 2241.167804]  [<ffffffff81849b63>] ? schedule_timeout+0x213/0x285
[ 2241.167806]  [<ffffffff8138027a>] ? debug_smp_processor_id+0x17/0x19
[ 2241.167807]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2241.167809]  [<ffffffff811a1ba4>] __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2241.167810]  [<ffffffff811a1ba4>] ? __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2241.167811]  [<ffffffff816cb6c6>] ? __alloc_skb+0x55/0x1b4
[ 2241.167812]  [<ffffffff811a1c78>] kmem_cache_alloc+0xa0/0x1d6
[ 2241.167813]  [<ffffffff816cb6c6>] ? __alloc_skb+0x55/0x1b4
[ 2241.167815]  [<ffffffff816cb6c6>] __alloc_skb+0x55/0x1b4
[ 2241.167817]  [<ffffffffc029bd0a>] ath9k_wmi_cmd+0x53/0x1f7 [ath9k_htc]
[ 2241.167820]  [<ffffffffc02a1d1f>] ath9k_regwrite+0xdd/0x129 [ath9k_htc]
[ 2241.167822]  [<ffffffffc021e86b>] ath_hw_cycle_counters_update+0xe4/0x129 [ath]
[ 2241.167828]  [<ffffffffc0240c51>] ath9k_hw_ani_monitor+0x1f/0x1da [ath9k_hw]
[ 2241.167831]  [<ffffffffc02a091d>] ath9k_htc_ani_work+0x151/0x19c [ath9k_htc]
[ 2241.167832]  [<ffffffff810999d3>] process_one_work+0x283/0x4e2
[ 2241.167833]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2241.167835]  [<ffffffff8109a860>] worker_thread+0x285/0x370
[ 2241.167836]  [<ffffffff8109a5db>] ? rescuer_thread+0x2d1/0x2d1
[ 2241.167837]  [<ffffffff8109f208>] kthread+0xff/0x107
[ 2241.167840]  [<ffffffff8184b1f2>] ret_from_fork+0x22/0x50
[ 2241.167841]  [<ffffffff8109f109>] ? kthread_create_on_node+0x1ea/0x1ea
[ 2241.167842] Mem-Info:
[ 2241.167844] active_anon:654090 inactive_anon:208875 isolated_anon:64
[ 2241.167844]  active_file:4644 inactive_file:3896 isolated_file:0
[ 2241.167844]  unevictable:1156 dirty:8 writeback:28052 unstable:0
[ 2241.167844]  slab_reclaimable:13827 slab_unreclaimable:25768
[ 2241.167844]  mapped:6794 shmem:3939 pagetables:5299 bounce:0
[ 2241.167844]  free:591 free_pcp:5 free_cma:0
[ 2241.167848] DMA free:12kB min:32kB low:44kB high:56kB active_anon:28kB inactive_anon:84kB active_file:68kB inactive_file:40kB unevictable:124kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:124kB dirty:0kB writeback:0kB mapped:228kB shmem:36kB slab_reclaimable:552kB slab_unreclaimable:14656kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 2241.167850] lowmem_reserve[]: 0 3156 3592 3592
[ 2241.167853] DMA32 free:2268kB min:6724kB low:9956kB high:13188kB active_anon:2414116kB inactive_anon:629228kB active_file:15184kB inactive_file:13336kB unevictable:3624kB isolated(anon):256kB isolated(file):0kB present:3334492kB managed:3243420kB mlocked:3624kB dirty:24kB writeback:104760kB mapped:21988kB shmem:13936kB slab_reclaimable:46356kB slab_unreclaimable:74196kB kernel_stack:4144kB pagetables:17708kB unstable:0kB bounce:0kB free_pcp:20kB local_pcp:20kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 2241.167855] lowmem_reserve[]: 0 0 435 435
[ 2241.167858] Normal free:84kB min:928kB low:1372kB high:1816kB active_anon:202216kB inactive_anon:206188kB active_file:3324kB inactive_file:2208kB unevictable:876kB isolated(anon):0kB isolated(file):0kB present:522240kB managed:446088kB mlocked:876kB dirty:8kB writeback:7448kB mapped:4960kB shmem:1784kB slab_reclaimable:8400kB slab_unreclaimable:14220kB kernel_stack:1024kB pagetables:3488kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:480 all_unreclaimable? no
[ 2241.167859] lowmem_reserve[]: 0 0 0 0
[ 2241.167864] DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[ 2241.167869] DMA32: 357*4kB (UME) 57*8kB (UME) 36*16kB (UME) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2460kB
[ 2241.167873] Normal: 11*4kB (ME) 3*8kB (ME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 68kB
[ 2241.167874] 51247 total pagecache pages
[ 2241.167874] 37950 pages in swap cache
[ 2241.167875] Swap cache stats: add 6449135, delete 6411185, find 2689085/3219518
[ 2241.167875] Free swap  = 1754552kB
[ 2241.167876] Total swap = 4194300kB
[ 2241.167876] 968179 pages RAM
[ 2241.167877] 0 pages HighMem/MovableOnly
[ 2241.167877] 41827 pages reserved
[ 2241.167878] slab_out_of_memory: 11 callbacks suppressed
[ 2241.167879] SLUB: Unable to allocate memory on node -1, gfp=0x2080020(GFP_ATOMIC)
[ 2241.167880]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
[ 2241.167881]   node 0: slabs: 1922, objs: 30752, free: 0
[ 2241.167884] kworker/u8:3: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)


[ 2377.965266] sysrq: SysRq : Show Blocked State
[ 2377.969684]   task                        PC stack   pid father
[ 2377.975647] systemd         D ffff88011ad63a30     0     1      0 0x00000000
[ 2377.982794]  ffff88011ad63a30 00ffffff81f56840 ffff88011b7d62d8 ffff88011ae5a900
[ 2377.990281]  ffff88011ad58000 ffff88011ad64000 ffffffff81f57540 0000000000000000
[ 2377.997786]  0000000000000000 0000000002421380 ffff88011ad63a48 ffffffff81845cec
[ 2378.005301] Call Trace:
[ 2378.007758]  [<ffffffff81845cec>] schedule+0x8b/0xa3
[ 2378.012749]  [<ffffffff81172138>] throttle_direct_reclaim+0x1f7/0x21d
[ 2378.019239]  [<ffffffff810bdd00>] ? wait_woken+0x72/0x72
[ 2378.024584]  [<ffffffff8117555d>] try_to_free_pages+0x8a/0x21f
[ 2378.030454]  [<ffffffff81168216>] __alloc_pages_nodemask+0x4c9/0x978
[ 2378.036840]  [<ffffffff8116cdf2>] __do_page_cache_readahead+0x144/0x29d
[ 2378.043460]  [<ffffffff8115fdfb>] ? find_get_entry+0xc1/0xcf
[ 2378.049171]  [<ffffffff81162464>] filemap_fault+0x189/0x4b5
[ 2378.054785]  [<ffffffff81162464>] ? filemap_fault+0x189/0x4b5
[ 2378.060600]  [<ffffffff8122e89e>] ext4_filemap_fault+0x3a/0x4e
[ 2378.066476]  [<ffffffff811869f6>] __do_fault+0x75/0xcf
[ 2378.071650]  [<ffffffff8118aaf5>] handle_mm_fault+0x7fc/0x1358
[ 2378.077493]  [<ffffffff81042332>] __do_page_fault+0x33c/0x4e5
[ 2378.083298]  [<ffffffff810424fd>] do_page_fault+0x22/0x27
[ 2378.088767]  [<ffffffff8184cdf8>] page_fault+0x28/0x30
[ 2378.093938] kthreadd        D ffff88011ad7b7c8     0     2      0 0x00000000
[ 2378.101095]  ffff88011ad7b7c8 00ff88011b7ccd80 ffff88011b7d62d8 ffff88011ae5a900
[ 2378.108591]  ffff88011ad5a900 ffff88011ad7c000 000000010009832f ffff88011ad7b800
[ 2378.116088]  ffff88011b7ccd80 0000000000000018 ffff88011ad7b7e0 ffffffff81845cec
[ 2378.123608] Call Trace:
[ 2378.126064]  [<ffffffff81845cec>] schedule+0x8b/0xa3
[ 2378.131063]  [<ffffffff81849b5b>] schedule_timeout+0x20b/0x285
[ 2378.136939]  [<ffffffff810e6da6>] ? init_timer_key+0x112/0x112
[ 2378.142799]  [<ffffffff81845070>] io_schedule_timeout+0xa0/0x102
[ 2378.148855]  [<ffffffff81845070>] ? io_schedule_timeout+0xa0/0x102
[ 2378.155062]  [<ffffffff8117d5c0>] congestion_wait+0x84/0x160
[ 2378.160796]  [<ffffffff810bdd00>] ? wait_woken+0x72/0x72
[ 2378.166163]  [<ffffffff8116c32f>] throttle_vm_writeout+0x88/0xab
[ 2378.172201]  [<ffffffff81174fff>] shrink_zone_memcg+0x635/0x661
[ 2378.178156]  [<ffffffff81175107>] shrink_zone+0xdc/0x1e5
[ 2378.183493]  [<ffffffff81175107>] ? shrink_zone+0xdc/0x1e5
[ 2378.189041]  [<ffffffff811753b5>] do_try_to_free_pages+0x1a5/0x2c3
[ 2378.195253]  [<ffffffff811755f6>] try_to_free_pages+0x123/0x21f
[ 2378.201191]  [<ffffffff81168216>] __alloc_pages_nodemask+0x4c9/0x978
[ 2378.207577]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2378.213800]  [<ffffffff8116893b>] alloc_kmem_pages_node+0x28/0x90
[ 2378.219937]  [<ffffffff810803ce>] copy_process.part.7+0x10f/0x1855
[ 2378.226158]  [<ffffffff8109f109>] ? kthread_create_on_node+0x1ea/0x1ea
[ 2378.232743]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2378.238966]  [<ffffffff81081cbb>] _do_fork+0xd1/0x430
[ 2378.244028]  [<ffffffff8138027a>] ? debug_smp_processor_id+0x17/0x19
[ 2378.250420]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2378.256645]  [<ffffffff81082043>] kernel_thread+0x29/0x2b
[ 2378.262068]  [<ffffffff8109fbe6>] kthreadd+0x1a2/0x1e9
[ 2378.267243]  [<ffffffff8184b1f2>] ret_from_fork+0x22/0x50
[ 2378.272703]  [<ffffffff8109fa44>] ? kthread_create_on_cpu+0x4b/0x4b
[ 2378.279029] kswapd0         D ffff88003744f538     0   766      2 0x00000000
[ 2378.286167]  ffff88003744f538 00ff88011b5ccd80 ffff88011b5d62d8 ffff88011ae58000
[ 2378.293628]  ffff880037450000 ffff880037450000 00000001000984f2 ffff88003744f570
[ 2378.301168]  ffff88011b5ccd80 ffff880037450000 ffff88003744f550 ffffffff81845cec
[ 2378.308674] Call Trace:
[ 2378.311154]  [<ffffffff81845cec>] schedule+0x8b/0xa3
[ 2378.316153]  [<ffffffff81849b5b>] schedule_timeout+0x20b/0x285
[ 2378.322028]  [<ffffffff810e6da6>] ? init_timer_key+0x112/0x112
[ 2378.327931]  [<ffffffff81845070>] io_schedule_timeout+0xa0/0x102
[ 2378.333960]  [<ffffffff81845070>] ? io_schedule_timeout+0xa0/0x102
[ 2378.340166]  [<ffffffff81162c2b>] mempool_alloc+0x123/0x154
[ 2378.345781]  [<ffffffff810bdd00>] ? wait_woken+0x72/0x72
[ 2378.351148]  [<ffffffff8133fdc1>] bio_alloc_bioset+0xe8/0x1d7
[ 2378.356910]  [<ffffffff816342ea>] alloc_tio+0x2d/0x47
[ 2378.361996]  [<ffffffff8163587e>] __split_and_process_bio+0x310/0x3a3
[ 2378.368470]  [<ffffffff81635e15>] dm_make_request+0xb5/0xe2
[ 2378.374078]  [<ffffffff81347ae7>] generic_make_request+0xcc/0x180
[ 2378.380206]  [<ffffffff81347c98>] submit_bio+0xfd/0x145
[ 2378.385482]  [<ffffffff81198948>] __swap_writepage+0x202/0x225
[ 2378.391349]  [<ffffffff810a5eeb>] ? preempt_count_sub+0xf0/0x100
[ 2378.397398]  [<ffffffff8184a5f7>] ? _raw_spin_unlock+0x31/0x44
[ 2378.403273]  [<ffffffff8119a903>] ? page_swapcount+0x45/0x4c
[ 2378.408984]  [<ffffffff811989a5>] swap_writepage+0x3a/0x3e
[ 2378.414530]  [<ffffffff811727ef>] pageout.isra.16+0x160/0x2a7
[ 2378.420320]  [<ffffffff81173a8f>] shrink_page_list+0x5a0/0x8c4
[ 2378.426197]  [<ffffffff81174489>] shrink_inactive_list+0x29e/0x4a1
[ 2378.432434]  [<ffffffff81174e8b>] shrink_zone_memcg+0x4c1/0x661
[ 2378.438406]  [<ffffffff81175107>] shrink_zone+0xdc/0x1e5
[ 2378.443742]  [<ffffffff81175107>] ? shrink_zone+0xdc/0x1e5
[ 2378.449238]  [<ffffffff8117628f>] kswapd+0x6df/0x814
[ 2378.454222]  [<ffffffff81175bb0>] ? mem_cgroup_shrink_node_zone+0x209/0x209
[ 2378.461196]  [<ffffffff8109f208>] kthread+0xff/0x107
[ 2378.466182]  [<ffffffff8184b1f2>] ret_from_fork+0x22/0x50
[ 2378.471631]  [<ffffffff8109f109>] ? kthread_create_on_node+0x1ea/0x1ea
[ 2378.478191] kworker/u8:3    D ffff8800c6397478     0  1470      2 0x00000000
[ 2378.485327] Workqueue: phy1 ath9k_htc_ani_work [ath9k_htc]
[ 2378.490876]  ffff8800c6397478 00ff88011b3ccd80 ffff88011b3d62d8 ffff88011ae45200
[ 2378.498390]  ffff8800c595a900 ffff8800c6398000 00000001000983b9 ffff8800c63974b0
[ 2378.505912]  ffff88011b3ccd80 0000000000000002 ffff8800c6397490 ffffffff81845cec
[ 2378.513426] Call Trace:
[ 2378.515880]  [<ffffffff81845cec>] schedule+0x8b/0xa3
[ 2378.520888]  [<ffffffff81849b5b>] schedule_timeout+0x20b/0x285
[ 2378.526754]  [<ffffffff810e6da6>] ? init_timer_key+0x112/0x112
[ 2378.532614]  [<ffffffff81845070>] io_schedule_timeout+0xa0/0x102
[ 2378.538626]  [<ffffffff81845070>] ? io_schedule_timeout+0xa0/0x102
[ 2378.544851]  [<ffffffff8117d5c0>] congestion_wait+0x84/0x160
[ 2378.550510]  [<ffffffff810bdd00>] ? wait_woken+0x72/0x72
[ 2378.555849]  [<ffffffff8116c32f>] throttle_vm_writeout+0x88/0xab
[ 2378.561889]  [<ffffffff81174fff>] shrink_zone_memcg+0x635/0x661
[ 2378.567834]  [<ffffffff81175107>] shrink_zone+0xdc/0x1e5
[ 2378.573153]  [<ffffffff81175107>] ? shrink_zone+0xdc/0x1e5
[ 2378.578710]  [<ffffffff811753b5>] do_try_to_free_pages+0x1a5/0x2c3
[ 2378.584922]  [<ffffffff811755f6>] try_to_free_pages+0x123/0x21f
[ 2378.590859]  [<ffffffff81168216>] __alloc_pages_nodemask+0x4c9/0x978
[ 2378.597247]  [<ffffffff8119fb97>] new_slab+0x129/0x3bb
[ 2378.602419]  [<ffffffff811a1acd>] ___slab_alloc.constprop.22+0x2fb/0x37b
[ 2378.609163]  [<ffffffff815b381a>] ? usb_alloc_urb+0x1a/0x40
[ 2378.614796]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2378.620022]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2378.625462]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2378.630714]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2378.636165]  [<ffffffff810c6438>] ? __lock_acquire.isra.16+0x55e/0xb4c
[ 2378.642717]  [<ffffffff811a1ba4>] __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2378.649883]  [<ffffffff811a1ba4>] ? __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2378.657275]  [<ffffffff815b381a>] ? usb_alloc_urb+0x1a/0x40
[ 2378.662900]  [<ffffffff811a20f3>] __kmalloc+0xde/0x217
[ 2378.668109]  [<ffffffff815b381a>] usb_alloc_urb+0x1a/0x40
[ 2378.673545]  [<ffffffffc029b445>] hif_usb_send+0x204/0x300 [ath9k_htc]
[ 2378.680120]  [<ffffffffc0299054>] htc_issue_send.constprop.1+0x54/0x5d [ath9k_htc]
[ 2378.687746]  [<ffffffffc0299383>] htc_send_epid+0x15/0x17 [ath9k_htc]
[ 2378.694221]  [<ffffffffc029bde4>] ath9k_wmi_cmd+0x12d/0x1f7 [ath9k_htc]
[ 2378.700868]  [<ffffffffc02a1aa6>] ath9k_regread+0x55/0xae [ath9k_htc]
[ 2378.707368]  [<ffffffffc021e7f0>] ath_hw_cycle_counters_update+0x69/0x129 [ath]
[ 2378.714696]  [<ffffffffc0240c51>] ath9k_hw_ani_monitor+0x1f/0x1da [ath9k_hw]
[ 2378.721779]  [<ffffffffc02a091d>] ath9k_htc_ani_work+0x151/0x19c [ath9k_htc]
[ 2378.728910]  [<ffffffff810999d3>] process_one_work+0x283/0x4e2
[ 2378.734784]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2378.741015]  [<ffffffff8109a860>] worker_thread+0x285/0x370
[ 2378.746613]  [<ffffffff8109a5db>] ? rescuer_thread+0x2d1/0x2d1
[ 2378.752506]  [<ffffffff8109f208>] kthread+0xff/0x107
[ 2378.757492]  [<ffffffff8184b1f2>] ret_from_fork+0x22/0x50
[ 2378.762905]  [<ffffffff8109f109>] ? kthread_create_on_node+0x1ea/0x1ea
[ 2378.769494] kworker/u8:4    D ffff8800c5dc3508     0  1592      2 0x00000000
[ 2378.776582] Workqueue: kcryptd kcryptd_crypt
[ 2378.780887]  ffff8800c5dc3508 00ff88011b7ccd80 ffff88011b7d62d8 ffff88011ae5a900
[ 2378.788399]  ffff88011a605200 ffff8800c5dc4000 00000001000983f7 ffff8800c5dc3540
[ 2378.795930]  ffff88011b7ccd80 0000000000000000 ffff8800c5dc3520 ffffffff81845cec
[ 2378.803408] Call Trace:
[ 2378.805879]  [<ffffffff81845cec>] schedule+0x8b/0xa3
[ 2378.810908]  [<ffffffff81849b5b>] schedule_timeout+0x20b/0x285
[ 2378.816783]  [<ffffffff810e6da6>] ? init_timer_key+0x112/0x112
[ 2378.822677]  [<ffffffff81845070>] io_schedule_timeout+0xa0/0x102
[ 2378.828716]  [<ffffffff81845070>] ? io_schedule_timeout+0xa0/0x102
[ 2378.834956]  [<ffffffff8117d5c0>] congestion_wait+0x84/0x160
[ 2378.840658]  [<ffffffff810bdd00>] ? wait_woken+0x72/0x72
[ 2378.845997]  [<ffffffff8116c32f>] throttle_vm_writeout+0x88/0xab
[ 2378.852036]  [<ffffffff81174fff>] shrink_zone_memcg+0x635/0x661
[ 2378.857982]  [<ffffffff81175107>] shrink_zone+0xdc/0x1e5
[ 2378.863309]  [<ffffffff81175107>] ? shrink_zone+0xdc/0x1e5
[ 2378.868832]  [<ffffffff811753b5>] do_try_to_free_pages+0x1a5/0x2c3
[ 2378.875028]  [<ffffffff811755f6>] try_to_free_pages+0x123/0x21f
[ 2378.880972]  [<ffffffff81168216>] __alloc_pages_nodemask+0x4c9/0x978
[ 2378.887385]  [<ffffffff8138027a>] ? debug_smp_processor_id+0x17/0x19
[ 2378.893782]  [<ffffffff8119fb2a>] new_slab+0xbc/0x3bb
[ 2378.898868]  [<ffffffff811a1acd>] ___slab_alloc.constprop.22+0x2fb/0x37b
[ 2378.905634]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2378.911659]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2378.916909]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2378.922325]  [<ffffffff810c6438>] ? __lock_acquire.isra.16+0x55e/0xb4c
[ 2378.928877]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2378.934138]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2378.939555]  [<ffffffff810c6438>] ? __lock_acquire.isra.16+0x55e/0xb4c
[ 2378.946125]  [<ffffffff811a1ba4>] __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2378.953289]  [<ffffffff811a1ba4>] ? __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2378.960630]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2378.966706]  [<ffffffff811a1c78>] kmem_cache_alloc+0xa0/0x1d6
[ 2378.972503]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2378.978567]  [<ffffffff81162a88>] mempool_alloc_slab+0x15/0x17
[ 2378.984426]  [<ffffffff81162b7a>] mempool_alloc+0x72/0x154
[ 2378.989930]  [<ffffffff810c4b45>] ? lockdep_init_map+0xc9/0x5a3
[ 2378.995866]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2379.001300]  [<ffffffff8133fdc1>] bio_alloc_bioset+0xe8/0x1d7
[ 2379.007107]  [<ffffffff81643127>] kcryptd_crypt+0x1ab/0x325
[ 2379.012704]  [<ffffffff810998fd>] ? process_one_work+0x1ad/0x4e2
[ 2379.018753]  [<ffffffff810999d3>] process_one_work+0x283/0x4e2
[ 2379.024629]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2379.030851]  [<ffffffff8109a860>] worker_thread+0x285/0x370
[ 2379.036423]  [<ffffffff8109a5db>] ? rescuer_thread+0x2d1/0x2d1
[ 2379.042309]  [<ffffffff8109f208>] kthread+0xff/0x107
[ 2379.047310]  [<ffffffff8184b1f2>] ret_from_fork+0x22/0x50
[ 2379.052726]  [<ffffffff8109f109>] ? kthread_create_on_node+0x1ea/0x1ea
[ 2379.059328] kworker/u8:6    D ffff8800c5ec3508     0  1594      2 0x00000000
[ 2379.066468] Workqueue: kcryptd kcryptd_crypt
[ 2379.070808]  ffff8800c5ec3508 00ff88011b7ccd80 ffff88011b7d62d8 ffff88011ae5a900
[ 2379.078296]  ffff88003749a900 ffff8800c5ec4000 0000000100098467 ffff8800c5ec3540
[ 2379.085836]  ffff88011b7ccd80 0000000000000000 ffff8800c5ec3520 ffffffff81845cec
[ 2379.093315] Call Trace:
[ 2379.095776]  [<ffffffff81845cec>] schedule+0x8b/0xa3
[ 2379.100785]  [<ffffffff81849b5b>] schedule_timeout+0x20b/0x285
[ 2379.106627]  [<ffffffff810e6da6>] ? init_timer_key+0x112/0x112
[ 2379.112494]  [<ffffffff81845070>] io_schedule_timeout+0xa0/0x102
[ 2379.118524]  [<ffffffff81845070>] ? io_schedule_timeout+0xa0/0x102
[ 2379.124740]  [<ffffffff8117d5c0>] congestion_wait+0x84/0x160
[ 2379.130432]  [<ffffffff810bdd00>] ? wait_woken+0x72/0x72
[ 2379.135771]  [<ffffffff8116c32f>] throttle_vm_writeout+0x88/0xab
[ 2379.141839]  [<ffffffff81174fff>] shrink_zone_memcg+0x635/0x661
[ 2379.147810]  [<ffffffff81175107>] shrink_zone+0xdc/0x1e5
[ 2379.153155]  [<ffffffff81175107>] ? shrink_zone+0xdc/0x1e5
[ 2379.158651]  [<ffffffff811753b5>] do_try_to_free_pages+0x1a5/0x2c3
[ 2379.164881]  [<ffffffff811755f6>] try_to_free_pages+0x123/0x21f
[ 2379.170861]  [<ffffffff81168216>] __alloc_pages_nodemask+0x4c9/0x978
[ 2379.177292]  [<ffffffff811a1776>] ? get_partial_node.isra.19+0x353/0x3af
[ 2379.184026]  [<ffffffff8119fb2a>] new_slab+0xbc/0x3bb
[ 2379.189103]  [<ffffffff811a1acd>] ___slab_alloc.constprop.22+0x2fb/0x37b
[ 2379.195843]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2379.201895]  [<ffffffff81049da2>] ? glue_xts_crypt_128bit+0x1a6/0x1d8
[ 2379.208357]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2379.213610]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2379.219050]  [<ffffffff810c6438>] ? __lock_acquire.isra.16+0x55e/0xb4c
[ 2379.225596]  [<ffffffff811a1ba4>] __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2379.232769]  [<ffffffff811a1ba4>] ? __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2379.240143]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2379.246177]  [<ffffffff811a1c78>] kmem_cache_alloc+0xa0/0x1d6
[ 2379.251957]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2379.258024]  [<ffffffff81162a88>] mempool_alloc_slab+0x15/0x17
[ 2379.263907]  [<ffffffff81162b7a>] mempool_alloc+0x72/0x154
[ 2379.269403]  [<ffffffff810c4b45>] ? lockdep_init_map+0xc9/0x5a3
[ 2379.275354]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2379.280754]  [<ffffffff8133fdc1>] bio_alloc_bioset+0xe8/0x1d7
[ 2379.286535]  [<ffffffff81643127>] kcryptd_crypt+0x1ab/0x325
[ 2379.292143]  [<ffffffff810998fd>] ? process_one_work+0x1ad/0x4e2
[ 2379.298208]  [<ffffffff810999d3>] process_one_work+0x283/0x4e2
[ 2379.304117]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2379.310341]  [<ffffffff8109a860>] worker_thread+0x285/0x370
[ 2379.315946]  [<ffffffff8109a5db>] ? rescuer_thread+0x2d1/0x2d1
[ 2379.321840]  [<ffffffff8109f208>] kthread+0xff/0x107
[ 2379.326825]  [<ffffffff8184b1f2>] ret_from_fork+0x22/0x50
[ 2379.332299]  [<ffffffff8109f109>] ? kthread_create_on_node+0x1ea/0x1ea


[ 2417.498163] BUG: workqueue lockup - pool[ 2417.500236] INFO: task kworker/u8:9:1598 blocked for more than 120 seconds.
[ 2417.500238]       Not tainted 4.6.2 #2
[ 2417.500239] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2417.500241] kworker/u8:9    D ffff8800c5f67688     0  1598      2 0x00000000
[ 2417.500248] Workqueue: writeback wb_workfn (flush-253:3)
[ 2417.500251]  ffff8800c5f67688 0000000000000000 ffff88011b5d62d8 ffff88011a605200
[ 2417.500255]  ffff8800c6018000 ffff8800c5f68000 7fffffffffffffff 7fffffffffffffff
[ 2417.500258]  0000000000000002 ffffffff8184649a ffff8800c5f676a0 ffffffff81845cec
[ 2417.500261] Call Trace:
[ 2417.500265]  [<ffffffff8184649a>] ? bit_wait+0x55/0x55
[ 2417.500267]  [<ffffffff81845cec>] schedule+0x8b/0xa3
[ 2417.500269]  [<ffffffff8184999e>] schedule_timeout+0x4e/0x285
[ 2417.500273]  [<ffffffff810a5eeb>] ? preempt_count_sub+0xf0/0x100
[ 2417.500275]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2417.500277]  [<ffffffff8184649a>] ? bit_wait+0x55/0x55
[ 2417.500279]  [<ffffffff8184649a>] ? bit_wait+0x55/0x55
[ 2417.500281]  [<ffffffff81845070>] io_schedule_timeout+0xa0/0x102
[ 2417.500283]  [<ffffffff81845070>] ? io_schedule_timeout+0xa0/0x102
[ 2417.500284]  [<ffffffff818464b5>] bit_wait_io+0x1b/0x5f
[ 2417.500286]  [<ffffffff818462cf>] __wait_on_bit_lock+0x4c/0x90
[ 2417.500290]  [<ffffffff8115fc06>] __lock_page+0x80/0x96
[ 2417.500293]  [<ffffffff810bdd34>] ? autoremove_wake_function+0x34/0x34
[ 2417.500297]  [<ffffffff81226edd>] mpage_prepare_extent_to_map+0x16f/0x284
[ 2417.500301]  [<ffffffff8127214a>] ? jbd2__journal_start+0xb5/0x1eb
[ 2417.500304]  [<ffffffff8122b154>] ? ext4_writepages+0x47f/0xd33
[ 2417.500308]  [<ffffffff81253f2b>] ? __ext4_journal_start_sb+0xd5/0x114
[ 2417.500311]  [<ffffffff8122b22f>] ext4_writepages+0x55a/0xd33
[ 2417.500314]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2417.500316]  [<ffffffff810c6438>] ? __lock_acquire.isra.16+0x55e/0xb4c
[ 2417.500318]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2417.500320]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2417.500324]  [<ffffffff8116c633>] do_writepages+0x23/0x2c
[ 2417.500327]  [<ffffffff8116c633>] ? do_writepages+0x23/0x2c
[ 2417.500329]  [<ffffffff811d9652>] __writeback_single_inode+0xc0/0x4b4
[ 2417.500331]  [<ffffffff8184a5f7>] ? _raw_spin_unlock+0x31/0x44
[ 2417.500334]  [<ffffffff811da09d>] writeback_sb_inodes+0x2b2/0x4a5
[ 2417.500337]  [<ffffffff811da306>] __writeback_inodes_wb+0x76/0xae
[ 2417.500339]  [<ffffffff811da5ad>] wb_writeback+0x19d/0x3c8
[ 2417.500342]  [<ffffffff811dae03>] wb_workfn+0x165/0x484
[ 2417.500344]  [<ffffffff811dae03>] ? wb_workfn+0x165/0x484
[ 2417.500347]  [<ffffffff810998fd>] ? process_one_work+0x1ad/0x4e2
[ 2417.500349]  [<ffffffff810999d3>] process_one_work+0x283/0x4e2
[ 2417.500351]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2417.500354]  [<ffffffff8109a860>] worker_thread+0x285/0x370
[ 2417.500356]  [<ffffffff8109a5db>] ? rescuer_thread+0x2d1/0x2d1
[ 2417.500359]  [<ffffffff8109f208>] kthread+0xff/0x107
[ 2417.500363]  [<ffffffff8184b1f2>] ret_from_fork+0x22/0x50
[ 2417.500366]  [<ffffffff8109f109>] ? kthread_create_on_node+0x1ea/0x1ea
[ 2417.500368] 4 locks held by kworker/u8:9/1598:
[ 2417.500369]  #0:  ("writeback"){......}, at: [<ffffffff810998fd>] process_one_work+0x1ad/0x4e2
[ 2417.500375]  #1:  ((&(&wb->dwork)->work)){......}, at: [<ffffffff810998fd>] process_one_work+0x1ad/0x4e2
[ 2417.500380]  #2:  (&type->s_umount_key#27){......}, at: [<ffffffff811b3aaf>] trylock_super+0x1b/0x4b
[ 2417.500386]  #3:  (jbd2_handle){......}, at: [<ffffffff81272006>] start_this_handle+0x358/0x3e7
[ 2417.500395] INFO: task jbd2/dm-3-8:2344 blocked for more than 120 seconds.
[ 2417.500397]       Not tainted 4.6.2 #2
[ 2417.500397] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2417.500398] jbd2/dm-3-8     D ffff8800bf297818     0  2344      2 0x00000000
[ 2417.500402]  ffff8800bf297818 00ffffff810ae420 ffff88011b1d62d8 ffff88011ae30000
[ 2417.500405]  ffff8800c7955200 ffff8800bf298000 7fffffffffffffff 7fffffffffffffff
[ 2417.500408]  0000000000000002 ffffffff8184649a ffff8800bf297830 ffffffff81845cec
[ 2417.500411] Call Trace:
[ 2417.500413]  [<ffffffff8184649a>] ? bit_wait+0x55/0x55
[ 2417.500415]  [<ffffffff81845cec>] schedule+0x8b/0xa3
[ 2417.500417]  [<ffffffff8184999e>] schedule_timeout+0x4e/0x285
[ 2417.500420]  [<ffffffff810a5eeb>] ? preempt_count_sub+0xf0/0x100
[ 2417.500421]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2417.500424]  [<ffffffff8184649a>] ? bit_wait+0x55/0x55
[ 2417.500425]  [<ffffffff8184649a>] ? bit_wait+0x55/0x55
[ 2417.500427]  [<ffffffff81845070>] io_schedule_timeout+0xa0/0x102
[ 2417.500429]  [<ffffffff81845070>] ? io_schedule_timeout+0xa0/0x102
[ 2417.500431]  [<ffffffff818464b5>] bit_wait_io+0x1b/0x5f
[ 2417.500432]  [<ffffffff818460fa>] __wait_on_bit+0x4e/0x80
[ 2417.500436]  [<ffffffff8115f90a>] wait_on_page_bit+0x83/0x99
[ 2417.500438]  [<ffffffff810bdd34>] ? autoremove_wake_function+0x34/0x34
[ 2417.500441]  [<ffffffff8116a15c>] write_cache_pages+0x248/0x448
[ 2417.500443]  [<ffffffff81169bbd>] ? mapping_tagged+0x14/0x14
[ 2417.500446]  [<ffffffff811a2be4>] ? __slab_free+0x31d/0x465
[ 2417.500448]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2417.500450]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2417.500452]  [<ffffffff810c6438>] ? __lock_acquire.isra.16+0x55e/0xb4c
[ 2417.500454]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2417.500457]  [<ffffffff8116a3bb>] generic_writepages+0x5f/0x8d
[ 2417.500460]  [<ffffffff810a5eeb>] ? preempt_count_sub+0xf0/0x100
[ 2417.500462]  [<ffffffff812746a2>] journal_submit_data_buffers+0x129/0x1c9
[ 2417.500464]  [<ffffffff812746a2>] ? journal_submit_data_buffers+0x129/0x1c9
[ 2417.500467]  [<ffffffff81274ea3>] jbd2_journal_commit_transaction+0x57a/0x1813
[ 2417.500470]  [<ffffffff810e72fd>] ? lock_timer_base.isra.0+0x46/0x6b
[ 2417.500473]  [<ffffffff8138027a>] ? debug_smp_processor_id+0x17/0x19
[ 2417.500476]  [<ffffffff810e7405>] ? try_to_del_timer_sync+0x63/0x83
[ 2417.500479]  [<ffffffff8127ab00>] kjournald2+0xd4/0x277
[ 2417.500481]  [<ffffffff8127ab00>] ? kjournald2+0xd4/0x277
[ 2417.500484]  [<ffffffff810bdd00>] ? wait_woken+0x72/0x72
[ 2417.500486]  [<ffffffff8127aa2c>] ? commit_timeout+0x10/0x10
[ 2417.500489]  [<ffffffff8109f208>] kthread+0xff/0x107
[ 2417.500493]  [<ffffffff8184b1f2>] ret_from_fork+0x22/0x50
[ 2417.500496]  [<ffffffff8109f109>] ? kthread_create_on_node+0x1ea/0x1ea
[ 2417.500497] no locks held by jbd2/dm-3-8/2344.
[ 2417.500501] INFO: task Xorg:3124 blocked for more than 120 seconds.
[ 2417.500502]       Not tainted 4.6.2 #2
[ 2417.500502] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2417.500503] Xorg            D ffff8800c0f63788     0  3124   3111 0x00400004
[ 2417.500507]  ffff8800c0f63788 00ff8800c7a88200 ffff88011b5d62d8 ffff8800bfe18000
[ 2417.500510]  ffff8800c08f8000 ffff8800c0f64000 7fffffffffffffff 7fffffffffffffff
[ 2417.500513]  0000000000000002 ffffffff8184649a ffff8800c0f637a0 ffffffff81845cec
[ 2417.500515] Call Trace:
[ 2417.500518]  [<ffffffff8184649a>] ? bit_wait+0x55/0x55
[ 2417.500519]  [<ffffffff81845cec>] schedule+0x8b/0xa3
[ 2417.500521]  [<ffffffff8184999e>] schedule_timeout+0x4e/0x285
[ 2417.500524]  [<ffffffff810a5eeb>] ? preempt_count_sub+0xf0/0x100
[ 2417.500526]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2417.500528]  [<ffffffff8184649a>] ? bit_wait+0x55/0x55
[ 2417.500530]  [<ffffffff81845070>] io_schedule_timeout+0xa0/0x102
[ 2417.500531]  [<ffffffff81845070>] ? io_schedule_timeout+0xa0/0x102
[ 2417.500533]  [<ffffffff818464b5>] bit_wait_io+0x1b/0x5f
[ 2417.500535]  [<ffffffff818460fa>] __wait_on_bit+0x4e/0x80
[ 2417.500538]  [<ffffffff8115f90a>] wait_on_page_bit+0x83/0x99
[ 2417.500541]  [<ffffffff810bdd34>] ? autoremove_wake_function+0x34/0x34
[ 2417.500543]  [<ffffffff8117890d>] shmem_getpage_gfp+0x25f/0x761
[ 2417.500547]  [<ffffffff81179abe>] shmem_read_mapping_page_gfp+0x45/0x74
[ 2417.500551]  [<ffffffff814b331b>] ? i915_gem_object_get_pages_gtt+0x60/0x3be
[ 2417.500554]  [<ffffffff814b33bf>] i915_gem_object_get_pages_gtt+0x104/0x3be
[ 2417.500556]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2417.500559]  [<ffffffff814b47e5>] i915_gem_object_get_pages+0x73/0xc4
[ 2417.500561]  [<ffffffff814b881a>] i915_gem_object_do_pin+0x3d3/0x880
[ 2417.500564]  [<ffffffff814b8cf4>] i915_gem_object_pin+0x2d/0x2f
[ 2417.500566]  [<ffffffff814a92ae>] i915_gem_execbuffer_reserve_vma.isra.5+0x9c/0x148
[ 2417.500568]  [<ffffffff814a9605>] i915_gem_execbuffer_reserve.isra.6+0x2ab/0x380
[ 2417.500571]  [<ffffffff814aa65f>] i915_gem_do_execbuffer.isra.7+0x753/0xfed
[ 2417.500574]  [<ffffffff817cb171>] ? unix_stream_recvmsg+0x4e/0x64
[ 2417.500578]  [<ffffffff817c7767>] ? unix_set_peek_off+0x4f/0x4f
[ 2417.500581]  [<ffffffff814abb84>] i915_gem_execbuffer2+0x14e/0x1d3
[ 2417.500584]  [<ffffffff814662b7>] drm_ioctl+0x264/0x3aa
[ 2417.500586]  [<ffffffff814aba36>] ? i915_gem_execbuffer+0x2ab/0x2ab
[ 2417.500590]  [<ffffffff810a5eeb>] ? preempt_count_sub+0xf0/0x100
[ 2417.500594]  [<ffffffff811c0b43>] vfs_ioctl+0x18/0x34
[ 2417.500596]  [<ffffffff811c10a7>] do_vfs_ioctl+0x4a5/0x526
[ 2417.500599]  [<ffffffff811ca89b>] ? __fget+0xb3/0xc3
[ 2417.500603]  [<ffffffff811c116b>] SyS_ioctl+0x43/0x61
[ 2417.500605]  [<ffffffff8184afbc>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[ 2417.500608] 1 lock held by Xorg/3124:
[ 2417.500608]  #0:  (&dev->struct_mutex){......}, at: [<ffffffff814b3a8f>] i915_mutex_lock_interruptible+0x29/0x48


[ 2418.933184]  cpus=0 node=0 flags=0x0 nice=0 stuck for 99s!
[ 2418.938946] Showing busy workqueues and worker pools:
[ 2418.944034] workqueue events: flags=0x0
[ 2418.947898]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=6/256
[ 2418.954048]     in-flight: 31967:linkwatch_event
[ 2418.958727]     pending: em28xx_ir_work [em28xx_rc], ieee80211_delayed_tailroom_dec [mac80211], console_callback, push_to_pool, do_cache_clean
[ 2418.971728] workqueue events_freezable_power_: flags=0x84
[ 2418.977180]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 2418.983277]     in-flight: 10655:disk_events_workfn
[ 2418.988228] workqueue cgroup_destroy: flags=0x0
[ 2418.992772]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/1
[ 2418.998687]     in-flight: 3267:css_free_work_fn
[ 2419.003372] workqueue writeback: flags=0x4e
[ 2419.007599]   pwq 8: cpus=0-3 flags=0x4 nice=0 active=2/256
[ 2419.013270]     in-flight: 1598:wb_workfn wb_workfn
[ 2419.018254] workqueue usb_hub_wq: flags=0x4
[ 2419.022453]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 2419.028566]     in-flight: 14831:hub_event
[ 2419.032736] workqueue vmstat: flags=0xc
[ 2419.036597]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256 MAYDAY
[ 2419.043309]     pending: vmstat_update
[ 2419.047134] workqueue kcryptd: flags=0x2a
[ 2419.051178]   pwq 8: cpus=0-3 flags=0x4 nice=0 active=4/4
[ 2419.056687]     in-flight: 1592:kcryptd_crypt, 1594:kcryptd_crypt, 2342:kcryptd_crypt, 15543:kcryptd_crypt
[ 2419.066479]     delayed: kcryptd_crypt, kcryptd_crypt [repeats over and over]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
