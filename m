Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4222A6B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 08:10:25 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id q63so105088506pfb.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 05:10:25 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d6si51122656pas.224.2016.02.16.05.10.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 05:10:23 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160204125700.GA14425@dhcp22.suse.cz>
	<201602042210.BCG18704.HOMFFJOStQFOLV@I-love.SAKURA.ne.jp>
	<20160204133905.GB14425@dhcp22.suse.cz>
	<201602071309.EJD59750.FOVMSFOOFHtJQL@I-love.SAKURA.ne.jp>
	<20160215200603.GA9223@dhcp22.suse.cz>
In-Reply-To: <20160215200603.GA9223@dhcp22.suse.cz>
Message-Id: <201602162210.DJH39596.OSHQFtFLFOMVOJ@I-love.SAKURA.ne.jp>
Date: Tue, 16 Feb 2016 22:10:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sun 07-02-16 13:09:33, Tetsuo Handa wrote:
> [...]
> > FYI, I again hit unexpected OOM-killer during genxref on linux-4.5-rc2 source.
> > I think current patchset is too fragile to merge.
> > ----------------------------------------
> > [ 3101.626995] smbd invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
> > [ 3101.629148] smbd cpuset=/ mems_allowed=0
> [...]
> > [ 3101.705887] Node 0 DMA: 75*4kB (UME) 69*8kB (UME) 43*16kB (UM) 23*32kB (UME) 8*64kB (UM) 4*128kB (UME) 2*256kB (UM) 0*512kB 1*1024kB (U) 1*2048kB (M) 0*4096kB = 6884kB
> > [ 3101.710581] Node 0 DMA32: 4513*4kB (UME) 15*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 18172kB
> 
> How come this is an unexpected OOM? There is clearly no order-2+ page
> available for the allocation request.

I used "unexpected" because there were only 35 userspace processes and
genxref was the only process which did a lot of memory allocation
(modulo kernel threads woken by file I/O) and most memory is reclaimable.

> 
> > > Something like the following:
> > Yes, I do think we need something like it.
> 
> Was the patch applied?

No for above result.

A result with the patch (20160204142400.GC14425@dhcp22.suse.cz) applied on
today's linux-next is shown below. It seems that protection is not enough.

