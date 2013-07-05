Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 428376B0033
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 16:39:59 -0400 (EDT)
Date: Fri, 5 Jul 2013 16:39:45 -0400
From: Dave Jones <davej@redhat.com>
Subject: Trying to vfree() bad address (e7eb1d38)
Message-ID: <20130705203945.GA17481@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

Fired up a 32bit box for nostalgia sake.  Pretty much instantly after
starting up my fuzzer, I see vmalloc exhaustion and then vmap corruption.
(Search below for WARNING to get to the interesting part)

It's been a while since I tried 32-bit fuzzing, so it may be a change in trinity
that's affected this (I just changed some code that mmap's zeropage a few times
at various sizes on startup, so maybe that's what's eaten up all the vmap space)

[  275.415399] vmap allocation for size 28672 failed: use vmalloc=<size> to increase size.
[  275.415503] vmalloc: allocation failure: 24576 bytes
[  275.415516] trinity-child38: page allocation failure: order:0, mode:0xd2
[  275.415531] CPU: 1 PID: 1184 Comm: trinity-child38 Not tainted 3.10.0+ #8 
[  275.415554] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  275.415571]  00000000 00000000 eb435bc4 c15a5a5c 00000001 eb435bec c1115c42 c1748de8
[  275.415612]  ece0aecc 00000000 000000d2 eb435c00 c174a828 eb435bdc 00006000 eb435c18
[  275.415651]  c1142b75 000000d2 00000000 c174a828 00006000 eb435c2c c109a9c4 ffbfe000
[  275.415692] Call Trace:
[  275.415709]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  275.415723]  [<c1115c42>] warn_alloc_failed+0xbf/0xf2
[  275.415740]  [<c1142b75>] __vmalloc_node_range+0x15d/0x1bd
[  275.415756]  [<c109a9c4>] ? lock_release_holdtime.part.30+0x8b/0xd4
[  275.415772]  [<c1142c33>] __vmalloc_node+0x5e/0x66
[  275.415786]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  275.415800]  [<c1142df3>] vmalloc+0x38/0x3a
[  275.415813]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  275.415826]  [<c11b39d1>] elf_core_dump+0x9d4/0x165c
[  275.415838]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  275.415852]  [<c1099f35>] ? trace_hardirqs_off+0xb/0xd
[  275.415866]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  275.415882]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  275.415897]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  275.415910]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.415923]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.415936]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  275.415974]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  275.415991]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  275.416006]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.416019]  [<c100111f>] do_signal+0x3a/0x864
[  275.416031]  [<c1099f90>] ? get_lock_stats+0x1b/0x43
[  275.416044]  [<c109a51a>] ? put_lock_stats.isra.29+0xd/0x24
[  275.416058]  [<c109a9c4>] ? lock_release_holdtime.part.30+0x8b/0xd4
[  275.416073]  [<c11a50a4>] ? fsnotify+0x247/0x552
[  275.416086]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  275.416099]  [<c116a29d>] ? vfs_write+0x150/0x19c
[  275.416112]  [<c116a29d>] ? vfs_write+0x150/0x19c
[  275.416126]  [<c15ae584>] ? work_notifysig+0x11/0x31
[  275.416139]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.416437]  [<c109ce92>] ? trace_hardirqs_on_caller+0xea/0x1b4
[  275.416724]  [<c116a846>] ? SyS_write+0x49/0x81
[  275.417180]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.417873]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  275.418538]  [<c15ae59c>] work_notifysig+0x29/0x31
[  275.433592] Mem-Info:
[  275.433865] DMA per-cpu:
[  275.434119] CPU    0: hi:    0, btch:   1 usd:   0
[  275.434428] CPU    1: hi:    0, btch:   1 usd:   0
[  275.435029] CPU    2: hi:    0, btch:   1 usd:   0
[  275.435611] CPU    3: hi:    0, btch:   1 usd:   0
[  275.436181] Normal per-cpu:
[  275.436730] CPU    0: hi:  186, btch:  31 usd: 175
[  275.445735] vmap allocation for size 28672 failed: use vmalloc=<size> to increase size.
[  275.446027] vmalloc: allocation failure: 24576 bytes
[  275.446268] trinity-child60: page allocation failure: order:0, mode:0xd2
[  275.446509] CPU: 3 PID: 1246 Comm: trinity-child60 Not tainted 3.10.0+ #8 
[  275.446919] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  275.447494]  00000000 00000000 e64ebbc4 c15a5a5c 00000001 e64ebbec c1115c42 c1748de8
[  275.448091]  e7675a8c 00000000 000000d2 e64ebc00 c174a828 e64ebbdc 00006000 e64ebc18
[  275.448708]  c1142b75 000000d2 00000000 c174a828 00006000 e64ebc2c c109a9c4 ffbfe000
[  275.449326] Call Trace:
[  275.449934]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  275.450591]  [<c1115c42>] warn_alloc_failed+0xbf/0xf2
[  275.451136]  [<c1142b75>] __vmalloc_node_range+0x15d/0x1bd
[  275.451733]  [<c109a9c4>] ? lock_release_holdtime.part.30+0x8b/0xd4
[  275.452344]  [<c1142c33>] __vmalloc_node+0x5e/0x66
[  275.452955]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  275.453569]  [<c1142df3>] vmalloc+0x38/0x3a
[  275.454175]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  275.454792]  [<c11b39d1>] elf_core_dump+0x9d4/0x165c
[  275.455408]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  275.456010]  [<c1099f35>] ? trace_hardirqs_off+0xb/0xd
[  275.456631]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  275.457253]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  275.457875]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  275.458496]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.459108]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.459718]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  275.460345]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  275.460937]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  275.461552]  [<c113273e>] ? might_fault+0x94/0x9a
[  275.462164]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.462779]  [<c100111f>] do_signal+0x3a/0x864
[  275.463389]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.464011]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  275.464637]  [<c15ae59c>] work_notifysig+0x29/0x31
[  275.477785] Mem-Info:
[  275.478068] DMA per-cpu:
[  275.478331] CPU    0: hi:    0, btch:   1 usd:   0
[  275.478608] CPU    1: hi:    0, btch:   1 usd:   0
[  275.479218] CPU    2: hi:    0, btch:   1 usd:   0
[  275.481633] CPU    3: hi:    0, btch:   1 usd:   0
[  275.481942] Normal per-cpu:
[  275.482201] CPU    0: hi:  186, btch:  31 usd: 181
[  275.482269] CPU    1: hi:  186, btch:  31 usd:  20
[  275.482271] CPU    2: hi:  186, btch:  31 usd: 169
[  275.482273] CPU    3: hi:  186, btch:  31 usd: 172
[  275.482274] HighMem per-cpu:
[  275.482275] CPU    0: hi:  186, btch:  31 usd: 145
[  275.482276] CPU    1: hi:  186, btch:  31 usd:  36
[  275.482278] CPU    2: hi:  186, btch:  31 usd:  23
[  275.482279] CPU    3: hi:  186, btch:  31 usd:  39
[  275.482284] active_anon:40991 inactive_anon:87 isolated_anon:0
 active_file:6312 inactive_file:831636 isolated_file:0
 unevictable:10 dirty:282 writeback:342 unstable:0
 free:1077864 slab_reclaimable:63433 slab_unreclaimable:13217
 mapped:6678 shmem:3609 pagetables:1190 bounce:273
 free_cma:0
