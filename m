Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id E39BA6B0038
	for <linux-mm@kvack.org>; Sat, 28 Jan 2017 10:27:47 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id f9so240203818otd.4
        for <linux-mm@kvack.org>; Sat, 28 Jan 2017 07:27:47 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w83si3379886oib.247.2017.01.28.07.27.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 28 Jan 2017 07:27:45 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages per zone
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170125101957.GA17632@lst.de>
	<20170125104605.GI32377@dhcp22.suse.cz>
	<201701252009.IHG13512.OFOJFSVLtOQMFH@I-love.SAKURA.ne.jp>
	<20170125130014.GO32377@dhcp22.suse.cz>
	<20170127144906.GB4148@dhcp22.suse.cz>
In-Reply-To: <20170127144906.GB4148@dhcp22.suse.cz>
Message-Id: <201701290027.AFB30799.FVtFLOOOJMSHQF@I-love.SAKURA.ne.jp>
Date: Sun, 29 Jan 2017 00:27:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> Tetsuo,
> before we settle on the proper fix for this issue, could you give the
> patch a try and try to reproduce the too_many_isolated() issue or
> just see whether patch [1] has any negative effect on your oom stress
> testing?
> 
> [1] http://lkml.kernel.org/r/20170119112336.GN30786@dhcp22.suse.cz

I tested with both [1] and below patch applied on linux-next-20170125 and
the result is at http://I-love.SAKURA.ne.jp/tmp/serial-20170128.txt.xz .

