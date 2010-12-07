Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 50D336B0093
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 10:21:42 -0500 (EST)
Date: Tue, 7 Dec 2010 23:21:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: ext4 memory leak?
Message-ID: <20101207152120.GA28220@localhost>
References: <20101205064430.GA15027@localhost>
 <4CFB9BE1.3030902@redhat.com>
 <20101207131136.GA20366@localhost>
 <20101207143351.GA23377@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="pWyiEgJYm5f9v55/"
Content-Disposition: inline
In-Reply-To: <20101207143351.GA23377@localhost>
Sender: owner-linux-mm@kvack.org
To: Theodore Ts'o <tytso@mit.edu>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Dec 07, 2010 at 10:33:51PM +0800, Wu Fengguang wrote:
> > In a simple dd test on a 8p system with "mem=256M", I find the light
> 
> When increasing to 10 concurrent dd tasks, I managed to crash ext4..
> (2 concurrent dd's are OK, with very good write performance.)
> 
> Here is the dmesg, which contains some ext4 routines.
> 
> It looks like a memory leak problem. Look at the attached
> vmstat-dirty.png, which is based on recorded vmstat numbers before
> system hang.  The global dirty/background thresholds keep decreasing.
> Their values are derived from determine_dirtyable_memory(). The
> decline means less and less reclaimable memory in the system.
> 
> ext3 and ext2 are fine, as you can see from the attached graphs.
> 
> The kernel is based on 2.6.37-rc4 with some additional writeback
> patches.

Here are more messages on vanilla 2.6.37-rc3. Attached is the kconfig.

Thanks,
Fengguang
---

[  158.713193] python invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0, oom_score_adj=0
[  158.713642] python cpuset=/ mems_allowed=0
[  158.713863] Pid: 2760, comm: python Not tainted 2.6.37-rc3 #154
[  158.714155] Call Trace:
[  158.714320]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  158.714605]  [<ffffffff81130593>] dump_header+0x83/0x200
[  158.714878]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  158.715170]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  158.715457]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  158.715732]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  158.716019]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  158.716299]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  158.716608]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  158.716904]  [<ffffffff81174c44>] new_slab+0x294/0x2a0
[  158.717169]  [<ffffffff81174e82>] ? __slab_alloc+0x232/0x450
[  158.717451]  [<ffffffff81174e97>] __slab_alloc+0x247/0x450
[  158.717725]  [<ffffffff81281951>] ? nfs_create_request+0x41/0x160
[  158.718021]  [<ffffffff81281951>] ? nfs_create_request+0x41/0x160
[  158.718321]  [<ffffffff81175d4c>] kmem_cache_alloc+0x17c/0x190
[  158.718609]  [<ffffffff81a33330>] ? _raw_spin_unlock_irq+0x30/0x40
[  158.718907]  [<ffffffff81a33330>] ? _raw_spin_unlock_irq+0x30/0x40
[  158.719203]  [<ffffffff81281951>] nfs_create_request+0x41/0x160
[  158.719499]  [<ffffffff81a33330>] ? _raw_spin_unlock_irq+0x30/0x40
[  158.719801]  [<ffffffff81283c30>] ? readpage_async_filler+0x0/0x150
[  158.720102]  [<ffffffff81283c95>] readpage_async_filler+0x65/0x150
[  158.720399]  [<ffffffff81283c30>] ? readpage_async_filler+0x0/0x150
[  158.720699]  [<ffffffff811388c2>] read_cache_pages+0xa2/0xf0
[  158.720983]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  158.721252]  [<ffffffff81284ba2>] nfs_readpages+0xe2/0x1b0
[  158.721524]  [<ffffffff812840c0>] ? nfs_pagein_one+0x0/0x100
[  158.721802]  [<ffffffff8113869c>] __do_page_cache_readahead+0x18c/0x260
[  158.722116]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  158.722438]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  158.722745]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  158.723003]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  158.723287]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  158.723595]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  158.723871]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  158.724163]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  158.724454]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  158.724764]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  158.725039]  [<ffffffff8114ce75>] ? might_fault+0xa5/0xb0
[  158.725306]  [<ffffffff8114ce2c>] ? might_fault+0x5c/0xb0
[  158.725572]  [<ffffffff81197961>] ? poll_select_copy_remaining+0x101/0x150
[  158.725893]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  158.726148]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  158.726456]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  158.726712] Mem-Info:
[  158.726861] Node 0 DMA per-cpu:
[  158.727076] CPU    0: hi:    0, btch:   1 usd:   0
[  158.727326] CPU    1: hi:    0, btch:   1 usd:   0
[  158.727570] CPU    2: hi:    0, btch:   1 usd:   0
[  158.727814] CPU    3: hi:    0, btch:   1 usd:   0
[  158.728057] CPU    4: hi:    0, btch:   1 usd:   0
[  158.728300] CPU    5: hi:    0, btch:   1 usd:   0
[  158.728543] CPU    6: hi:    0, btch:   1 usd:   0
[  158.728786] CPU    7: hi:    0, btch:   1 usd:   0
[  158.729027] Node 0 DMA32 per-cpu:
[  158.729250] CPU    0: hi:   90, btch:  15 usd:   6
[  158.729493] CPU    1: hi:   90, btch:  15 usd:   3
[  158.729736] CPU    2: hi:   90, btch:  15 usd:   0
[  158.729979] CPU    3: hi:   90, btch:  15 usd:  14
[  158.730222] CPU    4: hi:   90, btch:  15 usd:  27
[  158.730465] CPU    5: hi:   90, btch:  15 usd:   4
[  158.730707] CPU    6: hi:   90, btch:  15 usd:   0
[  158.730950] CPU    7: hi:   90, btch:  15 usd:   3
[  158.731195] active_anon:7304 inactive_anon:112 isolated_anon:0
[  158.731196]  active_file:405 inactive_file:2450 isolated_file:0
[  158.731197]  unevictable:0 dirty:198 writeback:810 unstable:0
[  158.731197]  free:761 slab_reclaimable:8191 slab_unreclaimable:5281
[  158.731198]  mapped:355 shmem:152 pagetables:557 bounce:0
[  158.732603] Node 0 DMA free:1056kB min:120kB low:148kB high:180kB active_anon:4316kB inactive_anon:0kB active_file:0kB inactive_file:3284kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:260kB writeback:416kB mapped:8kB shmem:0kB slab_reclaimable:6392kB slab_unreclaimable:392kB kernel_stack:8kB pagetables:40kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  158.734263] lowmem_reserve[]: 0 236 236 236
[  158.734649] Node 0 DMA32 free:1852kB min:1904kB low:2380kB high:2856kB active_anon:24900kB inactive_anon:448kB active_file:1620kB inactive_file:6516kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:532kB writeback:2824kB mapped:1412kB shmem:608kB slab_reclaimable:26372kB slab_unreclaimable:20732kB kernel_stack:1224kB pagetables:2188kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  158.736406] lowmem_reserve[]: 0 0 0 0
[  158.736777] Node 0 DMA: 32*4kB 55*8kB 32*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1080kB
[  158.737720] Node 0 DMA32: 3*4kB 28*8kB 99*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1852kB
[  158.738658] 3061 total pagecache pages
[  158.738860] 0 pages in swap cache
[  158.739046] Swap cache stats: add 0, delete 0, find 0/0
[  158.739301] Free swap  = 0kB
[  158.739476] Total swap = 0kB
[  158.740314] 65520 pages RAM
[  158.740483] 16492 pages reserved
[  158.740667] 5167 pages shared
[  158.740840] 44889 pages non-shared
[  158.741030] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  158.741410] [ 1995]     0  1995     4237      169   1     -17         -1000 udevd
[  158.741785] [ 2082]     0  2082     4264      179   2     -17         -1000 udevd
[  158.742158] [ 2083]     0  2083     4264      169   2     -17         -1000 udevd
[  158.742527] [ 2269]     0  2269    12303      170   1     -17         -1000 sshd
[  158.742894] [ 2343]     1  2343     2162       71   3       0             0 portmap
[  158.743278] [ 2355]     0  2355     3606       87   0       0             0 rpc.statd
[  158.743691] [ 2428]     0  2428     1633       93   1       0             0 syslogd
[  158.744080] [ 2437]     0  2437     1107       99   6       0             0 klogd
[  158.744462] [ 2448]   104  2448     5864      102   4       0             0 dbus-daemon
[  158.744864] [ 2490]   106  2490    11105      317   2       0             0 hald
[  158.745244] [ 2491]     0  2491     5552      101   1       0             0 hald-runner
[  158.745646] [ 2520]     0  2520    19756      246   4       0             0 sshd
[  158.746020] [ 2524]     0  2524     6081       83   5       0             0 hald-addon-inpu
[  158.746428] [ 2541]     0  2541     6083       82   0       0             0 hald-addon-cpuf
[  158.746835] [ 2542]   106  2542     6535      103   0       0             0 hald-addon-acpi
[  158.747244] [ 2551]  1000  2551    19756      322   4       0             0 sshd
[  158.747625] [ 2571]  1000  2571    11804      470   0       0             0 zsh
[  158.747997] [ 2632]     0  2632     1494       66   4       0             0 getty
[  158.748371] [ 2633]     0  2633     1494       67   0       0             0 getty
[  158.748744] [ 2634]     0  2634     1494       67   0       0             0 getty
[  158.749118] [ 2635]     0  2635     1494       67   0       0             0 getty
[  158.749492] [ 2636]     0  2636     1494       66   0       0             0 getty
[  158.750434] [ 2638]     0  2638     1494       66   0       0             0 getty
[  158.750811] [ 2689]     0  2689    13201      134   4       0             0 su
[  158.751175] [ 2692]     0  2692    11425      600   0       0             0 zsh
[  158.751588] [ 2720]     0  2720     3431      142   0       0             0 concurrent-dd.s
[  158.751997] [ 2749]     0  2749     3460      323   5       0             0 dd
[  158.752362] [ 2750]     0  2750     3460      322   1       0             0 dd
[  158.752727] [ 2751]     0  2751     3460      322   4       0             0 dd
[  158.753093] [ 2752]     0  2752     3460      323   3       0             0 dd
[  158.753459] [ 2753]     0  2753     3460      323   7       0             0 dd
[  158.753824] [ 2754]     0  2754     3460      322   3       0             0 dd
[  158.754189] [ 2755]     0  2755     3460      322   5       0             0 dd
[  158.754553] [ 2756]     0  2756     3460      323   0       0             0 dd
[  158.754914] [ 2757]     0  2757     3460      323   0       0             0 dd
[  158.755276] [ 2758]     0  2758     3460      323   3       0             0 dd
[  158.755647] [ 2759]     0  2759     3436      227   0       0             0 plot-written.sh
[  158.756054] [ 2760]     0  2760    11157     1726   2       0             0 python
[  158.756432] [ 2776]     0  2776     2144      140   4       0             0 iostat
[  158.756811] [ 7125]     0  7125      100       30   0       0             0 date
[  158.757184] Out of memory: Kill process 2571 (zsh) score 9 or sacrifice child
[  158.757515] Killed process 2689 (su) total-vm:52804kB, anon-rss:328kB, file-rss:208kB
[  158.862569] zsh invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  158.862991] zsh cpuset=/ mems_allowed=0
[  158.863209] Pid: 2571, comm: zsh Not tainted 2.6.37-rc3 #154
[  158.863540] Call Trace:
[  158.863710]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  158.864006]  [<ffffffff81130593>] dump_header+0x83/0x200
[  158.864282]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  158.864576]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  158.864860]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  158.865139]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  158.865428]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  158.865718]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  158.866037]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  158.866345]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  158.866644]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  158.866972]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  158.867305]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  158.867635]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  158.867903]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  158.868193]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  158.868496]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  158.868777]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  158.869052]  [<ffffffff810bb929>] ? trace_hardirqs_off_caller+0x29/0x150
[  158.869383]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  158.869676]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  158.869969]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  158.870288]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  158.870575]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  158.870842]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  158.871166]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  158.871446] Mem-Info:
[  158.871605] Node 0 DMA per-cpu:
[  158.871836] CPU    0: hi:    0, btch:   1 usd:   0
[  158.872092] CPU    1: hi:    0, btch:   1 usd:   0
[  158.872345] CPU    2: hi:    0, btch:   1 usd:   0
[  158.872598] CPU    3: hi:    0, btch:   1 usd:   0
[  158.872852] CPU    4: hi:    0, btch:   1 usd:   0
[  158.873104] CPU    5: hi:    0, btch:   1 usd:   0
[  158.873358] CPU    6: hi:    0, btch:   1 usd:   0
[  158.873610] CPU    7: hi:    0, btch:   1 usd:   0
[  158.873863] Node 0 DMA32 per-cpu:
[  158.874098] CPU    0: hi:   90, btch:  15 usd:  17
[  158.874352] CPU    1: hi:   90, btch:  15 usd:   1
[  158.874606] CPU    2: hi:   90, btch:  15 usd:   0
[  158.874858] CPU    3: hi:   90, btch:  15 usd:   0
[  158.875110] CPU    4: hi:   90, btch:  15 usd:  69
[  158.875363] CPU    5: hi:   90, btch:  15 usd:   0
[  158.875631] CPU    6: hi:   90, btch:  15 usd:  14
[  158.875885] CPU    7: hi:   90, btch:  15 usd:   0
[  158.876141] active_anon:7254 inactive_anon:95 isolated_anon:0
[  158.876143]  active_file:405 inactive_file:2484 isolated_file:0
[  158.876144]  unevictable:0 dirty:0 writeback:753 unstable:0
[  158.876145]  free:707 slab_reclaimable:8191 slab_unreclaimable:5231
[  158.876146]  mapped:380 shmem:152 pagetables:532 bounce:0
[  158.877578] Node 0 DMA free:1056kB min:120kB low:148kB high:180kB active_anon:4316kB inactive_anon:0kB active_file:0kB inactive_file:2572kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:780kB mapped:8kB shmem:0kB slab_reclaimable:6392kB slab_unreclaimable:464kB kernel_stack:8kB pagetables:40kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:4353 all_unreclaimable? yes
[  158.879330] lowmem_reserve[]: 0 236 236 236
[  158.879758] Node 0 DMA32 free:1788kB min:1904kB low:2380kB high:2856kB active_anon:24700kB inactive_anon:380kB active_file:1620kB inactive_file:7364kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:0kB writeback:1724kB mapped:1512kB shmem:608kB slab_reclaimable:26372kB slab_unreclaimable:20460kB kernel_stack:1224kB pagetables:2088kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:16092 all_unreclaimable? yes
[  158.881595] lowmem_reserve[]: 0 0 0 0
[  158.881987] Node 0 DMA: 43*4kB 90*8kB 11*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1068kB
[  158.882974] Node 0 DMA32: 91*4kB 39*8kB 85*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2068kB
[  158.883989] 2867 total pagecache pages
[  158.884205] 0 pages in swap cache
[  158.884404] Swap cache stats: add 0, delete 0, find 0/0
[  158.884677] Free swap  = 0kB
[  158.884859] Total swap = 0kB
[  158.885766] 65520 pages RAM
[  158.885945] 16492 pages reserved
[  158.886140] 5300 pages shared
[  158.886329] 44770 pages non-shared
[  158.886531] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  158.886928] [ 1995]     0  1995     4237      169   1     -17         -1000 udevd
[  158.887324] [ 2082]     0  2082     4264      179   2     -17         -1000 udevd
[  158.887737] [ 2083]     0  2083     4264      169   2     -17         -1000 udevd
[  158.888132] [ 2269]     0  2269    12303      170   1     -17         -1000 sshd
[  158.888523] [ 2343]     1  2343     2162       89   1       0             0 portmap
[  158.888923] [ 2355]     0  2355     3606       87   0       0             0 rpc.statd
[  158.889332] [ 2428]     0  2428     1633      118   2       0             0 syslogd
[  158.889734] [ 2437]     0  2437     1107       92   1       0             0 klogd
[  158.890131] [ 2448]   104  2448     5864      111   4       0             0 dbus-daemon
[  158.890542] [ 2490]   106  2490    11105      318   2       0             0 hald
[  158.890930] [ 2491]     0  2491     5552      101   1       0             0 hald-runner
[  158.891346] [ 2520]     0  2520    19756      246   4       0             0 sshd
[  158.891746] [ 2524]     0  2524     6081       83   5       0             0 hald-addon-inpu
[  158.892175] [ 2541]     0  2541     6083       82   0       0             0 hald-addon-cpuf
[  158.892600] [ 2542]   106  2542     6535      103   0       0             0 hald-addon-acpi
[  158.893024] [ 2551]  1000  2551    19756      323   4       0             0 sshd
[  158.893415] [ 2571]  1000  2571    11804      495   4       0             0 zsh
[  158.893805] [ 2632]     0  2632     1494       66   4       0             0 getty
[  158.894197] [ 2633]     0  2633     1494       67   0       0             0 getty
[  158.894591] [ 2634]     0  2634     1494       67   0       0             0 getty
[  158.894989] [ 2635]     0  2635     1494       67   0       0             0 getty
[  158.895381] [ 2636]     0  2636     1494       66   0       0             0 getty
[  158.895784] [ 2638]     0  2638     1494       66   0       0             0 getty
[  158.896179] [ 2692]     0  2692    11425      600   0       0             0 zsh
[  158.896568] [ 2720]     0  2720     3431      142   0       0             0 concurrent-dd.s
[  158.896996] [ 2749]     0  2749     3460      323   7       0             0 dd
[  158.897381] [ 2750]     0  2750     3460      322   1       0             0 dd
[  158.897766] [ 2751]     0  2751     3460      322   6       0             0 dd
[  158.898713] [ 2752]     0  2752     3460      323   7       0             0 dd
[  158.899099] [ 2753]     0  2753     3460      323   5       0             0 dd
[  158.899492] [ 2754]     0  2754     3460      322   7       0             0 dd
[  158.899877] [ 2755]     0  2755     3460      322   3       0             0 dd
[  158.900263] [ 2756]     0  2756     3460      323   4       0             0 dd
[  158.900648] [ 2757]     0  2757     3460      323   4       0             0 dd
[  158.901032] [ 2758]     0  2758     3460      323   1       0             0 dd
[  158.901418] [ 2759]     0  2759     3436      227   0       0             0 plot-written.sh
[  158.901840] [ 2760]     0  2760    11157     1726   6       0             0 python
[  158.902239] [ 2776]     0  2776     2144      134   4       0             0 iostat
[  158.902637] [ 7125]     0  7125     3202      138   5       0             0 date
[  158.903026] Out of memory: Kill process 2571 (zsh) score 10 or sacrifice child
[  158.903421] Killed process 2571 (zsh) total-vm:47216kB, anon-rss:1692kB, file-rss:288kB
remote: Counting objects: 272, done.
remote: Compressing objects: 100% (58/58), done.
remote: Total 178 (delta 151), reused 136 (delta 119)
Receiving objects: 100% (178/178), 25.77 KiB, done.
Resolving deltas: 100% (151/151), completed with 65 local objects.
>From git://proxy.jf.intel.com/pub/scm/linux/kernel/git/torvalds/linux-2.6
   771f8bc..cf7d7e5  master     -> origin/master
 * [new tag]         v2.6.37-rc5 -> v2.6.37-rc5
