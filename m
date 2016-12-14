Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C78AC6B0266
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 11:36:14 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c4so33490408pfb.7
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 08:36:14 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 201si53497062pgd.162.2016.12.14.08.36.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 08:36:13 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161212131910.GC3185@dhcp22.suse.cz>
	<201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
	<20161213170628.GC18362@dhcp22.suse.cz>
	<201612142037.AAC60483.HVOSOJFLMOFtQF@I-love.SAKURA.ne.jp>
	<20161214124231.GI25573@dhcp22.suse.cz>
In-Reply-To: <20161214124231.GI25573@dhcp22.suse.cz>
Message-Id: <201612150136.GBC13980.FHQFLSOJOFOtVM@I-love.SAKURA.ne.jp>
Date: Thu, 15 Dec 2016 01:36:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org, pmladek@suse.cz, sergey.senozhatsky@gmail.com

Michal Hocko wrote:
> On Wed 14-12-16 20:37:07, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 13-12-16 21:06:57, Tetsuo Handa wrote:
> > > > http://I-love.SAKURA.ne.jp/tmp/serial-20161213.txt.xz is a console log with
> > > > this patch applied. Due to hung task warnings disabled, amount of messages
> > > > are significantly reduced.
> > > > 
> > > > Uptime > 400 are testcases where the stresser was invoked via "taskset -c 0".
> > > > Since there are some "** XXX printk messages dropped **" messages, I can't
> > > > tell whether the OOM killer was able to make forward progress. But guessing
> > > >  from the result that there is no corresponding "Killed process" line for
> > > > "Out of memory: " line at uptime = 450 and the duration of PID 14622 stalled,
> > > > I think it is OK to say that the system got stuck because the OOM killer was
> > > > not able to make forward progress.
> > > 
> > > The oom situation certainly didn't get resolved. I would be really
> > > curious whether we can rule out the printk out of the picture, though. I
> > > am still not sure we can rule out some obscure OOM killer bug at this
> > > stage.
> > > 
> > > What if we lower the loglevel as much as possible to only see KERN_ERR
> > > should be sufficient to see few oom killer messages while suppressing
> > > most of the other noise. Unfortunatelly, even messages with level >
> > > loglevel get stored into the ringbuffer (as I've just learned) so
> > > console_unlock() has to crawl through them just to drop them (Meh) but
> > > at least it doesn't have to go to the serial console drivers and spend
> > > even more time there. An alternative would be to tweak printk to not
> > > even store those messaes. Something like the below
> > 
> > Changing loglevel is not a option for me. Under OOM, syslog cannot work.
> > Only messages sent to serial console / netconsole are available for
> > understanding something went wrong. And serial consoles may be very slow.
> > We need to try to avoid uncontrolled printk().
> 
> That is definitely true I just wanted the above for the sake of testing
> and rulling out a different problem because currently it is not clear to
> me that this is the printk livelock issue. Evidences are quite
> convincing but not 100% sure. So...
> 
> > > So it would be really great if you could
> > > 	1) test with the fixed throttling
> > > 	2) loglevel=4 on the kernel command line
> > > 	3) try the above with the same loglevel
> > > 
> > > ideally 1) would be sufficient and that would make the most sense from
> > > the warn_alloc point of view. If this is 2 or 3 then we are hitting a
> > > more generic problem and I would be quite careful to hack it around.
> > 
> > Thus, I don't think I can do these.
> 
> i think this would be really valuable.

OK. I tried 1) and 2). I didn't try 3) because printk() did not work as expected.

