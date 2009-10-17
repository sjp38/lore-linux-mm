Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 566DE6B004F
	for <linux-mm@kvack.org>; Sat, 17 Oct 2009 14:34:30 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id d23so705506fga.8
        for <linux-mm@kvack.org>; Sat, 17 Oct 2009 11:34:26 -0700 (PDT)
Date: Sat, 17 Oct 2009 20:34:21 +0200
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [PATCH 0/2] Reduce number of GFP_ATOMIC allocation failures
Message-ID: <20091017183421.GA3370@bizet.domek.prywatny>
References: <1255689446-3858-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1255689446-3858-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Frans Pop <elendil@planet.nl>, reinette chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 16, 2009 at 11:37:24AM +0100, Mel Gorman wrote:
> The following two patches against 2.6.32-rc4 should reduce allocation
> failure reports for GFP_ATOMIC allocations that have being cropping up
> since 2.6.31-rc1.
...
> The patches should also help the following bugs as well and testing there
> would be appreciated.
> 
> [Bug #14265] ifconfig: page allocation failure. order:5, mode:0x8020 w/ e100
> 
> It might also have helped the following bug

These patches actually made situation kind-of "worse" for this
particular issue.

I've tried patches with post 2.6.32-rc4 kernel and after second
suspend-resume cycle I got typical "order:5" failure.  However, this
time when I manually tried to bring interface up ("ifup eth0") it
failed for 4 consecutive times with "Can't allocate memory".  Before
applying these patches this never occured -- kernel sometimes failed
to allocate memory during resume, but it *never* failed afterwards.

I'll go now for another round of bisecting... and hopefully this time
I'll be able to trigger this problem on different/faster computer with
e100-based card.


> although that driver has already been fixed by not making high-order
> atomic allocations.

Driver has been fixed?  The one patch that I saw (by davem[1]) didn't
fix this issue.  As of 2.6.32-rc5 I see no fixes to e100.c in
mainline, has there been another than this[1] fix posted somewhere?

[1] http://lkml.org/lkml/2009/10/12/169

Thanks.


e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
e100 0000:00:03.0: PCI INT A -> Link[LNKC] -> GSI 9 (level, low) -> IRQ 9
e100 0000:00:03.0: PME# disabled
e100: eth0: e100_probe: addr 0xe8120000, irq 9, MAC addr 00:10:a4:89:e8:84
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 3124, comm: ifconfig Tainted: G        W  2.6.32-rc4+mel-00001-gd93a8f8-dirty #3
Call Trace:
 [<c016102a>] ? __alloc_pages_nodemask+0x434/0x49c
 [<c02fffd2>] ? __netdev_alloc_skb+0x14/0x2d
 [<c0104d7f>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0104d35>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0921b6f>] ? e100_alloc_cbs+0xc7/0x174 [e100]
 [<d0922bfe>] ? e100_up+0x1b/0xf5 [e100]
 [<d0922cef>] ? e100_open+0x17/0x41 [e100]
 [<c0305f01>] ? dev_open+0x8f/0xc5
 [<c03056c0>] ? dev_change_flags+0xa2/0x155
 [<c033c0f3>] ? devinet_ioctl+0x22a/0x51b
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c02f92ae>] ? sock_ioctl+0x1c0/0x1e4
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c01872ce>] ? vfs_ioctl+0x16/0x4a
 [<c0187b9a>] ? do_vfs_ioctl+0x48f/0x4c6
 [<c016dfa7>] ? handle_mm_fault+0x214/0x462
 [<c0356e7e>] ? do_page_fault+0x2ce/0x2e4
 [<c0187bfd>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  32
active_anon:23130 inactive_anon:23583 isolated_anon:0
 active_file:6605 inactive_file:6298 isolated_file:0
 unevictable:0 dirty:17 writeback:1 unstable:0 buffer:794
 free:1030 slab_reclaimable:795 slab_unreclaimable:1056
 mapped:9004 shmem:653 pagetables:513 bounce:0
DMA free:1104kB min:124kB low:152kB high:184kB active_anon:3848kB inactive_anon:4400kB active_file:1032kB inactive_file:1376kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15868kB mlocked:0kB dirty:0kB writeback:0kB mapped:508kB shmem:92kB slab_reclaimable:40kB slab_unreclaimable:64kB kernel_stack:0kB pagetables:12kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:3016kB min:1908kB low:2384kB high:2860kB active_anon:88672kB inactive_anon:89932kB active_file:25388kB inactive_file:23816kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:68kB writeback:4kB mapped:35508kB shmem:2520kB slab_reclaimable:3140kB slab_unreclaimable:4160kB kernel_stack:496kB pagetables:2040kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 4*4kB 6*8kB 1*16kB 2*32kB 5*64kB 5*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1104kB
Normal: 310*4kB 70*8kB 62*16kB 7*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3016kB
15712 total pagecache pages
2156 pages in swap cache
Swap cache stats: add 7794, delete 5638, find 8802/9281
Free swap  = 499860kB
Total swap = 514040kB
65520 pages RAM
1689 pages reserved
23609 pages shared
52171 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 3124, comm: ifconfig Tainted: G        W  2.6.32-rc4+mel-00001-gd93a8f8-dirty #3
Call Trace:
 [<c016102a>] ? __alloc_pages_nodemask+0x434/0x49c
 [<c02fffd2>] ? __netdev_alloc_skb+0x14/0x2d
 [<c0104d7f>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0104d35>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0921b6f>] ? e100_alloc_cbs+0xc7/0x174 [e100]
 [<d0922bfe>] ? e100_up+0x1b/0xf5 [e100]
 [<d0922cef>] ? e100_open+0x17/0x41 [e100]
 [<c0305f01>] ? dev_open+0x8f/0xc5
 [<c03056c0>] ? dev_change_flags+0xa2/0x155
 [<c033c0f3>] ? devinet_ioctl+0x22a/0x51b
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c02f92ae>] ? sock_ioctl+0x1c0/0x1e4
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c01872ce>] ? vfs_ioctl+0x16/0x4a
 [<c0187b9a>] ? do_vfs_ioctl+0x48f/0x4c6
 [<c017dcf8>] ? vfs_write+0xf4/0x105
 [<c0187bfd>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  41
active_anon:23092 inactive_anon:23619 isolated_anon:0
 active_file:6579 inactive_file:6315 isolated_file:0
 unevictable:0 dirty:20 writeback:50 unstable:0 buffer:796
 free:1030 slab_reclaimable:795 slab_unreclaimable:1055
 mapped:8995 shmem:653 pagetables:513 bounce:0
DMA free:1104kB min:124kB low:152kB high:184kB active_anon:3848kB inactive_anon:4400kB active_file:1032kB inactive_file:1376kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15868kB mlocked:0kB dirty:0kB writeback:0kB mapped:508kB shmem:92kB slab_reclaimable:40kB slab_unreclaimable:64kB kernel_stack:0kB pagetables:12kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:3016kB min:1908kB low:2384kB high:2860kB active_anon:88520kB inactive_anon:90076kB active_file:25284kB inactive_file:23884kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:80kB writeback:200kB mapped:35472kB shmem:2520kB slab_reclaimable:3140kB slab_unreclaimable:4156kB kernel_stack:496kB pagetables:2040kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:106 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 4*4kB 6*8kB 1*16kB 2*32kB 5*64kB 5*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1104kB
Normal: 310*4kB 70*8kB 64*16kB 6*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3016kB
15751 total pagecache pages
2199 pages in swap cache
Swap cache stats: add 7843, delete 5644, find 8802/9281
Free swap  = 499664kB
Total swap = 514040kB
65520 pages RAM
1689 pages reserved
23620 pages shared
52169 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 3162, comm: ifconfig Tainted: G        W  2.6.32-rc4+mel-00001-gd93a8f8-dirty #3
Call Trace:
 [<c016102a>] ? __alloc_pages_nodemask+0x434/0x49c
 [<c02fffd2>] ? __netdev_alloc_skb+0x14/0x2d
 [<c0104d7f>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0104d35>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0921b6f>] ? e100_alloc_cbs+0xc7/0x174 [e100]
 [<d0922bfe>] ? e100_up+0x1b/0xf5 [e100]
 [<d0922cef>] ? e100_open+0x17/0x41 [e100]
 [<c0305f01>] ? dev_open+0x8f/0xc5
 [<c03056c0>] ? dev_change_flags+0xa2/0x155
 [<c033c0f3>] ? devinet_ioctl+0x22a/0x51b
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c02f92ae>] ? sock_ioctl+0x1c0/0x1e4
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c01872ce>] ? vfs_ioctl+0x16/0x4a
 [<c0187b9a>] ? do_vfs_ioctl+0x48f/0x4c6
 [<c016dfa7>] ? handle_mm_fault+0x214/0x462
 [<c0356e7e>] ? do_page_fault+0x2ce/0x2e4
 [<c0187bfd>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  81
active_anon:21489 inactive_anon:24914 isolated_anon:0
 active_file:5995 inactive_file:6126 isolated_file:0
 unevictable:0 dirty:23 writeback:355 unstable:0 buffer:755
 free:2125 slab_reclaimable:783 slab_unreclaimable:1060
 mapped:8173 shmem:629 pagetables:475 bounce:0
DMA free:1104kB min:124kB low:152kB high:184kB active_anon:3848kB inactive_anon:4400kB active_file:1032kB inactive_file:1376kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15868kB mlocked:0kB dirty:0kB writeback:0kB mapped:508kB shmem:92kB slab_reclaimable:40kB slab_unreclaimable:64kB kernel_stack:0kB pagetables:12kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:7396kB min:1908kB low:2384kB high:2860kB active_anon:82108kB inactive_anon:95256kB active_file:22948kB inactive_file:23128kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:92kB writeback:1420kB mapped:32184kB shmem:2424kB slab_reclaimable:3092kB slab_unreclaimable:4176kB kernel_stack:464kB pagetables:1888kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 4*4kB 6*8kB 1*16kB 2*32kB 5*64kB 5*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1104kB
Normal: 629*4kB 216*8kB 117*16kB 40*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 7396kB
17084 total pagecache pages
4327 pages in swap cache
Swap cache stats: add 10245, delete 5918, find 8975/9466
Free swap  = 490612kB
Total swap = 514040kB
65520 pages RAM
1689 pages reserved
20322 pages shared
52044 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 3162, comm: ifconfig Tainted: G        W  2.6.32-rc4+mel-00001-gd93a8f8-dirty #3
Call Trace:
 [<c016102a>] ? __alloc_pages_nodemask+0x434/0x49c
 [<c02fffd2>] ? __netdev_alloc_skb+0x14/0x2d
 [<c0104d7f>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0104d35>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0921b6f>] ? e100_alloc_cbs+0xc7/0x174 [e100]
 [<d0922bfe>] ? e100_up+0x1b/0xf5 [e100]
 [<d0922cef>] ? e100_open+0x17/0x41 [e100]
 [<c0305f01>] ? dev_open+0x8f/0xc5
 [<c03056c0>] ? dev_change_flags+0xa2/0x155
 [<c033c0f3>] ? devinet_ioctl+0x22a/0x51b
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c02f92ae>] ? sock_ioctl+0x1c0/0x1e4
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c01872ce>] ? vfs_ioctl+0x16/0x4a
 [<c0187b9a>] ? do_vfs_ioctl+0x48f/0x4c6
 [<c016dfa7>] ? handle_mm_fault+0x214/0x462
 [<c011c0a1>] ? finish_task_switch+0x23/0x61
 [<c0187bfd>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  85
active_anon:21451 inactive_anon:24950 isolated_anon:0
 active_file:5975 inactive_file:6122 isolated_file:0
 unevictable:0 dirty:23 writeback:430 unstable:0 buffer:755
 free:2155 slab_reclaimable:781 slab_unreclaimable:1060
 mapped:8142 shmem:629 pagetables:475 bounce:0
DMA free:1104kB min:124kB low:152kB high:184kB active_anon:3848kB inactive_anon:4400kB active_file:1032kB inactive_file:1376kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15868kB mlocked:0kB dirty:0kB writeback:0kB mapped:508kB shmem:92kB slab_reclaimable:40kB slab_unreclaimable:64kB kernel_stack:0kB pagetables:12kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:7516kB min:1908kB low:2384kB high:2860kB active_anon:81956kB inactive_anon:95400kB active_file:22868kB inactive_file:23112kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:92kB writeback:1720kB mapped:32060kB shmem:2424kB slab_reclaimable:3084kB slab_unreclaimable:4176kB kernel_stack:464kB pagetables:1888kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:32 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 4*4kB 6*8kB 1*16kB 2*32kB 5*64kB 5*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1104kB
Normal: 647*4kB 218*8kB 119*16kB 40*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 7516kB
17126 total pagecache pages
4398 pages in swap cache
Swap cache stats: add 10320, delete 5922, find 8975/9466
Free swap  = 490312kB
Total swap = 514040kB
65520 pages RAM
1689 pages reserved
20263 pages shared
52046 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 3233, comm: ifconfig Tainted: G        W  2.6.32-rc4+mel-00001-gd93a8f8-dirty #3
Call Trace:
 [<c016102a>] ? __alloc_pages_nodemask+0x434/0x49c
 [<c02fffd2>] ? __netdev_alloc_skb+0x14/0x2d
 [<c0104d7f>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0104d35>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0921b6f>] ? e100_alloc_cbs+0xc7/0x174 [e100]
 [<d0922bfe>] ? e100_up+0x1b/0xf5 [e100]
 [<d0922cef>] ? e100_open+0x17/0x41 [e100]
 [<c0305f01>] ? dev_open+0x8f/0xc5
 [<c03056c0>] ? dev_change_flags+0xa2/0x155
 [<c033c0f3>] ? devinet_ioctl+0x22a/0x51b
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c02f92ae>] ? sock_ioctl+0x1c0/0x1e4
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c01872ce>] ? vfs_ioctl+0x16/0x4a
 [<c0187b9a>] ? do_vfs_ioctl+0x48f/0x4c6
 [<c016dfa7>] ? handle_mm_fault+0x214/0x462
 [<c0356e7e>] ? do_page_fault+0x2ce/0x2e4
 [<c0187bfd>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  37
active_anon:20712 inactive_anon:27914 isolated_anon:0
 active_file:5526 inactive_file:5663 isolated_file:0
 unevictable:0 dirty:6 writeback:0 unstable:0 buffer:654
 free:938 slab_reclaimable:767 slab_unreclaimable:1049
 mapped:6797 shmem:603 pagetables:460 bounce:0
DMA free:1008kB min:124kB low:152kB high:184kB active_anon:3908kB inactive_anon:4528kB active_file:1024kB inactive_file:1196kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15868kB mlocked:0kB dirty:0kB writeback:0kB mapped:484kB shmem:92kB slab_reclaimable:40kB slab_unreclaimable:160kB kernel_stack:0kB pagetables:12kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:2744kB min:1908kB low:2384kB high:2860kB active_anon:78940kB inactive_anon:107128kB active_file:21080kB inactive_file:21456kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:24kB writeback:0kB mapped:26704kB shmem:2320kB slab_reclaimable:3028kB slab_unreclaimable:4036kB kernel_stack:444kB pagetables:1828kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 2*4kB 1*8kB 0*16kB 1*32kB 5*64kB 5*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1008kB
Normal: 504*4kB 67*8kB 12*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2744kB
20891 total pagecache pages
9099 pages in swap cache
Swap cache stats: add 16321, delete 7222, find 10310/10862
Free swap  = 470564kB
Total swap = 514040kB
65520 pages RAM
1689 pages reserved
16854 pages shared
54310 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 3233, comm: ifconfig Tainted: G        W  2.6.32-rc4+mel-00001-gd93a8f8-dirty #3
Call Trace:
 [<c016102a>] ? __alloc_pages_nodemask+0x434/0x49c
 [<c02fffd2>] ? __netdev_alloc_skb+0x14/0x2d
 [<c0104d7f>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0104d35>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0921b6f>] ? e100_alloc_cbs+0xc7/0x174 [e100]
 [<d0922bfe>] ? e100_up+0x1b/0xf5 [e100]
 [<d0922cef>] ? e100_open+0x17/0x41 [e100]
 [<c0305f01>] ? dev_open+0x8f/0xc5
 [<c03056c0>] ? dev_change_flags+0xa2/0x155
 [<c033c0f3>] ? devinet_ioctl+0x22a/0x51b
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c02f92ae>] ? sock_ioctl+0x1c0/0x1e4
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c01872ce>] ? vfs_ioctl+0x16/0x4a
 [<c0187b9a>] ? do_vfs_ioctl+0x48f/0x4c6
 [<c01703df>] ? unmap_region+0xa2/0xd1
 [<c0170451>] ? remove_vma+0x43/0x48
 [<c0170f56>] ? do_munmap+0x20e/0x228
 [<c0187bfd>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  65
active_anon:20632 inactive_anon:27994 isolated_anon:0
 active_file:5497 inactive_file:5648 isolated_file:0
 unevictable:0 dirty:12 writeback:167 unstable:0 buffer:647
 free:956 slab_reclaimable:767 slab_unreclaimable:1049
 mapped:6763 shmem:601 pagetables:460 bounce:0
DMA free:1008kB min:124kB low:152kB high:184kB active_anon:3908kB inactive_anon:4528kB active_file:1024kB inactive_file:1196kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15868kB mlocked:0kB dirty:0kB writeback:0kB mapped:484kB shmem:92kB slab_reclaimable:40kB slab_unreclaimable:160kB kernel_stack:0kB pagetables:12kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:2816kB min:1908kB low:2384kB high:2860kB active_anon:78620kB inactive_anon:107448kB active_file:20964kB inactive_file:21396kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:48kB writeback:668kB mapped:26568kB shmem:2312kB slab_reclaimable:3028kB slab_unreclaimable:4036kB kernel_stack:444kB pagetables:1828kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:32 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 2*4kB 1*8kB 0*16kB 1*32kB 5*64kB 5*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1008kB
Normal: 518*4kB 69*8kB 12*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2816kB
21005 total pagecache pages
9259 pages in swap cache
Swap cache stats: add 16488, delete 7229, find 10317/10869
Free swap  = 469908kB
Total swap = 514040kB
65520 pages RAM
1689 pages reserved
16828 pages shared
54302 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 3243, comm: ifconfig Tainted: G        W  2.6.32-rc4+mel-00001-gd93a8f8-dirty #3
Call Trace:
 [<c016102a>] ? __alloc_pages_nodemask+0x434/0x49c
 [<c02fffd2>] ? __netdev_alloc_skb+0x14/0x2d
 [<c0104d7f>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0104d35>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0921b6f>] ? e100_alloc_cbs+0xc7/0x174 [e100]
 [<d0922bfe>] ? e100_up+0x1b/0xf5 [e100]
 [<d0922cef>] ? e100_open+0x17/0x41 [e100]
 [<c0305f01>] ? dev_open+0x8f/0xc5
 [<c03056c0>] ? dev_change_flags+0xa2/0x155
 [<c033c0f3>] ? devinet_ioctl+0x22a/0x51b
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c02f92ae>] ? sock_ioctl+0x1c0/0x1e4
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c01872ce>] ? vfs_ioctl+0x16/0x4a
 [<c0187b9a>] ? do_vfs_ioctl+0x48f/0x4c6
 [<c016dfa7>] ? handle_mm_fault+0x214/0x462
 [<c0356e7e>] ? do_page_fault+0x2ce/0x2e4
 [<c0187bfd>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  31
active_anon:20171 inactive_anon:29004 isolated_anon:0
 active_file:5325 inactive_file:5150 isolated_file:0
 unevictable:0 dirty:1 writeback:0 unstable:0 buffer:540
 free:1105 slab_reclaimable:766 slab_unreclaimable:1052
 mapped:6400 shmem:587 pagetables:461 bounce:0
DMA free:1104kB min:124kB low:152kB high:184kB active_anon:3908kB inactive_anon:4528kB active_file:1024kB inactive_file:1196kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15868kB mlocked:0kB dirty:0kB writeback:0kB mapped:484kB shmem:92kB slab_reclaimable:40kB slab_unreclaimable:64kB kernel_stack:0kB pagetables:12kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:3316kB min:1908kB low:2384kB high:2860kB active_anon:76776kB inactive_anon:111488kB active_file:20276kB inactive_file:19404kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:4kB writeback:0kB mapped:25116kB shmem:2256kB slab_reclaimable:3024kB slab_unreclaimable:4144kB kernel_stack:444kB pagetables:1832kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 2*4kB 1*8kB 2*16kB 1*32kB 6*64kB 5*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1104kB
Normal: 477*4kB 118*8kB 17*16kB 4*32kB 1*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3316kB
21943 total pagecache pages
10881 pages in swap cache
Swap cache stats: add 18555, delete 7674, find 10542/11111
Free swap  = 462548kB
Total swap = 514040kB
65520 pages RAM
1689 pages reserved
15831 pages shared
54614 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 3243, comm: ifconfig Tainted: G        W  2.6.32-rc4+mel-00001-gd93a8f8-dirty #3
Call Trace:
 [<c016102a>] ? __alloc_pages_nodemask+0x434/0x49c
 [<c02fffd2>] ? __netdev_alloc_skb+0x14/0x2d
 [<c0104d7f>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0104d35>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0921b6f>] ? e100_alloc_cbs+0xc7/0x174 [e100]
 [<d0922bfe>] ? e100_up+0x1b/0xf5 [e100]
 [<d0922cef>] ? e100_open+0x17/0x41 [e100]
 [<c0305f01>] ? dev_open+0x8f/0xc5
 [<c03056c0>] ? dev_change_flags+0xa2/0x155
 [<c033c0f3>] ? devinet_ioctl+0x22a/0x51b
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c02f92ae>] ? sock_ioctl+0x1c0/0x1e4
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c01872ce>] ? vfs_ioctl+0x16/0x4a
 [<c0187b9a>] ? do_vfs_ioctl+0x48f/0x4c6
 [<c01703df>] ? unmap_region+0xa2/0xd1
 [<c0170451>] ? remove_vma+0x43/0x48
 [<c0170f56>] ? do_munmap+0x20e/0x228
 [<c0187bfd>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  80
active_anon:20156 inactive_anon:29018 isolated_anon:0
 active_file:5269 inactive_file:5148 isolated_file:0
 unevictable:0 dirty:2 writeback:49 unstable:0 buffer:537
 free:1120 slab_reclaimable:766 slab_unreclaimable:1052
 mapped:6390 shmem:587 pagetables:461 bounce:0
DMA free:1104kB min:124kB low:152kB high:184kB active_anon:3908kB inactive_anon:4528kB active_file:1024kB inactive_file:1196kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15868kB mlocked:0kB dirty:0kB writeback:0kB mapped:484kB shmem:92kB slab_reclaimable:40kB slab_unreclaimable:64kB kernel_stack:0kB pagetables:12kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:3376kB min:1908kB low:2384kB high:2860kB active_anon:76716kB inactive_anon:111544kB active_file:20052kB inactive_file:19396kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:8kB writeback:196kB mapped:25076kB shmem:2256kB slab_reclaimable:3024kB slab_unreclaimable:4144kB kernel_stack:444kB pagetables:1832kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:68 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 2*4kB 1*8kB 2*16kB 1*32kB 6*64kB 5*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1104kB
Normal: 484*4kB 122*8kB 17*16kB 4*32kB 1*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3376kB
21928 total pagecache pages
10924 pages in swap cache
Swap cache stats: add 18604, delete 7680, find 10544/11113
Free swap  = 462352kB
Total swap = 514040kB
65520 pages RAM
1689 pages reserved
15831 pages shared
54564 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 3250, comm: ifconfig Tainted: G        W  2.6.32-rc4+mel-00001-gd93a8f8-dirty #3
Call Trace:
 [<c016102a>] ? __alloc_pages_nodemask+0x434/0x49c
 [<c02fffd2>] ? __netdev_alloc_skb+0x14/0x2d
 [<c0104d7f>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0104d35>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0921b6f>] ? e100_alloc_cbs+0xc7/0x174 [e100]
 [<d0922bfe>] ? e100_up+0x1b/0xf5 [e100]
 [<d0922cef>] ? e100_open+0x17/0x41 [e100]
 [<c0305f01>] ? dev_open+0x8f/0xc5
 [<c03056c0>] ? dev_change_flags+0xa2/0x155
 [<c033c0f3>] ? devinet_ioctl+0x22a/0x51b
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c02f92ae>] ? sock_ioctl+0x1c0/0x1e4
 [<c02f90ee>] ? sock_ioctl+0x0/0x1e4
 [<c01872ce>] ? vfs_ioctl+0x16/0x4a
 [<c0187b9a>] ? do_vfs_ioctl+0x48f/0x4c6
 [<c016dfa7>] ? handle_mm_fault+0x214/0x462
 [<c0356e7e>] ? do_page_fault+0x2ce/0x2e4
 [<c0187bfd>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  40
active_anon:20047 inactive_anon:29327 isolated_anon:0
 active_file:5168 inactive_file:5206 isolated_file:0
 unevictable:0 dirty:29 writeback:0 unstable:0 buffer:518
 free:1001 slab_reclaimable:763 slab_unreclaimable:1052
 mapped:6358 shmem:585 pagetables:461 bounce:0
DMA free:1108kB min:124kB low:152kB high:184kB active_anon:3908kB inactive_anon:4528kB active_file:1024kB inactive_file:1196kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15868kB mlocked:0kB dirty:0kB writeback:0kB mapped:484kB shmem:92kB slab_reclaimable:36kB slab_unreclaimable:64kB kernel_stack:0kB pagetables:12kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:2896kB min:1908kB low:2384kB high:2860kB active_anon:76280kB inactive_anon:112780kB active_file:19648kB inactive_file:19628kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:116kB writeback:0kB mapped:24948kB shmem:2248kB slab_reclaimable:3016kB slab_unreclaimable:4144kB kernel_stack:448kB pagetables:1832kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 3*4kB 1*8kB 2*16kB 1*32kB 6*64kB 5*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1108kB
Normal: 398*4kB 61*8kB 25*16kB 7*32kB 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2896kB
22378 total pagecache pages
11419 pages in swap cache
Swap cache stats: add 19190, delete 7771, find 10577/11151
Free swap  = 460168kB
Total swap = 514040kB
65520 pages RAM
1689 pages reserved
15753 pages shared
54757 pages non-shared
e100 0000:00:03.0: firmware: requesting e100/d101s_ucode.bin
ADDRCONF(NETDEV_UP): eth0: link is not ready
e100: eth0 NIC Link is Up 100 Mbps Full Duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: no IPv6 routers present

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
