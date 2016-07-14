Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0DBC6B0260
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 02:24:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p64so136479805pfb.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 23:24:46 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 63si2616637pfq.112.2016.07.13.23.24.44
        for <linux-mm@kvack.org>;
        Wed, 13 Jul 2016 23:24:45 -0700 (PDT)
Date: Thu, 14 Jul 2016 15:28:37 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 04/31] mm, vmscan: begin reclaiming pages on a per-node
 basis
Message-ID: <20160714062836.GB29676@js1304-P5Q-DELUXE>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-5-git-send-email-mgorman@techsingularity.net>
 <20160707011211.GA27987@js1304-P5Q-DELUXE>
 <20160707094808.GP11498@techsingularity.net>
 <20160708022852.GA2370@js1304-P5Q-DELUXE>
 <20160708100532.GC11498@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160708100532.GC11498@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 11:05:32AM +0100, Mel Gorman wrote:
> On Fri, Jul 08, 2016 at 11:28:52AM +0900, Joonsoo Kim wrote:
> > On Thu, Jul 07, 2016 at 10:48:08AM +0100, Mel Gorman wrote:
> > > On Thu, Jul 07, 2016 at 10:12:12AM +0900, Joonsoo Kim wrote:
> > > > > @@ -1402,6 +1406,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> > > > >  
> > > > >  		VM_BUG_ON_PAGE(!PageLRU(page), page);
> > > > >  
> > > > > +		if (page_zonenum(page) > sc->reclaim_idx) {
> > > > > +			list_move(&page->lru, &pages_skipped);
> > > > > +			continue;
> > > > > +		}
> > > > > +
> > > > 
> > > > I think that we don't need to skip LRU pages in active list. What we'd
> > > > like to do is just skipping actual reclaim since it doesn't make
> > > > freepage that we need. It's unrelated to skip the page in active list.
> > > > 
> > > 
> > > Why?
> > > 
> > > The active aging is sometimes about simply aging the LRU list. Aging the
> > > active list based on the timing of when a zone-constrained allocation arrives
> > > potentially introduces the same zone-balancing problems we currently have
> > > and applying them to node-lru.
> > 
> > Could you explain more? I don't understand why aging the active list
> > based on the timing of when a zone-constrained allocation arrives
> > introduces the zone-balancing problem again.
> > 
> 
> I mispoke. Avoid rotation of the active list based on the timing of a
> zone-constrained allocation is what I think potentially introduces problems.
> If there are zone-constrained allocations aging the active list then I worry
> that pages would be artificially preserved on the active list.  No matter
> what we do, there is distortion of the aging for zone-constrained allocation
> because right now, it may deactivate high zone pages sooner than expected.
> 
> > I think that if above logic is applied to both the active/inactive
> > list, it could cause zone-balancing problem. LRU pages on lower zone
> > can be resident on memory with more chance.
> 
> If anything, with node-based LRU, it's high zone pages that can be resident
> on memory for longer but only if there are zone-constrained allocations.
> If we always reclaim based on age regardless of allocation requirements
> then there is a risk that high zones are reclaimed far earlier than expected.
> 
> Basically, whether we skip pages in the active list or not there are
> distortions with page aging and the impact is workload dependent. Right now,
> I see no clear advantage to special casing active aging.
> 
> If we suspect this is a problem in the future, it would be a simple matter
> of adding an additional bool parameter to isolate_lru_pages.

Okay. I agree that it would be a simple matter.

> 
> > > > And, I have a concern that if inactive LRU is full with higher zone's
> > > > LRU pages, reclaim with low reclaim_idx could be stuck.
> > > 
> > > That is an outside possibility but unlikely given that it would require
> > > that all outstanding allocation requests are zone-contrained. If it happens
> > 
> > I'm not sure that it is outside possibility. It can also happens if there
> > is zone-contrained allocation requestor and parallel memory hogger. In
> > this case, memory would be reclaimed by memory hogger but memory hogger would
> > consume them again so inactive LRU is continually full with higher
> > zone's LRU pages and zone-contrained allocation requestor cannot
> > progress.
> > 
> 
> The same memory hogger will also be reclaiming the highmem pages and
> reallocating highmem pages.
> 
> > > It would be preferred to have an actual test case for this so the
> > > altered ratio can be tested instead of introducing code that may be
> > > useless or dead.
> > 
> > Yes, actual test case would be preferred. I will try to implement
> > an artificial test case by myself but I'm not sure when I can do it.
> > 
> 
> That would be appreciated.

I make an artificial test case and test this series by using next tree
(next-20160713) and found a regression.

My test setup is:

memory: 2048 mb
movablecore: 1500 mb (imitates highmem system to test effect of skip logic)
swapoff
forever repeat: sequential read file (1500 mb) (using mmap) by 2 threads
3000 processes fork

