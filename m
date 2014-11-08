Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 25E9B6B0104
	for <linux-mm@kvack.org>; Sat,  8 Nov 2014 08:12:18 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id n3so6855973wiv.0
        for <linux-mm@kvack.org>; Sat, 08 Nov 2014 05:12:17 -0800 (PST)
Received: from tux-cave.hellug.gr (tux-cave.hellug.gr. [195.134.99.74])
        by mx.google.com with ESMTPS id ea8si8110153wib.15.2014.11.08.05.12.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Nov 2014 05:12:16 -0800 (PST)
From: "P. Christeas" <xrg@linux.gr>
Subject: Re: Early test: hangs in mm/compact.c w. Linus's 12d7aacab56e9ef185c
Date: Sat, 08 Nov 2014 15:11:42 +0200
Message-ID: <3443150.6EQzxj6Rt9@xorhgos3.pefnos>
In-Reply-To: <545BEA3B.40005@suse.cz>
References: <12996532.NCRhVKzS9J@xorhgos3.pefnos> <3583067.00bS4AInhm@xorhgos3.pefnos> <545BEA3B.40005@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="nextPart3106412.5RfoaVLMj1"
Content-Transfer-Encoding: 7Bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, lkml <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.

--nextPart3106412.5RfoaVLMj1
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Thursday 06 November 2014, Vlastimil Babka wrote:
> > On Wednesday 05 November 2014, Vlastimil Babka wrote:
> >> Can you please try the following patch?
> >> -			compaction_defer_reset(zone, order, false);
> Oh and did I ask in this thread for /proc/zoneinfo yet? :)

Using that same kernel[1], got again into a race, gathered a few more data.

This time, I had 1x "urpmq" process [2] hung at 100% CPU , when "kwin" got 
apparently blocked (100% CPU, too) trying to resize a GUI window. I suppose 
the resizing operation would mean heavy memory alloc/free.

The rest of the system was responsive, I could easily get a console, login, 
gather the files.. Then, I have *killed* -9 the "urpmq" process, which solved 
the race and my system is still alive! "kwin" is still running, returned to 
regular CPU load.

Attached is traces from SysRq+l (pressed a few times, wanted to "snapshot" the 
stack) and /proc/zoneinfo + /proc/vmstat

Bisection is not yet meaningful, IMHO, because I cannot be sure that "good" 
points are really free from this issue. I'd estimate that each test would take 
+3days, unless I really find a deterministic way to reproduce the issue .


Thank you, again.


[1] linus's didn't have any -mm changes, so I haven't compiled anything yet. 
This means it also contains the "- compaction_defer_reset()" change

[2] urpmq is a Mandrake distro Perl script for querying the RPM database. It 
does some disk I/O , loads data into allocated Perl structs and sorts that, 
FYI.

--nextPart3106412.5RfoaVLMj1
Content-Disposition: attachment; filename="zoneinfo.log"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-log; charset="UTF-8"; name="zoneinfo.log"

Node 0, zone      DMA
  pages free     3055
        min      58
        low      72
        high     87
        scanned  0
        spanned  4095
        present  3998
        managed  3977
    nr_free_pages 3055
    nr_alloc_batch 15
    nr_inactive_anon 295
    nr_active_anon 132
    nr_inactive_file 134
    nr_active_file 198
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 388
    nr_mapped    84
    nr_file_pages 386
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 59
    nr_slab_unreclaimable 32
    nr_page_table_pages 57
    nr_kernel_stack 2
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 1301
    nr_vmscan_immediate_reclaim 272
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     19
    nr_dirtied   21715
    nr_written   20583
    nr_pages_scanned 0
    workingset_refault 7169
    workingset_activate 1604
    workingset_nodereclaim 0
    nr_anon_transparent_hugepages 0
    nr_free_cma  0
        protection: (0, 2984, 2984, 2984)
  pagesets
    cpu: 0
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 4
    cpu: 1
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 4
  all_unreclaimable: 0
  start_pfn:         1
  inactive_ratio:    1
Node 0, zone    DMA32
  pages free     51824
        min      11205
        low      14006
        high     16807
        scanned  0
        spanned  779984
        present  779984
        managed  764335
    nr_free_pages 51824
    nr_alloc_batch 42
    nr_inactive_anon 108284
    nr_active_anon 388047
    nr_inactive_file 28047
    nr_active_file 95328
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 444472
    nr_mapped    78178
    nr_file_pages 186535
    nr_dirty     236
    nr_writeback 0
    nr_slab_reclaimable 53697
    nr_slab_unreclaimable 11297
    nr_page_table_pages 18188
    nr_kernel_stack 483
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 423678
    nr_vmscan_immediate_reclaim 2915
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     50993
    nr_dirtied   10098257
    nr_written   8809535
    nr_pages_scanned 0
    workingset_refault 5683710
    workingset_activate 1087302
    workingset_nodereclaim 1664
    nr_anon_transparent_hugepages 334
    nr_free_cma  0
        protection: (0, 0, 0, 0)
  pagesets
    cpu: 0
              count: 155
              high:  186
              batch: 31
  vm stats threshold: 24
    cpu: 1
              count: 49
              high:  186
              batch: 31
  vm stats threshold: 24
  all_unreclaimable: 0
  start_pfn:         4096
  inactive_ratio:    4

/proc/vmstat:
nr_free_pages 24041
nr_alloc_batch 1364
nr_inactive_anon 108048
nr_active_anon 397021
nr_inactive_file 42071
nr_active_file 102045
nr_unevictable 0
nr_mlock 0
nr_anon_pages 453175
nr_mapped 79221
nr_file_pages 208686
nr_dirty 977
nr_writeback 0
nr_slab_reclaimable 54008
nr_slab_unreclaimable 11475
nr_page_table_pages 19820
nr_kernel_stack 488
nr_unstable 0
nr_bounce 0
nr_vmscan_write 425540
nr_vmscan_immediate_reclaim 3187
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 50631
nr_dirtied 10151224
nr_written 8851175
nr_pages_scanned 0
workingset_refault 5711048
workingset_activate 1090895
workingset_nodereclaim 1664
nr_anon_transparent_hugepages 331
nr_free_cma 0
nr_dirty_threshold 29656
nr_dirty_background_threshold 14828
pgpgin 26370697
pgpgout 36940756
pswpin 197981
pswpout 424588
pgalloc_dma 379037
pgalloc_dma32 226001662
pgalloc_normal 0
pgalloc_movable 0
pgfree 230530685
pgactivate 8145753
pgdeactivate 9388084
pgfault 205223740
pgmajfault 189721
pgrefill_dma 15435
pgrefill_dma32 10362280
pgrefill_normal 0
pgrefill_movable 0
pgsteal_kswapd_dma 11715
pgsteal_kswapd_dma32 7800447
pgsteal_kswapd_normal 0
pgsteal_kswapd_movable 0
pgsteal_direct_dma 0
pgsteal_direct_dma32 990214
pgsteal_direct_normal 0
pgsteal_direct_movable 0
pgscan_kswapd_dma 15269
pgscan_kswapd_dma32 9268463
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_dma32 1139388
pgscan_direct_normal 0
pgscan_direct_movable 0
pgscan_direct_throttle 0
pginodesteal 0
slabs_scanned 13515392
kswapd_inodesteal 2787
kswapd_low_wmark_hit_quickly 13889
kswapd_high_wmark_hit_quickly 8171
pageoutrun 24547
allocstall 6766
pgrotated 426791
drop_pagecache 0
drop_slab 0
pgmigrate_success 3318478
pgmigrate_fail 143
compact_migrate_scanned 25250660
compact_free_scanned 1321336375
compact_isolated 8016565
compact_stall 10944
compact_fail 9741
compact_success 1203
htlb_buddy_alloc_success 0
htlb_buddy_alloc_fail 0
unevictable_pgs_culled 934
unevictable_pgs_scanned 0
unevictable_pgs_rescued 3228
unevictable_pgs_mlocked 4060
unevictable_pgs_munlocked 4060
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
thp_fault_alloc 12914
thp_fault_fallback 9010
thp_collapse_alloc 5147
thp_collapse_alloc_failed 3115
thp_split 217
thp_zero_page_alloc 9
thp_zero_page_alloc_failed 0

