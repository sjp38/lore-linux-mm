Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4F8806B004D
	for <linux-mm@kvack.org>; Mon, 16 Nov 2009 07:08:53 -0500 (EST)
Received: by bwz7 with SMTP id 7so6058599bwz.6
        for <linux-mm@kvack.org>; Mon, 16 Nov 2009 04:08:49 -0800 (PST)
Date: Mon, 16 Nov 2009 13:08:45 +0100
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [PATCH 0/5] Reduce GFP_ATOMIC allocation failures, candidate
	fix V3
Message-ID: <20091116120845.GA10115@bizet.domek.prywatny>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie> <20091115120721.GA7557@bizet.domek.prywatny> <20091116095258.GS29804@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091116095258.GS29804@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Karol Lewandowski <karol.k.lewandowski@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 16, 2009 at 09:52:58AM +0000, Mel Gorman wrote:
> On Sun, Nov 15, 2009 at 01:07:21PM +0100, Karol Lewandowski wrote:
> >              total       used       free     shared    buffers     cached
> > Mem:        255240     194052      61188          0       4040      49364
> > -/+ buffers/cache:     140648     114592
> > Swap:       514040      72712     441328
> > 
> > 
> > Is that ok?  Wild guess -- maybe kswapd doesn't take fragmentation (or
> > other factors) into account as hard as it used to in 2.6.30?

> That's a lot of memory free. I take it the order-5 GFP_ATOMIC allocation
> failed. What was the dmesg for it please?

Sure, it's attached below.

Hmm, "Normal free"/"DMA free" are much lower than 61MB as shown above.
free(1) output was collected right after resume successfully finished.

Thanks.


e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
e100 0000:00:03.0: PCI INT A -> Link[LNKC] -> GSI 9 (level, low) -> IRQ 9
e100 0000:00:03.0: PME# disabled
e100: eth0: e100_probe: addr 0xe8120000, irq 9, MAC addr 00:10:a4:89:e8:84
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 7339, comm: ifconfig Not tainted 2.6.32-rc7-dirty #3
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
CPU    0: hi:   90, btch:  15 usd:  89
active_anon:15632 inactive_anon:17534 isolated_anon:0
 active_file:12373 inactive_file:12884 isolated_file:0
 unevictable:0 dirty:15 writeback:62 unstable:0
 free:2072 slab_reclaimable:849 slab_unreclaimable:1080
 mapped:7343 shmem:233 pagetables:505 bounce:0
DMA free:1440kB min:120kB low:148kB high:180kB active_anon:224kB inactive_anon:1516kB active_file:3440kB inactive_file:5140kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15808kB mlocked:0kB dirty:0kB writeback:0kB mapped:404kB shmem:44kB slab_reclaimable:16kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:6848kB min:1912kB low:2388kB high:2868kB active_anon:62304kB inactive_anon:68620kB active_file:46052kB inactive_file:46396kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:60kB writeback:248kB mapped:28968kB shmem:888kB slab_reclaimable:3380kB slab_unreclaimable:4304kB kernel_stack:464kB pagetables:2020kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:128 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 4*4kB 8*8kB 33*16kB 22*32kB 2*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1440kB
Normal: 486*4kB 271*8kB 139*16kB 12*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 6848kB
29040 total pagecache pages
3548 pages in swap cache
Swap cache stats: add 72385, delete 68837, find 70772/74308
Free swap  = 483200kB
Total swap = 514040kB
65520 pages RAM
1726 pages reserved
20970 pages shared
50976 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 7339, comm: ifconfig Not tainted 2.6.32-rc7-dirty #3
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
CPU    0: hi:   90, btch:  15 usd:  82
active_anon:15563 inactive_anon:17593 isolated_anon:0
 active_file:12294 inactive_file:12787 isolated_file:0
 unevictable:0 dirty:18 writeback:155 unstable:0
 free:2267 slab_reclaimable:847 slab_unreclaimable:1080
 mapped:7271 shmem:229 pagetables:505 bounce:0
DMA free:1440kB min:120kB low:148kB high:180kB active_anon:224kB inactive_anon:1516kB active_file:3440kB inactive_file:5140kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15808kB mlocked:0kB dirty:0kB writeback:0kB mapped:404kB shmem:44kB slab_reclaimable:16kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:7628kB min:1912kB low:2388kB high:2868kB active_anon:62028kB inactive_anon:68856kB active_file:45736kB inactive_file:46008kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:72kB writeback:620kB mapped:28680kB shmem:872kB slab_reclaimable:3372kB slab_unreclaimable:4304kB kernel_stack:464kB pagetables:2020kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 4*4kB 8*8kB 33*16kB 22*32kB 2*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1440kB
Normal: 559*4kB 290*8kB 152*16kB 16*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 7628kB
29016 total pagecache pages
3702 pages in swap cache
Swap cache stats: add 72550, delete 68848, find 70774/74310
Free swap  = 482540kB
Total swap = 514040kB
65520 pages RAM
1726 pages reserved
20826 pages shared
50895 pages non-shared
e100 0000:00:03.0: firmware: requesting e100/d101s_ucode.bin
e100: eth0 NIC Link is Up 100 Mbps Full Duplex
crashreporter[9491]: segfault at b67701a0 ip b67701a0 sp bfa0fc2c error 4 in libnss_files-2.7.so[b67b6000+a000]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