lowmem is roughly 500 mb and it is enough to keep 3000 processes. I
test this artificial scenario with v4.7-rc5 and find no problem. But,
with next-20160713, OOM kill is triggered as below.


-------- oops -------

fork invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
fork cpuset=/ mems_allowed=0
CPU: 0 PID: 10478 Comm: fork Not tainted 4.7.0-rc7-next-20160713 #646
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.1-0-gb3ef39f-prebuilt.qemu-project.org 04/01/2014
 0000000000000000 ffff880014273b18 ffffffff8142b8c3 ffff880014273d20
 ffff88001c44a500 ffff880014273b90 ffffffff81240b6e ffffffff81e6f0e0
 ffff880014273b40 ffffffff810de08d ffff880014273b60 0000000000000206
Call Trace:
 [<ffffffff8142b8c3>] dump_stack+0x85/0xc2
 [<ffffffff81240b6e>] dump_header+0x5c/0x22e
 [<ffffffff810de08d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff811b3381>] oom_kill_process+0x221/0x3f0
 [<ffffffff810901b7>] ? has_capability_noaudit+0x17/0x20
 [<ffffffff811b3acf>] out_of_memory+0x52f/0x560
 [<ffffffff811b377c>] ? out_of_memory+0x1dc/0x560
 [<ffffffff811ba004>] __alloc_pages_nodemask+0x1154/0x11b0
 [<ffffffff810813a1>] ? copy_process.part.30+0x121/0x1bf0
 [<ffffffff810813a1>] copy_process.part.30+0x121/0x1bf0
 [<ffffffff811ebb06>] ? handle_mm_fault+0xb36/0x13d0
 [<ffffffff810fb60d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
 [<ffffffff81083066>] _do_fork+0xe6/0x6a0
 [<ffffffff810836c9>] SyS_clone+0x19/0x20
 [<ffffffff81003e13>] do_syscall_64+0x73/0x1e0
 [<ffffffff81858ec3>] entry_SYSCALL64_slow_path+0x25/0x25
Mem-Info:
active_anon:19756 inactive_anon:18 isolated_anon:0
 active_file:142480 inactive_file:266065 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:6777 slab_unreclaimable:19127
 mapped:389778 shmem:95 pagetables:17512 bounce:0
 free:9533 free_pcp:80 free_cma:0
Node 0 active_anon:79024kB inactive_anon:72kB active_file:569920kB inactive_file:1064260kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1559112kB dirty:0kB writeback:0kB shmem:0kB shmem_thp
: 0kB shmem_pmdmapped: 0kB anon_thp: 380kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
Node 0 DMA free:2172kB min:204kB low:252kB high:300kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:2272kB kernel_stack:1216kB pagetables:2436kB bounce:0kB free_pcp:0k
B local_pcp:0kB free_cma:0kB node_pages_scanned:15639736
lowmem_reserve[]: 0 493 493 1955
Node 0 DMA32 free:6372kB min:6492kB low:8112kB high:9732kB present:2080632kB managed:508600kB mlocked:0kB slab_reclaimable:27108kB slab_unreclaimable:74236kB kernel_stack:32752kB pagetables:67612kB bounce:
0kB free_pcp:112kB local_pcp:12kB free_cma:0kB node_pages_scanned:16302012
lowmem_reserve[]: 0 0 0 1462
Node 0 Normal free:0kB min:0kB low:0kB high:0kB present:18446744073708015752kB managed:0kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB lo
cal_pcp:0kB free_cma:0kB node_pages_scanned:17033632
lowmem_reserve[]: 0 0 0 11698
Node 0 Movable free:29588kB min:19256kB low:24068kB high:28880kB present:1535864kB managed:1500964kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_
pcp:208kB local_pcp:112kB free_cma:0kB node_pages_scanned:17725436
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 1*4kB (M) 1*8kB (U) 1*16kB (M) 1*32kB (M) 1*64kB (M) 2*128kB (UM) 1*256kB (M) 1*512kB (U) 1*1024kB (U) 0*2048kB 0*4096kB = 2172kB
Node 0 DMA32: 60*4kB (ME) 45*8kB (UME) 24*16kB (ME) 13*32kB (UM) 12*64kB (UM) 6*128kB (UM) 6*256kB (M) 4*512kB (UM) 0*1024kB 0*2048kB 0*4096kB = 6520kB
Node 0 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
Node 0 Movable: 1*4kB (M) 130*8kB (M) 68*16kB (M) 30*32kB (M) 13*64kB (M) 9*128kB (M) 4*256kB (M) 0*512kB 1*1024kB (M) 1*2048kB (M) 5*4096kB (M) = 29652kB
Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
408717 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
524156 pages RAM
0 pages HighMem/MovableOnly
17788 pages reserved
0 pages cma reserved
0 pages hwpoisoned



-------- another one -------

fork invoked oom-killer: gfp_mask=0x25080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO), order=0, oom_score_adj=0
fork cpuset=/ mems_allowed=0
CPU: 3 PID: 7538 Comm: fork Not tainted 4.7.0-rc7-next-20160713 #646
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.1-0-gb3ef39f-prebuilt.qemu-project.org 04/01/2014
 0000000000000000 ffff8800141eb960 ffffffff8142b8c3 ffff8800141ebb68
 ffff88001c46a500 ffff8800141eb9d8 ffffffff81240b6e ffffffff81e6f0e0
 ffff8800141eb988 ffffffff810de08d ffff8800141eb9a8 0000000000000206
