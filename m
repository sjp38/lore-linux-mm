Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF11F6B0005
	for <linux-mm@kvack.org>; Wed, 25 May 2016 06:52:29 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id r64so68807135oie.1
        for <linux-mm@kvack.org>; Wed, 25 May 2016 03:52:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c35si4747798otb.145.2016.05.25.03.52.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 May 2016 03:52:28 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, oom_reaper: do not mmput synchronously from the oom reaper context
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1461679470-8364-1-git-send-email-mhocko@kernel.org>
	<1461679470-8364-3-git-send-email-mhocko@kernel.org>
	<201605192329.ABB17132.LFHOFJMVtOSFQO@I-love.SAKURA.ne.jp>
	<20160519172056.GA5290@dhcp22.suse.cz>
In-Reply-To: <20160519172056.GA5290@dhcp22.suse.cz>
Message-Id: <201605251952.EJF87514.SOJQMOVFOFHFLt@I-love.SAKURA.ne.jp>
Date: Wed, 25 May 2016 19:52:18 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org

Michal Hocko wrote:
> > Just a random thought, but after this patch is applied, do we still need to use
> > a dedicated kernel thread for OOM-reap operation? If I recall correctly, the
> > reason we decided to use a dedicated kernel thread was that calling
> > down_read(&mm->mmap_sem) / mmput() from the OOM killer context is unsafe due to
> > dependency. By replacing mmput() with mmput_async(), since __oom_reap_task() will
> > no longer do operations that might block, can't we try OOM-reap operation from
> > current thread which called mark_oom_victim() or oom_scan_process_thread() ?
> 
> I was already thinking about that. It is true that the main blocker
> was the mmput, as you say, but the dedicated kernel thread seems to be
> more robust locking and stack wise. So I would prefer staying with the
> current approach until we see that it is somehow limitting. One pid and
> kernel stack doesn't seem to be a terrible price to me. But as I've said
> I am not bound to the kernel thread approach...
> 

It seems to me that async OOM reaping widens race window for needlessly
selecting next OOM victim, for the OOM reaper holding a reference of a
TIF_MEMDIE thread's mm expedites clearing TIF_MEMDIE from that thread
by making atomic_dec_and_test() in mmput() from exit_mm() false.

