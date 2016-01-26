Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 436366B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 09:46:30 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id z14so58235777igp.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 06:46:30 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id qo12si6520998igb.70.2016.01.26.06.46.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 06:46:28 -0800 (PST)
Subject: Re: [LTP] [BUG] oom hangs the system, NMI backtrace shows most CPUs in shrink_slab
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <569D06F8.4040209@redhat.com>
	<569E1010.2070806@I-love.SAKURA.ne.jp>
	<56A24760.5020503@redhat.com>
	<56A724B1.3000407@redhat.com>
In-Reply-To: <56A724B1.3000407@redhat.com>
Message-Id: <201601262346.BFB30785.VOQOFFHJLMtFSO@I-love.SAKURA.ne.jp>
Date: Tue, 26 Jan 2016 23:46:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jstancek@redhat.com, linux-mm@kvack.org
Cc: ltp@lists.linux.it

Jan Stancek wrote:
> On 01/22/2016 04:14 PM, Jan Stancek wrote:
> > On 01/19/2016 11:29 AM, Tetsuo Handa wrote:
> >> although I
> >> couldn't find evidence that mlock() and madvice() are related with this hangup,
> > 
> > I simplified reproducer by having only single thread allocating
> > memory when OOM triggers:
> >   http://jan.stancek.eu/tmp/oom_hangs/console.log.3-v4.4-8606-with-memalloc.txt
> > 
> > In this instance it was mmap + mlock, as you can see from oom call trace.
> > It made it to do_exit(), but couldn't complete it:
> 
> I have extracted test from LTP into standalone reproducer (attached),
> if you want to give a try. It usually hangs my system within ~30
> minutes. If it takes too long, you can try disabling swap. From my past
> experience this usually helped to reproduce it faster on small KVM guests.
> 
> # gcc oom_mlock.c -pthread -O2
> # echo 1 > /proc/sys/vm/overcommit_memory
> (optionally) # swapoff -a
> # ./a.out
> 
> Also, it's interesting to note, that when I disabled mlock() calls
> test ran fine over night. I'll look into confirming this observation
> on more systems.
> 

Thank you for a reproducer. I tried it with

----------
--- oom_mlock.c
+++ oom_mlock.c
@@ -33,7 +33,7 @@
 	if (s == MAP_FAILED)
 		return errno;
 