----------
[  118.584571] fork invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[  118.586684] fork cpuset=/ mems_allowed=0
[  118.588254] CPU: 2 PID: 9565 Comm: fork Not tainted 4.5.0-rc4-next-20160216+ #306
[  118.589795] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  118.591941]  0000000000000286 0000000085a9ed62 ffff88007b3d3ad0 ffffffff8139e82d
[  118.593616]  0000000000000000 ffff88007b3d3d00 ffff88007b3d3b70 ffffffff811bedec
[  118.595273]  0000000000000206 ffffffff81810b70 ffff88007b3d3b10 ffffffff810be8f9
[  118.596970] Call Trace:
[  118.597634]  [<ffffffff8139e82d>] dump_stack+0x85/0xc8
[  118.598787]  [<ffffffff811bedec>] dump_header+0x5b/0x3b0
[  118.599979]  [<ffffffff810be8f9>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[  118.601421]  [<ffffffff810be9cd>] ? trace_hardirqs_on+0xd/0x10
[  118.602713]  [<ffffffff811447f6>] oom_kill_process+0x366/0x550
[  118.604882]  [<ffffffff81144c1f>] out_of_memory+0x1ef/0x5a0
[  118.606940]  [<ffffffff81144cdd>] ? out_of_memory+0x2ad/0x5a0
[  118.608275]  [<ffffffff8114a63b>] __alloc_pages_nodemask+0xb3b/0xd80
[  118.609698]  [<ffffffff810be800>] ? mark_held_locks+0x90/0x90
[  118.611166]  [<ffffffff8114aa3c>] alloc_kmem_pages_node+0x4c/0xc0
[  118.612589]  [<ffffffff8106d661>] copy_process.part.33+0x131/0x1be0
[  118.614203]  [<ffffffff8111e20a>] ? __audit_syscall_entry+0xaa/0xf0
[  118.615689]  [<ffffffff810e8939>] ? current_kernel_time64+0xa9/0xc0
[  118.617151]  [<ffffffff8106f2db>] _do_fork+0xdb/0x5d0
[  118.618391]  [<ffffffff810030c1>] ? do_audit_syscall_entry+0x61/0x70
[  118.619875]  [<ffffffff81003254>] ? syscall_trace_enter_phase1+0x134/0x150
[  118.621642]  [<ffffffff810bae1a>] ? up_read+0x1a/0x40
[  118.622920]  [<ffffffff817093ce>] ? retint_user+0x18/0x23
[  118.624262]  [<ffffffff810035ec>] ? do_syscall_64+0x1c/0x180
[  118.625661]  [<ffffffff8106f854>] SyS_clone+0x14/0x20
[  118.626959]  [<ffffffff8100362d>] do_syscall_64+0x5d/0x180
[  118.628340]  [<ffffffff81708abf>] entry_SYSCALL64_slow_path+0x25/0x25
[  118.630002] Mem-Info:
[  118.630853] active_anon:27270 inactive_anon:2094 isolated_anon:0
[  118.630853]  active_file:253575 inactive_file:89021 isolated_file:22
[  118.630853]  unevictable:0 dirty:0 writeback:0 unstable:0
[  118.630853]  slab_reclaimable:14202 slab_unreclaimable:13906
[  118.630853]  mapped:1622 shmem:2162 pagetables:10587 bounce:0
[  118.630853]  free:5328 free_pcp:356 free_cma:0
[  118.639774] Node 0 DMA free:6904kB min:44kB low:52kB high:64kB active_anon:3280kB inactive_anon:156kB active_file:684kB inactive_file:2292kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:420kB shmem:164kB slab_reclaimable:564kB slab_unreclaimable:800kB kernel_stack:256kB pagetables:200kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  118.650132] lowmem_reserve[]: 0 1714 1714 1714
[  118.651763] Node 0 DMA32 free:14256kB min:5172kB low:6464kB high:7756kB active_anon:105924kB inactive_anon:8220kB active_file:1026268kB inactive_file:340844kB unevictable:0kB isolated(anon):0kB isolated(file):88kB present:2080640kB managed:1759460kB mlocked:0kB dirty:0kB writeback:0kB mapped:6436kB shmem:8484kB slab_reclaimable:56740kB slab_unreclaimable:54824kB kernel_stack:28112kB pagetables:42148kB unstable:0kB bounce:0kB free_pcp:1440kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  118.663101] lowmem_reserve[]: 0 0 0 0
[  118.664704] Node 0 DMA: 83*4kB (ME) 51*8kB (UME) 9*16kB (UME) 2*32kB (UM) 1*64kB (M) 4*128kB (UME) 5*256kB (UME) 2*512kB (UM) 1*1024kB (E) 1*2048kB (M) 0*4096kB = 6900kB
[  118.670166] Node 0 DMA32: 2327*4kB (ME) 621*8kB (M) 1*16kB (M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 14292kB
[  118.673742] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  118.676297] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  118.678610] 344508 total pagecache pages
[  118.680163] 0 pages in swap cache
[  118.681567] Swap cache stats: add 0, delete 0, find 0/0
[  118.681567] Free swap  = 0kB
[  118.681568] Total swap = 0kB
[  118.681625] 524157 pages RAM
[  118.681625] 0 pages HighMem/MovableOnly
[  118.681625] 80316 pages reserved
[  118.681626] 0 pages hwpoisoned

