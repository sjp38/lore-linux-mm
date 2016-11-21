Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C29BC6B0038
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 16:50:36 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so1718942wma.2
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 13:50:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h8si22292880wjx.21.2016.11.21.13.50.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Nov 2016 13:50:34 -0800 (PST)
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
References: <20161121154336.GD19750@merlins.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
Date: Mon, 21 Nov 2016 22:50:20 +0100
MIME-Version: 1.0
In-Reply-To: <20161121154336.GD19750@merlins.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc MERLIN <marc@merlins.org>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>

On 11/21/2016 04:43 PM, Marc MERLIN wrote:
> Howdy,
> 
> As a followup to https://plus.google.com/u/0/+MarcMERLIN/posts/A3FrLVo3kc6
> 
> http://pastebin.com/yJybSHNq and http://pastebin.com/B6xEH4Dw
> show a system with plenty of RAM (24GB) falling over and killing inoccent
> user space apps, a few hours after I start a 9TB copy between 2 raid5 arrays 
> both hosting bcache, dmcrypt and btrfs (yes, that's 3 layers under btrfs)
> 
> This kind of stuff worked until 4.6 if I'm not mistaken and started failing
> with 4.8 (I didn't try 4.7)
> 
> I tried applying
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=9f7e3387939b036faacf4e7f32de7bb92a6635d6
> to 4.8.8 and it didn't help
> http://pastebin.com/2LUicF3k
> 
> 4.9rc5 however seems to be doing better, and is still running after 18
> hours. However, I got a few page allocation failures as per below, but the
> system seems to recover.
> Vlastimil, do you want me to continue the copy on 4.9 (may take 3-5 days) 
> or is that good enough, and i should go back to 4.8.8 with that patch applied?
> https://marc.info/?l=linux-mm&m=147423605024993

Hi, I think it's enough for 4.9 for now and I would appreciate trying
4.8 with that patch, yeah.

The failures below are in a GFP_NOWAIT context, which cannot do any
reclaim so it's not affected by OOM rewrite. If it's a regression, it
has to be caused by something else. But it seems the code in
cfq_get_queue() intentionally doesn't want to reclaim or use any atomic
reserves, and has a fallback scenario for allocation failure, in which
case I would argue that it should add __GFP_NOWARN, as these warnings
can't help anyone. CCing Tejun as author of commit d4aad7ff0.

> 
> Thanks,
> Marc
> 
> 
> bash: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)
> CPU: 4 PID: 16706 Comm: bash Not tainted 4.9.0-rc5-amd64-volpreempt-sysrq-20161108 #1
> Hardware name: System manufacturer System Product Name/P8H67-M PRO, BIOS 3904 04/27/2013
>  ffff9812088ff680 ffffffff9a36f697 0000000000000000 ffffffff9aababe8
>  ffff9812088ff710 ffffffff9a13ae2b 0220400000000012 ffffffff9aababe8  
>  ffff9812088ff6a8 ffffffff00000010 ffff9812088ff720 ffff9812088ff6c0
> Call Trace:
>  [<ffffffff9a36f697>] dump_stack+0x61/0x7d
>  [<ffffffff9a13ae2b>] warn_alloc+0x107/0x11b
>  [<ffffffff9a13b5cc>] __alloc_pages_slowpath+0x727/0x8f2 
>  [<ffffffff9a13abb8>] ? get_page_from_freelist+0x62e/0x66f
>  [<ffffffff9a13b8f3>] __alloc_pages_nodemask+0x15c/0x220
>  [<ffffffff9a18036d>] cache_grow_begin+0xb2/0x308
>  [<ffffffff9a180a2b>] fallback_alloc+0x137/0x19f
>  [<ffffffff9a1808e9>] ____cache_alloc_node+0xd3/0xde
>  [<ffffffff9a180b21>] kmem_cache_alloc_node+0x8e/0x163
>  [<ffffffff9a36ad08>] cfq_get_queue+0x162/0x29d
>  [<ffffffff9a1811d4>] ? kmem_cache_alloc+0xd7/0x14b
>  [<ffffffff9a136495>] ? mempool_alloc_slab+0x15/0x17
>  [<ffffffff9a13659f>] ? mempool_alloc+0x69/0x132
>  [<ffffffff9a36af84>] cfq_set_request+0x141/0x2be
>  [<ffffffff9a0bd9dc>] ? timekeeping_get_ns+0x1e/0x32
>  [<ffffffff9a0bdb8c>] ? ktime_get+0x41/0x52
>  [<ffffffff9a367188>] ? ktime_get_ns+0x9/0xb
>  [<ffffffff9a3671bf>] ? cfq_init_icq+0x12/0x19
>  [<ffffffff9a346046>] elv_set_request+0x1f/0x24
>  [<ffffffff9a3495ca>] get_request+0x324/0x5aa  
>  [<ffffffff9a0945b0>] ? wake_up_atomic_t+0x2c/0x2c
>  [<ffffffff9a34bc5c>] blk_queue_bio+0x19f/0x28c  
>  [<ffffffff9a34a525>] generic_make_request+0xbd/0x160
>  [<ffffffff9a34a6c8>] submit_bio+0x100/0x11d
>  [<ffffffff9a17177a>] ? map_swap_page+0x12/0x14  
>  [<ffffffff9a16e875>] ? get_swap_bio+0x57/0x6c
>  [<ffffffff9a16edfb>] swap_readpage+0x106/0x10e
>  [<ffffffff9a16f3e0>] read_swap_cache_async+0x26/0x2d  
>  [<ffffffff9a16f501>] swapin_readahead+0x11a/0x16a  
>  [<ffffffff9a15de97>] do_swap_page+0x9c/0x42e
>  [<ffffffff9a15de97>] ? do_swap_page+0x9c/0x42e
>  [<ffffffff9a1601ff>] handle_mm_fault+0xa51/0xb71
>  [<ffffffff9a6a61a5>] ? _raw_spin_lock_irq+0x1c/0x1e
>  [<ffffffff9a052091>] __do_page_fault+0x29e/0x425
>  [<ffffffff9a05223d>] do_page_fault+0x25/0x27
>  [<ffffffff9a6a7818>] page_fault+0x28/0x30
> Mem-Info:
> active_anon:563129 inactive_anon:140630 isolated_anon:0
>  active_file:4036325 inactive_file:448954 isolated_file:288
>  unevictable:1760 dirty:9197 writeback:446395 unstable:0
>  slab_reclaimable:47810 slab_unreclaimable:120834
>  mapped:534180 shmem:627708 pagetables:5647 bounce:0
>  free:90108 free_pcp:218 free_cma:78
> Node 0 active_anon:2252516kB inactive_anon:562520kB active_file:16145300kB inactive_file:1795816kB unevictable:7040kB isolated(anon):0kB isolated(file):1152kB mapped:2136720kB dirty:367
> 1785580kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2510832kB writeback_tmp:0kB unstable:0kB pages_scanned:32 all_unreclaimable? no
> Node 0 DMA free:15884kB min:168kB low:208kB high:248kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15976kB managed:15892kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> lowmem_reserve[]: 0 3199 23767 23767 23767
> Node 0 DMA32 free:117656kB min:35424kB low:44280kB high:53136kB active_anon:38004kB inactive_anon:13540kB active_file:2221420kB inactive_file:307236kB unevictable:0kB writepending:311780kB present:3362068kB managed:3296500kB mlocked:0kB slab_reclaimable:47992kB slab_unreclaimable:25360kB kernel_stack:512kB pagetables:796kB bounce:0kB free_pcp:96kB local_pcp:0kB free_cma:0kB
> lowmem_reserve[]: 0 0 20567 20567 20567
> Node 0 Normal free:226892kB min:226544kB low:283180kB high:339816kB active_anon:2214684kB inactive_anon:549272kB active_file:13923880kB inactive_file:1488092kB unevictable:7040kB writepending:1510452kB present:21485568kB managed:21080820kB mlocked:7040kB slab_reclaimable:143248kB slab_unreclaimable:457968kB kernel_stack:44384kB pagetables:21792kB bounce:0kB free_pcp:776kB local_pcp:132kB free_cma:312kB
> lowmem_reserve[]: 0 0 0 0 0
> Node 0 DMA: 1*4kB (U) 1*8kB (U) 0*16kB 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15884kB
> Node 0 DMA32: 11805*4kB (UME) 8876*8kB (UM) 5*16kB (UM) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 118308kB
> Node 0 Normal: 55077*4kB (UMEC) 843*8kB (UMC) 2*16kB (C) 1*32kB (C) 3*64kB (C) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 227308kB
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
> 5121498 total pagecache pages
> 7334 pages in swap cache
> Swap cache stats: add 1513475, delete 1506141, find 949827/1257375
> Free swap  = 14492876kB
> Total swap = 15616764kB
> 6215903 pages RAM
> 0 pages HighMem/MovableOnly
> 117600 pages reserved
> 4096 pages cma reserved
> 0 pages hwpoisoned
> 
> kworker/4:197: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)
> CPU: 4 PID: 7411 Comm: kworker/4:197 Not tainted 4.9.0-rc5-amd64-volpreempt-sysrq-20161108 #1
> Hardware name: System manufacturer System Product Name/P8H67-M PRO, BIOS 3904 04/27/2013
> Workqueue: bcache cache_lookup [bcache]
>  ffff98121672f590 ffffffff9a36f697 0000000000000000 ffffffff9aababe8
>  ffff98121672f620 ffffffff9a13ae2b 0220400000000012 ffffffff9aababe8
>  ffff98121672f5b8 ffffffff00000010 ffff98121672f630 ffff98121672f5d0
> Call Trace:
>  [<ffffffff9a36f697>] dump_stack+0x61/0x7d
>  [<ffffffff9a13ae2b>] warn_alloc+0x107/0x11b
>  [<ffffffff9a13b5cc>] __alloc_pages_slowpath+0x727/0x8f2
>  [<ffffffff9a13abb8>] ? get_page_from_freelist+0x62e/0x66f
>  [<ffffffff9a13b8f3>] __alloc_pages_nodemask+0x15c/0x220
>  [<ffffffff9a18036d>] cache_grow_begin+0xb2/0x308
>  [<ffffffff9a180a2b>] fallback_alloc+0x137/0x19f
>  [<ffffffff9a1808e9>] ____cache_alloc_node+0xd3/0xde
>  [<ffffffff9a180b21>] kmem_cache_alloc_node+0x8e/0x163
>  [<ffffffff9a36ad08>] cfq_get_queue+0x162/0x29d
>  [<ffffffff9a136495>] ? mempool_alloc_slab+0x15/0x17
>  [<ffffffff9a13659f>] ? mempool_alloc+0x69/0x132
>  [<ffffffff9a36af84>] cfq_set_request+0x141/0x2be
>  [<ffffffff9a0bd9dc>] ? timekeeping_get_ns+0x1e/0x32
>  [<ffffffff9a0bdb8c>] ? ktime_get+0x41/0x52
>  [<ffffffff9a367188>] ? ktime_get_ns+0x9/0xb
>  [<ffffffff9a3671bf>] ? cfq_init_icq+0x12/0x19
>  [<ffffffff9a346046>] elv_set_request+0x1f/0x24
>  [<ffffffff9a3495ca>] get_request+0x324/0x5aa
>  [<ffffffff9a0945b0>] ? wake_up_atomic_t+0x2c/0x2c
>  [<ffffffff9a34bc5c>] blk_queue_bio+0x19f/0x28c
>  [<ffffffff9a34a525>] generic_make_request+0xbd/0x160
>  [<ffffffffc062cd53>] cached_dev_cache_miss+0x20c/0x21b [bcache]
>  [<ffffffffc062c9ca>] cache_lookup_fn+0xe2/0x25f [bcache]
>  [<ffffffffc06227b7>] ? bch_ptr_bad+0xa/0xc [bcache]
>  [<ffffffffc062c8e8>] ? bio_next_split.constprop.22+0x20/0x20 [bcache]
>  [<ffffffffc0625377>] bch_btree_map_keys_recurse+0x7b/0x151 [bcache]
>  [<ffffffffc06250e8>] ? bch_btree_node_get+0xc2/0x1c8 [bcache]
>  [<ffffffffc062c8e8>] ? bio_next_split.constprop.22+0x20/0x20 [bcache]
>  [<ffffffffc06253c4>] bch_btree_map_keys_recurse+0xc8/0x151 [bcache]
>  [<ffffffff9a08acb4>] ? set_next_entity+0x51/0xbc
>  [<ffffffff9a08f309>] ? pick_next_task_fair+0x12c/0x348
>  [<ffffffffc062784c>] bch_btree_map_keys+0x8f/0xdb [bcache]
>  [<ffffffffc062c8e8>] ? bio_next_split.constprop.22+0x20/0x20 [bcache]
>  [<ffffffffc062c814>] cache_lookup+0x84/0xb7 [bcache]
>  [<ffffffff9a0771da>] process_one_work+0x17f/0x28d
>  [<ffffffff9a0777b6>] worker_thread+0x1ee/0x2c1
>  [<ffffffff9a0775c8>] ? rescuer_thread+0x2ad/0x2ad
>  [<ffffffff9a07bbb6>] kthread+0xa6/0xae
>  [<ffffffff9a07bb10>] ? init_completion+0x24/0x24
>  [<ffffffff9a6a66b5>] ret_from_fork+0x25/0x30
> Mem-Info:
> active_anon:557191 inactive_anon:139781 isolated_anon:0
>  active_file:4043120 inactive_file:390969 isolated_file:0
>  unevictable:1760 dirty:4811 writeback:387556 unstable:0
>  slab_reclaimable:47779 slab_unreclaimable:120741
>  mapped:561961 shmem:627643 pagetables:5533 bounce:0
>  free:90159 free_pcp:411 free_cma:78
> Node 0 active_anon:2228764kB inactive_anon:559124kB active_file:16172480kB inactive_file:1563876kB unevictable:7040kB isolated(anon):0kB isolated(file):0kB mapped:2247844kB dirty:19244kB writeback:1550224kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2510572kB writeback_tmp:0kB unstable:0kB pages_scanned:96 all_unreclaimable? no
> Node 0 DMA free:15884kB min:168kB low:208kB high:248kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15976kB managed:15892kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> lowmem_reserve[]: 0 3199 23767 23767 23767
> Node 0 DMA32 free:117816kB min:35424kB low:44280kB high:53136kB active_anon:35856kB inactive_anon:12996kB active_file:2225180kB inactive_file:289328kB unevictable:0kB writepending:290420kB present:3362068kB managed:3296500kB mlocked:0kB slab_reclaimable:47664kB slab_unreclaimable:25036kB kernel_stack:528kB pagetables:692kB bounce:0kB free_pcp:244kB local_pcp:0kB free_cma:0kB
> lowmem_reserve[]: 0 0 20567 20567 20567
> Node 0 Normal free:226936kB min:226544kB low:283180kB high:339816kB active_anon:2192908kB inactive_anon:546128kB active_file:13947204kB inactive_file:1274320kB unevictable:7040kB writepending:1279356kB present:21485568kB managed:21080820kB mlocked:7040kB slab_reclaimable:143452kB slab_unreclaimable:457920kB kernel_stack:44224kB pagetables:21440kB bounce:0kB free_pcp:1396kB local_pcp:0kB free_cma:312kB
> lowmem_reserve[]: 0 0 0 0 0
> Node 0 DMA: 1*4kB (U) 1*8kB (U) 0*16kB 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15884kB
> Node 0 DMA32: 9086*4kB (ME) 9579*8kB (UME) 306*16kB (UM) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 117872kB
> Node 0 Normal: 54290*4kB (UMEC) 1198*8kB (UMC) 2*16kB (C) 1*32kB (C) 3*64kB (C) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 227000kB
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
> 5067527 total pagecache pages
> 4955 pages in swap cache
> Swap cache stats: add 1516061, delete 1511106, find 950848/1258840
> Free swap  = 14488852kB
> Total swap = 15616764kB
> 6215903 pages RAM
> 0 pages HighMem/MovableOnly
> 117600 pages reserved
> 4096 pages cma reserved
> 0 pages hwpoisoned
> 
> hpet1: lost 7439 rtc interrupts 
> kworker/0:203: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK) 
> CPU: 0 PID: 10557 Comm: kworker/0:203 Not tainted 4.9.0-rc5-amd64-volpreempt-sysrq-20161108 #1 
> Hardware name: System manufacturer System Product Name/P8H67-M PRO, BIOS 3904 04/27/2013 
> Workqueue: bcache cache_lookup [bcache] 
>  ffff98121ac275f0 ffffffff9a36f697 0000000000000000 ffffffff9aababe8 
>  ffff98121ac27680 ffffffff9a13ae2b 0220400000000012 ffffffff9aababe8 
>  ffff98121ac27618 ffffffff00000010 ffff98121ac27690 ffff98121ac27630 
> Call Trace: 
>  [<ffffffff9a36f697>] dump_stack+0x61/0x7d 
>  [<ffffffff9a13ae2b>] warn_alloc+0x107/0x11b 
>  [<ffffffff9a13b5cc>] __alloc_pages_slowpath+0x727/0x8f2 
>  [<ffffffff9a13abb8>] ? get_page_from_freelist+0x62e/0x66f 
>  [<ffffffff9a13b8f3>] __alloc_pages_nodemask+0x15c/0x220 
>  [<ffffffff9a18036d>] cache_grow_begin+0xb2/0x308 
>  [<ffffffff9a180a2b>] fallback_alloc+0x137/0x19f 
>  [<ffffffff9a1808e9>] ____cache_alloc_node+0xd3/0xde 
>  [<ffffffff9a180b21>] kmem_cache_alloc_node+0x8e/0x163 
>  [<ffffffff9a36ad08>] cfq_get_queue+0x162/0x29d 
>  [<ffffffff9a367188>] ? ktime_get_ns+0x9/0xb 
>  [<ffffffff9a36bcb7>] ? cfq_dispatch_requests+0x124/0x81f 
>  [<ffffffffc01ad443>] ? sil24_qc_issue+0x1e/0x55 [sata_sil24] 
>  [<ffffffff9a51fa7c>] ? ata_qc_issue+0x278/0x2b9 
>  [<ffffffff9a36af84>] cfq_set_request+0x141/0x2be 
>  [<ffffffff9a347c0a>] ? alloc_request_struct+0x19/0x1b 
>  [<ffffffff9a13659f>] ? mempool_alloc+0x69/0x132 
>  [<ffffffff9a029dff>] ? native_sched_clock+0x1f/0x3a 
>  [<ffffffff9a346046>] elv_set_request+0x1f/0x24 
>  [<ffffffff9a3495ca>] get_request+0x324/0x5aa 
>  [<ffffffff9a0945b0>] ? wake_up_atomic_t+0x2c/0x2c 
>  [<ffffffff9a34bc5c>] blk_queue_bio+0x19f/0x28c 
>  [<ffffffff9a34a525>] generic_make_request+0xbd/0x160 
>  [<ffffffffc06296d6>] __bch_submit_bbio+0x5f/0x62 [bcache] 
>  [<ffffffffc0629704>] bch_submit_bbio+0x2b/0x30 [bcache] 
>  [<ffffffffc06241b9>] bch_btree_node_read+0xca/0x16e [bcache] 
>  [<ffffffffc06250db>] bch_btree_node_get+0xb5/0x1c8 [bcache] 
>  [<ffffffffc062c8e8>] ? bio_next_split.constprop.22+0x20/0x20 [bcache] 
>  [<ffffffffc062539d>] bch_btree_map_keys_recurse+0xa1/0x151 [bcache] 
>  [<ffffffff9a08acb4>] ? set_next_entity+0x51/0xbc 
>  [<ffffffff9a08f309>] ? pick_next_task_fair+0x12c/0x348 
>  [<ffffffffc062784c>] bch_btree_map_keys+0x8f/0xdb [bcache] 
>  [<ffffffffc062c8e8>] ? bio_next_split.constprop.22+0x20/0x20 [bcache] 
>  [<ffffffffc062c814>] cache_lookup+0x84/0xb7 [bcache] 
>  [<ffffffff9a0771da>] process_one_work+0x17f/0x28d 
>  [<ffffffff9a0777b6>] worker_thread+0x1ee/0x2c1 
>  [<ffffffff9a0775c8>] ? rescuer_thread+0x2ad/0x2ad 
>  [<ffffffff9a07bbb6>] kthread+0xa6/0xae 
>  [<ffffffff9a07bb10>] ? init_completion+0x24/0x24 
>  [<ffffffff9a6a66b5>] ret_from_fork+0x25/0x30 
> Mem-Info: 
> active_anon:561047 inactive_anon:140273 isolated_anon:0 
>  active_file:3993560 inactive_file:546181 isolated_file:0 
>  unevictable:1891 dirty:16100 writeback:540602 unstable:0 
>  slab_reclaimable:47776 slab_unreclaimable:122101 
>  mapped:646066 shmem:628914 pagetables:5797 bounce:0 
>  free:106427 free_pcp:1437 free_cma:126 
> Node 0 active_anon:2244188kB inactive_anon:561092kB active_file:15974240kB inactive_file:2184724kB unevictable:7564kB isolated(anon):0kB isolated(file):0kB mapped:2584264kB dirty:64400kB writeback:2162408kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2515656kB writeback_tmp:0kB unstable:0kB pages_scanned:96 all_unreclaimable? no 
> Node 0 DMA free:15884kB min:168kB low:208kB high:248kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15976kB managed:15892kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB 
> lowmem_reserve[]: 0 3199 23767 23767 23767 
> Node 0 DMA32 free:145580kB min:35424kB low:44280kB high:53136kB active_anon:28040kB inactive_anon:19732kB active_file:2166240kB inactive_file:458248kB unevictable:252kB writepending:469368kB present:3362068kB managed:3296500kB mlocked:252kB slab_reclaimable:48544kB slab_unreclaimable:25364kB kernel_stack:480kB pagetables:604kB bounce:0kB free_pcp:2896kB local_pcp:120kB free_cma:0kB 
> lowmem_reserve[]: 0 0 20567 20567 20567 
> Node 0 Normal free:264244kB min:226544kB low:283180kB high:339816kB active_anon:2216160kB inactive_anon:541360kB active_file:13808316kB inactive_file:1726796kB unevictable:7312kB writepending:1757972kB present:21485568kB managed:21080820kB mlocked:7312kB slab_reclaimable:142560kB slab_unreclaimable:463032kB kernel_stack:44544kB pagetables:22584kB bounce:0kB free_pcp:2688kB local_pcp:0kB free_cma:504kB 
> lowmem_reserve[]: 0 0 0 0 0  
> Node 0 DMA: 1*4kB (U) 1*8kB (U) 0*16kB 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15884kB 
> Node 0 DMA32: 9458*4kB (UME) 12888*8kB (UM) 297*16kB (UM) 1*32kB (M) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 145720kB  
> Node 0 Normal: 56076*4kB (UMEC) 4824*8kB (UMC) 106*16kB (UMC) 16*32kB (UC) 3*64kB (C) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 265296kB 
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB  
> 5177157 total pagecache pages 
> 7486 pages in swap cache 
> Swap cache stats: add 1529461, delete 1521975, find 963233/1276841  
> Free swap  = 14488104kB 
> Total swap = 15616764kB  
> 6215903 pages RAM 
> 0 pages HighMem/MovableOnly  
> 117600 pages reserved 
> 4096 pages cma reserved  
> 0 pages hwpoisoned 
> hpet1: lost 876 rtc interrupts 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