-	if (do_mlock) {
+	if (0 && do_mlock) {
 		while (mlock(s, length) == -1 && loop > 0) {
 			if (EAGAIN != errno)
 				return errno;
----------

applied (i.e. disabled mlock() calls) on a VM with 4CPUs / 5120MB RAM, and
successfully reproduced a livelock. Therefore, I think mlock() is irrelevant.

What I observed is that while disk_events_workfn workqueue item was looping,
"Node 0 Normal free:" remained smaller than "min:" but "Node 0 Normal:" was
larger than "Node 0 Normal free:".

Is this difference caused by pending vmstat_update, vmstat_shepherd, vmpressure_work_fn ?
Can we somehow check how long these workqueue items remained pending?

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160126.txt.xz .
----------
[  312.018243] Out of memory: Kill process 9785 (a.out) score 937 or sacrifice child
[  312.020469] Killed process 9785 (a.out) total-vm:6314312kB, anon-rss:4637568kB, file-rss:0kB
[  323.867935] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[  323.870075] MemAlloc: kworker/1:8(9698) seq=10 gfp=0x2400000 order=0 delay=9828
[  323.872259] kworker/1:8     R  running task        0  9698      2 0x00000080
[  323.874452] Workqueue: events_freezable_power_ disk_events_workfn
(...snipped...)
[  324.194104] Mem-Info:
[  324.195095] active_anon:1165831 inactive_anon:3486 isolated_anon:0
[  324.195095]  active_file:1 inactive_file:0 isolated_file:0
[  324.195095]  unevictable:0 dirty:0 writeback:0 unstable:0
[  324.195095]  slab_reclaimable:1906 slab_unreclaimable:5202
[  324.195095]  mapped:1175 shmem:4204 pagetables:2555 bounce:0
[  324.195095]  free:8087 free_pcp:0 free_cma:0
[  324.204574] Node 0 DMA free:15888kB min:28kB low:32kB high:40kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  324.213795] lowmem_reserve[]: 0 2708 4673 4673
[  324.215372] Node 0 DMA32 free:12836kB min:5008kB low:6260kB high:7512kB active_anon:2712464kB inactive_anon:7984kB active_file:4kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3129216kB managed:2776588kB mlocked:0kB dirty:0kB writeback:0kB mapped:2880kB shmem:9704kB slab_reclaimable:4556kB slab_unreclaimable:9116kB kernel_stack:1184kB pagetables:4644kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  324.226159] lowmem_reserve[]: 0 0 1965 1965
[  324.227795] Node 0 Normal free:3624kB min:3632kB low:4540kB high:5448kB active_anon:1950860kB inactive_anon:5960kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1820kB shmem:7112kB slab_reclaimable:3068kB slab_unreclaimable:11676kB kernel_stack:1952kB pagetables:5576kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:184 all_unreclaimable? yes
[  324.238987] lowmem_reserve[]: 0 0 0 0
[  324.240614] Node 0 DMA: 0*4kB 0*8kB 1*16kB (U) 2*32kB (U) 3*64kB (U) 0*128kB 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15888kB
[  324.244417] Node 0 DMA32: 38*4kB (UM) 24*8kB (UME) 146*16kB (UME) 139*32kB (UME) 52*64kB (UME) 11*128kB (UME) 2*256kB (UM) 1*512kB (M) 0*1024kB 0*2048kB 0*4096kB = 12888kB
[  324.249520] Node 0 Normal: 24*4kB (UM) 0*8kB 2*16kB (U) 29*32kB (U) 16*64kB (UM) 1*128kB (U) 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 3744kB
[  324.253481] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  324.255910] 4219 total pagecache pages
[  324.257497] 0 pages in swap cache
[  324.258996] Swap cache stats: add 0, delete 0, find 0/0
[  324.260835] Free swap  = 0kB
[  324.262243] Total swap = 0kB
[  324.263648] 1310589 pages RAM
[  324.265051] 0 pages HighMem/MovableOnly
[  324.266607] 109257 pages reserved
[  324.268079] 0 pages hwpoisoned
[  324.269503] Showing busy workqueues and worker pools:
[  324.271285] workqueue events: flags=0x0
[  324.272865]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=3/256
[  324.274933]     pending: vmstat_shepherd, vmpressure_work_fn, vmw_fb_dirty_flush [vmwgfx]
[  324.277426] workqueue events_freezable_power_: flags=0x84
[  324.279303]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  324.281398]     in-flight: 9698:disk_events_workfn
[  324.283242] workqueue vmstat: flags=0xc
[  324.284849]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  324.286947]     pending: vmstat_update
[  324.288647] pool 2: cpus=1 node=0 flags=0x0 nice=0 workers=10 idle: 9696 14 9665 9701 9675 9664 407 46 9691
(...snipped...)
[  334.771342] Node 0 Normal free:3624kB min:3632kB low:4540kB high:5448kB active_anon:1950860kB inactive_anon:5960kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1820kB shmem:7112kB slab_reclaimable:3068kB slab_unreclaimable:11676kB kernel_stack:1952kB pagetables:5576kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:184 all_unreclaimable? yes
(...snipped...)
[  334.792901] Node 0 Normal: 24*4kB (UM) 0*8kB 2*16kB (U) 29*32kB (U) 16*64kB (UM) 1*128kB (U) 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 3744kB
(...snipped...)
[  345.351647] Node 0 Normal free:3624kB min:3632kB low:4540kB high:5448kB active_anon:1950860kB inactive_anon:5960kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1820kB shmem:7112kB slab_reclaimable:3068kB slab_unreclaimable:11676kB kernel_stack:1952kB pagetables:5576kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:184 all_unreclaimable? yes
(...snipped...)
[  345.373938] Node 0 Normal: 24*4kB (UM) 0*8kB 2*16kB (U) 29*32kB (U) 16*64kB (UM) 1*128kB (U) 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 3744kB
(...snipped...)
[  355.983345] Node 0 Normal free:3624kB min:3632kB low:4540kB high:5448kB active_anon:1950860kB inactive_anon:5960kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1820kB shmem:7112kB slab_reclaimable:3068kB slab_unreclaimable:11676kB kernel_stack:1952kB pagetables:5576kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:184 all_unreclaimable? yes
(...snipped...)
[  356.008948] Node 0 Normal: 24*4kB (UM) 0*8kB 2*16kB (U) 29*32kB (U) 16*64kB (UM) 1*128kB (U) 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 3744kB
(...snipped...)
[  366.569312] Node 0 Normal free:3624kB min:3632kB low:4540kB high:5448kB active_anon:1950860kB inactive_anon:5960kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1820kB shmem:7112kB slab_reclaimable:3068kB slab_unreclaimable:11676kB kernel_stack:1952kB pagetables:5576kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
(...snipped...)
[  366.591131] Node 0 Normal: 24*4kB (UM) 0*8kB 2*16kB (U) 29*32kB (U) 16*64kB (UM) 1*128kB (U) 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 3744kB
(...snipped...)
[  377.255040] Node 0 Normal free:3624kB min:3632kB low:4540kB high:5448kB active_anon:1950860kB inactive_anon:5960kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1820kB shmem:7112kB slab_reclaimable:3068kB slab_unreclaimable:11676kB kernel_stack:1952kB pagetables:5576kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
(...snipped...)
[  377.276782] Node 0 Normal: 24*4kB (UM) 0*8kB 2*16kB (U) 29*32kB (U) 16*64kB (UM) 1*128kB (U) 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 3744kB
(...snipped...)
[  387.948890] Node 0 Normal free:3624kB min:3632kB low:4540kB high:5448kB active_anon:1950860kB inactive_anon:5960kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1820kB shmem:7112kB slab_reclaimable:3068kB slab_unreclaimable:11676kB kernel_stack:1952kB pagetables:5576kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
(...snipped...)
[  387.970629] Node 0 Normal: 24*4kB (UM) 0*8kB 2*16kB (U) 29*32kB (U) 16*64kB (UM) 1*128kB (U) 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 3744kB
(...snipped...)
[  398.582824] Node 0 Normal free:3624kB min:3632kB low:4540kB high:5448kB active_anon:1950860kB inactive_anon:5960kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1820kB shmem:7112kB slab_reclaimable:3068kB slab_unreclaimable:11676kB kernel_stack:1952kB pagetables:5576kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
(...snipped...)
[  398.604575] Node 0 Normal: 24*4kB (UM) 0*8kB 2*16kB (U) 29*32kB (U) 16*64kB (UM) 1*128kB (U) 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 3744kB
(...snipped...)
[  409.307406] Node 0 Normal free:3624kB min:3632kB low:4540kB high:5448kB active_anon:1950860kB inactive_anon:5960kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1820kB shmem:7112kB slab_reclaimable:3068kB slab_unreclaimable:11676kB kernel_stack:1952kB pagetables:5576kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
(...snipped...)
[  409.329012] Node 0 Normal: 24*4kB (UM) 0*8kB 2*16kB (U) 29*32kB (U) 16*64kB (UM) 1*128kB (U) 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 3744kB
(...snipped...)
[  419.866932] Node 0 Normal free:3624kB min:3632kB low:4540kB high:5448kB active_anon:1950860kB inactive_anon:5960kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1820kB shmem:7112kB slab_reclaimable:3068kB slab_unreclaimable:11676kB kernel_stack:1952kB pagetables:5576kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
(...snipped...)
[  419.888642] Node 0 Normal: 24*4kB (UM) 0*8kB 2*16kB (U) 29*32kB (U) 16*64kB (UM) 1*128kB (U) 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 3744kB
(...snipped...)
[  430.444391] Node 0 Normal free:3624kB min:3632kB low:4540kB high:5448kB active_anon:1950860kB inactive_anon:5960kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1820kB shmem:7112kB slab_reclaimable:3068kB slab_unreclaimable:11676kB kernel_stack:1952kB pagetables:5576kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
(...snipped...)
[  430.469660] Node 0 Normal: 24*4kB (UM) 0*8kB 3*16kB (U) 29*32kB (U) 16*64kB (UM) 1*128kB (U) 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 3760kB
(...snipped...)
[  441.055258] Node 0 Normal free:3624kB min:3632kB low:4540kB high:5448kB active_anon:1950860kB inactive_anon:5960kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1820kB shmem:7112kB slab_reclaimable:3068kB slab_unreclaimable:11676kB kernel_stack:1952kB pagetables:5576kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
(...snipped...)
[  441.078312] Node 0 Normal: 24*4kB (UM) 0*8kB 3*16kB (U) 29*32kB (U) 16*64kB (UM) 1*128kB (U) 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 3760kB
(...snipped...)
[  451.624394] Node 0 Normal free:3624kB min:3632kB low:4540kB high:5448kB active_anon:1950860kB inactive_anon:5960kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1820kB shmem:7112kB slab_reclaimable:3068kB slab_unreclaimable:11676kB kernel_stack:1952kB pagetables:5576kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
(...snipped...)
[  451.646614] Node 0 Normal: 24*4kB (UM) 0*8kB 3*16kB (U) 29*32kB (U) 16*64kB (UM) 1*128kB (U) 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 3760kB
(...snipped...)
[  461.701021] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
(...snipped...)
[  461.798182] MemAlloc: kworker/1:8(9698) seq=10 gfp=0x2400000 order=0 delay=147661
[  461.800145] kworker/1:8     R  running task        0  9698      2 0x00000080
[  461.802061] Workqueue: events_freezable_power_ disk_events_workfn
(...snipped...)
[  462.141865] Mem-Info:
[  462.142877] active_anon:1165831 inactive_anon:3486 isolated_anon:0
[  462.142877]  active_file:1 inactive_file:0 isolated_file:0
[  462.142877]  unevictable:0 dirty:0 writeback:0 unstable:0
[  462.142877]  slab_reclaimable:1906 slab_unreclaimable:5202
[  462.142877]  mapped:1175 shmem:4204 pagetables:2555 bounce:0
[  462.142877]  free:8087 free_pcp:0 free_cma:0
[  462.152641] Node 0 DMA free:15888kB min:28kB low:32kB high:40kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  462.161919] lowmem_reserve[]: 0 2708 4673 4673
[  462.163515] Node 0 DMA32 free:12836kB min:5008kB low:6260kB high:7512kB active_anon:2712464kB inactive_anon:7984kB active_file:4kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3129216kB managed:2776588kB mlocked:0kB dirty:0kB writeback:0kB mapped:2880kB shmem:9704kB slab_reclaimable:4556kB slab_unreclaimable:9116kB kernel_stack:1184kB pagetables:4644kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  462.174286] lowmem_reserve[]: 0 0 1965 1965
[  462.175919] Node 0 Normal free:3624kB min:3632kB low:4540kB high:5448kB active_anon:1950860kB inactive_anon:5960kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1820kB shmem:7112kB slab_reclaimable:3068kB slab_unreclaimable:11676kB kernel_stack:1952kB pagetables:5576kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  462.187058] lowmem_reserve[]: 0 0 0 0
[  462.188704] Node 0 DMA: 0*4kB 0*8kB 1*16kB (U) 2*32kB (U) 3*64kB (U) 0*128kB 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15888kB
[  462.192473] Node 0 DMA32: 38*4kB (UM) 24*8kB (UME) 146*16kB (UME) 139*32kB (UME) 52*64kB (UME) 11*128kB (UME) 2*256kB (UM) 1*512kB (M) 0*1024kB 0*2048kB 0*4096kB = 12888kB
[  462.198054] Node 0 Normal: 24*4kB (UM) 0*8kB 3*16kB (U) 29*32kB (U) 16*64kB (UM) 1*128kB (U) 0*256kB 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 3760kB
[  462.202046] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  462.204481] 4219 total pagecache pages
[  462.206068] 0 pages in swap cache
[  462.207569] Swap cache stats: add 0, delete 0, find 0/0
[  462.209416] Free swap  = 0kB
[  462.210833] Total swap = 0kB
[  462.212240] 1310589 pages RAM
[  462.213656] 0 pages HighMem/MovableOnly
[  462.215229] 109257 pages reserved
[  462.216696] 0 pages hwpoisoned
[  462.218116] Showing busy workqueues and worker pools:
[  462.219928] workqueue events: flags=0x0
[  462.221501]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=3/256
[  462.223582]     pending: vmstat_shepherd, vmpressure_work_fn, vmw_fb_dirty_flush [vmwgfx]
[  462.226085] workqueue events_power_efficient: flags=0x80
[  462.227943]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  462.230056]     pending: check_lifetime
[  462.231713] workqueue events_freezable_power_: flags=0x84
[  462.233577]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  462.235693]     in-flight: 9698:disk_events_workfn
[  462.237540] workqueue vmstat: flags=0xc
[  462.239172]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  462.241287]     pending: vmstat_update
[  462.242970] pool 2: cpus=1 node=0 flags=0x0 nice=0 workers=10 idle: 9696 14 9665 9701 9675 9664 407 46 9691
----------