[  120.117093] fork invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[  120.117097] fork cpuset=/ mems_allowed=0
[  120.117099] CPU: 0 PID: 9566 Comm: fork Not tainted 4.5.0-rc4-next-20160216+ #306
[  120.117100] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  120.117102]  0000000000000286 00000000be6c9129 ffff880035dabad0 ffffffff8139e82d
[  120.117103]  0000000000000000 ffff880035dabd00 ffff880035dabb70 ffffffff811bedec
[  120.117104]  0000000000000206 ffffffff81810b70 ffff880035dabb10 ffffffff810be8f9
[  120.117104] Call Trace:
[  120.117111]  [<ffffffff8139e82d>] dump_stack+0x85/0xc8
[  120.117113]  [<ffffffff811bedec>] dump_header+0x5b/0x3b0
[  120.117116]  [<ffffffff810be8f9>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[  120.117117]  [<ffffffff810be9cd>] ? trace_hardirqs_on+0xd/0x10
[  120.117119]  [<ffffffff811447f6>] oom_kill_process+0x366/0x550
[  120.117121]  [<ffffffff81144c1f>] out_of_memory+0x1ef/0x5a0
[  120.117122]  [<ffffffff81144cdd>] ? out_of_memory+0x2ad/0x5a0
[  120.117123]  [<ffffffff8114a63b>] __alloc_pages_nodemask+0xb3b/0xd80
[  120.117124]  [<ffffffff810be800>] ? mark_held_locks+0x90/0x90
[  120.117125]  [<ffffffff8114aa3c>] alloc_kmem_pages_node+0x4c/0xc0
[  120.117128]  [<ffffffff8106d661>] copy_process.part.33+0x131/0x1be0
[  120.117130]  [<ffffffff8111e20a>] ? __audit_syscall_entry+0xaa/0xf0
[  120.117132]  [<ffffffff810e8939>] ? current_kernel_time64+0xa9/0xc0
[  120.117133]  [<ffffffff8106f2db>] _do_fork+0xdb/0x5d0
[  120.117136]  [<ffffffff810030c1>] ? do_audit_syscall_entry+0x61/0x70
[  120.117137]  [<ffffffff81003254>] ? syscall_trace_enter_phase1+0x134/0x150
[  120.117139]  [<ffffffff810bae1a>] ? up_read+0x1a/0x40
[  120.117142]  [<ffffffff817093ce>] ? retint_user+0x18/0x23
[  120.117143]  [<ffffffff810035ec>] ? do_syscall_64+0x1c/0x180
[  120.117144]  [<ffffffff8106f854>] SyS_clone+0x14/0x20
[  120.117145]  [<ffffffff8100362d>] do_syscall_64+0x5d/0x180
[  120.117147]  [<ffffffff81708abf>] entry_SYSCALL64_slow_path+0x25/0x25
[  120.117147] Mem-Info:
[  120.117150] active_anon:30895 inactive_anon:2094 isolated_anon:0
[  120.117150]  active_file:183306 inactive_file:118692 isolated_file:18
[  120.117150]  unevictable:0 dirty:47 writeback:0 unstable:0
[  120.117150]  slab_reclaimable:14405 slab_unreclaimable:22372
[  120.117150]  mapped:3101 shmem:2162 pagetables:20154 bounce:0
[  120.117150]  free:7231 free_pcp:108 free_cma:0
[  120.117154] Node 0 DMA free:6904kB min:44kB low:52kB high:64kB active_anon:1172kB inactive_anon:156kB active_file:684kB inactive_file:1356kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:420kB shmem:164kB slab_reclaimable:564kB slab_unreclaimable:2244kB kernel_stack:1376kB pagetables:436kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:4 all_unreclaimable? no
[  120.117156] lowmem_reserve[]: 0 1714 1714 1714
[  120.117172] Node 0 DMA32 free:22020kB min:5172kB low:6464kB high:7756kB active_anon:122408kB inactive_anon:8220kB active_file:732540kB inactive_file:473412kB unevictable:0kB isolated(anon):0kB isolated(file):72kB present:2080640kB managed:1759460kB mlocked:0kB dirty:188kB writeback:0kB mapped:11984kB shmem:8484kB slab_reclaimable:57056kB slab_unreclaimable:87244kB kernel_stack:52048kB pagetables:80180kB unstable:0kB bounce:0kB free_pcp:432kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  120.117230] lowmem_reserve[]: 0 0 0 0
[  120.117238] Node 0 DMA: 46*4kB (UME) 82*8kB (ME) 37*16kB (UME) 13*32kB (M) 3*64kB (UM) 2*128kB (ME) 2*256kB (ME) 2*512kB (UM) 1*1024kB (E) 1*2048kB (M) 0*4096kB = 6904kB
[  120.117242] Node 0 DMA32: 709*4kB (UME) 2374*8kB (UME) 0*16kB 10*32kB (E) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 22148kB
[  120.117244] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  120.117244] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  120.117245] 304244 total pagecache pages
[  120.117246] 0 pages in swap cache
[  120.117246] Swap cache stats: add 0, delete 0, find 0/0
[  120.117247] Free swap  = 0kB
[  120.117247] Total swap = 0kB
[  120.117248] 524157 pages RAM
[  120.117248] 0 pages HighMem/MovableOnly
[  120.117248] 80316 pages reserved
[  120.117249] 0 pages hwpoisoned