[1]  + 19413 done       git remote update
[  206.063452] date invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  206.063863] date cpuset=/ mems_allowed=0
[  206.064074] Pid: 9396, comm: date Not tainted 2.6.37-rc3 #154
[  206.064352] Call Trace:
[  206.064513]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  206.064798]  [<ffffffff81130593>] dump_header+0x83/0x200
[  206.065063]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  206.065345]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  206.065633]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  206.065908]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  206.066193]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  206.066466]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  206.066768]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  206.067059]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  206.067342]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  206.067652]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  206.067968]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  206.068270]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  206.068523]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  206.068795]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  206.069078]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  206.069391]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  206.069685]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  206.069961]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  206.070262]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  206.070536]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  206.070802]  [<ffffffff810bb929>] ? trace_hardirqs_off_caller+0x29/0x150
[  206.071115]  [<ffffffff810bba5d>] ? trace_hardirqs_off+0xd/0x10
[  206.071399]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  206.071665]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  206.071920]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  206.072227]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  206.072481] Mem-Info:
[  206.072631] Node 0 DMA per-cpu:
[  206.072846] CPU    0: hi:    0, btch:   1 usd:   0
[  206.073090] CPU    1: hi:    0, btch:   1 usd:   0
[  206.073331] CPU    2: hi:    0, btch:   1 usd:   0
[  206.073582] CPU    3: hi:    0, btch:   1 usd:   0
[  206.073825] CPU    4: hi:    0, btch:   1 usd:   0
[  206.074068] CPU    5: hi:    0, btch:   1 usd:   0
[  206.074311] CPU    6: hi:    0, btch:   1 usd:   0
[  206.074553] CPU    7: hi:    0, btch:   1 usd:   0
[  206.074795] Node 0 DMA32 per-cpu:
[  206.075016] CPU    0: hi:   90, btch:  15 usd:   0
[  206.075258] CPU    1: hi:   90, btch:  15 usd:   0
[  206.075502] CPU    2: hi:   90, btch:  15 usd:   0
[  206.075743] CPU    3: hi:   90, btch:  15 usd:   0
[  206.075985] CPU    4: hi:   90, btch:  15 usd:   0
[  206.076228] CPU    5: hi:   90, btch:  15 usd:   0
[  206.076471] CPU    6: hi:   90, btch:  15 usd:   0
[  206.076714] CPU    7: hi:   90, btch:  15 usd:   0
[  206.076957] active_anon:4989 inactive_anon:19 isolated_anon:0
[  206.076958]  active_file:246 inactive_file:1257 isolated_file:0
[  206.076959]  unevictable:0 dirty:0 writeback:0 unstable:0
[  206.076959]  free:725 slab_reclaimable:11315 slab_unreclaimable:5147
[  206.076960]  mapped:198 shmem:75 pagetables:429 bounce:0
[  206.078351] Node 0 DMA free:1088kB min:120kB low:148kB high:180kB active_anon:576kB inactive_anon:0kB active_file:36kB inactive_file:848kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:24kB mapped:0kB shmem:0kB slab_reclaimable:12824kB slab_unreclaimable:352kB kernel_stack:16kB pagetables:12kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1466 all_unreclaimable? yes
[  206.080021] lowmem_reserve[]: 0 236 236 236
[  206.080410] Node 0 DMA32 free:1840kB min:1904kB low:2380kB high:2856kB active_anon:19372kB inactive_anon:28kB active_file:940kB inactive_file:4232kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:0kB writeback:0kB mapped:780kB shmem:300kB slab_reclaimable:32428kB slab_unreclaimable:20268kB kernel_stack:1200kB pagetables:1704kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:9452 all_unreclaimable? yes
[  206.082158] lowmem_reserve[]: 0 0 0 0
[  206.082531] Node 0 DMA: 67*4kB 4*8kB 46*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1036kB
[  206.083464] Node 0 DMA32: 173*4kB 98*8kB 23*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1844kB
[  206.084413] 1660 total pagecache pages
[  206.084617] 0 pages in swap cache
[  206.084805] Swap cache stats: add 0, delete 0, find 0/0
[  206.085063] Free swap  = 0kB
[  206.085234] Total swap = 0kB
[  206.085981] 65520 pages RAM
[  206.086152] 16492 pages reserved
[  206.086337] 1938 pages shared
[  206.086511] 46189 pages non-shared
[  206.086703] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  206.087084] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  206.087459] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  206.087834] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  206.088210] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  206.088581] [ 2343]     1  2343     2162       65   4       0             0 portmap
[  206.088963] [ 2355]     0  2355     3606       43   0       0             0 rpc.statd
[  206.089351] [ 2428]     0  2428     1633       44   0       0             0 syslogd
[  206.089738] [ 2437]     0  2437     1107       25   2       0             0 klogd
[  206.090113] [ 2448]   104  2448     5864       83   0       0             0 dbus-daemon
[  206.090507] [ 2490]   106  2490    11105      276   2       0             0 hald
[  206.090877] [ 2491]     0  2491     5552       63   1       0             0 hald-runner
[  206.091270] [ 2524]     0  2524     6081       49   5       0             0 hald-addon-inpu
[  206.091679] [ 2541]     0  2541     6083       48   0       0             0 hald-addon-cpuf
[  206.092085] [ 2542]   106  2542     6535       60   0       0             0 hald-addon-acpi
[  206.092492] [ 2632]     0  2632     1494       26   4       0             0 getty
[  206.092866] [ 2633]     0  2633     1494       27   0       0             0 getty
[  206.093238] [ 2634]     0  2634     1494       27   0       0             0 getty
[  206.093622] [ 2635]     0  2635     1494       27   0       0             0 getty
[  206.093999] [ 2636]     0  2636     1494       26   0       0             0 getty
[  206.094372] [ 2638]     0  2638     1494       26   0       0             0 getty
[  206.094746] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  206.095115] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  206.095522] [ 2749]     0  2749     3460      290   5       0             0 dd
[  206.095887] [ 2750]     0  2750     3460      289   4       0             0 dd
[  206.096252] [ 2751]     0  2751     3460      289   6       0             0 dd
[  206.096618] [ 2752]     0  2752     3460      290   4       0             0 dd
[  206.096982] [ 2753]     0  2753     3460      290   6       0             0 dd
[  206.097347] [ 2754]     0  2754     3460      289   1       0             0 dd
[  206.097720] [ 2755]     0  2755     3460      289   3       0             0 dd
[  206.098086] [ 2756]     0  2756     3460      290   6       0             0 dd
[  206.098452] [ 2757]     0  2757     3460      290   0       0             0 dd
[  206.098817] [ 2758]     0  2758     3460      290   0       0             0 dd
[  206.099182] [ 2759]     0  2759     3437      185   1       0             0 plot-written.sh
[  206.099589] [ 2776]     0  2776     2145       71   3       0             0 iostat
[  206.100540] [ 9396]     0  9396     3202      134   6       0             0 date
[  206.100910] Out of memory: Kill process 2490 (hald) score 5 or sacrifice child
[  206.101276] Killed process 2491 (hald-runner) total-vm:22208kB, anon-rss:248kB, file-rss:4kB
[  206.494475] date invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  206.494895] date cpuset=/ mems_allowed=0
[  206.495112] Pid: 9396, comm: date Not tainted 2.6.37-rc3 #154
[  206.495396] Call Trace:
[  206.495558]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  206.495845]  [<ffffffff81130593>] dump_header+0x83/0x200
[  206.496112]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  206.496400]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  206.496675]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  206.496951]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  206.497234]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  206.497514]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  206.497834]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  206.498131]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  206.498421]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  206.498740]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  206.499062]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  206.499373]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  206.499632]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  206.499911]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  206.500207]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  206.500475]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  206.500762]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  206.501045]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  206.501355]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  206.501635]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  206.501923]  [<ffffffff810bb929>] ? trace_hardirqs_off_caller+0x29/0x150
[  206.502244]  [<ffffffff810bba5d>] ? trace_hardirqs_off+0xd/0x10
[  206.502535]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  206.502809]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  206.503068]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  206.503384]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  206.503645] Mem-Info:
[  206.503798] Node 0 DMA per-cpu:
[  206.504019] CPU    0: hi:    0, btch:   1 usd:   0
[  206.504269] CPU    1: hi:    0, btch:   1 usd:   0
[  206.504518] CPU    2: hi:    0, btch:   1 usd:   0
[  206.504767] CPU    3: hi:    0, btch:   1 usd:   0
[  206.505069] CPU    4: hi:    0, btch:   1 usd:   0
[  206.505317] CPU    5: hi:    0, btch:   1 usd:   0
[  206.505566] CPU    6: hi:    0, btch:   1 usd:   0
[  206.505825] CPU    7: hi:    0, btch:   1 usd:   0
[  206.506074] Node 0 DMA32 per-cpu:
[  206.506302] CPU    0: hi:   90, btch:  15 usd:  14
[  206.506550] CPU    1: hi:   90, btch:  15 usd:   0
[  206.506798] CPU    2: hi:   90, btch:  15 usd:   0
[  206.507048] CPU    3: hi:   90, btch:  15 usd:   0
[  206.507297] CPU    4: hi:   90, btch:  15 usd:   0
[  206.507545] CPU    5: hi:   90, btch:  15 usd:   0
[  206.507795] CPU    6: hi:   90, btch:  15 usd:  14
[  206.508045] CPU    7: hi:   90, btch:  15 usd:   0
[  206.508296] active_anon:4928 inactive_anon:7 isolated_anon:0
[  206.508297]  active_file:142 inactive_file:571 isolated_file:0
[  206.508298]  unevictable:0 dirty:0 writeback:0 unstable:0
[  206.508299]  free:688 slab_reclaimable:11310 slab_unreclaimable:5150
[  206.508301]  mapped:121 shmem:75 pagetables:436 bounce:0
[  206.509719] Node 0 DMA free:1044kB min:120kB low:148kB high:180kB active_anon:552kB inactive_anon:0kB active_file:32kB inactive_file:388kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:44kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:12836kB slab_unreclaimable:352kB kernel_stack:8kB pagetables:20kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:802 all_unreclaimable? yes
[  206.511425] lowmem_reserve[]: 0 236 236 236
[  206.511830] Node 0 DMA32 free:1708kB min:1904kB low:2380kB high:2856kB active_anon:19160kB inactive_anon:28kB active_file:536kB inactive_file:1896kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:0kB writeback:0kB mapped:500kB shmem:300kB slab_reclaimable:32404kB slab_unreclaimable:20248kB kernel_stack:1176kB pagetables:1724kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:3774 all_unreclaimable? yes
[  206.513597] lowmem_reserve[]: 0 0 0 0
[  206.513990] Node 0 DMA: 66*4kB 2*8kB 49*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1064kB
[  206.514957] Node 0 DMA32: 146*4kB 77*8kB 29*16kB 3*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1760kB
[  206.515940] 906 total pagecache pages
[  206.516146] 0 pages in swap cache
[  206.516339] Swap cache stats: add 0, delete 0, find 0/0
[  206.516604] Free swap  = 0kB
[  206.516781] Total swap = 0kB
[  206.517638] 65520 pages RAM
[  206.517821] 16492 pages reserved
[  206.518011] 778 pages shared
[  206.518186] 47393 pages non-shared
[  206.518383] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  206.518772] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  206.519158] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  206.519542] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  206.519927] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  206.520309] [ 2343]     1  2343     2162       62   4       0             0 portmap
[  206.520702] [ 2355]     0  2355     3606       43   0       0             0 rpc.statd
[  206.521098] [ 2428]     0  2428     1633       90   0       0             0 syslogd
[  206.521488] [ 2437]     0  2437     1107       67   0       0             0 klogd
[  206.521879] [ 2448]   104  2448     5864       83   0       0             0 dbus-daemon
[  206.522283] [ 2490]   106  2490    11105      294   1       0             0 hald
[  206.522664] [ 2524]     0  2524     6081       49   5       0             0 hald-addon-inpu
[  206.523082] [ 2541]     0  2541     6083       48   0       0             0 hald-addon-cpuf
[  206.523499] [ 2542]   106  2542     6535       59   0       0             0 hald-addon-acpi
[  206.523916] [ 2632]     0  2632     1494       26   4       0             0 getty
[  206.524300] [ 2633]     0  2633     1494       27   0       0             0 getty
[  206.524684] [ 2634]     0  2634     1494       27   0       0             0 getty
[  206.525069] [ 2635]     0  2635     1494       27   0       0             0 getty
[  206.525453] [ 2636]     0  2636     1494       26   0       0             0 getty
[  206.525845] [ 2638]     0  2638     1494       26   0       0             0 getty
[  206.526231] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  206.526609] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  206.527027] [ 2749]     0  2749     3460      290   1       0             0 dd
[  206.527401] [ 2750]     0  2750     3460      289   0       0             0 dd
[  206.527777] [ 2751]     0  2751     3460      289   4       0             0 dd
[  206.528152] [ 2752]     0  2752     3460      290   2       0             0 dd
[  206.528527] [ 2753]     0  2753     3460      290   7       0             0 dd
[  206.528902] [ 2754]     0  2754     3460      289   3       0             0 dd
[  206.529275] [ 2755]     0  2755     3460      289   4       0             0 dd
[  206.529650] [ 2756]     0  2756     3460      290   6       0             0 dd
[  206.530032] [ 2757]     0  2757     3460      290   3       0             0 dd
[  206.530409] [ 2758]     0  2758     3460      290   5       0             0 dd
[  206.530785] [ 2759]     0  2759     3437      102   1       0             0 plot-written.sh
[  206.531203] [ 2776]     0  2776     2145       68   3       0             0 iostat
[  206.531591] [ 9396]     0  9396     3202      117   2       0             0 date
[  206.531972] Out of memory: Kill process 2490 (hald) score 5 or sacrifice child
[  206.532346] Killed process 2490 (hald) total-vm:44420kB, anon-rss:1096kB, file-rss:80kB
[  224.490577] plot-written.sh invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0, oom_score_adj=0
[  224.491034] plot-written.sh cpuset=/ mems_allowed=0
[  224.491283] Pid: 9920, comm: plot-written.sh Not tainted 2.6.37-rc3 #154
[  224.491597] Call Trace:
[  224.491758]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  224.492043]  [<ffffffff81130593>] dump_header+0x83/0x200
[  224.492311]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  224.492597]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  224.492870]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  224.493137]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  224.493411]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  224.493679]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  224.493975]  [<ffffffff8116cb48>] alloc_page_vma+0x88/0x160
[  224.494258]  [<ffffffff8114e221>] do_wp_page+0xf1/0x880
[  224.494517]  [<ffffffff81150324>] handle_mm_fault+0x3e4/0xc20
[  224.495345]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  224.495614]  [<ffffffff8114ce2c>] ? might_fault+0x5c/0xb0
[  224.495876]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  224.496125]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  224.496425]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  224.496676] Mem-Info:
[  224.496821] Node 0 DMA per-cpu:
[  224.497031] CPU    0: hi:    0, btch:   1 usd:   0
[  224.497268] CPU    1: hi:    0, btch:   1 usd:   0
[  224.497504] CPU    2: hi:    0, btch:   1 usd:   0
[  224.497740] CPU    3: hi:    0, btch:   1 usd:   0
[  224.497977] CPU    4: hi:    0, btch:   1 usd:   0
[  224.498235] CPU    5: hi:    0, btch:   1 usd:   0
[  224.498476] CPU    6: hi:    0, btch:   1 usd:   0
[  224.498719] CPU    7: hi:    0, btch:   1 usd:   0
[  224.498963] Node 0 DMA32 per-cpu:
[  224.499181] CPU    0: hi:   90, btch:  15 usd:  86
[  224.499422] CPU    1: hi:   90, btch:  15 usd:   0
[  224.499658] CPU    2: hi:   90, btch:  15 usd:   0
[  224.499895] CPU    3: hi:   90, btch:  15 usd:   0
[  224.500133] CPU    4: hi:   90, btch:  15 usd:  26
[  224.500369] CPU    5: hi:   90, btch:  15 usd:   0
[  224.500606] CPU    6: hi:   90, btch:  15 usd:   0
[  224.500842] CPU    7: hi:   90, btch:  15 usd:   0
[  224.501080] active_anon:4612 inactive_anon:31 isolated_anon:0
[  224.501081]  active_file:317 inactive_file:984 isolated_file:0
[  224.501081]  unevictable:0 dirty:0 writeback:699 unstable:0
[  224.501082]  free:1515 slab_reclaimable:12137 slab_unreclaimable:5131
[  224.501082]  mapped:201 shmem:75 pagetables:382 bounce:0
[  224.502468] Node 0 DMA free:1124kB min:120kB low:148kB high:180kB active_anon:572kB inactive_anon:0kB active_file:16kB inactive_file:672kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:104kB writeback:572kB mapped:0kB shmem:0kB slab_reclaimable:12952kB slab_unreclaimable:292kB kernel_stack:8kB pagetables:20kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  224.504105] lowmem_reserve[]: 0 236 236 236
[  224.504494] Node 0 DMA32 free:5600kB min:1904kB low:2380kB high:2856kB active_anon:17976kB inactive_anon:124kB active_file:1252kB inactive_file:2744kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:0kB writeback:2072kB mapped:804kB shmem:300kB slab_reclaimable:35596kB slab_unreclaimable:20232kB kernel_stack:1160kB pagetables:1508kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:14 all_unreclaimable? no
[  224.506241] lowmem_reserve[]: 0 0 0 0
[  224.506608] Node 0 DMA: 22*4kB 53*8kB 42*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1184kB
[  224.507546] Node 0 DMA32: 1016*4kB 165*8kB 6*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5480kB
[  224.508496] 1394 total pagecache pages
[  224.508700] 0 pages in swap cache
[  224.508888] Swap cache stats: add 0, delete 0, find 0/0
[  224.509146] Free swap  = 0kB
[  224.509318] Total swap = 0kB
[  224.510110] 65520 pages RAM
[  224.510282] 16492 pages reserved
[  224.510468] 2424 pages shared
[  224.510642] 45531 pages non-shared
[  224.510834] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  224.511216] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  224.511592] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  224.511967] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  224.512343] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  224.512716] [ 2343]     1  2343     2162       61   4       0             0 portmap
[  224.513098] [ 2355]     0  2355     3606       43   0       0             0 rpc.statd
[  224.513486] [ 2428]     0  2428     1633      102   2       0             0 syslogd
[  224.513867] [ 2437]     0  2437     1107       79   6       0             0 klogd
[  224.514253] [ 2448]   104  2448     5864       95   4       0             0 dbus-daemon
[  224.514648] [ 2524]     0  2524     6081       79   5       0             0 hald-addon-inpu
[  224.515054] [ 2541]     0  2541     6083       69   1       0             0 hald-addon-cpuf
[  224.515462] [ 2542]   106  2542     6535       68   4       0             0 hald-addon-acpi
[  224.515869] [ 2632]     0  2632     1494       26   4       0             0 getty
[  224.516243] [ 2633]     0  2633     1494       27   0       0             0 getty
[  224.516614] [ 2634]     0  2634     1494       27   0       0             0 getty
[  224.516985] [ 2635]     0  2635     1494       27   0       0             0 getty
[  224.517357] [ 2636]     0  2636     1494       26   0       0             0 getty
[  224.517729] [ 2638]     0  2638     1494       26   0       0             0 getty
[  224.518112] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  224.518477] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  224.518880] [ 2749]     0  2749     3460      290   0       0             0 dd
[  224.519241] [ 2750]     0  2750     3460      289   6       0             0 dd
[  224.519608] [ 2751]     0  2751     3460      289   3       0             0 dd
[  224.519969] [ 2752]     0  2752     3460      290   3       0             0 dd
[  224.520337] [ 2753]     0  2753     3460      290   2       0             0 dd
[  224.520702] [ 2754]     0  2754     3460      289   4       0             0 dd
[  224.521065] [ 2755]     0  2755     3460      289   7       0             0 dd
[  224.521428] [ 2756]     0  2756     3460      290   2       0             0 dd
[  224.521790] [ 2757]     0  2757     3460      290   2       0             0 dd
[  224.522165] [ 2758]     0  2758     3460      290   6       0             0 dd
[  224.522529] [ 2759]     0  2759     3437      197   4       0             0 plot-written.sh
[  224.522936] [ 2776]     0  2776     2144       94   2       0             0 iostat
[  224.523310] [ 9920]     0  9920     3437      130   5       0             0 plot-written.sh
[  224.523713] Out of memory: Kill process 2343 (portmap) score 1 or sacrifice child
[  224.524084] Killed process 2343 (portmap) total-vm:8648kB, anon-rss:132kB, file-rss:112kB
[  225.411466] iostat invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  225.411906] iostat cpuset=/ mems_allowed=0
[  225.412137] Pid: 2776, comm: iostat Not tainted 2.6.37-rc3 #154
[  225.412437] Call Trace:
[  225.412607]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  225.412907]  [<ffffffff81130593>] dump_header+0x83/0x200
[  225.413183]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  225.413482]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  225.413768]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  225.414052]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  225.414346]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  225.414650]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  225.414970]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  225.415272]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  225.415565]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  225.415884]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  225.416206]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  225.416518]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  225.416779]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  225.417059]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  225.417353]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  225.417620]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  225.417907]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  225.418190]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  225.418509]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  225.418792]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  225.419081]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  225.419342]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  225.419657]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  225.419919] Mem-Info:
[  225.420073] Node 0 DMA per-cpu:
[  225.420296] CPU    0: hi:    0, btch:   1 usd:   0
[  225.420545] CPU    1: hi:    0, btch:   1 usd:   0
[  225.420793] CPU    2: hi:    0, btch:   1 usd:   0
[  225.421041] CPU    3: hi:    0, btch:   1 usd:   0
[  225.421291] CPU    4: hi:    0, btch:   1 usd:   0
[  225.421541] CPU    5: hi:    0, btch:   1 usd:   0
[  225.421789] CPU    6: hi:    0, btch:   1 usd:   0
[  225.422038] CPU    7: hi:    0, btch:   1 usd:   0
[  225.422286] Node 0 DMA32 per-cpu:
[  225.422528] CPU    0: hi:   90, btch:  15 usd:  30
[  225.422779] CPU    1: hi:   90, btch:  15 usd:  12
[  225.423028] CPU    2: hi:   90, btch:  15 usd:   0
[  225.423276] CPU    3: hi:   90, btch:  15 usd:   0
[  225.423527] CPU    4: hi:   90, btch:  15 usd:  22
[  225.423776] CPU    5: hi:   90, btch:  15 usd:   0
[  225.424026] CPU    6: hi:   90, btch:  15 usd:  88
[  225.424276] CPU    7: hi:   90, btch:  15 usd:   0
[  225.424528] active_anon:4608 inactive_anon:48 isolated_anon:0
[  225.424530]  active_file:301 inactive_file:1753 isolated_file:0
[  225.424531]  unevictable:0 dirty:55 writeback:10 unstable:0
[  225.424532]  free:719 slab_reclaimable:12182 slab_unreclaimable:5137
[  225.424533]  mapped:226 shmem:75 pagetables:374 bounce:0
[  225.426537] Node 0 DMA free:1036kB min:120kB low:148kB high:180kB active_anon:656kB inactive_anon:0kB active_file:16kB inactive_file:736kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:32kB mapped:0kB shmem:0kB slab_reclaimable:12968kB slab_unreclaimable:300kB kernel_stack:16kB pagetables:52kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1138 all_unreclaimable? yes
[  225.428244] lowmem_reserve[]: 0 236 236 236
[  225.428650] Node 0 DMA32 free:1868kB min:1904kB low:2380kB high:2856kB active_anon:17776kB inactive_anon:192kB active_file:1188kB inactive_file:6276kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:252kB writeback:8kB mapped:904kB shmem:300kB slab_reclaimable:35760kB slab_unreclaimable:20248kB kernel_stack:1152kB pagetables:1444kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:18485 all_unreclaimable? yes
[  225.430439] lowmem_reserve[]: 0 0 0 0
[  225.430833] Node 0 DMA: 8*4kB 56*8kB 36*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1056kB
[  225.431806] Node 0 DMA32: 109*4kB 171*8kB 4*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1868kB
[  225.432790] 2123 total pagecache pages
[  225.432999] 0 pages in swap cache
[  225.433191] Swap cache stats: add 0, delete 0, find 0/0
[  225.433456] Free swap  = 0kB
[  225.433632] Total swap = 0kB
[  225.434528] 65520 pages RAM
[  225.434703] 16492 pages reserved
[  225.434893] 1459 pages shared
[  225.435072] 46692 pages non-shared
[  225.435269] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  225.435657] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  225.436042] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  225.436428] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  225.436814] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  225.437195] [ 2355]     0  2355     3606       43   0       0             0 rpc.statd
[  225.437593] [ 2428]     0  2428     1633       96   4       0             0 syslogd
[  225.437985] [ 2437]     0  2437     1107       73   7       0             0 klogd
[  225.438371] [ 2448]   104  2448     5864       95   4       0             0 dbus-daemon
[  225.438782] [ 2524]     0  2524     6081       79   5       0             0 hald-addon-inpu
[  225.439201] [ 2541]     0  2541     6083       69   1       0             0 hald-addon-cpuf
[  225.439617] [ 2542]   106  2542     6535       68   4       0             0 hald-addon-acpi
[  225.440037] [ 2632]     0  2632     1494       26   4       0             0 getty
[  225.440424] [ 2633]     0  2633     1494       27   0       0             0 getty
[  225.440809] [ 2634]     0  2634     1494       27   0       0             0 getty
[  225.441195] [ 2635]     0  2635     1494       27   0       0             0 getty
[  225.441579] [ 2636]     0  2636     1494       26   0       0             0 getty
[  225.441964] [ 2638]     0  2638     1494       26   0       0             0 getty
[  225.442349] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  225.442735] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  225.443154] [ 2749]     0  2749     3460      290   1       0             0 dd
[  225.443531] [ 2750]     0  2750     3460      289   6       0             0 dd
[  225.443906] [ 2751]     0  2751     3460      289   6       0             0 dd
[  225.444279] [ 2752]     0  2752     3460      290   7       0             0 dd
[  225.444655] [ 2753]     0  2753     3460      290   7       0             0 dd
[  225.445032] [ 2754]     0  2754     3460      289   3       0             0 dd
[  225.445407] [ 2755]     0  2755     3460      289   5       0             0 dd
[  225.445782] [ 2756]     0  2756     3460      290   0       0             0 dd
[  225.446158] [ 2757]     0  2757     3460      290   5       0             0 dd
[  225.446539] [ 2758]     0  2758     3460      290   6       0             0 dd
[  225.446916] [ 2759]     0  2759     3437      197   6       0             0 plot-written.sh
[  225.447334] [ 2776]     0  2776     2145       95   4       0             0 iostat
[  225.447722] [ 9922]     0  9922     3437      161   4       0             0 plot-written.sh
[  225.448141] [ 9923]     0  9923     1501       45   0       0             0 grep
[  225.448521] Out of memory: Kill process 2355 (rpc.statd) score 1 or sacrifice child
[  225.448913] Killed process 2355 (rpc.statd) total-vm:14424kB, anon-rss:168kB, file-rss:4kB
[  225.924637] iostat invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0, oom_score_adj=0
[  225.925045] iostat cpuset=/ mems_allowed=0
[  225.925266] Pid: 2776, comm: iostat Not tainted 2.6.37-rc3 #154
[  225.925551] Call Trace:
[  225.925710]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  225.925996]  [<ffffffff81130593>] dump_header+0x83/0x200
[  225.926260]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  225.926541]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  225.926833]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  225.927106]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  225.927390]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  225.927673]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  225.927984]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  225.928280]  [<ffffffff81174c44>] new_slab+0x294/0x2a0
[  225.928544]  [<ffffffff81174e82>] ? __slab_alloc+0x232/0x450
[  225.928827]  [<ffffffff81174e97>] __slab_alloc+0x247/0x450
[  225.929104]  [<ffffffff81281951>] ? nfs_create_request+0x41/0x160
[  225.929403]  [<ffffffff81281951>] ? nfs_create_request+0x41/0x160
[  225.929704]  [<ffffffff81175d4c>] kmem_cache_alloc+0x17c/0x190
[  225.929993]  [<ffffffff81a33330>] ? _raw_spin_unlock_irq+0x30/0x40
[  225.930296]  [<ffffffff81a33330>] ? _raw_spin_unlock_irq+0x30/0x40
[  225.930598]  [<ffffffff81281951>] nfs_create_request+0x41/0x160
[  225.930902]  [<ffffffff81a33330>] ? _raw_spin_unlock_irq+0x30/0x40
[  225.931206]  [<ffffffff81283c30>] ? readpage_async_filler+0x0/0x150
[  225.931511]  [<ffffffff81283c95>] readpage_async_filler+0x65/0x150
[  225.931815]  [<ffffffff81283c30>] ? readpage_async_filler+0x0/0x150
[  225.932122]  [<ffffffff811388c2>] read_cache_pages+0xa2/0xf0
[  225.932404]  [<ffffffff81284ba2>] nfs_readpages+0xe2/0x1b0
[  225.932678]  [<ffffffff812840c0>] ? nfs_pagein_one+0x0/0x100
[  225.932963]  [<ffffffff8113869c>] __do_page_cache_readahead+0x18c/0x260
[  225.933284]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  225.933605]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  225.933915]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  225.934175]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  225.934455]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  225.934758]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  225.935023]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  225.935311]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  225.935595]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  225.935957]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  225.936237]  [<ffffffff811bda2c>] ? fsnotify+0x7c/0x2d0
[  225.936505]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  225.936767]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  225.937082]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  225.937344] Mem-Info:
[  225.937498] Node 0 DMA per-cpu:
[  225.937721] CPU    0: hi:    0, btch:   1 usd:   0
[  225.937971] CPU    1: hi:    0, btch:   1 usd:   0
[  225.938218] CPU    2: hi:    0, btch:   1 usd:   0
[  225.938465] CPU    3: hi:    0, btch:   1 usd:   0
[  225.938715] CPU    4: hi:    0, btch:   1 usd:   0
[  225.938972] CPU    5: hi:    0, btch:   1 usd:   0
[  225.939222] CPU    6: hi:    0, btch:   1 usd:   0
[  225.939470] CPU    7: hi:    0, btch:   1 usd:   0
[  225.939718] Node 0 DMA32 per-cpu:
[  225.939947] CPU    0: hi:   90, btch:  15 usd:  15
[  225.940196] CPU    1: hi:   90, btch:  15 usd:  15
[  225.940496] CPU    2: hi:   90, btch:  15 usd:  14
[  225.940744] CPU    3: hi:   90, btch:  15 usd:   6
[  225.940992] CPU    4: hi:   90, btch:  15 usd:  13
[  225.941240] CPU    5: hi:   90, btch:  15 usd:  14
[  225.941488] CPU    6: hi:   90, btch:  15 usd:   6
[  225.941737] CPU    7: hi:   90, btch:  15 usd:  10
[  225.941987] active_anon:4614 inactive_anon:4 isolated_anon:0
[  225.941988]  active_file:260 inactive_file:926 isolated_file:0
[  225.941989]  unevictable:0 dirty:43 writeback:0 unstable:0
[  225.941990]  free:755 slab_reclaimable:12199 slab_unreclaimable:5122
[  225.941991]  mapped:251 shmem:75 pagetables:374 bounce:0
[  225.943408] Node 0 DMA free:1056kB min:120kB low:148kB high:180kB active_anon:656kB inactive_anon:0kB active_file:16kB inactive_file:164kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:20kB writeback:32kB mapped:0kB shmem:0kB slab_reclaimable:12968kB slab_unreclaimable:240kB kernel_stack:16kB pagetables:52kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:351 all_unreclaimable? yes
[  225.945113] lowmem_reserve[]: 0 236 236 236
[  225.945566] Node 0 DMA32 free:1868kB min:1904kB low:2380kB high:2856kB active_anon:17800kB inactive_anon:16kB active_file:1024kB inactive_file:3540kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:152kB writeback:0kB mapped:1004kB shmem:300kB slab_reclaimable:35828kB slab_unreclaimable:20248kB kernel_stack:1152kB pagetables:1444kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:8696 all_unreclaimable? yes
[  225.947950] lowmem_reserve[]: 0 0 0 0
[  225.948347] Node 0 DMA: 10*4kB 98*8kB 19*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1128kB
[  225.949349] Node 0 DMA32: 199*4kB 156*8kB 4*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2108kB
[  225.950362] 1343 total pagecache pages
[  225.950575] 0 pages in swap cache
[  225.950782] Swap cache stats: add 0, delete 0, find 0/0
[  225.951053] Free swap  = 0kB
[  225.951228] Total swap = 0kB
[  225.952026] 65520 pages RAM
[  225.952193] 16492 pages reserved
[  225.952375] 2225 pages shared
[  225.952548] 46398 pages non-shared
[  225.952739] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  225.953115] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  225.953488] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  225.953858] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  225.954230] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  225.954598] [ 2428]     0  2428     1633       96   4       0             0 syslogd
[  225.954982] [ 2437]     0  2437     1107       74   2       0             0 klogd
[  225.955355] [ 2448]   104  2448     5864       94   4       0             0 dbus-daemon
[  225.955750] [ 2524]     0  2524     6081       73   5       0             0 hald-addon-inpu
[  225.956153] [ 2541]     0  2541     6083       63   1       0             0 hald-addon-cpuf
[  225.956556] [ 2542]   106  2542     6535       65   4       0             0 hald-addon-acpi
[  225.956959] [ 2632]     0  2632     1494       26   4       0             0 getty
[  225.957377] [ 2633]     0  2633     1494       27   0       0             0 getty
[  225.957746] [ 2634]     0  2634     1494       27   0       0             0 getty
[  225.958120] [ 2635]     0  2635     1494       27   0       0             0 getty
[  225.958494] [ 2636]     0  2636     1494       26   0       0             0 getty
[  225.958877] [ 2638]     0  2638     1494       26   0       0             0 getty
[  225.959244] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  225.959603] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  225.960003] [ 2749]     0  2749     3460      290   7       0             0 dd
[  225.960361] [ 2750]     0  2750     3460      289   3       0             0 dd
[  225.960718] [ 2751]     0  2751     3460      289   6       0             0 dd
[  225.961078] [ 2752]     0  2752     3460      290   7       0             0 dd
[  225.961437] [ 2753]     0  2753     3460      290   6       0             0 dd
[  225.961805] [ 2754]     0  2754     3460      289   6       0             0 dd
[  225.962186] [ 2755]     0  2755     3460      289   5       0             0 dd
[  225.962570] [ 2756]     0  2756     3460      290   3       0             0 dd
[  225.962963] [ 2757]     0  2757     3460      290   7       0             0 dd
[  225.963346] [ 2758]     0  2758     3460      290   2       0             0 dd
[  225.963781] [ 2759]     0  2759     3437      196   6       0             0 plot-written.sh
[  225.964201] [ 2776]     0  2776     2144       98   1       0             0 iostat
[  225.964577] [ 9922]     0  9922     3437      161   4       0             0 plot-written.sh
[  225.964981] [ 9923]     0  9923     2675      128   2       0             0 grep
[  225.965347] Out of memory: Kill process 2428 (syslogd) score 1 or sacrifice child
[  225.965721] Killed process 2428 (syslogd) total-vm:6532kB, anon-rss:164kB, file-rss:220kB
[  226.294192] wc invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  226.294607] wc cpuset=/ mems_allowed=0
[  226.294815] Pid: 9926, comm: wc Not tainted 2.6.37-rc3 #154
[  226.295395] Call Trace:
[  226.295968]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  226.296265]  [<ffffffff81130593>] dump_header+0x83/0x200
[  226.296523]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  226.296805]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  226.297109]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  226.297381]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  226.297839]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  226.298114]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  226.298415]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  226.298702]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  226.299037]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  226.299344]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  226.299663]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  226.299970]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  226.300228]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  226.300649]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  226.300936]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  226.301208]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  226.301485]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  226.301761]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  226.302067]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  226.302346]  [<ffffffff81177445>] ? kmem_cache_free+0x105/0x180
[  226.302637]  [<ffffffff81177445>] ? kmem_cache_free+0x105/0x180
[  226.302990]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  226.303248]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  226.303561]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  226.303821] Mem-Info:
[  226.303977] Node 0 DMA per-cpu:
[  226.304203] CPU    0: hi:    0, btch:   1 usd:   0
[  226.304451] CPU    1: hi:    0, btch:   1 usd:   0
[  226.304699] CPU    2: hi:    0, btch:   1 usd:   0
[  226.304947] CPU    3: hi:    0, btch:   1 usd:   0
[  226.305194] CPU    4: hi:    0, btch:   1 usd:   0
[  226.305441] CPU    5: hi:    0, btch:   1 usd:   0
[  226.305690] CPU    6: hi:    0, btch:   1 usd:   0
[  226.305938] CPU    7: hi:    0, btch:   1 usd:   0
[  226.306186] Node 0 DMA32 per-cpu:
[  226.306418] CPU    0: hi:   90, btch:  15 usd:   0
[  226.306666] CPU    1: hi:   90, btch:  15 usd:   0
[  226.306924] CPU    2: hi:   90, btch:  15 usd:   0
[  226.307175] CPU    3: hi:   90, btch:  15 usd:   0
[  226.307423] CPU    4: hi:   90, btch:  15 usd:   0
[  226.307671] CPU    5: hi:   90, btch:  15 usd:  13
[  226.307916] CPU    6: hi:   90, btch:  15 usd:   0
[  226.308162] CPU    7: hi:   90, btch:  15 usd:   0
[  226.308409] active_anon:4552 inactive_anon:24 isolated_anon:0
[  226.308410]  active_file:287 inactive_file:1656 isolated_file:0
[  226.308410]  unevictable:0 dirty:1 writeback:1203 unstable:0
[  226.308411]  free:954 slab_reclaimable:12273 slab_unreclaimable:5181
[  226.308411]  mapped:252 shmem:75 pagetables:360 bounce:0
[  226.309798] Node 0 DMA free:1168kB min:120kB low:148kB high:180kB active_anon:616kB inactive_anon:0kB active_file:12kB inactive_file:612kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:12kB writeback:520kB mapped:4kB shmem:0kB slab_reclaimable:12972kB slab_unreclaimable:288kB kernel_stack:8kB pagetables:40kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  226.311750] lowmem_reserve[]: 0 236 236 236
[  226.312156] Node 0 DMA32 free:2748kB min:1904kB low:2380kB high:2856kB active_anon:17592kB inactive_anon:96kB active_file:1136kB inactive_file:6012kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:0kB writeback:3792kB mapped:1004kB shmem:300kB slab_reclaimable:36120kB slab_unreclaimable:20436kB kernel_stack:1144kB pagetables:1400kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  226.313900] lowmem_reserve[]: 0 0 0 0
[  226.314289] Node 0 DMA: 33*4kB 54*8kB 38*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1172kB
[  226.315300] Node 0 DMA32: 275*4kB 194*8kB 6*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2748kB
[  226.316294] 2103 total pagecache pages
[  226.316505] 0 pages in swap cache
[  226.316697] Swap cache stats: add 0, delete 0, find 0/0
[  226.316960] Free swap  = 0kB
[  226.317136] Total swap = 0kB
[  226.317871] 65520 pages RAM
[  226.318049] 16492 pages reserved
[  226.318239] 3641 pages shared
[  226.318419] 45492 pages non-shared
[  226.318615] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  226.319059] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  226.319440] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  226.319818] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  226.320195] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  226.320569] [ 2437]     0  2437     1107       76   6       0             0 klogd
[  226.321511] [ 2448]   104  2448     5864       94   4       0             0 dbus-daemon
[  226.321906] [ 2524]     0  2524     6081       73   5       0             0 hald-addon-inpu
[  226.322313] [ 2541]     0  2541     6083       63   1       0             0 hald-addon-cpuf
[  226.322724] [ 2542]   106  2542     6535       65   4       0             0 hald-addon-acpi
[  226.323244] [ 2632]     0  2632     1494       26   4       0             0 getty
[  226.323628] [ 2633]     0  2633     1494       27   0       0             0 getty
[  226.324004] [ 2634]     0  2634     1494       27   0       0             0 getty
[  226.324380] [ 2635]     0  2635     1494       27   0       0             0 getty
[  226.324945] [ 2636]     0  2636     1494       26   0       0             0 getty
[  226.325325] [ 2638]     0  2638     1494       26   0       0             0 getty
[  226.325701] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  226.326071] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  226.326479] [ 2749]     0  2749     3460      290   1       0             0 dd
[  226.326844] [ 2750]     0  2750     3460      289   3       0             0 dd
[  226.327322] [ 2751]     0  2751     3460      289   1       0             0 dd
[  226.327688] [ 2752]     0  2752     3460      290   3       0             0 dd
[  226.328054] [ 2753]     0  2753     3460      290   2       0             0 dd
[  226.328421] [ 2754]     0  2754     3460      289   2       0             0 dd
[  226.328786] [ 2755]     0  2755     3460      289   1       0             0 dd
[  226.329153] [ 2756]     0  2756     3460      290   3       0             0 dd
[  226.329518] [ 2757]     0  2757     3460      290   3       0             0 dd
[  226.329884] [ 2758]     0  2758     3460      290   6       0             0 dd
[  226.330250] [ 2759]     0  2759     3437      197   0       0             0 plot-written.sh
[  226.330659] [ 2776]     0  2776     2144       95   7       0             0 iostat
[  226.331239] [ 9924]     0  9924     3437      150   1       0             0 plot-written.sh
[  226.331651] [ 9926]     0  9926     2137      127   0       0             0 wc
[  226.332019] Out of memory: Kill process 2437 (klogd) score 1 or sacrifice child
[  226.332392] Killed process 2437 (klogd) total-vm:4428kB, anon-rss:96kB, file-rss:208kB
[  227.419481] dd invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  227.419889] dd cpuset=/ mems_allowed=0
[  227.420101] Pid: 2749, comm: dd Not tainted 2.6.37-rc3 #154
[  227.420380] Call Trace:
[  227.420546]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  227.420836]  [<ffffffff81130593>] dump_header+0x83/0x200
[  227.421107]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  227.421399]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  227.421679]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  227.421955]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  227.422242]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  227.422524]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  227.422833]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  227.423129]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  227.423420]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  227.423750]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  227.424070]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  227.424379]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  227.424639]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  227.424916]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  227.425209]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  227.425475]  [<ffffffff81a311d5>] ? __mutex_unlock_slowpath+0xd5/0x170
[  227.425790]  [<ffffffff81a311d5>] ? __mutex_unlock_slowpath+0xd5/0x170
[  227.426103]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  227.426390]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  227.426673]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  227.426943]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  227.427222]  [<ffffffff811bda2c>] ? fsnotify+0x7c/0x2d0
[  227.427503]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  227.427763]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  227.428077]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  227.428336] Mem-Info:
[  227.428491] Node 0 DMA per-cpu:
[  227.428711] CPU    0: hi:    0, btch:   1 usd:   0
[  227.428960] CPU    1: hi:    0, btch:   1 usd:   0
[  227.429206] CPU    2: hi:    0, btch:   1 usd:   0
[  227.429453] CPU    3: hi:    0, btch:   1 usd:   0
[  227.429700] CPU    4: hi:    0, btch:   1 usd:   0
[  227.429948] CPU    5: hi:    0, btch:   1 usd:   0
[  227.430195] CPU    6: hi:    0, btch:   1 usd:   0
[  227.430441] CPU    7: hi:    0, btch:   1 usd:   0
[  227.430688] Node 0 DMA32 per-cpu:
[  227.430916] CPU    0: hi:   90, btch:  15 usd:   0
[  227.431163] CPU    1: hi:   90, btch:  15 usd:  12
[  227.431409] CPU    2: hi:   90, btch:  15 usd:   8
[  227.431663] CPU    3: hi:   90, btch:  15 usd:  12
[  227.431910] CPU    4: hi:   90, btch:  15 usd:  14
[  227.432156] CPU    5: hi:   90, btch:  15 usd:   9
[  227.432404] CPU    6: hi:   90, btch:  15 usd:  24
[  227.432651] CPU    7: hi:   90, btch:  15 usd:   0
[  227.432903] active_anon:4512 inactive_anon:22 isolated_anon:0
[  227.432904]  active_file:26 inactive_file:398 isolated_file:265
[  227.432904]  unevictable:0 dirty:0 writeback:0 unstable:0
[  227.432905]  free:817 slab_reclaimable:12343 slab_unreclaimable:5117
[  227.432906]  mapped:34 shmem:75 pagetables:343 bounce:0
[  227.434316] Node 0 DMA free:1056kB min:120kB low:148kB high:180kB active_anon:572kB inactive_anon:0kB active_file:0kB inactive_file:204kB unevictable:0kB isolated(anon):0kB isolated(file):128kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:12984kB slab_unreclaimable:268kB kernel_stack:8kB pagetables:20kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:64 all_unreclaimable? no
[  227.436004] lowmem_reserve[]: 0 236 236 236
[  227.436402] Node 0 DMA32 free:1876kB min:1904kB low:2380kB high:2856kB active_anon:17476kB inactive_anon:88kB active_file:104kB inactive_file:1740kB unevictable:0kB isolated(anon):0kB isolated(file):716kB present:242400kB mlocked:0kB dirty:96kB writeback:184kB mapped:136kB shmem:300kB slab_reclaimable:36388kB slab_unreclaimable:20200kB kernel_stack:1128kB pagetables:1352kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:834 all_unreclaimable? no
[  227.438203] lowmem_reserve[]: 0 0 0 0
[  227.438599] Node 0 DMA: 10*4kB 44*8kB 39*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1016kB
[  227.439586] Node 0 DMA32: 156*4kB 155*8kB 4*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1928kB
[  227.440661] 1185 total pagecache pages
[  227.440867] 0 pages in swap cache
[  227.441062] Swap cache stats: add 0, delete 0, find 0/0
[  227.441322] Free swap  = 0kB
[  227.441496] Total swap = 0kB
[  227.442297] 65520 pages RAM
[  227.442471] 16492 pages reserved
[  227.442658] 1711 pages shared
[  227.442837] 46607 pages non-shared
[  227.443032] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  227.443425] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  227.443812] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  227.444196] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  227.444572] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  227.444946] [ 2448]   104  2448     5864       83   4       0             0 dbus-daemon
[  227.445345] [ 2524]     0  2524     6081       49   5       0             0 hald-addon-inpu
[  227.445761] [ 2541]     0  2541     6083       48   1       0             0 hald-addon-cpuf
[  227.446181] [ 2542]   106  2542     6535       53   0       0             0 hald-addon-acpi
[  227.446598] [ 2632]     0  2632     1494       26   4       0             0 getty
[  227.446982] [ 2633]     0  2633     1494       27   0       0             0 getty
[  227.447367] [ 2634]     0  2634     1494       27   0       0             0 getty
[  227.447762] [ 2635]     0  2635     1494       27   0       0             0 getty
[  227.448144] [ 2636]     0  2636     1494       26   0       0             0 getty
[  227.448531] [ 2638]     0  2638     1494       26   0       0             0 getty
[  227.448919] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  227.449294] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  227.449715] [ 2749]     0  2749     3460      288   2       0             0 dd
[  227.450086] [ 2750]     0  2750     3460      287   6       0             0 dd
[  227.450460] [ 2751]     0  2751     3460      287   1       0             0 dd
[  227.451407] [ 2752]     0  2752     3460      288   1       0             0 dd
[  227.451788] [ 2753]     0  2753     3460      288   7       0             0 dd
[  227.452160] [ 2754]     0  2754     3460      287   7       0             0 dd
[  227.452533] [ 2755]     0  2755     3460      287   4       0             0 dd
[  227.452908] [ 2756]     0  2756     3460      288   5       0             0 dd
[  227.453284] [ 2757]     0  2757     3460      288   3       0             0 dd
[  227.453660] [ 2758]     0  2758     3460      288   1       0             0 dd
[  227.454032] [ 2759]     0  2759     3437       84   1       0             0 plot-written.sh
[  227.454444] [ 2776]     0  2776     2145       39   4       0             0 iostat
[  227.454830] [ 9929]     0  9929     3202       39   5       0             0 date
[  227.455207] Out of memory: Kill process 2448 (dbus-daemon) score 1 or sacrifice child
[  227.455670] Killed process 2448 (dbus-daemon) total-vm:23456kB, anon-rss:328kB, file-rss:4kB
[  227.931323] iostat invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  227.931753] iostat cpuset=/ mems_allowed=0
[  227.931972] Pid: 2776, comm: iostat Not tainted 2.6.37-rc3 #154
[  227.932255] Call Trace:
[  227.932414]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  227.932697]  [<ffffffff81130593>] dump_header+0x83/0x200
[  227.932962]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  227.933245]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  227.933518]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  227.933787]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  227.934066]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  227.934339]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  227.934644]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  227.934932]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  227.935216]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  227.935528]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  227.935880]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  227.936183]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  227.936435]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  227.936707]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  227.936993]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  227.937251]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  227.937530]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  227.937804]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  227.938104]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  227.938375]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  227.938627]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  227.938935]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  227.939189] Mem-Info:
[  227.939339] Node 0 DMA per-cpu:
[  227.939556] CPU    0: hi:    0, btch:   1 usd:   0
[  227.939833] CPU    1: hi:    0, btch:   1 usd:   0
[  227.940078] CPU    2: hi:    0, btch:   1 usd:   0
[  227.940322] CPU    3: hi:    0, btch:   1 usd:   0
[  227.940564] CPU    4: hi:    0, btch:   1 usd:   0
[  227.940806] CPU    5: hi:    0, btch:   1 usd:   0
[  227.941049] CPU    6: hi:    0, btch:   1 usd:   0
[  227.941291] CPU    7: hi:    0, btch:   1 usd:   0
[  227.941533] Node 0 DMA32 per-cpu:
[  227.941755] CPU    0: hi:   90, btch:  15 usd:   0
[  227.941998] CPU    1: hi:   90, btch:  15 usd:   0
[  227.942241] CPU    2: hi:   90, btch:  15 usd:   0
[  227.942484] CPU    3: hi:   90, btch:  15 usd:   0
[  227.942728] CPU    4: hi:   90, btch:  15 usd:  17
[  227.942969] CPU    5: hi:   90, btch:  15 usd:   7
[  227.943212] CPU    6: hi:   90, btch:  15 usd:  14
[  227.943455] CPU    7: hi:   90, btch:  15 usd:   0
[  227.943735] active_anon:4462 inactive_anon:0 isolated_anon:0
[  227.943737]  active_file:26 inactive_file:1013 isolated_file:0
[  227.943738]  unevictable:0 dirty:11 writeback:0 unstable:0
[  227.943739]  free:728 slab_reclaimable:12283 slab_unreclaimable:5147
[  227.943740]  mapped:34 shmem:75 pagetables:343 bounce:0
[  227.945124] Node 0 DMA free:1056kB min:120kB low:148kB high:180kB active_anon:572kB inactive_anon:0kB active_file:0kB inactive_file:148kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:12984kB slab_unreclaimable:268kB kernel_stack:8kB pagetables:20kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:252 all_unreclaimable? yes
[  227.946837] lowmem_reserve[]: 0 236 236 236
[  227.947228] Node 0 DMA32 free:1880kB min:1904kB low:2380kB high:2856kB active_anon:17276kB inactive_anon:0kB active_file:104kB inactive_file:3904kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:96kB writeback:0kB mapped:136kB shmem:300kB slab_reclaimable:36148kB slab_unreclaimable:20320kB kernel_stack:1128kB pagetables:1352kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:10121 all_unreclaimable? yes
[  227.949004] lowmem_reserve[]: 0 0 0 0
[  227.949374] Node 0 DMA: 21*4kB 30*8kB 48*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1092kB
[  227.950312] Node 0 DMA32: 156*4kB 105*8kB 16*16kB 5*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1880kB
[  227.951264] 1245 total pagecache pages
[  227.951469] 0 pages in swap cache
[  227.951656] Swap cache stats: add 0, delete 0, find 0/0
[  227.951951] Free swap  = 0kB
[  227.952124] Total swap = 0kB
[  227.952895] 65520 pages RAM
[  227.953065] 16492 pages reserved
[  227.953251] 1367 pages shared
[  227.953426] 46562 pages non-shared
[  227.953618] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  227.954000] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  227.954376] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  227.954752] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  227.955129] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  227.955501] [ 2524]     0  2524     6081       49   5       0             0 hald-addon-inpu
[  227.955922] [ 2541]     0  2541     6083       54   4       0             0 hald-addon-cpuf
[  227.956329] [ 2542]   106  2542     6535       53   0       0             0 hald-addon-acpi
[  227.956736] [ 2632]     0  2632     1494       26   4       0             0 getty
[  227.957110] [ 2633]     0  2633     1494       27   0       0             0 getty
[  227.957484] [ 2634]     0  2634     1494       27   0       0             0 getty
[  227.957858] [ 2635]     0  2635     1494       27   0       0             0 getty
[  227.958231] [ 2636]     0  2636     1494       26   0       0             0 getty
[  227.958606] [ 2638]     0  2638     1494       26   0       0             0 getty
[  227.958980] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  227.959347] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  227.959761] [ 2749]     0  2749     3460      286   4       0             0 dd
[  227.960126] [ 2750]     0  2750     3460      285   4       0             0 dd
[  227.960491] [ 2751]     0  2751     3460      287   4       0             0 dd
[  227.960855] [ 2752]     0  2752     3460      286   1       0             0 dd
[  227.961219] [ 2753]     0  2753     3460      288   3       0             0 dd
[  227.961585] [ 2754]     0  2754     3460      285   7       0             0 dd
[  227.961951] [ 2755]     0  2755     3460      287   7       0             0 dd
[  227.962317] [ 2756]     0  2756     3460      288   4       0             0 dd
[  227.962683] [ 2757]     0  2757     3460      286   1       0             0 dd
[  227.963047] [ 2758]     0  2758     3460      286   3       0             0 dd
[  227.963413] [ 2759]     0  2759     3437       80   1       0             0 plot-written.sh
[  227.963831] [ 2776]     0  2776     2144       48   6       0             0 iostat
[  227.964210] [ 9929]     0  9929     3202       40   5       0             0 date
[  227.964583] Out of memory: Kill process 2524 (hald-addon-inpu) score 1 or sacrifice child
[  227.964983] Killed process 2524 (hald-addon-inpu) total-vm:24324kB, anon-rss:192kB, file-rss:4kB
[  233.630941] grep invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  233.631361] grep cpuset=/ mems_allowed=0
[  233.631579] Pid: 10008, comm: grep Not tainted 2.6.37-rc3 #154
[  233.631874] Call Trace:
[  233.632040]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  233.632341]  [<ffffffff81130593>] dump_header+0x83/0x200
[  233.632616]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  233.632919]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  233.633203]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  233.633489]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  233.633787]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  233.634082]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  233.634426]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  233.635279]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  233.635576]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  233.635903]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  233.636235]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  233.636554]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  233.636823]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  233.637109]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  233.637409]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  233.637685]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  233.637967]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  233.638261]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  233.638559]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  233.638878]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  233.639164]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  233.639444]  [<ffffffff810bb929>] ? trace_hardirqs_off_caller+0x29/0x150
[  233.639773]  [<ffffffff810bba5d>] ? trace_hardirqs_off+0xd/0x10
[  233.640075]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  233.640357]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  233.640624]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  233.640945]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  233.641214] Mem-Info:
[  233.641372] Node 0 DMA per-cpu:
[  233.641603] CPU    0: hi:    0, btch:   1 usd:   0
[  233.641859] CPU    1: hi:    0, btch:   1 usd:   0
[  233.642114] CPU    2: hi:    0, btch:   1 usd:   0
[  233.642377] CPU    3: hi:    0, btch:   1 usd:   0
[  233.642632] CPU    4: hi:    0, btch:   1 usd:   0
[  233.642888] CPU    5: hi:    0, btch:   1 usd:   0
[  233.643145] CPU    6: hi:    0, btch:   1 usd:   0
[  233.643400] CPU    7: hi:    0, btch:   1 usd:   0
[  233.643655] Node 0 DMA32 per-cpu:
[  233.643890] CPU    0: hi:   90, btch:  15 usd:   0
[  233.644148] CPU    1: hi:   90, btch:  15 usd:  23
[  233.644406] CPU    2: hi:   90, btch:  15 usd:   0
[  233.644659] CPU    3: hi:   90, btch:  15 usd:   0
[  233.644915] CPU    4: hi:   90, btch:  15 usd:   0
[  233.645171] CPU    5: hi:   90, btch:  15 usd:   7
[  233.645428] CPU    6: hi:   90, btch:  15 usd:  14
[  233.645685] CPU    7: hi:   90, btch:  15 usd:   8
[  233.645942] active_anon:4396 inactive_anon:26 isolated_anon:0
[  233.645943]  active_file:26 inactive_file:1033 isolated_file:92
[  233.645944]  unevictable:0 dirty:368 writeback:61 unstable:0
[  233.645945]  free:754 slab_reclaimable:12613 slab_unreclaimable:5104
[  233.645947]  mapped:44 shmem:75 pagetables:328 bounce:0
[  233.647410] Node 0 DMA free:1064kB min:120kB low:148kB high:180kB active_anon:572kB inactive_anon:0kB active_file:0kB inactive_file:268kB unevictable:0kB isolated(anon):0kB isolated(file):128kB present:15660kB mlocked:0kB dirty:20kB writeback:0kB mapped:48kB shmem:0kB slab_reclaimable:13092kB slab_unreclaimable:216kB kernel_stack:8kB pagetables:20kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:5473 all_unreclaimable? no
[  233.649164] lowmem_reserve[]: 0 236 236 236
[  233.649582] Node 0 DMA32 free:1920kB min:1904kB low:2380kB high:2856kB active_anon:17012kB inactive_anon:36kB active_file:108kB inactive_file:3916kB unevictable:0kB isolated(anon):0kB isolated(file):288kB present:242400kB mlocked:0kB dirty:152kB writeback:1396kB mapped:128kB shmem:300kB slab_reclaimable:37360kB slab_unreclaimable:20200kB kernel_stack:1120kB pagetables:1292kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:445 all_unreclaimable? no
[  233.651403] lowmem_reserve[]: 0 0 0 0
[  233.651800] Node 0 DMA: 48*4kB 100*8kB 8*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1120kB
[  233.652777] Node 0 DMA32: 104*4kB 156*8kB 2*16kB 5*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1856kB
[  233.653769] 1363 total pagecache pages
[  233.653983] 0 pages in swap cache
[  233.654175] Swap cache stats: add 0, delete 0, find 0/0
[  233.654448] Free swap  = 0kB
[  233.654625] Total swap = 0kB
[  233.655543] 65520 pages RAM
[  233.655721] 16492 pages reserved
[  233.655917] 1897 pages shared
[  233.656102] 46396 pages non-shared
[  233.656304] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  233.656706] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  233.657105] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  233.657503] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  233.657900] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  233.658294] [ 2541]     0  2541     6083       55   0       0             0 hald-addon-cpuf
[  233.658734] [ 2542]   106  2542     6535       51   4       0             0 hald-addon-acpi
[  233.659159] [ 2632]     0  2632     1494       26   4       0             0 getty
[  233.659546] [ 2633]     0  2633     1494       27   0       0             0 getty
[  233.659932] [ 2634]     0  2634     1494       27   0       0             0 getty
[  233.660332] [ 2635]     0  2635     1494       27   0       0             0 getty
[  233.660718] [ 2636]     0  2636     1494       26   0       0             0 getty
[  233.661110] [ 2638]     0  2638     1494       26   0       0             0 getty
[  233.661510] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  233.661897] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  233.662329] [ 2749]     0  2749     3460      289   5       0             0 dd
[  233.662723] [ 2750]     0  2750     3460      289   2       0             0 dd
[  233.663109] [ 2751]     0  2751     3460      288   2       0             0 dd
[  233.663496] [ 2752]     0  2752     3460      289   6       0             0 dd
[  233.663880] [ 2753]     0  2753     3460      290   7       0             0 dd
[  233.664267] [ 2754]     0  2754     3460      285   0       0             0 dd
[  233.664657] [ 2755]     0  2755     3460      288   5       0             0 dd
[  233.665042] [ 2756]     0  2756     3460      289   5       0             0 dd
[  233.665428] [ 2757]     0  2757     3460      290   5       0             0 dd
[  233.665815] [ 2758]     0  2758     3460      290   5       0             0 dd
[  233.666202] [ 2759]     0  2759     3437       70   4       0             0 plot-written.sh
[  233.666644] [ 2776]     0  2776     2145       63   3       0             0 iostat
[  233.667044] [10007]     0 10007     3437       70   5       0             0 plot-written.sh
[  233.667470] [10008]     0 10008     2675       33   4       0             0 grep
[  233.667864] Out of memory: Kill process 2541 (hald-addon-cpuf) score 1 or sacrifice child
[  233.668288] Killed process 2541 (hald-addon-cpuf) total-vm:24332kB, anon-rss:188kB, file-rss:32kB
[  236.216613] iostat invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  236.217039] iostat cpuset=/ mems_allowed=0
[  236.217262] Pid: 2776, comm: iostat Not tainted 2.6.37-rc3 #154
[  236.217553] Call Trace:
[  236.217718]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  236.218008]  [<ffffffff81130593>] dump_header+0x83/0x200
[  236.218277]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  236.218565]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  236.218844]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  236.219120]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  236.219408]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  236.219701]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  236.220015]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  236.220312]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  236.220601]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  236.220921]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  236.221243]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  236.221552]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  236.221812]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  236.222090]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  236.222379]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  236.222643]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  236.222929]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  236.223209]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  236.223515]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  236.223802]  [<ffffffff810fac04>] ? __call_rcu+0xd4/0x1a0
[  236.224072]  [<ffffffff810fac04>] ? __call_rcu+0xd4/0x1a0
[  236.224342]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  236.224600]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  236.224913]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  236.225172] Mem-Info:
[  236.225326] Node 0 DMA per-cpu:
[  236.225544] CPU    0: hi:    0, btch:   1 usd:   0
[  236.225789] CPU    1: hi:    0, btch:   1 usd:   0
[  236.226036] CPU    2: hi:    0, btch:   1 usd:   0
[  236.226282] CPU    3: hi:    0, btch:   1 usd:   0
[  236.226529] CPU    4: hi:    0, btch:   1 usd:   0
[  236.226775] CPU    5: hi:    0, btch:   1 usd:   0
[  236.227032] CPU    6: hi:    0, btch:   1 usd:   0
[  236.227278] CPU    7: hi:    0, btch:   1 usd:   0
[  236.227525] Node 0 DMA32 per-cpu:
[  236.227768] CPU    0: hi:   90, btch:  15 usd:  33
[  236.228015] CPU    1: hi:   90, btch:  15 usd:  24
[  236.228261] CPU    2: hi:   90, btch:  15 usd:  24
[  236.228507] CPU    3: hi:   90, btch:  15 usd:   0
[  236.228754] CPU    4: hi:   90, btch:  15 usd:  82
[  236.229575] CPU    5: hi:   90, btch:  15 usd:   0
[  236.229824] CPU    6: hi:   90, btch:  15 usd:  14
[  236.230072] CPU    7: hi:   90, btch:  15 usd:  20
[  236.230321] active_anon:4318 inactive_anon:0 isolated_anon:2
[  236.230322]  active_file:188 inactive_file:1707 isolated_file:0
[  236.230323]  unevictable:0 dirty:104 writeback:160 unstable:0
[  236.230324]  free:734 slab_reclaimable:12754 slab_unreclaimable:5107
[  236.230325]  mapped:117 shmem:75 pagetables:292 bounce:0
[  236.231744] Node 0 DMA free:1044kB min:120kB low:148kB high:180kB active_anon:572kB inactive_anon:0kB active_file:36kB inactive_file:640kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:40kB mapped:16kB shmem:0kB slab_reclaimable:13144kB slab_unreclaimable:256kB kernel_stack:8kB pagetables:20kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1480 all_unreclaimable? yes
[  236.233447] lowmem_reserve[]: 0 236 236 236
[  236.233851] Node 0 DMA32 free:1892kB min:1904kB low:2380kB high:2856kB active_anon:16700kB inactive_anon:0kB active_file:716kB inactive_file:6188kB unevictable:0kB isolated(anon):8kB isolated(file):0kB present:242400kB mlocked:0kB dirty:416kB writeback:600kB mapped:452kB shmem:300kB slab_reclaimable:37872kB slab_unreclaimable:20172kB kernel_stack:1096kB pagetables:1148kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:15720 all_unreclaimable? yes
[  236.235637] lowmem_reserve[]: 0 0 0 0
[  236.236017] Node 0 DMA: 10*4kB 57*8kB 37*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1088kB
[  236.236975] Node 0 DMA32: 74*4kB 185*8kB 0*16kB 3*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1872kB
[  236.237940] 2059 total pagecache pages
[  236.238146] 0 pages in swap cache
[  236.238339] Swap cache stats: add 0, delete 0, find 0/0
[  236.238601] Free swap  = 0kB
[  236.238776] Total swap = 0kB
[  236.239644] 65520 pages RAM
[  236.239819] 16492 pages reserved
[  236.240008] 1330 pages shared
[  236.240187] 46616 pages non-shared
[  236.240383] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  236.240771] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  236.241157] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  236.241542] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  236.241925] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  236.242304] [ 2542]   106  2542     6535       51   4       0             0 hald-addon-acpi
[  236.242720] [ 2632]     0  2632     1494       26   4       0             0 getty
[  236.243100] [ 2633]     0  2633     1494       27   0       0             0 getty
[  236.243482] [ 2634]     0  2634     1494       27   0       0             0 getty
[  236.243875] [ 2635]     0  2635     1494       27   0       0             0 getty
[  236.244259] [ 2636]     0  2636     1494       26   0       0             0 getty
[  236.244643] [ 2638]     0  2638     1494       26   0       0             0 getty
[  236.245029] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  236.245407] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  236.245825] [ 2749]     0  2749     3460      290   4       0             0 dd
[  236.246199] [ 2750]     0  2750     3460      289   4       0             0 dd
[  236.246573] [ 2751]     0  2751     3460      289   7       0             0 dd
[  236.246947] [ 2752]     0  2752     3460      290   1       0             0 dd
[  236.247322] [ 2753]     0  2753     3460      290   3       0             0 dd
[  236.247704] [ 2754]     0  2754     3460      289   7       0             0 dd
[  236.248079] [ 2755]     0  2755     3460      289   1       0             0 dd
[  236.248454] [ 2756]     0  2756     3460      290   2       0             0 dd
[  236.248828] [ 2757]     0  2757     3460      290   1       0             0 dd
[  236.249201] [ 2758]     0  2758     3460      290   7       0             0 dd
[  236.249575] [ 2759]     0  2759     3437      158   4       0             0 plot-written.sh
[  236.249993] [ 2776]     0  2776     2145       76   3       0             0 iostat
[  236.250381] [10015]     0 10015     3437      106   0       0             0 plot-written.sh
[  236.250796] Out of memory: Kill process 2542 (hald-addon-acpi) score 1 or sacrifice child
[  236.251205] Killed process 2542 (hald-addon-acpi) total-vm:26140kB, anon-rss:200kB, file-rss:4kB
[  237.068298] date invoked oom-killer: gfp_mask=0x84d0, order=0, oom_adj=0, oom_score_adj=0
[  237.068716] date cpuset=/ mems_allowed=0
[  237.068934] Pid: 10025, comm: date Not tainted 2.6.37-rc3 #154
[  237.069223] Call Trace:
[  237.069388]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  237.069679]  [<ffffffff81130593>] dump_header+0x83/0x200
[  237.069950]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  237.070240]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  237.070518]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  237.070793]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  237.071079]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  237.071361]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  237.071671]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  237.071989]  [<ffffffff8106934b>] pte_alloc_one+0x1b/0x40
[  237.072264]  [<ffffffff8114df1f>] __pte_alloc+0x2f/0xf0
[  237.072531]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  237.072804]  [<ffffffff811509d7>] handle_mm_fault+0xa97/0xc20
[  237.073089]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  237.073372]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  237.073652]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  237.073926]  [<ffffffff810bb929>] ? trace_hardirqs_off_caller+0x29/0x150
[  237.074247]  [<ffffffff810bba5d>] ? trace_hardirqs_off+0xd/0x10
[  237.074539]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  237.074811]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  237.075070]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  237.075386]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  237.075649] Mem-Info:
[  237.075802] Node 0 DMA per-cpu:
[  237.076033] CPU    0: hi:    0, btch:   1 usd:   0
[  237.076283] CPU    1: hi:    0, btch:   1 usd:   0
[  237.076532] CPU    2: hi:    0, btch:   1 usd:   0
[  237.076781] CPU    3: hi:    0, btch:   1 usd:   0
[  237.077029] CPU    4: hi:    0, btch:   1 usd:   0
[  237.077279] CPU    5: hi:    0, btch:   1 usd:   0
[  237.077528] CPU    6: hi:    0, btch:   1 usd:   0
[  237.077777] CPU    7: hi:    0, btch:   1 usd:   0
[  237.078026] Node 0 DMA32 per-cpu:
[  237.078256] CPU    0: hi:   90, btch:  15 usd:  35
[  237.078505] CPU    1: hi:   90, btch:  15 usd:  28
[  237.078753] CPU    2: hi:   90, btch:  15 usd:  14
[  237.079001] CPU    3: hi:   90, btch:  15 usd:   0
[  237.079250] CPU    4: hi:   90, btch:  15 usd:   3
[  237.079498] CPU    5: hi:   90, btch:  15 usd:   0
[  237.079748] CPU    6: hi:   90, btch:  15 usd:   0
[  237.080005] CPU    7: hi:   90, btch:  15 usd:   5
[  237.080261] active_anon:4303 inactive_anon:0 isolated_anon:0
[  237.080262]  active_file:240 inactive_file:1785 isolated_file:0
[  237.080263]  unevictable:0 dirty:122 writeback:0 unstable:0
[  237.080264]  free:748 slab_reclaimable:12788 slab_unreclaimable:5100
[  237.080265]  mapped:250 shmem:75 pagetables:307 bounce:0
[  237.081685] Node 0 DMA free:1036kB min:120kB low:148kB high:180kB active_anon:552kB inactive_anon:0kB active_file:36kB inactive_file:608kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:48kB mapped:100kB shmem:0kB slab_reclaimable:13144kB slab_unreclaimable:224kB kernel_stack:24kB pagetables:24kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:982 all_unreclaimable? yes
[  237.083397] lowmem_reserve[]: 0 236 236 236
[  237.083803] Node 0 DMA32 free:1920kB min:1904kB low:2380kB high:2856kB active_anon:16660kB inactive_anon:0kB active_file:924kB inactive_file:6532kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:496kB writeback:0kB mapped:900kB shmem:300kB slab_reclaimable:38008kB slab_unreclaimable:20176kB kernel_stack:1104kB pagetables:1204kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:13652 all_unreclaimable? yes
[  237.085592] lowmem_reserve[]: 0 0 0 0
[  237.085979] Node 0 DMA: 2*4kB 48*8kB 44*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1096kB
[  237.086950] Node 0 DMA32: 130*4kB 143*8kB 7*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1808kB
[  237.087933] 2190 total pagecache pages
[  237.088150] 0 pages in swap cache
[  237.088344] Swap cache stats: add 0, delete 0, find 0/0
[  237.088609] Free swap  = 0kB
[  237.088785] Total swap = 0kB
[  237.089664] 65520 pages RAM
[  237.089838] 16492 pages reserved
[  237.090029] 1235 pages shared
[  237.090208] 46759 pages non-shared
[  237.090404] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  237.090793] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  237.091177] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  237.091562] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  237.091947] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  237.092910] [ 2632]     0  2632     1494       26   4       0             0 getty
[  237.093295] [ 2633]     0  2633     1494       27   0       0             0 getty
[  237.093679] [ 2634]     0  2634     1494       27   0       0             0 getty
[  237.094062] [ 2635]     0  2635     1494       27   0       0             0 getty
[  237.094446] [ 2636]     0  2636     1494       26   0       0             0 getty
[  237.094830] [ 2638]     0  2638     1494       26   0       0             0 getty
[  237.095215] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  237.095594] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  237.096018] [ 2749]     0  2749     3460      290   1       0             0 dd
[  237.096393] [ 2750]     0  2750     3460      289   6       0             0 dd
[  237.096768] [ 2751]     0  2751     3460      289   2       0             0 dd
[  237.097141] [ 2752]     0  2752     3460      290   2       0             0 dd
[  237.097516] [ 2753]     0  2753     3460      290   4       0             0 dd
[  237.097890] [ 2754]     0  2754     3460      289   5       0             0 dd
[  237.098264] [ 2755]     0  2755     3460      289   3       0             0 dd
[  237.098639] [ 2756]     0  2756     3460      290   2       0             0 dd
[  237.099013] [ 2757]     0  2757     3460      290   7       0             0 dd
[  237.099387] [ 2758]     0  2758     3460      290   5       0             0 dd
[  237.099762] [ 2759]     0  2759     3437      172   4       0             0 plot-written.sh
[  237.100186] [ 2776]     0  2776     2144       79   5       0             0 iostat
[  237.100574] [10025]     0 10025     3202      120   6       0             0 date
[  237.100954] Out of memory: Kill process 2632 (getty) score 1 or sacrifice child
[  237.101330] Killed process 2632 (getty) total-vm:5976kB, anon-rss:100kB, file-rss:4kB
[  237.225753] getconf invoked oom-killer: gfp_mask=0x84d0, order=0, oom_adj=0, oom_score_adj=0
[  237.226177] getconf cpuset=/ mems_allowed=0
[  237.226399] Pid: 10027, comm: getconf Not tainted 2.6.37-rc3 #154
[  237.226690] Call Trace:
[  237.226850]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  237.227134]  [<ffffffff81130593>] dump_header+0x83/0x200
[  237.227399]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  237.227683]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  237.227956]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  237.228238]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  237.228518]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  237.228792]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  237.229096]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  237.229387]  [<ffffffff8106934b>] pte_alloc_one+0x1b/0x40
[  237.229655]  [<ffffffff8114df1f>] __pte_alloc+0x2f/0xf0
[  237.229917]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  237.230184]  [<ffffffff811509d7>] handle_mm_fault+0xa97/0xc20
[  237.230465]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  237.230742]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  237.231015]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  237.231282]  [<ffffffff810bb929>] ? trace_hardirqs_off_caller+0x29/0x150
[  237.231598]  [<ffffffff810bba5d>] ? trace_hardirqs_off+0xd/0x10
[  237.231883]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  237.232162]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  237.232417]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  237.232727]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  237.232984] Mem-Info:
[  237.233134] Node 0 DMA per-cpu:
[  237.233351] CPU    0: hi:    0, btch:   1 usd:   0
[  237.233594] CPU    1: hi:    0, btch:   1 usd:   0
[  237.233836] CPU    2: hi:    0, btch:   1 usd:   0
[  237.234080] CPU    3: hi:    0, btch:   1 usd:   0
[  237.234323] CPU    4: hi:    0, btch:   1 usd:   0
[  237.234567] CPU    5: hi:    0, btch:   1 usd:   0
[  237.234809] CPU    6: hi:    0, btch:   1 usd:   0
[  237.235053] CPU    7: hi:    0, btch:   1 usd:   0
[  237.235297] Node 0 DMA32 per-cpu:
[  237.235521] CPU    0: hi:   90, btch:  15 usd:  22
[  237.235761] CPU    1: hi:   90, btch:  15 usd:  75
[  237.236001] CPU    2: hi:   90, btch:  15 usd:  14
[  237.236257] CPU    3: hi:   90, btch:  15 usd:   0
[  237.236500] CPU    4: hi:   90, btch:  15 usd:  19
[  237.236741] CPU    5: hi:   90, btch:  15 usd:   0
[  237.236988] CPU    6: hi:   90, btch:  15 usd:   0
[  237.237231] CPU    7: hi:   90, btch:  15 usd:   0
[  237.237474] active_anon:4281 inactive_anon:7 isolated_anon:0
[  237.237475]  active_file:251 inactive_file:1703 isolated_file:0
[  237.237476]  unevictable:0 dirty:7 writeback:196 unstable:0
[  237.237476]  free:701 slab_reclaimable:12808 slab_unreclaimable:5119
[  237.237477]  mapped:197 shmem:75 pagetables:277 bounce:0
[  237.238855] Node 0 DMA free:1036kB min:120kB low:148kB high:180kB active_anon:572kB inactive_anon:0kB active_file:8kB inactive_file:728kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:44kB shmem:0kB slab_reclaimable:13148kB slab_unreclaimable:216kB kernel_stack:8kB pagetables:20kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1114 all_unreclaimable? yes
[  237.240511] lowmem_reserve[]: 0 236 236 236
[  237.240898] Node 0 DMA32 free:1868kB min:1904kB low:2380kB high:2856kB active_anon:16552kB inactive_anon:28kB active_file:996kB inactive_file:6084kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:88kB writeback:816kB mapped:744kB shmem:300kB slab_reclaimable:38084kB slab_unreclaimable:20260kB kernel_stack:1096kB pagetables:1088kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:13373 all_unreclaimable? yes
[  237.242627] lowmem_reserve[]: 0 0 0 0
[  237.242994] Node 0 DMA: 6*4kB 36*8kB 46*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1048kB
[  237.243934] Node 0 DMA32: 107*4kB 168*8kB 4*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1868kB
[  237.244905] 2126 total pagecache pages
[  237.245109] 0 pages in swap cache
[  237.245297] Swap cache stats: add 0, delete 0, find 0/0
[  237.245552] Free swap  = 0kB
[  237.245723] Total swap = 0kB
[  237.246505] 65520 pages RAM
[  237.246672] 16492 pages reserved
[  237.246856] 1393 pages shared
[  237.247030] 46727 pages non-shared
[  237.247221] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  237.247596] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  237.247969] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  237.248354] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  237.248728] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  237.249102] [ 2633]     0  2633     1494       27   0       0             0 getty
[  237.249479] [ 2634]     0  2634     1494       27   0       0             0 getty
[  237.249856] [ 2635]     0  2635     1494       27   0       0             0 getty
[  237.250232] [ 2636]     0  2636     1494       26   0       0             0 getty
[  237.250608] [ 2638]     0  2638     1494       26   0       0             0 getty
[  237.250983] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  237.251353] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  237.251761] [ 2749]     0  2749     3460      290   6       0             0 dd
[  237.252138] [ 2750]     0  2750     3460      289   6       0             0 dd
[  237.252506] [ 2751]     0  2751     3460      289   7       0             0 dd
[  237.252874] [ 2752]     0  2752     3460      290   2       0             0 dd
[  237.253243] [ 2753]     0  2753     3460      290   3       0             0 dd
[  237.253608] [ 2754]     0  2754     3460      289   5       0             0 dd
[  237.253976] [ 2755]     0  2755     3460      289   7       0             0 dd
[  237.254342] [ 2756]     0  2756     3460      290   6       0             0 dd
[  237.254710] [ 2757]     0  2757     3460      290   1       0             0 dd
[  237.255076] [ 2758]     0  2758     3460      290   1       0             0 dd
[  237.255444] [ 2759]     0  2759     3437      171   4       0             0 plot-written.sh
[  237.255851] [ 2776]     0  2776     2144       79   5       0             0 iostat
[  237.256238] [10026]     0 10026     3437      156   4       0             0 plot-written.sh
[  237.256648] [10027]     0 10027     2135      106   4       0             0 getconf
[  237.257030] Out of memory: Kill process 2633 (getty) score 1 or sacrifice child
[  237.257399] Killed process 2633 (getty) total-vm:5976kB, anon-rss:104kB, file-rss:4kB
[  237.441342] init invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  237.441747] init cpuset=/ mems_allowed=0
[  237.441957] Pid: 10030, comm: init Not tainted 2.6.37-rc3 #154
[  237.442236] Call Trace:
[  237.442393]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  237.442673]  [<ffffffff81130593>] dump_header+0x83/0x200
[  237.442936]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  237.443216]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  237.443486]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  237.443753]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  237.444028]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  237.444317]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  237.444618]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  237.444904]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  237.445184]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  237.445491]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  237.445803]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  237.446068]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  237.446321]  [<ffffffff81138bbe>] ondemand_readahead+0x10e/0x2b0
[  237.446609]  [<ffffffff81138e66>] page_cache_sync_readahead+0x36/0x50
[  237.446914]  [<ffffffff8112f984>] filemap_fault+0x444/0x4f0
[  237.447188]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  237.447474]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  237.447734]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  237.448014]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  237.448344]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  237.448643]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  237.448914]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  237.449177]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  237.449476]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  237.449725]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  237.450029]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  237.450284] Mem-Info:
[  237.450431] Node 0 DMA per-cpu:
[  237.450645] CPU    0: hi:    0, btch:   1 usd:   0
[  237.450884] CPU    1: hi:    0, btch:   1 usd:   0
[  237.451125] CPU    2: hi:    0, btch:   1 usd:   0
[  237.451366] CPU    3: hi:    0, btch:   1 usd:   0
[  237.451606] CPU    4: hi:    0, btch:   1 usd:   0
[  237.451846] CPU    5: hi:    0, btch:   1 usd:   0
[  237.452087] CPU    6: hi:    0, btch:   1 usd:   0
[  237.452379] CPU    7: hi:    0, btch:   1 usd:   0
[  237.452623] Node 0 DMA32 per-cpu:
[  237.452846] CPU    0: hi:   90, btch:  15 usd:  23
[  237.453088] CPU    1: hi:   90, btch:  15 usd:   0
[  237.453330] CPU    2: hi:   90, btch:  15 usd:  76
[  237.453573] CPU    3: hi:   90, btch:  15 usd:   0
[  237.453816] CPU    4: hi:   90, btch:  15 usd:  29
[  237.454058] CPU    5: hi:   90, btch:  15 usd:  28
[  237.454301] CPU    6: hi:   90, btch:  15 usd:   0
[  237.454544] CPU    7: hi:   90, btch:  15 usd:   0
[  237.454787] active_anon:4247 inactive_anon:15 isolated_anon:0
[  237.454788]  active_file:251 inactive_file:565 isolated_file:0
[  237.454788]  unevictable:0 dirty:21 writeback:73 unstable:0
[  237.454789]  free:742 slab_reclaimable:12825 slab_unreclaimable:5119
[  237.454790]  mapped:197 shmem:75 pagetables:277 bounce:0
[  237.456183] Node 0 DMA free:1036kB min:120kB low:148kB high:180kB active_anon:572kB inactive_anon:0kB active_file:8kB inactive_file:184kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:96kB writeback:176kB mapped:44kB shmem:0kB slab_reclaimable:13148kB slab_unreclaimable:216kB kernel_stack:8kB pagetables:20kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:288 all_unreclaimable? yes
[  237.457859] lowmem_reserve[]: 0 236 236 236
[  237.458252] Node 0 DMA32 free:1932kB min:1904kB low:2380kB high:2856kB active_anon:16416kB inactive_anon:60kB active_file:996kB inactive_file:2076kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:0kB writeback:116kB mapped:744kB shmem:300kB slab_reclaimable:38152kB slab_unreclaimable:20260kB kernel_stack:1096kB pagetables:1088kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:4678 all_unreclaimable? yes
[  237.459983] lowmem_reserve[]: 0 0 0 0
[  237.460384] Node 0 DMA: 2*4kB 38*8kB 46*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1048kB
[  237.461341] Node 0 DMA32: 79*4kB 173*8kB 4*16kB 3*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1860kB
[  237.462306] 1022 total pagecache pages
[  237.462513] 0 pages in swap cache
[  237.462704] Swap cache stats: add 0, delete 0, find 0/0
[  237.462966] Free swap  = 0kB
[  237.463143] Total swap = 0kB
[  237.463993] 65520 pages RAM
[  237.464176] 16492 pages reserved
[  237.464367] 1204 pages shared
[  237.464545] 46922 pages non-shared
[  237.464741] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  237.465128] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  237.465513] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  237.465897] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  237.466281] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  237.466661] [ 2634]     0  2634     1494       27   0       0             0 getty
[  237.467044] [ 2635]     0  2635     1494       27   0       0             0 getty
[  237.467429] [ 2636]     0  2636     1494       26   0       0             0 getty
[  237.467812] [ 2638]     0  2638     1494       26   0       0             0 getty
[  237.468204] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  237.468585] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  237.469003] [ 2749]     0  2749     3460      290   2       0             0 dd
[  237.469378] [ 2750]     0  2750     3460      289   0       0             0 dd
[  237.469752] [ 2751]     0  2751     3460      289   1       0             0 dd
[  237.470126] [ 2752]     0  2752     3460      290   6       0             0 dd
[  237.470500] [ 2753]     0  2753     3460      290   3       0             0 dd
[  237.470874] [ 2754]     0  2754     3460      289   4       0             0 dd
[  237.471250] [ 2755]     0  2755     3460      289   4       0             0 dd
[  237.471625] [ 2756]     0  2756     3460      290   4       0             0 dd
[  237.471998] [ 2757]     0  2757     3460      290   1       0             0 dd
[  237.472381] [ 2758]     0  2758     3460      290   1       0             0 dd
[  237.472755] [ 2759]     0  2759     3437      171   4       0             0 plot-written.sh
[  237.473169] [ 2776]     0  2776     2144       85   6       0             0 iostat
[  237.473558] [10028]     0 10028     3437      156   0       0             0 plot-written.sh
[  237.473974] [10029]     0 10029     2675      107   0       0             0 grep
[  237.474356] [10030]     0 10030     2611       51   5       0             0 init
[  237.474735] Out of memory: Kill process 2634 (getty) score 1 or sacrifice child
[  237.475112] Killed process 2634 (getty) total-vm:5976kB, anon-rss:104kB, file-rss:4kB
[  237.869084] dd invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  237.869486] dd cpuset=/ mems_allowed=0
[  237.869691] Pid: 2750, comm: dd Not tainted 2.6.37-rc3 #154
[  237.869964] Call Trace:
[  237.870123]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  237.870406]  [<ffffffff81130593>] dump_header+0x83/0x200
[  237.870671]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  237.870952]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  237.871224]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  237.871492]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  237.871769]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  237.872042]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  237.872355]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  237.872644]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  237.872927]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  237.873236]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  237.873549]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  237.873848]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  237.874100]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  237.874373]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  237.874656]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  237.874916]  [<ffffffff81a311d5>] ? __mutex_unlock_slowpath+0xd5/0x170
[  237.875222]  [<ffffffff81a311d5>] ? __mutex_unlock_slowpath+0xd5/0x170
[  237.875525]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  237.875801]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  237.876074]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  237.876341]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  237.876611]  [<ffffffff811bda2c>] ? fsnotify+0x7c/0x2d0
[  237.876867]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  237.877116]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  237.877419]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  237.877673] Mem-Info:
[  237.877820] Node 0 DMA per-cpu:
[  237.878032] CPU    0: hi:    0, btch:   1 usd:   0
[  237.878273] CPU    1: hi:    0, btch:   1 usd:   0
[  237.878515] CPU    2: hi:    0, btch:   1 usd:   0
[  237.878756] CPU    3: hi:    0, btch:   1 usd:   0
[  237.878998] CPU    4: hi:    0, btch:   1 usd:   0
[  237.879819] CPU    5: hi:    0, btch:   1 usd:   0
[  237.880067] CPU    6: hi:    0, btch:   1 usd:   0
[  237.880313] CPU    7: hi:    0, btch:   1 usd:   0
[  237.880567] Node 0 DMA32 per-cpu:
[  237.880801] CPU    0: hi:   90, btch:  15 usd:   8
[  237.881053] CPU    1: hi:   90, btch:  15 usd:  14
[  237.881307] CPU    2: hi:   90, btch:  15 usd:   0
[  237.881558] CPU    3: hi:   90, btch:  15 usd:  36
[  237.881809] CPU    4: hi:   90, btch:  15 usd:   1
[  237.882063] CPU    5: hi:   90, btch:  15 usd:  14
[  237.882312] CPU    6: hi:   90, btch:  15 usd:  77
[  237.882563] CPU    7: hi:   90, btch:  15 usd:   0
[  237.882816] active_anon:4255 inactive_anon:40 isolated_anon:0
[  237.882817]  active_file:170 inactive_file:670 isolated_file:0
[  237.882818]  unevictable:0 dirty:0 writeback:184 unstable:0
[  237.882819]  free:1245 slab_reclaimable:12817 slab_unreclaimable:5088
[  237.882820]  mapped:247 shmem:75 pagetables:302 bounce:0
[  237.884267] Node 0 DMA free:1320kB min:120kB low:148kB high:180kB active_anon:572kB inactive_anon:0kB active_file:0kB inactive_file:164kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:20kB mapped:44kB shmem:0kB slab_reclaimable:13184kB slab_unreclaimable:228kB kernel_stack:8kB pagetables:20kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  237.885936] lowmem_reserve[]: 0 236 236 236
[  237.886326] Node 0 DMA32 free:2604kB min:1904kB low:2380kB high:2856kB active_anon:16448kB inactive_anon:160kB active_file:728kB inactive_file:2228kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:0kB writeback:716kB mapped:944kB shmem:300kB slab_reclaimable:38084kB slab_unreclaimable:20124kB kernel_stack:1096kB pagetables:1188kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  237.888061] lowmem_reserve[]: 0 0 0 0
[  237.888438] Node 0 DMA: 14*4kB 53*8kB 38*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1120kB
[  237.889428] Node 0 DMA32: 217*4kB 178*8kB 8*16kB 2*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2484kB
[  237.890375] 1886 total pagecache pages
[  237.890579] 0 pages in swap cache
[  237.890765] Swap cache stats: add 0, delete 0, find 0/0
[  237.891024] Free swap  = 0kB
[  237.891246] Total swap = 0kB
[  237.891994] 65520 pages RAM
[  237.892162] 16492 pages reserved
[  237.892351] 2506 pages shared
[  237.892526] 45810 pages non-shared
[  237.892745] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  237.893157] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  237.893534] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  237.893909] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  237.894284] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  237.894659] [ 2635]     0  2635     1494       27   0       0             0 getty
[  237.895034] [ 2636]     0  2636     1494       26   0       0             0 getty
[  237.895407] [ 2638]     0  2638     1494       26   0       0             0 getty
[  237.895783] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  237.896153] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  237.896571] [ 2749]     0  2749     3460      288   6       0             0 dd
[  237.896939] [ 2750]     0  2750     3460      286   2       0             0 dd
[  237.897305] [ 2751]     0  2751     3460      286   5       0             0 dd
[  237.897669] [ 2752]     0  2752     3460      287   6       0             0 dd
[  237.898036] [ 2753]     0  2753     3460      288   3       0             0 dd
[  237.898401] [ 2754]     0  2754     3460      287   4       0             0 dd
[  237.898767] [ 2755]     0  2755     3460      286   6       0             0 dd
[  237.899134] [ 2756]     0  2756     3460      287   4       0             0 dd
[  237.899500] [ 2757]     0  2757     3460      288   1       0             0 dd
[  237.899864] [ 2758]     0  2758     3460      287   1       0             0 dd
[  237.900230] [ 2759]     0  2759     3437      160   4       0             0 plot-written.sh
[  237.900641] [ 2776]     0  2776     2144       71   6       0             0 iostat
[  237.901021] [10030]     0 10030     1493      106   0       0             0 getty
[  237.901397] [10031]     0 10031     3437      139   5       0             0 plot-written.sh
[  237.901804] [10033]     0 10033     2137      101   3       0             0 wc
[  237.902170] [10034]     0 10034     1493      106   5       0             0 getty
[  237.902543] Out of memory: Kill process 2635 (getty) score 1 or sacrifice child
[  237.902912] Killed process 2635 (getty) total-vm:5976kB, anon-rss:104kB, file-rss:4kB
[  238.261109] wc invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  238.261533] wc cpuset=/ mems_allowed=0
[  238.261751] Pid: 10033, comm: wc Not tainted 2.6.37-rc3 #154
[  238.262040] Call Trace:
[  238.262208]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  238.262505]  [<ffffffff81130593>] dump_header+0x83/0x200
[  238.262782]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  238.263077]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  238.263363]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  238.263645]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  238.263932]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  238.264214]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  238.264540]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  238.264843]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  238.265134]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  238.265452]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  238.265769]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  238.266073]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  238.266328]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  238.266602]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  238.266890]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  238.267151]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  238.267432]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  238.267709]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  238.268012]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  238.268286]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  238.268556]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  238.268874]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  238.269132] Mem-Info:
[  238.269284] Node 0 DMA per-cpu:
[  238.269504] CPU    0: hi:    0, btch:   1 usd:   0
[  238.269748] CPU    1: hi:    0, btch:   1 usd:   0
[  238.269992] CPU    2: hi:    0, btch:   1 usd:   0
[  238.270235] CPU    3: hi:    0, btch:   1 usd:   0
[  238.270478] CPU    4: hi:    0, btch:   1 usd:   0
[  238.270721] CPU    5: hi:    0, btch:   1 usd:   0
[  238.270962] CPU    6: hi:    0, btch:   1 usd:   0
[  238.271203] CPU    7: hi:    0, btch:   1 usd:   0
[  238.271444] Node 0 DMA32 per-cpu:
[  238.271667] CPU    0: hi:   90, btch:  15 usd:  19
[  238.271909] CPU    1: hi:   90, btch:  15 usd:  76
[  238.272152] CPU    2: hi:   90, btch:  15 usd:  14
[  238.272396] CPU    3: hi:   90, btch:  15 usd:  13
[  238.272649] CPU    4: hi:   90, btch:  15 usd:   0
[  238.272900] CPU    5: hi:   90, btch:  15 usd:   0
[  238.273145] CPU    6: hi:   90, btch:  15 usd:   6
[  238.273389] CPU    7: hi:   90, btch:  15 usd:  13
[  238.273634] active_anon:4240 inactive_anon:21 isolated_anon:0
[  238.273635]  active_file:200 inactive_file:1735 isolated_file:0
[  238.273635]  unevictable:0 dirty:43 writeback:303 unstable:0
[  238.273636]  free:726 slab_reclaimable:12860 slab_unreclaimable:5111
[  238.273636]  mapped:181 shmem:75 pagetables:276 bounce:0
[  238.275034] Node 0 DMA free:1052kB min:120kB low:148kB high:180kB active_anon:568kB inactive_anon:0kB active_file:24kB inactive_file:540kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:224kB mapped:12kB shmem:0kB slab_reclaimable:13168kB slab_unreclaimable:312kB kernel_stack:8kB pagetables:24kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:990 all_unreclaimable? yes
[  238.276718] lowmem_reserve[]: 0 236 236 236
[  238.277129] Node 0 DMA32 free:1852kB min:1904kB low:2380kB high:2856kB active_anon:16392kB inactive_anon:84kB active_file:776kB inactive_file:6400kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:248kB writeback:988kB mapped:712kB shmem:300kB slab_reclaimable:38272kB slab_unreclaimable:20132kB kernel_stack:1088kB pagetables:1080kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:15241 all_unreclaimable? yes
[  238.278917] lowmem_reserve[]: 0 0 0 0
[  238.279307] Node 0 DMA: 13*4kB 45*8kB 43*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1100kB
[  238.280275] Node 0 DMA32: 117*4kB 151*8kB 9*16kB 2*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1884kB
[  238.281262] 1896 total pagecache pages
[  238.281474] 0 pages in swap cache
[  238.281670] Swap cache stats: add 0, delete 0, find 0/0
[  238.281938] Free swap  = 0kB
[  238.282119] Total swap = 0kB
[  238.283135] 65520 pages RAM
[  238.283314] 16492 pages reserved
[  238.283507] 1889 pages shared
[  238.283693] 46297 pages non-shared
[  238.284473] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  238.284883] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  238.285276] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  238.285670] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  238.286067] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  238.286460] [ 2636]     0  2636     1494       26   0       0             0 getty
[  238.286854] [ 2638]     0  2638     1494       26   0       0             0 getty
[  238.287250] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  238.287636] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  238.288064] [ 2749]     0  2749     3460      290   1       0             0 dd
[  238.288536] [ 2750]     0  2750     3460      289   5       0             0 dd
[  238.288921] [ 2751]     0  2751     3460      289   2       0             0 dd
[  238.289305] [ 2752]     0  2752     3460      290   7       0             0 dd
[  238.289689] [ 2753]     0  2753     3460      290   7       0             0 dd
[  238.290074] [ 2754]     0  2754     3460      289   6       0             0 dd
[  238.290458] [ 2755]     0  2755     3460      289   1       0             0 dd
[  238.290840] [ 2756]     0  2756     3460      290   6       0             0 dd
[  238.291224] [ 2757]     0  2757     3460      290   1       0             0 dd
[  238.291612] [ 2758]     0  2758     3460      290   2       0             0 dd
[  238.291997] [ 2759]     0  2759     3437      160   4       0             0 plot-written.sh
[  238.292425] [ 2776]     0  2776     2144       70   6       0             0 iostat
[  238.292833] [10030]     0 10030     1493      108   6       0             0 getty
[  238.293275] [10031]     0 10031     3437      139   5       0             0 plot-written.sh
[  238.293697] [10033]     0 10033     2265      114   4       0             0 wc
[  238.294079] [10034]     0 10034     1493      110   0       0             0 getty
[  238.294474] Out of memory: Kill process 2636 (getty) score 1 or sacrifice child
[  238.294858] Killed process 2636 (getty) total-vm:5976kB, anon-rss:100kB, file-rss:4kB
[  239.413479] date invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  239.413907] date cpuset=/ mems_allowed=0
[  239.414130] Pid: 10040, comm: date Not tainted 2.6.37-rc3 #154
[  239.414426] Call Trace:
[  239.414593]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  239.414890]  [<ffffffff81130593>] dump_header+0x83/0x200
[  239.415166]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  239.415466]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  239.415755]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  239.416038]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  239.416331]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  239.416620]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  239.416941]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  239.417254]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  239.417553]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  239.417878]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  239.418210]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  239.418528]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  239.418849]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  239.419137]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  239.419440]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  239.419713]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  239.419994]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  239.420288]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  239.420580]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  239.420868]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  239.421201]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  239.421468]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  239.421791]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  239.422063] Mem-Info:
[  239.422222] Node 0 DMA per-cpu:
[  239.422451] CPU    0: hi:    0, btch:   1 usd:   0
[  239.422706] CPU    1: hi:    0, btch:   1 usd:   0
[  239.422962] CPU    2: hi:    0, btch:   1 usd:   0
[  239.423218] CPU    3: hi:    0, btch:   1 usd:   0
[  239.423473] CPU    4: hi:    0, btch:   1 usd:   0
[  239.423729] CPU    5: hi:    0, btch:   1 usd:   0
[  239.423985] CPU    6: hi:    0, btch:   1 usd:   0
[  239.424239] CPU    7: hi:    0, btch:   1 usd:   0
[  239.424495] Node 0 DMA32 per-cpu:
[  239.424731] CPU    0: hi:   90, btch:  15 usd:  10
[  239.424988] CPU    1: hi:   90, btch:  15 usd:   7
[  239.425250] CPU    2: hi:   90, btch:  15 usd:   0
[  239.425503] CPU    3: hi:   90, btch:  15 usd:   0
[  239.425757] CPU    4: hi:   90, btch:  15 usd:  14
[  239.426013] CPU    5: hi:   90, btch:  15 usd:   0
[  239.426270] CPU    6: hi:   90, btch:  15 usd:   0
[  239.426524] CPU    7: hi:   90, btch:  15 usd:   0
[  239.426778] active_anon:4253 inactive_anon:0 isolated_anon:0
[  239.426779]  active_file:192 inactive_file:1605 isolated_file:0
[  239.426780]  unevictable:0 dirty:0 writeback:465 unstable:0
[  239.426782]  free:749 slab_reclaimable:12916 slab_unreclaimable:5130
[  239.426783]  mapped:199 shmem:75 pagetables:284 bounce:0
[  239.428281] Node 0 DMA free:1044kB min:120kB low:148kB high:180kB active_anon:564kB inactive_anon:0kB active_file:12kB inactive_file:600kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:16kB shmem:0kB slab_reclaimable:13192kB slab_unreclaimable:324kB kernel_stack:8kB pagetables:24kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1083 all_unreclaimable? yes
[  239.430024] lowmem_reserve[]: 0 236 236 236
[  239.430441] Node 0 DMA32 free:1952kB min:1904kB low:2380kB high:2856kB active_anon:16448kB inactive_anon:0kB active_file:756kB inactive_file:5820kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:0kB writeback:1888kB mapped:780kB shmem:300kB slab_reclaimable:38472kB slab_unreclaimable:20196kB kernel_stack:1096kB pagetables:1112kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:14500 all_unreclaimable? yes
[  239.432254] lowmem_reserve[]: 0 0 0 0
[  239.432648] Node 0 DMA: 2*4kB 39*8kB 45*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1040kB
[  239.433651] Node 0 DMA32: 93*4kB 160*8kB 5*16kB 3*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1828kB
[  239.434660] 1995 total pagecache pages
[  239.434874] 0 pages in swap cache
[  239.435073] Swap cache stats: add 0, delete 0, find 0/0
[  239.435344] Free swap  = 0kB
[  239.435525] Total swap = 0kB
[  239.436391] 65520 pages RAM
[  239.436571] 16492 pages reserved
[  239.436764] 3000 pages shared
[  239.436949] 45889 pages non-shared
[  239.437203] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  239.437607] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  239.438003] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  239.438395] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  239.438790] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  239.439182] [ 2638]     0  2638     1494       26   0       0             0 getty
[  239.439577] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  239.439964] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  239.440392] [ 2749]     0  2749     3460      290   6       0             0 dd
[  239.440777] [ 2750]     0  2750     3460      289   1       0             0 dd
[  239.441222] [ 2751]     0  2751     3460      289   2       0             0 dd
[  239.441609] [ 2752]     0  2752     3460      290   2       0             0 dd
[  239.441991] [ 2753]     0  2753     3460      290   3       0             0 dd
[  239.442370] [ 2754]     0  2754     3460      289   4       0             0 dd
[  239.442752] [ 2755]     0  2755     3460      289   1       0             0 dd
[  239.443137] [ 2756]     0  2756     3460      290   0       0             0 dd
[  239.443518] [ 2757]     0  2757     3460      290   2       0             0 dd
[  239.443896] [ 2758]     0  2758     3460      290   2       0             0 dd
[  239.444267] [ 2759]     0  2759     3437      134   4       0             0 plot-written.sh
[  239.444696] [ 2776]     0  2776     2145       79   5       0             0 iostat
[  239.445107] [10030]     0 10030     1494      103   1       0             0 getty
[  239.446067] [10034]     0 10034     1494      103   0       0             0 getty
[  239.446460] [10035]     0 10035     1493       95   2       0             0 getty
[  239.446855] [10036]     0 10036     1493       95   5       0             0 getty
[  239.447250] [10038]     0 10038     1493       96   4       0             0 getty
[  239.447647] [10040]     0 10040     1485       37   4       0             0 date
[  239.448036] Out of memory: Kill process 2638 (getty) score 1 or sacrifice child
[  239.448417] Killed process 2638 (getty) total-vm:5976kB, anon-rss:100kB, file-rss:4kB
[  239.956444] getty invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  239.956874] getty cpuset=/ mems_allowed=0
[  239.957096] Pid: 10038, comm: getty Not tainted 2.6.37-rc3 #154
[  239.957415] Call Trace:
[  239.957579]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  239.957881]  [<ffffffff81130593>] dump_header+0x83/0x200
[  239.958158]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  239.958453]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  239.958737]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  239.959019]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  239.959309]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  239.959586]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  239.959902]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  239.960203]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  239.960490]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  239.960815]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  239.961141]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  239.961462]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  239.961721]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  239.962010]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  239.962310]  [<ffffffff8112d5a0>] ? find_get_page+0x0/0x110
[  239.962590]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  239.962865]  [<ffffffff81a337d0>] ? restore_args+0x0/0x30
[  239.963138]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  239.963432]  [<ffffffff81a32619>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  239.963753]  [<ffffffff8103d887>] ? do_softirq+0x97/0xe0
[  239.964030]  [<ffffffff81a337d0>] ? restore_args+0x0/0x30
[  239.964312]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  239.964599]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  239.964866]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  239.965190]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  239.965469] Mem-Info:
[  239.965623] Node 0 DMA per-cpu:
[  239.965858] CPU    0: hi:    0, btch:   1 usd:   0
[  239.966114] CPU    1: hi:    0, btch:   1 usd:   0
[  239.966363] CPU    2: hi:    0, btch:   1 usd:   0
[  239.966621] CPU    3: hi:    0, btch:   1 usd:   0
[  239.966877] CPU    4: hi:    0, btch:   1 usd:   0
[  239.967133] CPU    5: hi:    0, btch:   1 usd:   0
[  239.967389] CPU    6: hi:    0, btch:   1 usd:   0
[  239.967638] CPU    7: hi:    0, btch:   1 usd:   0
[  239.967896] Node 0 DMA32 per-cpu:
[  239.968134] CPU    0: hi:   90, btch:  15 usd:   0
[  239.968392] CPU    1: hi:   90, btch:  15 usd:   0
[  239.968649] CPU    2: hi:   90, btch:  15 usd:   0
[  239.968899] CPU    3: hi:   90, btch:  15 usd:  14
[  239.969157] CPU    4: hi:   90, btch:  15 usd:   0
[  239.969414] CPU    5: hi:   90, btch:  15 usd:   0
[  239.969673] CPU    6: hi:   90, btch:  15 usd:   0
[  239.969929] CPU    7: hi:   90, btch:  15 usd:   0
[  239.970188] active_anon:4249 inactive_anon:13 isolated_anon:0
[  239.970189]  active_file:192 inactive_file:1679 isolated_file:32
[  239.970190]  unevictable:0 dirty:38 writeback:353 unstable:0
[  239.970191]  free:700 slab_reclaimable:12933 slab_unreclaimable:5138
[  239.970192]  mapped:174 shmem:75 pagetables:309 bounce:0
[  239.971636] Node 0 DMA free:1044kB min:120kB low:148kB high:180kB active_anon:564kB inactive_anon:0kB active_file:12kB inactive_file:520kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:52kB writeback:24kB mapped:16kB shmem:0kB slab_reclaimable:13192kB slab_unreclaimable:288kB kernel_stack:8kB pagetables:24kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:812 all_unreclaimable? yes
[  239.973367] lowmem_reserve[]: 0 236 236 236
[  239.973784] Node 0 DMA32 free:1872kB min:1904kB low:2380kB high:2856kB active_anon:16432kB inactive_anon:52kB active_file:756kB inactive_file:6196kB unevictable:0kB isolated(anon):0kB isolated(file):128kB present:242400kB mlocked:0kB dirty:100kB writeback:1388kB mapped:680kB shmem:300kB slab_reclaimable:38540kB slab_unreclaimable:20264kB kernel_stack:1096kB pagetables:1212kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:16855 all_unreclaimable? yes
[  239.975606] lowmem_reserve[]: 0 0 0 0
[  239.976013] Node 0 DMA: 5*4kB 74*8kB 26*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1028kB
[  239.977021] Node 0 DMA32: 110*4kB 157*8kB 7*16kB 2*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1872kB
[  239.978059] 2132 total pagecache pages
[  239.978277] 0 pages in swap cache
[  239.978471] Swap cache stats: add 0, delete 0, find 0/0
[  239.978745] Free swap  = 0kB
[  239.978929] Total swap = 0kB
[  239.979822] 65520 pages RAM
[  239.979997] 16492 pages reserved
[  239.980195] 3174 pages shared
[  239.980381] 45788 pages non-shared
[  239.980577] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  239.980972] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  239.981372] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  239.981765] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  239.982158] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  239.982547] [ 2692]     0  2692    11425      554   0       0             0 zsh
[  239.982933] [ 2720]     0  2720     3431       63   4       0             0 concurrent-dd.s
[  239.983359] [ 2749]     0  2749     3460      290   7       0             0 dd
[  239.983741] [ 2750]     0  2750     3460      289   5       0             0 dd
[  239.984123] [ 2751]     0  2751     3460      289   5       0             0 dd
[  239.984505] [ 2752]     0  2752     3460      290   3       0             0 dd
[  239.984887] [ 2753]     0  2753     3460      290   1       0             0 dd
[  239.985270] [ 2754]     0  2754     3460      289   7       0             0 dd
[  239.985660] [ 2755]     0  2755     3460      289   5       0             0 dd
[  239.986042] [ 2756]     0  2756     3460      290   4       0             0 dd
[  239.986425] [ 2757]     0  2757     3460      290   2       0             0 dd
[  239.986807] [ 2758]     0  2758     3460      290   2       0             0 dd
[  239.987189] [ 2759]     0  2759     3437      134   4       0             0 plot-written.sh
[  239.987614] [ 2776]     0  2776     2145       79   5       0             0 iostat
[  239.988013] [10030]     0 10030     1494      103   1       0             0 getty
[  239.988404] [10034]     0 10034     1494      103   0       0             0 getty
[  239.988796] [10035]     0 10035     1622      106   0       0             0 getty
[  239.989189] [10036]     0 10036     1494      114   5       0             0 getty
[  239.989589] [10038]     0 10038     1621      106   0       0             0 getty
[  239.989980] [10040]     0 10040     3202      115   2       0             0 date
[  239.990368] [10041]     0 10041     1493      104   7       0             0 getty
[  239.990759] Out of memory: Kill process 2692 (zsh) score 1 or sacrifice child
[  239.991107] Killed process 2720 (concurrent-dd.s) total-vm:13724kB, anon-rss:248kB, file-rss:4kB
[  240.414356] zsh invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  240.414762] zsh cpuset=/ mems_allowed=0
[  240.414971] Pid: 2692, comm: zsh Not tainted 2.6.37-rc3 #154
[  240.415247] Call Trace:
[  240.415409]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  240.415697]  [<ffffffff81130593>] dump_header+0x83/0x200
[  240.415959]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  240.416240]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  240.416511]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  240.416782]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  240.417058]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  240.417332]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  240.417652]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  240.417942]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  240.418224]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  240.418534]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  240.418847]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  240.419148]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  240.419401]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  240.419672]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  240.419957]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  240.420217]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  240.420496]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  240.420769]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  240.421067]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  240.421337]  [<ffffffff81089ce7>] ? do_wait+0x1f7/0x250
[  240.421603]  [<ffffffff81196c9d>] ? do_vfs_ioctl+0x9d/0x5a0
[  240.422449]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  240.422703]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  240.423011]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  240.423268] Mem-Info:
[  240.423418] Node 0 DMA per-cpu:
[  240.423634] CPU    0: hi:    0, btch:   1 usd:   0
[  240.423876] CPU    1: hi:    0, btch:   1 usd:   0
[  240.424119] CPU    2: hi:    0, btch:   1 usd:   0
[  240.424363] CPU    3: hi:    0, btch:   1 usd:   0
[  240.424606] CPU    4: hi:    0, btch:   1 usd:   0
[  240.424849] CPU    5: hi:    0, btch:   1 usd:   0
[  240.425091] CPU    6: hi:    0, btch:   1 usd:   0
[  240.425335] CPU    7: hi:    0, btch:   1 usd:   0
[  240.425585] Node 0 DMA32 per-cpu:
[  240.425807] CPU    0: hi:   90, btch:  15 usd:   0
[  240.426051] CPU    1: hi:   90, btch:  15 usd:   0
[  240.426293] CPU    2: hi:   90, btch:  15 usd:  14
[  240.426536] CPU    3: hi:   90, btch:  15 usd:   0
[  240.426778] CPU    4: hi:   90, btch:  15 usd:  87
[  240.427021] CPU    5: hi:   90, btch:  15 usd:   0
[  240.427265] CPU    6: hi:   90, btch:  15 usd:  88
[  240.427508] CPU    7: hi:   90, btch:  15 usd:   0
[  240.427752] active_anon:4218 inactive_anon:0 isolated_anon:0
[  240.427753]  active_file:84 inactive_file:662 isolated_file:0
[  240.427753]  unevictable:0 dirty:0 writeback:484 unstable:0
[  240.427754]  free:1812 slab_reclaimable:12954 slab_unreclaimable:5122
[  240.427754]  mapped:86 shmem:75 pagetables:273 bounce:0
[  240.429138] Node 0 DMA free:1072kB min:120kB low:148kB high:180kB active_anon:584kB inactive_anon:0kB active_file:20kB inactive_file:524kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:300kB mapped:8kB shmem:0kB slab_reclaimable:13196kB slab_unreclaimable:324kB kernel_stack:8kB pagetables:32kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:198 all_unreclaimable? no
[  240.430797] lowmem_reserve[]: 0 236 236 236
[  240.431185] Node 0 DMA32 free:6176kB min:1904kB low:2380kB high:2856kB active_anon:16288kB inactive_anon:0kB active_file:316kB inactive_file:2124kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:0kB writeback:1636kB mapped:336kB shmem:300kB slab_reclaimable:38620kB slab_unreclaimable:20164kB kernel_stack:1096kB pagetables:1060kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1127 all_unreclaimable? no
[  240.432923] lowmem_reserve[]: 0 0 0 0
[  240.433292] Node 0 DMA: 19*4kB 72*8kB 27*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1084kB
[  240.434290] Node 0 DMA32: 155*4kB 226*8kB 8*16kB 2*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2620kB
[  240.435236] 989 total pagecache pages
[  240.435436] 0 pages in swap cache
[  240.435624] Swap cache stats: add 0, delete 0, find 0/0
[  240.435881] Free swap  = 0kB
[  240.436053] Total swap = 0kB
[  240.436840] 65520 pages RAM
[  240.437011] 16492 pages reserved
[  240.437193] 1663 pages shared
[  240.437368] 46900 pages non-shared
[  240.437567] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  240.437948] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  240.438324] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  240.438700] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  240.439073] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  240.439442] [ 2692]     0  2692    11425      564   3       0             0 zsh
[  240.439811] [ 2749]     0  2749     3460      288   4       0             0 dd
[  240.440178] [ 2750]     0  2750     3460      287   6       0             0 dd
[  240.440543] [ 2751]     0  2751     3460      287   1       0             0 dd
[  240.440908] [ 2752]     0  2752     3460      288   5       0             0 dd
[  240.441274] [ 2753]     0  2753     3460      288   1       0             0 dd
[  240.441646] [ 2754]     0  2754     3460      287   6       0             0 dd
[  240.442011] [ 2755]     0  2755     3460      287   6       0             0 dd
[  240.442376] [ 2756]     0  2756     3460      288   5       0             0 dd
[  240.442741] [ 2757]     0  2757     3460      288   3       0             0 dd
[  240.443105] [ 2758]     0  2758     3460      288   6       0             0 dd
[  240.443470] [ 2759]     0  2759     3437      117   4       0             0 plot-written.sh
[  240.443878] [ 2776]     0  2776     2145       55   4       0             0 iostat
[  240.444256] [10030]     0 10030     1494       46   1       0             0 getty
[  240.444631] [10034]     0 10034     1494       46   0       0             0 getty
[  240.445005] [10035]     0 10035     1494       56   4       0             0 getty
[  240.445380] [10036]     0 10036     1494       55   5       0             0 getty
[  240.445762] [10038]     0 10038     1494       57   1       0             0 getty
[  240.446136] [10040]     0 10040     3330       70   5       0             0 date
[  240.446505] [10041]     0 10041     1493       60   0       0             0 getty
[  240.446874] Out of memory: Kill process 2692 (zsh) score 1 or sacrifice child
[  240.447202] Killed process 2692 (zsh) total-vm:45700kB, anon-rss:2212kB, file-rss:44kB
[  247.945070] date invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  247.945502] date cpuset=/ mems_allowed=0
[  247.945725] Pid: 10248, comm: date Not tainted 2.6.37-rc3 #154
[  247.946023] Call Trace:
[  247.946191]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  247.946490]  [<ffffffff81130593>] dump_header+0x83/0x200
[  247.946768]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  247.947066]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  247.947352]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  247.947634]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  247.947927]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  247.948216]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  247.948535]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  247.948835]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  247.949144]  [<ffffffff8112f717>] filemap_fault+0x1d7/0x4f0
[  247.949433]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  247.949708]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  247.950001]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  247.950291]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  247.950580]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  247.950896]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  247.951162]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  247.951484]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  247.951751] Mem-Info:
[  247.951909] Node 0 DMA per-cpu:
[  247.952137] CPU    0: hi:    0, btch:   1 usd:   0
[  247.952393] CPU    1: hi:    0, btch:   1 usd:   0
[  247.952645] CPU    2: hi:    0, btch:   1 usd:   0
[  247.952897] CPU    3: hi:    0, btch:   1 usd:   0
[  247.953157] CPU    4: hi:    0, btch:   1 usd:   0
[  247.953411] CPU    5: hi:    0, btch:   1 usd:   0
[  247.953668] CPU    6: hi:    0, btch:   1 usd:   0
[  247.953921] CPU    7: hi:    0, btch:   1 usd:   0
[  247.954176] Node 0 DMA32 per-cpu:
[  247.954409] CPU    0: hi:   90, btch:  15 usd:   1
[  247.954666] CPU    1: hi:   90, btch:  15 usd:   0
[  247.954923] CPU    2: hi:   90, btch:  15 usd:   0
[  247.955178] CPU    3: hi:   90, btch:  15 usd:  14
[  247.955433] CPU    4: hi:   90, btch:  15 usd:  20
[  247.955688] CPU    5: hi:   90, btch:  15 usd:  77
[  247.955944] CPU    6: hi:   90, btch:  15 usd:  25
[  247.956200] CPU    7: hi:   90, btch:  15 usd:   0
[  247.956450] active_anon:3680 inactive_anon:42 isolated_anon:0
[  247.956452]  active_file:142 inactive_file:1673 isolated_file:0
[  247.956453]  unevictable:0 dirty:0 writeback:199 unstable:0
[  247.956454]  free:751 slab_reclaimable:13557 slab_unreclaimable:5125
[  247.956455]  mapped:139 shmem:75 pagetables:260 bounce:0
[  247.957919] Node 0 DMA free:1048kB min:120kB low:148kB high:180kB active_anon:576kB inactive_anon:0kB active_file:12kB inactive_file:476kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:13304kB slab_unreclaimable:252kB kernel_stack:16kB pagetables:32kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:802 all_unreclaimable? yes
[  247.959713] lowmem_reserve[]: 0 236 236 236
[  247.960130] Node 0 DMA32 free:1956kB min:1904kB low:2380kB high:2856kB active_anon:14144kB inactive_anon:168kB active_file:556kB inactive_file:6216kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:0kB writeback:844kB mapped:568kB shmem:300kB slab_reclaimable:40924kB slab_unreclaimable:20248kB kernel_stack:1080kB pagetables:1008kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:12451 all_unreclaimable? yes
[  247.961965] lowmem_reserve[]: 0 0 0 0
[  247.962356] Node 0 DMA: 1*4kB 54*8kB 45*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1156kB
[  247.963350] Node 0 DMA32: 108*4kB 147*8kB 7*16kB 4*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1848kB
[  247.964353] 2006 total pagecache pages
[  247.964568] 0 pages in swap cache
[  247.964766] Swap cache stats: add 0, delete 0, find 0/0
[  247.965045] Free swap  = 0kB
[  247.965228] Total swap = 0kB
[  247.966122] 65520 pages RAM
[  247.966302] 16492 pages reserved
[  247.967066] 2455 pages shared
[  247.967251] 45714 pages non-shared
[  247.967450] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  247.967851] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  247.968245] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  247.968642] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  247.969036] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  247.969434] [ 2749]     0  2749     3460      290   6       0             0 dd
[  247.969820] [ 2750]     0  2750     3460      289   1       0             0 dd
[  247.970205] [ 2751]     0  2751     3460      289   0       0             0 dd
[  247.970588] [ 2752]     0  2752     3460      290   6       0             0 dd
[  247.970971] [ 2753]     0  2753     3460      290   5       0             0 dd
[  247.971357] [ 2754]     0  2754     3460      289   6       0             0 dd
[  247.971740] [ 2755]     0  2755     3460      289   2       0             0 dd
[  247.972125] [ 2756]     0  2756     3460      290   5       0             0 dd
[  247.972511] [ 2757]     0  2757     3460      290   0       0             0 dd
[  247.972893] [ 2758]     0  2758     3460      290   0       0             0 dd
[  247.973284] [ 2759]     0  2759     3437      137   1       0             0 plot-written.sh
[  247.973711] [ 2776]     0  2776     2144       82   1       0             0 iostat
[  247.974109] [10030]     0 10030     1494       26   1       0             0 getty
[  247.974501] [10034]     0 10034     1494       26   0       0             0 getty
[  247.974888] [10035]     0 10035     1494       26   4       0             0 getty
[  247.975279] [10036]     0 10036     1494       26   5       0             0 getty
[  247.975672] [10038]     0 10038     1494       27   1       0             0 getty
[  247.976065] [10041]     0 10041     1494       29   4       0             0 getty
[  247.976460] [10248]     0 10248     3202       70   4       0             0 date
[  247.976851] Out of memory: Kill process 2749 (dd) score 1 or sacrifice child
[  247.977202] Killed process 2749 (dd) total-vm:13840kB, anon-rss:1140kB, file-rss:20kB
[  247.977652] dd: page allocation failure. order:0, mode:0x2005a
[  247.977947] Pid: 2749, comm: dd Not tainted 2.6.37-rc3 #154
[  247.978227] Call Trace:
[  247.978393]  [<ffffffff81136500>] __alloc_pages_nodemask+0x680/0x830
[  247.978703]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  247.979002]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  247.979292]  [<ffffffff8112ddcf>] grab_cache_page_write_begin+0x7f/0xc0
[  247.979612]  [<ffffffff8121de03>] ext4_da_write_begin+0x143/0x280
[  247.979911]  [<ffffffff8112cb19>] generic_file_buffered_write+0x109/0x260
[  247.980238]  [<ffffffff8121fdd4>] ? ext4_dirty_inode+0x54/0x60
[  247.980530]  [<ffffffff81a31030>] ? mutex_lock_nested+0x280/0x350
[  247.980829]  [<ffffffff8112e994>] __generic_file_aio_write+0x244/0x450
[  247.981161]  [<ffffffff81a31042>] ? mutex_lock_nested+0x292/0x350
[  247.981462]  [<ffffffff8112ebf8>] ? generic_file_aio_write+0x58/0xd0
[  247.981771]  [<ffffffff8112ebf8>] ? generic_file_aio_write+0x58/0xd0
[  247.982080]  [<ffffffff8112ec0b>] generic_file_aio_write+0x6b/0xd0
[  247.982385]  [<ffffffff812142b2>] ext4_file_write+0x42/0xc0
[  247.982665]  [<ffffffff8118586a>] do_sync_write+0xda/0x120
[  247.982940]  [<ffffffff8114ce75>] ? might_fault+0xa5/0xb0
[  247.983216]  [<ffffffff814ab385>] ? read_zero+0xe5/0x120
[  247.983487]  [<ffffffff81185fee>] vfs_write+0xce/0x190
[  247.983750]  [<ffffffff81186324>] sys_write+0x54/0x90
[  247.984008]  [<ffffffff8103afb2>] system_call_fastpath+0x16/0x1b
[  247.984304] Mem-Info:
[  247.984458] Node 0 DMA per-cpu:
[  247.984682] CPU    0: hi:    0, btch:   1 usd:   0
[  247.984930] CPU    1: hi:    0, btch:   1 usd:   0
[  247.985187] CPU    2: hi:    0, btch:   1 usd:   0
[  247.985436] CPU    3: hi:    0, btch:   1 usd:   0
[  247.985687] CPU    4: hi:    0, btch:   1 usd:   0
[  247.985936] CPU    5: hi:    0, btch:   1 usd:   0
[  247.986184] CPU    6: hi:    0, btch:   1 usd:   0
[  247.986434] CPU    7: hi:    0, btch:   1 usd:   0
[  247.986683] Node 0 DMA32 per-cpu:
[  247.986912] CPU    0: hi:   90, btch:  15 usd:   1
[  247.987159] CPU    1: hi:   90, btch:  15 usd:   0
[  247.987407] CPU    2: hi:   90, btch:  15 usd:   0
[  247.987658] CPU    3: hi:   90, btch:  15 usd:  14
[  247.987906] CPU    4: hi:   90, btch:  15 usd:  20
[  247.988154] CPU    5: hi:   90, btch:  15 usd:  77
[  247.988402] CPU    6: hi:   90, btch:  15 usd:  25
[  247.988651] CPU    7: hi:   90, btch:  15 usd:   0
[  247.988903] active_anon:3680 inactive_anon:42 isolated_anon:0
[  247.988904]  active_file:142 inactive_file:1673 isolated_file:0
[  247.988905]  unevictable:0 dirty:0 writeback:99 unstable:0
[  247.988906]  free:751 slab_reclaimable:13557 slab_unreclaimable:5125
[  247.988907]  mapped:139 shmem:75 pagetables:260 bounce:0
[  247.990386] Node 0 DMA free:1048kB min:120kB low:148kB high:180kB active_anon:576kB inactive_anon:0kB active_file:12kB inactive_file:476kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:13304kB slab_unreclaimable:252kB kernel_stack:16kB pagetables:32kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:802 all_unreclaimable? yes
[  247.992091] lowmem_reserve[]: 0 236 236 236
[  247.992496] Node 0 DMA32 free:1956kB min:1904kB low:2380kB high:2856kB active_anon:14144kB inactive_anon:168kB active_file:556kB inactive_file:6216kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:0kB writeback:444kB mapped:568kB shmem:300kB slab_reclaimable:40924kB slab_unreclaimable:20248kB kernel_stack:1080kB pagetables:1008kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:12451 all_unreclaimable? yes
[  247.994300] lowmem_reserve[]: 0 0 0 0
[  247.994687] Node 0 DMA: 1*4kB 54*8kB 45*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1156kB
[  247.995656] Node 0 DMA32: 108*4kB 147*8kB 7*16kB 4*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1848kB
[  247.996688] 2006 total pagecache pages
[  247.996898] 0 pages in swap cache
[  247.997133] Swap cache stats: add 0, delete 0, find 0/0
[  247.997398] Free swap  = 0kB
[  247.997575] Total swap = 0kB
[  247.998351] 65520 pages RAM
[  247.998527] 16492 pages reserved
[  247.998717] 2335 pages shared
[  247.998898] 45714 pages non-shared
[  248.259785] date invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  248.260191] date cpuset=/ mems_allowed=0
[  248.260401] Pid: 10248, comm: date Not tainted 2.6.37-rc3 #154
[  248.260682] Call Trace:
[  248.260843]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  248.261126]  [<ffffffff81130593>] dump_header+0x83/0x200
[  248.261405]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  248.261689]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  248.261961]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  248.262230]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  248.262508]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  248.262781]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  248.263084]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  248.263373]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  248.263656]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  248.263966]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  248.264280]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  248.264582]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  248.264835]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  248.265107]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  248.265442]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  248.265702]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  248.265968]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  248.266248]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  248.266523]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  248.266825]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  248.267096]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  248.267362]  [<ffffffff810bb929>] ? trace_hardirqs_off_caller+0x29/0x150
[  248.267676]  [<ffffffff810bba5d>] ? trace_hardirqs_off+0xd/0x10
[  248.267961]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  248.268227]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  248.268479]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  248.268786]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  248.269043] Mem-Info:
[  248.269242] Node 0 DMA per-cpu:
[  248.269460] CPU    0: hi:    0, btch:   1 usd:   0
[  248.269703] CPU    1: hi:    0, btch:   1 usd:   0
[  248.269947] CPU    2: hi:    0, btch:   1 usd:   0
[  248.270186] CPU    3: hi:    0, btch:   1 usd:   0
[  248.270426] CPU    4: hi:    0, btch:   1 usd:   0
[  248.270666] CPU    5: hi:    0, btch:   1 usd:   0
[  248.270906] CPU    6: hi:    0, btch:   1 usd:   0
[  248.271146] CPU    7: hi:    0, btch:   1 usd:   0
[  248.271387] Node 0 DMA32 per-cpu:
[  248.271606] CPU    0: hi:   90, btch:  15 usd:  15
[  248.271847] CPU    1: hi:   90, btch:  15 usd:   0
[  248.272088] CPU    2: hi:   90, btch:  15 usd:  14
[  248.272328] CPU    3: hi:   90, btch:  15 usd:  10
[  248.272569] CPU    4: hi:   90, btch:  15 usd:   0
[  248.272810] CPU    5: hi:   90, btch:  15 usd:   0
[  248.273050] CPU    6: hi:   90, btch:  15 usd:   0
[  248.273342] CPU    7: hi:   90, btch:  15 usd:   0
[  248.274149] active_anon:3376 inactive_anon:12 isolated_anon:0
[  248.274150]  active_file:157 inactive_file:2089 isolated_file:0
[  248.274150]  unevictable:0 dirty:24 writeback:603 unstable:0
[  248.274151]  free:726 slab_reclaimable:13593 slab_unreclaimable:5131
[  248.274151]  mapped:128 shmem:75 pagetables:238 bounce:0
[  248.275553] Node 0 DMA free:1052kB min:120kB low:148kB high:180kB active_anon:568kB inactive_anon:0kB active_file:12kB inactive_file:616kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:48kB writeback:136kB mapped:4kB shmem:0kB slab_reclaimable:13296kB slab_unreclaimable:252kB kernel_stack:8kB pagetables:32kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1000 all_unreclaimable? yes
[  248.277365] lowmem_reserve[]: 0 236 236 236
[  248.277751] Node 0 DMA32 free:1852kB min:1904kB low:2380kB high:2856kB active_anon:12936kB inactive_anon:48kB active_file:616kB inactive_file:7740kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:48kB writeback:1776kB mapped:508kB shmem:300kB slab_reclaimable:41076kB slab_unreclaimable:20272kB kernel_stack:1072kB pagetables:920kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:12633 all_unreclaimable? yes
[  248.279490] lowmem_reserve[]: 0 0 0 0
[  248.279860] Node 0 DMA: 7*4kB 39*8kB 45*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1060kB
[  248.280795] Node 0 DMA32: 122*4kB 118*8kB 16*16kB 6*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1880kB
[  248.281822] 2409 total pagecache pages
[  248.282030] 0 pages in swap cache
[  248.282224] Swap cache stats: add 0, delete 0, find 0/0
[  248.282488] Free swap  = 0kB
[  248.282664] Total swap = 0kB
[  248.283515] 65520 pages RAM
[  248.283689] 16492 pages reserved
[  248.283878] 1944 pages shared
[  248.284057] 46568 pages non-shared
[  248.284252] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  248.284636] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  248.285019] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  248.285457] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  248.285867] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  248.286274] [ 2750]     0  2750     3460      289   3       0             0 dd
[  248.286673] [ 2751]     0  2751     3460      289   1       0             0 dd
[  248.287046] [ 2752]     0  2752     3460      290   6       0             0 dd
[  248.287418] [ 2753]     0  2753     3460      290   5       0             0 dd
[  248.287792] [ 2754]     0  2754     3460      289   6       0             0 dd
[  248.288164] [ 2755]     0  2755     3460      289   2       0             0 dd
[  248.288538] [ 2756]     0  2756     3460      290   1       0             0 dd
[  248.288912] [ 2757]     0  2757     3460      290   4       0             0 dd
[  248.289340] [ 2758]     0  2758     3460      290   7       0             0 dd
[  248.289714] [ 2759]     0  2759     3437      136   1       0             0 plot-written.sh
[  248.290130] [ 2776]     0  2776     2144       82   1       0             0 iostat
[  248.290519] [10030]     0 10030     1494       26   1       0             0 getty
[  248.290901] [10034]     0 10034     1494       26   0       0             0 getty
[  248.291284] [10035]     0 10035     1494       26   4       0             0 getty
[  248.291667] [10036]     0 10036     1494       26   5       0             0 getty
[  248.292051] [10038]     0 10038     1494       27   1       0             0 getty
[  248.292433] [10041]     0 10041     1494       29   4       0             0 getty
[  248.292816] [10248]     0 10248     3202       75   1       0             0 date
[  248.293247] Out of memory: Kill process 2750 (dd) score 1 or sacrifice child
[  248.293580] Killed process 2750 (dd) total-vm:13840kB, anon-rss:1136kB, file-rss:20kB
[  251.665672] sleep invoked oom-killer: gfp_mask=0x84d0, order=0, oom_adj=0, oom_score_adj=0
[  251.666091] sleep cpuset=/ mems_allowed=0
[  251.666314] Pid: 10269, comm: sleep Not tainted 2.6.37-rc3 #154
[  251.666606] Call Trace:
[  251.666768]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  251.667072]  [<ffffffff81130593>] dump_header+0x83/0x200
[  251.667341]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  251.667623]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  251.667894]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  251.668162]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  251.668439]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  251.668712]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  251.669012]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  251.669300]  [<ffffffff8106934b>] pte_alloc_one+0x1b/0x40
[  251.669566]  [<ffffffff8114df1f>] __pte_alloc+0x2f/0xf0
[  251.669825]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  251.670089]  [<ffffffff811509d7>] handle_mm_fault+0xa97/0xc20
[  251.670367]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  251.670641]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  251.670921]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  251.671188]  [<ffffffff810bb929>] ? trace_hardirqs_off_caller+0x29/0x150
[  251.671499]  [<ffffffff810bba5d>] ? trace_hardirqs_off+0xd/0x10
[  251.671785]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  251.672055]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  251.672307]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  251.672615]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  251.672872] Mem-Info:
[  251.673024] Node 0 DMA per-cpu:
[  251.673243] CPU    0: hi:    0, btch:   1 usd:   0
[  251.673489] CPU    1: hi:    0, btch:   1 usd:   0
[  251.673733] CPU    2: hi:    0, btch:   1 usd:   0
[  251.673974] CPU    3: hi:    0, btch:   1 usd:   0
[  251.674215] CPU    4: hi:    0, btch:   1 usd:   0
[  251.674456] CPU    5: hi:    0, btch:   1 usd:   0
[  251.674699] CPU    6: hi:    0, btch:   1 usd:   0
[  251.674948] CPU    7: hi:    0, btch:   1 usd:   0
[  251.675191] Node 0 DMA32 per-cpu:
[  251.675413] CPU    0: hi:   90, btch:  15 usd:  18
[  251.675655] CPU    1: hi:   90, btch:  15 usd:  27
[  251.675897] CPU    2: hi:   90, btch:  15 usd:  22
[  251.676138] CPU    3: hi:   90, btch:  15 usd:   0
[  251.676380] CPU    4: hi:   90, btch:  15 usd:   0
[  251.676624] CPU    5: hi:   90, btch:  15 usd:   1
[  251.676872] CPU    6: hi:   90, btch:  15 usd:  29
[  251.677117] CPU    7: hi:   90, btch:  15 usd:  12
[  251.677363] active_anon:3075 inactive_anon:35 isolated_anon:0
[  251.677363]  active_file:236 inactive_file:2005 isolated_file:0
[  251.677364]  unevictable:0 dirty:212 writeback:0 unstable:0
[  251.677365]  free:770 slab_reclaimable:13787 slab_unreclaimable:5155
[  251.677365]  mapped:180 shmem:75 pagetables:223 bounce:0
[  251.678759] Node 0 DMA free:1060kB min:120kB low:148kB high:180kB active_anon:572kB inactive_anon:0kB active_file:12kB inactive_file:552kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:13260kB slab_unreclaimable:252kB kernel_stack:8kB pagetables:32kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1419 all_unreclaimable? yes
[  251.680436] lowmem_reserve[]: 0 236 236 236
[  251.680834] Node 0 DMA32 free:2020kB min:1904kB low:2380kB high:2856kB active_anon:11728kB inactive_anon:140kB active_file:932kB inactive_file:7468kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:848kB writeback:0kB mapped:720kB shmem:300kB slab_reclaimable:41888kB slab_unreclaimable:20368kB kernel_stack:1064kB pagetables:860kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:26694 all_unreclaimable? yes
[  251.682579] lowmem_reserve[]: 0 0 0 0
[  251.682963] Node 0 DMA: 2*4kB 38*8kB 45*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1064kB
[  251.683914] Node 0 DMA32: 191*4kB 88*8kB 24*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1884kB
[  251.684877] 2396 total pagecache pages
[  251.685082] 0 pages in swap cache
[  251.685272] Swap cache stats: add 0, delete 0, find 0/0
[  251.685531] Free swap  = 0kB
[  251.685704] Total swap = 0kB
[  251.686473] 65520 pages RAM
[  251.686643] 16492 pages reserved
[  251.686838] 1452 pages shared
[  251.687016] 46496 pages non-shared
[  251.687209] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  251.687587] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  251.687963] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  251.688339] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  251.688716] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  251.689090] [ 2751]     0  2751     3460      289   3       0             0 dd
[  251.689458] [ 2752]     0  2752     3460      290   1       0             0 dd
[  251.689824] [ 2753]     0  2753     3460      290   6       0             0 dd
[  251.690190] [ 2754]     0  2754     3460      289   2       0             0 dd
[  251.690556] [ 2755]     0  2755     3460      289   5       0             0 dd
[  251.690931] [ 2756]     0  2756     3460      290   6       0             0 dd
[  251.691873] [ 2757]     0  2757     3460      290   6       0             0 dd
[  251.692239] [ 2758]     0  2758     3460      290   5       0             0 dd
[  251.692605] [ 2759]     0  2759     3437      175   0       0             0 plot-written.sh
[  251.693013] [ 2776]     0  2776     2144       91   1       0             0 iostat
[  251.693392] [10030]     0 10030     1494       26   1       0             0 getty
[  251.693769] [10034]     0 10034     1494       26   0       0             0 getty
[  251.694145] [10035]     0 10035     1494       26   4       0             0 getty
[  251.694521] [10036]     0 10036     1494       26   5       0             0 getty
[  251.694914] [10038]     0 10038     1494       27   1       0             0 getty
[  251.695291] [10041]     0 10041     1494       29   4       0             0 getty
[  251.695668] [10269]     0 10269     2135       88   4       0             0 sleep
[  251.696043] Out of memory: Kill process 2751 (dd) score 1 or sacrifice child
[  251.696372] Killed process 2751 (dd) total-vm:13840kB, anon-rss:1136kB, file-rss:20kB
[  251.696805] dd: page allocation failure. order:0, mode:0x2005a
[  251.697098] Pid: 2751, comm: dd Not tainted 2.6.37-rc3 #154
[  251.697376] Call Trace:
[  251.697541]  [<ffffffff81136500>] __alloc_pages_nodemask+0x680/0x830
[  251.697852]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  251.698149]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  251.698439]  [<ffffffff8112ddcf>] grab_cache_page_write_begin+0x7f/0xc0
[  251.698757]  [<ffffffff8121de03>] ext4_da_write_begin+0x143/0x280
[  251.699067]  [<ffffffff8112cb19>] generic_file_buffered_write+0x109/0x260
[  251.699394]  [<ffffffff8121fdd4>] ? ext4_dirty_inode+0x54/0x60
[  251.699686]  [<ffffffff81a31030>] ? mutex_lock_nested+0x280/0x350
[  251.699984]  [<ffffffff8112e994>] __generic_file_aio_write+0x244/0x450
[  251.700301]  [<ffffffff81a31042>] ? mutex_lock_nested+0x292/0x350
[  251.700600]  [<ffffffff8112ebf8>] ? generic_file_aio_write+0x58/0xd0
[  251.700909]  [<ffffffff8112ebf8>] ? generic_file_aio_write+0x58/0xd0
[  251.701218]  [<ffffffff8112ec0b>] generic_file_aio_write+0x6b/0xd0
[  251.701521]  [<ffffffff812142b2>] ext4_file_write+0x42/0xc0
[  251.701801]  [<ffffffff8118586a>] do_sync_write+0xda/0x120
[  251.702077]  [<ffffffff8114ce75>] ? might_fault+0xa5/0xb0
[  251.702352]  [<ffffffff814ab385>] ? read_zero+0xe5/0x120
[  251.702622]  [<ffffffff81185fee>] vfs_write+0xce/0x190
[  251.702901]  [<ffffffff81186324>] sys_write+0x54/0x90
[  251.703162]  [<ffffffff8103afb2>] system_call_fastpath+0x16/0x1b
[  251.703457] Mem-Info:
[  251.703612] Node 0 DMA per-cpu:
[  251.703835] CPU    0: hi:    0, btch:   1 usd:   0
[  251.704084] CPU    1: hi:    0, btch:   1 usd:   0
[  251.704334] CPU    2: hi:    0, btch:   1 usd:   0
[  251.704584] CPU    3: hi:    0, btch:   1 usd:   0
[  251.704833] CPU    4: hi:    0, btch:   1 usd:   0
[  251.705082] CPU    5: hi:    0, btch:   1 usd:   0
[  251.705332] CPU    6: hi:    0, btch:   1 usd:   0
[  251.705581] CPU    7: hi:    0, btch:   1 usd:   0
[  251.705829] Node 0 DMA32 per-cpu:
[  251.706059] CPU    0: hi:   90, btch:  15 usd:  19
[  251.706308] CPU    1: hi:   90, btch:  15 usd:  27
[  251.706557] CPU    2: hi:   90, btch:  15 usd:  22
[  251.706814] CPU    3: hi:   90, btch:  15 usd:   0
[  251.707064] CPU    4: hi:   90, btch:  15 usd:   0
[  251.707312] CPU    5: hi:   90, btch:  15 usd:   1
[  251.707561] CPU    6: hi:   90, btch:  15 usd:  29
[  251.707810] CPU    7: hi:   90, btch:  15 usd:  12
[  251.708061] active_anon:3075 inactive_anon:35 isolated_anon:0
[  251.708062]  active_file:236 inactive_file:2005 isolated_file:0
[  251.708063]  unevictable:0 dirty:212 writeback:0 unstable:0
[  251.708064]  free:770 slab_reclaimable:13787 slab_unreclaimable:5155
[  251.708065]  mapped:180 shmem:75 pagetables:223 bounce:0
[  251.709486] Node 0 DMA free:1060kB min:120kB low:148kB high:180kB active_anon:572kB inactive_anon:0kB active_file:12kB inactive_file:552kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:13260kB slab_unreclaimable:252kB kernel_stack:8kB pagetables:32kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1419 all_unreclaimable? yes
[  251.711194] lowmem_reserve[]: 0 236 236 236
[  251.711602] Node 0 DMA32 free:2020kB min:1904kB low:2380kB high:2856kB active_anon:11728kB inactive_anon:140kB active_file:932kB inactive_file:7468kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:848kB writeback:0kB mapped:720kB shmem:300kB slab_reclaimable:41888kB slab_unreclaimable:20368kB kernel_stack:1064kB pagetables:860kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:26694 all_unreclaimable? yes
[  251.713383] lowmem_reserve[]: 0 0 0 0
[  251.713769] Node 0 DMA: 2*4kB 38*8kB 45*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1064kB
[  251.714739] Node 0 DMA32: 191*4kB 88*8kB 24*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1884kB
[  251.715732] 2396 total pagecache pages
[  251.715941] 0 pages in swap cache
[  251.716134] Swap cache stats: add 0, delete 0, find 0/0
[  251.716399] Free swap  = 0kB
[  251.716575] Total swap = 0kB
[  251.717304] 65520 pages RAM
[  251.717478] 16492 pages reserved
[  251.717668] 1452 pages shared
[  251.717847] 46496 pages non-shared
[  261.765242] sleep invoked oom-killer: gfp_mask=0x84d0, order=0, oom_adj=0, oom_score_adj=0
[  261.765664] sleep cpuset=/ mems_allowed=0
[  261.765887] Pid: 10422, comm: sleep Not tainted 2.6.37-rc3 #154
[  261.766179] Call Trace:
[  261.766342]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  261.766628]  [<ffffffff81130593>] dump_header+0x83/0x200
[  261.766895]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  261.767179]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  261.767453]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  261.767736]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  261.768017]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  261.768292]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  261.768595]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  261.768886]  [<ffffffff8106934b>] pte_alloc_one+0x1b/0x40
[  261.769153]  [<ffffffff8114df1f>] __pte_alloc+0x2f/0xf0
[  261.769415]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  261.769683]  [<ffffffff811509d7>] handle_mm_fault+0xa97/0xc20
[  261.769965]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  261.770242]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  261.770516]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  261.770783]  [<ffffffff810bb929>] ? trace_hardirqs_off_caller+0x29/0x150
[  261.771098]  [<ffffffff810bba5d>] ? trace_hardirqs_off+0xd/0x10
[  261.771385]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  261.771661]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  261.771917]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  261.772228]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  261.772485] Mem-Info:
[  261.772636] Node 0 DMA per-cpu:
[  261.772854] CPU    0: hi:    0, btch:   1 usd:   0
[  261.773095] CPU    1: hi:    0, btch:   1 usd:   0
[  261.773336] CPU    2: hi:    0, btch:   1 usd:   0
[  261.773578] CPU    3: hi:    0, btch:   1 usd:   0
[  261.773818] CPU    4: hi:    0, btch:   1 usd:   0
[  261.774060] CPU    5: hi:    0, btch:   1 usd:   0
[  261.774302] CPU    6: hi:    0, btch:   1 usd:   0
[  261.774543] CPU    7: hi:    0, btch:   1 usd:   0
[  261.774786] Node 0 DMA32 per-cpu:
[  261.775011] CPU    0: hi:   90, btch:  15 usd:  31
[  261.775255] CPU    1: hi:   90, btch:  15 usd:   0
[  261.775512] CPU    2: hi:   90, btch:  15 usd:   0
[  261.775760] CPU    3: hi:   90, btch:  15 usd:   0
[  261.776005] CPU    4: hi:   90, btch:  15 usd:  83
[  261.776246] CPU    5: hi:   90, btch:  15 usd:  28
[  261.776487] CPU    6: hi:   90, btch:  15 usd:   0
[  261.776728] CPU    7: hi:   90, btch:  15 usd:  15
[  261.776971] active_anon:2800 inactive_anon:10 isolated_anon:0
[  261.776971]  active_file:280 inactive_file:1696 isolated_file:0
[  261.776972]  unevictable:0 dirty:0 writeback:351 unstable:0
[  261.776972]  free:732 slab_reclaimable:14332 slab_unreclaimable:5150
[  261.776973]  mapped:242 shmem:75 pagetables:188 bounce:0
[  261.778361] Node 0 DMA free:1040kB min:120kB low:148kB high:180kB active_anon:572kB inactive_anon:0kB active_file:12kB inactive_file:536kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:8kB shmem:0kB slab_reclaimable:13392kB slab_unreclaimable:228kB kernel_stack:8kB pagetables:36kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:866 all_unreclaimable? yes
[  261.780066] lowmem_reserve[]: 0 236 236 236
[  261.780459] Node 0 DMA32 free:1888kB min:1904kB low:2380kB high:2856kB active_anon:10628kB inactive_anon:40kB active_file:1108kB inactive_file:6248kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:28kB writeback:992kB mapped:960kB shmem:300kB slab_reclaimable:43936kB slab_unreclaimable:20372kB kernel_stack:1056kB pagetables:716kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:13066 all_unreclaimable? yes
[  261.782197] lowmem_reserve[]: 0 0 0 0
[  261.782574] Node 0 DMA: 1*4kB 52*8kB 40*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1060kB
[  261.783583] Node 0 DMA32: 100*4kB 151*8kB 13*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1848kB
[  261.784550] 2137 total pagecache pages
[  261.784756] 0 pages in swap cache
[  261.784945] Swap cache stats: add 0, delete 0, find 0/0
[  261.785204] Free swap  = 0kB
[  261.785377] Total swap = 0kB
[  261.786140] 65520 pages RAM
[  261.786311] 16492 pages reserved
[  261.786497] 1556 pages shared
[  261.786674] 46628 pages non-shared
[  261.786867] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  261.787874] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  261.788252] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  261.788628] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  261.789004] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  261.789376] [ 2752]     0  2752     3460      290   2       0             0 dd
[  261.789743] [ 2753]     0  2753     3460      290   7       0             0 dd
[  261.790107] [ 2754]     0  2754     3460      289   5       0             0 dd
[  261.790471] [ 2755]     0  2755     3460      289   4       0             0 dd
[  261.790839] [ 2756]     0  2756     3460      290   2       0             0 dd
[  261.791207] [ 2757]     0  2757     3460      290   6       0             0 dd
[  261.791624] [ 2758]     0  2758     3460      290   1       0             0 dd
[  261.791989] [ 2759]     0  2759     3437      194   0       0             0 plot-written.sh
[  261.792397] [ 2776]     0  2776     2144       95   5       0             0 iostat
[  261.792774] [10030]     0 10030     1494       26   1       0             0 getty
[  261.793151] [10034]     0 10034     1494       26   0       0             0 getty
[  261.793527] [10035]     0 10035     1494       26   4       0             0 getty
[  261.793903] [10036]     0 10036     1494       26   5       0             0 getty
[  261.794276] [10038]     0 10038     1494       27   1       0             0 getty
[  261.794648] [10041]     0 10041     1494       29   4       0             0 getty
[  261.795020] [10422]     0 10422     2135      116   4       0             0 sleep
[  261.795393] Out of memory: Kill process 2752 (dd) score 1 or sacrifice child
[  261.795769] Killed process 2752 (dd) total-vm:13840kB, anon-rss:1140kB, file-rss:20kB
[  265.845137] grep invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  265.845587] grep cpuset=/ mems_allowed=0
[  265.845814] Pid: 10562, comm: grep Not tainted 2.6.37-rc3 #154
[  265.846109] Call Trace:
[  265.846279]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  265.846573]  [<ffffffff81130593>] dump_header+0x83/0x200
[  265.846844]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  265.847138]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  265.847415]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  265.847685]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  265.847965]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  265.848240]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  265.848545]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  265.848835]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  265.849119]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  265.849439]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  265.849755]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  265.850023]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  265.850278]  [<ffffffff81138bbe>] ondemand_readahead+0x10e/0x2b0
[  265.850569]  [<ffffffff81138e66>] page_cache_sync_readahead+0x36/0x50
[  265.850875]  [<ffffffff8112f984>] filemap_fault+0x444/0x4f0
[  265.851149]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  265.851436]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  265.851695]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  265.851973]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  265.852247]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  265.852546]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  265.852818]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  265.853083]  [<ffffffff810bb929>] ? trace_hardirqs_off_caller+0x29/0x150
[  265.853396]  [<ffffffff810bba5d>] ? trace_hardirqs_off+0xd/0x10
[  265.853685]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  265.853951]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  265.854203]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  265.854509]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  265.854764] Mem-Info:
[  265.854913] Node 0 DMA per-cpu:
[  265.855130] CPU    0: hi:    0, btch:   1 usd:   0
[  265.855377] CPU    1: hi:    0, btch:   1 usd:   0
[  265.855621] CPU    2: hi:    0, btch:   1 usd:   0
[  265.855864] CPU    3: hi:    0, btch:   1 usd:   0
[  265.856105] CPU    4: hi:    0, btch:   1 usd:   0
[  265.856346] CPU    5: hi:    0, btch:   1 usd:   0
[  265.856588] CPU    6: hi:    0, btch:   1 usd:   0
[  265.856830] CPU    7: hi:    0, btch:   1 usd:   0
[  265.857070] Node 0 DMA32 per-cpu:
[  265.857293] CPU    0: hi:   90, btch:  15 usd:  12
[  265.857541] CPU    1: hi:   90, btch:  15 usd:  14
[  265.857783] CPU    2: hi:   90, btch:  15 usd:   0
[  265.858024] CPU    3: hi:   90, btch:  15 usd:   2
[  265.858266] CPU    4: hi:   90, btch:  15 usd:  14
[  265.858507] CPU    5: hi:   90, btch:  15 usd:   4
[  265.858749] CPU    6: hi:   90, btch:  15 usd:   0
[  265.858990] CPU    7: hi:   90, btch:  15 usd:   0
[  265.859233] active_anon:2582 inactive_anon:52 isolated_anon:0
[  265.859234]  active_file:258 inactive_file:1714 isolated_file:0
[  265.859234]  unevictable:0 dirty:0 writeback:312 unstable:0
[  265.859235]  free:781 slab_reclaimable:14537 slab_unreclaimable:5120
[  265.859236]  mapped:255 shmem:75 pagetables:222 bounce:0
[  265.860624] Node 0 DMA free:1056kB min:120kB low:148kB high:180kB active_anon:416kB inactive_anon:0kB active_file:8kB inactive_file:484kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:13408kB slab_unreclaimable:228kB kernel_stack:8kB pagetables:84kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:837 all_unreclaimable? yes
[  265.862279] lowmem_reserve[]: 0 236 236 236
[  265.862676] Node 0 DMA32 free:2068kB min:1904kB low:2380kB high:2856kB active_anon:9912kB inactive_anon:208kB active_file:1024kB inactive_file:6372kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:0kB writeback:800kB mapped:1020kB shmem:300kB slab_reclaimable:44740kB slab_unreclaimable:20252kB kernel_stack:1056kB pagetables:804kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:11414 all_unreclaimable? yes
[  265.864406] lowmem_reserve[]: 0 0 0 0
[  265.864778] Node 0 DMA: 13*4kB 105*8kB 12*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1084kB
[  265.865740] Node 0 DMA32: 150*4kB 129*8kB 15*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1904kB
[  265.866708] 2141 total pagecache pages
[  265.866913] 0 pages in swap cache
[  265.867102] Swap cache stats: add 0, delete 0, find 0/0
[  265.867362] Free swap  = 0kB
[  265.867535] Total swap = 0kB
[  265.868316] 65520 pages RAM
[  265.868487] 16492 pages reserved
[  265.868673] 1572 pages shared
[  265.868849] 46772 pages non-shared
[  265.869041] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  265.869427] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  265.869807] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  265.870184] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  265.870559] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  265.870928] [ 2753]     0  2753     3460      290   2       0             0 dd
[  265.871292] [ 2754]     0  2754     3460      289   7       0             0 dd
[  265.871655] [ 2755]     0  2755     3460      289   7       0             0 dd
[  265.872021] [ 2756]     0  2756     3460      290   5       0             0 dd
[  265.872384] [ 2757]     0  2757     3460      290   6       0             0 dd
[  265.872751] [ 2758]     0  2758     3460      290   6       0             0 dd
[  265.873116] [ 2759]     0  2759     3437      194   0       0             0 plot-written.sh
[  265.873532] [ 2776]     0  2776     2144       96   4       0             0 iostat
[  265.873912] [10030]     0 10030     1494       26   1       0             0 getty
[  265.874289] [10034]     0 10034     1494       26   0       0             0 getty
[  265.874665] [10035]     0 10035     1494       26   4       0             0 getty
[  265.875040] [10036]     0 10036     1494       26   5       0             0 getty
[  265.875415] [10038]     0 10038     1494       27   1       0             0 getty
[  265.875791] [10041]     0 10041     1494       29   4       0             0 getty
[  265.876168] [10561]     0 10561     3437      163   5       0             0 plot-written.sh
[  265.876577] [10562]     0 10562     2675      139   4       0             0 grep
[  265.876950] Out of memory: Kill process 2753 (dd) score 1 or sacrifice child
[  265.877277] Killed process 2753 (dd) total-vm:13840kB, anon-rss:1140kB, file-rss:20kB
[  265.877713] dd: page allocation failure. order:0, mode:0x2005a
[  265.878005] Pid: 2753, comm: dd Not tainted 2.6.37-rc3 #154
[  265.878282] Call Trace:
[  265.878446]  [<ffffffff81136500>] __alloc_pages_nodemask+0x680/0x830
[  265.878756]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  265.879052]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  265.879914]  [<ffffffff8112ddcf>] grab_cache_page_write_begin+0x7f/0xc0
[  265.880233]  [<ffffffff8121de03>] ext4_da_write_begin+0x143/0x280
[  265.880532]  [<ffffffff8112cb19>] generic_file_buffered_write+0x109/0x260
[  265.880857]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  265.881147]  [<ffffffff81a31030>] ? mutex_lock_nested+0x280/0x350
[  265.881462]  [<ffffffff8112e994>] __generic_file_aio_write+0x244/0x450
[  265.881779]  [<ffffffff81a31042>] ? mutex_lock_nested+0x292/0x350
[  265.882077]  [<ffffffff8112ebf8>] ? generic_file_aio_write+0x58/0xd0
[  265.882383]  [<ffffffff8112ebf8>] ? generic_file_aio_write+0x58/0xd0
[  265.882689]  [<ffffffff8112ec0b>] generic_file_aio_write+0x6b/0xd0
[  265.882991]  [<ffffffff812142b2>] ext4_file_write+0x42/0xc0
[  265.883269]  [<ffffffff8118586a>] do_sync_write+0xda/0x120
[  265.883543]  [<ffffffff8114ce75>] ? might_fault+0xa5/0xb0
[  265.883814]  [<ffffffff814ab385>] ? read_zero+0xe5/0x120
[  265.884082]  [<ffffffff81185fee>] vfs_write+0xce/0x190
[  265.884343]  [<ffffffff81186324>] sys_write+0x54/0x90
[  265.884602]  [<ffffffff8103afb2>] system_call_fastpath+0x16/0x1b
[  265.884894] Mem-Info:
[  265.885045] Node 0 DMA per-cpu:
[  265.885266] CPU    0: hi:    0, btch:   1 usd:   0
[  265.885521] CPU    1: hi:    0, btch:   1 usd:   0
[  265.885767] CPU    2: hi:    0, btch:   1 usd:   0
[  265.886013] CPU    3: hi:    0, btch:   1 usd:   0
[  265.886259] CPU    4: hi:    0, btch:   1 usd:   0
[  265.886504] CPU    5: hi:    0, btch:   1 usd:   0
[  265.886750] CPU    6: hi:    0, btch:   1 usd:   0
[  265.886997] CPU    7: hi:    0, btch:   1 usd:   0
[  265.887243] Node 0 DMA32 per-cpu:
[  265.887470] CPU    0: hi:   90, btch:  15 usd:  12
[  265.887717] CPU    1: hi:   90, btch:  15 usd:  14
[  265.887965] CPU    2: hi:   90, btch:  15 usd:   0
[  265.888211] CPU    3: hi:   90, btch:  15 usd:   2
[  265.888458] CPU    4: hi:   90, btch:  15 usd:  14
[  265.888704] CPU    5: hi:   90, btch:  15 usd:   4
[  265.888949] CPU    6: hi:   90, btch:  15 usd:   0
[  265.889195] CPU    7: hi:   90, btch:  15 usd:   0
[  265.889454] active_anon:2582 inactive_anon:52 isolated_anon:0
[  265.889456]  active_file:258 inactive_file:1714 isolated_file:0
[  265.889457]  unevictable:0 dirty:0 writeback:0 unstable:0
[  265.889457]  free:781 slab_reclaimable:14537 slab_unreclaimable:5120
[  265.889459]  mapped:255 shmem:75 pagetables:222 bounce:0
[  265.890867] Node 0 DMA free:1056kB min:120kB low:148kB high:180kB active_anon:416kB inactive_anon:0kB active_file:8kB inactive_file:484kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:13408kB slab_unreclaimable:228kB kernel_stack:8kB pagetables:84kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:837 all_unreclaimable? yes
[  265.892556] lowmem_reserve[]: 0 236 236 236
[  265.892961] Node 0 DMA32 free:2068kB min:1904kB low:2380kB high:2856kB active_anon:9912kB inactive_anon:208kB active_file:1024kB inactive_file:6372kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:0kB writeback:0kB mapped:1020kB shmem:300kB slab_reclaimable:44740kB slab_unreclaimable:20252kB kernel_stack:1056kB pagetables:804kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:11414 all_unreclaimable? yes
[  265.894744] lowmem_reserve[]: 0 0 0 0
[  265.895132] Node 0 DMA: 13*4kB 105*8kB 12*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1084kB
[  265.896109] Node 0 DMA32: 150*4kB 129*8kB 15*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1904kB
[  265.897099] 2141 total pagecache pages
[  265.897308] 0 pages in swap cache
[  265.897515] Swap cache stats: add 0, delete 0, find 0/0
[  265.897780] Free swap  = 0kB
[  265.897956] Total swap = 0kB
[  265.898676] 65520 pages RAM
[  265.898851] 16492 pages reserved
[  265.899040] 1319 pages shared
[  265.899219] 46771 pages non-shared
[  268.591037] date invoked oom-killer: gfp_mask=0x84d0, order=0, oom_adj=0, oom_score_adj=0
[  268.591469] date cpuset=/ mems_allowed=0
[  268.591694] Pid: 10627, comm: date Not tainted 2.6.37-rc3 #154
[  268.591988] Call Trace:
[  268.592156]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  268.592454]  [<ffffffff81130593>] dump_header+0x83/0x200
[  268.592730]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  268.593025]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  268.593309]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  268.593585]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  268.593870]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  268.594151]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  268.594462]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  268.594783]  [<ffffffff8106934b>] pte_alloc_one+0x1b/0x40
[  268.595060]  [<ffffffff8114df1f>] __pte_alloc+0x2f/0xf0
[  268.595333]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  268.595612]  [<ffffffff811509d7>] handle_mm_fault+0xa97/0xc20
[  268.595905]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  268.596195]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  268.596480]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  268.596760]  [<ffffffff810bb929>] ? trace_hardirqs_off_caller+0x29/0x150
[  268.597088]  [<ffffffff810bba5d>] ? trace_hardirqs_off+0xd/0x10
[  268.597379]  [<ffffffff810b022f>] ? local_clock+0x6f/0x80
[  268.597647]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  268.597902]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  268.598210]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  268.598467] Mem-Info:
[  268.598618] Node 0 DMA per-cpu:
[  268.598851] CPU    0: hi:    0, btch:   1 usd:   0
[  268.599094] CPU    1: hi:    0, btch:   1 usd:   0
[  268.599338] CPU    2: hi:    0, btch:   1 usd:   0
[  268.599582] CPU    3: hi:    0, btch:   1 usd:   0
[  268.599826] CPU    4: hi:    0, btch:   1 usd:   0
[  268.600069] CPU    5: hi:    0, btch:   1 usd:   0
[  268.600314] CPU    6: hi:    0, btch:   1 usd:   0
[  268.600557] CPU    7: hi:    0, btch:   1 usd:   0
[  268.600801] Node 0 DMA32 per-cpu:
[  268.601027] CPU    0: hi:   90, btch:  15 usd:  27
[  268.601271] CPU    1: hi:   90, btch:  15 usd:  33
[  268.601514] CPU    2: hi:   90, btch:  15 usd:  49
[  268.601758] CPU    3: hi:   90, btch:  15 usd:  38
[  268.602002] CPU    4: hi:   90, btch:  15 usd:   0
[  268.602246] CPU    5: hi:   90, btch:  15 usd:   0
[  268.602489] CPU    6: hi:   90, btch:  15 usd:   0
[  268.602740] CPU    7: hi:   90, btch:  15 usd:  13
[  268.602985] active_anon:2211 inactive_anon:13 isolated_anon:0
[  268.602986]  active_file:323 inactive_file:1806 isolated_file:0
[  268.602986]  unevictable:0 dirty:8 writeback:800 unstable:0
[  268.602987]  free:709 slab_reclaimable:14675 slab_unreclaimable:5134
[  268.602988]  mapped:249 shmem:75 pagetables:197 bounce:0
[  268.604368] Node 0 DMA free:1040kB min:120kB low:148kB high:180kB active_anon:312kB inactive_anon:0kB active_file:12kB inactive_file:540kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:13428kB slab_unreclaimable:224kB kernel_stack:8kB pagetables:32kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  268.606013] lowmem_reserve[]: 0 236 236 236
[  268.606408] Node 0 DMA32 free:2388kB min:1904kB low:2380kB high:2856kB active_anon:8532kB inactive_anon:52kB active_file:1280kB inactive_file:6684kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:84kB writeback:3000kB mapped:992kB shmem:300kB slab_reclaimable:45272kB slab_unreclaimable:20312kB kernel_stack:1048kB pagetables:756kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  268.608186] lowmem_reserve[]: 0 0 0 0
[  268.608555] Node 0 DMA: 1*4kB 63*8kB 39*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1132kB
[  268.609492] Node 0 DMA32: 167*4kB 153*8kB 31*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2388kB
[  268.610441] 2297 total pagecache pages
[  268.610644] 0 pages in swap cache
[  268.610846] Swap cache stats: add 0, delete 0, find 0/0
[  268.611104] Free swap  = 0kB
[  268.611275] Total swap = 0kB
[  268.612057] 65520 pages RAM
[  268.612227] 16492 pages reserved
[  268.612410] 2213 pages shared
[  268.612585] 46407 pages non-shared
[  268.612776] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  268.613160] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  268.613551] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  268.613944] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  268.614338] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  268.614747] [ 2754]     0  2754     3460      289   1       0             0 dd
[  268.615133] [ 2755]     0  2755     3460      289   2       0             0 dd
[  268.615516] [ 2756]     0  2756     3460      290   2       0             0 dd
[  268.615901] [ 2757]     0  2757     3460      290   1       0             0 dd
[  268.616285] [ 2758]     0  2758     3460      290   2       0             0 dd
[  268.616667] [ 2759]     0  2759     3438      197   0       0             0 plot-written.sh
[  268.617098] [ 2776]     0  2776     2144      101   0       0             0 iostat
[  268.617497] [10030]     0 10030     1494       26   1       0             0 getty
[  268.617893] [10034]     0 10034     1494       26   0       0             0 getty
[  268.618290] [10035]     0 10035     1494       26   4       0             0 getty
[  268.618684] [10036]     0 10036     1494       26   5       0             0 getty
[  268.619087] [10038]     0 10038     1494       27   1       0             0 getty
[  268.620052] [10041]     0 10041     1494       29   4       0             0 getty
[  268.620446] [10627]     0 10627     3202      133   4       0             0 date
[  268.620840] Out of memory: Kill process 2754 (dd) score 1 or sacrifice child
[  268.621188] Killed process 2754 (dd) total-vm:13840kB, anon-rss:1136kB, file-rss:20kB
[  275.637877] wc invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  275.638373] wc cpuset=/ mems_allowed=0
[  275.638580] Pid: 10781, comm: wc Not tainted 2.6.37-rc3 #154
[  275.638858] Call Trace:
[  275.639016]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  275.639302]  [<ffffffff81130593>] dump_header+0x83/0x200
[  275.639567]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  275.639852]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  275.640120]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  275.640391]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  275.640666]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  275.640941]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  275.641239]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  275.641530]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  275.641809]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  275.642192]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  275.642647]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  275.642951]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  275.643200]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  275.643475]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  275.643759]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  275.644020]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  275.644300]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  275.644576]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  275.644879]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  275.645153]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  275.645458]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  275.645714]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  275.646100]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  275.646366] Mem-Info:
[  275.646520] Node 0 DMA per-cpu:
[  275.646740] CPU    0: hi:    0, btch:   1 usd:   0
[  275.646979] CPU    1: hi:    0, btch:   1 usd:   0
[  275.647223] CPU    2: hi:    0, btch:   1 usd:   0
[  275.647463] CPU    3: hi:    0, btch:   1 usd:   0
[  275.647708] CPU    4: hi:    0, btch:   1 usd:   0
[  275.647952] CPU    5: hi:    0, btch:   1 usd:   0
[  275.648196] CPU    6: hi:    0, btch:   1 usd:   0
[  275.648434] CPU    7: hi:    0, btch:   1 usd:   0
[  275.648680] Node 0 DMA32 per-cpu:
[  275.648904] CPU    0: hi:   90, btch:  15 usd:  19
[  275.649148] CPU    1: hi:   90, btch:  15 usd:   0
[  275.649393] CPU    2: hi:   90, btch:  15 usd:   0
[  275.649632] CPU    3: hi:   90, btch:  15 usd:   0
[  275.649877] CPU    4: hi:   90, btch:  15 usd:  38
[  275.650401] CPU    5: hi:   90, btch:  15 usd:   0
[  275.650641] CPU    6: hi:   90, btch:  15 usd:   0
[  275.650888] CPU    7: hi:   90, btch:  15 usd:   0
[  275.651134] active_anon:1962 inactive_anon:21 isolated_anon:0
[  275.651134]  active_file:213 inactive_file:2025 isolated_file:0
[  275.651135]  unevictable:0 dirty:0 writeback:379 unstable:1
[  275.651136]  free:715 slab_reclaimable:14999 slab_unreclaimable:5127
[  275.651136]  mapped:160 shmem:75 pagetables:185 bounce:0
[  275.652514] Node 0 DMA free:1044kB min:120kB low:148kB high:180kB active_anon:364kB inactive_anon:0kB active_file:4kB inactive_file:556kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:13396kB slab_unreclaimable:252kB kernel_stack:8kB pagetables:84kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:888 all_unreclaimable? yes
[  275.654231] lowmem_reserve[]: 0 236 236 236
[  275.654638] Node 0 DMA32 free:1816kB min:1904kB low:2380kB high:2856kB active_anon:7484kB inactive_anon:84kB active_file:848kB inactive_file:7544kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:0kB writeback:1516kB mapped:640kB shmem:300kB slab_reclaimable:46600kB slab_unreclaimable:20256kB kernel_stack:1056kB pagetables:656kB unstable:4kB bounce:0kB writeback_tmp:0kB pages_scanned:16113 all_unreclaimable? yes
[  275.656374] lowmem_reserve[]: 0 0 0 0
[  275.656745] Node 0 DMA: 0*4kB 73*8kB 31*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1080kB
[  275.657696] Node 0 DMA32: 125*4kB 115*8kB 27*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1884kB
[  275.658920] 2336 total pagecache pages
[  275.659127] 0 pages in swap cache
[  275.659312] Swap cache stats: add 0, delete 0, find 0/0
[  275.659572] Free swap  = 0kB
[  275.659747] Total swap = 0kB
[  275.660536] 65520 pages RAM
[  275.660703] 16492 pages reserved
[  275.660891] 1796 pages shared
[  275.661063] 46520 pages non-shared
[  275.661258] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  275.661634] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  275.662087] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  275.662473] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  275.662907] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  275.663291] [ 2755]     0  2755     3460      289   7       0             0 dd
[  275.663657] [ 2756]     0  2756     3460      290   7       0             0 dd
[  275.664022] [ 2757]     0  2757     3460      290   2       0             0 dd
[  275.664387] [ 2758]     0  2758     3460      290   4       0             0 dd
[  275.664757] [ 2759]     0  2759     3438      196   4       0             0 plot-written.sh
[  275.665167] [ 2776]     0  2776     2145       97   6       0             0 iostat
[  275.665548] [10030]     0 10030     1494       26   1       0             0 getty
[  275.666208] [10034]     0 10034     1494       26   0       0             0 getty
[  275.666586] [10035]     0 10035     1494       26   4       0             0 getty
[  275.666962] [10036]     0 10036     1494       26   5       0             0 getty
[  275.667337] [10038]     0 10038     1494       27   1       0             0 getty
[  275.667712] [10041]     0 10041     1494       29   4       0             0 getty
[  275.668087] [10779]     0 10779     3438      150   0       0             0 plot-written.sh
[  275.668493] [10781]     0 10781     2137       77   0       0             0 wc
[  275.668859] Out of memory: Kill process 2755 (dd) score 1 or sacrifice child
[  275.669186] Killed process 2755 (dd) total-vm:13840kB, anon-rss:1136kB, file-rss:20kB
[  282.955149] iostat invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  282.955563] iostat cpuset=/ mems_allowed=0
[  282.955778] Pid: 2776, comm: iostat Not tainted 2.6.37-rc3 #154
[  282.956061] Call Trace:
[  282.956218]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  282.956499]  [<ffffffff81130593>] dump_header+0x83/0x200
[  282.956760]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  282.957039]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  282.957308]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  282.957596]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  282.957871]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  282.958142]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  282.958442]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  282.958728]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  282.959010]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  282.959319]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  282.959633]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  282.959935]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  282.960185]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  282.960455]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  282.960738]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  282.960994]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  282.961272]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  282.961553]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  282.961853]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  282.962123]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  282.962405]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  282.962658]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  282.962965]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  282.963219] Mem-Info:
[  282.963368] Node 0 DMA per-cpu:
[  282.963584] CPU    0: hi:    0, btch:   1 usd:   0
[  282.963828] CPU    1: hi:    0, btch:   1 usd:   0
[  282.964070] CPU    2: hi:    0, btch:   1 usd:   0
[  282.964313] CPU    3: hi:    0, btch:   1 usd:   0
[  282.964556] CPU    4: hi:    0, btch:   1 usd:   0
[  282.964798] CPU    5: hi:    0, btch:   1 usd:   0
[  282.965042] CPU    6: hi:    0, btch:   1 usd:   0
[  282.965285] CPU    7: hi:    0, btch:   1 usd:   0
[  282.965535] Node 0 DMA32 per-cpu:
[  282.965759] CPU    0: hi:   90, btch:  15 usd:  35
[  282.966001] CPU    1: hi:   90, btch:  15 usd:  14
[  282.966244] CPU    2: hi:   90, btch:  15 usd:  32
[  282.966487] CPU    3: hi:   90, btch:  15 usd:   0
[  282.966730] CPU    4: hi:   90, btch:  15 usd:  14
[  282.966971] CPU    5: hi:   90, btch:  15 usd:  81
[  282.967213] CPU    6: hi:   90, btch:  15 usd:  28
[  282.967457] CPU    7: hi:   90, btch:  15 usd:   0
[  282.967701] active_anon:1656 inactive_anon:28 isolated_anon:0
[  282.967702]  active_file:36 inactive_file:2139 isolated_file:0
[  282.967703]  unevictable:0 dirty:274 writeback:109 unstable:0
[  282.967703]  free:760 slab_reclaimable:15317 slab_unreclaimable:5085
[  282.967704]  mapped:0 shmem:75 pagetables:181 bounce:0
[  282.969672] Node 0 DMA free:1060kB min:120kB low:148kB high:180kB active_anon:324kB inactive_anon:0kB active_file:0kB inactive_file:556kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:140kB writeback:132kB mapped:0kB shmem:0kB slab_reclaimable:13364kB slab_unreclaimable:308kB kernel_stack:8kB pagetables:32kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:886 all_unreclaimable? yes
[  282.971334] lowmem_reserve[]: 0 236 236 236
[  282.971721] Node 0 DMA32 free:1980kB min:1904kB low:2380kB high:2856kB active_anon:6300kB inactive_anon:112kB active_file:152kB inactive_file:8000kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:956kB writeback:304kB mapped:0kB shmem:300kB slab_reclaimable:47904kB slab_unreclaimable:20032kB kernel_stack:1016kB pagetables:692kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:20046 all_unreclaimable? yes
[  282.973466] lowmem_reserve[]: 0 0 0 0
[  282.973837] Node 0 DMA: 1*4kB 87*8kB 25*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1132kB
[  282.974773] Node 0 DMA32: 136*4kB 111*8kB 19*16kB 4*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1864kB
[  282.975724] 2323 total pagecache pages
[  282.975927] 0 pages in swap cache
[  282.976115] Swap cache stats: add 0, delete 0, find 0/0
[  282.976373] Free swap  = 0kB
[  282.976544] Total swap = 0kB
[  282.977336] 65520 pages RAM
[  282.977515] 16492 pages reserved
[  282.977702] 1382 pages shared
[  282.977876] 46536 pages non-shared
[  282.978067] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  282.978444] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  282.978819] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  282.979193] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  282.979568] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  282.979939] [ 2756]     0  2756     3460      290   6       0             0 dd
[  282.980305] [ 2757]     0  2757     3460      290   1       0             0 dd
[  282.980670] [ 2758]     0  2758     3460      290   2       0             0 dd
[  282.981036] [ 2759]     0  2759     3438       79   4       0             0 plot-written.sh
[  282.981449] [ 2776]     0  2776     2145       66   3       0             0 iostat
[  282.981826] [10030]     0 10030     1494       26   1       0             0 getty
[  282.982197] [10034]     0 10034     1494       26   0       0             0 getty
[  282.982569] [10035]     0 10035     1494       26   4       0             0 getty
[  282.982939] [10036]     0 10036     1494       26   5       0             0 getty
[  282.983311] [10038]     0 10038     1494       27   1       0             0 getty
[  282.983683] [10041]     0 10041     1494       27   4       0             0 getty
[  282.984054] [10932]     0 10932     3438       78   5       0             0 plot-written.sh
[  282.984459] Out of memory: Kill process 2756 (dd) score 1 or sacrifice child
[  282.984782] Killed process 2756 (dd) total-vm:13840kB, anon-rss:1140kB, file-rss:20kB
[  282.985208] dd: page allocation failure. order:0, mode:0x2005a
[  282.985507] Pid: 2756, comm: dd Not tainted 2.6.37-rc3 #154
[  282.985785] Call Trace:
[  282.985948]  [<ffffffff81136500>] __alloc_pages_nodemask+0x680/0x830
[  282.986261]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  282.986558]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  282.986847]  [<ffffffff8112ddcf>] grab_cache_page_write_begin+0x7f/0xc0
[  282.987166]  [<ffffffff8121de03>] ext4_da_write_begin+0x143/0x280
[  282.987465]  [<ffffffff8112cb19>] generic_file_buffered_write+0x109/0x260
[  282.987790]  [<ffffffff8121fdd4>] ? ext4_dirty_inode+0x54/0x60
[  282.988081]  [<ffffffff81a31030>] ? mutex_lock_nested+0x280/0x350
[  282.988380]  [<ffffffff8112e994>] __generic_file_aio_write+0x244/0x450
[  282.988695]  [<ffffffff81a31042>] ? mutex_lock_nested+0x292/0x350
[  282.988993]  [<ffffffff8112ebf8>] ? generic_file_aio_write+0x58/0xd0
[  282.989301]  [<ffffffff8112ebf8>] ? generic_file_aio_write+0x58/0xd0
[  282.989624]  [<ffffffff8112ec0b>] generic_file_aio_write+0x6b/0xd0
[  282.989928]  [<ffffffff812142b2>] ext4_file_write+0x42/0xc0
[  282.990209]  [<ffffffff8118586a>] do_sync_write+0xda/0x120
[  282.990485]  [<ffffffff8114ce75>] ? might_fault+0xa5/0xb0
[  282.990757]  [<ffffffff814ab385>] ? read_zero+0xe5/0x120
[  282.991027]  [<ffffffff81185fee>] vfs_write+0xce/0x190
[  282.991289]  [<ffffffff81186324>] sys_write+0x54/0x90
[  282.991549]  [<ffffffff8103afb2>] system_call_fastpath+0x16/0x1b
[  282.991843] Mem-Info:
[  282.991996] Node 0 DMA per-cpu:
[  282.992219] CPU    0: hi:    0, btch:   1 usd:   0
[  282.992468] CPU    1: hi:    0, btch:   1 usd:   0
[  282.992716] CPU    2: hi:    0, btch:   1 usd:   0
[  282.992964] CPU    3: hi:    0, btch:   1 usd:   0
[  282.993213] CPU    4: hi:    0, btch:   1 usd:   0
[  282.993470] CPU    5: hi:    0, btch:   1 usd:   0
[  282.993719] CPU    6: hi:    0, btch:   1 usd:   0
[  282.993968] CPU    7: hi:    0, btch:   1 usd:   0
[  282.994216] Node 0 DMA32 per-cpu:
[  282.994447] CPU    0: hi:   90, btch:  15 usd:  36
[  282.994697] CPU    1: hi:   90, btch:  15 usd:  14
[  282.994946] CPU    2: hi:   90, btch:  15 usd:  32
[  282.995196] CPU    3: hi:   90, btch:  15 usd:   0
[  282.995445] CPU    4: hi:   90, btch:  15 usd:  14
[  282.995693] CPU    5: hi:   90, btch:  15 usd:  76
[  282.995942] CPU    6: hi:   90, btch:  15 usd:  28
[  282.996192] CPU    7: hi:   90, btch:  15 usd:   1
[  282.996444] active_anon:1656 inactive_anon:28 isolated_anon:0
[  282.996445]  active_file:36 inactive_file:2139 isolated_file:0
[  282.996446]  unevictable:0 dirty:274 writeback:0 unstable:0
[  282.996447]  free:760 slab_reclaimable:15300 slab_unreclaimable:5085
[  282.996448]  mapped:0 shmem:75 pagetables:181 bounce:0
[  282.997866] Node 0 DMA free:1060kB min:120kB low:148kB high:180kB active_anon:324kB inactive_anon:0kB active_file:0kB inactive_file:556kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:140kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:13364kB slab_unreclaimable:308kB kernel_stack:8kB pagetables:32kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:886 all_unreclaimable? yes
[  282.999565] lowmem_reserve[]: 0 236 236 236
[  282.999969] Node 0 DMA32 free:1980kB min:1904kB low:2380kB high:2856kB active_anon:6300kB inactive_anon:112kB active_file:152kB inactive_file:8000kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:956kB writeback:0kB mapped:0kB shmem:300kB slab_reclaimable:47836kB slab_unreclaimable:20032kB kernel_stack:1016kB pagetables:692kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:20046 all_unreclaimable? yes
[  283.001746] lowmem_reserve[]: 0 0 0 0
[  283.002132] Node 0 DMA: 1*4kB 87*8kB 25*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1132kB
[  283.003104] Node 0 DMA32: 135*4kB 104*8kB 19*16kB 4*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1804kB
[  283.004090] 2323 total pagecache pages
[  283.004298] 0 pages in swap cache
[  283.004490] Swap cache stats: add 0, delete 0, find 0/0
[  283.004755] Free swap  = 0kB
[  283.004930] Total swap = 0kB
[  283.005666] 65520 pages RAM
[  283.005841] 16492 pages reserved
[  283.006030] 1242 pages shared
[  283.006209] 46544 pages non-shared
[  293.931092] iostat invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[  293.931515] iostat cpuset=/ mems_allowed=0
[  293.931739] Pid: 2776, comm: iostat Not tainted 2.6.37-rc3 #154
[  293.932058] Call Trace:
[  293.932219]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  293.932536]  [<ffffffff81130593>] dump_header+0x83/0x200
[  293.932804]  [<ffffffff810be27d>] ? trace_hardirqs_on+0xd/0x10
[  293.933149]  [<ffffffff813fa29b>] ? ___ratelimit+0xab/0x150
[  293.933426]  [<ffffffff81130817>] ? oom_badness+0x77/0x190
[  293.933729]  [<ffffffff81130acd>] oom_kill_process+0x8d/0x270
[  293.934038]  [<ffffffff811310e8>] out_of_memory+0x1d8/0x410
[  293.934316]  [<ffffffff8113669b>] __alloc_pages_nodemask+0x81b/0x830
[  293.934634]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  293.934927]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  293.935214]  [<ffffffff81138630>] __do_page_cache_readahead+0x120/0x260
[  293.935529]  [<ffffffff811385bd>] ? __do_page_cache_readahead+0xad/0x260
[  293.935849]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  293.936155]  [<ffffffff81138aa1>] ra_submit+0x21/0x30
[  293.936414]  [<ffffffff8112fa1c>] filemap_fault+0x4dc/0x4f0
[  293.936693]  [<ffffffff810bfe5e>] ? __lock_acquire+0x53e/0x1e70
[  293.936984]  [<ffffffff8114d0e4>] __do_fault+0x54/0x540
[  293.937250]  [<ffffffff811500ef>] handle_mm_fault+0x1af/0xc20
[  293.937536]  [<ffffffff81a37096>] ? do_page_fault+0xf6/0x560
[  293.937815]  [<ffffffff810bb64d>] ? lock_release_holdtime+0x3d/0x180
[  293.938120]  [<ffffffff81a3710b>] do_page_fault+0x16b/0x560
[  293.938397]  [<ffffffff81a333eb>] ? _raw_spin_unlock+0x2b/0x40
[  293.938698]  [<ffffffff81a33bf6>] ? error_sti+0x5/0x6
[  293.938957]  [<ffffffff81a32658>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  293.939269]  [<ffffffff81a339e5>] page_fault+0x25/0x30
[  293.939528] Mem-Info:
[  293.939680] Node 0 DMA per-cpu:
[  293.939898] CPU    0: hi:    0, btch:   1 usd:   0
[  293.940146] CPU    1: hi:    0, btch:   1 usd:   0
[  293.940394] CPU    2: hi:    0, btch:   1 usd:   0
[  293.940643] CPU    3: hi:    0, btch:   1 usd:   0
[  293.940891] CPU    4: hi:    0, btch:   1 usd:   0
[  293.941140] CPU    5: hi:    0, btch:   1 usd:   0
[  293.941389] CPU    6: hi:    0, btch:   1 usd:   0
[  293.942212] CPU    7: hi:    0, btch:   1 usd:   0
[  293.942461] Node 0 DMA32 per-cpu:
[  293.942697] CPU    0: hi:   90, btch:  15 usd:  19
[  293.942946] CPU    1: hi:   90, btch:  15 usd:   0
[  293.943194] CPU    2: hi:   90, btch:  15 usd:  27
[  293.943442] CPU    3: hi:   90, btch:  15 usd:   0
[  293.943690] CPU    4: hi:   90, btch:  15 usd:  83
[  293.943939] CPU    5: hi:   90, btch:  15 usd:  14
[  293.944187] CPU    6: hi:   90, btch:  15 usd:   0
[  293.944435] CPU    7: hi:   90, btch:  15 usd:   0
[  293.944685] active_anon:1452 inactive_anon:23 isolated_anon:0
[  293.944686]  active_file:257 inactive_file:1826 isolated_file:0
[  293.944687]  unevictable:0 dirty:25 writeback:145 unstable:0
[  293.944688]  free:737 slab_reclaimable:15674 slab_unreclaimable:5093
[  293.944689]  mapped:161 shmem:75 pagetables:141 bounce:0
[  293.946109] Node 0 DMA free:1040kB min:120kB low:148kB high:180kB active_anon:316kB inactive_anon:0kB active_file:4kB inactive_file:592kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:13412kB slab_unreclaimable:260kB kernel_stack:8kB pagetables:32kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:977 all_unreclaimable? yes
[  293.947801] lowmem_reserve[]: 0 236 236 236
[  293.948206] Node 0 DMA32 free:1908kB min:1904kB low:2380kB high:2856kB active_anon:5492kB inactive_anon:92kB active_file:1024kB inactive_file:6712kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:100kB writeback:584kB mapped:644kB shmem:300kB slab_reclaimable:49284kB slab_unreclaimable:20112kB kernel_stack:1024kB pagetables:532kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:13132 all_unreclaimable? yes
[  293.949987] lowmem_reserve[]: 0 0 0 0
[  293.950371] Node 0 DMA: 18*4kB 46*8kB 42*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1112kB
[  293.951354] Node 0 DMA32: 131*4kB 100*8kB 30*16kB 2*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1868kB
[  293.952338] 2303 total pagecache pages
[  293.952547] 0 pages in swap cache
[  293.952739] Swap cache stats: add 0, delete 0, find 0/0
[  293.953004] Free swap  = 0kB
[  293.953179] Total swap = 0kB
[  293.954046] 65520 pages RAM
[  293.954219] 16492 pages reserved
[  293.954409] 1590 pages shared
[  293.954599] 46579 pages non-shared
[  293.954796] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  293.955182] [ 1995]     0  1995     4237      150   1     -17         -1000 udevd
[  293.955566] [ 2082]     0  2082     4264      162   2     -17         -1000 udevd
[  293.955950] [ 2083]     0  2083     4264      153   2     -17         -1000 udevd
[  293.956334] [ 2269]     0  2269    12303      138   5     -17         -1000 sshd
[  293.956714] [ 2757]     0  2757     3460      290   6       0             0 dd
[  293.957087] [ 2758]     0  2758     3460      290   1       0             0 dd
[  293.957457] [ 2759]     0  2759     3438      198   1       0             0 plot-written.sh
[  293.957871] [ 2776]     0  2776     2145       96   2       0             0 iostat
[  293.958254] [10030]     0 10030     1494       26   1       0             0 getty
[  293.958642] [10034]     0 10034     1494       26   0       0             0 getty
[  293.959022] [10035]     0 10035     1494       26   4       0             0 getty
[  293.959405] [10036]     0 10036     1494       26   5       0             0 getty
[  293.959786] [10038]     0 10038     1494       27   1       0             0 getty
[  293.960170] [10041]     0 10041     1494       27   4       0             0 getty
[  293.960555] [11259]     0 11259     3438      164   3       0             0 plot-written.sh
[  293.960972] [11260]     0 11260     3438      112   3       0             0 plot-written.sh
[  293.961388] Out of memory: Kill process 2757 (dd) score 1 or sacrifice child
[  293.961723] Killed process 2757 (dd) total-vm:13840kB, anon-rss:1140kB, file-rss:20kB
[  293.962146] dd: page allocation failure. order:0, mode:0x2005a
[  293.962430] Pid: 2757, comm: dd Not tainted 2.6.37-rc3 #154
[  293.962722] Call Trace:
[  293.962887]  [<ffffffff81136500>] __alloc_pages_nodemask+0x680/0x830
[  293.963197]  [<ffffffff8116ae79>] alloc_pages_current+0x99/0x110
[  293.963493]  [<ffffffff8112db47>] __page_cache_alloc+0x87/0x90
[  293.963782]  [<ffffffff8112ddcf>] grab_cache_page_write_begin+0x7f/0xc0
[  293.964102]  [<ffffffff8121de03>] ext4_da_write_begin+0x143/0x280
[  293.964402]  [<ffffffff8112cb19>] generic_file_buffered_write+0x109/0x260
[  293.964727]  [<ffffffff8121fdd4>] ? ext4_dirty_inode+0x54/0x60
[  293.965017]  [<ffffffff81a31030>] ? mutex_lock_nested+0x280/0x350
[  293.965316]  [<ffffffff8112e994>] __generic_file_aio_write+0x244/0x450
[  293.965631]  [<ffffffff81a31042>] ? mutex_lock_nested+0x292/0x350
[  293.965931]  [<ffffffff8112ebf8>] ? generic_file_aio_write+0x58/0xd0
[  293.966240]  [<ffffffff8112ebf8>] ? generic_file_aio_write+0x58/0xd0
[  293.966557]  [<ffffffff8112ec0b>] generic_file_aio_write+0x6b/0xd0
[  293.966880]  [<ffffffff812142b2>] ext4_file_write+0x42/0xc0
[  293.967160]  [<ffffffff8118586a>] do_sync_write+0xda/0x120
[  293.967436]  [<ffffffff8114ce75>] ? might_fault+0xa5/0xb0
[  293.967710]  [<ffffffff814ab385>] ? read_zero+0xe5/0x120
[  293.967979]  [<ffffffff81185c79>] ? rw_verify_area+0x19/0xb0
[  293.968262]  [<ffffffff81185fee>] vfs_write+0xce/0x190
[  293.968524]  [<ffffffff81186324>] sys_write+0x54/0x90
[  293.968784]  [<ffffffff8103afb2>] system_call_fastpath+0x16/0x1b
[  293.969078] Mem-Info:
[  293.969232] Node 0 DMA per-cpu:
[  293.969454] CPU    0: hi:    0, btch:   1 usd:   0
[  293.969704] CPU    1: hi:    0, btch:   1 usd:   0
[  293.969952] CPU    2: hi:    0, btch:   1 usd:   0
[  293.970200] CPU    3: hi:    0, btch:   1 usd:   0
[  293.970449] CPU    4: hi:    0, btch:   1 usd:   0
[  293.970708] CPU    5: hi:    0, btch:   1 usd:   0
[  293.970958] CPU    6: hi:    0, btch:   1 usd:   0
[  293.971206] CPU    7: hi:    0, btch:   1 usd:   0
[  293.971450] Node 0 DMA32 per-cpu:
[  293.971674] CPU    0: hi:   90, btch:  15 usd:  19
[  293.971916] CPU    1: hi:   90, btch:  15 usd:   0
[  293.972158] CPU    2: hi:   90, btch:  15 usd:  27
[  293.972401] CPU    3: hi:   90, btch:  15 usd:  14
[  293.972643] CPU    4: hi:   90, btch:  15 usd:  83
[  293.972885] CPU    5: hi:   90, btch:  15 usd:  14
[  293.973128] CPU    6: hi:   90, btch:  15 usd:   0
[  293.973371] CPU    7: hi:   90, btch:  15 usd:   0
[  293.973615] active_anon:1452 inactive_anon:23 isolated_anon:0
[  293.973616]  active_file:257 inactive_file:1826 isolated_file:0
[  293.973616]  unevictable:0 dirty:25 writeback:0 unstable:0
[  293.973617]  free:737 slab_reclaimable:15674 slab_unreclaimable:5093
[  293.973617]  mapped:161 shmem:75 pagetables:141 bounce:0
[  293.975022] Node 0 DMA free:1040kB min:120kB low:148kB high:180kB active_anon:316kB inactive_anon:0kB active_file:4kB inactive_file:592kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:13412kB slab_unreclaimable:260kB kernel_stack:8kB pagetables:32kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:977 all_unreclaimable? yes
[  293.976677] lowmem_reserve[]: 0 236 236 236
[  293.977069] Node 0 DMA32 free:1908kB min:1904kB low:2380kB high:2856kB active_anon:5492kB inactive_anon:92kB active_file:1024kB inactive_file:6712kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:242400kB mlocked:0kB dirty:100kB writeback:0kB mapped:644kB shmem:300kB slab_reclaimable:49284kB slab_unreclaimable:20112kB kernel_stack:1024kB pagetables:532kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:13132 all_unreclaimable? yes
[  293.978822] lowmem_reserve[]: 0 0 0 0
[  293.979200] Node 0 DMA: 18*4kB 46*8kB 42*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1112kB
[  293.980138] Node 0 DMA32: 116*4kB 100*8kB 30*16kB 2*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1808kB
[  293.981088] 2303 total pagecache pages
[  293.981292] 0 pages in swap cache
[  293.981480] Swap cache stats: add 0, delete 0, find 0/0
[  293.981738] Free swap  = 0kB
[  293.981910] Total swap = 0kB
[  293.982420] 65520 pages RAM
[  293.982599] 16492 pages reserved
[  293.982790] 1432 pages shared
[  293.982970] 46580 pages non-shared
[  293.983878] dd used greatest stack depth: 2400 bytes left


