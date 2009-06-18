Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0AF3C6B0083
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 05:19:19 -0400 (EDT)
Date: Thu, 18 Jun 2009 17:19:49 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-ID: <20090618091949.GA711@localhost>
References: <20090610085638.GA32511@localhost> <1244626976.13761.11593.camel@twins> <20090610095950.GA514@localhost> <1244628314.13761.11617.camel@twins> <20090610113214.GA5657@localhost> <20090610102516.08f7300f@jbarnes-x200> <20090611052228.GA20100@localhost> <20090611101741.GA1974@cmpxchg.org> <20090612015927.GA6804@localhost> <20090615182216.GA1661@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615182216.GA1661@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Barnes, Jesse" <jesse.barnes@intel.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 16, 2009 at 02:22:17AM +0800, Johannes Weiner wrote:
> On Fri, Jun 12, 2009 at 09:59:27AM +0800, Wu Fengguang wrote:
> > On Thu, Jun 11, 2009 at 06:17:42PM +0800, Johannes Weiner wrote:
> > > On Thu, Jun 11, 2009 at 01:22:28PM +0800, Wu Fengguang wrote:
> > > > Unfortunately, after fixing it up the swap readahead patch still performs slow
> > > > (even worse this time):
> > > 
> > > Thanks for doing the tests.  Do you know if the time difference comes
> > > from IO or CPU time?
> > > 
> > > Because one reason I could think of is that the original code walks
> > > the readaround window in two directions, starting from the target each
> > > time but immediately stops when it encounters a hole where the new
> > > code just skips holes but doesn't abort readaround and thus might
> > > indeed read more slots.
> > > 
> > > I have an old patch flying around that changed the physical ra code to
> > > use a bitmap that is able to represent holes.  If the increased time
> > > is waiting for IO, I would be interested if that patch has the same
> > > negative impact.
> > 
> > You can send me the patch :)
> 
> Okay, attached is a rebase against latest -mmotm.
> 
> > But for this patch it is IO bound. The CPU iowait field actually is
> > going up as the test goes on:
> 
> It's probably the larger ra window then which takes away the bandwidth
> needed to load the new executables.  This sucks.  Would be nice to
> have 'optional IO' for readahead that is dropped when normal-priority
> IO requests are coming in...  Oh, we have READA for bios.  But it
> doesn't seem to implement dropping requests on load (or I am blind).

Hi Hannes,

Sorry for the long delay! A bad news is that I get many oom with this patch:

[  781.450862] Xorg invoked oom-killer: gfp_mask=0xd2, order=0, oom_adj=0
[  781.457411] Pid: 3272, comm: Xorg Not tainted 2.6.30-rc8-mm1 #312
[  781.463511] Call Trace:
[  781.465976]  [<ffffffff81545006>] ? _spin_unlock+0x26/0x30
[  781.471462]  [<ffffffff810c37cc>] oom_kill_process+0xdc/0x270
[  781.477210]  [<ffffffff810c3b2f>] ? badness+0x18f/0x300
[  781.482449]  [<ffffffff810c3dd5>] __out_of_memory+0x135/0x170
[  781.488188]  [<ffffffff810c3f05>] out_of_memory+0xf5/0x180
[  781.493666]  [<ffffffff810c857c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  781.500015]  [<ffffffff81079ebd>] ? trace_hardirqs_on+0xd/0x10
[  781.505846]  [<ffffffff810f3ea8>] alloc_pages_current+0x78/0x100
[  781.511857]  [<ffffffff810e7fe8>] __vmalloc_area_node+0xf8/0x190
[  781.517869]  [<ffffffffa014c9b5>] ? i915_gem_execbuffer+0xb45/0x12f0 [i915]
[  781.524835]  [<ffffffff810e8121>] __vmalloc_node+0xa1/0xb0
[  781.530346]  [<ffffffffa014c9b5>] ? i915_gem_execbuffer+0xb45/0x12f0 [i915]
[  781.537312]  [<ffffffffa014bf2b>] ? i915_gem_execbuffer+0xbb/0x12f0 [i915]
[  781.544192]  [<ffffffff810e8281>] vmalloc+0x21/0x30
[  781.549100]  [<ffffffffa014c9b5>] i915_gem_execbuffer+0xb45/0x12f0 [i915]
[  781.555920]  [<ffffffff81079ebd>] ? trace_hardirqs_on+0xd/0x10
[  781.561789]  [<ffffffffa00f5b7d>] drm_ioctl+0x12d/0x3d0 [drm]
[  781.567569]  [<ffffffffa014be70>] ? i915_gem_execbuffer+0x0/0x12f0 [i915]
[  781.574383]  [<ffffffff81079ebd>] ? trace_hardirqs_on+0xd/0x10
[  781.580225]  [<ffffffff8110babd>] vfs_ioctl+0x7d/0xa0
[  781.585287]  [<ffffffff8110bb6a>] do_vfs_ioctl+0x8a/0x580
[  781.590706]  [<ffffffff81078f3a>] ? lockdep_sys_exit+0x2a/0x90
[  781.596552]  [<ffffffff81544b34>] ? lockdep_sys_exit_thunk+0x35/0x67
[  781.602929]  [<ffffffff8110c0aa>] sys_ioctl+0x4a/0x80
[  781.607995]  [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b
[  781.614005] Mem-Info:
[  781.616293] Node 0 DMA per-cpu:
[  781.619471] CPU    0: hi:    0, btch:   1 usd:   0
[  781.624278] CPU    1: hi:    0, btch:   1 usd:   0
[  781.629080] Node 0 DMA32 per-cpu:
[  781.632443] CPU    0: hi:  186, btch:  31 usd:  83
[  781.637243] CPU    1: hi:  186, btch:  31 usd: 108
[  781.642045] Active_anon:41057 active_file:2334 inactive_anon:47003
[  781.642048]  inactive_file:2148 unevictable:4 dirty:0 writeback:0 unstable:0
[  781.642051]  free:1180 slab:14177 mapped:4473 pagetables:7629 bounce:0
[  781.661802] Node 0 DMA free:2016kB min:84kB low:104kB high:124kB active_anon:5408kB inactive_anon:5676kB active_file:16kB inactive_file:0kB unevictable:0kB present:15164kB pages_scanned:42276 all_unreclaimable? no
[  781.680773] lowmem_reserve[]: 0 483 483 483
[  781.685089] Node 0 DMA32 free:2704kB min:2768kB low:3460kB high:4152kB active_anon:158820kB inactive_anon:182224kB active_file:9320kB inactive_file:8592kB unevictable:16kB present:495008kB pages_scanned:673623 all_unreclaimable? yes
[  781.705711] lowmem_reserve[]: 0 0 0 0
[  781.709501] Node 0 DMA: 104*4kB 0*8kB 6*16kB 1*32kB 1*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2016kB
[  781.720553] Node 0 DMA32: 318*4kB 1*8kB 1*16kB 6*32kB 1*64kB 3*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 2704kB
[  781.731764] 61569 total pagecache pages
[  781.735618] 6489 pages in swap cache
[  781.739212] Swap cache stats: add 285146, delete 278657, find 31455/133061
[  781.746092] Free swap  = 709316kB
[  781.749417] Total swap = 1048568kB
[  781.759726] 131072 pages RAM
[  781.762645] 9628 pages reserved
[  781.765793] 95620 pages shared
[  781.768862] 58466 pages non-shared
[  781.772278] Out of memory: kill process 3487 (run-many-x-apps) score 1471069 or a child
[  781.780291] Killed process 3488 (xeyes)
[  781.830240] gtali invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
[  781.837208] Pid: 4113, comm: gtali Not tainted 2.6.30-rc8-mm1 #312
[  781.843554] Call Trace:
[  781.846233]  [<ffffffff81545006>] ? _spin_unlock+0x26/0x30
[  781.851870]  [<ffffffff810c37cc>] oom_kill_process+0xdc/0x270
[  781.857615]  [<ffffffff810c3b2f>] ? badness+0x18f/0x300
[  781.862840]  [<ffffffff810c3dd5>] __out_of_memory+0x135/0x170
[  781.868578]  [<ffffffff810c3f05>] out_of_memory+0xf5/0x180
[  781.874054]  [<ffffffff810c857c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  781.880401]  [<ffffffff810f3fb6>] alloc_page_vma+0x86/0x1c0
[  781.885969]  [<ffffffff810e9d08>] read_swap_cache_async+0xd8/0x120
[  781.892147]  [<ffffffff810e9f05>] swapin_readahead+0xb5/0x110
[  781.897886]  [<ffffffff810dac73>] do_swap_page+0x403/0x510
[  781.903366]  [<ffffffff810e9933>] ? lookup_swap_cache+0x13/0x30
[  781.909279]  [<ffffffff810da8ea>] ? do_swap_page+0x7a/0x510
[  781.914850]  [<ffffffff810dc72e>] handle_mm_fault+0x44e/0x500
[  781.920587]  [<ffffffff81548274>] do_page_fault+0x1c4/0x330
[  781.926149]  [<ffffffff81545a95>] page_fault+0x25/0x30
[  781.931287] Mem-Info:
[  781.933559] Node 0 DMA per-cpu:
[  781.936714] CPU    0: hi:    0, btch:   1 usd:   0
[  781.941500] CPU    1: hi:    0, btch:   1 usd:   0
[  781.946288] Node 0 DMA32 per-cpu:
[  781.949615] CPU    0: hi:  186, btch:  31 usd:  84
[  781.954402] CPU    1: hi:  186, btch:  31 usd: 109
[  781.959192] Active_anon:41029 active_file:2334 inactive_anon:46908
[  781.959193]  inactive_file:2211 unevictable:4 dirty:0 writeback:0 unstable:0
[  781.959194]  free:1180 slab:14177 mapped:4492 pagetables:7608 bounce:0
[  781.978897] Node 0 DMA free:2016kB min:84kB low:104kB high:124kB active_anon:5296kB inactive_anon:5408kB active_file:16kB inactive_file:176kB unevictable:0kB present:15164kB pages_scanned:6816 all_unreclaimable? no
[  781.997900] lowmem_reserve[]: 0 483 483 483
[  782.002173] Node 0 DMA32 free:2704kB min:2768kB low:3460kB high:4152kB active_anon:158820kB inactive_anon:182224kB active_file:9320kB inactive_file:8668kB unevictable:16kB present:495008kB pages_scanned:674199 all_unreclaimable? yes
[  782.022740] lowmem_reserve[]: 0 0 0 0
[  782.026488] Node 0 DMA: 82*4kB 9*8kB 7*16kB 1*32kB 1*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2016kB
[  782.037309] Node 0 DMA32: 318*4kB 1*8kB 1*16kB 6*32kB 1*64kB 3*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 2704kB
[  782.048405] 61637 total pagecache pages
[  782.052236] 6494 pages in swap cache
[  782.055809] Swap cache stats: add 285154, delete 278660, find 31456/133069
[  782.062672] Free swap  = 709592kB
[  782.065983] Total swap = 1048568kB
[  782.072735] 131072 pages RAM
[  782.075632] 9628 pages reserved
[  782.078774] 95669 pages shared
[  782.081822] 58413 pages non-shared
[  782.085223] Out of memory: kill process 3487 (run-many-x-apps) score 1466556 or a child
[  782.093215] Killed process 3566 (gthumb)
[  790.063897] gnome-panel invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  790.071664] Pid: 3405, comm: gnome-panel Not tainted 2.6.30-rc8-mm1 #312
[  790.078421] Call Trace:
[  790.080902]  [<ffffffff81545006>] ? _spin_unlock+0x26/0x30
[  790.086410]  [<ffffffff810c37cc>] oom_kill_process+0xdc/0x270
[  790.092159]  [<ffffffff810c3b2f>] ? badness+0x18f/0x300
[  790.097387]  [<ffffffff810c3dd5>] __out_of_memory+0x135/0x170
[  790.103135]  [<ffffffff810c3f05>] out_of_memory+0xf5/0x180
[  790.108632]  [<ffffffff810c857c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  790.115001]  [<ffffffff810f3ea8>] alloc_pages_current+0x78/0x100
[  790.121002]  [<ffffffff810c0c7b>] __page_cache_alloc+0xb/0x10
[  790.126745]  [<ffffffff810ca910>] __do_page_cache_readahead+0x120/0x240
[  790.133352]  [<ffffffff810ca8a2>] ? __do_page_cache_readahead+0xb2/0x240
[  790.140057]  [<ffffffff810caa4c>] ra_submit+0x1c/0x20
[  790.145103]  [<ffffffff810c1497>] filemap_fault+0x3f7/0x400
[  790.150678]  [<ffffffff810d9893>] __do_fault+0x53/0x510
[  790.155902]  [<ffffffff81271ce0>] ? __down_read_trylock+0x20/0x60
[  790.161989]  [<ffffffff810dc4a9>] handle_mm_fault+0x1c9/0x500
[  790.167738]  [<ffffffff81548274>] do_page_fault+0x1c4/0x330
[  790.173304]  [<ffffffff81545a95>] page_fault+0x25/0x30
[  790.178441] Mem-Info:
[  790.180714] Node 0 DMA per-cpu:
[  790.183870] CPU    0: hi:    0, btch:   1 usd:   0
[  790.188659] CPU    1: hi:    0, btch:   1 usd:   0
[  790.193446] Node 0 DMA32 per-cpu:
[  790.196783] CPU    0: hi:  186, btch:  31 usd:  43
[  790.201569] CPU    1: hi:  186, btch:  31 usd:  31
[  790.206359] Active_anon:41179 active_file:900 inactive_anon:46967
[  790.206360]  inactive_file:4104 unevictable:4 dirty:0 writeback:0 unstable:0
[  790.206361]  free:1165 slab:13961 mapped:3241 pagetables:7475 bounce:0
[  790.225984] Node 0 DMA free:2012kB min:84kB low:104kB high:124kB active_anon:5496kB inactive_anon:5800kB active_file:4kB inactive_file:220kB unevictable:0kB present:15164kB pages_scanned:26112 all_unreclaimable? yes
[  790.245079] lowmem_reserve[]: 0 483 483 483
[  790.249352] Node 0 DMA32 free:2648kB min:2768kB low:3460kB high:4152kB active_anon:159220kB inactive_anon:182068kB active_file:3596kB inactive_file:16196kB unevictable:16kB present:495008kB pages_scanned:875456 all_unreclaimable? yes
[  790.270005] lowmem_reserve[]: 0 0 0 0
[  790.273762] Node 0 DMA: 53*4kB 9*8kB 12*16kB 2*32kB 1*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2012kB
[  790.284681] Node 0 DMA32: 190*4kB 46*8kB 7*16kB 6*32kB 1*64kB 3*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 2648kB
[  790.295866] 62097 total pagecache pages
[  790.299698] 6548 pages in swap cache
[  790.303271] Swap cache stats: add 286032, delete 279484, find 31565/133879
[  790.310137] Free swap  = 717460kB
[  790.313445] Total swap = 1048568kB
[  790.320544] 131072 pages RAM
[  790.323445] 9628 pages reserved
[  790.326591] 85371 pages shared
[  790.329641] 59742 pages non-shared
[  790.333046] Out of memory: kill process 3487 (run-many-x-apps) score 1258333 or a child
[  790.341039] Killed process 3599 (gedit)
[  790.382081] gedit used greatest stack depth: 2064 bytes left
[  792.149572] Xorg invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0
[  792.156786] Pid: 3272, comm: Xorg Not tainted 2.6.30-rc8-mm1 #312
[  792.162980] Call Trace:
[  792.165429]  [<ffffffff81545006>] ? _spin_unlock+0x26/0x30
[  792.170937]  [<ffffffff810c37cc>] oom_kill_process+0xdc/0x270
[  792.176691]  [<ffffffff810c3b2f>] ? badness+0x18f/0x300
[  792.181909]  [<ffffffff810c3dd5>] __out_of_memory+0x135/0x170
[  792.187653]  [<ffffffff810c3f05>] out_of_memory+0xf5/0x180
[  792.193136]  [<ffffffff810c857c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  792.199490]  [<ffffffff810f3ea8>] alloc_pages_current+0x78/0x100
[  792.205491]  [<ffffffff810c7409>] __get_free_pages+0x9/0x50
[  792.211060]  [<ffffffff8110e402>] __pollwait+0xc2/0x100
[  792.216283]  [<ffffffff81495903>] unix_poll+0x23/0xc0
[  792.221330]  [<ffffffff81419ac8>] sock_poll+0x18/0x20
[  792.226380]  [<ffffffff8110d9a9>] do_select+0x3e9/0x730
[  792.231597]  [<ffffffff8110d5c0>] ? do_select+0x0/0x730
[  792.236816]  [<ffffffff8110e340>] ? __pollwait+0x0/0x100
[  792.242126]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[  792.247180]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[  792.252227]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[  792.257275]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[  792.262331]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[  792.267377]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[  792.272422]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[  792.277468]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[  792.282519]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[  792.287574]  [<ffffffff8110deef>] core_sys_select+0x1ff/0x330
[  792.293317]  [<ffffffff8110dd38>] ? core_sys_select+0x48/0x330
[  792.299162]  [<ffffffffa014954c>] ? i915_gem_throttle_ioctl+0x4c/0x60 [i915]
[  792.306204]  [<ffffffff81079ebd>] ? trace_hardirqs_on+0xd/0x10
[  792.312034]  [<ffffffff810706cc>] ? getnstimeofday+0x5c/0xf0
[  792.317687]  [<ffffffff8106acb9>] ? ktime_get_ts+0x59/0x60
[  792.323169]  [<ffffffff8110e27a>] sys_select+0x4a/0x110
[  792.328387]  [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b
[  792.334389] Mem-Info:
[  792.336663] Node 0 DMA per-cpu:
[  792.339824] CPU    0: hi:    0, btch:   1 usd:   0
[  792.344612] CPU    1: hi:    0, btch:   1 usd:   0
[  792.349397] Node 0 DMA32 per-cpu:
[  792.352734] CPU    0: hi:  186, btch:  31 usd:  57
[  792.357518] CPU    1: hi:  186, btch:  31 usd:  50
[  792.362310] Active_anon:40862 active_file:1622 inactive_anon:47020
[  792.362311]  inactive_file:3746 unevictable:4 dirty:0 writeback:0 unstable:0
[  792.362313]  free:1187 slab:13902 mapped:4052 pagetables:7387 bounce:0
[  792.382030] Node 0 DMA free:2012kB min:84kB low:104kB high:124kB active_anon:5428kB inactive_anon:5680kB active_file:0kB inactive_file:224kB unevictable:0kB present:15164kB pages_scanned:4992 all_unreclaimable? no
[  792.400957] lowmem_reserve[]: 0 483 483 483
[  792.405232] Node 0 DMA32 free:2736kB min:2768kB low:3460kB high:4152kB active_anon:158020kB inactive_anon:182284kB active_file:6488kB inactive_file:14760kB unevictable:16kB present:495008kB pages_scanned:876741 all_unreclaimable? yes
[  792.425889] lowmem_reserve[]: 0 0 0 0
[  792.429637] Node 0 DMA: 31*4kB 14*8kB 15*16kB 2*32kB 1*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2012kB
[  792.440651] Node 0 DMA32: 86*4kB 95*8kB 14*16kB 6*32kB 1*64kB 3*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 2736kB
[  792.451821] 62288 total pagecache pages
[  792.455655] 6442 pages in swap cache
[  792.459230] Swap cache stats: add 286223, delete 279781, find 31574/134040
[  792.466100] Free swap  = 723520kB
[  792.469405] Total swap = 1048568kB
[  792.476461] 131072 pages RAM
[  792.479359] 9628 pages reserved
[  792.482502] 86274 pages shared
[  792.485547] 59031 pages non-shared
[  792.488956] Out of memory: kill process 3487 (run-many-x-apps) score 1235901 or a child
[  792.496952] Killed process 3626 (xpdf.bin)
[  912.097890] gnome-control-c invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  912.105967] Pid: 5395, comm: gnome-control-c Not tainted 2.6.30-rc8-mm1 #312
[  912.113042] Call Trace:
[  912.115499]  [<ffffffff81545006>] ? _spin_unlock+0x26/0x30
[  912.120994]  [<ffffffff810c37cc>] oom_kill_process+0xdc/0x270
[  912.126737]  [<ffffffff810c3b2f>] ? badness+0x18f/0x300
[  912.131961]  [<ffffffff810c3dd5>] __out_of_memory+0x135/0x170
[  912.137709]  [<ffffffff810c3f05>] out_of_memory+0xf5/0x180
[  912.143193]  [<ffffffff810c857c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  912.149547]  [<ffffffff810f3ea8>] alloc_pages_current+0x78/0x100
[  912.155551]  [<ffffffff810c0c7b>] __page_cache_alloc+0xb/0x10
[  912.161295]  [<ffffffff810ca910>] __do_page_cache_readahead+0x120/0x240
[  912.167904]  [<ffffffff810ca8a2>] ? __do_page_cache_readahead+0xb2/0x240
[  912.174602]  [<ffffffff810caa4c>] ra_submit+0x1c/0x20
[  912.179650]  [<ffffffff810c1497>] filemap_fault+0x3f7/0x400
[  912.185221]  [<ffffffff810d9893>] __do_fault+0x53/0x510
[  912.190445]  [<ffffffff81271ce0>] ? __down_read_trylock+0x20/0x60
[  912.196539]  [<ffffffff810dc4a9>] handle_mm_fault+0x1c9/0x500
[  912.202278]  [<ffffffff81548274>] do_page_fault+0x1c4/0x330
[  912.207840]  [<ffffffff81545a95>] page_fault+0x25/0x30
[  912.212976] Mem-Info:
[  912.215247] Node 0 DMA per-cpu:
[  912.218402] CPU    0: hi:    0, btch:   1 usd:   0
[  912.223190] CPU    1: hi:    0, btch:   1 usd:   0
[  912.227979] Node 0 DMA32 per-cpu:
[  912.231315] CPU    0: hi:  186, btch:  31 usd: 118
[  912.236100] CPU    1: hi:  186, btch:  31 usd: 158
[  912.240891] Active_anon:42350 active_file:809 inactive_anon:47098
[  912.240892]  inactive_file:2682 unevictable:4 dirty:0 writeback:3 unstable:0
[  912.240893]  free:1164 slab:13886 mapped:3078 pagetables:7561 bounce:0
[  912.260546] Node 0 DMA free:2016kB min:84kB low:104kB high:124kB active_anon:5456kB inactive_anon:5676kB active_file:4kB inactive_file:72kB unevictable:0kB present:15164kB pages_scanned:1920 all_unreclaimable? no
[  912.279403] lowmem_reserve[]: 0 483 483 483
[  912.283671] Node 0 DMA32 free:2600kB min:2768kB low:3460kB high:4152kB active_anon:163944kB inactive_anon:182600kB active_file:3232kB inactive_file:10644kB unevictable:16kB present:495008kB pages_scanned:571360 all_unreclaimable? yes
[  912.304335] lowmem_reserve[]: 0 0 0 0
[  912.308082] Node 0 DMA: 22*4kB 16*8kB 12*16kB 2*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2008kB
[  912.319093] Node 0 DMA32: 128*4kB 131*8kB 1*16kB 0*32kB 0*64kB 2*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 2600kB
[  912.330367] 62393 total pagecache pages
[  912.334201] 7186 pages in swap cache
[  912.337778] Swap cache stats: add 320003, delete 312817, find 34852/153688
[  912.344648] Free swap  = 714408kB
[  912.347950] Total swap = 1048568kB
[  912.355114] 131072 pages RAM
[  912.358011] 9628 pages reserved
[  912.361153] 84608 pages shared
[  912.364199] 58138 pages non-shared
[  912.367606] Out of memory: kill process 3487 (run-many-x-apps) score 1281073 or a child
[  912.375604] Killed process 3669 (xterm)
[  912.427936] tty_ldisc_deref: no references.
[  912.480847] nautilus invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  912.487981] Pid: 3408, comm: nautilus Not tainted 2.6.30-rc8-mm1 #312
[  912.494418] Call Trace:
[  912.496876]  [<ffffffff81545006>] ? _spin_unlock+0x26/0x30
[  912.502361]  [<ffffffff810c37cc>] oom_kill_process+0xdc/0x270
[  912.508100]  [<ffffffff810c3b2f>] ? badness+0x18f/0x300
[  912.513327]  [<ffffffff810c3dd5>] __out_of_memory+0x135/0x170
[  912.519067]  [<ffffffff810c3f05>] out_of_memory+0xf5/0x180
[  912.524552]  [<ffffffff810c857c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  912.530902]  [<ffffffff810f3ea8>] alloc_pages_current+0x78/0x100
[  912.536907]  [<ffffffff810c0c7b>] __page_cache_alloc+0xb/0x10
[  912.542645]  [<ffffffff810ca910>] __do_page_cache_readahead+0x120/0x240
[  912.549253]  [<ffffffff810ca8a2>] ? __do_page_cache_readahead+0xb2/0x240
[  912.555946]  [<ffffffff810a9c9b>] ? delayacct_end+0x6b/0xa0
[  912.561517]  [<ffffffff810caa4c>] ra_submit+0x1c/0x20
[  912.566563]  [<ffffffff810cacb3>] ondemand_readahead+0x163/0x2d0
[  912.572563]  [<ffffffff810caf25>] page_cache_sync_readahead+0x25/0x30
[  912.579000]  [<ffffffff810c141c>] filemap_fault+0x37c/0x400
[  912.584576]  [<ffffffff810d9893>] __do_fault+0x53/0x510
[  912.589799]  [<ffffffff81271ce0>] ? __down_read_trylock+0x20/0x60
[  912.595888]  [<ffffffff810dc4a9>] handle_mm_fault+0x1c9/0x500
[  912.601632]  [<ffffffff81548274>] do_page_fault+0x1c4/0x330
[  912.607206]  [<ffffffff81545a95>] page_fault+0x25/0x30
[  912.612345] Mem-Info:
[  912.614624] Node 0 DMA per-cpu:
[  912.617787] CPU    0: hi:    0, btch:   1 usd:   0
[  912.622570] CPU    1: hi:    0, btch:   1 usd:   0
[  912.627353] Node 0 DMA32 per-cpu:
[  912.630682] CPU    0: hi:  186, btch:  31 usd: 121
[  912.635470] CPU    1: hi:  186, btch:  31 usd:  76
[  912.640259] Active_anon:42310 active_file:830 inactive_anon:47085
[  912.640260]  inactive_file:2747 unevictable:4 dirty:0 writeback:0 unstable:0
[  912.640261]  free:1182 slab:13881 mapped:3111 pagetables:7523 bounce:0
[  912.659881] Node 0 DMA free:2004kB min:84kB low:104kB high:124kB active_anon:5468kB inactive_anon:5784kB active_file:4kB inactive_file:56kB unevictable:0kB present:15164kB pages_scanned:5152 all_unreclaimable? no
[  912.678724] lowmem_reserve[]: 0 483 483 483
[  912.682990] Node 0 DMA32 free:2724kB min:2768kB low:3460kB high:4152kB active_anon:163772kB inactive_anon:182556kB active_file:3316kB inactive_file:10932kB unevictable:16kB present:495008kB pages_scanned:51712 all_unreclaimable? no
[  912.703478] lowmem_reserve[]: 0 0 0 0
[  912.707226] Node 0 DMA: 21*4kB 16*8kB 12*16kB 2*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2004kB
[  912.718239] Node 0 DMA32: 159*4kB 132*8kB 1*16kB 0*32kB 0*64kB 2*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 2732kB
[  912.729502] 62461 total pagecache pages
[  912.733337] 7171 pages in swap cache
[  912.736915] Swap cache stats: add 320011, delete 312840, find 34852/153696
[  912.743782] Free swap  = 715668kB
[  912.747098] Total swap = 1048568kB
[  912.754168] 131072 pages RAM
[  912.757059] 9628 pages reserved
[  912.760191] 84519 pages shared
[  912.763248] 58139 pages non-shared
[  912.766653] Out of memory: kill process 3487 (run-many-x-apps) score 1273781 or a child
[  912.774647] Killed process 3762 (gnome-terminal)
[  913.650490] tty_ldisc_deref: no references.
[  914.671325] kerneloops-appl invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
[  914.679083] Pid: 3425, comm: kerneloops-appl Not tainted 2.6.30-rc8-mm1 #312
[  914.686121] Call Trace:
[  914.688575]  [<ffffffff81545006>] ? _spin_unlock+0x26/0x30
[  914.694057]  [<ffffffff810c37cc>] oom_kill_process+0xdc/0x270
[  914.699800]  [<ffffffff810c3b2f>] ? badness+0x18f/0x300
[  914.705034]  [<ffffffff810c3dd5>] __out_of_memory+0x135/0x170
[  914.710791]  [<ffffffff810c3f05>] out_of_memory+0xf5/0x180
[  914.716279]  [<ffffffff810c857c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  914.722640]  [<ffffffff810f3fb6>] alloc_page_vma+0x86/0x1c0
[  914.728208]  [<ffffffff810e9d08>] read_swap_cache_async+0xd8/0x120
[  914.734391]  [<ffffffff810e9f05>] swapin_readahead+0xb5/0x110
[  914.740139]  [<ffffffff810dac73>] do_swap_page+0x403/0x510
[  914.745632]  [<ffffffff810c0710>] ? find_get_page+0x0/0x110
[  914.751200]  [<ffffffff810e9933>] ? lookup_swap_cache+0x13/0x30
[  914.757115]  [<ffffffff810da8ea>] ? do_swap_page+0x7a/0x510
[  914.762688]  [<ffffffff810dc72e>] handle_mm_fault+0x44e/0x500
[  914.768437]  [<ffffffff81548274>] do_page_fault+0x1c4/0x330
[  914.774005]  [<ffffffff81545a95>] page_fault+0x25/0x30
[  914.779136] Mem-Info:
[  914.781410] Node 0 DMA per-cpu:
[  914.784572] CPU    0: hi:    0, btch:   1 usd:   0
[  914.789367] CPU    1: hi:    0, btch:   1 usd:   0
[  914.794156] Node 0 DMA32 per-cpu:
[  914.797493] CPU    0: hi:  186, btch:  31 usd: 150
[  914.802278] CPU    1: hi:  186, btch:  31 usd: 147
[  914.807064] Active_anon:42324 active_file:1285 inactive_anon:47097
[  914.807065]  inactive_file:2225 unevictable:4 dirty:0 writeback:0 unstable:0
[  914.807067]  free:1185 slab:13908 mapped:3648 pagetables:7413 bounce:0
[  914.826781] Node 0 DMA free:2016kB min:84kB low:104kB high:124kB active_anon:5360kB inactive_anon:5784kB active_file:0kB inactive_file:0kB unevictable:0kB present:15164kB pages_scanned:17408 all_unreclaimable? yes
[  914.845718] lowmem_reserve[]: 0 483 483 483
[  914.849988] Node 0 DMA32 free:2724kB min:2768kB low:3460kB high:4152kB active_anon:163936kB inactive_anon:182604kB active_file:5140kB inactive_file:8908kB unevictable:16kB present:495008kB pages_scanned:581760 all_unreclaimable? yes
[  914.870559] lowmem_reserve[]: 0 0 0 0
[  914.874306] Node 0 DMA: 37*4kB 10*8kB 12*16kB 2*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2020kB
[  914.885318] Node 0 DMA32: 119*4kB 139*8kB 7*16kB 0*32kB 0*64kB 2*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 2724kB
[  914.896588] 62441 total pagecache pages
[  914.900417] 7199 pages in swap cache
[  914.903999] Swap cache stats: add 320272, delete 313073, find 34864/153895
[  914.910867] Free swap  = 721224kB
[  914.914193] Total swap = 1048568kB
[  914.921489] 131072 pages RAM
[  914.924370] 9628 pages reserved
[  914.927519] 84507 pages shared
[  914.930581] 57535 pages non-shared
[  914.933989] Out of memory: kill process 3487 (run-many-x-apps) score 1213315 or a child
[  914.941986] Killed process 3803 (urxvt)
[  914.947298] tty_ldisc_deref: no references.
[  919.983335] gnome-keyboard- invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
[  919.991145] Pid: 5458, comm: gnome-keyboard- Not tainted 2.6.30-rc8-mm1 #312
[  919.998198] Call Trace:
[  920.000663]  [<ffffffff81545006>] ? _spin_unlock+0x26/0x30
[  920.006157]  [<ffffffff810c37cc>] oom_kill_process+0xdc/0x270
[  920.011906]  [<ffffffff810c3b2f>] ? badness+0x18f/0x300
[  920.017135]  [<ffffffff810c3dd5>] __out_of_memory+0x135/0x170
[  920.022876]  [<ffffffff810c3f05>] out_of_memory+0xf5/0x180
[  920.028357]  [<ffffffff810c857c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  920.034706]  [<ffffffff810f3fb6>] alloc_page_vma+0x86/0x1c0
[  920.040280]  [<ffffffff810e9d08>] read_swap_cache_async+0xd8/0x120
[  920.046460]  [<ffffffff810e9f05>] swapin_readahead+0xb5/0x110
[  920.052196]  [<ffffffff810dac73>] do_swap_page+0x403/0x510
[  920.057676]  [<ffffffff810e9933>] ? lookup_swap_cache+0x13/0x30
[  920.063592]  [<ffffffff810da8ea>] ? do_swap_page+0x7a/0x510
[  920.069165]  [<ffffffff810dc72e>] handle_mm_fault+0x44e/0x500
[  920.074901]  [<ffffffff81548274>] do_page_fault+0x1c4/0x330
[  920.080470]  [<ffffffff81545a95>] page_fault+0x25/0x30
[  920.085604] Mem-Info:
[  920.087875] Node 0 DMA per-cpu:
[  920.091031] CPU    0: hi:    0, btch:   1 usd:   0
[  920.095818] CPU    1: hi:    0, btch:   1 usd:   0
[  920.100617] Node 0 DMA32 per-cpu:
[  920.103947] CPU    0: hi:  186, btch:  31 usd:  89
[  920.108734] CPU    1: hi:  186, btch:  31 usd: 119
[  920.113524] Active_anon:42944 active_file:542 inactive_anon:46956
[  920.113525]  inactive_file:2652 unevictable:4 dirty:0 writeback:0 unstable:0
[  920.113526]  free:1169 slab:13893 mapped:3036 pagetables:7342 bounce:0
[  920.133149] Node 0 DMA free:2008kB min:84kB low:104kB high:124kB active_anon:5568kB inactive_anon:5772kB active_file:20kB inactive_file:164kB unevictable:0kB present:15164kB pages_scanned:22824 all_unreclaimable? yes
[  920.152324] lowmem_reserve[]: 0 483 483 483
[  920.156597] Node 0 DMA32 free:2668kB min:2768kB low:3460kB high:4152kB active_anon:166208kB inactive_anon:182052kB active_file:2148kB inactive_file:10444kB unevictable:16kB present:495008kB pages_scanned:650400 all_unreclaimable? yes
[  920.177245] lowmem_reserve[]: 0 0 0 0
[  920.180991] Node 0 DMA: 44*4kB 9*8kB 10*16kB 2*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2008kB
[  920.191903] Node 0 DMA32: 165*4kB 117*8kB 3*16kB 0*32kB 0*64kB 2*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 2668kB
[  920.203169] 62409 total pagecache pages
[  920.207000] 7469 pages in swap cache
[  920.210572] Swap cache stats: add 321003, delete 313534, find 34989/154507
[  920.217436] Free swap  = 725812kB
[  920.220752] Total swap = 1048568kB
[  920.227856] 131072 pages RAM
[  920.230752] 9628 pages reserved
[  920.233901] 78560 pages shared
[  920.236958] 58011 pages non-shared
[  920.240355] Out of memory: kill process 3487 (run-many-x-apps) score 1195965 or a child
[  920.248346] Killed process 3889 (gnome-system-mo)
[  920.993872] nautilus invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  921.001843] Pid: 3408, comm: nautilus Not tainted 2.6.30-rc8-mm1 #312
[  921.008294] Call Trace:
[  921.010757]  [<ffffffff81545006>] ? _spin_unlock+0x26/0x30
[  921.016245]  [<ffffffff810c37cc>] oom_kill_process+0xdc/0x270
[  921.021995]  [<ffffffff810c3b2f>] ? badness+0x18f/0x300
[  921.027215]  [<ffffffff810c3dd5>] __out_of_memory+0x135/0x170
[  921.032954]  [<ffffffff810c3f05>] out_of_memory+0xf5/0x180
[  921.038441]  [<ffffffff810c857c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  921.044805]  [<ffffffff810f3ea8>] alloc_pages_current+0x78/0x100
[  921.050808]  [<ffffffff810c0c7b>] __page_cache_alloc+0xb/0x10
[  921.056549]  [<ffffffff810ca910>] __do_page_cache_readahead+0x120/0x240
[  921.063163]  [<ffffffff810ca8a2>] ? __do_page_cache_readahead+0xb2/0x240
[  921.069868]  [<ffffffff810caa4c>] ra_submit+0x1c/0x20
[  921.074918]  [<ffffffff810c1497>] filemap_fault+0x3f7/0x400
[  921.080487]  [<ffffffff810d9893>] __do_fault+0x53/0x510
[  921.085717]  [<ffffffff81271ce0>] ? __down_read_trylock+0x20/0x60
[  921.091805]  [<ffffffff810dc4a9>] handle_mm_fault+0x1c9/0x500
[  921.097552]  [<ffffffff81548274>] do_page_fault+0x1c4/0x330
[  921.103145]  [<ffffffff81545a95>] page_fault+0x25/0x30
[  921.108280] Mem-Info:
[  921.110556] Node 0 DMA per-cpu:
[  921.113720] CPU    0: hi:    0, btch:   1 usd:   0
[  921.118501] CPU    1: hi:    0, btch:   1 usd:   0
[  921.123286] Node 0 DMA32 per-cpu:
[  921.126614] CPU    0: hi:  186, btch:  31 usd:  25
[  921.131400] CPU    1: hi:  186, btch:  31 usd:  58
[  921.136187] Active_anon:42277 active_file:992 inactive_anon:46953
[  921.136188]  inactive_file:3279 unevictable:4 dirty:0 writeback:0 unstable:0
[  921.136189]  free:1183 slab:13728 mapped:3449 pagetables:7235 bounce:0
[  921.155810] Node 0 DMA free:2016kB min:84kB low:104kB high:124kB active_anon:5540kB inactive_anon:5772kB active_file:20kB inactive_file:224kB unevictable:0kB present:15164kB pages_scanned:18464 all_unreclaimable? yes
[  921.174995] lowmem_reserve[]: 0 483 483 483
[  921.179259] Node 0 DMA32 free:2716kB min:2768kB low:3460kB high:4152kB active_anon:163568kB inactive_anon:182040kB active_file:3948kB inactive_file:12892kB unevictable:16kB present:495008kB pages_scanned:719674 all_unreclaimable? yes
[  921.199914] lowmem_reserve[]: 0 0 0 0
[  921.203661] Node 0 DMA: 50*4kB 7*8kB 10*16kB 2*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2016kB
[  921.214577] Node 0 DMA32: 257*4kB 45*8kB 19*16kB 0*32kB 0*64kB 2*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 2716kB
[  921.225837] 63208 total pagecache pages
[  921.229675] 7214 pages in swap cache
[  921.233249] Swap cache stats: add 321070, delete 313856, find 34991/154562
[  921.240112] Free swap  = 730844kB
[  921.243427] Total swap = 1048568kB
[  921.250566] 131072 pages RAM
[  921.253460] 9628 pages reserved
[  921.256599] 79050 pages shared
[  921.259646] 57895 pages non-shared
[  921.263048] Out of memory: kill process 3487 (run-many-x-apps) score 1168892 or a child
[  921.271042] Killed process 3917 (gnome-help)
[  934.057490] firefox-bin invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  934.065285] Pid: 3353, comm: firefox-bin Not tainted 2.6.30-rc8-mm1 #312
[  934.072425] Call Trace:
[  934.074882]  [<ffffffff81545006>] ? _spin_unlock+0x26/0x30
[  934.080382]  [<ffffffff810c37cc>] oom_kill_process+0xdc/0x270
[  934.086126]  [<ffffffff810c3b2f>] ? badness+0x18f/0x300
[  934.091349]  [<ffffffff810c3dd5>] __out_of_memory+0x135/0x170
[  934.097091]  [<ffffffff810c3f05>] out_of_memory+0xf5/0x180
[  934.102568]  [<ffffffff810c857c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  934.108914]  [<ffffffff810f3ea8>] alloc_pages_current+0x78/0x100
[  934.114922]  [<ffffffff810c0c7b>] __page_cache_alloc+0xb/0x10
[  934.120667]  [<ffffffff810ca910>] __do_page_cache_readahead+0x120/0x240
[  934.127269]  [<ffffffff810ca8a2>] ? __do_page_cache_readahead+0xb2/0x240
[  934.133963]  [<ffffffff810caa4c>] ra_submit+0x1c/0x20
[  934.139018]  [<ffffffff810c1497>] filemap_fault+0x3f7/0x400
[  934.144593]  [<ffffffff810d9893>] __do_fault+0x53/0x510
[  934.149812]  [<ffffffff81271ce0>] ? __down_read_trylock+0x20/0x60
[  934.155898]  [<ffffffff810dc4a9>] handle_mm_fault+0x1c9/0x500
[  934.161640]  [<ffffffff81548274>] do_page_fault+0x1c4/0x330
[  934.167208]  [<ffffffff81545a95>] page_fault+0x25/0x30
[  934.172348] Mem-Info:
[  934.174614] Node 0 DMA per-cpu:
[  934.177775] CPU    0: hi:    0, btch:   1 usd:   0
[  934.182560] CPU    1: hi:    0, btch:   1 usd:   0
[  934.187342] Node 0 DMA32 per-cpu:
[  934.190671] CPU    0: hi:  186, btch:  31 usd: 115
[  934.195459] CPU    1: hi:  186, btch:  31 usd: 146
[  934.200251] Active_anon:43024 active_file:1381 inactive_anon:46959
[  934.200252]  inactive_file:2292 unevictable:4 dirty:0 writeback:0 unstable:0
[  934.200253]  free:1170 slab:13755 mapped:4121 pagetables:7012 bounce:0
[  934.219958] Node 0 DMA free:2000kB min:84kB low:104kB high:124kB active_anon:5532kB inactive_anon:5756kB active_file:16kB inactive_file:248kB unevictable:0kB present:15164kB pages_scanned:18348 all_unreclaimable? yes
[  934.239142] lowmem_reserve[]: 0 483 483 483
[  934.243408] Node 0 DMA32 free:2680kB min:2768kB low:3460kB high:4152kB active_anon:166564kB inactive_anon:182080kB active_file:5508kB inactive_file:8920kB unevictable:16kB present:495008kB pages_scanned:689667 all_unreclaimable? yes
[  934.263988] lowmem_reserve[]: 0 0 0 0
[  934.267735] Node 0 DMA: 60*4kB 0*8kB 10*16kB 2*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2000kB
[  934.278662] Node 0 DMA32: 294*4kB 2*8kB 9*16kB 10*32kB 0*64kB 2*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 2680kB
[  934.289834] 62846 total pagecache pages
[  934.293669] 7202 pages in swap cache
[  934.297244] Swap cache stats: add 322861, delete 315659, find 35288/156117
[  934.304107] Free swap  = 758748kB
[  934.307422] Total swap = 1048568kB
[  934.314470] 131072 pages RAM
[  934.317362] 9628 pages reserved
[  934.320501] 76930 pages shared
[  934.323549] 57149 pages non-shared
[  934.326955] Out of memory: kill process 3487 (run-many-x-apps) score 1006662 or a child
[  934.334948] Killed process 3952 (gnome-dictionar)
[  934.340708] firefox-bin invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  934.348622] Pid: 3353, comm: firefox-bin Not tainted 2.6.30-rc8-mm1 #312
[  934.355318] Call Trace:
[  934.357768]  [<ffffffff81545006>] ? _spin_unlock+0x26/0x30
[  934.363256]  [<ffffffff810c37cc>] oom_kill_process+0xdc/0x270
[  934.368998]  [<ffffffff810c3b2f>] ? badness+0x18f/0x300
[  934.372992]  [<ffffffff810c3dd5>] __out_of_memory+0x135/0x170
[  934.372992]  [<ffffffff810c3f05>] out_of_memory+0xf5/0x180
[  934.385506]  [<ffffffff810c857c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  934.389481]  [<ffffffff810f3ea8>] alloc_pages_current+0x78/0x100
[  934.397856]  [<ffffffff810c0c7b>] __page_cache_alloc+0xb/0x10
[  934.401848]  [<ffffffff810ca910>] __do_page_cache_readahead+0x120/0x240
[  934.410200]  [<ffffffff810ca8a2>] ? __do_page_cache_readahead+0xb2/0x240
[  934.416894]  [<ffffffff810caa4c>] ra_submit+0x1c/0x20
[  934.421942]  [<ffffffff810c1497>] filemap_fault+0x3f7/0x400
[  934.425936]  [<ffffffff810d9893>] __do_fault+0x53/0x510
[  934.432734]  [<ffffffff81271ce0>] ? __down_read_trylock+0x20/0x60
[  934.438822]  [<ffffffff810dc4a9>] handle_mm_fault+0x1c9/0x500
[  934.444566]  [<ffffffff81548274>] do_page_fault+0x1c4/0x330
[  934.448558]  [<ffffffff81545a95>] page_fault+0x25/0x30
[  934.455262] Mem-Info:
[  934.457533] Node 0 DMA per-cpu:
[  934.460695] CPU    0: hi:    0, btch:   1 usd:   0
[  934.464690] CPU    1: hi:    0, btch:   1 usd:   0
[  934.470263] Node 0 DMA32 per-cpu:
[  934.473589] CPU    0: hi:  186, btch:  31 usd: 172
[  934.478377] CPU    1: hi:  186, btch:  31 usd: 145
[  934.482373] Active_anon:42768 active_file:1390 inactive_anon:46967
[  934.482373]  inactive_file:2301 unevictable:4 dirty:0 writeback:0 unstable:0
[  934.482373]  free:1495 slab:13778 mapped:4137 pagetables:6916 bounce:0
[  934.502869] Node 0 DMA free:2060kB min:84kB low:104kB high:124kB active_anon:5492kB inactive_anon:5788kB active_file:28kB inactive_file:252kB unevictable:0kB present:15164kB pages_scanned:0 all_unreclaimable? no
[  934.521612] lowmem_reserve[]: 0 483 483 483
[  934.525885] Node 0 DMA32 free:3920kB min:2768kB low:3460kB high:4152kB active_anon:165580kB inactive_anon:182080kB active_file:5532kB inactive_file:8952kB unevictable:16kB present:495008kB pages_scanned:0 all_unreclaimable? no
[  934.545927] lowmem_reserve[]: 0 0 0 0
[  934.549677] Node 0 DMA: 71*4kB 2*8kB 10*16kB 2*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2060kB
[  934.560588] Node 0 DMA32: 588*4kB 10*8kB 9*16kB 10*32kB 0*64kB 2*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 3920kB
[  934.568475] 62739 total pagecache pages
[  934.575685] 7086 pages in swap cache
[  934.579254] Swap cache stats: add 322861, delete 315775, find 35288/156117
[  934.586118] Free swap  = 763384kB
[  934.589433] Total swap = 1048568kB
[  934.597155] 131072 pages RAM
[  934.600036] 9628 pages reserved
[  934.600235] 76640 pages shared
[  934.606236] 56884 pages non-shared
[  934.609634] Out of memory: kill process 3487 (run-many-x-apps) score 978701 or a child
[  934.617540] Killed process 4014 (sol)
[ 1028.279307] firefox-bin invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[ 1028.286714] Pid: 5554, comm: firefox-bin Not tainted 2.6.30-rc8-mm1 #312
[ 1028.293414] Call Trace:
[ 1028.295874]  [<ffffffff81545006>] ? _spin_unlock+0x26/0x30
[ 1028.301361]  [<ffffffff810c37cc>] oom_kill_process+0xdc/0x270
[ 1028.307109]  [<ffffffff810c3b2f>] ? badness+0x18f/0x300
[ 1028.312330]  [<ffffffff810c3dd5>] __out_of_memory+0x135/0x170
[ 1028.318069]  [<ffffffff810c3f05>] out_of_memory+0xf5/0x180
[ 1028.323554]  [<ffffffff810c857c>] __alloc_pages_nodemask+0x6ac/0x6c0
[ 1028.329900]  [<ffffffff810f3ea8>] alloc_pages_current+0x78/0x100
[ 1028.335899]  [<ffffffff810c0c7b>] __page_cache_alloc+0xb/0x10
[ 1028.341639]  [<ffffffff810ca910>] __do_page_cache_readahead+0x120/0x240
[ 1028.348247]  [<ffffffff810ca8a2>] ? __do_page_cache_readahead+0xb2/0x240
[ 1028.354935]  [<ffffffff810caa4c>] ra_submit+0x1c/0x20
[ 1028.359982]  [<ffffffff810cacb3>] ondemand_readahead+0x163/0x2d0
[ 1028.365986]  [<ffffffff810caf25>] page_cache_sync_readahead+0x25/0x30
[ 1028.372422]  [<ffffffff810c141c>] filemap_fault+0x37c/0x400
[ 1028.377985]  [<ffffffff810d9893>] __do_fault+0x53/0x510
[ 1028.383205]  [<ffffffff81271ce0>] ? __down_read_trylock+0x20/0x60
[ 1028.389291]  [<ffffffff810dc4a9>] handle_mm_fault+0x1c9/0x500
[ 1028.395031]  [<ffffffff81548274>] do_page_fault+0x1c4/0x330
[ 1028.400594]  [<ffffffff81545a95>] page_fault+0x25/0x30
[ 1028.405726] Mem-Info:
[ 1028.408001] Node 0 DMA per-cpu:
[ 1028.411161] CPU    0: hi:    0, btch:   1 usd:   0
[ 1028.416012] CPU    1: hi:    0, btch:   1 usd:   0
[ 1028.420860] Node 0 DMA32 per-cpu:
[ 1028.424346] CPU    0: hi:  186, btch:  31 usd: 125
[ 1028.429129] CPU    1: hi:  186, btch:  31 usd:  17
[ 1028.433914] Active_anon:41222 active_file:1015 inactive_anon:47978
[ 1028.433915]  inactive_file:4149 unevictable:4 dirty:0 writeback:0 unstable:0
[ 1028.433916]  free:1168 slab:13459 mapped:4432 pagetables:6766 bounce:0
[ 1028.453622] Node 0 DMA free:2000kB min:84kB low:104kB high:124kB active_anon:5520kB inactive_anon:5776kB active_file:0kB inactive_file:84kB unevictable:0kB present:15164kB pages_scanned:16704 all_unreclaimable? no
[ 1028.472548] lowmem_reserve[]: 0 483 483 483
[ 1028.476811] Node 0 DMA32 free:2672kB min:2768kB low:3460kB high:4152kB active_anon:159368kB inactive_anon:186136kB active_file:4060kB inactive_file:16512kB unevictable:16kB present:495008kB pages_scanned:566633 all_unreclaimable? yes
[ 1028.497459] lowmem_reserve[]: 0 0 0 0
[ 1028.501203] Node 0 DMA: 56*4kB 0*8kB 11*16kB 2*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2000kB
[ 1028.512136] Node 0 DMA32: 278*4kB 3*8kB 4*16kB 8*32kB 1*64kB 3*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 2672kB
[ 1028.523222] 64013 total pagecache pages
[ 1028.527049] 6900 pages in swap cache
[ 1028.530627] Swap cache stats: add 334539, delete 327639, find 36253/163064
[ 1028.537490] Free swap  = 775384kB
[ 1028.540803] Total swap = 1048568kB
[ 1028.547522] 131072 pages RAM
[ 1028.550399] 9628 pages reserved
[ 1028.553550] 79539 pages shared
[ 1028.556607] 57450 pages non-shared
[ 1028.560008] Out of memory: kill process 3487 (run-many-x-apps) score 938661 or a child
[ 1028.567914] Killed process 4046 (gnometris)
[ 1162.209886] Xorg invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0
[ 1162.216441] Pid: 3272, comm: Xorg Not tainted 2.6.30-rc8-mm1 #312
[ 1162.222536] Call Trace:
[ 1162.224993]  [<ffffffff81545006>] ? _spin_unlock+0x26/0x30
[ 1162.230485]  [<ffffffff810c37cc>] oom_kill_process+0xdc/0x270
[ 1162.236231]  [<ffffffff810c3b2f>] ? badness+0x18f/0x300
[ 1162.241461]  [<ffffffff810c3dd5>] __out_of_memory+0x135/0x170
[ 1162.247198]  [<ffffffff810c3f05>] out_of_memory+0xf5/0x180
[ 1162.252677]  [<ffffffff810c857c>] __alloc_pages_nodemask+0x6ac/0x6c0
[ 1162.259027]  [<ffffffff810f3ea8>] alloc_pages_current+0x78/0x100
[ 1162.265027]  [<ffffffff810c7409>] __get_free_pages+0x9/0x50
[ 1162.270599]  [<ffffffff8110e402>] __pollwait+0xc2/0x100
[ 1162.275815]  [<ffffffff81495903>] unix_poll+0x23/0xc0
[ 1162.280860]  [<ffffffff81419ac8>] sock_poll+0x18/0x20
[ 1162.285907]  [<ffffffff8110d9a9>] do_select+0x3e9/0x730
[ 1162.291129]  [<ffffffff8110d5c0>] ? do_select+0x0/0x730
[ 1162.296349]  [<ffffffff8110e340>] ? __pollwait+0x0/0x100
[ 1162.301659]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[ 1162.306706]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[ 1162.311748]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[ 1162.316792]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[ 1162.321840]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[ 1162.326886]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[ 1162.331933]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[ 1162.336979]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[ 1162.342029]  [<ffffffff8110e440>] ? pollwake+0x0/0x60
[ 1162.347071]  [<ffffffff8110deef>] core_sys_select+0x1ff/0x330
[ 1162.352807]  [<ffffffff8110dd38>] ? core_sys_select+0x48/0x330
[ 1162.358644]  [<ffffffffa014954c>] ? i915_gem_throttle_ioctl+0x4c/0x60 [i915]
[ 1162.365687]  [<ffffffff81079ebd>] ? trace_hardirqs_on+0xd/0x10
[ 1162.371511]  [<ffffffff810706cc>] ? getnstimeofday+0x5c/0xf0
[ 1162.377161]  [<ffffffff8106acb9>] ? ktime_get_ts+0x59/0x60
[ 1162.382641]  [<ffffffff8110e27a>] sys_select+0x4a/0x110
[ 1162.387863]  [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b
[ 1162.393865] Mem-Info:
[ 1162.396132] Node 0 DMA per-cpu:
[ 1162.399294] CPU    0: hi:    0, btch:   1 usd:   0
[ 1162.404076] CPU    1: hi:    0, btch:   1 usd:   0
[ 1162.408858] Node 0 DMA32 per-cpu:
[ 1162.412185] CPU    0: hi:  186, btch:  31 usd: 161
[ 1162.416972] CPU    1: hi:  186, btch:  31 usd: 182
[ 1162.421762] Active_anon:42731 active_file:740 inactive_anon:48110
[ 1162.421763]  inactive_file:2851 unevictable:4 dirty:0 writeback:0 unstable:0
[ 1162.421764]  free:1174 slab:13321 mapped:3702 pagetables:6595 bounce:0
[ 1162.441384] Node 0 DMA free:2008kB min:84kB low:104kB high:124kB active_anon:5552kB inactive_anon:5812kB active_file:0kB inactive_file:0kB unevictable:0kB present:15164kB pages_scanned:9376 all_unreclaimable? no
[ 1162.460128] lowmem_reserve[]: 0 483 483 483
[ 1162.464392] Node 0 DMA32 free:2688kB min:2768kB low:3460kB high:4152kB active_anon:165372kB inactive_anon:186628kB active_file:2960kB inactive_file:11404kB unevictable:16kB present:495008kB pages_scanned:675382 all_unreclaimable? yes
[ 1162.485048] lowmem_reserve[]: 0 0 0 0
[ 1162.488797] Node 0 DMA: 56*4kB 1*8kB 11*16kB 2*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2008kB
[ 1162.499720] Node 0 DMA32: 274*4kB 3*8kB 8*16kB 7*32kB 1*64kB 3*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 2688kB
[ 1162.510803] 62374 total pagecache pages
[ 1162.514635] 6690 pages in swap cache
[ 1162.518210] Swap cache stats: add 344648, delete 337958, find 37585/169560
[ 1162.525071] Free swap  = 796012kB
[ 1162.528385] Total swap = 1048568kB
[ 1162.535461] 131072 pages RAM
[ 1162.538352] 9628 pages reserved
[ 1162.541490] 73953 pages shared
[ 1162.544536] 58149 pages non-shared
[ 1162.547940] Out of memory: kill process 3487 (run-many-x-apps) score 918444 or a child
[ 1162.555846] Killed process 4079 (gnect)
[ 1162.634031] /usr/games/gnom invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[ 1162.641791] Pid: 4259, comm: /usr/games/gnom Not tainted 2.6.30-rc8-mm1 #312
[ 1162.648843] Call Trace:
[ 1162.651302]  [<ffffffff81545006>] ? _spin_unlock+0x26/0x30
[ 1162.656786]  [<ffffffff810c37cc>] oom_kill_process+0xdc/0x270
[ 1162.662531]  [<ffffffff810c3b2f>] ? badness+0x18f/0x300
[ 1162.667761]  [<ffffffff810c3dd5>] __out_of_memory+0x135/0x170
[ 1162.673511]  [<ffffffff810c3f05>] out_of_memory+0xf5/0x180
[ 1162.678995]  [<ffffffff810c857c>] __alloc_pages_nodemask+0x6ac/0x6c0
[ 1162.685345]  [<ffffffff810f3ea8>] alloc_pages_current+0x78/0x100
[ 1162.691347]  [<ffffffff810c0c7b>] __page_cache_alloc+0xb/0x10
[ 1162.697086]  [<ffffffff810ca910>] __do_page_cache_readahead+0x120/0x240
[ 1162.703701]  [<ffffffff810ca8a2>] ? __do_page_cache_readahead+0xb2/0x240
[ 1162.710401]  [<ffffffff810caa4c>] ra_submit+0x1c/0x20
[ 1162.715446]  [<ffffffff810c1497>] filemap_fault+0x3f7/0x400
[ 1162.721012]  [<ffffffff810d9893>] __do_fault+0x53/0x510
[ 1162.726236]  [<ffffffff81271ce0>] ? __down_read_trylock+0x20/0x60
[ 1162.732333]  [<ffffffff810dc4a9>] handle_mm_fault+0x1c9/0x500
[ 1162.738088]  [<ffffffff81548274>] do_page_fault+0x1c4/0x330
[ 1162.743659]  [<ffffffff81545a95>] page_fault+0x25/0x30
[ 1162.748793] Mem-Info:
[ 1162.751069] Node 0 DMA per-cpu:
[ 1162.754231] CPU    0: hi:    0, btch:   1 usd:   0
[ 1162.759021] CPU    1: hi:    0, btch:   1 usd:   0
[ 1162.763812] Node 0 DMA32 per-cpu:
[ 1162.767147] CPU    0: hi:  186, btch:  31 usd:  90
[ 1162.771930] CPU    1: hi:  186, btch:  31 usd:  89
[ 1162.776719] Active_anon:42484 active_file:760 inactive_anon:48078
[ 1162.776721]  inactive_file:3351 unevictable:4 dirty:0 writeback:0 unstable:0
[ 1162.776722]  free:1174 slab:13329 mapped:3807 pagetables:6487 bounce:0
[ 1162.796351] Node 0 DMA free:2008kB min:84kB low:104kB high:124kB active_anon:5532kB inactive_anon:5812kB active_file:4kB inactive_file:0kB unevictable:0kB present:15164kB pages_scanned:1408 all_unreclaimable? no
[ 1162.815110] lowmem_reserve[]: 0 483 483 483
[ 1162.819378] Node 0 DMA32 free:2688kB min:2768kB low:3460kB high:4152kB active_anon:164404kB inactive_anon:186500kB active_file:3036kB inactive_file:13404kB unevictable:16kB present:495008kB pages_scanned:40768 all_unreclaimable? no
[ 1162.839863] lowmem_reserve[]: 0 0 0 0
[ 1162.843612] Node 0 DMA: 57*4kB 1*8kB 11*16kB 2*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2012kB
[ 1162.854539] Node 0 DMA32: 274*4kB 4*8kB 8*16kB 7*32kB 1*64kB 3*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 2696kB
[ 1162.865631] 62784 total pagecache pages
[ 1162.869465] 6595 pages in swap cache
[ 1162.873034] Swap cache stats: add 344648, delete 338053, find 37585/169561
[ 1162.879901] Free swap  = 802992kB
[ 1162.883222] Total swap = 1048568kB
[ 1162.891314] 131072 pages RAM
[ 1162.894216] 9628 pages reserved
[ 1162.897365] 74036 pages shared
[ 1162.900414] 58276 pages non-shared
[ 1162.903825] Out of memory: kill process 3487 (run-many-x-apps) score 890891 or a child
[ 1162.911747] Killed process 4113 (gtali)


Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