[  275.482290] DMA free:15912kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15912kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.482294] lowmem_reserve[]: 0 757 8055 8055
[  275.482300] Normal free:423956kB min:38508kB low:48132kB high:57760kB active_anon:0kB inactive_anon:0kB active_file:460kB inactive_file:1016kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:897016kB managed:775440kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:253732kB slab_unreclaimable:52868kB kernel_stack:2096kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.482303] lowmem_reserve[]: 0 0 58384 58384
[  275.482309] HighMem free:3871588kB min:512kB low:93292kB high:186076kB active_anon:163964kB inactive_anon:348kB active_file:24788kB inactive_file:3325528kB unevictable:40kB isolated(anon):0kB isolated(file):0kB present:7473200kB managed:7473200kB mlocked:40kB dirty:1128kB writeback:1368kB mapped:26708kB shmem:14436kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:4760kB unstable:0kB bounce:3355464kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.482313] lowmem_reserve[]: 0 0 0 0
[  275.482329] DMA: 0*4kB 1*8kB (U) 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15912kB
[  275.482346] Normal: 138*4kB (UM) 150*8kB (UEM) 225*16kB (UEM) 139*32kB (UEM) 70*64kB (UEM) 38*128kB (UEM) 26*256kB (UEM) 22*512kB (UEM) 14*1024kB (UEM) 6*2048kB (UEM) 88*4096kB (MR) = 424136kB
[  275.482361] HighMem: 1*4kB (M) 3*8kB (U) 5*16kB (UM) 4*32kB (UM) 0*64kB 0*128kB 0*256kB 3*512kB (UM) 1*1024kB (M) 1*2048kB (M) 944*4096kB (MR) = 3871468kB
[  275.482364] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  275.482365] 841760 total pagecache pages
[  275.482367] 0 pages in swap cache
[  275.482368] Swap cache stats: add 0, delete 0, find 0/0
[  275.482369] Free swap  = 16383996kB
[  275.482370] Total swap = 16383996kB
[  275.494119] vmap allocation for size 28672 failed: use vmalloc=<size> to increase size.
[  275.494167] vmalloc: allocation failure: 24576 bytes
[  275.494169] trinity-child56: page allocation failure: order:0, mode:0xd2
[  275.494177] CPU: 0 PID: 1199 Comm: trinity-child56 Not tainted 3.10.0+ #8 
[  275.494179] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  275.494187]  00000000 00000000 e7e59bc4 c15a5a5c 00000001 e7e59bec c1115c42 c1748de8
[  275.494193]  eafb18ec 00000000 000000d2 e7e59c00 c174a828 e7e59bdc 00006000 e7e59c18
[  275.494198]  c1142b75 000000d2 00000000 c174a828 00006000 e7e59c2c c109a9c4 ffbfe000
[  275.494200] Call Trace:
[  275.494210]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  275.494215]  [<c1115c42>] warn_alloc_failed+0xbf/0xf2
[  275.494221]  [<c1142b75>] __vmalloc_node_range+0x15d/0x1bd
[  275.494227]  [<c109a9c4>] ? lock_release_holdtime.part.30+0x8b/0xd4
[  275.494230]  [<c1142c33>] __vmalloc_node+0x5e/0x66
[  275.494235]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  275.494239]  [<c1142df3>] vmalloc+0x38/0x3a
[  275.494241]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  275.494244]  [<c11b39d1>] elf_core_dump+0x9d4/0x165c
[  275.494247]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  275.494251]  [<c1099f35>] ? trace_hardirqs_off+0xb/0xd
[  275.494255]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  275.494260]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  275.494264]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  275.494267]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.494270]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.494273]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  275.494277]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  275.494282]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  275.494285]  [<c113273e>] ? might_fault+0x94/0x9a
[  275.494289]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.494293]  [<c100111f>] do_signal+0x3a/0x864
[  275.494302]  [<f8f0e8e0>] ? tg3_phy_reset+0x13c/0x9ee [tg3]
[  275.494310]  [<f8f0e8e0>] ? tg3_phy_reset+0x13c/0x9ee [tg3]
[  275.494316]  [<f8f0e8e0>] ? tg3_phy_reset+0x13c/0x9ee [tg3]
[  275.494319]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.494322]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  275.494326]  [<c15ae59c>] work_notifysig+0x29/0x31
[  275.494328] Mem-Info:
[  275.494329] DMA per-cpu:
[  275.494331] CPU    0: hi:    0, btch:   1 usd:   0
[  275.494333] CPU    1: hi:    0, btch:   1 usd:   0
[  275.494334] CPU    2: hi:    0, btch:   1 usd:   0
[  275.494335] CPU    3: hi:    0, btch:   1 usd:   0
[  275.494336] Normal per-cpu:
[  275.494338] CPU    0: hi:  186, btch:  31 usd: 180
[  275.494339] CPU    1: hi:  186, btch:  31 usd:  20
[  275.494341] CPU    2: hi:  186, btch:  31 usd: 166
[  275.494342] CPU    3: hi:  186, btch:  31 usd: 172
[  275.494343] HighMem per-cpu:
[  275.494344] CPU    0: hi:  186, btch:  31 usd: 136
[  275.494345] CPU    1: hi:  186, btch:  31 usd:  36
[  275.494346] CPU    2: hi:  186, btch:  31 usd:  37
[  275.494348] CPU    3: hi:  186, btch:  31 usd:  39
[  275.494352] active_anon:40991 inactive_anon:87 isolated_anon:0
 active_file:6312 inactive_file:831722 isolated_file:0
 unevictable:10 dirty:346 writeback:342 unstable:0
 free:1077802 slab_reclaimable:63433 slab_unreclaimable:13217
 mapped:6678 shmem:3609 pagetables:1190 bounce:273
 free_cma:0
[  275.494358] DMA free:15912kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15912kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.494362] lowmem_reserve[]: 0 757 8055 8055
[  275.494368] Normal free:423956kB min:38508kB low:48132kB high:57760kB active_anon:0kB inactive_anon:0kB active_file:460kB inactive_file:1016kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:897016kB managed:775440kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:253732kB slab_unreclaimable:52868kB kernel_stack:2096kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.494371] lowmem_reserve[]: 0 0 58384 58384
[  275.494377] HighMem free:3871340kB min:512kB low:93292kB high:186076kB active_anon:163964kB inactive_anon:348kB active_file:24788kB inactive_file:3325872kB unevictable:40kB isolated(anon):0kB isolated(file):0kB present:7473200kB managed:7473200kB mlocked:40kB dirty:1384kB writeback:1368kB mapped:26708kB shmem:14436kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:4760kB unstable:0kB bounce:3355464kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.494381] lowmem_reserve[]: 0 0 0 0
[  275.494397] DMA: 0*4kB 1*8kB (U) 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15912kB
[  275.494414] Normal: 158*4kB (UM) 150*8kB (UEM) 224*16kB (UM) 139*32kB (UEM) 69*64kB (UM) 38*128kB (UEM) 26*256kB (UEM) 22*512kB (UEM) 14*1024kB (UEM) 6*2048kB (UEM) 88*4096kB (MR) = 424136kB
[  275.494429] HighMem: 0*4kB 3*8kB (U) 4*16kB (U) 3*32kB (U) 1*64kB (M) 1*128kB (M) 0*256kB 2*512kB (UM) 1*1024kB (M) 1*2048kB (M) 944*4096kB (MR) = 3871096kB
[  275.494432] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  275.494433] 841824 total pagecache pages
[  275.494436] 0 pages in swap cache
[  275.494437] Swap cache stats: add 0, delete 0, find 0/0
[  275.494438] Free swap  = 16383996kB
[  275.494439] Total swap = 16383996kB
[  275.563440] vmap allocation for size 28672 failed: use vmalloc=<size> to increase size.
[  275.563478] vmalloc: allocation failure: 24576 bytes
[  275.563480] trinity-child53: page allocation failure: order:0, mode:0xd2
[  275.563488] CPU: 0 PID: 1249 Comm: trinity-child53 Not tainted 3.10.0+ #8 
[  275.563490] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  275.563497]  00000000 00000000 e7eb1bc4 c15a5a5c 00000001 e7eb1bec c1115c42 c1748de8
[  275.563503]  e7e1830c 00000000 000000d2 e7eb1c00 c174a828 e7eb1bdc 00006000 e7eb1c18
[  275.563508]  c1142b75 000000d2 00000000 c174a828 00006000 e7eb1c2c c109a9c4 ffbfe000
[  275.563509] Call Trace:
[  275.563518]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  275.563523]  [<c1115c42>] warn_alloc_failed+0xbf/0xf2
[  275.563529]  [<c1142b75>] __vmalloc_node_range+0x15d/0x1bd
[  275.563534]  [<c109a9c4>] ? lock_release_holdtime.part.30+0x8b/0xd4
[  275.563537]  [<c1142c33>] __vmalloc_node+0x5e/0x66
[  275.563542]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  275.563545]  [<c1142df3>] vmalloc+0x38/0x3a
[  275.563548]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  275.563551]  [<c11b39d1>] elf_core_dump+0x9d4/0x165c
[  275.563553]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  275.563557]  [<c1099f35>] ? trace_hardirqs_off+0xb/0xd
[  275.563561]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  275.563566]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  275.563570]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  275.563573]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.563576]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.563579]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  275.563583]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  275.563587]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  275.563590]  [<c1099f35>] ? trace_hardirqs_off+0xb/0xd
[  275.563593]  [<c1099f90>] ? get_lock_stats+0x1b/0x43
[  275.563597]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.563600]  [<c100111f>] do_signal+0x3a/0x864
[  275.563604]  [<c15a0dd7>] ? bad_area+0x28/0x42
[  275.563608]  [<c113273e>] ? might_fault+0x94/0x9a
[  275.563612]  [<c15ae584>] ? work_notifysig+0x11/0x31
[  275.563614]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.563618]  [<c109ce92>] ? trace_hardirqs_on_caller+0xea/0x1b4
[  275.563621]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.563623]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  275.563626]  [<c15ae59c>] work_notifysig+0x29/0x31
[  275.563628] Mem-Info:
[  275.563629] DMA per-cpu:
[  275.563631] CPU    0: hi:    0, btch:   1 usd:   0
[  275.563633] CPU    1: hi:    0, btch:   1 usd:   0
[  275.563634] CPU    2: hi:    0, btch:   1 usd:   0
[  275.563635] CPU    3: hi:    0, btch:   1 usd:   0
[  275.563636] Normal per-cpu:
[  275.563637] CPU    0: hi:  186, btch:  31 usd: 180
[  275.563639] CPU    1: hi:  186, btch:  31 usd:  19
[  275.563640] CPU    2: hi:  186, btch:  31 usd: 187
[  275.563641] CPU    3: hi:  186, btch:  31 usd: 172
[  275.563642] HighMem per-cpu:
[  275.563644] CPU    0: hi:  186, btch:  31 usd: 116
[  275.563645] CPU    1: hi:  186, btch:  31 usd:  38
[  275.563646] CPU    2: hi:  186, btch:  31 usd:  42
[  275.563647] CPU    3: hi:  186, btch:  31 usd:  39
[  275.563652] active_anon:41120 inactive_anon:87 isolated_anon:0
 active_file:6312 inactive_file:831851 isolated_file:0
 unevictable:10 dirty:410 writeback:470 unstable:0
 free:1077372 slab_reclaimable:63459 slab_unreclaimable:13217
 mapped:6678 shmem:3609 pagetables:1190 bounce:401
 free_cma:0