--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=".config"

#
# Automatically generated make config: don't edit
# Linux/x86_64 2.6.37-rc4 Kernel Configuration
# Mon Dec  6 09:47:33 2010
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_HAVE_CPUMASK_OF_CPU_MAP=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_X86_TRAMPOLINE=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
# CONFIG_KTIME_SCALAR is not set
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_LOCK_KERNEL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ=y
# CONFIG_GENERIC_HARDIRQS_NO_DEPRECATED is not set
CONFIG_HAVE_SPARSE_IRQ=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_PENDING_IRQ=y
# CONFIG_AUTO_IRQ_AFFINITY is not set
# CONFIG_IRQ_PER_CPU is not set
# CONFIG_HARDIRQS_SW_RESEND is not set
CONFIG_SPARSE_IRQ=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_TRACE=y
CONFIG_RCU_FANOUT=64
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_RCU_FAST_NO_HZ is not set
CONFIG_TREE_RCU_TRACE=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=18
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
CONFIG_CGROUP_NS=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_RESOURCE_COUNTERS=y
CONFIG_CGROUP_MEM_RES_CTLR=y
CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED=y
# CONFIG_CGROUP_SCHED is not set
CONFIG_BLK_CGROUP=y
CONFIG_DEBUG_BLK_CGROUP=y
# CONFIG_NAMESPACES is not set
CONFIG_MM_OWNER=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_LZO is not set
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_EMBEDDED=y
CONFIG_UID16=y
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
# CONFIG_KALLSYMS_EXTRA_PASS is not set
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_PERF_COUNTERS is not set
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_OPROFILE=y
# CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_THROTTLING is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PREEMPT_NOTIFIERS=y
# CONFIG_INLINE_SPIN_TRYLOCK is not set
# CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK is not set
# CONFIG_INLINE_SPIN_LOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK_IRQ is not set
# CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
# CONFIG_INLINE_SPIN_UNLOCK is not set
# CONFIG_INLINE_SPIN_UNLOCK_BH is not set
# CONFIG_INLINE_SPIN_UNLOCK_IRQ is not set
# CONFIG_INLINE_SPIN_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_READ_TRYLOCK is not set
# CONFIG_INLINE_READ_LOCK is not set
# CONFIG_INLINE_READ_LOCK_BH is not set
# CONFIG_INLINE_READ_LOCK_IRQ is not set
# CONFIG_INLINE_READ_LOCK_IRQSAVE is not set
# CONFIG_INLINE_READ_UNLOCK is not set
# CONFIG_INLINE_READ_UNLOCK_BH is not set
# CONFIG_INLINE_READ_UNLOCK_IRQ is not set
# CONFIG_INLINE_READ_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_WRITE_TRYLOCK is not set
# CONFIG_INLINE_WRITE_LOCK is not set
# CONFIG_INLINE_WRITE_LOCK_BH is not set
# CONFIG_INLINE_WRITE_LOCK_IRQ is not set
# CONFIG_INLINE_WRITE_LOCK_IRQSAVE is not set
# CONFIG_INLINE_WRITE_UNLOCK is not set
# CONFIG_INLINE_WRITE_UNLOCK_BH is not set
# CONFIG_INLINE_WRITE_UNLOCK_IRQ is not set
# CONFIG_INLINE_WRITE_UNLOCK_IRQRESTORE is not set
# CONFIG_MUTEX_SPIN_ON_OWNER is not set
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_VSMP is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_SCHED_OMIT_FRAME_POINTER=y
CONFIG_PARAVIRT_GUEST=y
# CONFIG_XEN is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_CLOCK=y
CONFIG_KVM_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
CONFIG_MCORE2=y
# CONFIG_MATOM is not set
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=7
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_XADD=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_P6_NOP=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
CONFIG_CPU_SUP_INTEL=y
# CONFIG_CPU_SUP_AMD is not set
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
# CONFIG_CALGARY_IOMMU is not set
# CONFIG_AMD_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
# CONFIG_IOMMU_API is not set
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=64
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_X86_THERMAL_VECTOR=y
# CONFIG_I8K is not set
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
# CONFIG_K8_NUMA is not set
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
CONFIG_NUMA_EMU=y
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=999999
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_EFI=y
CONFIG_SECCOMP=y
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
# CONFIG_KEXEC_JUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
# CONFIG_PM_VERBOSE is not set
CONFIG_CAN_PM_TRACE=y
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_SLEEP=y
# CONFIG_PM_SLEEP_ADVANCED_DEBUG is not set
CONFIG_SUSPEND_NVS=y
CONFIG_SUSPEND=y
# CONFIG_PM_TEST_SUSPEND is not set
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
# CONFIG_PM_RUNTIME is not set
CONFIG_PM_OPS=y
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS=y
CONFIG_ACPI_PROCFS_POWER=y
CONFIG_ACPI_POWER_METER=y
CONFIG_ACPI_EC_DEBUGFS=y
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_DEBUG_FUNC_TRACE=y
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
CONFIG_ACPI_SBS=y
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_APEI is not set
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_DEBUG=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# CPUFreq processor drivers
#
# CONFIG_X86_PCC_CPUFREQ is not set
CONFIG_X86_ACPI_CPUFREQ=y
# CONFIG_X86_POWERNOW_K8 is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=y
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_SPEEDSTEP_LIB is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_INTEL_IDLE is not set

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_DMAR is not set
# CONFIG_INTR_REMAP is not set
CONFIG_PCIEPORTBUS=y
# CONFIG_HOTPLUG_PCI_PCIE is not set
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
# CONFIG_PCIEAER_INJECT is not set
# CONFIG_PCIEASPM is not set
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
CONFIG_PCI_IOAPIC=y
CONFIG_ISA_DMA_API=y
# CONFIG_PCCARD is not set
CONFIG_HOTPLUG_PCI=y
# CONFIG_HOTPLUG_PCI_FAKE is not set
# CONFIG_HOTPLUG_PCI_ACPI is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_SHPC is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_UNIX=y
CONFIG_XFRM=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=y
# CONFIG_NET_KEY_MIGRATE is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_FIB_HASH=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
# CONFIG_ARPD is not set
# CONFIG_SYN_COOKIES is not set
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=y
CONFIG_TCP_CONG_HTCP=y
CONFIG_TCP_CONG_HSTCP=y
CONFIG_TCP_CONG_HYBLA=y
CONFIG_TCP_CONG_VEGAS=y
CONFIG_TCP_CONG_SCALABLE=y
CONFIG_TCP_CONG_LP=y
CONFIG_TCP_CONG_VENO=y
CONFIG_TCP_CONG_YEAH=y
CONFIG_TCP_CONG_ILLINOIS=y
# CONFIG_DEFAULT_BIC is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_HYBLA is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_VENO is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IPV6 is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_NETLINK_QUEUE=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_ZONES=y
CONFIG_NF_CONNTRACK_EVENTS=y
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=y
CONFIG_NF_CT_PROTO_SCTP=y
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=y
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_CONNTRACK_H323=y
CONFIG_NF_CONNTRACK_IRC=y
CONFIG_NF_CONNTRACK_NETBIOS_NS=y
CONFIG_NF_CONNTRACK_PPTP=y
CONFIG_NF_CONNTRACK_SANE=y
CONFIG_NF_CONNTRACK_SIP=y
CONFIG_NF_CONNTRACK_TFTP=y
CONFIG_NF_CT_NETLINK=y
CONFIG_NETFILTER_TPROXY=y
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
CONFIG_NETFILTER_XT_CONNMARK=y

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=y
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
CONFIG_NETFILTER_XT_TARGET_CT=y
CONFIG_NETFILTER_XT_TARGET_DSCP=y
CONFIG_NETFILTER_XT_TARGET_HL=y
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=y
CONFIG_NETFILTER_XT_TARGET_LED=y
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
CONFIG_NETFILTER_XT_TARGET_NOTRACK=y
CONFIG_NETFILTER_XT_TARGET_RATEEST=y
CONFIG_NETFILTER_XT_TARGET_TEE=y
CONFIG_NETFILTER_XT_TARGET_TPROXY=y
CONFIG_NETFILTER_XT_TARGET_TRACE=y
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=y

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NETFILTER_XT_MATCH_CPU=y
CONFIG_NETFILTER_XT_MATCH_DCCP=y
CONFIG_NETFILTER_XT_MATCH_DSCP=y
CONFIG_NETFILTER_XT_MATCH_ESP=y
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
CONFIG_NETFILTER_XT_MATCH_MAC=y
CONFIG_NETFILTER_XT_MATCH_MARK=y
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
CONFIG_NETFILTER_XT_MATCH_OSF=y
CONFIG_NETFILTER_XT_MATCH_OWNER=y
CONFIG_NETFILTER_XT_MATCH_POLICY=y
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=y
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
CONFIG_NETFILTER_XT_MATCH_QUOTA=y
CONFIG_NETFILTER_XT_MATCH_RATEEST=y
CONFIG_NETFILTER_XT_MATCH_REALM=y
CONFIG_NETFILTER_XT_MATCH_RECENT=y
CONFIG_NETFILTER_XT_MATCH_SCTP=y
CONFIG_NETFILTER_XT_MATCH_SOCKET=y
CONFIG_NETFILTER_XT_MATCH_STATE=y
CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
CONFIG_NETFILTER_XT_MATCH_STRING=y
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
CONFIG_NETFILTER_XT_MATCH_TIME=y
CONFIG_NETFILTER_XT_MATCH_U32=y
# CONFIG_IP_VS is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
# CONFIG_IP_NF_QUEUE is not set
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_ADDRTYPE=y
CONFIG_IP_NF_MATCH_AH=y
CONFIG_IP_NF_MATCH_ECN=y
CONFIG_IP_NF_MATCH_TTL=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_LOG=y
CONFIG_IP_NF_TARGET_ULOG=y
CONFIG_NF_NAT=y
CONFIG_NF_NAT_NEEDED=y
CONFIG_IP_NF_TARGET_MASQUERADE=y
CONFIG_IP_NF_TARGET_NETMAP=y
CONFIG_IP_NF_TARGET_REDIRECT=y
CONFIG_NF_NAT_SNMP_BASIC=y
CONFIG_NF_NAT_PROTO_DCCP=y
CONFIG_NF_NAT_PROTO_GRE=y
CONFIG_NF_NAT_PROTO_UDPLITE=y
CONFIG_NF_NAT_PROTO_SCTP=y
CONFIG_NF_NAT_FTP=y
CONFIG_NF_NAT_IRC=y
CONFIG_NF_NAT_TFTP=y
CONFIG_NF_NAT_AMANDA=y
CONFIG_NF_NAT_PPTP=y
CONFIG_NF_NAT_H323=y
CONFIG_NF_NAT_SIP=y
CONFIG_IP_NF_MANGLE=y
CONFIG_IP_NF_TARGET_CLUSTERIP=y
CONFIG_IP_NF_TARGET_ECN=y
CONFIG_IP_NF_TARGET_TTL=y
CONFIG_IP_NF_RAW=y
CONFIG_IP_NF_ARPTABLES=y
CONFIG_IP_NF_ARPFILTER=y
CONFIG_IP_NF_ARP_MANGLE=y
CONFIG_BRIDGE_NF_EBTABLES=y
CONFIG_BRIDGE_EBT_BROUTE=y
CONFIG_BRIDGE_EBT_T_FILTER=y
CONFIG_BRIDGE_EBT_T_NAT=y
CONFIG_BRIDGE_EBT_802_3=y
CONFIG_BRIDGE_EBT_AMONG=y
CONFIG_BRIDGE_EBT_ARP=y
CONFIG_BRIDGE_EBT_IP=y
CONFIG_BRIDGE_EBT_LIMIT=y
CONFIG_BRIDGE_EBT_MARK=y
CONFIG_BRIDGE_EBT_PKTTYPE=y
CONFIG_BRIDGE_EBT_STP=y
CONFIG_BRIDGE_EBT_VLAN=y
CONFIG_BRIDGE_EBT_ARPREPLY=y
CONFIG_BRIDGE_EBT_DNAT=y
CONFIG_BRIDGE_EBT_MARK_T=y
CONFIG_BRIDGE_EBT_REDIRECT=y
CONFIG_BRIDGE_EBT_SNAT=y
CONFIG_BRIDGE_EBT_LOG=y
CONFIG_BRIDGE_EBT_ULOG=y
CONFIG_BRIDGE_EBT_NFLOG=y
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
CONFIG_STP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
# CONFIG_NET_SCH_CBQ is not set
# CONFIG_NET_SCH_HTB is not set
# CONFIG_NET_SCH_HFSC is not set
# CONFIG_NET_SCH_PRIO is not set
# CONFIG_NET_SCH_MULTIQ is not set
# CONFIG_NET_SCH_RED is not set
# CONFIG_NET_SCH_SFQ is not set
# CONFIG_NET_SCH_TEQL is not set
# CONFIG_NET_SCH_TBF is not set
# CONFIG_NET_SCH_GRED is not set
# CONFIG_NET_SCH_DSMARK is not set
CONFIG_NET_SCH_NETEM=y
# CONFIG_NET_SCH_DRR is not set