Above result was obtained using below patch on Linux 4.4.

----------
diff --git a/include/linux/sched.h b/include/linux/sched.h
index fa39434..daf2a1a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1375,6 +1375,28 @@ struct tlbflush_unmap_batch {
 	bool writable;
 };
 
+struct memalloc_info {
+	/* For locking and progress monitoring. */
+	unsigned int sequence;
+	/*
+	 * 0: not doing __GFP_RECLAIM allocation.
+	 * 1: doing non-recursive __GFP_RECLAIM allocation.
+	 * 2: doing recursive __GFP_RECLAIM allocation.
+	 */
+	u8 valid;
+	/*
+	 * bit 0: Will be reported as OOM victim.
+	 * bit 1: Will be reported as dying task.
+	 * bit 2: Will be reported as stalling task.
+	 */
+	u8 type;
+	/* Started time in jiffies as of valid == 1. */
+	unsigned long start;
+	/* Requested order and gfp flags as of valid == 1. */
+	unsigned int order;
+	gfp_t gfp;
+};
+
 struct task_struct {
 	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
 	void *stack;
@@ -1813,6 +1835,9 @@ struct task_struct {
 	unsigned long	task_state_change;
 #endif
 	int pagefault_disabled;
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	struct memalloc_info memalloc;
+#endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
diff --git a/include/linux/sched/sysctl.h b/include/linux/sched/sysctl.h
index c9e4731..fb3004a 100644
--- a/include/linux/sched/sysctl.h
+++ b/include/linux/sched/sysctl.h
@@ -9,6 +9,9 @@ extern int sysctl_hung_task_warnings;
 extern int proc_dohung_task_timeout_secs(struct ctl_table *table, int write,
 					 void __user *buffer,
 					 size_t *lenp, loff_t *ppos);
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+extern unsigned long sysctl_memalloc_task_timeout_secs;
+#endif
 #else
 /* Avoid need for ifdefs elsewhere in the code */
 enum { sysctl_hung_task_timeout_secs = 0 };
diff --git a/kernel/fork.c b/kernel/fork.c
index 1155eac..894221df 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1416,6 +1416,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->sequential_io_avg	= 0;
 #endif
 
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	p->memalloc.sequence = 0;
+#endif
+
 	/* Perform scheduler related setup. Assign this task to a CPU. */
 	retval = sched_fork(clone_flags, p);
 	if (retval)
diff --git a/kernel/hung_task.c b/kernel/hung_task.c
index e0f90c2..2abebb9 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -16,6 +16,7 @@
 #include <linux/export.h>
 #include <linux/sysctl.h>
 #include <linux/utsname.h>
+#include <linux/console.h>
 #include <trace/events/sched.h>
 
 /*
@@ -72,6 +73,207 @@ static struct notifier_block panic_block = {
 	.notifier_call = hung_task_panic,
 };
 
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+/*
+ * Zero means infinite timeout - no checking done:
+ */
+unsigned long __read_mostly sysctl_memalloc_task_timeout_secs =
+	CONFIG_DEFAULT_MEMALLOC_TASK_TIMEOUT;
+static struct memalloc_info memalloc; /* Filled by is_stalling_task(). */
+
+static long memalloc_timeout_jiffies(unsigned long last_checked, long timeout)
+{
+	struct task_struct *g, *p;
+	long t;
+	unsigned long delta;
+
+	/* timeout of 0 will disable the watchdog */
+	if (!timeout)
+		return MAX_SCHEDULE_TIMEOUT;
+	/* At least wait for timeout duration. */
+	t = last_checked - jiffies + timeout * HZ;
+	if (t > 0)
+		return t;
+	/* Calculate how long to wait more. */
+	t = timeout * HZ;
+	delta = t - jiffies;
+
+	/*
+	 * We might see outdated values in "struct memalloc_info" here.
+	 * We will recheck later using is_stalling_task().
+	 */
+	preempt_disable();
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		if (likely(!p->memalloc.valid))
+			continue;
+		t = min_t(long, t, p->memalloc.start + delta);
+		if (unlikely(t <= 0))
+			goto stalling;
+	}
+ stalling:
+	rcu_read_unlock();
+	preempt_enable();
+	return t;
+}
+
+/**
+ * is_stalling_task - Check and copy a task's memalloc variable.
+ *
+ * @task:   A task to check.
+ * @expire: Timeout in jiffies.
+ *
+ * Returns true if a task is stalling, false otherwise.
+ */
+static bool is_stalling_task(const struct task_struct *task,
+			     const unsigned long expire)
+{
+	const struct memalloc_info *m = &task->memalloc;
+
+	/*
+	 * If start_memalloc_timer() is updating "struct memalloc_info" now,
+	 * we can ignore it because timeout jiffies cannot be expired as soon
+	 * as updating it completes.
+	 */
+	if (!m->valid || (m->sequence & 1))
+		return false;
+	smp_rmb(); /* Block start_memalloc_timer(). */
+	memalloc.start = m->start;
+	memalloc.order = m->order;
+	memalloc.gfp = m->gfp;
+	smp_rmb(); /* Unblock start_memalloc_timer(). */
+	memalloc.sequence = m->sequence;
+	/*
+	 * If start_memalloc_timer() started updating it while we read it,
+	 * we can ignore it for the same reason.
+	 */
+	if (!m->valid || (memalloc.sequence & 1))
+		return false;
+	/* This is a valid "struct memalloc_info". Check for timeout. */
+	return time_after_eq(expire, memalloc.start);
+}
+
+/* Check for memory allocation stalls. */
+static void check_memalloc_stalling_tasks(unsigned long timeout)
+{
+	char buf[128];
+	struct task_struct *g, *p;
+	unsigned long now;
+	unsigned long expire;
+	unsigned int sigkill_pending;
+	unsigned int memdie_pending;
+	unsigned int stalling_tasks;
+
+	cond_resched();
+	now = jiffies;
+	/*
+	 * Report tasks that stalled for more than half of timeout duration
+	 * because such tasks might be correlated with tasks that already
+	 * stalled for full timeout duration.
+	 */
+	expire = now - timeout * (HZ / 2);
+	/* Count stalling tasks, dying and victim tasks. */
+	sigkill_pending = 0;
+	memdie_pending = 0;
+	stalling_tasks = 0;
+	preempt_disable();
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		u8 type = 0;
+
+		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
+			type |= 1;
+			memdie_pending++;
+		}
+		if (fatal_signal_pending(p)) {
+			type |= 2;
+			sigkill_pending++;
+		}
+		if (is_stalling_task(p, expire)) {
+			type |= 4;
+			stalling_tasks++;
+		}
+		p->memalloc.type = type;
+	}
+	rcu_read_unlock();
+	preempt_enable();
+	if (!stalling_tasks)
+		return;
+	/* Report stalling tasks, dying and victim tasks. */
+	pr_warn("MemAlloc-Info: %u stalling task, %u dying task, %u victim task.\n",
+		stalling_tasks, sigkill_pending, memdie_pending);
+	cond_resched();
+	preempt_disable();
+	rcu_read_lock();
+ restart_report:
+	for_each_process_thread(g, p) {
+		bool can_cont;
+		u8 type;
+
+		if (likely(!p->memalloc.type))
+			continue;
+		p->memalloc.type = 0;
+		/* Recheck in case state changed meanwhile. */
+		type = 0;
+		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+			type |= 1;
+		if (fatal_signal_pending(p))
+			type |= 2;
+		if (is_stalling_task(p, expire)) {
+			type |= 4;
+			snprintf(buf, sizeof(buf),
+				 " seq=%u gfp=0x%x order=%u delay=%lu",
+				 memalloc.sequence >> 1, memalloc.gfp,
+				 memalloc.order, now - memalloc.start);
+		} else {
+			buf[0] = '\0';
+		}
+		if (unlikely(!type))
+			continue;
+		/*
+		 * Victim tasks get pending SIGKILL removed before arriving at
+		 * do_exit(). Therefore, print " exiting" instead for " dying".
+		 */
+		pr_warn("MemAlloc: %s(%u)%s%s%s%s%s\n", p->comm, p->pid, buf,
+			(p->state & TASK_UNINTERRUPTIBLE) ?
+			" uninterruptible" : "",
+			(p->flags & PF_EXITING) ? " exiting" : "",
+			(type & 2) ? " dying" : "",
+			(type & 1) ? " victim" : "");
+		sched_show_task(p);
+		debug_show_held_locks(p);
+		/*
+		 * Since there could be thousands of tasks to report, we always
+		 * sleep and try to flush printk() buffer after each report, in
+		 * order to avoid RCU stalls and reduce possibility of messages
+		 * being dropped by continuous printk() flood.
+		 *
+		 * Since not yet reported tasks have p->memalloc.type > 0, we
+		 * can simply restart this loop in case "g" or "p" went away.
+		 */
+		get_task_struct(g);
+		get_task_struct(p);
+		rcu_read_unlock();
+		preempt_enable();
+		schedule_timeout_interruptible(1);
+		preempt_disable();
+		rcu_read_lock();
+		can_cont = pid_alive(g) && pid_alive(p);
+		put_task_struct(p);
+		put_task_struct(g);
+		if (!can_cont)
+			goto restart_report;
+	}
+	rcu_read_unlock();
+	preempt_enable();
+	cond_resched();
+	/* Show memory information. (SysRq-m) */
+	show_mem(0);
+	/* Show workqueue state. */
+	show_workqueue_state();
+}
+#endif /* CONFIG_DETECT_MEMALLOC_STALL_TASK */
+
 static void check_hung_task(struct task_struct *t, unsigned long timeout)
 {
 	unsigned long switch_count = t->nvcsw + t->nivcsw;
@@ -185,10 +387,12 @@ static void check_hung_uninterruptible_tasks(unsigned long timeout)
 	rcu_read_unlock();
 }
 