[  126.034913] fork invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[  126.034918] fork cpuset=/ mems_allowed=0
[  126.034920] CPU: 2 PID: 9566 Comm: fork Not tainted 4.5.0-rc4-next-20160216+ #306
[  126.034921] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  126.034923]  0000000000000286 00000000be6c9129 ffff880035dabad0 ffffffff8139e82d
[  126.034925]  0000000000000000 ffff880035dabd00 ffff880035dabb70 ffffffff811bedec
[  126.034926]  0000000000000206 ffffffff81810b70 ffff880035dabb10 ffffffff810be8f9
[  126.034926] Call Trace:
[  126.034932]  [<ffffffff8139e82d>] dump_stack+0x85/0xc8
[  126.034935]  [<ffffffff811bedec>] dump_header+0x5b/0x3b0
[  126.034938]  [<ffffffff810be8f9>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[  126.034939]  [<ffffffff810be9cd>] ? trace_hardirqs_on+0xd/0x10
[  126.034941]  [<ffffffff811447f6>] oom_kill_process+0x366/0x550
[  126.034943]  [<ffffffff81144c1f>] out_of_memory+0x1ef/0x5a0
[  126.034944]  [<ffffffff81144cdd>] ? out_of_memory+0x2ad/0x5a0
[  126.034945]  [<ffffffff8114a63b>] __alloc_pages_nodemask+0xb3b/0xd80
[  126.034947]  [<ffffffff810be800>] ? mark_held_locks+0x90/0x90
[  126.034948]  [<ffffffff8114aa3c>] alloc_kmem_pages_node+0x4c/0xc0
[  126.034950]  [<ffffffff8106d661>] copy_process.part.33+0x131/0x1be0
[  126.034952]  [<ffffffff8111e20a>] ? __audit_syscall_entry+0xaa/0xf0
[  126.034954]  [<ffffffff810e8939>] ? current_kernel_time64+0xa9/0xc0
[  126.034956]  [<ffffffff8106f2db>] _do_fork+0xdb/0x5d0
[  126.034958]  [<ffffffff810030c1>] ? do_audit_syscall_entry+0x61/0x70
[  126.034959]  [<ffffffff81003254>] ? syscall_trace_enter_phase1+0x134/0x150
[  126.034961]  [<ffffffff810bae1a>] ? up_read+0x1a/0x40
[  126.034965]  [<ffffffff817093ce>] ? retint_user+0x18/0x23
[  126.034965]  [<ffffffff810035ec>] ? do_syscall_64+0x1c/0x180
[  126.034967]  [<ffffffff8106f854>] SyS_clone+0x14/0x20
[  126.034968]  [<ffffffff8100362d>] do_syscall_64+0x5d/0x180
[  126.034969]  [<ffffffff81708abf>] entry_SYSCALL64_slow_path+0x25/0x25
[  126.034970] Mem-Info:
[  126.034973] active_anon:27060 inactive_anon:2093 isolated_anon:0
[  126.034973]  active_file:206123 inactive_file:85224 isolated_file:32
[  126.034973]  unevictable:0 dirty:47 writeback:0 unstable:0
[  126.034973]  slab_reclaimable:13214 slab_unreclaimable:26604
[  126.034973]  mapped:2421 shmem:2161 pagetables:24889 bounce:0
[  126.034973]  free:4649 free_pcp:30 free_cma:0
[  126.034986] Node 0 DMA free:6924kB min:44kB low:52kB high:64kB active_anon:1156kB inactive_anon:156kB active_file:728kB inactive_file:1060kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:368kB shmem:164kB slab_reclaimable:468kB slab_unreclaimable:2496kB kernel_stack:832kB pagetables:704kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:4 all_unreclaimable? no
[  126.034988] lowmem_reserve[]: 0 1714 1714 1714
[  126.034992] Node 0 DMA32 free:11672kB min:5172kB low:6464kB high:7756kB active_anon:107084kB inactive_anon:8216kB active_file:823764kB inactive_file:339836kB unevictable:0kB isolated(anon):0kB isolated(file):128kB present:2080640kB managed:1759460kB mlocked:0kB dirty:188kB writeback:0kB mapped:9316kB shmem:8480kB slab_reclaimable:52388kB slab_unreclaimable:103920kB kernel_stack:66016kB pagetables:98852kB unstable:0kB bounce:0kB free_pcp:120kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  126.034993] lowmem_reserve[]: 0 0 0 0
[  126.035000] Node 0 DMA: 70*4kB (UME) 16*8kB (UME) 59*16kB (UME) 34*32kB (ME) 14*64kB (UME) 2*128kB (UE) 1*256kB (E) 2*512kB (M) 2*1024kB (ME) 0*2048kB 0*4096kB = 6920kB
[  126.035005] Node 0 DMA32: 2372*4kB (UME) 290*8kB (UM) 3*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 11856kB
[  126.035006] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  126.035006] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  126.035007] 293674 total pagecache pages
[  126.035008] 0 pages in swap cache
[  126.035008] Swap cache stats: add 0, delete 0, find 0/0
[  126.035009] Free swap  = 0kB
[  126.035009] Total swap = 0kB
[  126.035010] 524157 pages RAM
[  126.035010] 0 pages HighMem/MovableOnly
[  126.035010] 80316 pages reserved
[  126.035011] 0 pages hwpoisoned
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
