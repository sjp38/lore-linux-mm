Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A42956B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 22:16:22 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so159132rvb.26
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 19:16:50 -0700 (PDT)
Date: Wed, 1 Jul 2009 10:16:45 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: Found the commit that causes the OOMs
Message-ID: <20090701021645.GA6356@localhost>
References: <1246291007.663.630.camel@macbook.infradead.org> <20090630140512.GA16923@localhost> <20090701094446.85C8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090701094446.85C8.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 01, 2009 at 10:18:03AM +0900, KOSAKI Motohiro wrote:
> > On Mon, Jun 29, 2009 at 11:56:47PM +0800, David Woodhouse wrote:
> > > On Mon, 2009-06-29 at 16:54 +0100, David Howells wrote:
> > > > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > >
> > > > > Yes this time the OOM order/flags are much different from all previous OOMs.
> > > > >
> > > > > btw, I found that msgctl11 is pretty good at making a lot of SUnreclaim and
> > > > > PageTables pages:
> > > >
> > > > I got David Woodhouse to run this on one of this boxes, but he doesn't see the
> > > > problem, I think because he's got 4GB of RAM, and never comes close to running
> > > > out.
> > > >
> > > > I've asked him to reboot with mem=1G to see if that helps reproduce it.
> > >
> > > msgctl11 invoked oom-killer: gfp_mask=0xd0, order=1, oom_adj=0
> > > Pid: 5795, comm: msgctl11 Not tainted 2.6.31-rc1 #147
> > > Call Trace:
> > >  [<ffffffff81092c77>] oom_kill_process.clone.0+0xac/0x254
> > >  [<ffffffff81092b5c>] ? badness+0x24d/0x2bc
> > >  [<ffffffff81092f5f>] __out_of_memory+0x140/0x157
> > >  [<ffffffff8109308f>] out_of_memory+0x119/0x150
> > >  [<ffffffff81095c65>] ? drain_local_pages+0x16/0x18
> > >  [<ffffffff810967ab>] __alloc_pages_nodemask+0x45a/0x55b
> > >  [<ffffffff810a32b0>] ? __inc_zone_page_state+0x2e/0x30
> > >  [<ffffffff810bb6b9>] alloc_pages_current+0xae/0xb6
> > >  [<ffffffff810a604a>] ? do_wp_page+0x621/0x6c3
> > >  [<ffffffff81094d7e>] __get_free_pages+0xe/0x4b
> > >  [<ffffffff810403a7>] copy_process+0xab/0x11a5
> > >  [<ffffffff810327c8>] ? check_preempt_wakeup+0x11a/0x142
> > >  [<ffffffff810a7a06>] ? handle_mm_fault+0x678/0x6e9
> > >  [<ffffffff810415ec>] do_fork+0x14b/0x338
> > >  [<ffffffff8105b50a>] ? up_read+0xe/0x10
> > >  [<ffffffff814ee655>] ? do_page_fault+0x2da/0x307
> > >  [<ffffffff8100a55c>] sys_clone+0x28/0x2a
> > >  [<ffffffff8100bfc3>] stub_clone+0x13/0x20
> > >  [<ffffffff8100bcdb>] ? system_call_fastpath+0x16/0x1b
> > > Mem-Info:
> > > Node 0 DMA per-cpu:
> > > CPU    0: hi:    0, btch:   1 usd:   0
> > > CPU    1: hi:    0, btch:   1 usd:   0
> > > CPU    2: hi:    0, btch:   1 usd:   0
> > > CPU    3: hi:    0, btch:   1 usd:   0
> > > CPU    4: hi:    0, btch:   1 usd:   0
> > > CPU    5: hi:    0, btch:   1 usd:   0
> > > CPU    6: hi:    0, btch:   1 usd:   0
> > > CPU    7: hi:    0, btch:   1 usd:   0
> > > Node 0 DMA32 per-cpu:
> > > CPU    0: hi:  186, btch:  31 usd:   0
> > > CPU    1: hi:  186, btch:  31 usd:  20
> > > CPU    2: hi:  186, btch:  31 usd:  19
> > > CPU    3: hi:  186, btch:  31 usd:  20
> > > CPU    4: hi:  186, btch:  31 usd:  19
> > > CPU    5: hi:  186, btch:  31 usd:  24
> > > CPU    6: hi:  186, btch:  31 usd:  41
> > > CPU    7: hi:  186, btch:  31 usd:  25
> > > Active_anon:72835 active_file:89 inactive_anon:575
> > >  inactive_file:103 unevictable:0 dirty:36 writeback:0 unstable:0
> > >  free:2467 slab:38211 mapped:229 pagetables:66918 bounce:0
> > > Node 0 DMA free:4036kB min:60kB low:72kB high:88kB active_anon:3228kB inactive_a
> > > non:256kB active_file:0kB inactive_file:0kB unevictable:0kB present:15356kB page
> > > s_scanned:0 all_unreclaimable? no
> > > lowmem_reserve[]: 0 994 994 994
> > > Node 0 DMA32 free:5832kB min:4000kB low:5000kB high:6000kB active_anon:288112kB
> > > inactive_anon:2044kB active_file:356kB inactive_file:412kB unevictable:0kB prese
> > > nt:1018080kB pages_scanned:0 all_unreclaimable? no
> > > lowmem_reserve[]: 0 0 0 0
> > > Node 0 DMA: 1*4kB 2*8kB 1*16kB 0*32kB 1*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 1*
> > > 2048kB 0*4096kB = 3940kB
> > > Node 0 DMA32: 852*4kB 1*8kB 0*16kB 1*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024k
> > > B 0*2048kB 0*4096kB = 5304kB
> > > 437 total pagecache pages
> > > 0 pages in swap cache
> > > Swap cache stats: add 0, delete 0, find 0/0
> > > Free swap  = 0kB
> > > Total swap = 0kB
> > > 262144 pages RAM
> > > 6503 pages reserved
> > > 205864 pages shared
> > > 226536 pages non-shared
> > > Out of memory: kill process 3855 (msgctl11) score 179248 or a child
> > > Killed process 4222 (msgctl11)
> > 
> > More data: I boot 2.6.30-rc1 with mem=1G and enabled 1GB swap and run msgctl11.
> > 
> > It goes OOM at the 2nd run. They are very interesting numbers: memory leaked?
> > 
> >         [ 2259.825958] msgctl11 invoked oom-killer: gfp_mask=0x84d0, order=0, oom_adj=0
> >         [ 2259.828092] Pid: 29657, comm: msgctl11 Not tainted 2.6.31-rc1 #22
> >         [ 2259.830505] Call Trace:
> >         [ 2259.832010]  [<ffffffff8156f366>] ? _spin_unlock+0x26/0x30
> >         [ 2259.834219]  [<ffffffff810c8b26>] oom_kill_process+0x176/0x270
> >         [ 2259.837603]  [<ffffffff810c8def>] ? badness+0x18f/0x300
> >         [ 2259.839906]  [<ffffffff810c9095>] __out_of_memory+0x135/0x170
> >         [ 2259.842035]  [<ffffffff810c91c5>] out_of_memory+0xf5/0x180
> >         [ 2259.844270]  [<ffffffff810cd86c>] __alloc_pages_nodemask+0x6ac/0x6c0
> >         [ 2259.846743]  [<ffffffff810f8fa8>] alloc_pages_current+0x78/0x100
> >         [ 2259.849083]  [<ffffffff81033515>] pte_alloc_one+0x15/0x50
> >         [ 2259.851282]  [<ffffffff810e0eda>] __pte_alloc+0x2a/0xf0
> >         [ 2259.853454]  [<ffffffff810e16e2>] handle_mm_fault+0x742/0x830
> >         [ 2259.855793]  [<ffffffff815725cb>] do_page_fault+0x1cb/0x330
> >         [ 2259.858033]  [<ffffffff8156fdf5>] page_fault+0x25/0x30
> >         [ 2259.860301] Mem-Info:
> >         [ 2259.861706] Node 0 DMA per-cpu:
> >         [ 2259.862523] CPU    0: hi:    0, btch:   1 usd:   0
> >         [ 2259.864454] CPU    1: hi:    0, btch:   1 usd:   0
> >         [ 2259.866608] Node 0 DMA32 per-cpu:
> >         [ 2259.867404] CPU    0: hi:  186, btch:  31 usd: 197
> >         [ 2259.869283] CPU    1: hi:  186, btch:  31 usd: 175
> >         [ 2259.870511] Active_anon:0 active_file:11 inactive_anon:0
> > 
> > zero anon pages!
> >
> >        [ 2259.870512]  inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
> >        [ 2259.870513]  free:1986 slab:42170 mapped:96 pagetables:59427 bounce:0
> 
> I bet this is NOT zero. it only hidden. 