#
# Classification
#
# CONFIG_NET_CLS_BASIC is not set
# CONFIG_NET_CLS_TCINDEX is not set
# CONFIG_NET_CLS_ROUTE4 is not set
CONFIG_NET_CLS_ROUTE=y
# CONFIG_NET_CLS_FW is not set
# CONFIG_NET_CLS_U32 is not set
# CONFIG_NET_CLS_RSVP is not set
# CONFIG_NET_CLS_RSVP6 is not set
# CONFIG_NET_CLS_FLOW is not set
# CONFIG_NET_CLS_CGROUP is not set
# CONFIG_NET_EMATCH is not set
# CONFIG_NET_CLS_ACT is not set
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_RPS=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_NET_TCPPROBE is not set
# CONFIG_NET_DROP_MONITOR is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_WIRELESS is not set
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
# CONFIG_DEVTMPFS is not set
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=y
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_CRYPTOLOOP=y
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=65536
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=128
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
# CONFIG_ATA_OVER_ETH is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_MISC_DEVICES is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
# CONFIG_CHR_DEV_SG is not set
# CONFIG_CHR_DEV_SCH is not set
# CONFIG_SCSI_MULTI_LUN is not set
CONFIG_SCSI_CONSTANTS=y
# CONFIG_SCSI_LOGGING is not set
CONFIG_SCSI_SCAN_ASYNC=y
CONFIG_SCSI_WAIT_SCAN=m

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_ATA is not set
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SAS_LIBSAS_DEBUG=y
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
# CONFIG_ISCSI_BOOT_SYSFS is not set
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_3W_SAS is not set
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AACRAID=y
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
CONFIG_AIC7XXX_RESET_DELAY_MS=5000
# CONFIG_AIC7XXX_BUILD_FIRMWARE is not set
CONFIG_AIC7XXX_DEBUG_ENABLE=y
CONFIG_AIC7XXX_DEBUG_MASK=0
CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC7XXX_OLD=y
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=5000
# CONFIG_AIC79XX_BUILD_FIRMWARE is not set
CONFIG_AIC79XX_DEBUG_ENABLE=y
CONFIG_AIC79XX_DEBUG_MASK=0
CONFIG_AIC79XX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC94XX=y
CONFIG_AIC94XX_DEBUG=y
CONFIG_SCSI_MVSAS=y
CONFIG_SCSI_MVSAS_DEBUG=y
CONFIG_SCSI_DPT_I2O=y
CONFIG_SCSI_ADVANSYS=y
# CONFIG_SCSI_ARCMSR is not set
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
CONFIG_MEGARAID_LEGACY=y
CONFIG_MEGARAID_SAS=y
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_VMWARE_PVSCSI is not set
# CONFIG_LIBFC is not set
# CONFIG_LIBFCOE is not set
# CONFIG_FCOE is not set
# CONFIG_FCOE_FNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
CONFIG_SCSI_QLOGIC_1280=y
CONFIG_SCSI_QLA_FC=y
CONFIG_SCSI_QLA_ISCSI=y
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_BFA_FC is not set
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
# CONFIG_SATA_AHCI_PLATFORM is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_SX4 is not set
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=y
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_SVW is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_ATP867X is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RDC is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SCH is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_TOSHIBA is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
CONFIG_PATA_PLATFORM=y
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
CONFIG_ATA_GENERIC=y
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
CONFIG_MULTICORE_RAID456=y
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
CONFIG_BLK_DEV_DM=y
CONFIG_DM_DEBUG=y
CONFIG_DM_CRYPT=y
CONFIG_DM_SNAPSHOT=y
CONFIG_DM_MIRROR=y
CONFIG_DM_LOG_USERSPACE=y
CONFIG_DM_ZERO=y
CONFIG_DM_MULTIPATH=y
CONFIG_DM_MULTIPATH_QL=y
CONFIG_DM_MULTIPATH_ST=y
CONFIG_DM_DELAY=y
CONFIG_DM_UEVENT=y
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
CONFIG_FUSION_FC=y
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=y
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_DUMMY=y
# CONFIG_BONDING is not set
# CONFIG_MACVLAN is not set
# CONFIG_EQUALIZER is not set
CONFIG_TUN=y
# CONFIG_VETH is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
CONFIG_MII=y
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
CONFIG_MARVELL_PHY=y
CONFIG_DAVICOM_PHY=y
CONFIG_QSEMI_PHY=y
CONFIG_LXT_PHY=y
CONFIG_CICADA_PHY=y
CONFIG_VITESSE_PHY=y
CONFIG_SMSC_PHY=y
CONFIG_BROADCOM_PHY=y
# CONFIG_BCM63XX_PHY is not set
CONFIG_ICPLUS_PHY=y
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_MICREL_PHY is not set
# CONFIG_FIXED_PHY is not set
# CONFIG_MDIO_BITBANG is not set
CONFIG_NET_ETHERNET=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_ETHOC is not set
# CONFIG_DNET is not set
# CONFIG_NET_TULIP is not set
# CONFIG_HP100 is not set
# CONFIG_IBM_NEW_EMAC_ZMII is not set
# CONFIG_IBM_NEW_EMAC_RGMII is not set
# CONFIG_IBM_NEW_EMAC_TAH is not set
# CONFIG_IBM_NEW_EMAC_EMAC4 is not set
# CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL is not set
# CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT is not set
# CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR is not set
CONFIG_NET_PCI=y
# CONFIG_PCNET32 is not set
# CONFIG_AMD8111_ETH is not set
# CONFIG_ADAPTEC_STARFIRE is not set
# CONFIG_KSZ884X_PCI is not set
# CONFIG_B44 is not set
# CONFIG_FORCEDETH is not set
CONFIG_E100=y
# CONFIG_FEALNX is not set
# CONFIG_NATSEMI is not set
# CONFIG_NE2K_PCI is not set
CONFIG_8139CP=y
CONFIG_8139TOO=y
CONFIG_8139TOO_PIO=y
# CONFIG_8139TOO_TUNE_TWISTER is not set
# CONFIG_8139TOO_8129 is not set
# CONFIG_8139_OLD_RX_RESET is not set
# CONFIG_R6040 is not set
# CONFIG_SIS900 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC9420 is not set
# CONFIG_SUNDANCE is not set
# CONFIG_TLAN is not set
# CONFIG_KS8842 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_VIA_RHINE is not set
# CONFIG_SC92031 is not set
# CONFIG_ATL2 is not set
CONFIG_NETDEV_1000=y
CONFIG_ACENIC=y
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_DL2K=y
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_IP1000=y
CONFIG_IGB=y
CONFIG_IGB_DCA=y
CONFIG_IGBVF=y
CONFIG_NS83820=y
CONFIG_HAMACHI=y
CONFIG_YELLOWFIN=y
CONFIG_R8169=y
CONFIG_SIS190=y
CONFIG_SKGE=y
# CONFIG_SKGE_DEBUG is not set
CONFIG_SKY2=y
# CONFIG_SKY2_DEBUG is not set
CONFIG_VIA_VELOCITY=y
CONFIG_TIGON3=y
CONFIG_BNX2=y
CONFIG_CNIC=y
CONFIG_QLA3XXX=y
CONFIG_ATL1=y
CONFIG_ATL1E=y
CONFIG_ATL1C=y
CONFIG_JME=y
# CONFIG_STMMAC_ETH is not set
# CONFIG_PCH_GBE is not set
CONFIG_NETDEV_10000=y
CONFIG_MDIO=y
# CONFIG_CHELSIO_T1 is not set
CONFIG_CHELSIO_T3_DEPENDS=y
# CONFIG_CHELSIO_T3 is not set
CONFIG_CHELSIO_T4_DEPENDS=y
# CONFIG_CHELSIO_T4 is not set
CONFIG_CHELSIO_T4VF_DEPENDS=y
# CONFIG_CHELSIO_T4VF is not set
# CONFIG_ENIC is not set
CONFIG_IXGBE=y
CONFIG_IXGBE_DCA=y
# CONFIG_IXGBEVF is not set
CONFIG_IXGB=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
# CONFIG_MYRI10GE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_NIU is not set
# CONFIG_MLX4_EN is not set
# CONFIG_MLX4_CORE is not set
# CONFIG_TEHUTI is not set
# CONFIG_BNX2X is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_BNA is not set
# CONFIG_SFC is not set
# CONFIG_BE2NET is not set
# CONFIG_TR is not set
# CONFIG_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#