--nextPart3106412.5RfoaVLMj1
Content-Disposition: attachment; filename="kcrash2.log"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-log; charset="UTF-8"; name="kcrash2.log"

SysRq : Changing Loglevel
Loglevel set to 8
SysRq : Show backtrace of all active CPUs
sending NMI to all CPUs:
NMI backtrace for cpu 0
CPU: 0 PID: 7037 Comm: urpmq Not tainted 3.18.0-rc3+ #46
Hardware name: Acer            TravelMate 5720                /Columbia                       , BIOS V1.34           04/15/2008
task: ffff88000387de80 ti: ffff88007dddc000 task.ti: ffff88007dddc000
RIP: 0010:[<ffffffff811df82b>]  [<ffffffff811df82b>] __const_udelay+0x15/0x29
RSP: 0000:ffff8800bf203b68  EFLAGS: 00000006
RAX: 0000000001062560 RBX: 0000000000002710 RCX: 0000000000000007
RDX: 00000000001859ed RSI: 0000000000000c00 RDI: 0000000000418958
RBP: ffff8800bf203b68 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000046 R11: 0000000000000046 R12: 0000000000000008
R13: 000000000000006c R14: 0000000000000001 R15: ffffffff81668f90
FS:  00007f20be79b700(0000) GS:ffff8800bf200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f0428984000 CR3: 0000000012f19000 CR4: 00000000000007f0
Stack:
 ffff8800bf203b88 ffffffff81025de1 0000000080010002 ffffffff816692b0
 ffff8800bf203b98 ffffffff8126bc4f ffff8800bf203bc8 ffffffff8126c186
 ffff88003780c000 0000000000000001 0000000000000026 ffff88003780c001