Regarding below patch, it helped avoiding complete memory depletion with
large write() request. I don't know whether below patch helps avoiding
complete memory depletion when reading large amount (in other words, I
don't know whether this check is done for large read() request). But
I believe that __GFP_KILLABLE (despite the limitation that there are
unkillable waits in the reclaim path) is better solution compared to
scattering around fatal_signal_pending() in the callers. The reason
we check SIGKILL here is to avoid allocating memory more than needed.
If we check SIGKILL in the entry point of __alloc_pages_nodemask() and
retry: label in __alloc_pages_slowpath(), we waste 0 page. Regardless
of whether the OOM killer is invoked, whether memory can be allocated
without direct reclaim operation, not allocating memory unless needed
(in other words, allow page allocator fail immediately if the caller
can give up on SIGKILL and SIGKILL is pending) makes sense. It will
reduce possibility of OOM livelock on CONFIG_MMU=n kernels where the
OOM reaper is not available.

> 
> On Wed 25-01-17 14:00:14, Michal Hocko wrote:
> [...]
> > From 362da5cac527146a341300c2ca441245c16043e8 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Wed, 25 Jan 2017 11:06:37 +0100
> > Subject: [PATCH] fs: break out of iomap_file_buffered_write on fatal signals
> > 
> > Tetsuo has noticed that an OOM stress test which performs large write
> > requests can cause the full memory reserves depletion. He has tracked
> > this down to the following path
> > 	__alloc_pages_nodemask+0x436/0x4d0
> > 	alloc_pages_current+0x97/0x1b0
> > 	__page_cache_alloc+0x15d/0x1a0          mm/filemap.c:728
> > 	pagecache_get_page+0x5a/0x2b0           mm/filemap.c:1331
> > 	grab_cache_page_write_begin+0x23/0x40   mm/filemap.c:2773
> > 	iomap_write_begin+0x50/0xd0             fs/iomap.c:118
> > 	iomap_write_actor+0xb5/0x1a0            fs/iomap.c:190
> > 	? iomap_write_end+0x80/0x80             fs/iomap.c:150
> > 	iomap_apply+0xb3/0x130                  fs/iomap.c:79
> > 	iomap_file_buffered_write+0x68/0xa0     fs/iomap.c:243
> > 	? iomap_write_end+0x80/0x80
> > 	xfs_file_buffered_aio_write+0x132/0x390 [xfs]
> > 	? remove_wait_queue+0x59/0x60
> > 	xfs_file_write_iter+0x90/0x130 [xfs]
> > 	__vfs_write+0xe5/0x140
> > 	vfs_write+0xc7/0x1f0
> > 	? syscall_trace_enter+0x1d0/0x380
> > 	SyS_write+0x58/0xc0
> > 	do_syscall_64+0x6c/0x200
> > 	entry_SYSCALL64_slow_path+0x25/0x25
> > 
> > the oom victim has access to all memory reserves to make a forward
> > progress to exit easier. But iomap_file_buffered_write and other callers
> > of iomap_apply loop to complete the full request. We need to check for
> > fatal signals and back off with a short write instead. As the
> > iomap_apply delegates all the work down to the actor we have to hook
> > into those. All callers that work with the page cache are calling
> > iomap_write_begin so we will check for signals there. dax_iomap_actor
> > has to handle the situation explicitly because it copies data to the
> > userspace directly. Other callers like iomap_page_mkwrite work on a
> > single page or iomap_fiemap_actor do not allocate memory based on the
> > given len.
> > 
> > Fixes: 68a9f5e7007c ("xfs: implement iomap based buffered write path")
> > Cc: stable # 4.8+
> > Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  fs/dax.c   | 5 +++++
> >  fs/iomap.c | 3 +++
> >  2 files changed, 8 insertions(+)
> > 
> > diff --git a/fs/dax.c b/fs/dax.c
> > index 413a91db9351..0e263dacf9cf 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -1033,6 +1033,11 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
> >  		struct blk_dax_ctl dax = { 0 };
> >  		ssize_t map_len;
> >  
> > +		if (fatal_signal_pending(current)) {
> > +			ret = -EINTR;
> > +			break;
> > +		}
> > +
> >  		dax.sector = dax_iomap_sector(iomap, pos);
> >  		dax.size = (length + offset + PAGE_SIZE - 1) & PAGE_MASK;
> >  		map_len = dax_map_atomic(iomap->bdev, &dax);
> > diff --git a/fs/iomap.c b/fs/iomap.c
> > index e57b90b5ff37..691eada58b06 100644
> > --- a/fs/iomap.c
> > +++ b/fs/iomap.c
> > @@ -114,6 +114,9 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
> >  
> >  	BUG_ON(pos + len > iomap->offset + iomap->length);
> >  
> > +	if (fatal_signal_pending(current))
> > +		return -EINTR;
> > +
> >  	page = grab_cache_page_write_begin(inode->i_mapping, index, flags);
> >  	if (!page)
> >  		return -ENOMEM;
> > -- 
> > 2.11.0

Regarding [1], it helped avoiding the too_many_isolated() issue. I can't
tell whether it has any negative effect, but I got on the first trial that
all allocating threads are blocked on wait_for_completion() from flush_work()
in drain_all_pages() introduced by "mm, page_alloc: drain per-cpu pages from
workqueue context". There was no warn_alloc() stall warning message afterwords.

----------
[  540.039842] kworker/1:1: page allocation stalls for 10079ms, order:0, mode:0x14001c2(GFP_KERNEL|__GFP_HIGHMEM|__GFP_COLD), nodemask=(null)
[  540.041961] kthreadd invoked oom-killer: gfp_mask=0x16040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK), nodemask=(null),  order=2, oom_score_adj=0
[  540.041970] kthreadd cpuset=/ mems_allowed=0
[  540.041984] CPU: 3 PID: 2 Comm: kthreadd Not tainted 4.10.0-rc5-next-20170125+ #495
[  540.041987] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  540.041989] Call Trace:
[  540.042008]  dump_stack+0x85/0xc9
[  540.042016]  dump_header+0x9f/0x296
[  540.042028]  ? trace_hardirqs_on+0xd/0x10
[  540.042039]  oom_kill_process+0x219/0x400
[  540.042046]  out_of_memory+0x13d/0x580
[  540.042049]  ? out_of_memory+0x20d/0x580
[  540.042058]  __alloc_pages_slowpath+0x951/0xe02
[  540.042063]  ? deactivate_slab+0x1fb/0x690
[  540.042082]  __alloc_pages_nodemask+0x382/0x3d0
[  540.042091]  new_slab+0x450/0x6b0
[  540.042100]  ___slab_alloc+0x3a3/0x620
[  540.042109]  ? copy_process.part.31+0x122/0x2200
[  540.042116]  ? cpuacct_charge+0x38/0x1e0
[  540.042122]  ? copy_process.part.31+0x122/0x2200
[  540.042129]  __slab_alloc+0x46/0x7d
[  540.042135]  kmem_cache_alloc_node+0xab/0x3a0
[  540.042144]  copy_process.part.31+0x122/0x2200
[  540.042150]  ? cpuacct_charge+0xf3/0x1e0
[  540.042153]  ? cpuacct_charge+0x38/0x1e0
[  540.042164]  ? kthread_create_on_node+0x70/0x70
[  540.042168]  ? finish_task_switch+0x70/0x240
[  540.042175]  _do_fork+0xf3/0x750
[  540.042183]  ? kthreadd+0x2f2/0x3c0
[  540.042193]  kernel_thread+0x29/0x30
[  540.042196]  kthreadd+0x35a/0x3c0
[  540.042206]  ? ret_from_fork+0x31/0x40
[  540.042218]  ? kthread_create_on_cpu+0xb0/0xb0
[  540.042225]  ret_from_fork+0x31/0x40
[  540.042237] Mem-Info:
[  540.042248] active_anon:170208 inactive_anon:2096 isolated_anon:0
[  540.042248]  active_file:40034 inactive_file:40034 isolated_file:32
[  540.042248]  unevictable:0 dirty:78514 writeback:1568 unstable:0
[  540.042248]  slab_reclaimable:19763 slab_unreclaimable:47744
[  540.042248]  mapped:491 shmem:2162 pagetables:4842 bounce:0
[  540.042248]  free:12698 free_pcp:637 free_cma:0
[  540.042258] Node 0 active_anon:680832kB inactive_anon:8384kB active_file:160136kB inactive_file:160136kB unevictable:0kB isolated(anon):0kB isolated(file):128kB mapped:1964kB dirty:314056kB writeback:6272kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 217088kB anon_thp: 8648kB writeback_tmp:0kB unstable:0kB pages_scanned:561618 all_unreclaimable? yes
[  540.042260] Node 0 DMA free:6248kB min:476kB low:592kB high:708kB active_anon:9492kB inactive_anon:0kB active_file:4kB inactive_file:4kB unevictable:0kB writepending:8kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:48kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:28kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  540.042270] lowmem_reserve[]: 0 1443 1443 1443
[  540.042279] Node 0 DMA32 free:44544kB min:44576kB low:55720kB high:66864kB active_anon:671340kB inactive_anon:8384kB active_file:160132kB inactive_file:160132kB unevictable:0kB writepending:320320kB present:2080640kB managed:1478648kB mlocked:0kB slab_reclaimable:79004kB slab_unreclaimable:190944kB kernel_stack:12240kB pagetables:19340kB bounce:0kB free_pcp:2548kB local_pcp:728kB free_cma:0kB
[  540.042288] lowmem_reserve[]: 0 0 0 0
[  540.042296] Node 0 DMA: 2*4kB (UM) 0*8kB 2*16kB (UE) 4*32kB (UME) 3*64kB (ME) 2*128kB (UM) 2*256kB (UE) 2*512kB (ME) 2*1024kB (UE) 1*2048kB (E) 0*4096kB = 6248kB
[  540.042330] Node 0 DMA32: 764*4kB (UME) 1122*8kB (UME) 536*16kB (UME) 210*32kB (UME) 107*64kB (UE) 41*128kB (EH) 20*256kB (UME) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 44544kB
[  540.042363] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  540.042366] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  540.042368] 82262 total pagecache pages
[  540.042371] 0 pages in swap cache
[  540.042374] Swap cache stats: add 0, delete 0, find 0/0
[  540.042376] Free swap  = 0kB
[  540.042377] Total swap = 0kB
[  540.042380] 524157 pages RAM
[  540.042382] 0 pages HighMem/MovableOnly
[  540.042383] 150519 pages reserved
[  540.042384] 0 pages cma reserved
[  540.042386] 0 pages hwpoisoned
[  540.042390] Out of memory: Kill process 10688 (a.out) score 998 or sacrifice child
[  540.042401] Killed process 10688 (a.out) total-vm:14404kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  540.043111] oom_reaper: reaped process 10688 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  540.212629] kworker/1:1 cpuset=/ mems_allowed=0
[  540.214404] CPU: 1 PID: 51 Comm: kworker/1:1 Not tainted 4.10.0-rc5-next-20170125+ #495
[  540.216858] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  540.219901] Workqueue: events pcpu_balance_workfn
[  540.221740] Call Trace:
[  540.223154]  dump_stack+0x85/0xc9
[  540.224724]  warn_alloc+0x11e/0x1d0
[  540.226333]  __alloc_pages_slowpath+0x3d4/0xe02
[  540.228160]  __alloc_pages_nodemask+0x382/0x3d0
[  540.229970]  pcpu_populate_chunk+0xc2/0x440
[  540.231724]  pcpu_balance_workfn+0x615/0x670
[  540.233483]  ? process_one_work+0x194/0x760
[  540.235405]  process_one_work+0x22b/0x760
[  540.237133]  ? process_one_work+0x194/0x760
[  540.238943]  worker_thread+0x243/0x4b0
[  540.240588]  kthread+0x10f/0x150
[  540.242125]  ? process_one_work+0x760/0x760
[  540.243865]  ? kthread_create_on_node+0x70/0x70
[  540.245631]  ret_from_fork+0x31/0x40
[  540.247278] Mem-Info:
[  540.248572] active_anon:170208 inactive_anon:2096 isolated_anon:0
[  540.248572]  active_file:40163 inactive_file:40049 isolated_file:32
[  540.248572]  unevictable:0 dirty:78514 writeback:1568 unstable:0
[  540.248572]  slab_reclaimable:19763 slab_unreclaimable:47744
[  540.248572]  mapped:522 shmem:2162 pagetables:4842 bounce:0
[  540.248572]  free:12698 free_pcp:500 free_cma:0
[  540.259735] Node 0 active_anon:680832kB inactive_anon:8384kB active_file:160412kB inactive_file:160436kB unevictable:0kB isolated(anon):0kB isolated(file):128kB mapped:2088kB dirty:314056kB writeback:6272kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 217088kB anon_thp: 8648kB writeback_tmp:0kB unstable:0kB pages_scanned:519289 all_unreclaimable? yes
[  540.267919] Node 0 DMA free:6248kB min:476kB low:592kB high:708kB active_anon:9492kB inactive_anon:0kB active_file:4kB inactive_file:4kB unevictable:0kB writepending:8kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:48kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:28kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  540.276033] lowmem_reserve[]: 0 1443 1443 1443
[  540.277629] Node 0 DMA32 free:44544kB min:44576kB low:55720kB high:66864kB active_anon:671340kB inactive_anon:8384kB active_file:160408kB inactive_file:160432kB unevictable:0kB writepending:320320kB present:2080640kB managed:1478648kB mlocked:0kB slab_reclaimable:79004kB slab_unreclaimable:190944kB kernel_stack:12240kB pagetables:19340kB bounce:0kB free_pcp:2000kB local_pcp:352kB free_cma:0kB
[  540.286732] lowmem_reserve[]: 0 0 0 0
[  540.288204] Node 0 DMA: 2*4kB (UM) 0*8kB 2*16kB (UE) 4*32kB (UME) 3*64kB (ME) 2*128kB (UM) 2*256kB (UE) 2*512kB (ME) 2*1024kB (UE) 1*2048kB (E) 0*4096kB = 6248kB
[  540.292593] Node 0 DMA32: 738*4kB (ME) 1125*8kB (ME) 539*16kB (UME) 209*32kB (ME) 106*64kB (E) 42*128kB (UEH) 20*256kB (UME) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 44544kB
[  540.297228] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  540.299825] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  540.302365] 82400 total pagecache pages
[  540.304010] 0 pages in swap cache
[  540.305535] Swap cache stats: add 0, delete 0, find 0/0
[  540.307302] Free swap  = 0kB
[  540.308600] Total swap = 0kB
[  540.309915] 524157 pages RAM
[  540.311187] 0 pages HighMem/MovableOnly
[  540.312613] 150519 pages reserved
[  540.314026] 0 pages cma reserved
[  540.315325] 0 pages hwpoisoned
[  540.317504] kworker/1:1 invoked oom-killer: gfp_mask=0x14001c2(GFP_KERNEL|__GFP_HIGHMEM|__GFP_COLD), nodemask=(null),  order=0, oom_score_adj=0
[  540.320589] kworker/1:1 cpuset=/ mems_allowed=0
[  540.322213] CPU: 1 PID: 51 Comm: kworker/1:1 Not tainted 4.10.0-rc5-next-20170125+ #495
[  540.324410] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  540.327138] Workqueue: events pcpu_balance_workfn
[  540.328821] Call Trace:
[  540.330060]  dump_stack+0x85/0xc9
[  540.331449]  dump_header+0x9f/0x296
[  540.332925]  ? trace_hardirqs_on+0xd/0x10
[  540.334436]  oom_kill_process+0x219/0x400
[  540.335963]  out_of_memory+0x13d/0x580
[  540.337615]  ? out_of_memory+0x20d/0x580
[  540.339214]  __alloc_pages_slowpath+0x951/0xe02
[  540.340875]  __alloc_pages_nodemask+0x382/0x3d0
[  540.342544]  pcpu_populate_chunk+0xc2/0x440
[  540.344125]  pcpu_balance_workfn+0x615/0x670
[  540.345729]  ? process_one_work+0x194/0x760
[  540.347301]  process_one_work+0x22b/0x760
[  540.349042]  ? process_one_work+0x194/0x760
[  540.350616]  worker_thread+0x243/0x4b0
[  540.352245]  kthread+0x10f/0x150
[  540.353613]  ? process_one_work+0x760/0x760
[  540.355152]  ? kthread_create_on_node+0x70/0x70
[  540.356709]  ret_from_fork+0x31/0x40
[  540.358083] Mem-Info:
[  540.359191] active_anon:170208 inactive_anon:2096 isolated_anon:0
[  540.359191]  active_file:40103 inactive_file:40109 isolated_file:32
[  540.359191]  unevictable:0 dirty:78514 writeback:1568 unstable:0
[  540.359191]  slab_reclaimable:19763 slab_unreclaimable:47744
[  540.359191]  mapped:522 shmem:2162 pagetables:4842 bounce:0
[  540.359191]  free:12698 free_pcp:500 free_cma:0
[  540.369461] Node 0 active_anon:680832kB inactive_anon:8384kB active_file:160412kB inactive_file:160436kB unevictable:0kB isolated(anon):0kB isolated(file):128kB mapped:2088kB dirty:314056kB writeback:6272kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 217088kB anon_thp: 8648kB writeback_tmp:0kB unstable:0kB pages_scanned:519430 all_unreclaimable? yes
[  540.376876] Node 0 DMA free:6248kB min:476kB low:592kB high:708kB active_anon:9492kB inactive_anon:0kB active_file:4kB inactive_file:4kB unevictable:0kB writepending:8kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:48kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:28kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  540.384224] lowmem_reserve[]: 0 1443 1443 1443
[  540.385668] Node 0 DMA32 free:44544kB min:44576kB low:55720kB high:66864kB active_anon:671340kB inactive_anon:8384kB active_file:160408kB inactive_file:160432kB unevictable:0kB writepending:320320kB present:2080640kB managed:1478648kB mlocked:0kB slab_reclaimable:79004kB slab_unreclaimable:190944kB kernel_stack:12240kB pagetables:19340kB bounce:0kB free_pcp:2000kB local_pcp:352kB free_cma:0kB
[  540.394066] lowmem_reserve[]: 0 0 0 0
[  540.395479] Node 0 DMA: 2*4kB (UM) 0*8kB 2*16kB (UE) 4*32kB (UME) 3*64kB (ME) 2*128kB (UM) 2*256kB (UE) 2*512kB (ME) 2*1024kB (UE) 1*2048kB (E) 0*4096kB = 6248kB
[  540.399533] Node 0 DMA32: 738*4kB (ME) 1125*8kB (ME) 539*16kB (UME) 209*32kB (ME) 106*64kB (E) 42*128kB (UEH) 20*256kB (UME) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 44544kB
[  540.403793] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  540.406130] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  540.408490] 82400 total pagecache pages
[  540.409942] 0 pages in swap cache
[  540.411320] Swap cache stats: add 0, delete 0, find 0/0
[  540.412992] Free swap  = 0kB
[  540.414260] Total swap = 0kB
[  540.415633] 524157 pages RAM
[  540.416877] 0 pages HighMem/MovableOnly
[  540.418307] 150519 pages reserved
[  540.419695] 0 pages cma reserved
[  540.421020] 0 pages hwpoisoned
[  540.422293] Out of memory: Kill process 10689 (a.out) score 998 or sacrifice child
[  540.424450] Killed process 10689 (a.out) total-vm:14404kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  540.430407] oom_reaper: reaped process 10689 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  575.747685] BUG: workqueue lockup - pool cpus=2 node=0 flags=0x0 nice=0 stuck for 242s!
[  575.757497] Showing busy workqueues and worker pools:
[  575.765110] workqueue events: flags=0x0
[  575.772069]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=26/256
[  575.780544]     pending: free_work, vmpressure_work_fn, drain_local_pages_wq BAR(9811), vmw_fb_dirty_flush [vmwgfx], drain_local_pages_wq BAR(2506), drain_local_pages_wq BAR(812), drain_local_pages_wq BAR(2466), drain_local_pages_wq BAR(2485), drain_local_pages_wq BAR(3714), drain_local_pages_wq BAR(2862), drain_local_pages_wq BAR(827), drain_local_pages_wq BAR(527), drain_local_pages_wq BAR(9779), drain_local_pages_wq BAR(2484), drain_local_pages_wq BAR(932), drain_local_pages_wq BAR(2492), drain_local_pages_wq BAR(9820), drain_local_pages_wq BAR(811), drain_local_pages_wq BAR(1), drain_local_pages_wq BAR(2521), drain_local_pages_wq BAR(565), drain_local_pages_wq BAR(10420), drain_local_pages_wq BAR(9824), drain_local_pages_wq BAR(9749), drain_local_pages_wq BAR(2), drain_local_pages_wq BAR(9801)
[  575.827418] workqueue writeback: flags=0x4e
[  575.829234]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  575.831299]     in-flight: 425:wb_workfn wb_workfn
[  575.834155] workqueue xfs-eofblocks/sda1: flags=0xc
[  575.836083]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  575.838318]     in-flight: 123:xfs_eofblocks_worker [xfs]
[  575.840396] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=242s workers=2 manager: 80
[  575.843446] pool 256: cpus=0-127 flags=0x4 nice=0 hung=35s workers=3 idle: 424 423
[  605.951087] BUG: workqueue lockup - pool cpus=2 node=0 flags=0x0 nice=0 stuck for 272s!
[  605.961096] Showing busy workqueues and worker pools:
[  605.968703] workqueue events: flags=0x0
[  605.975212]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=27/256
[  605.982787]     pending: free_work, vmpressure_work_fn, drain_local_pages_wq BAR(9811), vmw_fb_dirty_flush [vmwgfx], drain_local_pages_wq BAR(2506), drain_local_pages_wq BAR(812), drain_local_pages_wq BAR(2466), drain_local_pages_wq BAR(2485), drain_local_pages_wq BAR(3714), drain_local_pages_wq BAR(2862), drain_local_pages_wq BAR(827), drain_local_pages_wq BAR(527), drain_local_pages_wq BAR(9779), drain_local_pages_wq BAR(2484), drain_local_pages_wq BAR(932), drain_local_pages_wq BAR(2492), drain_local_pages_wq BAR(9820), drain_local_pages_wq BAR(811), drain_local_pages_wq BAR(1), drain_local_pages_wq BAR(2521), drain_local_pages_wq BAR(565), drain_local_pages_wq BAR(10420), drain_local_pages_wq BAR(9824), drain_local_pages_wq BAR(9749), drain_local_pages_wq BAR(2), drain_local_pages_wq BAR(9801)
[  606.010284] , drain_local_pages_wq BAR(47)
[  606.012955] workqueue writeback: flags=0x4e
[  606.014860]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  606.016732]     in-flight: 425:wb_workfn wb_workfn
[  606.019085] workqueue mpt_poll_0: flags=0x8
[  606.020678]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  606.022521]     pending: mpt_fault_reset_work [mptbase]
[  606.024445] workqueue xfs-eofblocks/sda1: flags=0xc
[  606.026148]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  606.027992]     in-flight: 123:xfs_eofblocks_worker [xfs]
[  606.029904] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=272s workers=2 manager: 80
[  606.032120] pool 256: cpus=0-127 flags=0x4 nice=0 hung=65s workers=3 idle: 424 423
(...snipped...)
[  908.869406] sysrq: SysRq : Show State
[  908.875534]   task                        PC stack   pid father
[  908.883117] systemd         D11784     1      0 0x00000000
[  908.890352] Call Trace:
[  908.893121]  __schedule+0x345/0xdd0
[  908.895830]  ? __list_lru_count_one.isra.2+0x22/0x80
[  908.899036]  schedule+0x3d/0x90
[  908.901616]  schedule_timeout+0x287/0x540
[  908.904485]  ? wait_for_completion+0x4c/0x190
[  908.907488]  wait_for_completion+0x12c/0x190
[  908.910423]  ? wake_up_q+0x80/0x80
[  908.913060]  flush_work+0x230/0x310
[  908.915699]  ? flush_work+0x2b4/0x310
[  908.918382]  ? work_busy+0xb0/0xb0
[  908.920976]  drain_all_pages.part.88+0x319/0x390
[  908.923312]  ? drain_local_pages+0x30/0x30
[  908.924833]  __alloc_pages_slowpath+0x4dc/0xe02
[  908.926380]  ? alloc_pages_current+0x193/0x1b0
[  908.927887]  __alloc_pages_nodemask+0x382/0x3d0
[  908.929406]  ? __radix_tree_lookup+0x84/0xf0
[  908.930879]  alloc_pages_current+0x97/0x1b0
[  908.932333]  ? find_get_entry+0x5/0x300
[  908.933683]  __page_cache_alloc+0x15d/0x1a0
[  908.935069]  ? pagecache_get_page+0x2c/0x2b0
[  908.936447]  filemap_fault+0x4df/0x8b0
[  908.937728]  ? filemap_fault+0x373/0x8b0
[  908.939078]  ? xfs_ilock+0x22c/0x360 [xfs]
[  908.940393]  ? xfs_filemap_fault+0x64/0x1e0 [xfs]
[  908.941775]  ? down_read_nested+0x7b/0xc0
[  908.943046]  ? xfs_ilock+0x22c/0x360 [xfs]
[  908.944290]  xfs_filemap_fault+0x6c/0x1e0 [xfs]
[  908.945587]  __do_fault+0x1e/0xa0
[  908.946647]  ? _raw_spin_unlock+0x27/0x40
[  908.947823]  handle_mm_fault+0xd75/0x10d0
[  908.948954]  ? handle_mm_fault+0x5e/0x10d0
[  908.950079]  __do_page_fault+0x24a/0x530
[  908.951158]  do_page_fault+0x30/0x80
[  908.952199]  page_fault+0x28/0x30
(...snipped...)
[  909.537512] kswapd0         D11112    68      2 0x00000000
[  909.538860] Call Trace:
[  909.539675]  __schedule+0x345/0xdd0
[  909.540670]  schedule+0x3d/0x90
[  909.541619]  rwsem_down_read_failed+0x10e/0x1a0
[  909.542827]  ? xfs_map_blocks+0x98/0x5a0 [xfs]
[  909.543992]  call_rwsem_down_read_failed+0x18/0x30
[  909.545218]  down_read_nested+0xaf/0xc0
[  909.546316]  ? xfs_ilock+0x154/0x360 [xfs]
[  909.547519]  xfs_ilock+0x154/0x360 [xfs]
[  909.548608]  xfs_map_blocks+0x98/0x5a0 [xfs]
[  909.549754]  xfs_do_writepage+0x215/0x920 [xfs]
[  909.550954]  ? clear_page_dirty_for_io+0xb4/0x310
[  909.552188]  xfs_vm_writepage+0x3b/0x70 [xfs]
[  909.553340]  pageout.isra.54+0x1a4/0x460
[  909.554428]  shrink_page_list+0xa86/0xcf0
[  909.555529]  shrink_inactive_list+0x1d3/0x680
[  909.556680]  ? shrink_active_list+0x44f/0x590
[  909.557829]  shrink_node_memcg+0x535/0x7f0
[  909.558952]  ? mem_cgroup_iter+0x14d/0x720
[  909.560050]  shrink_node+0xe1/0x310
[  909.561043]  kswapd+0x362/0x9b0
[  909.561976]  kthread+0x10f/0x150
[  909.562974]  ? mem_cgroup_shrink_node+0x3b0/0x3b0
[  909.564199]  ? kthread_create_on_node+0x70/0x70
[  909.565375]  ret_from_fork+0x31/0x40
(...snipped...)
[  998.658049] BUG: workqueue lockup - pool cpus=2 node=0 flags=0x0 nice=0 stuck for 665s!
[  998.667526] Showing busy workqueues and worker pools:
[  998.673851] workqueue events: flags=0x0
[  998.676147]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=28/256
[  998.678935]     pending: free_work, vmpressure_work_fn, drain_local_pages_wq BAR(9811), vmw_fb_dirty_flush [vmwgfx], drain_local_pages_wq BAR(2506), drain_local_pages_wq BAR(812), drain_local_pages_wq BAR(2466), drain_local_pages_wq BAR(2485), drain_local_pages_wq BAR(3714), drain_local_pages_wq BAR(2862), drain_local_pages_wq BAR(827), drain_local_pages_wq BAR(527), drain_local_pages_wq BAR(9779), drain_local_pages_wq BAR(2484), drain_local_pages_wq BAR(932), drain_local_pages_wq BAR(2492), drain_local_pages_wq BAR(9820), drain_local_pages_wq BAR(811), drain_local_pages_wq BAR(1), drain_local_pages_wq BAR(2521), drain_local_pages_wq BAR(565), drain_local_pages_wq BAR(10420), drain_local_pages_wq BAR(9824), drain_local_pages_wq BAR(9749), drain_local_pages_wq BAR(2), drain_local_pages_wq BAR(9801)
[  998.705187] , drain_local_pages_wq BAR(47), drain_local_pages_wq BAR(10805)
[  998.707558]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  998.709548]     pending: e1000_watchdog [e1000], vmstat_shepherd
[  998.711593] workqueue events_power_efficient: flags=0x80
[  998.713479]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  998.715399]     pending: neigh_periodic_work
[  998.717075] workqueue writeback: flags=0x4e
[  998.718656]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  998.720587]     in-flight: 425:wb_workfn wb_workfn
[  998.723062] workqueue mpt_poll_0: flags=0x8
[  998.724712]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  998.726601]     pending: mpt_fault_reset_work [mptbase]
[  998.728548] workqueue xfs-eofblocks/sda1: flags=0xc
[  998.730292]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  998.732178]     in-flight: 123:xfs_eofblocks_worker [xfs]
[  998.733997] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=665s workers=2 manager: 80
[  998.736251] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=2 manager: 53 idle: 10804
[  998.738634] pool 256: cpus=0-127 flags=0x4 nice=0 hung=458s workers=3 idle: 424 423
----------

So, you believed that the too_many_isolated() issue is the only problem which
can prevent reasonable return to the page allocator [2]. But the reality is that
we are about to introduce a new problem without knowing the possibility which can
prevent reasonable return to the page allocator.

So, would you please please please accept asynchronous watchdog [3]? I said
"the cause of allocation stall might be due to out of idle workqueue thread"
in that post and I think above lockup is exactly in this case. We cannot be
careful enough to prove. We forever have possibility of failing to warn as
long as we depend on only synchronous watchdog.

[2] http://lkml.kernel.org/r/201701141910.ACF73418.OJHFVFStQOOMFL@I-love.SAKURA.ne.jp
[3] http://lkml.kernel.org/r/201701261928.DIG05227.OtOVFHOJMFLSQF@I-love.SAKURA.ne.jp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