#
# USB Network Adapters
#
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_DM9601=y
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
CONFIG_USB_NET_GL620A=y
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
# CONFIG_USB_NET_CX82310_ETH is not set
CONFIG_USB_NET_INT51X1=y
# CONFIG_USB_IPHETH is not set
# CONFIG_USB_SIERRA_NET is not set
# CONFIG_WAN is not set

#
# CAIF transport drivers
#
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
# CONFIG_NET_FC is not set
CONFIG_NETCONSOLE=y
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_VIRTIO_NET=y
# CONFIG_VMXNET3 is not set
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
CONFIG_KEYBOARD_NEWTON=y
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
CONFIG_KEYBOARD_XTKBD=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_PCSPKR is not set
# CONFIG_INPUT_APANEL is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_UINPUT=y
# CONFIG_INPUT_WINBOND_CIR is not set
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_ADXL34X is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_DEVKMEM=y
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_N_GSM is not set
CONFIG_NOZOMI=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_NR_UARTS=16
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_CONSOLE_POLL=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_TTY_PRINTK is not set
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
# CONFIG_HW_RANDOM_AMD is not set
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_RAMOOPS is not set
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
# CONFIG_I2C_CHARDEV is not set
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_ALGOBIT=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_INTEL_MID is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_STUB is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set

