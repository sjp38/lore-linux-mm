Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBAFA6B0069
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 20:31:29 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id i35so2509099ote.12
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 17:31:29 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z18si5518612oia.201.2018.01.11.17.31.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 17:31:26 -0800 (PST)
Message-Id: <201801120131.w0C1VJUN034283@www262.sakura.ne.jp>
Subject: Re: [mm 4.15-rc7] Random oopses under memory pressure.
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 12 Jan 2018 10:31:19 +0900
References: <201801112311.EHI90152.FLJMQOStVHFOFO@I-love.SAKURA.ne.jp> <20180111142148.GD1732@dhcp22.suse.cz>
In-Reply-To: <20180111142148.GD1732@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: torvalds@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org, linux-fsdevel@vger.kernel.org

Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 10-01-18 22:37:52, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Wed 10-01-18 20:49:56, Tetsuo Handa wrote:
> > > > > Tetsuo Handa wrote:
> > > > > > I can hit this bug with Linux 4.11 and 4.8. (i.e. at least all 4.8+ have this bug.)
> > > > > > So far I haven't hit this bug with Linux 4.8-rc3 and 4.7.
> > > > > > Does anyone know what is happening?
> > > > > 
> > > > > I simplified the reproducer and succeeded to reproduce this bug with both
> > > > > i7-2630QM (8 core) and i5-4440S (4 core). Thus, I think that this bug is
> > > > > not architecture specific.
> > > > 
> > > > Can you see the same with 64b kernel?
> > > 
> > > No. I can hit this bug with only x86_32 kernels.
> > > But if the cause is not specific to 32b, this might be silent memory corruption.
> > > 
> > > > It smells like a ref count imbalance and premature page free to me. Can
> > > > you try to bisect this?
> > > 
> > > Too difficult to bisect, but at least I can hit this bug with 4.8+ kernels.
> 
> The bug in 4.8 kernel might be different from the bug in 4.15-rc7 kernel.
> 4.15-rc7 kernel hits the bug so trivially.

CONFIG_HIGHMEM4G=y or CONFIG_HIGHMEM64G=y x86_32 kernel hits this bug.

[    0.000000] 2184MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 0 - 377fe000
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x00000000377fdfff]
[    0.000000]   HighMem  [mem 0x00000000377fe000-0x00000000bfffffff]

[    0.000000] 4230MB HIGHMEM available.
[    0.000000] 889MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 379fe000
[    0.000000]   low ram: 0 - 379fe000
[    0.000000] crashkernel: memory value expected
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x00000000379fdfff]
[    0.000000]   HighMem  [mem 0x00000000379fe000-0x000000013fffffff]

CONFIG_NOHIGHMEM=y x86_32 kernel does not hit this bug.

[    0.000000] Warning only 891MB will be used.
[    0.000000] Use a HIGHMEM enabled kernel.
[    0.000000] 891MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 37bfe000
[    0.000000]   low ram: 0 - 37bfe000
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x0000000037bfdfff]

x86_64 kernel does not show HighMem line.

[    0.000000] Reserving 256MB of memory at 448MB for crashkernel (System RAM: 4095MB)
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000013fffffff]

Thus, I suspect that somewhere is confusing HighMem pages and !HighMem pages.