Regarding 1), it did not help. I can still see "** XXX printk messages dropped **"
( http://I-love.SAKURA.ne.jp/tmp/serial-20161215-1.txt.xz ).

Regarding 2), I can't tell whether it helped
( http://I-love.SAKURA.ne.jp/tmp/serial-20161215-2.txt.xz ).
I can no longer see "** XXX printk messages dropped **", but sometimes they stalled.
In most cases, "Out of memory: " and "Killed process" lines are printed within 0.1
second. But sometimes it took a few seconds. Less often it took longer than a minute.
There was one big stall which lasted for minutes. I changed loglevel to 7 and checked
memory information. Seems that watermark was low enough to call out_of_memory().

[  371.077952] Out of memory: Kill process 5092 (a.out) score 999 or sacrifice child
[  371.080486] Killed process 5092 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  371.087651] Out of memory: Kill process 5093 (a.out) score 999 or sacrifice child
[  371.090130] Killed process 5093 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  371.096977] Out of memory: Kill process 5094 (a.out) score 999 or sacrifice child
[  371.099452] Killed process 5094 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  609.565043] sysrq: SysRq : Show Memory
[  617.645805] sysrq: SysRq : Changing Loglevel
[  617.647667] sysrq: Loglevel set to 7
[  619.493984] sysrq: SysRq : Show Memory
[  619.495721] Mem-Info:
[  619.497065] active_anon:356034 inactive_anon:2961 isolated_anon:0
[  619.497065]  active_file:57 inactive_file:133 isolated_file:32
[  619.497065]  unevictable:0 dirty:14 writeback:0 unstable:0
[  619.497065]  slab_reclaimable:3654 slab_unreclaimable:29434
[  619.497065]  mapped:718 shmem:4209 pagetables:9032 bounce:0
[  619.497065]  free:12922 free_pcp:89 free_cma:0
[  619.508579] Node 0 active_anon:1424136kB inactive_anon:11844kB active_file:228kB inactive_file:532kB unevictable:0kB isolated(anon):0kB isolated(file):128kB mapped:2872kB dirty:56kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 1161216kB anon_thp: 16836kB writeback_tmp:0kB unstable:0kB pages_scanned:1347 all_unreclaimable? yes
[  619.516992] Node 0 DMA free:7120kB min:412kB low:512kB high:612kB active_anon:8752kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  619.525582] lowmem_reserve[]: 0 1677 1677 1677
[  619.527519] Node 0 DMA32 free:44568kB min:44640kB low:55800kB high:66960kB active_anon:1415384kB inactive_anon:11844kB active_file:228kB inactive_file:532kB unevictable:0kB writepending:56kB present:2080640kB managed:1717740kB mlocked:0kB slab_reclaimable:14616kB slab_unreclaimable:117704kB kernel_stack:18816kB pagetables:36128kB bounce:0kB free_pcp:356kB local_pcp:0kB free_cma:0kB
[  619.536967] lowmem_reserve[]: 0 0 0 0
[  619.538808] Node 0 DMA: 0*4kB 0*8kB 1*16kB (M) 0*32kB 3*64kB (UM) 2*128kB (UM) 2*256kB (UM) 0*512kB 2*1024kB (UM) 0*2048kB 1*4096kB (M) = 7120kB
[  619.542971] Node 0 DMA32: 2*4kB (UH) 248*8kB (MEH) 59*16kB (UMEH) 135*32kB (UMEH) 47*64kB (UMEH) 8*128kB (UEH) 4*256kB (UEH) 31*512kB (M) 16*1024kB (UM) 0*2048kB 0*4096kB = 44568kB
[  619.548827] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  619.551524] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  619.554147] 4441 total pagecache pages
[  619.555838] 0 pages in swap cache
[  619.557421] Swap cache stats: add 0, delete 0, find 0/0
[  619.559359] Free swap  = 0kB
[  619.560827] Total swap = 0kB
[  619.562312] 524157 pages RAM
[  619.563779] 0 pages HighMem/MovableOnly
[  619.565418] 90746 pages reserved
[  619.566897] 0 pages hwpoisoned
[  624.638061] a.out: page allocation stalls for 140001ms, order:0[  624.646725] a.out: 
[  624.646727] page allocation stalls for 140026ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  624.646731] CPU: 0 PID: 5167 Comm: a.out Tainted: G        W       4.9.0+ #102
[  624.646732] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  624.646733]  ffff880060dab930
[  624.646734]  ffffffff8134b0af ffffffff8198ce88 0000000000000001 ffff880060dab9b8
[  624.646735]  ffffffff8115489b 0342004a5fa93740 ffffffff8198ce88 ffff880060dab958
[  624.646737]  ffff880000000010 ffff880060dab9c8 ffff880060dab978Call Trace:
[  624.646744]  [<ffffffff8134b0af>] dump_stack+0x67/0x98
[  624.646747]  [<ffffffff8115489b>] warn_alloc+0x12b/0x170
[  624.646748]  [<ffffffff8115526b>] __alloc_pages_nodemask+0x91b/0xf20
[  624.646751]  [<ffffffff811a71e6>] alloc_pages_current+0x96/0x190
[  624.646754]  [<ffffffff811488f2>] __page_cache_alloc+0x142/0x180
[  624.646755]  [<ffffffff81149208>] ? find_get_entry+0x198/0x270
[  624.646756]  [<ffffffff81149070>] ? page_cache_prev_hole+0x50/0x50
[  624.646758]  [<ffffffff8114949b>] pagecache_get_page+0x8b/0x2a0
[  624.646759]  [<ffffffff8114a92e>] grab_cache_page_write_begin+0x1e/0x40
[  624.646761]  [<ffffffff81244adb>] iomap_write_begin+0x4b/0x100
[  624.646762]  [<ffffffff81244d60>] iomap_write_actor+0xb0/0x190
[  624.646764]  [<ffffffff812cb28b>] ? xfs_trans_commit+0xb/0x10
[  624.646765]  [<ffffffff81244cb0>] ? iomap_write_end+0x70/0x70
[  624.646766]  [<ffffffff812453ae>] iomap_apply+0xae/0x130
[  624.646767]  [<ffffffff81245493>] iomap_file_buffered_write+0x63/0xa0
[  624.646768]  [<ffffffff81244cb0>] ? iomap_write_end+0x70/0x70
[  624.646770]  [<ffffffff812b03af>] xfs_file_buffered_aio_write+0xcf/0x1f0
[  624.646772]  [<ffffffff812b0555>] xfs_file_write_iter+0x85/0x120
[  624.646773]  [<ffffffff811dc770>] __vfs_write+0xe0/0x140
[  624.646774]  [<ffffffff811dd440>] vfs_write+0xb0/0x1b0
[  624.646776]  [<ffffffff81002240>] ? syscall_trace_enter+0x1b0/0x240
[  624.646778]  [<ffffffff811de8e3>] SyS_write+0x53/0xc0
[  624.646781]  [<ffffffff81367963>] ? __this_cpu_preempt_check+0x13/0x20
[  624.646781]  [<ffffffff81002511>] do_syscall_64+0x61/0x1d0
[  624.646784]  [<ffffffff816b9d64>] entry_SYSCALL64_slow_path+0x25/0x25
[  624.646786] Mem-Info:
[  624.646788] active_anon:356034 inactive_anon:2961 isolated_anon:0
[  624.646788]  active_file:57 inactive_file:133 isolated_file:32
[  624.646788]  unevictable:0 dirty:14 writeback:0 unstable:0
[  624.646788]  slab_reclaimable:3654 slab_unreclaimable:29434
[  624.646788]  mapped:718 shmem:4209 pagetables:9032 bounce:0
[  624.646788]  free:12922 free_pcp:89 free_cma:0
[  624.646791] Node 0 active_anon:1424136kB inactive_anon:11844kB active_file:228kB inactive_file:532kB unevictable:0kB isolated(anon):0kB isolated(file):128kB mapped:2872kB dirty:56kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 1161216kB anon_thp: 16836kB writeback_tmp:0kB unstable:0kB pages_scanned:1347 all_unreclaimable? yes
[  624.646792] Node 0 
[  624.646794] DMA free:7120kB min:412kB low:512kB high:612kB active_anon:8752kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]:
[  624.646795]  0 1677 1677 1677Node 0 
[  624.646799] DMA32 free:44568kB min:44640kB low:55800kB high:66960kB active_anon:1415384kB inactive_anon:11844kB active_file:228kB inactive_file:532kB unevictable:0kB writepending:56kB present:2080640kB managed:1717740kB mlocked:0kB slab_reclaimable:14616kB slab_unreclaimable:117704kB kernel_stack:18816kB pagetables:36128kB bounce:0kB free_pcp:356kB local_pcp:120kB free_cma:0kB
lowmem_reserve[]:
[  624.646800]  0 0 0 0Node 0 
[  624.646801] DMA: 0*4kB 0*8kB 1*16kB (M) 0*32kB 3*64kB (UM) 2*128kB (UM) 2*256kB (UM) 0*512kB 2*1024kB (UM) 0*2048kB 1*4096kB (M) = 7120kB
Node 0 
[  624.646810] DMA32: 2*4kB (UH) 248*8kB (MEH) 59*16kB (UMEH) 135*32kB (UMEH) 47*64kB (UMEH) 8*128kB (UEH) 4*256kB (UEH) 31*512kB (M) 16*1024kB (UM) 0*2048kB 0*4096kB = 44568kB
[  624.646819] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  624.646820] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  624.646821] 4441 total pagecache pages
[  624.646822] 0 pages in swap cache
[  624.646822] Swap cache stats: add 0, delete 0, find 0/0
[  624.646823] Free swap  = 0kB
[  624.646823] Total swap = 0kB
[  624.646824] 524157 pages RAM
[  624.646825] 0 pages HighMem/MovableOnly
[  624.646825] 90746 pages reserved
[  624.646825] 0 pages hwpoisoned

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