#
# PPS support
#
# CONFIG_PPS is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_BQ20Z75 is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_MAX17040 is not set
CONFIG_HWMON=y
# CONFIG_HWMON_VID is not set
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_G760A is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_PKGTEMP is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP401 is not set
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_LIS3_I2C is not set
# CONFIG_SENSORS_APPLESMC is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ATK0110 is not set
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
CONFIG_WATCHDOG=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
# CONFIG_F71808E_WDT is not set
# CONFIG_SC520_WDT is not set
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
# CONFIG_IBMASR is not set
# CONFIG_WAFER_WDT is not set
# CONFIG_I6300ESB_WDT is not set
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
# CONFIG_IT8712F_WDT is not set
# CONFIG_IT87_WDT is not set
# CONFIG_HP_WATCHDOG is not set
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_W83627HF_WDT is not set
# CONFIG_W83697HF_WDT is not set
# CONFIG_W83697UG_WDT is not set
# CONFIG_W83877F_WDT is not set
# CONFIG_W83977F_WDT is not set
# CONFIG_MACHZ_WDT is not set
# CONFIG_SBC_EPX_C3_WATCHDOG is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
# CONFIG_USBPCWATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_MFD_SUPPORT=y
# CONFIG_MFD_CORE is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_TPS6507X is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_TC35892 is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_REGULATOR is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_INTEL=y
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_VIA is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_I810 is not set
# CONFIG_DRM_I830 is not set
CONFIG_DRM_I915=y
CONFIG_DRM_I915_KMS=y
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_SIS is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_STUB_POULSBO is not set
# CONFIG_VGASTATE is not set
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
# CONFIG_FB_DDC is not set
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
# CONFIG_FB_SYS_FILLRECT is not set
# CONFIG_FB_SYS_COPYAREA is not set
# CONFIG_FB_SYS_IMAGEBLIT is not set
# CONFIG_FB_FOREIGN_ENDIAN is not set
# CONFIG_FB_SYS_FOPS is not set
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
# CONFIG_FB_TILEBLITTING is not set

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
# CONFIG_FB_VESA is not set
# CONFIG_FB_EFI is not set
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_VIRTUAL is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
# CONFIG_BACKLIGHT_PROGEAR is not set
# CONFIG_BACKLIGHT_MBP_NVIDIA is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set

