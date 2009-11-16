Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 38A216B004D
	for <linux-mm@kvack.org>; Mon, 16 Nov 2009 09:34:08 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id d23so2062327fga.8
        for <linux-mm@kvack.org>; Mon, 16 Nov 2009 06:32:47 -0800 (PST)
Date: Mon, 16 Nov 2009 15:32:43 +0100
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [PATCH 0/5] Reduce GFP_ATOMIC allocation failures, candidate
	fix V3
Message-ID: <20091116143243.GA10602@bizet.domek.prywatny>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie> <20091115120721.GA7557@bizet.domek.prywatny> <20091116095258.GS29804@csn.ul.ie> <20091116120845.GA10115@bizet.domek.prywatny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091116120845.GA10115@bizet.domek.prywatny>
Sender: owner-linux-mm@kvack.org
To: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 16, 2009 at 01:08:45PM +0100, Karol Lewandowski wrote:
> On Mon, Nov 16, 2009 at 09:52:58AM +0000, Mel Gorman wrote:
> > On Sun, Nov 15, 2009 at 01:07:21PM +0100, Karol Lewandowski wrote:
> > >              total       used       free     shared    buffers     cached
> > > Mem:        255240     194052      61188          0       4040      49364
> > > -/+ buffers/cache:     140648     114592
> > > Swap:       514040      72712     441328
> > > 
> > > 
> > > Is that ok?  Wild guess -- maybe kswapd doesn't take fragmentation (or
> > > other factors) into account as hard as it used to in 2.6.30?
> 
> > That's a lot of memory free. I take it the order-5 GFP_ATOMIC allocation
> > failed. What was the dmesg for it please?
> 
> Sure, it's attached below.
> 
> Hmm, "Normal free"/"DMA free" are much lower than 61MB as shown above.
> free(1) output was collected right after resume successfully finished.

Replying to myself, but well, it happened again:

  $ free
             total       used       free     shared    buffers     cached
Mem:        255240     189400      65840          0       3968      58916
-/+ buffers/cache:     126516     128724
Swap:       514040      98460     415580


  $ dmesg