Yes, very likely! I noticed that it's all about direct scans:

pgscan_kswapd_dma 0
pgscan_kswapd_dma32 0
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_dma32 7295
pgscan_direct_normal 143810
pgscan_direct_movable 0
zone_reclaim_failed 0

> I guess this system's memory usage is,
>    pagetables: 60k pages
>    kernel stack: 60k pages
>    anon (hidden): 60k pages
>    slab: 40k pages
>    other: 30k pages
>    ===================
>    total: 250k pages = 1GB
> 
> What is "hidden" anon pages?
> each shrink_{in}active_list isolate 32 pages from lru. it mean anon or file lru
> accounting decrease temporary.
> 
> if system have plenty thread or process, heavy memory pressure makes 
> #-of-thread x 32pages isolation.
> 
> msgctl11 makes >10K processes.

More exactly, ~16K processes:

        msgctl11    0  INFO  :  Using upto 16298 pids

So the maximum number of isolated pages is 16K * 32 = 512K, or 2GiB.

> I have debugging patch for this case.
> Wu, Can you please try this patch?

OK. But the OOM is not quite reproducible. Sometimes it produces these
messages:

[  480.921813] INFO: task msgctl11:21576 blocked for more than 120 seconds.
[  480.923604] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  480.926330] msgctl11      D ffffffff8180e650  5992 21576  20749 0x00000000
[  480.929877]  ffff880020c87dd8 0000000000000046 0000000000000000 0000000000000046
[  480.933694]  ffff880020c87d48 00000000001d2d80 000000000000cec8 ffff88000d8f8000
[  480.936458]  ffff880034822280 ffff88000d8f8380 0000000020c87d88 ffffffff8107d5d8
[  480.941100] Call Trace:
[  480.941706]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[  480.943798]  [<ffffffff8158db60>] ? _spin_unlock_irq+0x30/0x40
[  480.946098]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  480.948623]  [<ffffffff8158d535>] __down_write_nested+0x85/0xc0
[  480.950960]  [<ffffffff8158d57b>] __down_write+0xb/0x10
[  480.953102]  [<ffffffff8158c76d>] down_write+0x6d/0x90
[  480.955276]  [<ffffffff8126d88d>] ? ipcctl_pre_down+0x3d/0x150
[  480.957637]  [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  480.959897]  [<ffffffff8126f04e>] sys_msgctl+0xbe/0x5a0
[  480.962024]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[  480.964177]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[  480.966438]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  480.968996]  [<ffffffff8158d66e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  480.971421]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[  480.974826] 1 lock held by msgctl11/21576:
[  480.976828]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  480.980709] INFO: task msgctl11:21602 blocked for more than 120 seconds.
[  480.983198] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  480.985973] msgctl11      D ffffffff8180e650  5992 21602  20749 0x00000000
[  480.988581]  ffff88001fea7dd8 0000000000000046 0000000000000000 0000000000000046
[  480.992378]  ffff88001fea7d48 00000000001d2d80 000000000000cec8 ffff88002db02280
[  480.996046]  ffff88000f0b0000 ffff88002db02600 000000011fea7d88 ffffffff8107d5d8
[  480.998791] Call Trace:
[  481.000111]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[  481.002636]  [<ffffffff8158db60>] ? _spin_unlock_irq+0x30/0x40
[  481.004775]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.007406]  [<ffffffff8158d535>] __down_write_nested+0x85/0xc0
[  481.009474]  [<ffffffff8158d57b>] __down_write+0xb/0x10
[  481.011810]  [<ffffffff8158c76d>] down_write+0x6d/0x90
[  481.013932]  [<ffffffff8126d88d>] ? ipcctl_pre_down+0x3d/0x150
[  481.016245]  [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.018489]  [<ffffffff8126f04e>] sys_msgctl+0xbe/0x5a0
[  481.020638]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[  481.022885]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[  481.025086]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.027644]  [<ffffffff8158d66e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  481.030087]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[  481.032424] 1 lock held by msgctl11/21602:
[  481.034358]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.038314] INFO: task msgctl11:21603 blocked for more than 120 seconds.
[  481.040852] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  481.043573] msgctl11      D ffffffff8180e650  5992 21603  20749 0x00000000
[  481.048159]  ffff88003e051dd8 0000000000000046 0000000000000000 0000000000000046
[  481.051955]  ffff88003e051d48 00000000001d2d80 000000000000cec8 ffff88002db04500
[  481.054755]  ffff88003842a280 ffff88002db04880 000000013e051d88 ffffffff8107d5d8
[  481.058423] Call Trace:
[  481.059062]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[  481.061049]  [<ffffffff8158db60>] ? _spin_unlock_irq+0x30/0x40
[  481.063352]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.065890]  [<ffffffff8158d535>] __down_write_nested+0x85/0xc0
[  481.068213]  [<ffffffff8158d57b>] __down_write+0xb/0x10
[  481.070388]  [<ffffffff8158c76d>] down_write+0x6d/0x90
[  481.072531]  [<ffffffff8126d88d>] ? ipcctl_pre_down+0x3d/0x150
[  481.074918]  [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.077266]  [<ffffffff8126f04e>] sys_msgctl+0xbe/0x5a0
[  481.079328]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[  481.081413]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[  481.084243]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.086253]  [<ffffffff8158d66e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  481.088653]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[  481.093086] 1 lock held by msgctl11/21603:
[  481.095000]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.099994] INFO: task msgctl11:21604 blocked for more than 120 seconds.
[  481.102728] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  481.105238] msgctl11      D ffffffff8180e650  6024 21604  20749 0x00000000
[  481.108100]  ffff88001d8dddd8 0000000000000046 0000000000000000 0000000000000046
[  481.111671]  ffff88001d8ddd48 00000000001d2d80 000000000000cec8 ffff8800261e8000
[  481.115274]  ffff880011da2280 ffff8800261e8380 000000011d8ddd88 ffffffff8107d5d8
[  481.118169] Call Trace:
[  481.119356]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[  481.121621]  [<ffffffff8158db60>] ? _spin_unlock_irq+0x30/0x40
[  481.125037]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.127587]  [<ffffffff8158d535>] __down_write_nested+0x85/0xc0
[  481.129854]  [<ffffffff8158d57b>] __down_write+0xb/0x10
[  481.132100]  [<ffffffff8158c76d>] down_write+0x6d/0x90
[  481.134228]  [<ffffffff8126d88d>] ? ipcctl_pre_down+0x3d/0x150
[  481.136518]  [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.138748]  [<ffffffff8126f04e>] sys_msgctl+0xbe/0x5a0
[  481.140988]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[  481.143146]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[  481.145382]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.147988]  [<ffffffff8158d66e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  481.150339]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[  481.152653] 1 lock held by msgctl11/21604:
[  481.154622]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.158578] INFO: task msgctl11:21605 blocked for more than 120 seconds.
[  481.161122] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  481.163820] msgctl11      D ffffffff8180e650  5992 21605  20749 0x00000000
[  481.167579]  ffff88003ac9bdd8 0000000000000046 0000000000000000 0000000000000046
[  481.171269]  ffff88003ac9bd48 00000000001d2d80 000000000000cec8 ffff8800261ea280
[  481.174033]  ffff88001b18c500 ffff8800261ea600 000000003ac9bd88 ffffffff8107d5d8
[  481.177742] Call Trace:
[  481.178353]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[  481.180308]  [<ffffffff8158db60>] ? _spin_unlock_irq+0x30/0x40
[  481.182594]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.185166]  [<ffffffff8158d535>] __down_write_nested+0x85/0xc0
[  481.187611]  [<ffffffff8158d57b>] __down_write+0xb/0x10
[  481.189586]  [<ffffffff8158c76d>] down_write+0x6d/0x90
[  481.191787]  [<ffffffff8126d88d>] ? ipcctl_pre_down+0x3d/0x150
[  481.194182]  [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.196414]  [<ffffffff8126f04e>] sys_msgctl+0xbe/0x5a0
[  481.198593]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[  481.200719]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[  481.203212]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.205518]  [<ffffffff8158d66e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  481.208072]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[  481.211357] 1 lock held by msgctl11/21605:
[  481.213263]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.217340] INFO: task msgctl11:21606 blocked for more than 120 seconds.
[  481.219787] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  481.222503] msgctl11      D ffffffff8180e650  5992 21606  20749 0x00000000
[  481.225146]  ffff88003c46fdd8 0000000000000046 0000000000000000 0000000000000046
[  481.228946]  ffff88003c46fd48 00000000001d2d80 000000000000cec8 ffff8800261ec500
[  481.233527]  ffff88000d524500 ffff8800261ec880 000000003c46fd88 ffffffff8107d5d8
[  481.236324] Call Trace:
[  481.237669]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[  481.239944]  [<ffffffff8158db60>] ? _spin_unlock_irq+0x30/0x40
[  481.242294]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.244740]  [<ffffffff8158d535>] __down_write_nested+0x85/0xc0
[  481.247035]  [<ffffffff8158d57b>] __down_write+0xb/0x10
[  481.249302]  [<ffffffff8158c76d>] down_write+0x6d/0x90
[  481.251494]  [<ffffffff8126d88d>] ? ipcctl_pre_down+0x3d/0x150
[  481.253789]  [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.255967]  [<ffffffff8126f04e>] sys_msgctl+0xbe/0x5a0
[  481.259279]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[  481.261388]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[  481.263678]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.266087]  [<ffffffff8158d66e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  481.269651]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[  481.271956] 1 lock held by msgctl11/21606:
[  481.273861]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.277914] INFO: task msgctl11:21607 blocked for more than 120 seconds.
[  481.280416] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  481.283078] msgctl11      D ffffffff8180e650  5992 21607  20749 0x00000000
[  481.286706]  ffff880037541dd8 0000000000000046 0000000000000000 0000000000000046
[  481.290514]  ffff880037541d48 00000000001d2d80 000000000000cec8 ffff880032778000
[  481.293299]  ffff880026138000 ffff880032778380 0000000037541d88 ffffffff8107d5d8
[  481.296913] Call Trace:
[  481.297602]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[  481.299598]  [<ffffffff8158db60>] ? _spin_unlock_irq+0x30/0x40
[  481.301883]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.304459]  [<ffffffff8158d535>] __down_write_nested+0x85/0xc0
[  481.307723]  [<ffffffff8158d57b>] __down_write+0xb/0x10
[  481.309897]  [<ffffffff8158c76d>] down_write+0x6d/0x90
[  481.312082]  [<ffffffff8126d88d>] ? ipcctl_pre_down+0x3d/0x150
[  481.314457]  [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.316683]  [<ffffffff8126f04e>] sys_msgctl+0xbe/0x5a0
[  481.318874]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[  481.320968]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[  481.323255]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.325778]  [<ffffffff8158d66e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  481.328244]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[  481.330614] 1 lock held by msgctl11/21607:
[  481.332534]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.336512] INFO: task msgctl11:21608 blocked for more than 120 seconds.
[  481.338992] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  481.341831] msgctl11      D ffffffff8180e650  5992 21608  20749 0x00000000
[  481.344388]  ffff880037543dd8 0000000000000046 0000000000000000 0000000000000046
[  481.349179]  ffff880037543d48 00000000001d2d80 000000000000cec8 ffff88003277a280
[  481.352782]  ffff8800238a4500 ffff88003277a600 0000000037543d88 ffffffff8107d5d8
[  481.355573] Call Trace:
[  481.356895]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[  481.359168]  [<ffffffff8158db60>] ? _spin_unlock_irq+0x30/0x40
[  481.361546]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.364026]  [<ffffffff8158d535>] __down_write_nested+0x85/0xc0
[  481.366314]  [<ffffffff8158d57b>] __down_write+0xb/0x10
[  481.369593]  [<ffffffff8158c76d>] down_write+0x6d/0x90
[  481.371761]  [<ffffffff8126d88d>] ? ipcctl_pre_down+0x3d/0x150
[  481.374024]  [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.376267]  [<ffffffff8126f04e>] sys_msgctl+0xbe/0x5a0
[  481.379570]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[  481.381661]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[  481.383910]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.386391]  [<ffffffff8158d66e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  481.389858]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[  481.392210] 1 lock held by msgctl11/21608:
[  481.394137]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.398198] INFO: task msgctl11:21609 blocked for more than 120 seconds.
[  481.400671] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  481.403631] msgctl11      D ffffffff8180e650  5992 21609  20749 0x00000000
[  481.406951]  ffff88002987bdd8 0000000000000046 0000000000000000 0000000000000046
[  481.410783]  ffff88002987bd48 00000000001d2d80 000000000000cec8 ffff88003277c500
[  481.413558]  ffff880038d40000 ffff88003277c880 000000002987bd88 ffffffff8107d5d8
[  481.417817] Call Trace:
[  481.418735]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[  481.421819]  [<ffffffff8158db60>] ? _spin_unlock_irq+0x30/0x40
[  481.424177]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.426707]  [<ffffffff8158d535>] __down_write_nested+0x85/0xc0
[  481.429080]  [<ffffffff8158d57b>] __down_write+0xb/0x10
[  481.431200]  [<ffffffff8158c76d>] down_write+0x6d/0x90
[  481.433302]  [<ffffffff8126d88d>] ? ipcctl_pre_down+0x3d/0x150
[  481.435736]  [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.437966]  [<ffffffff8126f04e>] sys_msgctl+0xbe/0x5a0
[  481.440139]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[  481.442243]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[  481.444473]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.447078]  [<ffffffff8158d66e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  481.449563]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[  481.451897] 1 lock held by msgctl11/21609:
[  481.453829]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.457796] INFO: task msgctl11:21611 blocked for more than 120 seconds.
[  481.460287] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  481.463045] msgctl11      D ffffffff8180e650  5992 21611  20749 0x00000000
[  481.465725]  ffff88001a45fdd8 0000000000000046 0000000000000000 0000000000000046
[  481.469609]  ffff88001a45fd48 00000000001d2d80 000000000000cec8 ffff8800238e2280
[  481.473053]  ffff88001edd0000 ffff8800238e2600 000000011a45fd88 ffffffff8107d5d8
[  481.475887] Call Trace:
[  481.477197]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[  481.479530]  [<ffffffff8158db60>] ? _spin_unlock_irq+0x30/0x40
[  481.481820]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.484352]  [<ffffffff8158d535>] __down_write_nested+0x85/0xc0
[  481.486579]  [<ffffffff8158d57b>] __down_write+0xb/0x10
[  481.488980]  [<ffffffff8158c76d>] down_write+0x6d/0x90
[  481.491034]  [<ffffffff8126d88d>] ? ipcctl_pre_down+0x3d/0x150
[  481.493963]  [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150
[  481.495567]  [<ffffffff8126f04e>] sys_msgctl+0xbe/0x5a0
[  481.497803]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[  481.499943]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[  481.502171]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[  481.504634]  [<ffffffff8158d66e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  481.507161]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[  481.509674] 1 lock held by msgctl11/21611:
[  481.511401]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126d88d>] ipcctl_pre_down+0x3d/0x150