#
# Display device support
#
CONFIG_DISPLAY_SUPPORT=y

#
# Display hardware drivers
#

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=1024
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
# CONFIG_FRAMEBUFFER_CONSOLE_ROTATION is not set
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
# CONFIG_LOGO is not set
CONFIG_SOUND=y
# CONFIG_SOUND_OSS_CORE is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
# CONFIG_SND_MIXER_OSS is not set
# CONFIG_SND_PCM_OSS is not set
# CONFIG_SND_SEQUENCER_OSS is not set
CONFIG_SND_HRTIMER=y
CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
CONFIG_SND_DYNAMIC_MINORS=y
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_VERBOSE_PROCFS=y
CONFIG_SND_VERBOSE_PRINTK=y
CONFIG_SND_DEBUG=y
CONFIG_SND_DEBUG_VERBOSE=y
CONFIG_SND_PCM_XRUN_DEBUG=y
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
# CONFIG_SND_RAWMIDI_SEQ is not set
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
CONFIG_SND_DRIVERS=y
CONFIG_SND_PCSP=m
# CONFIG_SND_DUMMY is not set
# CONFIG_SND_ALOOP is not set
# CONFIG_SND_VIRMIDI is not set
# CONFIG_SND_MTPAV is not set
# CONFIG_SND_SERIAL_U16550 is not set
# CONFIG_SND_MPU401 is not set
CONFIG_SND_PCI=y
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
# CONFIG_SND_ALI5451 is not set
# CONFIG_SND_ASIHPI is not set
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_OXYGEN is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CS5530 is not set
# CONFIG_SND_CS5535AUDIO is not set
# CONFIG_SND_CTXFI is not set
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
# CONFIG_SND_INDIGOIOX is not set
# CONFIG_SND_INDIGODJX is not set
# CONFIG_SND_EMU10K1 is not set
# CONFIG_SND_EMU10K1X is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
CONFIG_SND_HDA_INTEL=y
CONFIG_SND_HDA_HWDEP=y
CONFIG_SND_HDA_RECONFIG=y
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=1
CONFIG_SND_HDA_INPUT_JACK=y
# CONFIG_SND_HDA_PATCH_LOADER is not set
CONFIG_SND_HDA_CODEC_REALTEK=y
CONFIG_SND_HDA_CODEC_ANALOG=y
CONFIG_SND_HDA_CODEC_SIGMATEL=y
CONFIG_SND_HDA_CODEC_VIA=y
CONFIG_SND_HDA_CODEC_HDMI=y
CONFIG_SND_HDA_CODEC_CIRRUS=y
CONFIG_SND_HDA_CODEC_CONEXANT=y
CONFIG_SND_HDA_CODEC_CA0110=y
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDA_POWER_SAVE=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_HIFIER is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
# CONFIG_SND_INTEL8X0 is not set
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_LX6464ES is not set
# CONFIG_SND_MAESTRO3 is not set
# CONFIG_SND_MIXART is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_SONICVIBES is not set
# CONFIG_SND_TRIDENT is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set
# CONFIG_SND_USB is not set
# CONFIG_SND_SOC is not set
# CONFIG_SOUND_PRIME is not set
CONFIG_HID_SUPPORT=y
CONFIG_HID=y
# CONFIG_HIDRAW is not set