[  275.563658] DMA free:15912kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15912kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.563662] lowmem_reserve[]: 0 757 8055 8055
[  275.563668] Normal free:423476kB min:38508kB low:48132kB high:57760kB active_anon:0kB inactive_anon:0kB active_file:460kB inactive_file:1016kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:897016kB managed:775440kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:253836kB slab_unreclaimable:52868kB kernel_stack:2096kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.563671] lowmem_reserve[]: 0 0 58384 58384
[  275.563677] HighMem free:3870100kB min:512kB low:93292kB high:186076kB active_anon:164480kB inactive_anon:348kB active_file:24788kB inactive_file:3326388kB unevictable:40kB isolated(anon):0kB isolated(file):0kB present:7473200kB managed:7473200kB mlocked:40kB dirty:1640kB writeback:1880kB mapped:26708kB shmem:14436kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:4760kB unstable:0kB bounce:3355976kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.563680] lowmem_reserve[]: 0 0 0 0
[  275.563697] DMA: 0*4kB 1*8kB (U) 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15912kB
[  275.563714] Normal: 35*4kB (UEM) 149*8kB (UM) 224*16kB (UM) 138*32kB (UM) 69*64kB (UM) 37*128kB (UM) 26*256kB (UEM) 22*512kB (UEM) 14*1024kB (UEM) 6*2048kB (UEM) 88*4096kB (MR) = 423476kB
[  275.563729] HighMem: 0*4kB 4*8kB (UM) 4*16kB (U) 4*32kB (UM) 1*64kB (M) 1*128kB (M) 1*256kB (M) 1*512kB (U) 0*1024kB 1*2048kB (M) 944*4096kB (MR) = 3869856kB
[  275.563731] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  275.563732] 841952 total pagecache pages
[  275.563734] 0 pages in swap cache
[  275.563735] Swap cache stats: add 0, delete 0, find 0/0
[  275.563736] Free swap  = 16383996kB
[  275.563737] Total swap = 16383996kB
[  275.608433] vmap allocation for size 28672 failed: use vmalloc=<size> to increase size.
[  275.608470] vmalloc: allocation failure: 24576 bytes
[  275.608472] trinity-child17: page allocation failure: order:0, mode:0xd2
[  275.608480] CPU: 0 PID: 1298 Comm: trinity-child17 Not tainted 3.10.0+ #8 
[  275.608482] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  275.608489]  00000000 00000000 e75d9bc4 c15a5a5c 00000001 e75d9bec c1115c42 c1748de8
[  275.608495]  e76e98ec 00000000 000000d2 e75d9c00 c174a828 e75d9bdc 00006000 e75d9c18
[  275.608500]  c1142b75 000000d2 00000000 c174a828 00006000 e75d9c2c c109a9c4 ffbfe000
[  275.608501] Call Trace:
[  275.608511]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  275.608515]  [<c1115c42>] warn_alloc_failed+0xbf/0xf2
[  275.608521]  [<c1142b75>] __vmalloc_node_range+0x15d/0x1bd
[  275.608526]  [<c109a9c4>] ? lock_release_holdtime.part.30+0x8b/0xd4
[  275.608530]  [<c1142c33>] __vmalloc_node+0x5e/0x66
[  275.608534]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  275.608537]  [<c1142df3>] vmalloc+0x38/0x3a
[  275.608540]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  275.608543]  [<c11b39d1>] elf_core_dump+0x9d4/0x165c
[  275.608546]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  275.608549]  [<c1099f35>] ? trace_hardirqs_off+0xb/0xd
[  275.608554]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  275.608558]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  275.608563]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  275.608566]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.608569]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.608572]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  275.608576]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  275.608580]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  275.608583]  [<c113273e>] ? might_fault+0x94/0x9a
[  275.608587]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.608590]  [<c100111f>] do_signal+0x3a/0x864
[  275.608595]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.608597]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  275.608601]  [<c15ae59c>] work_notifysig+0x29/0x31
[  275.608603] Mem-Info:
[  275.608604] DMA per-cpu:
[  275.608606] CPU    0: hi:    0, btch:   1 usd:   0
[  275.608608] CPU    1: hi:    0, btch:   1 usd:   0
[  275.608609] CPU    2: hi:    0, btch:   1 usd:   0
[  275.608610] CPU    3: hi:    0, btch:   1 usd:   0
[  275.608611] Normal per-cpu:
[  275.608613] CPU    0: hi:  186, btch:  31 usd: 180
[  275.608614] CPU    1: hi:  186, btch:  31 usd:  19
[  275.608616] CPU    2: hi:  186, btch:  31 usd: 187
[  275.608617] CPU    3: hi:  186, btch:  31 usd: 172
[  275.608618] HighMem per-cpu:
[  275.608619] CPU    0: hi:  186, btch:  31 usd:  25
[  275.608620] CPU    1: hi:  186, btch:  31 usd:  38
[  275.608621] CPU    2: hi:  186, btch:  31 usd:  42
[  275.608623] CPU    3: hi:  186, btch:  31 usd:  39
[  275.608627] active_anon:41335 inactive_anon:87 isolated_anon:0
 active_file:6312 inactive_file:831851 isolated_file:0
 unevictable:10 dirty:410 writeback:470 unstable:0
 free:1077249 slab_reclaimable:63459 slab_unreclaimable:13217
 mapped:6678 shmem:3609 pagetables:1190 bounce:401
 free_cma:0
[  275.608633] DMA free:15912kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15912kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.608637] lowmem_reserve[]: 0 757 8055 8055
[  275.608643] Normal free:423476kB min:38508kB low:48132kB high:57760kB active_anon:0kB inactive_anon:0kB active_file:460kB inactive_file:1016kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:897016kB managed:775440kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:253836kB slab_unreclaimable:52868kB kernel_stack:2096kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.608646] lowmem_reserve[]: 0 0 58384 58384
[  275.608652] HighMem free:3869608kB min:512kB low:93292kB high:186076kB active_anon:165340kB inactive_anon:348kB active_file:24788kB inactive_file:3326388kB unevictable:40kB isolated(anon):0kB isolated(file):0kB present:7473200kB managed:7473200kB mlocked:40kB dirty:1640kB writeback:1880kB mapped:26708kB shmem:14436kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:4760kB unstable:0kB bounce:3355976kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.608656] lowmem_reserve[]: 0 0 0 0
[  275.608672] DMA: 0*4kB 1*8kB (U) 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15912kB
[  275.608689] Normal: 35*4kB (UEM) 149*8kB (UM) 224*16kB (UM) 138*32kB (UM) 69*64kB (UM) 37*128kB (UM) 26*256kB (UEM) 22*512kB (UEM) 14*1024kB (UEM) 6*2048kB (UEM) 88*4096kB (MR) = 423476kB
[  275.608704] HighMem: 0*4kB 4*8kB (UM) 5*16kB (UM) 4*32kB (UM) 1*64kB (M) 1*128kB (M) 1*256kB (M) 2*512kB (UM) 1*1024kB (M) 0*2048kB 944*4096kB (MR) = 3869360kB
[  275.608706] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  275.608707] 841952 total pagecache pages
[  275.608709] 0 pages in swap cache
[  275.608711] Swap cache stats: add 0, delete 0, find 0/0
[  275.608711] Free swap  = 16383996kB
[  275.608712] Total swap = 16383996kB
[  275.711340] 2162687 pages RAM
[  275.712170] 1934338 pages HighMem
[  275.713075] 96549 pages reserved
[  275.713977] 1994110 pages shared
[  275.714884] 179400 pages non-shared
[  275.716380] 2162687 pages RAM
[  275.716713] 1934338 pages HighMem
[  275.717597] 96549 pages reserved
[  275.719435] 1994013 pages shared
[  275.719763] 179242 pages non-shared