> if my guess is correct, we need to implement #-of-reclaim-process throttling
> mechanism.
> 
> ============================================
> If the system have plenty thread,  concurrent reclaim can isolate very much pages.
> Unfortunately, current /proc/meminfo and OOM log can't show it.
> 
> Machine
>   IA64 x8 CPU
>   MEM 8GB
> 
> reproduce way
> 
> % ./hackbench 140 process 1000
>    => couse OOM
> 
> Active_anon:203 active_file:91 inactive_anon:104
>  inactive_file:76 unevictable:0 dirty:0 writeback:72 unstable:0
>  free:168 slab:4968 mapped:136 pagetables:28203 bounce:0
>  isolate:49088
>              ^^^^
> 
> ---
>  fs/proc/meminfo.c      |    6 ++++--
>  include/linux/mmzone.h |    1 +
>  mm/page_alloc.c        |    6 ++++--
>  mm/vmscan.c            |    5 +++++
>  mm/vmstat.c            |    1 +
>  5 files changed, 15 insertions(+), 4 deletions(-)
> 
> Index: b/fs/proc/meminfo.c
> ===================================================================
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -95,7 +95,8 @@ static int meminfo_proc_show(struct seq_
>  		"Committed_AS:   %8lu kB\n"
>  		"VmallocTotal:   %8lu kB\n"
>  		"VmallocUsed:    %8lu kB\n"
> -		"VmallocChunk:   %8lu kB\n",
> +		"VmallocChunk:   %8lu kB\n"
> +		"IsolatePages:   %8lu kB\n",
>  		K(i.totalram),
>  		K(i.freeram),
>  		K(i.bufferram),
> @@ -139,7 +140,8 @@ static int meminfo_proc_show(struct seq_
>  		K(committed),
>  		(unsigned long)VMALLOC_TOTAL >> 10,
>  		vmi.used >> 10,
> -		vmi.largest_chunk >> 10
> +		vmi.largest_chunk >> 10,
> +		K(global_page_state(NR_ISOLATE)),
>  		);
>  
>  	hugetlb_report_meminfo(m);
> Index: b/include/linux/mmzone.h
> ===================================================================
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -107,6 +107,7 @@ enum zone_stat_item {
>  	NUMA_LOCAL,		/* allocation from local node */
>  	NUMA_OTHER,		/* allocation from other node */
>  #endif
> +	NR_ISOLATE,
>  	NR_VM_ZONE_STAT_ITEMS };
>  
>  /*
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2119,7 +2119,8 @@ void show_free_areas(void)
>  		" inactive_file:%lu"
>  		" unevictable:%lu"
>  		" dirty:%lu writeback:%lu unstable:%lu\n"
> -		" free:%lu slab:%lu mapped:%lu pagetables:%lu bounce:%lu\n",
> +		" free:%lu slab:%lu mapped:%lu pagetables:%lu bounce:%lu\n"
> +		" isolate:%lu\n",
>  		global_page_state(NR_ACTIVE_ANON),
>  		global_page_state(NR_ACTIVE_FILE),
>  		global_page_state(NR_INACTIVE_ANON),
> @@ -2133,7 +2134,8 @@ void show_free_areas(void)
>  			global_page_state(NR_SLAB_UNRECLAIMABLE),
>  		global_page_state(NR_FILE_MAPPED),
>  		global_page_state(NR_PAGETABLE),
> -		global_page_state(NR_BOUNCE));
> +		global_page_state(NR_BOUNCE),
> +		global_page_state(NR_ISOLATE));
>  
>  	for_each_populated_zone(zone) {
>  		int i;
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1066,6 +1066,7 @@ static unsigned long shrink_inactive_lis
>  		unsigned long nr_freed;
>  		unsigned long nr_active;
>  		unsigned int count[NR_LRU_LISTS] = { 0, };
> +		unsigned int total_count;
>  		int mode = lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
>  
>  		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
> @@ -1082,6 +1083,7 @@ static unsigned long shrink_inactive_lis
>  						-count[LRU_ACTIVE_ANON]);
>  		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
>  						-count[LRU_INACTIVE_ANON]);
> +		__mod_zone_page_state(zone, NR_ISOLATE, nr_taken);
>  
>  		if (scanning_global_lru(sc))
>  			zone->pages_scanned += nr_scan;
> @@ -1131,6 +1133,7 @@ static unsigned long shrink_inactive_lis
>  			goto done;
>  
>  		spin_lock(&zone->lru_lock);
> +		__mod_zone_page_state(zone, NR_ISOLATE, -nr_taken);
>  		/*
>  		 * Put back any unfreeable pages.
>  		 */
> @@ -1232,6 +1235,7 @@ static void move_active_pages_to_lru(str
>  		}
>  	}
>  	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> +	__mod_zone_page_state(zone, NR_ISOLATE, -pgmoved);
>  	if (!is_active_lru(lru))
>  		__count_vm_events(PGDEACTIVATE, pgmoved);
>  }
> @@ -1267,6 +1271,7 @@ static void shrink_active_list(unsigned 
>  		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
>  	else
>  		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -pgmoved);
> +	__mod_zone_page_state(zone, NR_ISOLATE, pgmoved);
>  	spin_unlock_irq(&zone->lru_lock);
>  
>  	pgmoved = 0;  /* count referenced (mapping) mapped pages */
> Index: b/mm/vmstat.c
> ===================================================================
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -697,6 +697,7 @@ static const char * const vmstat_text[] 
>  	"unevictable_pgs_stranded",
>  	"unevictable_pgs_mlockfreed",
>  #endif
> +	"isolate_pages",
>  };
>  
>  static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