#
# USB Input Devices
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
CONFIG_USB_HIDDEV=y

#
# Special HID drivers
#
# CONFIG_HID_3M_PCT is not set
# CONFIG_HID_A4TECH is not set
# CONFIG_HID_ACRUX_FF is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CANDO is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_PRODIKEYS is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EGALAX is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MOSART is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_NTRIG is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_QUANTA is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_ROCCAT_KONE is not set
# CONFIG_HID_ROCCAT_PYRA is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SONY is not set
# CONFIG_HID_STANTUM is not set
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=y
CONFIG_USB_DEBUG=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=y
# CONFIG_USB_DEVICE_CLASS is not set
CONFIG_USB_DYNAMIC_MINORS=y
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_MON is not set
# CONFIG_USB_WUSB is not set
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_WHCI_HCD is not set
# CONFIG_USB_HWA_HCD is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
CONFIG_USB_STORAGE_ISD200=y
CONFIG_USB_STORAGE_USBAT=y
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
CONFIG_USB_STORAGE_ONETOUCH=y
CONFIG_USB_STORAGE_KARMA=y
CONFIG_USB_STORAGE_CYPRESS_ATACB=y
# CONFIG_USB_UAS is not set
CONFIG_USB_LIBUSUAL=y

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set

#
# USB port drivers
#
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_CONSOLE=y
# CONFIG_USB_EZUSB is not set
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_AIRCABLE is not set
# CONFIG_USB_SERIAL_ARK3116 is not set
CONFIG_USB_SERIAL_BELKIN=y
# CONFIG_USB_SERIAL_CH341 is not set
# CONFIG_USB_SERIAL_WHITEHEAT is not set
# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
# CONFIG_USB_SERIAL_CP210X is not set
# CONFIG_USB_SERIAL_CYPRESS_M8 is not set
# CONFIG_USB_SERIAL_EMPEG is not set
# CONFIG_USB_SERIAL_FTDI_SIO is not set
# CONFIG_USB_SERIAL_FUNSOFT is not set
# CONFIG_USB_SERIAL_VISOR is not set
# CONFIG_USB_SERIAL_IPAQ is not set
# CONFIG_USB_SERIAL_IR is not set
# CONFIG_USB_SERIAL_EDGEPORT is not set
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
# CONFIG_USB_SERIAL_GARMIN is not set
# CONFIG_USB_SERIAL_IPW is not set
# CONFIG_USB_SERIAL_IUU is not set
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
# CONFIG_USB_SERIAL_KEYSPAN is not set
# CONFIG_USB_SERIAL_KLSI is not set
# CONFIG_USB_SERIAL_KOBIL_SCT is not set
# CONFIG_USB_SERIAL_MCT_U232 is not set
# CONFIG_USB_SERIAL_MOS7720 is not set
# CONFIG_USB_SERIAL_MOS7840 is not set
# CONFIG_USB_SERIAL_MOTOROLA is not set
# CONFIG_USB_SERIAL_NAVMAN is not set
# CONFIG_USB_SERIAL_PL2303 is not set
# CONFIG_USB_SERIAL_OTI6858 is not set
# CONFIG_USB_SERIAL_QCAUX is not set
# CONFIG_USB_SERIAL_QUALCOMM is not set
# CONFIG_USB_SERIAL_SPCP8X5 is not set
# CONFIG_USB_SERIAL_HP4X is not set
# CONFIG_USB_SERIAL_SAFE is not set
# CONFIG_USB_SERIAL_SAMBA is not set
# CONFIG_USB_SERIAL_SIEMENS_MPI is not set
# CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
# CONFIG_USB_SERIAL_SYMBOL is not set
# CONFIG_USB_SERIAL_TI is not set
# CONFIG_USB_SERIAL_CYBERJACK is not set
# CONFIG_USB_SERIAL_XIRCOM is not set
# CONFIG_USB_SERIAL_OPTION is not set
# CONFIG_USB_SERIAL_OMNINET is not set
# CONFIG_USB_SERIAL_OPTICON is not set
# CONFIG_USB_SERIAL_VIVOPAY_SERIAL is not set
# CONFIG_USB_SERIAL_ZIO is not set
# CONFIG_USB_SERIAL_SSU100 is not set
# CONFIG_USB_SERIAL_DEBUG is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_ALIX2 is not set
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_LP3944 is not set
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_CLEVO_MAIL is not set
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_INTEL_SS4200 is not set
# CONFIG_LEDS_DELL_NETBOOKS is not set
CONFIG_LEDS_TRIGGERS=y

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGER_TIMER is not set
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_DS1307 is not set
# CONFIG_RTC_DRV_DS1374 is not set
# CONFIG_RTC_DRV_DS1672 is not set
# CONFIG_RTC_DRV_DS3232 is not set
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
# CONFIG_RTC_DRV_ISL12022 is not set
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
# CONFIG_RTC_DRV_M41T80 is not set
# CONFIG_RTC_DRV_BQ32K is not set
# CONFIG_RTC_DRV_S35390A is not set
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8581 is not set
# CONFIG_RTC_DRV_RX8025 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_MSM6242 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
# CONFIG_RTC_DRV_RP5C01 is not set
# CONFIG_RTC_DRV_V3020 is not set

#
# on-CPU RTC drivers
#
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
CONFIG_INTEL_IOATDMA=y
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
# CONFIG_NET_DMA is not set
# CONFIG_ASYNC_TX_DMA is not set
# CONFIG_DMATEST is not set
CONFIG_DCA=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
# CONFIG_UIO_PDRV is not set
# CONFIG_UIO_PDRV_GENIRQ is not set
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_WMI=y
# CONFIG_FUJITSU_LAPTOP is not set
CONFIG_HP_WMI=y
# CONFIG_PANASONIC_LAPTOP is not set
CONFIG_THINKPAD_ACPI=y
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
CONFIG_EEEPC_LAPTOP=y
# CONFIG_EEEPC_WMI is not set
CONFIG_ACPI_WMI=y
# CONFIG_MSI_WMI is not set
# CONFIG_ACPI_ASUS is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_ACPI_TOSHIBA is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_EFI_VARS is not set
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y
# CONFIG_ISCSI_IBFT_FIND is not set

#
# File systems
#
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
# CONFIG_EXT2_FS_SECURITY is not set
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_XATTR=y
# CONFIG_EXT4_FS_POSIX_ACL is not set
# CONFIG_EXT4_FS_SECURITY is not set
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
CONFIG_REISERFS_PROC_INFO=y
# CONFIG_REISERFS_FS_XATTR is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
# CONFIG_JFS_SECURITY is not set
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_XFS_FS=y
# CONFIG_XFS_QUOTA is not set
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
# CONFIG_XFS_DEBUG is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
# CONFIG_BTRFS_FS_POSIX_ACL is not set
# CONFIG_NILFS2_FS is not set
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
# CONFIG_ZISOFS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
# CONFIG_MSDOS_FS is not set
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_LOGFS is not set
CONFIG_CRAMFS=y
# CONFIG_SQUASHFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_ROMFS_FS is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
# CONFIG_NFS_V4 is not set
CONFIG_ROOT_NFS=y
CONFIG_NFSD=y
CONFIG_NFSD_DEPRECATED=y
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
# CONFIG_NFSD_V4 is not set
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
# CONFIG_RPCSEC_GSS_KRB5 is not set
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=y
CONFIG_CIFS_STATS=y
CONFIG_CIFS_STATS2=y
# CONFIG_CIFS_WEAK_PW_HASH is not set
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
CONFIG_CIFS_DEBUG2=y
# CONFIG_CIFS_EXPERIMENTAL is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_SHIRQ=y
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_HARDLOCKUP_DETECTOR is not set
CONFIG_DETECT_HUNG_TASK=y
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
CONFIG_DEBUG_OBJECTS_FREE=y
CONFIG_DEBUG_OBJECTS_TIMERS=y
# CONFIG_DEBUG_OBJECTS_WORK is not set
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_SLUB_DEBUG_ON is not set
CONFIG_SLUB_STATS=y
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_BKL=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
# CONFIG_PROVE_RCU is not set
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_DEBUG_SPINLOCK_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_INFO=y
# CONFIG_DEBUG_INFO_REDUCED is not set
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_WRITECOUNT=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_LIST=y
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_CPU_STALL_DETECTOR is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_LKDTM is not set
# CONFIG_CPU_NOTIFIER_ERROR_INJECT is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
CONFIG_FAIL_PAGE_ALLOC=y
CONFIG_FAIL_MAKE_REQUEST=y
# CONFIG_FAIL_IO_TIMEOUT is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
CONFIG_LATENCYTOP=y
CONFIG_SYSCTL_SYSCALL_CHECK=y
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FTRACE_NMI_ENTER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_RING_BUFFER=y
CONFIG_FTRACE_NMI_ENTER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
CONFIG_IRQSOFF_TRACER=y
CONFIG_SCHED_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENT=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_FUNCTION_PROFILER=y
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
CONFIG_MMIOTRACE=y
CONFIG_MMIOTRACE_TEST=m
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DYNAMIC_DEBUG is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
CONFIG_KGDB=y
CONFIG_KGDB_SERIAL_CONSOLE=y
# CONFIG_KGDB_TESTS is not set
# CONFIG_KGDB_LOW_LEVEL_TRAP is not set
# CONFIG_KGDB_KDB is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_PER_CPU_MAPS is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA is not set
# CONFIG_DEBUG_NX_TEST is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_X86_DECODER_SELFTEST is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
CONFIG_ASYNC_TX_DISABLE_PQ_VAL_DMA=y
CONFIG_ASYNC_TX_DISABLE_XOR_VAL_DMA=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
# CONFIG_CRYPTO_GF128MUL is not set
CONFIG_CRYPTO_NULL=y
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
# CONFIG_CRYPTO_CRYPTD is not set
CONFIG_CRYPTO_AUTHENC=y
# CONFIG_CRYPTO_TEST is not set

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
# CONFIG_CRYPTO_SEQIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_CTR is not set
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=y
# CONFIG_CRYPTO_LRW is not set
# CONFIG_CRYPTO_PCBC is not set
# CONFIG_CRYPTO_XTS is not set

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
# CONFIG_CRYPTO_GHASH is not set
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA256 is not set
# CONFIG_CRYPTO_SHA512 is not set
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_X86_64 is not set
# CONFIG_CRYPTO_AES_NI_INTEL is not set
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_CAMELLIA is not set
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST6 is not set
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
# CONFIG_CRYPTO_SEED is not set
# CONFIG_CRYPTO_SERPENT is not set
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_TWOFISH is not set
# CONFIG_CRYPTO_TWOFISH_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_ZLIB is not set
# CONFIG_CRYPTO_LZO is not set

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
# CONFIG_CRYPTO_DEV_HIFN_795X is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
# CONFIG_KVM_AMD is not set
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_VHOST_NET=y
CONFIG_VIRTIO=y
CONFIG_VIRTIO_RING=y
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_FIND_NEXT_BIT=y
CONFIG_GENERIC_FIND_LAST_BIT=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_TEXTSEARCH_BM=y
CONFIG_TEXTSEARCH_FSM=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_NLATTR=y

--pWyiEgJYm5f9v55/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