Maybe we should wait for first OOM reap attempt from the OOM killer context
before releasing oom_lock mutex (sync OOM reaping) ?

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160525.txt.xz .
----------------------------------------
[   73.485228] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[   73.487497] [  442]     0   442   123055   105971     215       4        0             0 oleg's-test
[   73.490055] Out of memory: Kill process 442 (oleg's-test) score 855 or sacrifice child
[   73.492178] Killed process 442 (oleg's-test) total-vm:492220kB, anon-rss:423880kB, file-rss:4kB, shmem-rss:0kB
[   73.516065] oom_reaper: reaped process 442 (oleg's-test), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[   74.308526] oleg's-test invoked oom-killer: gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), order=0, oom_score_adj=0
[   74.316047] oleg's-test cpuset=/ mems_allowed=0
[   74.320387] CPU: 3 PID: 443 Comm: oleg's-test Not tainted 4.6.0-rc7+ #51
[   74.325435] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   74.329768]  0000000000000286 00000000e7952d6d ffff88001943fad0 ffffffff812c7cbd
[   74.333314]  0000000000000000 ffff88001943fcf0 ffff88001943fb70 ffffffff811b9e94
[   74.336859]  0000000000000206 ffffffff8182b970 ffff88001943fb10 ffffffff810bc519
[   74.340524] Call Trace:
[   74.342373]  [<ffffffff812c7cbd>] dump_stack+0x85/0xc8
[   74.345138]  [<ffffffff811b9e94>] dump_header+0x5b/0x394
[   74.347878]  [<ffffffff810bc519>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[   74.350988]  [<ffffffff810bc5ed>] ? trace_hardirqs_on+0xd/0x10
[   74.353897]  [<ffffffff8114434f>] oom_kill_process+0x35f/0x540
[   74.356908]  [<ffffffff81144786>] out_of_memory+0x206/0x5a0
[   74.359694]  [<ffffffff81144844>] ? out_of_memory+0x2c4/0x5a0
[   74.362553]  [<ffffffff8114a55a>] __alloc_pages_nodemask+0xb3a/0xb50
[   74.365611]  [<ffffffff810bcd36>] ? __lock_acquire+0x3d6/0x1fb0
[   74.368513]  [<ffffffff81194fe6>] alloc_pages_vma+0xb6/0x290
[   74.371293]  [<ffffffff81172673>] handle_mm_fault+0x1873/0x1e60
[   74.374181]  [<ffffffff81170e4c>] ? handle_mm_fault+0x4c/0x1e60
[   74.376989]  [<ffffffff8105c01a>] ? __do_page_fault+0x1da/0x4d0
[   74.379758]  [<ffffffff8105bf67>] ? __do_page_fault+0x127/0x4d0
[   74.382502]  [<ffffffff8105bff5>] __do_page_fault+0x1b5/0x4d0
[   74.385086]  [<ffffffff8105c340>] do_page_fault+0x30/0x80
[   74.386771]  [<ffffffff8160fbe8>] page_fault+0x28/0x30
[   74.388469] Mem-Info:
[   74.389457] active_anon:106132 inactive_anon:1024 isolated_anon:0
[   74.389457]  active_file:1 inactive_file:20 isolated_file:0
[   74.389457]  unevictable:0 dirty:0 writeback:0 unstable:0
[   74.389457]  slab_reclaimable:368 slab_unreclaimable:3722
[   74.389457]  mapped:3 shmem:1026 pagetables:224 bounce:0
[   74.389457]  free:1085 free_pcp:0 free_cma:0
[   74.398435] Node 0 DMA free:1816kB min:92kB low:112kB high:132kB active_anon:12208kB inactive_anon:124kB active_file:8kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:128kB slab_reclaimable:44kB slab_unreclaimable:624kB kernel_stack:112kB pagetables:20kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:4 all_unreclaimable? yes
[   74.408909] lowmem_reserve[]: 0 432 432 432
[   74.410422] Node 0 DMA32 free:2524kB min:2612kB low:3264kB high:3916kB active_anon:412320kB inactive_anon:3972kB active_file:0kB inactive_file:76kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:507776kB managed:465568kB mlocked:0kB dirty:0kB writeback:0kB mapped:8kB shmem:3976kB slab_reclaimable:1428kB slab_unreclaimable:14264kB kernel_stack:2704kB pagetables:876kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   74.421596] lowmem_reserve[]: 0 0 0 0
[   74.423273] Node 0 DMA: 11*4kB (UM) 8*8kB (U) 5*16kB (U) 3*32kB (UM) 4*64kB (U) 4*128kB (UM) 3*256kB (UM) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1820kB
[   74.427306] Node 0 DMA32: 95*4kB (UME) 117*8kB (UME) 44*16kB (UME) 16*32kB (UM) 0*64kB 1*128kB (M) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2660kB
[   74.431255] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   74.433655] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   74.436036] 1056 total pagecache pages
[   74.437448] 0 pages in swap cache
[   74.438935] Swap cache stats: add 0, delete 0, find 0/0
[   74.440573] Free swap  = 0kB
[   74.441830] Total swap = 0kB
[   74.443003] 130941 pages RAM
[   74.444220] 0 pages HighMem/MovableOnly
[   74.445603] 10573 pages reserved
[   74.446873] 0 pages cma reserved
[   74.448068] 0 pages hwpoisoned
[   74.449255] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[   74.451523] [  443]     0   443   123312   105971     214       3        0             0 oleg's-test
[   74.453958] Out of memory: Kill process 443 (oleg's-test) score 855 or sacrifice child
[   74.456234] Killed process 443 (oleg's-test) total-vm:493248kB, anon-rss:423880kB, file-rss:4kB, shmem-rss:0kB
[   74.459219] sh invoked oom-killer: gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), order=0, oom_score_adj=0
[   74.462813] sh cpuset=/ mems_allowed=0
[   74.465221] CPU: 2 PID: 1 Comm: sh Not tainted 4.6.0-rc7+ #51
[   74.467037] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   74.470207]  0000000000000286 00000000a17a86b0 ffff88001e673a18 ffffffff812c7cbd
[   74.473422]  0000000000000000 ffff88001e673bd0 ffff88001e673ab8 ffffffff811b9e94
[   74.475704]  ffff88001e66cbe0 ffff88001e673ab8 0000000000000246 0000000000000000
[   74.477990] Call Trace:
[   74.479170]  [<ffffffff812c7cbd>] dump_stack+0x85/0xc8
[   74.480872]  [<ffffffff811b9e94>] dump_header+0x5b/0x394
[   74.481837] oom_reaper: reaped process 443 (oleg's-test), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[   74.485142]  [<ffffffff81144ac6>] out_of_memory+0x546/0x5a0
[   74.486959]  [<ffffffff81144844>] ? out_of_memory+0x2c4/0x5a0
[   74.489013]  [<ffffffff8114a55a>] __alloc_pages_nodemask+0xb3a/0xb50
[   74.491229]  [<ffffffff8113f500>] ? find_get_entry+0x40/0x1d0
[   74.493033]  [<ffffffff81193316>] alloc_pages_current+0x96/0x1b0
[   74.494909]  [<ffffffff8113edcd>] __page_cache_alloc+0x12d/0x160
[   74.496705]  [<ffffffff81142915>] filemap_fault+0x455/0x670
[   74.498470]  [<ffffffff811427f0>] ? filemap_fault+0x330/0x670
[   74.500279]  [<ffffffffa0231c99>] xfs_filemap_fault+0x39/0x60 [xfs]
[   74.502149]  [<ffffffff8116bc0b>] __do_fault+0x6b/0x120
[   74.503811]  [<ffffffff81171fd2>] handle_mm_fault+0x11d2/0x1e60
[   74.505702]  [<ffffffff81170e4c>] ? handle_mm_fault+0x4c/0x1e60
[   74.507450]  [<ffffffff810bc519>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[   74.509336]  [<ffffffff8105bf67>] ? __do_page_fault+0x127/0x4d0
[   74.511054]  [<ffffffff8105bff5>] __do_page_fault+0x1b5/0x4d0
[   74.512693]  [<ffffffff8105c340>] do_page_fault+0x30/0x80
[   74.514303]  [<ffffffff8160fbe8>] page_fault+0x28/0x30
[   74.515893] Mem-Info:
[   74.516865] active_anon:106 inactive_anon:1024 isolated_anon:0
[   74.516865]  active_file:1 inactive_file:20 isolated_file:0
[   74.516865]  unevictable:0 dirty:0 writeback:0 unstable:0
[   74.516865]  slab_reclaimable:368 slab_unreclaimable:3722
[   74.516865]  mapped:3 shmem:1026 pagetables:24 bounce:0
[   74.516865]  free:107155 free_pcp:191 free_cma:0
[   74.526066] Node 0 DMA free:14024kB min:92kB low:112kB high:132kB active_anon:24kB inactive_anon:124kB active_file:8kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:128kB slab_reclaimable:44kB slab_unreclaimable:624kB kernel_stack:112kB pagetables:4kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   74.536441] lowmem_reserve[]: 0 432 432 432
[   74.538048] Node 0 DMA32 free:414596kB min:2612kB low:3264kB high:3916kB active_anon:400kB inactive_anon:3972kB active_file:0kB inactive_file:76kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:507776kB managed:465568kB mlocked:0kB dirty:0kB writeback:0kB mapped:8kB shmem:3976kB slab_reclaimable:1428kB slab_unreclaimable:14264kB kernel_stack:2704kB pagetables:92kB unstable:0kB bounce:0kB free_pcp:764kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   74.549582] lowmem_reserve[]: 0 0 0 0
[   74.551165] Node 0 DMA: 23*4kB (UM) 20*8kB (UM) 13*16kB (UM) 6*32kB (UM) 5*64kB (UM) 6*128kB (UM) 2*256kB (U) 3*512kB (UM) 2*1024kB (M) 2*2048kB (M) 1*4096kB (M) = 14028kB
[   74.556385] Node 0 DMA32: 522*4kB (UME) 342*8kB (UME) 198*16kB (UME) 116*32kB (UM) 91*64kB (UM) 29*128kB (M) 23*256kB (M) 17*512kB (M) 16*1024kB (M) 9*2048kB (M) 84*4096kB (M) = 414712kB
[   74.561989] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   74.564360] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   74.566681] 1056 total pagecache pages
[   74.568112] 0 pages in swap cache
[   74.569439] Swap cache stats: add 0, delete 0, find 0/0
[   74.571166] Free swap  = 0kB
[   74.572455] Total swap = 0kB
[   74.573683] 130941 pages RAM
[   74.574960] 0 pages HighMem/MovableOnly
[   74.576336] 10573 pages reserved
[   74.577610] 0 pages cma reserved
[   74.578924] 0 pages hwpoisoned
[   74.580135] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[   74.582454] Kernel panic - not syncing: Out of memory and no killable processes...
[   74.582454]
[   74.585646] Kernel Offset: disabled
[   74.587538] ---[ end Kernel panic - not syncing: Out of memory and no killable processes...
----------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