Here's where it gets really interesting..


[  275.719794] ------------[ cut here ]------------
[  275.719805] WARNING: at mm/vmalloc.c:1456 __vunmap.isra.27+0x38/0x3a()
[  275.719806] Trying to vfree() bad address (e7eb1d38)
[  275.719833] Modules linked in: nfsv3 nfs_acl nfs lockd sunrpc fscache nouveau video mxm_wmi wmi i2c_algo_bit ttm drm_kms_helper iTCO_wdt drm iTCO_vendor_support lpc_ich ppdev mfd_core tg3 serio_raw i2c_i801 dcdbas ptp pcspkr pps_core i2c_core parport_pc shpchp i5k_amb parport xfs libcrc32c raid0 floppy
[  275.719840] CPU: 1 PID: 1249 Comm: trinity-child53 Not tainted 3.10.0+ #8 
[  275.719842] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  275.719848]  c174da5b 00000000 e7eb1bf4 c15a5a5c e7eb1c2c e7eb1c1c c1038105 c174a778
[  275.719854]  e7eb1c48 000005b0 c114039d c114039d e7eb1d38 00000006 eae28dd0 e7eb1c34
[  275.719859]  c103814f 00000009 e7eb1c2c c174a778 e7eb1c48 e7eb1c4c c114039d c174da5b
[  275.719860] Call Trace:
[  275.719867]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  275.719872]  [<c1038105>] warn_slowpath_common+0x5e/0x75
[  275.719875]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  275.719878]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  275.719881]  [<c103814f>] warn_slowpath_fmt+0x33/0x35
[  275.719884]  [<c114039d>] __vunmap.isra.27+0x38/0x3a
[  275.719887]  [<c11403f5>] vfree+0x30/0x70
[  275.719891]  [<c11b3fdc>] elf_core_dump+0xfdf/0x165c
[  275.719894]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  275.719899]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  275.719904]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  275.719908]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  275.719911]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.719914]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.719917]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  275.719923]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  275.719927]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  275.719930]  [<c1099f35>] ? trace_hardirqs_off+0xb/0xd
[  275.719943]  [<c1099f90>] ? get_lock_stats+0x1b/0x43
[  275.719947]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.719951]  [<c100111f>] do_signal+0x3a/0x864
[  275.719956]  [<c15a0dd7>] ? bad_area+0x28/0x42
[  275.719960]  [<c113273e>] ? might_fault+0x94/0x9a
[  275.719964]  [<c15ae584>] ? work_notifysig+0x11/0x31
[  275.719967]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.719976]  [<c109ce92>] ? trace_hardirqs_on_caller+0xea/0x1b4
[  275.719982]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.719987]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  275.719993]  [<c15ae59c>] work_notifysig+0x29/0x31
[  275.724760] ---[ end trace 657cf3c64f8d54d6 ]---
[  275.727511] 2162687 pages RAM
[  275.727512] 1934338 pages HighMem
[  275.727513] 96549 pages reserved
[  275.727514] 1994131 pages shared
[  275.727515] 179610 pages non-shared
[  275.731380] ------------[ cut here ]------------
[  275.731390] WARNING: at mm/vmalloc.c:1456 __vunmap.isra.27+0x38/0x3a()
[  275.731391] Trying to vfree() bad address (e75d9d38)
[  275.731419] Modules linked in: nfsv3 nfs_acl nfs lockd sunrpc fscache nouveau video mxm_wmi wmi i2c_algo_bit ttm drm_kms_helper iTCO_wdt drm iTCO_vendor_support lpc_ich ppdev mfd_core tg3 serio_raw i2c_i801 dcdbas ptp pcspkr pps_core i2c_core parport_pc shpchp i5k_amb parport xfs libcrc32c raid0 floppy
[  275.731426] CPU: 0 PID: 1298 Comm: trinity-child17 Tainted: G        W    3.10.0+ #8 
[  275.731428] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  275.731435]  c174da5b 00000000 e75d9bf4 c15a5a5c e75d9c2c e75d9c1c c1038105 c174a778
[  275.731441]  e75d9c48 000005b0 c114039d c114039d e75d9d38 00000006 e5390710 e75d9c34
[  275.731446]  c103814f 00000009 e75d9c2c c174a778 e75d9c48 e75d9c4c c114039d c174da5b
[  275.731447] Call Trace:
[  275.731455]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  275.731460]  [<c1038105>] warn_slowpath_common+0x5e/0x75
[  275.731464]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  275.731467]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  275.731470]  [<c103814f>] warn_slowpath_fmt+0x33/0x35
[  275.731473]  [<c114039d>] __vunmap.isra.27+0x38/0x3a
[  275.731476]  [<c11403f5>] vfree+0x30/0x70
[  275.731481]  [<c11b3fdc>] elf_core_dump+0xfdf/0x165c
[  275.731484]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  275.731490]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  275.731496]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  275.731502]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  275.731507]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.731510]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.731513]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  275.731519]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  275.731525]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  275.731528]  [<c113273e>] ? might_fault+0x94/0x9a
[  275.731533]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.731537]  [<c100111f>] do_signal+0x3a/0x864
[  275.731541]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.731543]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  275.731547]  [<c15ae59c>] work_notifysig+0x29/0x31
[  275.731549] ---[ end trace 657cf3c64f8d54d7 ]---
[  275.736295] vmap allocation for size 28672 failed: use vmalloc=<size> to increase size.
[  275.736330] vmalloc: allocation failure: 24576 bytes
[  275.736332] trinity-child43: page allocation failure: order:0, mode:0xd2
[  275.736340] CPU: 1 PID: 1240 Comm: trinity-child43 Tainted: G        W    3.10.0+ #8 
[  275.736341] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  275.736349]  00000000 00000000 e82b1bc4 c15a5a5c 00000001 e82b1bec c1115c42 c1748de8
[  275.736355]  e6b55a8c 00000000 000000d2 e82b1c00 c174a828 e82b1bdc 00006000 e82b1c18
[  275.736360]  c1142b75 000000d2 00000000 c174a828 00006000 e82b1c2c c109a9c4 ffbfe000
[  275.736361] Call Trace:
[  275.736369]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  275.736373]  [<c1115c42>] warn_alloc_failed+0xbf/0xf2
[  275.736378]  [<c1142b75>] __vmalloc_node_range+0x15d/0x1bd
[  275.736384]  [<c109a9c4>] ? lock_release_holdtime.part.30+0x8b/0xd4
[  275.736387]  [<c1142c33>] __vmalloc_node+0x5e/0x66
[  275.736391]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  275.736394]  [<c1142df3>] vmalloc+0x38/0x3a
[  275.736397]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  275.736400]  [<c11b39d1>] elf_core_dump+0x9d4/0x165c
[  275.736403]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  275.736406]  [<c1099f35>] ? trace_hardirqs_off+0xb/0xd
[  275.736410]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  275.736414]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  275.736419]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  275.736421]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.736424]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.736427]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  275.736431]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  275.736436]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  275.736439]  [<c113273e>] ? might_fault+0x94/0x9a
[  275.736443]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.736446]  [<c100111f>] do_signal+0x3a/0x864
[  275.736450]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.736452]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  275.736456]  [<c15ae59c>] work_notifysig+0x29/0x31
[  275.736458] Mem-Info:
[  275.736460] DMA per-cpu:
[  275.736462] CPU    0: hi:    0, btch:   1 usd:   0
[  275.736463] CPU    1: hi:    0, btch:   1 usd:   0
[  275.736464] CPU    2: hi:    0, btch:   1 usd:   0
[  275.736465] CPU    3: hi:    0, btch:   1 usd:   0
[  275.736466] Normal per-cpu:
[  275.736468] CPU    0: hi:  186, btch:  31 usd: 184
[  275.736470] CPU    1: hi:  186, btch:  31 usd:  55
[  275.736471] CPU    2: hi:  186, btch:  31 usd: 166
[  275.736473] CPU    3: hi:  186, btch:  31 usd: 177
[  275.736473] HighMem per-cpu:
[  275.736475] CPU    0: hi:  186, btch:  31 usd:  80
[  275.736476] CPU    1: hi:  186, btch:  31 usd:  75
[  275.736477] CPU    2: hi:  186, btch:  31 usd:  53
[  275.736478] CPU    3: hi:  186, btch:  31 usd:  39
[  275.736483] active_anon:41550 inactive_anon:87 isolated_anon:0
 active_file:6312 inactive_file:831894 isolated_file:0
 unevictable:10 dirty:410 writeback:278 unstable:0
 free:1077370 slab_reclaimable:63459 slab_unreclaimable:13217
 mapped:6678 shmem:3609 pagetables:1190 bounce:0
 free_cma:0
