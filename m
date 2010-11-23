Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3FDB56B0087
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 20:34:10 -0500 (EST)
Date: Mon, 22 Nov 2010 17:34:06 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: Free memory never fully used, swapping
Message-ID: <20101123013406.GC26876@hostway.ca>
References: <20101115195246.GB17387@hostway.ca> <20101122154419.ee0e09d2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101122154419.ee0e09d2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Uploaded a new graph with maybe more useful pixels.
( http://0x.ca/sim/ref/2.6.36/memory_long.png )  Units are day-of-month.

On this same server, dovecot is probably leaking a bit, but it seems to
be backing off on the page cache at the same time.  Disk usage grows all
day and not much is unlink()ed until the middle of the night, so I don't
see any reason things shouldn't stay around in page cache.

We then restarted dovecot (with old processes left around), and it seems
it started swapping to /dev/sda and throwing out pages from running apps
which came from /dev/sda (disks) while churning through mail on /dev/md0
(/dev/sd[bc]) which is SSD.  Killing the old processes seemed to make it
happy to keep enough in page cache again to make /dev/sda idle again.

I guess the vm has no idea about the relative expensiveness of reads from
the SSD versus conventional disks connected to the same box?

Anyway, we turned off swap to try to stop load on /dev/sda.  sysreq-M
showed this sort of output while kswapd was churning, if it helps:

SysRq : Show Memory
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 164
CPU    1: hi:  186, btch:  31 usd: 177
CPU    2: hi:  186, btch:  31 usd: 157
CPU    3: hi:  186, btch:  31 usd: 156
Node 0 Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd:  51
CPU    1: hi:  186, btch:  31 usd: 152
CPU    2: hi:  186, btch:  31 usd:  57
CPU    3: hi:  186, btch:  31 usd: 157
active_anon:102749 inactive_anon:164705 isolated_anon:0
 active_file:117584 inactive_file:132410 isolated_file:0
 unevictable:7155 dirty:64 writeback:18 unstable:0
 free:409953 slab_reclaimable:41904 slab_unreclaimable:10369
 mapped:3980 shmem:698 pagetables:3947 bounce:0
Node 0 DMA free:15904kB min:28kB low:32kB high:40kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15772kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 3251 4009 4009
Node 0 DMA32 free:1477136kB min:6560kB low:8200kB high:9840kB active_anon:351928kB inactive_anon:512024kB active_file:405472kB inactive_file:361028kB unevictable:16kB isolated(anon):0kB isolated(file):0kB present:3329568kB mlocked:16kB dirty:128kB writeback:0kB mapped:9184kB shmem:1584kB slab_reclaimable:153108kB slab_unreclaimable:17180kB kernel_stack:808kB pagetables:5760kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 757 757
Node 0 Normal free:146772kB min:1528kB low:1908kB high:2292kB active_anon:59068kB inactive_anon:146796kB active_file:64864kB inactive_file:168464kB unevictable:28604kB isolated(anon):0kB isolated(file):92kB present:775680kB mlocked:28604kB dirty:128kB writeback:72kB mapped:6736kB shmem:1208kB slab_reclaimable:14508kB slab_unreclaimable:24280kB kernel_stack:1320kB pagetables:10028kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:236 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 2*4kB 1*8kB 1*16kB 2*32kB 1*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15904kB
Node 0 DMA32: 126783*4kB 85660*8kB 13612*16kB 2013*32kB 32*64kB 3*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1477308kB
Node 0 Normal: 19801*4kB 8446*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 146772kB
252045 total pagecache pages
0 pages in swap cache
Swap cache stats: add 10390951, delete 10390951, find 21038039/22538430
Free swap  = 0kB
Total swap = 0kB
1048575 pages RAM
35780 pages reserved
263717 pages shared
455184 pages non-shared

Simon-

On Mon, Nov 22, 2010 at 03:44:19PM -0800, Andrew Morton wrote:

> (cc linux-mm, where all the suckiness ends up)
> 
> On Mon, 15 Nov 2010 11:52:46 -0800
> Simon Kirby <sim@hostway.ca> wrote:
> 
> > Hi!
> > 
> > We're seeing cases on a number of servers where cache never fully grows
> > to use all available memory.  Sometimes we see servers with 4 GB of
> > memory that never seem to have less than 1.5 GB free, even with a
> > constantly-active VM.  In some cases, these servers also swap out while
> > this happens, even though they are constantly reading the working set
> > into memory.  We have been seeing this happening for a long time;
> > I don't think it's anything recent, and it still happens on 2.6.36.
> > 
> > I noticed that CONFIG_NUMA seems to enable some more complicated
> > reclaiming bits and figured it might help since most stock kernels seem
> > to ship with it now.  This seems to have helped, but it may just be
> > wishful thinking.  We still see this happening, though maybe to a lesser
> > degree.  (The following observations are with CONFIG_NUMA enabled.)
> > 
> > I was eyeballing "vmstat 1" and "watch -n.2 -d cat /proc/vmstat" at the
> > same time, and I can see distinctly that the page cache is growing nicely
> > until a sudden event where 400 MB is freed within 1 second, leaving
> > this particular box with 700 MB free again.  kswapd numbers increase in
> > /proc/vmstat, which leads me to believe that __alloc_pages_slowpath() has
> > been called, since it seems to be the thing that wakes up kswapd.
> > 
> > Previous patterns and watching of "vmstat 1" show that the swapping out
> > also seems to occur during the times that memory is quickly freed.
> > 
> > These are all x86_64, and so there is no highmem garbage going on. 
> > The only zones would be for DMA, right?  Is the combination of memory
> > fragmentation and large-order allocations the only thing that would be
> > causing this reclaim here?  Is there some easy bake knob for finding what
> > is causing the free memory jumps each time this happens?
> > 
> > Kernel config and munin graph of free memory here:
> > 
> > http://0x.ca/sim/ref/2.6.36/
> > 
> > I notice CONFIG_COMPACTION is still "EXPERIMENTAL".  Would it be worth
> > trying here?  It seems to enable defrag before reclaim, but that sounds
> > kind of ...complicated...
> > 
> > Cheers,
> > 
> > Simon-
> > 
> > procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
> >  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
> >  1  0  11496 401684  40364 2531844    0    0  4540   773 7890 16291 13  9 77  1
> >  3  0  11492 400180  40372 2534204    0    0  5572   699 8544 14856 25  9 66  1
> >  0  0  11492 394344  40372 2540796    0    0  5256   345 8239 16723 17  7 73  2
> >  0  0  11492 388524  40372 2546236    0    0  5216   393 8687 17289 14  9 76  1
> >  4  1  11684 716296  40244 2218612    0  220  6868  1837 11124 27368 28 20 51  0
> >  1  0  11732 753992  40248 2181468    0  120  5240   647 9542 15609 38 11 50  1
> >  1  0  11712 736864  40260 2197788    0    0  5872  9147 9838 16373 41 11 47  1
> >  0  0  11712 738096  40260 2196984    0    0  4628   493 7980 15536 22 10 67  1
> >  2  0  11712 733508  40260 2201756    0    0  4404   418 7265 16867 10  9 80  2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
