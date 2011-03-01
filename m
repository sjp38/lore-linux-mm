Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1ACCD8D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:44:33 -0500 (EST)
Received: from sim by peace.netnation.com with local (Exim 4.69)
	(envelope-from <sim@netnation.com>)
	id 1PuZF1-0007cP-3x
	for linux-mm@kvack.org; Tue, 01 Mar 2011 15:44:31 -0800
Date: Tue, 1 Mar 2011 15:44:31 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Failing order >= 1 atomic allocations on 2.6.38-rc6
Message-ID: <20110301234431.GB9759@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello!

After hitting a btrfs bug in 2.6.33.2 fixed in newer kernels, I decided
to try 2.6.38-rc6 on this backup server which writes to 60 TB of
AOE-attached storage. It uses a 9000-byte MTU on the AOE interface.

This thing was running without logging any kernel errors or warnings on
2.6.33.2, but on 2.6.38-rc6 (4662db446190ddef8fb), the first backup run
produced a boatload of order 2 atomic allocation failures from the skb
allocations. I lowered the MTU to 4200 for the next night to try to make
it fit in two pages, but there were still a ton of order 1 allocation
failures.

I haven't tried any kernels before and bisecting this would be difficult
as it takes a while to get any allocation failures, but this seems to be
a regression. I wonder if this is a result of us not balancing all zones
for higher orders now, but fragmentation seems worse as well (at least
judging by free memory -- I didn't have munin buddyinfo plugin enabled
before).

# CONFIG_NUMA is not set
CONFIG_COMPACTION=y
# CONFIG_TRANSPARENT_HUGEPAGE is not set

Whole config: http://0x.ca/sim/ref/2.6.38/config-2.6.38-rc6

Munin graph of change in memory behaviour: http://0x.ca/sim/ref/2.6.38/2.6.33-to-2.6.38-rc6_memory.png

Munin graphs of fragmentation (buddyinfo): http://0x.ca/sim/ref/2.6.38/

I suspect this will cause problems for others as well. The performance
regression as well seems to be pushing backup times up to be slightly
too long, though I'm not sure if that's just VM or also btrfs changes.

Ideas?

Simon-