[  275.736489] DMA free:15912kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15912kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.736493] lowmem_reserve[]: 0 757 8055 8055
[  275.736499] Normal free:424952kB min:38508kB low:48132kB high:57760kB active_anon:0kB inactive_anon:0kB active_file:460kB inactive_file:1016kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:897016kB managed:775440kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:253836kB slab_unreclaimable:52868kB kernel_stack:2096kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.736502] lowmem_reserve[]: 0 0 58384 58384
[  275.736508] HighMem free:3868616kB min:512kB low:93292kB high:186076kB active_anon:166200kB inactive_anon:348kB active_file:24788kB inactive_file:3326560kB unevictable:40kB isolated(anon):0kB isolated(file):0kB present:7473200kB managed:7473200kB mlocked:40kB dirty:1640kB writeback:1112kB mapped:26708kB shmem:14436kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:4760kB unstable:0kB bounce:3355976kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.736512] lowmem_reserve[]: 0 0 0 0
[  275.736528] DMA: 0*4kB 1*8kB (U) 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15912kB
[  275.736545] Normal: 168*4kB (UM) 275*8kB (UM) 233*16kB (UEM) 141*32kB (UEM) 69*64kB (UM) 38*128kB (UEM) 25*256kB (UM) 22*512kB (UEM) 14*1024kB (UEM) 6*2048kB (UEM) 88*4096kB (MR) = 425128kB
[  275.736559] HighMem: 0*4kB 4*8kB (UM) 5*16kB (UM) 3*32kB (U) 0*64kB 0*128kB 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 944*4096kB (MR) = 3868368kB
[  275.736561] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  275.736562] 841952 total pagecache pages
[  275.736564] 0 pages in swap cache
[  275.736566] Swap cache stats: add 0, delete 0, find 0/0
[  275.736567] Free swap  = 16383996kB
[  275.736567] Total swap = 16383996kB
[  275.836283] 2162687 pages RAM
[  275.837151] 1934338 pages HighMem
[  275.860249] 96549 pages reserved
[  275.860668] 1993918 pages shared
[  275.861093] 179078 pages non-shared
[  275.864857] ------------[ cut here ]------------
[  275.865209] WARNING: at mm/vmalloc.c:1456 __vunmap.isra.27+0x38/0x3a()
[  275.865691] Trying to vfree() bad address (eb435d38)
[  275.867371] Modules linked in: nfsv3 nfs_acl nfs lockd sunrpc fscache nouveau video mxm_wmi wmi i2c_algo_bit ttm drm_kms_helper iTCO_wdt drm iTCO_vendor_support lpc_ich ppdev mfd_core tg3 serio_raw i2c_i801 dcdbas ptp pcspkr pps_core i2c_core parport_pc shpchp i5k_amb parport xfs libcrc32c raid0 floppy
[  275.869691] CPU: 1 PID: 1184 Comm: trinity-child38 Tainted: G        W    3.10.0+ #8 
[  275.870777] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  275.871790]  c174da5b 00000000 eb435bf4 c15a5a5c eb435c2c eb435c1c c1038105 c174a778
[  275.872878]  eb435c48 000005b0 c114039d c114039d eb435d38 00000006 e7f1c3b0 eb435c34
[  275.873988]  c103814f 00000009 eb435c2c c174a778 eb435c48 eb435c4c c114039d c174da5b
[  275.875099] Call Trace:
[  275.876200]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  275.877288]  [<c1038105>] warn_slowpath_common+0x5e/0x75
[  275.878375]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  275.879459]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  275.880548]  [<c103814f>] warn_slowpath_fmt+0x33/0x35
[  275.881578]  [<c114039d>] __vunmap.isra.27+0x38/0x3a
[  275.882608]  [<c11403f5>] vfree+0x30/0x70
[  275.883618]  [<c11b3fdc>] elf_core_dump+0xfdf/0x165c
[  275.884632]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  275.885584]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  275.886563]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  275.887453] CPU    1: hi:  186, btch:  31 usd:  52
[  275.887455] CPU    2: hi:  186, btch:  31 usd: 167
[  275.887456] CPU    3: hi:  186, btch:  31 usd: 207
[  275.887458] HighMem per-cpu:
[  275.887459] CPU    0: hi:  186, btch:  31 usd:  26
[  275.887461] CPU    1: hi:  186, btch:  31 usd:  57
[  275.887462] CPU    2: hi:  186, btch:  31 usd:  24
[  275.887463] CPU    3: hi:  186, btch:  31 usd:  31
[  275.887468] active_anon:41980 inactive_anon:87 isolated_anon:0
 active_file:6312 inactive_file:832582 isolated_file:0
 unevictable:10 dirty:1178 writeback:22 unstable:0
 free:1076275 slab_reclaimable:63509 slab_unreclaimable:13217
 mapped:6678 shmem:3609 pagetables:1190 bounce:0
 free_cma:0
