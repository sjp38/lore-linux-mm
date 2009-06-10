Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2D60C6B005A
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 01:03:44 -0400 (EDT)
Date: Wed, 10 Jun 2009 13:03:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-ID: <20090610050342.GA8867@localhost>
References: <20090609190128.GA1785@cmpxchg.org> <20090609193702.GA2017@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090609193702.GA2017@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 10, 2009 at 03:37:02AM +0800, Johannes Weiner wrote:
> On Tue, Jun 09, 2009 at 09:01:28PM +0200, Johannes Weiner wrote:
> > [resend with lists cc'd, sorry]
> 
> [and fixed Hugh's email.  crap]
> 
> > Hi,
> > 
> > here is a new iteration of the virtual swap readahead.  Per Hugh's
> > suggestion, I moved the pte collecting to the callsite and thus out
> > ouf swap code.  Unfortunately, I had to bound page_cluster due to an
> > array of that many swap entries on the stack, but I think it is better
> > to limit the cluster size to a sane maximum than using dynamic
> > allocation for this purpose.

Hi Johannes,

When stress testing your patch, I found it triggered many OOM kills.
Around the time of last OOMs, the memory usage is:

             total       used       free     shared    buffers     cached
Mem:           474        468          5          0          0        239
-/+ buffers/cache:        229        244
Swap:         1023        221        802

Thanks,
Fengguang
---

full kernel log:

[  472.528487] /usr/games/glch invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  472.537228] Pid: 4361, comm: /usr/games/glch Not tainted 2.6.30-rc8-mm1 #301
[  472.544293] Call Trace:
[  472.546762]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  472.552259]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  472.558010]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  472.563250]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  472.568991]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  472.574499]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  472.580858]  [<ffffffff810f3e68>] alloc_pages_current+0x78/0x100
[  472.586871]  [<ffffffff810c0c6b>] __page_cache_alloc+0xb/0x10
[  472.592614]  [<ffffffff810ca900>] __do_page_cache_readahead+0x120/0x240
[  472.599222]  [<ffffffff810ca892>] ? __do_page_cache_readahead+0xb2/0x240
[  472.605926]  [<ffffffff810caa3c>] ra_submit+0x1c/0x20
[  472.610987]  [<ffffffff810c1487>] filemap_fault+0x3f7/0x400
[  472.616558]  [<ffffffff810d9883>] __do_fault+0x53/0x510
[  472.621786]  [<ffffffff81271ca0>] ? __down_read_trylock+0x20/0x60
[  472.627874]  [<ffffffff810dc489>] handle_mm_fault+0x1c9/0x500
[  472.633658]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  472.639258]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  472.644413] Mem-Info:
[  472.646698] Node 0 DMA per-cpu:
[  472.649855] CPU    0: hi:    0, btch:   1 usd:   0
[  472.654649] CPU    1: hi:    0, btch:   1 usd:   0
[  472.659439] Node 0 DMA32 per-cpu:
[  472.662774] CPU    0: hi:  186, btch:  31 usd: 114
[  472.667560] CPU    1: hi:  186, btch:  31 usd:  81
[  472.672350] Active_anon:43340 active_file:774 inactive_anon:46297
[  472.672351]  inactive_file:2095 unevictable:4 dirty:0 writeback:0 unstable:0
[  472.672352]  free:1334 slab:13888 mapped:3528 pagetables:7580 bounce:0
[  472.692012] Node 0 DMA free:2016kB min:84kB low:104kB high:124kB active_anon:4892kB inactive_anon:6200kB active_file:12kB inactive_file:172kB unevictable:0kB present:15164kB pages_scanned:6752 all_unreclaimable? no
[  472.711031] lowmem_reserve[]: 0 483 483 483
[  472.715313] Node 0 DMA32 free:3320kB min:2768kB low:3460kB high:4152kB active_anon:168468kB inactive_anon:179064kB active_file:3084kB inactive_file:8208kB unevictable:16kB present:495008kB pages_scanned:265856 all_unreclaimable? no
[  472.735793] lowmem_reserve[]: 0 0 0 0
[  472.739546] Node 0 DMA: 21*4kB 2*8kB 4*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2020kB
[  472.750386] Node 0 DMA32: 220*4kB 23*8kB 17*16kB 14*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 3320kB
[  472.761754] 63776 total pagecache pages
[  472.765589] 9263 pages in swap cache
[  472.769162] Swap cache stats: add 166054, delete 156791, find 14174/51560
[  472.775943] Free swap  = 689708kB
[  472.779264] Total swap = 1048568kB
[  472.786832] 131072 pages RAM
[  472.789713] 9628 pages reserved
[  472.792861] 86958 pages shared
[  472.795921] 56805 pages non-shared
[  472.799325] Out of memory: kill process 3514 (run-many-x-apps) score 1495085 or a child
[  472.807327] Killed process 3516 (xeyes)
[  473.861300] gnobots2 invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
[  473.868615] Pid: 4533, comm: gnobots2 Not tainted 2.6.30-rc8-mm1 #301
[  473.875196] Call Trace:
[  473.877669]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  473.883155]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  473.888919]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  473.894141]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  473.899881]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  473.905362]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  473.911711]  [<ffffffff810f3f76>] alloc_page_vma+0x86/0x1c0
[  473.917276]  [<ffffffff810e9ce8>] read_swap_cache_async+0xd8/0x120
[  473.923451]  [<ffffffff810e9de5>] swapin_readahead+0xb5/0x170
[  473.929194]  [<ffffffff810dac5d>] do_swap_page+0x3fd/0x500
[  473.934677]  [<ffffffff810e9913>] ? lookup_swap_cache+0x13/0x30
[  473.940585]  [<ffffffff810da8da>] ? do_swap_page+0x7a/0x500
[  473.946152]  [<ffffffff810dc70e>] handle_mm_fault+0x44e/0x500
[  473.951898]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  473.957464]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  473.962601] Mem-Info:
[  473.964870] Node 0 DMA per-cpu:
[  473.968036] CPU    0: hi:    0, btch:   1 usd:   0
[  473.972818] CPU    1: hi:    0, btch:   1 usd:   0
[  473.977601] Node 0 DMA32 per-cpu:
[  473.980930] CPU    0: hi:  186, btch:  31 usd:  78
[  473.985718] CPU    1: hi:  186, btch:  31 usd:  79
[  473.990512] Active_anon:43366 active_file:728 inactive_anon:46639
[  473.990513]  inactive_file:2442 unevictable:4 dirty:0 writeback:0 unstable:0
[  473.990515]  free:1187 slab:13677 mapped:3344 pagetables:7560 bounce:0
[  474.010136] Node 0 DMA free:2008kB min:84kB low:104kB high:124kB active_anon:4872kB inactive_anon:6360kB active_file:28kB inactive_file:96kB unevictable:0kB present:15164kB pages_scanned:15568 all_unreclaimable? no
[  474.029143] lowmem_reserve[]: 0 483 483 483
[  474.033403] Node 0 DMA32 free:2740kB min:2768kB low:3460kB high:4152kB active_anon:168592kB inactive_anon:180308kB active_file:2884kB inactive_file:9672kB unevictable:16kB present:495008kB pages_scanned:627904 all_unreclaimable? yes
[  474.053974] lowmem_reserve[]: 0 0 0 0
[  474.057721] Node 0 DMA: 16*4kB 3*8kB 4*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2008kB
[  474.068556] Node 0 DMA32: 105*4kB 6*8kB 16*16kB 15*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2740kB
[  474.079825] 64075 total pagecache pages
[  474.083660] 9277 pages in swap cache
[  474.087235] Swap cache stats: add 166129, delete 156852, find 14175/51619
[  474.094011] Free swap  = 690168kB
[  474.097327] Total swap = 1048568kB
[  474.104333] 131072 pages RAM
[  474.107225] 9628 pages reserved
[  474.110363] 84659 pages shared
[  474.113409] 57530 pages non-shared
[  474.116816] Out of memory: kill process 3514 (run-many-x-apps) score 1490267 or a child
[  474.124811] Killed process 3593 (gthumb)
[  480.443446] gnome-network-p invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
[  480.451749] Pid: 5242, comm: gnome-network-p Not tainted 2.6.30-rc8-mm1 #301
[  480.458883] Call Trace:
[  480.461362]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  480.467248]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  480.473025]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  480.478294]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  480.484050]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  480.489546]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  480.495920]  [<ffffffff810f3f76>] alloc_page_vma+0x86/0x1c0
[  480.501509]  [<ffffffff810e9ce8>] read_swap_cache_async+0xd8/0x120
[  480.507718]  [<ffffffff810e9de5>] swapin_readahead+0xb5/0x170
[  480.513477]  [<ffffffff810dac5d>] do_swap_page+0x3fd/0x500
[  480.518982]  [<ffffffff810e9913>] ? lookup_swap_cache+0x13/0x30
[  480.524917]  [<ffffffff810da8da>] ? do_swap_page+0x7a/0x500
[  480.530515]  [<ffffffff810dc70e>] handle_mm_fault+0x44e/0x500
[  480.536273]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  480.541865]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  480.547023] Mem-Info:
[  480.549305] Node 0 DMA per-cpu:
[  480.552485] CPU    0: hi:    0, btch:   1 usd:   0
[  480.557293] CPU    1: hi:    0, btch:   1 usd:   0
[  480.562106] Node 0 DMA32 per-cpu:
[  480.565450] CPU    0: hi:  186, btch:  31 usd: 166
[  480.570260] CPU    1: hi:  186, btch:  31 usd:  54
[  480.575072] Active_anon:43200 active_file:1328 inactive_anon:46633
[  480.575077]  inactive_file:2266 unevictable:4 dirty:0 writeback:0 unstable:0
[  480.575081]  free:1175 slab:13522 mapped:4094 pagetables:7430 bounce:0
[  480.594826] Node 0 DMA free:2004kB min:84kB low:104kB high:124kB active_anon:5048kB inactive_anon:6228kB active_file:24kB inactive_file:92kB unevictable:0kB present:15164kB pages_scanned:20576 all_unreclaimable? yes
[  480.613968] lowmem_reserve[]: 0 483 483 483
[  480.618302] Node 0 DMA32 free:2696kB min:2768kB low:3460kB high:4152kB active_anon:167804kB inactive_anon:180304kB active_file:5324kB inactive_file:9012kB unevictable:16kB present:495008kB pages_scanned:698592 all_unreclaimable? yes
[  480.638902] lowmem_reserve[]: 0 0 0 0
[  480.642709] Node 0 DMA: 15*4kB 1*8kB 4*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 1988kB
[  480.653661] Node 0 DMA32: 100*4kB 5*8kB 15*16kB 15*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2696kB
[  480.665062] 64296 total pagecache pages
[  480.668909] 9027 pages in swap cache
[  480.672486] Swap cache stats: add 166520, delete 157493, find 14190/51963
[  480.679265] Free swap  = 697604kB
[  480.682590] Total swap = 1048568kB
[  480.692920] 131072 pages RAM
[  480.695835] 9628 pages reserved
[  480.698989] 83496 pages shared
[  480.702055] 56997 pages non-shared
[  480.705460] Out of memory: kill process 3514 (run-many-x-apps) score 1233725 or a child
[  480.713480] Killed process 3620 (gedit)
[  485.239788] firefox-bin invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  485.247180] Pid: 3407, comm: firefox-bin Not tainted 2.6.30-rc8-mm1 #301
[  485.253879] Call Trace:
[  485.256340]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  485.261825]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  485.267587]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  485.272810]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  485.278556]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  485.284034]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  485.290383]  [<ffffffff810f3e68>] alloc_pages_current+0x78/0x100
[  485.296384]  [<ffffffff810c0c6b>] __page_cache_alloc+0xb/0x10
[  485.302127]  [<ffffffff810ca900>] __do_page_cache_readahead+0x120/0x240
[  485.308729]  [<ffffffff810ca892>] ? __do_page_cache_readahead+0xb2/0x240
[  485.315421]  [<ffffffff810caa3c>] ra_submit+0x1c/0x20
[  485.320471]  [<ffffffff810c1487>] filemap_fault+0x3f7/0x400
[  485.326044]  [<ffffffff810d9883>] __do_fault+0x53/0x510
[  485.331264]  [<ffffffff81271ca0>] ? __down_read_trylock+0x20/0x60
[  485.337348]  [<ffffffff810dc489>] handle_mm_fault+0x1c9/0x500
[  485.343091]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  485.348660]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  485.353794] Mem-Info:
[  485.356074] Node 0 DMA per-cpu:
[  485.359238] CPU    0: hi:    0, btch:   1 usd:   0
[  485.364022] CPU    1: hi:    0, btch:   1 usd:   0
[  485.368805] Node 0 DMA32 per-cpu:
[  485.372130] CPU    0: hi:  186, btch:  31 usd:  86
[  485.376917] CPU    1: hi:  186, btch:  31 usd:  65
[  485.381704] Active_anon:43069 active_file:1343 inactive_anon:46566
[  485.381705]  inactive_file:2264 unevictable:4 dirty:0 writeback:0 unstable:0
[  485.381706]  free:1177 slab:13765 mapped:3976 pagetables:7336 bounce:0
[  485.401416] Node 0 DMA free:2000kB min:84kB low:104kB high:124kB active_anon:5096kB inactive_anon:6228kB active_file:24kB inactive_file:0kB unevictable:0kB present:15164kB pages_scanned:14624 all_unreclaimable? no
[  485.420352] lowmem_reserve[]: 0 483 483 483
[  485.424627] Node 0 DMA32 free:2708kB min:2768kB low:3460kB high:4152kB active_anon:167180kB inactive_anon:180036kB active_file:5348kB inactive_file:9072kB unevictable:16kB present:495008kB pages_scanned:700592 all_unreclaimable? yes
[  485.445209] lowmem_reserve[]: 0 0 0 0
[  485.448983] Node 0 DMA: 25*4kB 1*8kB 3*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2012kB
[  485.459812] Node 0 DMA32: 97*4kB 8*8kB 15*16kB 15*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2708kB
[  485.470995] 64132 total pagecache pages
[  485.474826] 8910 pages in swap cache
[  485.478397] Swap cache stats: add 166970, delete 158060, find 14213/52337
[  485.485171] Free swap  = 704464kB
[  485.488481] Total swap = 1048568kB
[  485.495505] 131072 pages RAM
[  485.498400] 9628 pages reserved
[  485.501539] 80730 pages shared
[  485.504593] 57330 pages non-shared
[  485.507994] Out of memory: kill process 3514 (run-many-x-apps) score 1208843 or a child
[  485.515986] Killed process 3653 (xpdf.bin)
[  487.520227] blackjack invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
[  487.527723] Pid: 4579, comm: blackjack Not tainted 2.6.30-rc8-mm1 #301
[  487.534650] Call Trace:
[  487.537290]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  487.542782]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  487.548533]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  487.553767]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  487.559522]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  487.565003]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  487.571353]  [<ffffffff810f3f76>] alloc_page_vma+0x86/0x1c0
[  487.576933]  [<ffffffff810e9ce8>] read_swap_cache_async+0xd8/0x120
[  487.583117]  [<ffffffff810e9e19>] swapin_readahead+0xe9/0x170
[  487.588860]  [<ffffffff810d1167>] shmem_getpage+0x607/0x970
[  487.594432]  [<ffffffff810a9c8b>] ? delayacct_end+0x6b/0xa0
[  487.600003]  [<ffffffff810a9caa>] ? delayacct_end+0x8a/0xa0
[  487.605571]  [<ffffffff810a9d2f>] ? __delayacct_blkio_end+0x2f/0x50
[  487.611837]  [<ffffffff81542132>] ? io_schedule+0x82/0xb0
[  487.617229]  [<ffffffff8107ca35>] ? print_lock_contention_bug+0x25/0x120
[  487.623927]  [<ffffffff810c0970>] ? sync_page+0x0/0x80
[  487.629060]  [<ffffffff810c0700>] ? find_get_page+0x0/0x110
[  487.634633]  [<ffffffff81052702>] ? current_fs_time+0x22/0x30
[  487.640372]  [<ffffffff810d9983>] ? __do_fault+0x153/0x510
[  487.645849]  [<ffffffff8107ca35>] ? print_lock_contention_bug+0x25/0x120
[  487.652542]  [<ffffffff810d151a>] shmem_fault+0x4a/0x80
[  487.657762]  [<ffffffff812444a9>] shm_fault+0x19/0x20
[  487.662819]  [<ffffffff810d9883>] __do_fault+0x53/0x510
[  487.668036]  [<ffffffff81271ca0>] ? __down_read_trylock+0x20/0x60
[  487.674125]  [<ffffffff810dc489>] handle_mm_fault+0x1c9/0x500
[  487.679867]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  487.685434]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  487.690570] Mem-Info:
[  487.692836] Node 0 DMA per-cpu:
[  487.696003] CPU    0: hi:    0, btch:   1 usd:   0
[  487.700790] CPU    1: hi:    0, btch:   1 usd:   0
[  487.705578] Node 0 DMA32 per-cpu:
[  487.708906] CPU    0: hi:  186, btch:  31 usd: 142
[  487.713698] CPU    1: hi:  186, btch:  31 usd:  77
[  487.718498] Active_anon:42533 active_file:677 inactive_anon:46561
[  487.718499]  inactive_file:3214 unevictable:4 dirty:0 writeback:0 unstable:0
[  487.718500]  free:1573 slab:13680 mapped:3351 pagetables:7308 bounce:0
[  487.738125] Node 0 DMA free:2064kB min:84kB low:104kB high:124kB active_anon:5152kB inactive_anon:6328kB active_file:8kB inactive_file:92kB unevictable:0kB present:15164kB pages_scanned:1586 all_unreclaimable? no
[  487.756958] lowmem_reserve[]: 0 483 483 483
[  487.761221] Node 0 DMA32 free:4228kB min:2768kB low:3460kB high:4152kB active_anon:164980kB inactive_anon:180068kB active_file:2700kB inactive_file:12764kB unevictable:16kB present:495008kB pages_scanned:42720 all_unreclaimable? no
[  487.781711] lowmem_reserve[]: 0 0 0 0
[  487.785458] Node 0 DMA: 37*4kB 2*8kB 3*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2068kB
[  487.796294] Node 0 DMA32: 271*4kB 105*8kB 16*16kB 16*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 4228kB
[  487.807722] 64270 total pagecache pages
[  487.811557] 8728 pages in swap cache
[  487.815132] Swap cache stats: add 167087, delete 158359, find 14218/52435
[  487.821908] Free swap  = 711028kB
[  487.825220] Total swap = 1048568kB
[  487.832277] 131072 pages RAM
[  487.835178] 9628 pages reserved
[  487.838317] 76338 pages shared
[  487.841364] 57425 pages non-shared
[  487.844768] Out of memory: kill process 3514 (run-many-x-apps) score 1201219 or a child
[  487.852761] Killed process 3696 (xterm)
[  487.857092] tty_ldisc_deref: no references.
[  489.747066] firefox-bin invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  489.754480] Pid: 5404, comm: firefox-bin Not tainted 2.6.30-rc8-mm1 #301
[  489.761179] Call Trace:
[  489.763640]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  489.769123]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  489.774870]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  489.780090]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  489.785830]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  489.791315]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  489.797665]  [<ffffffff810f3e68>] alloc_pages_current+0x78/0x100
[  489.803672]  [<ffffffff810c0c6b>] __page_cache_alloc+0xb/0x10
[  489.809409]  [<ffffffff810ca900>] __do_page_cache_readahead+0x120/0x240
[  489.816020]  [<ffffffff810ca892>] ? __do_page_cache_readahead+0xb2/0x240
[  489.822723]  [<ffffffff810caa3c>] ra_submit+0x1c/0x20
[  489.827771]  [<ffffffff810c1487>] filemap_fault+0x3f7/0x400
[  489.833338]  [<ffffffff810d9883>] __do_fault+0x53/0x510
[  489.838565]  [<ffffffff81271ca0>] ? __down_read_trylock+0x20/0x60
[  489.844653]  [<ffffffff810dc489>] handle_mm_fault+0x1c9/0x500
[  489.850404]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  489.855970]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  489.861101] Mem-Info:
[  489.863375] Node 0 DMA per-cpu:
[  489.866538] CPU    0: hi:    0, btch:   1 usd:   0
[  489.871327] CPU    1: hi:    0, btch:   1 usd:   0
[  489.876114] Node 0 DMA32 per-cpu:
[  489.879450] CPU    0: hi:  186, btch:  31 usd: 139
[  489.884235] CPU    1: hi:  186, btch:  31 usd: 168
[  489.889020] Active_anon:42548 active_file:713 inactive_anon:46654
[  489.889022]  inactive_file:3551 unevictable:4 dirty:0 writeback:0 unstable:0
[  489.889023]  free:1191 slab:13619 mapped:3463 pagetables:7277 bounce:0
[  489.908648] Node 0 DMA free:2000kB min:84kB low:104kB high:124kB active_anon:5156kB inactive_anon:6324kB active_file:0kB inactive_file:0kB unevictable:0kB present:15164kB pages_scanned:18048 all_unreclaimable? yes
[  489.927583] lowmem_reserve[]: 0 483 483 483
[  489.931852] Node 0 DMA32 free:2764kB min:2768kB low:3460kB high:4152kB active_anon:165036kB inactive_anon:180292kB active_file:2852kB inactive_file:14204kB unevictable:16kB present:495008kB pages_scanned:598624 all_unreclaimable? yes
[  489.952505] lowmem_reserve[]: 0 0 0 0
[  489.956255] Node 0 DMA: 24*4kB 2*8kB 3*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2016kB
[  489.967104] Node 0 DMA32: 67*4kB 16*8kB 20*16kB 16*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2764kB
[  489.978371] 64571 total pagecache pages
[  489.982209] 8716 pages in swap cache
[  489.985779] Swap cache stats: add 167160, delete 158444, find 14228/52496
[  489.992561] Free swap  = 712436kB
[  489.995878] Total swap = 1048568kB
[  490.003023] 131072 pages RAM
[  490.005917] 9628 pages reserved
[  490.009051] 77164 pages shared
[  490.012111] 57863 pages non-shared
[  490.015516] Out of memory: kill process 3514 (run-many-x-apps) score 1193943 or a child
[  490.023514] Killed process 3789 (gnome-terminal)
[  490.042359] gnome-terminal invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
[  490.050059] Pid: 3817, comm: gnome-terminal Not tainted 2.6.30-rc8-mm1 #301
[  490.057019] Call Trace:
[  490.059490]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  490.064986]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  490.070743]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  490.075981]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  490.081738]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  490.087245]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  490.093606]  [<ffffffff810f3f76>] alloc_page_vma+0x86/0x1c0
[  490.099200]  [<ffffffff810e9ce8>] read_swap_cache_async+0xd8/0x120
[  490.105390]  [<ffffffff810e9de5>] swapin_readahead+0xb5/0x170
[  490.111157]  [<ffffffff810dac5d>] do_swap_page+0x3fd/0x500
[  490.116651]  [<ffffffff810e9913>] ? lookup_swap_cache+0x13/0x30
[  490.122581]  [<ffffffff810da8da>] ? do_swap_page+0x7a/0x500
[  490.128166]  [<ffffffff810dc70e>] handle_mm_fault+0x44e/0x500
[  490.133932]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  490.139510]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  490.144658]  [<ffffffff8127600c>] ? __get_user_8+0x1c/0x23
[  490.150157]  [<ffffffff810806ad>] ? exit_robust_list+0x5d/0x160
[  490.156088]  [<ffffffff81077c4d>] ? trace_hardirqs_off+0xd/0x10
[  490.162026]  [<ffffffff81544f97>] ? _spin_unlock_irqrestore+0x67/0x70
[  490.168473]  [<ffffffff8104ae5d>] mm_release+0xed/0x100
[  490.173707]  [<ffffffff8104f653>] exit_mm+0x23/0x150
[  490.178684]  [<ffffffff81544f1b>] ? _spin_unlock_irq+0x2b/0x40
[  490.184528]  [<ffffffff81051208>] do_exit+0x138/0x880
[  490.189593]  [<ffffffff8105e757>] ? get_signal_to_deliver+0x67/0x430
[  490.195967]  [<ffffffff81051998>] do_group_exit+0x48/0xd0
[  490.201373]  [<ffffffff8105e9d4>] get_signal_to_deliver+0x2e4/0x430
[  490.207653]  [<ffffffff8100b332>] do_notify_resume+0xc2/0x820
[  490.213410]  [<ffffffff81012859>] ? sched_clock+0x9/0x10
[  490.218743]  [<ffffffff81077c85>] ? lock_release_holdtime+0x35/0x1c0
[  490.225102]  [<ffffffff810fd768>] ? vfs_read+0xc8/0x1a0
[  490.230340]  [<ffffffff8100c057>] sysret_signal+0x83/0xd9
[  490.235750] Mem-Info:
[  490.238041] Node 0 DMA per-cpu:
[  490.241213] CPU    0: hi:    0, btch:   1 usd:   0
[  490.246023] CPU    1: hi:    0, btch:   1 usd:   0
[  490.250817] Node 0 DMA32 per-cpu:
[  490.254173] CPU    0: hi:  186, btch:  31 usd: 139
[  490.258976] CPU    1: hi:  186, btch:  31 usd: 169
[  490.263781] Active_anon:42548 active_file:713 inactive_anon:46660
[  490.263784]  inactive_file:3551 unevictable:4 dirty:0 writeback:0 unstable:0
[  490.263787]  free:1191 slab:13619 mapped:3463 pagetables:7277 bounce:0
[  490.283433] Node 0 DMA free:2000kB min:84kB low:104kB high:124kB active_anon:5156kB inactive_anon:6324kB active_file:0kB inactive_file:0kB unevictable:0kB present:15164kB pages_scanned:18048 all_unreclaimable? yes
[  490.302379] lowmem_reserve[]: 0 483 483 483
[  490.306699] Node 0 DMA32 free:2764kB min:2768kB low:3460kB high:4152kB active_anon:165036kB inactive_anon:180316kB active_file:2852kB inactive_file:14204kB unevictable:16kB present:495008kB pages_scanned:616288 all_unreclaimable? yes
[  490.327380] lowmem_reserve[]: 0 0 0 0
[  490.331178] Node 0 DMA: 24*4kB 2*8kB 3*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2016kB
[  490.342134] Node 0 DMA32: 67*4kB 16*8kB 20*16kB 16*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2764kB
[  490.353506] 64571 total pagecache pages
[  490.357357] 8716 pages in swap cache
[  490.360943] Swap cache stats: add 167160, delete 158444, find 14228/52497
[  490.367735] Free swap  = 712436kB
[  490.371063] Total swap = 1048568kB
[  490.381335] 131072 pages RAM
[  490.384247] 9628 pages reserved
[  490.387398] 77163 pages shared
[  490.390461] 57864 pages non-shared
[  491.721918] tty_ldisc_deref: no references.
[  507.974133] Xorg invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  507.981095] Pid: 3308, comm: Xorg Not tainted 2.6.30-rc8-mm1 #301
[  507.987465] Call Trace:
[  507.990171]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  507.995670]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  508.001413]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  508.006640]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  508.012378]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  508.017857]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  508.024207]  [<ffffffff810f3e68>] alloc_pages_current+0x78/0x100
[  508.030211]  [<ffffffff810c0c6b>] __page_cache_alloc+0xb/0x10
[  508.035951]  [<ffffffff810ca900>] __do_page_cache_readahead+0x120/0x240
[  508.042555]  [<ffffffff810ca892>] ? __do_page_cache_readahead+0xb2/0x240
[  508.049248]  [<ffffffff810caa3c>] ra_submit+0x1c/0x20
[  508.054298]  [<ffffffff810c1487>] filemap_fault+0x3f7/0x400
[  508.059864]  [<ffffffff810d9883>] __do_fault+0x53/0x510
[  508.065082]  [<ffffffff81271ca0>] ? __down_read_trylock+0x20/0x60
[  508.071170]  [<ffffffff810dc489>] handle_mm_fault+0x1c9/0x500
[  508.076916]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  508.082488]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  508.087617] Mem-Info:
[  508.089890] Node 0 DMA per-cpu:
[  508.093045] CPU    0: hi:    0, btch:   1 usd:   0
[  508.097831] CPU    1: hi:    0, btch:   1 usd:   0
[  508.102618] Node 0 DMA32 per-cpu:
[  508.105949] CPU    0: hi:  186, btch:  31 usd:  70
[  508.110732] CPU    1: hi:  186, btch:  31 usd:  35
[  508.115518] Active_anon:43375 active_file:1606 inactive_anon:46595
[  508.115519]  inactive_file:2431 unevictable:4 dirty:0 writeback:0 unstable:0
[  508.115520]  free:1171 slab:13500 mapped:4464 pagetables:7137 bounce:0
[  508.135223] Node 0 DMA free:2000kB min:84kB low:104kB high:124kB active_anon:5372kB inactive_anon:6304kB active_file:48kB inactive_file:152kB unevictable:0kB present:15164kB pages_scanned:18016 all_unreclaimable? yes
[  508.154402] lowmem_reserve[]: 0 483 483 483
[  508.158670] Node 0 DMA32 free:2684kB min:2768kB low:3460kB high:4152kB active_anon:168128kB inactive_anon:180076kB active_file:6376kB inactive_file:9572kB unevictable:16kB present:495008kB pages_scanned:574528 all_unreclaimable? yes
[  508.179230] lowmem_reserve[]: 0 0 0 0
[  508.182977] Node 0 DMA: 20*4kB 2*8kB 3*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2000kB
[  508.193806] Node 0 DMA32: 81*4kB 9*8kB 17*16kB 15*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2684kB
[  508.204972] 64466 total pagecache pages
[  508.208804] 8648 pages in swap cache
[  508.212374] Swap cache stats: add 169110, delete 160462, find 14531/53889
[  508.219151] Free swap  = 723636kB
[  508.222465] Total swap = 1048568kB
[  508.229465] 131072 pages RAM
[  508.232364] 9628 pages reserved
[  508.235504] 80834 pages shared
[  508.238558] 57150 pages non-shared
[  508.241961] Out of memory: kill process 3514 (run-many-x-apps) score 1142844 or a child
[  508.249954] Killed process 3828 (urxvt)
[  508.254826] tty_ldisc_deref: no references.
[  518.644007] /usr/games/gnom invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  518.652048] Pid: 4284, comm: /usr/games/gnom Not tainted 2.6.30-rc8-mm1 #301
[  518.659110] Call Trace:
[  518.661572]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  518.667060]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  518.672805]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  518.678036]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  518.683779]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  518.689265]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  518.695629]  [<ffffffff810f3e68>] alloc_pages_current+0x78/0x100
[  518.701648]  [<ffffffff810c0c6b>] __page_cache_alloc+0xb/0x10
[  518.707396]  [<ffffffff810ca900>] __do_page_cache_readahead+0x120/0x240
[  518.714015]  [<ffffffff810ca892>] ? __do_page_cache_readahead+0xb2/0x240
[  518.720728]  [<ffffffff810caa3c>] ra_submit+0x1c/0x20
[  518.725782]  [<ffffffff810c1487>] filemap_fault+0x3f7/0x400
[  518.731376]  [<ffffffff810d9883>] __do_fault+0x53/0x510
[  518.736610]  [<ffffffff81271ca0>] ? __down_read_trylock+0x20/0x60
[  518.742724]  [<ffffffff810dc489>] handle_mm_fault+0x1c9/0x500
[  518.748470]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  518.754050]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  518.759186] Mem-Info:
[  518.761457] Node 0 DMA per-cpu:
[  518.764622] CPU    0: hi:    0, btch:   1 usd:   0
[  518.769433] CPU    1: hi:    0, btch:   1 usd:   0
[  518.774250] Node 0 DMA32 per-cpu:
[  518.777607] CPU    0: hi:  186, btch:  31 usd: 122
[  518.782429] CPU    1: hi:  186, btch:  31 usd: 140
[  518.787320] Active_anon:43558 active_file:800 inactive_anon:46596
[  518.787322]  inactive_file:3200 unevictable:4 dirty:0 writeback:1 unstable:0
[  518.787324]  free:1170 slab:13276 mapped:3632 pagetables:7067 bounce:0
[  518.806969] Node 0 DMA free:2004kB min:84kB low:104kB high:124kB active_anon:5392kB inactive_anon:6284kB active_file:8kB inactive_file:192kB unevictable:0kB present:15164kB pages_scanned:0 all_unreclaimable? no
[  518.825631] lowmem_reserve[]: 0 483 483 483
[  518.829894] Node 0 DMA32 free:2676kB min:2768kB low:3460kB high:4152kB active_anon:168840kB inactive_anon:180100kB active_file:3192kB inactive_file:12608kB unevictable:16kB present:495008kB pages_scanned:2752 all_unreclaimable? no
[  518.850287] lowmem_reserve[]: 0 0 0 0
[  518.854034] Node 0 DMA: 17*4kB 2*8kB 4*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2004kB
[  518.864860] Node 0 DMA32: 51*4kB 9*8kB 22*16kB 16*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2676kB
[  518.876047] 64523 total pagecache pages
[  518.879879] 8754 pages in swap cache
[  518.883453] Swap cache stats: add 169415, delete 160661, find 14593/54101
[  518.890231] Free swap  = 727320kB
[  518.893549] Total swap = 1048568kB
[  518.900474] 131072 pages RAM
[  518.903375] 9628 pages reserved
[  518.906522] 75910 pages shared
[  518.909579] 57545 pages non-shared
[  518.912975] Out of memory: kill process 3514 (run-many-x-apps) score 1125494 or a child
[  518.920971] Killed process 3913 (gnome-system-mo)
[  664.508168] Xorg invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  664.514995] Pid: 3308, comm: Xorg Not tainted 2.6.30-rc8-mm1 #301
[  664.521111] Call Trace:
[  664.523568]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  664.529049]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  664.534794]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  664.540021]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  664.545757]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  664.551235]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  664.557591]  [<ffffffff810f3e68>] alloc_pages_current+0x78/0x100
[  664.563593]  [<ffffffff810c0c6b>] __page_cache_alloc+0xb/0x10
[  664.569336]  [<ffffffff810ca900>] __do_page_cache_readahead+0x120/0x240
[  664.575947]  [<ffffffff810ca892>] ? __do_page_cache_readahead+0xb2/0x240
[  664.582648]  [<ffffffff810caa3c>] ra_submit+0x1c/0x20
[  664.587710]  [<ffffffff810c1487>] filemap_fault+0x3f7/0x400
[  664.593282]  [<ffffffff810d9883>] __do_fault+0x53/0x510
[  664.598508]  [<ffffffff81271ca0>] ? __down_read_trylock+0x20/0x60
[  664.604603]  [<ffffffff810dc489>] handle_mm_fault+0x1c9/0x500
[  664.610357]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  664.615937]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  664.621071] Mem-Info:
[  664.623341] Node 0 DMA per-cpu:
[  664.626517] CPU    0: hi:    0, btch:   1 usd:   0
[  664.631305] CPU    1: hi:    0, btch:   1 usd:   0
[  664.636096] Node 0 DMA32 per-cpu:
[  664.639430] CPU    0: hi:  186, btch:  31 usd: 108
[  664.644229] CPU    1: hi:  186, btch:  31 usd: 104
[  664.649022] Active_anon:42958 active_file:868 inactive_anon:46862
[  664.649024]  inactive_file:3541 unevictable:4 dirty:0 writeback:0 unstable:0
[  664.649026]  free:1182 slab:13288 mapped:3904 pagetables:7002 bounce:0
[  664.668657] Node 0 DMA free:2004kB min:84kB low:104kB high:124kB active_anon:5528kB inactive_anon:6256kB active_file:0kB inactive_file:56kB unevictable:0kB present:15164kB pages_scanned:17829 all_unreclaimable? yes
[  664.687670] lowmem_reserve[]: 0 483 483 483
[  664.691974] Node 0 DMA32 free:2724kB min:2768kB low:3460kB high:4152kB active_anon:166304kB inactive_anon:181192kB active_file:3472kB inactive_file:14108kB unevictable:16kB present:495008kB pages_scanned:561984 all_unreclaimable? yes
[  664.712637] lowmem_reserve[]: 0 0 0 0
[  664.716412] Node 0 DMA: 21*4kB 2*8kB 4*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2020kB
[  664.727297] Node 0 DMA32: 83*4kB 9*8kB 17*16kB 16*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2724kB
[  664.738494] 64381 total pagecache pages
[  664.742329] 7902 pages in swap cache
[  664.745909] Swap cache stats: add 174458, delete 166556, find 14826/56928
[  664.752696] Free swap  = 734732kB
[  664.756012] Total swap = 1048568kB
[  664.763953] 131072 pages RAM
[  664.766845] 9628 pages reserved
[  664.769992] 74903 pages shared
[  664.773047] 58244 pages non-shared
[  664.776465] Out of memory: kill process 3514 (run-many-x-apps) score 1094818 or a child
[  664.784464] Killed process 3941 (gnome-help)
[  700.167781] Xorg invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0
[  700.174355] Pid: 3308, comm: Xorg Not tainted 2.6.30-rc8-mm1 #301
[  700.180473] Call Trace:
[  700.182949]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  700.188480]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  700.194247]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  700.199501]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  700.205257]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  700.210748]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  700.217115]  [<ffffffff810f3e68>] alloc_pages_current+0x78/0x100
[  700.223132]  [<ffffffff810c73f9>] __get_free_pages+0x9/0x50
[  700.228731]  [<ffffffff8110e3c2>] __pollwait+0xc2/0x100
[  700.233966]  [<ffffffff814958c3>] unix_poll+0x23/0xc0
[  700.239025]  [<ffffffff81419a88>] sock_poll+0x18/0x20
[  700.244095]  [<ffffffff8110d969>] do_select+0x3e9/0x730
[  700.249333]  [<ffffffff8110d580>] ? do_select+0x0/0x730
[  700.254575]  [<ffffffff8110e300>] ? __pollwait+0x0/0x100
[  700.259909]  [<ffffffff8110e400>] ? pollwake+0x0/0x60
[  700.264976]  [<ffffffff8110e400>] ? pollwake+0x0/0x60
[  700.270034]  [<ffffffff8110e400>] ? pollwake+0x0/0x60
[  700.275093]  [<ffffffff8110e400>] ? pollwake+0x0/0x60
[  700.280157]  [<ffffffff8110e400>] ? pollwake+0x0/0x60
[  700.285223]  [<ffffffff8110e400>] ? pollwake+0x0/0x60
[  700.290287]  [<ffffffff8110e400>] ? pollwake+0x0/0x60
[  700.295360]  [<ffffffff8110e400>] ? pollwake+0x0/0x60
[  700.300416]  [<ffffffff8110e400>] ? pollwake+0x0/0x60
[  700.305475]  [<ffffffff8110deaf>] core_sys_select+0x1ff/0x330
[  700.311225]  [<ffffffff8110dcf8>] ? core_sys_select+0x48/0x330
[  700.317068]  [<ffffffffa014954c>] ? i915_gem_throttle_ioctl+0x4c/0x60 [i915]
[  700.324109]  [<ffffffff810fcf9a>] ? do_readv_writev+0x16a/0x1f0
[  700.330037]  [<ffffffff810706bc>] ? getnstimeofday+0x5c/0xf0
[  700.335708]  [<ffffffff8106aca9>] ? ktime_get_ts+0x59/0x60
[  700.341207]  [<ffffffff8110e23a>] sys_select+0x4a/0x110
[  700.346450]  [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b
[  700.352471] Mem-Info:
[  700.354744] Node 0 DMA per-cpu:
[  700.357931] CPU    0: hi:    0, btch:   1 usd:   0
[  700.362728] CPU    1: hi:    0, btch:   1 usd:   0
[  700.367528] Node 0 DMA32 per-cpu:
[  700.370869] CPU    0: hi:  186, btch:  31 usd: 124
[  700.375681] CPU    1: hi:  186, btch:  31 usd: 109
[  700.380485] Active_anon:42750 active_file:1211 inactive_anon:46836
[  700.380487]  inactive_file:3834 unevictable:4 dirty:0 writeback:0 unstable:0
[  700.380490]  free:1185 slab:13047 mapped:4269 pagetables:6879 bounce:0
[  700.400224] Node 0 DMA free:2016kB min:84kB low:104kB high:124kB active_anon:5504kB inactive_anon:6244kB active_file:4kB inactive_file:20kB unevictable:0kB present:15164kB pages_scanned:21160 all_unreclaimable? no
[  700.419171] lowmem_reserve[]: 0 483 483 483
[  700.423495] Node 0 DMA32 free:2724kB min:2768kB low:3460kB high:4152kB active_anon:165496kB inactive_anon:181100kB active_file:4840kB inactive_file:15316kB unevictable:16kB present:495008kB pages_scanned:749440 all_unreclaimable? yes
[  700.444177] lowmem_reserve[]: 0 0 0 0
[  700.447982] Node 0 DMA: 24*4kB 2*8kB 3*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2016kB
[  700.458919] Node 0 DMA32: 95*4kB 7*8kB 15*16kB 16*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2724kB
[  700.470109] 64769 total pagecache pages
[  700.473944] 7685 pages in swap cache
[  700.477521] Swap cache stats: add 174858, delete 167173, find 14884/57219
[  700.484305] Free swap  = 756796kB
[  700.487619] Total swap = 1048568kB
[  700.495533] 131072 pages RAM
[  700.498435] 9628 pages reserved
[  700.501585] 75677 pages shared
[  700.504647] 57992 pages non-shared
[  700.508062] Out of memory: kill process 3514 (run-many-x-apps) score 920259 or a child
[  700.515981] Killed process 3972 (gnome-dictionar)
[  772.754850] firefox-bin invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  772.762316] Pid: 3363, comm: firefox-bin Not tainted 2.6.30-rc8-mm1 #301
[  772.769042] Call Trace:
[  772.771532]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  772.777056]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  772.782830]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  772.788093]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  772.793861]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  772.799371]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  772.805903]  [<ffffffff810f3e68>] alloc_pages_current+0x78/0x100
[  772.812044]  [<ffffffff810c0c6b>] __page_cache_alloc+0xb/0x10
[  772.817979]  [<ffffffff810ca900>] __do_page_cache_readahead+0x120/0x240
[  772.824833]  [<ffffffff810ca892>] ? __do_page_cache_readahead+0xb2/0x240
[  772.831934]  [<ffffffff810caa3c>] ra_submit+0x1c/0x20
[  772.837201]  [<ffffffff810c1487>] filemap_fault+0x3f7/0x400
[  772.843077]  [<ffffffff810d9883>] __do_fault+0x53/0x510
[  772.848298]  [<ffffffff81271ca0>] ? __down_read_trylock+0x20/0x60
[  772.854384]  [<ffffffff810dc489>] handle_mm_fault+0x1c9/0x500
[  772.860126]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  772.865693]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  772.870831] Mem-Info:
[  772.873099] Node 0 DMA per-cpu:
[  772.876268] CPU    0: hi:    0, btch:   1 usd:   0
[  772.881052] CPU    1: hi:    0, btch:   1 usd:   0
[  772.885837] Node 0 DMA32 per-cpu:
[  772.889177] CPU    0: hi:  186, btch:  31 usd: 119
[  772.893970] CPU    1: hi:  186, btch:  31 usd: 131
[  772.898771] Active_anon:42925 active_file:967 inactive_anon:46822
[  772.898773]  inactive_file:3951 unevictable:4 dirty:0 writeback:0 unstable:0
[  772.898775]  free:1195 slab:13130 mapped:4261 pagetables:6775 bounce:0
[  772.918425] Node 0 DMA free:2000kB min:84kB low:104kB high:124kB active_anon:5572kB inactive_anon:6228kB active_file:0kB inactive_file:28kB unevictable:0kB present:15164kB pages_scanned:1152 all_unreclaimable? no
[  772.937282] lowmem_reserve[]: 0 483 483 483
[  772.941583] Node 0 DMA32 free:2780kB min:2768kB low:3460kB high:4152kB active_anon:166128kB inactive_anon:181060kB active_file:3868kB inactive_file:15776kB unevictable:16kB present:495008kB pages_scanned:31168 all_unreclaimable? no
[  772.962096] lowmem_reserve[]: 0 0 0 0
[  772.965848] Node 0 DMA: 19*4kB 3*8kB 4*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2020kB
[  772.976695] Node 0 DMA32: 113*4kB 7*8kB 16*16kB 15*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2780kB
[  772.987966] 64559 total pagecache pages
[  772.991800] 7639 pages in swap cache
[  772.995376] Swap cache stats: add 175606, delete 167967, find 14965/57706
[  773.002155] Free swap  = 761820kB
[  773.005474] Total swap = 1048568kB
[  773.012974] 131072 pages RAM
[  773.015871] 9628 pages reserved
[  773.019017] 75524 pages shared
[  773.022066] 57891 pages non-shared
[  773.025474] Out of memory: kill process 3514 (run-many-x-apps) score 892555 or a child
[  773.033387] Killed process 4039 (sol)
[  794.790990] NFS: Server wrote zero bytes, expected 120.
[  822.483490] Xorg invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  822.490772] Pid: 3308, comm: Xorg Not tainted 2.6.30-rc8-mm1 #301
[  822.496918] Call Trace:
[  822.499384]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  822.504871]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  822.510622]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  822.515851]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  822.521593]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  822.527081]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  822.533429]  [<ffffffff810f3e68>] alloc_pages_current+0x78/0x100
[  822.539434]  [<ffffffff810c0c6b>] __page_cache_alloc+0xb/0x10
[  822.545175]  [<ffffffff810ca900>] __do_page_cache_readahead+0x120/0x240
[  822.551788]  [<ffffffff810ca892>] ? __do_page_cache_readahead+0xb2/0x240
[  822.558481]  [<ffffffff810caa3c>] ra_submit+0x1c/0x20
[  822.563528]  [<ffffffff810c1487>] filemap_fault+0x3f7/0x400
[  822.569098]  [<ffffffff810d9883>] __do_fault+0x53/0x510
[  822.574327]  [<ffffffff81271ca0>] ? __down_read_trylock+0x20/0x60
[  822.580413]  [<ffffffff810dc489>] handle_mm_fault+0x1c9/0x500
[  822.586157]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  822.591727]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  822.596859] Mem-Info:
[  822.599136] Node 0 DMA per-cpu:
[  822.602299] CPU    0: hi:    0, btch:   1 usd:   0
[  822.607084] CPU    1: hi:    0, btch:   1 usd:   0
[  822.611869] Node 0 DMA32 per-cpu:
[  822.615198] CPU    0: hi:  186, btch:  31 usd:  91
[  822.619985] CPU    1: hi:  186, btch:  31 usd:  98
[  822.624773] Active_anon:43566 active_file:835 inactive_anon:46874
[  822.624774]  inactive_file:3327 unevictable:4 dirty:0 writeback:0 unstable:0
[  822.624775]  free:1187 slab:13349 mapped:3843 pagetables:6679 bounce:0
[  822.644402] Node 0 DMA free:2000kB min:84kB low:104kB high:124kB active_anon:5648kB inactive_anon:6260kB active_file:24kB inactive_file:72kB unevictable:0kB present:15164kB pages_scanned:20672 all_unreclaimable? yes
[  822.663507] lowmem_reserve[]: 0 483 483 483
[  822.667773] Node 0 DMA32 free:2748kB min:2768kB low:3460kB high:4152kB active_anon:168616kB inactive_anon:181236kB active_file:3316kB inactive_file:13236kB unevictable:16kB present:495008kB pages_scanned:729026 all_unreclaimable? yes
[  822.688432] lowmem_reserve[]: 0 0 0 0
[  822.692178] Node 0 DMA: 16*4kB 2*8kB 4*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2000kB
[  822.703015] Node 0 DMA32: 53*4kB 31*8kB 15*16kB 16*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2748kB
[  822.714282] 63870 total pagecache pages
[  822.718120] 7714 pages in swap cache
[  822.721687] Swap cache stats: add 177378, delete 169664, find 15255/58971
[  822.728470] Free swap  = 772080kB
[  822.731787] Total swap = 1048568kB
[  822.738767] 131072 pages RAM
[  822.741648] 9628 pages reserved
[  822.744800] 78480 pages shared
[  822.747857] 58328 pages non-shared
[  822.751262] Out of memory: kill process 3514 (run-many-x-apps) score 874039 or a child
[  822.759173] Killed process 4071 (gnometris)
[  838.434074] firefox-bin invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  838.441560] Pid: 5500, comm: firefox-bin Not tainted 2.6.30-rc8-mm1 #301
[  838.448286] Call Trace:
[  838.450770]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  838.456279]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  838.462053]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  838.467299]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  838.473064]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  838.478570]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  838.484930]  [<ffffffff810f3e68>] alloc_pages_current+0x78/0x100
[  838.490953]  [<ffffffff810c0c6b>] __page_cache_alloc+0xb/0x10
[  838.496714]  [<ffffffff810ca900>] __do_page_cache_readahead+0x120/0x240
[  838.503346]  [<ffffffff810ca892>] ? __do_page_cache_readahead+0xb2/0x240
[  838.510056]  [<ffffffff810caa3c>] ra_submit+0x1c/0x20
[  838.515121]  [<ffffffff810c1487>] filemap_fault+0x3f7/0x400
[  838.520707]  [<ffffffff810d9883>] __do_fault+0x53/0x510
[  838.525955]  [<ffffffff81271ca0>] ? __down_read_trylock+0x20/0x60
[  838.532058]  [<ffffffff810dc489>] handle_mm_fault+0x1c9/0x500
[  838.537819]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  838.543405]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  838.548553] Mem-Info:
[  838.550844] Node 0 DMA per-cpu:
[  838.554023] CPU    0: hi:    0, btch:   1 usd:   0
[  838.558818] CPU    1: hi:    0, btch:   1 usd:   0
[  838.563614] Node 0 DMA32 per-cpu:
[  838.566959] CPU    0: hi:  186, btch:  31 usd: 174
[  838.571767] CPU    1: hi:  186, btch:  31 usd:  87
[  838.576579] Active_anon:43520 active_file:718 inactive_anon:46874
[  838.576582]  inactive_file:3607 unevictable:4 dirty:0 writeback:0 unstable:0
[  838.576584]  free:1193 slab:13228 mapped:4138 pagetables:6608 bounce:0
[  838.596232] Node 0 DMA free:2008kB min:84kB low:104kB high:124kB active_anon:5620kB inactive_anon:6260kB active_file:28kB inactive_file:72kB unevictable:0kB present:15164kB pages_scanned:18848 all_unreclaimable? yes
[  838.615367] lowmem_reserve[]: 0 483 483 483
[  838.619678] Node 0 DMA32 free:2764kB min:2768kB low:3460kB high:4152kB active_anon:168460kB inactive_anon:181236kB active_file:2844kB inactive_file:14356kB unevictable:16kB present:495008kB pages_scanned:585548 all_unreclaimable? yes
[  838.640372] lowmem_reserve[]: 0 0 0 0
[  838.644163] Node 0 DMA: 18*4kB 2*8kB 4*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2008kB
[  838.655125] Node 0 DMA32: 109*4kB 7*8kB 16*16kB 14*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2732kB
[  838.666499] 64009 total pagecache pages
[  838.670350] 7656 pages in swap cache
[  838.673941] Swap cache stats: add 177561, delete 169905, find 15273/59126
[  838.680734] Free swap  = 791892kB
[  838.684060] Total swap = 1048568kB
[  838.694532] 131072 pages RAM
[  838.697436] 9628 pages reserved
[  838.700590] 73594 pages shared
[  838.703661] 58166 pages non-shared
[  838.707076] Out of memory: kill process 3514 (run-many-x-apps) score 853023 or a child
[  838.714995] Killed process 4104 (gnect)
[  889.461532] scim-panel-gtk invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  889.469205] Pid: 3360, comm: scim-panel-gtk Not tainted 2.6.30-rc8-mm1 #301
[  889.476177] Call Trace:
[  889.478662]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  889.484172]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  889.489944]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  889.495191]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  889.500962]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  889.506455]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  889.512814]  [<ffffffff810f3e68>] alloc_pages_current+0x78/0x100
[  889.518831]  [<ffffffff810c0c6b>] __page_cache_alloc+0xb/0x10
[  889.524591]  [<ffffffff810ca900>] __do_page_cache_readahead+0x120/0x240
[  889.531220]  [<ffffffff810ca892>] ? __do_page_cache_readahead+0xb2/0x240
[  889.537930]  [<ffffffff810caa3c>] ra_submit+0x1c/0x20
[  889.542994]  [<ffffffff810c1487>] filemap_fault+0x3f7/0x400
[  889.548580]  [<ffffffff810d9883>] __do_fault+0x53/0x510
[  889.553829]  [<ffffffff81271ca0>] ? __down_read_trylock+0x20/0x60
[  889.559928]  [<ffffffff810dc489>] handle_mm_fault+0x1c9/0x500
[  889.565694]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  889.571281]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  889.576428] Mem-Info:
[  889.578716] Node 0 DMA per-cpu:
[  889.581897] CPU    0: hi:    0, btch:   1 usd:   0
[  889.586693] CPU    1: hi:    0, btch:   1 usd:   0
[  889.591489] Node 0 DMA32 per-cpu:
[  889.594838] CPU    0: hi:  186, btch:  31 usd:  27
[  889.599639] CPU    1: hi:  186, btch:  31 usd:  52
[  889.604447] Active_anon:43571 active_file:1739 inactive_anon:47198
[  889.604450]  inactive_file:2522 unevictable:4 dirty:0 writeback:0 unstable:0
[  889.604453]  free:1172 slab:13250 mapped:4789 pagetables:6476 bounce:0
[  889.624188] Node 0 DMA free:2012kB min:84kB low:104kB high:124kB active_anon:5672kB inactive_anon:6228kB active_file:0kB inactive_file:28kB unevictable:0kB present:15164kB pages_scanned:18758 all_unreclaimable? yes
[  889.643237] lowmem_reserve[]: 0 483 483 483
[  889.647549] Node 0 DMA32 free:2676kB min:2768kB low:3460kB high:4152kB active_anon:168612kB inactive_anon:182564kB active_file:6956kB inactive_file:10060kB unevictable:16kB present:495008kB pages_scanned:562004 all_unreclaimable? yes
[  889.668244] lowmem_reserve[]: 0 0 0 0
[  889.672043] Node 0 DMA: 19*4kB 2*8kB 4*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2012kB
[  889.683006] Node 0 DMA32: 85*4kB 8*8kB 16*16kB 15*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2676kB
[  889.694298] 63465 total pagecache pages
[  889.698147] 7133 pages in swap cache
[  889.701736] Swap cache stats: add 181169, delete 174036, find 15337/60473
[  889.708527] Free swap  = 795216kB
[  889.711853] Total swap = 1048568kB
[  889.722306] 131072 pages RAM
[  889.725220] 9628 pages reserved
[  889.728368] 73642 pages shared
[  889.731430] 58217 pages non-shared
[  889.734842] Out of memory: kill process 3314 (gnome-session) score 875272 or a child
[  889.742589] Killed process 3345 (ssh-agent)
[  889.753188] urxvt invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
[  889.760064] Pid: 3364, comm: urxvt Not tainted 2.6.30-rc8-mm1 #301
[  889.766248] Call Trace:
[  889.768709]  [<ffffffff81544fc6>] ? _spin_unlock+0x26/0x30
[  889.774212]  [<ffffffff810c37bc>] oom_kill_process+0xdc/0x270
[  889.779963]  [<ffffffff810c3b1f>] ? badness+0x18f/0x300
[  889.785202]  [<ffffffff810c3dc5>] __out_of_memory+0x135/0x170
[  889.790961]  [<ffffffff810c3ef5>] out_of_memory+0xf5/0x180
[  889.796460]  [<ffffffff810c856c>] __alloc_pages_nodemask+0x6ac/0x6c0
[  889.802839]  [<ffffffff810f3e68>] alloc_pages_current+0x78/0x100
[  889.808867]  [<ffffffff810c0c6b>] __page_cache_alloc+0xb/0x10
[  889.814622]  [<ffffffff810ca900>] __do_page_cache_readahead+0x120/0x240
[  889.821253]  [<ffffffff810ca892>] ? __do_page_cache_readahead+0xb2/0x240
[  889.827970]  [<ffffffff810caa3c>] ra_submit+0x1c/0x20
[  889.833050]  [<ffffffff810c1487>] filemap_fault+0x3f7/0x400
[  889.838635]  [<ffffffff810d9883>] __do_fault+0x53/0x510
[  889.843875]  [<ffffffff81271ca0>] ? __down_read_trylock+0x20/0x60
[  889.849989]  [<ffffffff810dc489>] handle_mm_fault+0x1c9/0x500
[  889.855753]  [<ffffffff81548234>] do_page_fault+0x1c4/0x330
[  889.861356]  [<ffffffff81545a55>] page_fault+0x25/0x30
[  889.866503] Mem-Info:
[  889.868779] Node 0 DMA per-cpu:
[  889.871969] CPU    0: hi:    0, btch:   1 usd:   0
[  889.876771] CPU    1: hi:    0, btch:   1 usd:   0
[  889.881590] Node 0 DMA32 per-cpu:
[  889.884950] CPU    0: hi:  186, btch:  31 usd:  27
[  889.889752] CPU    1: hi:  186, btch:  31 usd:  83
[  889.894557] Active_anon:43568 active_file:1748 inactive_anon:47202
[  889.894560]  inactive_file:2532 unevictable:4 dirty:0 writeback:0 unstable:0
[  889.894562]  free:1172 slab:13256 mapped:4800 pagetables:6457 bounce:0
[  889.914305] Node 0 DMA free:2012kB min:84kB low:104kB high:124kB active_anon:5672kB inactive_anon:6244kB active_file:16kB inactive_file:36kB unevictable:0kB present:15164kB pages_scanned:18758 all_unreclaimable? yes
[  889.933431] lowmem_reserve[]: 0 483 483 483
[  889.937757] Node 0 DMA32 free:2676kB min:2768kB low:3460kB high:4152kB active_anon:168600kB inactive_anon:182564kB active_file:6976kB inactive_file:10092kB unevictable:16kB present:495008kB pages_scanned:572756 all_unreclaimable? yes
[  889.958441] lowmem_reserve[]: 0 0 0 0
[  889.962251] Node 0 DMA: 19*4kB 2*8kB 4*16kB 2*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2012kB
[  889.973218] Node 0 DMA32: 85*4kB 8*8kB 16*16kB 15*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2676kB
[  889.984510] 63470 total pagecache pages
[  889.988363] 7128 pages in swap cache
[  889.991956] Swap cache stats: add 181169, delete 174041, find 15337/60473
[  889.998764] Free swap  = 795628kB
[  890.002089] Total swap = 1048568kB
[  890.012112] 131072 pages RAM
[  890.015034] 9628 pages reserved
[  890.018197] 73633 pages shared
[  890.021274] 58191 pages non-shared
[  890.024686] Out of memory: kill process 3314 (gnome-session) score 870770 or a child
[  890.032441] Killed process 3363 (firefox-bin)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