[    2.845150] systemd-journald[128]: Received SIGTERM from PID 1 (systemd).
[    2.859834] bash: 31 output lines suppressed due to ratelimiting
[    8.234776] random: crng init done
[   58.935340] WARNING: CPU: 0 PID: 720 at fs/xfs/xfs_aops.c:1468 xfs_vm_set_page_dirty+0x12d/0x210 [xfs]
[   58.939192] Modules linked in: xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm mptspi drm crc32c_intel scsi_transport_spi serio_raw ata_piix mptscsih libata e1000 mptbase i2c_core
[   58.948541] CPU: 0 PID: 720 Comm: b.out Not tainted 4.15.0-rc7+ #309
[   58.951330] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   58.956375] EIP: xfs_vm_set_page_dirty+0x12d/0x210 [xfs]
[   58.958909] EFLAGS: 00010046 CPU: 0
[   58.960846] EAX: 13000010 EBX: f3bd61d8 ECX: f3bd61d8 EDX: f3bd61cc
[   58.963663] ESI: 00000246 EDI: f4503f68 EBP: eed8d9ec ESP: eed8d9c4
[   58.966515]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   58.969065] CR0: 80050033 CR2: b7f07700 CR3: 33453a80 CR4: 000406f0
[   58.971948] Call Trace:
[   58.973593]  set_page_dirty+0x42/0xa0
[   58.975606]  try_to_unmap_one+0x417/0x6c0
[   58.977768]  rmap_walk_file+0xf0/0x1e0
[   58.979878]  rmap_walk+0x37/0x60
[   58.981781]  try_to_unmap+0x52/0xd0
[   58.983645]  ? page_remove_rmap+0x270/0x270
[   58.985938]  ? page_not_mapped+0x20/0x20
[   58.988044]  ? page_get_anon_vma+0x80/0x80
[   58.990222]  shrink_page_list+0x3f6/0xef0
[   58.992275]  shrink_inactive_list+0x1c2/0x530
[   58.994528]  ? check_preempt_wakeup+0x181/0x230
[   58.996757]  shrink_node_memcg+0x352/0x770
[   58.998710]  shrink_node+0xc3/0x2f0
[   59.000481]  do_try_to_free_pages+0xc9/0x320
[   59.002494]  try_to_free_pages+0x163/0x420
[   59.004472]  __alloc_pages_slowpath+0x280/0x8e4
[   59.006613]  ? release_pages+0x13a/0x340
[   59.008508]  ? __accumulate_pelt_segments+0x37/0x50
[   59.010835]  __alloc_pages_nodemask+0x23b/0x260
[   59.012955]  do_anonymous_page+0xef/0x5a0
[   59.014879]  ? set_next_entity+0x96/0x280
[   59.016772]  handle_mm_fault+0x888/0xa50
[   59.018665]  __do_page_fault+0x1e3/0x4d0
[   59.020609]  ? __do_page_fault+0x4d0/0x4d0
[   59.022481]  do_page_fault+0x29/0xe0
[   59.024165]  ? __do_page_fault+0x4d0/0x4d0
[   59.025992]  ? __do_page_fault+0x4d0/0x4d0
[   59.027808]  common_exception+0x6f/0x76
[   59.029566] EIP: 0x8048437
[   59.031034] EFLAGS: 00010202 CPU: 0
[   59.032699] EAX: 004c5000 EBX: 7ff00000 ECX: 382cd008 EDX: 00000000
[   59.035109] ESI: 7ff00000 EDI: 00000000 EBP: bfbc6198 ESP: bfbc6160
[   59.037516]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   59.039825] Code: e4 8d 58 0c 89 d8 e8 23 c6 8c c8 89 c6 8b 45 e8 8b 50 04 85 d2 74 5b 8b 40 14 a8 01 0f 85 d3 00 00 00 8b 45 e8 8b 00 a8 08 75 7b <0f> ff 8b 7d e8 8b 55 e4 89 f8 e8 94 0a 38 c8 8b 47 14 a8 01 0f
[   59.046971] ---[ end trace a3882c406e0b0b93 ]---
[   59.061588] b.out invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[   59.066371] b.out cpuset=/ mems_allowed=0
[   59.068273] CPU: 0 PID: 798 Comm: b.out Tainted: G        W        4.15.0-rc7+ #309
[   59.071107] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   59.075456] Call Trace:
[   59.076963]  dump_stack+0x58/0x78
[   59.078653]  dump_header+0x70/0x271
[   59.080371]  ? ___ratelimit+0x83/0xf0
[   59.082086]  oom_kill_process+0x1f5/0x3f0
[   59.083881]  ? has_capability_noaudit+0x1a/0x30
[   59.086106]  ? oom_badness+0xe1/0x140
[   59.087885]  out_of_memory+0xe6/0x280
[   59.089653]  __alloc_pages_slowpath+0x647/0x8e4
[   59.091643]  __alloc_pages_nodemask+0x23b/0x260
[   59.093741]  do_anonymous_page+0xef/0x5a0
[   59.095767]  ? set_next_entity+0x96/0x280
[   59.097770]  handle_mm_fault+0x888/0xa50
[   59.099640]  __do_page_fault+0x1e3/0x4d0
[   59.101440]  ? __do_page_fault+0x4d0/0x4d0
[   59.103344]  do_page_fault+0x29/0xe0
[   59.105011]  ? __do_page_fault+0x4d0/0x4d0
[   59.106821]  ? __do_page_fault+0x4d0/0x4d0
[   59.108635]  common_exception+0x6f/0x76
[   59.110432] EIP: 0x8048437
[   59.111920] EFLAGS: 00010202 CPU: 0
[   59.113598] EAX: 003e5000 EBX: 7ff00000 ECX: 382a3008 EDX: 00000000
[   59.116181] ESI: 7ff00000 EDI: 00000000 EBP: bf8ccc08 ESP: bf8ccbd0
[   59.118630]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   59.120851]  ? move_vma+0x90/0x280
[   59.122535] Mem-Info:
[   59.123848] active_anon:957369 inactive_anon:2048 isolated_anon:0
[   59.123848]  active_file:8 inactive_file:32 isolated_file:34
[   59.123848]  unevictable:0 dirty:0 writeback:0 unstable:0
[   59.123848]  slab_reclaimable:1481 slab_unreclaimable:2749
[   59.123848]  mapped:0 shmem:2050 pagetables:24289 bounce:0
[   59.123848]  free:39933 free_pcp:63 free_cma:0
[   59.137797] Node 0 active_anon:3829476kB inactive_anon:8192kB active_file:32kB inactive_file:128kB unevictable:0kB isolated(anon):0kB isolated(file):136kB mapped:0kB dirty:0kB writeback:0kB shmem:8200kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[   59.150272] DMA free:15912kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15916kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   59.164549] lowmem_reserve[]: 0 803 4009 4009
[   59.166791] Normal free:143380kB min:40868kB low:51084kB high:61300kB active_anon:568644kB inactive_anon:0kB active_file:20kB inactive_file:44kB unevictable:0kB writepending:0kB present:894968kB managed:840896kB mlocked:0kB kernel_stack:4760kB pagetables:97156kB bounce:0kB free_pcp:120kB local_pcp:120kB free_cma:0kB
[   59.179026] lowmem_reserve[]: 0 0 25647 25647
[   59.181335] HighMem free:440kB min:512kB low:41276kB high:82040kB active_anon:3260828kB inactive_anon:8192kB active_file:12kB inactive_file:24kB unevictable:0kB writepending:0kB present:3282888kB managed:3282888kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:132kB local_pcp:132kB free_cma:0kB
[   59.193942] lowmem_reserve[]: 0 0 0 0
[   59.196116] DMA: 0*4kB 1*8kB (U) 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15912kB
[   59.202192] Normal: 159*4kB (UE) 91*8kB (UE) 36*16kB (UME) 18*32kB (UE) 9*64kB (UE) 6*128kB (UME) 3*256kB (UE) 3*512kB (UME) 2*1024kB (ME) 2*2048kB (UE) 32*4096kB (M) = 143380kB
[   59.209381] HighMem: 6*4kB (UM) 4*8kB (UM) 4*16kB (UM) 4*32kB (UM) 1*64kB (M) 1*128kB (U) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 440kB
[   59.215678] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   59.220196] 2125 total pagecache pages
[   59.222587] 0 pages in swap cache
[   59.224777] Swap cache stats: add 0, delete 0, find 0/0
[   59.227634] Free swap  = 0kB
[   59.229594] Total swap = 0kB
[   59.231533] 1048462 pages RAM
[   59.233527] 820722 pages HighMem/MovableOnly
[   59.235870] 13537 pages reserved
[   59.237905] 0 pages cma reserved
[   59.239980] Out of memory: Kill process 388 (b.out) score 3 or sacrifice child
[   59.243277] Killed process 388 (b.out) total-vm:2099260kB, anon-rss:16688kB, file-rss:12kB, shmem-rss:0kB
[   66.736837] ------------[ cut here ]------------
[   66.739227] list_add corruption. next->prev should be prev (cf64836e), but was 6673909a. (next=b675dd8b).
[   66.743934] WARNING: CPU: 0 PID: 720 at lib/list_debug.c:25 __list_add_valid+0x3f/0x90
[   66.747137] Modules linked in: xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm mptspi drm crc32c_intel scsi_transport_spi serio_raw ata_piix mptscsih libata e1000 mptbase i2c_core
[   66.756725] CPU: 0 PID: 720 Comm: b.out Tainted: G        W        4.15.0-rc7+ #309
[   66.759984] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   66.764940] EIP: __list_add_valid+0x3f/0x90
[   66.767046] EFLAGS: 00010096 CPU: 0
[   66.768984] EAX: 0000005d EBX: 00000200 ECX: c1b3bce8 EDX: 00000086
[   66.771626] ESI: f4503f7c EDI: f4503f7c EBP: eed8db40 ESP: eed8db2c
[   66.774286]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   66.776701] CR0: 80050033 CR2: 08048437 CR3: 33453a80 CR4: 000406f0
[   66.779404] Call Trace:
[   66.781033]  putback_inactive_pages+0x13f/0x3b0
[   66.783198]  shrink_inactive_list+0x215/0x530
[   66.785300]  ? check_preempt_wakeup+0x181/0x230
[   66.787465]  shrink_node_memcg+0x352/0x770
[   66.789431]  shrink_node+0xc3/0x2f0
[   66.791192]  do_try_to_free_pages+0xc9/0x320
[   66.793156]  try_to_free_pages+0x163/0x420
[   66.795057]  __alloc_pages_slowpath+0x280/0x8e4
[   66.797072]  ? release_pages+0x13a/0x340
[   66.798908]  ? __accumulate_pelt_segments+0x37/0x50
[   66.800993]  __alloc_pages_nodemask+0x23b/0x260
[   66.802991]  do_anonymous_page+0xef/0x5a0
[   66.804855]  ? set_next_entity+0x96/0x280
[   66.806716]  handle_mm_fault+0x888/0xa50
[   66.808573]  __do_page_fault+0x1e3/0x4d0
[   66.810423]  ? __do_page_fault+0x4d0/0x4d0
[   66.812325]  do_page_fault+0x29/0xe0
[   66.814069]  ? __do_page_fault+0x4d0/0x4d0
[   66.815902]  ? __do_page_fault+0x4d0/0x4d0
[   66.817738]  common_exception+0x6f/0x76
[   66.819512] EIP: 0x8048437
[   66.820931] EFLAGS: 00010202 CPU: 0
[   66.822529] EAX: 004c5000 EBX: 7ff00000 ECX: 382cd008 EDX: 00000000
[   66.824891] ESI: 7ff00000 EDI: 00000000 EBP: bfbc6198 ESP: bfbc6160
[   66.827199]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   66.829285] Code: 39 c8 74 2d 39 c3 74 29 b8 01 00 00 00 83 c4 10 5b 5d c3 89 4c 24 0c 89 5c 24 08 89 54 24 04 c7 04 24 70 aa 8d c1 e8 b1 e5 d2 ff <0f> ff 31 c0 eb dc 89 4c 24 0c 89 5c 24 08 89 44 24 04 c7 04 24
[   66.836182] ---[ end trace a3882c406e0b0b94 ]---
[   66.844058] ------------[ cut here ]------------
[   66.845963] list_add corruption. next->prev should be prev (cf64836e), but was 6673909a. (next=b675dd8b).
[   66.849814] WARNING: CPU: 0 PID: 30 at lib/list_debug.c:25 __list_add_valid+0x3f/0x90
[   66.852599] Modules linked in: xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm mptspi drm crc32c_intel scsi_transport_spi serio_raw ata_piix mptscsih libata e1000 mptbase i2c_core
[   66.861186] CPU: 0 PID: 30 Comm: kswapd0 Tainted: G        W        4.15.0-rc7+ #309
[   66.864078] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   66.868375] EIP: __list_add_valid+0x3f/0x90
[   66.870277] EFLAGS: 00010096 CPU: 0
[   66.872003] EAX: 0000005d EBX: 00000200 ECX: c1b3bce8 EDX: 00000082
[   66.874461] ESI: f4503f7c EDI: f55738bc EBP: f352dd50 ESP: f352dd3c
[   66.876985]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   66.879233] CR0: 80050033 CR2: b7d9f2a0 CR3: 33560d20 CR4: 000406f0
[   66.881768] Call Trace:
[   66.883233]  putback_inactive_pages+0x13f/0x3b0
[   66.885256]  shrink_inactive_list+0x215/0x530
[   66.887211]  shrink_node_memcg+0x352/0x770
[   66.889120]  ? _cond_resched+0x17/0x30
[   66.890928]  shrink_node+0xc3/0x2f0
[   66.892748]  kswapd+0x257/0x670
[   66.894395]  kthread+0xdb/0x110
[   66.896078]  ? mem_cgroup_shrink_node+0x160/0x160
[   66.898157]  ? kthread_worker_fn+0x160/0x160
[   66.900153]  ret_from_fork+0x19/0x24
[   66.901902] Code: 39 c8 74 2d 39 c3 74 29 b8 01 00 00 00 83 c4 10 5b 5d c3 89 4c 24 0c 89 5c 24 08 89 54 24 04 c7 04 24 70 aa 8d c1 e8 b1 e5 d2 ff <0f> ff 31 c0 eb dc 89 4c 24 0c 89 5c 24 08 89 44 24 04 c7 04 24
[   66.909496] ---[ end trace a3882c406e0b0b95 ]---
(...snipped...)
[   67.964739] ------------[ cut here ]------------
[   67.966833] list_add corruption. next->prev should be prev (cf64836e), but was 6673909a. (next=b675dd8b).
[   67.971133] WARNING: CPU: 0 PID: 30 at lib/list_debug.c:25 __list_add_valid+0x3f/0x90
[   67.974100] Modules linked in: xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm mptspi drm crc32c_intel scsi_transport_spi serio_raw ata_piix mptscsih libata e1000 mptbase i2c_core
[   67.982900] CPU: 0 PID: 30 Comm: kswapd0 Tainted: G        W        4.15.0-rc7+ #309
[   67.985849] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   67.990519] EIP: __list_add_valid+0x3f/0x90
[   67.992533] EFLAGS: 00010096 CPU: 0
[   67.994334] EAX: 0000005d EBX: 00000200 ECX: c1b3bce8 EDX: 00000082
[   67.996837] ESI: f4503f7c EDI: f5573b14 EBP: f352dd50 ESP: f352dd3c
[   67.999430]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   68.001757] CR0: 80050033 CR2: b7d9f2a0 CR3: 33436e20 CR4: 000406f0
[   68.004304] Call Trace:
[   68.005785]  putback_inactive_pages+0x13f/0x3b0
[   68.007812]  shrink_inactive_list+0x215/0x530
[   68.009804]  shrink_node_memcg+0x352/0x770
[   68.011771]  ? _cond_resched+0x17/0x30
[   68.013593]  shrink_node+0xc3/0x2f0
[   68.015379]  kswapd+0x257/0x670
[   68.017047]  kthread+0xdb/0x110
[   68.018674]  ? mem_cgroup_shrink_node+0x160/0x160
[   68.020700]  ? kthread_worker_fn+0x160/0x160
[   68.022667]  ret_from_fork+0x19/0x24
[   68.024436] Code: 39 c8 74 2d 39 c3 74 29 b8 01 00 00 00 83 c4 10 5b 5d c3 89 4c 24 0c 89 5c 24 08 89 54 24 04 c7 04 24 70 aa 8d c1 e8 b1 e5 d2 ff <0f> ff 31 c0 eb dc 89 4c 24 0c 89 5c 24 08 89 44 24 04 c7 04 24
[   68.031947] ---[ end trace a3882c406e0b0ba3 ]---
[   68.034203] ------------[ cut here ]------------
[   68.036504] list_del corruption, b675dd8b->next is LIST_POISON1 (490f1932)
[   68.039405] WARNING: CPU: 0 PID: 30 at lib/list_debug.c:47 __list_del_entry_valid+0x47/0xa0
[   68.042497] Modules linked in: xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm mptspi drm crc32c_intel scsi_transport_spi serio_raw ata_piix mptscsih libata e1000 mptbase i2c_core
[   68.051350] CPU: 0 PID: 30 Comm: kswapd0 Tainted: G        W        4.15.0-rc7+ #309
[   68.054343] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   68.059006] EIP: __list_del_entry_valid+0x47/0xa0
[   68.061197] EFLAGS: 00010086 CPU: 0
[   68.063002] EAX: 0000003e EBX: f4503f7c ECX: c1b3bce8 EDX: 00000082
[   68.065590] ESI: f3c60c18 EDI: f352dd90 EBP: f352dd4c ESP: f352dd40
[   68.068098]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   68.070375] CR0: 80050033 CR2: b7d9f2a0 CR3: 33436e20 CR4: 000406f0
[   68.072858] Call Trace:
[   68.074311]  isolate_lru_pages.isra.65+0x210/0x360
[   68.076482]  ? putback_inactive_pages+0x13f/0x3b0
[   68.078583]  ? apic_timer_interrupt+0x3c/0x44
[   68.080537]  shrink_active_list+0xb1/0x3a0
[   68.082502]  ? inactive_list_is_low.isra.64+0x12b/0x1f0
[   68.084688]  shrink_node_memcg+0x3a2/0x770
[   68.086600]  shrink_node+0xc3/0x2f0
[   68.088372]  kswapd+0x257/0x670
[   68.090007]  kthread+0xdb/0x110
[   68.091642]  ? mem_cgroup_shrink_node+0x160/0x160
[   68.093779]  ? kthread_worker_fn+0x160/0x160
[   68.095686]  ret_from_fork+0x19/0x24
[   68.097479] Code: 09 39 c8 75 46 8b 52 04 39 d0 75 25 b8 01 00 00 00 c9 c3 89 44 24 04 c7 44 24 08 00 01 00 00 c7 04 24 40 ab 8d c1 e8 19 e5 d2 ff <0f> ff 31 c0 c9 c3 89 54 24 08 89 44 24 04 c7 04 24 e4 ab 8d c1
[   68.104937] ---[ end trace a3882c406e0b0ba4 ]---
[   68.107030] ------------[ cut here ]------------
[   68.109187] kernel BUG at mm/vmscan.c:1560!
[   68.111147] invalid opcode: 0000 [#1] SMP
[   68.112978] Modules linked in: xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm mptspi drm crc32c_intel scsi_transport_spi serio_raw ata_piix mptscsih libata e1000 mptbase i2c_core
[   68.121527] CPU: 0 PID: 30 Comm: kswapd0 Tainted: G        W        4.15.0-rc7+ #309
[   68.124410] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   68.129258] EIP: isolate_lru_pages.isra.65+0x248/0x360
[   68.132206] EFLAGS: 00010082 CPU: 0
[   68.134103] EAX: ffffffea EBX: f4503f7c ECX: f352df68 EDX: 00000000
[   68.136776] ESI: f3c60c18 EDI: 00000001 EBP: f352ddc8 ESP: f352dd54
[   68.139404]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   68.141700] CR0: 80050033 CR2: b7d9f2a0 CR3: 33436e20 CR4: 000406f0
[   68.144202] Call Trace:
[   68.145656]  ? putback_inactive_pages+0x13f/0x3b0
[   68.147714]  ? apic_timer_interrupt+0x3c/0x44
[   68.149628]  shrink_active_list+0xb1/0x3a0
[   68.151576]  ? inactive_list_is_low.isra.64+0x12b/0x1f0
[   68.153749]  shrink_node_memcg+0x3a2/0x770
[   68.155605]  shrink_node+0xc3/0x2f0
[   68.157303]  kswapd+0x257/0x670
[   68.158884]  kthread+0xdb/0x110
[   68.160500]  ? mem_cgroup_shrink_node+0x160/0x160
[   68.162491]  ? kthread_worker_fn+0x160/0x160
[   68.164366]  ret_from_fork+0x19/0x24
[   68.166050] Code: 10 8b 45 b0 8b 38 89 c2 89 d8 89 f9 e8 02 36 1b 00 84 c0 0f 84 d5 fe ff ff 8b 45 b0 89 5f 04 89 3b 89 43 04 89 18 e9 c3 fe ff ff <0f> 0b 8d b6 00 00 00 00 89 d8 e8 69 36 1b 00 84 c0 74 0a 8b 13
[   68.173408] EIP: isolate_lru_pages.isra.65+0x248/0x360 SS:ESP: 0068:f352dd54
[   68.176105] ---[ end trace a3882c406e0b0ba5 ]---
[   68.178248] Kernel panic - not syncing: Fatal exception
[   68.180517] Kernel Offset: 0x0 from 0xc1000000 (relocation range: 0xc0000000-0xf81fdfff)
[   68.183605] Rebooting in 5 seconds..
[   73.262601] ACPI MEMORY or I/O RESET_REG.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