[  275.887474] DMA free:15912kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15912kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.887479] lowmem_reserve[]: 0 757 8055 8055
[  275.887484] Normal free:425036kB min:38508kB low:48132kB high:57760kB active_anon:0kB inactive_anon:0kB active_file:460kB inactive_file:1016kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:897016kB managed:775440kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:254036kB slab_unreclaimable:52868kB kernel_stack:2096kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.887488] lowmem_reserve[]: 0 0 58384 58384
[  275.887494] HighMem free:3864152kB min:512kB low:93292kB high:186076kB active_anon:167920kB inactive_anon:348kB active_file:24788kB inactive_file:3329312kB unevictable:40kB isolated(anon):0kB isolated(file):0kB present:7473200kB managed:7473200kB mlocked:40kB dirty:4712kB writeback:88kB mapped:26708kB shmem:14436kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:4760kB unstable:0kB bounce:3355976kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  275.887516] lowmem_reserve[]: 0 0 0 0
[  275.887533] DMA: 0*4kB 1*8kB (U) 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15912kB
[  275.887550] Normal: 186*4kB (UM) 279*8kB (UM) 233*16kB (UEM) 140*32kB (UM) 70*64kB (UEM) 37*128kB (UM) 26*256kB (UEM) 21*512kB (UM) 14*1024kB (UEM) 6*2048kB (UEM) 88*4096kB (MR) = 424880kB
[  275.887565] HighMem: 19*4kB (U) 7*8kB (UM) 4*16kB (U) 3*32kB (U) 1*64kB (M) 1*128kB (M) 1*256kB (M) 1*512kB (U) 0*1024kB 0*2048kB 943*4096kB (MR) = 3863780kB
[  275.887567] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  275.887568] 842720 total pagecache pages
[  275.887571] 0 pages in swap cache
[  275.887572] Swap cache stats: add 0, delete 0, find 0/0
[  275.887573] Free swap  = 16383996kB
[  275.887574] Total swap = 16383996kB
[  275.888664] vmap allocation for size 28672 failed: use vmalloc=<size> to increase size.
[  275.888708] vmalloc: allocation failure: 24576 bytes
[  275.888710] trinity-child5: page allocation failure: order:0, mode:0xd2
[  275.924526]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  275.925296]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.926265]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.927231]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  275.928190]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  275.929160]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  275.931450]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.932014]  [<c100111f>] do_signal+0x3a/0x864
[  275.932446]  [<c1099f90>] ? get_lock_stats+0x1b/0x43
[  275.932466] 2162687 pages RAM
[  275.932468] 1934338 pages HighMem
[  275.932468] 96549 pages reserved
[  275.932469] 1989692 pages shared
[  275.932470] 180013 pages non-shared
[  275.935545] ------------[ cut here ]------------
[  275.935552] WARNING: at mm/vmalloc.c:1456 __vunmap.isra.27+0x38/0x3a()
[  275.935553] Trying to vfree() bad address (e64ebd38)
[  275.935581] Modules linked in: nfsv3 nfs_acl nfs lockd sunrpc fscache nouveau video mxm_wmi wmi i2c_algo_bit ttm drm_kms_helper iTCO_wdt drm iTCO_vendor_support lpc_ich ppdev mfd_core tg3 serio_raw i2c_i801 dcdbas ptp pcspkr pps_core i2c_core parport_pc shpchp i5k_amb parport xfs libcrc32c raid0 floppy
[  275.944420]  [<c109a51a>] ? put_lock_stats.isra.29+0xd/0x24
[  275.945195]  [<c109a9c4>] ? lock_release_holdtime.part.30+0x8b/0xd4
[  275.946165]  [<c11a50a4>] ? fsnotify+0x247/0x552
[  275.947115]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  275.948046]  [<c116a29d>] ? vfs_write+0x150/0x19c
[  275.948953]  [<c116a29d>] ? vfs_write+0x150/0x19c
[  275.949842]  [<c15ae584>] ? work_notifysig+0x11/0x31
[  275.951373]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.951711]  [<c109ce92>] ? trace_hardirqs_on_caller+0xea/0x1b4
[  275.952418]  [<c116a846>] ? SyS_write+0x49/0x81
[  275.953243]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.954053]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  275.954846]  [<c15ae59c>] work_notifysig+0x29/0x31
[  275.955617] CPU: 3 PID: 1246 Comm: trinity-child60 Tainted: G        W    3.10.0+ #8 
[  275.956392] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  275.957160]  c174da5b 00000000 e64ebbf4 c15a5a5c e64ebc2c e64ebc1c c1038105 c174a778
[  275.957926]  e64ebc48 000005b0 c114039d c114039d e64ebd38 00000006 eae29b50 e64ebc34
[  275.958678]  c103814f 00000009 e64ebc2c c174a778 e64ebc48 e64ebc4c c114039d c174da5b
[  275.959419] Call Trace:
[  275.960253]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  275.960828]  [<c1038105>] warn_slowpath_common+0x5e/0x75
[  275.961529]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  275.962227]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  275.962914]  [<c103814f>] warn_slowpath_fmt+0x33/0x35
[  275.963610]  [<c114039d>] __vunmap.isra.27+0x38/0x3a
[  275.964289]  [<c11403f5>] vfree+0x30/0x70
[  275.964958]  [<c11b3fdc>] elf_core_dump+0xfdf/0x165c
[  275.965622]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  275.966278]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  275.966936]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  275.967601]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  275.968268]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.968927]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.969581]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  275.970272]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  275.970885]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  275.970980] ---[ end trace 657cf3c64f8d54d8 ]---
[  275.972191]  [<c113273e>] ? might_fault+0x94/0x9a
[  275.972849]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.973512]  [<c100111f>] do_signal+0x3a/0x864
[  275.974177]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.974852]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  275.975524]  [<c15ae59c>] work_notifysig+0x29/0x31
[  275.976199] CPU: 2 PID: 1269 Comm: trinity-child5 Tainted: G        W    3.10.0+ #8 
[  275.976897] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  275.977596]  00000000 00000000 e7c39bc4 c15a5a5c 00000001 e7c39bec c1115c42 c1748de8
[  275.978296]  eafb2ecc 00000000 000000d2 e7c39c00 c174a828 e7c39bdc 00006000 e7c39c18
[  275.978987]  c1142b75 000000d2 00000000 c174a828 00006000 e7c39c2c c109a9c4 ffbfe000
[  275.979686] Call Trace:
[  275.980421]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  275.981063]  [<c1115c42>] warn_alloc_failed+0xbf/0xf2
[  275.981729]  [<c1142b75>] __vmalloc_node_range+0x15d/0x1bd
[  275.982267] ---[ end trace 657cf3c64f8d54d9 ]---
[  275.983102]  [<c109a9c4>] ? lock_release_holdtime.part.30+0x8b/0xd4
[  275.983804]  [<c1142c33>] __vmalloc_node+0x5e/0x66
[  275.984503]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  275.985197]  [<c1142df3>] vmalloc+0x38/0x3a
[  275.985882]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  275.986575]  [<c11b39d1>] elf_core_dump+0x9d4/0x165c
[  275.987273]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  275.987963]  [<c1099f35>] ? trace_hardirqs_off+0xb/0xd
[  275.988642]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  275.989300]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  275.989940]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  275.990607]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.991196]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  275.991802]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  275.992401]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  275.993012]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  275.993613]  [<c1099f35>] ? trace_hardirqs_off+0xb/0xd
[  275.994228]  [<c1099f90>] ? get_lock_stats+0x1b/0x43
[  275.994846]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  275.995458]  [<c100111f>] do_signal+0x3a/0x864
[  275.996073]  [<c15a0dd7>] ? bad_area+0x28/0x42
[  275.996683]  [<c113273e>] ? might_fault+0x94/0x9a
[  275.997190] ------------[ cut here ]------------
[  275.997201] WARNING: at mm/vmalloc.c:1456 __vunmap.isra.27+0x38/0x3a()
[  275.997202] Trying to vfree() bad address (e7e59d38)
[  275.997229] Modules linked in: nfsv3 nfs_acl nfs lockd sunrpc fscache nouveau video mxm_wmi wmi i2c_algo_bit ttm drm_kms_helper iTCO_wdt drm iTCO_vendor_support lpc_ich ppdev mfd_core tg3 serio_raw i2c_i801 dcdbas ptp pcspkr pps_core i2c_core parport_pc shpchp i5k_amb parport xfs libcrc32c raid0 floppy
[  276.001212]  [<c15ae584>] ? work_notifysig+0x11/0x31
[  276.001885]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  276.002578]  [<c109ce92>] ? trace_hardirqs_on_caller+0xea/0x1b4
[  276.003266]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  276.003957]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  276.004653]  [<c15ae59c>] work_notifysig+0x29/0x31
[  276.005347] CPU: 3 PID: 1199 Comm: trinity-child56 Tainted: G        W    3.10.0+ #8 
[  276.006079] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  276.006805]  c174da5b 00000000 e7e59bf4 c15a5a5c e7e59c2c e7e59c1c c1038105 c174a778
[  276.007570]  e7e59c48 000005b0 c114039d c114039d e7e59d38 00000006 eae288c0 e7e59c34
[  276.008331]  c103814f 00000009 e7e59c2c c174a778 e7e59c48 e7e59c4c c114039d c174da5b
[  276.009078] Call Trace:
[  276.009805]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  276.010547]  [<c1038105>] warn_slowpath_common+0x5e/0x75
[  276.011223]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  276.011917]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  276.012605]  [<c103814f>] warn_slowpath_fmt+0x33/0x35
[  276.013290]  [<c114039d>] __vunmap.isra.27+0x38/0x3a
[  276.013974]  [<c11403f5>] vfree+0x30/0x70
[  276.014664]  [<c11b3fdc>] elf_core_dump+0xfdf/0x165c
[  276.015328]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  276.016007]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  276.016679]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  276.017159] Mem-Info:
[  276.017161] DMA per-cpu:
[  276.017164] CPU    0: hi:    0, btch:   1 usd:   0
[  276.017165] CPU    1: hi:    0, btch:   1 usd:   0
[  276.017167] CPU    2: hi:    0, btch:   1 usd:   0
[  276.017169] CPU    3: hi:    0, btch:   1 usd:   0
[  276.017170] Normal per-cpu:
[  276.017171] CPU    0: hi:  186, btch:  31 usd:  79
[  276.017173] CPU    1: hi:  186, btch:  31 usd:  44
[  276.017174] CPU    2: hi:  186, btch:  31 usd: 175
[  276.017175] CPU    3: hi:  186, btch:  31 usd: 180
[  276.017176] HighMem per-cpu:
[  276.017178] CPU    0: hi:  186, btch:  31 usd:  30
[  276.017179] CPU    1: hi:  186, btch:  31 usd:  38
[  276.017180] CPU    2: hi:  186, btch:  31 usd:  37
[  276.017182] CPU    3: hi:  186, btch:  31 usd: 155
[  276.017186] active_anon:41974 inactive_anon:87 isolated_anon:0
 active_file:6434 inactive_file:833486 isolated_file:0
 unevictable:8 dirty:2008 writeback:8 unstable:0
 free:1075441 slab_reclaimable:63589 slab_unreclaimable:13216
 mapped:6696 shmem:3609 pagetables:1112 bounce:0
 free_cma:0
