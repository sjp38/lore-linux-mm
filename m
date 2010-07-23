Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 24FD26B02AA
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 14:02:37 -0400 (EDT)
Date: Fri, 23 Jul 2010 14:02:16 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1507379750.1116011279908136772.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <645277378.1113891279906891174.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: [PATCH 0/8] zcache: page cache compression support
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Nitin Gupta <ngupta@vflare.org>
List-ID: <linux-mm.kvack.org>

Ignore me. The test case should not be using mlockall()!

----- "CAI Qian" <caiqian@redhat.com> wrote:

> ----- caiqian@redhat.com wrote:
> 
> > ----- "Nitin Gupta" <ngupta@vflare.org> wrote:
> > 
> > > Frequently accessed filesystem data is stored in memory to reduce
> > > access to
> > > (much) slower backing disks. Under memory pressure, these pages
> are
> > > freed and
> > > when needed again, they have to be read from disks again. When
> > > combined working
> > > set of all running application exceeds amount of physical RAM, we
> > get
> > > extereme
> > > slowdown as reading a page from disk can take time in order of
> > > milliseconds.
> > > 
> > > Memory compression increases effective memory size and allows
> more
> > > pages to
> > > stay in RAM. Since de/compressing memory pages is several orders
> of
> > > magnitude
> > > faster than disk I/O, this can provide signifant performance
> gains
> > for
> > > many
> > > workloads. Also, with multi-cores becoming common, benefits of
> > reduced
> > > disk I/O
> > > should easily outweigh the problem of increased CPU usage.
> > > 
> > > It is implemented as a "backend" for cleancache_ops [1] which
> > > provides
> > > callbacks for events such as when a page is to be removed from
> the
> > > page cache
> > > and when it is required again. We use them to implement a 'second
> > > chance' cache
> > > for these evicted page cache pages by compressing and storing
> them
> > in
> > > memory
> > > itself.
> > > 
> > > We only keep pages that compress to PAGE_SIZE/2 or less.
> Compressed
> > > chunks are
> > > stored using xvmalloc memory allocator which is already being
> used
> > by
> > > zram
> > > driver for the same purpose. Zero-filled pages are checked and no
> > > memory is
> > > allocated for them.
> > > 
> > > A separate "pool" is created for each mount instance for a
> > > cleancache-aware
> > > filesystem. Each incoming page is identified with <pool_id,
> > inode_no,
> > > index>
> > > where inode_no identifies file within the filesystem
> corresponding
> > to
> > > pool_id
> > > and index is offset of the page within this inode. Within a pool,
> > > inodes are
> > > maintained in an rb-tree and each of its nodes points to a
> separate
> > > radix-tree
> > > which maintains list of pages within that inode.
> > > 
> > > While compression reduces disk I/O, it also reduces the space
> > > available for
> > > normal (uncompressed) page cache. This can result in more
> frequent
> > > page cache
> > > reclaim and thus higher CPU overhead. Thus, it's important to
> > maintain
> > > good hit
> > > rate for compressed cache or increased CPU overhead can nullify
> any
> > > other
> > > benefits. This requires adaptive (compressed) cache resizing and
> > page
> > > replacement policies that can maintain optimal cache size and
> > quickly
> > > reclaim
> > > unused compressed chunks. This work is yet to be done. However,
> in
> > the
> > > current
> > > state, it allows manually resizing cache size using (per-pool)
> > sysfs
> > > node
> > > 'memlimit' which in turn frees any excess pages *sigh* randomly.
> > > 
> > > Finally, it uses percpu stats and compression buffers to allow
> > better
> > > performance on multi-cores. Still, there are known bottlenecks
> like
> > a
> > > single
> > > xvmalloc mempool per zcache pool and few others. I will work on
> > this
> > > when I
> > > start with profiling.
> > > 
> > >  * Performance numbers:
> > >    - Tested using iozone filesystem benchmark
> > >    - 4 CPUs, 1G RAM
> > >    - Read performance gain: ~2.5X
> > >    - Random read performance gain: ~3X
> > >    - In general, performance gains for every kind of I/O
> > > 
> > > Test details with graphs can be found here:
> > > http://code.google.com/p/compcache/wiki/zcacheIOzone
> > > 
> > > If I can get some help with testing, it would be intersting to
> find
> > > its
> > > effect in more real-life workloads. In particular, I'm intersted
> in
> > > finding
> > > out its effect in KVM virtualization case where it can
> potentially
> > > allow
> > > running more number of VMs per-host for a given amount of RAM.
> With
> > > zcache
> > > enabled, VMs can be assigned much smaller amount of memory since
> > host
> > > can now
> > > hold bulk of page-cache pages, allowing VMs to maintain similar
> > level
> > > of
> > > performance while a greater number of them can be hosted.
> > > 
> > >  * How to test:
> > > All patches are against 2.6.35-rc5:
> > > 
> > >  - First, apply all prerequisite patches here:
> > >
> http://compcache.googlecode.com/hg/sub-projects/zcache_base_patches
> > > 
> > >  - Then apply this patch series; also uploaded here:
> > > http://compcache.googlecode.com/hg/sub-projects/zcache_patches
> > > 
> > > 
> > > Nitin Gupta (8):
> > >   Allow sharing xvmalloc for zram and zcache
> > >   Basic zcache functionality
> > >   Create sysfs nodes and export basic statistics
> > >   Shrink zcache based on memlimit
> > >   Eliminate zero-filled pages
> > >   Compress pages using LZO
> > >   Use xvmalloc to store compressed chunks
> > >   Document sysfs entries
> > > 
> > >  Documentation/ABI/testing/sysfs-kernel-mm-zcache |   53 +
> > >  drivers/staging/Makefile                         |    2 +
> > >  drivers/staging/zram/Kconfig                     |   22 +
> > >  drivers/staging/zram/Makefile                    |    5 +-
> > >  drivers/staging/zram/xvmalloc.c                  |    8 +
> > >  drivers/staging/zram/zcache_drv.c                | 1312
> > > ++++++++++++++++++++++
> > >  drivers/staging/zram/zcache_drv.h                |   90 ++
> > >  7 files changed, 1491 insertions(+), 1 deletions(-)
> > >  create mode 100644
> > Documentation/ABI/testing/sysfs-kernel-mm-zcache
> > >  create mode 100644 drivers/staging/zram/zcache_drv.c
> > >  create mode 100644 drivers/staging/zram/zcache_drv.h
> > By tested those patches on the top of the linus tree at this commit
> > d0c6f6258478e1dba532bf7c28e2cd6e1047d3a4, the OOM was trigger even
> > though there looked like still lots of swap.
> > 
> > # free -m
> >              total       used       free     shared    buffers    
> > cached
> > Mem:           852        379        473          0          3      
>  
> > 15
> > -/+ buffers/cache:        359        492
> > Swap:         2015         14       2001
> > 
> > # ./usemem 1024
> > 0: Mallocing 32 megabytes
> > 1: Mallocing 32 megabytes
> > 2: Mallocing 32 megabytes
> > 3: Mallocing 32 megabytes
> > 4: Mallocing 32 megabytes
> > 5: Mallocing 32 megabytes
> > 6: Mallocing 32 megabytes
> > 7: Mallocing 32 megabytes
> > 8: Mallocing 32 megabytes
> > 9: Mallocing 32 megabytes
> > 10: Mallocing 32 megabytes
> > 11: Mallocing 32 megabytes
> > 12: Mallocing 32 megabytes
> > 13: Mallocing 32 megabytes
> > 14: Mallocing 32 megabytes
> > 15: Mallocing 32 megabytes
> > Connection to 192.168.122.193 closed.
> > 
> > usemem invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0
> > usemem cpuset=/ mems_allowed=0
> > Pid: 1829, comm: usemem Not tainted 2.6.35-rc5+ #5
> > Call Trace:
> >  [<ffffffff814e10cb>] ? _raw_spin_unlock+0x2b/0x40
> >  [<ffffffff81108520>] dump_header+0x70/0x190
> >  [<ffffffff811086c1>] oom_kill_process+0x81/0x180
> >  [<ffffffff81108c08>] __out_of_memory+0x58/0xd0
> >  [<ffffffff81108ddc>] ? out_of_memory+0x15c/0x1f0
> >  [<ffffffff81108d8f>] out_of_memory+0x10f/0x1f0
> >  [<ffffffff8110cc7f>] __alloc_pages_nodemask+0x7af/0x7c0
> >  [<ffffffff81140a69>] alloc_page_vma+0x89/0x140
> >  [<ffffffff81125f76>] handle_mm_fault+0x6d6/0x990
> >  [<ffffffff814e10cb>] ? _raw_spin_unlock+0x2b/0x40
> >  [<ffffffff81121afd>] ? follow_page+0x19d/0x350
> >  [<ffffffff8112639c>] __get_user_pages+0x16c/0x480
> >  [<ffffffff810127c9>] ? sched_clock+0x9/0x10
> >  [<ffffffff811276ef>] __mlock_vma_pages_range+0xef/0x1f0
> >  [<ffffffff81127f01>] mlock_vma_pages_range+0x91/0xa0
> >  [<ffffffff8112ad57>] mmap_region+0x307/0x5b0
> >  [<ffffffff8112b354>] do_mmap_pgoff+0x354/0x3a0
> >  [<ffffffff8112b3fc>] ? sys_mmap_pgoff+0x5c/0x200
> >  [<ffffffff8112b41a>] sys_mmap_pgoff+0x7a/0x200
> >  [<ffffffff814e02f2>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> >  [<ffffffff8100fa09>] sys_mmap+0x29/0x30
> >  [<ffffffff8100b032>] system_call_fastpath+0x16/0x1b
> > Mem-Info:
> > Node 0 DMA per-cpu:
> > CPU    0: hi:    0, btch:   1 usd:   0
> > CPU    1: hi:    0, btch:   1 usd:   0
> > Node 0 DMA32 per-cpu:
> > CPU    0: hi:  186, btch:  31 usd: 140
> > CPU    1: hi:  186, btch:  31 usd:  47
> > active_anon:128 inactive_anon:140 isolated_anon:0
> >  active_file:0 inactive_file:9 isolated_file:0
> >  unevictable:126855 dirty:0 writeback:125 unstable:0
> >  free:1996 slab_reclaimable:4445 slab_unreclaimable:23646
> >  mapped:923 shmem:7 pagetables:778 bounce:0
> > Node 0 DMA free:4032kB min:60kB low:72kB high:88kB active_anon:0kB
> > inactive_anon:0kB active_file:0kB inactive_file:0kB
> > unevictable:11896kB isolated(anon):0kB isolated(file):0kB
> > present:15756kB mlocked:11896kB dirty:0kB writeback:0kB mapped:0kB
> > shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB
> kernel_stack:0kB
> > pagetables:24kB unstable:0kB bounce:0kB writeback_tmp:0kB
> > pages_scanned:0 all_unreclaimable? yes
> > lowmem_reserve[]: 0 994 994 994
> > Node 0 DMA32 free:3952kB min:4000kB low:5000kB high:6000kB
> > active_anon:512kB inactive_anon:560kB active_file:0kB
> > inactive_file:36kB unevictable:495524kB isolated(anon):0kB
> > isolated(file):0kB present:1018060kB mlocked:495524kB dirty:0kB
> > writeback:500kB mapped:3692kB shmem:28kB slab_reclaimable:17780kB
> > slab_unreclaimable:94584kB kernel_stack:1296kB pagetables:3088kB
> > unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1726
> > all_unreclaimable? yes
> > lowmem_reserve[]: 0 0 0 0
> > Node 0 DMA: 0*4kB 2*8kB 1*16kB 1*32kB 2*64kB 2*128kB 2*256kB
> 0*512kB
> > 1*1024kB 1*2048kB 0*4096kB = 4032kB
> > Node 0 DMA32: 476*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB
> > 0*512kB 0*1024kB 1*2048kB 0*4096kB = 3952kB
> > 1146 total pagecache pages
> > 215 pages in swap cache
> > Swap cache stats: add 19633, delete 19418, find 941/1333
> > Free swap  = 2051080kB
> > Total swap = 2064380kB
> > 262138 pages RAM
> > 43914 pages reserved
> > 4832 pages shared
> > 155665 pages non-shared
> > Out of memory: kill process 1727 (console-kit-dae) score 1027939 or
> a
> > child
> > Killed process 1727 (console-kit-dae) vsz:4111756kB, anon-rss:0kB,
> > file-rss:600kB
> > console-kit-dae invoked oom-killer: gfp_mask=0xd0, order=0,
> oom_adj=0
> > console-kit-dae cpuset=/ mems_allowed=0
> > Pid: 1752, comm: console-kit-dae Not tainted 2.6.35-rc5+ #5
> > Call Trace:
> >  [<ffffffff814e10cb>] ? _raw_spin_unlock+0x2b/0x40
> >  [<ffffffff81108520>] dump_header+0x70/0x190
> >  [<ffffffff811086c1>] oom_kill_process+0x81/0x180
> >  [<ffffffff81108c08>] __out_of_memory+0x58/0xd0
> >  [<ffffffff81108ddc>] ? out_of_memory+0x15c/0x1f0
> >  [<ffffffff81108d8f>] out_of_memory+0x10f/0x1f0
> >  [<ffffffff8110cc7f>] __alloc_pages_nodemask+0x7af/0x7c0
> >  [<ffffffff8114522e>] kmem_getpages+0x6e/0x180
> >  [<ffffffff81147d79>] fallback_alloc+0x1c9/0x2b0
> >  [<ffffffff81147602>] ? cache_grow+0x4b2/0x520
> >  [<ffffffff81147a5b>] ____cache_alloc_node+0xab/0x200
> >  [<ffffffff810d55d5>] ? taskstats_exit+0x305/0x3b0
> >  [<ffffffff8114862b>] kmem_cache_alloc+0x1fb/0x290
> >  [<ffffffff810d55d5>] taskstats_exit+0x305/0x3b0
> >  [<ffffffff81063a4b>] do_exit+0x12b/0x890
> >  [<ffffffff810924fd>] ? trace_hardirqs_off+0xd/0x10
> >  [<ffffffff8108641f>] ? cpu_clock+0x6f/0x80
> >  [<ffffffff81095cbd>] ? lock_release_holdtime+0x3d/0x190
> >  [<ffffffff814e1010>] ? _raw_spin_unlock_irq+0x30/0x40
> >  [<ffffffff8106420e>] do_group_exit+0x5e/0xd0
> >  [<ffffffff81075b54>] get_signal_to_deliver+0x2d4/0x490
> >  [<ffffffff811ea6ad>] ? inode_has_perm+0x7d/0xf0
> >  [<ffffffff8100a2e5>] do_signal+0x75/0x7b0
> >  [<ffffffff81169d2d>] ? vfs_ioctl+0x3d/0xf0
> >  [<ffffffff8116a394>] ? do_vfs_ioctl+0x84/0x570
> >  [<ffffffff8100aa85>] do_notify_resume+0x65/0x80
> >  [<ffffffff814e02f2>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> >  [<ffffffff8100b381>] int_signal+0x12/0x17
> > Mem-Info:
> > Node 0 DMA per-cpu:
> > CPU    0: hi:    0, btch:   1 usd:   0
> > CPU    1: hi:    0, btch:   1 usd:   0
> > Node 0 DMA32 per-cpu:
> > CPU    0: hi:  186, btch:  31 usd: 151
> > CPU    1: hi:  186, btch:  31 usd:  61
> > active_anon:128 inactive_anon:165 isolated_anon:0
> >  active_file:0 inactive_file:9 isolated_file:0
> >  unevictable:126855 dirty:0 writeback:25 unstable:0
> >  free:1965 slab_reclaimable:4445 slab_unreclaimable:23646
> >  mapped:923 shmem:7 pagetables:778 bounce:0
> > Node 0 DMA free:4032kB min:60kB low:72kB high:88kB active_anon:0kB
> > inactive_anon:0kB active_file:0kB inactive_file:0kB
> > unevictable:11896kB isolated(anon):0kB isolated(file):0kB
> > present:15756kB mlocked:11896kB dirty:0kB writeback:0kB mapped:0kB
> > shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB
> kernel_stack:0kB
> > pagetables:24kB unstable:0kB bounce:0kB writeback_tmp:0kB
> > pages_scanned:0 all_unreclaimable? yes
> > lowmem_reserve[]: 0 994 994 994
> > Node 0 DMA32 free:3828kB min:4000kB low:5000kB high:6000kB
> > active_anon:512kB inactive_anon:660kB active_file:0kB
> > inactive_file:36kB unevictable:495524kB isolated(anon):0kB
> > isolated(file):0kB present:1018060kB mlocked:495524kB dirty:0kB
> > writeback:100kB mapped:3692kB shmem:28kB slab_reclaimable:17780kB
> > slab_unreclaimable:94584kB kernel_stack:1296kB pagetables:3088kB
> > unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1726
> > all_unreclaimable? yes
> > lowmem_reserve[]: 0 0 0 0
> > Node 0 DMA: 0*4kB 2*8kB 1*16kB 1*32kB 2*64kB 2*128kB 2*256kB
> 0*512kB
> > 1*1024kB 1*2048kB 0*4096kB = 4032kB
> > Node 0 DMA32: 445*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB
> > 0*512kB 0*1024kB 1*2048kB 0*4096kB = 3828kB
> > 1146 total pagecache pages
> > 230 pages in swap cache
> > Swap cache stats: add 19649, delete 19419, find 942/1336
> > Free swap  = 2051084kB
> > Total swap = 2064380kB
> > 262138 pages RAM
> > 43914 pages reserved
> > 4818 pages shared
> > 155685 pages non-shared
> > Out of memory: kill process 1806 (sshd) score 9474 or a child
> > Killed process 1810 (bash) vsz:108384kB, anon-rss:0kB,
> file-rss:656kB
> > console-kit-dae invoked oom-killer: gfp_mask=0xd0, order=0,
> oom_adj=0
> > console-kit-dae cpuset=/ mems_allowed=0
> > Pid: 1752, comm: console-kit-dae Not tainted 2.6.35-rc5+ #5
> > Call Trace:
> >  [<ffffffff814e10cb>] ? _raw_spin_unlock+0x2b/0x40
> >  [<ffffffff81108520>] dump_header+0x70/0x190
> >  [<ffffffff811086c1>] oom_kill_process+0x81/0x180
> >  [<ffffffff81108c08>] __out_of_memory+0x58/0xd0
> >  [<ffffffff81108ddc>] ? out_of_memory+0x15c/0x1f0
> >  [<ffffffff81108d8f>] out_of_memory+0x10f/0x1f0
> >  [<ffffffff8110cc7f>] __alloc_pages_nodemask+0x7af/0x7c0
> >  [<ffffffff8114522e>] kmem_getpages+0x6e/0x180
> >  [<ffffffff81147d79>] fallback_alloc+0x1c9/0x2b0
> >  [<ffffffff81147602>] ? cache_grow+0x4b2/0x520
> >  [<ffffffff81147a5b>] ____cache_alloc_node+0xab/0x200
> >  [<ffffffff810d55d5>] ? taskstats_exit+0x305/0x3b0
> >  [<ffffffff8114862b>] kmem_cache_alloc+0x1fb/0x290
> >  [<ffffffff810d55d5>] taskstats_exit+0x305/0x3b0
> >  [<ffffffff81063a4b>] do_exit+0x12b/0x890
> >  [<ffffffff810924fd>] ? trace_hardirqs_off+0xd/0x10
> >  [<ffffffff8108641f>] ? cpu_clock+0x6f/0x80
> >  [<ffffffff81095cbd>] ? lock_release_holdtime+0x3d/0x190
> >  [<ffffffff814e1010>] ? _raw_spin_unlock_irq+0x30/0x40
> >  [<ffffffff8106420e>] do_group_exit+0x5e/0xd0
> >  [<ffffffff81075b54>] get_signal_to_deliver+0x2d4/0x490
> >  [<ffffffff811ea6ad>] ? inode_has_perm+0x7d/0xf0
> >  [<ffffffff8100a2e5>] do_signal+0x75/0x7b0
> >  [<ffffffff81169d2d>] ? vfs_ioctl+0x3d/0xf0
> >  [<ffffffff8116a394>] ? do_vfs_ioctl+0x84/0x570
> >  [<ffffffff8100aa85>] do_notify_resume+0x65/0x80
> >  [<ffffffff814e02f2>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> >  [<ffffffff8100b381>] int_signal+0x12/0x17
> > Mem-Info:
> > Node 0 DMA per-cpu:
> > CPU    0: hi:    0, btch:   1 usd:   0
> > CPU    1: hi:    0, btch:   1 usd:   0
> > Node 0 DMA32 per-cpu:
> > CPU    0: hi:  186, btch:  31 usd: 119
> > CPU    1: hi:  186, btch:  31 usd:  73
> > active_anon:50 inactive_anon:175 isolated_anon:0
> >  active_file:0 inactive_file:9 isolated_file:0
> >  unevictable:126855 dirty:0 writeback:25 unstable:0
> >  free:1996 slab_reclaimable:4445 slab_unreclaimable:23663
> >  mapped:923 shmem:7 pagetables:778 bounce:0
> > Node 0 DMA free:4032kB min:60kB low:72kB high:88kB active_anon:0kB
> > inactive_anon:0kB active_file:0kB inactive_file:0kB
> > unevictable:11896kB isolated(anon):0kB isolated(file):0kB
> > present:15756kB mlocked:11896kB dirty:0kB writeback:0kB mapped:0kB
> > shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB
> kernel_stack:0kB
> > pagetables:24kB unstable:0kB bounce:0kB writeback_tmp:0kB
> > pages_scanned:0 all_unreclaimable? yes
> > lowmem_reserve[]: 0 994 994 994
> > Node 0 DMA32 free:3952kB min:4000kB low:5000kB high:6000kB
> > active_anon:200kB inactive_anon:700kB active_file:0kB
> > inactive_file:36kB unevictable:495524kB isolated(anon):0kB
> > isolated(file):0kB present:1018060kB mlocked:495524kB dirty:0kB
> > writeback:100kB mapped:3692kB shmem:28kB slab_reclaimable:17780kB
> > slab_unreclaimable:94652kB kernel_stack:1296kB pagetables:3088kB
> > unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1536
> > all_unreclaimable? yes
> > lowmem_reserve[]: 0 0 0 0
> > Node 0 DMA: 0*4kB 2*8kB 1*16kB 1*32kB 2*64kB 2*128kB 2*256kB
> 0*512kB
> > 1*1024kB 1*2048kB 0*4096kB = 4032kB
> > Node 0 DMA32: 470*4kB 3*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB
> > 0*512kB 0*1024kB 1*2048kB 0*4096kB = 3952kB
> > 1146 total pagecache pages
> > 221 pages in swap cache
> > Swap cache stats: add 19848, delete 19627, find 970/1386
> > Free swap  = 2051428kB
> > Total swap = 2064380kB
> > 262138 pages RAM
> > 43914 pages reserved
> > 4669 pages shared
> > 155659 pages non-shared
> > Out of memory: kill process 1829 (usemem) score 8253 or a child
> > Killed process 1829 (usemem) vsz:528224kB, anon-rss:502468kB,
> > file-rss:376kB
> > 
> > # cat usemem.c
> > # cat usemem.c 
> > #include <stdio.h>
> > #include <stdlib.h>
> > #include <string.h>
> > #include <sys/mman.h>
> > #define CHUNKS 32
> > 
> > int 
> > main(int argc, char *argv[])
> > {
> > 	mlockall(MCL_FUTURE);
> > 
> > 	unsigned long mb;
> > 	char *buf[CHUNKS];
> > 	int i;
> > 
> > 	if (argc < 2) {
> > 		fprintf(stderr, "usage: usemem megabytes\n");
> > 		exit(1);
> > 	}
> > 	mb = strtoul(argv[1], NULL, 0);
> > 
> > 	for (i = 0; i < CHUNKS; i++) {
> > 		fprintf(stderr, "%d: Mallocing %lu megabytes\n", i, mb/CHUNKS);
> > 		buf[i] = (char *)malloc(mb/CHUNKS * 1024L * 1024L);
> > 		if (!buf[i]) {
> > 			fprintf(stderr, "malloc failure\n");
> > 			exit(1);
> > 		}
> > 	}
> > 
> > 	for (i = 0; i < CHUNKS; i++) {
> > 		fprintf(stderr, "%d: Zeroing %lu megabytes at %p\n", 
> > 				i, mb/CHUNKS, buf[i]);
> > 		memset(buf[i], 0, mb/CHUNKS * 1024L * 1024L);
> > 	}
> > 
> > 
> > 	exit(0);
> > }
> > 
> If this ever be relevant, this was tested inside the kvm guest. The
> host was a RHEL6 with THP enabled.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
