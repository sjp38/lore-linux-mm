Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D5EB682F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 07:41:43 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id 78so66193967pfw.2
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 04:41:43 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g5si1985069pfd.147.2015.12.24.04.41.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Dec 2015 04:41:42 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
Message-Id: <201512242141.EAH69761.MOVFQtHSFOJFLO@I-love.SAKURA.ne.jp>
Date: Thu, 24 Dec 2015 21:41:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I got OOM killers while running heavy disk I/O (extracting kernel source,
running lxr's genxref command). (Environ: 4 CPUs / 2048MB RAM / no swap / XFS)
Do you think these OOM killers reasonable? Too weak against fragmentation?

[ 3902.430630] kthreadd invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[ 3902.432780] kthreadd cpuset=/ mems_allowed=0
[ 3902.433904] CPU: 3 PID: 2 Comm: kthreadd Not tainted 4.4.0-rc6-next-20151222 #255
[ 3902.435463] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[ 3902.437541]  0000000000000000 000000009cc7eb67 ffff88007cc1faa0 ffffffff81395bc3
[ 3902.439129]  0000000000000000 ffff88007cc1fb40 ffffffff811babac 0000000000000206
[ 3902.440779]  ffffffff81810470 ffff88007cc1fae0 ffffffff810bce29 0000000000000206
[ 3902.442436] Call Trace:
[ 3902.443094]  [<ffffffff81395bc3>] dump_stack+0x4b/0x68
[ 3902.444188]  [<ffffffff811babac>] dump_header+0x5b/0x3b0
[ 3902.445301]  [<ffffffff810bce29>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[ 3902.446656]  [<ffffffff810bcefd>] ? trace_hardirqs_on+0xd/0x10
[ 3902.447881]  [<ffffffff81142646>] oom_kill_process+0x366/0x540
[ 3902.449093]  [<ffffffff81142a5f>] out_of_memory+0x1ef/0x5a0
[ 3902.450266]  [<ffffffff81142b1d>] ? out_of_memory+0x2ad/0x5a0
[ 3902.451430]  [<ffffffff8114836d>] __alloc_pages_nodemask+0xb9d/0xd90
[ 3902.452757]  [<ffffffff810bce00>] ? trace_hardirqs_on_caller+0xd0/0x1c0
[ 3902.454468]  [<ffffffff8114871c>] alloc_kmem_pages_node+0x4c/0xc0
[ 3902.455756]  [<ffffffff8106c451>] copy_process.part.31+0x131/0x1b40
[ 3902.457076]  [<ffffffff8108f590>] ? kthread_create_on_node+0x230/0x230
[ 3902.458396]  [<ffffffff8106e02b>] _do_fork+0xdb/0x5d0
[ 3902.459480]  [<ffffffff81094a8a>] ? finish_task_switch+0x6a/0x2b0
[ 3902.460775]  [<ffffffff8106e544>] kernel_thread+0x24/0x30
[ 3902.461894]  [<ffffffff8109007c>] kthreadd+0x1bc/0x220
[ 3902.463035]  [<ffffffff816fc89f>] ? ret_from_fork+0x3f/0x70
[ 3902.464230]  [<ffffffff8108fec0>] ? kthread_create_on_cpu+0x60/0x60
[ 3902.465502]  [<ffffffff816fc89f>] ret_from_fork+0x3f/0x70
[ 3902.466648]  [<ffffffff8108fec0>] ? kthread_create_on_cpu+0x60/0x60
[ 3902.467953] Mem-Info:
[ 3902.468537] active_anon:20817 inactive_anon:2098 isolated_anon:0
[ 3902.468537]  active_file:145434 inactive_file:145453 isolated_file:0
[ 3902.468537]  unevictable:0 dirty:20613 writeback:7248 unstable:0
[ 3902.468537]  slab_reclaimable:86363 slab_unreclaimable:14905
[ 3902.468537]  mapped:6670 shmem:2167 pagetables:1497 bounce:0
[ 3902.468537]  free:5422 free_pcp:75 free_cma:0
[ 3902.476541] Node 0 DMA free:6904kB min:44kB low:52kB high:64kB active_anon:3268kB inactive_anon:200kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:36kB shmem:216kB slab_reclaimable:3708kB slab_unreclaimable:456kB kernel_stack:48kB pagetables:160kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 3902.486494] lowmem_reserve[]: 0 1714 1714 1714
[ 3902.487659] Node 0 DMA32 free:13760kB min:5172kB low:6464kB high:7756kB active_anon:80000kB inactive_anon:8192kB active_file:581780kB inactive_file:581848kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1758960kB mlocked:0kB dirty:82312kB writeback:29588kB mapped:26648kB shmem:8452kB slab_reclaimable:341744kB slab_unreclaimable:59496kB kernel_stack:3456kB pagetables:5828kB unstable:0kB bounce:0kB free_pcp:732kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:560 all_unreclaimable? no
[ 3902.500438] lowmem_reserve[]: 0 0 0 0
[ 3902.502373] Node 0 DMA: 42*4kB (UME) 84*8kB (UM) 57*16kB (UM) 15*32kB (UM) 11*64kB (M) 9*128kB (UME) 1*256kB (M) 1*512kB (M) 2*1024kB (UM) 0*2048kB 0*4096kB = 6904kB
[ 3902.507561] Node 0 DMA32: 3788*4kB (UME) 184*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 16624kB
[ 3902.511236] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 3902.513938] 292144 total pagecache pages
[ 3902.515609] 0 pages in swap cache
[ 3902.517139] Swap cache stats: add 0, delete 0, find 0/0
[ 3902.519153] Free swap  = 0kB
[ 3902.520587] Total swap = 0kB
[ 3902.522095] 524157 pages RAM
[ 3902.523511] 0 pages HighMem/MovableOnly
[ 3902.525091] 80441 pages reserved
[ 3902.526580] 0 pages hwpoisoned
[ 3902.528169] Out of memory: Kill process 687 (firewalld) score 11 or sacrifice child
[ 3902.531017] Killed process 687 (firewalld) total-vm:323600kB, anon-rss:17032kB, file-rss:4896kB, shmem-rss:0kB
[ 5262.901161] smbd invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[ 5262.903629] smbd cpuset=/ mems_allowed=0
[ 5262.904725] CPU: 2 PID: 3935 Comm: smbd Not tainted 4.4.0-rc6-next-20151222 #255
[ 5262.906401] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[ 5262.908679]  0000000000000000 00000000eaa24b41 ffff88007c37faf8 ffffffff81395bc3
[ 5262.910459]  0000000000000000 ffff88007c37fb98 ffffffff811babac 0000000000000206
[ 5262.912224]  ffffffff81810470 ffff88007c37fb38 ffffffff810bce29 0000000000000206
[ 5262.914019] Call Trace:
[ 5262.914839]  [<ffffffff81395bc3>] dump_stack+0x4b/0x68
[ 5262.916118]  [<ffffffff811babac>] dump_header+0x5b/0x3b0
[ 5262.917493]  [<ffffffff810bce29>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[ 5262.919131]  [<ffffffff810bcefd>] ? trace_hardirqs_on+0xd/0x10
[ 5262.920690]  [<ffffffff81142646>] oom_kill_process+0x366/0x540
[ 5262.922204]  [<ffffffff81142a5f>] out_of_memory+0x1ef/0x5a0
[ 5262.923863]  [<ffffffff81142b1d>] ? out_of_memory+0x2ad/0x5a0
[ 5262.925386]  [<ffffffff8114836d>] __alloc_pages_nodemask+0xb9d/0xd90
[ 5262.927121]  [<ffffffff8114871c>] alloc_kmem_pages_node+0x4c/0xc0
[ 5262.928738]  [<ffffffff8106c451>] copy_process.part.31+0x131/0x1b40
[ 5262.930438]  [<ffffffff8111c4da>] ? __audit_syscall_entry+0xaa/0xf0
[ 5262.932110]  [<ffffffff8106e02b>] _do_fork+0xdb/0x5d0
[ 5262.933410]  [<ffffffff8111c4da>] ? __audit_syscall_entry+0xaa/0xf0
[ 5262.935016]  [<ffffffff810030c1>] ? do_audit_syscall_entry+0x61/0x70
[ 5262.936632]  [<ffffffff81003254>] ? syscall_trace_enter_phase1+0x134/0x150
[ 5262.938383]  [<ffffffff81003017>] ? trace_hardirqs_on_thunk+0x17/0x19
[ 5262.940024]  [<ffffffff8106e5a4>] SyS_clone+0x14/0x20
[ 5262.941465]  [<ffffffff816fc532>] entry_SYSCALL_64_fastpath+0x12/0x76
[ 5262.943137] Mem-Info:
[ 5262.944068] active_anon:37901 inactive_anon:2095 isolated_anon:0
[ 5262.944068]  active_file:134812 inactive_file:135474 isolated_file:0
[ 5262.944068]  unevictable:0 dirty:257 writeback:0 unstable:0
[ 5262.944068]  slab_reclaimable:90770 slab_unreclaimable:12759
[ 5262.944068]  mapped:4223 shmem:2166 pagetables:1428 bounce:0
[ 5262.944068]  free:3738 free_pcp:49 free_cma:0
[ 5262.953176] Node 0 DMA free:6904kB min:44kB low:52kB high:64kB active_anon:900kB inactive_anon:200kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:32kB shmem:216kB slab_reclaimable:5556kB slab_unreclaimable:712kB kernel_stack:48kB pagetables:152kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5262.963749] lowmem_reserve[]: 0 1714 1714 1714
[ 5262.965434] Node 0 DMA32 free:8048kB min:5172kB low:6464kB high:7756kB active_anon:150704kB inactive_anon:8180kB active_file:539244kB inactive_file:541892kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1758960kB mlocked:0kB dirty:1028kB writeback:0kB mapped:16860kB shmem:8448kB slab_reclaimable:357524kB slab_unreclaimable:50324kB kernel_stack:3232kB pagetables:5560kB unstable:0kB bounce:0kB free_pcp:184kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:132 all_unreclaimable? no
[ 5262.976879] lowmem_reserve[]: 0 0 0 0
[ 5262.978586] Node 0 DMA: 58*4kB (UME) 60*8kB (UME) 73*16kB (UME) 23*32kB (UME) 13*64kB (UME) 5*128kB (UM) 5*256kB (UME) 3*512kB (UE) 0*1024kB 0*2048kB 0*4096kB = 6904kB
[ 5262.983496] Node 0 DMA32: 1987*4kB (UME) 14*8kB (ME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 8060kB
[ 5262.987124] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 5262.989532] 272459 total pagecache pages
[ 5262.991203] 0 pages in swap cache
[ 5262.992583] Swap cache stats: add 0, delete 0, find 0/0
[ 5262.994334] Free swap  = 0kB
[ 5262.995787] Total swap = 0kB
[ 5262.997038] 524157 pages RAM
[ 5262.998270] 0 pages HighMem/MovableOnly
[ 5262.999683] 80441 pages reserved
[ 5263.001153] 0 pages hwpoisoned
[ 5263.002612] Out of memory: Kill process 26226 (genxref) score 54 or sacrifice child
[ 5263.004648] Killed process 26226 (genxref) total-vm:130348kB, anon-rss:94680kB, file-rss:4756kB, shmem-rss:0kB
[ 5269.764580] kthreadd invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[ 5269.767289] kthreadd cpuset=/ mems_allowed=0
[ 5269.768904] CPU: 2 PID: 2 Comm: kthreadd Not tainted 4.4.0-rc6-next-20151222 #255
[ 5269.770956] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[ 5269.773754]  0000000000000000 000000009cc7eb67 ffff88007cc1faa0 ffffffff81395bc3
[ 5269.776088]  0000000000000000 ffff88007cc1fb40 ffffffff811babac 0000000000000206
[ 5269.778213]  ffffffff81810470 ffff88007cc1fae0 ffffffff810bce29 0000000000000206
[ 5269.780497] Call Trace:
[ 5269.781796]  [<ffffffff81395bc3>] dump_stack+0x4b/0x68
[ 5269.783634]  [<ffffffff811babac>] dump_header+0x5b/0x3b0
[ 5269.786116]  [<ffffffff810bce29>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[ 5269.788495]  [<ffffffff810bcefd>] ? trace_hardirqs_on+0xd/0x10
[ 5269.790538]  [<ffffffff81142646>] oom_kill_process+0x366/0x540
[ 5269.792755]  [<ffffffff81142a5f>] out_of_memory+0x1ef/0x5a0
[ 5269.794784]  [<ffffffff81142b1d>] ? out_of_memory+0x2ad/0x5a0
[ 5269.796848]  [<ffffffff8114836d>] __alloc_pages_nodemask+0xb9d/0xd90
[ 5269.799038]  [<ffffffff810bce00>] ? trace_hardirqs_on_caller+0xd0/0x1c0
[ 5269.801073]  [<ffffffff8114871c>] alloc_kmem_pages_node+0x4c/0xc0
[ 5269.803186]  [<ffffffff8106c451>] copy_process.part.31+0x131/0x1b40
[ 5269.805249]  [<ffffffff8108f590>] ? kthread_create_on_node+0x230/0x230
[ 5269.807374]  [<ffffffff8106e02b>] _do_fork+0xdb/0x5d0
[ 5269.809089]  [<ffffffff81094a8a>] ? finish_task_switch+0x6a/0x2b0
[ 5269.811146]  [<ffffffff8106e544>] kernel_thread+0x24/0x30
[ 5269.812944]  [<ffffffff8109007c>] kthreadd+0x1bc/0x220
[ 5269.814698]  [<ffffffff816fc89f>] ? ret_from_fork+0x3f/0x70
[ 5269.816330]  [<ffffffff8108fec0>] ? kthread_create_on_cpu+0x60/0x60
[ 5269.818088]  [<ffffffff816fc89f>] ret_from_fork+0x3f/0x70
[ 5269.819685]  [<ffffffff8108fec0>] ? kthread_create_on_cpu+0x60/0x60
[ 5269.821399] Mem-Info:
[ 5269.822430] active_anon:14280 inactive_anon:2095 isolated_anon:0
[ 5269.822430]  active_file:134344 inactive_file:134515 isolated_file:0
[ 5269.822430]  unevictable:0 dirty:2 writeback:0 unstable:0
[ 5269.822430]  slab_reclaimable:96214 slab_unreclaimable:22185
[ 5269.822430]  mapped:3512 shmem:2166 pagetables:1368 bounce:0
[ 5269.822430]  free:12388 free_pcp:51 free_cma:0
[ 5269.831310] Node 0 DMA free:6892kB min:44kB low:52kB high:64kB active_anon:856kB inactive_anon:200kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:32kB shmem:216kB slab_reclaimable:5556kB slab_unreclaimable:768kB kernel_stack:48kB pagetables:152kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5269.840580] lowmem_reserve[]: 0 1714 1714 1714
[ 5269.842107] Node 0 DMA32 free:42660kB min:5172kB low:6464kB high:7756kB active_anon:56264kB inactive_anon:8180kB active_file:537372kB inactive_file:538056kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1758960kB mlocked:0kB dirty:8kB writeback:0kB mapped:14020kB shmem:8448kB slab_reclaimable:379300kB slab_unreclaimable:87972kB kernel_stack:3232kB pagetables:5320kB unstable:0kB bounce:0kB free_pcp:204kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5269.852375] lowmem_reserve[]: 0 0 0 0
[ 5269.853784] Node 0 DMA: 67*4kB (ME) 60*8kB (UME) 72*16kB (ME) 22*32kB (ME) 13*64kB (UME) 5*128kB (UM) 5*256kB (UME) 3*512kB (UE) 0*1024kB 0*2048kB 0*4096kB = 6892kB
[ 5269.858330] Node 0 DMA32: 10648*4kB (UME) 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 42592kB
[ 5269.861551] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 5269.863676] 271012 total pagecache pages
[ 5269.865100] 0 pages in swap cache
[ 5269.866366] Swap cache stats: add 0, delete 0, find 0/0
[ 5269.867996] Free swap  = 0kB
[ 5269.869363] Total swap = 0kB
[ 5269.870593] 524157 pages RAM
[ 5269.871857] 0 pages HighMem/MovableOnly
[ 5269.873604] 80441 pages reserved
[ 5269.874937] 0 pages hwpoisoned
[ 5269.876207] Out of memory: Kill process 2710 (tuned) score 7 or sacrifice child
[ 5269.878265] Killed process 2710 (tuned) total-vm:553052kB, anon-rss:10596kB, file-rss:2776kB, shmem-rss:0kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
