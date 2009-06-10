Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 773746B004F
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 04:54:58 -0400 (EDT)
Date: Wed, 10 Jun 2009 16:56:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-ID: <20090610085638.GA32511@localhost>
References: <20090609190128.GA1785@cmpxchg.org> <20090609193702.GA2017@cmpxchg.org> <20090610050342.GA8867@localhost> <20090610074508.GA1960@cmpxchg.org> <20090610081132.GA27519@localhost> <20090610173249.50e19966.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090610173249.50e19966.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 10, 2009 at 04:32:49PM +0800, KAMEZAWA Hiroyuki wrote:
> On Wed, 10 Jun 2009 16:11:32 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > On Wed, Jun 10, 2009 at 03:45:08PM +0800, Johannes Weiner wrote:
> > > Hi Fengguang,
> > > 
> > > On Wed, Jun 10, 2009 at 01:03:42PM +0800, Wu Fengguang wrote:
> > > > On Wed, Jun 10, 2009 at 03:37:02AM +0800, Johannes Weiner wrote:
> > > > > On Tue, Jun 09, 2009 at 09:01:28PM +0200, Johannes Weiner wrote:
> > > > > > [resend with lists cc'd, sorry]
> > > > > 
> > > > > [and fixed Hugh's email.  crap]
> > > > > 
> > > > > > Hi,
> > > > > > 
> > > > > > here is a new iteration of the virtual swap readahead.  Per Hugh's
> > > > > > suggestion, I moved the pte collecting to the callsite and thus out
> > > > > > ouf swap code.  Unfortunately, I had to bound page_cluster due to an
> > > > > > array of that many swap entries on the stack, but I think it is better
> > > > > > to limit the cluster size to a sane maximum than using dynamic
> > > > > > allocation for this purpose.
> > > > 
> > > > Hi Johannes,
> > > > 
> > > > When stress testing your patch, I found it triggered many OOM kills.
> > > > Around the time of last OOMs, the memory usage is:
> > > > 
> > > >              total       used       free     shared    buffers     cached
> > > > Mem:           474        468          5          0          0        239
> > > > -/+ buffers/cache:        229        244
> > > > Swap:         1023        221        802
> > > 
> > > Wow, that really confused me for a second as we shouldn't read more
> > > pages ahead than without the patch, probably even less under stress.
> > 
> > Yup - swap readahead is much more challenging than sequential readahead,
> > in that it must be accurate enough given some really obscure patterns.
> > 
> > > So the problem has to be a runaway reading.  And indeed, severe
> > > stupidity here:
> > > 
> > > +       window = cluster << PAGE_SHIFT;
> > > +       min = addr & ~(window - 1);
> > > +       max = min + cluster;
> > > +       /*
> > > +        * To keep the locking/highpte mapping simple, stay
> > > +        * within the PTE range of one PMD entry.
> > > +        */
> > > +       limit = addr & PMD_MASK;
> > > +       if (limit > min)
> > > +               min = limit;
> > > +       limit = pmd_addr_end(addr, max);
> > > +       if (limit < max)
> > > +               max = limit;
> > > +       limit = max - min;
> > > 
> > > The mistake is at the initial calculation of max.  It should be
> > > 
> > > 	max = min + window;
> > > 
> > > The resulting problem is that min could get bigger than max when
> > > cluster is bigger than PMD_SHIFT.  Did you use page_cluster == 5?
> > 
> > No I use the default 3.
> > 
> > btw, the mistake reflects bad named variables. How about rename
> >         cluster => pages
> >         window  => bytes
> > ?
> > 
> > > The initial min is aligned to a value below the PMD boundary and max
> > > based on it with a too small offset, staying below the PMD boundary as
> > > well.  When min is rounded up, this becomes a bit large:
> > > 
> > > 	limit = max - min;
> > > 
> > > So if my brain is already functioning, fixing the initial max should
> > > be enough because either
> > > 
> > > 	o window is smaller than PMD_SIZE, than we won't round down
> > > 	below a PMD boundary in the first place or
> > > 
> > > 	o window is bigger than PMD_SIZE, than we can round down below
> > > 	a PMD boundary but adding window to that is garuanteed to
> > > 	cross the boundary again
> > > 
> > > and thus max is always bigger than min.
> > > 
> > > Fengguang, does this make sense?  If so, the patch below should fix
> > > it.
> > 
> > Too bad, a quick test of the below patch freezes the box..
> > 
> 
> +	window = cluster << PAGE_SHIFT;
> +	min = addr & ~(window - 1);
> +	max = min + cluster;
> 
> max = min + window; # this is fixed. then,
> 
> +	/*
> +	 * To keep the locking/highpte mapping simple, stay
> +	 * within the PTE range of one PMD entry.
> +	 */
> +	limit = addr & PMD_MASK;
> +	if (limit > min)
> +		min = limit;
> +	limit = pmd_addr_end(addr, max);
> +	if (limit < max)
> +		max = limit;
> +	limit = max - min;
> 
> limit = (max - min) >> PAGE_SHIFT;  
> 
> +	ptep = pte_offset_map_lock(mm, pmd, min, &ptl);
> +	for (i = nr = 0; i < limit; i++)
> +		if (is_swap_pte(ptep[i]))
> +			entries[nr++] = pte_to_swp_entry(ptep[i]);
> +	pte_unmap_unlock(ptep, ptl);

Yes it worked!  But then I run into page allocation failures:

[  340.639803] Xorg: page allocation failure. order:4, mode:0x40d0
[  340.645744] Pid: 3258, comm: Xorg Not tainted 2.6.30-rc8-mm1 #303
[  340.651839] Call Trace:
[  340.654289]  [<ffffffff810c8204>] __alloc_pages_nodemask+0x344/0x6c0
[  340.660645]  [<ffffffff810f7489>] __slab_alloc_page+0xb9/0x3b0
[  340.666472]  [<ffffffff810f8608>] __kmalloc+0x198/0x250
[  340.671786]  [<ffffffffa014bf9f>] ? i915_gem_execbuffer+0x17f/0x11e0 [i915]
[  340.678746]  [<ffffffffa014bf9f>] i915_gem_execbuffer+0x17f/0x11e0 [i915]
[  340.685527]  [<ffffffff81079ead>] ? trace_hardirqs_on+0xd/0x10
[  340.691356]  [<ffffffff81542b49>] ? mutex_unlock+0x9/0x10
[  340.696771]  [<ffffffffa00f5b7d>] drm_ioctl+0x12d/0x3d0 [drm]
[  340.702518]  [<ffffffffa014be20>] ? i915_gem_execbuffer+0x0/0x11e0 [i915]
[  340.709301]  [<ffffffff81271f1a>] ? __up_read+0x2a/0xb0
[  340.714529]  [<ffffffff8110ba8d>] vfs_ioctl+0x7d/0xa0
[  340.719578]  [<ffffffff8110bb3a>] do_vfs_ioctl+0x8a/0x580
[  340.724969]  [<ffffffff8106b236>] ? up_read+0x26/0x30
[  340.730024]  [<ffffffff81544b04>] ? lockdep_sys_exit_thunk+0x35/0x67
[  340.736375]  [<ffffffff8110c07a>] sys_ioctl+0x4a/0x80
[  340.741430]  [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b
[  340.747434] Mem-Info:
[  340.749730] Node 0 DMA per-cpu:
[  340.752896] CPU    0: hi:    0, btch:   1 usd:   0
[  340.757679] CPU    1: hi:    0, btch:   1 usd:   0
[  340.762462] Node 0 DMA32 per-cpu:
[  340.765797] CPU    0: hi:  186, btch:  31 usd: 161
[  340.770582] CPU    1: hi:  186, btch:  31 usd:   0
[  340.775367] Active_anon:38344 active_file:6556 inactive_anon:41644
[  340.775368]  inactive_file:4210 unevictable:4 dirty:1 writeback:10 unstable:1
[  340.775370]  free:3136 slab:15738 mapped:8023 pagetables:6294 bounce:0
[  340.795166] Node 0 DMA free:2024kB min:84kB low:104kB high:124kB active_anon:5296kB inactive_anon:5772kB active_file:644kB inactive_file:612kB unevictable:0kB present:15164kB pages_scanned:0 all_unreclaimable? no
[  340.814007] lowmem_reserve[]: 0 483 483 483
[  340.818277] Node 0 DMA32 free:10520kB min:2768kB low:3460kB high:4152kB active_anon:148080kB inactive_anon:160804kB active_file:25580kB inactive_file:16228kB unevictable:16kB present:495008kB pages_scanned:0 all_unreclaimable? no
[  340.838594] lowmem_reserve[]: 0 0 0 0
[  340.842338] Node 0 DMA: 87*4kB 14*8kB 2*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2028kB
[  340.853398] Node 0 DMA32: 2288*4kB 24*8kB 4*16kB 2*32kB 3*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 10560kB
[  340.864874] 59895 total pagecache pages
[  340.868720] 4176 pages in swap cache
[  340.872315] Swap cache stats: add 99021, delete 94845, find 8313/23463
[  340.878847] Free swap  = 780376kB
[  340.882178] Total swap = 1048568kB
[  340.889619] 131072 pages RAM
[  340.892527] 9628 pages reserved
[  340.895677] 126767 pages shared
[  340.898836] 60472 pages non-shared
[  341.026977] Xorg: page allocation failure. order:4, mode:0x40d0
[  341.032900] Pid: 3258, comm: Xorg Not tainted 2.6.30-rc8-mm1 #303
[  341.038989] Call Trace:
[  341.041451]  [<ffffffff810c8204>] __alloc_pages_nodemask+0x344/0x6c0
[  341.047801]  [<ffffffff810f7489>] __slab_alloc_page+0xb9/0x3b0
[  341.053628]  [<ffffffff810f7840>] __remote_slab_alloc_node+0xc0/0x130
[  341.060073]  [<ffffffff810f78e5>] __remote_slab_alloc+0x35/0xc0
[  341.065983]  [<ffffffff810f76e4>] ? __slab_alloc_page+0x314/0x3b0
[  341.072070]  [<ffffffff810f8528>] __kmalloc+0xb8/0x250
[  341.077220]  [<ffffffffa014bf9f>] ? i915_gem_execbuffer+0x17f/0x11e0 [i915]
[  341.084184]  [<ffffffffa014bf9f>] i915_gem_execbuffer+0x17f/0x11e0 [i915]
[  341.090963]  [<ffffffff81079ead>] ? trace_hardirqs_on+0xd/0x10
[  341.096791]  [<ffffffff81542b49>] ? mutex_unlock+0x9/0x10
[  341.102197]  [<ffffffffa00f5b7d>] drm_ioctl+0x12d/0x3d0 [drm]
[  341.107948]  [<ffffffffa014be20>] ? i915_gem_execbuffer+0x0/0x11e0 [i915]
[  341.114726]  [<ffffffff81271f1a>] ? __up_read+0x2a/0xb0
[  341.119948]  [<ffffffff8110ba8d>] vfs_ioctl+0x7d/0xa0
[  341.124996]  [<ffffffff8110bb3a>] do_vfs_ioctl+0x8a/0x580
[  341.130389]  [<ffffffff8106b236>] ? up_read+0x26/0x30
[  341.135436]  [<ffffffff81544b04>] ? lockdep_sys_exit_thunk+0x35/0x67
[  341.141787]  [<ffffffff8110c07a>] sys_ioctl+0x4a/0x80
[  341.146848]  [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b
[  341.152855] Mem-Info:
[  341.155124] Node 0 DMA per-cpu:
[  341.158289] CPU    0: hi:    0, btch:   1 usd:   0
[  341.163074] CPU    1: hi:    0, btch:   1 usd:   0
[  341.167878] Node 0 DMA32 per-cpu:
[  341.171212] CPU    0: hi:  186, btch:  31 usd:  72
[  341.176009] CPU    1: hi:  186, btch:  31 usd:   0
[  341.180794] Active_anon:38344 active_file:6605 inactive_anon:41579
[  341.180795]  inactive_file:4180 unevictable:4 dirty:0 writeback:0 unstable:1
[  341.180797]  free:3147 slab:15867 mapped:8021 pagetables:6295 bounce:0
[  341.200505] Node 0 DMA free:2028kB min:84kB low:104kB high:124kB active_anon:5284kB inactive_anon:5784kB active_file:644kB inactive_file:612kB unevictable:0kB present:15164kB pages_scanned:0 all_unreclaimable? no
[  341.219339] lowmem_reserve[]: 0 483 483 483
[  341.223605] Node 0 DMA32 free:10560kB min:2768kB low:3460kB high:4152kB active_anon:148092kB inactive_anon:160532kB active_file:25776kB inactive_file:16108kB unevictable:16kB present:495008kB pages_scanned:618 all_unreclaimable? no
[  341.244093] lowmem_reserve[]: 0 0 0 0
[  341.247851] Node 0 DMA: 87*4kB 14*8kB 2*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2028kB
[  341.258769] Node 0 DMA32: 2296*4kB 18*8kB 5*16kB 2*32kB 3*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 10560kB
[  341.270121] 59860 total pagecache pages
[  341.273957] 4142 pages in swap cache
[  341.277531] Swap cache stats: add 99071, delete 94929, find 8313/23465
[  341.284052] Free swap  = 780184kB
[  341.287357] Total swap = 1048568kB
[  341.294497] 131072 pages RAM
[  341.297396] 9628 pages reserved
[  341.300538] 126655 pages shared
[  341.303674] 60501 pages non-shared
[  357.833157] Xorg: page allocation failure. order:4, mode:0x40d0
[  357.839105] Pid: 3258, comm: Xorg Not tainted 2.6.30-rc8-mm1 #303
[  357.845243] Call Trace:
[  357.847737]  [<ffffffff810c8204>] __alloc_pages_nodemask+0x344/0x6c0
[  357.854108]  [<ffffffff810f7489>] __slab_alloc_page+0xb9/0x3b0
[  357.859965]  [<ffffffff810f8608>] __kmalloc+0x198/0x250
[  357.865263]  [<ffffffffa014bf9f>] ? i915_gem_execbuffer+0x17f/0x11e0 [i915]
[  357.872245]  [<ffffffffa014bf9f>] i915_gem_execbuffer+0x17f/0x11e0 [i915]
[  357.879029]  [<ffffffff810ea8bb>] ? swap_info_get+0x6b/0xf0
[  357.884626]  [<ffffffffa00f5b7d>] drm_ioctl+0x12d/0x3d0 [drm]
[  357.890396]  [<ffffffffa014be20>] ? i915_gem_execbuffer+0x0/0x11e0 [i915]
[  357.897190]  [<ffffffff81271f1a>] ? __up_read+0x2a/0xb0
[  357.902412]  [<ffffffff8110ba8d>] vfs_ioctl+0x7d/0xa0
[  357.907460]  [<ffffffff8110bb3a>] do_vfs_ioctl+0x8a/0x580
[  357.912873]  [<ffffffff8106b236>] ? up_read+0x26/0x30
[  357.917923]  [<ffffffff81544b04>] ? lockdep_sys_exit_thunk+0x35/0x67
[  357.924289]  [<ffffffff8110c07a>] sys_ioctl+0x4a/0x80
[  357.929347]  [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b
[  357.935350] Mem-Info:
[  357.937630] Node 0 DMA per-cpu:
[  357.940801] CPU    0: hi:    0, btch:   1 usd:   0
[  357.945590] CPU    1: hi:    0, btch:   1 usd:   0
[  357.950379] Node 0 DMA32 per-cpu:
[  357.953728] CPU    0: hi:  186, btch:  31 usd: 159
[  357.958513] CPU    1: hi:  186, btch:  31 usd:   0
[  357.963300] Active_anon:38863 active_file:6095 inactive_anon:41764
[  357.963301]  inactive_file:4777 unevictable:4 dirty:0 writeback:18 unstable:0
[  357.963302]  free:2317 slab:15674 mapped:8121 pagetables:6408 bounce:0
[  357.983105] Node 0 DMA free:2012kB min:84kB low:104kB high:124kB active_anon:5268kB inactive_anon:5768kB active_file:644kB inactive_file:632kB unevictable:0kB present:15164kB pages_scanned:65 all_unreclaimable? no
[  358.002033] lowmem_reserve[]: 0 483 483 483
[  358.006331] Node 0 DMA32 free:7380kB min:2768kB low:3460kB high:4152kB active_anon:150124kB inactive_anon:161368kB active_file:23736kB inactive_file:18404kB unevictable:16kB present:495008kB pages_scanned:32 all_unreclaimable? no
[  358.026802] lowmem_reserve[]: 0 0 0 0
[  358.030561] Node 0 DMA: 81*4kB 11*8kB 0*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2012kB
[  358.041571] Node 0 DMA32: 1534*4kB 29*8kB 3*16kB 4*32kB 1*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 7504kB
[  358.052856] 60223 total pagecache pages
[  358.056690] 4367 pages in swap cache
[  358.060265] Swap cache stats: add 105056, delete 100689, find 9043/26609
[  358.066954] Free swap  = 774800kB
[  358.070268] Total swap = 1048568kB
[  358.077041] 131072 pages RAM
[  358.079954] 9628 pages reserved
[  358.083094] 128803 pages shared
[  358.086237] 61031 pages non-shared
[  507.741934] Xorg: page allocation failure. order:4, mode:0x40d0
[  507.748019] Pid: 3258, comm: Xorg Not tainted 2.6.30-rc8-mm1 #303
[  507.754182] Call Trace:
[  507.756636]  [<ffffffff810c8204>] __alloc_pages_nodemask+0x344/0x6c0
[  507.762988]  [<ffffffff810f7489>] __slab_alloc_page+0xb9/0x3b0
[  507.768812]  [<ffffffff810f8608>] __kmalloc+0x198/0x250
[  507.774048]  [<ffffffffa014bf9f>] ? i915_gem_execbuffer+0x17f/0x11e0 [i915]
[  507.781010]  [<ffffffffa014bf9f>] i915_gem_execbuffer+0x17f/0x11e0 [i915]
[  507.787798]  [<ffffffff81079ead>] ? trace_hardirqs_on+0xd/0x10
[  507.793636]  [<ffffffff81542b49>] ? mutex_unlock+0x9/0x10
[  507.799043]  [<ffffffffa00f5b7d>] drm_ioctl+0x12d/0x3d0 [drm]
[  507.804788]  [<ffffffffa014be20>] ? i915_gem_execbuffer+0x0/0x11e0 [i915]
[  507.811572]  [<ffffffff81271f1a>] ? __up_read+0x2a/0xb0
[  507.816788]  [<ffffffff8110ba8d>] vfs_ioctl+0x7d/0xa0
[  507.821847]  [<ffffffff8110bb3a>] do_vfs_ioctl+0x8a/0x580
[  507.827244]  [<ffffffff8106b236>] ? up_read+0x26/0x30
[  507.832291]  [<ffffffff81544b04>] ? lockdep_sys_exit_thunk+0x35/0x67
[  507.838642]  [<ffffffff8110c07a>] sys_ioctl+0x4a/0x80
[  507.843696]  [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b
[  507.849699] Mem-Info:
[  507.851973] Node 0 DMA per-cpu:
[  507.855130] CPU    0: hi:    0, btch:   1 usd:   0
[  507.859916] CPU    1: hi:    0, btch:   1 usd:   0
[  507.864700] Node 0 DMA32 per-cpu:
[  507.868036] CPU    0: hi:  186, btch:  31 usd:   0
[  507.872819] CPU    1: hi:  186, btch:  31 usd:  30
[  507.876816] Active_anon:34956 active_file:5472 inactive_anon:45220
[  507.876816]  inactive_file:6158 unevictable:4 dirty:13 writeback:2 unstable:0
[  507.876816]  free:1726 slab:15603 mapped:7450 pagetables:6818 bounce:0
[  507.897413] Node 0 DMA free:2044kB min:84kB low:104kB high:124kB active_anon:5060kB inactive_anon:6028kB active_file:644kB inactive_file:624kB unevictable:0kB present:15164kB pages_scanned:0 all_unreclaimable? no
[  507.916249] lowmem_reserve[]: 0 483 483 483
[  507.920598] Node 0 DMA32 free:4488kB min:2768kB low:3460kB high:4152kB active_anon:134764kB inactive_anon:174852kB active_file:21244kB inactive_file:24008kB unevictable:16kB present:495008kB pages_scanned:0 all_unreclaimable? no
[  507.940856] lowmem_reserve[]: 0 0 0 0
[  507.944849] Node 0 DMA: 51*4kB 14*8kB 0*16kB 4*32kB 1*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2044kB
[  507.955772] Node 0 DMA32: 888*4kB 1*8kB 0*16kB 3*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 4488kB
[  507.966871] 64772 total pagecache pages
[  507.970702] 6574 pages in swap cache
[  507.974276] Swap cache stats: add 161629, delete 155055, find 17122/59120
[  507.981051] Free swap  = 735792kB
[  507.984361] Total swap = 1048568kB
[  507.991453] 131072 pages RAM
[  507.994364] 9628 pages reserved
[  507.997503] 114413 pages shared
[  508.000643] 59801 pages non-shared
[  509.462416] NFS: Server wrote zero bytes, expected 756.
[  580.369464] Xorg: page allocation failure. order:4, mode:0x40d0
[  580.375400] Pid: 3258, comm: Xorg Not tainted 2.6.30-rc8-mm1 #303
[  580.381522] Call Trace:
[  580.384092]  [<ffffffff810c8204>] __alloc_pages_nodemask+0x344/0x6c0
[  580.390669]  [<ffffffff810f7489>] __slab_alloc_page+0xb9/0x3b0
[  580.396802]  [<ffffffff810f8608>] __kmalloc+0x198/0x250
[  580.402033]  [<ffffffffa014bf9f>] ? i915_gem_execbuffer+0x17f/0x11e0 [i915]
[  580.408992]  [<ffffffffa014bf9f>] i915_gem_execbuffer+0x17f/0x11e0 [i915]
[  580.415775]  [<ffffffff81079ead>] ? trace_hardirqs_on+0xd/0x10
[  580.421607]  [<ffffffff81542b49>] ? mutex_unlock+0x9/0x10
[  580.427033]  [<ffffffffa00f5b7d>] drm_ioctl+0x12d/0x3d0 [drm]
[  580.432804]  [<ffffffffa014be20>] ? i915_gem_execbuffer+0x0/0x11e0 [i915]
[  580.439600]  [<ffffffff81271f1a>] ? __up_read+0x2a/0xb0
[  580.444824]  [<ffffffff8110ba8d>] vfs_ioctl+0x7d/0xa0
[  580.449889]  [<ffffffff8110bb3a>] do_vfs_ioctl+0x8a/0x580
[  580.455287]  [<ffffffff8106b236>] ? up_read+0x26/0x30
[  580.460353]  [<ffffffff81544b04>] ? lockdep_sys_exit_thunk+0x35/0x67
[  580.466702]  [<ffffffff8110c07a>] sys_ioctl+0x4a/0x80
[  580.471751]  [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b
[  580.477753] Mem-Info:
[  580.480020] Node 0 DMA per-cpu:
[  580.483189] CPU    0: hi:    0, btch:   1 usd:   0
[  580.487977] CPU    1: hi:    0, btch:   1 usd:   0
[  580.492767] Node 0 DMA32 per-cpu:
[  580.496095] CPU    0: hi:  186, btch:  31 usd:  90
[  580.500892] CPU    1: hi:  186, btch:  31 usd:   1
[  580.505679] Active_anon:34315 active_file:5739 inactive_anon:45597
[  580.505681]  inactive_file:5830 unevictable:4 dirty:2 writeback:0 unstable:1
[  580.505682]  free:3781 slab:13422 mapped:6830 pagetables:7180 bounce:0
[  580.525398] Node 0 DMA free:2016kB min:84kB low:104kB high:124kB active_anon:5024kB inactive_anon:6012kB active_file:640kB inactive_file:608kB unevictable:0kB present:15164kB pages_scanned:0 all_unreclaimable? no
[  580.544234] lowmem_reserve[]: 0 483 483 483
[  580.548504] Node 0 DMA32 free:13108kB min:2768kB low:3460kB high:4152kB active_anon:132236kB inactive_anon:176376kB active_file:22316kB inactive_file:22712kB unevictable:16kB present:495008kB pages_scanned:417 all_unreclaimable? no
[  580.568992] lowmem_reserve[]: 0 0 0 0
[  580.572741] Node 0 DMA: 56*4kB 22*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2016kB
[  580.583661] Node 0 DMA32: 2995*4kB 23*8kB 1*16kB 1*32kB 4*64kB 1*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 13108kB
[  580.595010] 64782 total pagecache pages
[  580.598845] 6586 pages in swap cache
[  580.602421] Swap cache stats: add 185372, delete 178786, find 19755/72917
[  580.609205] Free swap  = 722720kB
[  580.612513] Total swap = 1048568kB
[  580.619688] 131072 pages RAM
[  580.622586] 9628 pages reserved
[  580.625726] 112220 pages shared
[  580.628868] 58034 pages non-shared

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