[  276.017192] DMA free:15912kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15912kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  276.017197] lowmem_reserve[]: 0 757 8055 8055
[  276.017203] Normal free:425216kB min:38508kB low:48132kB high:57760kB active_anon:0kB inactive_anon:0kB active_file:460kB inactive_file:1016kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:897016kB managed:775440kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:254356kB slab_unreclaimable:52864kB kernel_stack:2128kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  276.017207] lowmem_reserve[]: 0 0 58384 58384
[  276.017213] HighMem free:3860388kB min:512kB low:93292kB high:186076kB active_anon:168068kB inactive_anon:348kB active_file:25276kB inactive_file:3332928kB unevictable:32kB isolated(anon):0kB isolated(file):0kB present:7473200kB managed:7473200kB mlocked:32kB dirty:8032kB writeback:32kB mapped:26780kB shmem:14436kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:4448kB unstable:0kB bounce:3356400kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  276.017216] lowmem_reserve[]: 0 0 0 0
[  276.017232] DMA: 0*4kB 1*8kB (U) 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15912kB
[  276.017249] Normal: 200*4kB (UEM) 307*8kB (UEM) 236*16kB (UEM) 143*32kB (UEM) 69*64kB (UEM) 37*128kB (UEM) 24*256kB (UM) 22*512kB (UM) 14*1024kB (UEM) 6*2048kB (UEM) 88*4096kB (MR) = 425240kB
[  276.017265] HighMem: 31*4kB (UM) 7*8kB (U) 4*16kB (U) 5*32kB (UM) 1*64kB (M) 1*128kB (M) 1*256kB (M) 2*512kB (UM) 0*1024kB 0*2048kB 942*4096kB (MR) = 3860308kB
[  276.017267] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  276.017268] 843578 total pagecache pages
[  276.017271] 0 pages in swap cache
[  276.017272] Swap cache stats: add 0, delete 0, find 0/0
[  276.017273] Free swap  = 16383996kB
[  276.017274] Total swap = 16383996kB
[  276.051943]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  276.052662]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  276.053570]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  276.054485]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  276.055401]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  276.056324]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  276.057248]  [<c113273e>] ? might_fault+0x94/0x9a
[  276.058181]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  276.059115]  [<c100111f>] do_signal+0x3a/0x864
[  276.060109]  [<f8f0e8e0>] ? tg3_phy_reset+0x13c/0x9ee [tg3]
[  276.061004]  [<f8f0e8e0>] ? tg3_phy_reset+0x13c/0x9ee [tg3]
[  276.061935]  [<f8f0e8e0>] ? tg3_phy_reset+0x13c/0x9ee [tg3]
[  276.062865]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  276.063302] vmap allocation for size 28672 failed: use vmalloc=<size> to increase size.
[  276.063344] vmalloc: allocation failure: 24576 bytes
[  276.063348] trinity-child63: page allocation failure: order:0, mode:0xd2
[  276.066736]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  276.067714]  [<c15ae59c>] work_notifysig+0x29/0x31
[  276.068654] CPU: 2 PID: 1275 Comm: trinity-child63 Tainted: G        W    3.10.0+ #8 
[  276.069671] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  276.070740]  00000000 00000000 eadfbbc4 c15a5a5c 00000001 eadfbbec c1115c42 c1748de8
[  276.071606] ---[ end trace 657cf3c64f8d54da ]---
[  276.072706]  eaf198ec 00000000 000000d2 eadfbc00 c174a828 eadfbbdc 00006000 eadfbc18
[  276.073700]  c1142b75 000000d2 00000000 c174a828 00006000 eadfbc2c c109a9c4 ffbfe000
[  276.074695] Call Trace:
[  276.075908]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  276.076614]  [<c1115c42>] warn_alloc_failed+0xbf/0xf2
[  276.077555]  [<c1142b75>] __vmalloc_node_range+0x15d/0x1bd
[  276.078475]  [<c109a9c4>] ? lock_release_holdtime.part.30+0x8b/0xd4
[  276.079387]  [<c1142c33>] __vmalloc_node+0x5e/0x66
[  276.080320]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  276.080567] 2162687 pages RAM
[  276.080568] 1934338 pages HighMem
[  276.080569] 96549 pages reserved
[  276.080570] 1986520 pages shared
[  276.080571] 180303 pages non-shared
[  276.083753] ------------[ cut here ]------------
[  276.083759] WARNING: at mm/vmalloc.c:1456 __vunmap.isra.27+0x38/0x3a()
[  276.083760] Trying to vfree() bad address (e7c39d38)
[  276.083786] Modules linked in: nfsv3 nfs_acl nfs lockd sunrpc fscache nouveau video mxm_wmi wmi i2c_algo_bit ttm drm_kms_helper iTCO_wdt drm iTCO_vendor_support lpc_ich ppdev mfd_core tg3 serio_raw i2c_i801 dcdbas ptp pcspkr pps_core i2c_core parport_pc shpchp i5k_amb parport xfs libcrc32c raid0 floppy
[  276.089632]  [<c1142df3>] vmalloc+0x38/0x3a
[  276.090344]  [<c11b39d1>] ? elf_core_dump+0x9d4/0x165c
[  276.091027]  [<c11b39d1>] elf_core_dump+0x9d4/0x165c
[  276.091728]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  276.092424]  [<c1099f35>] ? trace_hardirqs_off+0xb/0xd
[  276.093130]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  276.093828]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  276.094532]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  276.095244]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  276.095955]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  276.096654]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  276.097350]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  276.098053]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  276.098760]  [<c113273e>] ? might_fault+0x94/0x9a
[  276.099462]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  276.100175]  [<c100111f>] do_signal+0x3a/0x864
[  276.100863]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  276.101579]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  276.102296]  [<c15ae59c>] work_notifysig+0x29/0x31
[  276.103004] CPU: 0 PID: 1269 Comm: trinity-child5 Tainted: G        W    3.10.0+ #8 
[  276.103737] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  276.104472]  c174da5b 00000000 e7c39bf4 c15a5a5c e7c39c2c e7c39c1c c1038105 c174a778
[  276.105231]  e7c39c48 000005b0 c114039d c114039d e7c39d38 00000006 e5391130 e7c39c34
[  276.106011]  c103814f 00000009 e7c39c2c c174a778 e7c39c48 e7c39c4c c114039d c174da5b
[  276.106492] Mem-Info:
[  276.106494] DMA per-cpu:
[  276.106497] CPU    0: hi:    0, btch:   1 usd:   0
[  276.106498] CPU    1: hi:    0, btch:   1 usd:   0
[  276.106499] CPU    2: hi:    0, btch:   1 usd:   0
[  276.106501] CPU    3: hi:    0, btch:   1 usd:   0
[  276.106502] Normal per-cpu:
[  276.106503] CPU    0: hi:  186, btch:  31 usd:  87
[  276.106505] CPU    1: hi:  186, btch:  31 usd:  41
[  276.106506] CPU    2: hi:  186, btch:  31 usd: 179
[  276.106508] CPU    3: hi:  186, btch:  31 usd: 168
[  276.106509] HighMem per-cpu:
[  276.106510] CPU    0: hi:  186, btch:  31 usd:  49
[  276.106511] CPU    1: hi:  186, btch:  31 usd:  40
[  276.106512] CPU    2: hi:  186, btch:  31 usd:  42
[  276.106514] CPU    3: hi:  186, btch:  31 usd:  38
[  276.106518] active_anon:42498 inactive_anon:88 isolated_anon:0
 active_file:6473 inactive_file:834284 isolated_file:0
 unevictable:11 dirty:2925 writeback:10 unstable:0
 free:1074084 slab_reclaimable:63633 slab_unreclaimable:13172
 mapped:6702 shmem:3609 pagetables:1129 bounce:0
 free_cma:0