e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
e100 0000:00:03.0: PCI INT A -> Link[LNKC] -> GSI 9 (level, low) -> IRQ 9
e100 0000:00:03.0: PME# disabled
e100: eth0: e100_probe: addr 0xe8120000, irq 9, MAC addr 00:10:a4:89:e8:84
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 10402, comm: ifconfig Not tainted 2.6.32-rc7-dirty #3
Call Trace:
 [<c0168704>] ? __alloc_pages_nodemask+0x45d/0x4eb
 [<c01050b3>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0105069>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0935ba0>] ? e100_alloc_cbs+0xc2/0x16f [e100]
 [<d0936d23>] ? e100_up+0x1b/0xf5 [e100]
 [<d0936e14>] ? e100_open+0x17/0x41 [e100]
 [<c03245cc>] ? dev_open+0x8f/0xc5
 [<c0323d54>] ? dev_change_flags+0xa2/0x155
 [<c03576b0>] ? devinet_ioctl+0x22a/0x51e
 [<c0316ebc>] ? sock_ioctl+0x1b6/0x1da
 [<c0316d06>] ? sock_ioctl+0x0/0x1da
 [<c0193f9b>] ? vfs_ioctl+0x1c/0x5f
 [<c0194565>] ? do_vfs_ioctl+0x4bf/0x4fb
 [<c0373362>] ? do_page_fault+0x33b/0x351
 [<c01945cd>] ? sys_ioctl+0x2c/0x42
 [<c0102834>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  81
active_anon:10734 inactive_anon:19229 isolated_anon:0
 active_file:14360 inactive_file:14515 isolated_file:0
 unevictable:0 dirty:7 writeback:53 unstable:0
 free:1101 slab_reclaimable:1334 slab_unreclaimable:1143
 mapped:2686 shmem:44 pagetables:522 bounce:0
DMA free:1496kB min:120kB low:148kB high:180kB active_anon:724kB inactive_anon:1520kB active_file:3752kB inactive_file:3964kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15808kB mlocked:0kB dirty:0kB writeback:0kB mapped:324kB shmem:0kB slab_reclaimable:216kB slab_unreclaimable:36kB kernel_stack:4kB pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:2908kB min:1912kB low:2388kB high:2868kB active_anon:42212kB inactive_anon:75396kB active_file:53688kB inactive_file:54096kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:28kB writeback:212kB mapped:10420kB shmem:176kB slab_reclaimable:5120kB slab_unreclaimable:4536kB kernel_stack:444kB pagetables:2072kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 26*4kB 48*8kB 53*16kB 1*32kB 2*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1496kB
Normal: 275*4kB 58*8kB 50*16kB 13*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2908kB
35091 total pagecache pages
6168 pages in swap cache
Swap cache stats: add 367741, delete 361573, find 144185/185303
Free swap  = 438964kB
Total swap = 514040kB
65520 pages RAM
1726 pages reserved
13452 pages shared
53168 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 10402, comm: ifconfig Not tainted 2.6.32-rc7-dirty #3
Call Trace:
 [<c0168704>] ? __alloc_pages_nodemask+0x45d/0x4eb
 [<c01050b3>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0105069>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0935ba0>] ? e100_alloc_cbs+0xc2/0x16f [e100]
 [<d0936d23>] ? e100_up+0x1b/0xf5 [e100]
 [<d0936e14>] ? e100_open+0x17/0x41 [e100]
 [<c03245cc>] ? dev_open+0x8f/0xc5
 [<c0323d54>] ? dev_change_flags+0xa2/0x155
 [<c03576b0>] ? devinet_ioctl+0x22a/0x51e
 [<c0316ebc>] ? sock_ioctl+0x1b6/0x1da
 [<c0316d06>] ? sock_ioctl+0x0/0x1da
 [<c0193f9b>] ? vfs_ioctl+0x1c/0x5f
 [<c0194565>] ? do_vfs_ioctl+0x4bf/0x4fb
 [<c0189370>] ? vfs_write+0xf4/0x105
 [<c01945cd>] ? sys_ioctl+0x2c/0x42
 [<c0102834>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  93
active_anon:10715 inactive_anon:19236 isolated_anon:0
 active_file:14312 inactive_file:14473 isolated_file:0
 unevictable:0 dirty:7 writeback:52 unstable:0
 free:1191 slab_reclaimable:1334 slab_unreclaimable:1144
 mapped:2686 shmem:44 pagetables:522 bounce:0
DMA free:1496kB min:120kB low:148kB high:180kB active_anon:724kB inactive_anon:1520kB active_file:3752kB inactive_file:3964kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15808kB mlocked:0kB dirty:0kB writeback:0kB mapped:324kB shmem:0kB slab_reclaimable:216kB slab_unreclaimable:36kB kernel_stack:4kB pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:3268kB min:1912kB low:2388kB high:2868kB active_anon:42136kB inactive_anon:75424kB active_file:53496kB inactive_file:53928kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:28kB writeback:208kB mapped:10420kB shmem:176kB slab_reclaimable:5120kB slab_unreclaimable:4540kB kernel_stack:444kB pagetables:2072kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 26*4kB 48*8kB 53*16kB 1*32kB 2*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1496kB
Normal: 291*4kB 73*8kB 63*16kB 12*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3268kB
35039 total pagecache pages
6209 pages in swap cache
Swap cache stats: add 367794, delete 361585, find 144185/185304
Free swap  = 438756kB
Total swap = 514040kB
65520 pages RAM
1726 pages reserved
13445 pages shared
53086 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 10440, comm: ifconfig Not tainted 2.6.32-rc7-dirty #3
Call Trace:
 [<c0168704>] ? __alloc_pages_nodemask+0x45d/0x4eb
 [<c01050b3>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0105069>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0935ba0>] ? e100_alloc_cbs+0xc2/0x16f [e100]
 [<d0936d23>] ? e100_up+0x1b/0xf5 [e100]
 [<d0936e14>] ? e100_open+0x17/0x41 [e100]
 [<c03245cc>] ? dev_open+0x8f/0xc5
 [<c0323d54>] ? dev_change_flags+0xa2/0x155
 [<c03576b0>] ? devinet_ioctl+0x22a/0x51e
 [<c0316ebc>] ? sock_ioctl+0x1b6/0x1da
 [<c0316d06>] ? sock_ioctl+0x0/0x1da
 [<c0193f9b>] ? vfs_ioctl+0x1c/0x5f
 [<c0194565>] ? do_vfs_ioctl+0x4bf/0x4fb
 [<c0373362>] ? do_page_fault+0x33b/0x351
 [<c01945cd>] ? sys_ioctl+0x2c/0x42
 [<c0102834>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  27
active_anon:9587 inactive_anon:19792 isolated_anon:0
 active_file:12298 inactive_file:12256 isolated_file:0
 unevictable:0 dirty:13 writeback:442 unstable:0
 free:6098 slab_reclaimable:1287 slab_unreclaimable:1142
 mapped:2436 shmem:37 pagetables:519 bounce:0
DMA free:1948kB min:120kB low:148kB high:180kB active_anon:724kB inactive_anon:1520kB active_file:3752kB inactive_file:3524kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15808kB mlocked:0kB dirty:0kB writeback:0kB mapped:324kB shmem:0kB slab_reclaimable:208kB slab_unreclaimable:32kB kernel_stack:4kB pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:22444kB min:1912kB low:2388kB high:2868kB active_anon:37624kB inactive_anon:77648kB active_file:45440kB inactive_file:45500kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:52kB writeback:1768kB mapped:9420kB shmem:148kB slab_reclaimable:4940kB slab_unreclaimable:4536kB kernel_stack:444kB pagetables:2060kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 115*4kB 54*8kB 56*16kB 1*32kB 2*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1948kB
Normal: 2005*4kB 829*8kB 379*16kB 50*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 22444kB
32732 total pagecache pages
8128 pages in swap cache
Swap cache stats: add 370349, delete 362221, find 144309/185439
Free swap  = 428812kB
Total swap = 514040kB
65520 pages RAM
1726 pages reserved
10771 pages shared
50488 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 10440, comm: ifconfig Not tainted 2.6.32-rc7-dirty #3
Call Trace:
 [<c0168704>] ? __alloc_pages_nodemask+0x45d/0x4eb
 [<c01050b3>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0105069>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0935ba0>] ? e100_alloc_cbs+0xc2/0x16f [e100]
 [<d0936d23>] ? e100_up+0x1b/0xf5 [e100]
 [<d0936e14>] ? e100_open+0x17/0x41 [e100]
 [<c03245cc>] ? dev_open+0x8f/0xc5
 [<c0323d54>] ? dev_change_flags+0xa2/0x155
 [<c03576b0>] ? devinet_ioctl+0x22a/0x51e
 [<c0316ebc>] ? sock_ioctl+0x1b6/0x1da
 [<c0316d06>] ? sock_ioctl+0x0/0x1da
 [<c0193f9b>] ? vfs_ioctl+0x1c/0x5f
 [<c0194565>] ? do_vfs_ioctl+0x4bf/0x4fb
 [<c0101683>] ? __switch_to+0xf/0x14c
 [<c011d24b>] ? finish_task_switch+0x2e/0x7d
 [<c0370423>] ? schedule+0x4cc/0x4f3
 [<c01945cd>] ? sys_ioctl+0x2c/0x42
 [<c0102834>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  30
active_anon:9587 inactive_anon:19792 isolated_anon:0
 active_file:12298 inactive_file:12270 isolated_file:0
 unevictable:0 dirty:13 writeback:434 unstable:0
 free:6083 slab_reclaimable:1287 slab_unreclaimable:1143
 mapped:2449 shmem:37 pagetables:519 bounce:0
DMA free:1948kB min:120kB low:148kB high:180kB active_anon:724kB inactive_anon:1520kB active_file:3752kB inactive_file:3524kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15808kB mlocked:0kB dirty:0kB writeback:0kB mapped:324kB shmem:0kB slab_reclaimable:208kB slab_unreclaimable:32kB kernel_stack:4kB pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:22384kB min:1912kB low:2388kB high:2868kB active_anon:37624kB inactive_anon:77648kB active_file:45440kB inactive_file:45556kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:52kB writeback:1724kB mapped:9472kB shmem:148kB slab_reclaimable:4940kB slab_unreclaimable:4540kB kernel_stack:444kB pagetables:2060kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 115*4kB 54*8kB 56*16kB 1*32kB 2*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1948kB
Normal: 1990*4kB 829*8kB 379*16kB 50*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 22384kB
32740 total pagecache pages
8128 pages in swap cache
Swap cache stats: add 370349, delete 362221, find 144309/185439
Free swap  = 428812kB
Total swap = 514040kB
65520 pages RAM
1726 pages reserved
10844 pages shared
50429 pages non-shared

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