Call Trace:
 <IRQ> 

 [<ffffffff81025de1>] arch_trigger_all_cpu_backtrace+0xa8/0xd2
 [<ffffffff8126bc4f>] sysrq_handle_showallcpus+0xe/0x10
 [<ffffffff8126c186>] __handle_sysrq+0x94/0x126
 [<ffffffff8126c329>] sysrq_filter+0xee/0x287
 [<ffffffff812c0fd8>] input_to_handler+0x5e/0xcb
 [<ffffffff812c1de2>] input_pass_values.part.3+0x76/0x134
 [<ffffffff812c3eae>] input_handle_event+0x457/0x46d
 [<ffffffff812c3f19>] input_event+0x55/0x6f
 [<ffffffff812c6fb5>] input_sync+0xf/0x11
 [<ffffffff812c7f47>] atkbd_interrupt+0x4d5/0x595
 [<ffffffff812bf2c3>] serio_interrupt+0x43/0x7d
 [<ffffffff812bfa2e>] i8042_interrupt+0x292/0x2a8
 [<ffffffff8108b64b>] ? tick_sched_do_timer+0x33/0x33
 [<ffffffff810729a6>] handle_irq_event_percpu+0x44/0x19f
 [<ffffffff81072b3d>] handle_irq_event+0x3c/0x5c
 [<ffffffff81025e49>] ? apic_eoi+0x18/0x1a
 [<ffffffff810752b2>] handle_edge_irq+0x95/0xae
 [<ffffffff81004679>] handle_irq+0x158/0x16d
 [<ffffffff8105683f>] ? get_parent_ip+0xe/0x3e
 [<ffffffff81003f71>] do_IRQ+0x58/0xda
 [<ffffffff813ba1ea>] common_interrupt+0x6a/0x6a
 <EOI> 

 [<ffffffff813b6b95>] ? preempt_schedule_irq+0x3c/0x59
 [<ffffffff810d75cc>] ? __zone_watermark_ok+0x7a/0x85
 [<ffffffff810d839e>] zone_watermark_ok+0x1a/0x1c
 [<ffffffff810ef3d7>] compact_zone+0x215/0x4b2
 [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
 [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
 [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
 [<ffffffff810da5c8>] __alloc_pages_nodemask+0x5f0/0x799
 [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
 [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
 [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
 [<ffffffff8111af2b>] ? new_sync_read+0x74/0x98
 [<ffffffff8111b2c3>] ? fsnotify_access+0x5a/0x63
 [<ffffffff8111b602>] ? vfs_read+0xac/0xd2
 [<ffffffff8111b1f9>] ? fdput_pos.isra.13+0x29/0x30
 [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
 [<ffffffff813bb162>] page_fault+0x22/0x30
Code: 48 ff c8 75 fb 48 ff c8 5d c3 55 48 89 e5 ff 15 a4 0c 48 00 5d c3 55 48 8d 04 bd 00 00 00 00 48 89 e5 65 48 8b 14 25 20 26 01 00 <48> 69 d2 fa 00 00 00 f7 e2 48 8d 7a 01 e8 cd ff ff ff 5d c3 48 
NMI backtrace for cpu 1
CPU: 1 PID: 7072 Comm: ps Not tainted 3.18.0-rc3+ #46
Hardware name: Acer            TravelMate 5720                /Columbia                       , BIOS V1.34           04/15/2008
task: ffff88000387c6e0 ti: ffff880059bcc000 task.ti: ffff880059bcc000
RIP: 0010:[<ffffffff81136da3>]  [<ffffffff81136da3>] seq_put_decimal_ull+0x46/0x72
RSP: 0018:ffff880059bcfce8  EFLAGS: 00000206
RAX: 00000000000000ad RBX: ffff880091097480 RCX: 00000000000000ae
RDX: 0000000000000030 RSI: 0000000000000020 RDI: ffff8800b0230000
RBP: ffff880059bcfcf8 R08: 000000000000000a R09: 00000000ffffffff
R10: ffffffff81136749 R11: ffffffff59bcfcb0 R12: ffff880080768000
R13: ffff8800ba205a40 R14: 0000000000000001 R15: 0000000000003d00
FS:  00007f042896a700(0000) GS:ffff8800bf300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000f0b018 CR3: 000000003abb8000 CR4: 00000000000007e0
Stack:
 00000000ffffffff ffff880091097480 ffff880059bcfe28 ffffffff8116d751
 ffff8800749e8480 0000000000800e06 5300880000000000 ffffffffffffffff
 0000000000000000 0000000000000000 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff8116d751>] do_task_stat+0x7cf/0x980
 [<ffffffff8116e12b>] proc_tgid_stat+0xf/0x11
 [<ffffffff81168d8a>] proc_single_show+0x4c/0x6e
 [<ffffffff81137069>] seq_read+0x163/0x330
 [<ffffffff8111b5d3>] vfs_read+0x7d/0xd2
 [<ffffffff811322c1>] ? __fdget_pos+0xd/0x3c
 [<ffffffff8111bc4c>] SyS_read+0x42/0x79
 [<ffffffff813b9752>] system_call_fastpath+0x12/0x17
Code: 0f 48 8b 0f 48 8d 78 01 48 89 7b 18 40 88 34 01 48 83 fa 09 48 8b 43 18 48 8b 3b 77 10 48 8d 48 01 83 c2 30 48 89 4b 18 88 14 07 <eb> 17 8b 73 08 48 01 c7 29 c6 e8 89 84 0a 00 85 c0 74 0a 48 98 
INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 76.962 msecs
SysRq : HELP : loglevel(0-9) reboot(b) crash(c) terminate-all-tasks(e) memory-full-oom-kill(f) kill-all-tasks(i) thaw-filesystems(j) sak(k) show-backtrace-all-active-cpus(l) show-memory-usage(m) nice-all-RT-tasks(n) poweroff(o) show-registers(p) show-all-timers(q) unraw(r) sync(s) show-task-states(t) unmount(u) force-fb(V) show-blocked-tasks(w) dump-ftrace-buffer(z) 
SysRq : Show backtrace of all active CPUs
sending NMI to all CPUs:
NMI backtrace for cpu 1
CPU: 1 PID: 7037 Comm: urpmq Not tainted 3.18.0-rc3+ #46
Hardware name: Acer            TravelMate 5720                /Columbia                       , BIOS V1.34           04/15/2008
task: ffff88000387de80 ti: ffff88007dddc000 task.ti: ffff88007dddc000
RIP: 0010:[<ffffffff810ef578>]  [<ffffffff810ef578>] compact_zone+0x3b6/0x4b2
RSP: 0000:ffff88007dddfa38  EFLAGS: 00000297
RAX: 00000000ffffffff RBX: ffffffff8168be40 RCX: 0000000000000008
RDX: 0000000000000800 RSI: 0000000000000009 RDI: ffffffff8168be40
RBP: ffff88007dddfa98 R08: 0000000000000000 R09: fffffffffffffef1
R10: 0000000000000038 R11: ffffffff8168be40 R12: 00000000000bf800
R13: 00000000000bf600 R14: ffff88007dddfab8 R15: 0000160000000000
FS:  00007f20be79b700(0000) GS:ffff8800bf300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f143453c000 CR3: 0000000012f19000 CR4: 00000000000007e0
Stack:
 ffff8800bf312e80 ffffea0002fd0000 0000000000000020 ffff88000387de80
 0000000000000004 ffff88007dddfac8 0000000000000000 0000000000000000
 0000000000000009 ffff88007dddfcec 0000000000000002 0000000000000000
Call Trace:
 [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
 [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
 [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
 [<ffffffff810da5c8>] __alloc_pages_nodemask+0x5f0/0x799
 [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
 [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
 [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
 [<ffffffff8111af2b>] ? new_sync_read+0x74/0x98
 [<ffffffff8111b2c3>] ? fsnotify_access+0x5a/0x63
 [<ffffffff8111b602>] ? vfs_read+0xac/0xd2
 [<ffffffff8111b1f9>] ? fdput_pos.isra.13+0x29/0x30
 [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
 [<ffffffff813bb162>] page_fault+0x22/0x30
Code: 00 48 8b 1d 9b 2e 5a 00 48 85 db 74 9e 48 8b 7b 08 44 89 e6 ff 13 48 83 c3 10 48 83 3b 00 eb eb 41 83 7e 40 01 4d 8b 6e 38 19 c0 <89> 45 c0 4d 8d a5 00 02 00 00 83 65 c0 04 49 81 e4 00 fe ff ff 
NMI backtrace for cpu 0
CPU: 0 PID: 7356 Comm: kwin Not tainted 3.18.0-rc3+ #46
Hardware name: Acer            TravelMate 5720                /Columbia                       , BIOS V1.34           04/15/2008
task: ffff8800b8c23f00 ti: ffff88009b1f8000 task.ti: ffff88009b1f8000
RIP: 0010:[<ffffffff811df861>]  [<ffffffff811df861>] delay_tsc+0x1/0xa2
RSP: 0000:ffff8800bf203b48  EFLAGS: 00000807
RAX: 0000000026e004c0 RBX: 0000000000002710 RCX: 0000000000000007
RDX: 00000000001859f9 RSI: 0000000000000c00 RDI: 00000000001859fa
RBP: ffff8800bf203b58 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000046 R11: 0000000000000046 R12: 0000000000000008
R13: 000000000000006c R14: 0000000000000001 R15: ffffffff81668f90
FS:  00007f445c0f17c0(0000) GS:ffff8800bf200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000003a5b1d8 CR3: 00000000a6d15000 CR4: 00000000000007f0
Stack:
 ffff8800bf203b58 ffffffff811df814 ffff8800bf203b68 ffffffff811df83d
 ffff8800bf203b88 ffffffff81025de1 0000000080010002 ffffffff816692b0
 ffff8800bf203b98 ffffffff8126bc4f ffff8800bf203bc8 ffffffff8126c186
Call Trace:
 <IRQ> 

 [<ffffffff811df814>] ? __delay+0xa/0xc
 [<ffffffff811df83d>] __const_udelay+0x27/0x29
 [<ffffffff81025de1>] arch_trigger_all_cpu_backtrace+0xa8/0xd2
 [<ffffffff8126bc4f>] sysrq_handle_showallcpus+0xe/0x10
 [<ffffffff8126c186>] __handle_sysrq+0x94/0x126
 [<ffffffff8126c329>] sysrq_filter+0xee/0x287
 [<ffffffff812c0fd8>] input_to_handler+0x5e/0xcb
 [<ffffffff812c1de2>] input_pass_values.part.3+0x76/0x134
 [<ffffffff812c3eae>] input_handle_event+0x457/0x46d
 [<ffffffff812c3f19>] input_event+0x55/0x6f
 [<ffffffff812c6fb5>] input_sync+0xf/0x11
 [<ffffffff812c7f47>] atkbd_interrupt+0x4d5/0x595
 [<ffffffff812bf2c3>] serio_interrupt+0x43/0x7d
 [<ffffffff812bfa2e>] i8042_interrupt+0x292/0x2a8
 [<ffffffff8108b64b>] ? tick_sched_do_timer+0x33/0x33
 [<ffffffff810729a6>] handle_irq_event_percpu+0x44/0x19f
 [<ffffffff81072b3d>] handle_irq_event+0x3c/0x5c
 [<ffffffff81025e49>] ? apic_eoi+0x18/0x1a
 [<ffffffff810752b2>] handle_edge_irq+0x95/0xae
 [<ffffffff81004679>] handle_irq+0x158/0x16d
 [<ffffffff8105683f>] ? get_parent_ip+0xe/0x3e
 [<ffffffff81003f71>] do_IRQ+0x58/0xda
 [<ffffffff813ba1ea>] common_interrupt+0x6a/0x6a
 <EOI> 

 [<ffffffff810ef3d9>] ? compact_zone+0x217/0x4b2
 [<ffffffff810ef3d7>] ? compact_zone+0x215/0x4b2
 [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
 [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
 [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
 [<ffffffff810da3e1>] __alloc_pages_nodemask+0x409/0x799
 [<ffffffff810fdcba>] ? anon_vma_prepare+0x2b/0x12c
 [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
 [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
 [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
 [<ffffffff8105ca95>] ? set_next_entity+0x3a/0x63
 [<ffffffff811e952e>] ? debug_smp_processor_id+0x17/0x19
 [<ffffffff810017c3>] ? __switch_to+0x33f/0x49c
 [<ffffffff813b9028>] ? _raw_spin_unlock_irq+0x14/0x27
 [<ffffffff811e952e>] ? debug_smp_processor_id+0x17/0x19
 [<ffffffff813b66d1>] ? __schedule+0x2d9/0x451
 [<ffffffff810f9997>] ? SyS_mmap_pgoff+0x183/0x1cf
 [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
 [<ffffffff813bb162>] page_fault+0x22/0x30
Code: 7a 01 e8 cd ff ff ff 5d c3 48 69 ff c7 10 00 00 55 48 89 e5 e8 c7 ff ff ff 5d c3 55 48 8d 3c bf 48 89 e5 e8 b8 ff ff ff 5d c3 55 <48> 89 e5 41 56 41 55 41 54 41 89 fc bf 01 00 00 00 53 e8 f7 6f 
INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 182.694 msecs
SysRq : Show backtrace of all active CPUs
sending NMI to all CPUs:
NMI backtrace for cpu 1
CPU: 1 PID: 7037 Comm: urpmq Not tainted 3.18.0-rc3+ #46
Hardware name: Acer            TravelMate 5720                /Columbia                       , BIOS V1.34           04/15/2008
task: ffff88000387de80 ti: ffff88007dddc000 task.ti: ffff88007dddc000
RIP: 0010:[<ffffffff810d75c9>]  [<ffffffff810d75c9>] __zone_watermark_ok+0x77/0x85
RSP: 0000:ffff88007dddfa10  EFLAGS: 00000212
RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000001
RDX: 000000000000057c RSI: 0000000000000009 RDI: ffffffff8168be40
RBP: ffff88007dddfa18 R08: 0000000000000000 R09: 000000000000ca1f
R10: 0000000000001c5b R11: ffffffff8168be40 R12: 00000000000bf800
R13: 00000000000bf600 R14: ffff88007dddfab8 R15: 0000160000000000
FS:  00007f20be79b700(0000) GS:ffff8800bf300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f143453c000 CR3: 0000000012f19000 CR4: 00000000000007e0
Stack:
 ffffffff8168be40 ffff88007dddfa28 ffffffff810d839e ffff88007dddfa98
 ffffffff810ef3d7 ffff8800bf312e80 ffffea0002fd0000 0000000000000020
 ffff88000387de80 0000000000000004 ffff88007dddfac8 0000000000000000
Call Trace:
 [<ffffffff810d839e>] zone_watermark_ok+0x1a/0x1c
 [<ffffffff810ef3d7>] compact_zone+0x215/0x4b2
 [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
 [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
 [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
 [<ffffffff810da5c8>] __alloc_pages_nodemask+0x5f0/0x799
 [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
 [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
 [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
 [<ffffffff8111af2b>] ? new_sync_read+0x74/0x98
 [<ffffffff8111b2c3>] ? fsnotify_access+0x5a/0x63
 [<ffffffff8111b602>] ? vfs_read+0xac/0xd2
 [<ffffffff8111b1f9>] ? fdput_pos.isra.13+0x29/0x30
 [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
 [<ffffffff813bb162>] page_fault+0x22/0x30
Code: d2 31 c0 31 c9 48 03 54 df 18 49 39 d1 7e 27 39 ce 76 21 48 6b d1 58 49 d1 fa 48 8b 94 17 28 01 00 00 48 d3 e2 48 ff c1 49 29 d1 <4d> 39 d1 7f df 31 c0 eb 02 b0 01 5b 5d c3 49 b9 13 da 4b 68 2f 
NMI backtrace for cpu 0
CPU: 0 PID: 7356 Comm: kwin Not tainted 3.18.0-rc3+ #46
Hardware name: Acer            TravelMate 5720                /Columbia                       , BIOS V1.34           04/15/2008
task: ffff8800b8c23f00 ti: ffff88009b1f8000 task.ti: ffff88009b1f8000
RIP: 0010:[<ffffffff811df86a>]  [<ffffffff811df86a>] delay_tsc+0xa/0xa2
RSP: 0000:ffff8800bf203b30  EFLAGS: 00000807
RAX: 0000000026e004c0 RBX: 0000000000002710 RCX: 0000000000000007
RDX: 00000000001859f9 RSI: 0000000000000c00 RDI: 00000000001859fa
RBP: ffff8800bf203b48 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000046 R11: 0000000000000046 R12: 0000000000000008
R13: 000000000000006c R14: 0000000000000001 R15: ffffffff81668f90
FS:  00007f445c0f17c0(0000) GS:ffff8800bf200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000003a5b1d8 CR3: 00000000a6d15000 CR4: 00000000000007f0
Stack:
 0000000000000008 000000000000006c 0000000000000001 ffff8800bf203b58
 ffffffff811df814 ffff8800bf203b68 ffffffff811df83d ffff8800bf203b88
 ffffffff81025de1 0000000080010002 ffffffff816692b0 ffff8800bf203b98
Call Trace:
 <IRQ> 

 [<ffffffff811df814>] __delay+0xa/0xc
 [<ffffffff811df83d>] __const_udelay+0x27/0x29
 [<ffffffff81025de1>] arch_trigger_all_cpu_backtrace+0xa8/0xd2
 [<ffffffff8126bc4f>] sysrq_handle_showallcpus+0xe/0x10
 [<ffffffff8126c186>] __handle_sysrq+0x94/0x126
 [<ffffffff8126c329>] sysrq_filter+0xee/0x287
 [<ffffffff812c0fd8>] input_to_handler+0x5e/0xcb
 [<ffffffff812c1de2>] input_pass_values.part.3+0x76/0x134
 [<ffffffff812c3eae>] input_handle_event+0x457/0x46d
 [<ffffffff812c3f19>] input_event+0x55/0x6f
 [<ffffffff812c6fb5>] input_sync+0xf/0x11
 [<ffffffff812c7f47>] atkbd_interrupt+0x4d5/0x595
 [<ffffffff812bf2c3>] serio_interrupt+0x43/0x7d
 [<ffffffff812bfa2e>] i8042_interrupt+0x292/0x2a8
 [<ffffffff8108b64b>] ? tick_sched_do_timer+0x33/0x33
 [<ffffffff810729a6>] handle_irq_event_percpu+0x44/0x19f
 [<ffffffff81072b3d>] handle_irq_event+0x3c/0x5c
 [<ffffffff81025e49>] ? apic_eoi+0x18/0x1a
 [<ffffffff810752b2>] handle_edge_irq+0x95/0xae
 [<ffffffff81004679>] handle_irq+0x158/0x16d
 [<ffffffff8105683f>] ? get_parent_ip+0xe/0x3e
 [<ffffffff81003f71>] do_IRQ+0x58/0xda
 [<ffffffff813ba1ea>] common_interrupt+0x6a/0x6a
 <EOI> 

 [<ffffffff810d839e>] ? zone_watermark_ok+0x1a/0x1c
 [<ffffffff810d839e>] ? zone_watermark_ok+0x1a/0x1c
 [<ffffffff810ef3d7>] compact_zone+0x215/0x4b2
 [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
 [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
 [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
 [<ffffffff810da3e1>] __alloc_pages_nodemask+0x409/0x799
 [<ffffffff810fdcba>] ? anon_vma_prepare+0x2b/0x12c
 [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
 [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
 [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
 [<ffffffff8105ca95>] ? set_next_entity+0x3a/0x63
 [<ffffffff811e952e>] ? debug_smp_processor_id+0x17/0x19
 [<ffffffff810017c3>] ? __switch_to+0x33f/0x49c
 [<ffffffff813b9028>] ? _raw_spin_unlock_irq+0x14/0x27
 [<ffffffff811e952e>] ? debug_smp_processor_id+0x17/0x19
 [<ffffffff813b66d1>] ? __schedule+0x2d9/0x451
 [<ffffffff810f9997>] ? SyS_mmap_pgoff+0x183/0x1cf
 [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
 [<ffffffff813bb162>] page_fault+0x22/0x30
Code: 48 69 ff c7 10 00 00 55 48 89 e5 e8 c7 ff ff ff 5d c3 55 48 8d 3c bf 48 89 e5 e8 b8 ff ff ff 5d c3 55 48 89 e5 41 56 41 55 41 54 <41> 89 fc bf 01 00 00 00 53 e8 f7 6f e7 ff e8 9a 9c 00 00 41 89 
SysRq : Show backtrace of all active CPUs
sending NMI to all CPUs:
NMI backtrace for cpu 1
CPU: 1 PID: 7037 Comm: urpmq Not tainted 3.18.0-rc3+ #46
Hardware name: Acer            TravelMate 5720                /Columbia                       , BIOS V1.34           04/15/2008
task: ffff88000387de80 ti: ffff88007dddc000 task.ti: ffff88007dddc000
RIP: 0010:[<ffffffff8105686f>]  [<ffffffff8105686f>] preempt_count_add+0x0/0x8b
RSP: 0000:ffff8800bf303b20  EFLAGS: 00000807
RAX: 0000000026e004c0 RBX: 0000000000002710 RCX: 0000000000000007
RDX: 00000000001859f9 RSI: 0000000000000c00 RDI: 0000000000000001
RBP: ffff8800bf303b48 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000046 R11: 0000000000000046 R12: 00000000001859fa
R13: 000000000000006c R14: 0000000000000001 R15: ffffffff81668f90
FS:  00007f20be79b700(0000) GS:ffff8800bf300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f143453c000 CR3: 0000000012f19000 CR4: 00000000000007e0
Stack:
 ffffffff811df878 0000000000002710 0000000000000008 000000000000006c
 0000000000000001 ffff8800bf303b58 ffffffff811df814 ffff8800bf303b68
 ffffffff811df83d ffff8800bf303b88 ffffffff81025de1 0000000080010002
Call Trace:
 <IRQ> 

 [<ffffffff811df878>] ? delay_tsc+0x18/0xa2
 [<ffffffff811df814>] __delay+0xa/0xc
 [<ffffffff811df83d>] __const_udelay+0x27/0x29
 [<ffffffff81025de1>] arch_trigger_all_cpu_backtrace+0xa8/0xd2
 [<ffffffff8126bc4f>] sysrq_handle_showallcpus+0xe/0x10
 [<ffffffff8126c186>] __handle_sysrq+0x94/0x126
 [<ffffffff8126c329>] sysrq_filter+0xee/0x287
 [<ffffffff812c0fd8>] input_to_handler+0x5e/0xcb
 [<ffffffff812c1de2>] input_pass_values.part.3+0x76/0x134
 [<ffffffff812c3eae>] input_handle_event+0x457/0x46d
 [<ffffffff812c3f19>] input_event+0x55/0x6f
 [<ffffffff812c6fb5>] input_sync+0xf/0x11
 [<ffffffff812c7f47>] atkbd_interrupt+0x4d5/0x595
 [<ffffffff812bf2c3>] serio_interrupt+0x43/0x7d
 [<ffffffff812bfa2e>] i8042_interrupt+0x292/0x2a8
 [<ffffffff8108b64b>] ? tick_sched_do_timer+0x33/0x33
 [<ffffffff810729a6>] handle_irq_event_percpu+0x44/0x19f
 [<ffffffff81072b3d>] handle_irq_event+0x3c/0x5c
 [<ffffffff81025e49>] ? apic_eoi+0x18/0x1a
 [<ffffffff810752b2>] handle_edge_irq+0x95/0xae
 [<ffffffff81004679>] handle_irq+0x158/0x16d
 [<ffffffff8105683f>] ? get_parent_ip+0xe/0x3e
 [<ffffffff81003f71>] do_IRQ+0x58/0xda
 [<ffffffff813ba1ea>] common_interrupt+0x6a/0x6a
 <EOI> 

 [<ffffffff813b6b95>] ? preempt_schedule_irq+0x3c/0x59
 [<ffffffff810d75b8>] ? __zone_watermark_ok+0x66/0x85
 [<ffffffff810d839e>] zone_watermark_ok+0x1a/0x1c
 [<ffffffff810ef3d7>] compact_zone+0x215/0x4b2
 [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
 [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
 [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
 [<ffffffff810da5c8>] __alloc_pages_nodemask+0x5f0/0x799
 [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
 [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
 [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
 [<ffffffff8111af2b>] ? new_sync_read+0x74/0x98
 [<ffffffff8111b2c3>] ? fsnotify_access+0x5a/0x63
 [<ffffffff8111b602>] ? vfs_read+0xac/0xd2
 [<ffffffff8111b1f9>] ? fdput_pos.isra.13+0x29/0x30
 [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
 [<ffffffff813bb162>] page_fault+0x22/0x30
Code: 8b 45 00 48 8b 00 48 8b 58 08 48 89 df e8 15 f4 00 00 85 c0 74 0e 48 8b 45 00 48 8b 00 48 8b 00 48 8b 58 08 5a 48 89 d8 5b 5d c3 <55> 48 89 e5 53 89 fb 41 50 65 01 3c 25 90 b8 00 00 83 3d c1 3d 
NMI backtrace for cpu 0
CPU: 0 PID: 7356 Comm: kwin Not tainted 3.18.0-rc3+ #46
Hardware name: Acer            TravelMate 5720                /Columbia                       , BIOS V1.34           04/15/2008
task: ffff8800b8c23f00 ti: ffff88009b1f8000 task.ti: ffff88009b1f8000
RIP: 0010:[<ffffffff810ef3bc>]  [<ffffffff810ef3bc>] compact_zone+0x1fa/0x4b2
RSP: 0000:ffff88009b1fba38  EFLAGS: 00000217
RAX: 00000000000bf600 RBX: ffffffff8168be40 RCX: ffff88009b1fba09
RDX: 0000000000000000 RSI: 0000000000000009 RDI: ffff8800b8c23f00
RBP: ffff88009b1fba98 R08: 0000000000000000 R09: fffffffffffffefb
R10: 0000000000000038 R11: ffffffff8168be40 R12: 00000000000bf800
R13: 00000000000bf600 R14: ffff88009b1fbab8 R15: 0000160000000000
FS:  00007f445c0f17c0(0000) GS:ffff8800bf200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000003a5b1d8 CR3: 00000000a6d15000 CR4: 00000000000007f0
Stack:
 ffff8800354be660 ffffea0002fd0000 0000000000000020 ffff8800b8c23f00
 0000000000000004 ffff88009b1fbac8 ffff8800a6d1a800 0000000000000000
 0000000000000009 ffff88009b1fbcec 0000000000000002 0000000000000000
Call Trace:
 [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
 [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
 [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
 [<ffffffff810da3e1>] __alloc_pages_nodemask+0x409/0x799
 [<ffffffff810fdcba>] ? anon_vma_prepare+0x2b/0x12c
 [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
 [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
 [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
 [<ffffffff8105ca95>] ? set_next_entity+0x3a/0x63
 [<ffffffff811e952e>] ? debug_smp_processor_id+0x17/0x19
 [<ffffffff810017c3>] ? __switch_to+0x33f/0x49c
 [<ffffffff813b9028>] ? _raw_spin_unlock_irq+0x14/0x27
 [<ffffffff811e952e>] ? debug_smp_processor_id+0x17/0x19
 [<ffffffff813b66d1>] ? __schedule+0x2d9/0x451
 [<ffffffff810f9997>] ? SyS_mmap_pgoff+0x183/0x1cf
 [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
 [<ffffffff813bb162>] page_fault+0x22/0x30
Code: 00 48 8b 45 b8 f6 40 16 04 0f 85 3e 01 00 00 c6 83 7c 05 00 00 01 e9 32 01 00 00 41 8b 76 48 83 fe ff 0f 84 b4 01 00 00 40 88 f1 <ba> 01 00 00 00 45 31 c0 d3 e2 48 89 df 31 c9 48 63 d2 48 03 53 
SysRq : Show backtrace of all active CPUs
sending NMI to all CPUs:
NMI backtrace for cpu 1
CPU: 1 PID: 7037 Comm: urpmq Not tainted 3.18.0-rc3+ #46
Hardware name: Acer            TravelMate 5720                /Columbia                       , BIOS V1.34           04/15/2008
task: ffff88000387de80 ti: ffff88007dddc000 task.ti: ffff88007dddc000
RIP: 0010:[<ffffffff811df82b>]  [<ffffffff811df82b>] __const_udelay+0x15/0x29
RSP: 0000:ffff8800bf303b68  EFLAGS: 00000006
RAX: 0000000001062560 RBX: 0000000000002710 RCX: 0000000000000007
RDX: 00000000001859ed RSI: 0000000000000c00 RDI: 0000000000418958
RBP: ffff8800bf303b68 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000046 R11: 0000000000000046 R12: 0000000000000008
R13: 000000000000006c R14: 0000000000000001 R15: ffffffff81668f90
FS:  00007f20be79b700(0000) GS:ffff8800bf300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f143453c000 CR3: 0000000012f19000 CR4: 00000000000007e0
Stack:
 ffff8800bf303b88 ffffffff81025de1 0000000080010002 ffffffff816692b0
 ffff8800bf303b98 ffffffff8126bc4f ffff8800bf303bc8 ffffffff8126c186
 ffff88003780c000 0000000000000001 0000000000000026 ffff88003780c001
Call Trace:
 <IRQ> 

 [<ffffffff81025de1>] arch_trigger_all_cpu_backtrace+0xa8/0xd2
 [<ffffffff8126bc4f>] sysrq_handle_showallcpus+0xe/0x10
 [<ffffffff8126c186>] __handle_sysrq+0x94/0x126
 [<ffffffff8126c329>] sysrq_filter+0xee/0x287
 [<ffffffff812c0fd8>] input_to_handler+0x5e/0xcb
 [<ffffffff812c1de2>] input_pass_values.part.3+0x76/0x134
 [<ffffffff812c3eae>] input_handle_event+0x457/0x46d
 [<ffffffff812c3f19>] input_event+0x55/0x6f
 [<ffffffff812c6fb5>] input_sync+0xf/0x11
 [<ffffffff812c7f47>] atkbd_interrupt+0x4d5/0x595
 [<ffffffff812bf2c3>] serio_interrupt+0x43/0x7d
 [<ffffffff812bfa2e>] i8042_interrupt+0x292/0x2a8
 [<ffffffff8108b64b>] ? tick_sched_do_timer+0x33/0x33
 [<ffffffff810729a6>] handle_irq_event_percpu+0x44/0x19f
 [<ffffffff81072b3d>] handle_irq_event+0x3c/0x5c
 [<ffffffff81025e49>] ? apic_eoi+0x18/0x1a
 [<ffffffff810752b2>] handle_edge_irq+0x95/0xae
 [<ffffffff81004679>] handle_irq+0x158/0x16d
 [<ffffffff8105683f>] ? get_parent_ip+0xe/0x3e
 [<ffffffff81003f71>] do_IRQ+0x58/0xda
 [<ffffffff813ba1ea>] common_interrupt+0x6a/0x6a
 <EOI> 

 [<ffffffff810d75c0>] ? __zone_watermark_ok+0x6e/0x85
 [<ffffffff810d839e>] zone_watermark_ok+0x1a/0x1c
 [<ffffffff810ef3d7>] compact_zone+0x215/0x4b2
 [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
 [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
 [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
 [<ffffffff810da5c8>] __alloc_pages_nodemask+0x5f0/0x799
 [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
 [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
 [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
 [<ffffffff8111af2b>] ? new_sync_read+0x74/0x98
 [<ffffffff8111b2c3>] ? fsnotify_access+0x5a/0x63
 [<ffffffff8111b602>] ? vfs_read+0xac/0xd2
 [<ffffffff8111b1f9>] ? fdput_pos.isra.13+0x29/0x30
 [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
 [<ffffffff813bb162>] page_fault+0x22/0x30
Code: 48 ff c8 75 fb 48 ff c8 5d c3 55 48 89 e5 ff 15 a4 0c 48 00 5d c3 55 48 8d 04 bd 00 00 00 00 48 89 e5 65 48 8b 14 25 20 26 01 00 <48> 69 d2 fa 00 00 00 f7 e2 48 8d 7a 01 e8 cd ff ff ff 5d c3 48 
NMI backtrace for cpu 0
CPU: 0 PID: 7356 Comm: kwin Not tainted 3.18.0-rc3+ #46
Hardware name: Acer            TravelMate 5720                /Columbia                       , BIOS V1.34           04/15/2008
task: ffff8800b8c23f00 ti: ffff88009b1f8000 task.ti: ffff88009b1f8000
RIP: 0010:[<ffffffff810d75af>]  [<ffffffff810d75af>] __zone_watermark_ok+0x5d/0x85
RSP: 0000:ffff88009b1fba10  EFLAGS: 00000202
RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000007
RDX: 0000000000000f00 RSI: 0000000000000009 RDI: ffffffff8168be40
RBP: ffff88009b1fba18 R08: 0000000000000000 R09: 00000000000006fd
R10: 0000000000000071 R11: ffffffff8168be40 R12: 00000000000bf800
R13: 00000000000bf600 R14: ffff88009b1fbab8 R15: 0000160000000000
FS:  00007f445c0f17c0(0000) GS:ffff8800bf200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f26fa192000 CR3: 00000000a6d15000 CR4: 00000000000007f0
Stack:
 ffffffff8168be40 ffff88009b1fba28 ffffffff810d839e ffff88009b1fba98
 ffffffff810ef3d7 ffff8800354be660 ffffea0002fd0000 0000000000000020
 ffff8800b8c23f00 0000000000000004 ffff88009b1fbac8 ffff8800a6d1a800
Call Trace:
 [<ffffffff810d839e>] zone_watermark_ok+0x1a/0x1c
 [<ffffffff810ef3d7>] compact_zone+0x215/0x4b2
 [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
 [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
 [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
 [<ffffffff810da3e1>] __alloc_pages_nodemask+0x409/0x799
 [<ffffffff810fdcba>] ? anon_vma_prepare+0x2b/0x12c
 [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
 [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
 [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
 [<ffffffff8105ca95>] ? set_next_entity+0x3a/0x63
 [<ffffffff811e952e>] ? debug_smp_processor_id+0x17/0x19
 [<ffffffff810017c3>] ? __switch_to+0x33f/0x49c
 [<ffffffff813b9028>] ? _raw_spin_unlock_irq+0x14/0x27
 [<ffffffff811e952e>] ? debug_smp_processor_id+0x17/0x19
 [<ffffffff813b66d1>] ? __schedule+0x2d9/0x451
 [<ffffffff810f9997>] ? SyS_mmap_pgoff+0x183/0x1cf
 [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
 [<ffffffff813bb162>] page_fault+0x22/0x30
Code: c2 41 80 e0 10 74 11 4c 89 d0 41 b8 04 00 00 00 48 99 49 f7 f8 49 29 c2 4c 89 d2 31 c0 31 c9 48 03 54 df 18 49 39 d1 7e 27 39 ce <76> 21 48 6b d1 58 49 d1 fa 48 8b 94 17 28 01 00 00 48 d3 e2 48 
SysRq : Show backtrace of all active CPUs
sending NMI to all CPUs:
NMI backtrace for cpu 0
CPU: 0 PID: 7356 Comm: kwin Not tainted 3.18.0-rc3+ #46
Hardware name: Acer            TravelMate 5720                /Columbia                       , BIOS V1.34           04/15/2008
task: ffff8800b8c23f00 ti: ffff88009b1f8000 task.ti: ffff88009b1f8000
RIP: 0010:[<ffffffff811df861>]  [<ffffffff811df861>] delay_tsc+0x1/0xa2
RSP: 0000:ffff8800bf203b48  EFLAGS: 00000807
RAX: 0000000026e004c0 RBX: 0000000000002710 RCX: 0000000000000007
RDX: 00000000001859f9 RSI: 0000000000000c00 RDI: 00000000001859fa
RBP: ffff8800bf203b58 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000046 R11: 0000000000000046 R12: 0000000000000008
R13: 000000000000006c R14: 0000000000000001 R15: ffffffff81668f90
FS:  00007f445c0f17c0(0000) GS:ffff8800bf200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007ffc189c5640 CR3: 00000000a6d15000 CR4: 00000000000007f0
Stack:
 ffff8800bf203b58 ffffffff811df814 ffff8800bf203b68 ffffffff811df83d
 ffff8800bf203b88 ffffffff81025de1 0000000080010002 ffffffff816692b0
 ffff8800bf203b98 ffffffff8126bc4f ffff8800bf203bc8 ffffffff8126c186
Call Trace:
 <IRQ> 

 [<ffffffff811df814>] ? __delay+0xa/0xc
 [<ffffffff811df83d>] __const_udelay+0x27/0x29
 [<ffffffff81025de1>] arch_trigger_all_cpu_backtrace+0xa8/0xd2
 [<ffffffff8126bc4f>] sysrq_handle_showallcpus+0xe/0x10
 [<ffffffff8126c186>] __handle_sysrq+0x94/0x126
 [<ffffffff8126c329>] sysrq_filter+0xee/0x287
 [<ffffffff812c0fd8>] input_to_handler+0x5e/0xcb
 [<ffffffff812c1de2>] input_pass_values.part.3+0x76/0x134
 [<ffffffff812c3eae>] input_handle_event+0x457/0x46d
 [<ffffffff812c3f19>] input_event+0x55/0x6f
 [<ffffffff812c6fb5>] input_sync+0xf/0x11
 [<ffffffff812c7f47>] atkbd_interrupt+0x4d5/0x595
 [<ffffffff812bf2c3>] serio_interrupt+0x43/0x7d
 [<ffffffff812bfa2e>] i8042_interrupt+0x292/0x2a8
 [<ffffffff8108b64b>] ? tick_sched_do_timer+0x33/0x33
 [<ffffffff810729a6>] handle_irq_event_percpu+0x44/0x19f
 [<ffffffff81072b3d>] handle_irq_event+0x3c/0x5c
 [<ffffffff81025e49>] ? apic_eoi+0x18/0x1a
 [<ffffffff810752b2>] handle_edge_irq+0x95/0xae
 [<ffffffff81004679>] handle_irq+0x158/0x16d
 [<ffffffff8105683f>] ? get_parent_ip+0xe/0x3e
 [<ffffffff81003f71>] do_IRQ+0x58/0xda
 [<ffffffff813ba1ea>] common_interrupt+0x6a/0x6a
 <EOI> 

 [<ffffffff813ba390>] ? retint_kernel+0x20/0x30
 [<ffffffff810d7569>] ? __zone_watermark_ok+0x17/0x85
 [<ffffffff810d839e>] zone_watermark_ok+0x1a/0x1c
 [<ffffffff810ef3d7>] compact_zone+0x215/0x4b2
 [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
 [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
 [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
 [<ffffffff810da3e1>] __alloc_pages_nodemask+0x409/0x799
 [<ffffffff810fdcba>] ? anon_vma_prepare+0x2b/0x12c
 [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
 [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
 [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
 [<ffffffff8105ca95>] ? set_next_entity+0x3a/0x63
 [<ffffffff811e952e>] ? debug_smp_processor_id+0x17/0x19
 [<ffffffff810017c3>] ? __switch_to+0x33f/0x49c
 [<ffffffff813b9028>] ? _raw_spin_unlock_irq+0x14/0x27
 [<ffffffff811e952e>] ? debug_smp_processor_id+0x17/0x19
 [<ffffffff813b66d1>] ? __schedule+0x2d9/0x451
 [<ffffffff810f9997>] ? SyS_mmap_pgoff+0x183/0x1cf
 [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
 [<ffffffff813bb162>] page_fault+0x22/0x30
Code: 7a 01 e8 cd ff ff ff 5d c3 48 69 ff c7 10 00 00 55 48 89 e5 e8 c7 ff ff ff 5d c3 55 48 8d 3c bf 48 89 e5 e8 b8 ff ff ff 5d c3 55 <48> 89 e5 41 56 41 55 41 54 41 89 fc bf 01 00 00 00 53 e8 f7 6f 
NMI backtrace for cpu 1
CPU: 1 PID: 7037 Comm: urpmq Not tainted 3.18.0-rc3+ #46
Hardware name: Acer            TravelMate 5720                /Columbia                       , BIOS V1.34           04/15/2008
task: ffff88000387de80 ti: ffff88007dddc000 task.ti: ffff88007dddc000
RIP: 0010:[<ffffffff810d75af>]  [<ffffffff810d75af>] __zone_watermark_ok+0x5d/0x85
RSP: 0000:ffff88007dddfa10  EFLAGS: 00000202
RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000007
RDX: 0000000000000f00 RSI: 0000000000000009 RDI: ffffffff8168be40
RBP: ffff88007dddfa18 R08: 0000000000000000 R09: 0000000000000701
R10: 0000000000000071 R11: ffffffff8168be40 R12: 00000000000bf800
R13: 00000000000bf600 R14: ffff88007dddfab8 R15: 0000160000000000
FS:  00007f20be79b700(0000) GS:ffff8800bf300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f143453c000 CR3: 0000000012f19000 CR4: 00000000000007e0
Stack:
 ffffffff8168be40 ffff88007dddfa28 ffffffff810d839e ffff88007dddfa98
 ffffffff810ef3d7 ffff8800bf312e80 ffffea0002fd0000 0000000000000020
 ffff88000387de80 0000000000000004 ffff88007dddfac8 0000000000000000
Call Trace:
 [<ffffffff810d839e>] zone_watermark_ok+0x1a/0x1c
 [<ffffffff810ef3d7>] compact_zone+0x215/0x4b2
 [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
 [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
 [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
 [<ffffffff810da5c8>] __alloc_pages_nodemask+0x5f0/0x799
 [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
 [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
 [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
 [<ffffffff8111af2b>] ? new_sync_read+0x74/0x98
 [<ffffffff8111b2c3>] ? fsnotify_access+0x5a/0x63
 [<ffffffff8111b602>] ? vfs_read+0xac/0xd2
 [<ffffffff8111b1f9>] ? fdput_pos.isra.13+0x29/0x30
 [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
 [<ffffffff813bb162>] page_fault+0x22/0x30
Code: c2 41 80 e0 10 74 11 4c 89 d0 41 b8 04 00 00 00 48 99 49 f7 f8 49 29 c2 4c 89 d2 31 c0 31 c9 48 03 54 df 18 49 39 d1 7e 27 39 ce <76> 21 48 6b d1 58 49 d1 fa 48 8b 94 17 28 01 00 00 48 d3 e2 48 
SysRq : Show backtrace of all active CPUs
sending NMI to all CPUs:
NMI backtrace for cpu 0
CPU: 0 PID: 7037 Comm: urpmq Not tainted 3.18.0-rc3+ #46
Hardware name: Acer            TravelMate 5720                /Columbia                       , BIOS V1.34           04/15/2008
task: ffff88000387de80 ti: ffff88007dddc000 task.ti: ffff88007dddc000
RIP: 0010:[<ffffffff811df82b>]  [<ffffffff811df82b>] __const_udelay+0x15/0x29
RSP: 0000:ffff8800bf203b68  EFLAGS: 00000006
RAX: 0000000001062560 RBX: 0000000000002710 RCX: 0000000000000007
RDX: 00000000001859ed RSI: 0000000000000c00 RDI: 0000000000418958
RBP: ffff8800bf203b68 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000046 R11: 0000000000000046 R12: 0000000000000008
R13: 000000000000006c R14: 0000000000000001 R15: ffffffff81668f90
FS:  00007f20be79b700(0000) GS:ffff8800bf200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007faaeda2a000 CR3: 0000000012f19000 CR4: 00000000000007f0
Stack:
 ffff8800bf203b88 ffffffff81025de1 0000000080010002 ffffffff816692b0
 ffff8800bf203b98 ffffffff8126bc4f ffff8800bf203bc8 ffffffff8126c186
 ffff88003780c000 0000000000000001 0000000000000026 ffff88003780c001
Call Trace:
 <IRQ> 

 [<ffffffff81025de1>] arch_trigger_all_cpu_backtrace+0xa8/0xd2
 [<ffffffff8126bc4f>] sysrq_handle_showallcpus+0xe/0x10
 [<ffffffff8126c186>] __handle_sysrq+0x94/0x126
 [<ffffffff8126c329>] sysrq_filter+0xee/0x287
 [<ffffffff812c0fd8>] input_to_handler+0x5e/0xcb
 [<ffffffff812c1de2>] input_pass_values.part.3+0x76/0x134
 [<ffffffff812c3eae>] input_handle_event+0x457/0x46d
 [<ffffffff812c3f19>] input_event+0x55/0x6f
 [<ffffffff812c6fb5>] input_sync+0xf/0x11
 [<ffffffff812c7f47>] atkbd_interrupt+0x4d5/0x595
 [<ffffffff812bf2c3>] serio_interrupt+0x43/0x7d
 [<ffffffff812bfa2e>] i8042_interrupt+0x292/0x2a8
 [<ffffffff8108b64b>] ? tick_sched_do_timer+0x33/0x33
 [<ffffffff810729a6>] handle_irq_event_percpu+0x44/0x19f
 [<ffffffff81072b3d>] handle_irq_event+0x3c/0x5c
 [<ffffffff81025e49>] ? apic_eoi+0x18/0x1a
 [<ffffffff810752b2>] handle_edge_irq+0x95/0xae
 [<ffffffff81004679>] handle_irq+0x158/0x16d
 [<ffffffff8105683f>] ? get_parent_ip+0xe/0x3e
 [<ffffffff81003f71>] do_IRQ+0x58/0xda
 [<ffffffff813ba1ea>] common_interrupt+0x6a/0x6a
 <EOI> 

 [<ffffffff810ef3d7>] ? compact_zone+0x215/0x4b2
 [<ffffffff810ef3d7>] ? compact_zone+0x215/0x4b2
 [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
 [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
 [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
 [<ffffffff810da5c8>] __alloc_pages_nodemask+0x5f0/0x799
 [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
 [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
 [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
 [<ffffffff8111af2b>] ? new_sync_read+0x74/0x98
 [<ffffffff8111b2c3>] ? fsnotify_access+0x5a/0x63
 [<ffffffff8111b602>] ? vfs_read+0xac/0xd2
 [<ffffffff8111b1f9>] ? fdput_pos.isra.13+0x29/0x30
 [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
 [<ffffffff813bb162>] page_fault+0x22/0x30
Code: 48 ff c8 75 fb 48 ff c8 5d c3 55 48 89 e5 ff 15 a4 0c 48 00 5d c3 55 48 8d 04 bd 00 00 00 00 48 89 e5 65 48 8b 14 25 20 26 01 00 <48> 69 d2 fa 00 00 00 f7 e2 48 8d 7a 01 e8 cd ff ff ff 5d c3 48 
NMI backtrace for cpu 1
CPU: 1 PID: 7356 Comm: kwin Not tainted 3.18.0-rc3+ #46
Hardware name: Acer            TravelMate 5720                /Columbia                       , BIOS V1.34           04/15/2008
task: ffff8800b8c23f00 ti: ffff88009b1f8000 task.ti: ffff88009b1f8000
RIP: 0010:[<ffffffff810ef3d9>]  [<ffffffff810ef3d9>] compact_zone+0x217/0x4b2
RSP: 0000:ffff88009b1fba38  EFLAGS: 00000246
RAX: 0000000000000000 RBX: ffffffff8168be40 RCX: 0000000000000008
RDX: 0000000000000800 RSI: 0000000000000009 RDI: ffffffff8168be40
RBP: ffff88009b1fba98 R08: 0000000000000000 R09: ffffffffffffff01
R10: 0000000000000038 R11: ffffffff8168be40 R12: 00000000000bf800
R13: 00000000000bf600 R14: ffff88009b1fbab8 R15: 0000160000000000
FS:  00007f445c0f17c0(0000) GS:ffff8800bf300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000003a5b1d8 CR3: 00000000a6d15000 CR4: 00000000000007e0
Stack:
 ffff8800354be660 ffffea0002fd0000 0000000000000020 ffff8800b8c23f00
 0000000000000004 ffff88009b1fbac8 ffff8800a6d1a800 0000000000000000
 0000000000000009 ffff88009b1fbcec 0000000000000002 0000000000000000
Call Trace:
 [<ffffffff810ef6c0>] compact_zone_order+0x4c/0x5f
 [<ffffffff810ef87f>] try_to_compact_pages+0xc4/0x1d6
 [<ffffffff813b3118>] __alloc_pages_direct_compact+0x61/0x1bf
 [<ffffffff810da3e1>] __alloc_pages_nodemask+0x409/0x799
 [<ffffffff810fdcba>] ? anon_vma_prepare+0x2b/0x12c
 [<ffffffff811163bb>] do_huge_pmd_anonymous_page+0x13c/0x255
 [<ffffffff810f65bd>] handle_mm_fault+0x112/0x808
 [<ffffffff8102dced>] __do_page_fault+0x27a/0x358
 [<ffffffff8105ca95>] ? set_next_entity+0x3a/0x63
 [<ffffffff811e952e>] ? debug_smp_processor_id+0x17/0x19
 [<ffffffff810017c3>] ? __switch_to+0x33f/0x49c
 [<ffffffff813b9028>] ? _raw_spin_unlock_irq+0x14/0x27
 [<ffffffff811e952e>] ? debug_smp_processor_id+0x17/0x19
 [<ffffffff813b66d1>] ? __schedule+0x2d9/0x451
 [<ffffffff810f9997>] ? SyS_mmap_pgoff+0x183/0x1cf
 [<ffffffff8102ddf8>] do_page_fault+0xc/0xe
 [<ffffffff813bb162>] page_fault+0x22/0x30
Code: 76 48 83 fe ff 0f 84 b4 01 00 00 40 88 f1 ba 01 00 00 00 45 31 c0 d3 e2 48 89 df 31 c9 48 63 d2 48 03 53 08 e8 ad 8f fe ff 84 c0 <0f> 84 8e 01 00 00 41 8b 56 48 89 d0 83 f8 0a 0f 87 7f 01 00 00 

--nextPart3106412.5RfoaVLMj1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