[  276.106524] DMA free:15912kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15912kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  276.106528] lowmem_reserve[]: 0 757 8055 8055
[  276.106534] Normal free:425076kB min:38508kB low:48132kB high:57760kB active_anon:0kB inactive_anon:0kB active_file:460kB inactive_file:1016kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:897016kB managed:775440kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:254532kB slab_unreclaimable:52688kB kernel_stack:2120kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  276.106537] lowmem_reserve[]: 0 0 58384 58384
[  276.106544] HighMem free:3855348kB min:512kB low:93292kB high:186076kB active_anon:169992kB inactive_anon:352kB active_file:25432kB inactive_file:3336120kB unevictable:44kB isolated(anon):0kB isolated(file):0kB present:7473200kB managed:7473200kB mlocked:44kB dirty:11700kB writeback:40kB mapped:26804kB shmem:14436kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:4516kB unstable:0kB bounce:3356568kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  276.106547] lowmem_reserve[]: 0 0 0 0
[  276.106564] DMA: 0*4kB 1*8kB (U) 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15912kB
[  276.106582] Normal: 199*4kB (UEM) 308*8kB (UEM) 238*16kB (UEM) 140*32kB (UEM) 69*64kB (UM) 37*128kB (UEM) 24*256kB (UM) 22*512kB (UM) 14*1024kB (UEM) 6*2048kB (UEM) 88*4096kB (MR) = 425180kB
[  276.106598] HighMem: 32*4kB (U) 11*8kB (UM) 4*16kB (U) 5*32kB (UM) 1*64kB (M) 1*128kB (M) 1*256kB (M) 2*512kB (UM) 1*1024kB (M) 1*2048kB (M) 940*4096kB (MR) = 3855224kB
[  276.106601] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  276.106602] 844504 total pagecache pages
[  276.106604] 0 pages in swap cache
[  276.106606] Swap cache stats: add 0, delete 0, find 0/0
[  276.106607] Free swap  = 16383996kB
[  276.106608] Total swap = 16383996kB
[  276.142476] Call Trace:
[  276.143234]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  276.144122]  [<c1038105>] warn_slowpath_common+0x5e/0x75
[  276.145035]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  276.145948]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  276.146874]  [<c103814f>] warn_slowpath_fmt+0x33/0x35
[  276.147770]  [<c114039d>] __vunmap.isra.27+0x38/0x3a
[  276.148688]  [<c11403f5>] vfree+0x30/0x70
[  276.149619]  [<c11b3fdc>] elf_core_dump+0xfdf/0x165c
[  276.150622]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  276.151477]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  276.152396]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  276.153335]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  276.154278]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  276.155227]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  276.156179]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  276.157103]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  276.158038]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  276.158423] 2162687 pages RAM
[  276.158424] 1934338 pages HighMem
[  276.158425] 96549 pages reserved
[  276.158425] 1987356 pages shared
[  276.158426] 180227 pages non-shared
[  276.162291] ------------[ cut here ]------------
[  276.162298] WARNING: at mm/vmalloc.c:1456 __vunmap.isra.27+0x38/0x3a()
[  276.162299] Trying to vfree() bad address (eadfbd38)
[  276.162326] Modules linked in: nfsv3 nfs_acl nfs lockd sunrpc fscache nouveau video mxm_wmi wmi i2c_algo_bit ttm drm_kms_helper iTCO_wdt drm iTCO_vendor_support lpc_ich ppdev mfd_core tg3 serio_raw i2c_i801 dcdbas ptp pcspkr pps_core i2c_core parport_pc shpchp i5k_amb parport xfs libcrc32c raid0 floppy
[  276.168720]  [<c1099f35>] ? trace_hardirqs_off+0xb/0xd
[  276.169326]  [<c1099f90>] ? get_lock_stats+0x1b/0x43
[  276.170157]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  276.170935]  [<c100111f>] do_signal+0x3a/0x864
[  276.171718]  [<c15a0dd7>] ? bad_area+0x28/0x42
[  276.172469]  [<c113273e>] ? might_fault+0x94/0x9a
[  276.173213]  [<c15ae584>] ? work_notifysig+0x11/0x31
[  276.173935]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  276.174633]  [<c109ce92>] ? trace_hardirqs_on_caller+0xea/0x1b4
[  276.175302]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  276.175947]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  276.176566]  [<c15ae59c>] work_notifysig+0x29/0x31
[  276.177162] CPU: 2 PID: 1275 Comm: trinity-child63 Tainted: G        W    3.10.0+ #8 
[  276.177776] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  276.178395]  c174da5b 00000000 eadfbbf4 c15a5a5c eadfbc2c eadfbc1c c1038105 c174a778
[  276.179045]  eadfbc48 000005b0 c114039d c114039d eadfbd38 00000006 eaf60c20 eadfbc34
[  276.179714]  c103814f 00000009 eadfbc2c c174a778 eadfbc48 eadfbc4c c114039d c174da5b
[  276.180398] Call Trace:
[  276.181042]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  276.181702]  [<c1038105>] warn_slowpath_common+0x5e/0x75
[  276.182363]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  276.183022]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  276.183684]  [<c103814f>] warn_slowpath_fmt+0x33/0x35
[  276.184337]  [<c114039d>] __vunmap.isra.27+0x38/0x3a
[  276.185292]  [<c11403f5>] vfree+0x30/0x70
[  276.185657]  [<c11b3fdc>] elf_core_dump+0xfdf/0x165c
[  276.186314]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  276.186977]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  276.187636]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  276.188304]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  276.188961]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  276.189619]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  276.190298]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  276.190931]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  276.191591]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  276.192269]  [<c113273e>] ? might_fault+0x94/0x9a
[  276.192906]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  276.193562]  [<c100111f>] do_signal+0x3a/0x864
[  276.194222]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  276.194891]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  276.195579]  [<c15ae59c>] work_notifysig+0x29/0x31
[  276.202896] ---[ end trace 657cf3c64f8d54db ]---
[  276.203573] ---[ end trace 657cf3c64f8d54dc ]---
[  276.374521] 2162687 pages RAM
[  276.374867] 1934338 pages HighMem
[  276.375150] 96549 pages reserved
[  276.375437] 1988957 pages shared
[  276.376024] 179117 pages non-shared
[  276.743151] ------------[ cut here ]------------
[  276.743461] WARNING: at mm/vmalloc.c:1456 __vunmap.isra.27+0x38/0x3a()
[  276.743722] Trying to vfree() bad address (e82b1d38)
[  276.743971] Modules linked in: nfsv3 nfs_acl nfs lockd sunrpc fscache nouveau video mxm_wmi wmi i2c_algo_bit ttm drm_kms_helper iTCO_wdt drm iTCO_vendor_support lpc_ich ppdev mfd_core tg3 serio_raw i2c_i801 dcdbas ptp pcspkr pps_core i2c_core parport_pc shpchp i5k_amb parport xfs libcrc32c raid0 floppy
[  276.745958] CPU: 2 PID: 1240 Comm: trinity-child43 Tainted: G        W    3.10.0+ #8 
[  276.746660] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
[  276.747362]  c174da5b 00000000 e82b1bf4 c15a5a5c e82b1c2c e82b1c1c c1038105 c174a778
[  276.748091]  e82b1c48 000005b0 c114039d c114039d e82b1d38 00000006 e53917f0 e82b1c34
[  276.748841]  c103814f 00000009 e82b1c2c c174a778 e82b1c48 e82b1c4c c114039d c174da5b
[  276.749600] Call Trace:
[  276.750482]  [<c15a5a5c>] dump_stack+0x4b/0x79
[  276.751039]  [<c1038105>] warn_slowpath_common+0x5e/0x75
[  276.751725]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  276.752387]  [<c114039d>] ? __vunmap.isra.27+0x38/0x3a
[  276.753053]  [<c103814f>] warn_slowpath_fmt+0x33/0x35
[  276.753702]  [<c114039d>] __vunmap.isra.27+0x38/0x3a
[  276.754347]  [<c11403f5>] vfree+0x30/0x70
[  276.754993]  [<c11b3fdc>] elf_core_dump+0xfdf/0x165c
[  276.755632]  [<c11b37b2>] ? elf_core_dump+0x7b5/0x165c
[  276.756299]  [<c15a9c6e>] ? __mutex_unlock_slowpath+0xc9/0x161
[  276.756961]  [<c12b9fca>] ? __percpu_counter_add+0x83/0xbb
[  276.757612]  [<c116c03e>] ? __sb_start_write+0xd8/0x17c
[  276.758258]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  276.758911]  [<c11b7f59>] ? do_coredump+0xd0b/0xe5a
[  276.759562]  [<c11b7ca9>] do_coredump+0xa5b/0xe5a
[  276.760288]  [<c109a9d8>] ? lock_release_holdtime.part.30+0x9f/0xd4
[  276.760861]  [<c104df81>] get_signal_to_deliver+0x276/0x8b9
[  276.761504]  [<c113273e>] ? might_fault+0x94/0x9a
[  276.762157]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  276.762819]  [<c100111f>] do_signal+0x3a/0x864
[  276.763470]  [<c15b192a>] ? __do_page_fault+0x55c/0x55c
[  276.764136]  [<c10019a5>] do_notify_resume+0x5c/0x6b
[  276.764797]  [<c15ae59c>] work_notifysig+0x29/0x31
[  276.790131] ---[ end trace 657cf3c64f8d54dd ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