[399719.313562] aoe_tx: page allocation failure. order:1, mode:0x4020
[399719.313599] Pid: 3246, comm: aoe_tx Not tainted 2.6.38-rc6-hw+ #2
[399719.313628] Call Trace:
[399719.313661]  [<ffffffff810d10af>] ? __alloc_pages_nodemask+0x57f/0x810
[399719.313695]  [<ffffffff811062ad>] ? new_slab+0x20d/0x220
[399719.313723]  [<ffffffff8110653b>] ? __slab_alloc+0x27b/0x2c0
[399719.313753]  [<ffffffff815cbcd9>] ? pskb_expand_head+0xa9/0x2b0
[399719.313783]  [<ffffffff81106b0b>] ? __kmalloc+0x16b/0x1a0
[399719.313811]  [<ffffffff815cbcd9>] ? pskb_expand_head+0xa9/0x2b0
[399719.313840]  [<ffffffff815cc3ac>] ? __pskb_pull_tail+0x5c/0x350
[399719.313872]  [<ffffffff815d5fa6>] ? dev_hard_start_xmit+0x3e6/0x6a0
[399719.313908]  [<ffffffff815efe6f>] ? sch_direct_xmit+0x13f/0x1d0
[399719.313938]  [<ffffffff815d64a2>] ? dev_queue_xmit+0x242/0x5c0
[399719.313974]  [<ffffffffa001a0d5>] ? tx+0x45/0x90 [aoe]
[399719.314003]  [<ffffffffa0016c7c>] ? kthread+0x9c/0x100 [aoe]
[399719.314036]  [<ffffffff8104fb10>] ? default_wake_function+0x0/0x10
[399719.314067]  [<ffffffffa0016be0>] ? kthread+0x0/0x100 [aoe]
[399719.314099]  [<ffffffff810753b6>] ? kthread+0x96/0xb0
[399719.314128]  [<ffffffff8100cbe4>] ? kernel_thread_helper+0x4/0x10
[399719.314158]  [<ffffffff81075320>] ? kthread+0x0/0xb0
[399719.314185]  [<ffffffff8100cbe0>] ? kernel_thread_helper+0x0/0x10
[399719.314213] Mem-Info:
[399719.314235] DMA per-cpu:
[399719.314257] CPU    0: hi:    0, btch:   1 usd:   0
[399719.314284] CPU    1: hi:    0, btch:   1 usd:   0
[399719.314310] CPU    2: hi:    0, btch:   1 usd:   0
[399719.314336] CPU    3: hi:    0, btch:   1 usd:   0
[399719.314362] DMA32 per-cpu:
[399719.314384] CPU    0: hi:  186, btch:  31 usd: 153
[399719.314411] CPU    1: hi:  186, btch:  31 usd:  36
[399719.314437] CPU    2: hi:  186, btch:  31 usd:  82
[399719.314463] CPU    3: hi:  186, btch:  31 usd:  57
[399719.314489] Normal per-cpu:
[399719.314512] CPU    0: hi:  186, btch:  31 usd: 164
[399719.314538] CPU    1: hi:  186, btch:  31 usd: 142
[399719.314564] CPU    2: hi:  186, btch:  31 usd: 175
[399719.314591] CPU    3: hi:  186, btch:  31 usd:  60
[399719.314621] active_anon:11748 inactive_anon:8062 isolated_anon:0
[399719.314622]  active_file:1382798 inactive_file:1682148 isolated_file:0
[399719.314623]  unevictable:0 dirty:298209 writeback:1326 unstable:0
[399719.314624]  free:38054 slab_reclaimable:943251 slab_unreclaimable:31133
[399719.314626]  mapped:1752 shmem:716 pagetables:1480 bounce:0
[399719.314765] DMA free:15876kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15700kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[399719.314918] lowmem_reserve[]: 0 2995 16125 16125
[399719.314959] DMA32 free:119836kB min:3016kB low:3768kB high:4524kB active_anon:1512kB inactive_anon:1456kB active_file:50784kB inactive_file:542556kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3067424kB mlocked:0kB dirty:40988kB writeback:104kB mapped:116kB shmem:0kB slab_reclaimable:2060704kB slab_unreclaimable:11732kB kernel_stack:552kB pagetables:328kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[399719.315119] lowmem_reserve[]: 0 0 13130 13130
[399719.315160] Normal free:16504kB min:13224kB low:16528kB high:19836kB active_anon:45480kB inactive_anon:30792kB active_file:5480408kB inactive_file:6186036kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:13445120kB mlocked:0kB dirty:1151848kB writeback:5200kB mapped:6892kB shmem:2864kB slab_reclaimable:1712300kB slab_unreclaimable:112784kB kernel_stack:3040kB pagetables:5592kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[399719.315323] lowmem_reserve[]: 0 0 0 0
[399719.315357] DMA: 1*4kB 0*8kB 0*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15876kB
[399719.315432] DMA32: 29825*4kB 0*8kB 28*16kB 5*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 119908kB
[399719.315720] Normal: 3755*4kB 1*8kB 0*16kB 10*32kB 8*64kB 4*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 16628kB
[399719.315793] 3065785 total pagecache pages
[399719.315817] 68 pages in swap cache
[399719.315840] Swap cache stats: add 311, delete 243, find 1548/1566
[399719.315869] Free swap  = 15630756kB
[399719.315892] Total swap = 15631208kB
[399719.316005] 4194288 pages RAM
[399719.316005] 84372 pages reserved
[399719.316005] 2782402 pages shared
[399719.316005] 2191956 pages non-shared
[399719.316005] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
[399719.316005]   cache: kmalloc-8192, object size: 8192, buffer size: 8192, default order: 3, min order: 1
[399719.316005]   node 0: slabs: 11, objs: 44, free: 0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