Call Trace:
 [<ffffffff8142b8c3>] dump_stack+0x85/0xc2
 [<ffffffff81240b6e>] dump_header+0x5c/0x22e
 [<ffffffff810de08d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff811b3381>] oom_kill_process+0x221/0x3f0
 [<ffffffff810901b7>] ? has_capability_noaudit+0x17/0x20
 [<ffffffff811b3acf>] out_of_memory+0x52f/0x560
 [<ffffffff811b377c>] ? out_of_memory+0x1dc/0x560
 [<ffffffff811ba004>] __alloc_pages_nodemask+0x1154/0x11b0
 [<ffffffff8120ed61>] ? alloc_pages_current+0xa1/0x1f0
 [<ffffffff8120ed61>] alloc_pages_current+0xa1/0x1f0
 [<ffffffff811eae37>] ? __pmd_alloc+0x37/0x1d0
 [<ffffffff811eae37>] __pmd_alloc+0x37/0x1d0
 [<ffffffff811ed627>] copy_page_range+0x947/0xa50
 [<ffffffff811f9386>] ? anon_vma_fork+0xd6/0x150
 [<ffffffff81432bd2>] ? __rb_insert_augmented+0x132/0x210
 [<ffffffff81082035>] copy_process.part.30+0xdb5/0x1bf0
 [<ffffffff81083066>] _do_fork+0xe6/0x6a0
 [<ffffffff810836c9>] SyS_clone+0x19/0x20
 [<ffffffff81003e13>] do_syscall_64+0x73/0x1e0
 [<ffffffff81858ec3>] entry_SYSCALL64_slow_path+0x25/0x25
Mem-Info:
active_anon:18779 inactive_anon:18 isolated_anon:0
 active_file:91577 inactive_file:320615 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:6741 slab_unreclaimable:18124
 mapped:389774 shmem:95 pagetables:18332 bounce:0
 free:8194 free_pcp:140 free_cma:0
Node 0 active_anon:75116kB inactive_anon:72kB active_file:366308kB inactive_file:1282460kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1559096kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 380kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
Node 0 DMA free:2172kB min:204kB low:252kB high:300kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:2380kB kernel_stack:1632kB pagetables:3632kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB node_pages_scanned:13673372
lowmem_reserve[]: 0 493 493 1955
Node 0 DMA32 free:6444kB min:6492kB low:8112kB high:9732kB present:2080632kB managed:508600kB mlocked:0kB slab_reclaimable:26964kB slab_unreclaimable:70116kB kernel_stack:30496kB pagetables:69696kB bounce:0kB free_pcp:316kB local_pcp:100kB free_cma:0kB node_pages_scanned:13673372
lowmem_reserve[]: 0 0 0 1462
Node 0 Normal free:0kB min:0kB low:0kB high:0kB present:18446744073708015752kB managed:0kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB node_pages_scanned:13673832
lowmem_reserve[]: 0 0 0 11698
Node 0 Movable free:24200kB min:19256kB low:24068kB high:28880kB present:1535864kB managed:1500964kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:956kB local_pcp:100kB free_cma:0kB node_pages_scanned:1504
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 2*4kB (M) 0*8kB 1*16kB (M) 0*32kB 1*64kB (M) 0*128kB 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 0*4096kB = 2136kB
Node 0 DMA32: 58*4kB (ME) 40*8kB (UME) 27*16kB (UME) 15*32kB (ME) 8*64kB (UM) 5*128kB (M) 10*256kB (UM) 1*512kB (U) 1*1024kB (M) 0*2048kB 0*4096kB = 6712kB
Node 0 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
Node 0 Movable: 40*4kB (M) 8*8kB (M) 3*16kB (M) 6*32kB (M) 7*64kB (M) 2*128kB (M) 1*256kB (M) 2*512kB (M) 2*1024kB (M) 1*2048kB (M) 5*4096kB (M) = 27024kB
Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
411446 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
524156 pages RAM
0 pages HighMem/MovableOnly
17788 pages reserved
0 pages cma reserved

Size of active/inactive_file is larger than size of movable zone so I guess
there is reclaimable pages on DMA32 and it would mean that there is some problems
related to skip logic. Could you help how to check it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