-static unsigned long timeout_jiffies(unsigned long timeout)
+static unsigned long hung_timeout_jiffies(long last_checked, long timeout)
 {
 	/* timeout of 0 will disable the watchdog */
-	return timeout ? timeout * HZ : MAX_SCHEDULE_TIMEOUT;
+	if (!timeout)
+		return MAX_SCHEDULE_TIMEOUT;
+	return last_checked - jiffies + timeout * HZ;
 }
 
 /*
@@ -224,18 +428,36 @@ EXPORT_SYMBOL_GPL(reset_hung_task_detector);
  */
 static int watchdog(void *dummy)
 {
+	unsigned long hung_last_checked = jiffies;
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	unsigned long stall_last_checked = hung_last_checked;
+#endif
+
 	set_user_nice(current, 0);
 
 	for ( ; ; ) {
 		unsigned long timeout = sysctl_hung_task_timeout_secs;
-
-		while (schedule_timeout_interruptible(timeout_jiffies(timeout)))
-			timeout = sysctl_hung_task_timeout_secs;
-
-		if (atomic_xchg(&reset_hung_task, 0))
+		long t = hung_timeout_jiffies(hung_last_checked, timeout);
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+		unsigned long timeout2 = sysctl_memalloc_task_timeout_secs;
+		long t2 = memalloc_timeout_jiffies(stall_last_checked,
+						   timeout2);
+
+		if (t2 <= 0) {
+			check_memalloc_stalling_tasks(timeout2);
+			stall_last_checked = jiffies;
 			continue;
-
-		check_hung_uninterruptible_tasks(timeout);
+		}
+#else
+		long t2 = t;
+#endif
+		if (t <= 0) {
+			if (!atomic_xchg(&reset_hung_task, 0))
+				check_hung_uninterruptible_tasks(timeout);
+			hung_last_checked = jiffies;
+			continue;
+		}
+		schedule_timeout_interruptible(min(t, t2));
 	}
 
 	return 0;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index dc6858d..96460aa 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1061,6 +1061,16 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &neg_one,
 	},
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	{
+		.procname	= "memalloc_task_timeout_secs",
+		.data		= &sysctl_memalloc_task_timeout_secs,
+		.maxlen		= sizeof(unsigned long),
+		.mode		= 0644,
+		.proc_handler	= proc_dohung_task_timeout_secs,
+		.extra2		= &hung_task_timeout_max,
+	},
+#endif
 #endif
 #ifdef CONFIG_COMPAT
 	{
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 8c15b29..26d2c91 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -812,6 +812,30 @@ config BOOTPARAM_HUNG_TASK_PANIC_VALUE
 	default 0 if !BOOTPARAM_HUNG_TASK_PANIC
 	default 1 if BOOTPARAM_HUNG_TASK_PANIC
 
+config DETECT_MEMALLOC_STALL_TASK
+	bool "Detect tasks stalling inside memory allocator"
+	default n
+	depends on DETECT_HUNG_TASK
+	help
+	  This option emits warning messages and traces when memory
+	  allocation requests are stalling, in order to catch unexplained
+	  hangups/reboots caused by memory allocation stalls.
+
+config DEFAULT_MEMALLOC_TASK_TIMEOUT
+	int "Default timeout for stalling task detection (in seconds)"
+	depends on DETECT_MEMALLOC_STALL_TASK
+	default 10
+	help
+	  This option controls the default timeout (in seconds) used
+	  to determine when a task has become non-responsive and should
+	  be considered stalling inside memory allocator.
+
+	  It can be adjusted at runtime via the kernel.memalloc_task_timeout_secs
+	  sysctl or by writing a value to
+	  /proc/sys/kernel/memalloc_task_timeout_secs.
+
+	  A timeout of 0 disables the check. The default is 10 seconds.
+
 endmenu # "Debug lockups and hangs"
 
 config PANIC_ON_OOPS
diff --git a/mm/mlock.c b/mm/mlock.c
index 339d9e0..d6006b1 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -172,7 +172,7 @@ static void __munlock_isolation_failed(struct page *page)
  */
 unsigned int munlock_vma_page(struct page *page)
 {
-	unsigned int nr_pages;
+	int nr_pages;
 	struct zone *zone = page_zone(page);
 
 	/* For try_to_munlock() and to serialize with page migration */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d666df..4e4e4b6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3165,6 +3165,37 @@ got_pg:
 	return page;
 }
 
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+static void start_memalloc_timer(const gfp_t gfp_mask, const int order)
+{
+	struct memalloc_info *m = &current->memalloc;
+
+	/* We don't check for stalls for !__GFP_RECLAIM allocations. */
+	if (!(gfp_mask & __GFP_RECLAIM))
+		return;
+	/* We don't check for stalls for nested __GFP_RECLAIM allocations */
+	if (!m->valid) {
+		m->sequence++;
+		smp_wmb(); /* Block is_stalling_task(). */
+		m->start = jiffies;
+		m->order = order;
+		m->gfp = gfp_mask;
+		smp_wmb(); /* Unblock is_stalling_task(). */
+		m->sequence++;
+	}
+	m->valid++;
+}
+
+static void stop_memalloc_timer(const gfp_t gfp_mask)
+{
+	if (gfp_mask & __GFP_RECLAIM)
+		current->memalloc.valid--;
+}
+#else
+#define start_memalloc_timer(gfp_mask, order) do { } while (0)
+#define stop_memalloc_timer(gfp_mask) do { } while (0)
+#endif
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
@@ -3232,7 +3263,9 @@ retry_cpuset:
 		alloc_mask = memalloc_noio_flags(gfp_mask);
 		ac.spread_dirty_pages = false;
 
+		start_memalloc_timer(alloc_mask, order);
 		page = __alloc_pages_slowpath(alloc_mask, order, &ac);
+		stop_memalloc_timer(alloc_mask);
 	}
 
 	if (kmemcheck_enabled && page)
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
